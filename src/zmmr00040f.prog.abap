*&---------------------------------------------------------------------*
*& Include  : ZMMR00040F
*& Purpose  : FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 - ZMMT00070 JOIN EBAN + LFA1 into gt_data
"   inputs: s_banfn, s_erdat, p_urgent (selection screen globals)
"   output: gt_data (global)
*----------------------------------------------------------------------
FORM fetch_data_0100.
  TYPES: BEGIN OF ty_raw,
           banfn            TYPE banfn,
           bnfpo            TYPE bnfpo,
           urgency_code     TYPE c LENGTH 4,
           exception_reason TYPE c LENGTH 30,
           exec_approver    TYPE syuname,
           exec_approval_ts TYPE timestampl,
           matnr            TYPE matnr,
           menge            LIKE eban-menge,
           lifnr            TYPE lifnr,
           erdat            TYPE erdat,
         END OF ty_raw.
  DATA: lt_raw  TYPE STANDARD TABLE OF ty_raw,
        ls_raw  TYPE ty_raw,
        ls_out  TYPE ty_output,
        lv_date TYPE dats.

  CLEAR gt_data.

  SELECT z~banfn,
         z~bnfpo,
         z~urgency_code,
         z~exception_reason,
         z~exec_approver,
         z~exec_approval_ts,
         e~matnr,
         e~menge,
         e~lifnr,
         e~erdat
    FROM zmmt00070 AS z
    INNER JOIN eban AS e
      ON e~banfn = z~banfn AND e~bnfpo = z~bnfpo
    INTO TABLE @lt_raw
   WHERE z~banfn IN @s_banfn
     AND e~erdat IN @s_erdat.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  LOOP AT lt_raw INTO ls_raw.
    IF p_urgent = abap_true AND ls_raw-urgency_code IS INITIAL.
      CONTINUE.
    ENDIF.

    CONVERT TIME STAMP ls_raw-exec_approval_ts
            TIME ZONE sy-zonlo
            INTO DATE lv_date.

    SELECT SINGLE name1
      INTO @DATA(lv_name1)
      FROM lfa1
     WHERE lifnr = @ls_raw-lifnr.
    IF sy-subrc <> 0.
      CLEAR lv_name1.
    ENDIF.

    CLEAR ls_out.
    ls_out-banfn       = ls_raw-banfn.
    ls_out-bnfpo       = ls_raw-bnfpo.
    ls_out-urgency     = ls_raw-urgency_code.
    ls_out-urgency_rsn = ls_raw-exception_reason.
    ls_out-exec_appr   = ls_raw-exec_approver.
    ls_out-appr_date   = lv_date.
    ls_out-matnr       = ls_raw-matnr.
    ls_out-menge       = ls_raw-menge.
    ls_out-lifnr       = ls_raw-lifnr.
    ls_out-name1       = lv_name1.
    APPEND ls_out TO gt_data.
  ENDLOOP.
ENDFORM.
