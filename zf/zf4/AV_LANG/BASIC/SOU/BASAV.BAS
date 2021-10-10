'(****************************************************************************)
'(*****                     BASAV (c) 2000 by RedArc                     *****)
'(*****     Антивирусная программа на языке Microsoft QuickBasic 4.5     *****)
'(*****       специально для электронного журнала "Земский Фершал"       *****)
'(****************************************************************************)

CONST MaxSubDir = 50 'максимальное количество вложенных каталогов

CONST MaxFileLength = 32700 'буфер под открываемые файлы

CONST KnownViruses = 2
CONST MaxPartBeg = 3
CONST MaxLengthS = 20
CONST TypeBeg = 0
CONST TypeMov = 1
CONST TypeAdd = 2
CONST TypeIns = 3
CONST TypeEnd = 4
CONST TypeOvr = 5
CONST TypeSat = 6
CONST TypeUep = 7
CONST DisinfNo = 0
CONST DisinfYes = 1
CONST CryptNone = 0
CONST CryptByte0 = 1
CONST CryptByte1 = 2
CONST CryptByte2 = 3
CONST CryptWord0 = 4
CONST CryptWord1 = 5
CONST CryptWord2 = 6
CONST False = 0
CONST True = 1

TYPE TSigInfo
     SigOffset AS INTEGER
     SigLength AS INTEGER
     NumPArray AS INTEGER 'раздел в массиве SigArray
END TYPE

TYPE TBegInfo
     BytesOffset AS INTEGER
     BytesLength AS INTEGER
     BytesCrypt  AS INTEGER
     CodeOffset  AS INTEGER
     SourceOffs  AS INTEGER
END TYPE

TYPE TCrypto
     TypeCryptCode AS INTEGER
     ConstCrypCodW AS INTEGER
     ConstCrypCodB AS INTEGER
     CodeOffset    AS INTEGER
     BegOfCrypt    AS INTEGER
     LengthCrypt   AS INTEGER
END TYPE

TYPE TSignature
     VirName     AS STRING * 40
     VirNameLen  AS INTEGER
     VirLength   AS INTEGER
     TypeWrt     AS INTEGER
     Desinfect   AS INTEGER
     CryptInfo   AS INTEGER
     Crypto      AS TCrypto
     Sig1Info    AS TSigInfo
     Sig2Info    AS TSigInfo
     VirBegOffs  AS INTEGER
     NumBytesInf AS INTEGER 'раздел в массиве BytesPartIn
     BytesPartCo AS INTEGER
     TypeSat     AS INTEGER
     NameFile    AS STRING * 80
     Extension   AS STRING * 80
     CouFind     AS LONG
END TYPE

COMMON SHARED CouRecords, CouFileInfect, CouFileDesinf, AFileLength AS LONG
COMMON SHARED CouFileErased, CouVirusFind, CouVirusSkip, CouErrorFile AS LONG
COMMON SHARED CouParam%, OkMode%, CureMode%, TextMode%, FlagError%, NumOfRecord%
COMMON SHARED CP$, HOME$, START$, PARAM$, TEMP$, Flag%, CurSubDir$, CouErr&
COMMON SHARED CurFileName$, CouSubDir&, CouOpenFile&, CD&, CF&, MainDir&, Gerr&
COMMON SHARED TEMP1 AS STRING * 1, ProtokolFile

DIM SHARED SubDir$(MaxSubDir), AllSubDir%(MaxSubDir), MySubDir%(MaxSubDir)
DIM SHARED SigArray(1 TO KnownViruses, 1 TO 2, 1 TO MaxLengthS)  AS INTEGER
DIM SHARED BytesPartIn(1 TO KnownViruses, 1 TO MaxPartBeg)  AS TBegInfo
DIM SHARED Signature(1 TO KnownViruses)  AS TSignature
DIM SHARED ARGUM$(1 TO 15)
DIM SHARED FileBuff(1 TO MaxFileLength) AS STRING * 1

