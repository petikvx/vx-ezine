;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;룼ㄳ�獸˚� � 쭬蟯耀���с pⅵº�
;귣若�: CF = 0 - 뙫┃� �쩺ε�ㄸ筍 � 쭬蟯耀��硫 pⅵº
;       CF = 1 - 롨Æ첓 ��ㄳ�獸˚�
prepare_to_protect_mode:
        pusha
        call     init_prepare_to_protect_mode
init_prepare_to_protect_mode:
        pop      bp
        mov      ax,1687h                ;IS DPMI here ?
        int      2Fh
        or       ax,ax
        jnz      no_DPMI_present
        ;귣若�: ES:DI - DPMI Entrypoint
        ;          SI - 뫇�レぎ �pⅰ濕恂� � 캙p젫p졽졾 DPMI ㄻ� PRIVATE DATA
        mov      word ptr ds:[bp+dpmi_entrypoint-init_prepare_to_protect_mode],di
        mov      word ptr ds:[bp+dpmi_entrypoint-init_prepare_to_protect_mode+2],es
        ;뫌�p젺º 飡쟰硫 �죖젩�洵Ø INT 21
        mov      ax,3521h
        int      21h
        ;귣若�: ES:BX - 飡쟰硫 �죖젩�洵Ø
        mov      word ptr ds:[bp+old_int21-init_prepare_to_protect_mode],bx
        mov      word ptr ds:[bp+old_int21-init_prepare_to_protect_mode+2],es
        ;볚�젺�˘� 췅� �죖젩�洵Ø
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
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
back_to_real:
        pop      di
        mov      ax,4CFFh
        int      21h
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
DPMI_call:
        db       9Ah
dpmi_entrypoint:
        dd       00000000h
        retn
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
