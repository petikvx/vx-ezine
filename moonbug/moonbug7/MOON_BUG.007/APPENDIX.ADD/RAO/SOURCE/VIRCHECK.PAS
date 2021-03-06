
{1998 (�) VirCheck by Kravchenko Eugene}

program vircheck;

uses
dos,crt;

var
dr,cr,sr: searchrec;
filepath,currentpath: string;
dir: dirstr;
name: namestr;
ext: extstr;
ch: char;
dircounter: array [1..16] of byte;
i,k,n: word;
log,del,dirs,scan: boolean;
minus: integer;
o,bat: text;
gr,br: array[1..16*1024] of byte;
oldexitproc: pointer;

{$F+}
procedure newexit;
begin
exitproc:=oldexitproc;
if erroraddr<>nil then begin
clreol;
writeln('�訡�� � ',fexpand(sr.name));
writeln(o,'�訡�� � ',fexpand(sr.name));
close(o);
close(bat);
if del then
erase(bat);
if log then
erase(o);
fsplit(paramstr(0),dir,name,ext);
chdir(copy(dir,1,length(dir)-1));
end;
erroraddr:=nil;
end;
{$F-}

procedure compare(a,b: string);
var
f,j: file;
s,q: char;
iff,ifj,compare: boolean;
fa,ja: word;
begin
if (a<>b) and (sr.size>0) and (cr.size>0) then begin
iff:=false;
ifj:=false;
assign(f,a);
assign(j,b);
getfattr(f,fa);
getfattr(j,ja);
if (fa and readonly)=readonly then begin
iff:=true;
setfattr(f,fa-readonly);
end;
if (ja and readonly)=readonly then begin
ifj:=true;
setfattr(j,ja-readonly);
end;
reset(f,1);
reset(j,1);
compare:=true;
s:=' ';
q:=' ';
repeat
blockread(f,s,1);
blockread(j,q,1);
if s<>q then
compare:=false;
until (filepos(f)=filesize(f)) or (compare=false);
if compare=true then begin
if filepath<>currentpath then begin
filepath:=currentpath;
writeln(o,filepath);
end;
writeln(o,sr.name,' = ',cr.name);
clreol;
writeln(sr.name,' = ',cr.name);
writeln(bat,'@DEL ',b);
if ifj then ifj:=false;
del:=false;
log:=false;
end;
close(f);
close(j);
if iff then
setfattr(f,fa);
if ifj then
setfattr(j,ja);
end;
end;

procedure setcursorsize(c_start,c_end: byte);
var
regs: registers;
begin
with regs do begin
ah:=$01;
ch:=c_start;
cl:=c_end;
end;
intr($10,regs);
end;

begin
checkbreak:=false;
oldexitproc:=exitproc;
exitproc:=@newexit;
setcursorsize(32,0);
for n:=1 to 16 do dircounter[n]:=0;
scan:=true;
dirs:=true;
del:=true;
log:=true;
minus:=1;
assign(o,copy(paramstr(0),1,length(paramstr(0))-3)+'log');
assign(bat,copy(paramstr(0),1,length(paramstr(0))-3)+'bat');
settextbuf(o,br);
settextbuf(bat,gr);
rewrite(o);
rewrite(bat);
{�����祭� ����室��� ��ࢮ��砫�� ��᢮����}

if (paramcount=0) or (paramstr(1)='/?') then begin
writeln(' ');
writeln('�⨫�� ��� ���᪠ ���������� 䠩��� ����� �����⠫����.');
writeln(' ');
writeln('�������� ᪠��஢���� ��������� � 䠩� VIRCHECK.LOG.');
writeln('��� 㤠����� 䠩���-�㡫���⮢ �������� VIRCHECK.BAT.');
writeln(' ');
writeln('�����: ',paramstr(0),' [/?] [path]');
writeln('�ਬ��: ',paramstr(0),' C:\VIRUS\INFECTED');
writeln(' ');
writeln('                              1998 (c) ������� �ࠢ祭��, 2:5020/1997.4@FidoNet');
close(o);
close(bat);
erase(o);
erase(bat);
halt;
end;

