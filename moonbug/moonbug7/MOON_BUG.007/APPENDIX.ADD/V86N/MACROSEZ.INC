;----------------------------------------------------------------------------
; CopyRight [C] 1997-1998 RAM Scanner // [CiD], VD. All Rights Reserved
;----------------------------------------------------------------------------
Version_           Equ '0.12 Alpha'
TRUE		   Equ 0ffh
FALSE		   Equ 0
INT_ENABLED        Equ 200h
INT_DISABLED       Equ 0
;----------------------------------------------------------------------------
; ���ᨬ���� ����� ��᥯襭�. �� ���� �������� ���-����� 䥭�, ⠪ ��
; ��� ���� ���� �� ������.
;----------------------------------------------------------------------------
MaxFaultNum        Equ 11h
;----------------------------------------------------------------------------
; ��᪮�������� ��� ࠡ��� � IOPL 0 ���� ࠡ�⠥� � IOPL 3.
; ������� � IOPL 0 �㤥� �ਢ� ��-�� ������⢨� ����樨 pushfd/popfd �
; ��㤭�㫮������ �� � int 1. �� iopl 3 ��ଠ�쭮.
;----------------------------------------------------------------------------
;$$IOPL0            Equ 0

;----------------------------------------------------------------------------
; ���㣮�� ����� Invalid OpCode. �࠯��� ��設�.
;----------------------------------------------------------------------------
_Break		   Equ Db 0fh,0ffh


;----------------------------------------------------------------------------
; �� ���� ���㣮��� 䥭�窠
;----------------------------------------------------------------------------
_Debug		   Macro Char
		   mov ax,Sel_Video
		   mov es,ax
		   mov br es:[0],Char
		   jmp $
		   Endm

;----------------------------------------------------------------------------
; ���㣮��� 䥭�
;----------------------------------------------------------------------------
_Debug32	   Macro Reg_
		   mov ax,Sel_Video
		   mov es,ax
		   mov eax,Reg_
		   mov ebx,eax
		   shr eax,16
		   mov es:[0],ah
		   mov es:[2],al
		   mov eax,ebx
		   mov es:[4],ah
		   mov es:[6],al
		   jmp $
		   Endm

;----------------------------------------------------------------------------
; ��᫥���� ���� PC. ������ IO-Map � TSS. �᫨ ���⠢��� 3ff, � �� PCI �㤥�
; ������ ��-�� ���饭�� � ���� ���⠬.
;----------------------------------------------------------------------------
Last_PC_Port       Equ 03ffh
;Last_PC_Port      Equ 0ffffh

;----------------------------------------------------------------------------
; ��䮫⭮� ���祭�� IOPL. �� �� ����� ��� 祣� �㦭�
;----------------------------------------------------------------------------
DefIOPL            Equ 3

;----------------------------------------------------------------------------
; ���ᠭ�� ⨯�� ᥫ���஢
;----------------------------------------------------------------------------
RDOnly		   Equ 10h
RD_WR		   Equ 12h
RD_WR_XD	   Equ 16h
EXOnly		   Equ 18h
EX_RD		   Equ 1ah
EXOnly_CF	   Equ 1ch
EX_RD_CF	   Equ 1eh

_IF		   Equ (1 Shl 9)
_TF		   Equ (1 Shl 8)

XTSS		   Equ 9
XTSS_Busy	   Equ 0bh
XCall_Gate	   Equ 0ch
XINT_Gate	   Equ 0eh
XTrap_Gate	   Equ 0fh

;----------------------------------------------------------------------------
; �� ��直� ������ ࠧ��
;----------------------------------------------------------------------------
GdLimit		   Macro Granularity,Default,HighLimit
		   Db (Granularity Shl 7) Or (Default Shl 6) Or	(HighLimit And 0fh)
		   Endm

PlType		   Macro Privilege,Type
		   Db 80h Or (Privilege	Shl 3) Or Type
		   Endm

;----------------------------------------------------------------------------
; ����� ���室� �� �ணࠬ����� �᪫�祭��. �⮡ ��ᠭ��� �����
;----------------------------------------------------------------------------
FaultJmp	   Macro Lbl,NPtr,Jump
Fault_&Lbl:
		   push	Dr NPtr
		   jmp Jump
		   Endm

;----------------------------------------------------------------------------
; �� �� ᠬ��, �� �� �����⭮�� ����
;----------------------------------------------------------------------------                   
HardwIntJmp	   Macro Lbl,NPtr,Jump
HWInt_&Lbl:
;		   push	dr NPtr
		   Db 66h,6ah
HWVectIrq_&Lbl	   Db NPtr
		   jmp Jump
		   Endm

;----------------------------------------------------------------------------
; ����ࠨ����� IDT/GDT
;----------------------------------------------------------------------------
Adjust_Table	   Macro SysTableName,DescriptorCount
		   mov si,ofs SysTableName
		   mov cx,DescriptorCount
		   call	Adjust
		   Endm


;----------------------------------------------------------------------------
; ��室���� � PM16. �� ���� � ���⠫��� � ��᫥��⢮
;----------------------------------------------------------------------------
Set_PM             Macro GDTTbl_Seg,GDTTBl_Name,IRQ0_Vect,IRQ8_Vect
		   mov ax,GDTTbl_Seg
		   mov es,ax
		   mov si,ofs GDTTbl_Name
		   mov bh,IRQ0_Vect
		   mov bl,IRQ8_Vect
		   mov ah,89h
		   int 15h
		   Endm

;----------------------------------------------------------------------------
; ������ઠ TSS
;----------------------------------------------------------------------------                   
XTaskSegment	   Struc
		   _Link	 Dw 0
				 Dw 0
		   ESP0		 Dd 0
		   SS0		 Dw 0
				 Dw 0
		   ESP1		 Dd 0
		   SS1		 Dw 0
				 Dw 0
		   ESP2		 Dd 0
		   SS2		 Dw 0
				 Dw 0
		   _CR3		 Dd 0
		   _EIP		 Dd 0
		   _EFlags	 Dd 0
		   _EAX		 Dd 0
		   _ECX		 Dd 0
		   _EDX		 Dd 0
		   _EBX		 Dd 0
		   _ESP		 Dd 0
		   _EBP		 Dd 0
		   _ESI		 Dd 0
		   _EDI		 Dd 0
		   _ES		 Dw 0
				 Dw 0
		   _CS		 Dw 0
				 Dw 0
		   _SS		 Dw 0
				 Dw 0
		   _DS		 Dw 0
				 Dw 0
		   _FS		 Dw 0
				 Dw 0
		   _GS		 Dw 0
				 Dw 0
		   _LDT		 Dw 0
				 Dw 0
		   _TrapF	 Dw 0
		   IOBase	 Dw 68h	  ; Offset Virtual_IO -	Offset _Link
		   Virtual_IO	 Db (Last_PC_Port/8+1) Dup (0)
				 Dd -1
		   Ends
