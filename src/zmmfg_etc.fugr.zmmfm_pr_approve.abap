FUNCTION zmmfm_pr_approve.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BANFN) TYPE  BANFN
*"     VALUE(IV_FRGCO) TYPE  FRGCO
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  ZMME00700
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  DATA: lt_rel_info   TYPE TABLE OF bapieban,
        lt_return     TYPE TABLE OF bapiret2,
        ls_ret        TYPE bapiret2,
        lv_released   TYPE char1.

  CONSTANTS: lc_stat_s TYPE zmme00700 VALUE 'S',
             lc_stat_e TYPE zmme00700 VALUE 'E'.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_banfn IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Purchase requisition number (IV_BANFN) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. 사전 조회: 현재 릴리즈 상태 확인 --------------------------------
  CALL FUNCTION 'BAPI_REQUISITION_GETRELINFO'
    EXPORTING
      number            = iv_banfn
    TABLES
      requisition_items = lt_rel_info
      return            = lt_return.

  READ TABLE lt_return WITH KEY type = 'E' INTO ls_ret.
  IF sy-subrc = 0.
    APPEND LINES OF lt_return TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  CLEAR: lt_return, ls_ret.

  " ---- 3. BAPI_REQUISITION_RELEASE 호출 ----------------------------------
  CALL FUNCTION 'BAPI_REQUISITION_RELEASE'
    EXPORTING
      number            = iv_banfn
      release_code      = iv_frgco
    IMPORTING
      released          = lv_released
    TABLES
      return            = lt_return.

  " ---- 4. 오류 체크 -------------------------------------------------------
  READ TABLE lt_return WITH KEY type = 'E' INTO ls_ret.
  IF sy-subrc = 0.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    APPEND LINES OF lt_return TO et_return.
    ev_status = lc_stat_e.
    RAISE bapi_error.
  ENDIF.

  " ---- 5. 커밋 -----------------------------------------------------------
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = abap_true.

  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |PR { iv_banfn } released (code { iv_frgco }): { lv_released }|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
