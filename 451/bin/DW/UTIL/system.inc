include memory.inc


;�����������������������������������������������������������������������������
;Out:	eax=seed
randomize:
		pusha
		xcall GetTickCount
		mov [esp._eax],eax
		popa
		ret

;�����������������������������������������������������������������������������
;In:	eax=msecs count
sleep:
		pusha
		push eax
		xcall Sleep
		popa
		ret

;�����������������������������������������������������������������������������
;In:	edx=SYSTEMIME bufer offset
getsystime:
		pusha
		push edx
		xcall GetLocalTime
		popa
		ret