Program AwardLog;
type
 Sarr=array[1..80] of byte;
 Parr=^Sarr;
var
 L,T:integer;
 K:byte;
 P:Parr;
 FL,FM:word;
 MAS:Sarr;
 Z:array[1..4] of char;
 F:file;
Procedure Halt1;
begin
 writeln('AWARDLOG is Award logo bmp viewer');
 writeln('Using: awardlog <award logo bmp file name>');
 Halt(1);
end;
Procedure Halt2;
begin
 writeln('File ',ParamStr(1),' is not Award logo bmp file');
 Halt(1);
end;
begin
 if ParamCount<1
  then
   Halt1;
 {$I-}
 Assign(F,ParamStr(1));
 Reset(F,1);
 if IOResult<>0
  then
   Halt1;
 {$I+}
 if FileSize(F)<=8
  then
   Halt2;
 BlockRead(F,Z,4);
 if ((Z[1]<>'A')or(Z[2]<>'W'))or((Z[3]<>'B')or(Z[4]<>'M'))
  then
   Halt2;
 asm
  mov AX,0012h
  int 10h
  mov AL,05h
  mov AH,0h
  mov DX,03CEh
  out DX,AX
  mov AL,03h
  mov AH,0h
  mov DX,03CEh
  out DX,AX
  mov AL,01h
  mov AH,0h
  mov DX,03CEh
  out DX,AX
  mov AL,08h
  mov AH,0FFh
  mov DX,03CEh
  out DX,AX
 end;
 BlockRead(F,FM,2);
 BlockRead(F,FL,2);
 for L:=0 to FL-1 do
  for T:=0 to 3 do
   begin
    BlockRead(F,MAS,FM div 8);
    K:=1 shl T;
    asm
     mov AL,02h
     mov AH,K
     mov DX,03C4h
     out DX,AX
    end;
    P:=Ptr($A000,L*80);
    P^:=MAS;
   end;
 readln;
 asm
  mov AX,0003h
  int 10h
 end;
 Close(F);
end.