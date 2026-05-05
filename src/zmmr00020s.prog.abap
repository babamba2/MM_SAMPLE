*&---------------------------------------------------------------------*
*& Include  : ZMMR00020S
*& Purpose  : Selection Screen
*&---------------------------------------------------------------------*

DATA: gv_field TYPE c LENGTH 30.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
  SELECT-OPTIONS: s_ebeln  FOR gs_data-ebeln,
                  s_ebelp  FOR gs_data-ebelp,
                  s_chdate FOR gs_data-ch_date.
  PARAMETERS:     p_field  TYPE c LENGTH 30.
SELECTION-SCREEN END OF BLOCK b1.
