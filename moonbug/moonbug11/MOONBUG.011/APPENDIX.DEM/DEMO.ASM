Model Tiny
.code
.386
org 100h
start:
       mov bp,100h
;---
       lea di,[bp+@StartCode+@@SC2+1]
       call _Calc_Rnd16
       mov word ptr ds:[di],bx
;---
       lea si,Cryptor
       mov SI_CUR,si
       lea di,Decryptor
       add di,BuffLength
       mov DI_CUR,di
       call PolyProc
;---
       lea si,@@@1
       push si
;*
       lea di,Cryptor
       dec di
       push di
       mov al,0adh
       stosb
;*
       mov cx,(@@EndCode / 2) + 1
       mov di,SI_CUR
;*
       mov al,0abh
       stosb
;*
       mov ax,08349h
       stosw
       mov ax,000f9h
       stosw
       mov ax,00374h
       stosw
       pop si
       push di
       mov al,0e9h
       stosb
       mov ax,1234h
       stosw
       pop ax
       push di
       xchg di,ax
       lea bx,Buff
       call CalcJump
       pop di

;*
       mov al,0c3h
       stosb
;*
       lea di,EndCode
       lea si,[bp + @StartCode + @@SC2 + 1]
       mov bx,word ptr ds:[si]
       lea si,Cryptor
       dec si
       push si
       lea si,EndCode
       ret
@@@1:
;---
       lea si,StartCode
       lea di,Buff
       mov cx,@@StartCode
       rep movsb
       push di
;*
       call Musor
;*
       mov al,0adh
       stosb
;*
       call Musor
;*
       mov si,DI_CUR
       lea cx,Decryptor
       add cx,BuffLength
       sub cx,si
       rep movsb
;*
       call Musor
;*
       mov al,0abh
       stosb
;*
       call Musor
;*
       pop si
       mov al,049h
       stosb
       call Musor
       mov ax,0f983h
       stosw
       mov al,0
       stosb
       call Musor1
       mov ax,00574h
       stosw
       call Musor1
       push di
       mov al,0e9h
       stosb
       mov ax,1234h
       stosw
       pop ax
       push di
       xchg di,ax
       lea bx,Buff
       call CalcJump
       pop di
       call Musor1
;*
       push di
;*
       lea si,EndCode
       mov cx,@@EndCode
       rep movsb
;---
       pop ax
       lea si,Buff
       sub ax,si
       add si,@@SC1+2
       mov word ptr ds:[si],ax
;---
       mov cx,di
       lea di,Buff
       sub cx,di
       call WriteBuff
;---
       mov ax,4c00h
       int 21h
;---
include library.inc
;---
end start
