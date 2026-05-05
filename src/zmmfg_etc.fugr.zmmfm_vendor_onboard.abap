FUNCTION zmmfm_vendor_onboard.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LIFNR) TYPE  LIFNR OPTIONAL
*"     VALUE(IV_NAME1) TYPE  NAME1_GP
*"     VALUE(IV_LAND1) TYPE  LAND1_GP
*"     VALUE(IV_BUKRS) TYPE  BUKRS
*"     VALUE(IV_ZTERM) TYPE  DZTERM OPTIONAL
*"     VALUE(IV_STCD1) TYPE  STCD1 OPTIONAL
*"     VALUE(IV_STCD2) TYPE  STCD2 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_LIFNR) TYPE  LIFNR
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"      UPDATE_FAILED
*"----------------------------------------------------------------------
  CONSTANTS: lc_stat_s  TYPE char1     VALUE 'S',
             lc_stat_e  TYPE char1     VALUE 'E',
             lc_eval_n  TYPE zmme00750 VALUE 'N'.

  DATA: lv_lifnr   TYPE lifnr,
        ls_lfa1    TYPE lfa1,
        ls_lfb1    TYPE lfb1,
        ls_ext     TYPE zmmt00670,
        ls_ret     TYPE bapiret2,
        lv_ts      TYPE timestampl,
        lv_cnt     TYPE i.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_name1 IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Vendor name (IV_NAME1) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  IF iv_land1 IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Country (IV_LAND1) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  IF iv_bukrs IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Company code (IV_BUKRS) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Resolve or derive LIFNR ----------------------------------------
  IF iv_lifnr IS NOT INITIAL.
    lv_lifnr = iv_lifnr.
    SELECT COUNT(*) FROM lfa1 WHERE lifnr = @lv_lifnr INTO @lv_cnt.
    IF lv_cnt > 0.
      ls_ret-type    = 'E'.
      ls_ret-message = |Vendor { iv_lifnr } already exists|.
      APPEND ls_ret TO et_return.
      ev_status = lc_stat_e.
      RAISE validation_failed.
    ENDIF.
  ELSE.
    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        nr_range_nr             = '02'
        object                  = 'KRED'
      IMPORTING
        number                  = lv_lifnr
      EXCEPTIONS
        interval_not_found      = 1
        number_range_not_intern = 2
        object_not_found        = 3
        quantity_is_0           = 4
        quantity_is_not_1       = 5
        interval_overflow       = 6
        buffer_overflow         = 7
        OTHERS                  = 8.
    IF sy-subrc <> 0.
      ls_ret-type    = 'E'.
      ls_ret-message = 'Vendor number range exhausted (KRED/02)'.
      APPEND ls_ret TO et_return.
      ev_status = lc_stat_e.
      RAISE bapi_error.
    ENDIF.
  ENDIF.

  " ---- 3. Populate LFA1 (general segment) --------------------------------
  CLEAR ls_lfa1.
  ls_lfa1-mandt = sy-mandt.
  ls_lfa1-lifnr = lv_lifnr.
  ls_lfa1-name1 = iv_name1.
  ls_lfa1-land1 = iv_land1.
  ls_lfa1-stcd1 = iv_stcd1.
  ls_lfa1-stcd2 = iv_stcd2.
  ls_lfa1-ktokk = 'LIEF'.
  ls_lfa1-erdat = sy-datum.
  ls_lfa1-ernam = sy-uname.
  INSERT lfa1 FROM ls_lfa1.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    ls_ret-type    = 'E'.
    ls_ret-message = |LFA1 INSERT failed for { lv_lifnr } (subrc={ sy-subrc })|.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE update_failed.
  ENDIF.

  " ---- 4. Populate LFB1 (company-code segment) ---------------------------
  CLEAR ls_lfb1.
  ls_lfb1-mandt = sy-mandt.
  ls_lfb1-lifnr = lv_lifnr.
  ls_lfb1-bukrs = iv_bukrs.
  ls_lfb1-zterm = iv_zterm.
  ls_lfb1-erdat = sy-datum.
  ls_lfb1-ernam = sy-uname.
  INSERT lfb1 FROM ls_lfb1.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    ls_ret-type    = 'E'.
    ls_ret-message = |LFB1 INSERT failed for { lv_lifnr }/{ iv_bukrs }|.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE update_failed.
  ENDIF.

  " ---- 5. Insert vendor onboarding extension ZMMT00670 ------------------
  GET TIME STAMP FIELD lv_ts.
  CLEAR ls_ext.
  ls_ext-mandt       = sy-mandt.
  ls_ext-lifnr       = lv_lifnr.
  ls_ext-stcd1       = iv_stcd1.
  ls_ext-stcd2       = iv_stcd2.
  ls_ext-eval_status = lc_eval_n.
  ls_ext-zterm       = iv_zterm.
  ls_ext-created_by  = sy-uname.
  ls_ext-created_at  = lv_ts.
  INSERT zmmt00670 FROM ls_ext.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    ls_ret-type    = 'E'.
    ls_ret-message = |ZMMT00670 INSERT failed for { lv_lifnr }|.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE update_failed.
  ENDIF.

  COMMIT WORK AND WAIT.

  " ---- 6. Success --------------------------------------------------------
  ev_lifnr  = lv_lifnr.
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |Vendor { lv_lifnr } onboarded successfully|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
