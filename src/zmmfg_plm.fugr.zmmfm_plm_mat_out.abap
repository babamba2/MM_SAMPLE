FUNCTION zmmfm_plm_mat_out.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR_FROM) TYPE  MATNR OPTIONAL
*"     VALUE(IV_MATNR_TO) TYPE  MATNR OPTIONAL
*"     VALUE(IV_MTART) TYPE  MTART OPTIONAL
*"  TABLES
*"      ET_RETURN STRUCTURE  BAPIRET2
*"  EXCEPTIONS
*"      VALIDATION_FAILED
*"      BAPI_ERROR
*"----------------------------------------------------------------------
  CONSTANTS: lc_if_id   TYPE zmme00680 VALUE 'PLM_MAT_OUT',
             lc_dir_out TYPE zmme00690 VALUE 'O',
             lc_stat_p  TYPE zmme00700 VALUE 'P',
             lc_stat_s  TYPE zmme00700 VALUE 'S'.

  DATA: ls_log   TYPE zmmt00650,
        ls_ret   TYPE bapiret2,
        lv_count TYPE i,
        BEGIN OF ls_mat,
          matnr TYPE matnr,
          mtart TYPE mtart,
          matkl TYPE matkl,
          meins TYPE meins,
          mbrsh TYPE mbrsh,
          ersda TYPE ersda,
          laeda TYPE laeda,
          maktx TYPE maktx,
        END OF ls_mat,
        lt_mat   LIKE TABLE OF ls_mat.

  " ---- 1. 로그 INSERT (Pending) ------------------------------------------
  GET TIME STAMP FIELD ls_log-process_ts.
  ls_log-mandt     = sy-mandt.
  ls_log-if_id     = lc_if_id.
  ls_log-seqnr     = 1.
  ls_log-direction = lc_dir_out.
  ls_log-status    = lc_stat_p.
  ls_log-usnam     = sy-uname.
  INSERT zmmt00650 FROM ls_log.

  " ---- 2. MARA + MAKT 조회 (최대 1000건) --------------------------------
  SELECT a~matnr, a~mtart, a~matkl, a~meins, a~mbrsh, a~ersda, a~laeda,
         t~maktx
    FROM mara AS a
    LEFT JOIN makt AS t ON t~matnr = a~matnr
                       AND t~spras = @sy-langu
    INTO CORRESPONDING FIELDS OF TABLE @lt_mat.
  " Trim to max 1000 rows for performance
  IF lines( lt_mat ) > 1000.
    DELETE lt_mat FROM 1001.
  ENDIF.

  " Filter by optional import params
  IF iv_matnr_from IS NOT INITIAL.
    DELETE lt_mat WHERE matnr < iv_matnr_from.
  ENDIF.
  IF iv_matnr_to IS NOT INITIAL.
    DELETE lt_mat WHERE matnr > iv_matnr_to.
  ENDIF.
  IF iv_mtart IS NOT INITIAL.
    DELETE lt_mat WHERE mtart <> iv_mtart.
  ENDIF.

  lv_count = lines( lt_mat ).

  " ---- 3. 결과 메시지 -----------------------------------------------------
  IF lv_count = 0.
    ls_ret-type    = 'W'.
    ls_ret-id      = 'ZMM'.
    ls_ret-number  = '030'.
    ls_ret-message = 'No materials found for the given selection.'.
  ELSE.
    ls_ret-type    = 'S'.
    ls_ret-id      = 'ZMM'.
    ls_ret-number  = '031'.
    ls_ret-message = 'Material outbound extraction completed.'.
  ENDIF.
  APPEND ls_ret TO et_return.

  " ---- 4. 로그 UPDATE (Success) ------------------------------------------
  ls_log-status   = lc_stat_s.
  ls_log-msg_type = ls_ret-type.
  ls_log-msgtxt   = ls_ret-message.
  UPDATE zmmt00650 FROM ls_log.
  COMMIT WORK AND WAIT.

ENDFUNCTION.
