*&---------------------------------------------------------------------*
*& Include  ZMMR00120A — 스크랩 원가 분석 ALV Field Catalog
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
      WHEN 'MBLNR'.           <fs_fcat>-coltext = text-f01. <fs_fcat>-outputlen = 10.
      WHEN 'MJAHR'.           <fs_fcat>-coltext = text-f02. <fs_fcat>-outputlen = 4.
      WHEN 'ZEILE'.           <fs_fcat>-coltext = text-f03. <fs_fcat>-outputlen = 4.
      WHEN 'MATNR'.           <fs_fcat>-coltext = text-f04. <fs_fcat>-outputlen = 18.
      WHEN 'MAKTX'.           <fs_fcat>-coltext = text-f05. <fs_fcat>-outputlen = 30.
      WHEN 'WERKS'.           <fs_fcat>-coltext = text-f06. <fs_fcat>-outputlen = 4.
      WHEN 'SCRAP_QTY'.       <fs_fcat>-coltext = text-f07. <fs_fcat>-qfieldname = 'MEINS'. <fs_fcat>-do_sum = abap_true.
      WHEN 'MEINS'.           <fs_fcat>-coltext = text-f08. <fs_fcat>-no_out = abap_true.
      WHEN 'SCRAP_TYPE'.      <fs_fcat>-coltext = text-f09. <fs_fcat>-outputlen = 4.
      WHEN 'DEFECT_CATEGORY'. <fs_fcat>-coltext = text-f10. <fs_fcat>-outputlen = 4.
      WHEN 'DEPARTMENT'.      <fs_fcat>-coltext = text-f11. <fs_fcat>-outputlen = 10.
      WHEN 'LOSS_AMOUNT'.     <fs_fcat>-coltext = text-f12. <fs_fcat>-cfieldname = 'WAERS'. <fs_fcat>-do_sum = abap_true.
      WHEN 'WAERS'.           <fs_fcat>-coltext = text-f13. <fs_fcat>-no_out = abap_true.
      WHEN 'BUDAT'.           <fs_fcat>-coltext = text-f14. <fs_fcat>-outputlen = 10.
      WHEN 'USNAM'.           <fs_fcat>-coltext = text-f15. <fs_fcat>-outputlen = 12.
    ENDCASE.
  ENDLOOP.
ENDFORM.
