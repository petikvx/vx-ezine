;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
;
;  LTME mutator
;
;  2002 (c) 451
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

include src\keys.ash

include list.ash
include ltme.ash
include src\mutator\opcodes.ash

include src\1.ash
include src\opz.ash
include src\macros.ash

@d		equ		<+8*4+4>

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

m__free		equ	4 ptr [ebp+32 @d]
m__malloc	equ	4 ptr [ebp+28 @d]
m__seed		equ	4 ptr [ebp+24 @d]
m__rnd		equ	4 ptr [ebp+20 @d]
m__params	equ	4 ptr [ebp+16 @d]
m__flags	equ	4 ptr [ebp+12 @d]
m__plast_label	equ	4 ptr [ebp+8  @d]
m__list		equ 	4 ptr [ebp+4  @d]
m__size  	equ     4 ptr [ebp+   @d]

;-----------------------------------------------------------------------------
m__temp		equ	[ebp-SIZE ltmedata]

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
mutator:
		pusha

		mov ebp,esp
		ntsub <SIZE ltmedata>

		mov ebx,m__list

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		test m__flags,LTMEF_LSWAP
		jz mutator__2

		include src\mutator\xchg.inc
;-----------------------------------------------------------------------------
mutator__2:
		test m__flags,LTMEF_JCC
		jz mutator__3

		include src\mutator\jmp_mut.inc
;-----------------------------------------------------------------------------
mutator__3:
		test m__flags,LTMEF_GARBAGE
		jz mutator__4

		include src\mutator\garbage.inc
;-----------------------------------------------------------------------------
mutator__4:
		test m__flags,LTMEF_CMD
		jz mutator__5

		include src\mutator\cmdm.inc
;-----------------------------------------------------------------------------
mutator__5:
		test m__flags,LTMEF_PSWAP
		jz mutator__exit

		include src\mutator\mixing.inc
;-----------------------------------------------------------------------------
mutator__exit:

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

		ntadd <SIZE ltmedata>
		popa
		ret

include src\mutator\list.inc
include src\mutator\add.inc