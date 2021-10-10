BLOCK_LENGTH	equ	8
KEY_LENGTH	equ	8                               ; bytes = 64 bits

; (*key, S, P)
blowfish_init:
	pusha
	mov	edx, [esp + 36]	;key
	mov	esi, [esp + 40]	;S
		push	4096
		push	dword [edx]
		push	esi
		call	mk_key	
	mov	edi, [esp + 44]	;P
		push	72
		push	dword [edx]
		push	edi
		call	mk_key
	call	BlowfishInit
	popa
	retn	12
; (*data, S, P)
blowfish_encipher:
	pusha
	mov	ebp, [esp + 36]
	mov	eax, [ebp + 0]
	mov	edx, [ebp + 4]
	mov	esi, [esp + 40]	; S
	mov	edi, [esp + 44]	; P
	call	BlowfishEncrypt
	mov	[ebp + 0], eax
	mov	[ebp + 4], edx
	popa
	retn	12
; (*data, S, P)
blowfish_decipher:
	pusha
	mov	ebp, [esp + 36]
	mov	eax, [ebp + 0]
	mov	edx, [ebp + 4]
	mov	esi, [esp + 40]	; S
	mov	edi, [esp + 44]	; P
	call	BlowfishDecrypt
	mov	[ebp + 0], eax
	mov	[ebp + 4], edx
	popa
	retn	12


%macro feistel 0

        xor eax,[edi]                                   ; xL=xL xor P[i]

        push eax
        push edx

        mov edx,eax

        movzx eax,dl                                    ;
        mov ebx,[(esi+256*0)+eax]                       ; +S1,a

        movzx eax,dh                                    ;
        add ebx,[(esi+256*1)+eax]                       ; +S2,b

        shr edx,16
        movzx eax,dl                                    ; XOR S1,c
        xor ebx,[(esi+256*2)+eax]                       ;

        movzx eax,dh                                    ; + S4,d
        add ebx,[(esi+256*3)+eax]                       ;

        pop edx
        pop eax

        ; EBX = F(xL)

        xor edx,ebx                                     ; xR=xR XOR F(xL)
        xchg eax,edx

%endmacro


;² INIT    ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;
;In:    EDI=P table
;       ESI=S table
;       EDX=Key
;

BlowfishInit:
        pusha

;--[random P XOR P]----------------------------------------------------------
        push edi
        push esi

        mov ecx,18
        xor ebx,ebx                                     ; key delta
        mov esi,edi
init_P:
        lodsd
        xor eax,[edx+ebx]                               ; XOR key part
        stosd

        add ebx,4
        cmp ebx,KEY_LENGTH
	jne init_P_next

        xor ebx,ebx

init_P_next:
        loop init_P

        pop esi
        pop edi
;---------------------------------------------------------------------------

        xor eax,eax                                     ; EAX=EDX=0
        cdq                                             ;

        mov ecx,18/2
        xor ebx,ebx

encrypt_P:
        call BlowfishEncrypt
        mov [edi+ebx],eax                               ; P[i]=Low
        mov [edi+ebx+4],edx                             ; P[i+1]=High

        add ebx,8
        loop encrypt_P

;---------------------------------------------------------------------------

        mov ecx,4
        xor ebx,ebx                                     ; S delta

encrypt_S4:
        xor eax,eax                                     ; EAX=EDX=0
        cdq                                             ;

        push ecx
        mov ecx,256/2
;---------------------------------------------------------------------------
encrypt_S256:

        call BlowfishEncrypt
        mov [esi+ebx],eax
        mov [esi+ebx+4],edx

        add ebx,8
        loop encrypt_S256

;---------------------------------------------------------------------------
        pop ecx
        loop encrypt_S4


        popa
        ret

;² ENCRYPT ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:    EAX=Low
;       EDX=High
;       ESI=S
;       EDI=P
;Out:   EAX=Encrypted Low
;       EDX=Encrypted High
BlowfishEncrypt:
        push ecx
        push ebx
        push edi

        mov ecx,16

feistel_e:

        feistel

        add edi,4
        loop feistel_e

        xchg eax,edx

        xor edx,[edi]                                   ; xR=xR XOR P[17]
        xor eax,[edi+4]                                 ; xL=xL XOR P[18]

        pop edi
        pop ebx
        pop ecx
        ret


;² DECRYPT ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;In:    EAX=Low
;       EDX=High
;       ESI=S
;       EDI=P
;Out:   EAX=Encrypted Low
;       EDX=Encrypted High
BlowfishDecrypt:
        push ecx
        push ebx
        push edi


        add edi,17*4
        mov ecx,16

feistel_d:

        feistel                                        ; Fiestel

        sub edi,4
        loop feistel_d

        xchg eax,edx

        xor edx,[edi]                                   ; xR=xR XOR P[2]
        xor eax,[edi-4]                                 ; xL=xL XOR P[1]

        pop edi
        pop ebx
        pop ecx
        ret
