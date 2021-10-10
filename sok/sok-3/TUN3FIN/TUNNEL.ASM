;
;                ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;                ³               Tunneling               ³
;                ³                  via                  ³
;                ³         miscellanous methods          ³
;                ³                EXAMPLE                ³
;                ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;
;     I just whipped up this example program so you can see how all the 
; different mini-tunnelers I have shown you work on i13 and i21 on your 
; system.  Obviously, this is not a virus so it is not optimized in any 
; way at all.  Note that you will probably need TASM to compile this.
;
;                                      Methyl [Immortal Riot/Genesis]
some segment para 'code'
    org 100h
main proc far
    assume cs:some, ds:nothing, es:some, ss:some
    push ds
    push cs
    pop ds
    mov ah, 52h
    int 21h
    mov ax, es:[bx-2]
    mov cs:[first_mcb], ax
    mov ah, 9
    lea dx, [m_intro]
    int 21h
    call tracer
    call tracer_show
    call rtfm
    call rtfm_show
    call stealth
    call stealth_show
    call i20_exploit
    call i20_show
    call i2a_exploit
    call i2a_show    
    call grab_13
    call grab_13_show
    call kernel_13
    call kernel_13_show
    pop ds
    call tunnel_cpm
    call tunnel_cpm_show
    mov ah, 4ch
    int 21h
main endp

orig_21 dw 0, 0
orig_13 dw 0, 0
orig_2a dw 0, 0
first_mcb dw 0

m_intro:
    db 'Methyl''s mini-tunneler tester', 0dh, 0ah, '$'

m_tracer_success:
    db 0dh, 0ah, 'Code tracer success - $'
m_tracer_failure:
    db 0dh, 0ah, 'Code tracer failure$'

tracer_show proc near
    mov ds:[orig_21], di
    mov ds:[orig_21+2], es
    mov ah, 9
    cmp si, 0
    jne tracer_show_fail
    lea dx, [m_tracer_success]
    int 21h
    call display21
    ret
tracer_show_fail:
    lea dx, [m_tracer_failure]
    int 21h
    ret
tracer_show endp

override       db 02eh  ; current segment override
loop_counter   dw 0300h ; local abort counter
global_counter dw 0     ; global abort counter
temp_ip        dw 0     ; temporary storage for stack searching
temp_store     dw 0, 0  ; temporary storage for stack searching
stack_top      dw 0     ; do not POP past this point
stack_bottom   dw 0     ; do not PUSH past this point

tracer proc near
    push cs
    pop ds
    mov ds:[stack_top], sp          ; setup stack
    mov ax, offset program_end+40h  ; smaller than lea ax, [program_end+40h]
    mov ds:[stack_bottom], ax       ; assuming we're running from a COM file,
                                    ; we shouldn't push past this point
    mov ax, 03521h
    int 021h                ; get i21 address
    xchg bx, di             ; into ES:DI
    push ax
    push ax
    push ax                 ; fixup stack (push fake CALL)
tracer_begin:
    mov ds:[override], 02eh ; clear overrides
tracer_skip_prefix:
    xor si, si
    mov ax, es
    cmp ax, ds:[first_mcb]
    jb tracer_success       ; check for DOS segment
    dec ds:[loop_counter]
    jz tracer_ret_far       ; do another path if this path has led nowhere
    dec ds:[global_counter]
    jz tracer_error         ; exit if too many global passes
    cmp di, 0fff0h
    jb check_opcode         ; everything is okay, handle opcodes
tracer_ret_far:             ; do another path as this has gone too long
    mov ax, sp
    add ax, 6
    cmp ax, ds:[stack_top]
    jae tracer_error        ; make sure we don't pop too much off the stack
    pop di
    pop es
    pop ds:[loop_counter]
    jmp tracer_begin        ; do RETF and return to main handler
    
tracer_error:
    inc si
tracer_success:
    mov sp, ds:[stack_top]
    ret                     ; exit tunneler

tracer_override:
    mov bl, es:[di]
    mov ds:[override], bl
    add di, ax
    jmp tracer_skip_prefix  ; handles segment overrides

tracer_conditional_jump:
    mov ax, di
    inc ax
    inc ax
    call tracer_call_finish ; push address after conditional jump onto the
                            ; stack
tracer_jmp_short:
    mov al, es:[di+1]
    cbw
    add di, ax
    inc di
    inc di
    jmp tracer_begin        ; do jump short and return to trace

