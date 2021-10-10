;KillSMEG (c) 1994 Stormbriner, Phalcon/Skism
;Вольный перевод с "ихнего" на "наш" by DrMad, 1998

;Finds and disinfects the original SMEG viruses (Pathogen and Queeg)
;Ищет и обезвреживает оригинальные SMEG-вирусы (Pathigen и Queeg).

;Author assumes NO responsibility for any damages caused by this program
;or by the SMEG viruses themselves.  This utility is simply made to find it,
;and may or may not work as it is supposed to.  No garuantees.

;Автор принимает никакой ответственности за любые повреждения,  нане-
;сенные программой  или  сами SMEG-вирусами.  Эта утилита просто на-
;писана для поиска их, и может либо работать, либо нет, что вполне
;допустимо. Никаких гарантий.

;First phase is to look for time signatures.  The seconds in any Queeg
;infected file (unless something else has changed timestamp after infection)
;is 56 seconds (1c in bits 0-4 of the time sig).  All following Checks are
;done regardless of the time sig check.  Pathogen marks infections by making
;the high byte in the date > 0c8h

;Первая фаза  предназначена для поиска временных сигнатур.  Для
;любого файла,  зараженного Queeg (разве что, если что-нибудь иное из-
;менило метку  времени после инфицирования) количество секунд равно 56
;( число !C в битах 0-4 метки времени).  Все следующие проверки выпол-
;няются вне  зависимости  от  результатов  контроля  временной  метки.
;Pathogen помечает инфицированные объекты помещением  числа, большего,
;чем 0C8h в старший байт даты.

;Second Phase on each file is to Check if it's an .EXE or a .COM.

;Вторая фаза для каждого файла это проверка на .ЕХЕ или .СОМ.

;Third phase is to trace the program until an invalid condition is found or
;the virus is detected.

;Третья фаза - это трассировка программы до тех пор,  пока не  выпол-
;нено будет недопустимое условие, либо не будет обнаружен вирус.

;Finally, the user is asked if s/he wishes to disinfect the virus, and
;the file is cleaned.

;Наконец, пользователя спрашивают, хочет ли он/она убить виря, и файл
;очищается.

Strengths:
Преимущества:

;       VERY reliable detection rate from my testing.

;       Очень высокий уровень обнаружения в моих тестах

;       Currently only free program capable of disinfecting SMEG viruses,
;       especially from .EXE files.

;       В настоящще время единственная бесплатная программа, способная
;       обезвреживать SMEG-вирусы, особенно в .ЕХЕ-файлах.

;       Comes with full source code.

;       Поставляется с сырками.

;Weaknesses:
;Недостатки:

;       Third phase is slow(!!!), and actually executes part of program,
;       although it is careful not to allow detrimental actions to be taken
;       (i.e. viruses cannot go memres, etc.)

;       Третья фаза медленная и фактически выполняет часть программы,
;       хотя осторожно не допускает опасных операций (т.е вирусы не
;       смогут сесть в память и пр.)

;
;       Only scans current directory using user filemask.

;       Сканирует только текущий каталог по ользовательской маске.

;       Disinfection will leave some garbage at the end of files,
;       as the virus pads its hosts to the paragraph boundaries.
;       This will cause self-checking programs to choke.

;       Обезвреживание будет оставлять некоторый мусор в конце файлов,
;       поскольку вирус выравнивает длину на границу параграфа.
;       Это может вызвать тревогу у программ, проверяющих свою
;       целостность .

.model tiny
.radix 16
.code
        org 100
start:
ReduceMem:
        mov     ah,4a
        mov     bx,(endfinder-start+10f)/10     ;Reduce Memory to that needed
        int     21

        mov     sp,offset TopStack              ;Set STack within memory

        mov     ah,09
        mov     dx,offset IntroMSG
        int     21

        cmp     byte ptr ds:[80],1
        ja      CopyFilename
        mov     ah,09
        mov     dx,offset Instructions
        int     21
        mov     ax,4c00
        int     21
CopyFilename:
        mov     si,82
        mov     di,offset Filenamebuf
    CopyFN:
        lodsb
        cmp     al,0dh
        je      doneCFN
        stosb
        jmp     CopyFN
doneCFN:
        xor     al,al
        stosb

