*&---------------------------------------------------------------------*
*& Include  ZMMR00110F — GI 반품 사유 분석 FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" init_0100 — Initialization: set default date range (current month)
*----------------------------------------------------------------------
FORM init_0100.
  s_budat-sign   = 'I'.
  s_budat-option = 'BT'.
  s_budat-low    = sy-datum(6) && '01'.
  s_budat-high   = sy-datum.
  APPEND s_budat.
ENDFORM.

*----------------------------------------------------------------------
" validate_screen_0100 — Check mandatory selection-screen input
*----------------------------------------------------------------------
FORM validate_screen_0100.
  IF s_budat IS INITIAL.
    MESSAGE text-e01 TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" fetch_data_0100 — Read ZMMT00460 JOIN MSEG + MKPF + MAKT
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR: gt_alv_0100, gv_vendor_fault_cnt, gv_total_claim.

  SELECT z~mblnr, z~mjahr, z~zeile,
         m~matnr, t~maktx, m~werks, m~lgort, m~lifnr,
         z~qty_returned AS return_qty, z~meins,
         z~return_reason AS reason_code, z~vendor_fault,
         z~claim_amount, z~waers,
         k~budat AS return_date
    INTO CORRESPONDING FIELDS OF TABLE @gt_alv_0100
    FROM zmmt00460 AS z
    INNER JOIN mseg AS m ON m~mblnr = z~mblnr
                        AND m~mjahr = z~mjahr
                        AND m~zeile = z~zeile
    INNER JOIN mkpf AS k ON k~mblnr = z~mblnr
                        AND k~mjahr = z~mjahr
    INNER JOIN makt AS t ON t~matnr = m~matnr
                        AND t~spras = @sy-langu
    WHERE k~budat IN @s_budat
      AND m~matnr IN @s_matnr
      AND m~lifnr IN @s_lifnr.
  IF sy-subrc <> 0.
    MESSAGE text-i01 TYPE 'I'.
    RETURN.
  ENDIF.

  " Calculate footer totals
  LOOP AT gt_alv_0100 INTO gs_alv_0100.
    IF gs_alv_0100-vendor_fault = gc_vendor_fault.
      ADD 1 TO gv_vendor_fault_cnt.
    ENDIF.
    ADD gs_alv_0100-claim_amount TO gv_total_claim.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" display_alv_0100 — Setup docking container + ALV grid, call screen
*----------------------------------------------------------------------
FORM display_alv_0100.
  IF gt_alv_0100 IS INITIAL.
    RETURN.
  ENDIF.
  CALL SCREEN gc_screen_0100.
ENDFORM.

*----------------------------------------------------------------------
" f_status_0100 — PBO: set GUI status, title, build ALV
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

    go_alv_grid->set_table_for_first_display(
      EXPORTING is_layout       = ls_layout
      CHANGING  it_fieldcatalog = gt_fieldcat
                it_outtab       = gt_alv_0100 ).
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" user_command_0100 — PAI: handle Back/Exit/Cancel
*----------------------------------------------------------------------
FORM user_command_0100.
  DATA lv_fcode TYPE syucomm.
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
  ENDCASE.
ENDFORM.