tracer_indirect:
    xchg ax, bx             ; save opcode length 
    mov ax, es:[di]
    cmp al, 0feh
    jb tracer_not_indirect  ; make sure it's within the right range
    and ah, 11000111b
    mov cl, ah              ; save MODR/M information, if there is an indirect
                            ; reference then CX!=110
    cmp ds:[override], 2eh
    je tracer_indirect_next
    inc cx                  ; sets CX!=0 if a non-CS override encountered
tracer_indirect_next:
    mov ax, es:[di]
    and ah, 111000b
    cmp ah, 10000b
    je tracer_call_near_mem ; CALL [X]
    cmp ah, 11000b
    je tracer_call_far_mem  ; CALL FAR [X]
    cmp ah, 100000b
    je tracer_jmp_near_mem  ; JMP [X]
    cmp ah, 101000b
    je tracer_jmp_far_mem   ; JMP FAR [X]

tracer_not_indirect:
    xchg bx, ax             ; restore opcode length
    jmp generic_opcode      ; it's a normal opcode so handle it normally

check_opcode:
    mov ax, es:[di]
        ; although the following opcode checks could be in the CMT, it is
        ; smaller to handle them directly
    cmp al, 0e9h
    je tracer_jmp_near_immed    ; JMP WORD PTR X
    cmp al, 0eah
    je tracer_jmp_far_immed     ; JMP DWORD PTR X:X
    cmp al, 0e8h
    je tracer_call_near_immed   ; CALL WORD PTR X
    cmp al, 9ah
    je tracer_call_far_immed    ; CALL DWORD PTR X:X
    push si
    call decoder                ; get length of opcode in AX... destroys SI 
    pop si                      ; which is why we save/restore it
    cmp bl, 1
    je _tracer_ret_far          ; follow another path if invalid opcode found
    cmp bp, 0
    je generic_opcode           ; handle like a normal opcode 
    jmp bp                      ; use a dedicated procedure for this opcode
generic_opcode:
    add di, ax                  ; DI=DI+Opcode Length
    jmp tracer_begin            ; resume tracing

tracer_call_near_mem:
    call tracer_call_setup      ; make sure CALL doesn't overflow stack
    add ax, 4
    jc _tracer_ret_far
    call tracer_call_finish     ; push address after CALL onto stack
tracer_jmp_near_mem:
    cmp cl, 110b                ; exit if indirect memory access
    jne _tracer_ret_far
    mov di, es:[di+2]
    mov di, es:[di]
    jmp tracer_begin            ; resume tracing

tracer_call_far_mem:
    call tracer_call_setup      ; make sure CALL doesn't overflow stack
    add ax, 5
    jc _tracer_ret_far
    call tracer_call_finish     ; push address after CALL onto stack
tracer_jmp_far_mem:
    cmp cl, 110b                ; exit if indirect memory access
    jne _tracer_ret_far
    mov di, es:[di+2]
    mov ax, es:[di+2]
    mov di, es:[di]
    mov es, ax
    jmp tracer_begin            ; resume tracing

tracer_call_near_immed:
    call tracer_call_setup      ; make sure CALL doesn't overflow stack
    add ax, 3
    jc _tracer_ret_far
    call tracer_call_finish     ; push address after CALL onto stack
tracer_jmp_near_immed:
    add di, es:[di+1]
    add di, 3
    jmp tracer_begin            ; resume tracing

tracer_call_far_immed:
    call tracer_call_setup      ; make sure CALL doesn't overflow stack
    add ax, 5
    jc _tracer_ret_far
    call tracer_call_finish     ; push address after CALL onto stack
tracer_jmp_far_immed:
    mov ax, es:[di+3]
    mov di, es:[di+1]
    mov es, ax
    jmp tracer_begin            ; resume tracing

_tracer_ret_far:                ; so short jumps can
    jmp tracer_ret_far          ; jump to tracer_ret_far
_tracer_error:                  ; so short jumps can
    jmp tracer_error            ; jump to tracer_error

; if you are going to push 6 values (CS, IP, COUNTER) onto the stack, then this
; routine makes sure the stack doesn't overflow... if it would overflow, then
; the tracer aborts
tracer_call_setup:
    pop bx
    mov ax, sp
    sub ax, 6                   ; AX=what SP will be after push's
    cmp ax, ds:[stack_bottom]
    jbe _tracer_error           ; abort if stack goes past limits
    mov ax, di
    push bx
    ret

