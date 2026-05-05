*&---------------------------------------------------------------------*
*& Include ZMMR00160F — FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
* fetch_data_0100 — read ZMMT00440 LEFT JOIN ZMMT00450 + EKKO/EKPO/LFA1
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: lt_stage  TYPE STANDARD TABLE OF zmmt00440 WITH DEFAULT KEY,
        ls_stage  TYPE zmmt00440,
        lt_issue  TYPE STANDARD TABLE OF zmmt00450 WITH DEFAULT KEY,
        ls_issue  TYPE zmmt00450,
        lt_ekko   TYPE STANDARD TABLE OF ekko WITH DEFAULT KEY,
        ls_ekko   TYPE ekko,
        lt_lfa1   TYPE STANDARD TABLE OF lfa1 WITH DEFAULT KEY,
        ls_lfa1   TYPE lfa1,
        ls_out    TYPE ty_s_output.

  CLEAR gt_output.

  " Read PO headers matching selection
  SELECT ebeln lifnr
    FROM ekko
    INTO TABLE lt_ekko
    WHERE ebeln IN s_ebeln
      AND lifnr IN s_lifnr.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  " Read stages
  SELECT *
    FROM zmmt00440
    INTO TABLE lt_stage
    FOR ALL ENTRIES IN lt_ekko
    WHERE ebeln = lt_ekko-ebeln
      AND ebelp IN s_ebelp.
  IF sy-subrc <> 0.
    MESSAGE s001(00) WITH text-m01.
    RETURN.
  ENDIF.

  " Read issue log
  SELECT *
    FROM zmmt00450
    INTO TABLE lt_issue
    FOR ALL ENTRIES IN lt_stage
    WHERE ebeln = lt_stage-ebeln
      AND ebelp = lt_stage-ebelp.

  " Read vendors
  SELECT lifnr name1
    FROM lfa1
    INTO TABLE lt_lfa1
    FOR ALL ENTRIES IN lt_ekko
    WHERE lifnr = lt_ekko-lifnr.

  LOOP AT lt_stage INTO ls_stage.
    " Apply P_OPEN filter: stage_status = 'I' means in-progress
    IF p_open = abap_true AND ls_stage-stage_status = 'C'.
      CONTINUE.
    ENDIF.

    CLEAR ls_out.
    ls_out-ebeln              = ls_stage-ebeln.
    ls_out-ebelp              = ls_stage-ebelp.
    ls_out-stage_seq          = ls_stage-stage_seq.
    ls_out-stage_name         = ls_stage-stage_name.
    ls_out-stage_qty          = ls_stage-qty_planned.
    ls_out-stage_progress_pct = ls_stage-progress_pct.
    ls_out-meins              = ls_stage-meins.
    ls_out-last_update        = ls_stage-updated_at.

    " Aggregate issued/returned from ZMMT00450 for this ebeln/ebelp
    LOOP AT lt_issue INTO ls_issue
      WHERE ebeln = ls_stage-ebeln
        AND ebelp = ls_stage-ebelp.
      ls_out-issued_qty   = ls_out-issued_qty   + ls_issue-qty_issued.
      ls_out-returned_qty = ls_out-returned_qty + ls_issue-qty_returned.
    ENDLOOP.
    ls_out-remaining_qty = ls_out-issued_qty - ls_out-returned_qty.

    " Get vendor from EKKO
    READ TABLE lt_ekko INTO ls_ekko
      WITH KEY ebeln = ls_stage-ebeln.
    IF sy-subrc = 0.
      ls_out-lifnr = ls_ekko-lifnr.
      READ TABLE lt_lfa1 INTO ls_lfa1
        WITH KEY lifnr = ls_ekko-lifnr.
      IF sy-subrc = 0.
        ls_out-name1 = ls_lfa1-name1.
      ENDIF.
    ENDIF.

    APPEND ls_out TO gt_output.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
* display_alv_0100 — create docking container and ALV grid
*----------------------------------------------------------------------
FORM display_alv_0100.
  CHECK gt_output IS NOT INITIAL.
  CALL SCREEN 100.
ENDFORM.

*----------------------------------------------------------------------
* f_status_0100 — set GUI status and title
*----------------------------------------------------------------------
FORM f_status_0100.
  SET PF-STATUS gc_status_0100.
  SET TITLEBAR 't01'.
ENDFORM.

*----------------------------------------------------------------------
* f_modify_screen_0100 — build and show ALV on first paint
*----------------------------------------------------------------------
FORM f_modify_screen_0100.
  DATA: lt_fcat   TYPE lvc_t_fcat,
        ls_layout TYPE lvc_s_layo.

  CHECK go_alv IS INITIAL.

  CREATE OBJECT go_container
    EXPORTING
      side    = cl_gui_docking_container=>dock_at_bottom
      ratio   = 85.

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
    EXPORTING
      is_layout       = ls_layout
    CHANGING
      it_outtab       = gt_output
      it_fieldcatalog = lt_fcat.
ENDFORM.

*----------------------------------------------------------------------
* f_user_command_0100 — handle toolbar actions
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
