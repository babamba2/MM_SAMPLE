*&---------------------------------------------------------------------*
*& Include ZMMR00180S — SELECTION SCREEN
*&---------------------------------------------------------------------*
DATA: gv_matnr_sel TYPE matnr,
      gv_dsn_sel   TYPE zmme00710.

SELECT-OPTIONS s_matnr  FOR gv_matnr_sel.
SELECT-OPTIONS s_dsn    FOR gv_dsn_sel.
SELECT-OPTIONS s_lsync  FOR sy-datum.
