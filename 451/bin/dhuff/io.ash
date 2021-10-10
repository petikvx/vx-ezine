PAGE_READWRITE 			equ  4
FILE_MAP_WRITE 			equ  2

GENERIC_READ                    equ 80000000h
GENERIC_WRITE                   equ 40000000h
GENERIC_EXECUTE                 equ 20000000h
GENERIC_ALL                     equ 10000000h

FILE_SHARE_READ                 equ 00000001h
FILE_SHARE_WRITE                equ 00000002h  
FILE_SHARE_DELETE               equ 00000004h  

FILE_BEGIN           		equ 0
FILE_CURRENT         		equ 1
FILE_END            		equ 2

FILE_ATTRIBUTE_READONLY         equ 00000001h  
FILE_ATTRIBUTE_HIDDEN           equ 00000002h  
FILE_ATTRIBUTE_SYSTEM           equ 00000004h  
FILE_ATTRIBUTE_DIRECTORY        equ 00000010h  
FILE_ATTRIBUTE_ARCHIVE          equ 00000020h  
FILE_ATTRIBUTE_NORMAL           equ 00000080h  

GMEM_FIXED          		equ 0000h

OPEN_EXISTING       		equ 3
OPEN_ALWAYS        		equ 4
