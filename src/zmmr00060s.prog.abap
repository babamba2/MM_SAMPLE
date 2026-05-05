*&---------------------------------------------------------------------*
*& Include ZMMR00060S — Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_lifnr FOR gv_sel_lifnr.
PARAMETERS:     p_year  TYPE gjahr DEFAULT sy-datum(4),
                p_month TYPE poper DEFAULT sy-datum+4(2).
SELECTION-SCREEN END OF BLOCK b1.
