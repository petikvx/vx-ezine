旼컴컴컴컴컴컴컴컫컴쩡컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴커
쿔NFECTED MOSCOW �#1� JAN'97 �(C)STEALTH Group MoscoW & Co � one@redline.ru  �
읕컴컴컴컴컴컴컴컨컴좔컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴켸
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴�
� 넡設쥯 ㄻ� ˘說��                                � (C) Beast/SGBishkek    �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴�

; � ぎ�η�� �㎖Þ禎刷 쭬 �ⅰ�レ溫� ぎエ曄飡¡ ぎК���졷�ⅱ, �� ��-М�с
; � 將�� �昔％ � ぎК��殊昔쥯筍 �ηⅲ�. 
;  뒶昔曄, ㏇� 췅´惜篆� 쭬캙黍エ刷 � �젵쳽Ж-┘設쥯Ж, 첓┐硫 �젳 ⓨ 
; �洙蝨�-獸 ��誓�ⓤ猶졻� ��笹� �曄誓ㄽ�� �昔´夕� ˘黍�. 
;  뤲�飡� 丞젲ⓥ� � ぎК젺ㄽ�� 飡昔ぅ: 
; zhertva.com R

; � �� �젹좑 Л�．飡�젮젷彛좑 ┘設쥯 ▲ㄵ� ¡飡젺�˙��췅.

;  P.S. � ぎ쵟�ㄽ�� 飡昔ぅ R 丞젳猶졻� ‘レ溫�. 뜢 獸 OneHalf ��ㅶ��ⓥ� >:-)

		.MODEL SMALL
		.CODE
		ORG	100H
START:
		MOV	AL,DS:[82H]	; 뿞． �젹 � ぎ쵟�ㄽ�� 飡昔ぅ ?
		CMP	AL,'R'		; �γ╈� 췅� ¡遜�젺�˘恂� �昔碎�
		JNE	NO_RESTORE
					; �昔碎�. 꽑 ι� 첓�
        mov ax,Ds:[2ch]		; 롡 find'º �洙蝨� ｀習젺乘ⓤ�
        mov Ds,ax
        xor bx,bx
next:
        mov al,Ds:[bx]
        or al,0
        je con
        inc bx
        jmp next
con:
        inc bx
        mov al,Ds:[bx]
        or al,al
        jne next
	add bx,3

		MOV	AH,3CH	; � 쭬黍率�п�
		MOV	CX,0	; � CX � �젶 �黍 쭬｀習ぅ ZERO 獸暹ⓥ
		MOV	DX,BX
		INT	21H
		JC	NO_RESTORE
		MOV	BH,40H
		XCHG	BX,AX
		PUSH	CS
		POP	DS
		MOV	CX,PRL
		CWD	
		INC	DH
;		MOV	DX,100H
		INT	21H
		MOV	AH,3CH
		INT	21H
NO_RESTORE:
		RET
PL		EQU	$-START
		DB	2000-PL DUP (90H)
PRL		EQU	$-START
		END	START