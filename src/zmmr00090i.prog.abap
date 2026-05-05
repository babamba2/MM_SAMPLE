*&---------------------------------------------------------------------*
*& Include ZMMR00090I — PAI Modules
*&---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.
  PERFORM f_user_command_0100.
ENDMODULE.

MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN 'OK_0200'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL' OR 'BACK'.
      CLEAR: gv_dlg_name1, gv_dlg_land1, gv_dlg_bukrs.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
