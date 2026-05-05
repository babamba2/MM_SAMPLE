*&---------------------------------------------------------------------*
*& Include ZMMR00160S — SELECTION SCREEN
*&---------------------------------------------------------------------*
DATA: gv_ebeln_sel TYPE ebeln,
      gv_ebelp_sel TYPE ebelp,
      gv_lifnr_sel TYPE lifnr.

SELECT-OPTIONS s_ebeln FOR gv_ebeln_sel.
SELECT-OPTIONS s_ebelp FOR gv_ebelp_sel.
SELECT-OPTIONS s_lifnr FOR gv_lifnr_sel.
PARAMETERS     p_open  AS CHECKBOX DEFAULT ' '.
