.model tiny
.code
org 100h
start:
     lea dx, stub
     mov ax, 3D00h
     int 21h
     xchg ax, bx
     lea dx, buffer
     mov ah, 3Fh
     mov cx, -1
     int 21h
     mov ah, 3eh
     int 21h
     lea dx, _file
     mov ax, 3d02h
     int 21h
     xchg ax, bx
     lea dx, buffer
     mov cx, 100h
     mov ah, 40h
     int 21h
     mov ah, 3eh
     int 21h
     ret 
_file db 'mylene.exe',0
stub db 'stub\stub.exe',0
buffer:
    db 100h dup (00h) 
end start