; this routine scans the stack for the address you are wanting to push onto
; it... if it is not on there, the routine adds it to the stack, otherwise
; it performs a RET FAR
tracer_call_finish:
    pop ds:[temp_ip]            ; keeps the stack clear
    mov ds:[temp_store], ax
    mov ds:[temp_store+2], es   ; save ES and AX which are modified in the
                                ; routine
    push ss
    pop es
    xchg bp, di                 ; save DI
    mov di, sp                  ; ES:DI == SS:SP
tracer_call_loop:
    mov ax, es:[di]
    cmp ax, ds:[temp_store]
    jne tracer_call_nomatch     ; jump if IP!=SS:[SP]
    mov ax, es:[di+2]
    cmp ax, ds:[temp_store+2]
    je _tracer_ret_far          ; do RET FAR if CS:IP==SS:[SP]
tracer_call_nomatch:
    add di, 6
    cmp di, ds:[stack_top]
    jb tracer_call_loop         ; loop until the stack is exhausted
tracer_call_exit:
    push ds:[loop_counter]      ; push loop counter onto stack
    mov ax, ds:[temp_store+2]
    push ax                     ; push CS onto stack
    push ds:[temp_store]        ; push IP onto stack
    push ds:[temp_ip]           ; set return IP on stack
    mov es, ax
    xchg bp, di                 ; restore ES:DI (CS:IP)
    ret                         ; return to caller
tracer endp

m_cpm_okay:
    db 0dh, 0ah, 'CPM tunnel success - $'
m_cpm_failure:
    db 0dh, 0ah, 'CPM tunnel failure$'

tunnel_cpm_show proc near
    mov cs:[orig_21], si
    mov cs:[orig_21+2], ds
    push cs
    pop ds
    mov ah, 9
    jc tunnel_cpm_show_fail
    lea dx, [m_cpm_okay]
    int 21h
    call display21
    ret
tunnel_cpm_show_fail:
    lea dx, [m_cpm_failure]
    int 21h
    ret
tunnel_cpm_show endp

;; on entry, make sure DS==PSP address
; returns DS:SI as i21 address
; carry clear on success, carry set on failure
;
tunnel_cpm proc near
    mov ax, ds:[016h]
    mov bx, ds
    cmp ax, bx
    je psp_end
    cmp ax, 0
    je psp_end
    mov ds, ax
    jmp tunnel_cpm

psp_end:
    mov si, 5

jump_loop:
    lds si, ds:[si+1]
    cmp byte ptr ds:[si], 0eah
    je jump_loop

check_first_magic:
    cmp word ptr ds:[si], 9090h
    jne check_second_magic
    sub si, 32h
    cmp word ptr ds:[si], 9090h
    jne tunnel_error

tunnel_success:
    clc
    ret

check_second_magic:
    cmp word ptr ds:[si], 2e1eh
    jne tunnel_error
    add si, 25h
    cmp word ptr ds:[si], 80fah
    je tunnel_success

tunnel_error:
    stc
    ret
tunnel_cpm endp

m_k13_success:
    db 0dh, 0ah, 'i13 KERNEL scan success - $'

m_k13_fail:
    db 0dh, 0ah, 'i13 KERNEL scan failure$'

kernel_13_show proc near
    push cs
    pop ds
    mov ah, 9
    jc kernel_13_show_fail
    lea dx, [m_k13_success]
    int 21h
    call display13
    ret
kernel_13_show_fail:
    lea dx, [m_k13_fail]
    int 21h
    ret
kernel_13_show endp

kernel_13 proc near
    mov ax, 70h
    mov ds, ax
    mov si, 1
    cld
kernel_13_loop:
    cmp si, 0
    je kernel_13_abort      ; exit when we've finished total scan   

    dec si
    lodsw                   ; get data from DS:SI

    cmp ax,1effh            ; is it the CALL FAR [X]?
    jne kernel_13_loop      ; nope, keep scanning

    cmp word ptr ds:[si],0b4h
    jne kernel_13_loop

    mov si, 0b4h
    push ds:[si]
    pop cs:[orig_13]
    push ds:[si+2]
    pop cs:[orig_13+2]
    clc
    ret
kernel_13_abort:
    mov cs:[orig_13], 0
    mov cs:[orig_13+2], 0
    stc
    ret
kernel_13 endp

