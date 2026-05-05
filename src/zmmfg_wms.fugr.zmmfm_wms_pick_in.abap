FUNCTION zmmfm_wms_pick_in.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  LGNUM
*"     VALUE(IV_TANUM) TYPE  TANUM
*"     VALUE(IV_TAPOS) TYPE  TAPOS DEFAULT '0001'
*"     VALUE(IV_ANFME) TYPE  MENGE_D
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"      UPDATE_FAILED
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id  TYPE zmme00680 VALUE 'WMS_PICK_IN',
             lc_dir_in TYPE zmme00690 VALUE 'I',
             lc_stat_p TYPE zmme00700 VALUE 'P',
             lc_stat_s TYPE zmme00700 VALUE 'S',
             lc_stat_e TYPE zmme00700 VALUE 'E'.

  DATA: ls_log    TYPE zmmt00660,
        ls_ret    TYPE bapiret2,
        lt_return TYPE TABLE OF bapiret2.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_lgnum IS INITIAL OR iv_tanum IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Warehouse number (IV_LGNUM) and transfer order (IV_TANUM) are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. 로그 INSERT (Pending) ------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = 1.
  ls_log-direction = lc_dir_in.
  ls_log-status    = lc_stat_p.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00660 FROM ls_log.

  " ---- 3. LE_TO_CONFIRM_POSTINGS 호출 (Transfer Order 확인) -------------
  CALL FUNCTION 'LE_TO_CONFIRM_POSTINGS'
    EXPORTING
      lgnum      = iv_lgnum
      tanum      = iv_tanum
      tapos      = iv_tapos
      update_gn  = abap_true
    EXCEPTIONS
      not_found  = 1
      blocked    = 2
      OTHERS     = 3.

  " ---- 4. 오류 체크 -------------------------------------------------------
  IF sy-subrc <> 0.
    ls_ret-type    = 'E'.
    ls_ret-id      = 'ZMM'.
    ls_ret-number  = '070'.
    ls_ret-message = 'Transfer order confirmation failed (LE_TO_CONFIRM_POSTINGS).'.
    APPEND ls_ret TO et_return.
    ls_log-status = lc_stat_e.
    ls_log-msgtxt = ls_ret-message.
    UPDATE zmmt00660 FROM ls_log.
    COMMIT WORK.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 5. 커밋 + 로그 UPDATE (Success) -----------------------------------
  COMMIT WORK AND WAIT.
  ls_log-status = lc_stat_s.
  ls_log-msgtxt = 'Pick confirmation posted successfully.'.
  UPDATE zmmt00660 FROM ls_log.
  COMMIT WORK AND WAIT.

  ev_status = lc_stat_s.

ENDFUNCTION.