DECLARE FUNCTION UpStr$ (S AS STRING)
DECLARE SUB InitRecords ()
DECLARE SUB KhizhnjakFill ()
DECLARE SUB RedArc112 ()
DECLARE SUB HELP ()
DECLARE SUB Comline (NumArgs%, Args$(), MaxArgs%)
DECLARE SUB FindDir ()
DECLARE SUB KillDir ()
DECLARE SUB FindFile ()
DECLARE SUB KillFile ()
DECLARE SUB HOMEIN ()
DECLARE SUB ExtractMode ()
DECLARE SUB ExtractParam ()
DECLARE SUB SearchDir ()
DECLARE SUB SearchFile ()
DECLARE SUB ScanFile (FileName$, FileLength&)
DECLARE SUB BlockPresent (I&, J&, Len1&, Flag, Offs&)
DECLARE SUB FromBegOfFile (I&, AFName$, S$)
DECLARE SUB FromEndOfFile (I&, AFName$, S$)

ON ERROR GOTO HANDLER

'*
PRINT
PRINT "Example for ZF (c) 2000 by RedArc"

'Обнуление переменных
CouRecords = 0: CouFileInfect = 0: CouFileDesinf = 0
CouFileErased = 0: CouVirusFind = 0: CouVirusSkip = 0: CouErrorFile = 0
CouParam% = False: OkMode% = False: CureMode% = False: TextMode% = False
FlagError% = False: NumOfRecord% = 0: Flag% = 0
FOR I% = 1 TO MaxSubDir
    AllSubDir%(I%) = 0
    MySubDir%(I%) = 0
NEXT I%
CD& = 0
CF& = 0
CouSubDir& = 1
CouOpenFile& = 0
ProtokolFile = 0
CouErr& = 0

'Определение каталога старта программы
CP$ = ENVIRON$("COMSPEC")
CALL HOMEIN

'Разбор командной строки
CALL Comline(CouParam%, ARGUM$(), 10)
FOR I% = 1 TO CouParam%: PARAM$ = PARAM$ + " " + ARGUM$(I%): NEXT I%
START$ = MID$(HOME$, 1, 2)
CALL ExtractParam
IF START$ = "" THEN
   CALL HELP
END IF
IF RIGHT$(START$, 1) = "\" THEN START$ = MID$(START$, 1, LEN(START$) - 1)
CurSubDir$ = START$
SubDir$(1) = CurSubDir$

IF TextMode% = True THEN
   CouOpenFile& = CouOpenFile& + 1
   ProtokolFile = CouOpenFile&
   OPEN "BASAV.RPT" FOR APPEND AS #CouOpenFile&
   PRINT #CouOpenFile&, "---------------------------------"
   PRINT #CouOpenFile&, "Example for ZF (c) 2000 by RedArc"
   PRINT #CouOpenFile&, ""
   PRINT #CouOpenFile&, "BASAV.EXE "; PARAM$
   PRINT #CouOpenFile&, "Date: "; DATE$; "   Time: "; TIME$
   PRINT #CouOpenFile&, ""
END IF

'Инициализация сигнатур
CALL InitRecords

