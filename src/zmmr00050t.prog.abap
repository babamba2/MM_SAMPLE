*&---------------------------------------------------------------------*
*& Include  : ZMMR00050T
*& Purpose  : TOP - Global Types, Data, Constants
*&---------------------------------------------------------------------*

" ---- Output structure ----
TYPES: BEGIN OF ty_output,
         ebeln         TYPE ebeln,
         ebelp         TYPE ebelp,
         matnr         TYPE matnr,
         maktx         TYPE maktx,
         std_price     TYPE p DECIMALS 2,
         req_price     TYPE p DECIMALS 2,
         deviation_pct TYPE p DECIMALS 2,
         deviation_amt TYPE p DECIMALS 2,
         approver      TYPE syuname,
         appr_date     TYPE dats,
         reason        TYPE c LENGTH 30,
         waers         TYPE waers,
       END OF ty_output.

TYPES: ty_t_output TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

" ---- Global work areas ----
DATA: gt_data      TYPE ty_t_output,
      gs_data      TYPE ty_output,
      go_dock      TYPE REF TO cl_gui_docking_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fcat      TYPE lvc_t_fcat,
      gs_layout    TYPE lvc_s_layo,
      gv_total_dev TYPE p DECIMALS 2.
