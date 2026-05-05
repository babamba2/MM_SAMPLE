*&---------------------------------------------------------------------*
*& Include ZMMR00060F — FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 — reads ZMMT00180 joined LFA1/T001 into gt_kpi
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: lv_year  TYPE numc4,
        lv_month TYPE numc2.

  lv_year  = p_year.
  lv_month = p_month.

  CLEAR gt_kpi.

  SELECT k~lifnr, l~name1, k~bukrs, t~butxt,
         k~kpi_year, k~kpi_month,
         k~otd_rate, k~quality_rate, k~claim_count,
         k~lead_time_avg, k~po_count, k~po_amount, k~waers
    FROM zmmt00180 AS k
    LEFT JOIN lfa1  AS l ON l~lifnr = k~lifnr
    LEFT JOIN t001  AS t ON t~bukrs = k~bukrs
    INTO CORRESPONDING FIELDS OF TABLE @gt_kpi
    WHERE k~lifnr   IN @s_lifnr
      AND k~kpi_year  = @lv_year
      AND k~kpi_month = @lv_month.

  IF sy-subrc <> 0.
    MESSAGE s000(00) WITH text-e01.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" convert_fcat_data_grid — SALV factory → LVC_T_FCAT
*----------------------------------------------------------------------
FORM convert_fcat_data_grid USING pt_table TYPE STANDARD TABLE
                          CHANGING pt_fcat  TYPE lvc_t_fcat.
  DATA lo_table TYPE REF TO data.
  CREATE DATA lo_table LIKE pt_table.
  ASSIGN lo_table->* TO FIELD-SYMBOL(<fo_table>).
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_salv)
        CHANGING  t_table      = <fo_table> ).
      pt_fcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
        r_columns      = lo_salv->get_columns( )
        r_aggregations = lo_salv->get_aggregations( ) ).
    CATCH cx_root.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------
" build_fcat_0100 — adjusts field catalog for screen 0100
*----------------------------------------------------------------------
FORM build_fcat_0100.
  PERFORM convert_fcat_data_grid
    USING gt_kpi
    CHANGING gt_fcat.

  FIELD-SYMBOLS: <ls_fc> TYPE lvc_s_fcat.

  LOOP AT gt_fcat ASSIGNING <ls_fc>.
    CASE <ls_fc>-fieldname.
      WHEN 'LIFNR'.       <ls_fc>-coltext = text-f01. <ls_fc>-outputlen = 10.
      WHEN 'NAME1'.       <ls_fc>-coltext = text-f02. <ls_fc>-outputlen = 30.
      WHEN 'BUKRS'.       <ls_fc>-coltext = text-f03. <ls_fc>-outputlen = 6.
      WHEN 'BUTXT'.       <ls_fc>-coltext = text-f04. <ls_fc>-outputlen = 20.
      WHEN 'KPI_YEAR'.    <ls_fc>-coltext = text-f05. <ls_fc>-outputlen = 6.
      WHEN 'KPI_MONTH'.   <ls_fc>-coltext = text-f06. <ls_fc>-outputlen = 5.
      WHEN 'OTD_RATE'.    <ls_fc>-coltext = text-f07. <ls_fc>-outputlen = 8.  <ls_fc>-do_sum = abap_true.
      WHEN 'QUALITY_RATE'.<ls_fc>-coltext = text-f08. <ls_fc>-outputlen = 8.  <ls_fc>-do_sum = abap_true.
      WHEN 'CLAIM_COUNT'. <ls_fc>-coltext = text-f09. <ls_fc>-outputlen = 8.  <ls_fc>-do_sum = abap_true.
      WHEN 'LEAD_TIME_AVG'.<ls_fc>-coltext = text-f10. <ls_fc>-outputlen = 8. <ls_fc>-do_sum = abap_true.
      WHEN 'PO_COUNT'.    <ls_fc>-coltext = text-f11. <ls_fc>-outputlen = 8.  <ls_fc>-do_sum = abap_true.
      WHEN 'PO_AMOUNT'.   <ls_fc>-coltext = text-f12. <ls_fc>-outputlen = 12. <ls_fc>-do_sum = abap_true.
                          <ls_fc>-cfieldname = 'WAERS'.
      WHEN 'WAERS'.       <ls_fc>-coltext = text-f13. <ls_fc>-outputlen = 5.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" build_layout_0100 — sets ALV grid layout for screen 0100
*----------------------------------------------------------------------
FORM build_layout_0100.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-totals_bef = abap_true.
ENDFORM.

*----------------------------------------------------------------------
" display_alv_0100 — creates Docking + ALV grid on screen 0100
*----------------------------------------------------------------------
FORM display_alv_0100.
  IF go_dock IS INITIAL.
    CREATE OBJECT go_dock
      EXPORTING
        ratio = 90.

    CREATE OBJECT go_alv
      EXPORTING
        i_parent = go_dock.

    PERFORM build_fcat_0100.
    PERFORM build_layout_0100.

    go_alv->set_table_for_first_display(
      EXPORTING
        is_layout       = gs_layout
      CHANGING
        it_outtab       = gt_kpi
        it_fieldcatalog = gt_fcat ).
  ELSE.
    go_alv->refresh_table_display( ).
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" f_status_0100 — sets GUI status for screen 0100
*----------------------------------------------------------------------
FORM f_status_0100.
  SET PF-STATUS gc_status_0100.
  SET TITLEBAR 't01'.
ENDFORM.

*----------------------------------------------------------------------
" f_user_command_0100 — handles user commands from screen 0100
*----------------------------------------------------------------------
FORM f_user_command_0100.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.
