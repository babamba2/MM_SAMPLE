*&---------------------------------------------------------------------*
*& Include ZMMR00080F — FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 — reads ZMMT00220 joined MAKT/LFA1/EORD into gt_srclist
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR gt_srclist.

  SELECT z~matnr, mk~maktx, z~werks, z~lifnr, l~name1,
         z~eval_seq, z~score, z~grade_new,
         z~eval_date, z~next_review,
         e~vdatu AS eord_vlfrom
    FROM zmmt00220 AS z
    LEFT JOIN makt AS mk ON mk~matnr = z~matnr AND mk~spras = @sy-langu
    LEFT JOIN lfa1 AS l  ON l~lifnr  = z~lifnr
    LEFT JOIN eord AS e  ON e~matnr  = z~matnr
                        AND e~werks  = z~werks
                        AND e~lifnr  = z~lifnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_srclist
    WHERE z~matnr IN @s_matnr
      AND z~werks IN @s_werks
      AND z~lifnr IN @s_lifnr.

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
    USING gt_srclist
    CHANGING gt_fcat.

  FIELD-SYMBOLS: <ls_fc> TYPE lvc_s_fcat.

  LOOP AT gt_fcat ASSIGNING <ls_fc>.
    CASE <ls_fc>-fieldname.
      WHEN 'MATNR'.       <ls_fc>-coltext = text-f01. <ls_fc>-outputlen = 18.
      WHEN 'MAKTX'.       <ls_fc>-coltext = text-f02. <ls_fc>-outputlen = 25.
      WHEN 'WERKS'.       <ls_fc>-coltext = text-f03. <ls_fc>-outputlen = 6.
      WHEN 'LIFNR'.       <ls_fc>-coltext = text-f04. <ls_fc>-outputlen = 10.
      WHEN 'NAME1'.       <ls_fc>-coltext = text-f05. <ls_fc>-outputlen = 25.
      WHEN 'EVAL_SEQ'.    <ls_fc>-coltext = text-f06. <ls_fc>-outputlen = 8.
      WHEN 'SCORE'.       <ls_fc>-coltext = text-f07. <ls_fc>-outputlen = 8.
      WHEN 'GRADE_NEW'.   <ls_fc>-coltext = text-f08. <ls_fc>-outputlen = 6.
      WHEN 'EVAL_DATE'.   <ls_fc>-coltext = text-f09. <ls_fc>-outputlen = 10.
      WHEN 'NEXT_REVIEW'. <ls_fc>-coltext = text-f10. <ls_fc>-outputlen = 12.
      WHEN 'EORD_VLFROM'. <ls_fc>-coltext = text-f11. <ls_fc>-outputlen = 12.
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
        it_outtab       = gt_srclist
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
