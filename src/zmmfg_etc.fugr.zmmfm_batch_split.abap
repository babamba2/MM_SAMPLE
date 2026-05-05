FUNCTION zmmfm_batch_split.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_LGORT) TYPE  LGORT_D
*"     VALUE(IV_CHARG) TYPE  CHARG_D
*"     VALUE(IV_CHARG_N) TYPE  CHARG_D
*"     VALUE(IV_MENGE) TYPE  MENGE_D
*"     VALUE(IV_MEINS) TYPE  MEINS
*"  EXPORTING
*"     VALUE(EV_MBLNR) TYPE  MBLNR
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_mvt_344 TYPE bwart VALUE '344',
             lc_mvt_345 TYPE bwart VALUE '345',
             lc_gm_code TYPE char2 VALUE '04',
             lc_stat_s  TYPE char1 VALUE 'S',
             lc_stat_e  TYPE char1 VALUE 'E'.

  DATA: ls_gm_header  TYPE bapi2017_gm_head_01,
        ls_gm_code    TYPE bapi2017_gm_code,
        ls_gm_item    TYPE bapi2017_gm_item_create,
        lt_gm_items   TYPE TABLE OF bapi2017_gm_item_create,
        ls_gm_headret TYPE bapi2017_gm_head_ret,
        lt_return     TYPE TABLE OF bapiret2,
        ls_ret        TYPE bapiret2,
        lv_mblnr      TYPE mblnr,
        lv_mjahr      TYPE mjahr.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL OR iv_werks IS INITIAL OR iv_charg IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Material, plant and source batch are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  IF iv_charg_n IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'New child batch number (IV_CHARG_N) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  IF iv_menge <= 0.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Split quantity must be greater than zero'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Build GM header ------------------------------------------------
  ls_gm_header-pstng_date = sy-datum.
  ls_gm_header-doc_date   = sy-datum.
  ls_gm_code-gm_code      = lc_gm_code.

  " ---- 3. Line 1: consume from source batch (mvt 344) -------------------
  CLEAR ls_gm_item.
  ls_gm_item-material   = iv_matnr.
  ls_gm_item-plant      = iv_werks.
  ls_gm_item-stge_loc   = iv_lgort.
  ls_gm_item-batch      = iv_charg.
  ls_gm_item-move_type  = lc_mvt_344.
  ls_gm_item-entry_qnt  = iv_menge.
  ls_gm_item-entry_uom  = iv_meins.
  ls_gm_item-move_batch = iv_charg_n.
  APPEND ls_gm_item TO lt_gm_items.

  " ---- 4. Line 2: receive into new child batch (mvt 345) ----------------
  CLEAR ls_gm_item.
  ls_gm_item-material   = iv_matnr.
  ls_gm_item-plant      = iv_werks.
  ls_gm_item-stge_loc   = iv_lgort.
  ls_gm_item-batch      = iv_charg_n.
  ls_gm_item-move_type  = lc_mvt_345.
  ls_gm_item-entry_qnt  = iv_menge.
  ls_gm_item-entry_uom  = iv_meins.
  ls_gm_item-move_batch = iv_charg.
  APPEND ls_gm_item TO lt_gm_items.

  " ---- 5. Post goods movement via BAPI -----------------------------------
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
  READ TABLE lt_return WITH KEY type = 'E' TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    APPEND LINES OF lt_return TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 7. Commit ---------------------------------------------------------
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  " ---- 8. Success --------------------------------------------------------
  ev_mblnr  = lv_mblnr.
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |Batch split posted: { lv_mblnr }/{ lv_mjahr } |
                && |({ iv_charg }->{ iv_charg_n } qty={ iv_menge } { iv_meins })|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
