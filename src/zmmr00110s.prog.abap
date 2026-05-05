*&---------------------------------------------------------------------*
*& Include  ZMMR00110S — GI 반품 사유 분석 Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_budat FOR gs_alv_0100-return_date,
                s_matnr FOR gs_alv_0100-matnr,
                s_lifnr FOR gs_alv_0100-lifnr.
SELECTION-SCREEN END OF BLOCK b01.
