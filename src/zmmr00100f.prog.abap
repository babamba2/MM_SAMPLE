*&---------------------------------------------------------------------*
*& Include ZMMR00100F — FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 — reads ZMMT00280 joined MKPF/MSEG/MAKT into gt_gr_disc
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR gt_gr_disc.

  SELECT z~mblnr, z~mjahr, z~zeile,
         s~matnr, mk~maktx,
         s~werks, s~lgort,
         z~qty_expected, z~qty_received, z~qty_diff,
         z~meins, z~disposition,
         s~lifnr, h~budat
    FROM zmmt00280 AS z
    INNER JOIN mkpf AS h ON h~mblnr = z~mblnr AND h~mjahr = z~mjahr
    INNER JOIN mseg AS s ON s~mblnr = z~mblnr
                        AND s~mjahr = z~mjahr
                        AND s~zeile = z~zeile
    LEFT JOIN makt AS mk ON mk~matnr = s~matnr AND mk~spras = @sy-langu
    INTO CORRESPONDING FIELDS OF TABLE @gt_gr_disc
    WHERE s~werks  IN @s_werks
      AND h~budat  IN @s_budat
      AND s~matnr  IN @s_matnr.

  IF sy-subrc <> 0.
    MESSAGE s000(00) WITH text-e01.
    RETURN.
  ENDIF.

  " Filter to discrepancies only if checkbox is selected
  IF p_discr = abap_true.
    DELETE gt_gr_disc WHERE qty_diff = 0.
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
    USING gt_gr_disc
    CHANGING gt_fcat.

  FIELD-SYMBOLS: <ls_fc> TYPE lvc_s_fcat.

  LOOP AT gt_fcat ASSIGNING <ls_fc>.
    CASE <ls_fc>-fieldname.
      WHEN 'MBLNR'.        <ls_fc>-coltext = text-f01. <ls_fc>-outputlen = 10.
      WHEN 'MJAHR'.        <ls_fc>-coltext = text-f02. <ls_fc>-outputlen = 6.
      WHEN 'ZEILE'.        <ls_fc>-coltext = text-f03. <ls_fc>-outputlen = 6.
      WHEN 'MATNR'.        <ls_fc>-coltext = text-f04. <ls_fc>-outputlen = 18.
      WHEN 'MAKTX'.        <ls_fc>-coltext = text-f05. <ls_fc>-outputlen = 25.
      WHEN 'WERKS'.        <ls_fc>-coltext = text-f06. <ls_fc>-outputlen = 6.
      WHEN 'LGORT'.        <ls_fc>-coltext = text-f07. <ls_fc>-outputlen = 6.
      WHEN 'QTY_EXPECTED'. <ls_fc>-coltext = text-f08. <ls_fc>-outputlen = 12. <ls_fc>-do_sum = abap_true.
      WHEN 'QTY_RECEIVED'. <ls_fc>-coltext = text-f09. <ls_fc>-outputlen = 12. <ls_fc>-do_sum = abap_true.
      WHEN 'QTY_DIFF'.     <ls_fc>-coltext = text-f10. <ls_fc>-outputlen = 12. <ls_fc>-do_sum = abap_true.
      WHEN 'MEINS'.        <ls_fc>-coltext = text-f11. <ls_fc>-outputlen = 6.
      WHEN 'DISPOSITION'.  <ls_fc>-coltext = text-f12. <ls_fc>-outputlen = 8.
      WHEN 'LIFNR'.        <ls_fc>-coltext = text-f13. <ls_fc>-outputlen = 10.
      WHEN 'BUDAT'.        <ls_fc>-coltext = text-f14. <ls_fc>-outputlen = 10.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" build_layout_0100 — sets ALV grid layout for screen 0100
*----------------------------------------------------------------------
FORM build_layout_0100.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-box_fname  = 'SEL'.
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
        it_outtab       = gt_gr_disc
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
" f_user_command_0100 — handles WMS_SEND action and navigation
*----------------------------------------------------------------------
FORM f_user_command_0100.
  DATA: lt_return TYPE TABLE OF bapiret2,
        ls_return TYPE bapiret2,
        lv_count  TYPE i,
        lv_status TYPE c LENGTH 1.

  CASE sy-ucomm.
    WHEN gc_fc_wms_send.
      PERFORM send_wms_0100.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------
" send_wms_0100 — calls ZMMFM_WMS_GR_OUT for selected rows
*----------------------------------------------------------------------
FORM send_wms_0100.
  DATA: lt_return TYPE TABLE OF bapiret2,
        ls_return TYPE bapiret2,
        lv_count  TYPE i,
        lv_status TYPE c LENGTH 1.

  CALL FUNCTION 'ZMMFM_WMS_GR_OUT'
    IMPORTING
      ev_count  = lv_count
      ev_status = lv_status
    TABLES
      et_return = lt_return
    EXCEPTIONS
      validation_failed = 1
      bapi_error        = 2
      OTHERS            = 3.

  IF sy-subrc = 0.
    MESSAGE s000(00) WITH text-m01 lv_count.
    PERFORM fetch_data_0100.
    IF go_alv IS NOT INITIAL.
      go_alv->refresh_table_display( ).
    ENDIF.
  ELSE.
    READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      MESSAGE e000(00) WITH ls_return-message.
    ENDIF.
  ENDIF.
ENDFORM.
