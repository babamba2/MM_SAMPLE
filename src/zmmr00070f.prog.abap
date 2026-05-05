*&---------------------------------------------------------------------*
*& Include ZMMR00070F — FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 — reads ZMMT00190 joined LFA1 into gt_eval
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR gt_eval.

  SELECT e~lifnr, l~name1,
         e~eval_id, e~eval_type,
         e~eval_score, e~eval_grade, e~prev_grade,
         e~remark, e~action_required, e~evaluator,
         e~created_at
    FROM zmmt00190 AS e
    LEFT JOIN lfa1 AS l ON l~lifnr = e~lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_eval
    WHERE e~lifnr          IN @s_lifnr
      AND e~eval_period_from IN @s_evdate.

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
    USING gt_eval
    CHANGING gt_fcat.

  FIELD-SYMBOLS: <ls_fc> TYPE lvc_s_fcat.

  LOOP AT gt_fcat ASSIGNING <ls_fc>.
    CASE <ls_fc>-fieldname.
      WHEN 'LIFNR'.           <ls_fc>-coltext = text-f01. <ls_fc>-outputlen = 10.
      WHEN 'NAME1'.           <ls_fc>-coltext = text-f02. <ls_fc>-outputlen = 25.
      WHEN 'EVAL_ID'.         <ls_fc>-coltext = text-f03. <ls_fc>-outputlen = 12.
      WHEN 'EVAL_TYPE'.       <ls_fc>-coltext = text-f04. <ls_fc>-outputlen = 8.
      WHEN 'EVAL_SCORE'.      <ls_fc>-coltext = text-f05. <ls_fc>-outputlen = 8.
      WHEN 'EVAL_GRADE'.      <ls_fc>-coltext = text-f06. <ls_fc>-outputlen = 6.
      WHEN 'PREV_GRADE'.      <ls_fc>-coltext = text-f07. <ls_fc>-outputlen = 8.
      WHEN 'REMARK'.          <ls_fc>-coltext = text-f08. <ls_fc>-outputlen = 30.
      WHEN 'ACTION_REQUIRED'. <ls_fc>-coltext = text-f09. <ls_fc>-outputlen = 6.
      WHEN 'EVALUATOR'.       <ls_fc>-coltext = text-f10. <ls_fc>-outputlen = 12.
      WHEN 'CREATED_AT'.      <ls_fc>-coltext = text-f11. <ls_fc>-outputlen = 20.
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
        it_outtab       = gt_eval
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
