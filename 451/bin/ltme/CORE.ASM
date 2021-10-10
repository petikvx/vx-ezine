include src\1.ash
include src\ldizx.ash
include list.ash
include ltme.ash

include src\opz.ash

__SIGN1		equ	'SBGN'
__SIGN2		equ	'SEND'

	.586p
	.model flat
	.code
_start:
	ret
	
db __SIGN1
	include src\core.inc
db __SIGN2
end	_start
