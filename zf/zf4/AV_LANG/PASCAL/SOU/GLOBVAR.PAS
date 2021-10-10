UNIT GlobVar;

INTERFACE

Uses Dos, CRT;

const
    OkMode    : Boolean = False;
    CureMode  : Boolean = False;
    TextMode  : Boolean = False;
    FlagError : Boolean = False;
    NumOfRecord : Integer = 0;

type
    DrivesSetType = Set of 'A'..'Z';

    PList = ^TList;
    TList = record
      Name : String[12];
      Next : PList;
    end;

var
    Ch : Char;
    S  : String;
    HD : DrivesSetType;
    SR : SearchRec;
    HomeDir : String;
    Path : String;
    StartTime : DateTime;
    EndTime   : DateTime;
    STime     : LongInt;
    ETime     : LongInt;
    y         : Word;
    tProt     : Text;

procedure ChDrive (Drive : Byte);
procedure Testdrives (var Drives : DrivesSetType);

function BlockPresent(var memaddr,baddr;msize,bsize:word):boolean;
function BlockOffs (var memaddr,baddr;msize,bsize:word):Word;

IMPLEMENTATION

procedure ChDrive (Drive : Byte);
begin
     asm
        mov ah,0eh
        mov dl,Drive
        int 21h
     end;
end;

procedure Testdrives (var Drives : DrivesSetType);
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

function BlockPresent(var memaddr,baddr;msize,bsize:word):boolean;assembler;
asm
        mov     cx,msize
        mov     dx,bsize
        push    ds
        les     di,memaddr
        lds     si,baddr
@@find_block:
        mov     al,byte ptr [si]
        repne   scasb
        or      cx,cx
        jcxz    @@block_not_found
        jmp     @@chk_equ_block
@@block_not_found:
        xor     ax,ax
        jmp     @@end_find_block
@@chk_equ_block:
        push    di
        push    si
        push    cx
        dec     di
        mov     cx,dx
        repe    cmpsb
        mov     ax,cx
        pop     cx
        pop     si
        pop     di
        or      ax,ax
        jnz     @@find_block
        mov     ax,1
@@end_find_block:
        pop     ds
end;

function BlockOffs (var memaddr,baddr;msize,bsize:word):Word;assembler;
asm
        mov     cx,msize
        mov     dx,bsize
        push    ds
        les     di,memaddr
        lds     si,baddr
@@find_block:
        mov     al,byte ptr [si]
        repne   scasb
        or      cx,cx
        jcxz    @@block_not_found
        jmp     @@chk_equ_block
@@block_not_found:
        xor     ax,ax
        jmp     @@end_find_block
@@chk_equ_block:
        push    di
        push    si
        push    cx
        dec     di
        mov     cx,dx
        repe    cmpsb
        mov     ax,cx
        pop     cx
        pop     si
        pop     di
        or      ax,ax
        jnz     @@find_block
        mov     ax,di
@@end_find_block:
        pop     ds
end;

BEGIN
     WriteLn;
     WriteLn ('Example for ZF (c) 2000 by RedArc');
     WriteLn;
END.
