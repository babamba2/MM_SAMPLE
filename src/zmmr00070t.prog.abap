*&---------------------------------------------------------------------*
*& Include ZMMR00070T — TOP: Types / Data / Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_eval,
         lifnr      TYPE lifnr,
         name1      TYPE name1_gp,
         eval_id    TYPE numc10,
         eval_type  TYPE c LENGTH 4,
         eval_score TYPE p DECIMALS 2,
         eval_grade TYPE c LENGTH 2,
         prev_grade TYPE c LENGTH 2,
         remark     TYPE c LENGTH 255,
         action_required TYPE c LENGTH 1,
         evaluator  TYPE syuname,
         created_at TYPE timestampl,
       END OF ty_eval.

DATA: gt_eval       TYPE STANDARD TABLE OF ty_eval,
      go_dock       TYPE REF TO cl_gui_docking_container,
      go_alv        TYPE REF TO cl_gui_alv_grid,
      gt_fcat       TYPE lvc_t_fcat,
      gs_layout     TYPE lvc_s_layo,
      gv_sel_lifnr  TYPE lifnr,
      gv_sel_date   TYPE dats.

CONSTANTS: gc_status_0100 TYPE c LENGTH 20 VALUE 'STATUS_0100'.
