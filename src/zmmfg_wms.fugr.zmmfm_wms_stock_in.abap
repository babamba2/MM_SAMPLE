FUNCTION zmmfm_wms_stock_in.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_LGORT) TYPE  LGORT_D
*"     VALUE(IV_MENGE) TYPE  MENGE_D
*"     VALUE(IV_MEINS) TYPE  MEINS
*"     VALUE(IV_BWART) TYPE  BWART DEFAULT '701'
*"  EXPORTING
*"     VALUE(EV_MBLNR) TYPE  MBLNR
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"      UPDATE_FAILED
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id   TYPE zmme00680 VALUE 'WMS_STOCK_IN',
             lc_dir_in  TYPE zmme00690 VALUE 'I',
             lc_stat_p  TYPE zmme00700 VALUE 'P',
             lc_stat_s  TYPE zmme00700 VALUE 'S',
             lc_stat_e  TYPE zmme00700 VALUE 'E',
             lc_mvt_701 TYPE bwart      VALUE '701'.

  DATA: ls_log        TYPE zmmt00660,
        ls_gm_header  TYPE bapi2017_gm_head_01,
        ls_gm_code    TYPE bapi2017_gm_code,
        ls_gm_item    TYPE bapi2017_gm_item_create,
        lt_gm_items   TYPE TABLE OF bapi2017_gm_item_create,
        ls_gm_headret TYPE bapi2017_gm_head_ret,
        lt_return     TYPE TABLE OF bapiret2,
        ls_ret        TYPE bapiret2,
        lv_mblnr      TYPE mblnr,
        lv_mjahr      TYPE mjahr.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL OR iv_werks IS INITIAL OR iv_lgort IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Material, plant, and storage location are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  IF iv_menge IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Quantity (IV_MENGE) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Log INSERT (Pending) -------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = 1.
  ls_log-direction = lc_dir_in.
  ls_log-status    = lc_stat_p.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00660 FROM ls_log.

  " ---- 3. BAPI header (inventory adjustment) -----------------------------
  ls_gm_header-pstng_date = sy-datum.
  ls_gm_header-doc_date   = sy-datum.
  ls_gm_code-gm_code      = '04'.

  " ---- 4. Movement item --------------------------------------------------
  ls_gm_item-material  = iv_matnr.
  ls_gm_item-plant     = iv_werks.
  ls_gm_item-stge_loc  = iv_lgort.
  ls_gm_item-entry_qnt = iv_menge.
  ls_gm_item-entry_uom = iv_meins.
  ls_gm_item-move_type = iv_bwart.
  APPEND ls_gm_item TO lt_gm_items.

  " ---- 5. Post via BAPI_GOODSMVT_CREATE ----------------------------------
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = ls_gm_header
      goodsmvt_code    = ls_gm_code
    IMPORTING
      goodsmvt_headret = ls_gm_headret
      materialdocument = lv_mblnr
      matdocumentyear  = lv_mjahr
    TABLES
      goodsmvt_item    = lt_gm_items
      return           = lt_return.

  " ---- 6. Error check ----------------------------------------------------
  READ TABLE lt_return WITH KEY type = 'E' INTO ls_ret.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    APPEND LINES OF lt_return TO et_return.
    ls_log-status = lc_stat_e.
    ls_log-msgtxt = ls_ret-message.
    UPDATE zmmt00660 FROM ls_log.
    COMMIT WORK.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 7. Commit + log UPDATE (Success) ----------------------------------
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  ev_mblnr  = lv_mblnr.
  ev_status = lc_stat_s.
  ls_log-mblnr  = lv_mblnr.
  ls_log-status = lc_stat_s.
  UPDATE zmmt00660 FROM ls_log.
  COMMIT WORK AND WAIT.

  ls_ret-type    = 'S'.
  ls_ret-message = |Stock adjustment posted: { lv_mblnr }/{ lv_mjahr } for { iv_matnr }|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
