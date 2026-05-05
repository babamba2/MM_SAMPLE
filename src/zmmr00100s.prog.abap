*&---------------------------------------------------------------------*
*& Include ZMMR00100S — Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_werks FOR gv_sel_werks,
                s_budat FOR gv_sel_budat,
                s_matnr FOR gv_sel_matnr.
PARAMETERS: p_discr AS CHECKBOX DEFAULT ' '.
SELECTION-SCREEN END OF BLOCK b1.
