*&---------------------------------------------------------------------*
*& Include ZMMR00180F — FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
* fetch_data_0100 — read ZMMT00680 LEFT JOIN MARA + MAKT
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: lt_plm  TYPE STANDARD TABLE OF zmmt00680 WITH DEFAULT KEY,
        ls_plm  TYPE zmmt00680,
        lt_makt TYPE STANDARD TABLE OF makt WITH DEFAULT KEY,
        ls_makt TYPE makt,
        ls_out  TYPE ty_s_output.

  CLEAR gt_output.

  SELECT *
    FROM zmmt00680
    INTO TABLE lt_plm
    WHERE matnr         IN s_matnr
      AND design_status IN s_dsn.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  SELECT matnr maktx
    FROM makt
    INTO TABLE lt_makt
    FOR ALL ENTRIES IN lt_plm
    WHERE matnr = lt_plm-matnr
      AND spras = sy-langu.

  LOOP AT lt_plm INTO ls_plm.
    CLEAR ls_out.
    ls_out-sel           = space.
    ls_out-matnr         = ls_plm-matnr.
    ls_out-design_status = ls_plm-design_status.
    ls_out-revision      = ls_plm-revision.
    ls_out-draw_url      = ls_plm-draw_url.
    ls_out-plm_guid      = ls_plm-plm_guid.
    ls_out-last_sync_ts  = ls_plm-last_sync_ts.

    CASE ls_plm-design_status.
      WHEN gc_dsn_draft.
        ls_out-dsn_stat_txt = text-v01.
      WHEN gc_dsn_released.
        ls_out-dsn_stat_txt = text-v02.
      WHEN gc_dsn_obsolete.
        ls_out-dsn_stat_txt = text-v03.
      WHEN OTHERS.
        ls_out-dsn_stat_txt = ls_plm-design_status.
    ENDCASE.

    IF ls_plm-draw_url IS NOT INITIAL.
      ls_out-has_drawing = gc_has_draw_yes.
    ELSE.
      ls_out-has_drawing = gc_has_draw_no.
    ENDIF.

    READ TABLE lt_makt INTO ls_makt
      WITH KEY matnr = ls_plm-matnr.
    IF sy-subrc = 0.
      ls_out-maktx = ls_makt-maktx.
    ENDIF.

    APPEND ls_out TO gt_output.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
* display_alv_0100 — call screen
*----------------------------------------------------------------------
FORM display_alv_0100.
  CHECK gt_output IS NOT INITIAL.
  CALL SCREEN 100.
ENDFORM.

*----------------------------------------------------------------------
* f_status_0100 — set GUI status
*----------------------------------------------------------------------
FORM f_status_0100.
  SET PF-STATUS gc_status_0100.
  SET TITLEBAR 't01'.
ENDFORM.

*----------------------------------------------------------------------
* f_modify_screen_0100 — build ALV on first paint
*----------------------------------------------------------------------
FORM f_modify_screen_0100.
  DATA: lt_fcat   TYPE lvc_t_fcat,
        ls_layout TYPE lvc_s_layo.

  CHECK go_alv IS INITIAL.

  CREATE OBJECT go_container
    EXPORTING
      side  = cl_gui_docking_container=>dock_at_bottom
      ratio = 85.

  PERFORM convert_fcat_data_grid
    USING    gt_output
    CHANGING lt_fcat.

  PERFORM modify_fcat_data_grid1_0100
    CHANGING lt_fcat.

  PERFORM build_layout_0100
    CHANGING ls_layout.

  CREATE OBJECT go_alv
    EXPORTING i_parent = go_container.

  CALL METHOD go_alv->set_table_for_first_display
    EXPORTING is_layout       = ls_layout
    CHANGING  it_outtab       = gt_output
              it_fieldcatalog = lt_fcat.
ENDFORM.

*----------------------------------------------------------------------
* f_user_command_0100 — handle PLM_RESEND and standard exits
*----------------------------------------------------------------------
FORM f_user_command_0100.
  DATA lv_fcode TYPE sy-ucomm.
  lv_fcode = sy-ucomm.
  CLEAR sy-ucomm.

  CASE lv_fcode.
    WHEN gc_fcode_resend.
      PERFORM f_plm_resend_0100.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.

*----------------------------------------------------------------------
* f_plm_resend_0100 — call ZMMFM_PLM_MAT_OUT for selected materials
*----------------------------------------------------------------------
FORM f_plm_resend_0100.
  DATA: ls_out    TYPE ty_s_output,
        lt_return TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY,
        lv_count  TYPE i.

  CALL METHOD go_alv->check_changed_data.

  LOOP AT gt_output INTO ls_out
    WHERE sel = abap_true.

    CLEAR lt_return.
    CALL FUNCTION 'ZMMFM_PLM_MAT_OUT'
      EXPORTING
        iv_matnr  = ls_out-matnr
      IMPORTING
        ev_count  = lv_count
      TABLES
        et_return = lt_return.
    IF sy-subrc <> 0.
      MESSAGE w001(00) WITH ls_out-matnr text-m03.
    ENDIF.
  ENDLOOP.

  MESSAGE s001(00) WITH text-m04.
  PERFORM fetch_data_0100.
  CALL METHOD go_alv->refresh_table_display.
ENDFORM.