ComSearch:
        mov     ah,4e
        mov     dx,offset FilenameBuf
        mov     cx,07
  FindFirstNext:
        int     21
        jnc     SearchGood
        jmp     NoMoreCOMS
  SearchGood:
        call    notifycheck

        mov     cx,ds:[96]
        and     cl,1f
        cmp     cl,1c                   ;Check time stamp (56 seconds)
        jne     AfterTimeCheck1
        call    SuspiciousTime
  AfterTimeCheck1:
        mov     cx,ds:[98]
        cmp     ch,0c8
        jb      AfterTimeCheck
        call    PathTime

  AfterTimeCheck:
        mov     ax,3d00
        mov     dx,9e
        int     21
        jnc     ATCGood
        jmp     ErrorOpen
  ATCGood:
        xchg    bx,ax
        mov     dx,offset EXECCheck
        mov     cx,4
        mov     ah,3f
        int     21
        mov     ah,3e
        int     21                              ;Close File
        mov     ax,word ptr ds:[ExecCheck]
        xor     ah,al
        cmp     ah,('M' xor 'Z')                ;Check if it's a com or exec
        je      ISEXE
        push    cs
        pop     es
        mov     di,offset JmpByte
        mov     si,offset ExecCheck             ;Save Jump
        movsb
        movsw
        mov     byte ptr ds:[COMEXE],0
        jmp     short OtherChecks
    ISEXE:
        mov     byte ptr ds:[COMEXE],1
  OtherChecks:
        mov     Infected,0                      ;Initialize to not infected
        mov     TraceDone,0
        call    LoadAndCheckFile                ;Trace file
        cmp     Infected,1
        jne     FindAnotherFile

        call    PrintFilename
        cmp     Knownvir,1
        je      DisinfectProg
        mov     ah,09
        mov     dx,offset NewVar
        int     21
        jmp     FindAnotherFile

DisinfectProg:
        mov     ah,09
        mov     dx,offset InfectedMSG
        int     21

        xor     ax,ax
        int     16
        push    ax
        mov     dx,offset DoneChecking
        mov     ah,09
        int     21
        pop     ax
        or      al,20
        cmp     al,'y'
        jne     FindAnotherFile
   Disinfect:
        cmp     comexe,1
        je      DisEXE
        call    DisinfCom
        jmp     short FindAnotherFile
   DisEXE:
        call    DisinfExe
  FindAnotherFile:
        mov     ah,4f
        jmp     FindFirstNext

ErrorOpen:
        call    PRintFilename
        mov     ah,09
        mov     dx,offset OpenError
        int     21
        jmp     FindAnotherFile

NoMoreCOMS:
        mov     ax,4c00
        int     21

SuspiciousTime:
        call    PrintFilename
        mov     ah,09
        mov     dx,offset TIMEMSG
        int     21
        ret
PathTime:
        call    printfilename
        mov     ah,09
        mov     dx,offset pathtimemsg
        int     21
        ret


NotifyCheck:

        mov     dx,offset Checking
        mov     ah,09
        int     21
        call    PrintFileName
        mov     dx,offset DoneChecking
        mov     ah,09
        int     21
        ret


PrintFilename:
        mov     si,9e
  PrintFN:
        lodsb
        or      al,al
        jz      doneprintfn
        mov     ah,02
        mov     dl,al
        int     21
        jmp     Printfn
    DonePrintFN:
        ret

LoadAndCheckFile:
        push    cs
        pop     ds
        mov     ax,ds:[2c]
        mov     EnvSeg,ax
        mov     ax,ds
        mov     word ptr [CommandTail+2],ax
        mov     word ptr [FCB1+2],ax
        mov     word ptr [FCB2+2],ax
        mov     ax,offset ParmData
        mov     word ptr [CommandTail],ax
        mov     word ptr [FCB1],ax
        mov     word ptr [FCB2],ax

        mov     ax,3501
        int     21
        mov     IP01,bx
        mov     CS01,es         ;Get int 1 vector

        mov     ax,2501
        mov     dx,offset Int01  ;And set it
        int     21
        mov     ax,ss
        mov     Oldss,ax
        mov     oldsp,sp
        push    cs
        pop     es

     LoadFile:
        mov     ax,4b01
        mov     bx,offset ParmBlock
        mov     dx,9e
        int     21
        jc      ErrorExecute
    SetupExec:
        push    cs
        pop     ds
        mov     ax,2522
        mov     dx,offset ExecuteTerminated
        int     21                              ;Set Termination address

        mov     ah,62
        int     21
        push    bx bx
        pop     es ds

        mov     word ptr cs:[StartDS],bx

        mov     ax,cs
        mov     word ptr ds:[0a],offset ExecuteTerminated
        mov     word ptr ds:[0c],ax                      ;Set Termination Address

        cli
        mov     ax,word ptr cs:[NewStack+2]
        mov     ss,ax
        mov     sp,word ptr cs:[NewStack]
        sti

        pushf
        pop     ax
        or      ax,0100
        xor     bx,bx
        xor     cx,cx
        xor     dx,dx
        mov     si,100
        xor     di,di
        xor     bp,bp
        push    word ptr cs:[NewCS]
        push    word ptr cs:[NewIP]
        push    ax
        popf
        retf