'Поиск файлов по указанному пути
SHELL (CP$ + " /c " + LEFT$(START$, 2))
SHELL (CP$ + " /c cd \")
MainDir& = 0
IF LEN(START$) > 2 THEN CHDIR (START$)
CALL SearchDir

'Возвращаемся в каталог, из которого стартовали
MDE0:
SHELL (CP$ + " /c " + LEFT$(HOME$, 2))
SHELL (CP$ + " /c cd \")
MainDir& = 1
IF LEN(HOME$) > 2 THEN CHDIR (HOME$)

FOR I& = 1 TO CouRecords
    IF Signature(I&).CouFind > 0 THEN CouVirusFind = CouVirusFind + 1
NEXT I&

'Протокол работы
MDE45:
PRINT "-----"
PRINT "Directory found   - "; CD&
PRINT "Files found       - "; CF&
PRINT "Error found       - "; CouErr&
PRINT "Known viruses     - "; CouRecords
PRINT "Infected files    - "; CouFileInfect
PRINT "Desinfected files - "; CouFileDesinf
PRINT "Erased files      - "; CouFileErased
PRINT "Viruses finded    - "; CouVirusFind
PRINT "Skiped viruses    - "; CouVirusSkip
PRINT "Errors in files   - "; CouErrorFile
PRINT "*****"
IF TextMode% = True THEN
   CouOpenFile& = ProtokolFile
   PRINT #CouOpenFile&, "-----"
   PRINT #CouOpenFile&, "Directory found   - "; CD&
   PRINT #CouOpenFile&, "Files found       - "; CF&
   PRINT #CouOpenFile&, "Error found       - "; CouErr&
   PRINT #CouOpenFile&, "Known viruses     - "; CouRecords
   PRINT #CouOpenFile&, "Infected files    - "; CouFileInfect
   PRINT #CouOpenFile&, "Desinfected files - "; CouFileDesinf
   PRINT #CouOpenFile&, "Erased files      - "; CouFileErased
   PRINT #CouOpenFile&, "Viruses finded    - "; CouVirusFind
   PRINT #CouOpenFile&, "Skiped viruses    - "; CouVirusSkip
   PRINT #CouOpenFile&, "Errors in files   - "; CouErrorFile
   PRINT #CouOpenFile&, "*****"
   CLOSE #CouOpenFile&
   CouOpenFile& = CouOpenFile& - 1
END IF

MDE1:
END
'*

'Обработка ошибок ввода-вывода
HANDLER:
'         PRINT
'         PRINT "Error "; ERR; " on line "; ERL
         Gerr& = ERR
         SELECT CASE ERR
                CASE 6 'Overflow
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 7 'Out of memory
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 24 'Device timeout
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 25 'Device fault
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 51 'Internal error
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 52 'Bad file name or number
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 53 'File not found
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 54 'Bad file mode
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 55 'File already open
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 57 'Device I/O error
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 58 'File already exists
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 61 'Disk full
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 62 'EOF of file
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 64 'Bad file name
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 67 'Too many files
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 68 'Device unavailable
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 70 'Permission denied
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 71 'Disk not ready
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 72 'Disk-media error
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 75 'Path/File access error
                     CouErr& = CouErr& + 1
                     RESUME
                CASE 76 'Path not found
                     SELECT CASE MainDir&
                            CASE 0
                                 IF TextMode% = True THEN
                                    PRINT #ProtokolFile, "Path "; START$; " not found"
                                 END IF
                                 PRINT "Path "; START$; " not found"
                                 CouErr& = CouErr& + 1
                                 RESUME MDE0
                            CASE 1
                                 IF TextMode% = True THEN
                                    PRINT #ProtokolFile, "Path "; HOME$; " not found"
                                 END IF
                                 PRINT "Path "; HOME$; " not found"
                                 CouErr& = CouErr& + 1
                                 RESUME MDE1
                            CASE 4 TO 5
                                 IF TextMode% = True THEN
                                    PRINT #ProtokolFile, "Path "; CurSubDir$; " not found"
                                 END IF
                                 PRINT "Path "; CurSubDir$; " not found"
                                 CouErr& = CouErr& + 1
                                 RESUME MDE45
                            CASE 2 TO 3
                                 IF TextMode% = True THEN
                                    PRINT #ProtokolFile, "Path "; CurSubDir$; " not found"
                                 END IF
                                 PRINT "Path "; CurSubDir$; " not found"
                                 CouErr& = CouErr& + 1
                                 RESUME NEXT
                            CASE 4 TO 5
                                 IF TextMode% = True THEN
                                    PRINT #ProtokolFile, "Path "; CurSubDir$; " not found"
                                 END IF
                                 PRINT "Path "; CurSubDir$; " not found"
                                 CouErr& = CouErr& + 1
                                 RESUME MDE45
                    END SELECT
                     IF TextMode% = True THEN
                        PRINT #ProtokolFile, "Path not found"
                     END IF
                     PRINT "Path not found"
                     CouErr& = CouErr& + 1
                     RESUME
         END SELECT
         CouErr& = CouErr& + 1
         RESUME

SUB BlockPresent (I&, J&, Len1&, Flag, Offs&)
    Flag = 1
    L = SigArray(I&, J&, 1)
    FOR K& = 1 TO AFileLength
        P = ASC(FileBuff(K&))
        IF L = P THEN
           R = 1
           FOR L& = 1 TO Len1&
               IF ASC(FileBuff(K& + L& - 1)) <> SigArray(I&, J&, L&) THEN R = 0
           NEXT L&
           IF R = 1 THEN
              Flag = 0
              Offs& = K&
              EXIT FOR
           END IF
        END IF
    NEXT K&
END SUB

'Вытаскиваем параметры из командной строки
SUB Comline (NumArgs%, Args$(), MaxArgs%) STATIC
CONST True = -1, False = 0
   NumArgs% = 0: In = False
   Cl$ = COMMAND$
   L = LEN(Cl$)
   FOR I = 1 TO L
      C$ = MID$(Cl$, I, 1)
      IF (C$ <> " " AND C$ <> CHR$(9)) THEN
         IF NOT In THEN
            IF NumArgs% = MaxArgs% THEN EXIT FOR
            NumArgs% = NumArgs% + 1
            In = True
         END IF
         Args$(NumArgs%) = Args$(NumArgs%) + C$
      ELSE
         In = False
      END IF
   NEXT I
   PARAM$ = ""
END SUB

'Устанавливаем режим работы антивируса
SUB ExtractMode
    IF UCASE$(TEMP$) = "O" THEN OkMode% = True
    IF UCASE$(TEMP$) = "C" THEN CureMode% = True
    IF UCASE$(TEMP$) = "P" THEN TextMode% = True
    IF UCASE$(TEMP$) = "?" THEN
       CALL HELP
    END IF
END SUB

'Обрабатываем командную строку
SUB ExtractParam
    IF CouParam% = 0 THEN
       CALL HELP
    END IF
    FOR I% = 1 TO CouParam%
        IF LEFT$(ARGUM$(I%), 1) = "/" THEN
           TEMP$ = MID$(ARGUM$(I%), 2, 1)
           CALL ExtractMode
           GOTO 10
        END IF
        IF LEFT$(ARGUM$(I%), 1) = "+" THEN
           START$ = MID$(HOME$, 1, 2)
           GOTO 10
        END IF
        START$ = ARGUM$(I%)
10  NEXT I%
END SUB

'Поиск подкаталогов в текущем каталоге
SUB FindDir
    SHELL CP$ + " /c dir *.* /A:D /B >SUBDIR.LST"
END SUB

'Поиск COM-файлов в текущем каталоге
SUB FindFile
    SHELL CP$ + " /c dir *.com /A:A /A:-D /B >FILES.LST"
END SUB

SUB FromBegOfFile (I&, AFName$, S$)
    CouOpenFile& = CouOpenFile& + 1
    OPEN AFName$ FOR BINARY AS #CouOpenFile&
    CouOpenFile& = CouOpenFile& + 1
    OPEN "CURE$.$$$" FOR BINARY AS #CouOpenFile&
    J& = 1
    FOR L& = Signature(I&).VirLength + 1 TO AFileLength
        GET #CouOpenFile& - 1, L&, TEMP1
        PUT #CouOpenFile&, J&, TEMP1
        J& = J& + 1
    NEXT L&
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    KILL AFName$
    S1$ = CP$ + " /c ren CURE$.$$$ " + CurFileName$ 'AFName$
    SHELL S1$
    CouFileDesinf = CouFileDesinf + 1
    S$ = S$ + " - cured!"
END SUB

SUB FromEndOfFile (I&, AFName$, S$)
    CouOpenFile& = CouOpenFile& + 1
    OPEN AFName$ FOR BINARY AS #CouOpenFile&
    FOR L& = 1 TO Signature(I&).BytesPartCo
        J& = Signature(I&).Sig1Info.SigOffset - 1
        K& = J& + BytesPartIn(Signature(I&).NumBytesInf, L&).BytesOffset + 1
        N& = BytesPartIn(Signature(I&).NumBytesInf, L&).SourceOffs
        N& = N& + 1
        FOR M& = 0 TO BytesPartIn(Signature(I&).NumBytesInf, L&).BytesLength - 1
            GET #CouOpenFile&, K&, TEMP1
            PUT #CouOpenFile&, N&, TEMP1
            N& = N& + 1
            K& = K& + 1
        NEXT M&
    NEXT L&
    CouOpenFile& = CouOpenFile& + 1
    OPEN "CURE$.$$$" FOR BINARY AS #CouOpenFile&
    FOR L& = 1 TO J& - Signature(I&).VirBegOffs
        GET #CouOpenFile& - 1, L&, TEMP1
        PUT #CouOpenFile&, L&, TEMP1
    NEXT L&
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    KILL AFName$
    S1$ = CP$ + " /c ren CURE$.$$$ " + CurFileName$ 'AFName$
    SHELL S1$
    CouFileDesinf = CouFileDesinf + 1
    S$ = S$ + " - cured!"
END SUB

'Вывод помощи
SUB HELP
     IF (CouParam% = 0) OR (UpStr$(ARGUM$(1)) = "/H") OR (UpStr$(ARGUM$(1)) = "/?") OR (UpStr$(ARGUM$(1)) = "?") THEN
        CLS 0
        PRINT "USAGE: BASAV.EXE [Drive/Path] [Keys]"
        PRINT "       Drive:"
        PRINT "             A:"
        PRINT "             B:"
        PRINT "             C:"
        PRINT "             X:"
        PRINT "             + - only current HDD"
        PRINT "       Keys:"
        PRINT "             /? - this help"
        PRINT "             /O - show Ok"
        PRINT "             /C - cure mode"
        PRINT "             /P - protokol save"
        PRINT "Example:"
        PRINT "         BASAV.EXE A:"
        PRINT "         BASAV.EXE D:\TEST"
        PRINT "         BASAV.EXE + /C /O /P"
        PRINT "         BASAV.EXE /O /P"
        END
     END IF
END SUB

'Определение каталога запуска программы
SUB HOMEIN
'Определение текущего каталога
SHELL CP$ + " /c truename > HOME$$$$.BAV"
OPEN "HOME$$$$.BAV" FOR INPUT AS #5
INPUT #5, HOME$
INPUT #5, HOME$
CLOSE #5
KILL "HOME$$$$.BAV"
END SUB

'Инициализация сигнатур
SUB InitRecords
    CALL KhizhnjakFill
    CALL RedArc112
END SUB

'Сигнатура вируса
SUB KhizhnjakFill
    Signature(1).VirName = "Khizhnjak.452"
    Signature(1).VirNameLen = LEN("Khizhnjak.452")
    Signature(1).VirLength = 452
    Signature(1).TypeWrt = TypeEnd
    Signature(1).Desinfect = DisinfYes
    Signature(1).CryptInfo = CryptNone
    Signature(1).Sig1Info.SigOffset = 0
    Signature(1).Sig1Info.SigLength = 7
    Signature(1).Sig1Info.NumPArray = 1
    SigArray(1, 1, 1) = &HA0
    SigArray(1, 1, 2) = &H39
    SigArray(1, 1, 3) = &H2
    SigArray(1, 1, 4) = &H2E
    SigArray(1, 1, 5) = &HA2
    SigArray(1, 1, 6) = &H0
    SigArray(1, 1, 7) = &H1
    Signature(1).Sig2Info.SigOffset = &HCC
    Signature(1).Sig2Info.SigLength = 9
    Signature(1).Sig2Info.NumPArray = 1
    SigArray(1, 2, 1) = &H72
    SigArray(1, 2, 2) = &H36
    SigArray(1, 2, 3) = &H80
    SigArray(1, 2, 4) = &H3E
    SigArray(1, 2, 5) = &HD2
    SigArray(1, 2, 6) = &H2
    SigArray(1, 2, 7) = &H37
    SigArray(1, 2, 8) = &H75
    SigArray(1, 2, 9) = &H3
    Signature(1).VirBegOffs = 8
    Signature(1).BytesPartCo = 1
    Signature(1).NumBytesInf = 1
    BytesPartIn(1, 1).BytesOffset = &H121
    BytesPartIn(1, 1).BytesLength = 3
    BytesPartIn(1, 1).BytesCrypt = CryptNone
    BytesPartIn(1, 1).SourceOffs = 0
    Signature(1).CouFind = 0
    CouRecords = CouRecords + 1
END SUB

'Удаление списка подкаталогов
SUB KillDir
    KILL "SUBDIR.LST"
END SUB

'Удаление списка COM-файлов
SUB KillFile
    KILL "FILES.LST"
END SUB

'Сигнатура вируса
SUB RedArc112
    Signature(2).VirName = "RedArc.112"
    Signature(2).VirNameLen = LEN("RedArc.112")
    Signature(2).VirLength = 112
    Signature(2).TypeWrt = TypeBeg
    Signature(2).Desinfect = DisinfYes
    Signature(2).CryptInfo = CryptNone
    Signature(2).Sig1Info.SigOffset = 0
    Signature(2).Sig1Info.SigLength = 12
    Signature(2).Sig1Info.NumPArray = 2
    SigArray(2, 1, 1) = &H53
    SigArray(2, 1, 2) = &H68
    SigArray(2, 1, 3) = &H6F
    SigArray(2, 1, 4) = &H6D
    SigArray(2, 1, 5) = &H68
    SigArray(2, 1, 6) = &H2E
    SigArray(2, 1, 7) = &H63
    SigArray(2, 1, 8) = &H68
    SigArray(2, 1, 9) = &H2A
    SigArray(2, 1, 10) = &H3F
    SigArray(2, 1, 11) = &H8B
    SigArray(2, 1, 12) = &HD4
    Signature(2).Sig2Info.SigOffset = &H4B
    Signature(2).Sig2Info.SigLength = 9
    Signature(2).Sig2Info.NumPArray = 2
    SigArray(2, 2, 1) = &HB4
    SigArray(2, 2, 2) = &H40
    SigArray(2, 2, 3) = &HFE
    SigArray(2, 2, 4) = &HC6
    SigArray(2, 2, 5) = &HCD
    SigArray(2, 2, 6) = &H21
    SigArray(2, 2, 7) = &H55
    SigArray(2, 2, 8) = &H5C
    SigArray(2, 2, 9) = &HCB
    Signature(2).VirBegOffs = 0
    Signature(2).BytesPartCo = 0
    Signature(2).CouFind = 0
    CouRecords = CouRecords + 1
END SUB

SUB ScanFile (FileName$, FileLength&)
    Flag = 1
    CouOpenFile& = CouOpenFile& + 1
    OPEN FileName$ FOR BINARY AS #CouOpenFile&
    FileLength& = LOF(CouOpenFile&)
    IF FileLength& > MaxFileLength THEN
       PRINT FileName$; " - file too big"
       IF TextMode% = True THEN
          PRINT #ProtokolFile, FileName$; " - file too big"
       END IF
       FileLength& = MaxFileLength
    END IF
    I& = 0
    DO
        I& = I& + 1
        GET #CouOpenFile&, I&, FileBuff(I&)
        IF I& = MaxFileLength THEN EXIT DO
    LOOP UNTIL (EOF(CouOpenFile&))
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    K& = 0
    FOR I& = 1 TO CouRecords
        P& = Signature(I&).Sig1Info.SigLength
        J& = 1
        CALL BlockPresent(I&, J&, P&, Flag, Offs&)
        IF Flag = 0 THEN
           AOffs1 = Offs& 'Смещение первой сигнатуры
           J& = 2
           P& = Signature(I&).Sig2Info.SigLength
           CALL BlockPresent(I&, J&, P&, Flag, Offs&)
           IF Flag = 0 THEN
              AOffs2 = Offs& 'Смещение второй сигнатуры
              Flag = 3
              K& = I&
              Signature(I&).CouFind = Signature(I&).CouFind + 1
              EXIT FOR
           END IF
        END IF
    NEXT I&
    IF Flag <> 3 THEN
        'Сигнатуру не нашли
        IF OkMode% = True THEN
           PRINT FileName$; " - Ok"
           IF TextMode% = True THEN
              PRINT #ProtokolFile, FileName$; " - Ok"
           END IF
        END IF
        EXIT SUB
    END IF
    CouFileInfect = CouFileInfect + 1
    'Здесь будем лечить файл
    Signature(K&).Sig1Info.SigOffset = AOffs1
    S$ = MID$(Signature(K&).VirName, 1, Signature(K&).VirNameLen)
    S$ = FileName$ + " - Infected " + S$
    'Лечение
    IF CureMode% = True THEN
       IF Signature(K&).Desinfect = DisinfNo THEN
          KILL FileName$
          CouFileErased = CouFileErased + 1
          S$ = S$ + " - deleted"
       ELSE
            IF Signature(K&).TypeWrt = TypeBeg THEN
               CALL FromBegOfFile(K&, FileName$, S$)
            END IF
            IF Signature(K&).TypeWrt = TypeEnd THEN
               CALL FromEndOfFile(K&, FileName$, S$)
            END IF
       END IF
    END IF
    PRINT S$
    IF TextMode% = True THEN
       PRINT #ProtokolFile, S$
    END IF
END SUB

'Обход дерева каталогов
SUB SearchDir
    CD& = CD& + 1
LBL:
    'Поиск вложенных каталогов
    CALL FindDir
    CouOpenFile& = CouOpenFile& + 1
    AllSubDir%(CouSubDir&) = 0
    OPEN "SUBDIR.LST" FOR INPUT AS #CouOpenFile&
    DO
        IF (EOF(CouOpenFile&)) THEN EXIT DO
        LINE INPUT #CouOpenFile&, CurSubDir$
        AllSubDir%(CouSubDir&) = AllSubDir%(CouSubDir&) + 1
    LOOP UNTIL (EOF(CouOpenFile&))
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    IF AllSubDir%(CouSubDir&) = 0 THEN
        GOTO Label1
    END IF
    MySubDir%(CouSubDir&) = MySubDir%(CouSubDir&) + 1
    IF MySubDir%(CouSubDir&) > AllSubDir%(CouSubDir&) THEN GOTO Label1
    CouOpenFile& = CouOpenFile& + 1
    OPEN "SUBDIR.LST" FOR INPUT AS #CouOpenFile&
    FOR I% = 1 TO MySubDir%(CouSubDir&)
        LINE INPUT #CouOpenFile&, CurSubDir$
    NEXT I%
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    CouSubDir& = CouSubDir& + 1
    IF CouSubDir& > MaxSubDir THEN GOTO Label1
    CALL KillDir
    SubDir$(CouSubDir&) = CurSubDir$
Label2:
    IF LEN(CurSubDir$) > 2 THEN
        MainDir& = 2
        CHDIR (CurSubDir$)
        IF Gerr& = 76 THEN
           Gerr& = 0
           GOSUB DirUP
           GOTO LBL
        END IF
    ELSE
        IF MID$(CurSubDir$, 2, 1) = ":" THEN
           SHELL (CP$ + " /c cd \")
        ELSE
           MainDir& = 3
           CHDIR (CurSubDir$)
           IF Gerr& = 76 THEN
              Gerr& = 0
              GOSUB DirUP
              GOTO LBL
           END IF
        END IF
    END IF
    CALL SearchDir
    GOTO LBL
DirUP:
    CouSubDir& = CouSubDir& - 1
    S$ = ""
    FOR I% = 1 TO CouSubDir&
        S$ = S$ + SubDir$(I%) + "\"
    NEXT I%
    IF RIGHT$(S$, 1) = "\" THEN S$ = MID$(S$, 1, LEN(S$) - 1)
    CurSubDir$ = S$
    IF LEN(CurSubDir$) > 2 THEN
        MainDir& = 4
        CHDIR (CurSubDir$)
    ELSE
        IF MID$(CurSubDir$, 2, 1) = ":" THEN
           SHELL (CP$ + " /c cd \")
        ELSE
           MainDir& = 5
           CHDIR (CurSubDir$)
        END IF
    END IF
    RETURN
Label1:
    CALL KillDir
    S$ = ""
    FOR I% = 1 TO CouSubDir&
        S$ = S$ + SubDir$(I%) + "\"
    NEXT I%
    MyRow% = CSRLIN
    MyCol% = 1
    LOCATE MyRow%, MyCol%
    PRINT S$;
    LOCATE MyRow%, MyCol%
    CALL SearchFile
    AllSubDir%(CouSubDir&) = 0
    MySubDir%(CouSubDir&) = 0
    IF CouSubDir& = 1 THEN GOTO Label0
    GOSUB DirUP
Label0:
END SUB

'Обработка списка COM-файлов в текущем каталоге
SUB SearchFile
    'Поиск файлов в каталоге
    CALL FindFile

    S$ = ""
    FOR I% = 1 TO CouSubDir&
        S$ = S$ + SubDir$(I%) + "\"
    NEXT I%
    MyRow% = CSRLIN
    MyCol% = 1
    LOCATE MyRow%, MyCol%
    S$ = SPACE$(LEN(S$))
    PRINT S$;
    LOCATE MyRow%, MyCol%

    CouOpenFile& = CouOpenFile& + 1
    OPEN "FILES.LST" FOR INPUT AS #CouOpenFile&
    DO
        IF (EOF(CouOpenFile&)) THEN EXIT DO
        LINE INPUT #CouOpenFile&, CurFileName$
        IF CurFileName$ = "FILES.LST" THEN GOTO SF1
        S$ = ""
        FOR I% = 1 TO CouSubDir&
            S$ = S$ + SubDir$(I%) + "\"
        NEXT I%
        'Здесь мы нашли файл и будем его проверять на наличие вируса
        'PRINT S$; CurFileName$
        CALL ScanFile(S$ + CurFileName$, AFileLength)
        CF& = CF& + 1
SF1:
    LOOP UNTIL (EOF(CouOpenFile&))
    CLOSE #CouOpenFile&
    CouOpenFile& = CouOpenFile& - 1
    CALL KillFile
END SUB

'Для совместимости с Pascal-программой
FUNCTION UpStr$ (S AS STRING)
         UpStr$ = UCASE$(S)
END FUNCTION

