
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;VOID* MALLOC (DWORD bytes_count);
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
malloc:
		pusha

		mov eax,[esp+8*4+4]
		push eax
		push GMEM_FIXED
		KernelCall GlobalAlloc

		jmp std_exit


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;FREE  (VOID* bufer);
;IN:	EAX=bufer
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
free:
		pusha

		mov eax,[esp+8*4+4]
		push eax
		KernelCall GlobalFree
std_exit:		
		mov [esp._eax],eax
		popa
		ret