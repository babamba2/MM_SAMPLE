FUNCTION zmmfm_wms_gr_out.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(IV_LGORT) TYPE  LGORT_D OPTIONAL
*"  EXPORTING
*"     VALUE(EV_COUNT) TYPE  I
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id    TYPE zmme00680 VALUE 'WMS_GR_OUT',
             lc_dir_out  TYPE zmme00690 VALUE 'O',
             lc_stat_s   TYPE zmme00700 VALUE 'S',
             lc_stat_e   TYPE zmme00700 VALUE 'E',
             lc_mvt_101  TYPE bwart     VALUE '101',
             lc_mvt_105  TYPE bwart     VALUE '105'.

  TYPES: BEGIN OF ty_gr,
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
           ebeln TYPE ebeln,
           ebelp TYPE ebelp,
         END OF ty_gr.
  DATA: lt_gr    TYPE TABLE OF ty_gr,
        ls_gr    TYPE ty_gr,
        ls_log   TYPE zmmt00660,
        ls_ret   TYPE bapiret2,
        lv_seqnr TYPE zmme00740.

  " ---- 1. Select GR movements from MKPF/MSEG (today, mvt 101/105) -------
  IF iv_werks IS INITIAL AND iv_lgort IS INITIAL.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins, s~ebeln, s~ebelp
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_gr
      WHERE s~bwart IN ( @lc_mvt_101, @lc_mvt_105 )
        AND h~budat = @sy-datum.
  ELSEIF iv_lgort IS INITIAL.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins, s~ebeln, s~ebelp
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_gr
      WHERE s~bwart IN ( @lc_mvt_101, @lc_mvt_105 )
        AND s~werks = @iv_werks
        AND h~budat = @sy-datum.
  ELSE.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins, s~ebeln, s~ebelp
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_gr
      WHERE s~bwart IN ( @lc_mvt_101, @lc_mvt_105 )
        AND s~werks = @iv_werks
        AND s~lgort = @iv_lgort
        AND h~budat = @sy-datum.
  ENDIF.

  " ---- 2. Log each GR line to ZMMT00660 ----------------------------------
  LOOP AT lt_gr INTO ls_gr.
    ADD 1 TO lv_seqnr.
    CLEAR ls_log.
    GET TIME STAMP FIELD ls_log-process_ts.
    ls_log-mandt     = sy-mandt.
    ls_log-if_id     = lc_if_id.
    ls_log-seqnr     = lv_seqnr.
    ls_log-direction = lc_dir_out.
    ls_log-werks     = ls_gr-werks.
    ls_log-lgort     = ls_gr-lgort.
    ls_log-matnr     = ls_gr-matnr.
    ls_log-mblnr     = ls_gr-mblnr.
    ls_log-menge     = ls_gr-menge.
    ls_log-meins     = ls_gr-meins.
    ls_log-status    = lc_stat_s.
    ls_log-msgtxt    = |GR: { ls_gr-mblnr } mvt { ls_gr-bwart } { ls_gr-menge } { ls_gr-meins }|.
    ls_log-usnam     = sy-uname.
    INSERT zmmt00660 FROM ls_log.
  ENDLOOP.
  COMMIT WORK AND WAIT.

  " ---- 3. Build success return -------------------------------------------
  ev_count  = lines( lt_gr ).
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |WMS_GR_OUT: { ev_count } GR lines sent for { sy-datum }|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
