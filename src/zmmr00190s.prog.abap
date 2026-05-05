*&---------------------------------------------------------------------*
*& Include ZMMR00190S — SELECTION SCREEN
*&---------------------------------------------------------------------*
DATA gv_matnr_sel TYPE matnr.

SELECT-OPTIONS s_matnr FOR gv_matnr_sel.
PARAMETERS: p_reg      TYPE char10 DEFAULT 'ALL',
            p_expire   TYPE i      DEFAULT 30.
