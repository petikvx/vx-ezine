DEBUG   EQU 1  ; ��� �⫠��� ��������.
NODEBUG EQU 0  ; � ⠪ ����㤭����
DEBUGFLAG EQU NODEBUG ;DEBUG
 IF DEBUGFLAG
    EXEPTION EQU dw 0ffffh,090c3h,9090h
    ELSE
    EXEPTION EQU db 0cch
 ENDIF
