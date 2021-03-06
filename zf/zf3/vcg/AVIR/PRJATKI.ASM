;*********************************************************
;* �ணࠬ��� ��� ���᪠ ���㬮�䨪��                    *
;* (c) DrMad, 1997                                       *
;* ������ ������஢���                                 *
;* (c) DrMad, 1 ��५� 1999                              *
;*********************************************************
.286
Cseg	segment
	assume	cs:Cseg, ds:Cseg, ss:Cseg
	org	100h
Start:
	mov	ah, 9
	mov	dx, offset Mess1
	int	21h	
; ������ ��������� ��ப�
	cmp	byte ptr ds:[80h], 0
	jz	ReqFil
; ��ࠬ��� ����
	mov	si, 82h
@3:
	mov	di, offset NamBuf
@1:	
	lodsb
	cmp	al, 0Dh ; �����?
	jz 	EndScan
	stosb
	jmp	short @1
EndScan:
	sub	al, al
	stosb		; ��堥� 0	
	jmp	short @2
; ��ࠬ��� ���, ������ ��ப�
ReqFil:	
	mov	ah, 9
	mov	dx, offset Req
	int	21h
	mov	ah, 0Ah
	mov	dx, offset MaxLen
	int	21h
;	mov	al, 13
;	int	29h
;	mov	al, 10
;	int	29h
	mov	si, offset NamBuf
	jmp	short @3
@2:
	lea	dx, NamBuf
	call	Detect
	push	cs
	pop	ds
; ��� "������ ������" ��頥��� � ����				
	mov	ah, 9
	mov	dx, offset Mess2
	int	21h
; �뫥���� � ��⥬�		
	mov	ah, 4Ch
	int	21h
;*********************************************************
;*      ds:dx 㪠�뢠�� �� ��� �ண�                     *
;*********************************************************
Detect:
	push	cs
	pop	ds
	push	cs
	pop	es
; ���࠭��� ����� 1
	mov	ax, 3501h
	int	21h
	mov	Seg1, es
	mov	Ofs1, bx
; ��⠭����� ᢮� ��ࠡ��稪 Int 1
	push	dx
	mov	ax, 2501h
	mov	dx, offset Int1
	int	21h
	pop	dx
; ���࠭��� �⥪
	mov	OldSP, sp
	mov	OldSS, ss
; ����⠭����� ES
	push	cs
	pop	es
; �᫮������ ������
	mov	ah,4Ah
	mov	bx,1001h
	int	21h
	jnc	MemOK
	jmp	MemErr
MemOK:	
; ������ ���稪 ������
	mov	Count, 0
; ������ 䫠� ����砭�� ����஢��
	mov	StFlag, 0	
; ��⠭����� ��ࠬ����
	lea	bx,BParam
	mov	SegCMS,cs
	mov	SegBP1,cs
	mov	SegBP2,cs
; ����㧨�� �ணࠬ��
        mov     ax,4B01h
	int	21h
	jc	RunErr
; ��।����� ����஦����� PSP
	mov	ah,62h
	int	21h
	jc	PSPErr
; ��ନ஢��� ��� ��室� ����஦������ �ண�
;       lea     ax,Next
;	mov	ds,bx
;	mov	ds:word ptr [0Ah],ax
;	mov	ds:word ptr [0Ch],cs
	mov	bx,Offset BParam
; ��⠭����� ���� �⥪
	cli
	mov	ss,es:[bx+10h]
	mov	sp,es:[bx+0Eh]
	sti
; ��ନ஢��� � �⥪� 䫠�� � ��⮬ T=1
	push	303h
; ��ନ஢��� � �⥪� ��� �室�
	push	es:[bx+14h]
	push	es:[bx+12h]
; ��⠭����� ES �� ���� PSP ( ��� ��� )
	mov	ax,ds
	mov	es,ax
; ������ ॣ����� (�� �� ᮢᥬ ���४⭮)
	sub	ax,ax
	sub	bx,bx
	sub	cx,cx
	sub	dx,dx
	sub	si,si
	sub	di,di
	sub	bp,bp
; ��३� �� ����� �ணࠬ��
        iret
; ��뭥 ����饭��� �ணࠬ�� ࠡ�⠥�
; � ��蠣���� ०���
Next:
; ����⠭����� ᥣ����� ॣ�����
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
; ����⠭����� �⥪
	cli
	mov	ss,ax
	mov	sp, OldSP
	sti
; �������騥 ᮮ�饭��
Compl:
; ������⢮ ������஢����� ������
	mov	al, 13
	int	29h
	mov	al, 10
	int	29h
	mov	al, '('
	int	29h
	mov	ax, Count
	call	PriNum
	mov	al, ')'
	int	29h
; �� � ����� �� १����?
	cmp	cs:InFlag, 1
	jz	ItIs
ItsNot:	
	lea	dx, BAD
	jmp	Ex
ItIs:
	lea	dx, OK
	jmp	Ex	
MemErr:
	lea	dx, ME
	jmp	Ex
RunErr:
	lea	dx, RU
	jmp	Ex
PSPErr:
	lea	dx, PP
Ex:
; �뢥�� ᮮ�饭��
        mov     ah,9
	int	21h
; ����⠭����� ����� 1
	mov	ax, 2501h
	mov	dx, Ofs1
	mov	ds, Seg1
	int	21h
; ����������
	ret
;******************************************************
;* �� ��ࠡ��稪 ����஢�筮�� ���뢠���          *
;* � �⥪�: 1) �����                                  *
;*          2) CS ��।��� �������                   *
;*          3) IP ��।��� �������                   *  
;******************************************************
Int1:
; � �� ��� �� ����������?
	cmp	cs:StFlag, 1
 	jnz	ConTr
        jmp	Tr	
