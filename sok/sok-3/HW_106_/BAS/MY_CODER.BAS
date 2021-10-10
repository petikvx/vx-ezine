DECLARE SUB CodeEXE ()
DECLARE SUB EXE (n$)
DECLARE FUNCTION FindStart% (l$)
DECLARE FUNCTION FindEnd% (l$)
DECLARE SUB ClipName (Comm$, Line$)
DECLARE SUB ErrorMessage (a%, n$)
DECLARE SUB LST (n$)
DECLARE FUNCTION Hexy$ (a$, p%)
DECLARE FUNCTION Num% (k$)
DECLARE SUB MakeINC (n$)
'
' программа выполняет кодирование предварительно откомпилированного
' файла и преобразование его в .INC для финальной сборки.
'
' Начало закодированного блока начинается в исходнике с метки
' Start_Of_Code_x и заверщается End_Of_Code_x, где 'x' - уникальный символ
' после метки Start_... должны обязательно следовать 5 любых байт для
' установки Int 3 и хранения длины и кода.
' Для эталона кодирования используется блок кодов длиной 128 байт начиная
' с метки Etalone_To_Code.
'
'  --- Не включай в области для кодирования блоки глобальных данных !!!  ---
'
' Описание алгоритма - файл MORPH.INC
'
' Формат запуска:
'       MY_CODER <exe-файл> <lst-файл> [/nocode]
'
' exe-файл должен быть получен с помощью компиляции (ML /Fl ...)
' lst-файл нужен для вычисления адресов меток (компиляция с /Fl)
' опция /nocode указывает на то, что кодировать файл не нужно. Тогда 5-ти
' байтовые промежутки забиваются NOP'ами
'
' на выходе будет создан файл с именем от EXE и расширением INC
'

TYPE LabelType
  Letter AS STRING * 1
  Label  AS INTEGER
END TYPE
TYPE Code
  Start  AS INTEGER
  Lenght AS INTEGER
END TYPE

DIM SHARED Nocode AS INTEGER
DIM SHARED Ends(100) AS LabelType
DIM SHARED Starts(100) AS LabelType
DIM SHARED Etalone AS INTEGER
DIM SHARED Buffer$
DIM SHARED KolEnds AS INTEGER
DIM SHARED KolStarts AS INTEGER
DIM SHARED CodeArrea(100) AS Code

n$ = COMMAND$
n$ = LCASE$(LTRIM$(RTRIM$(n$)))

ClipName n1$, n$
ClipName n2$, n$

Nocode = 0
Etalone = -1

n$ = LTRIM$(n$)
IF n$ <> "" THEN
   IF n$ = "/nocode" THEN Nocode = -1 ELSE ErrorMessage 0, n$
END IF

LST n2$
EXE n1$
CodeEXE
MakeINC n1$

END
100 RESUME NEXT

SUB ClipName (c$, l$)
  IF LEN(l$) = 0 THEN
    ErrorMessage 1, ""
  ELSE
    i% = INSTR(l$, " ")
    IF i% = 0 THEN
      c$ = l$
      l$ = ""
    ELSE
      c$ = MID$(l$, 1, i% - 1)
      l$ = LTRIM$(MID$(l$, i%))
    END IF
  END IF
END SUB

SUB CodeEXE
  RANDOMIZE TIMER
  FOR a% = 0 TO KolEnds - 1
    IF Nocode THEN
      MID$(Buffer$, CodeArrea(a%).Start + 1, 5) = "РРРРР"  'забиваем NOP'ами
    ELSE
      cc& = INT(RND * 65535.9)
      IF cc& > 32767 THEN cc& = cc& - 65536
      c% = cc&
      t$ = CHR$(&HCC) + MKI$(c%) + MKI$(CodeArrea(a%).Lenght)
      s% = CodeArrea(a%).Start + 1
      MID$(Buffer$, s%, 5) = t$
      s% = s% + 5
      FOR b% = 0 TO CodeArrea(a%).Lenght - 1
        c1% = CVI(MID$(Buffer$, s% + b% * 2, 2))
        c2% = CVI(MID$(Buffer$, Etalone + 1 + ((b% * 2) AND 127), 2))
        c3% = c1% XOR c2% XOR c%
        MID$(Buffer$, s% + b% * 2, 2) = MKI$(c3%)
      NEXT
    END IF
  NEXT
END SUB

SUB ErrorMessage (a%, n$)
   SELECT CASE a%
     CASE 0
       PRINT "Нейзвестная опция: "; n$
     CASE 1
       PRINT "Запуск: MY_CODE <exe-file> <lst-file> [/nocode]"
     CASE 2
       PRINT "Незакрытый блок "; n$
     CASE 3
       PRINT "Неоткрытый блок "; n$
     CASE 4
       PRINT "Укажи человеческое имя EXE-файла"
     CASE 5
       PRINT "Не задано метки Etalone_To_Code"
   END SELECT
   BEEP
   END
