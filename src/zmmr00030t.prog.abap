*&---------------------------------------------------------------------*
*& Include  : ZMMR00030T
*& Purpose  : TOP - Global Types, Data, Constants
*&---------------------------------------------------------------------*

" ---- Output structure ----
TYPES: BEGIN OF ty_output,
         ebeln        TYPE ebeln,
         ebelp        TYPE ebelp,
         matnr        TYPE matnr,
         menge        LIKE ekpo-menge,
         meins        TYPE meins,
         confirm_seq  TYPE n LENGTH 4,
         orig_deldate TYPE dats,
         new_deldate  TYPE dats,
         delay_days   TYPE i,
         vendor_ack   TYPE c LENGTH 1,
         reason       TYPE c LENGTH 30,
         confirm_user TYPE syuname,
         confirm_date TYPE dats,
       END OF ty_output.

TYPES: ty_t_output TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

" ---- Global work areas ----
DATA: gt_data      TYPE ty_t_output,
      gs_data      TYPE ty_output,
      go_dock      TYPE REF TO cl_gui_docking_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fcat      TYPE lvc_t_fcat,
      gs_layout    TYPE lvc_s_layo,
      gv_delay_cnt TYPE i,
      gv_delay_avg TYPE p DECIMALS 2.
