;Codegenerator (c) 1999 by RedArc

;----------------------------------------------------------------------------
_PREPARE_JUMPS:
        pusha
        mov bx,BuffBegin
;--- Локализация первого блока тушки
        mov al,0
        call Get_Block
        mov di,bx
        call CalcJump
;* Большой цикл расстановки переходов между блоками
        mov cx,0
@PJ0:
        mov al,cl
        call Get_Jump
        mov al,cl
        inc al
        call Get_Block
        call CalcJump
        inc cx
        cmp cx,CouAllBlock+1
        jl @PJ0
;* jmp _Manager
        mov si,bp
        mov al,29
        call Get_Jump
        call CalcJump
;* jmp _Interrupt
        mov al,63
        call Get_Jump
        mov al,44
        call Get_Block
        call CalcJump
;* jmp _TF0
        mov al,101
        call Get_Jump
        mov al,63
        call Get_Block
        call CalcJump
;* jmp _CloseFile
        mov al,122
        call Get_Jump
        mov al,93
        call Get_Block
        call CalcJump
;* Адреса переходов в вынужденных блоках
         mov al,45
         call Get_Block
         add si,2
         xchg si,di
         push di
         mov al,46
         call Get_Block
         call CalcJump
         pop di
         add di,3
         mov al,59
         call Get_Block
         call CalcJump
;*
         mov al,51
         call Get_Block
         add si,2
         xchg si,di
         push di
         mov al,52
         call Get_Block
         call CalcJump
         pop di
         add di,3
         mov al,53
         call Get_Block
         call CalcJump
;*
         mov al,62
         call Get_Block
         add si,2
         xchg si,di
         push di
         mov al,63
         call Get_Block
         call CalcJump
         pop di
         add di,3
         mov al,64
         call Get_Block
         call CalcJump
;*
         mov al,65
         call Get_Block
         add si,2
         xchg si,di
         push di
         mov al,63
         call Get_Block
         call CalcJump
         pop di
         add di,3
         mov al,66
         call Get_Block
         call CalcJump
;*
         mov al,92
         call Get_Block
         add si,2
         xchg si,di
         push di
         mov al,102
         call Get_Block
         call CalcJump
         pop di
         add di,3
         mov al,93
         call Get_Block
         call CalcJump
;---
        popa
        ret
;----------------------------------------------------------------------------
_PREPARE_CONST:
        pusha
;--- Получение размера кода в буфере
        mov cx,di
        sub cx,BuffBegin
;* Расстановка констант
        mov al,12
        call Get_Block
        mov word ptr ds:[si+2],cx
;*
        mov al,18
        call Get_Block
        mov word ptr ds:[si+2],cx
;*
        mov al,30
        call Get_Block
        xchg si,di
        mov al,29
        call Get_Block
        sub di,BuffBegin-100h
        mov word ptr ds:[si+1],di
;*
        mov al,31
        call Get_Block
        mov word ptr ds:[si+2],cx
;*
        mov al,77
        call Get_Block
        mov word ptr ds:[si+2],cx
;*
        mov al,115
        call Get_Block
        mov word ptr ds:[si+2],cx
;*
        mov di,766
        mov si,word ptr ds:[di]
        mov word ptr ds:[si+1],cx
;---
        popa
        ret
;----------------------------------------------------------------------------
