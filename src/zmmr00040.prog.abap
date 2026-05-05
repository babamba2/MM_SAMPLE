*&---------------------------------------------------------------------*
*& Program  : ZMMR00040
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - E-include migration + header normalize
*& Desc     : 긴급/예외 PR 감사 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00040.

INCLUDE zmmr00040t.   "TOP
INCLUDE zmmr00040s.   "SELECTION SCREEN
INCLUDE zmmr00040a.   "ALV
INCLUDE zmmr00040o.   "PBO
INCLUDE zmmr00040i.   "PAI
INCLUDE zmmr00040f.   "FORM

START-OF-SELECTION.
  PERFORM fetch_data_0100.

END-OF-SELECTION.
  IF gt_data IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