ExecuteTerminated:
        cld
        pushf
        pop     ax
        and     ax,not 100      ;ditch trapflag
        push    ax
        popf
        cli
        mov     ax,cs:[OldSS]
        mov     ss,ax
        mov     sp,cs:[OldSP]
        sti
        lds     dx,dword ptr cs:[IP01]
        mov     ax,2501
        int     21
        push    cs cs
        pop     es ds

        mov     ah,1a
        mov     dx,80                   ;Reset DTA
        int     21
   ErrorExecute:
        ret

OldSS   dw      0
OldSP   dw      0


Int01:
        cld
        push    bp
        mov     bp,sp
        add     bp,2
        push    ax bx cx dx es ds si di
        cmp     cs:TraceDone,1
        je      DOneInt01
        call    CheckESDS
        call    CheckOPCode
        jne     DoneInt01
        call    InitScanString
        call    ScanMemory
        call    InitScanString

   DoneInt01:
        pop     di si ds es dx cx bx ax
        pop     bp
        iret

InitScanString:
        push    ds si cx
        push    cs
        pop     ds
        mov     si,offset QueegScan1
        mov     cx,EndScan1-QueegScan1
   DecryptString:
        xor     byte ptr [si],42
        inc     si
        loop    DecryptString
        pop     cx si ds
        ret

TerminateProgram:
        mov     byte ptr cs:[TraceDone],1
        mov     ax,4c00
        int     21

CheckOpCode:
        mov     si,[bp+2]
        mov     ds,si
        mov     si,[bp]
        cmp     byte ptr dS:[si],0cdh
        je      NonvalidOp
        cmp     byte ptr ds:[si],0eah
        je      NonvalidOp
        cmp     byte ptr ds:[si],09ah
        je      NonvalidOp
        cmp     byte ptr ds:[si],0abh
        je      NonvalidOp
        cmp     byte ptr ds:[si],0adh
        je      NonvalidOp
        mov     al,byte ptr ds:[si]
        and     al,0f0
        cmp     al,60
        je      NonvalidOp
        cmp     al,90
        je      NonvalidOp
        cmp     al,0a0
        je      NonvalidOp
        cmp     word ptr ds:[si],00e8
        jne     ExitOpTest
        cmp     word ptr ds:[si+2],5800
  ExitOpTest:
        ret

NonValidOp:
        jmp     TerminatePRogram


CheckESDS:
        mov     ax,[bp+2]
        cmp     ax,word ptr cs:[NewCS]
        je      CSOkay
        jmp     TerminateProgram
CSOkay:
        mov     ax,[bp+2]
        mov     bx,ds
        cmp     bx,ax
        jne     DSNotEqualCS
  CheckES:
        mov     bx,es
        cmp     bx,ax
        jne     ESNotEqualCS
  ExitSEGCheck:
        ret
DSNotEqualCS:
        cmp     bx,word ptr cs:[StartDS]
        je      CheckES
        mov     byte ptr cs:[TraceDone],1
        jmp     TerminateProgram
   ESNotEqualCS:
        cmp     bx,word ptr cs:[StartDS]
        je      ExitSEGCheck
        mov     byte ptr cs:[TraceDone],1
        jmp     TerminateProgram

ScanMemory:
        push    cs
        pop     ds
        mov     si,offset QueegScan1
        mov     di,[bp+2]
        mov     es,di
        mov     di,[bp]
        mov     cx,800
        lodsb
   SearchForString:
        repnz   scasb
        jcxz    StringNotFound
        push    ax cx si di
        mov     cx,0bh
        repz    cmpsb
        jcxz    StringFound
        pop     di si cx ax
        jmp     SearchForString
