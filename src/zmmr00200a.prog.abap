*&---------------------------------------------------------------------*
*& Include ZMMR00200A — ALV field catalog and layout
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
      WHEN 'INFNR'.
        <fs_fc>-coltext   = text-f01.
        <fs_fc>-outputlen = 10.
      WHEN 'MATNR'.
        <fs_fc>-coltext   = text-f02.
        <fs_fc>-outputlen = 18.
      WHEN 'MAKTX'.
        <fs_fc>-coltext   = text-f03.
        <fs_fc>-outputlen = 30.
      WHEN 'LIFNR'.
        <fs_fc>-coltext   = text-f04.
        <fs_fc>-outputlen = 10.
      WHEN 'NAME1'.
        <fs_fc>-coltext   = text-f05.
        <fs_fc>-outputlen = 30.
      WHEN 'EKORG'.
        <fs_fc>-coltext   = text-f06.
        <fs_fc>-outputlen = 6.
      WHEN 'CHANGE_SEQ'.
        <fs_fc>-coltext   = text-f07.
        <fs_fc>-outputlen = 6.
      WHEN 'CH_FIELD'.
        <fs_fc>-coltext   = text-f08.
        <fs_fc>-outputlen = 20.
      WHEN 'CH_OLD_VAL'.
        <fs_fc>-coltext   = text-f09.
        <fs_fc>-outputlen = 25.
      WHEN 'CH_NEW_VAL'.
        <fs_fc>-coltext   = text-f10.
        <fs_fc>-outputlen = 25.
      WHEN 'REASON'.
        <fs_fc>-coltext   = text-f11.
        <fs_fc>-outputlen = 20.
      WHEN 'APPROVER'.
        <fs_fc>-coltext   = text-f12.
        <fs_fc>-outputlen = 12.
      WHEN 'APPR_DATE'.
        <fs_fc>-coltext   = text-f13.
        <fs_fc>-outputlen = 10.
      WHEN 'USNAM'.
        <fs_fc>-coltext   = text-f14.
        <fs_fc>-outputlen = 12.
    ENDCASE.
  ENDLOOP.
ENDFORM.

FORM build_layout_0100 CHANGING ps_layout TYPE lvc_s_layo.
  ps_layout-zebra      = abap_true.
  ps_layout-cwidth_opt = abap_true.
ENDFORM.
