*&---------------------------------------------------------------------*
*& Include  ZMMR00130F — 수입/통관 문서 추적 FORM Routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" init_0100 — Initialization
*----------------------------------------------------------------------
FORM init_0100.
  s_trkdat-sign   = 'I'.
  s_trkdat-option = 'BT'.
  s_trkdat-low    = sy-datum(6) && '01'.
  s_trkdat-high   = sy-datum.
  APPEND s_trkdat.
ENDFORM.

*----------------------------------------------------------------------
" validate_screen_0100 — Check mandatory fields
*----------------------------------------------------------------------
FORM validate_screen_0100.
  IF s_ebeln IS INITIAL AND s_trkdat IS INITIAL AND s_carrie IS INITIAL.
    MESSAGE text-e01 TYPE 'E'.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" fetch_data_0100 — Read ZMMT00510 JOIN EKKO + LFA1
*----------------------------------------------------------------------
FORM fetch_data_0100.
  CLEAR: gt_alv_0100, gv_avg_days.
  DATA lv_total_days TYPE i.
  DATA lv_count      TYPE i.

  SELECT z~ebeln, z~track_seq,
         z~bl_number    AS bl_no,
         z~customs_declaration AS customs_decl_no,
         z~carrier      AS carrier_code,
         l~name1        AS carrier_name,
         z~duty_amount, z~waers,
         k~lifnr, v~name1,
         z~ata_date     AS import_date,
         z~eta_date     AS clearance_date
    INTO CORRESPONDING FIELDS OF TABLE @gt_alv_0100
    FROM zmmt00510 AS z
    INNER JOIN ekko AS k ON k~ebeln = z~ebeln
    LEFT OUTER JOIN lfa1 AS v ON v~lifnr = k~lifnr
    LEFT OUTER JOIN lfa1 AS l ON l~lifnr = z~carrier
    WHERE z~ebeln    IN @s_ebeln
      AND z~ata_date IN @s_trkdat
      AND z~carrier  IN @s_carrie.
  IF sy-subrc <> 0.
    MESSAGE text-i01 TYPE 'I'.
    RETURN.
  ENDIF.

  " Calculate clearance days and average
  LOOP AT gt_alv_0100 INTO gs_alv_0100.
    IF gs_alv_0100-import_date IS NOT INITIAL
    AND gs_alv_0100-clearance_date IS NOT INITIAL.
      DATA(lv_days) = gs_alv_0100-clearance_date - gs_alv_0100-import_date.
      gs_alv_0100-days_to_clear = lv_days.
      MODIFY gt_alv_0100 FROM gs_alv_0100.
      ADD lv_days TO lv_total_days.
      ADD 1 TO lv_count.
    ENDIF.
  ENDLOOP.
  IF lv_count > 0.
    gv_avg_days = lv_total_days / lv_count.
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" display_alv_0100 — call screen if data present
*----------------------------------------------------------------------
FORM display_alv_0100.
  IF gt_alv_0100 IS INITIAL.
    RETURN.
  ENDIF.
  CALL SCREEN gc_screen_0100.
ENDFORM.

*----------------------------------------------------------------------
" f_status_0100 — PBO: build ALV
*----------------------------------------------------------------------
FORM f_status_0100.
  SET PF-STATUS gc_status_0100.
  SET TITLEBAR 'T01'.

  IF go_docking IS INITIAL.
    CREATE OBJECT go_docking
      EXPORTING side  = cl_gui_docking_container=>dock_at_bottom
                ratio = 90.
    CREATE OBJECT go_alv_grid
      EXPORTING i_parent = go_docking.

    PERFORM convert_fcat_data_grid
      USING    gt_alv_0100
      CHANGING gt_fieldcat.
    PERFORM modify_fcat_data_grid1_0100 CHANGING gt_fieldcat.

    DATA ls_layout TYPE lvc_s_layo.
    ls_layout-zebra      = abap_true.
    ls_layout-sel_mode   = 'A'.
    ls_layout-cwidth_opt = abap_true.

    go_alv_grid->set_table_for_first_display(
      EXPORTING is_layout       = ls_layout
      CHANGING  it_fieldcatalog = gt_fieldcat
                it_outtab       = gt_alv_0100 ).
  ENDIF.
ENDFORM.

*----------------------------------------------------------------------
" user_command_0100 — PAI: handle Back/Exit/Cancel
*----------------------------------------------------------------------
FORM user_command_0100.
  DATA lv_fcode TYPE syucomm.
  lv_fcode = sy-ucomm.
  CLEAR sy-ucomm.
  CASE lv_fcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      IF go_docking IS NOT INITIAL.
        go_docking->free( ).
        FREE go_docking.
        FREE go_alv_grid.
      ENDIF.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDFORM.