StringFound:
        pop     di si cx ax
SaveInfo:
        dec     di              ;ES:DI = beginning of virus
        push    es di
        pop     si ds

;ds:si+133       22 c0 75 19 bb 00 01 2e a1
     MakeSureKnowVir:
        cmp     word ptr ds:[si+33],0c022
        jne     NotKnown
        cmp     word ptr ds:[si+39],2e01
        jne     NotKnown
        mov     byte ptr cs:[knownvir],1
        jmp     DoneVarCheck
     NotKnown:
        mov     byte ptr cs:[knownvir],0
     DoneVarCheck:
        mov     bx,si
        sub     bx,100

        mov     si,word ptr ds:[bx+13c]
        add     si,bx
        push    cs
        pop     es
        mov     di,offset COMStorage
        movsw
        movsb

        mov     si,word ptr ds:[bx+164]
        add     si,bx
        mov     di,offset EXEStack
        movsw
        movsw

        mov     si,word ptr ds:[bx+171]
        add     si,bx
        mov     di,offset EXEInstruct
        movsw
        movsw
MarkInfected:
        mov     byte ptr cs:[Infected],1
        call    InitScanString
        jmp     TerminateProgram
StringNotFound:
        ret

OutOfMemory:
        mov     dx,offset OOM
 ErrExit:
        push    cs
        pop     ds
        mov     ah,9
        int     21
        mov     ax,4c02
        int     21

ErrorClean:
        mov     dx,offset FileError
        mov     ah,09
        push    cs
        pop     ds
        int     21
        jmp     Dealloc

DisinfCom:
        mov     ah,48
        mov     bx,1000
        int     21
        jc      OutOfMemory
        mov     es,ax
        mov     dx,9e
        mov     ax,3d00
        int     21
        jc      ErrorClean
        xchg    bx,ax
        push    es
        pop     ds
        xor     dx,dx
        mov     cx,word ptr cs:[ComJump]
        add     cx,3
        mov     ah,3f
        int     21
        push    ax
        mov     ah,3e
        int     21
        mov     ax,word ptr cs:[COMStorage]
        mov     word ptr ds:[0],ax
        mov     al,byte ptr cs:[ComStorage+2]
        mov     byte ptr ds:[2],al
        push    cs
        pop     ds
        mov     ah,3c
        xor     cx,cx
        mov     dx,9e
        int     21
        pop     cx
        jc      ErrorClean
        xchg    bx,ax

        push    es
        pop     ds
        mov     ah,40
        xor     dx,dx
        int     21

        mov     ah,3e
        int     21
  DeAlloc:
        mov     ah,49
        int     21
        push    cs cs
        pop     es ds
        ret

EXEErrorClean:
        mov     dx,offset FileError
        mov     ah,09
        push    cs
        pop     ds
        int     21
        ret


DisinfEXE:
        int     3
        mov     ah,41
        mov     dx,offset TMPFile
        int     21

        push    cs cs
        pop     es ds
        mov     dx,9e
        mov     ax,3d02        ;open file
        int     21
        jnc     EXECOpenGood
        jmp     EXEErrorClean
     ExecOpenGood:
        xchg    bx,ax
        mov     cx,20
        mov     ah,3f
        mov     dx,offset ExecHeader
        int     21
        mov     di,offset Execheader+0e
        mov     si,offset ExeStack
        movsw
        movsw
        xor     bp,bp
        mov     di,offset execheader+14
        mov     dx,[di+2]               ;DX:AX = new filesize kinda
        mov     ax,[di]
        mov     cl,4
        shl     dx,cl
        adc     bp,0
        add     ax,dx
        adc     bp,0
        mov     dx,bp                   ;DX:AX = filesize w/o header
        mov     cx,word ptr [execheader+08]
        shl     cx,1
        shl     cx,1
        shl     cx,1
        shl     cx,1
        add     ax,cx
        adc     dx,0                    ;Header now calculated in
        mov     ExeSizeHigh,dx
        mov     ExeSizeLow,ax
        and     ax,1ff                      ;modulo 512
        mov     word ptr [execheader+2],ax
        mov     ax,EXESizeLow
        mov     cx,7
        shl     dx,cl
        mov     word ptr [execheader+4],dx
        mov     cx,9
        add     ax,1ff
        shr     ax,cl
        add     word ptr [execheader+4],ax

        mov     si,offset ExeInstruct
        movsw
        movsw

        mov     ax,4200
        xor     cx,cx
        xor     dx,dx
        int     21
        mov     ah,40
        mov     dx,offset execheader
        mov     cx,20
        int     21
        mov     ah,3e
        int     21

        mov     ah,56
        mov     dx,9e
        mov     di,offset TmpFile       ;Rename file
        int     21

        mov     ah,3c
        mov     dx,9e
        xor     cx,cx
        int     21
        mov     Dest,ax
        mov     ax,3d00
        mov     dx,offset TmpFile
        int     21
        mov     Source,ax

     CopyLoop:
        mov     cx,400
        cmp     word ptr [EXESizeHIgh],0
        jne     FullSize
        cmp     word ptr [ExeSizeLow],400
        ja      FullSize
        mov     cx,word ptr [ExeSizeLow]
    FullSize:
        sub     word ptr [ExeSizeLow],400
        sbb     word ptr [ExeSizeHigh],0
        mov     ah,3f
        mov     bx,Source
        mov     dx,offset CopyBuffer
        int     21

        mov     cx,ax
        mov     ah,40
        mov     bx,Dest
        mov     dx,offset CopyBuffer
        int     21

        cmp     ax,400
        je      CopyLoop

