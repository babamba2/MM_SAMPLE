*&---------------------------------------------------------------------*
*& Include  : ZMMR00050S
*& Purpose  : Selection Screen
*&---------------------------------------------------------------------*

DATA: gv_deviat TYPE p DECIMALS 2.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
  SELECT-OPTIONS: s_ebeln  FOR gs_data-ebeln,
                  s_deviat FOR gv_deviat.
SELECTION-SCREEN END OF BLOCK b1.
