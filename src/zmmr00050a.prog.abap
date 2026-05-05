*&---------------------------------------------------------------------*
*& Include  : ZMMR00050A
*& Purpose  : ALV display FORMs
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
" convert_fcat_data_grid - SALV factory -> LVC_T_FCAT conversion
*----------------------------------------------------------------------
FORM convert_fcat_data_grid USING    pt_table   TYPE STANDARD TABLE
                             CHANGING pt_fieldcat TYPE lvc_t_fcat.
  DATA lo_table TYPE REF TO data.
  CREATE DATA lo_table LIKE pt_table.
  ASSIGN lo_table->* TO FIELD-SYMBOL(<fo_table>).
  TRY.
      cl_salv_table=>factory(
        IMPORTING r_salv_table = DATA(salv_table)
        CHANGING  t_table      = <fo_table> ).
      pt_fieldcat = cl_salv_controller_metadata=>get_lvc_fieldcatalog(
        r_columns      = salv_table->get_columns( )
        r_aggregations = salv_table->get_aggregations( ) ).
    CATCH cx_root.
  ENDTRY.
ENDFORM.

*----------------------------------------------------------------------
" build_fcat_0100 - per-field attributes via CASE FIELDNAME
*----------------------------------------------------------------------
FORM build_fcat_0100.
  DATA ls_fcat TYPE lvc_s_fcat.

  PERFORM convert_fcat_data_grid USING    gt_data
                                  CHANGING gt_fcat.

  LOOP AT gt_fcat INTO ls_fcat.
    CASE ls_fcat-fieldname.
      WHEN 'EBELN'.
        ls_fcat-coltext   = text-c01.
        ls_fcat-outputlen = 10.
      WHEN 'EBELP'.
        ls_fcat-coltext   = text-c02.
        ls_fcat-outputlen = 5.
      WHEN 'MATNR'.
        ls_fcat-coltext   = text-c03.
        ls_fcat-outputlen = 18.
      WHEN 'MAKTX'.
        ls_fcat-coltext   = text-c04.
        ls_fcat-outputlen = 30.
      WHEN 'STD_PRICE'.
        ls_fcat-coltext    = text-c05.
        ls_fcat-outputlen  = 15.
        ls_fcat-cfieldname = 'WAERS'.
      WHEN 'REQ_PRICE'.
        ls_fcat-coltext    = text-c06.
        ls_fcat-outputlen  = 15.
        ls_fcat-cfieldname = 'WAERS'.
      WHEN 'DEVIATION_PCT'.
        ls_fcat-coltext   = text-c07.
        ls_fcat-outputlen = 8.
      WHEN 'DEVIATION_AMT'.
        ls_fcat-coltext    = text-c08.
        ls_fcat-outputlen  = 15.
        ls_fcat-do_sum     = abap_true.
        ls_fcat-cfieldname = 'WAERS'.
      WHEN 'APPROVER'.
        ls_fcat-coltext   = text-c09.
        ls_fcat-outputlen = 12.
      WHEN 'APPR_DATE'.
        ls_fcat-coltext   = text-c10.
        ls_fcat-outputlen = 10.
      WHEN 'REASON'.
        ls_fcat-coltext   = text-c11.
        ls_fcat-outputlen = 20.
      WHEN 'WAERS'.
        ls_fcat-coltext   = text-c12.
        ls_fcat-outputlen = 5.
        ls_fcat-no_out    = abap_true.
    ENDCASE.
    MODIFY gt_fcat FROM ls_fcat.
  ENDLOOP.
ENDFORM.

*----------------------------------------------------------------------
" display_alv_0100 - Docking Container + ALV Grid
*----------------------------------------------------------------------
FORM display_alv_0100.
  PERFORM build_fcat_0100.

  CREATE OBJECT go_dock
    EXPORTING
      repid     = sy-repid
      dynnr     = sy-dynnr
      side      = cl_gui_docking_container=>dock_at_bottom
      extension = 5000.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_dock.

  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = 'A'.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
    CHANGING
      it_outtab       = gt_data
      it_fieldcatalog = gt_fcat.
ENDFORM.
