.386p                                   ; 386 opcodes
.model      flat,stdcall                ; Written for flat Win32
option      casemap:none                ; Use mixed case symbols
assume      fs:nothing                  ; Required for MASMs SEH
include     c:\masm32\inc\windows.inc   ; Win32 Constant/Structs
include     c:\masm32\inc\kernel32.inc  ; Imports
include     c:\masm32\inc\imagehlp.inc
includelib  c:\masm32\lib\kernel32.lib  ; Imports
includelib  c:\masm32\lib\imagehlp.lib

.DATA
    HexBuffer   DB 0, 0, 0, 0, 0, 0, 0, 0
    HexTables   DB '0123456789ABCDEF'
    NewLine     DB 0dh, 0ah
    TheFile     DB 'Kittens.TXT', 0

.CODE
Display     PROC    USES EAX EBX ECX EDX EDI ESI,
                    STRING:DWORD,
                    NUMBER:DWORD
            LOCAL   WRITTEN:DWORD,
                    CONSOLE:DWORD

    INVOKE  GetStdHandle, STD_OUTPUT_HANDLE
    mov     [CONSOLE],    eax
    INVOKE  lstrlen, [STRING]
    mov     [WRITTEN],    eax

    mov     eax, [NUMBER   ]
    lea     edi, [HexBuffer]
    mov     ecx, 8
    .REPEAT
            rol     eax, 4
            mov     edx, 0fh
            and     edx, eax
            mov     edx, dword ptr [HexTables][edx]
            mov     [edi], dl
            inc     edi
    .UNTILCXZ

    cmp     [STRING], 0
    je      @F
    INVOKE  WriteFile, [CONSOLE], [STRING],  [WRITTEN], ADDR [WRITTEN], 0
@@: INVOKE  WriteFile, [CONSOLE], ADDR [HexBuffer], 8,  ADDR [WRITTEN], 0
    INVOKE  WriteFile, [CONSOLE], ADDR [NewLine],   2,  ADDR [WRITTEN], 0
    ret
Display     ENDP

LoadSEH     MACRO   SAFE:REQ
    push    ebp
    lea     eax, [ &SAFE    ]
    push    eax
    lea     eax, [HANDLER]
    push    eax
    push    fs:[0]
    mov     fs:[0],       esp
ENDM        LoadSEH
    
ExitSEH     MACRO
    pop     fs:[0]
    add     esp, 12
ENDM        ExitSEH

WinMain:
    LoadSEH Safe

    INVOKE CreateFileA, ADDR TheFile, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
    INVOKE Display, 0, eax

Safe:
    ExitSEH

    INVOKE  Display, 0, -1
    INVOKE  ExitProcess, NULL

HANDLER                     PROC C \
                            USES EBX ECX EDX ESI EDI,
                            pExceptionRecord  :DWORD,
                            pEstablisherFrame :DWORD,
                            pContextRecord    :DWORD,
                            pDispatcherContext:DWORD

    MOV     EAX, [pExceptionRecord]
    CMP     [EAX][EXCEPTION_RECORD.ExceptionFlags], EXCEPTION_CONTINUABLE
    JNE     HANDLER_ABORT
    
    LEA     EAX, @F
    INVOKE  RtlUnwind, [pEstablisherFrame], EAX, [pExceptionRecord], \
            [pEstablisherFrame]
@@: MOV     ESI, [pContextRecord]
    PUSH    [EAX][8]
    POP     [ESI][CONTEXT.regEip]
    PUSH    [EAX][12]
    POP     [ESI][CONTEXT.regEbp]
    ADD     EAX, 16
    MOV     [ESI][CONTEXT.regEsp], EAX
    MOV     EAX, ExceptionContinueExecution
    RET
    
HANDLER_ABORT:
    MOV     EAX, ExceptionContinueSearch
    RET

HANDLER                     ENDP
END         WinMain
