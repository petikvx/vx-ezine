{
   Codegenerator (c) 1999 by RedArc
Генератор команд с 16-битными регистрами
}

UNIT CG16;

INTERFACE

const
     rAX = 0;
     rCX = 1;
     rDX = 2;
     rBX = 3;
     rSP = 4;
     rBP = 5;
     rSI = 6;
     rDI = 7;

{Декодирование слова в два байта}
procedure Word2Bytes (var B1, B2 : Byte; W : Word);

{Кодирование двух байт в одно слово}
function Bytes2Word (B1, B2 : Byte) : Word;

{RND_8}
function Rnd8 (Range : Byte) : Byte;

{RND_16}
function Rnd16 : Word;

{Выбор 16-байтового регистра}
function CaseReg16 (R16 : Byte) : Byte;

{Push Reg16}
function PushReg16 (Reg16 : Byte) : Byte;

{Pop Reg16}
function PopReg16 (Reg16 : Byte) : Byte;

{Add Reg16,Value16}
procedure Add_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);

{Sub Reg16,Value16}
procedure Sub_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);

{Add Reg16,Value8}
procedure Add_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);

{Sub Reg16,Value8}
procedure Sub_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);

{Выбор кода R2 относительно заданного R1}
function CalculCodeR2ofR1 (R1, R2 : Byte) : Byte;

{Add Reg16_1,Reg16_2}
function Add_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;

{Sub Reg16_1,Reg16_2}
function Sub_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;

{Xor Reg16_1,Reg16_2}
function Xor_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;

{Xor Reg16,Value8}
procedure Xor_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);

{Xor Reg16,Value16}
procedure Xor_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);

{Mov Reg16_1,Reg16_2}
function Mov_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;

{Mov Reg16,Value16}
procedure Mov_Reg16_Value16 (var CoH : Byte; var CoL : Word; Reg16 : Byte; Value16 : Word);

{Xchg Reg16_1,Reg16_2}
function Xchg_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;

{Inc Reg16}
function Inc_Reg16 (Reg16 : Byte) : Byte;

{Dec Reg16}
function Dec_Reg16 (Reg16 : Byte) : Byte;

{Or Reg16,Value8}
procedure Or_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);

{Or Reg16,Value16}
procedure Or_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);

{Or Reg16_1,Reg16_2}
function Or_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;

{Int IntNum}
function Inth (IntNum : Byte) : Word;

IMPLEMENTATION

procedure Word2Bytes (var B1, B2 : Byte; W : Word);
var
   RB1, RB2 : Byte;
begin
     asm
        mov ax,W
        mov RB1,ah
        mov RB2,al
     end;
     B1 := RB1;
     B2 := RB2;
end;

function Bytes2Word (B1, B2 : Byte) : Word;
var
   Result : Word;
begin
     asm
        mov ah,B1
        mov al,B2
        mov Result,ax
     end;
     Bytes2Word := Result;
end;

function Rnd8 (Range : Byte) : Byte;
var
   Result : Byte;
begin
     asm
       mov ah,Range
@1:
       mov al,ah
       in al,40h
       cmp al,ah
       jnc @1
       mov Result,al
     end;
     Rnd8 := Result;
end;

function Rnd16 : Word;
var
   RB1, RB2 : Byte;
begin
     RB1 := Rnd8 ($FF);
     RB2 := Rnd8 ($FF);
     Rnd16 := Bytes2Word (RB1, RB2);
end;

function CaseReg16 (R16 : Byte) : Byte;
var
   RB1 : Byte;
begin
     repeat
           RB1 := Rnd8 (7);
     until (RB1 <> R16) and (RB1 <> 4);
     CaseReg16 := RB1;
end;

function PushReg16 (Reg16 : Byte) : Byte;
begin
     PushReg16 := Reg16 + $50
end;

function PopReg16 (Reg16 : Byte) : Byte;
begin
    PopReg16 := Reg16 + $58
end;

procedure Add_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);
begin
     CoH := Bytes2Word (Reg16 + $C0, $81);
     CoL := Value16;
end;

procedure Sub_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);
begin
     CoH := Bytes2Word (Reg16 + $E8, $81);
     CoL := Value16;
end;

procedure Add_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);
begin
     CoH := $83;
     CoL := Bytes2Word (Value8, Reg16 + $C0);
end;

procedure Sub_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);
begin
     CoH := $83;
     CoL := Bytes2Word (Value8, Reg16 + $E8);
end;

function CalculCodeR2ofR1 (R1, R2 : Byte) : Byte;
var
   B : Byte;
begin
     asm
        push ax
        push cx
        push dx
        mov bl,R1
        mov bh,R2
        mov al,bl
        mov cx,8
        mul cx
        add al,bh
        xchg bx,ax
        add bl,0c0h
        pop dx
        pop cx
        pop ax
        mov B,bl
     end;
     CalculCodeR2ofR1 := B;
end;

function Add_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;
begin
     Add_Reg1_Reg2_16 := Bytes2Word (CalculCodeR2ofR1 (Reg16_1, Reg16_2), $3);
end;

function Sub_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;
begin
     Sub_Reg1_Reg2_16 := Bytes2Word (CalculCodeR2ofR1 (Reg16_1, Reg16_2), $2B);
end;

function Xor_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;
begin
     Xor_Reg1_Reg2_16 := Bytes2Word (CalculCodeR2ofR1 (Reg16_1, Reg16_2), $33);
end;

procedure Xor_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);
begin
     CoH := $83;
     CoL := Bytes2Word (Value8, Reg16 + $F0);
end;

procedure Xor_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);
begin
     CoL := Value16;
     CoH := Bytes2Word (Reg16 + $F0, $81);
end;

function Mov_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;
begin
     Mov_Reg1_Reg2_16 := Bytes2Word (CalculCodeR2ofR1(Reg16_1, Reg16_2), $8B);
end;

procedure Mov_Reg16_Value16 (var CoH : Byte; var CoL : Word; Reg16 : Byte; Value16 : Word);
begin
     CoL := Value16;
     CoH := Reg16 + $B8;
end;

function Xchg_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;
begin
     Xchg_Reg1_Reg2_16 := Bytes2Word (CalculCodeR2ofR1(Reg16_1, Reg16_2), $87);
end;

function Inc_Reg16 (Reg16 : Byte) : Byte;
begin
     Inc_Reg16 := Reg16 + $40;
end;

function Dec_Reg16 (Reg16 : Byte) : Byte;
begin
     Dec_Reg16 := Reg16 + $48;
end;

procedure Or_Reg16_Value8 (var CoH : Byte; var CoL : Word; Reg16, Value8 : Byte);
begin
     CoH := $83;
     CoL := Bytes2Word (Value8, Reg16 + $C8);
end;

procedure Or_Reg16_Value16 (var CoH, CoL : Word; Reg16 : Byte; Value16 : Word);
begin
     CoH := Bytes2Word (Reg16 + $C8, $81);
     CoL := Value16;
end;

function Or_Reg1_Reg2_16 (Reg16_1, Reg16_2 : Byte) : Word;
begin
     Or_Reg1_Reg2_16 := Bytes2Word (CalculCodeR2ofR1(Reg16_1, Reg16_2), $0B);
end;

function Inth (IntNum : Byte) : Word;
begin
     Inth := Bytes2Word (IntNum, $CD);
end;

END.
