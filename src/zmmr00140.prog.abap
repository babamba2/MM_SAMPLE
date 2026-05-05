*&---------------------------------------------------------------------*
*& Program  : ZMMR00140
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - Include structure reconstruction
*& Desc     : 재고 노화 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00140.

INCLUDE zmmr00140t.  "TOP
INCLUDE zmmr00140s.  "SELECTION SCREEN
INCLUDE zmmr00140a.  "ALV
INCLUDE zmmr00140o.  "PBO
INCLUDE zmmr00140i.  "PAI
INCLUDE zmmr00140f.  "FORM

*&---------------------------------------------------------------------*
*& INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  PERFORM init_0100.

*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM validate_screen_0100.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data_0100.

*&---------------------------------------------------------------------*
*& END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM display_alv_0100.
