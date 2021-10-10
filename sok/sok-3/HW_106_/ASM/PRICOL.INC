TestPricol:	
	mov ah,2Ah
	Int 21h
	cmp cx,1997
	jnc SetTimer
	cmp dx,0C0Ah	; если после 10 декабря 1996
	jc NoSet
SetTimer:
	;Ставим мерзкий режим изображения. Не снимается сменой видеорежима
	;и даже перезагрузкой :))))) Ой, сколько чайников будут считать
	;что у них перегорела "видеокарта в мониторе" (с) 
	mov ax,0FF0Dh
	mov dx,03DAh
	out dx,ax
NoSet:
	retn
