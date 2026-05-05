FUNCTION zmmfm_comp_avail_chk.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_MEINS) TYPE  MEINS
*"     VALUE(IV_REQ_QTY) TYPE  MENGE_D
*"     VALUE(IV_REQ_DATE) TYPE  DATS OPTIONAL
*"  EXPORTING
*"     VALUE(EV_AVAIL_QTY) TYPE  MENGE_D
*"     VALUE(EV_AVAILABLE) TYPE  ABAP_BOOL
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
  CONSTANTS: lc_stat_s  TYPE char1 VALUE 'S',
             lc_stat_e  TYPE char1 VALUE 'E'.

  DATA: lv_req_date   TYPE dats,
        lv_endleadtme TYPE bapi2017_gm_head_01-pstng_date,
        lv_av_qty     TYPE menge_d,
        lv_dialogflag TYPE bapiflag,
        ls_atp_return TYPE bapireturn,
        lt_wmdvsx     TYPE TABLE OF bapiwmdvs,
        lt_wmdvex     TYPE TABLE OF bapiwmdve,
        ls_wmdvsx     TYPE bapiwmdvs,
        ls_ret        TYPE bapiret2.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL OR iv_werks IS INITIAL.
    ls_ret-type    = lc_stat_e.
    ls_ret-message = 'Material (IV_MATNR) and plant (IV_WERKS) are required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RETURN.
  ENDIF.
  lv_req_date = COND #( WHEN iv_req_date IS NOT INITIAL THEN iv_req_date ELSE sy-datum ).

  " ---- 2. Build requirement schedule (one line = the requirement date/qty)
  CLEAR ls_wmdvsx.
  ls_wmdvsx-req_date = lv_req_date.
  ls_wmdvsx-req_qty  = iv_req_qty.
  APPEND ls_wmdvsx TO lt_wmdvsx.

  " ---- 3. Call BAPI_MATERIAL_AVAILABILITY (ATP check) -------------------
  CALL FUNCTION 'BAPI_MATERIAL_AVAILABILITY'
    EXPORTING
      plant       = iv_werks
      material    = iv_matnr
      unit        = iv_meins
    IMPORTING
      endleadtme  = lv_endleadtme
      av_qty_plt  = lv_av_qty
      dialogflag  = lv_dialogflag
      return      = ls_atp_return
    TABLES
      wmdvsx      = lt_wmdvsx
      wmdvex      = lt_wmdvex.

  " ---- 4. Handle errors --------------------------------------------------
  IF ls_atp_return-type = 'E'.
    ls_ret-type    = 'E'.
    ls_ret-message = ls_atp_return-message.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RETURN.
  ENDIF.

  " ---- 5. Compare available qty vs required qty -------------------------
  ev_avail_qty = lv_av_qty.
  IF lv_av_qty >= iv_req_qty.
    ev_available = abap_true.
  ELSE.
    ev_available = abap_false.
  ENDIF.

  " ---- 6. Success --------------------------------------------------------
  ev_status = lc_stat_s.
  ls_ret-type = 'S'.
  IF ev_available = abap_true.
    ls_ret-message = |Material { iv_matnr }: available qty { lv_av_qty } |
                  && |>= required { iv_req_qty } { iv_meins } (OK)|.
  ELSE.
    ls_ret-message = |Material { iv_matnr }: available qty { lv_av_qty } |
                  && |< required { iv_req_qty } { iv_meins } (SHORTAGE)|.
  ENDIF.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
