*&---------------------------------------------------------------------*
*& Include  ZMMR00150T — Cycle Count 차이 리포트 TOP
*&---------------------------------------------------------------------*

CONSTANTS: gc_status_0100   TYPE char20 VALUE 'STATUS_0100',
           gc_screen_0100   TYPE i      VALUE 100,
           gc_fcode_recount TYPE char4  VALUE 'RCT',
           gc_adj_posted    TYPE char1  VALUE 'X'.

TYPES: BEGIN OF ty_alv_0100,
         count_doc        TYPE char10,
         matnr            TYPE matnr,
         maktx            TYPE maktx,
         werks            TYPE werks_d,
         lgort            TYPE lgort_d,
         system_qty       TYPE p LENGTH 8 DECIMALS 3,
         counted_qty      TYPE p LENGTH 8 DECIMALS 3,
         diff_qty         TYPE p LENGTH 8 DECIMALS 3,
         variance_pct     TYPE p LENGTH 4 DECIMALS 2,
         meins            TYPE meins,
         reason           TYPE char30,
         adjustment_posted TYPE char1,
         post_date        TYPE dats,
         usnam            TYPE syuname,
         sel_flag         TYPE char1,
       END OF ty_alv_0100.

DATA: gt_alv_0100       TYPE STANDARD TABLE OF ty_alv_0100,
      gs_alv_0100       TYPE ty_alv_0100,
      gt_fieldcat       TYPE lvc_t_fcat,
      go_docking        TYPE REF TO cl_gui_docking_container,
      go_alv_grid       TYPE REF TO cl_gui_alv_grid,
      gv_unposted_cnt   TYPE i.
