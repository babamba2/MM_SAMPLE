*&---------------------------------------------------------------------*
*& Include ZMMR00080S — Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_matnr FOR gv_sel_matnr,
                s_werks FOR gv_sel_werks,
                s_lifnr FOR gv_sel_lifnr.
SELECTION-SCREEN END OF BLOCK b1.