END SUB

SUB EXE (n$)
  t% = INSTR(n$, ".")
  SELECT CASE t%
    CASE 0
   
    CASE 1
      ErrorMessage 4, n$
    CASE ELSE
      n$ = MID$(n$, 1, t% - 1)
  END SELECT
  OPEN n$ + ".exe" FOR BINARY ACCESS READ AS #1
    GET #1, 3, l%
    GET #1, 5, p%
    d% = 512 * p% - 512 + l%
    GET #1, 9, f%
    f% = f% * 16 + 1
    SEEK #1, f%
    Buffer$ = INPUT$(d%, #1)
  CLOSE
END SUB

FUNCTION FindEnd% (l$)
   FOR a% = 0 TO KolEnds - 1
     IF Ends(a%).Letter = l$ THEN
       FindEnd% = Ends(a%).Label
       EXIT FUNCTION
     END IF
   NEXT
   ErrorMessage 2, "End_Of_Code_" + l$

END FUNCTION

FUNCTION FindStart% (l$)
   FOR a% = 0 TO KolStarts - 1
     IF Starts(a%).Letter = l$ THEN
       FindStart% = Starts(a%).Label
       EXIT FUNCTION
     END IF
   NEXT
   ErrorMessage 3, "Start_Of_Code_" + l$
END FUNCTION

FUNCTION Hexy$ (a$, p%)
  n% = ASC(MID$(a$, p%, 1))
  j$ = LTRIM$(STR$(n%))
  Hexy$ = j$

  'j$ = HEX$(n%)
  'Hexy$ = "0" + j$ + "h"

END FUNCTION

SUB LST (n$)
    IF INSTR(n$, ".") = 0 THEN n$ = n$ + ".lst"
    OPEN n$ FOR INPUT AS #1
      WHILE NOT EOF(1)
      LINE INPUT #1, k$
        IF LEN(k$) > 20 THEN
          i$ = LCASE$(MID$(k$, 1, 14))
          IF i$ = "start_of_code_" THEN
            n$ = MID$(k$, 15, 1)
            p% = Num(k$)
            Starts(KolStarts).Letter = n$
            Starts(KolStarts).Label = p%
            KolStarts = KolStarts + 1
          ELSE
            i$ = LCASE$(MID$(k$, 1, 12))
            IF i$ = "end_of_code_" THEN
              n$ = MID$(k$, 13, 1)
              p% = Num(k$)
              Ends(KolEnds).Letter = n$
              Ends(KolEnds).Label = p%
              KolEnds = KolEnds + 1
            ELSE
              i$ = LCASE$(MID$(k$, 1, 15))
              IF i$ = "etalone_to_code" THEN
                Etalone = Num(k$)
              END IF
            END IF
          END IF
        END IF
      WEND
    CLOSE
    IF Etalone = -1 THEN ErrorMessage 5, ""
    FOR a% = 0 TO KolStarts - 1
      j$ = Starts(a%).Letter
      p% = FindEnd(j$)
    NEXT
'                Пересортировка для вложенных блоков
10
    FOR a% = 0 TO KolEnds - 2
      IF Ends(a%).Label > Ends(a% + 1).Label THEN SWAP Ends(a%), Ends(a% + 1): GOTO 10
    NEXT

    FOR a% = 0 TO KolEnds - 1
      j$ = Ends(a%).Letter
      s% = Ends(a%).Label
      p% = FindStart(j$)
      CodeArrea(a%).Start = p%
      CodeArrea(a%).Lenght = INT((s% - p% - 5) / 2)
    NEXT
END SUB

SUB MakeINC (n$)

ON ERROR GOTO 100
KILL n$ + ".inc"
ON ERROR GOTO 0

OPEN n$ + ".inc" FOR OUTPUT AS #1
  h% = LEN(Buffer$)
  FOR a% = 1 TO (h% AND &HFFF0) STEP 16
    PRINT #1, "byte ";
    FOR b% = 0 TO 15
      PRINT #1, Hexy$(Buffer$, a% + b%);
      IF b% = 15 THEN PRINT #1,  ELSE PRINT #1, ",";
    NEXT
  NEXT
  g% = (h% AND 15)
  IF g% > 0 THEN
    PRINT #1, "byte ";
    FOR b% = g% - 1 TO 0 STEP -1
      PRINT #1, Hexy$(Buffer$, LEN(Buffer$) - b%);
      IF b% = 0 THEN PRINT #1,  ELSE PRINT #1, ",";
    NEXT
  END IF
CLOSE
END SUB

FUNCTION Num% (k$)
   l$ = MID$(k$, 42, 4)
   Num = VAL("&h" + l$)
END FUNCTION

