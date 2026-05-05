*&---------------------------------------------------------------------*
*& Program  : ZMMR00050
*& Author   : SV5_000030
*& Date     : 2026-04-19
*& S/4HANA  : 2025 Release
*& Version  : v1.1 - E-include migration + header normalize
*& Desc     : 가격예외 결재 리포트
*&---------------------------------------------------------------------*
REPORT zmmr00050.

INCLUDE zmmr00050t.   "TOP
INCLUDE zmmr00050s.   "SELECTION SCREEN
INCLUDE zmmr00050a.   "ALV
INCLUDE zmmr00050o.   "PBO
INCLUDE zmmr00050i.   "PAI
INCLUDE zmmr00050f.   "FORM

START-OF-SELECTION.
  PERFORM fetch_data_0100.

END-OF-SELECTION.
  PERFORM calc_footer_0100.
  IF gt_data IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE text-e01 TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
