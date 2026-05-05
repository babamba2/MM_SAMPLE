*&---------------------------------------------------------------------*
*& Program  : ZMMR00110
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - Include structure reconstruction
*& Desc     : GI 반품 사유 분석
*&---------------------------------------------------------------------*
REPORT zmmr00110.

INCLUDE zmmr00110t.  "TOP
INCLUDE zmmr00110s.  "SELECTION SCREEN
INCLUDE zmmr00110a.  "ALV
INCLUDE zmmr00110o.  "PBO
INCLUDE zmmr00110i.  "PAI
INCLUDE zmmr00110f.  "FORM

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