CloseUP:
        mov     ah,3e
        mov     bx,Dest
        int     21
        mov     ah,3e
        mov     bx,Source
        int     21
 DoneDis:
        mov     ah,41
        mov     dx,offset TMPFile
        int     21
        ret

Source   dw      0
Dest    dw      0
OldInt01:
        IP01    dw      0
        CS01    dw      0

TraceDone       db      0
StartDS         dw      0


ParmBlock:
   EnvSeg       dw      0
   CommandTail  dd      0
   FCB1         dd      0
   FCB2         dd      0
   NewStack     dd      0
   NewIP        dw      0
   NEWCS        dw      0

Tmpfile         db      'KQTMP',0
NewVar          db      ' - New Variant of SMEG!',0a,0dh,24
FileError       db      'Sorry, File Error.',07,0a,0dh,24
OOM             db      'Sorry, Out Of Memory',07,0a,0dh,24
Checking        db      'Checking $'
OpenError       db      ' - Error Opening.'
DoneChecking    db      0a,0dh,24
TimeMSG         db      ' - Time stamp is suspicious of SMEG.Queeg signature.',0a,0dh,24
pathtimemsg     db      ' - Time stamp is suspicious of SMEG.Pathogen signature.',0a,0dh,24
InfectedMSG     db      ' - INFECTED WITH SMEG!',0a,0dh
                db      'Disinfect (y/N)?',7,24
IntroMSG        db      0a,0dh,'KillSMEG (c) 1994 Stormbringer, Phalcon/Skism.',0a,0dh
                db      'Finds and disinfects the 2 known SMEG viruses in the current directory.',0a,0dh,24

Instructions:
                db      'Usage :    KILLSMEG Filemask (COM once, then EXE once is recommended)',0a,0dh
                db      'Example:   KILLSMEG *.COM',0a,0dh,24

QueegScan1:
db 0E8 xor 42, 00 xor 42, 00 xor 42, 58 xor 42, 0FE xor 42, 0CC xor 42
db 0B1 xor 42, 04 xor 42, 0D3 xor 42, 0E8 xor 42, 08C xor 42, 0CBh xor 42      ;Initializing Code
EndScan1:
;QueegScan2:
;db 0B8, 0EF, 18, 0CDh, 21, 3Dh, 10, 0E7, 75, 01, 0C3, 0E8    ;Installation Check


ParmData        db      40 dup(0)
knownvir        db      0
Jmpbyte         db      0
COMJump         db      0,0

Infected        db      0
COMEXE          db      0                       ;0 for COM, 1 for EXE
EXECCheck       dw      0,0

COMStorage      db      0,0,0
EXEStack        dd      0
EXEInstruct     dd      0

;0f9d-SP  0f9b-SS  0fa0-IP:CS
ExeSizeLow      dw      0
EXESizeHigh     dw      0


Filenamebuf     db      80d dup (?)
ExecHeader      db      20 dup(?)
CopyBuffer      db      400 dup(?)
StackBuffer db  1000 dup(?)
TopStack:

endfinder:
end start
