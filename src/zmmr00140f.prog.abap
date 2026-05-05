*&---------------------------------------------------------------------*
*& Include  ZMMR00140F — 재고 노화 리포트 FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" init_0100 — Initialization: current year/month defaults
*----------------------------------------------------------------------
FORM init_0100.
  p_year  = sy-datum(4).
  p_month = sy-datum+4(2).
ENDFORM.

*----------------------------------------------------------------------
" validate_screen_0100 — year and month mandatory
*----------------------------------------------------------------------
FORM validate_screen_0100.
  IF p_year IS INITIAL OR p_month IS INITIAL.
    MESSAGE text-e01 TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" fetch_data_0100 — Read ZMMT00490 JOIN MAKT; derive AGING_BAND
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR: gt_alv_0100, gv_total_value.

  SELECT z~matnr, t~maktx, z~werks, z~lgort,
         z~snap_year, z~snap_month,
         z~abc_class,
         z~qty_total AS stock_qty,
         z~value_total AS stock_value, z~waers,
         z~days_since_movement
    INTO TABLE @DATA(lt_raw)
    FROM zmmt00490 AS z
    INNER JOIN makt AS t ON t~matnr = z~matnr
                        AND t~spras = @sy-langu
    WHERE z~matnr      IN @s_matnr
      AND z~werks      IN @s_werks
      AND z~lgort      IN @s_lgort
      AND z~snap_year   = @p_year
      AND z~snap_month  = @p_month
      AND z~abc_class  IN @s_abc.
  IF sy-subrc <> 0.
    MESSAGE text-i01 TYPE 'I'.
    RETURN.
  ENDIF.

  " Derive AGING_BAND and LAST_MOVEMENT_DATE
  LOOP AT lt_raw INTO DATA(ls_raw).
    CLEAR gs_alv_0100.
    MOVE-CORRESPONDING ls_raw TO gs_alv_0100.
    IF ls_raw-days_since_movement <= 30.
      gs_alv_0100-aging_band = gc_band_0_30.
    ELSEIF ls_raw-days_since_movement <= 90.
      gs_alv_0100-aging_band = gc_band_31_90.
    ELSEIF ls_raw-days_since_movement <= 180.
      gs_alv_0100-aging_band = gc_band_91_180.
    ELSEIF ls_raw-days_since_movement <= 365.
      gs_alv_0100-aging_band = gc_band_181_365.
    ELSE.
      gs_alv_0100-aging_band = gc_band_365p.
    ENDIF.
    gs_alv_0100-last_movement_date = sy-datum - ls_raw-days_since_movement.
    ADD gs_alv_0100-stock_value TO gv_total_value.
    APPEND gs_alv_0100 TO gt_alv_0100.
  ENDLOOP.
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
" f_status_0100 — PBO: build ALV with subtotals by AGING_BAND
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

    " Sort + subtotal by AGING_BAND
    DATA lt_sort TYPE lvc_t_sort.
    DATA ls_sort TYPE lvc_s_sort.
    ls_sort-fieldname = 'AGING_BAND'.
    ls_sort-up        = abap_true.
    ls_sort-subtot    = abap_true.
    APPEND ls_sort TO lt_sort.

    go_alv_grid->set_table_for_first_display(
      EXPORTING is_layout       = ls_layout
      CHANGING  it_fieldcatalog = gt_fieldcat
                it_outtab       = gt_alv_0100
                it_sort         = lt_sort ).
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
