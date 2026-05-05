*&---------------------------------------------------------------------*
*& Include  : ZMMR00020F
*& Purpose  : FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 - ZMMT00120 JOIN EKKO+LFA1 into gt_data
"   inputs: s_ebeln, s_ebelp, s_chdate, p_field (selection screen globals)
"   output: gt_data (global)
*----------------------------------------------------------------------
FORM fetch_data_0100.
  TYPES: BEGIN OF ty_raw,
           ebeln         TYPE ebeln,
           ebelp         TYPE ebelp,
           seq_no        TYPE n LENGTH 4,
           field_changed TYPE c LENGTH 30,
           value_old     TYPE c LENGTH 50,
           value_new     TYPE c LENGTH 50,
           change_reason TYPE c LENGTH 30,
           changed_by    TYPE syuname,
           changed_at    TYPE timestampl,
           lifnr         TYPE lifnr,
         END OF ty_raw.
  DATA: lt_raw  TYPE STANDARD TABLE OF ty_raw,
        ls_raw  TYPE ty_raw,
        ls_out  TYPE ty_output,
        lv_date TYPE dats,
        lv_time TYPE tims.

  CLEAR gt_data.

  SELECT z~ebeln,
         z~ebelp,
         z~seq_no,
         z~field_changed,
         z~value_old,
         z~value_new,
         z~change_reason,
         z~changed_by,
         z~changed_at,
         k~lifnr
    FROM zmmt00120 AS z
    INNER JOIN ekko AS k
      ON k~ebeln = z~ebeln
    INTO TABLE @lt_raw
   WHERE z~ebeln IN @s_ebeln
     AND z~ebelp IN @s_ebelp.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  LOOP AT lt_raw INTO ls_raw.
    CONVERT TIME STAMP ls_raw-changed_at
            TIME ZONE sy-zonlo
            INTO DATE lv_date TIME lv_time.

    IF s_chdate IS NOT INITIAL.
      CHECK lv_date IN s_chdate.
    ENDIF.

    IF p_field IS NOT INITIAL.
      CHECK ls_raw-field_changed CP p_field.
    ENDIF.

    SELECT SINGLE name1
      INTO @DATA(lv_name1)
      FROM lfa1
     WHERE lifnr = @ls_raw-lifnr.
    IF sy-subrc <> 0.
      CLEAR lv_name1.
    ENDIF.

    CLEAR ls_out.
    ls_out-ebeln     = ls_raw-ebeln.
    ls_out-ebelp     = ls_raw-ebelp.
    ls_out-seq_no    = ls_raw-seq_no.
    ls_out-ch_field  = ls_raw-field_changed.
    ls_out-ch_old    = ls_raw-value_old.
    ls_out-ch_new    = ls_raw-value_new.
    ls_out-ch_reason = ls_raw-change_reason.
    ls_out-ch_user   = ls_raw-changed_by.
    ls_out-ch_date   = lv_date.
    ls_out-ch_time   = lv_time.
    ls_out-lifnr     = ls_raw-lifnr.
    ls_out-name1     = lv_name1.
    APPEND ls_out TO gt_data.
  ENDLOOP.
ENDFORM.
