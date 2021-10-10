include src\1.ash
include src\pe.ash

include src\ldizx.ash
include getd.ash


SIGN1			equ	'SBGN'
SIGN2			equ	'SEND'
	.586p
	.model flat
	.data
	.code
_start:
	ret
	
db SIGN1
	include src\getd.asm
db SIGN2
end	_start
