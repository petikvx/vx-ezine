; (c) Reminder  (1997)

.model tiny
.code
.startup

number equ 31

;--------------- get 1 param (fname)
cld
mov si,81h
lea di,fname
@para1:
lodsb
cmp al,20h
jbe @para2
stosb
@para2:
cmp al,0dh
jnz @para1
xor ax,ax
stosb
;---------------

cld
mov ax,3d00h
lea dx,fname
int 21h
jnc @vbb
jmp er
@vbb:
xchg ax,bx
mov ah,3fh
lea dx,buf
mov cx,0f000h
int 21h
jc er

lea di,sot
call @dis_init


;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------

lea si,buf
mov cx,number
lea bp,sot
mov di,buf2
call e_build

mov cx,number
add cx,dx
mov di,buf2
mov si,buf2
call e_scan

;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------

mov ah,3ch
lea dx,fna
mov cx,20h
int 21h
xchg ax,bx
mov ah,40h
mov dx,buf2
mov cx,200
int 21h
mov ah,3eh
int 21h
int 20h

;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------

er:
int 20h





;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


e_build:
xor dx,dx
mov bx,si
			@e1:
push cx
call @dmain
mov ax,si
sub ax,bx

mov si,bx
mov cx,ax
rep movsb
mov bx,si
			call _2be
;			jz @nea
mov cx,3
call rnd
inc cx
inc cx
mov al,@nop
add dx,cx
rep stosb
			@nea:
pop cx
loop @e1
ret






;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


;------
e_scan:
@e2:
push cx

mov dx,1		; 8 bit

xor ax,ax
lodsb
dec si
cmp al,0ebh
jz @e_8bit
cmp al,78h
ja @e4
cmp al,70h
jb @e4

@e_8bit:		;   ll
lodsb
lodsb

mov bx,si
sub bx,di	; xc
add bl,al
add bx,di	; xc

call e_uau
sub si,2
jmp @e5

@e4:			; !!
mov dx,2		; 16 bit

cmp al,0e8h
jz @e_16bit
cmp al,0e9h
jnz @e5

@e_16bit:
lodsb	; cod
lodsw	; operand
add ax,si
mov bx,ax
call e_uau
sub si,3

@e5:
call @dmain

pop cx
loop @e2
ret






;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


;-------

e_uau:
cmp bx,si
jb bx_si

si_bx:						; FORWARD
call e_trep

cmp dx,2
jz @16bit

dec si
lodsb
add al,cl
mov byte ptr ds:[si-1],al
ret

@16bit:
sub si,2
lodsw
add ax,cx
mov word ptr ds:[si-2],ax
ret



;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


;----------------				; BACK
bx_si:

mov ax,si
sub ax,bx
mov bx,ax

;--------===----
push si dx

mov dx,si

mov si,di
xor cx,cx
@e9:
push si
inc cx
call @dmain
cmp si,dx
jbe @e9
			; |0 ..  |
			; |  ..  |
			; |  bx  | 
			; |  ..	 |
			; |  si  |

;---------------------------------------------
xor dx,dx

@e90:
pop si
dec cx
lodsb
dec si
cmp al,@nop
jz @e89

		push si
call @dmain
		pop ax
push si
sub si,ax
add dx,si
pop si

@e89:
cmp dx,bx
jb @e90

pop si
dec cx

@cv0:
pop ax
loop @cv0

; si is place of this fucked command

mov ax,si
pop dx si	; si is place of fucked jz/jmp/etc + 2

mov cx,si
sub cx,ax
dec cx

;---------------------------------------------

cmp dx,2
jz @16bit2

;				sub si,2
;xchg si,bx
;call e_trep_back
;xchg si,bx

xor ax,ax
sub al,cl

mov byte ptr ds:[si-1],al
ret

@16bit2:
xor ax,ax
sub ax,cx
mov word ptr ds:[si-2],ax
ret

sub si,3
xchg si,bx
call e_trep_back
xchg si,bx
lodsb
lodsw
sub ax,cx
mov word ptr ds:[si-2],ax
ret



;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


;-------------------------------
e_trep:
xor cx,cx
push si
	@e7:
lodsb
dec si
cmp al,@nop
jnz @e6
inc cx
@e6:
call @dmain
	push si
	sub si,cx
	cmp si,bx
	pop si 
	jbe @e7				; yes	jbe
	pop si
ret

;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------


e_trep_back:
xor cx,cx
push si
	@e72:
lodsb
dec si
cmp al,@nop
jnz @e62
inc cx
@e62:
call @dmain
		cmp si,bx
		jbe @e72
pop si
ret




;--------------------------------------------------------------------
;--------------------------------------------------------------------
;--------------------------------------------------------------------



include aifs.inc
include hex.inc
include rnd.amb

fname 	db 13 dup (?)
fna db 'kos',0
sot 	db 260 dup (?)
@nop 	equ 90h
buf:
buf2 equ offset buf+20000
end
