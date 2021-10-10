; Fast Random-Number generator
;  (PC version by J/SOFT '96)
;
;IN:	r1,r2,r3 - key to set the random sequence  (default: 5,90,37)
;OUT:	al = random number (0..255)
;DESTROYS:	AX

rnd	mov ax,[r2]
	mov [r1],al
	add ah,al
	mov al,[r3]
	mov [r2],al
	add al,ah
	rol al
	mov [r3],al
	retn

r3	db 37
r2	db 90
r1	db 5

