*&---------------------------------------------------------------------*
*& Include  ZMMR00150S — Cycle Count 차이 리포트 Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_matnr  FOR gs_alv_0100-matnr,
                s_werks  FOR gs_alv_0100-werks,
                s_lgort  FOR gs_alv_0100-lgort,
                s_cntdat FOR gs_alv_0100-post_date.
PARAMETERS:     p_var    TYPE p LENGTH 4 DECIMALS 2 DEFAULT '0.00'.
SELECTION-SCREEN END OF BLOCK b01.
