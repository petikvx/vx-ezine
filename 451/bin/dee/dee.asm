
__SIGN1		equ	"SBGN"
__SIGN2		equ	"SEND"

	.386
	.model flat
	.data
	.code
_start:
	ret
	
db __SIGN1
	include src\dee.inc
db __SIGN2

end	_start
