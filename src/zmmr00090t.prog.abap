*&---------------------------------------------------------------------*
*& Include ZMMR00090T — TOP: Types / Data / Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_vendor,
         lifnr       TYPE lifnr,
         name1       TYPE name1_gp,
         land1       TYPE land1_gp,
         stcd1       TYPE stcd1,
         stcd2       TYPE stcd2,
         eval_status TYPE zmme00750,
         int_grade   TYPE zmme00760,
         zterm       TYPE dzterm,
         created_by  TYPE usnam,
         created_at  TYPE timestampl,
       END OF ty_vendor.

DATA: gt_vendor     TYPE STANDARD TABLE OF ty_vendor,
      go_dock       TYPE REF TO cl_gui_docking_container,
      go_alv        TYPE REF TO cl_gui_alv_grid,
      gt_fcat       TYPE lvc_t_fcat,
      gs_layout     TYPE lvc_s_layo,
      gv_sel_lifnr  TYPE lifnr,
      gv_sel_status TYPE zmme00750,
      " dialog input
      gv_dlg_lifnr  TYPE lifnr,
      gv_dlg_name1  TYPE name1_gp,
      gv_dlg_land1  TYPE land1_gp,
      gv_dlg_bukrs  TYPE bukrs.

CONSTANTS: gc_status_0100  TYPE c LENGTH 20 VALUE 'STATUS_0100',
           gc_fc_new_vnd   TYPE c LENGTH 20 VALUE 'NEW_VENDOR'.
