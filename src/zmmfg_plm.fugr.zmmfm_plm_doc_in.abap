FUNCTION zmmfm_plm_doc_in.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_DOKAR) TYPE  DOKAR DEFAULT 'DRW'
*"     VALUE(IV_DOKTL) TYPE  DOKTL DEFAULT '000'
*"     VALUE(IV_DOKVR) TYPE  DOKVR DEFAULT '00'
*"     VALUE(IV_DKTXT) TYPE  DKTXT OPTIONAL
*"     VALUE(IV_MATNR) TYPE  MATNR OPTIONAL
*"  EXPORTING
*"     VALUE(EV_DOKNR) TYPE  DOKNR
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      IT_FILES STRUCTURE  BAPI_DOC_FILES2
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"      UPDATE_FAILED
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id  TYPE zmme00680 VALUE 'PLM_DOC_IN',
             lc_dir_in TYPE zmme00690 VALUE 'I',
             lc_stat_p TYPE zmme00700 VALUE 'P',
             lc_stat_s TYPE zmme00700 VALUE 'S',
             lc_stat_e TYPE zmme00700 VALUE 'E'.

  DATA: ls_log      TYPE zmmt00650,
        ls_doc_data TYPE bapi_doc_draw2,
        lt_return   TYPE TABLE OF bapiret2,
        ls_ret      TYPE bapiret2,
        lv_doknr    TYPE doknr.

  " ---- 1. 로그 INSERT (Pending) ------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = 1.
  ls_log-direction = lc_dir_in.
  ls_log-status    = lc_stat_p.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00650 FROM ls_log.

  " ---- 2. 문서 헤더 구성 --------------------------------------------------
  ls_doc_data-documenttype    = iv_dokar.
  ls_doc_data-documentpart    = iv_doktl.
  ls_doc_data-documentversion = iv_dokvr.
  ls_doc_data-description     = iv_dktxt.

  " ---- 3. BAPI_DOCUMENT_CREATE2 호출 -------------------------------------
  CALL FUNCTION 'BAPI_DOCUMENT_CREATE2'
    EXPORTING
      documentdata   = ls_doc_data
    IMPORTING
      documentnumber = lv_doknr
    TABLES
      documentfiles  = it_files
      return         = lt_return.

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
  ls_log-doc_id   = lv_doknr.
  ls_log-msg_type = 'S'.
  UPDATE zmmt00650 FROM ls_log.
  COMMIT WORK AND WAIT.

  ev_doknr  = lv_doknr.
  ev_status = lc_stat_s.

ENDFUNCTION.
