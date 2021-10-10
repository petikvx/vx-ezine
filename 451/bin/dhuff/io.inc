include io.ash

xcall 		macro	x
			extrn  x:near
			call x
		endm


;------------------------------------------------------------------------------
;in:		edx=filename
;out		eax=handle
fopen  proc

       		pushad

       		xor ebx,ebx

       		push ebx
       		push FILE_ATTRIBUTE_NORMAL
       		push OPEN_EXISTING
       		push ebx
       		push FILE_SHARE_READ + FILE_SHARE_WRITE
       		push GENERIC_READ + GENERIC_WRITE
       		push edx
       		xcall CreateFileA

       		inc eax                 		;eax=-1?
       		jz fopen_exit
       		dec eax

fopen_exit:

       		mov [esp._eax], eax
       		popad
       		retn
fopen  endp


;------------------------------------------------------------------------------
;in  : ebx=handle
;out : eax=file image

f_createmap  proc
	       	pusha

	       	xor eax,eax
	      	push eax			    	;for mapvievoffile

       		push eax			    	;name
      	 	push eax                     		;lowsize
       		push eax                     		;highsize
       		push PAGE_READWRITE
       		push eax
       		push ebx
       		xcall CreateFileMappingA

       		xchg ebx,eax

  		pop eax			    		;null
		push eax			    	;count bytes
       		push eax                     		;lowsize
       		push eax                     		;highsize
       		push 2;FILE_MAP_ALL_ACCESS	
       		push ebx
       		xcall MapViewOfFile

       		jmp short fopen_exit	
f_createmap  endp 



;------------------------------------------------------------------------------
;in:eax=mapiing image
f_closemap  proc
      		pusha
       		push eax
       		xcall UnmapViewOfFile
	       	popa
       		retn
f_closemap  endp


;------------------------------------------------------------------------------
;in:ebx=handle
fclose proc

       		pushad

       		push ebx
       		xcall CloseHandle

       		popad
       		retn
fclose endp



;------------------------------------------------------------------------------
;in	:	ebx=handle
;      	  	ecx=bytes count 
fseek  proc

       		pushad

       		push FILE_BEGIN
       		push 0
       		push ecx
       		push ebx
       		xcall SetFilePointer

       		popad
       		retn
fseek  endp



;------------------------------------------------------------------------------
;in:		ebx=handle
;      		ecx=bytes count
;      		edx=bufer
fwrite  proc

       		pushad

       		push eax
		mov eax,esp
       		push 0


		push eax				       			;push 4 ptr [ebp+offset bytesread @ex]
	       	push ecx
	       	push edx

       		push ebx
	       	xcall WriteFile

	 	jmp short _clear_exit
fwrite  endp

;------------------------------------------------------------------------------
;in:		ebx=handle file
;      		ecx=count of bytes to read
;      		edx=offset of bufer
fread  proc

	       	pushad

	       	push eax
	       	mov eax,esp				;save for bytesRead	

	       	push 0
      	
	       	push eax				;bytes read
	       	push ecx
	       	push edx
	       	push ebx
	       	xcall ReadFile

_clear_exit:

	       	pop ebp					;clear stack
	       	popad
	       	retn                                    ;& return
fread  endp


;------------------------------------------------------------------------------
;in:		ebx=handle
;out		eax=file size
fsize 	proc
		pusha

		push 0
		push ebx
		xcall GetFileSize

		mov [esp._eax],eax
		popa
		retn
fsize  	endp


;------------------------------------------------------------------------------
;in:		ebx=handle
set_EOF 	proc
		pusha
		push ebx
		xcall SetEndOfFile
		popa
		retn
set_EOF 	endp


;------------------------------------------------------------------------------
;in:		edx=name
;out:		eax=handle
fcreate		proc
		pusha

		push 0
		push edx
		xcall  _lcreat

		mov [esp._eax],eax

		popa
		retn
fcreate         endp
