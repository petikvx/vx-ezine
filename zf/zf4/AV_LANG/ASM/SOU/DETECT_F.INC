;INTERFACE

;DetectFile proc near

;IMPLEMENTATION
;**************************************************************************
DetectFile proc near
          pusha
          pushf
          push ds
          push es
;*
          call ClrEol
          call PrintName
          mov CurFile,0
          inc AllFileFound
          mov bp,si
          call FindExtension
          cmp ax,0
          je ExitDetectFile
          mov si,ax
          lodsb
          call LoverCase
          cmp al,'c'
          jne ExitDetectFile
          lodsb
          call LoverCase
          cmp al,'o'
          jne ExitDetectFile
          lodsb
          call LoverCase
          cmp al,'m'
          jne ExitDetectFile
;*
          call WriteLine
          mov si,bp
          lea di,SouFileName
          call RestoreFileName
          mov dx,bp
          call GetFileAttr
          mov FileAttr,cx
          mov al,0
          call OpenFile
          cmp bx,0
          jne OkOpenFile
          inc AllErrorFound
          lea dx,ErrorOpenFile
          call Write
          jmp ExitDetectFile
OkOpenFile:
          mov SouFileH,bx
          call GetFileDateTime
          mov FileTime,cx
          mov FileDate,dx
          inc AllFileTested
          mov ax,4202h
          xor cx,cx
          xor dx,dx
          int 21h
          mov FileLength,ax
          cmp dx,0
          je FileLenTest
          mov FileLength,0ffffh
FileLenTest:
          mov cx,FileLength
          mov dx,57000
          cmp cx,dx
          jc Tiny_File
          inc AllFileError
          lea dx,FileTooBig
Close_File:
          call Write
Close_File_1:
          call Ctrl
          call CloseFile
          jmp ExitDetectFile
Tiny_File:
          mov si,0
          call Seek
          mov cx,FileLength
          mov dx,0
          cmp FileLength,8001h
          jb Read_Rest
          mov cx,8000h
          push ds
          mov dx,0
          call BuffInit
          call ReadFromFile
          pop ds
          mov cx,FileLength
          mov dx,8000h
          sub cx,8000h
Read_Rest:
          push ds
          call BuffInit
          call ReadFromFile
          pop ds
          jnc Check_Sig
          lea dx,ErrorOpenFile
          inc AllErrorFound
          jmp Close_File
Check_Sig:
          push cs
          pop ds
          push cs
          pop es
TestRedArc112:
          mov FlagInfect,0
          call RedArc112Fill
          call FindSign
          cmp FlagInfect,1
          jne TestKhizhnjak452
          lea dx,InfectFile
          call Write
          lea dx,VirName
          call Write
          inc RedArcMyCouFind
          inc CurFile
          cmp CuMode,1
          jne NoCure_2
          call WriteLine
          call CureFileProc
NoCure_2:
          call Ctrl
          cmp EraseFlag,0
          je _NCure2
          call ClrEol
          jmp ExitDetectFile
_NCure2:
          mov si,bp
          call PrintName
          call WriteLine
TestKhizhnjak452:
          mov FlagInfect,0
          call KhizhnjakFill
          call FindSign
          cmp FlagInfect,1
          jne NextVirSign
          lea dx,InfectFile
          call Write
          lea dx,VirName
          call Write
          inc KhizhnjakMyCouFind
          inc CurFile
          cmp CuMode,1
          jne NoCure_1
          call WriteLine
          call CureFileProc
NoCure_1:
          call Ctrl
          cmp EraseFlag,0
          je _NCure1
          call ClrEol
          jmp ExitDetectFile
_NCure1:
          mov si,bp
          call PrintName
          call WriteLine
NextVirSign:
          cmp CurFile,0
          je OkMessage
          inc AllFileInfect
          call WriteBuff
          cmp al,1
          je NoMsgOk
OkMessage:
          cmp OkMode,0
          je NoMsgOk
          cmp CurFile,1
          je NoMsgOk
          lea dx,OkFile
          jmp Close_File
NoMsgOk:
          call ClrEol
;*
ExitDetectFile:
          pop es
          pop ds
          popf
          popa
          retn
DetectFile endp
