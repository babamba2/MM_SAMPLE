*&---------------------------------------------------------------------*
*& Include  : ZMMR00030S
*& Purpose  : Selection Screen
*&---------------------------------------------------------------------*

DATA: gv_werks TYPE werks_d,
      gv_delay TYPE i.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
  SELECT-OPTIONS: s_ebeln FOR gs_data-ebeln,
                  s_werks FOR gv_werks,
                  s_delay FOR gv_delay.
SELECTION-SCREEN END OF BLOCK b1.
