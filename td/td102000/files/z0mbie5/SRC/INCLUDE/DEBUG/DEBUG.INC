
; all debug stuff is here

;debugmsg               macro   msgnum, arg1   ; (if %? out: ZR=Yes NZ=No)
;debugskip              macro   msgnum, skiplabel, arg1 (%?, jz(yes) skiplbl)
;debuggetkey            macro

int3                    macro          ; generate INT3 if only DEBUG version
        IFDEF   DEBUG
                        db      0CCh
        ENDIF
                        endm

debugmsg                macro   msgnum, arg1   ; output: ZR=Yes NZ=No
IFDEF   DEBUG
                        push    msg_&msgnum
                        ifnb    <arg1>
                        push    arg1
                        else
                        push    0
                        endif
                        call    _debugmsg_
ENDIF ; DEBUG
                        endm

debugskip               macro   msgnum, skiplabel, arg1
IFDEF   DEBUG
                        debugmsg msgnum, arg1
                        jnz     skiplabel
ENDIF ; DEBUG
                        endm

debuggetkey             macro
IFDEF   DEBUG
                        call    _debuggetkey_
ENDIF ; DEBUG
                        endm

IFDEF   DEBUG

_debugmsg_              proc    pascal

                        arg     msgarg
                        arg     msgnum

                        pusha
                        pushf
                        cld

                        xor     edi, edi        ; result
                        inc     edi

                        call    __loaddebugstrings

                        call    xxAllocConsole  ; alloc console if GUI app

                        mov     edx, msgnum
                        lea     esi, _debugstrings_data
                        mov     ecx, _debugstrings_size

__1:                    dec     ecx
                        jle     __notfound
                        lodsb
                        cmp     word ptr [esi+11], ';;'
                        jne     __1
                        dec     edx
                        jnz     __1

__found:
                        call    __dump_asciiz

__exit:
                        popf
                        or      edi, edi
                        popa
                        ret

__notfound:
                        x_push  esi, ***ERROR***~
                        mov     esi, esp
                        call    __dump_asciiz
                        x_pop

                        jmp     __exit


__loaddebugstrings:
                        cmp     _is_debugstrings, 1
                        je      __x
                        mov     _is_debugstrings, 1

IFDEF   USE_C
                        x_push  edx, c:\debug.zmb~
ELSE
                        x_push  edx, q:\proj-z5\src\include\debug\debug.zmb~
ENDIF

                        mov     edx, esp
                        call    fopen_ro
                        x_pop
                        jc      __x

                        xchg    ebx, eax

                        lea     edx, _debugstrings_data
                        mov     ecx, size _debugstrings_data
                        call    fread
                        mov     _debugstrings_size, eax

                        call    fclose

                        debugmsg dsload, _debugstrings_size

__x:                    retn

__dump_asciiz:
                        lodsb
                        call    dump_al

__0:                    lodsb
                        or      al, al
                        jz      __q
                        cmp     word ptr [esi-1-2], 0A0Dh
                        je      __q

                        cmp     al, '%'
                        jne     __xc

                        lodsb

                        cmp     al, '#'
                        je      __getkey
                        cmp     al, '?'
                        je      __key
                        cmp     al, 'd'
                        je      __xd
                        cmp     al, 'i'
                        je      __xi
                        cmp     al, 's'
                        je      __xs

__xc:                   call    dump_al
                        jmp     __0

__no:                   mov     al, 'N'
                        call    dump_al
                        mov     al, 'o'
                        call    dump_al
                        jmp     __0

__getkey:               call    _debuggetkey_
                        jmp     __0

__key:                  call    _debugaskyn_
                        jnz     __no

                        xor     edi, edi

__yes:                  mov     al, 'Y'
                        call    dump_al
                        mov     al, 'e'
                        call    dump_al
                        mov     al, 's'
                        call    dump_al
                        jmp     __0

__xi:                   mov     eax, msgarg
                        call    dump_decnum
                        jmp     __0

__xd:                   mov     eax, msgarg
                        call    dump_hexdword
                        jmp     __0

__xs:                   mov     edx, msgarg
__ccc:                  mov     al, [edx]
                        inc     edx
                        or      al, al
                        jz      __0
                        call    dump_al
                        jmp     __ccc

__q:                    retn

                        endp    ; _debugmsg_

dump_al:                pusha

                        push    -11             ; STD_OUTPUT_HANDLE
                        call    xxGetStdHandle
                        xchg    esi, eax

                        lea     ebx, [esp+7*4]
                        push    0
                        push    esp
                        push    1
                        push    ebx
                        push    esi
                        call    xxWriteConsoleA

                        push    esi
                        call    xxFlushFileBuffers

                        popa
                        ret

dump_hexdword:          push    ecx
                        push    8
                        pop     ecx
__cycle:                rol     eax, 4
                        push    eax
                        ;;
                        and     al, 15
                        aam     10
                        aad     'A'-'0'
                        add     al, '0'
                        call    dump_al
                        ;;
                        pop     eax
                        loop    __cycle
                        pop     ecx
                        ret

dump_decnum:
__recdiv:               xor     edx, edx
                        mov     ebx, 10
                        div     ebx
                        push    edx
                        or      eax, eax
                        jz      __divend
                        call    __recdiv
__divend:               pop     eax
                        add     al, '0'
                        call    dump_al
                        ret

; output: AL=pressed key

_debuggetkey_:          pusha

                        call    xxAllocConsole  ; alloc console

                        push    -10             ; STD_INPUT_HANDLE
                        call    xxGetStdHandle
                        mov     esi, eax
                        push    esi
                        call    xxFlushConsoleInputBuffer

                        push    0               ; no flags
                        push    esi
                        call    xxSetConsoleMode

                        push    0
                        push    esp
                        push    1
                        lea     eax, [esp+3*4+7*4]     ; popa.eax -- buffer
                        push    eax
                        push    esi
                        call    xxReadConsoleA

                        popa
                        ret

; output: ZR: 'Y' or 'y' pressed
;         NZ: other key pressed

_debugaskyn_:           pusha

                        call    _debuggetkey_
                        cmp     al, 'y'
                        je      __exit
                        cmp     al, 'Y'

__exit:                 popa
                        ret


ENDIF ; DEBUG
