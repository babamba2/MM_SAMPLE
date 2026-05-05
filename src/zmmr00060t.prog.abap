*&---------------------------------------------------------------------*
*& Include ZMMR00060T — TOP: Types, Data, Constants
*&---------------------------------------------------------------------*

*-- Types
TYPES: BEGIN OF ty_kpi,
         lifnr      TYPE lifnr,
         name1      TYPE name1,
         bukrs      TYPE bukrs,
         butxt      TYPE butxt,
         kpi_year   TYPE numc4,
         kpi_month  TYPE numc2,
         otd_rate   TYPE p DECIMALS 2,
         quality_rate TYPE p DECIMALS 2,
         claim_count  TYPE i,
         po_count     TYPE i,
         lead_time_avg TYPE p DECIMALS 1,
         po_amount    TYPE p DECIMALS 2,
         waers        TYPE waers,
       END OF ty_kpi.

*-- Global Data
DATA: gt_kpi     TYPE STANDARD TABLE OF ty_kpi,
      go_dock    TYPE REF TO cl_gui_docking_container,
      go_alv     TYPE REF TO cl_gui_alv_grid,
      gt_fcat    TYPE lvc_t_fcat,
      gs_layout  TYPE lvc_s_layo.

DATA: gv_sel_lifnr TYPE lifnr.

*-- Constants
CONSTANTS: gc_status_0100 TYPE c LENGTH 20 VALUE 'STATUS_0100'.
