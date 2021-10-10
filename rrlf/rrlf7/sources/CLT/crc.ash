;= CRC Instruction Set (c) 2006 JPanic ====================================
;
; These routines use the CRC32 standard algorithm, with the exception that
; they DO NOT invert (bitwise negate) the final CRC, to save on a
; redundant instruction. If you want the true instruction, use 'NOT crc'
; and add a 'not eax' to the code.
;
; Note: Tasm doesnt support '!' in ascii strings so you got to addcrc 21h
;
; Provides macros to emulate CRC32 instructions:
;
;	initcrc	- Initialise crc with CRC32 initial value.
;	addcrc	- Add a byte list to the CRC32 value in crc.
;	addcrca	- Add an ascii string (but no terminating 0) to crc.
;	lcrc	- Initialise crc,  then add a byte list to crc.
;	lcrca	- Initialise crc,  then add an ascii string (no 0) to crc.
;	lcrcaz  - Same as lcrca, but adds a terminating 0.
;
; Examples:
;	('crc' can be used where an 32-bit immediate would be.)
;	(All these examples do the same thing, except the ASCIIZ one.)
;
;	;-ADDCRC-----------------------------------------------------------
;	initcrc
;	addcrc	<'1','2','3','4','5','6','7','8','9','0'>
;	cmp	eax,crc
;
;	;-ADDCRCA----------------------------------------------------------
;	initcrc
;	addcrca	12345
;	addcrca 67890
;	cmp	eax,1234h
;	org	$-4
;	dd	crc
;
;	;-LCRC-------------------------------------------------------------
;	lcrc	<31h,32h,33h,34h,35h,36h,37h,38h,39h,30h>
;	cmp	eax,crc
;
;	;-LCRCA------------------------------------------------------------
;	lcrca	1234567890
;	cmp	eax,crc
;
;	;-A mixed example--------------------------------------------------
;	lcrc	<31h,32h,33h>
;	addcrca	45
;	addcrc	<'6','7','8'>
;	addcrc	<39h,30h>
;	cmp	eax,crc
;
;	;-ASCIIZ strings---------------------------------------------------
;	lcrcaz	<Hello World>
;	HelloWorldCRC	dd	crc
;
;- Procedure Definitions --------------------------------------------------
.model flat
.486

IFNDEF	_CRC_ASM
	extrn GetCRC32:PROC
	extrn GetCRC32az:PROC
ENDIF	;_CRC_ASM

;- CRC VALUES -------------------------------------------------------------

crc = 0

CRC_INIT = 0FFFFFFFFh
CRC_POLY = 0EDB88320h

;= CRC INSTRUCTIONS =======================================================
	
;- initcrc ----------------------------------------------------------------
	initcrc	MACRO

		crc = CRC_INIT

	ENDM

;- addcrc -----------------------------------------------------------------
	addcrc MACRO data

		.xlist
		LOCAL dbyte
		
		IRP dbyte, <data>
			crc = (&dbyte& AND 0FFh) XOR crc
			REPT 8
				crc = (crc SHR 1) XOR (CRC_POLY * (crc AND 1))
			ENDM
		ENDM
		.list
	ENDM

;- addcrca ----------------------------------------------------------------	
	addcrca MACRO data

		.xlist
		LOCAL dbyte

		IRPC dbyte, <data>
			crc = ('&dbyte&' AND 0FFh) XOR crc
			REPT 8
				crc = (crc SHR 1) XOR (CRC_POLY * (crc AND 1))
			ENDM
		ENDM
		.list
	ENDM

;- lcrc -------------------------------------------------------------------
	lcrc MACRO data

		initcrc
		addcrc	<data>

	ENDM

;- lcrca ------------------------------------------------------------------
	lcrca MACRO data

		initcrc
		addcrca	<data>

	ENDM

;- lcrcaz -----------------------------------------------------------------
	lcrcaz MACRO data

		lcrca	<data>
		addcrc	0

	ENDM

;= END FILE ===============================================================	
