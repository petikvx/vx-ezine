unit lgArray;
interface
type longArray=record name: string[40];
                      private: array[1..35] of byte
     end;
     stringPtr=^string;

    longintPtr=^longint;
    dictionary=record name: string[40];
                    index,corpus: longArray;
                    frequency: longint;
                    fqPtr: longintPtr;
     end;

procedure memAssign(var a: longArray; st: string);
procedure memRewrite(var a: longArray; items: longint; itemSize: word);
procedure memReset(var a: longArray);
procedure memSeek(var a: longArray; item: longint);
procedure memAppend(var a: longArray);
procedure memRead(var a: longArray; var item);
procedure memWrite(var a: longArray; var item);
procedure memSeekAndRead(var a: longArray; i: longint; var item);
procedure memSeekAndWrite(var a: longArray; i: longint; var item);
procedure memGet(var a: longArray; var item);
procedure memPut(var a: longArray; var item);
procedure memSeekAndGet(var a: longArray; i: longint; var item);
procedure memSeekAndPut(var a: longArray; i: longint; var item);
procedure memClose;
procedure memErase(var a: longArray);
function  memFileSize(var a: longArray):longint;
function  memLast(var a: longArray): longint;
function  memFilePos(var a: longArray): longint;
function  memEof(var a: longArray): boolean;

procedure dicAssign(var d: dictionary; st: string);
procedure dicRewrite(var d: dictionary; items: longint);
procedure dicReset(var d: dictionary);
procedure dicSeek(var d: dictionary; item: longint);
procedure dicAppend(var d: dictionary);
procedure dicFind(var d: dictionary; st: string; var foundPos: longint);
procedure dicFindBetween(var d: dictionary; st: string; lo,hi: longint; var foundPos: longint);
procedure dicRead(var d: dictionary; var st: string);
procedure dicWrite(var d: dictionary; st: string);
procedure dicPut(var d: dictionary; st: string);
procedure dicGet(var d: dictionary; var st: string);
procedure dicAdd(var d: dictionary; st: string; fq: longint);
procedure dicSeekAndWrite(var d: dictionary; i: longint; st: string);
procedure dicSeekAndRead(var d: dictionary; i: longint; var st: string);
procedure dicSeekAndGet(var d: dictionary; i: longint; var st: string);
procedure dicSeekAndPut(var d: dictionary; i: longint; st: string);
procedure dicClose;
procedure dicErase(var d: dictionary);
function  dicFileSize(var d: dictionary):longint;
function  dicLast(var d: dictionary): longint;
function  dicFilePos(var d: dictionary): longint;
function  dicEof(var d: dictionary): boolean;

procedure SetFq(var st: string; fq: longint);
procedure GetFq(var st: string; var fq: longint);

const expectedWordLength=10;

type aRowPtr=^aRow;
     aDictionaryPtr=^dictionary;
     anIndex=array[0..0] of aRowPtr;
     anIndexPtr=^anIndex;
     aRow= array[0..0] of byte;

     memRec=object
       name: string[40];
       bytesPerRow,bytesInIndex,lastRow,recordsPerRow,
       bytesPerRecord,shift,mask: word;
       maxRecordsInArray,lastRecord,pos: longint;
       insertMode: boolean;
       rowPtrNo: anIndexPtr;
       dicPtr:   aDictionaryPtr;
     end;

implementation

uses crt;

procedure SaveDic(var d: dictionary; fn: string);
var f: text; c,cc: char; i: longint; st: string;
begin write('Save current state of dictionary? (y/n) ');
      repeat c:=upcase(readkey);
             if keypressed then cc:=readkey
      until (c='Y') or (c='N');
      writeln;
      if c='Y' then
      begin assign(f,fn);
            rewrite(f);
            write('Saving to '+fn+'... ');
            dicSeek(d,1);
            for i:=1 to dicLast(d) do
            begin dicRead(d,st);
                  SetFq(st,d.frequency);
                  writeln(f,st)
            end;
            Close(f);
            writeln(' Dictionary saved.')
      end;
end;

procedure SaveMem(var a: longArray; fn: string);
var f: file of byte; i: longint; j,n: word; c,cc: char;
    unknown: array[1..8196] of byte;
