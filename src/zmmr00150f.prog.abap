*&---------------------------------------------------------------------*
*& Include  ZMMR00150F — Cycle Count 차이 리포트 FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" init_0100 — Initialization: default count date range
*----------------------------------------------------------------------
FORM init_0100.
  s_cntdat-sign   = 'I'.
  s_cntdat-option = 'BT'.
  s_cntdat-low    = sy-datum(6) && '01'.
  s_cntdat-high   = sy-datum.
  APPEND s_cntdat.
ENDFORM.

*----------------------------------------------------------------------
" validate_screen_0100 — at least one selection criterion required
*----------------------------------------------------------------------
FORM validate_screen_0100.
  IF s_cntdat IS INITIAL AND s_matnr IS INITIAL AND s_werks IS INITIAL.
    MESSAGE text-e01 TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" fetch_data_0100 — Read ZMMT00500 JOIN MAKT
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR: gt_alv_0100, gv_unposted_cnt.

  SELECT z~count_doc, z~matnr, t~maktx, z~werks, z~lgort,
         z~qty_system   AS system_qty,
         z~qty_counted  AS counted_qty,
         z~qty_diff     AS diff_qty,
         z~meins,
         z~diff_reason  AS reason,
         z~adjustment_posted,
         z~count_date   AS post_date,
         z~counter      AS usnam
    INTO CORRESPONDING FIELDS OF TABLE @gt_alv_0100
    FROM zmmt00500 AS z
    INNER JOIN makt AS t ON t~matnr = z~matnr
                        AND t~spras = @sy-langu
    WHERE z~matnr      IN @s_matnr
      AND z~werks      IN @s_werks
      AND z~lgort      IN @s_lgort
      AND z~count_date IN @s_cntdat.
  IF sy-subrc <> 0.
    MESSAGE text-i01 TYPE 'I'.
    RETURN.
  ENDIF.

  " Apply variance% filter and calculate variance_pct; count unposted
  DATA lt_filtered TYPE STANDARD TABLE OF ty_alv_0100.
  LOOP AT gt_alv_0100 INTO gs_alv_0100.
    IF gs_alv_0100-system_qty <> 0.
      gs_alv_0100-variance_pct =
        ABS( gs_alv_0100-diff_qty ) / ABS( gs_alv_0100-system_qty ) * 100.
    ELSE.
      gs_alv_0100-variance_pct = 0.
    ENDIF.
    IF gs_alv_0100-variance_pct >= p_var.
      IF gs_alv_0100-adjustment_posted <> gc_adj_posted.
        ADD 1 TO gv_unposted_cnt.
      ENDIF.
      APPEND gs_alv_0100 TO lt_filtered.
    ENDIF.
  ENDLOOP.
  gt_alv_0100 = lt_filtered.
ENDFORM.

*----------------------------------------------------------------------
" display_alv_0100 — call screen if data present
*----------------------------------------------------------------------
FORM display_alv_0100.
  IF gt_alv_0100 IS INITIAL.
    RETURN.
  ENDIF.
  CALL SCREEN gc_screen_0100.
ENDFORM.

