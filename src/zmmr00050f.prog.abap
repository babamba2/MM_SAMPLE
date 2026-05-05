*&---------------------------------------------------------------------*
*& Include  : ZMMR00050F
*& Purpose  : FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 - ZMMT00200 JOIN EKPO + MAKT into gt_data
"   inputs: s_ebeln, s_deviat (selection screen globals)
"   output: gt_data (global)
*----------------------------------------------------------------------
FORM fetch_data_0100.
  TYPES: BEGIN OF ty_raw,
           ebeln            TYPE ebeln,
           ebelp            TYPE ebelp,
           price_standard   TYPE p DECIMALS 2,
           price_requested  TYPE p DECIMALS 2,
           deviation_pct    TYPE p DECIMALS 2,
           exception_reason TYPE c LENGTH 30,
           approver         TYPE syuname,
           approval_ts      TYPE timestampl,
           waers            TYPE waers,
           matnr            TYPE matnr,
         END OF ty_raw.
  DATA: lt_raw   TYPE STANDARD TABLE OF ty_raw,
        ls_raw   TYPE ty_raw,
        ls_out   TYPE ty_output,
        lv_date  TYPE dats,
        lv_dev   TYPE p DECIMALS 2.

  CLEAR: gt_data, gv_total_dev.

  SELECT z~ebeln,
         z~ebelp,
         z~price_standard,
         z~price_requested,
         z~deviation_pct,
         z~exception_reason,
         z~approver,
         z~approval_ts,
         z~waers,
         e~matnr
    FROM zmmt00200 AS z
    INNER JOIN ekpo AS e
      ON e~ebeln = z~ebeln AND e~ebelp = z~ebelp
    INTO TABLE @lt_raw
   WHERE z~ebeln IN @s_ebeln
     AND z~deviation_pct IN @s_deviat.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  LOOP AT lt_raw INTO ls_raw.
    CONVERT TIME STAMP ls_raw-approval_ts
            TIME ZONE sy-zonlo
            INTO DATE lv_date.

    SELECT SINGLE maktx
      INTO @DATA(lv_maktx)
      FROM makt
     WHERE matnr  = @ls_raw-matnr
       AND spras  = @sy-langu.
    IF sy-subrc <> 0.
      CLEAR lv_maktx.
    ENDIF.

    lv_dev = ls_raw-price_requested - ls_raw-price_standard.

    CLEAR ls_out.
    ls_out-ebeln         = ls_raw-ebeln.
    ls_out-ebelp         = ls_raw-ebelp.
    ls_out-matnr         = ls_raw-matnr.
    ls_out-maktx         = lv_maktx.
    ls_out-std_price     = ls_raw-price_standard.
    ls_out-req_price     = ls_raw-price_requested.
    ls_out-deviation_pct = ls_raw-deviation_pct.
    ls_out-deviation_amt = lv_dev.
    ls_out-approver      = ls_raw-approver.
    ls_out-appr_date     = lv_date.
    ls_out-reason        = ls_raw-exception_reason.
    ls_out-waers         = ls_raw-waers.
    APPEND ls_out TO gt_data.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" calc_footer_0100 - accumulates total deviation amount
"   input: gt_data (global)
"   output: gv_total_dev (global)
*----------------------------------------------------------------------
FORM calc_footer_0100.
  CLEAR gv_total_dev.
  LOOP AT gt_data INTO DATA(ls_row).
    gv_total_dev = gv_total_dev + ls_row-deviation_amt.
  ENDLOOP.
ENDFORM.
