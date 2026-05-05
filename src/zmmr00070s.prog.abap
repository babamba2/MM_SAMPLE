*&---------------------------------------------------------------------*
*& Include ZMMR00070S — Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_lifnr  FOR gv_sel_lifnr,
                s_evdate FOR gv_sel_date.
SELECTION-SCREEN END OF BLOCK b1.
