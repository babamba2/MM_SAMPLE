*&---------------------------------------------------------------------*
*& Include  : ZMMR00040S
*& Purpose  : Selection Screen
*&---------------------------------------------------------------------*

DATA: gv_erdat TYPE erdat.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
  SELECT-OPTIONS: s_banfn FOR gs_data-banfn,
                  s_erdat FOR gv_erdat.
  PARAMETERS:     p_urgent AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.
