

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;     	In:edx=offset to filename
;	Out:eax=file handle,cf=1 if error occured
fcreatelog:
		pusha

		push 0
		push FILE_ATTRIBUTE_NORMAL
		push OPEN_ALWAYS
		push 0
		push FILE_SHARE_READ
		push GENERIC_READ+GENERIC_WRITE
		push edx
		KernelCall CreateFileA

		mov [esp._eax],eax
		popa
		ret


;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;     	In:edx=offset to filename
;	Out:eax=file handle,cf=1 if error occured
fcreate:
		pusha

		push 0
		push FILE_ATTRIBUTE_NORMAL
		push CREATE_ALWAYS
		push 0
		push FILE_SHARE_READ
		push GENERIC_READ+GENERIC_WRITE
		push edx
		KernelCall CreateFileA

		mov [esp._eax],eax
		popa
		ret


;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;     	In:edx=offset to filename
;	Out:ebx=file handle,cf=1 if error occured
fopen:
		pusha

		push 0
		push FILE_ATTRIBUTE_NORMAL
		push OPEN_EXISTING
		push 0
		push FILE_SHARE_READ
		push GENERIC_READ+GENERIC_WRITE
		push edx
		KernelCall CreateFileA

		mov [esp._eax],eax
		popa
		ret


;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;	In:ebx=file handle
fclose:
		pusha

		push ebx
		KernelCall CloseHandle

		popa
		ret

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;	In:ebx=file handle,edx=offset bufer,ecx=count bytes
fread:
		pusha


		push eax
		mov eax,esp

		push 0
		push eax					;bytes_cnt_ptr
		push ecx					;bytes_cnt
		push edx                                        ;bufer
		push ebx					;handle
		KernelCall ReadFile

		pop eax						;clear
		popa
		ret

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;	In:ebx=file handle,edx=offset bufer,ecx=count bytes
fwrite:
		pusha

		push eax
		mov eax,esp

		push 0
		push eax					;bytes_cnt_ptr
		push ecx					;bytes_cnt
		push edx                                        ;bufer
		push ebx					;handle
		KernelCall WriteFile

		pop eax						;clear
		popa
		ret

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;	In: ebx=handle
;	    ecx=bytes count
;	    eax=type
fseek:
		pusha

		push eax					;type
		push 0                                          ;hdword
		push ecx	                                ;ldword
		push ebx                                        ;handler
		KernelCall SetFilePointer

		popa
		ret


;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;In:	ebx=handle
;	edi=bufer ( size=3*sizeof(FILETIME) )

fgettime:
                pusha
						
		push edi				;LastWrite
		scasd
		scasd
		push edi				;LastAccess
		scasd
		scasd
		push edi				;LastCreation
		push ebx
		KernelCall GetFileTime
		
		popa
		ret

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;In:	ebx=handle
;	edi=bufer from fgettime

fsettime:
                pusha

		push edi				;LastWrite
		scasd
		scasd
		push edi				;LastAccess
		scasd
		scasd
		push edi				;LastCreation

		push ebx
		KernelCall SetFileTime
		
		popa
		ret

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;In:		edx=ASCIIZ filename
;Out:		eax=attributes
fgetattrb:
		pusha

		push edx
		KernelCall GetFileAttributesA

		mov [esp._eax],eax
		popa
		ret

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;In:		edx=ASCIIZ filename,eax=attributes
fsetattrb:
		pusha

		push eax
		push edx
		KernelCall SetFileAttributesA

		popa
		ret


;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
;in:		ebx=handel
;out:		eax=size
fsize:
		pusha

		push 0
		push ebx
		KernelCall GetFileSize

		mov [esp._eax],eax
		popa
		retn