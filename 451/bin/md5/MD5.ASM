
;
; MD5 Hashing algorithm
; Gets 128-bit hash from bufer
;

include klimport.ash
include macros.ash
includelib	import32.lib

        .586p
        .model flat
        .data

md5_data:


md5_sin:

	dd	0D76AA478h,0E8C7B756h,0242070DBh,0C1BDCEEEh
	dd	0F57C0FAFh,04787C62Ah,0A8304613h,0FD469501h
	dd	0698098D8h,08B44F7AFh,0FFFF5BB1h,0895CD7BEh
	dd	06B901122h,0FD987193h,0A679438Eh,049B40821h

	dd	0F61E2562h,0C040B340h,0265E5A51h,0E9B6C7AAh
	dd	0D62F105Dh,002441453h,0D8A1E681h,0E7D3FBC8h
	dd	021E1CDE6h,0C33707D6h,0F4D50D87h,0455A14EDh
	dd	0A9E3E905h,0FCEFA3F8h,0676F02D9h,08D2A4C8Ah

	dd	0FFFA3942h,08771F681h,06D9D6122h,0FDE5380Ch
	dd	0A4BEEA44h,04BDECFA9h,0F6BB4B60h,0BEBFBC70h
	dd	0289B7EC6h,0EAA127FAh,0D4EF3085h,004881D05h
	dd	0D9D4D039h,0E6DB99E5h,01FA27CF8h,0C4AC5665h

	dd	0F4292244h,0432AFF97h,0AB9423A7h,0FC93A039h
	dd	0655B59C3h,08F0CCC92h,0FFEFF47Dh,085845DD1h
	dd	06FA87E4Fh,0FE2CE6E0h,0A3014314h,04E0811A1h
	dd 	0F7537E82h,0BD3AF235h,02AD7D2BBh,0EB86D391h

md5_k:
	db 	00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15
	db	01,06,11,00,05,10,15,04,09,14,03,08,13,02,07,12
	db	05,08,11,14,01,04,07,10,13,00,03,06,09,12,15,02
	db	00,07,14,05,12,03,10,01,08,15,06,13,04,11,02,09

md5_s:
	db	07,12,17,22,07,12,17,22,07,12,17,22,07,12,17,22
	db	05,09,14,20,05,09,14,20,05,09,14,20,05,09,14,20
	db	04,11,16,23,04,11,16,23,04,11,16,23,04,11,16,23
	db	06,10,15,21,06,10,15,21,06,10,15,21,06,10,15,21

message 	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' 
xlen	= $ -offset message

buf		db xlen+128 dup ('c')
md		db 16 dup  (0)

   	.code
_start:

        int 3

	mov ebp,offset md5_data
        mov esi,offset message
	mov edi,offset md
	mov edx,offset buf
	mov ecx,xlen
	call MD5

        push 0
        xcall ExitProcess

@mdd		equ	<-offset md5_data>

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
;In:    ECX = message length (bytes)
;       ESI = message offset
;       EDI = MD5 bufer (128 bits/16 bytes)
;       EDX = bufer (message length+64+64)
;	EBP = MD5 tables

MD5:
        pusha

	lea ebx,[ecx*8]
        push edi

	push ecx
	mov edi,edx
	rep movsb	
	pop ecx

;� EXPAND to 448/8 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

        mov al,80h
        stosb

md5_expand:
        inc ecx

        mov eax,ecx
        and eax,3Fh                                     ;512/8

        cmp al,56                                       ;448/8
        je md5_expand_end

        xor eax,eax
        stosb
        jmp md5_expand

md5_expand_end:

	mov eax,ebx
	stosd
	xor eax,eax
	stosd

	add ecx,8

;-----------------------------------------------------------------------------

	mov esi,edx
	mov edi,ecx					; blocks count
	shr edi,6                                       ;

	mov eax,067452301h
	mov ebx,0EFCDAB89h
        mov ecx,098BADCFEh
        mov edx,010325476h

md5_main:

	push edi   					; size
	push ebp

	mov edi,ebp					; EDI = MD5 tables
	xor ebp,ebp

	push eax
	push ebx
	push ecx
	push edx

	pusho I
	pusho H
	pusho G
	pusho F

md5_1234:
	push ebp
	push esi

	xchg esi,eax                                    ;
	shr ebp,4					; /16
	call 4 ptr[esp+ebp*4+4*2]			; a+F/G/H/I
	add eax,esi                                     ;

	pop esi
	pop ebp
	
	push ecx
	movzx ecx,1 ptr[edi+offset md5_k @mdd+ebp]	; + X[k]
	add eax,4 ptr[esi+ecx*4]			;
	add eax,[edi+offset md5_sin @mdd+ebp*4]		; + T[i]

	mov cl,1 ptr[edi+offset md5_s @mdd +ebp]        ; << s
	rol eax,cl	                                ; 
	pop ecx

	add eax,ebx					; + b

	xchg edx,ecx                                    ;
	xchg ecx,ebx                                    ; next position
	xchg eax,ebx					;

	inc ebp
	cmp ebp,64
        jne md5_1234

	add eax,[esp+12+4*4]				; A += AA
	add ebx,[esp+8+4*4]                             ; B += BB
	add ecx,[esp+4+4*4]                             ; C += CC
	add edx,[esp+4*4]                               ; D += DD

        add esp,(4*4)*2
	add esi,16*4

	pop ebp
	pop edi
	dec edi
	jnz md5_main
	pop edi

	stosd
	xchg eax,ebx
	stosd
	xchg eax,ecx
	stosd
	xchg eax,edx
	stosd

        popa
        ret

; A = EAX
; B = EBX
; C = ECX
; D = EDX

X	equ	<ebx>
Y	equ	<ecx>
Z	equ	<edx>


;-----------------------------------------------------------------------------
;in:	X = ebx
;	Y = ecx
;	Z = edx
;out:	EAX = result
F:
	push X

	mov eax,X					; X & Y             
	not eax                                         ;
	and eax,Z                                       ; ~X & Z            
	and X,Y                                         ; (X & Y) | (~X & Z)
	or eax,X

	pop X
	ret

;-----------------------------------------------------------------------------
;in:	X = ebx
;	Y = ecx
;	Z = edx
;out:	EAX = result


G:
	push Z

	mov eax,Z                                       ;
	not eax   					;
	and eax,Y	                                ;
	and Z,X						;
	or  eax,Z                                       ; (X & Z) | (~Z & Y)

	pop Z                                                          
	ret

;-----------------------------------------------------------------------------
;in:	X = ebx
;	Y = ecx
;	Z = edx
;out:	EAX = result
H:
	mov eax,X
	xor eax,Y					; X xor Y xor Z
	xor eax,Z					;
	ret

                  	
;-----------------------------------------------------------------------------
;in:	X = ebx
;	Y = ecx
;	Z = edx
;out:	EAX = result
I:
	mov eax,Z   	                                ;  Y xor (X or ~Z)
	not eax                                         ;
	or eax,X                                        ;
	xor eax,Y					;
	ret

end _start
