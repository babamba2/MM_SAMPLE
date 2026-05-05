*&---------------------------------------------------------------------*
*& Include ZMMR00200S — SELECTION SCREEN
*&---------------------------------------------------------------------*
DATA: gv_infnr_sel TYPE infnr,
      gv_lifnr_sel TYPE lifnr,
      gv_matnr_sel TYPE matnr,
      gv_chgdt_sel TYPE dats.

SELECT-OPTIONS s_infnr  FOR gv_infnr_sel.
SELECT-OPTIONS s_lifnr  FOR gv_lifnr_sel.
SELECT-OPTIONS s_matnr  FOR gv_matnr_sel.
SELECT-OPTIONS s_chgdt  FOR gv_chgdt_sel.
