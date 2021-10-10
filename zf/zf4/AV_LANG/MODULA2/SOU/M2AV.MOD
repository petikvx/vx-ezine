(******************************************************************)
(*            Простейший антивирус на TopSpeed Modula-2           *)
(*                     by DrMad for ZF4                           *)
(******************************************************************)
MODULE M2AV;

FROM FIO     IMPORT  Open,Create,AssignBuffer,Rename,Size,directory,
                     RdBin,WrBin,ReadFirstEntry,ReadNextEntry,
                     PathTail,FileAttr,DirEntry,EOF,IOcheck,File,
                     directory,Seek,Close,Erase,IOcheck,Truncate;
FROM SYSTEM  IMPORT  Registers,Seg,Ofs;
FROM Lib     IMPORT  Dos,ParamCount,ParamStr;
FROM Str     IMPORT  Copy,Append,Pos,Length,Caps;
FROM IO      IMPORT  WrStr,WrLn,WrCard,WrChar;
FROM Storage IMPORT  ALLOCATE,DEALLOCATE;

VAR
    TotalInfected:CARDINAL; (* Счетчик зараженных                *)
    TotalChecked:CARDINAL; (* Счетчик проверенных                *)
    TotalCured:CARDINAL; (* Счетчик вылеченных *)
    NeedCure  : BOOLEAN; (* Признак необходимости лечения        *)
    Parameter,Parameter1 : ARRAY [0..127] OF CHAR; (* Параметры  *)
    TDA : RECORD  (* Дата, время, атрибут файла                  *)
           FDate : CARDINAL;
           FTime : CARDINAL;
           FAttr : CARDINAL;
          END;
    R : Registers;Ch:CHAR;Index:CARDINAL;

(*****************************************************************)
(*         Процедура сохранения времени, даты, атрибута          *)
(*****************************************************************)
PROCEDURE SaveTDA(FileName:ARRAY OF CHAR);
VAR H:CARDINAL;
BEGIN

 R.AX:=4300H;
 R.DS:=Seg(FileName);
 R.DX:=Ofs(FileName);
 Dos(R);
 TDA.FAttr:=R.CX;

 R.AX:=3D00H;
 R.DS:=Seg(FileName);
 R.DX:=Ofs(FileName);
 Dos(R);
 H:=R.AX;

 R.AX:=5700H;
 R.BX:=H;
 Dos(R);
 TDA.FDate:=R.DX;
 TDA.FTime:=R.CX;

 R.AH:=3EH;
 R.BX:=H;
 Dos(R);

END SaveTDA;

(*****************************************************************)
(*    Процедура восстановления  времени, даты , атрибута         *)
(*****************************************************************)
PROCEDURE RestTDA(FileName:ARRAY OF CHAR);
VAR H:CARDINAL;
BEGIN

 R.AX:=4301H;
 R.DS:=Seg(FileName);
 R.DX:=Ofs(FileName);
 R.CX:=TDA.FAttr;
 Dos(R);

 R.AX:=3D00H;
 R.DS:=Seg(FileName);
 R.DX:=Ofs(FileName);
 Dos(R);
 H:=R.AX;

 R.AX:=5701H;
 R.BX:=H;
 R.DX:=TDA.FDate;
 R.CX:=TDA.FTime;
 Dos(R);

 R.AH:=3EH;
 R.BX:=H;
 Dos(R);

END RestTDA;

(*****************************************************************)
(*   Процедура проверки необходимости лечения от 460             *)
(*****************************************************************)
PROCEDURE Infected1(FileName:ARRAY OF CHAR):BOOLEAN;
VAR
 F      : File;
 Q      : CARDINAL;
 SigBuf : ARRAY [0..7] OF SHORTCARD;
 R      : BOOLEAN;
 A      : POINTER TO CARDINAL;
