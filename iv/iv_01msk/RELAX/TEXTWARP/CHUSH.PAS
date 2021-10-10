Uses Crt;
Const
 GenSize=4*1024;
 GroupSize=3;
Type
 PGroupRec=^TGroupRec;
 TGroupRec=
 Record
  s     : string[GroupSize];
  c     : longint;
  a,b,p : real;
  next  : PGroupRec;
 End;
Var
 Gluk       : boolean;
 Ch         : char;
 Direct     : boolean;
 prvs       : string[GroupSize-1];
 First      : array [char] of PGroupRec;
 Curr       : PGroupRec;
 F          : File;
 T          : Text;
 Buf        : array [1..4096] of char;
 r,i,j      : integer;
 ss         : string[GroupSize];
 cc,gg,mems : longint;
 rr         : longint;
 Prv,c,op,k : real;

Const
 CacheSize=512;

Var
 CacheBuf   : array [1..CacheSize] of byte;
 Index      : word;


Procedure FFlush;
Var
 r:integer;
Begin
 BlockWrite(F,CacheBuf,Index,r);
 Index:=0;
 GoToXY(1,WhereY);
 Write(FilePos(F)/GenSize*100:3:0,'% of ',GenSize div 1024,'K written.');
End;

Procedure FWriteByte(b:byte);
Begin
 if Index=CacheSize then FFlush;
 Inc(Index);
 CacheBuf[Index]:=b;
End;



BEGIN
 cc:=0;
 gg:=0;
 rr:=0;
 Index:=0;
 mems:=MaxAvail;
 If ParamCount<2 then Halt;
 FillChar(First,SizeOf(First),0);
 Assign(F,ParamStr(1));
 Reset(F,1);
 if ioResult<>0 then
 Begin
  Writeln('Cannot open ',ParamStr(1));
  Halt;
 End;
 ClrScr;
 Writeln('Wait...');
 Repeat
  BlockRead(F,Buf,Sizeof(Buf),r);
  If r>GroupSize then
   For i:=1 to r-GroupSize do
   Begin
    Inc(cc);
    ss:='';
    For j:=1 to GroupSize do
     ss:=ss+Buf[i+j-1];
    Curr:=First[ss[1]];
    While Curr<>nil do
    Begin
     If Curr^.s=ss then
     Begin
      Inc(Curr^.c);
      Break;
     End;
     Curr:=Curr^.Next;
    End; {While}
    If Curr=nil then
    Begin
     If MaxAvail<1024 then
     Begin
      Writeln('Warning : out of memory, loading not completed.');
      Gluk:=True;
      Break;
     End;
     New(Curr);
     Curr^.c:=1;
     Curr^.s:=ss;
     Curr^.Next:=First[ss[1]];
     First[ss[1]]:=Curr;
     Inc(gg);
    End; {Curr=nil}
   End; {For}
  If Gluk Then Break;
  ClrScr;
  Writeln('Wait...');
  Writeln('Loading ',ParamStr(1),', ',Filesize(F) div 1024,'K, ',FilePos(F)/FileSize(F)*100:3:0,'% completed.');
  Writeln(MaxAvail div 1024,'K memory remaining.');
  Writeln('Press any key to interrupt...');
  If KeyPressed then Gluk:=True;
 Until (r<>sizeof(Buf)) or Gluk;
 Writeln(gg div 1024,'K groups loaded, ',(mems-MaxAvail) div 1024,'K memory used.');
 Writeln('Sorting...');
 For ch:=#0 to #255 do
 Begin
  Curr:=First[ch];
  Prv:=0;
  While Curr<>nil do
  Begin
   c:=Curr^.c/cc;
   Curr^.p:=c;
   Curr^.a:=Prv;
   Prv:=Prv+c;
   Curr^.b:=Prv;
   Curr:=Curr^.Next;
  End;
 End;
 Close(F);
 Assign(T,ParamStr(2));
 Rewrite(T);
 if ioResult<>0 then
 Begin
  Writeln('Cannot create ',ParamStr(2));
  Halt;
 End;
 Writeln(T,'Source file was ',ParamStr(1));
 Writeln(T,gg div 1024,'K groups loaded, GroupSize = ',GroupSize);
 Close(T);
 Assign(F,ParamStr(2));
 Reset(F,1);
 Seek(F,FileSize(F));
 Writeln('Generation...');
 Write('  0% of ',GenSize div 1024,'K written.');
 Randomize;
 Prvs:='';
 For i:=1 to GroupSize-1 do Prvs:=Prvs+' ';
 For i:=1 to GenSize do
 Begin
  op:=0;
  Curr:=First[prvs[1]];
  While Curr<>nil do
  Begin
   If prvs=Copy(Curr^.s,1,GroupSize-1) then
    op:=op+Curr^.b-Curr^.a;
   Curr:=Curr^.Next;
  End;
  If op=0 then
  Begin
   Direct:=True;
   c:=0;
   Inc(rr);
   For ch:=#0 to #255 do
    If First[ch]<>nil then Break;
  End {if op=0}
  else
  Begin
   ch:=prvs[1];
   Direct:=False;
   c:=Random*op;
  End; {elseif op=0}
  Curr:=First[ch];
  Prv:=0;
  While Curr<>nil do
  Begin
   If (Prvs=Copy(Curr^.s,1,GroupSize-1)) then Prv:=Prv+Curr^.p;
   If (Direct and (Curr^.a>=c) and (c<=Curr^.b)) or
      ((Prvs=Copy(Curr^.s,1,GroupSize-1)) and (Prv>c)) then
   Begin
    Prvs:=Copy(Curr^.s,2,GroupSize-1);
    FWriteByte(Ord(Curr^.s[Length(Curr^.s)]));
    Break;
   End; {if}
   Curr:=Curr^.Next;
  End; {while}
 End; {for}
 FFlush;
 Writeln;
 Close(F);
 Writeln('DONE.');
END.

