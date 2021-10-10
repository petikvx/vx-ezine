include src\1.ash
include src\ldizx.ash
include list.ash
include ltme.ash

include src\opz.ash

__MSIGN1	equ	'SBGN'
__MSIGN2	equ	'SEND'

	.586p
	.model flat
	.code

_start:
	ret

db __MSIGN1
	include src\mutator.inc
db __MSIGN2

end	_start
