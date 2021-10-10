Var f,g,h:text;
    s,t:string;
    i:word;
Const N:word=0;
Begin
 if paramcount<2 then begin
  writeln('Listing File Processor for GPS');
  writeln('Copyright (C) 1999 by Tahorg');
  writeln('Usage: lfp <infile> <outfile>');
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
 assign(h,'lfp.$$$');
 rewrite(h);

 while not eof(f) do begin
  readln(f,s);
  if pos('GPSVAR_',s)<>0 then begin
   i:=pos('=OFFSET',s);
   t:=copy(s,i+8,4);
   writeln(h,'db '+t+'h');
   inc(N)
  end
 end;

 close(h);
 writeln(g,'N equ ',N);
 write(g,'BlockPos ');
 for i:=1 to N do
  writeln(g,'dw ',i-1);
 write(g,'BlockSize ');
 reset(h);
 for i:=1 to N do begin
  readln(h,s);
  writeln(g,s);
 end;
 close(h);
 erase(h);

 close(g);
 close(f)
End.