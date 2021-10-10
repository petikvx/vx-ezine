;=============================================================================
;In:	ecx=count of bytes need
;Out:	eax=memory adress
;	cf=1 if error,else cf=0
getmem:

                        pusha

			push ecx
			push GMEM_FIXED
			xcall GlobalAlloc

			mov [esp._eax],eax		;save id
                        popa
			retn

;=============================================================================
;In:	eax=memory adress 
freemem:
                        pusha

                        push eax
			xcall GlobalFree

			popa
			retn
