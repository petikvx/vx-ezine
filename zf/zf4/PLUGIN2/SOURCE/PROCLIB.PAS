{
Библиотека процедур для внешних подпрограмм
}

{$F+}
{$I-}

UNIT ProcLib;

INTERFACE

USES DOS;

TYPE
    DrivesSetType = Set of 'A'..'Z';

procedure _AssignFile (var F : File; FileName : String);
procedure _OpenFileRead (var F : File);
procedure _OpenFileWrite (var F : File);
procedure _ReadFromFile (var F : File; var Buff; Size : Word);
procedure _WriteToFile (var F : File; var Buff; Size : Word);
procedure _GetMemProc (var P : Pointer; Size : Word);
procedure _FreeMemProc (var P : Pointer; Size : Word);
function _SignOffset (var MemAddr, BlockAddr;
                      MemSize, BlockSize : Word) : Word;
procedure _WriteString (S : String);
procedure _WriteLnString (S : String);
procedure _ReadString (var S : String);
procedure _ReadLnString (var S : String);
function _MaxByte (A, B : Byte) : Byte;
function _MaxInteger (A, B : Integer) : Integer;
function _MaxWord (A, B : Word) : Word;
function _MinByte (A, B : Byte) : Byte;
function _MinInteger (A, B : Integer) : Integer;
function _MinWord (A, B : Word) : Word;
function _XorByte (Param, Key : Byte) : Byte;
function _XorWord (Param, Key : Word) : Word;
function _AndByte (Param, Key : Byte) : Byte;
function _AndWord (Param, Key : Word) : Word;
function _NotByte (Param : Byte) : Byte;
function _NotWord (Param : Word) : Word;
function _OrByte  (Param, Key : Byte) : Byte;
function _OrWord  (Param, Key : Word) : Word;
procedure _RenameFile (var F : File; NewName : String);
procedure _EraseFile (var F : File);
procedure _TruncateFile (var F : File);
procedure _CopyFile (OldName, NewName : String);
function _FileExists (FileName : String) : Boolean;
function _FileSize (var F : File) : LongInt;
function _FilePos (var F : File) : LongInt;
procedure _FileSeek (var F : File; NewPos : LongInt);
procedure _Randomize;
function _Rnd (Range : Word) : Word;
procedure _RmDir (S : String);
procedure _ChDir (S : String);
procedure _MkDir (S : String);
function _GetDir (Drive : Byte) : String;
procedure _ChDrive (Drive : Byte);
procedure _TestDrives (var Drives : DrivesSetType);
function _Seg (P : Pointer) : Word;
function _Ofs (P : Pointer) : Word;
function _Hi (W : Word) : Byte;
function _Lo (W : Word) : Byte;
procedure _CloseFile (var F : File);
function _IOResult : Integer;
function _MemAvail : LongInt;
function _MaxAvail : LongInt;

IMPLEMENTATION

procedure _AssignFile (var F : File; FileName : String);
begin
     Assign (F, FileName);
end;

procedure _OpenFileRead (var F : File);
begin
     ReSet (F, 1);
end;

procedure _OpenFileWrite (var F : File);
begin
     ReWrite (F, 1);
end;

procedure _ReadFromFile (var F : File; var Buff; Size : Word);
var
   CR : Word;
begin
     BlockRead (F, Buff, Size, CR);
end;

procedure _WriteToFile (var F : File; var Buff; Size : Word);
var
   CW : Word;
begin
     BlockWrite (F, Buff, Size, CW);
end;

procedure _GetMemProc (var P : Pointer; Size : Word);
begin
     GetMem (P, Size);
end;

procedure _FreeMemProc (var P : Pointer; Size : Word);
begin
     FreeMem (P, Size);
end;

function BlockOffs (var memaddr, baddr; msize, bsize : word) : Word; assembler;
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

function _SignOffset (var MemAddr, BlockAddr;
                      MemSize, BlockSize : Word) : Word;
begin
     _SignOffset := BlockOffs (MemAddr, BlockAddr, MemSize, BlockSize)
end;

procedure _WriteString (S : String);
begin
     Write (S);
end;

procedure _WriteLnString (S : String);
begin
     WriteLn (S);
end;

procedure _ReadString (var S : String);
begin
     Read (S);
end;

procedure _ReadLnString (var S : String);
begin
     ReadLn (S);
end;

function _MaxByte (A, B : Byte) : Byte;
begin
     if A > B then _MaxByte := A else _MaxByte := B
end;

function _MaxInteger (A, B : Integer) : Integer;
begin
     if A > B then _MaxInteger := A else _MaxInteger := B
