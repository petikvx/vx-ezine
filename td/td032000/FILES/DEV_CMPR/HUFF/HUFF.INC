; Deviator's Huffman Encoding/Deconing Engine

; �� ! ��� � � ������� ���䬠�� !
;  ������ �� �� ᮢᥬ ���䬠�,᪮॥ ����-���䬠�....��ॢ� � ���� :)
;  ��ᨤ�� � � ���⨪�� � ��࠭��讬,����ந� �������� ��⨬��쭮� ��ॢ�,
;  ��ᬮ�५ ��������୮�� � ����ᠫ ������ �ண�.

; ������ 㯠���騪�:	~340 ����
; ��ᯠ���騪�:		~90  ����
;  ������ �ᯠ���騪� ����� 㪮���� ���� �� 30

; �������� ��⨬��쭮� ��ॢ�:
;		 
;		/^\
;	      /     \
;	    /\	     /\
;	   /  \     /  \
;         /\  /\   /\  /\
; � ⠪ �����...
;  ��� ��� �᫨ �� ����ந� ⠪�� ��ॢ� �� ����,� � १���� �� ����
; ����稬 ⠡���� ������ ���� �� ����. ����� ���� ���-� 㪮���� ����� ����,
; � ���-� 㢥�����. 

;	       /^\
;	      /   \
;	     /    /\		- ���� �� 2 ������⮢
;	    /\   /  \
;	   /  \
;	  /    \
;	 /     /\		- �������� 㤢�������� - 4 �������
;       /     /   \
;      /     /\    /\
;     /     /  \  /  \ 
; � ⠪ �����... ����砥��� �������� ��⨬��쭮� ��।������ ����.
; ����⢥���,祬 ����� ࠧ����� ����,⥬ ���. ���ਬ�� ��������� �����
; ��⢨ ��� 2-��稭���� ������⮢ ��⠢��� 14 ���:

; 2 ���  = 2   �������
; 4 ���  = 4   �������
; 6 ���   = 8   ������⮢
; 8 ���   = 16  ������⮢
; 10 ���  = 32  �������
; 12 ���  = 64  �������
; 14 ���  = 128 ������⮢
;           ---
;	    256

; ����⢥���,�᫨ � ��稭��饩 ��⢨ ���� �������, � ���ॡ���� ����� 
; ��� ��� �ᥣ� ��ॢ�(15). ���⢥��⢥���,祬 � 䠩�� ����� �ᯮ������
; ࠧ����� ᨬ�����, ⥬ ����� �㦭� ������ ����� ����.

; ���ᨬ��쭠� �⥯��� ᦠ�� �� ���䬠�� 1:8 (�� 䠩�� ����饬 �� �����
;  � ��-�� ᨬ����� � � ��砫쭮� ����� � ���� �������).

; ���筮 �����訥 १����� ���� ��砫쭠� ���� �� 4 ������⮢. ���ᨬ��쭠�
;  �⥯��� ᦠ�� - 2:1. �����,� �ਭ樯�,�� ������⢠ ࠧ����� ᨬ�����
;  �������� ��ࢮ��砫��� ����,�� � ���� ���� �ய�ᠫ �� ࠧ��� ����⠭⮩.

; � �।��� �⥯��� ᦠ�� �㦥 祬 � LZ77,�� �뢠�� ��ᢥ��,����� ���䬠�
;  ᦨ���� �祭� ���� ������.

; P.S.	   ��� �ᥣ� �ਬ����� � ᮢ��㯭��� � RLE
; P.S.S.   ������ �����,ᦨ���� ���,����॥ 祬 �ᬮ�� �ਬ�� Z0MBiE :)
;	   (� ����ᨬ��� �� ������⮣� 䠩�� � ����ன�� BitLim)
; P.S.S.S. ��-� ��� �� #vir ����ਫ �� �� ���⮩,� �� �� ����ᠫ Huffman 
;	   �����騪/�ᯠ���騪 � ~700/600 ����. ��祬 �� ��� ��⠫�� ��������
;          �� ���䬠� � ���� ᦨ���� � ᮮ⭮襭�� ����� 祬 8:1,⮫쪮 ���
;	   ��'�᭨�� ��祬� �� ⠪ ᦨ����, �� ᬮ� :)

