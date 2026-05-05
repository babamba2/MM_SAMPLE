*&---------------------------------------------------------------------*
*& Include  ZMMR00140T — 재고 노화 리포트 TOP
*&---------------------------------------------------------------------*

CONSTANTS: gc_status_0100  TYPE char20 VALUE 'STATUS_0100',
           gc_screen_0100  TYPE i      VALUE 100,
           gc_band_0_30    TYPE char10 VALUE '0-30',
           gc_band_31_90   TYPE char10 VALUE '31-90',
           gc_band_91_180  TYPE char10 VALUE '91-180',
           gc_band_181_365 TYPE char10 VALUE '181-365',
           gc_band_365p    TYPE char10 VALUE '365+'.

TYPES: BEGIN OF ty_alv_0100,
         matnr              TYPE matnr,
         maktx              TYPE maktx,
         werks              TYPE werks_d,
         lgort              TYPE lgort_d,
         snap_year          TYPE numc4,
         snap_month         TYPE numc2,
         abc_class          TYPE char1,
         aging_band         TYPE char10,
         stock_qty          TYPE p LENGTH 8 DECIMALS 3,
         stock_value        TYPE p LENGTH 8 DECIMALS 2,
         waers              TYPE waers,
         last_movement_date TYPE dats,
       END OF ty_alv_0100.

DATA: gt_alv_0100     TYPE STANDARD TABLE OF ty_alv_0100,
      gs_alv_0100     TYPE ty_alv_0100,
      gt_fieldcat     TYPE lvc_t_fcat,
      go_docking      TYPE REF TO cl_gui_docking_container,
      go_alv_grid     TYPE REF TO cl_gui_alv_grid,
      gv_total_value  TYPE p LENGTH 8 DECIMALS 2.