begin write('Save current state of array? (y/n) ');
      repeat c:=upcase(readkey);
             if keypressed then cc:=readkey
      until (c='Y') or (c='N');
      writeln;
      if c='Y' then
      begin assign(f,fn);
            rewrite(f);
            write('Saving to '+fn+'... ');
            memReset(a);
            n:=memRec(a).bytesPerRecord;
            for i:=0 to memLast(a) do
            begin memRead(a,unknown);
                  for j:=1 to n do write(f,unknown[j])
            end;
            Close(f);
            writeln(' Array saved.')
      end;
end;

procedure Abort(var a: longArray; bytesNeeded: longint; msg: string);
begin with memRec(a) do
begin    writeln;
         write('Not enough space for '+msg+' of "'+name+'"');
         if dicPtr<>nil then
         writeln(' of dictionary "'+dicPtr^.name+'"')
         else writeln;
         writeln(bytesNeeded,' bytes needed, ',MaxAvail,' available');
         if dicPtr<>nil then
         begin SaveDic(dicPtr^,'ABORTED.DIC'); dicErase(dicPtr^);
         end
         else
         begin SaveMem(a,'ABORTED.MEM'); memErase(a)
         end;
         Halt(1);
end
end;

procedure SetFq(var st: string; fq: longint);
begin if length(st)>251 then st[0]:=#251;
      move(fq,st[length(st)+1],4); inc(st[0],4);
end;

procedure GetFq(var st: string; var fq: longint);
begin dec(st[0],4);
      move(st[length(st)+1],fq,4)
end;

procedure MemAssign(var a: longArray; st: string);
begin a.name:=st
end;

procedure MemReset(var a: longArray);
begin MemSeek(a,0)
end;

procedure MemAppend(var a: longArray);
begin MemSeek(a,MemFileSize(a))
end;

procedure MemRewrite(var a: longArray; items: longint; itemSize: word);
var i: word; expectedSize,n: longint;
begin
    FillChar(a.Private,SizeOf(a.Private),0);
    with memRec(a) do
begin
   bytesPerRecord:=itemSize;
   expectedSize:=items*bytesPerRecord;
   recordsPerRow:=65520 div bytesPerRecord;
   if recordsPerRow>items then recordsPerRow:=items;
   n:=32768; shift:=15;
   while (n>recordsPerRow) and (n>2) do begin n:=n div 2; dec(shift) end;
   mask:=(1 shl shift) -1;
   recordsPerRow:=n;
   bytesPerRow:=recordsPerRow * bytesPerRecord;
   lastRow:=items div recordsPerRow; (* first Row = 0 *)
   maxRecordsInArray:=longint(lastRow+1) * longint(recordsPerRow);
   lastRecord:=-1;
   bytesInIndex:=(lastRow+1)*sizeOf(pointer);
   GetMem(rowPtrNo,bytesInIndex);
   for i:=0 to lastRow do
   begin
         GetMem(rowPtrNo^[i],bytesPerRow);
         FillChar(rowPtrNo^[i]^,bytesPerRow,0)
   end;
end
end;

procedure MemExpand(var a: longArray; items: longint);
var newLastRow,bytesInNewIndex,i: word;
    newIndex_: anIndexPtr;
begin with memRec(a) do
begin
   newLastRow:=(items) div recordsPerRow;
   if newLastRow<=lastRow then exit;
   bytesInNewIndex:=(newLastRow+1)*sizeOf(pointer);
   if bytesInNewIndex>MaxAvail then Abort(a,bytesInNewIndex,' index ');


   GetMem(newIndex_,bytesInNewIndex);
   Move(rowPtrNo^,newIndex_^,bytesInIndex);
   FreeMem(rowPtrNo,bytesInIndex);
   rowPtrNo:=newIndex_;
   for i:=lastRow+1 to newLastRow do
   begin
         if bytesPerRow>MaxAvail then
         Abort(a,bytesPerRow,' data ');

         GetMem(rowPtrNo^[i],bytesPerRow);
         FillChar(rowPtrNo^[i]^,bytesPerRow,0);
   end;
   lastRow:=newLastRow;
   bytesInIndex:=bytesInNewIndex;
   maxRecordsInArray:=(lastRow+1)*recordsPerRow;
end
end;

procedure memReadString(var a: longArray; var st: string);
var row,col,lgth: word;
    stPtr: stringPtr;
