FUNCTION zmmfm_plm_ecn_in.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_AENNR) TYPE  AENNR OPTIONAL
*"     VALUE(IV_AETXT) TYPE  AETXT OPTIONAL
*"     VALUE(IV_MATNR) TYPE  MATNR OPTIONAL
*"     VALUE(IV_DATUV) TYPE  DATUV OPTIONAL
*"  EXPORTING
*"     VALUE(EV_AENNR) TYPE  AENNR
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"      UPDATE_FAILED
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id  TYPE zmme00680 VALUE 'PLM_ECN_IN',
             lc_dir_in TYPE zmme00690 VALUE 'I',
             lc_stat_p TYPE zmme00700 VALUE 'P',
             lc_stat_s TYPE zmme00700 VALUE 'S',
             lc_stat_e TYPE zmme00700 VALUE 'E'.

  DATA: ls_log     TYPE zmmt00650,
        ls_ecm_hdr TYPE bapi_ecm_order_detail,
        lt_return  TYPE TABLE OF bapiret2,
        ls_ret     TYPE bapiret2,
        lv_aennr   TYPE aennr.

  " ---- 1. 로그 INSERT (Pending) ------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = 1.
  ls_log-direction = lc_dir_in.
  ls_log-status    = lc_stat_p.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00650 FROM ls_log.

  " ---- 2. ECO 헤더 구성 --------------------------------------------------
  ls_ecm_hdr-change_order = iv_aennr.
  ls_ecm_hdr-release_date = COND #( WHEN iv_datuv IS NOT INITIAL
                                    THEN iv_datuv ELSE sy-datum ).

  " ---- 3. BAPI_ECMORD_CREATE 호출 ----------------------------------------
  CALL FUNCTION 'BAPI_ECMORD_CREATE'
    EXPORTING
      headdata     = ls_ecm_hdr
    IMPORTING
      changenumber = lv_aennr
    TABLES
      return       = lt_return.

  " ---- 4. 오류 체크 -------------------------------------------------------
  READ TABLE lt_return WITH KEY type = 'E' INTO ls_ret.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ls_log-status   = lc_stat_e.
    ls_log-msg_type = 'E'.
    ls_log-msgtxt   = ls_ret-message.
    UPDATE zmmt00650 FROM ls_log.
    COMMIT WORK.
    APPEND LINES OF lt_return TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 5. 커밋 + 로그 UPDATE (Success) -----------------------------------
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  ls_log-status   = lc_stat_s.
  ls_log-ecn_no   = lv_aennr.
  ls_log-msg_type = 'S'.
  UPDATE zmmt00650 FROM ls_log.
  COMMIT WORK AND WAIT.

  ev_aennr  = lv_aennr.
  ev_status = lc_stat_s.

ENDFUNCTION.
