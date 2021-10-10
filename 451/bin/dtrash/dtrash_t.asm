include dtrash.ash

SIGN1			equ	'SBGN'
SIGN2			equ	'SEND'

	.586p
	.model flat
	.data
	.code
_start:
	ret

db SIGN1	
	include src\dtrash_data.asm
db SIGN2

end	_start
