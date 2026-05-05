FUNCTION zmmfm_wms_gi_out.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_WERKS) TYPE  WERKS_D
*"     VALUE(IV_LGORT) TYPE  LGORT_D OPTIONAL
*"     VALUE(IV_DATE_FROM) TYPE  BUDAT OPTIONAL
*"     VALUE(IV_DATE_TO) TYPE  BUDAT OPTIONAL
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id   TYPE zmme00680 VALUE 'WMS_GI_OUT',
             lc_dir_out TYPE zmme00690 VALUE 'O',
             lc_stat_p  TYPE zmme00700 VALUE 'P',
             lc_stat_s  TYPE zmme00700 VALUE 'S',
             lc_mvt_601 TYPE bwart      VALUE '601',
             lc_mvt_261 TYPE bwart      VALUE '261'.

  DATA: ls_log    TYPE zmmt00660,
        ls_ret    TYPE bapiret2,
        lv_count  TYPE i,
        lv_date_f TYPE budat,
        lv_date_t TYPE budat,
        BEGIN OF ls_gi,
          mblnr TYPE mblnr,
          mjahr TYPE mjahr,
          zeile TYPE mblpo,
          budat TYPE budat,
          matnr TYPE matnr,
          werks TYPE werks_d,
          lgort TYPE lgort_d,
          bwart TYPE bwart,
          menge TYPE menge_d,
          meins TYPE meins,
        END OF ls_gi,
        lt_gi     LIKE TABLE OF ls_gi.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_werks IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Plant (IV_WERKS) is required'.
    APPEND ls_ret TO et_return.
    RAISE validation_failed.
  ENDIF.
  lv_date_f = COND #( WHEN iv_date_from IS NOT INITIAL THEN iv_date_from ELSE sy-datum ).
  lv_date_t = COND #( WHEN iv_date_to   IS NOT INITIAL THEN iv_date_to   ELSE sy-datum ).

  " ---- 2. 로그 INSERT (Pending) ------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = 1.
  ls_log-direction = lc_dir_out.
  ls_log-status    = lc_stat_p.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00660 FROM ls_log.

  " ---- 3. MKPF/MSEG 조회 — GI 이동유형 601/261 --------------------------
  IF iv_lgort IS INITIAL.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_gi
      WHERE s~bwart IN ( @lc_mvt_601, @lc_mvt_261 )
        AND s~werks = @iv_werks
        AND h~budat BETWEEN @lv_date_f AND @lv_date_t.
  ELSE.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_gi
      WHERE s~bwart IN ( @lc_mvt_601, @lc_mvt_261 )
        AND s~werks = @iv_werks
        AND s~lgort = @iv_lgort
        AND h~budat BETWEEN @lv_date_f AND @lv_date_t.
  ENDIF.

  lv_count = lines( lt_gi ).

  " ---- 4. 결과 메시지 -----------------------------------------------------
  IF lv_count = 0.
    ls_ret-type    = 'W'.
    ls_ret-id      = 'ZMM'.
    ls_ret-number  = '060'.
    ls_ret-message = 'No GI documents found.'.
  ELSE.
    ls_ret-type    = 'S'.
    ls_ret-id      = 'ZMM'.
    ls_ret-number  = '061'.
    ls_ret-message = 'GI outbound extraction completed.'.
  ENDIF.
  APPEND ls_ret TO et_return.

  " ---- 5. 로그 UPDATE (Success) ------------------------------------------
  ls_log-status = lc_stat_s.
  ls_log-msgtxt = ls_ret-message.
  UPDATE zmmt00660 FROM ls_log.
  COMMIT WORK AND WAIT.

ENDFUNCTION.
