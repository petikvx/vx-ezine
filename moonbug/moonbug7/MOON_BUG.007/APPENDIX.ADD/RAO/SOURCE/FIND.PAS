UNIT FIND;
{$I-}

INTERFACE

uses crt, dos, COPYSERV;

procedure ScanDir(stdir:PathStr);

IMPLEMENTATION

procedure ScanDir(stdir:PathStr);
  var
    n,L : PList;
    m : PathStr;
    St : string[79];
    ch : char;
    DIR : DirStr;
    NAM : NameStr;
    EXT : EXTSTR;
begin
  FileMode := 0;
  L := nil;
  if stdir[Length(stdir)] <> '\' then
    stdir:=stdir+'\';
  m := stdir+'*.*';
  FindFirst(m,AnyFile,SR);
  while dosError=0 do begin
    if ((SR.Attr and Directory) <> 0) and ((SR.Name<>'.') and
      (SR.Name<>'..')) then begin
      New(n);
      N^.Next := L;
      N^.Name := SR.Name;
      L := N;
      end
    else
      if (SR.Attr and VolumeID=0) and (SR.Attr and Directory=0) then begin
       {Здесь мы нашли файл}
       {stdir+S.Name - путь к файлу}
	S := m;
	Delete (S, Length (m)-2, 3);
	S := S + SR.Name;
        CopyFile (S);
	end;

    FindNext(sR);
    end;
  while L<> nil do begin
    m := Stdir+L^.Name;
    ChDir(m);
    n := L;
    L := L^.next;
    Dispose(n);
    m := m+'\';
    ScanDir(m);
    m := stdir;
    if m[length(m)-1] <> ':' then
      m[0] := chr(length(stdir)-1);
    ChDir(m);
    end;
end;

END.
