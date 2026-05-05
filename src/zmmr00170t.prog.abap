*&---------------------------------------------------------------------*
*& Include ZMMR00170T — TOP: Types, Data, Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_s_output,
         matnr_primary    TYPE matnr,
         maktx_primary    TYPE maktx,
         matnr_alt        TYPE matnr,
         maktx_alt        TYPE maktx,
         werks            TYPE werks_d,
         substitution_ratio TYPE p LENGTH 5 DECIMALS 2,
         valid_from       TYPE dats,
         valid_to         TYPE dats,
         created_by       TYPE syuname,
       END OF ty_s_output.

TYPES ty_t_output TYPE STANDARD TABLE OF ty_s_output WITH DEFAULT KEY.

DATA: gt_output    TYPE ty_t_output,
      go_container TYPE REF TO cl_gui_docking_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

CONSTANTS: gc_status_0100 TYPE char14 VALUE 'STATUS_0100',
           gc_screen_0100 TYPE numc4  VALUE '0100'.
