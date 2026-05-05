*&---------------------------------------------------------------------*
*& Include ZMMR00180A — ALV field catalog and layout
*&---------------------------------------------------------------------*

FORM convert_fcat_data_grid USING    pt_table    TYPE STANDARD TABLE
                             CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA lo_table TYPE REF TO data.
  CREATE DATA lo_table LIKE pt_table.
  ASSIGN lo_table->* TO FIELD-SYMBOL(<fo_table>).
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(lo_salv)
        CHANGING  t_table      = <fo_table> ).
      pt_fieldcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
        r_columns      = lo_salv->get_columns( )
        r_aggregations = lo_salv->get_aggregations( ) ).
    CATCH cx_root.
  ENDTRY.
ENDFORM.

FORM modify_fcat_data_grid1_0100 CHANGING pt_fieldcat TYPE lvc_t_fcat.
  FIELD-SYMBOLS <fs_fc> TYPE lvc_s_fcat.
  LOOP AT pt_fieldcat ASSIGNING <fs_fc>.
    CASE <fs_fc>-fieldname.
      WHEN 'SEL'.
        <fs_fc>-coltext   = text-f01.
        <fs_fc>-checkbox  = abap_true.
        <fs_fc>-edit      = abap_true.
        <fs_fc>-outputlen = 4.
      WHEN 'MATNR'.
        <fs_fc>-coltext   = text-f02.
        <fs_fc>-outputlen = 18.
      WHEN 'MAKTX'.
        <fs_fc>-coltext   = text-f03.
        <fs_fc>-outputlen = 30.
      WHEN 'DESIGN_STATUS'.
        <fs_fc>-no_out    = abap_true.
      WHEN 'DSN_STAT_TXT'.
        <fs_fc>-coltext   = text-f04.
        <fs_fc>-outputlen = 15.
      WHEN 'REVISION'.
        <fs_fc>-coltext   = text-f05.
        <fs_fc>-outputlen = 6.
      WHEN 'DRAW_URL'.
        <fs_fc>-coltext   = text-f06.
        <fs_fc>-outputlen = 40.
      WHEN 'PLM_GUID'.
        <fs_fc>-coltext   = text-f07.
        <fs_fc>-outputlen = 36.
      WHEN 'LAST_SYNC_TS'.
        <fs_fc>-coltext   = text-f08.
        <fs_fc>-outputlen = 20.
      WHEN 'HAS_DRAWING'.
        <fs_fc>-coltext   = text-f09.
        <fs_fc>-checkbox  = abap_true.
        <fs_fc>-outputlen = 6.
    ENDCASE.
  ENDLOOP.
ENDFORM.

FORM build_layout_0100 CHANGING ps_layout TYPE lvc_s_layo.
  ps_layout-zebra      = abap_true.
  ps_layout-cwidth_opt = abap_true.
  ps_layout-box_fname  = 'SEL'.
ENDFORM.
