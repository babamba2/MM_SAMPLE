*&---------------------------------------------------------------------*
*& Program  : ZMMR00010
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - E-include migration + header normalize
*& Desc     : PR 다단계 결재 현황 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00010.

INCLUDE zmmr00010t.   "TOP
INCLUDE zmmr00010s.   "SELECTION SCREEN
INCLUDE zmmr00010a.   "ALV
INCLUDE zmmr00010o.   "PBO
INCLUDE zmmr00010i.   "PAI
INCLUDE zmmr00010f.   "FORM

START-OF-SELECTION.
  PERFORM fetch_data_0100.

END-OF-SELECTION.
  IF gt_data IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
