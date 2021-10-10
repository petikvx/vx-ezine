.586
.model flat

VRPC_SERV_PORT		=		0E903h ; 1001

.data

include vrpc.inc

serv_msg			db		'VRPC is running', 0

; хендл нитки сервера, если надо то по нему его можно кильнуть
vrpc_serv			dd					?

.code

main:
	mov		EAX, offset vrpc_serv
	mov		EBX, VRPC_SERV_PORT
	call	VRPC_RunServer
	
	push	0
	push	offset serv_msg
	push	offset serv_msg
	push	0
	api		MessageBoxA, LIB_USER
	
	api		ExitProcess, LIB_KERN
	ret
end main