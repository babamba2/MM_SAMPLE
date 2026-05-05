*&---------------------------------------------------------------------*
*& Include  ZMMR00150A — Cycle Count 차이 리포트 ALV Field Catalog
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
      WHEN 'COUNT_DOC'.         <fs_fcat>-coltext = text-f01. <fs_fcat>-outputlen = 10.
      WHEN 'MATNR'.             <fs_fcat>-coltext = text-f02. <fs_fcat>-outputlen = 18.
      WHEN 'MAKTX'.             <fs_fcat>-coltext = text-f03. <fs_fcat>-outputlen = 30.
      WHEN 'WERKS'.             <fs_fcat>-coltext = text-f04. <fs_fcat>-outputlen = 4.
      WHEN 'LGORT'.             <fs_fcat>-coltext = text-f05. <fs_fcat>-outputlen = 4.
      WHEN 'SYSTEM_QTY'.        <fs_fcat>-coltext = text-f06. <fs_fcat>-qfieldname = 'MEINS'.
      WHEN 'COUNTED_QTY'.       <fs_fcat>-coltext = text-f07. <fs_fcat>-qfieldname = 'MEINS'.
      WHEN 'DIFF_QTY'.          <fs_fcat>-coltext = text-f08. <fs_fcat>-qfieldname = 'MEINS'.
      WHEN 'VARIANCE_PCT'.      <fs_fcat>-coltext = text-f09. <fs_fcat>-outputlen = 8.
      WHEN 'MEINS'.             <fs_fcat>-coltext = text-f10. <fs_fcat>-no_out = abap_true.
      WHEN 'REASON'.            <fs_fcat>-coltext = text-f11. <fs_fcat>-outputlen = 30.
      WHEN 'ADJUSTMENT_POSTED'. <fs_fcat>-coltext = text-f12. <fs_fcat>-outputlen = 1.
      WHEN 'POST_DATE'.         <fs_fcat>-coltext = text-f13. <fs_fcat>-outputlen = 10.
      WHEN 'USNAM'.             <fs_fcat>-coltext = text-f14. <fs_fcat>-outputlen = 12.
      WHEN 'SEL_FLAG'.          <fs_fcat>-coltext = text-f15. <fs_fcat>-no_out = abap_true.
    ENDCASE.
  ENDLOOP.
ENDFORM.
