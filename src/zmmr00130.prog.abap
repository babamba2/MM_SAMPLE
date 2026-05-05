*&---------------------------------------------------------------------*
*& Program  : ZMMR00130
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - Include structure reconstruction
*& Desc     : 수입/통관 문서 추적
*&---------------------------------------------------------------------*
REPORT zmmr00130.

INCLUDE zmmr00130t.  "TOP
INCLUDE zmmr00130s.  "SELECTION SCREEN
INCLUDE zmmr00130a.  "ALV
INCLUDE zmmr00130o.  "PBO
INCLUDE zmmr00130i.  "PAI
INCLUDE zmmr00130f.  "FORM

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