m_grab_13:
    db 0dh, 0ah, 'i13 DOS grab leads to - $'

grab_13_show proc near
    push cs
    pop ds
    mov ah, 9
    lea dx, [m_grab_13]
    int 21h
    call display13
    ret    
grab_13_show endp

grab_13 proc near
    mov ah, 013h
    int 02fh                    ; grab original i13 handler addresses
    push es
    push bx                     ; save address we want on the stack
    mov ah, 013h
    int 02fh                    ; restore original addresses (as they were
                                ; corrupted on the first call)
    pop bx
    pop es
    mov cs:[orig_13], bx
    mov cs:[orig_13+2], es      ; save original i13 address in a variable
    ret                         ; exit
grab_13 endp

m_stealth:
    db 0dh, 0ah, 'Stealth success - $'

stealth_show proc near
    push cs
    pop ds
    mov ah, 9
    lea dx, [m_stealth]
    int 21h
    call display21
    ret
stealth_show endp

stealth proc near
    cld
    mov ah, 52h
    int 21h             ; get DOS list-of-lists
    lds si, es:[bx+4]   ; DS:SI = DOS SFT tables
    lds si, ds:[si-4]   ; DS:SI = ??????????????
stealth_loop:
    dec si
    cmp word ptr ds:[si], 0e18ah
    jne stealth_loop    ; MOV AH, CL
    cmp byte ptr ds:[si+2], 0ebh
    jne stealth_loop    ; JMP SHORT
stealth_calculate:
    lodsb
    cmp al, 0fah
    jne stealth_calculate   ; search for DOS kernel entrypoint CLI
    dec si
    mov cs:[orig_21], si
    mov cs:[orig_21+2], ds
    ret     
stealth endp

m_rtfm_okay:
    db 0dh, 0ah, 'RTFM trace success - $'
m_rtfm_failure:
    db 0dh, 0ah, 'RTFM trace failure$'

rtfm_show proc near
    push cs
    pop ds
    mov ah, 9
    jc rtfm_show_fail
    lea dx, [m_rtfm_okay]
    int 21h
    call display21
    ret
rtfm_show_fail:
    lea dx, [m_rtfm_failure]
    int 21h
    ret
rtfm_show endp

rtfm proc near
    mov ax, 4300h
    int 2fh
    cmp al, 80h
    jne rtfm_error          ; abort if no memory manager

    mov ah, 52
    int 21h                 ; ES == DOS data segment
    
    push es
    pop ds
    xor si, si
    cld

rtfm_loop:
    lodsw
    cmp si, -1
    je rtfm_error           ; abort if entire segment scanned with no result
    dec si
    cmp ax, 9090h
    jne rtfm_loop           ; reloop if no double-NOP signature

    cmp word ptr ds:[si+4], 0ff2eh
    jne rtfm_loop           ; no JMP FAR CS: there

    cmp byte ptr ds:[si+6], 2eh
    jne rtfm_loop           ; no JMP FAR CS: there

    mov bx, ds:[si+7]
    les di, ds:[bx]

    cmp byte ptr es:[di], 0fah
    jne rtfm_loop           ; no CLI at entrypoint

    mov cs:[orig_21], di
    mov cs:[orig_21+2], es
    clc
    ret                     ; save address and exit

rtfm_error:
    mov cs:[orig_21], 0
    mov cs:[orig_21+2], 0
    stc
    ret                     ; clear address and exit
rtfm endp

m_i2a_okay:
    db 0dh, 0ah, 'i2a trace success - $'
m_i2a_failure:
    db 0dh, 0ah, 'i2a trace failure$'

i2a_show proc near
    push cs
    pop ds
    mov ah, 9
    cmp ds:[orig_21+2], 0
    je i2a_show_fail
    lea dx, [m_i2a_okay]
    int 21h
    call display21
    ret
i2a_show_fail:
    lea dx, [m_i2a_failure]
    int 21h
    ret
i2a_show endp

i2a_exploit proc near
    xor ax, ax
    mov ds, ax
    les ax, ds:[(02ah*4)]
    mov cs:[orig_2a], ax
    mov cs:[orig_2a+2], es      ; save old 2A handler
    cli
    mov word ptr ds:[(02ah*4)], offset new_2a_handler
    mov ds:[(02ah*4)+2], cs     ; write new handler
    sti
    mov ah, 052h
    int 021h                    ; execute any old INT 21 function
    les ax, dword ptr cs:[orig_2a]
    cli
    mov ds:[(02ah*4)], ax
    mov ds:[(02ah*4)+2], es     ; restore old handler
    sti
    ret                         ; exit routine
