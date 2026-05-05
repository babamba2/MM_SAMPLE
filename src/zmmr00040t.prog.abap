*&---------------------------------------------------------------------*
*& Include  : ZMMR00040T
*& Purpose  : TOP - Global Types, Data, Constants
*&---------------------------------------------------------------------*

" ---- Output structure ----
TYPES: BEGIN OF ty_output,
         banfn        TYPE banfn,
         bnfpo        TYPE bnfpo,
         urgency      TYPE c LENGTH 4,
         urgency_rsn  TYPE c LENGTH 30,
         exec_appr    TYPE syuname,
         appr_date    TYPE dats,
         matnr        TYPE matnr,
         menge        LIKE eban-menge,
         lifnr        TYPE lifnr,
         name1        TYPE name1,
       END OF ty_output.

TYPES: ty_t_output TYPE STANDARD TABLE OF ty_output WITH DEFAULT KEY.

" ---- Global work areas ----
DATA: gt_data      TYPE ty_t_output,
      gs_data      TYPE ty_output,
      go_dock      TYPE REF TO cl_gui_docking_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fcat      TYPE lvc_t_fcat,
      gs_layout    TYPE lvc_s_layo.
