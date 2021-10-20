
;Simple DialogBox that closes if you press the "x" button located on the caption

%define IDC_B1 500

EXTERN ExitProcess
EXTERN DialogBoxParamA
EXTERN EndDialog
EXTERN GetModuleHandleA

%macro stdcall 0-*          
%define _j %1
%rep %0-1
    %rotate -1
    push %1
%endrep
    call _j
%endmacro

;------------------------------------------------------------------------------
SECTION CODE USE32 CLASS=CODE
..start:
	stdcall GetModuleHandleA, UINT 0	;=> instance handle in EAX
        stdcall DialogBoxParamA, eax, UINT 100, UINT 0, LPFN DlgProc, UINT 0
	stdcall	ExitProcess, UINT 0

DlgProc:push eax
	push ebp
	mov ebp,esp
	mov eax,UINT [ss:ebp+16]	;In eax we have the message
	cmp eax,WM_COMMAND
	je ControlCommand
	cmp eax,WM_CLOSE
	jne Exit
GetOut:	mov eax,UINT [ss:ebp+12]	;Get handle
	stdcall EndDialog, eax, UINT 0
Exit:	pop ebp
	pop eax
	xor eax,eax			;Exit code (0 = OK)
	ret 16				;Clear the stack (4parameters * 4bytes)
ControlCommand:
	mov eax,UINT [ss:ebp+20]
	cmp eax,IDC_B1			;When our button is pressed we just exit
	je GetOut
	jmp short Exit
;------------------------------------------------------------------------------
SECTION DATA USE32 CLASS=DATA
;------------------------------------------------------------------------------
