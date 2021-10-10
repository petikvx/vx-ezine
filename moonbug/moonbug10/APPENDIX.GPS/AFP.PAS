Var f,g:text;
    s,s0,lab,comm:string;
    cmd:byte;
    i,labstart:integer;
Const incode:boolean=false;
      N:word=0;
Procedure strproc(var s,comm:string);
     var t:string;
         i:integer;
         c:char;
         c_on:boolean;
     begin
      t:='';
      comm:='';
      c_on:=false;
      for i:=1 to length(s) do begin
       c:=upcase(s[i]);
       if c=#9 then c:=' ';
       if not((c=' ') and ((length(t)=0) or (t[length(t)]=' '))) then
        t:=t+c
      end;
      s:='';
      for i:=1 to length(t) do begin
       c:=t[i];
       if c=';' then
        c_on:=true;
       if not c_on then
        s:=s+c
       else
        comm:=comm+c
      end;
      c_on:=false;
      for i:=1 to length(s) do
       if s[i]<>' ' then
        c_on:=true;
      if not c_on then
       s:=''
     end;
Function labname(N:word):string;
     var t:string;
         i:byte;
     begin
      str(N:5,t);
      for i:=1 to 5 do
       if t[i]=' ' then
        t[i]:='0';
      labname:='GPS_'+t
     end;
Function equname(N:word):string;
     var t:string;
         i:byte;
     begin
      str(N:5,t);
      for i:=1 to 5 do
       if t[i]=' ' then
        t[i]:='0';
      equname:='GPSVAR_'+t+' EQU OFFSET '+labname(N+1)+'-OFFSET '+labname(N)
     end;
Begin
 if paramcount<2 then begin
  writeln('Assembler File Processor for GPS');
  writeln('Copyright (C) 1999 by Tahorg');
  writeln('Usage: afp <infile> <outfile>');
  halt
 end;
 assign(f,paramstr(1));
 {$I-}
 reset(f);
 {$I+}
 if ioresult<>0 then begin
  writeln('Cannot open input file');
  halt
 end;
 assign(g,paramstr(2));
 {$I-}
 rewrite(g);
 {$I+}
 if ioresult<>0 then begin
  writeln('Cannot open output file');
  halt
 end;

 writeln(g,'%NOSYMS');
 while not eof(f) do begin
  readln(f,s0);
  s:=s0;
  strproc(s,comm);
  if comm=';#CODESTART' then begin
   incode:=true;
   writeln(g,comm);
   s:=''
  end;
  if comm=';#CODEEND' then begin
   incode:=false;
   writeln(g,labname(N)+':');
   writeln(g,comm);
   s:=''
  end;
  if s<>'' then
   if incode then begin
    cmd:=0;
    if comm=';#CALL' then
     cmd:=1;
    if comm=';#WARP' then
     cmd:=2;
    if comm=';#JXX' then
     cmd:=3;
    if comm=';#JMP' then
     cmd:=4;
    if comm=';#PROC' then
     cmd:=5;
    if (cmd=3) or (cmd=4) then begin
     lab:='';
     i:=length(s);
     while s[i]=' ' do
      dec(i);
     while s[i]<>' ' do
      dec(i);
     labstart:=i;
     inc(i);
     while (i<=length(s)) and (s[i]<>' ') do begin
      lab:=lab+s[i];
      inc(i)
     end
    end;
    case cmd of
     0:begin
        writeln(g,equname(N)+' OR 40H');
        writeln(g,labname(N)+':');
        inc(N);
        writeln(g,s);
        writeln(g,'DB 0E9H, 0, 0')
       end;
     1:begin
        writeln(g,equname(N)+' OR 80H');
        writeln(g,labname(N)+':');
        inc(N);
        writeln(g,s);
        writeln(g,'DB 0E9H, 0, 0')
       end;
     2:begin
        writeln(g,equname(N));
        writeln(g,labname(N)+':');
        inc(N);
        writeln(g,s)
       end;
     3:begin
        delete(s,labstart,100);
        writeln(g,equname(N)+' OR 80H');
        writeln(g,labname(N)+':');
        inc(N);
        writeln(g,s+' $+5');
        writeln(g,'DB 0E9H, 3, 0');
        writeln(g,'DB 0E9H');
        writeln(g,'DW OFFSET '+lab+'-$-2')
       end;
     4:begin
        writeln(g,equname(N)+' OR 40H');
        writeln(g,labname(N)+':');
        inc(N);
        writeln(g,'DB 0E9H');
        writeln(g,'DW OFFSET '+lab+'-$-2')
       end;
     5:begin
        writeln(g,s)
       end
    end
   end
   else
    writeln(g,s0)
 end;

 close(g);
 close(f)
End.