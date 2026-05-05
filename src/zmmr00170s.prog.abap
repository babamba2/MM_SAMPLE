*&---------------------------------------------------------------------*
*& Include ZMMR00170S — SELECTION SCREEN
*&---------------------------------------------------------------------*
DATA: gv_matnr_sel  TYPE matnr,
      gv_matnra_sel TYPE matnr,
      gv_werks_sel  TYPE werks_d.

SELECT-OPTIONS s_matnr  FOR gv_matnr_sel.
SELECT-OPTIONS s_matnra FOR gv_matnra_sel.
SELECT-OPTIONS s_werks  FOR gv_werks_sel.
PARAMETERS     p_valid  AS CHECKBOX DEFAULT ' '.
