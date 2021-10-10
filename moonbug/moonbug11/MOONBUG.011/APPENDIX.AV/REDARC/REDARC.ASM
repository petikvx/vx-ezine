;Антивирус для конкурса
;1996 (c) by RedArc
Model Tiny
.code
org 100h
start:
       call About
       call LoadBases
;---
;       mov ah,3ch
;       lea dx,ProtNameTxt
;       mov cx,0
;       int 21h
;       jnc FileProtokol
;       mov FPFlag,1
;       jmp NotFileProtokol
FileProtokol:
;       mov FPFlag,0
;       mov ProtokolFHandle,ax
NotFileProtokol:
;---
       lea dx,AllFileMask
       mov cx,0feh
       mov ah,4eh
Search:
       int 21h
       jb NotFileFound
       inc ProtokolAllFileScaned
       call InspectFile
       mov ah,4fh
       jmp short Search
NotFileFound:
       call Protocol
       mov al,Result
       mov ah,4ch
       int 21h
InspectFile:
       mov dx,9eh
       lea di,TabelleFileExtension
       call CmpExtFile
       jc NextFile
       call PrintFileName
       mov ax,4301h
       xor cx,cx
       int 21h
       jc NextFile1
       mov ax,3d02h
       int 21h
       jc NextFile1
       xchg bx,ax
       mov cx,3
       lea dx,Buffer
       call ReadFromFile
       jc CloseFile1
       lea si,Buffer
       mov ax,word ptr ds:[si]
       call FormatFile
       jc ProcedureExeFile
       call Inspect_COM_File
       jmp short CloseFile2
ProcedureExeFile:
       call Inspect_EXE_File
CloseFile2:
       call CloseFile
       jmp short NextFile
CloseFile1:
       call CloseFile
NextFile1:
       inc ProtokolAllErrorFile
NextFile:
       ret
;---
include library.inc
Buffer label byte
end start
