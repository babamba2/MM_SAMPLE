*&---------------------------------------------------------------------*
*& Include  ZMMR00130T — 수입/통관 문서 추적 TOP
*&---------------------------------------------------------------------*

CONSTANTS: gc_status_0100 TYPE char20 VALUE 'STATUS_0100',
           gc_screen_0100 TYPE i      VALUE 100.

TYPES: BEGIN OF ty_alv_0100,
         ebeln            TYPE ebeln,
         track_seq        TYPE numc4,
         bl_no            TYPE char30,
         customs_decl_no  TYPE char30,
         carrier_code     TYPE char30,
         carrier_name     TYPE char35,
         duty_amount      TYPE p LENGTH 8 DECIMALS 2,
         waers            TYPE waers,
         lifnr            TYPE lifnr,
         name1            TYPE name1,
         import_date      TYPE dats,
         clearance_date   TYPE dats,
         days_to_clear    TYPE i,
       END OF ty_alv_0100.

DATA: gt_alv_0100      TYPE STANDARD TABLE OF ty_alv_0100,
      gs_alv_0100      TYPE ty_alv_0100,
      gt_fieldcat      TYPE lvc_t_fcat,
      go_docking       TYPE REF TO cl_gui_docking_container,
      go_alv_grid      TYPE REF TO cl_gui_alv_grid,
      gv_avg_days      TYPE p LENGTH 4 DECIMALS 1.