BitLim	=	4			; ������⢮ ������⮢ � ��ࢮ� ��⢨
NumLim	=	1 shl (BitLim-1)	; �������筮,�� � �᫥

Huffe	proc	; DS:Si - Source, ES:Di - Dest; Returns new size in CX (bytes)
	pusha
	mov bp,sp

	mov ax,cx			; ���࠭�� ࠧ���
	stosw

	push di
	mov cx,256
	xor eax,eax
	mov di,offset EncTbl
	push di
FillTbl:				; �������� ⠡����
	stosd
	inc ax
	loop FillTbl

	mov cx,[bp][12]
	pop  di
Count:	xor ax,ax			; �ந������ ����⨪� ������ ⮣�
	lodsb				; ��� ����� ᨬ����
	shl ax,2
	xchg ax,bx
	inc 2 ptr ds:[di][bx][1]
	loop Count

	mov cx,255			; �����㥬 :)
Sort:	push cx	

	mov ax,255			; ���᫨� ���-�� 横���
	sub cx,ax
	add ax,cx
	xchg ax,cx

	mov si,di
Inner:	mov ebx,ds:[si]			; ���� ���஢��
	mov ax,ds:[si][1]
	cmp 2 ptr ds:[si][4][1],ax
	jbe NoXchange
	xchg ebx,ds:[si][4]
	mov  ds:[si],ebx
NoXChange:
	add si,4
	loop Inner
NoSort:	pop  cx
	loop Sort
					; ������ � ��� ���� �筠� ����⨪�
	xchg si,di
	mov  di,offset HufTbl		; ��९�襬 ᨬ���� � ⠡����
	mov  cx,256
	xor  bx,bx			; Bx ���쬥� ��� ���稪 ���-�� �㪢
CopySym:movsb				; �����㥬 �㪢�
	lodsw				; ��६ ࠧ���. 
	or ax,ax			; ��, �ਥ堫� ?
	jz Copied
	inc bx
	inc si
	loop CopySym			; ������ �� ����
Copied:	mov F,bx			; ���࠭�� ���-��
	xchg ax,bx
	pop di
	stosw				; ������ � ��⮪ ���-�� ᨬ�����

	mov  si,offset HufTbl
	xchg ax,cx
rep	movsb				; ��९��뢠�� � ��室��� ��⮪ ᨬ����
	push di
	
        Call GenTree			; �������� �ᥢ��-��ॢ�

	pop di
	mov si,[Bp][2]
	mov cx,[Bp][12]

	xor bp,bp
Pack:	lodsb				; ���쬥� ����
	xchg ax,dx			; ���࠭�� ���� � DL

	push si cx
	mov  si,offset HufTbl		; �饬 � ⠡��� (�����஢�����)
	mov  cx,F
	xor  bx,bx
FindIt:	lodsb
	cmp al,dl
	jz  SameChar			; ��諨 ?
	inc bx
	loop FindIt

SameChar:			; ��諨... � BX �࠭���� ����� ᨬ���� � ⠡���
	mov si,bx
	shl si,1			; ������� �� 2
	mov ax,2 ptr [si][EncTbl]	; ��६ ��� ������ ��� ������� ᨬ����
	bsr cx,ax			; �㦭�� ���-�� ��� ��� �।�⠢�����
					; ����
	jz  Zero			; ����� ��� ���� ?
	cmp cx,BitLim			; < BitLim ?
	jae Break
Zero:	mov cx,BitLim-1			; No comment
Break:	inc cx				; �����稬 �� 1
BitStore:				; ���࠭塞 ��� � ��室��� ��⮪�
	dec cx				; �⭨��� 1
	bt  ax,cx			; ��� �⮨� ?
	jc SetBit			; �⮨�...
	btr [di],bp			; �� �⮨�,���⨬
	jmp SBit
