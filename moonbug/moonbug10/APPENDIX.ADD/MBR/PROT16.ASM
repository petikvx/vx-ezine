;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;®¤£®â®¢ª  ª § é¨é¥­­®¬ã p¥¦¨¬ã
;‚ëå®¤: CF = 0 - Œ®¦­® ¯¥p¥å®¤¨âì ¢ § é¨é¥­­ë© p¥¦¨¬
;       CF = 1 - è¨¡ª  ¯®¤£®â®¢ª¨
prepare_to_protect_mode:
        pusha
        call     init_prepare_to_protect_mode
init_prepare_to_protect_mode:
        pop      bp
        mov      ax,1687h                ;IS DPMI here ?
        int      2Fh
        or       ax,ax
        jnz      no_DPMI_present
        ;‚ëå®¤: ES:DI - DPMI Entrypoint
        ;          SI - ‘ª®«ìª® âp¥¡ã¥âáï ¢ ¯ p £p ä å DPMI ¤«ï PRIVATE DATA
        mov      word ptr ds:[bp+dpmi_entrypoint-init_prepare_to_protect_mode],di
        mov      word ptr ds:[bp+dpmi_entrypoint-init_prepare_to_protect_mode+2],es
        ;‘®åp ­¨¬ áâ pë© ®¡p ¡®âç¨ª INT 21
        mov      ax,3521h
        int      21h
        ;‚ëå®¤: ES:BX - áâ pë© ®¡p ¡®âç¨ª
        mov      word ptr ds:[bp+old_int21-init_prepare_to_protect_mode],bx
        mov      word ptr ds:[bp+old_int21-init_prepare_to_protect_mode+2],es
        ;“áâ ­®¢¨¬ ­ è ®¡p ¡®âç¨ª
        mov      ax,2521h
        lea      dx,[bp+our_int21-init_prepare_to_protect_mode]
        int      21h
        popa
        clc
        retn
no_DPMI_present:
        popa
        stc
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
back_to_real:
        pop      di
        mov      ax,4CFFh
        int      21h
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
our_int21:
        cmp      ax,4CFFh
        jnz      exit_int21
        add      sp,8h
        pusha
        push     ds
        push     cs
        pop      ds
        call     init_our_int21
init_our_int21:
        pop      bp
        mov      ax,2521h
        lds      dx,dword ptr ds:[bp+old_int21-init_our_int21]
        int      21h
        pop      ds
        popa
        push     di
        retn
exit_int21:
        db       0EAh
old_int21:
        dd       00000000h
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DPMI_call:
        db       9Ah
dpmi_entrypoint:
        dd       00000000h
        retn
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
