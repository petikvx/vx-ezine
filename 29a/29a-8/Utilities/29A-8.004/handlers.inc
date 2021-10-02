.data
libc_ptable equ this byte
        libc_api __libc_start_main
        libc_api printf
        dd 0,0


.code
__libc_start_main:
        ;***process cmdline
        call dword ptr [esp+8]
        invoke ExitProcess,eax


PRINTF_PARAMS EQU 8

printf:
        mov ecx,PRINTF_PARAMS
        lea eax,[esp+(PRINTF_PARAMS*4)+4]
        push esi
        sub esp,MAX_PATH
        mov esi,esp
  @@:
        push [eax]
        sub eax,4
        loop @b
        push esi
        call wsprintf
        invoke StdOut,esi
        lea esp,[esp+MAX_PATH+(PRINTF_PARAMS*4)+8]
        pop esi
        ret

