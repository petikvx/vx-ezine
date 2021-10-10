UNIT WINHARRY;

INTERFACE

USES DOS,CRT,WIN;

TYPE
	 WindowType = Record
		 Size : Word;            {Объем памяти для окна в байтах}
		 Frame : 0..2;           {Шифр типа рамки (0-если нет)  }
		 BufSave : Pointer;      {Адрес изображения под окном   }
		 BufWin : Pointer;       {Адрес изображения в окне      }
		 StateSave : WinState;   {Состояние до открытия окна    }
		 StateWin : WinState;    {Состояние при закрытии окна   }
	 END;

	 VideoWord=Record
		    Symbol : Char;
		    Attrib : Byte;
		   End;
	 VideoText=Array [1..50*80] of VideoWord;
	 VideoTextPtr=^VideoText;

VAR WW : Array [1..100] of WindowType;
	 {Процедура меняет цвет символов и фона в прямоугольной области}
PROCEDURE TenWin(x1,y1,x2,y2,att:Byte);
	 { Открывает окно и делает его текущим}
PROCEDURE OpenWin(x1,y1,x2,y2 : Byte; T : TitleStr; TAttr,FAttr,
	               	FrameSort : Byte; VAR W : WindowType);
	{Процедура делает окно активным (текущим)}
PROCEDURE ActivateWin(VAR W : WindowType);
	{Процедура делает окно неактивным и может временно его стереть}
	{ если параметр ERASE=True                                    }
PROCEDURE FreezeWin(VAR W : WindowType; Erase : Boolean);
	{Процедура закрывает (уничтожает) окно}
PROCEDURE CloseWin(VAR W:WindowType);
	{Процедура устанавливает тип курсора}
Procedure SetC(x,y:Byte);
	{Процедура делает курсор нормальным}
Procedure SetN;
	{Процедура делает курсор невидимым}
Procedure SetO;
	{Процедура делает крупный блок-курсор}
Procedure SetB;

FUNCTION GetScreenPtr  : Pointer;
FUNCTION CurrentMode   : Byte;
FUNCTION Font8x8YES    : Boolean;
FUNCTION GetScreenSize : Word;
FUNCTION GetColNum     : Byte;
FUNCTION GetRowNum     : Byte;
PROCEDURE SaveCurrentScreenOnDisk (FileName : String);
PROCEDURE LoadScreenFromDisk (FileName : String);

PROCEDURE WriteChar (Col, Row, CharToPrint : Byte;
          CharToFill : Char; VAR AddrOfTable_2);
PROCEDURE WriteLargeString (X,Y : Byte; C, T : Char; S : String);

FUNCTION GetCharAttr (X, Y : Byte) : Word;
PROCEDURE PutCharAttr (X, Y : Byte; W : Word);
FUNCTION GetChar (X, Y : Byte) : Word;
PROCEDURE FillArea (X1, Y1, X2, Y2 : Byte; Ch : Char; Attr : Byte);


IMPLEMENTATION

{Процедура меняет цвет символов и фона в прямоугольной области}
PROCEDURE TenWin(x1,y1,x2,y2,att:Byte);

Function GetScreenPtr:Pointer;
Begin
			if (Mem[0:$0410] and $30) = $30
			 then GetScreenPtr:=Ptr($B000,0)
			 else GetScreenPtr:=Ptr($B800,0)
End;

Procedure ChangeAttr(VT : VideoTextPtr; x1,y1,x2,y2,Attr : Byte);
Var
	 VW : VideoWord;
	 i,j,k,n : Word;
				 M : Byte absolute 0:$44A;
Begin
		 VW.Attrib:=Attr;
		 for j:=y1 to y2 do begin
			 k:=M*(j-1);
			 for i:=x1 to x2 do begin
				 n:=k+i;
				 VW.Symbol:=VT^[n].Symbol;
				 VT^[n]:=VW
			 end
		 end
End;

VAR
	 V : Pointer;
