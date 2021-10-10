

                        CD-ROM Drive faking under DOS
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

                                   by  Renegade
         

; This program can be very useful faking a drive for some games
; Thx to MBF and A.


.model tiny
.code
radix 16
org 100

start: mov dx,offset logo
       mov ah,9
       int 21
       cld    
       call continue
       mov ah,62                         
       int 21
       mov es,bx
       mov ah,62
       int 21
       mov dx,offset outmem
       int 27                  
continue:
       mov word ptr [extra],'\:'                       
       mov byte ptr [temp_change],'\'                 
       mov byte ptr [reply_mscdex],00h               
       mov si,81                                      
       call skip_blanks                              
       lodsw
       cmp al,'/'                                      
       jnz goon
       jz init_mscdex
       cmp ah,'r'
       jz remove
init_mscdex:
       mov byte ptr [REPLY_MSCDEX],0FFH                
       int 3
       CALL SKIP_BLANKS
       lodsw
       jmp goon
remove:
       mov ax,150ch                                  
       mov bx,1606h
       mov cx,0f00dH
       int 2f
       or cx,cx                                     
       jnz removed                             
       mov dx,offset removing
       mov ah,9
       int 21
       mov al,1
       jmp quit
       removed:
       cmp cl,1                                   
       jz doremove
       mov dx, offset notres
       mov ah,9
       int 21
       xor ax,ax
       jmp quit
doremove:
       mov dx, offset remdone
       mov ah,9
       int 21
       xor ax,ax
       jmp quit
goon:
       call existing                             
       mov byte ptr [drive],AL                         
       call skip_blanks
       cmp al,0d
       jnz check2
then:
       mov si,offset directory                         
       call getdir
       add al,41
       mov byte ptr [xdrive],al                       
       jmp dirdone
check2:
       push si                                   
       pop di                                         
       lodsw
       cmp ah,':'
       jz lokdrive
       mov si,offset directory                       
       call getdir                             
       add al,41                                      
       mov byte ptr[xdrive],al                   
       mov si,di
       call skip_blanks
       jmp driveok
lokdrive:
       call existing                           
       mov byte ptr [xdrive],al
driveok:
      mov di,offset dir1
      call string
      cmp byte ptr [di],'\'
      jz convert
      cmp byte ptr [di],0d
      JZ convert
      cmp byte ptr [di],20
      jnz nxtcheck
      convert:
      dec di
nxtcheck:
     inc di
     xor ax,ax
     stosb
     call tempdir
     call backdir
dirdone:
     mov ax,150ch                              
     mov bx,1606h 
     int 2f
     cmp cx,6666h
     jnz nothres
     mov dx, offset nottres
     mov ah,9
     int 21
     mov al,01h
     jmp quit
nothres:
     mov ah,19
     int 21
     mov dl,al
     mov ah,0eh
     int 21
     mov dl,byte ptr [drive]
     mov byte ptr [drive_err],dl
     sub dl,41
     mov ah,00h
     cmp dl,al
     jl dosdri
     mov dx, offset drive_err
     mov ah,9
     int 21
     mov al,01h
     jmp quit
dosdri:
     mov dx,offset no_spec                          
     mov ah,09h
     int 21
     call tempdir
     mov ah,52                                    
     int 21
     cwd
     mov dl,byte ptr[drive]                      
     sub dl,41     
     mov byte ptr [edrive],dl                     
     mov ax,88d                                
     imul dx                                      
     les bx,dword ptr es:[bx+18H]                    
     mov word ptr [temp_addr+02],es                
     mov word ptr [temp_addr+00h],bx
     mov cx,es
     add ax,cx
     adc bx,0000h
     mov word ptr [subst_addr+02h],bx              
     mov word ptr [subst_addr+00h],ax
     push cs                                     
     pop es                                          
     mov di,offset data1                   
     lds si,dword ptr [subst_addr]                   
     mov cx,88d                                                                            
     rep movsb                                       
     push cs
     pop ds
     les di,dword ptr [subst_addr]                  
     cwd
     mov dl,byte ptr [xdrive]
     sub dl,41
     mov cx,88d
     mov ax,cx
     imul dx
     mov si,word ptr [temp_addr+02]                 
     mov bx,word ptr [temp_addr+00]
     add si,ax
     adc bx,0000h
     mov ds,bx                                      
     rep movsb                                      
     lds si,dword ptr cs:[subst_addr+00h]            
     call strile                            
     xchg ah,al                                   
     les di,dword ptr cs:[subst_addr+00h]
     add di,4fh
     stosw
     call backdir
     mov ax,352Fh                                   
     int 21
     mov word ptr [jmp_addr+02h],es
     mov word ptr [jmp_addr+00h],bx
     mov dx,offset memin                       
     mov ax,252fh
     int 21
     ret                                          
quit:
     mov ah,4ch
     int 21
skip_blanks proc                                
redo:
     lodsb
     cmp al,0dh
     jz ahead
     cmp al,' '
     jz redo
ahead:
     dec si
     ret
     endp
string proc                                 
     push cx                                       
     mov cx,00ffh
again:
     lodsb
     cmp al,0dh
     jz done2
     cmp al,' '
     jz done2
     stosb
     loop again                                            
     mov ah,0ffh                                   
done2:
     dec di
     pop cx
     ret
     endp
strile proc                             
     push cx
     mov cx,00ffh
     cbw
making:
     inc ah
     lodsb
     cmp al,00h
     jz nekst
     loop making
     mov ah,0ffh                                    
nekst:
     pop cx
     ret
     endp
