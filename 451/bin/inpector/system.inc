include memory.inc

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;Out:	eax=seed
randomize:
		pusha
		kernelCall GetTickCount
		mov [esp._eax],eax
		popa
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;Out:	eax=dll's address
load_library:
		pusha
		push eax
		kernelCall LoadLibraryA
		mov [esp._eax],eax
		popa
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	edx=DLL address
;	eax=function address

;Out:	eax=function address
get_proc_addr:
		pusha
		push eax
		push edx
		kernelCall GetProcAddress
		mov [esp._eax],eax
		popa
		ret


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;Out:	eax = module handle
get_module_handle:
		pusha
		push 0
		kernelCall GetModuleHandleA
		mov [esp._eax],eax
		popa
		ret

