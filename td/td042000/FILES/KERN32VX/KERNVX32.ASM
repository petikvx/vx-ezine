.386p
.model flat
include exeption.inc
.DATA
include dinav2.inc
db '(c) Voodoo//SMF 31.03.2000'
extrn   MessageBeep:PROC  ; ���쪮 ���� ��� ⮣� �⮡� �ண� ����᪠����.
                          ; ��� ���o�⮢ �ண� �� ����᪠��� � �32 �����.
;-----------------------------------------------------------------------------
MyCode:
; � ��।��� �ࠢ����� DINA v2.0
; ��� ࠡ�⠥� � �⥪�.
           call @MyCodeL1
@Hello:      db 'Hello from stack !!!',0
@MyCodeL1:   pop ebx
call GetKernelHahdlerA ; ����砥�  � EDI=KernelHahdler
                       ; ��� ���樠����樨 VX ��୥��
call Kern32VxInit      ; ���樠������ VX ��୥��
; ����稬  User32Hahdler
          call LpL
@UserName    db 'USER32.dll',0
LpL:         push zGetModuleHandleA ; �맮� GetModuleHandleA
             EXEPTION              ; � �⥪� offset �� USER32.DLL
             mov edi,eax
             add eax,[eax+3ch] ; eax=offset 2 PE
             mov esi,[eax+78h] ; esi=Export Table RVA 2 USER32.dll
             ;-------------
             xor eax,eax
             pop dword ptr  fs:[eax]
             pop eax
             ;-------------
            call Kern32VxInit ; ���樠������ VX ��୥�� �� ��� User32.dll
            push 0
            push ebx
            push ebx
            push 0
            push zMessageBoxA
            EXEPTION
             ;-------------
             xor eax,eax
             pop dword ptr  fs:[eax]
             pop eax
             ;-------------
             call GetKernelHahdlerA
             call Kern32VxInit   ; ���樠������ VX ��୥�� ��� KERNEL32.dll
             push 0             ; ��室 �� �ண�.
             push zExitProcess   ;
             EXEPTION           ;
include kern32vx.inc
;-----------------------------------------------------------------------------
EndMyCode:
.data?
buffer db 1024 dup(?)
.CODE
MyCodeSize equ offset EndMyCode- offset MyCode
KernVX32:
mov eax,MyCodeSize
call GetKernelHahdlerA ; ����砥�
                       ; � EDI=KernelHahdler
                       ; � ESI=Export Table RVA
                       ; ��� ���樠����樨 VX ��୥��
call Kern32VxInit      ; ���樠������ VX ��୥��
   ;--------------------
   ; ������ Randomaze
    push offset buffer
    push zGetSystemTime  ; �맮� GetSystemTime
    EXEPTION            ;
    mov RandSeed,eax
   ;-----------------
   ; �뤥�塞 ������ ��� �����樨 ����
    push MyCodeSize*10 ; K<=10
    push 0
    push zGlobalAlloc
    EXEPTION
    push eax
    push zGlobalLock
    EXEPTION
    ;-------------------
    mov edi,eax            ;edi=���饭�� �� ��� ����
    mov esi,offset MyCode  ;esi=��� ��� ����� �� "�������䨬"
    mov ecx,MyCodeSize     ;ecx=��� ࠧ���
    call MakePolyImg       ;�� ��室� eax=������ ᣥ���஢������ ����
    ;--------------------
    xor eax,eax  ; �����⠫�� VX ��୥�
    pop dword ptr fs:[eax] ;
    pop eax      ;
    jmp edi      ; �⤠�� �ࠢ����� ᣥ���஢������ ����.
                 ;
    push 0
    push zExitProcess
    EXEPTION
exit_:
Ends
End KernVX32

