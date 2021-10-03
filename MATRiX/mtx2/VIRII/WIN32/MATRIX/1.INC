CRC32_init	equ 0EDB88320h
CRC32_num       equ 0FFFFFFFFh   

CRC32	macro	string
	    crcReg = CRC32_num
	    irpc    _x,<string>
		ctrlByte = '&_x&' xor (crcReg and 0FFh)
		crcReg = crcReg shr 8
		rept 8
		    ctrlByte = (ctrlByte shr 1) xor (CRC32_init * (ctrlByte and 1))
		endm
		crcReg = crcReg xor ctrlByte
	    endm
	    dd	crcReg
endm

import_beg macro kernel
           db '&kernel&',0
           endm
import_nam macro name
           CRC32 &name&
           local b
           b=0
           irpc a,<name>
               IF b EQ 0 
                  db '&a&'
               ENDIF
               b=b+1
           endm
&name&     dd    0       
           endm 
import_end macro 
           db 0
           endm