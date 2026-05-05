FUNCTION zmmfm_stock_recount.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_INVDOC) TYPE  INVNR
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_LGORT) TYPE  LGORT_D
*"     VALUE(IV_QTY_CNT) TYPE  MENGE_D
*"     VALUE(IV_MEINS) TYPE  MEINS
*"     VALUE(IV_REASON) TYPE  CHAR30 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_stat_s TYPE char1 VALUE 'S',
             lc_stat_e TYPE char1 VALUE 'E',
             lc_posted TYPE char1 VALUE 'X'.

  DATA: ls_ret       TYPE bapiret2,
        ls_diff_log  TYPE zmmt00500,
        lv_qty_sys   TYPE menge_d.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_invdoc IS INITIAL OR iv_matnr IS INITIAL OR iv_werks IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Inventory document, material and plant are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Read system stock for comparison (MARD unrestricted labst) -----
  SELECT SINGLE labst
    FROM mard
    INTO @lv_qty_sys
    WHERE matnr = @iv_matnr
      AND werks = @iv_werks
      AND lgort = @iv_lgort.

  " ---- 3. Trigger recount via MI04 equivalent FM -------------------------
  CALL FUNCTION 'MI_COUNT_DOCUMENT_RECOUNT'
    EXPORTING
      invdoc         = iv_invdoc
    EXCEPTIONS
      not_authorized = 1
      no_items_found = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    ls_ret-type    = 'E'.
    ls_ret-message = |MI_COUNT_DOCUMENT_RECOUNT failed for { iv_invdoc } (subrc={ sy-subrc })|.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 4. Post physical inventory difference (BAPI_MATPHYSINV_POSTDIFF) --
  CALL FUNCTION 'BAPI_MATPHYSINV_POSTDIFF'
    EXPORTING
      invent_doc     = iv_invdoc
      posting_date   = sy-datum
    TABLES
      return         = et_return
    EXCEPTIONS
      OTHERS         = 1.
  IF sy-subrc <> 0.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  READ TABLE et_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  " ---- 5. Log difference to ZMMT00500 -----------------------------------
  CLEAR ls_diff_log.
  ls_diff_log-mandt              = sy-mandt.
  ls_diff_log-count_doc          = iv_invdoc.
  ls_diff_log-matnr              = iv_matnr.
  ls_diff_log-werks              = iv_werks.
  ls_diff_log-lgort              = iv_lgort.
  ls_diff_log-count_date         = sy-datum.
  ls_diff_log-qty_system         = lv_qty_sys.
  ls_diff_log-qty_counted        = iv_qty_cnt.
  ls_diff_log-qty_diff           = iv_qty_cnt - lv_qty_sys.
  ls_diff_log-meins              = iv_meins.
  ls_diff_log-diff_reason        = iv_reason.
  ls_diff_log-adjustment_posted  = lc_posted.
  ls_diff_log-counter            = sy-uname.
  MODIFY zmmt00500 FROM ls_diff_log.
  COMMIT WORK AND WAIT.

  " ---- 6. Success --------------------------------------------------------
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |Recount posted for { iv_invdoc }: |
                && |system={ lv_qty_sys }, counted={ iv_qty_cnt }, |
                && |diff={ iv_qty_cnt - lv_qty_sys }|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
