*&---------------------------------------------------------------------*
*& Include ZMMR00160T — TOP: Types, Data, Constants
*&---------------------------------------------------------------------*

* Output structure
TYPES: BEGIN OF ty_s_output,
         ebeln              TYPE ebeln,
         ebelp              TYPE ebelp,
         stage_seq          TYPE numc4,
         stage_name         TYPE char30,
         stage_qty          TYPE p LENGTH 8 DECIMALS 3,
         stage_progress_pct TYPE p LENGTH 5 DECIMALS 2,
         issued_qty         TYPE p LENGTH 8 DECIMALS 3,
         returned_qty       TYPE p LENGTH 8 DECIMALS 3,
         remaining_qty      TYPE p LENGTH 8 DECIMALS 3,
         meins              TYPE meins,
         lifnr              TYPE lifnr,
         name1              TYPE name1_gp,
         last_update        TYPE timestampl,
       END OF ty_s_output.

TYPES ty_t_output TYPE STANDARD TABLE OF ty_s_output WITH DEFAULT KEY.

* Globals
DATA: gt_output      TYPE ty_t_output,
      go_container   TYPE REF TO cl_gui_docking_container,
      go_alv         TYPE REF TO cl_gui_alv_grid.

* Constants
CONSTANTS: gc_status_0100 TYPE char14  VALUE 'STATUS_0100',
           gc_screen_0100 TYPE numc4   VALUE '0100'.
