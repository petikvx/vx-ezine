
opzmov	macro	reg,val

	if val eq 0
		xor reg,reg
		exitm
	endif

	if val eq 0FFFFFFFFh
		xor reg,reg
		dec reg
		exitm
	endif


        if val lt 80h
		push val
	    	pop reg		
		exitm
	else
	
		if val lt 100h

				ifidn <reg>,<eax>
					xor eax,eax
					mov al,val
					exitm
				endif		

				ifidn <reg>,<ebx>
					xor ebx,ebx
					mov bl,val
					exitm
				endif		

				ifidn <reg>,<ecx>
					xor ecx,ecx
					mov cl,val
					exitm
				endif		

				ifidn <reg>,<edx>
					xor edx,edx
					mov dl,val
					exitm
				endif		
		else
				mov reg,val
				exitm
		endif		

	endif
	

	endm


;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北


opzcmp	macro	reg,val

	if val eq 0
		or reg,reg
		exitm

	else
		cmp reg,val
		exitm
	endif

	endm
