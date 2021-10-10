include klimport.ash
include macros.ash

includelib import32.lib

        .586p
        .model flat
        .data

include deal_des_data.inc

	 dd 2   dup (0)					; need condition
KDL1     dd 6*2 dup (0) 				; DEAL keys bufer

key	db '1234567890ABCDEF'
_data	db 'abcdefghiklmnopq'

undata	db 128/8 dup (0)
data2	db 128/8 dup (0)

        .code
_start:
        int 3

	mov esi,offset key
	mov edi,offset KDL1
	mov ebp,offset DES_tables
	call DEALinit

	mov esi,offset _data
	mov edi,offset KDL1
	mov ebp,offset DES_tables
	mov ebx,offset undata
	call DEALencrypt

	mov esi,offset undata
	mov edi,offset KDL1
	mov ebp,offset DES_tables
	mov ebx,offset data2
	call DEALdecrypt

        push 0
        xcall ExitProcess

;께 DEAL Init 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�
;In:	ESI = 128 bit DEAL key offset
;       EBP = DES tables
;       EDI = 6 DES keys bufer
;
DEALinit:
	pusha
	sub esp,16*8					; DES subkeys
	mov ebx,edi
	mov edi,esp

	mov edx,0FEDCBA09h                              ;
	mov eax,087654321h				; *K=1234567890ABCDEF
	call DESinit					; 

	xchg ebx,edi
	mov ecx,6
deal_rkeys:
	push esi

	test cl,1
	jz deal_rkeys_0					; K1

	lodsd						; K2
	lodsd                                           ;

deal_rkeys_0:

	lodsd                                           ;
	xchg eax,edx					; DES K1/K2 = DEAL key
	lodsd                                           ;
	xchg eax,edx                                    ;
	
	push edi

	xor eax,[edi-8]					; XOR RK(n-1)
	xor edx,[edi-4]                                 ;
	                                                ;
	mov edi,16	                                ; EDI= 0/0/1/2/4/8
	shr edi,cl					;
	xor eax,edi

	mov edi,ebx
	call DESencrypt
	pop edi

	stosd	
	xchg eax,edx
	stosd

	pop esi
	loop deal_rkeys

	add esp,16*8
	popa
	ret

;께 DEAL Encrypt 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;In:	ESI = Data block
;       EBP = DES tables
;       EDI = 6 DES keys bufer
;       EBX = Out data block
DEALencrypt:
	pusha
	sub esp,(16*8)*6
	mov eax,esp

	push esi

	mov esi,edi
	mov edi,eax
	push edi

	mov ecx,6
deal_e_keys:
	lodsd
	xchg eax,edx
	lodsd
	xchg eax,edx
	call DESinit
	add edi,16*8
	loop deal_e_keys

	pop edi
	pop esi

	push ebx
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

	lodsd                                           ;
	xchg eax,ebx                                    ; ECX:EBX = Right part
	lodsd                                           ;
	xchg eax,ecx					;

	lodsd						; EDX:EAX = Left part
	xchg eax,edx                                    ;
	lodsd                                           ;
	xchg eax,edx                                    ;

	mov esi,ecx					; ESI:EBX = Right part
	mov ecx,6
deal_e:

	push edx
	push eax

	; EDX:EAX = L
	call DESencrypt
		
	; EDX:EAX = E(L)
	xor edx,esi
	xor eax,ebx
	
	pop ebx
	pop esi

	add edi,16*8					; next key
	loop deal_e

	xchg eax,ebx
	xchg edx,esi

	pop edi						; out bufer

	add edi,8					;
	stosd                                           ;
	xchg eax,edx                                    ;
	stosd                                           ;
	sub edi,16                                      ; Write result
	xchg eax,ebx                                    ;
	stosd                                           ;
	xchg eax,esi                                    ;
	stosd                                           ;

	add esp,(16*8)*6
	popa
	ret

;께 DEAL Decrypt 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;In:	ESI = Encrypted data block
;       EBP = DES tables
;       EDI = 6 DES keys bufer
;       EBX = Out data block
DEALdecrypt:
	pusha
	sub esp,(16*8)*6
	mov eax,esp

	push esi

	mov esi,edi
	mov edi,eax

	mov ecx,6
deal_d_keys:
	lodsd
	xchg eax,edx
	lodsd
	xchg eax,edx
	call DESinit
	add edi,16*8
	loop deal_d_keys
	pop esi

	push ebx
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

	lodsd                                           ;
	xchg eax,ebx                                    ; ECX:EBX = Right part
	lodsd                                           ;
	xchg eax,ecx					;

	lodsd						; EDX:EAX = Left part
	xchg eax,edx                                    ;
	lodsd                                           ;
	xchg eax,edx                                    ;

	mov esi,ecx					; ESI:EBX = Right part
	mov ecx,6
	sub edi,16*8
deal_d:

	push edx
	push eax

	; EDX:EAX = L
	call DESencrypt
	; EDX:EAX = E(L)
	xor edx,esi
	xor eax,ebx

	pop ebx
	pop esi

	sub edi,16*8					; next key
	loop deal_d

	xchg eax,ebx
	xchg edx,esi
	
	pop edi						; out bufer

	add edi,8					;
	stosd                                           ;
	xchg eax,edx                                    ;
	stosd                                           ;
	sub edi,16                                      ; Write result
	xchg eax,ebx                                    ;
	stosd                                           ;
	xchg eax,esi                                    ;
	stosd                                           ;

	add esp,(16*8)*6
	popa
	ret

include deal_des.inc
end _start