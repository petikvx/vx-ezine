; ������� � ������� ������ ��� Win9x 
; �����: IDT (Interrupt Descriptor Table, ������� ������������ ����������)

.586p
.model flat

callW           macro   x
                extern  x:PROC
                call    x
                endm

.data

_Start:
go_to_ring0:    pusha

                call    __pop1          ; SEH
                mov     esp, [esp+8]
                jmp     __exit
__pop1:         push    dword ptr fs:[0]
                mov     fs:[0], esp

                push    EDI             ; �������� ����� IDT
                sidt    [esp-2]
                pop     EDI

                add     EDI, 8*00h      ; ����� ����������� INT 00h

                fild    qword ptr [EDI] ; ��������� ����������

                call    __pop2          ; �������� ����� ������
                                        ; ����������� ����������

                call    ring0_proc      ; ������� � ring0

                dec     EAX             ; ��� ���������� ������� DIV-�
                iret                    ; ������� �� ���������� � ring-3

__pop2:         pop     word ptr [EDI]  ; ���������� ����� ������
                pop     word ptr [EDI+6]; ����������� ����������

                xor     EAX, EAX
                xor     EDX, EDX
                div     EAX             ; ������� INT 00h

                fistp   qword ptr [EDI] ; ������������ ����������

__exit:         pop     dword ptr fs:[0]; SEH
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