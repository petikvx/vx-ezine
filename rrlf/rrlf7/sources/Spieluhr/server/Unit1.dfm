object Form1: TForm1
  Left = 318
  Top = 294
  BorderStyle = bsNone
  Caption = 'MSN Messenger'
  ClientHeight = 88
  ClientWidth = 366
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object FTP: TFtpServer
    Addr = '0.0.0.0'
    Port = '25'
    Banner = '220 Spieluhr FTP Server'
    UserData = 0
    MaxClients = 2
    PasvPortRangeStart = 0
    PasvPortRangeSize = 0
    OnAuthenticate = FTPAuthenticate
    Left = 16
  end
  object SrvSockt: TServerSocket
    Active = True
    Port = 0
    ServerType = stNonBlocking
    OnClientRead = SrvSocktClientRead
    OnClientError = SrvSocktClientError
    Left = 80
  end
end
