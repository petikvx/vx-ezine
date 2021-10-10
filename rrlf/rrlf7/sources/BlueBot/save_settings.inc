; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Save settings

save_settings:	pushad
		lea	esi, [connectsettings]
		xor	eax, eax
.size:		inc	eax
		cmp	byte [esi+eax-1], 0
		jnz	.size
		invoke	RegSetValueEx,[inithandle],0,0,REG_SZ,esi,eax
		popad
		ret