end;

function _MaxWord (A, B : Word) : Word;
begin
     if A > B then _MaxWord := A else _MaxWord := B
end;

function _MinByte (A, B : Byte) : Byte;
begin
     if A > B then _MinByte := B else _MinByte := A
end;

function _MinInteger (A, B : Integer) : Integer;
begin
     if A > B then _MinInteger := B else _MinInteger := A
end;

function _MinWord (A, B : Word) : Word;
begin
     if A > B then _MinWord := B else _MinWord := A
end;

function _XorByte (Param, Key : Byte) : Byte;
begin
     _XorByte := Param xor Key
end;

function _XorWord (Param, Key : Word) : Word;
begin
     _XorWord := Param xor Key
end;

function _AndByte (Param, Key : Byte) : Byte;
begin
     _AndByte := Param and Key
end;

function _AndWord (Param, Key : Word) : Word;
begin
     _AndWord := Param and Key
end;

function _NotByte (Param : Byte) : Byte;
begin
     _NotByte := not Param
end;

function _NotWord (Param : Word) : Word;
begin
     _NotWord := not Param
end;

function _OrByte  (Param, Key : Byte) : Byte;
begin
     _OrByte := Param or Key
end;

function _OrWord  (Param, Key : Word) : Word;
begin
     _OrWord := Param or Key
end;

procedure _RenameFile (var F : File; NewName : String);
begin
     Rename (F, NewName)
end;

procedure _EraseFile (var F : File);
begin
     Erase (F)
end;

procedure _TruncateFile (var F : File);
begin
     Truncate (F)
end;

procedure _CopyFile (OldName, NewName : String);
var
   P : Pointer;
   CR, CW : Word;
   fSou, fTar : File;
begin
     GetMem (P, 65535);
     Assign (fSou, OldName);
     ReSet (fSou, 1);
     Assign (fTar, NewName);
     ReWrite (fTar, 1);
     repeat
           BlockRead (fSou, P^, 65535, CR);
           BlockWrite (fTar, P^, CR, CW);
           if CR <> 65535 then Break;
     until False;
     Close (fTar);
     Close (fSou);
     FreeMem (P, 65535);
end;

function _FileExists (FileName : String) : Boolean;
var
   f : File;
begin
     Assign (f, FileName);
     ReSet (f, 1);
     if IOResult = 0 then begin
        Close (f);
        _FileExists := True;
     end else
        _FileExists := False;
end;

function _FileSize (var F : File) : LongInt;
begin
     _FileSize := FileSize (F)
end;

function _FilePos (var F : File) : LongInt;
begin
     _FilePos := FilePos (F)
end;

procedure _FileSeek (var F : File; NewPos : LongInt);
begin
     Seek (F, NewPos);
end;

procedure _Randomize;
begin
     Randomize
end;

function _Rnd (Range : Word) : Word;
begin
     _Rnd := Random (Range)
end;

procedure _RmDir (S : String);
begin
     RmDir (S)
end;

procedure _ChDir (S : String);
begin
     ChDir (S)
end;

procedure _MkDir (S : String);
begin
     MkDir (S);
end;

function _GetDir (Drive : Byte) : String;
var
   S : String;
begin
     GetDir (Drive, S);
     _GetDir := S;
end;

procedure _ChDrive (Drive : Byte);
begin
     asm
	MOV AH, 0Eh
	MOV DL, Drive;
	INT 21h
     end;
end;

procedure _TestDrives (var Drives : DrivesSetType);
var
   R  : Registers;
   i  : Byte;
   Ch : Char;
begin
     Ch := Pred ('A');
     Drives := [];
     for i := 1 to 26 do begin
         Ch := Succ (Ch);
         R.AH := $44;
         R.AL := $08;
         R.BL := i;
         MsDos (R);
         if R.AX <= 1 then Drives := Drives + [Ch]
     end;
end;

function _Seg (P : Pointer) : Word;
begin
     _Seg := Seg (P)
end;

function _Ofs (P : Pointer) : Word;
begin
     _Ofs := Ofs (P)
end;

function _Hi (W : Word) : Byte;
begin
     _Hi := Hi (W)
end;

function _Lo (W : Word) : Byte;
begin
     _Lo := Lo (W)
end;

procedure _CloseFile (var F : File);
begin
     Close (f)
end;

function _IOResult : Integer;
begin
     _IOResult := IOResult
end;

function _MemAvail : LongInt;
begin
     _MemAvail := MemAvail;
end;

function _MaxAvail : LongInt;
begin
     _MaxAvail := MaxAvail;
end;

{$F-}
END.
