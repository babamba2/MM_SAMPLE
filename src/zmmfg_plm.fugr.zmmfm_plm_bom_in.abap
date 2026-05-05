FUNCTION zmmfm_plm_bom_in.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_STLAL) TYPE  STLAL OPTIONAL
*"     VALUE(IV_DATUV) TYPE  DATUV OPTIONAL
*"  EXPORTING
*"     VALUE(EV_STLNR) TYPE  STLNR_W
*"     VALUE(EV_STLAL) TYPE  STLAL
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id  TYPE zmme00680 VALUE 'PLM_BOM_IN',
             lc_stat_s TYPE zmme00700 VALUE 'S',
             lc_stat_e TYPE zmme00700 VALUE 'E'.

  DATA: ls_log       TYPE zmmt00650,
        ls_ret       TYPE bapiret2,
        lv_stlnr     TYPE stlnr_w,
        lv_stlal_out TYPE stlal,
        lv_seqnr     TYPE zmme00740,
        lv_datuv     TYPE datuv.

  " ---- 1. Build log entry -----------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = lv_seqnr.
  ls_log-direction = 'I'.
  ls_log-matnr     = iv_matnr.
  ls_log-status    = lc_stat_e.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00650 FROM ls_log.

  " ---- 2. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL OR iv_werks IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Material and plant are required for BOM creation'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  lv_datuv = COND #( WHEN iv_datuv IS NOT INITIAL THEN iv_datuv ELSE sy-datum ).

  " ---- 3. Call CSAP_MAT_BOM_CREATE (SAP standard BOM function) ----------
  CALL FUNCTION 'CSAP_MAT_BOM_CREATE'
    EXPORTING
      material           = iv_matnr
      plant              = iv_werks
      bom_usage          = '1'
      alternative        = iv_stlal
      valid_from         = lv_datuv
      fl_commit_and_wait = abap_true
    IMPORTING
      fl_bom_no          = lv_stlnr
      fl_alt_no          = lv_stlal_out
    EXCEPTIONS
      error              = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ls_log-status  = lc_stat_e.
    ls_log-msgtxt  = |CSAP_MAT_BOM_CREATE failed (subrc={ sy-subrc })|.
    UPDATE zmmt00650 FROM ls_log.
    COMMIT WORK AND WAIT.
    ls_ret-type    = 'E'.
    ls_ret-message = ls_log-msgtxt.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 4. Update log to success -----------------------------------------
  ls_log-bom_no   = lv_stlnr.
  ls_log-status   = lc_stat_s.
  ls_log-msg_type = 'S'.
  ls_log-msgtxt   = |BOM { lv_stlnr }/{ lv_stlal_out } created for { iv_matnr }|.
  UPDATE zmmt00650 FROM ls_log.
  COMMIT WORK AND WAIT.

  ev_stlnr  = lv_stlnr.
  ev_stlal  = lv_stlal_out.
  ev_status = lc_stat_s.

ENDFUNCTION.