currentpath:=paramstr(1);
if copy(currentpath,length(currentpath),1)='\' then
delete(currentpath,length(currentpath),1);
{$I-}
chdir(currentpath);
{$I+}
if ioresult>0 then begin
writeln('��⠫�� �� �������');
writeln(o,currentpath);
writeln(o,'��⠫�� �� �������');
close(o);
close(bat);
erase(bat);
halt;
end;
{����뢠�� ��६����� ⥪�饣� ��⠫��� �� ��ࢮ�� �஢�� ����������}
k:=1;
{����뢠�� �����䨪��� �஢�� ���������� �� �������}

repeat
{���� ���� ��楤�� ���᪠ ���������� 䠩��� � ������ ��४�ਨ}
if scan then begin
findfirst(currentpath+'\*.*',$26,sr);
if (doserror>0) or (sr.attr=$10) then
{��� 䠩��� � ��४�ਨ}
n:=1 else n:=0;
if n=0 then begin
clreol;
writeln(currentpath);
writeln(o,currentpath);
filepath:=currentpath;
log:=false;
repeat
clreol;
write(sr.name);
gotoxy(1,wherey);
findfirst(currentpath+'\*.*',$26,cr);
for i:=1 to n do findnext(cr);
{�� ������� �� ��� - ���⮩ 横�; �� ������� �� ������� - ���� ��室}
repeat
findnext(cr);
if (doserror=0) and (cr.attr<>$10) then begin
if cr.size=sr.size then
compare(fexpand(sr.name),fexpand(cr.name));
{�ࠢ����� �����}
end;
if keypressed then begin
while keypressed do
ch:=readkey;
write('�����? (Y/n)');
repeat
until keypressed;
ch:=readkey;
if (ord(ch)<>78) and (ord(ch)<>110) then begin
writeln(o,'��ࢠ�� ���짮��⥫��');
close(o);
close(bat);
if del then
erase(bat);
fsplit(paramstr(0),dir,name,ext);
chdir(copy(dir,1,length(dir)-1));
halt;
end;
while keypressed do
ch:=readkey;
gotoxy(1,wherey);
clreol;
write(sr.name);
gotoxy(1,wherey);
end;
until doserror>0;
findnext(sr);
n:=n+1;
until (doserror>0) or (sr.attr=$10);
end;
end;

getdir(0,currentpath);
findfirst(currentpath+'\*.*',directory,dr);
if dircounter[k]=0 then
dircounter[k]:=dircounter[k]+2
else dircounter[k]:=dircounter[k]+1;
findnext(dr);
findnext(dr);
if ((doserror>0) or (dr.attr<>$10)) and (k=1) then
dirs:=false;
{��諨 ����� ��४���}


if dircounter[k]>2 then begin
{�஢��塞, �᪠�� �� �� 㦥 ��४�ਨ �� ������ �஢�� ����������}
n:=2;
repeat
findnext(dr);
if ((doserror>0) or (dr.attr<>$10)) and (k=1) then
dirs:=false;
if (doserror>0) or (dr.attr<>$10) then begin
if minus=-1 then
dircounter[k+1]:=0;
dircounter[k]:=0;
minus:=-1;
scan:=false;
chdir('..');
getdir(0,currentpath);
n:=dircounter[k]-1;
end else
begin
if (dircounter[k]-n)=1 then begin
minus:=1;
n:=n+1;
scan:=true;
{�� ���� ��४��� �������: ⠪ � ����襬}
chdir(fexpand(dr.name));
getdir(0,currentpath);
end;
end;
n:=n+1;
until n>=dircounter[k];
{��諨 ᫥������ �� �஢�७��� ��४���}
end else begin
if (doserror=0) and (dr.attr=$10) then begin
chdir(fexpand(dr.name));
getdir(0,currentpath);
minus:=1;
scan:=true;
end else begin
if minus=-1 then
dircounter[k+1]:=0;
dircounter[k]:=0;
minus:=-1;
scan:=false;
chdir('..');
getdir(0,currentpath);
end;
end;
k:=k+minus;
{�����﫨 �����䨪��� ����������}
{����� � �ணࠬ�� ���� 䠩��� � ��⠫���}
until dirs=false;
close(bat);
if del then
erase(bat);
if log then
writeln(o,currentpath);
close(o);
fsplit(paramstr(0),dir,name,ext);
chdir(copy(dir,1,length(dir)-1));
end.