i2a_exploit endp

new_2a_handler proc far
    push bp
    mov bp, sp
    push ax
    push es
    push di
    push cx                     ; Save registers
    mov cx, -1
    les di, [bp+2]              ; Set ES:DI to return address
    std                         ; Scan backwards
    mov al, 0fah                ; 'CLI'
    
int_2a_loop:
    scasb
    je int_2a_scan_okay         ; Exit if CLI found
    loop int_2a_loop            ; Keep scanning
int_2a_scan_error:
    mov word ptr cs:[orig_21], 0
    mov word ptr cs:[orig_21+2], 0
    jmp exit_2a_handler         ; Abort if no CLI in whole segment
int_2a_scan_okay:
    cmp word ptr es:[di+2], 0FC80h
    jne int_2a_loop
    inc di                      ; SCASB fixup
    mov cs:[orig_21], di
    mov cs:[orig_21+2], es      ; Save CLI's CS:IP (ES:DI)
exit_2a_handler:
    mov ax, ss:[bp+6]
    push ax
    popf                        ; Restore proper flags
    pop cx
    pop di
    pop es
    pop ax
    pop bp                      ; Restore modified registers
    jmp dword ptr cs:[orig_2a]  ; Hand control back to original 2A handler
new_2a_handler endp

m_i20_okay:
    db 0dh, 0ah, 'i20 trace success - $'
m_i20_fail:
    db 0dh, 0ah, 'i20 trace failure$'

i20_show proc near
    push cs
    pop ds
    mov ah, 9
    jc i20_show_fail
    lea dx, [m_i20_okay]
    int 21h
    call display21
    ret
i20_show_fail:
    lea dx, [m_i20_fail]
    int 21h
    ret    
i20_show endp

i20_exploit proc near
    mov ax, 3520h
    int 21h
    mov ax, es
    mov ds, ax
    mov si, bx              ; point DS:SI to i20
    cmp ax, cs:[first_mcb]
    jae i20_hooked
i20_high:
    cmp byte ptr ds:[si], 0eah
    jne i20_low             ; check for first JMP FAR
    add si, 5
    cmp byte ptr ds:[si+5], 0cfh    
                            ; check for IRET (maybe this should be left out)
    jne i20_hooked
    cmp byte ptr ds:[si], 0eah      
                            ; check for second JMP FAR
    jne i20_hooked
    inc si
    lds si, ds:[si]
    mov cs:[orig_21], si
    mov cs:[orig_21+2], ds
    clc
    ret
i20_hooked:
    mov word ptr cs:[orig_21], 0
    mov word ptr cs:[orig_21+2], 0
    stc
    ret
i20_low:
    push ds
    pop es
    mov cx, -1
    std                         ; scan backwards
    xor di, di                  ; bleh :)
    mov al, 0fah                ; 'CLI'
    
i20_scan_loop:
    scasb
    je i20_scan_okay            ; exit if CLI found
    loop i20_scan_loop          ; keep scanning
i20_scan_error:
    mov word ptr cs:[orig_21], 0
    mov word ptr cs:[orig_21+2], 0
    stc
    ret                         ; exit if no CLI found
i20_scan_okay:
    cmp word ptr es:[di+2], 0FC80h
    jne i20_scan_loop
    inc di                      ; SCASB fixup
    mov cs:[orig_21], di
    mov cs:[orig_21+2], es      ; save CLI's CS:IP (ES:DI)
    clc
    ret                         ; exit happily        
i20_exploit endp

display21 proc near
    mov bx, cs:[orig_21+2]
    call bin_2_hex
    call print_colon
    mov bx, cs:[orig_21]
    call bin_2_hex
    ret
display21 endp

display13 proc near
    mov bx, cs:[orig_13+2]
    call bin_2_hex
    call print_colon
    mov bx, cs:[orig_13]
    call bin_2_hex
    ret
display13 endp

bin_2_hex proc near
    mov ch, 4
rotate:
    mov cl, 4
    rol bx, cl
    mov al, bl
    and al, 0fh
    add al, 030h
    cmp al, '9'+1
    jl print_it
    add al, 07h
print_it:
    mov dl, al
    mov ah, 2
    int 021h
    dec ch
    jnz rotate
    ret
