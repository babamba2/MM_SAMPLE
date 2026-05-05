*&---------------------------------------------------------------------*
*& Program  : ZMMR00150
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - Include structure reconstruction
*& Desc     : Cycle Count 차이 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00150.

INCLUDE zmmr00150t.  "TOP
INCLUDE zmmr00150s.  "SELECTION SCREEN
INCLUDE zmmr00150a.  "ALV
INCLUDE zmmr00150o.  "PBO
INCLUDE zmmr00150i.  "PAI
INCLUDE zmmr00150f.  "FORM

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
