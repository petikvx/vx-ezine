;����஢騪 䠩�� TST20.COM
;(C) 1999 bY B!Z0n //[BzZ].

model tiny
                org  100h

.code
.startup

crstart         equ     263h

                lea     dx,file
                mov     ax,3d02h
                int     21h                     ;���뢠�� 䠩� �� �⥭��\������
                jc      exit
                xchg    bx,ax

                mov     cx,-1
                mov     ah,3fh
                int     21h                     ;�⠥� ��� 楫���� � ������
                push    ax dx                   ;AX=����� 䠩��

                lea     si, file
                add     si, crstart
                mov     di, si
                mov     cx, ax
                sub     cx, crstart
                shr     cx, 1
                or      cx, 1
                in      ax, 40h
                xchg    dx, ax
crypt:
                lodsw
                xor     ax, dx
                stosw
                loop    crypt

                xor     dx, dx
                mov     ax,4200h
                int     21h                     ;㪠��⥫� �� ��砫� 䠩��

                pop     dx cx
                mov     ah,40h

                int     21h                     ;��襬 ������஢���� ���⮪
                mov     ah,3eh
                int     21h                     ;����뢠�� 䠩�
exit:           mov     ax,4c00h                ;��室
                int     21h

file            db      'tst20.com',0           ;��� 䠩��

                end