bin_2_hex endp

print_colon proc near
    mov ah, 2
    mov dl, ':'
    int 021h
    ret
print_colon endp

; Registers modified: AX, BX, CX, DX, SI, BP
; Requires:           AX holds opcode to scan through table
;                     Segment of CMT database in DS
; Returns on failure: BL=1
; Returns on success: BL=0
;                     AX=instruction length
;                     BP=address to give control to if dedicated routine
;                        needed, or 0 if no dedicated routine needed
;
decoder proc near
        lea si, [instruction_table-1]
        mov dx, ax                      ; DX holds the virgin opcode through 
                                        ; the entire routine
decoder_main:
        xor bp, bp
        inc si
        cmp si, offset instruction_table.end_of_table
        jne decoder_valid       ; make sure we don't go off past the 
                                        ; end of the table
decoder_invalid:
        mov bl, 1                       ; BL = failure code
        ret                             ; exit decoder

decoder_valid:
        mov ax, dx                      ; reload AX with current opcode
        mov bl, ds:[si]                 ; get status word in BL
        mov bh, bl                      ; make a copy
        and al, ds:[si+1]               ; mask opcode against table entry
        inc si
        inc si
        test bl, 10000b
        je decoder_not_special          ; no special routine needed
        mov bp, ds:[si]                 ; grab routine address
        inc si
        inc si                          ; adjust DS:SI pointer
decoder_not_special:
        cmp al, ds:[si]                 ; check masked opcode against CMP value
        jne decoder_main                ; no match, so restart with next entry
        
        ; there is a bug in my tables which makes it so you have to set this
        ; bit in the field descriptor byte if a TEST B/TEST W instruction is
        ; encountered
        mov ax, dx
        and ax, 11100011111110b
        cmp ax, 00000011110110b
        jne decoder_notest
        or bh, 1000000b

decoder_notest:
        ; now we need to work out the opcode length... using the status bits
        ; still held intact in BH (our BL copy was destroyed earlier)... note
        ; that CL holds the end instruction length throughout this section

        ; first we need the beginning length of the instruction
        mov al, bh
        and al, 111b
        mov cl, al                      ; this is added/used as instruction
                                        ; length no matter what the rest of the
                                        ; bitfields say

        ; next we handle the 'last bitfields' section
        mov al, bh
        and al, 1000000b
        jz decoder_nobits       ; we're not supposed to use the bits

        mov ax, dx                      ; get current opcode back
        and al, 1
        inc al
        add cl, al                      ; increase accordingly
        mov al, bh
        and al, 100000b
        jz decoder_nobits
        mov ax, dx                      ; get current opcode back
        and al, 11b
        cmp al, 11b
        jne decoder_nobits
        dec cl                          ; decrease accordingly

decoder_nobits:
        ; now that we have the beginning length, we check to see if this 
        ; entry uses MODR/M
        mov al, bh
        and al, 1000b
        jz decoder_nomodrm

        ; if we do use MODR/M... the shit really hits the fan here
        add cl, 2                       ; we add 2 by default since the opcode
                                        ; is at least 2 bytes long (identifier
                                        ; plus MODR/M byte)
        mov ax, dx                      ; get current opcode back
        and ah, 11000111b
        cmp ah, 110b
        je decoder_add_two      ; we just add 2 for str8 memory access
        and ah, 11000000b
        jz decoder_nomodrm      ; we add nothing
        cmp ah, 01000000b
        je decoder_add_one      ; we just add a byte displacement here
        cmp ah, 11000000b
        je decoder_nomodrm      ; we add nothing here either
        
decoder_add_two:
        inc cl
decoder_add_one:
        inc cl
decoder_nomodrm:
        mov ch, 0
        mov ax, cx                      ; AX = instruction length
        mov bl, 0                       ; BL = success
        ret                             ; leave decoder
decoder endp

