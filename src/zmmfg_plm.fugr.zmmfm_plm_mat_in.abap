FUNCTION zmmfm_plm_mat_in.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_MTART) TYPE  MTART
*"     VALUE(IV_MEINS) TYPE  MEINS
*"     VALUE(IV_MBRSH) TYPE  MBRSH
*"  EXPORTING
*"     VALUE(EV_MATNR) TYPE  MATNR
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id   TYPE zmme00680  VALUE 'PLM_MAT_IN',
             lc_dir_in  TYPE zmme00690  VALUE 'IN',
             lc_stat_s  TYPE zmme00700  VALUE 'S',
             lc_stat_e  TYPE zmme00700  VALUE 'E'.

  DATA: ls_log        TYPE zmmt00650,
        ls_headdata   TYPE bapimathead,
        ls_mara_data  TYPE bapi_mara,
        ls_mara_datax TYPE bapi_marax,
        lt_return     TYPE TABLE OF bapiret2,
        ls_ret        TYPE bapiret2,
        lv_seqnr      TYPE zmme00740.

  " ---- 1. Build log header -----------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = lv_seqnr.
  ls_log-direction = lc_dir_in.
  ls_log-matnr     = iv_matnr.
  ls_log-status    = lc_stat_e.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00650 FROM ls_log.

  " ---- 2. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL OR iv_mtart IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Material number and type are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 3. Build BAPI structures ------------------------------------------
  ls_headdata-material   = iv_matnr.
  ls_headdata-matl_type  = iv_mtart.
  ls_headdata-ind_sector = iv_mbrsh.

  ls_mara_data-base_uom  = iv_meins.
  ls_mara_datax-base_uom = abap_true.

  " ---- 4. Call BAPI_MATERIAL_SAVEREPLICA ---------------------------------
  CALL FUNCTION 'BAPI_MATERIAL_SAVEREPLICA'
    EXPORTING
      headdata  = ls_headdata
      maradata  = ls_mara_data
      maradatax = ls_mara_datax
    TABLES
      return    = lt_return.

  " ---- 5. Error check ----------------------------------------------------
  READ TABLE lt_return WITH KEY type = 'E' INTO ls_ret.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ls_log-status  = lc_stat_e.
    ls_log-msgtxt  = ls_ret-message.
    UPDATE zmmt00650 FROM ls_log.
    COMMIT WORK AND WAIT.
    APPEND LINES OF lt_return TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 6. Commit ---------------------------------------------------------
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  " ---- 7. Update log to success ------------------------------------------
  ls_log-status   = lc_stat_s.
  ls_log-msg_type = 'S'.
  ls_log-msgtxt   = |Material { iv_matnr } replicated successfully|.
  UPDATE zmmt00650 FROM ls_log.
  COMMIT WORK AND WAIT.

  ev_matnr  = iv_matnr.
  ev_status = lc_stat_s.

ENDFUNCTION.
