;********** Разборка коммандной строки **********************************
TEST_PARAM:
cmp byte ptr cs:[80h],0
        jnz FIRST_PARAM
RETURN:
        ret
FIRST_PARAM:
        mov ax,ds
        mov es,ax
        cld
;--------------------------------
TESTED_Ok:
        mov al,'o'
        call CMP_PARAM
        je Ok_Print
        mov al,'O'
        call CMP_PARAM
        je Ok_Print
        jmp TESTED_MODE
Ok_Print:
        inc Ok_byte
;-------------------------------
TESTED_MODE:
        mov al,'f'
        call CMP_PARAM
        je CURE_MODE
        mov al,'F'
        call CMP_PARAM
        je CURE_MODE
        mov MODE,0
        ret
CURE_MODE:
        mov MODE,1
        ret
;-------------------------------
CMP_PARAM:
        mov ch,0
        mov cl,cs:[80h]
        mov di,81h
repne   scasb
        ret
