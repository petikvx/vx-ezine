;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	EDX= atom name offset
;Out:	EAX=atom id
addatom:
		pusha
		push edx
		kernelCall GlobalAddAtomA
		jmp ipc_exit

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	EAX = atom id
killatom:
		pusha
		push eax
		kernelCall GlobalDeleteAtom
		popa
		ret		

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	EDX = atom name offset
;Out:	ZF=1 if atom not finded
findatom:
		pusha
		push edx
		kernelCall GlobalFindAtomA

		or eax,eax
ipc_exit:
		mov [esp._eax],eax
		popa
		ret		
