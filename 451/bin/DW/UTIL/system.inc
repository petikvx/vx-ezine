include memory.inc


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;Out:	eax=seed
randomize:
		pusha
		xcall GetTickCount
		mov [esp._eax],eax
		popa
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	eax=msecs count
sleep:
		pusha
		push eax
		xcall Sleep
		popa
		ret

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	edx=SYSTEMIME bufer offset
getsystime:
		pusha
		push edx
		xcall GetLocalTime
		popa
		ret
