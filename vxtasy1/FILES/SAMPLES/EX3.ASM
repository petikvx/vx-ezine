EXTERN ExitProcess
EXTERN MessageBoxA

%define uType MB_ICONEXCLAMATION
%define hWnd 0

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
	stdcall MessageBoxA, HWND hWnd, LPCTSTR lpText, LPCTSTR lpCaption, UINT uType
	stdcall	ExitProcess, UINT 0
;------------------------------------------------------------------------------
SECTION DATA USE32 CLASS=DATA
lpCaption	db 'First NASM BOX',0
lpText		db 'Are you happy now ?',0
;------------------------------------------------------------------------------
