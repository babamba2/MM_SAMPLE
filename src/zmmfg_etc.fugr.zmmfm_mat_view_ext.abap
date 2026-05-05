FUNCTION zmmfm_mat_view_ext.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  MATNR
*"     VALUE(IV_WERKS) TYPE  WERKS_D OPTIONAL
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      SELECT_FAILED
*"----------------------------------------------------------------------
  DATA: ls_mara    TYPE mara,
        ls_ext_att TYPE zmmt00680,
        ls_ret     TYPE bapiret2.

  TYPES: BEGIN OF ty_stock,
           werks TYPE werks_d,
           lgort TYPE lgort_d,
           labst TYPE labst,
         END OF ty_stock.
  DATA: lt_stock TYPE TABLE OF ty_stock.

  DATA: lt_stb TYPE TABLE OF stpox.

  TYPES: BEGIN OF ty_doc,
           doknr TYPE doknr,
           dokar TYPE dokar,
           dokvr TYPE dokvr,
           doktl TYPE doktl_d,
         END OF ty_doc.
  DATA: lt_docs  TYPE TABLE OF ty_doc,
        lv_objky TYPE objky.

  CONSTANTS: lc_stat_s  TYPE char1 VALUE 'S',
             lc_stat_e  TYPE char1 VALUE 'E',
             lc_dokob   TYPE dokob  VALUE 'MATERIAL'.

  " ---- 1. Input validation -----------------------------------------------
  IF iv_matnr IS INITIAL.
    ls_ret-type    = 'E'.
    ls_ret-message = 'Material number (IV_MATNR) is required'.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE validation_failed.
  ENDIF.

  " ---- 2. Read MARA (material master general) ----------------------------
  SELECT SINGLE matnr, mtart, matkl, meins, mbrsh, ersda, laeda
    FROM mara
    INTO CORRESPONDING FIELDS OF @ls_mara
    WHERE matnr = @iv_matnr.
  IF sy-subrc <> 0.
    ls_ret-type    = 'E'.
    ls_ret-message = |Material { iv_matnr } not found in MARA|.
    APPEND ls_ret TO et_return.
    ev_status = lc_stat_e.
    RAISE select_failed.
  ENDIF.

  " ---- 3. Read stock from MARD (unrestricted, labst) ---------------------
  IF iv_werks IS INITIAL.
    SELECT werks, lgort, labst
      FROM mard
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock
      WHERE matnr = @iv_matnr.
  ELSE.
    SELECT werks, lgort, labst
      FROM mard
      INTO CORRESPONDING FIELDS OF TABLE @lt_stock
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks.
  ENDIF.

  " ---- 4. Explode BOM (single-level) via CS_BOM_EXPL_MAT_V2 -------------
  IF iv_werks IS NOT INITIAL.
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        capid   = 'PP01'
        datuv   = sy-datum
        mtnrv   = iv_matnr
        werks   = iv_werks
        mehrs   = abap_true
      TABLES
        stb     = lt_stb
      EXCEPTIONS
        alt_not_found         = 1
        call_invalid          = 2
        material_not_found    = 3
        missing_authorization = 4
        no_bom_found          = 5
        no_plant_data         = 6
        no_suitable_bom_found = 7
        conversion_error      = 8
        OTHERS                = 9.
    " sy-subrc <> 0 is acceptable (no BOM = informational only)
  ENDIF.

  " ---- 5. Read DMS document links via DRAD (dokob=MATERIAL, objky=matnr) -
  lv_objky = iv_matnr.
  SELECT doknr, dokar, dokvr, doktl
    FROM drad
    INTO CORRESPONDING FIELDS OF TABLE @lt_docs
    WHERE dokob = @lc_dokob
      AND objky = @lv_objky.

  " ---- 6. Read extension attributes ZMMT00680 ----------------------------
  SELECT SINGLE *
    FROM zmmt00680
    INTO @ls_ext_att
    WHERE matnr = @iv_matnr.

  " ---- 7. Success --------------------------------------------------------
  ev_status = lc_stat_s.
  ls_ret-type    = 'S'.
  ls_ret-message = |Material { iv_matnr }: { lines( lt_stock ) } stock rows, |
                && |{ lines( lt_stb ) } BOM items, { lines( lt_docs ) } DMS docs|.
  APPEND ls_ret TO et_return.

ENDFUNCTION.
