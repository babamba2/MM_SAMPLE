*&---------------------------------------------------------------------*
*& Include  ZMMR00140S — 재고 노화 리포트 Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_matnr FOR gs_alv_0100-matnr,
                s_werks FOR gs_alv_0100-werks,
                s_lgort FOR gs_alv_0100-lgort,
                s_abc   FOR gs_alv_0100-abc_class.
PARAMETERS:     p_year  TYPE numc4,
                p_month TYPE numc2.
SELECTION-SCREEN END OF BLOCK b01.
