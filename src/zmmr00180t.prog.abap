*&---------------------------------------------------------------------*
*& Include ZMMR00180T — TOP: Types, Data, Constants
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_s_output,
         sel            TYPE char1,
         matnr          TYPE matnr,
         maktx          TYPE maktx,
         design_status  TYPE zmme00710,
         dsn_stat_txt   TYPE char20,
         revision       TYPE revlv,
         draw_url       TYPE zmme00720,
         plm_guid       TYPE zmme00730,
         last_sync_ts   TYPE timestampl,
         has_drawing    TYPE char1,
       END OF ty_s_output.

TYPES ty_t_output TYPE STANDARD TABLE OF ty_s_output WITH DEFAULT KEY.

DATA: gt_output    TYPE ty_t_output,
      go_container TYPE REF TO cl_gui_docking_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

* Domain ZMMD00710 fixed values: D=Draft, R=Released, O=Obsolete
CONSTANTS: gc_dsn_draft    TYPE zmme00710 VALUE 'D',
           gc_dsn_released TYPE zmme00710 VALUE 'R',
           gc_dsn_obsolete TYPE zmme00710 VALUE 'O'.

CONSTANTS: gc_status_0100  TYPE char14 VALUE 'STATUS_0100',
           gc_fcode_resend TYPE char20 VALUE 'PLM_RESEND',
           gc_has_draw_yes TYPE char1  VALUE 'Y',
           gc_has_draw_no  TYPE char1  VALUE 'N'.
