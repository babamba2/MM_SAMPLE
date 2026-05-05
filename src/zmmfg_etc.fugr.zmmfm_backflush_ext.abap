FUNCTION zmmfm_backflush_ext.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_AUFNR) TYPE  AUFNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_LGORT) TYPE  LGORT_D OPTIONAL
*"     VALUE(IV_BUDAT) TYPE  BUDAT OPTIONAL
*"  EXPORTING
*"     VALUE(EV_MBLNR) TYPE  MBLNR
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_mvt_261  TYPE bwart VALUE '261',
             lc_gm_code  TYPE char2 VALUE '01',
             lc_stat_s   TYPE char1 VALUE 'S',
             lc_stat_e   TYPE char1 VALUE 'E'.

  DATA: ls_gm_header  TYPE bapi2017_gm_head_01,
        ls_gm_code    TYPE bapi2017_gm_code,
        ls_gm_item    TYPE bapi2017_gm_item_create,
        lt_gm_items   TYPE TABLE OF bapi2017_gm_item_create,
        ls_gm_headret TYPE bapi2017_gm_head_ret,
        lt_return     TYPE TABLE OF bapiret2,
        ls_ret        TYPE bapiret2,
        lv_mblnr      TYPE mblnr,
        lv_mjahr      TYPE mjahr,
        lv_budat      TYPE budat.

  TYPES: BEGIN OF ty_comp,
           matnr  TYPE matnr,
           werks  TYPE werks_d,
           lgort  TYPE lgort_d,
           bdmng  TYPE bdmng,
           meins  TYPE meins,
           rsnum  TYPE rsnum,
           rspos  TYPE rspos,
         END OF ty_comp.
  DATA: lt_comps  TYPE TABLE OF ty_comp,
        ls_comp   TYPE ty_comp.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_aufnr IS INITIAL OR iv_werks IS INITIAL.
    ls_ret-type    = lc_stat_e.
    ls_ret-message = 'Production order (IV_AUFNR) and plant (IV_WERKS) are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  lv_budat = COND #( WHEN iv_budat IS NOT INITIAL THEN iv_budat ELSE sy-datum ).

  " ---- 2. Read open reservation items for order from RESB ---------------
  SELECT matnr, werks, lgort, bdmng, meins, rsnum, rspos
    FROM resb
    INTO CORRESPONDING FIELDS OF TABLE @lt_comps
    WHERE aufnr = @iv_aufnr
      AND werks = @iv_werks
      AND kzear = @abap_false
      AND bwart = @lc_mvt_261.

  IF lt_comps IS INITIAL.
    ls_ret-type    = 'I'.
    ls_ret-message = |No open reservation components for order { iv_aufnr }|.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_s.
    RETURN.
  ENDIF.

  " ---- 3. Build GM header ------------------------------------------------
  ls_gm_header-pstng_date = lv_budat.
  ls_gm_header-doc_date   = lv_budat.
  ls_gm_code-gm_code      = lc_gm_code.

  " ---- 4. Build movement items from reservation lines -------------------
  LOOP AT lt_comps INTO ls_comp.
    CLEAR ls_gm_item.
    ls_gm_item-material   = ls_comp-matnr.
    ls_gm_item-plant      = ls_comp-werks.
    ls_gm_item-stge_loc   = COND #( WHEN iv_lgort IS NOT INITIAL
                                    THEN iv_lgort
                                    ELSE ls_comp-lgort ).
    ls_gm_item-move_type  = lc_mvt_261.
    ls_gm_item-entry_qnt  = ls_comp-bdmng.
    ls_gm_item-entry_uom  = ls_comp-meins.
    ls_gm_item-orderid    = iv_aufnr.
    ls_gm_item-reserv_no  = ls_comp-rsnum.
    ls_gm_item-res_item   = ls_comp-rspos.
    APPEND ls_gm_item TO lt_gm_items.
  ENDLOOP.

  " ---- 5. Post goods issue via BAPI_GOODSMVT_CREATE ----------------------
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
  ls_ret-message = |Backflush posted: { lv_mblnr }/{ lv_mjahr } |
                && |for order { iv_aufnr } ({ lines( lt_gm_items ) } components)|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
