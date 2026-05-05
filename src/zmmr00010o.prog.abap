*&---------------------------------------------------------------------*
*& Include  : ZMMR00010O
*& Purpose  : PBO Modules
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.
  IF go_grid IS INITIAL.
    PERFORM display_alv_0100.
  ENDIF.
ENDMODULE.