BEGIN
 INC(TotalChecked);
 F:=Open(FileName);
 Q := RdBin( F, SigBuf, 8);
 IF (SigBuf[0]=0E9H)         (* Должен быть JMP *)
  THEN
   A:=ADR(SigBuf[1]);        (* Адрес слова, начинающегося с байта 1 *)
   Seek(F,LONGCARD(A^+3));   (* На гипотетическое начало вируса *)
   Q := RdBin( F, SigBuf, 8);
   IF (SigBuf[0]=01EH)&      (* Проверяем сигнатуру *)
      (SigBuf[1]=08CH)&
      (SigBuf[2]=0D8H)&
      (SigBuf[3]=05H)&
      (SigBuf[6]=08EH)&
      (SigBuf[7]=0D8H)
       THEN
        R:=TRUE;             (* Вирус есть! *)
        INC(TotalInfected);
        WrStr(' БОЛЕН ВИРУСОМ 460');
       ELSE
        R:=FALSE             (* Вируса нет *)
   END;
  ELSE
   R:=FALSE
 END;
 Close(F);
 RETURN R;
END Infected1;

(*****************************************************************)
(*        Процедура лечения вируса 460                           *)
(*****************************************************************)
PROCEDURE Cure1(FileName:ARRAY OF CHAR);
VAR
 F   : File;
 L   : LONGCARD;
 Buf : ARRAY [0..2] OF SHORTCARD;
 Par : ARRAY [0..15] OF SHORTCARD;
 Q   : CARDINAL;
 i   : CARDINAL;
BEGIN
 IF NeedCure
  THEN
   F := Open( FileName );
   L := Size( F );
   Seek(F, L-09BH);
   Q := RdBin( F, Buf, 3);  (* Спрятанные байты *)
   Seek(F, 0);
   WrBin(F, Buf, 3);
   Seek(F, L-(1C4H+16));
   Q := RdBin(F, Par, 16);
   i:=15; WHILE ((Par[i]=0)&(i>0)) DO DEC(i) END; (* Правильный конец *)
   Seek(F, L-(1C4H+16)+LONGCARD(i)+1);
   Truncate(F);
   Close(F);
   WrStr(' и ПРООПЕРИРОВАН');
   INC(TotalCured)
 END
END Cure1;

(*****************************************************************)
(*   Процедура проверки необходимости лечения от 112             *)
(*****************************************************************)
PROCEDURE Infected2(FileName:ARRAY OF CHAR):BOOLEAN;
VAR
 F      : File;
 Q      : CARDINAL;
 SigBuf : ARRAY [0..5] OF SHORTCARD;
 R      : BOOLEAN;

BEGIN
 INC(TotalChecked);
 F:=Open(FileName);
 Q:=RdBin(F,SigBuf,6);
 IF (SigBuf[0]=08CH)&      (* Проверяем сигнатуру *)
    (SigBuf[1]=0CAH)&
    (SigBuf[2]=0FEH)&
    (SigBuf[3]=0C6H)&
    (SigBuf[4]=08EH)&
    (SigBuf[5]=0C2H)
     THEN
      R:=TRUE;             (* Вирус есть! *)
      INC(TotalInfected);
      WrStr(' БОЛЕН ВИРУСОМ 112');
     ELSE
      R:=FALSE             (* Вируса нет *)
 END;
 Close(F);
 RETURN R
END Infected2;

(*****************************************************************)
(*        Процедура лечения вируса 112                           *)
(*****************************************************************)
PROCEDURE Cure2(FileName:ARRAY OF CHAR);
VAR
 F      : File;
 Q      : CARDINAL;
 Buf    : ARRAY [0..111] OF SHORTCARD;
 Wr, Rd : LONGCARD;
BEGIN
 IF NeedCure
  THEN
   F := Open(FileName);
   Rd:=112; Wr:=0;
   EOF:=FALSE;
   REPEAT
    Seek(F, Rd);
    Q:=RdBin(F, Buf, 112);
    Seek(F, Wr);
    WrBin(F, Buf, Q);
    Rd:=Rd+112;
    Wr:=Wr+112;
   UNTIL Q<112;
   Truncate(F); (* Отстрижение хвоста *)
   Close(F);
   WrStr(' и ПРООПЕРИРОВАН');
   INC(TotalCured);
 END
