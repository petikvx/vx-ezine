{ ************************************************************ }
{ *		     Tower Runtime Library		     * }
{ *							     * }
{ *		     TFUNC  Interface Unit		     * }
{ *							     * }
{ *	  Copyright (c) 1995,96 by Vladimir S. Lokhov	     * }
{ *    It's an Object Oriented Interface Library for DOS     * }
{ *	User font, mouse, 16 clr background, high speed,     * }
{ *	     dynamic virtual methods, and more ...	     * }
{ ************************************************************ }
unit tfunc;
interface
type
  PString=^String;
  tword=record
   case boolean of
     false:(blo,bhi:byte);
     true:(w:word);
   end;
  TLong=record
   wlo:tword;
   whi:tword;
  end;
const
  dtAmerican	=	0 ;
  dtMDY 	=	0 ;
  dtANSI	=	1 ;
  dtBritis	=	2 ;
  dtFrench	=	2 ;
  dtDMY 	=	2 ;
  dtItalian	=	3 ;
  dtGerman	=	4 ;
  dtUSA 	=	5 ;
  dtYMD 	=	6 ;
  lngEnglish	=	0 ;
  lngRussian	=	1 ;

var
  CfgFile:string[127];
  SProgName:string[8];
  ProgName:string[15];
  ProgPath:string[79];

function Max(a,b:Longint):Longint;
function Min(a,b:Longint):Longint;
function IsPKey(k:string):boolean;
function ValPKey(k:string):integer;
function StrPKey(k:string):string;
function UpStr(s:string):string;
function UpChar(c:char):char;
function ShowHex(value:word):string;
function ShowHexN(var value;num:byte):string;
function ShowHexB(value:byte):string;
function ShowPtr(value:pointer):string;
function ConvertNum(Num,NumBase:word):string;
function IStr(b,n:integer):string;
function RStr(n:real;a,b:byte):string;
function Space(n:byte):string;
function Ltrim(s:string):string;
function Rtrim(s:string):string;
function Addr20(p:pointer):longint;
function GetExtName(s:string):string;
function GetFName(s:string):string;
function Replicate(c:string;n:byte):string;
function Center(s:string;n:byte):string;
function GetDate(style:byte):string;
function GetTime:string;
function GetDay(lang:byte):string;
function BlockPresent(var memaddr,baddr;msize,bsize:word):boolean;
function BlockOffs (var memaddr,baddr;msize,bsize:word):Word;
function getcmosbyte(n:byte):longint;

implementation
const
 DayName:array[0..1,1..7] of string [11]=(
 ('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'),
 ('Воскресенье','Понедельник','Вторник','Среда',
  'Четверг','Пятница','Суббота')
 );
   function ConvertNum(Num,NumBase:word):string;assembler;
   asm
      les      di,@Result
      mov      cx,NumBase
      mov      bx,di
      mov      al,0
      cld
      stosb
      mov      ax,Num
      call     @@1
      jmp      @@4
  @@1:xor      dx,dx
      div      cx
      or       ax,ax
      push     dx
      jz       @@2
      call     @@1
  @@2:pop      ax
      cmp      al,0Ah
      jc       @@3
      add      al,7
  @@3:add      al,30h
      stosb
      inc      byte ptr es:[bx]
      retn
  @@4:
  end;

 function	getcmosbyte(n:byte):longint;
 var k:byte;
 begin
  repeat
  asm
   mov	al,n
   out	70h,al
   jmp	@@1
 @@1:
   jmp	@@2
 @@2:
   jmp	@@3
 @@3:
   in	al,71h
   mov	k,al
  end;
  until k<>$FF;
  getcmosbyte:=k;
 end;
 function	GetDate;
 var s1,s2,s3:string[7];
 s:string;
 begin
  s1:=ShowHexB(getcmosbyte(9));
  s2:=ShowHexB(getcmosbyte(8));
  s3:=ShowHexB(getcmosbyte(7));
  case style of
   dtAmerican,dtMDY:s:=s2+'/'+s3+'/'+s1;
   dtANSI:s:=s1+'.'+s2+'.'+s3;
   dtBritis,dtFrench,dtDMY:s:=s3+'/'+s2+'/'+s1;
   dtItalian:s:=s3+'-'+s2+'-'+s1;
   dtGerman:s:=s3+'.'+s2+'.'+s1;
   dtUSA:s:=s2+'-'+s3+'-'+s1;
   dtYMD:s:=s1+'/'+s2+'/'+s3;
   else s:=s3+'.'+s2+'.'+s1;
  end;
  GetDate:=s;
 end;
 function GetTime;
 begin
  GetTime:= ShowHexB(getcmosbyte(4))+
	':'+ShowHexB(getcmosbyte(2))+
	':'+ShowHexB(getcmosbyte(0));
 end;
 function GetDay;
 var m:byte;
 begin
  m:=GetCMOSByte(6);
  if m=0 then GetDay:='?' else GetDay:=DayName[lang][m];
 end;

function Max(a,b:Longint):Longint;
begin
 if a>b then max:=a else max:=b;
end;
function Min(a,b:Longint):Longint;
begin
 if a<b then min:=a else min:=b;
end;

function Center;
var k:byte;
begin
 s:=ltrim(rtrim(s));k:=(n-length(s)) shr 1;
 s:=space(k)+s+space(k);
 if length(s)<>n then s:=s+' ';
 center:=s;
end;

function UpChar;
begin
 case c of
  'a'..'z':UpChar:=chr(ord(c)-97+65);
  'а'..'п':UpChar:=chr(ord(c)-160+128);
  'р'..'я':UpChar:=chr(ord(c)-224+144);
   else UpChar:=c;
 end;
end;

function upstr;
var i:byte;
begin
 for i:=1 to byte(s[0]) do s[i]:=upchar(s[i]);
 upstr:=s;
end;

function IsPKey;
var
 s:string;
 i:byte;
begin
 IsPKey:=false;
 if paramcount=0 then exit;
 s:='';
 for i:=1 to paramcount do s:=s+paramstr(i);
 for i:=1 to length(s) do s[i]:=UpCase(s[i]);
 for i:=1 to length(k) do k[i]:=UpCase(k[i]);
 if pos(k,s)<>0 then IsPKey:=true;
end;
function valpkey;
var
 s:string;
 i:byte;
 c,vl:integer;
begin
 valpkey:=0;
 if paramcount=0 then exit;
 s:='';
 for i:=1 to paramcount do s:=s+paramstr(i);
 for i:=1 to length(s) do s[i]:=UpCase(s[i]);
 for i:=1 to length(k) do k[i]:=UpCase(k[i]);
 vl:=0;
 if pos(k,s)<>0 then begin
   delete(s,1,pos(k,s)+length(k)-1);
   val(s,vl,c);
   if c<>0 then val(copy(s,1,c-1),vl,c);
 end;
 valpkey:=vl;
end;

function strpkey;
var
 s:string;
 i:byte;
 c:integer;
begin
 strpkey:='';
 if paramcount=0 then exit else s:='';
 for i:=1 to paramcount do s:=s+paramstr(i)+#32;
 s:=UpStr(s);k:=UpStr(k);
 if pos(k,s)<>0 then begin
   delete(s,1,pos(k,s)+length(k)-1);
   i:=1;while (i<=byte(s[0])) and (s[i]<>#32) do inc(i);
   s:=copy(s,1,i-1);
   strpkey:=s;
 end;
end;

function istr;
var s:string;
begin
system.str(b,s);
s:='00000'+s;
if n=0 then n:=length(s)-5;
s:=copy(s,length(s)-n+1,n);
istr:=s;
end;

function rstr;
var s:string;
 r:integer;
begin
r:=0;
if n<>0 then r:=abs(round(ln(abs(n))/ln(10)));
if r<(a-b-1) then system.str(n:a:b,s) else system.str(n:a,s);
rstr:=s;
end;

function ShowHex;assembler;
asm
	les	di,@Result
	mov	byte ptr es:[di],5
	inc	di
	mov	ax,value
	mov	cl,12
@@Next: push	ax
	shr	ax,cl
	and	AL,0Fh
	aam
	db	0D5h,'A'-'0'
	add	al,'0'
	stosb
	pop	ax
	sub	cl,4
	jae	@@Next
	mov	al,'h'
	stosb
end;

function ShowHexB;assembler;
asm
	les	di,@Result
	mov	byte ptr es:[di],2
	inc	di
	xor	ax,ax
	mov	al,value
	mov	cl,4
@@Next: push	ax
	shr	ax,cl
	and	AL,0Fh
	aam
	db	0D5h,'A'-'0'
	add	al,'0'
	stosb
	pop	ax
	sub	cl,4
	jae	@@Next
end;

function showptr;
begin
 showptr:=showhex(seg(value^))+':'+showhex(ofs(value^));
end;

function ltrim;
var i:byte;
begin
  i:=1;
  while (s[i] in [#9,#32]) and (i<=byte(s[0])) do inc(i);
  delete(s,1,i-1);
  ltrim:=s;
end;

function rtrim;
var i:byte;
begin
  i:=byte(s[0]);
  while (s[i] in [#9,#32]) and (i>0) do dec(i);
  delete(s,i+1,byte(s[0])-i);
  rtrim:=s;
end;

function space;
var s:string;
begin
 fillchar(s[1],n,' ');s[0]:=char(n);
 space:=s;
end;
function addr20;
var
 l:record
   lw,hw:word;
  end absolute p;
begin
 addr20:=(longint(l.hw) shl 4)+l.lw;
end;

function getextname;
var
 l:byte absolute s;
 i:byte;
begin
 i:=l;while (i>0) and (s[i]<>'.') do dec(i);
 getextname:=copy(s,i+1,l-i);
end;
function getfname(s:string):string;
var
 l:byte absolute s;
 i:byte;
begin
 i:=l;while (i>0) and (s[i]<>'.') do dec(i);
 if i=0 then i:=l+1;
 getfname:=copy(s,1,i-1);
end;

function replicate;
var s:string;
begin
 s:='';
 while n>0 do begin s:=s+c;dec(n) end;
 replicate:=s;
end;

function BlockPresent(var memaddr,baddr;msize,bsize:word):boolean;assembler;
asm
	mov	cx,msize
	mov	dx,bsize
	push	ds
	les	di,memaddr
	lds	si,baddr
@@find_block:
	mov	al,byte ptr [si]
	repne	scasb
	or	cx,cx
	jcxz	@@block_not_found
	jmp	@@chk_equ_block
@@block_not_found:
	xor	ax,ax
	jmp	@@end_find_block
@@chk_equ_block:
	push	di
	push	si
	push	cx
	dec	di
	mov	cx,dx
	repe	cmpsb
	mov	ax,cx
	pop	cx
	pop	si
	pop	di
	or	ax,ax
	jnz	@@find_block
	mov	ax,1
@@end_find_block:
	pop	ds
end;

function BlockOffs (var memaddr,baddr;msize,bsize:word):Word;assembler;
asm
	mov	cx,msize
	mov	dx,bsize
	push	ds
	les	di,memaddr
	lds	si,baddr
@@find_block:
	mov	al,byte ptr [si]
	repne	scasb
	or	cx,cx
	jcxz	@@block_not_found
	jmp	@@chk_equ_block
@@block_not_found:
	xor	ax,ax
	jmp	@@end_find_block
@@chk_equ_block:
	push	di
	push	si
	push	cx
	dec	di
	mov	cx,dx
	repe	cmpsb
	mov	ax,cx
	pop	cx
	pop	si
	pop	di
	or	ax,ax
	jnz	@@find_block
	mov	ax,di
@@end_find_block:
	pop	ds
end;

function ShowHexN;
type a=array[1..15] of byte;
var i:byte;s:string;
 p:^a;
begin
 s:='';p:=@value;
 for i:=num downto 1 do s:=s+ShowHexB(p^[i]);
 ShowHexN:=s;
end;

var
 s:string;
 l:byte absolute s;
 i:byte;
begin
  s:=paramstr(0);i:=l;ProgName:='';ProgPath:='';
  while (not (s[i] in ['\',':'])) and (i>0) do dec(i);
  ProgName:=copy(s,i+1,l-i);s[0]:=char(i);ProgPath:=s;
  i:=length(ProgName);while (ProgName[i]<>'.') and (i>1) do dec(i);
  SProgName:=copy(ProgName,1,i-1);
  CfgFile:=ProgPath+SProgName+'.INI';
end.
