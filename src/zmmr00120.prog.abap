*&---------------------------------------------------------------------*
*& Program  : ZMMR00120
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - Include structure reconstruction
*& Desc     : 스크랩 원가 분석
*&---------------------------------------------------------------------*
REPORT zmmr00120.

INCLUDE zmmr00120t.  "TOP
INCLUDE zmmr00120s.  "SELECTION SCREEN
INCLUDE zmmr00120a.  "ALV
INCLUDE zmmr00120o.  "PBO
INCLUDE zmmr00120i.  "PAI
INCLUDE zmmr00120f.  "FORM

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
