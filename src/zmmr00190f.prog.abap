*&---------------------------------------------------------------------*
*& Include ZMMR00190F — FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
* fetch_data_0100 — read ZMMT00430 INNER JOIN MARA + MAKT
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: lt_comp  TYPE STANDARD TABLE OF zmmt00430 WITH DEFAULT KEY,
        ls_comp  TYPE zmmt00430,
        lt_makt  TYPE STANDARD TABLE OF makt WITH DEFAULT KEY,
        ls_makt  TYPE makt,
        ls_out   TYPE ty_s_output,
        lv_diff  TYPE i.

  CLEAR: gt_output, gv_expiry_cnt.

  SELECT *
    FROM zmmt00430
    INTO TABLE lt_comp
    WHERE matnr IN s_matnr.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  " Apply regulation filter
  IF p_reg <> gc_reg_all.
    DELETE lt_comp WHERE regulation <> p_reg.
  ENDIF.

  " Read MAKT
  SELECT matnr maktx
    FROM makt
    INTO TABLE lt_makt
    FOR ALL ENTRIES IN lt_comp
    WHERE matnr = lt_comp-matnr
      AND spras = sy-langu.

  LOOP AT lt_comp INTO ls_comp.
    CLEAR ls_out.
    ls_out-matnr             = ls_comp-matnr.
    ls_out-regulation        = ls_comp-regulation.
    ls_out-check_seq         = ls_comp-check_seq.
    ls_out-cert_id           = ls_comp-certificate_id.
    ls_out-cert_valid_from   = ls_comp-issue_date.
    ls_out-cert_valid_to     = ls_comp-expiry_date.
    ls_out-substance_list    = ls_comp-substance_list.
    ls_out-cert_verif_status = ls_comp-compliance_status.

    " Calculate days to expiry
    IF ls_comp-expiry_date IS NOT INITIAL.
      lv_diff = ls_comp-expiry_date - sy-datum.
      ls_out-days_to_expiry = lv_diff.
      IF lv_diff <= p_expire.
        gv_expiry_cnt = gv_expiry_cnt + 1.
      ENDIF.
    ENDIF.

    READ TABLE lt_makt INTO ls_makt
      WITH KEY matnr = ls_comp-matnr.
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

  " Show footer: expiry count
  WRITE: / text-f11, gv_expiry_cnt.
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
