(***************************************************************)
(*   Простой расшифровщик макросов для небольших DOC-файлов    *)
(*   TopSpeed Modula-2                                         *)
(*   (c) DrMad, 1998                                           *)
(***************************************************************)
MODULE DisMacro;

IMPORT IO,FIO,Storage,Lib;

CONST
     OFFST = 0118H;

LABEL
     NEXT;

VAR
     FileNa : ARRAY [0..31] OF CHAR; (* Имя файла *)
     Q,i,j,k: CARDINAL;              (* Вспомогательные переменные *)
     A      : POINTER TO ARRAY [0..MAX(CARDINAL)-1] OF SHORTCARD;
     F      : FIO.File;              (* Файл *)
     NPar   : CARDINAL;              (* Кол-во параметров в ком. строке *)
     FSize  : LONGCARD;              (* Размер файла *)
     HPos   : CARDINAL;              (* Позиция DOC-заголовка    *)
     NEnt   : CARDINAL;              (* Количество макроблоков   *)
     EPos   : CARDINAL;              (* Позиция макровхождения   *)
     Var    : CARDINAL;              (* Вариант заголовка        *)
     UnXOR  : BOOLEAN;               (* Признак наличия макросов *)

(* 4 байта -> длинное слово *)
PROCEDURE ToLONG( P:CARDINAL ) : LONGCARD;
 VAR
  L:LONGCARD;
BEGIN
 L:=0;
 L:=L+
    LONGCARD(A^[P])+
    LONGCARD(A^[P+1])*100H+
    LONGCARD(A^[P+2])*10000H+
    LONGCARD(A^[P+3])*1000000H;
 RETURN L;
END ToLONG;

(* 2 байта -> слово *)
PROCEDURE ToCARD( P:CARDINAL ) : CARDINAL;
 VAR
  C:CARDINAL;
BEGIN
 C:=0;
 C:=C+
    CARDINAL(A^[P])+
    CARDINAL(A^[P+1])*100H;
 RETURN C;
END ToCARD;

BEGIN

 IO.WrStr('Расшифровывальщик макросов в DOC-файлах версий 6.0'+15C+12C);
 IO.WrStr('                                   (c) DrMad, 1998'+15C+12C);
 IO.WrStr('──────────────────────────────────────────────────'+15C+12C);

 (* Читаем имя файла из параметров или с клавы *)
 NPar := Lib.ParamCount();
 IF NPar < 1
  THEN
   IO.WrStr('FileName> ');IO.RdStr(FileNa);
  ELSE
   Lib.ParamStr(FileNa, 1)
 END;

 IF ~FIO.Exists(FileNa) THEN IO.WrStr('Нет такого файла!'+7C);HALT END;

 F:=FIO.Open(FileNa); FSize := FIO.Size(F);
 IF (FSize>0FFFFH) THEN IO.WrStr('Файл больше 64 Кб!'+7C);FIO.Close(F);HALT END;

 (* Распределяем память *)
 IF Storage.Available(CARDINAL(FSize))
  THEN Storage.ALLOCATE( A , CARDINAL(FSize) );
  ELSE IO.WrStr('Не хватает динамической памяти!'+7C);FIO.Close(F);HALT
 END;

 (* Читаем файло в буфер *)
 Q := FIO.RdBin ( F, A^, CARDINAL(FSize) );

 (* Проверяем на признак OLE2-объекта *)
 IF (Q<>CARDINAL(FSize)) OR
    (A^[0]# 0D0H) OR
    (A^[1]# 0CFH) OR
    (A^[2]# 011H) OR
    (A^[3]# 0E0H) OR
    (A^[4]# 0A1H) OR
    (A^[5]# 0B1H) OR
    (A^[6]# 01AH) OR
    (A^[7]# 0E1H)
      THEN IO.WrStr('Это не файл WORD 6.0!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  (* Ищем заветные байтики DOC-заголовка, позиция кратна 10H *)
  Var:=0; j:=0;

NEXT:

  i:= j;
  HPos := 0;
  LOOP
   IF ((A^[i]=0DCH)&(A^[i+1]=0A5H)) OR
      ((A^[i]=097H)&(A^[i+1]=0A6H)) OR
      ((A^[i]=099H)&(A^[i+1]=0A6H)) OR
      ((A^[i]=0ECH)&(A^[i+1]=0A5H)) THEN HPos:=i; j:=i+16; EXIT END;
   i := i + 16;
   IF i > CARDINAL(FSize) THEN EXIT END;
  END;

  IF (HPos=0) & (Var=0)
      THEN IO.WrStr('Заголовок WORD 6.0 не найден!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  IF (HPos=0) & (Var#0)
      THEN IO.WrStr('Макросы в документе отсутствуют!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  IF (ToLONG(HPos+OFFST+4) <= 2) THEN INC(Var);GOTO NEXT END;

  IF (A^[CARDINAL( ToLONG(HPos+OFFST))+HPos] # 0FFH)
      THEN IO.WrStr('Заголовок описания макро имеет недопустимый формат!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  IF (A^[CARDINAL( ToLONG(HPos+OFFST))+HPos+1] # 01H)
      THEN IO.WrStr('Заголовок описания макро имеет недопустимый формат!'+7C);
           FIO.Close(F);
           Storage.DEALLOCATE( A, CARDINAL(FSize) );
           HALT END;

  NEnt := ToCARD(CARDINAL(ToLONG(HPos+OFFST))+HPos+2);

  IO.WrStr('Количество макрофрагментов : '); IO.WrCard(NEnt, 5);IO.WrLn;

  (* Разбираем дескрипторы и расксориваем макросы *)
  EPos := CARDINAL( ToLONG(HPos+OFFST) )+HPos+4; UnXOR:=FALSE;
  FOR i:=0 TO NEnt-1 DO
   IF A^[EPos+1] > 0
    THEN
     j:=CARDINAL(ToLONG(EPos+14H))+HPos; k:=0;
     WHILE k<CARDINAL(ToLONG(EPos+0CH)) DO
      A^[j] := SHORTCARD ( BITSET(A^[j])/BITSET(A^[EPos+1]));
      INC(j);
      INC(k);
     END;
     A^[EPos+1]:=0;
     UnXOR := TRUE;
   END;
   EPos:=EPos+18H;
  END;

  (* Если расксорили, то надо записать результат *)
  IF UnXOR
   THEN
    IO.WrStr('Фрагменты расшифрованы');
    FIO.Seek(F,0);
    FIO.WrBin(F, A^, CARDINAL(FSize) );
   ELSE
    IO.WrStr('Расшифровка не требуется');
  END;

  FIO.Close(F);
  Storage.DEALLOCATE( A, CARDINAL(FSize) );

END DisMacro.