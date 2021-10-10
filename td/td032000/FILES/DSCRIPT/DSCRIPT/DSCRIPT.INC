
; ---------------------------------------------------------------------------
; subroutine:   DSCRIPT                                       (x) 2000 Z0MBiE
; returns:      exit code in EAX, see DS_ERR_xxx        http://z0mbie.cjb.net
; comments:
;   - input buffer = your binary data
;   - max input buffer size = 65280 bytes
;   - output buffer = DEBUG.EXE's script generating your data
;   - maximal output buffer size needed = (512+<input_size>*43/16)
;   - NULL pointer to output size processed correctly
;   - NULL ptr to filename means dont create file-writing part of the script
;   - flags:
;       DS_FL_WRITEFILE: _param is ptr to fname to be created by the script
;       DS_FL_EXECUTE:   _param is relative entrypoint of 16-bit code,
;                        (code loaded at 100h, max size is 65278)
; ---------------------------------------------------------------------------

; flags
DS_FL_WRITEFILE         equ     00000000h       ; create file (_param=@fname)
DS_FL_EXECUTE           equ     00000001h       ; execute code (_param=ip)

; exit codes
DS_ERR_SUCCESS          equ     0               ; success
DS_ERR_BADSIZE          equ     1  ; too big input or too small output buffer

; ---------------------------------------------------------------------------

DS_MAXSIZE              equ     65536-256       ; max input size
DS_WPL                  equ     8               ; words per line
DS_EXPCOEFF             equ     2+5*DS_WPL+1    ; 'DW',<xNNNN>*<DS_WPL>,13

                        locals  __

dscript                 proc    pascal

  ; comment: arguments should be pushed in reversed order
                        arg     _flags          ; see DS_FL_xxx
                        arg     _param          ; extra parameter (fname/ip)
                        arg     _onewsizeptr    ; ptr to output buffer size
                        arg     _omaxsize       ; output buffer max size
                        arg     _obufptr        ; output buffer offset
                        arg     _isize          ; input buffer size
                        arg     _ibufptr        ; input buffer offset

                        pusha
                        cld

                        mov     eax, _isize     ; calculate approx. output
                        imul    eax, DS_EXPCOEFF; size
                IF      DS_WPL eq 8
                        shr     eax, 1+3
                ELSE
                        cwd
                        push    DS_WPL*2
                        pop     ecx
                        div     ecx
                ENDIF
                        add     eax, 512

                        cmp     _omaxsize, eax  ; check if not enough memory
                        jb      __err_badsize   ; in the output buffer

                        mov     edi, _obufptr   ; begin writing to outbuf

                        mov     al, 'a'         ; 'a'=assemble
                        stosb

                        mov     ecx, _isize     ; input buffer: size
                        cmp     ecx, DS_MAXSIZE ; check error
                        jae     __err_badsize
                        mov     esi, _ibufptr   ; input buffer: offs

__newline:              push    DS_WPL          ; EDX=words per line
                        pop     edx

                        mov     eax, 2077640Dh  ; 13,'dw '
                        stosd

__nextword:             lodsw                   ; get word
                        call    __hexword       ; store in hex form

                        dec     ecx           ; check if all buffer converted
                        dec     ecx
                        jle     __exitcycle

                        dec     edx             ; check if end of line
                        jz      __newline

                        mov     al, ','         ; add ',' before next word
                        stosb

                        jmp     __nextword

__exitcycle:            mov     al, 13          ; 13,13
                        stosb
                        stosb

                        test    _flags, DS_FL_EXECUTE
                        jz      __writefile

__execute:              mov     ax, '=g'        ; 'g=<_param+100h>',13,10
                        stosw
                        mov     eax, _param
                        add     ax, 100h
                        call    __hexword
                        mov     al, 0Dh
                        stosb

                        jmp     __q

__writefile:            mov     esi, _param     ; file name
                        or      esi, esi
                        jz      __q
                        mov     eax, 'xc r'     ; 'r cx' (cx--length of file)
                        stosd
                        mov     al, 13          ; 13
                        stosb
                        mov     eax, _isize     ; <size of file> (max 64k)
                        call    __hexword
                        mov     al, 0Dh
                        stosb
                        mov     ax, ' n'        ; 'n '
                        stosw
__copystr:              lodsb                   ; <filename>
                        stosb
                        or      al, al
                        jnz     __copystr
                        mov     eax, 0D770D0Ah  ; 10,13,'w',13
                        stosd

__q:                    mov     ax, 0D71h       ; 'q',13
                        stosw

                        sub     edi, _obufptr    ; calc & store outbuf size

                        mov     ecx, _onewsizeptr ; dont store if NULL
                        jecxz   __s1
                        mov     [ecx], edi
__s1:

; exit
                        mov     al, DS_ERR_SUCCESS

__exit:                 movzx   eax, al
                        mov     [esp+7*4], eax

                        popa
                        ret

__err_badsize:          mov     al, DS_ERR_BADSIZE
                        jmp     __exit

__hexword:              push    ecx
                        push    4
                        pop     ecx
__hexword_1:            rol     ax, 4
                        push    eax
                        and     al, 15
                        daa
                        add     al, -10h
                        adc     al, '0'+10h
                        stosb
                        pop     eax
                        loop    __hexword_1
                        pop     ecx
                        retn

dscript                 endp

; ---------------------------------------------------------------------------
