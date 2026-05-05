*&---------------------------------------------------------------------*
*& Include  ZMMR00110T — GI 반품 사유 분석 TOP
*&---------------------------------------------------------------------*

CONSTANTS: gc_status_0100  TYPE char20 VALUE 'STATUS_0100',
           gc_screen_0100  TYPE i      VALUE 100,
           gc_vendor_fault TYPE char1  VALUE 'X'.

TYPES: BEGIN OF ty_alv_0100,
         mblnr        TYPE mblnr,
         mjahr        TYPE mjahr,
         zeile        TYPE numc4,
         matnr        TYPE matnr,
         maktx        TYPE maktx,
         werks        TYPE werks_d,
         lgort        TYPE lgort_d,
         lifnr        TYPE lifnr,
         return_qty   TYPE p LENGTH 8 DECIMALS 3,
         meins        TYPE meins,
         reason_code  TYPE char4,
         vendor_fault TYPE char1,
         claim_amount TYPE p LENGTH 8 DECIMALS 2,
         waers        TYPE waers,
         return_date  TYPE budat,
       END OF ty_alv_0100.

DATA: gt_alv_0100         TYPE STANDARD TABLE OF ty_alv_0100,
      gs_alv_0100         TYPE ty_alv_0100,
      gt_fieldcat         TYPE lvc_t_fcat,
      go_docking          TYPE REF TO cl_gui_docking_container,
      go_alv_grid         TYPE REF TO cl_gui_alv_grid,
      gv_vendor_fault_cnt TYPE i,
      gv_total_claim      TYPE p LENGTH 8 DECIMALS 2.
