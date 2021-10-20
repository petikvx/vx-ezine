EXTERN ExitProcess
EXTERN MessageBoxA

%define uType MB_ICONEXCLAMATION
%define hWnd 0

SECTION CODE USE32 CLASS=CODE
..start:
	push	UINT uType
	push	LPCTSTR lpCaption
	push	LPCTSTR lpText
	push	HWND hWnd
	call	MessageBoxA
	xor	eax,eax
	push	eax
	call	ExitProcess
	
SECTION DATA USE32 CLASS=DATA
lpCaption	db 'First NASM BOX',0
lpText		db 'Are you happy now ?',0

