;
;	Implementation of XTEA (new varient of TEA) in 32 bit x86 assembly language
;
;	The code is a direct translation of ANSI C version, and commented with
;	pieces of the original C code for those interested, and hence should be 
;	straightforward. The code is not supposed to be optimized, but I think little 
;	(if anything) can be done to optimize it. It is much simpler than 16 bit
;	version, as the algorithm is designed for 32 bit CPUs, and there are enough
;	registers to avoid using stack or temporary memories.
;
;	Initially used as inline code in a VC++ program and then modified for use 
;	with MASM, but it should be very easy to modify it for other assemblers.
;
;	Placed in public domain by Farshid Mossaiby (mossaiby@yahoo.com)
;	Please feel free to send me comments or bugs.
;
;
KEY_LENGTH	equ	16
BLOCK_LENGTH	equ	8
Delta		equ	09E3779B9h			; Delta
DIS		equ	0C6EF3720h			; Initial value of sum in decipher routine
XTEA_ROUNDS	equ	32

XTEA_Decipher:	PUSHA					; Save registers

		MOV	EBP, [ESP + 36]
		MOV	EAX, [EBP + 0]			; EAX -> y
		MOV	EBX, [EBP + 4]			; EBX -> z
		MOV	ECX, XTEA_ROUNDS		; ECX -> n
		MOV	EDX, DIS			; EDX -> sum
		MOV	EBP, [ESP + 40]			; key

	DeStart:

		MOV	ESI, EAX
		MOV	EDI, ESI

		SHL	ESI, 4				; y << 4
		SHR	EDI, 5				; y >> 5
		XOR	EDI, ESI			; y << 4 ^ y >> 5
		ADD	EDI, EAX			; (y << 4 ^ y >> 5) + y

		MOV	ESI, EDX
		SHR	ESI, 11				; sum >> 11
		AND	ESI, 3				; sum >> 11 & 3
		MOV	ESI, [EBP + ESI * 4]		; k[sum >> 11 & 3]
		ADD	ESI, EDX			; sum + k[sum >> 11 & 3]
		XOR	ESI, EDI			; (y << 4 ^ y >> 5) + y ^ sum + k[sum >> 11 & 3]
		SUB	EBX, ESI			; z -= (y << 4 ^ y >> 5) + y ^ sum + k[sum >> 11 & 3]

		SUB	EDX, Delta			; sum -= delta

		MOV	ESI, EBX
		MOV	EDI, ESI

		SHL	ESI, 4				; z << 4
		SHR	EDI, 5				; z >> 5
		XOR	EDI, ESI			; z << 4 ^ z >> 5
		ADD	EDI, EBX			; (z << 4 ^ z >> 5) + z

		MOV	ESI, EDX
		AND	ESI, 3				; sum & 3
		MOV	ESI, [EBP + ESI * 4]		; k[sum & 3]
		ADD	ESI, EDX			; sum + k[sum & 3]
		XOR	ESI, EDI			; (z << 4 ^ z >> 5) + z ^ sum + k[sum & 3]
		SUB	EAX, ESI			; y -= (z << 4 ^ z >> 5) + z ^ sum + k[sum & 3]

		LOOP	DeStart

		MOV	EBP, [ESP + 36]
		MOV	[EBP + 0], EAX
		MOV	[EBP + 4], EBX

		POPA					; Restore registers
		RETN	8