BEGIN
	 V:=GetScreenPtr;
{	 if Seg(V^)=$B000 then TextMode(Mono)
										else TextMode(CO80);}
										ChangeAttr(V,x1,y1,x2,y2,att);
END;

{ Открывает окно и делает его текущим}
PROCEDURE OpenWin(x1,y1,x2,y2 : Byte; T : TitleStr; TAttr,FAttr,
									FrameSort : Byte; VAR W : WindowType);
BEGIN
		 with W do begin
			 SaveWin(StateSave);
			 Window(x1,y1,x2,y2);
			 Frame:=FrameSort;
			 Size:=WinSize;
			 GetMem(BufSave,Size);
			 ReadWin(BufSave^);
				case FrameSort of
				 1: FrameWin(T,SingleFrame,TAttr,FAttr);
				 2: FrameWin(T,DoubleFrame,TAttr,FAttr);
				end;
				ClrScr;
				SaveWin(StateWin);
				if Frame<>0 then UnFrameWin;
				GetMem(BufWin,Size);
				ReadWin(BufWin^);
				RestoreWin(StateWin)
		 end;
END;

{Процедура делает окно активным (текущим)}
PROCEDURE ActivateWin(VAR W : WindowType);
BEGIN
		 with W do begin
			 RestoreWin(StateWin);
			 if Frame<>0 then UnFrameWin;
			 WriteWin(BufWin^);
			 RestoreWin(StateWin)
		 end
END;

{Процедура делает окно неактивным и может временно его стереть}
{ если параметр ERASE=True                                    }
PROCEDURE FreezeWin(VAR W : WindowType; Erase : Boolean);
BEGIN
		 with W do begin
			 saveWin(StateWin);
			 if Frame<>0 then UnFrameWin;
			 ReadWin(BufWin^);
			 GotoXY(1,1);
			 if Erase then
				 WriteWin(BufSave^);
				 RestoreWin(Statesave)
		 end
END;

{Процедура закрывает (уничтожает) окно}
PROCEDURE CloseWin(VAR W:WindowType);
BEGIN
		 with W do begin
			 RestoreWin(StateWin);
			 if Frame<>0 then UnFrameWin;
			 GotoXY(1,1);
			 WriteWin(BufSave^);
			 RestoreWin(Statesave);
			 FreeMem(BufSave,Size);
			 FreeMem(BufWin,Size)
		 end
END;

{Процедура устанавливает тип курсора}
Procedure SetC(x,y:Byte);
Var R : Registers;
BEGIN
with R do begin
 AH:=$01;
 CH:=x;
 CL:=y;
end;
Intr($10,R)
End;

{Процедура делает курсор нормальным}
Procedure SetN;
Var se : Word;
begin
se:=$0607;
 SetC(Hi(se),Lo(se))
END;

{Процедура делает курсор невидимым}
Procedure SetO;
Begin
SetC(32,0)
End;

{Процедура делает крупный блок-курсор}
Procedure SetB;
Var x : Byte;
Begin
x:=13;
SetC(0,x)
END;

FUNCTION GetScreenPtr  : Pointer;
BEGIN
     if (Mem[0:$0410] and $30) = $30 then GetScreenPtr := Ptr($B000,0)
     else GetScreenPtr := Ptr($B800,0)
END;

FUNCTION CurrentMode   : Byte;
BEGIN
     CurrentMode := Lo (LastMode);
END;

FUNCTION Font8x8YES    : Boolean;
BEGIN
     Font8x8YES := (LastMode and Font8x8) = Font8x8
END;

FUNCTION GetScreenSize : Word;
VAR
   R : Byte absolute $0000:$0484;
   C : Byte absolute $0000:$044A;
BEGIN
     if Hi (LastMode) = 1 then GetScreenSize := Succ (R) * C * 2
     else GetScreenSize := 25*C*2
END;

FUNCTION GetColNum     : Byte;
BEGIN
     GetColNum := Mem[0:$44A]
END;

