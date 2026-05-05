FUNCTION zmmfm_po_create_ext.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_LIFNR) TYPE  LIFNR
*"     VALUE(IV_EKORG) TYPE  EKORG
*"     VALUE(IV_EKGRP) TYPE  BKGRP
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_LGORT) TYPE  LGORT_D
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_MENGE) TYPE  BSTMG
*"     VALUE(IV_MEINS) TYPE  MEINS
*"     VALUE(IV_NETPR) TYPE  BAPICUREXT
*"     VALUE(IV_WAERS) TYPE  WAERS
*"     VALUE(IV_BEDAT) TYPE  BEDAT OPTIONAL
*"  EXPORTING
*"     VALUE(EV_EBELN) TYPE  EBELN
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_doc_type TYPE esart VALUE 'NB',
             lc_stat_s   TYPE char1 VALUE 'S',
             lc_stat_e   TYPE char1 VALUE 'E'.

  DATA: ls_po_header   TYPE bapimepoheader,
        ls_po_headerx  TYPE bapimepoheaderx,
        ls_po_item     TYPE bapimepoitem,
        ls_po_itemx    TYPE bapimepoitemx,
        ls_po_sched    TYPE bapimeposchedule,
        ls_po_schedx   TYPE bapimeposchedulx,
        lt_po_items    TYPE TABLE OF bapimepoitem,
        lt_po_itemsx   TYPE TABLE OF bapimepoitemx,
        lt_po_sched    TYPE TABLE OF bapimeposchedule,
        lt_po_schedx   TYPE TABLE OF bapimeposchedulx,
        lt_return      TYPE TABLE OF bapiret2,
        ls_ret         TYPE bapiret2,
        lv_ebeln       TYPE ebeln.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_lifnr IS INITIAL OR iv_ekorg IS INITIAL OR iv_matnr IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Vendor, purchasing org, and material are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Build PO header ------------------------------------------------
  ls_po_header-doc_type  = lc_doc_type.
  ls_po_header-vendor    = iv_lifnr.
  ls_po_header-purch_org = iv_ekorg.
  ls_po_header-pur_group = iv_ekgrp.
  ls_po_header-doc_date  = sy-datum.
  ls_po_header-currency  = iv_waers.
  ls_po_headerx-doc_type  = abap_true.
  ls_po_headerx-vendor    = abap_true.
  ls_po_headerx-purch_org = abap_true.
  ls_po_headerx-pur_group = abap_true.
  ls_po_headerx-doc_date  = abap_true.
  ls_po_headerx-currency  = abap_true.

  " ---- 3. Build PO item --------------------------------------------------
  ls_po_item-po_item    = '00010'.
  ls_po_item-material   = iv_matnr.
  ls_po_item-plant      = iv_werks.
  ls_po_item-stge_loc   = iv_lgort.
  ls_po_item-quantity   = iv_menge.
  ls_po_item-po_unit    = iv_meins.
  ls_po_item-net_price  = iv_netpr.
  ls_po_item-price_unit = 1.
  ls_po_itemx-po_item   = '00010'.
  ls_po_itemx-material  = abap_true.
  ls_po_itemx-plant     = abap_true.
  ls_po_itemx-stge_loc  = abap_true.
  ls_po_itemx-quantity  = abap_true.
  ls_po_itemx-po_unit   = abap_true.
  ls_po_itemx-net_price = abap_true.
  APPEND ls_po_item  TO lt_po_items.
  APPEND ls_po_itemx TO lt_po_itemsx.

  " ---- 4. Build schedule line (delivery date) ----------------------------
  ls_po_sched-po_item       = '00010'.
  ls_po_sched-sched_line    = '0001'.
  ls_po_sched-delivery_date = COND #( WHEN iv_bedat IS NOT INITIAL
                                      THEN iv_bedat ELSE sy-datum ).
  ls_po_sched-quantity      = iv_menge.
  ls_po_schedx-po_item      = '00010'.
  ls_po_schedx-sched_line   = '0001'.
  ls_po_schedx-delivery_date = abap_true.
  ls_po_schedx-quantity     = abap_true.
  APPEND ls_po_sched  TO lt_po_sched.
  APPEND ls_po_schedx TO lt_po_schedx.

  " ---- 5. Call BAPI_PO_CREATE1 ------------------------------------------
  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      poheader  = ls_po_header
      poheaderx = ls_po_headerx
    IMPORTING
      exppurchaseorder = lv_ebeln
    TABLES
      return      = lt_return
      poitem      = lt_po_items
      poitemx     = lt_po_itemsx
      poschedule  = lt_po_sched
      poschedulex = lt_po_schedx.

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
  ev_ebeln  = lv_ebeln.
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |PO { lv_ebeln } created for vendor { iv_lifnr }|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