begin with memRec(a) do
begin
      row:= pos shr shift;
      col:=(pos and mask);
      stPtr:=addr(rowPtrNo^[row]^[col]);
      lgth:=length(stPtr^)+1;
      Move(stPtr^,st,lgth);
      inc(pos,lgth);
end
end;

procedure memReadStringPtr(var a: longArray; var st: stringPtr);
var row,col: word;
begin with memRec(a) do
begin
      row:= pos shr shift;
      col:=(pos and mask);
      st:=addr(rowPtrNo^[row]^[col]);
end
end;

procedure MemWriteString(var a: longArray; st: string);
var row,col,lgth: word;
begin with memRec(a) do
begin lgth:=length(st)+1;
      row:= pos shr shift;
      col:=(pos and mask);
      if col+lgth>bytesPerRow-1
      then
      begin inc(row); col:=0;
            if row>lastRow then
            MemExpand(a,longint(row+1)*bytesPerRow);
      end;
      Move(st,rowPtrNo^[row]^[col],lgth);
      lastRecord:=longint(row)*bytesPerRow+col+lgth-1;
      pos:=lastRecord+1;
end
end;

procedure MemSeek(var a: longArray; item: longint);
begin with memRec(a) do
begin if (item<0) then Exit;
      if (item>maxRecordsInArray) then MemExpand(a,item);
      pos:=item;
end;
end;

procedure memMoveVar(var a: longArray; pos1,pos2,itemsToMove: longint);
var newlastRecord,newItemCapacity: longint;
    itemsFromSource,itemsIntoTarget: word;
    res, {Row of end of source }
    rss, {Row of start of source }
    css, {Col of start of source }
    ces, {Col of end of source }
    ret, {Row of end of target }
    cet  {Col of end of target }
    : word;
begin with MemRec(a) do
begin newlastRecord:=pos2+itemsToMove-1;
      if newLastRecord<lastRecord then newLastRecord:=lastRecord;
      newItemCapacity:=newlastRecord div recordsPerRow * recordsPerRow{-1};
      lastRecord:=newLastRecord;
      if newLastRecord>=maxRecordsInArray then
      begin MemExpand(a,newlastRecord);
      end;
      rss:=pos1 div recordsPerRow;
      css:= pos1 mod recordsPerRow;
      inc(pos1,itemsToMove-1); inc(pos2,itemsToMove-1);
      res:=pos1 div recordsPerRow;
      ret:=pos2 div recordsPerRow;
      ces:=pos1 mod recordsPerRow;
      cet:=pos2 mod recordsPerRow;
      repeat
             if rss=res then
             itemsFromSource:=itemsToMove
             else itemsFromSource:=ces+1;
             itemsIntoTarget:=cet+1;
             if itemsFromSource>itemsIntoTarget
             then itemsFromSource:=itemsIntoTarget;
                  Move(rowPtrNo^[res]^[bytesPerRecord*(ces+1-itemsFromSource)],
                  rowPtrNo^[ret]^[bytesPerRecord*(cet+1-itemsFromSource)],
                  itemsFromSource*bytesPerRecord);
             dec(itemsToMove,itemsFromSource);
             dec(pos1,itemsFromSource);
             res:=pos1 div recordsPerRow;
             ces:=pos1 mod recordsPerRow;
             dec(pos2,itemsFromSource);
             ret:=pos2 div recordsPerRow;
             cet:=pos2 mod recordsPerRow;
      until itemsToMove=0;
end
end;

procedure memPutVar(var a: longArray; var what);
var row,col: word;
    dummy: byte absolute what;
begin with memRec(a) do
begin
      if pos+1>maxRecordsInArray then BEGIN
        MemExpand(a,pos);
      END;
      if pos>lastRecord then lastRecord:=pos;
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(dummy,rowPtrNo^[row]^[col],bytesPerRecord);
end;
end;

procedure memInsertVar(var a: longArray; var what);
var row,col: word;
    dummy: byte absolute what;
begin with memRec(a) do
begin if pos<=lastRecord
      then memMoveVar(a,pos,pos+1,lastRecord-pos+1)
      else
      begin if pos+1>maxRecordsInArray then MemExpand(a,pos);
            if pos>lastRecord then lastRecord:=pos;
      end;
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(dummy,rowPtrNo^[row]^[col],bytesPerRecord);
end;
end;