SetBit:	bts [di],bp			; ���⠢��
SBit:	inc bp				; ����. ���
	cmp bp,8000h			; > 8000h ��� ?
	jb SBitOk			; �� ��ଠ�쭮
	xor bp,bp			; ��� = 0
	add di,4096			; ������� 4096 ����
SBitOk:	or  cx,cx			; ���� �� ���� ?
	jnz BitStore
PNChar:
	pop  cx si
	loop Pack			; ���� �� ����� ?

	mov ax,bp			; ����⠥� ���� ࠧ���
	xor dx,dx
	mov cx,8
	div cx
	inc ax				; ����稬 ���-�� ���⮢
	add ax,di
	mov bp,sp
	sub ax,[bp][0]
	mov [bp][12],ax			; ���࠭�� ���� ࠧ���

	popa
	ret
Huffe	endp
Huffel	equ	$ - Huffe
;---------------------------------------------------------------------

Huffu	proc				; ��ᯠ���騪
	pusha				; DS:Si - Src, ES:Di - Dest
	mov bp,sp			; Returns: new size in CX
	lodsw				; ��६ ���� ࠧ���
	mov [bp][12],ax
	add ax,di
	mov F,ax			; �� �㤠 �ᯠ���뢠��

	lodsw				; ���-�� ࠧ����� ����
	xchg ax,cx
	mov di,offset HufTbl
rep	movsb				; ��९�ᠫ� ᮮ⢥��⢨�
					;  ���� � ��ॢ�
	mov di,[bp][0]

	xor bp,bp

Unpack:	mov bx,offset HufTbl		; ���� �ᯠ����� (������ ������ !)
	mov dx,NumLim
	xor ax,ax			; Ax = 0
Travel:	bt  [si],bp	                ; ��६ ���
	inc bp
	pushf
	cmp  bp,8000h
	jb xOkay
	xor  bp,bp
	add si,4096
xOkay:	popf
	jnc NoBit			; �� �⮨� ?
	add bx,dx			; �⮨�. �ய��⨬ �㦭�� ���-�� ����
	cmp al,0			; �뫨 㦥 0-�� ���� ?
	jnz xBit			; ��
	shl dx,1			; ������ ࠧ��� ��⢨
	jmp dBit			; ����. ���
NoBit:	mov al,1			; ��� �� 0-��� ���
xBit:	shr dx,1			; ������� ࠧ��� ��⢨ �� 2
dBit:	or  dx,dx			; ��諨 �� ���� ?
	jnz Travel			; ���
	mov al,[bx]			; ��६ ���� �� ⠡����
	stosb				; ���࠭塞
	cmp di,F			; ���� �� ������ ?
	jb UnPack			; ����...
	
	popa
	ret				; �� ��室
Huffu	endp
Hufful	equ	$ - Huffu
;-----------------------------------
GenTree proc
	mov di,offset EncTbl
	mov cx,256		; ������� ⠡���� ����⠭����
	xor ax,ax
	xor bx,bx
	mov si,NumLim
	mov dx,BitLim
GenTbl:	push cx
	stosw			; ���࠭塞 ���祭�� ����⠭����
	inc bx
	cmp bx,si		; �ॢ�ᨫ� ����� ?
	jb  Okay		; ���

	xor bx,bx		; ��.
	shl dh,1		; ������� �� ���� ������� ��� � Bh
	or  dh,1		; ��⠭����

	inc dl			; ���-�� ���

	shl si,1		; �����

Okay:	xor ax,ax
	mov ah,dh		; ����� ����
	mov cl,8
	sub cl,dl		; ��।������ � ᤢ����
	or  cl,cl
	jl NoS
	shr ax,cl		; ��������
	jmp XX
NoS:	neg cl
	shl ax,cl
XX:	add al,bl		; ������� �ࠢ�� ����
	pop  cx
	loop GenTbl

        ret
GenTree endp

F	dw	?
HufTbl	db	256 dup (?)
EncTbl	dd	256 dup (?)
