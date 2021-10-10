;INTERFACE

;AllocMem proc near
;P_MSG Exit to Dos with show message

;IMPLEMENTATION
;**************************************************************************
AllocMem proc near
        mov ax,ds
        mov es,ax
        mov bx,1100h
        mov ah,4ah
        int 21h
        jnc ALLOCATED
NOT_ALLOCATED:
        lea dx,NO_MEM
        jmp P_MSG
ALLOCATED:
        lea ax,LBL
        mov cl,4
        shr ax,cl
        inc ax
        mov bx,ds
        add ax,bx
        mov FSEG,ax
        retn
AllocMem endp
;**************************************************************************
P_MSG:
        call Write
        jmp Beenden
;**************************************************************************
