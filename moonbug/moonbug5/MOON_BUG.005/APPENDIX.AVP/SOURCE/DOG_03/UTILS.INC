OPEN_FILE:
        lea dx,FNAME
        mov ax,4300h
        int 21h
        mov FILE_ATTRIB,cx
        mov ax,3d02h
        int 21h
        jc FILE_ERROR
        jmp YES_OPEN
FILE_ERROR:
        lea dx,ERROR_FILE
        mov ah,09h
        int 21h
        mov ah,09h
        lea dx,busser
        int 21h
        call Yes_No
        ret
YES_OPEN:
        mov bx,ax
        mov HANDLE,ax
GET_FDATE:
        mov ax,5700h
        int 21h
        mov FILE_DATE,dx
        mov FILE_TIME,cx
        ret
;-------------------------------------------
CLOSE_File:
        mov ax,5701h
        mov dx,FILE_DATE
        mov cx,FILE_TIME
        int 21h
        mov ah,3eh
        mov bx,HANDLE
        int 21h
        mov HANDLE,0FFFFh
        lea dx,FNAME
        mov ax,4301h
        mov cx,FILE_ATTRIB
        int 21h
        ret
;-------------------------------------------
WRITE_FILE:
          mov ah,40h
          mov bx,handle
          int 21h
          ret
;-------------------------------------------
ERASE_FILE:
          xor cx,cx
          xor dx,dx
          call MOVE_OFSET_START
          xor cx,cx
          call WRITE_FILE
          call CLOSE_FILE
          mov ax,4301h
          lea dx,FNAME
          xor cx,cx
          int 21h
          mov ah,41h
          lea dx,FNAME
          int 21h
          ret
;------------------------------------------
READ_FILE:
         mov ah,3fh
         mov bx,handle
         int 21h
         ret
;------------------------------------------
MOVE_OFSET_START:
         mov ax,4200h
         mov bx,handle
         int 21h
         ret
;-----------------------------------------
MOVE_OFSET_END:
         mov ax,4202h
         mov bx,handle
         int 21h
         ret
;-----------------------------------------
