*&---------------------------------------------------------------------*
*& Include ZMMR00190T — TOP: Types, Data, Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_s_output,
         matnr            TYPE matnr,
         maktx            TYPE maktx,
         regulation       TYPE char10,
         check_seq        TYPE numc4,
         cert_id          TYPE char40,
         cert_valid_from  TYPE dats,
         cert_valid_to    TYPE dats,
         days_to_expiry   TYPE i,
         substance_list   TYPE char255,
         cert_verif_status TYPE zmme00430,
       END OF ty_s_output.

TYPES ty_t_output TYPE STANDARD TABLE OF ty_s_output WITH DEFAULT KEY.

DATA: gt_output    TYPE ty_t_output,
      gv_expiry_cnt TYPE i,
      go_container TYPE REF TO cl_gui_docking_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

CONSTANTS: gc_reg_all    TYPE char10 VALUE 'ALL',
           gc_reg_rohs   TYPE char10 VALUE 'RoHS',
           gc_reg_reach  TYPE char10 VALUE 'REACH',
           gc_status_0100 TYPE char14 VALUE 'STATUS_0100'.
