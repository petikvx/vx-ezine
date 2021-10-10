{
                          1997 (c) by RedArc // TAVC
}
UNIT Global;

INTERFACE

CONST
     Ident1           = 'VIRLIST (c) 1997 by RedArc // TAVC';
     Ident2           = '     Source: MooN BuG issue 4';
     CFGFileName      = 'VIRLIST.CFG';
     DefaultPFI       = 'C:\TEST\';
     DefaultPFR       = 'C:\TEMP\';
     DefaultPFV       = 'C:\TEMP\VIRLIST.TXT';
     PathFileVirlist1 = 'NEWSLIST.$$$';
     Autors           = 'Дикшев Игорь Владиславович';
TYPE
    FileRecordInfo = RECORD
             FileName  : String [12];
             VirusName : String [80];
             DirCount  : Byte;
             DirName   : Array [1..20] OF String [12];
             NamePr    : String;
             Flag_I    : Boolean;
             Flag_S    : Boolean;
             Flag_M    : Boolean;
             Flag_O    : Boolean;
             Flag_E    : Boolean;
    END;

    AntivirusRec = RECORD
              IF_Flags : Array [1..3] OF String [80];
              SF_Flags : Array [1..3] OF String [80];
              MF_Flags : Array [1..3] OF String [80];
              OF_Flags : Array [1..3] OF String [80];
              EF_Flags : Array [1..6] OF String [80];
              CodeAnal : Array [1..10] OF String [3];
    END;

VAR
   PathFileInfected : String [100];
   PathFileReport   : String [100];
   PathFileVirlist  : String [100];
   PathFileHeaderList : String [100];
   PathFileVirusDestion : String [100];
   Clon             : String [100];
   ModifyInsertFlag : String [100];
   DivNameFlag      : String [100];
   AntiVirusInform  : String [100];
   PrioryPath       : String [10];
   Comments         : String [5];
   InfPath, ModPath, UnkPath, ClePath, ErrPath : String [8];

   CountAVInform    : Word;
   AVName           : STRING [8];
   AVRName          : String [12];
   AVKatalog        : String [8];
   AVConfig         : String [12];
   CFG              : Text;
   F                : File;
   T                : Text;
   CountAVInfo      : Word;
   FileInfo         : FileRecordInfo;
   AntiInfo         : AntivirusRec;

   I_Flag           : String [80];
   S_Flag           : String [80];
   M_Flag           : String [80];
   O_Flag           : String [80];
   AllRecord        : Word;

   GlobalFlag       : Byte;
   X_Cur, Y_Cur     : Byte;

procedure DelLeftSpace (VAR S : String);
function UpStr (S : String) : String;

IMPLEMENTATION

procedure DelLeftSpace (VAR S : String);
begin
     while (S [1] = ' ') or (S [1] = ',') or (S [1] = #9) do delete (S, 1, 1)
end;

function UpStr (S : String) : String;
var
   i : byte;
begin
     for i := 1 to length (S) do S [i] := upcase (S [i]);
     UpStr := S;
end;

BEGIN
     AllRecord := 0;
     WriteLn (Ident1);
     PathFileVirusDestion := '';
     ModifyInsertFlag := 'NO';
     PrioryPath := 'NO';
END.
