
FILE_BEGIN           		equ		0
FILE_CURRENT         		equ		1
FILE_END             		equ		2

OF_READWRITE   			equ 		00000002h

GMEM_FIXED			EQU		000000000h
GMEM_MOVEABLE			EQU		000000002h
GMEM_ZEROINIT			EQU		000000040h
GMEM_MODIFY			EQU		000000080h
GMEM_SHARE			EQU		000002000h
GMEM_DDESHARE			EQU		000002000h
GMEM_NOTIFY			EQU		000004000h
GMEM_INVALID_HANDLE		EQU		000008000h

CREATE_NEW			EQU		00000001h
CREATE_ALWAYS			EQU		00000002h
OPEN_EXISTING			EQU		00000003h
OPEN_ALWAYS			EQU		00000004h
TRUNCATE_EXISTING		EQU		00000005h

STD_OUTPUT_HANDLE		equ		-11
STD_INPUT_HANDLE    		equ		-10

FILE_SHARE_READ                 equ 		00000001h
FILE_SHARE_WRITE                equ 		00000002h  

GENERIC_READ                    equ 		80000000h
GENERIC_WRITE                   equ 		40000000h

FILE_ATTRIBUTE_READONLY         equ 		00000001h  
FILE_ATTRIBUTE_HIDDEN           equ 		00000002h  
FILE_ATTRIBUTE_SYSTEM           equ 		00000004h  
FILE_ATTRIBUTE_DIRECTORY        equ 		00000010h  
FILE_ATTRIBUTE_ARCHIVE          equ		00000020h  
FILE_ATTRIBUTE_NORMAL           equ 		00000080h  
FILE_ATTRIBUTE_TEMPORARY        equ 		00000100h  
FILE_ATTRIBUTE_COMPRESSED       equ 		00000800h  
FILE_ATTRIBUTE_OFFLINE          equ 		00001000h  


f_struc                	struc

			ff_attr                 dd      ?
			ff_time_create          dd      ?,?
			ff_time_lastaccess      dd      ?,?
			ff_time_lastwrite       dd      ?,?
			ff_size_high            dd      ?
			ff_size                 dd      ?
		         	                dd      ?,?
			ff_fullname             db      260 dup (?) 
			ff_shortname            db      14 dup (?)

                       	ends

FILETIME		struc

			dwLowDateTime		dd	?
			dwHighDateTime		dd	?

FILETIME		ends

