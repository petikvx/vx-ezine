; это антивирус на вирус [VD/SLAM].393

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
        lea     dx,mesStart     ; dx указывает на сообщение
        call    print           ; печать сообщения mes
        call    checkMem        ; проверить память
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
        lea     dx,path	     	; по адресу path хранится имя найденного
                                ; файла
	call	printPath
	call	openForRead
        jc      openNextFile    ; ошибка открытия
        lea     dx,buf          ; dx указывает на буфер
        mov     cx,100          ; cx = 100
	call	readFromFile
	call	checkJmp	; проверить сигнатуру JMP
	jne	close
	mov	ax,startPos
	call	seekToAx
	mov 	cx,100
	call	readFromFile
        call    checkVir        ; проверить сигнатуру вируса
        jne     close           ; уход, если не найдена
        lea     dx,path     	; dx указывает на имя файла
        call    printPath	; вывести имя
	call	writeVirName
	lea	dx,mesInfect2
	call	print
	call	readKey
	jc	close
        call    cureFile	; подпрограмма лечения вируса
	call	setDataTimeCreat
close:
	call	closeFile	; закрыть файл
	jmp	openNextFile
exit:
        lea     dx,mesBye	; dx указывает на сообщение mesBye
exitProg:
        call    printPath	; печать сообщения
	mov	ah,4Ch
        int     21h		; завершить программу

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

; подпрограмма устанавливает старое время, дату создания файла
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

; подпрограмма устанавливает сегменты DS, ES
setupSegments	proc
	push	ax
	mov	ax,data
	mov	ds,ax
	mov	envSeg,es
	mov	es,ax
	pop	ax
	ret
	endp

; открыть файл для чтения
openForRead	proc
	push	ax
	mov 	ax,3D40h
	int	21h
	mov	handle,ax
	pop	ax
	ret	
	endp

; закрыть файл
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

; переместить файловый указатель на AX
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

; переместить указатель файла на АХ байт от конца
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

; читать из файла сх байт
readFromFile	proc
	push	ax bx cx
	mov	bx,handle
	mov	ah,3Fh
	int	21h
	pop	cx bx ax
	ret
	endp

; записать в файл cx байт
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

; подпрограмма поиска сигнатуры Jmp
checkJmp	proc
	push	ax bx dx si
	lea	si,jmpSig
	call	checkSig
	jne 	noGetAx
	mov	bx,[si]		; смещение для JMP
	mov	dx,[si+2]	; длина команды
	lea	si,buf
	mov	ax,[si+bx]	; адрес перехода + 3 в ax
	add	ax,dx		; коррекция ax
	mov	startPos,ax
	cmp	ax,ax
noGetAx:
	pop	si dx bx ax
	ret	
	endp

; подпрограмма сканирования участка памяти
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

; подпрограмма поиска сигнатуры вируса
checkVir	proc
	push	si
        lea     si,sigVir	; si указывает на сигнатуру
	call	checkSig
	mov	offsetSig,si
	pop	si
	ret
	endp

; подпрограмма сканирует сигнатуру DS:SI <=> ES:DI
checkSig	proc
	cld
	push	ax cx di
        mov     di,dx		; di указывает на buf
        lodsw			; в ax дополнительное смещение
        add     di,ax		; di = di + ax
	xor	ah,ah
        lodsb			; в al длина сигнатуры
        mov     cx,ax		; cx = ax
        rep     cmpsb		; сравнить цепочку байт ds:[si] и es:[di]
	pushf
	add	si,cx		; скорректировать si
	popf
	pop	di cx ax
        ret
	endp

; подпрограмма проверки памяти
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
        lea     dx,mesMemOk	; dx указывает на mesMemOk
        call    print		; печать строки
memOk:
        ret
	endp

; подпрограмма выводит имя вируса
writeVirName	proc
	push	ax dx si
        lea     dx,mesInfect1	; dx указывает на mesInf
        call    print		; печать сообщения
	mov	si,offsetSig
	mov	dx,[si]
	push	ds
	mov	ax,virNameSeg
	mov	ds,ax
	call	print		; печать имени вируса
	pop	ds
	mov	dl,'.'
	call 	printChar	; печать точки
	mov	dx,[si+2]
	call	printDecimal
	pop	si dx ax
	ret
	endp

; подпрограмма выводит число в DX
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

; подпрограмма запроса лечения вируса
readKey	proc
	push	ax dx
	cmp	varKeyOk,1
	lea	dx,mesYes
	je	cureOk
        xor     ax,ax		; ax = 0
        int     16h		; ожидать нажатия клавиши
        cmp     al,0Dh		; это Enter ?
        je      cureOk		; да
        cmp     al,' '		; это Space ?
        je      cureOk		; да
	or	al,20h
        cmp     al,'y'		; это 'y'
        je      cureOk		; да
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

; открыть файл для записи
reopenFile	proc
	push	ax bx cx dx
	mov	bx,handle
        mov     ah,3Eh		; закрыть файл, номер в bx
        int     21h
        lea     dx,path		; dx указывает на имя файла
	xor	cx,cx
        mov     ax,4301h	; установить новый атрибут в cx
        int     21h		
        jc      @F		; переход при ошибке
        mov     ax,3D42h	; открыть файл для чтения/записи
        int     21h
	mov	handle,ax
@F:
	pop	dx cx bx ax
	ret
	endp

; вылечить файл
cureFile	proc
	push	ax bx cx dx si
	call	reopenFile	; открыть файл для записи
        jc      outErr		; переход при ошибке
	xor	ah,ah
	mov	si,offsetSig
	mov	al,[si+4]	; в al - число байт для восстановления
	push	ax
        mov	ax,[si+5]	; в ax - смещение для настоящих байт
	add	startPos,ax
	mov	ax,startPos
	call	seekToAx
        lea     dx,buf		
        mov     cx,512		 
	call	readFromFile	; загрузить оригинальные байты
	mov	ax,[si+7]	; в ax - адрес подпрограммы для расшифровки
	pop	cx	
	lea	dx,buf
	clc
	call	ax		; расшифровать байты
	jc	outErr
	xor	ax,ax
	call	seekToAx	; переход на начало файла
	lea	dx,buf
	call	writeToFile	; записать байты
	jc	outErr
	mov	ax,[si+9]	; в ax - длина вируса
	call	seekToAxEnd
	xor	cx,cx
	call	writeToFile	; укоротить файл на ax байт
	jc	outErr
        lea     dx,mesOk	; сообщение о лечении
        call    print		; печать
	stc			; признак - файл был заражен
	jmp	short exitCure
outErr:
        lea     dx,mesErr	; сообщение об ошибке
        call    print		; печать
	clc			; останов сканирования
exitCure:
	pop	si dx cx bx ax
        ret
	endp

; подпрограмма переводит курсор на строку вниз
print0D0A	proc
        push    ax
        mov     ax,0E0Dh	; функция 0Eh, символ 0Dh
        int     10h		; возврат каретки
        mov     ax,0E0Ah	; функция 0Eh, символ 0Ah
        int     10h		; перевод строки
        pop     ax
        ret
	endp

; подпрограмма, печатающая символ
printChar	proc
	push	ax
	mov	ah,2
	int	21h
	pop	ax
	ret
	endp

; подпрограмма, печатающая строку
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

; подпрограмма расшифровывает байты
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

; сегмент содержит имена вирусов
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
