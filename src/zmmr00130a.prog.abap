*&---------------------------------------------------------------------*
*& Include  ZMMR00130A — 수입/통관 문서 추적 ALV Field Catalog
*&---------------------------------------------------------------------*

FORM convert_fcat_data_grid USING    pt_table TYPE STANDARD TABLE
                             CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA lo_table TYPE REF TO data.
  CREATE DATA lo_table LIKE pt_table.
  ASSIGN lo_table->* TO FIELD-SYMBOL(<fo_table>).
  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = DATA(salv_table)
                              CHANGING  t_table      = <fo_table> ).
      pt_fieldcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
        r_columns      = salv_table->get_columns( )
        r_aggregations = salv_table->get_aggregations( ) ).
    CATCH cx_root.
  ENDTRY.
ENDFORM.

FORM modify_fcat_data_grid1_0100 CHANGING pt_fieldcat TYPE lvc_t_fcat.
  FIELD-SYMBOLS <fs_fcat> TYPE lvc_s_fcat.
  LOOP AT pt_fieldcat ASSIGNING <fs_fcat>.
    CASE <fs_fcat>-fieldname.
      WHEN 'EBELN'.           <fs_fcat>-coltext = text-f01. <fs_fcat>-outputlen = 10.
      WHEN 'TRACK_SEQ'.       <fs_fcat>-coltext = text-f02. <fs_fcat>-outputlen = 4.
      WHEN 'BL_NO'.           <fs_fcat>-coltext = text-f03. <fs_fcat>-outputlen = 30.
      WHEN 'CUSTOMS_DECL_NO'. <fs_fcat>-coltext = text-f04. <fs_fcat>-outputlen = 30.
      WHEN 'CARRIER_CODE'.    <fs_fcat>-coltext = text-f05. <fs_fcat>-outputlen = 10.
      WHEN 'CARRIER_NAME'.    <fs_fcat>-coltext = text-f06. <fs_fcat>-outputlen = 30.
      WHEN 'DUTY_AMOUNT'.     <fs_fcat>-coltext = text-f07. <fs_fcat>-cfieldname = 'WAERS'. <fs_fcat>-do_sum = abap_true.
      WHEN 'WAERS'.           <fs_fcat>-coltext = text-f08. <fs_fcat>-no_out = abap_true.
      WHEN 'LIFNR'.           <fs_fcat>-coltext = text-f09. <fs_fcat>-outputlen = 10.
      WHEN 'NAME1'.           <fs_fcat>-coltext = text-f10. <fs_fcat>-outputlen = 30.
      WHEN 'IMPORT_DATE'.     <fs_fcat>-coltext = text-f11. <fs_fcat>-outputlen = 10.
      WHEN 'CLEARANCE_DATE'.  <fs_fcat>-coltext = text-f12. <fs_fcat>-outputlen = 10.
      WHEN 'DAYS_TO_CLEAR'.   <fs_fcat>-coltext = text-f13. <fs_fcat>-outputlen = 5.
    ENDCASE.
  ENDLOOP.
ENDFORM.
