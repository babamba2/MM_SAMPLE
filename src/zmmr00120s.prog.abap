*&---------------------------------------------------------------------*
*& Include  ZMMR00120S — 스크랩 원가 분석 Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_budat FOR gs_alv_0100-budat,
                s_werks FOR gs_alv_0100-werks,
                s_matnr FOR gs_alv_0100-matnr,
                s_dept  FOR gs_alv_0100-department.
SELECTION-SCREEN END OF BLOCK b01.
