*&---------------------------------------------------------------------*
*& Program  : ZMMR00030
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - E-include migration + header normalize
*& Desc     : PO 납기 재확인 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00030.

INCLUDE zmmr00030t.   "TOP
INCLUDE zmmr00030s.   "SELECTION SCREEN
INCLUDE zmmr00030a.   "ALV
INCLUDE zmmr00030o.   "PBO
INCLUDE zmmr00030i.   "PAI
INCLUDE zmmr00030f.   "FORM

START-OF-SELECTION.
  PERFORM fetch_data_0100.

END-OF-SELECTION.
  PERFORM calc_footer_0100.
  IF gt_data IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
