;INTERFACE

;procedure GetParamLine
;procedure concatenat_string_in_memory
;procedure RestorePath

;IMPLEMENTATION
;-----------------------------------------------------------------------------
GetParamLine proc near
             cmp byte ptr cs:[80h],0
             jne TestParam
             mov ah,1
             ret
TestParam:
             push ds
             pop es
             cld
             mov ah,0
             lea si,OkMode_1
             call CMP_PARAM2
             mov OkMode,al
             lea si,CuMode_1
             call CMP_PARAM2
             mov CuMode,al
             lea si,LoMode_1
             call CMP_PARAM2
             mov LoMode,al
             lea si,OkMode_2
             call CMP_PARAM2
             mov OkMode,al
             lea si,CuMode_2
             call CMP_PARAM2
             mov CuMode,al
             lea si,LoMode_2
             call CMP_PARAM2
             mov LoMode,al
             mov si,81h
             lodsb
             cmp al,'/'
             je CurrentPath
             lodsb
             cmp al,':'
             jne CurrentPath
             mov si,81h
             lodsb
             call LoverCase
             sub al,'a'
             mov dsk,al
             xchg dx,ax
             mov ah,0Eh
             int 21h
             mov ah,3Bh
             lea dx,pth
             int 21h
             mov si,81h
             lea di,startpath
             call RestorePath
             mov ah,3Bh
             lea dx,startpath
             int 21h
             xor ax,ax
             jmp short ExitParam
CurrentPath:
             mov ah,1
ExitParam:
             ret
CMP_PARAM2:
             mov di,81h
             xor cx,cx
             mov cl,byte ptr ds:[80h]
             mov bx,2
             call concatenat_string_in_memory
             cmp di,0ffffh
             je _NoFound
             mov al,1
             ret
_NoFound:
             mov al,0
             ret
GetParamLine endp
;-----------------------------------------------------------------------------
RestorePath proc near
             pusha
             pushf
AAA1:
             lodsb
             cmp al,20h
             je AAA3
             cmp al,0Dh
             jne AAA2
AAA3:
             mov al,0
AAA2:
             stosb
             cmp al,0
             je ExitParam1
             jmp short AAA1
ExitParam1:
             sub di,2
             mov si,di
             lodsb
             cmp al,'\'
             jne ExitParam2
             xor ax,ax
             stosb
ExitParam2:
             popf
             popa
             ret
RestorePath endp
;-----------------------------------------------------------------------------
;ÇïéÑ:
;DS:SI - ÄÑêÖë àëäéåéâ ëíêéäà
;ES:DI - ÄÑêÖë Ñãü èéàëäÄ
;CX - äéãàóÖëíÇé ÅÄâí Ñãü ëêÄÇçÖçàü
;BX - ÑãàçÄ àëäéåéâ ëíêéäà
;ÇõïéÑ:
;DI    - ëåÖôÖçàÖ Ç ëÖÉåÖçíÖ Öëãà çÄòãà, Ç èêéíàÇçéå ëãìóÄÖ 0FFFFH
concatenat_string_in_memory proc near
             push ax
             push dx
             cld
             mov al,byte ptr ds:[si]
next_find_string:
             repne scasb
             je found_first_char
             mov di,0ffffh
             jmp end_find_string
found_first_char:
             push cx
             push di
             push si
             mov cx,bx
             dec di
             repe cmpsb
             je found_string
             pop si
             pop di
             pop cx
             jmp next_find_string
found_string:
             pop si
             pop di
             dec di
             pop cx
end_find_string:
             pop ax
             pop dx
             ret
concatenat_string_in_memory endp
;-----------------------------------------------------------------------------