existing proc
     cmp ah,':'
     jz alfa                             
alfa:
     cmp al,'a'                                    
     jb con
     sub al,20h                                     
con:
     cmp al,'A'
     jge bene
bene:
     cmp al,'Z'
     jle char
char:
     ret
     endp
getdir proc
     mov ah,19                                  
     int 21
     push ax                                        
     xor dx,dx
     mov ah,47h                                    
     int 21
     pop ax                                         
     jnc dirok
     mov dx,offset error
     mov ah,9
     int 21
     mov al,011
     jmp quit
dirok:
     ret
     endp
tempdir proc
     mov si,offset temp_cur_dir                      
     call getdir                             
     mov byte ptr [temp_drive],al
     mov dl,byte ptr [xdrive]                        
     sub dl,41
     mov ah,0eh                                      
     int 21
     mov ah,19h                                     
     int 21
     cmp dl,al
     jnz changer
     mov dx, offset dir1                            
     mov ah,3bh                                     
     int 21
     jnc goodir
changer:
     mov dx,offset error2
     mov ah,9
     int 21
     mov al,01h
     jmp quit
goodir:
     ret
     endp
backdir proc
     push cs
     push cs
     pop ds
     pop es
     mov dl,byte ptr [temp_drive]                   
     mov ah,0eh                                      
     int 21
     mov ah,19
     int 21
     cmp al,dl
     jnz changer
     mov dx,offset temp_change                     
     mov ah,3bh
     int 21
     jc changer
     ret
     endp
memin:
     cmp ax,1100h                                   
     jnz nomscdex
     push bp
     mov bp,sp
     cmp byte ptr cs:[reply_mscdex],0ffh
     jnz argh
     mov al,0ffh
argh:
     cmp word ptr SS:[bp+08h],0dadah
     pop bp
     jz yumscdex
     jmp tworet
yumscdex:
     mov al,0ffh
     push bp
     mov bp,sp
     mov word ptr SS:[bp+08h],0adadh
     pop bp
     iret                                           
nomscdex:
     cmp ah,15h
     jnz driche
     cmp al,00h                                    
     jz all
     cmp al,01h                                   
     jz tworet
     cmp al,0bh                                      
     jz cdcheck
     cmp al,0ch                                   
     jz versio
     cmp al,0dh                                      
     jz lastdriv
     cmp al,10h                                     
     jz cdinit
driche:                              
     db 0eh                                         
     jmp_addr  dd ?
tworet:
     iret                                      
all:
     mov bx,01h
     xor cx,cx
     mov cl,byte ptr cs:[edrive]
     iret                                            
cdcheck:
     cmp cl,byte ptr cs:[edrive]
     jz newche
     xor ax,ax
     mov bx,0adadh
     iret
newche:
     mov ax,0ffffh
     mov bx,0adadh
     iret                                          
lastdriv:
     push ax
     mov al,byte ptr cs:[edrive]
     mov byte ptr es:[bx],al
     pop ax
     iret                                           
cdinit:
     cmp cl,byte ptr cs:[edrive]
     jnz differ
     mov word ptr es:[bx+03h],0100h
     iret                                         
differ:
     mov word ptr es:[bx+03h],8001h 
     iret                                          
versio:
     cmp bx,1606h                                 
     jnz movassn
     cmp cx,0f00dh                        
     mov cx,6666h                                    
     jnz movassn
     push ax
     push dx
     push ds
     push es
     push di
     push si
     mov ax,352fh                                   
     int 21
     mov ax,cs
     mov dx,es
     cmp ax,dx
     mov cl,00h                                     
     jnz other
     cmp bx,offset memin
     jnz other
     lds dx,dword ptr cs:[jmp_addr]
     mov ax,252fh
     int 21
     les di,dword ptr cs:[subst_addr]               
     mov si,offset data1
     mov cx,88d
     push cs      
     pop ds
     cld
     rep movsb
     cli                                             
     mov ah,49h
     mov es,cs:[2ch]
     int 21h
     mov ah,49h
     push cs
     pop es
     int 21h
     sti
     mov cl,01h                                     
other:
     mov ch,00h
     pop si
     pop di
     pop es
     pop ds
     pop dx
     pop ax
movassn:
     mov bx,0217h
     iret                                           

reply_mscdex db ?                            
edrive db ?                                   
subst_addr dd ?                               
data1 db 88d dup (?)                 

outmem:

         logo: db 0dh,0ah,' CD-ROM Faking by Renegade / ASM', 0
               db 0dh,0ah,'','',0
               db 0dh,0ah,' Romfake [drive] [directory]', 0
               db 0dh,0ah,'','', 0
               db 0dh,0ah,' Romfake / r  to remove','$',0



remdone   db 0dh,0ah,'Successfully removed','$'
notres  db 0dh,0ah,'Not resident!','$'
nottres  db 0dh,0ah,'Already resident!','$'
Removing  db0dh,0ah, 'Error removing!','$'
drive_err:   db ?
             db 0dh,0ah,': Not in lastdrive','$',0dh,0ah
no_spec:     db 0dh,0ah,'faked drive= '
drive db ?
db ':','$',0dh,0ah
error db 0dh,0ah,'Error reading directory!','$',0dh,0ah
error2 db 0dh,0ah, 'not able to read directory!','$',0dh,0ah
xdrive db ?
extra db ?
dir1 db ?
directory db (70h - 4h) dup (?)
           db ?
temp_drive db ?
temp_change db ?
temp_cur_dir db (70h) dup (?)
             db ?
temp_addr dd ?
end start
code ends