*----------------------------------------------------------------------
" f_status_0100 — PBO: build ALV with action button (box selection)
*----------------------------------------------------------------------
FORM f_status_0100.
  SET PF-STATUS gc_status_0100.
  SET TITLEBAR 'T01'.

  IF go_docking IS INITIAL.
    CREATE OBJECT go_docking
      EXPORTING side  = cl_gui_docking_container=>dock_at_bottom
                ratio = 90.
    CREATE OBJECT go_alv_grid
      EXPORTING i_parent = go_docking.

    PERFORM convert_fcat_data_grid
      USING    gt_alv_0100
      CHANGING gt_fieldcat.
    PERFORM modify_fcat_data_grid1_0100 CHANGING gt_fieldcat.

    DATA ls_layout TYPE lvc_s_layo.
    ls_layout-zebra      = abap_true.
    ls_layout-sel_mode   = 'A'.
    ls_layout-cwidth_opt = abap_true.
    ls_layout-box_fname  = 'SEL_FLAG'.

    go_alv_grid->set_table_for_first_display(
      EXPORTING is_layout       = ls_layout
      CHANGING  it_fieldcatalog = gt_fieldcat
                it_outtab       = gt_alv_0100 ).
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" user_command_0100 — PAI: handle Back/Exit/Cancel + Recount action
*----------------------------------------------------------------------
FORM user_command_0100.
  DATA lv_fcode TYPE syucomm.
  DATA lt_rows  TYPE lvc_t_row.

  lv_fcode = sy-ucomm.
  CLEAR sy-ucomm.

  CASE lv_fcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF go_docking IS NOT INITIAL.
        go_docking->free( ).
        FREE go_docking.
        FREE go_alv_grid.
      ENDIF.
      LEAVE TO SCREEN 0.

    WHEN gc_fcode_recount.
      go_alv_grid->get_selected_rows( IMPORTING et_index_rows = lt_rows ).
      IF lt_rows IS INITIAL.
        MESSAGE text-w01 TYPE 'W'.
        RETURN.
      ENDIF.
      PERFORM process_recount_0100 USING lt_rows.
      go_alv_grid->refresh_table_display( ).
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------
" process_recount_0100 — Call ZMMFM_STOCK_RECOUNT for selected rows
*----------------------------------------------------------------------
FORM process_recount_0100 USING pt_rows TYPE lvc_t_row.
  DATA ls_return TYPE bapiret2.
  DATA lt_return TYPE TABLE OF bapiret2.
  DATA lv_mblnr  TYPE mblnr.
  DATA lv_docvar TYPE p LENGTH 8 DECIMALS 2.

  LOOP AT pt_rows INTO DATA(ls_row).
    READ TABLE gt_alv_0100 INTO gs_alv_0100 INDEX ls_row-index.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    IF gs_alv_0100-adjustment_posted = gc_adj_posted.
      CONTINUE.
    ENDIF.

    CLEAR: lt_return, lv_mblnr, lv_docvar.
    CALL FUNCTION 'ZMMFM_STOCK_RECOUNT'
      EXPORTING
        iv_matnr      = gs_alv_0100-matnr
        iv_werks      = gs_alv_0100-werks
        iv_lgort      = gs_alv_0100-lgort
        iv_actual_qty = gs_alv_0100-counted_qty
        iv_meins      = gs_alv_0100-meins
      IMPORTING
        ev_mblnr      = lv_mblnr
        ev_variance   = lv_docvar
      TABLES
        et_return     = lt_return
      EXCEPTIONS
        not_authorized = 1
        posting_failed = 2
        OTHERS         = 3.
    CASE sy-subrc.
      WHEN 0.
        gs_alv_0100-adjustment_posted = gc_adj_posted.
        gs_alv_0100-post_date         = sy-datum.
        gs_alv_0100-usnam             = sy-uname.
        MODIFY gt_alv_0100 FROM gs_alv_0100 INDEX ls_row-index.
        MESSAGE text-s01 TYPE 'S'.
      WHEN 1.
        MESSAGE text-e02 TYPE 'E'.
        RETURN.
      WHEN 2.
        READ TABLE lt_return INTO ls_return INDEX 1.
        IF sy-subrc = 0.
          MESSAGE ls_return-message TYPE 'E'.
        ENDIF.
        RETURN.
      WHEN OTHERS.
        MESSAGE text-e03 TYPE 'E'.
        RETURN.
    ENDCASE.
  ENDLOOP.

  gv_unposted_cnt = 0.
  LOOP AT gt_alv_0100 INTO gs_alv_0100.
    IF gs_alv_0100-adjustment_posted <> gc_adj_posted.
      ADD 1 TO gv_unposted_cnt.
    ENDIF.
  ENDLOOP.
ENDFORM.
