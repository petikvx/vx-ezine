;INTERFACE
;ScanDir proc near
;Recurse proc near

;IMPLEMENTATION
; (c) Alexander Zigar' FidoNet: 2:5058/56.8
;**************************************************************************
ScanDir proc near
        mov ah,19h
        int 21h
        mov ah,0Eh
        push ax
        mov dl,dsk
        int 21h
        mov ah,47h
        cwd
        lea si,oldpath
        push si
        int 21h
        lea dx,startpath ;pth
        call Recurse
        pop dx
        mov ah,3Bh
        int 21h
        pop ax
        mov dl,al
        int 21h
        retn
ScanDir endp
;**************************************************************************
Recurse proc near
        mov ah,3Bh      ; переходим в новый каталог
        int 21h
        sub sp,44       ; создаем локальную DTA
        mov dx,sp       ; всего может быть не более 31 подкаталога => всего
        mov si,dx       ; может потребоваться (44+4)*31=1488 байт стека
        add si,1Eh      ; не так уж и много
        mov ah,1Ah
        int 21h
        inc AllPathFound
        lea dx,msk      ; поиск файлов
        xor cx,cx
        mov ah,4Eh
        int 21h
        jc @1
@2:     call DetectFile ;PrintName  ; нашли!
        mov ah,4Fh
        int 21h
        jnc @2
@1:
        mov cx,16       ; поиск всех каталогов
        lea dx,all
        mov ah,4Eh
        int 21h
        jc @3
@5:
        test byte ptr [si-9],16 ; подлая ms-dos вместе с каталогами выдает
                                ; и файлы - будем отсекать
        jz @4
        cmp word ptr [si],'.'           ; корневая директория
        jz @4
        cmp word ptr [si],'..'          ; надкаталог
        jz @4

        push si
        mov dx,si
        call Recurse    ; рекурсивный вызов
        lea dx,old      ; выодим из подкаталога
        mov ah,3Bh
        int 21h
        pop si
        lea dx,[si-1Eh] ; назначаем старую dta
        mov ah,1Ah
        int 21h
@4:
        mov ah,4Fh
        int 21h
        jnc @5
@3:
        add sp,44       ; удалаяем локальную dta
        retn
Recurse endp
;**************************************************************************
