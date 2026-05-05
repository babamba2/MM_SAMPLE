*&---------------------------------------------------------------------*
*& Include ZMMR00200T — TOP: Types, Data, Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_s_output,
         infnr      TYPE infnr,
         matnr      TYPE matnr,
         maktx      TYPE maktx,
         lifnr      TYPE lifnr,
         name1      TYPE name1_gp,
         ekorg      TYPE ekorg,
         change_seq TYPE numc4,
         ch_field   TYPE char30,
         ch_old_val TYPE char50,
         ch_new_val TYPE char50,
         reason     TYPE char30,
         approver   TYPE syuname,
         appr_date  TYPE dats,
         usnam      TYPE syuname,
       END OF ty_s_output.

TYPES ty_t_output TYPE STANDARD TABLE OF ty_s_output WITH DEFAULT KEY.

DATA: gt_output    TYPE ty_t_output,
      go_container TYPE REF TO cl_gui_docking_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

CONSTANTS gc_status_0100 TYPE char14 VALUE 'STATUS_0100'.
