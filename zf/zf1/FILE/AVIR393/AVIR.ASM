; �� ��⨢���� �� ����� [VD/SLAM].393

	.model	small

public	print, readKey
extrn	findIni:near, findRun:near, pathIni:near, path:near
extrn	fTime:word, fDate:word, changePath:near

	assume	cs:code, ds:data
code	segment public
start:
	call	setupSegments
	call	getPathIni
	lea	dx,mesHelp
	jc	exitProg
        lea     dx,mesStart     ; dx 㪠�뢠�� �� ᮮ�饭��
        call    print           ; ����� ᮮ�饭�� mes
        call    checkMem        ; �஢���� ������
searchNextDisk:
	call	findIni
	jc	exit
openNextFile:
	call	findRun
	jnc	openNow
	call	changePath
	jc	searchNextDisk
	jmp	short exit
openNow:
        lea     dx,path	     	; �� ����� path �࠭���� ��� ����������
                                ; 䠩��
	call	printPath
	call	openForRead
        jc      openNextFile    ; �訡�� ������
        lea     dx,buf          ; dx 㪠�뢠�� �� ����
        mov     cx,100          ; cx = 100
	call	readFromFile
	call	checkJmp	; �஢���� ᨣ������ JMP
	jne	close
	mov	ax,startPos
	call	seekToAx
	mov 	cx,100
	call	readFromFile
        call    checkVir        ; �஢���� ᨣ������ �����
        jne     close           ; �室, �᫨ �� �������
        lea     dx,path     	; dx 㪠�뢠�� �� ��� 䠩��
        call    printPath	; �뢥�� ���
	call	writeVirName
	lea	dx,mesInfect2
	call	print
	call	readKey
	jc	close
        call    cureFile	; ����ணࠬ�� ��祭�� �����
	call	setDataTimeCreat
close:
	call	closeFile	; ������� 䠩�
	jmp	openNextFile
exit:
        lea     dx,mesBye	; dx 㪠�뢠�� �� ᮮ�饭�� mesBye
exitProg:
        call    printPath	; ����� ᮮ�饭��
	mov	ah,4Ch
        int     21h		; �������� �ணࠬ��

getPathIni	proc
	push	ax cx si di ds
	mov	si,80h
	mov	ds,envSeg
	xor	ah,ah
	lodsb
	mov	cx,ax
	stc
	jcxz	exitGetIni
nextEbyte:
	lodsb
	cmp	al,' '
	loope   nextEbyte
	dec 	si
	inc 	cx
	lea	di,pathIni
moveToIni:
	lodsb
	cmp 	al,' '
	je	endMove
	cmp	al,0Dh
	je	endMove
	stosb
endMove:
	loopne	moveToIni
exitGetIni:	
	pop	ds di si cx ax
	ret
	endp

printPath	proc
	call	print0D
	call	printSpace
	call	print0D
	call	print
	ret
	endp

printSpace	proc
	push	cx dx
	mov	cx,79
fillSpace:
	mov	dl,' '
	call	printChar
	loop	fillSpace	
	pop	dx cx
	ret
	endp

print0D		proc
	push	ax
	mov	ax,0E0Dh
	int	10h
	pop	ax
	ret
	endp

; ����ணࠬ�� ��⠭�������� ��஥ �६�, ���� ᮧ����� 䠩��
setDataTimeCreat	proc
	push	ax bx cx dx
	mov	bx,handle
	mov	cx,fTime
	mov	dx,fDate
	mov	ax,5701h
	int	21h
	pop	dx cx bx ax
	ret
	endp

; ����ணࠬ�� ��⠭�������� ᥣ����� DS, ES
setupSegments	proc
	push	ax
	mov	ax,data
	mov	ds,ax
	mov	envSeg,es
	mov	es,ax
	pop	ax
	ret
	endp

; ������ 䠩� ��� �⥭��
openForRead	proc
	push	ax
	mov 	ax,3D40h
	int	21h
	mov	handle,ax
	pop	ax
	ret	
	endp

; ������� 䠩�
closeFile	proc
	pushf
	push	ax bx
	mov	bx,handle
	mov	ah,3Eh
	int	21h
	pop	bx ax
	popf
	ret
	endp

; ��६����� 䠩���� 㪠��⥫� �� AX
seekToAx	proc
	push 	ax bx cx dx
	mov	bx,handle
	mov	dx,ax
	xor	cx,cx
	mov	ax,4200h
	int	21h
	pop	dx cx bx ax
	ret
	endp

; ��६����� 㪠��⥫� 䠩�� �� �� ���� �� ����
seekToAxEnd	proc
	push	ax bx cx dx
	mov	bx,handle
	neg	ax
	cwd
	mov	cx,dx
	mov	dx,ax
	mov	ax,4202h
	int	21h
	pop	dx cx bx ax
	ret
	endp

; ���� �� 䠩�� �� ����
readFromFile	proc
	push	ax bx cx
	mov	bx,handle
	mov	ah,3Fh
	int	21h
	pop	cx bx ax
	ret
	endp

