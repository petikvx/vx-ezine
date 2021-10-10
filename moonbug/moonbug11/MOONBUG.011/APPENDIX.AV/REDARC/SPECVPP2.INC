_SpecVpp2:
      call ZerroBuffer
      mov cx,0
      mov dx,word ptr ds:[9ah]
      sub dx,681
      call GotoStart
      jc CureVpp2_0
      lea dx,[Buffer]
      mov cx,681
      call ReadFromFile
      lea si,Buffer
      lea di,Vpp2Mask
      push bx
      mov cx,Vpp2MLength
      mov bx,cx
      call concatenat_string_in_memory
      pop bx
      cmp di,0ffffh
      je CureVpp2_0
      call CureVpp2_1
      jmp short CureVpp2_2
CureVpp2_0:
      clc
CureVpp2_2:
      ret
CureVpp2_1:
      call VPP2Alert
      nop
      mov ax,ax
      nop
      lea di,[Buffer+2fh]
      mov dx,word ptr ds:[di]
      lea si,[Buffer]
      mov di,si
      mov cx,681 / 2
@CVPP2:
      lodsw
      not ax
      xor ax,dx
      not ax
      stosw
      loop @CVPP2
      mov cx,0
      mov dx,word ptr ds:[9ah]
      sub dx,681
      call GotoStart
      lea si,[Buffer]
      add si,681-6
      lodsb
      lea di,Vaccine2_1
      dec di
      stosb
      lodsb
      lea di,Vaccine2_2
      dec di
      stosb
      lodsb
      lea di,Vaccine2_3
      dec di
      stosb
      lea dx,Vaccine2Vpp
      mov cx,Vaccine2Length
      mov ah,40h
      int 21h
      mov ah,40h
      xor cx,cx
      mov dx,dx
      int 21h
      call CuredInfo
      inc ProtokolAllFileCured
      stc
      ret
;---
VPP2Alert:
      call PrintAlert
      lea dx,Vpp2Name
      call PrintVirusName
      ret
;---
Vaccine2Vpp:
      push bp
      push ax
      mov bp,sp
      mov bp,word ptr ss:[bp+4]
      sub bp,3
      mov byte ptr cs:[bp],90h
Vaccine2_1:
      mov byte ptr cs:[bp+1],90h
Vaccine2_2:
      mov byte ptr cs:[bp+2],90h
Vaccine2_3:
      mov ax,bp
      mov bp,sp
      mov word ptr ss:[bp+4],ax
      pop ax
      pop bp
      ret
Vaccine2Length equ $-Vaccine2Vpp
;---
Vpp2Name db 'Vpp2',0h
Vpp2Virus db 'vpp2.bin',0h
;---
Vpp2Mask:
         db 055h, 056h, 08bh, 0f4h, 036h, 08bh, 06ch, 004h
         db 083h, 0edh, 003h, 036h, 089h, 06ch, 004h, 089h
         db 02eh, 004h, 000h, 05eh, 05dh
Vpp2MLength equ $-Vpp2Mask
