*&---------------------------------------------------------------------*
*& Program  : ZMMR00020
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - E-include migration + header normalize
*& Desc     : PO 변경 이력 감사 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00020.

INCLUDE zmmr00020t.   "TOP
INCLUDE zmmr00020s.   "SELECTION SCREEN
INCLUDE zmmr00020a.   "ALV
INCLUDE zmmr00020o.   "PBO
INCLUDE zmmr00020i.   "PAI
INCLUDE zmmr00020f.   "FORM

START-OF-SELECTION.
  PERFORM fetch_data_0100.

END-OF-SELECTION.
  IF gt_data IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
