FUNCTION zmmfm_wms_bin_sync.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LGNUM) TYPE  LGNUM
*"     VALUE(IV_LGTYP) TYPE  LGTYP OPTIONAL
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"      UPDATE_FAILED
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id  TYPE zmme00680 VALUE 'WMS_BIN_SYNC',
             lc_dir_in TYPE zmme00690 VALUE 'I',
             lc_stat_p TYPE zmme00700 VALUE 'P',
             lc_stat_s TYPE zmme00700 VALUE 'S'.

  DATA: ls_log    TYPE zmmt00660,
        ls_ret    TYPE bapiret2,
        lv_count  TYPE i,
        BEGIN OF ls_bin,
          lgnum TYPE lgnum,
          lgtyp TYPE lgtyp,
          lgpla TYPE lgpla,
          skzue TYPE lagp_skzue,
          skzua TYPE lagp_skzua,
        END OF ls_bin,
        lt_bin    LIKE TABLE OF ls_bin.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_lgnum IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Warehouse number (IV_LGNUM) is required'.
    APPEND ls_ret TO et_return.
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

  " ---- 3. LAGP 조회 (SAP 보관위치 마스터) --------------------------------
  IF iv_lgtyp IS INITIAL.
    SELECT lgnum, lgtyp, lgpla, skzue, skzua
      FROM lagp
      INTO CORRESPONDING FIELDS OF TABLE @lt_bin
      WHERE lgnum = @iv_lgnum.
  ELSE.
    SELECT lgnum, lgtyp, lgpla, skzue, skzua
      FROM lagp
      INTO CORRESPONDING FIELDS OF TABLE @lt_bin
      WHERE lgnum = @iv_lgnum
        AND lgtyp = @iv_lgtyp.
  ENDIF.

  lv_count = lines( lt_bin ).

  " ---- 4. 결과 메시지 -----------------------------------------------------
  ls_ret-type    = 'S'.
  ls_ret-id      = 'ZMM'.
  ls_ret-number  = '080'.
  ls_ret-message = |Bin synchronization completed: { lv_count } bins for warehouse { iv_lgnum }|.
  APPEND ls_ret TO et_return.

  " ---- 5. 로그 UPDATE (Success) ------------------------------------------
  ls_log-status = lc_stat_s.
  ls_log-msgtxt = ls_ret-message.
  UPDATE zmmt00660 FROM ls_log.
  COMMIT WORK AND WAIT.

ENDFUNCTION.