FUNCTION GetRowNum     : Byte;
BEGIN
     GetRowNum := GetScreenSize div GetColNum div 2
END;

PROCEDURE SaveCurrentScreenOnDisk (FileName : String);
VAR
   F : File;
   R : Word;
BEGIN
     Assign (F, FileName);
     ReWrite (F, GetScreenSize);
     BlockWrite (F, GetScreenPtr^, 1, R);
     Close (F);
END;

PROCEDURE LoadScreenFromDisk (FileName : String);
VAR
   F : File;
   FS, R : Word;
BEGIN
     Assign (F, FileName);
     {$I-}
     ReSet (F, 40);
     {$I+}
     IF IOResult = 0 THEN BEGIN
        FS := FileSize (F);
        BlockRead (F, GetScreenPtr^, FS, R);
        Close (F);
        Erase (F);
     END;
END;

PROCEDURE WriteChar (Col, Row, CharToPrint : Byte;
          CharToFill : Char; VAR AddrOfTable_2);
TYPE
    CharDim = Array [1..8] of Byte;
    TableDim = Array [0..127] of CharDim;
VAR
   X, Y : Byte;
   Table_1 : TableDim absolute $F000 : $FA6E;
   Table_2 : TableDim absolute AddrOfTable_2;
   Pattern : CharDim;
BEGIN
     case CharToPrint of
          000..127 : Pattern := Table_1[CharToPrint];
          128..255 : Pattern := Table_2[CharToPrint-128]
     end;
     Inc (Col, 7);
     Dec (Row, 8);
     for X := 1 to 8 do
         for Y := 7 downto 0 do begin
             GotoXY (Col-Y, Row+X);
             if (Odd (Pattern[X] SHR Y)) then Write (CharToFill)
         end;
END;

PROCEDURE WriteLargeString (X,Y : Byte; C, T : Char; S : String);
VAR
   i : Byte;
   Del : ShortInt;
   P : Pointer;
BEGIN
     Inc (Y);
     GetIntVec ($1F, P);
     if Y < 9 then y := 9;
     if y > Hi(WindMax) then y := Hi(WindMax)+1;
     i := Lo(WindMax)-Lo(WindMin)+1;
     repeat
           Del := i-(8*Length (S) +X-1);
           if Del < 0 then Delete (S, Length (S), 1);
     until Del >=0;
     for i := 1 to Length (S) do
         begin
              WriteChar (X+(i*8-7), y, ord(S[i]), T, P^);
              WriteChar (x+(i*8-8), y-1, ord (S[i]),c,P^);
         end
END;

FUNCTION GetCharAttr (X, Y : Byte) : Word; assembler;
asm
     mov ah,02
     mov dh,y
     mov dl,x
     int 10h
     mov ah, 08h
     mov bh,00
     int 10h
END;

PROCEDURE PutCharAttr (X, Y : Byte; W : Word); assembler;
asm
     mov ah,02
     mov dh,y
     mov dl,x
     int 10h
     mov ah,09h
     mov bx, W
     mov al,bl
     xchg bh,bl
     xor bh,bh
     xor cx,cx
     mov cl,1
     int 10h
END;

FUNCTION GetChar (X, Y : Byte) : Word; assembler;
asm
     mov ah,02
     mov dh,y
     mov dl,x
     int 10h
     mov ah, 08h
     mov bh,00
     int 10h
     xor ah,ah
END;

PROCEDURE FillArea (X1, Y1, X2, Y2 : Byte; Ch : Char; Attr : Byte);
VAR
   i, j, k : Word;
   BuffWord : VideoWord;
   M : Byte absolute 0:$44A;
   VT : VideoTextPtr;
BEGIN
     VT := GetScreenPtr;
     with BuffWord do begin
          Symbol := Ch;
          Attrib := Attr
     end;
     for j := Y1 to Y2 do begin
         k := M * (j-1);
         for i := X1 to X2 do
             VT^ [k+i] := BuffWord;
     end;
END;

END.