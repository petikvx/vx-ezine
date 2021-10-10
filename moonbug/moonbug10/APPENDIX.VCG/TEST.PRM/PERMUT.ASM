;(c) RedArc
Model Tiny
.code
org 100h
start:
;--- For begin
    lea di,Flags
    mov cx,5
@1:
    stosb
    loop @1
    mov Count,5
    lea di,buff
    call Jump
;--- Permutation algoritm
Permut:
    cmp Count,1
    je Ende
@2:
    mov ah,6
    call RND_Tabelle
    cmp ah,6
    jge @2
    mov al,ah
    call TEST_Flag
    cmp al,0
    jne @2
    mov al,ah
    call VCG_Emul
    call Jump
    dec Count
    jmp short Permut
Ende:
    mov cx,5
    xor ax,ax
@3:
    push ax
    call TEST_Flag
    cmp al,0
    je @4
    pop ax
    inc ax
    loop @3
@4:
    pop ax
    call VCG_Emul
    call Jump
    mov bp,di
Prepare:
;Jump to first block
    lea si,LOffs
    lea di,buff
    mov ax,word ptr ds:[si]
    sub ax,di
    sub ax,3
    mov word ptr ds:[di+1],ax
    xor cx,cx
    xchg di,bx
;Jump to next block
@7:
    mov ax,word ptr ds:[si]
    mov di,ax
    add si,2
    push si
    mov dx,word ptr ds:[si]
    sub ax,bx
    sub dx,bx
    lea si,DatenLeng
    add si,cx
    push cx
    xor cx,cx
    mov cl,byte ptr ds:[si]
    add ax,cx
    add di,cx
    pop cx
    pop si
    cmp ax,dx
    jl @5
    push cx
    mov cx,0ffffh
    sub ax,dx
    sub cx,ax
    xchg dx,cx
    sub dx,2
    pop cx
    jmp short @6
@5:
    add ax,3
    sub dx,ax
@6:
    mov word ptr ds:[di+1],dx
    inc cx
    cmp cx,3
    jne @7
;Offset Message
    lea si,LOffs
    add si,8
    mov ax,word ptr ds:[si]
    sub ax,bx
    inc ah
    sub si,6
    mov dx,word ptr ds:[si]
    inc dx
    xchg si,dx
    mov word ptr ds:[si],ax
;--- Write File on Disk
    mov ah,3ch
    lea dx,filename
    xor cx,cx
    int 21h
    xchg ax,bx
    mov ah,40h
    lea dx,buff
    mov cx,bp
    sub cx,dx
    int 21h
    mov ah,40h
    xor cx,cx
    xor dx,dx
    int 21h
    mov ah,3eh
    int 21h
    int 20h
;--- Jump Generator
Jump:
    push ax bx
    call _Calc_Rnd16
    mov al,0e9h
    stosb
    xchg bx,ax
    stosw
    pop bx ax
    ret
;--- VCG
;Input:  al - numblock
;Output: none
VCG_Emul:
    push ax bx cx si
    call SET_Flag
    sub ah,ah
    lea si,LOffs
    push ax
    mov cl,2
    mul cl
    add si,ax
    mov word ptr ds:[si],di
    lea si,DatenOffs
    add si,ax
    mov bx,word ptr ds:[si]
    lea si,DatenLeng
    pop ax
    add si,ax
    xor cx,cx
    mov cl,byte ptr ds:[si]
    xchg si,bx
VCG_Loop:
    lodsb
    stosb
    loop VCG_Loop
    pop si cx bx ax
    ret
;--- Temp
Temp:
    sub ah,ah
    lea si,Flags
    add si,ax
    ret
;--- TestFlag
;Input:  al - flag
;Output: al - range
TEST_Flag:
    push si ax
    call Temp
    pop ax
    mov al,byte ptr ds:[si]
    pop si
    ret
;--- SetFlag
;Input:  al - flag
;Output: none
SET_Flag:
    push ax si
    call Temp
    mov byte ptr ds:[si],1
    pop si ax
    ret
;--- RND Generator
;Input:  ah - range
;Output: ah - rnd
RND_Tabelle:
       mov al,ah
       in al,40h
       cmp al,ah
       jnc RND_Tabelle
       xchg ah,al
       ret
;--- RND Value
;Input:  none
;Output: ax - Rnd16
_Calc_Rnd16:
         push ax
         mov ah,0ffh
         call RND_Tabelle
         mov al,ah
         mov ah,0ffh
         call RND_Tabelle
         xchg bx,ax
         pop ax
         ret
;--- Daten
DatenOffs dw m1o+100h, m2o+100h, m3o+100h, m4o+100h, m5o+100h
DatenLeng db m1l, m2l, m3l, m4l, m5l
;--- Code to Permutation
m1o equ $-start
m1:
   mov ah,9h
m1l equ $-m1
m2o equ $-start
m2:
   mov dx,1234h   ;LABEL1
m2l equ $-m2
m3o equ $-start
m3:
  int 21h
m3l equ $-m3
m4o equ $-start
m4:
  ret
m4l equ $-m4
m5o equ $-start
m5:
  db 'Hello World!',0ah,0dh,'$'
m5l equ $-m5
;--- File for Test
filename db 'perm1.com',0h
;--- Flags of code
Flags db ?, ?, ?, ?, ?
;--- Offsets
LOffs dw ?, ?, ?, ?, ?
;--- Counter
Count db ?
;--- Buffer
buff label byte
end start
