*&---------------------------------------------------------------------*
*& Include  ZMMR00130S — 수입/통관 문서 추적 Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_ebeln   FOR gs_alv_0100-ebeln,
                s_trkdat  FOR gs_alv_0100-import_date,
                s_carrie  FOR gs_alv_0100-carrier_code.
SELECTION-SCREEN END OF BLOCK b01.