; ������� � 䠩� cx ����
writeToFile	proc
	push	ax bx
	mov	bx,handle
	mov	ah,40h
	int	21h
	jc	writeErr
	cmp 	ax,cx
writeErr:
	pop	bx ax
	ret

; ����ணࠬ�� ���᪠ ᨣ������ Jmp
checkJmp	proc
	push	ax bx dx si
	lea	si,jmpSig
	call	checkSig
	jne 	noGetAx
	mov	bx,[si]		; ᬥ饭�� ��� JMP
	mov	dx,[si+2]	; ����� �������
	lea	si,buf
	mov	ax,[si+bx]	; ���� ���室� + 3 � ax
	add	ax,dx		; ���४�� ax
	mov	startPos,ax
	cmp	ax,ax
noGetAx:
	pop	si dx bx ax
	ret	
	endp

; ����ணࠬ�� ᪠��஢���� ���⪠ �����
checkSigMem	proc
	push	dx si es
	lea	si,sigMem
	mov	dx,[si]
	mov	es,[si+2]
	add	si,4
	call	checkSig
	mov	memoryOff,dx
	mov	memorySeg,es
	mov	offsetSig,si
	pop	es si dx
	ret
	endp

; ����ணࠬ�� ���᪠ ᨣ������ �����
checkVir	proc
	push	si
        lea     si,sigVir	; si 㪠�뢠�� �� ᨣ������
	call	checkSig
	mov	offsetSig,si
	pop	si
	ret
	endp

; ����ணࠬ�� ᪠����� ᨣ������ DS:SI <=> ES:DI
checkSig	proc
	cld
	push	ax cx di
        mov     di,dx		; di 㪠�뢠�� �� buf
        lodsw			; � ax �������⥫쭮� ᬥ饭��
        add     di,ax		; di = di + ax
	xor	ah,ah
        lodsb			; � al ����� ᨣ������
        mov     cx,ax		; cx = ax
        rep     cmpsb		; �ࠢ���� 楯��� ���� ds:[si] � es:[di]
	pushf
	add	si,cx		; ᪮�४�஢��� si
	popf
	pop	di cx ax
        ret
	endp

; ����ணࠬ�� �஢�ન �����
checkMem	proc
	call	checkSigMem
	jne	memOk	
	push	dx si di es
	lea	dx,mesMemory
	call	print
	call	writeVirName
	mov	si,offsetSig
	mov	di,memoryOff
	mov	es,memorySeg
	mov	1 ptr es:[di],0E9h
	mov	ax,[si+4]
	mov	2 ptr es:[di+1],ax
	pop	es di si dx	
        lea     dx,mesMemOk	; dx 㪠�뢠�� �� mesMemOk
        call    print		; ����� ��ப�
memOk:
        ret
	endp

; ����ணࠬ�� �뢮��� ��� �����
writeVirName	proc
	push	ax dx si
        lea     dx,mesInfect1	; dx 㪠�뢠�� �� mesInf
        call    print		; ����� ᮮ�饭��
	mov	si,offsetSig
	mov	dx,[si]
	push	ds
	mov	ax,virNameSeg
	mov	ds,ax
	call	print		; ����� ����� �����
	pop	ds
	mov	dl,'.'
	call 	printChar	; ����� �窨
	mov	dx,[si+2]
	call	printDecimal
	pop	si dx ax
	ret
	endp

; ����ணࠬ�� �뢮��� �᫮ � DX
printDecimal	proc
	push 	ax bx cx dx
	mov	ax,dx
	xor	cx,cx
	mov	bx,10
nextDiv:
	xor	dx,dx
	div	bx
	inc	cx
	push	dx
	or 	ax,ax
	jne	nextDiv
nextPop:
	pop	dx
	or	dl,'0'
	call	printChar
	loop	nextPop
	pop	dx cx bx ax
	ret
	endp

; ����ணࠬ�� ����� ��祭�� �����
readKey	proc
	push	ax dx
	cmp	varKeyOk,1
	lea	dx,mesYes
	je	cureOk
        xor     ax,ax		; ax = 0
        int     16h		; ������� ������ ������
        cmp     al,0Dh		; �� Enter ?
        je      cureOk		; ��
        cmp     al,' '		; �� Space ?
        je      cureOk		; ��
	or	al,20h
        cmp     al,'y'		; �� 'y'
        je      cureOk		; ��
	cmp	al,'a'
	jne	checkQuit
	mov	varKeyOk,1
	jmp	short cureOk
checkQuit:
	cmp	al,'q'
	jne	noCure
	lea	dx,mesQuit
	call	print
	mov	ax,4C01h
	int	21h
noCure:
	lea	dx,mesNo
	stc
cureOk:
	pushf
	call	print
	popf
	pop	dx ax
        ret
	endp

; ������ 䠩� ��� �����
reopenFile	proc
	push	ax bx cx dx
	mov	bx,handle
        mov     ah,3Eh		; ������� 䠩�, ����� � bx
        int     21h
        lea     dx,path		; dx 㪠�뢠�� �� ��� 䠩��
	xor	cx,cx
        mov     ax,4301h	; ��⠭����� ���� ��ਡ�� � cx
        int     21h		
        jc      @F		; ���室 �� �訡��
        mov     ax,3D42h	; ������ 䠩� ��� �⥭��/�����
        int     21h
	mov	handle,ax
