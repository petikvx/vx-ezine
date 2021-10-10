_SpecVpp3:
      mov cx,0
      mov dx,word ptr ds:[9ah]
      sub dx,3
      call GotoStart
      jc NotAVirus
      lea dx,[Buffer+3]
      mov cx,3
      call ReadFromFile
      lea si,Buffer
      mov di,si
      add di,3
      call Vpp3
      cmp al,'V'
      jne NotAVirus
      call Vpp3
      cmp al,'+'
      jne NotAVirus
      call Vpp3
      cmp al,'+'
      jne NotAVirus
      call CuredVpp3
      jmp short ICFExit
NotAVirus:
           clc
ICFExit:
           ret
Vpp3:
      lodsb
      xchg ah,al
      xchg si,di
      lodsb
      xchg si,di
      xor al,ah
      ret
Vpp3Name db 'Vpp3',0h
VppVirus db 'vpp3.bin',0h
CuredVpp3:
      mov dx,word ptr ds:[9ah]
      sub dx,3529
      xor cx,cx
      push cx
      push dx
      call GotoStart
      mov cx,DatenLength
      push cx
      lea dx,[Buffer]
      push dx
      call ReadFromFile
      pop si
      lea di,DatenVpp3
      pop cx
LVPP3_1:
      lodsb
      xchg si,di
      xchg dx,ax
      lodsb
      xor dx,ax
      xchg dx,ax
      sub di,1
      stosb
      xchg si,di
      loop LVPP3_1
      lea di,XorMask
      lea si,[Buffer]
      mov cx,4
      rep movsb
      pop dx
      pop cx
      call GotoStart
      mov cx,3529
      push cx
      lea dx,[Buffer]
      push dx
      call ReadFromFile
      pop di
      pop cx
      mov si,di
      push bx
      mov dh,byte ptr ds:[XorMask]
      mov dl,byte ptr ds:[XorMask+1]
      mov bh,byte ptr ds:[XorMask+2]
      mov bl,byte ptr ds:[XorMask+3]
LVPP3_2:
      lodsb
      xor al,dh
      stosb
      dec cx
      call CMP_CX
      jc LVPP3Ende
      lodsb
      xor al,dl
      stosb
      dec cx
      call CMP_CX
      jc LVPP3Ende
      lodsb
      xor al,bh
      stosb
      dec cx
      call CMP_CX
      jc LVPP3Ende
      lodsb
      xor al,bl
      stosb
      dec cx
      call CMP_CX
      jc LVPP3Ende
      jmp short LVPP3_2
LVPP3Ende:
      mov bx,word ptr ds:[Buffer+9]
      mov cx,word ptr ds:[Buffer+17]
      lea si,[Buffer+31]
      mov di,si
      push di
LVPP3_3:
      lodsw
      not ax
      xor ax,bx
      not ax
      stosw
      loop LVPP3_3
      pop si
      lea di,FixedVpp3
      mov cx,11
      mov bx,cx
      call concatenat_string_in_memory
      cmp di,0ffffh
      je NotAVirusVpp3
      call VPP3Alert
      call SaveVpp3Bin
      pop bx
      lea si,[Buffer]
      add si,3523
      mov dx,word ptr ds:[si-2]
      sub dx,100h
      xor cx,cx
      call GotoStart
      xchg dx,si
      mov ah,40h
      mov cx,3
      int 21h
      mov dx,word ptr ds:[9ah]
      sub dx,3529
      xor cx,cx
      call GotoStart
      mov ah,40h
      xor cx,cx
      xor dx,dx
      int 21h
      call CuredInfo
      inc ProtokolAllFileCured
      stc
NotAVirusVpp3:
      ret
;---
CMP_CX:
      cmp cx,0
      je CMPCX
      clc
      ret
CMPCX:
      stc
      ret
;---
VPP3Alert:
      call PrintAlert
      lea dx,Vpp3Name
      call PrintVirusName
      ret
;---
SaveVpp3Bin:
       ret
       lea dx,VppVirus
       mov ah,3ch
       mov cx,0
       int 21h
       xchg bx,ax
       lea dx,[Buffer]
       mov cx,3529
       mov ah,40h
       int 21h
       mov ah,3eh
       int 21h
       mov ax,4301h
       lea dx,VppVirus
       mov cx,0feh
       int 21h
       stc
       ret
;---
DatenVpp3:
      db 0e8h, 000h, 000h, 0fch, 0beh, 000h, 000h, 05dh, 0bbh, 000h, 000h
      db 083h, 0edh, 003h, 003h, 0f5h, 0b9h, 0d3h, 006h, 08bh, 0feh, 0adh
      db 0f7h, 0d0h, 033h, 0c3h, 0f7h, 0d0h, 0abh, 0e2h, 0f6h
DatenLength equ $-DatenVpp3
XorMask db 4 dup (?)
FixedVpp3 db 0e8h, 054h, 000h, 0b8h, 001h, 025h, 08dh, 096h, 097h, 000h, 0cch