procedure MemRead(var a: longArray; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
      inc(pos)
    end
end
end;

procedure MemGet(var a: longArray; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
    end
end
end;

procedure MemWrite(var a: longArray; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin
       if insertMode then MemInsertVar(a,anon)
       else MemPutVar(a,anon);
       inc(pos)
end;
end;

procedure MemPut(var a: longArray; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin if insertMode then MemInsertVar(a,anon)
      else MemPutVar(a,anon);
end;
end;

procedure MemSeekAndWrite(var a: longArray; i: longint; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin pos:=i;
      if insertMode then MemInsertVar(a,anon)
      else MemPutVar(a,anon);
      inc(pos);
end;
end;

procedure MemSeekAndPut(var a: longArray; i: longint; var item);
var anon: byte absolute item;
begin with memRec(a) do
begin pos:=i;
      if insertMode then MemInsertVar(a,anon)
      else MemPutVar(a,anon);
end;
end;

procedure MemSeekAndRead(var a: longArray; i: longint; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin pos:=i;
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
      inc(pos)
    end
end
end;

procedure MemSeekAndGet(var a: longArray; i: longint; var item);
var row,col: word; dummy: byte absolute item;
begin with MemRec(a) do
begin pos:=i;
    if pos>lastRecord then FillChar(dummy,bytesPerRecord,0)
    else
    begin
      row:= pos shr shift;
      col:=(pos and mask) * bytesPerRecord;
      Move(rowPtrNo^[row]^[col],dummy,bytesPerRecord);
    end
end
end;

procedure MemSetInsertMode(var a: longArray; onOff: boolean);
begin memRec(a).insertMode:=onOff
end;

procedure MemClose;
begin
end;

procedure MemErase(var a: longArray);
var i: word;
begin with MemRec(a) do
begin for i:=lastRow downto 0 do
      FreeMem(rowPtrNo^[i],bytesPerRow);
      FreeMem(rowPtrNo,bytesInIndex);
end
end;

function MemLast(var a: longArray): longint;
begin MemLast:=memRec(a).lastRecord
end;

function  MemFileSize(var a: longArray):longint;
begin MemFileSize:=memRec(a).lastRecord+1
end;

function  MemEof(var a: longArray): boolean;
begin with memRec(a) do MemEof:=pos>lastRecord;
end;

function  MemFilePos(var a: longArray): longint;
begin MemFilePos:=memRec(a).pos
end;

procedure dicAssign(var d: dictionary; st: string);
begin with d do
begin name:=st;
      memAssign(index,'index'); memAssign(corpus,'corpus');
end
end;

procedure dicReset(var d: dictionary);
begin dicSeek(d,0)
end;

procedure dicAppend(var d: dictionary);
begin dicSeek(d,dicFileSize(d))
end;

procedure dicRewrite(var d: dictionary; items: longint);
var null: string;
begin with d do
begin memRewrite(index,items,SizeOf(pointer));
      memSetInsertMode(index,true);
      items:=items*(expectedWordLength+5);
      if items<256 then items:=256;
      memRewrite(corpus,items,sizeOf(char));
      memRec(index).dicPtr:=@d;
      memRec(corpus).dicPtr:=@d;
end;
      null:='';
      dicPut(d,null);
end;

procedure dicClose;
begin
end;

procedure dicErase(var d: dictionary);
begin memErase(d.corpus); memErase(d.index)
end;

procedure dicSeek(var d: dictionary; item: longint);
begin memSeek(d.index,item)
end;

procedure dicFind(var d: dictionary; st: string; var foundPos: longint);
var lo,mid,hi,posInCorpus,oldPos: longint; found: boolean;
    tmpPtr: stringPtr; tmp: string;
begin with d do
begin found:=false; lo:=0; hi:=memFileSize(index)-1;
      oldPos:=memRec(corpus).pos;
      while (lo<=hi) and not found do
      begin mid:=(lo+hi) div 2;
         memSeekAndRead(index,mid,posInCorpus);
         memSeek(corpus,posInCorpus);
         memReadStringPtr(corpus,tmpPtr);
         tmp:=tmpPtr^;
         GetFq(tmp,frequency);
         if st>tmp then lo:=mid+1 else
         if st<tmp then hi:=mid-1 else
         if st=tmp then found:=true;
      end;
      if found then
      begin FoundPos:=mid;
            fqPtr:=longintPtr(longint(tmpPtr)+length(tmp)+1);
      end
      else foundPos:=-lo;
      memRec(corpus).pos:=oldPos;
end;
end;

procedure dicFindBetween(var d: dictionary; st: string; lo,hi: longint; var foundPos: longint);
var mid,posInCorpus,oldPos: longint; found: boolean;
    tmpPtr: stringPtr; tmp: string;
begin with d do
begin found:=false;
      if lo>hi then
      begin mid:=lo; lo:=hi; hi:=mid
      end;
      mid:=memFileSize(index)-1;
      if lo>mid then lo:=mid;
      if hi>mid then hi:=mid;
      oldPos:=memRec(corpus).pos;
      while (lo<=hi) and not found do
      begin mid:=(lo+hi) div 2;
         memSeekAndRead(index,mid,posInCorpus);
         memSeek(corpus,posInCorpus);
         memReadStringPtr(corpus,tmpPtr);
         tmp:=tmpPtr^;
         GetFq(tmp,frequency);
         if st>tmp then lo:=mid+1 else
         if st<tmp then hi:=mid-1 else
         if st=tmp then found:=true;
      end;
      if found then
      begin FoundPos:=mid;
            fqPtr:=longintPtr(longint(tmpPtr)+length(tmp)+1);
      end
      else foundPos:=-lo;
      memRec(corpus).pos:=oldPos;
end;
end;

procedure dicRead(var d: dictionary; var st: string);
var posInCorpus: longint;
begin with d do
begin memRead(index,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicGet(var d: dictionary; var st: string);
var posInCorpus: longint;
begin with d do
begin memGet(index,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicPut(var d: dictionary; st: string);
var indexPos: longint;
begin with d do
begin
      SetFq(st,1);
      memWriteString(corpus,st);
      indexPos:=memFileSize(corpus)-(length(st)+1);
      memWrite(index,indexPos);
end
end;

procedure dicSeekAndRead(var d: dictionary; i: longint; var st: string);
var posInCorpus: longint;
begin with d do
begin memSeekAndRead(index,i,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicSeekAndWrite(var d: dictionary; i: longint; st: string);
var corpusPos: longint;
begin with d do
begin SetFq(st,1);
      memWriteString(corpus,st);
      corpusPos:=memFilePos(corpus)-(length(st)+1);
      memSeekAndWrite(index,i,corpusPos);
end
end;


procedure dicSeekAndGet(var d: dictionary; i: longint; var st: string);
var posInCorpus: longint;
begin with d do
begin memSeekAndPut(index,i,posInCorpus);
      memSeek(corpus,posInCorpus);
      memReadString(corpus,st);
      GetFq(st,frequency);
end
end;

procedure dicSeekAndPut(var d: dictionary; i: longint; st: string);
var corpusPos: longint;
begin with d do
begin SetFq(st,1);
      memWriteString(corpus,st);
      corpusPos:=memFilePos(corpus)-(length(st)+1);
      memSeekAndPut(index,i,corpusPos);
end
end;

procedure dicWrite(var d: dictionary; st: string);
var i: longint;
begin dicFind(d,st,i);
      if i<0 then dicSeekAndWrite(d,-i,st)
      else inc(d.fqPtr^);
end;

procedure dicAdd(var d: dictionary; st: string; fq: longint);
var i: longint;
begin dicFind(d,st,i);
      if i<0 then
      begin SetFq(st,fq);
            dicSeekAndWrite(d,-i,st)
      end
      else
      begin inc(d.fqPtr^,fq);
            d.frequency:=d.fqPtr^
      end
end;

function dicLast(var d: dictionary): longint;
begin with d do dicLast:=memLast(index);
end;

function  dicFileSize(var d: dictionary):longint;
begin with d do dicFileSize:=memFileSize(index);
end;

function  dicFilePos(var d: dictionary): longint;
begin with d do dicFilePos:=memFilePos(index)
end;

function  dicEof(var d: dictionary): boolean;
begin with d do dicEof:=memEof(index)
end;
end.

