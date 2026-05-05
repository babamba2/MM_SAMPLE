FUNCTION zmmfm_mat_hist_get.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D OPTIONAL
*"     VALUE(IV_DATE_FROM) TYPE  DATS
*"     VALUE(IV_DATE_TO) TYPE  DATS
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_objclas  TYPE cdobjectcl VALUE 'MATERIAL',
             lc_stat_s   TYPE char1      VALUE 'S',
             lc_stat_e   TYPE char1      VALUE 'E',
             lc_max_chg  TYPE i          VALUE 500,
             lc_max_mov  TYPE i          VALUE 1000.

  DATA: ls_ret      TYPE bapiret2,
        lv_objectid TYPE cdobjectv,
        lt_cdhdr    TYPE TABLE OF cdhdr,
        lt_cdpos    TYPE TABLE OF cdpos.

  TYPES: BEGIN OF ty_mov,
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
         END OF ty_mov.
  DATA: lt_movs TYPE TABLE OF ty_mov.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL.
    ls_ret-type    = lc_stat_e.
    ls_ret-message = 'Material number (IV_MATNR) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.
  IF iv_date_from IS INITIAL OR iv_date_to IS INITIAL.
    ls_ret-type    = lc_stat_e.
    ls_ret-message = 'Date range (IV_DATE_FROM / IV_DATE_TO) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Read change document headers (CDHDR) for MATERIAL object class -
  lv_objectid = iv_matnr.
  SELECT *
    FROM cdhdr
    INTO TABLE @lt_cdhdr
    WHERE objectclas = @lc_objclas
      AND objectid   = @lv_objectid
      AND udate BETWEEN @iv_date_from AND @iv_date_to.
  IF lines( lt_cdhdr ) > lc_max_chg.
    DELETE lt_cdhdr FROM lc_max_chg + 1.
  ENDIF.

  " ---- 3. Read change document details (CDPOS) for collected headers -----
  IF lt_cdhdr IS NOT INITIAL.
    SELECT *
      FROM cdpos
      INTO TABLE @lt_cdpos
      FOR ALL ENTRIES IN @lt_cdhdr
      WHERE objectclas = @lc_objclas
        AND objectid   = @lt_cdhdr-objectid
        AND changenr   = @lt_cdhdr-changenr.
  ENDIF.

  " ---- 4. Read stock movements from MSEG/MKPF ----------------------------
  IF iv_werks IS INITIAL.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins, s~ebeln, s~ebelp
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_movs
      WHERE s~matnr = @iv_matnr
        AND h~budat BETWEEN @iv_date_from AND @iv_date_to.
  ELSE.
    SELECT h~mblnr, h~mjahr, s~zeile, h~budat,
           s~matnr, s~werks, s~lgort, s~bwart,
           s~menge, s~meins, s~ebeln, s~ebelp
      FROM mkpf AS h
      INNER JOIN mseg AS s ON s~mblnr = h~mblnr AND s~mjahr = h~mjahr
      INTO CORRESPONDING FIELDS OF TABLE @lt_movs
      WHERE s~matnr = @iv_matnr
        AND s~werks = @iv_werks
        AND h~budat BETWEEN @iv_date_from AND @iv_date_to.
  ENDIF.
  IF lines( lt_movs ) > lc_max_mov.
    DELETE lt_movs FROM lc_max_mov + 1.
  ENDIF.

  " ---- 5. Success --------------------------------------------------------
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |Material { iv_matnr } history { iv_date_from }-{ iv_date_to }: |
                && |{ lines( lt_cdhdr ) } change docs, { lines( lt_cdpos ) } field changes, |
                && |{ lines( lt_movs ) } stock movements|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