@F:
	pop	dx cx bx ax
	ret
	endp

; �뫥��� 䠩�
cureFile	proc
	push	ax bx cx dx si
	call	reopenFile	; ������ 䠩� ��� �����
        jc      outErr		; ���室 �� �訡��
	xor	ah,ah
	mov	si,offsetSig
	mov	al,[si+4]	; � al - �᫮ ���� ��� ����⠭�������
	push	ax
        mov	ax,[si+5]	; � ax - ᬥ饭�� ��� ������� ����
	add	startPos,ax
	mov	ax,startPos
	call	seekToAx
        lea     dx,buf		
        mov     cx,512		 
	call	readFromFile	; ����㧨�� �ਣ������ �����
	mov	ax,[si+7]	; � ax - ���� ����ணࠬ�� ��� ����஢��
	pop	cx	
	lea	dx,buf
	clc
	call	ax		; ����஢��� �����
	jc	outErr
	xor	ax,ax
	call	seekToAx	; ���室 �� ��砫� 䠩��
	lea	dx,buf
	call	writeToFile	; ������� �����
	jc	outErr
	mov	ax,[si+9]	; � ax - ����� �����
	call	seekToAxEnd
	xor	cx,cx
	call	writeToFile	; 㪮���� 䠩� �� ax ����
	jc	outErr
        lea     dx,mesOk	; ᮮ�饭�� � ��祭��
        call    print		; �����
	stc			; �ਧ��� - 䠩� �� ��ࠦ��
	jmp	short exitCure
outErr:
        lea     dx,mesErr	; ᮮ�饭�� �� �訡��
        call    print		; �����
	clc			; ��⠭�� ᪠��஢����
exitCure:
	pop	si dx cx bx ax
        ret
	endp

; ����ணࠬ�� ��ॢ���� ����� �� ��ப� ����
print0D0A	proc
        push    ax
        mov     ax,0E0Dh	; �㭪�� 0Eh, ᨬ��� 0Dh
        int     10h		; ������ ���⪨
        mov     ax,0E0Ah	; �㭪�� 0Eh, ᨬ��� 0Ah
        int     10h		; ��ॢ�� ��ப�
        pop     ax
        ret
	endp

; ����ணࠬ��, ������� ᨬ���
printChar	proc
	push	ax
	mov	ah,2
	int	21h
	pop	ax
	ret
	endp

; ����ணࠬ��, ������� ��ப�
print	proc
        push    ax cx dx si
        mov     si,dx
nextChar:
        lodsb
        or      al,al
        je      endPrint
	mov	dl,al
	call	printChar
        jmp     nextChar
endPrint:
        pop     si dx cx ax
        ret
	endp

; ����ணࠬ�� ����஢뢠�� �����
decodeSub	proc
	push	si
	mov	si,dx
	xor	1 ptr [si],21h
	xor	1 ptr [si+1],85h
	xor	1 ptr [si+2],2Dh
	clc
	pop	si
	ret
	endp
	ends

; ᥣ���� ᮤ�ন� ����� ����ᮢ
virNameSeg	segment
name1		db '[VD/SLAM]',0
	ends

data	segment public
mesHelp		db 13,10
		db ' ANTIVIRUS for virus [VD/SLAM].393. Written by '
		db 'Valentin Kolesnikov.'
		db 13,10,10
		db 'Usage:  AVIR.EXE path'
		db 13,10,10
		db 'Example: avir *',0
mesYes		db 'YES ',0
mesNo		db 'NO',13,10,0
mesQuit		db 'QUIT',13,10,0
mesStart     	db 13,' Looking for virus ...',13,10,0
mesMemOk	db ' CURED !',13,10,0
mesBye   	db 13,' Scanning complete.',0
mesMemory	db 'MEMORY'
mesInfect1  	db ' - infected with ',0
mesInfect2	db ' virus. Repaired infected file (y/n/a/q) ? ',0
mesOk   	db ' REPAIRED !',13,10,0
mesErr  	db ' Dos error.',7,13,10,0
varKeyOk	db 0
handle		dw 0
startPos	dw 0
offsetSig	dw 0
memoryOff	dw 0
memorySeg	dw 0
envSeg		dw 0
jmpSig		dw 0
		db 1, 0E9h
		dw 1, 3
sigVir  	dw 0
        	db 0Fh,0E9h,0EDh,00,0B0h,3,0CFh,80h
		db 0FCh,04Bh,74h,3,0E9h,0DDh,0,60h
		dw name1
		dw 393
		db 3
		dw 174h
		dw decodeSub
        	dw 393
sigMem		dw 6, 20h, -6
        	db 0Fh,0E9h,0EDh,00,0B0h,3,0CFh,80h
		db 0FCh,04Bh,74h,3,0E9h,0DDh,0,60h
		dw name1
		dw 393
		dw 2
buf		db 512 dup (?)
ends
stack	segment stack
		dw 1024	dup (?)
ends
		end