instruction_struc struc

    ; AAA/AAS/DAA/DAS
    db 00000001b
    db 11100111b
    db 00100111b

    ; AAD/AAM
    db 00000010b
    db 11111110b
    db 11010100b

    ; BOUND
    db 00001000b
    db 11111111b
    db 01100010b

    ; CBW/CWD/POPF/PUSHF/SAHF/LAHF/WAIT/CALL FAR OFF:SEG
    ; XCHG accumulator with register
    db 00000001b
    db 11110000b
    db 10010000b

    ; CLD/STD/CMC/HLT
    db 00000001b
    db 11110110b
    db 11110100b

    ; CLI/STI/CLC/STC
    db 00000001b
    db 11111100b
    db 11111000b

    ; CS/DS/ES/SS overrides
    db 00010001b
    db 11100111b
    dw tracer_override
    db 00100110b

    ; JMP conditional
    db 00010010b
    db 11110000b
    dw tracer_conditional_jump
    db 01110000b

    ; JMP short
    db 00010010b
    db 11111111b
    dw tracer_jmp_short
    db 11101011b

    ; LOCK/REP[N[E]]
    db 00000001b
    db 11111100b
    db 11110000b

    ; CMPS/MOVS/LODS/SCAS
    db 00000001b
    db 11110100b
    db 10100100b

    ; DEC|INC|PUSH|POP register
    db 00000001b
    db 11100000b
    db 01000000b

    ; INT 3 | INTO
    db 00000001b
    db 11111101b
    db 11001100b

    ; IRET
    db 00010000b
    db 11111111b
    dw tracer_ret_far
    db 11001111b

    ; RETN|F 
    db 00010000b
    db 11110110b
    dw tracer_ret_far
    db 11000010b

    ; INT variable
    db 00000010b
    db 11111111b
    db 11001101b

    ; PUSH|POP segment register
    db 00000001b
    db 11100110b
    db 00000110b

    ; ENTER
    db 00000100b
    db 11111111b
    db 11001000b

    ; LEAVE 
    db 00000001b
    db 11111111b    
    db 11001001b

    ; LOOP series and JCXZ
    db 00010010b
    db 11111100b
    dw tracer_jmp_short
    db 11100000b

    ; XCHG/TEST/LEA/POP register/memory
    ; MOV segment register with register/memory
    db 00001000b
    db 11110100b
    db 10000100b

    ; PUSHA and POPA
    db 00000001b
    db 11111110b
    db 01100000b

    ; IN/OUT variable port
    db 00000001b
    db 11111100b
    db 11101100b

    ; IN/OUT fixed port
    db 00000010b
    db 11111100b
    db 11100100b

    ; STOS
    db 00000001b
    db 11111110b
    db 10101010b

    ; XLAT
    db 00000001b
    db 11111111b
    db 11010111b

    ; ESC
    db 00001000b
    db 11111000b
    db 11011000b

    ; LDS/LES
    db 00001000b
    db 11111110b
    db 11000100b

    ; MOV register/memory with register
    db 00001000b
    db 11111100b
    db 10001000b

    ; MOV memory with accumulator
    db 00000011b
    db 11111100b
    db 10100000b

    ; MOV register with immediate byte
    db 00000010b
    db 11111000b
    db 10110000b

    ; MOV register with immediate word
    db 00000011b
    db 11111000b
    db 10111000b

    ; TEST accumulator with immediate 
    db 01000001b
    db 11111110b
    db 10101000b

    ; ADC|ADD|AND|CMP|OR|SBB|SUB|XOR register/memory with register
    db 00001000b
    db 11000100b
    db 00000000b

    ; RCR|RCL|ROR|ROL|SHR|SHL|SAR|SAL register/memory with 1 or CL
    db 00001000b
    db 11111100b
    db 11010000b

    ; RCR|RCL|ROR|ROL|SHR|SHL|SAR|SAL register/memory with immediate
    db 00001001b
    db 11111110b
    db 11000000b

    ; ADC|ADD|AND|CMP|OR|SBB|SUB|XOR register/memory with immediate
    db 01101000b
    db 11111100b
    db 10000000b

    ; MOV register/memory with immediate
    db 01001000b
    db 11111110b
    db 11000110b

    ; ADC|ADD|AND|CMP|OR|SBB|SUB|XOR accumulator with immediate
    db 01000001b
    db 11000110b
    db 00000100b

; F6 - test, ???, not, neg, mul, imul, div, idiv  b's
; F7 - test, ???, not, neg, mul, imul, div, idiv  w's
; FE - inc, dec, callin, callif, jmpin, jmpif, push, ???
; FF - inc, dec, callin, callif, jmpin, jmpif, push, ???
; Note that the TEST instruction is handled incorrectly!
;
    db 00011000b
    db 11110110b
    dw tracer_indirect
    db 11110110b

    end_of_table equ $
    ends

instruction_table instruction_struc <>
                            ; our new complex mask table
program_end equ $

some ends
     end main
