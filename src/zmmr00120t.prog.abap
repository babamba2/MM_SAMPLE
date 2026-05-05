*&---------------------------------------------------------------------*
*& Include  ZMMR00120T — 스크랩 원가 분석 TOP
*&---------------------------------------------------------------------*

CONSTANTS: gc_status_0100 TYPE char20 VALUE 'STATUS_0100',
           gc_screen_0100 TYPE i      VALUE 100.

TYPES: BEGIN OF ty_alv_0100,
         mblnr           TYPE mblnr,
         mjahr           TYPE mjahr,
         zeile           TYPE numc4,
         matnr           TYPE matnr,
         maktx           TYPE maktx,
         werks           TYPE werks_d,
         scrap_qty       TYPE p LENGTH 8 DECIMALS 3,
         meins           TYPE meins,
         scrap_type      TYPE char4,
         defect_category TYPE char4,
         department      TYPE char10,
         loss_amount     TYPE p LENGTH 8 DECIMALS 2,
         waers           TYPE waers,
         budat           TYPE budat,
         usnam           TYPE syuname,
       END OF ty_alv_0100.

DATA: gt_alv_0100    TYPE STANDARD TABLE OF ty_alv_0100,
      gs_alv_0100    TYPE ty_alv_0100,
      gt_fieldcat    TYPE lvc_t_fcat,
      go_docking     TYPE REF TO cl_gui_docking_container,
      go_alv_grid    TYPE REF TO cl_gui_alv_grid,
      gv_total_loss  TYPE p LENGTH 8 DECIMALS 2.
