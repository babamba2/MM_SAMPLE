*&---------------------------------------------------------------------*
*& Include ZMMR00080T — TOP: Types / Data / Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_srclist,
         matnr       TYPE matnr,
         maktx       TYPE maktx,
         werks       TYPE werks_d,
         lifnr       TYPE lifnr,
         name1       TYPE name1_gp,
         eval_seq    TYPE numc4,
         score       TYPE p DECIMALS 2,
         grade_new   TYPE c LENGTH 2,
         eval_date   TYPE dats,
         next_review TYPE dats,
         eord_vlfrom TYPE dats,
       END OF ty_srclist.

DATA: gt_srclist    TYPE STANDARD TABLE OF ty_srclist,
      go_dock       TYPE REF TO cl_gui_docking_container,
      go_alv        TYPE REF TO cl_gui_alv_grid,
      gt_fcat       TYPE lvc_t_fcat,
      gs_layout     TYPE lvc_s_layo,
      gv_sel_matnr  TYPE matnr,
      gv_sel_werks  TYPE werks_d,
      gv_sel_lifnr  TYPE lifnr.

CONSTANTS: gc_status_0100 TYPE c LENGTH 20 VALUE 'STATUS_0100'.
