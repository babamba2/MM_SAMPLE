*&---------------------------------------------------------------------*
*& Include ZMMR00200F — FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
* fetch_data_0100 — read ZMMT00210 INNER JOIN EINA/EINE/MARA/LFA1
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: lt_chg   TYPE STANDARD TABLE OF zmmt00210 WITH DEFAULT KEY,
        ls_chg   TYPE zmmt00210,
        lt_eina  TYPE STANDARD TABLE OF eina WITH DEFAULT KEY,
        ls_eina  TYPE eina,
        lt_makt  TYPE STANDARD TABLE OF makt WITH DEFAULT KEY,
        ls_makt  TYPE makt,
        lt_eine  TYPE STANDARD TABLE OF eine WITH DEFAULT KEY,
        ls_eine  TYPE eine,
        lt_lfa1  TYPE STANDARD TABLE OF lfa1 WITH DEFAULT KEY,
        ls_lfa1  TYPE lfa1,
        ls_out   TYPE ty_s_output.

  CLEAR gt_output.

  " Read EINA for info records matching selection
  SELECT *
    FROM eina
    INTO TABLE lt_eina
    WHERE infnr IN s_infnr
      AND matnr IN s_matnr
      AND lifnr IN s_lifnr.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  " Read EINE for purchasing org
  SELECT *
    FROM eine
    INTO TABLE lt_eine
    FOR ALL ENTRIES IN lt_eina
    WHERE infnr = lt_eina-infnr.

  " Read ZMMT00210 change log
  SELECT *
    FROM zmmt00210
    INTO TABLE lt_chg
    FOR ALL ENTRIES IN lt_eina
    WHERE infnr = lt_eina-infnr.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  " Read MAKT
  SELECT matnr maktx
    FROM makt
    INTO TABLE lt_makt
    FOR ALL ENTRIES IN lt_eina
    WHERE matnr = lt_eina-matnr
      AND spras = sy-langu.

  " Read LFA1
  SELECT lifnr name1
    FROM lfa1
    INTO TABLE lt_lfa1
    FOR ALL ENTRIES IN lt_eina
    WHERE lifnr = lt_eina-lifnr.

  LOOP AT lt_chg INTO ls_chg.
    CLEAR ls_out.
    ls_out-infnr      = ls_chg-infnr.
    ls_out-change_seq = ls_chg-change_seq.
    ls_out-ch_field   = ls_chg-field_name.
    ls_out-ch_old_val = ls_chg-value_old.
    ls_out-ch_new_val = ls_chg-value_new.
    ls_out-reason     = ls_chg-change_reason.
    ls_out-approver   = ls_chg-approver.
    ls_out-usnam      = ls_chg-requester.

    " Convert approval_ts to date for display
    IF ls_chg-approval_ts IS NOT INITIAL.
      CONVERT TIME STAMP ls_chg-approval_ts TIME ZONE sy-zonlo
        INTO DATE ls_out-appr_date.
    ENDIF.

    READ TABLE lt_eina INTO ls_eina
      WITH KEY infnr = ls_chg-infnr.
    IF sy-subrc = 0.
      ls_out-matnr = ls_eina-matnr.
      ls_out-lifnr = ls_eina-lifnr.

      READ TABLE lt_makt INTO ls_makt
        WITH KEY matnr = ls_eina-matnr.
      IF sy-subrc = 0.
        ls_out-maktx = ls_makt-maktx.
      ENDIF.

      READ TABLE lt_lfa1 INTO ls_lfa1
        WITH KEY lifnr = ls_eina-lifnr.
      IF sy-subrc = 0.
        ls_out-name1 = ls_lfa1-name1.
      ENDIF.
    ENDIF.

    READ TABLE lt_eine INTO ls_eine
      WITH KEY infnr = ls_chg-infnr.
    IF sy-subrc = 0.
      ls_out-ekorg = ls_eine-ekorg.
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
