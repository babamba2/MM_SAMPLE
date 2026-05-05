*&---------------------------------------------------------------------*
*& Include ZMMR00090S — Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_lifnr  FOR gv_sel_lifnr,
                s_status FOR gv_sel_status.
SELECTION-SCREEN END OF BLOCK b1.
