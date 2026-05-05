*&---------------------------------------------------------------------*
*& Include  : ZMMR00030F
*& Purpose  : FORM routines
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" fetch_data_0100 - ZMMT00130 JOIN EKPO into gt_data
"   inputs: s_ebeln, s_werks, s_delay (selection screen globals)
"   output: gt_data (global)
*----------------------------------------------------------------------
FORM fetch_data_0100.
  DATA: ls_out  TYPE ty_output,
        lv_date TYPE dats.

  CLEAR: gt_data, gv_delay_cnt, gv_delay_avg.

  SELECT ebeln, ebelp, confirm_seq,
         delivery_date_old, delivery_date_new, delay_days,
         vendor_ack, delay_reason, created_by, created_at
    FROM zmmt00130
    INTO TABLE @DATA(lt_conf)
   WHERE ebeln IN @s_ebeln.

  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  LOOP AT lt_conf INTO DATA(ls_conf).
    IF s_delay IS NOT INITIAL.
      CHECK ls_conf-delay_days IN s_delay.
    ENDIF.

    SELECT SINGLE matnr, menge, meins, werks
      INTO @DATA(ls_ekpo)
      FROM ekpo
     WHERE ebeln = @ls_conf-ebeln
       AND ebelp = @ls_conf-ebelp
       AND werks IN @s_werks.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    CONVERT TIME STAMP ls_conf-created_at
            TIME ZONE sy-zonlo
            INTO DATE lv_date.

    CLEAR ls_out.
    ls_out-ebeln        = ls_conf-ebeln.
    ls_out-ebelp        = ls_conf-ebelp.
    ls_out-matnr        = ls_ekpo-matnr.
    ls_out-menge        = ls_ekpo-menge.
    ls_out-meins        = ls_ekpo-meins.
    ls_out-confirm_seq  = ls_conf-confirm_seq.
    ls_out-orig_deldate = ls_conf-delivery_date_old.
    ls_out-new_deldate  = ls_conf-delivery_date_new.
    ls_out-delay_days   = ls_conf-delay_days.
    ls_out-vendor_ack   = ls_conf-vendor_ack.
    ls_out-reason       = ls_conf-delay_reason.
    ls_out-confirm_user = ls_conf-created_by.
    ls_out-confirm_date = lv_date.
    APPEND ls_out TO gt_data.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" calc_footer_0100 - calculates delay count + average delay days
"   input: gt_data (global)
"   output: gv_delay_cnt, gv_delay_avg (globals)
*----------------------------------------------------------------------
FORM calc_footer_0100.
  DATA: lv_total TYPE i.

  CLEAR: gv_delay_cnt, gv_delay_avg, lv_total.

  LOOP AT gt_data INTO DATA(ls_row).
    IF ls_row-delay_days > 0.
      gv_delay_cnt = gv_delay_cnt + 1.
      lv_total = lv_total + ls_row-delay_days.
    ENDIF.
  ENDLOOP.

  IF gv_delay_cnt > 0.
    gv_delay_avg = lv_total / gv_delay_cnt.
  ENDIF.
ENDFORM.
