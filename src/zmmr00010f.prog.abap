*&---------------------------------------------------------------------*
*& Include  : ZMMR00010F
*& Purpose  : FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 - reads ZMMT00010 JOIN EBAN into gt_data
"   inputs: selection screen globals s_banfn, s_erdat, p_status
"   output: gt_data (global)
*----------------------------------------------------------------------
FORM fetch_data_0100.
  TYPES: BEGIN OF ty_raw,
           banfn        TYPE banfn,
           appr_seq     TYPE n LENGTH 4,
           appr_level   TYPE c LENGTH 20,
           appr_role    TYPE c LENGTH 20,
           appr_user    TYPE syuname,
           appr_status  TYPE c LENGTH 1,
           appr_comment TYPE c LENGTH 255,
           bnfpo        TYPE bnfpo,
           matnr        TYPE matnr,
           menge        LIKE eban-menge,
           meins        TYPE meins,
           erdat        TYPE erdat,
         END OF ty_raw.
  DATA: lt_raw  TYPE STANDARD TABLE OF ty_raw,
        ls_raw  TYPE ty_raw,
        ls_out  TYPE ty_output.

  CLEAR gt_data.

  SELECT z~banfn,
         z~appr_seq,
         z~appr_level,
         z~appr_role,
         z~appr_user,
         z~appr_status,
         z~appr_comment,
         e~bnfpo,
         e~matnr,
         e~menge,
         e~meins,
         e~erdat
    FROM zmmt00010 AS z
    INNER JOIN eban AS e
      ON e~banfn = z~banfn
    INTO TABLE @lt_raw
   WHERE z~banfn IN @s_banfn
     AND e~erdat IN @s_erdat.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  LOOP AT lt_raw INTO ls_raw.
    IF p_status IS NOT INITIAL AND ls_raw-appr_status <> p_status.
      CONTINUE.
    ENDIF.

    CLEAR ls_out.
    ls_out-banfn        = ls_raw-banfn.
    ls_out-bnfpo        = ls_raw-bnfpo.
    ls_out-matnr        = ls_raw-matnr.
    ls_out-menge        = ls_raw-menge.
    ls_out-meins        = ls_raw-meins.
    ls_out-appr_seq     = ls_raw-appr_seq.
    ls_out-appr_level   = ls_raw-appr_level.
    ls_out-appr_user    = ls_raw-appr_user.
    ls_out-appr_role    = ls_raw-appr_role.
    ls_out-appr_status  = ls_raw-appr_status.
    ls_out-appr_comment = ls_raw-appr_comment.
    ls_out-erdat        = ls_raw-erdat.
    APPEND ls_out TO gt_data.
  ENDLOOP.
ENDFORM.
