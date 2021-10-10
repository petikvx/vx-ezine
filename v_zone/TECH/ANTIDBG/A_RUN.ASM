;Вот это вещь! Это собственно не антитрассировочный прием, но штучка полезная
;для  вирмакера.  Трассируя  эту  штуку  (неаккуратно)  вы  просто запускаете
;остальную программу (вирус)!

.model tiny
.code
	org 100h
start:
	mov cx,1000
a_trace_loop:
	dec word ptr cs:[a_trace]
	loop a_trace_loop		;Эти две строчки дожны быть
a_trace dw 9090h+1000			;обязательно вместе!

wow:
	mov ax,cs
	mov ds,ax
	mov dx,offset all_ok
	mov ah,9
	int 21h
	xor ax,ax
	int 16h
	ret
all_ok	db 0dh,0ah,'Auto-running pattern by CyberShadow...',0dh,0ah
	db 'Try to trace it under TurboDebugger...',7,'$'
end start