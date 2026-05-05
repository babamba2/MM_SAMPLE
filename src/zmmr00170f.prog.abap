*&---------------------------------------------------------------------*
*& Include ZMMR00170F — FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
* fetch_data_0100 — read ZMMT00390 INNER JOIN MARA + MAKT (primary+alt)
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: lt_sub   TYPE STANDARD TABLE OF zmmt00390 WITH DEFAULT KEY,
        ls_sub   TYPE zmmt00390,
        lt_makt  TYPE STANDARD TABLE OF makt WITH DEFAULT KEY,
        ls_makt  TYPE makt,
        ls_out   TYPE ty_s_output.

  CLEAR gt_output.

  SELECT *
    FROM zmmt00390
    INTO TABLE lt_sub
    WHERE matnr_primary IN s_matnr
      AND matnr_alt     IN s_matnra
      AND werks         IN s_werks.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  " Apply valid filter
  IF p_valid = abap_true.
    DELETE lt_sub WHERE valid_to < sy-datum.
  ENDIF.

  " Collect all material numbers for MAKT read
  DATA lt_matnr TYPE STANDARD TABLE OF matnr WITH DEFAULT KEY.
  LOOP AT lt_sub INTO ls_sub.
    APPEND ls_sub-matnr_primary TO lt_matnr.
    APPEND ls_sub-matnr_alt     TO lt_matnr.
  ENDLOOP.
  SORT lt_matnr.
  DELETE ADJACENT DUPLICATES FROM lt_matnr.

  SELECT matnr maktx
    FROM makt
    INTO TABLE lt_makt
    FOR ALL ENTRIES IN lt_matnr
    WHERE matnr  = lt_matnr-table_line
      AND spras  = sy-langu.

  LOOP AT lt_sub INTO ls_sub.
    CLEAR ls_out.
    ls_out-matnr_primary      = ls_sub-matnr_primary.
    ls_out-matnr_alt          = ls_sub-matnr_alt.
    ls_out-werks              = ls_sub-werks.
    ls_out-substitution_ratio = ls_sub-ratio.
    ls_out-valid_from         = ls_sub-valid_from.
    ls_out-valid_to           = ls_sub-valid_to.
    ls_out-created_by         = ls_sub-created_by.

    READ TABLE lt_makt INTO ls_makt
      WITH KEY matnr = ls_sub-matnr_primary.
    IF sy-subrc = 0.
      ls_out-maktx_primary = ls_makt-maktx.
    ENDIF.

    READ TABLE lt_makt INTO ls_makt
      WITH KEY matnr = ls_sub-matnr_alt.
    IF sy-subrc = 0.
      ls_out-maktx_alt = ls_makt-maktx.
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
* f_user_command_0100 — toolbar actions
*----------------------------------------------------------------------
FORM f_user_command_0100.
  DATA lv_fcode TYPE sy-ucomm.
  lv_fcode = sy-ucomm.
  CLEAR sy-ucomm.

  CASE lv_fcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.
