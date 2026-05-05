*&---------------------------------------------------------------------*
*& Include  : ZMMR00020T
*& Purpose  : TOP - Global Types, Data, Constants
*&---------------------------------------------------------------------*

" ---- Output structure ----
TYPES: BEGIN OF ty_output,
         ebeln      TYPE ebeln,
         ebelp      TYPE ebelp,
         seq_no     TYPE n LENGTH 4,
         ch_field   TYPE c LENGTH 30,
         ch_old     TYPE c LENGTH 50,
         ch_new     TYPE c LENGTH 50,
         ch_reason  TYPE c LENGTH 30,
         ch_user    TYPE syuname,
         ch_date    TYPE dats,
         ch_time    TYPE tims,
         lifnr      TYPE lifnr,
         name1      TYPE name1,
       END OF ty_output.

TYPES: ty_t_output TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

" ---- Global work areas ----
DATA: gt_data      TYPE ty_t_output,
      gs_data      TYPE ty_output,
      go_dock      TYPE REF TO cl_gui_docking_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fcat      TYPE lvc_t_fcat,
      gs_layout    TYPE lvc_s_layo.
