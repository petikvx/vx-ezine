;INTERFACE

;PrintName proc near
;PrintStr proc near
;Ctrl proc near
;ClrEol proc near
;FindExtension proc near
;_SetC proc near
;_SetN proc near
;_SetO proc near
;LoverCase proc near
;Yes_No proc near
;Write proc near
;WriteLine proc near
;RestoreFileName proc near
;ConverNumToString proc near

;IMPLEMENTATION
;**************************************************************************
PrintName proc near
        push si
        mov al,dsk
        add al,'A'
        int 29h         ; int 29h - fast put char
        mov al,':'
        int 29h
        mov al,'\'
        int 29h
        lea dx,curpath
        mov ah,47h
        mov si,dx
        cwd
        int 21h
        call PrintStr
        mov al,'\'      ; для файлов в корневухе напечатается два слеша,
        int 29h         ; что в принципе не страшно
        pop si
        call PrintStr
        retn
PrintName endp
;**************************************************************************
PrintStr proc near
        push si
@6:     lodsb
        or al,al
        jz @7
        int 29h
        jmp @6
@7:
        pop si
        retn
PrintStr endp
;**************************************************************************
Ctrl proc near
        push ax
        mov al,13
        int 29h
        mov al,10
        int 29h
        pop ax
        retn
Ctrl endp
;**************************************************************************
ClrEol proc near
        push ax dx
        lea dx,ClrEolC
        call Write
        pop dx ax
        retn
ClrEol endp
;**************************************************************************
FindExtension proc near
              push bp si
FExt0:
              lodsb
              cmp al,'.'
              je FoundExt
              cmp al,0
              je NoFoundExt
              jmp short FExt0
NoFoundExt:
              mov si,0
FoundExt:
              xchg si,ax
              pop si bp
              retn
FindExtension endp
;**************************************************************************
_SetC proc near
     mov ah,01h
     int 10h
     retn
_SetC endp
;**************************************************************************
_SetN proc near
     mov cx,0607h
     call _SetC
     retn
_SetN endp
;**************************************************************************
_SetO proc near
     mov cx,2000h
     call _SetC
     retn
_SetO endp
;**************************************************************************
LoverCase proc near
     or al,00100000b
     retn
LoverCase endp
;**************************************************************************
Yes_No proc near
       mov ah,01h
       int 21h
       cmp al,0dh
       je YES_
       or al,00100000b
       cmp al,'y'
       jne NO_
YES_:
       mov [Yes_No_Byte],1
       ret
NO_:
       mov [Yes_No_Byte],0
       ret
Yes_No endp
;**************************************************************************
Write proc near
      mov ah,09h
      int 21h
      ret
Write endp
;**************************************************************************
WriteLine proc near
          mov al,' '
          int 29h
          mov al,'-'
          int 29h
          mov al,' '
          int 29h
          ret
WriteLine endp
;**************************************************************************
RestoreFileName proc near
          push si di
RestoreFileName_:
          lodsb
          stosb
          cmp al,0
          jne RestoreFileName_
          pop di si
          ret
RestoreFileName endp
;**************************************************************************
;CX <- NumBase
;DX <- Num
;ES:DI -> StringBuff
ConvertNumToString proc near
      mov      bx,di
      mov      al,0
      cld
      stosb
      xchg     dx,ax
      call     @@1
      jmp      @@4
  @@1:xor      dx,dx
      div      cx
      or       ax,ax
      push     dx
      jz       @@2
      call     @@1
  @@2:pop      ax
      cmp      al,0Ah
      jc       @@3
      add      al,7
  @@3:add      al,30h
      stosb
      inc      byte ptr es:[bx]
      retn
  @@4:
ConvertNumToString endp
