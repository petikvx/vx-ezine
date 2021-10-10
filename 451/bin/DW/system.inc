include memory.inc
include ipc.inc


;�����������������������������������������������������������������������������
;Out:	eax=seed
randomize:
		pusha
		kernelCall GetTickCount
		mov [esp._eax],eax
		popa
		ret

;�����������������������������������������������������������������������������
;In:	eax=msecs count
sleep:
		pusha
		push eax
		kernelCall Sleep
		popa
		ret

;�����������������������������������������������������������������������������
;In:	edx=SYSTEMIME bufer offset
getsystime:
		pusha
		push edx
		kernelCall GetLocalTime
		popa
		ret