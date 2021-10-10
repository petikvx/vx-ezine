const
 hex:array [0..15] of char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

function writehex (b:word):string;
var
 s:string[10];
begin
 s:= '';
 if b = 0 then s:= '0';
 while b > 0 do
  begin
   s:= hex[b and $F]+s;
   b:= b div 16;
  end;
 writehex:=s;
end;

var
 f:file;
 t:text;
 s:string;
 buf:array [0..30000] of byte;
 i,size:word;
 d:boolean;
BEGIN
 if paramcount < 1 then halt(1);
 s:= paramstr(1);
 if pos('.',s) > 0 then s:= copy(s,0,length(s)-4);
 assign(f,s+'.com');
 reset(f,1);
 size:= filesize(f);
 blockread(f,buf,size);
 close(f);
 assign(t,s+'.dbg');
 rewrite(t);
 writeln(t,'e 100');
 write(t,writehex(buf[0]));
 i:= 1;
 while i < size do
  begin
   write(t,' ',writehex(buf[i]));
   inc(i);
  end;
 writeln(t);
 close(t);
END.