_SpecVpp1:
      call ZerroBuffer
      mov cx,0
      mov dx,word ptr ds:[9ah]
      sub dx,18
      call GotoStart
      jc CureVpp0
      lea dx,[Buffer]
      mov cx,18
      call ReadFromFile
      lea si,Buffer
      lea di,Vpp1Mask
      push bx
      mov cx,6
      mov bx,cx
      call concatenat_string_in_memory
      pop bx
      cmp di,0ffffh
      je CureVpp0
      call CureVpp1
      jmp short CureVpp2
CureVpp0:
      clc
CureVpp2:
      ret
CureVpp1:
      call VPP1Alert
      mov cx,0
      mov dx,word ptr ds:[9ah]
      sub dx,475
      call GotoStart
      lea si,[Buffer+10]
      lodsb
      lea di,Vaccine1
      dec di
      stosb
      lodsb
      lea di,Vaccine2
      dec di
      stosb
      lodsb
      lea di,Vaccine3
      dec di
      stosb
      lea dx,Vaccine
      mov cx,VaccineLength
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
VPP1Alert:
      call PrintAlert
      lea dx,Vpp1Name
      call PrintVirusName
      ret
;---
Vaccine:
      push bp
      push ax
      mov bp,sp
      mov bp,word ptr ss:[bp+4]
      sub bp,3
      mov byte ptr cs:[bp],90h
Vaccine1:
      mov byte ptr cs:[bp+1],90h
Vaccine2:
      mov byte ptr cs:[bp+2],90h
Vaccine3:
      mov ax,bp
      mov bp,sp
      mov word ptr ss:[bp+4],ax
      pop ax
      pop bp
      ret
VaccineLength equ $-Vaccine
;---
Vpp1Name db 'Vpp1',0h
Vpp1Virus db 'vpp1.bin',0h
;---
Vpp1Mask db '*' xor 'V', '.' xor '+', 'c' xor '+'
         db 'o' xor 'V', 'm' xor '+', 0h  xor '+'
