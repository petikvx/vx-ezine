; DrWeb patcher for v3.18
; Пеpед pаботой с этой пpогpаммой необходимо pаспаковать DrWeb
; "drweb drweb /upw"  и лyчше снять его самозащиту от изменения (см.тyт же)

cseg    segment
        assume cs:cseg,ds:cseg
        org 100h
start:
       mov dx,offset file
       mov ax,3d02h
       int 21h
       mov bx,ax
       xor cx,cx
       mov dx,9be2h             ;Only for 3.18 version....
       mov ax,4200h
       int 21h
       mov ah,40h
       mov dx,offset _dat
       mov cx,5
       int 21h
       mov ah,3eh
       int 21h
       retn
file   db 'drweb.exe',0
_dat   db 0cdh,0abh,90h,90h,90h
cseg   ends
       end start