; Пример перехвата файловой системы
;
include 	ring09x.inc

DEBUG = 1

.386p
.model flat

extrn ExitProcess:PROC

.data

_Start:
                call      init
init:
                pop       EBP
                sub       EBP, offset(init - _Start)
                pusha
                call      set_seh                        ; install our SEH
                mov       ESP, [ESP + 8]
                jmp       short Exit_Main
set_seh:
                push      4 ptr FS:[0]
                mov       FS:[0], ESP
                call      get_r0                        ; get callgate addr
                call      ring0_proc
                retf                                 ; back to r3
get_r0:
                pop       ESI                        ; ESI = callgate addr
                push      EBX                        ; get GDT addr
                sgdt      [ESP - 2]
                pop       EBX
                sldt      AX                         ; get LDT selector
                and       EAX, not 111b
                jz        short Exit_Main
                add       EBX, EAX                   ; LDT descriptor addr in GDT
                mov       EDI, [EBX + 2 - 2]         ; get LDT addr
                mov       AH, [EBX + 7]
                mov       AL, [EBX + 4]
                shrd      EDI, EAX, 16
                fild      8 ptr [EDI]                ; save descriptor
                mov       EAX, ESI                   ; make new callgate descriptor
                cld
                stosw
                mov       EAX, 1110110000000000b shl 16 + 28h
                stosd
                shld      EAX, ESI, 16
                stosw
                db        9Ah                        ; call callgate
                dd        0
                dw        100b + 11b                 ; sel.#0, LDT, r3
                fistp     8 ptr [EDI - 8]            ; restore descriptor
Exit_Main:
                pop       4 ptr FS:[0]               ; rem SEH
                pop       EAX
                popa
                retn

ring0_proc:                                ; Код, работающий в ring 0
                pushad

                ; alloc sys mem
                push      PAGEFIXED + PAGEZEROINIT
                xor       EAX, EAX
                push      EAX                     ; PhysAddr
                push      EAX                     ; maxPhys
                push      EAX                     ; minPhys
                push      EAX                     ; Align
                push      EAX                     ; handle of VM = 0 if PG_SYS
                push      PG_SYS                  ; allocate mem in sys area
                push      1                       ; nPages
                VMMcall   PageAllocate
                add       ESP, 32
                or        EAX, EAX                ; check for error
                jz        short exit_r0
                push      EAX

                cld
                mov       EDI, EAX
                lea       ESI, [EBP+IFSAPI_handler-_Start]
                mov       ECX, IFSAPI_handler_Len
                rep movsb

                jc        exit_r0
                xchg      EAX, EDI

                pop       ESI   ; адрес выделенной памяти
                push      ESI
                push      ESI
                VxDcall   IFSMGR, InstallFileSystemApiHook
                add       SP, 4
                pop       EDI
                ; save prev handler
                mov       [EDI + old_IFSAPI - IFSAPI_handler], EAX

exit_r0:
                popad
                retn			; r0 end

IFSAPI_handler:				; Наш обработчик IFS API	
                pushad

; Здесь строим имя файла, с которым в данный момент происходит какое
; либо действие:

                lea        EDI, [EBP + filepath - IFSAPI_handler]
                mov        EAX, drive                ; drive
                or         AL, AL
                jle        End_IFSAPI_handler
                lea        EBX, ioreq_ptr                ; ptr to IOREQ struct

                add        AL, 64
                stosb
                mov        AL, ':'
                stosb
                push       0
                push       7Fh
                mov        EBX, [EBX]
                mov        EAX, [EBX + 0Ch]
                add        EAX, 4
                push       EAX
                push       EDI
                VxDcall    IFSMGR, UniToBCSPath
                add        ESP, 10h
                or         EDX, EDX
                jne        End_IFSAPI_handler
                mov        EDX, EDI
                sub        EDX, 2                  ; EDX -> file name
                add        EDI, EAX                ; EDI -> file name end
                mov        1 ptr [EDI], 0          ; make a null term str

; Теперь EDX указывает на имя файла, используя функции, описанные
; в ring09x.inc можно делать всё что угодно! :)			

Exit_IFSAPI_handler:
                popad
                db        0FFh, 25h                ; jmp на старый обработчик
old_IFSAPI label dword
                dd        0

;---------------------------------------------------------------------------
access_eax      equ     (dword ptr 7*4)

IFSAPI_handler_Len equ $ - IFSAPI_handler
.code

start:
                call        _Start
exit:
                push        00000000h
                call        ExitProcess
end start