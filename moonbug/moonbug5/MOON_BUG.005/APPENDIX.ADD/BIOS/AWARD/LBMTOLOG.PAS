Program LbmToLog;
uses Crt;
type
 Col=record
      R,G,B:byte;
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
 PAL:array[0..15] of Col;
 TPAL:array[0..15] of byte;
 MAS,NMAS:array[1..4,1..80] of byte;
 ST:array[1..4] of char;
Procedure Halt1;
begin
 writeln('LBMTOLOG is lbm to Award logo bmp converter');
 writeln('Using: awardlog <lbm file name> <award logo bmp file name>');
 Halt(1);
end;
Procedure Halt2;
begin
 writeln('File ',ParamStr(1),' is not correct lbm file');
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
 if FileSize(F1)<=104
  then
   Halt2;
 Seek(F1,20);
 BlockRead(F1,C,1);
 BlockRead(F1,NC,1);
 FM:=NC+C*256;
 BlockRead(F1,C,1);
 BlockRead(F1,NC,1);
 FL:=NC+C*256;
 Seek(F1,48);
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
 Seek(F1,104);
 BlockWrite(F2,ST,4);
 BlockWrite(F2,FM,2);
 BlockWrite(F2,FL,2);
 for L:=1 to FL do
  begin
   for T:=1 to 4 do
    BlockRead(F1,MAS[T],FM div 8);
   for M:=1 to FM div 8 do
    begin
     for T:=1 to 4 do
      NMAS[T,M]:=0;
     for T:=1 to 8 do
      begin
       C:=0;
       for N:=1 to 4 do
        begin
         C:=C*2+(MAS[N,M] div 128);
         MAS[N,M]:=MAS[N,M] shl 1;
        end;
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