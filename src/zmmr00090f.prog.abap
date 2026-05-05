*&---------------------------------------------------------------------*
*& Include ZMMR00090F — FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 — reads ZMMT00670 joined LFA1 into gt_vendor
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR gt_vendor.

  SELECT v~lifnr, l~name1, l~land1,
         v~stcd1, v~stcd2,
         v~eval_status, v~int_grade, v~zterm,
         v~created_by, v~created_at
    FROM zmmt00670 AS v
    LEFT JOIN lfa1 AS l ON l~lifnr = v~lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_vendor
    WHERE v~lifnr       IN @s_lifnr
      AND v~eval_status IN @s_status.

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
    USING gt_vendor
    CHANGING gt_fcat.

  FIELD-SYMBOLS: <ls_fc> TYPE lvc_s_fcat.

  LOOP AT gt_fcat ASSIGNING <ls_fc>.
    CASE <ls_fc>-fieldname.
      WHEN 'LIFNR'.       <ls_fc>-coltext = text-f01. <ls_fc>-outputlen = 10.
      WHEN 'NAME1'.       <ls_fc>-coltext = text-f02. <ls_fc>-outputlen = 25.
      WHEN 'LAND1'.       <ls_fc>-coltext = text-f03. <ls_fc>-outputlen = 6.
      WHEN 'STCD1'.       <ls_fc>-coltext = text-f04. <ls_fc>-outputlen = 16.
      WHEN 'STCD2'.       <ls_fc>-coltext = text-f05. <ls_fc>-outputlen = 11.
      WHEN 'EVAL_STATUS'. <ls_fc>-coltext = text-f06. <ls_fc>-outputlen = 12.
      WHEN 'INT_GRADE'.   <ls_fc>-coltext = text-f07. <ls_fc>-outputlen = 8.
      WHEN 'ZTERM'.       <ls_fc>-coltext = text-f08. <ls_fc>-outputlen = 8.
      WHEN 'CREATED_BY'.  <ls_fc>-coltext = text-f09. <ls_fc>-outputlen = 12.
      WHEN 'CREATED_AT'.  <ls_fc>-coltext = text-f10. <ls_fc>-outputlen = 20.
    ENDCASE.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" build_layout_0100 — sets ALV grid layout for screen 0100
*----------------------------------------------------------------------
FORM build_layout_0100.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
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
        it_outtab       = gt_vendor
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
" f_user_command_0100 — handles NEW_VENDOR action and navigation
*----------------------------------------------------------------------
FORM f_user_command_0100.
  CASE sy-ucomm.
    WHEN gc_fc_new_vnd.
      PERFORM show_new_vendor_dialog_0100.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------
" show_new_vendor_dialog_0100 — popup screen 0200 for new vendor input
*----------------------------------------------------------------------
FORM show_new_vendor_dialog_0100.
  DATA: lt_return TYPE TABLE OF bapiret2,
        ls_return TYPE bapiret2,
        lv_lifnr  TYPE lifnr,
        lv_status TYPE c LENGTH 1.

  CLEAR: gv_dlg_lifnr, gv_dlg_name1, gv_dlg_land1, gv_dlg_bukrs.

  CALL SCREEN 200 STARTING AT 10 5
                  ENDING   AT 60 15.

  IF gv_dlg_name1 IS INITIAL.
    RETURN.
  ENDIF.

  CALL FUNCTION 'ZMMFM_VENDOR_ONBOARD'
    EXPORTING
      iv_lifnr = gv_dlg_lifnr
      iv_name1 = gv_dlg_name1
      iv_land1 = gv_dlg_land1
      iv_bukrs = gv_dlg_bukrs
    IMPORTING
      ev_lifnr  = lv_lifnr
      ev_status = lv_status
    TABLES
      et_return = lt_return
    EXCEPTIONS
      validation_failed = 1
      bapi_error        = 2
      update_failed     = 3
      OTHERS            = 4.

  IF sy-subrc = 0.
    MESSAGE s000(00) WITH text-m01 lv_lifnr.
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
