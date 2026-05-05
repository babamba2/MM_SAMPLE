*&---------------------------------------------------------------------*
*& Include ZMMR00100T — TOP: Types / Data / Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_gr_disc,
         mblnr        TYPE mblnr,
         mjahr        TYPE mjahr,
         zeile        TYPE numc4,
         matnr        TYPE matnr,
         maktx        TYPE maktx,
         werks        TYPE werks_d,
         lgort        TYPE lgort_d,
         qty_expected TYPE p DECIMALS 3,
         qty_received TYPE p DECIMALS 3,
         qty_diff     TYPE p DECIMALS 3,
         meins        TYPE meins,
         disposition  TYPE c LENGTH 4,
         lifnr        TYPE lifnr,
         budat        TYPE budat,
       END OF ty_gr_disc.

DATA: gt_gr_disc    TYPE STANDARD TABLE OF ty_gr_disc,
      go_dock       TYPE REF TO cl_gui_docking_container,
      go_alv        TYPE REF TO cl_gui_alv_grid,
      gt_fcat       TYPE lvc_t_fcat,
      gs_layout     TYPE lvc_s_layo,
      gv_sel_werks  TYPE werks_d,
      gv_sel_budat  TYPE budat,
      gv_sel_matnr  TYPE matnr.

CONSTANTS: gc_status_0100 TYPE c LENGTH 20 VALUE 'STATUS_0100',
           gc_fc_wms_send TYPE c LENGTH 20 VALUE 'WMS_SEND'.
