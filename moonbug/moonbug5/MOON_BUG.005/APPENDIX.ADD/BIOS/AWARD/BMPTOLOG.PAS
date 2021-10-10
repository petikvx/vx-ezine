Program BmpToLog;
uses Crt;
type
 Col=record
      R,G,B:byte;
     end;
 SCol=record
       B,G,R,S:byte;
      end;
const
 STPAL:array[0..15] of Col=((R:0;G:0;B:0),(R:0;G:0;B:168),(R:0;G:168;B:0),
                         (R:0;G:168;B:168),(R:168;G:0;B:0),(R:168;G:0;B:168),
                         (R:168;G:84;B:0),(R:168;G:168;B:168),
                         (R:84;G:84;B:84),(R:84;G:84;B:252),(R:84;G:252;B:84),
                         (R:84;G:252;B:252),(R:252;G:84;B:84),
                         (R:252;G:84;B:252),(R:252;G:252;B:84),
                         (R:252;G:252;B:252));
var
 M,L,T,N,FM,FL,DPAL,DPALMIN:integer;
 C,NC:byte;
 F1,F2:file;
 PAL:array[0..15] of SCol;
 TPAL:array[0..15] of byte;
 MAS:array[1..320] of byte;
 NMAS:array[1..4,1..80] of byte;
 ST:array[1..4] of char;
Procedure Halt1;
begin
 writeln('BMPTOLOG is bmp to Award logo bmp converter');
 writeln('Using: awardlog <bmp file name> <award logo bmp file name>');
 Halt(1);
end;
Procedure Halt2;
begin
 writeln('File ',ParamStr(1),' is not correct bmp file');
 Halt(1);
end;
begin
 if ParamCount<2
  then
   Halt1;
 {$I-}
 Assign(F1,ParamStr(1));
 Assign(F2,ParamStr(2));
 Reset(F1,1);
 if IOResult<>0
  then
   Halt1;
 ReWrite(F2,1);
 if IOResult<>0
  then
   Halt1;
 {$I+}
 if FileSize(F1)<=118
  then
   Halt2;
 Seek(F1,18);
 BlockRead(F1,FM,2);
 Seek(F1,22);
 BlockRead(F1,FL,2);
 Seek(F1,54);
 BlockRead(F1,PAL,SizeOf(PAL));
 for M:=0 to 15 do
  begin
   DPAlMIN:=1024;
   for L:=0 to 15 do
    begin
     DPAL:=abs(STPAL[L].R-PAL[M].R)+abs(STPAL[L].G-PAL[M].G)+abs(STPAL[L].B-PAL[M].B);
     if DPAL<DPALMIN
      then
       begin
        DPALMIN:=DPAL;
        TPAL[M]:=L;
       end;
    end;
  end;
 ST[1]:='A';
 ST[2]:='W';
 ST[3]:='B';
 ST[4]:='M';
 BlockWrite(F2,ST,4);
 BlockWrite(F2,FM,2);
 BlockWrite(F2,FL,2);
 for L:=1 to FL do
  begin
   Seek(F1,118+LongInt(FM div 2)*LongInt(FL-L));
   BlockRead(F1,MAS,FM div 2);
   for M:=1 to FM div 8 do
    begin
     for T:=1 to 4 do
      NMAS[T,M]:=0;
     for T:=1 to 8 do
      begin
       if (T mod 2)>0
        then
         C:=MAS[(M-1)*4+(T-1) div 2+1] div 16
        else
         C:=MAS[(M-1)*4+(T-1) div 2+1] mod 16;
       NC:=TPAL[C];
       for N:=1 to 4 do
        begin
         if (NC div 8)>0
          then
           NMAS[N,M]:=NMAS[N,M]+(1 shl (8-T));
         NC:=(NC mod 8) shl 1;
        end;
      end;
    end;
   for T:=1 to 4 do
    BlockWrite(F2,NMAS[T],FM div 8);
  end;
 Close(F1);
 Close(F2);
end.