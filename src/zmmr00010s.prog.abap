*&---------------------------------------------------------------------*
*& Include  : ZMMR00010S
*& Purpose  : Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
  SELECT-OPTIONS: s_banfn FOR gs_data-banfn,
                  s_erdat FOR gs_data-erdat.
  PARAMETERS:     p_status TYPE c LENGTH 1.
SELECTION-SCREEN END OF BLOCK b1.