ConTr:	
; ���६����㥬 ���稪
	inc	cs:Count
; �� ᫨誮� �� ����� ������ ������஢���?
	cmp	cs:Count, 0FFFEh
	jb	OkCount
	jmp	StopTrace
OkCount:		
; ���࠭塞 �� ॣ�����
	mov	cs:word ptr RAX,AX
	mov	cs:word ptr RBX,BX
	mov	cs:word ptr RCX,CX
	mov	cs:word ptr RDX,DX
	mov	cs:word ptr RSI,SI
	mov	cs:word ptr RDI,DI
	mov	cs:word ptr RBP,BP
	mov	cs:word ptr RDS,DS
	mov	cs:word ptr RES,ES
	pushf
	pop	cs:word ptr FLAGS
; ���㥬 �� �⥪� ���� ��।��� �������
	pop	bx ; IP
	pop	es ; CS
; �� ������ ��⠢����� � �⥪� ��-��஬�
	push	es
	push	bx
; �஢��塞 �� ������� ��������� CS
	push	ax
	mov	ax, word ptr es:[bx]
	cmp	al, 0CDh ; int XX
	jz	StopTrace
	cmp	al, 0CCh ; int 3
	jz	StopTrace
	cmp	al, 0CFh ; iret
	jz	StopTrace
	cmp	al, 0CBh ; retf
	jz	StopTrace
	cmp	al, 0EAh ; jmp xxxx:xxxx
	jz	StopTrace
	cmp	al, 09Ah ; call xxxx:xxxx
	jz	StopTrace
	cmp	ax, 2EFFh ; jmp dptr xxxx
	jz	StopTrace
	cmp	ax, 1EFFh ; call dptr xxxx
	jz	StopTrace
	pop	ax
; ����⠭�������� �� ॣ�����	
	mov	AX, cs:word ptr RAX
	mov	BX, cs:word ptr RBX
	mov	CX, cs:word ptr RCX
	mov	DX, cs:word ptr RDX
	mov	SI, cs:word ptr RSI
	mov	DI, cs:word ptr RDI
	mov     BP, cs:word ptr RBP
	mov	DS, cs:word ptr RDS
	mov	ES, cs:word ptr RES
	push	cs:word ptr FLAGS
	popf
Tr:	
; � �த������ ����஢��	
	iret	
; ����⨫��� ������� ��������� cs. ��⠥�,
; �� ��誠 㦥 ����஢��� � ����� �஢�����
; �� ᨣ������.
StopTrace:
	pop	ax
	cmp	ah, 9
	jnz	GoodFil
; � ��� ⠪�� �㡮��� �ࠢ����� �� ���ॢ� ᨣ�,
; ����� scasb �뫮 ����
	mov	si, dx
	cmp	ds:word ptr [si], 'iV'
	jnz	GoodFil
	cmp	ds:word ptr [si+2], 'ur'
	jnz	GoodFil
	cmp	ds:word ptr [si+4], 'Cs'
	jnz	GoodFil	
BadFil:	
	mov	cs:InFlag, 1
	jmp	short GOut
GoodFil:
	mov	cs:InFlag, 0
; ��堥� stop �� ����� ᫥���饩 �������
GOut:
	pop	bx
	pop	es
	push	es
	push	bx
	mov	es:[bx], 4CB4h
	mov	es:[bx+2], 21CDh
	mov	cs:StFlag, 1
;	jmp	Tr
	jmp	Next
;***********************************************
;* ����⨭�� ���� �᫠ � ax               * 
;***********************************************
PriNum:
	pusha
	sub	cx, cx
LpD:
	sub	dx, dx
	mov	bx, 10
	div	bx
	push	dx
	inc	cx
	or	ax, ax
        jz      FinDiv
	jmp	LpD
FinDiv:
	pop	ax
	add	al,'0'
	int	29h
	loop	FinDiv
	popa
	retn
;************************************************
;* ���� ������                                  *
;************************************************
; ���稪 ������⢠ ������
Count	dw	0
; �ਧ��� ����砭�� ����஢��
StFlag	dw	0
; �ਧ��� ᮢ������� ᨣ������
InFlag	dw	0
; ���࠭���� ॣ�����
RAX	dw	?
RBX	dw	?
RCX	dw	?
RDX	dw	?
RSI	dw	?
RDI	dw	?
RBP	dw	?
RDS	dw	?
RES	dw	?
Flags	dw	?
; ��஥ ��������� �⥪�
OldSS   dw      ?
OldSP	dw	?
; ��஥ ���祭�� ����� 1
Ofs1	dw	?
Seg1	dw	?
; ���� ��ࠬ��஢ ��� ����᪠
BParam  dw      0
OfsCMS	dw	81h
SegCMS  dw      0
OfsBP1	dw	5Ch
SegBP1	dw	0
OfsBP2	dw	6Ch
SegBP2  dw      0
; �⥪
        db      127 dup (?)
StMem	db	?
; �뢮���� ᮮ�饭��
Mess1	db	'***************************',13,10
	db	'* ��⥪��㥬 �������䨪� *',13,10
	db	'***************************$'
Mess2	db	'***************************',13,10
	db	'* ������� ��⥪�஢���   *',13,10
	db	'***************************$'	
OK	db	' �㪨-�㪨 - �����  !',7,13,10,'$'
BAD	db	' �� � ��ࠤ��, �e� !',13,10,'$'
ME	db	13,10,'�訡�� �����!$'
RU	db	13,10,'�訡�� ����㧪�!$'
PP	db	13,10,'�訡�� ��।������ ���� PSP!$'
Req	db	13,10,'���� > $'
MaxLen	db	64
CurLen	db	0
NamBuf	db	64 dup (0)
Finish:
;
Cseg	Ends
	End	Start
	