END Cure2;

(*****************************************************************)
(*      Процедура рекурсивного обхода дерева каталогов           *)
(*      методом "полных имен":                                   *)
(*      - текущий каталог не изменяется;                         *)
(*      - маска всегда "<Диск>:\<Кат1>\<Кат2>...\<КатN>\*.*"     *)
(*****************************************************************)
PROCEDURE GoAroundTree(Path:ARRAY OF CHAR);
VAR
 IsEntry:BOOLEAN;
 FoundEntry:DirEntry;
 PathCopy1,PathCopy2:ARRAY [0..127] OF CHAR;

  (* Селектор ссылок наверх и на себя *)
  PROCEDURE DummyPointer(DirName:ARRAY OF CHAR):BOOLEAN;
  BEGIN RETURN Pos(DirName,'.')#MAX(CARDINAL) END DummyPointer;

BEGIN

 (* Поиск подкаталогов данного каталога *)
 Copy(PathCopy1,Path);
 Append(PathCopy1,'\*.*');
 IsEntry:=ReadFirstEntry(PathCopy1,FileAttr{directory},FoundEntry);
 WHILE IsEntry DO
  IF (~DummyPointer(FoundEntry.Name))&
     ( directory IN FoundEntry.attr ) (* Необходимо из за ошибки в FIO *)
   THEN
    Copy(PathCopy2,Path);
    Append(PathCopy2,'\');
    Append(PathCopy2,FoundEntry.Name);
    GoAroundTree(PathCopy2);
  END;
  IsEntry:=ReadNextEntry(FoundEntry);
 END;

 (* К этому моменту подкаталогов нет - ищем цели для лечения     *)
 Copy(PathCopy1,Path);
 Append(PathCopy1,'\*.COM');
 IsEntry:=ReadFirstEntry(PathCopy1,FileAttr{},FoundEntry);
 WHILE IsEntry DO
  Copy(PathCopy2,Path);
  Append(PathCopy2,'\');
  Append(PathCopy2,FoundEntry.Name);
  WrStr('                                                         ');
  WrStr(15C);
  WrStr(PathCopy2);

  IF Infected1(PathCopy2) THEN Cure1(PathCopy2);WrLn  END;
  IF Infected2(PathCopy2) THEN Cure2(PathCopy2);WrLn  END;

  WrStr(15C);
  IsEntry:=ReadNextEntry(FoundEntry);
 END;

END GoAroundTree;

BEGIN

 IF ParamCount()=0
  THEN
   WrStr('┌------------------------------------------------┐');WrLn;
   WrStr('│        Программа - простейший хирург           │');WrLn;
   WrStr('│     Запуск : M2AV  < Тропа > [-ключ]           │');WrLn;
   WrStr('│  Ключ c или t означает необходимость лечения   │');WrLn;
   WrStr('└------------------------------------------------┘');WrLn;
  ELSE
   WrStr('┌------------------------------------------------┐');WrLn;
   WrStr('│        Программа - простейший хирург           │');WrLn;
   WrStr('└------------------------------------------------┘');WrLn;
   WrLn;
   ParamStr(Parameter,1);
   Caps(Parameter);
   NeedCure:=FALSE;
   IF (ParamCount()>1) THEN
    ParamStr(Parameter1,2);
    Caps(Parameter1);
    NeedCure:=(Pos(Parameter1,'-C')#MAX(CARDINAL))OR
              (Pos(Parameter1,'-T')#MAX(CARDINAL));
   END;
   TotalInfected:=0;TotalChecked:=0;TotalCured:=0;
   GoAroundTree(Parameter);
   WrLn;WrLn;
   WrStr(' Всего проверено        : ');WrCard(TotalChecked,5);WrLn;
   WrStr(' Обнаружено зараженных  : ');WrCard(TotalInfected,5);WrLn;
   WrStr(' Прооперировано         : ');WrCard(TotalCured,5);
  END;
END M2AV.
