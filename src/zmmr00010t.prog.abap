*&---------------------------------------------------------------------*
*& Include  : ZMMR00010T
*& Purpose  : TOP - Global Types, Data, Constants
*&---------------------------------------------------------------------*

" ---- Output structure ----
TYPES: BEGIN OF ty_output,
         banfn        TYPE banfn,
         bnfpo        TYPE bnfpo,
         matnr        TYPE matnr,
         menge        LIKE eban-menge,
         meins        TYPE meins,
         appr_seq     TYPE n LENGTH 4,
         appr_level   TYPE c LENGTH 20,
         appr_user    TYPE syuname,
         appr_role    TYPE c LENGTH 20,
         appr_status  TYPE c LENGTH 1,
         appr_date    TYPE dats,
         appr_comment TYPE c LENGTH 255,
         erdat        TYPE erdat,
       END OF ty_output.

TYPES: ty_t_output TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

" ---- Global work areas ----
DATA: gt_data      TYPE ty_t_output,
      gs_data      TYPE ty_output,
      go_dock      TYPE REF TO cl_gui_docking_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fcat      TYPE lvc_t_fcat,
      gs_layout    TYPE lvc_s_layo.
