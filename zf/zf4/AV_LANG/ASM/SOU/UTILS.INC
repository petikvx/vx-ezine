;INTERFACE

;procedure OpenFile
;procedure ReadFromFile
;procedure CloseFile
;procedure WriteToFile
;procedure Seek
;procedure GetFileAttr
;procedure SetFileAttr
;procedure GetFileDateTime
;procedure SetFileDateTime
;procedure BuffInit
;procedure BlockOffs
;procedure BlockPresent
;procedure EraseFile
;procedure FilePos
;procedure FileSize

;IMPLEMENTATION
;-----------------------------------------------------------------------------
;DX <- FileName
;AL <- Mode (0, 1, 2)
;BX -> Handle (or 0 if error)
OpenFile proc near
    mov ah,3dh
    int 21h
    xchg bx,ax
    jnc OFRE
    xor bx,bx
OFRE:
    ret
OpenFile endp
;-----------------------------------------------------------------------------
;DX <- Buff
;CX <- Count
;BX <- Handle
;AX -> Cou
ReadFromFile proc near
    mov ah,3fh
    int 21h
    ret
ReadFromFile endp
;-----------------------------------------------------------------------------
;BX <- Handle
CloseFile proc near
    mov ah,3eh
    int 21h
    ret
CloseFile endp
;-----------------------------------------------------------------------------
;DX <- Buff
;CX <- Count
;BX <- Handle
;AX -> Cou
WriteToFile proc near
    mov ah,40h
    int 21h
    ret
WriteToFile endp
;-----------------------------------------------------------------------------
;BX <- Handle
;SI <- Pos from begin
Seek proc near
    push ax cx dx si
    mov ax,4200h
    xchg si,cx
    xor dx,dx
    int 21h
    pop si dx cx ax
    ret
Seek endp
;-----------------------------------------------------------------------------
;DX <- FileName
;CX -> FileAttr
GetFileAttr proc near
    mov ax,4300h
    int 21h
    ret
GetFileAttr endp
;-----------------------------------------------------------------------------
;DX <- FileName
;CX <- FileAttr
SetFileAttr proc near
    mov ax,4301h
    int 21h
    ret
SetFileAttr endp
;-----------------------------------------------------------------------------
;BX <- Handle
;CX -> Time
;DX -> Date
GetFileDateTime proc near
    mov ax,5700h
    int 21h
    ret
GetFileDateTime endp
;-----------------------------------------------------------------------------
;BX <- Handle
;CX <- Time
;DX <- Date
SetFileDateTime proc near
    mov ax,5701h
    int 21h
    ret
SetFileDateTime endp
;-----------------------------------------------------------------------------
BuffInit proc near
          mov ax,FSEG
          mov ds,ax
          ret
BuffInit endp
;-----------------------------------------------------------------------------
;CX <- MemSize
;DX <- BlockSize
;ES:DI <- MemAddr
;DS:SI <- BlockAddr
;AX -> Offset
BlockOffs proc near
        push    ds
@@find_block:
        mov     al,byte ptr [si]
        repne   scasb
        or      cx,cx
        jcxz    @@block_not_found
        jmp     @@chk_equ_block
@@block_not_found:
        xor     ax,ax
        jmp     @@end_find_block
@@chk_equ_block:
        push    di
        push    si
        push    cx
        dec     di
        mov     cx,dx
        repe    cmpsb
        mov     ax,cx
        pop     cx
        pop     si
        pop     di
        or      ax,ax
        jnz     @@find_block
        mov     ax,di
@@end_find_block:
        pop     ds
        retn
BlockOffs endp
;-----------------------------------------------------------------------------
;CX <- MemSize
;DX <- BlockSize
;ES:DI <- MemAddr
;DS:SI <- BlockAddr
;AX -> 0=False / 1=True
BlockPresent proc near
        push    ds
@@_find_block:
        mov     al,byte ptr [si]
        repne   scasb
        or      cx,cx
        jcxz    @@_block_not_found
        jmp     @@_chk_equ_block
@@_block_not_found:
        xor     ax,ax
        jmp     @@_end_find_block
@@_chk_equ_block:
        push    di
        push    si
        push    cx
        dec     di
        mov     cx,dx
        repe    cmpsb
        mov     ax,cx
        pop     cx
        pop     si
        pop     di
        or      ax,ax
        jnz     @@_find_block
        mov     ax,1
@@_end_find_block:
        pop     ds
        retn
BlockPresent endp
;-----------------------------------------------------------------------------
;DS:DX <- FileName
EraseFile proc near
          mov ah,41h
          int 21h
          ret
EraseFile endp
;-----------------------------------------------------------------------------
;BX <- Handle
;AX -> Current position
FilePos proc near
        push cx dx
        mov ax,4201h
        xor cx,cx
        xor dx,dx
        int 21h
        pop dx cx
        retn
FilePos endp
;-----------------------------------------------------------------------------
;BX <- Handle
;CX -> FileSize
FileSize proc near
       push ax dx si
       call FilePos
       push dx ax
       mov ax,4202h
       xor cx,cx
       xor dx,dx
       int 21h
       xchg cx,ax
       pop ax dx
       xchg si,ax
       call Seek
       pop si dx ax
FileSize endp
