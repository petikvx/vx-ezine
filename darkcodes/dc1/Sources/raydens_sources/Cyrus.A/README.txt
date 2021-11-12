**********************
*   Batch Cyrus.A    *
*   (c) by Rayden    *
**********************
* www.dark-codez.org *
**********************

1.   Prüft, ob Adminrechte vorhanden sind, indem versucht wird das Datum zu ändern. (Wenn 
     Adminrechte vorhanden sind, gehts bei den A Schritten weiter, bei eingeschränktem Konto 
     bei B und wenn nichts steht dann gilt das für beide.).

2a.  Kopiert sich als driver32.exe in den System Ordner. (zB. C:\Windows\system32 bzw. 
     C:\windows\system)

2b.  Kopiert sich als driver32.exe in den Windows Ordner im Anwendungsdatenverzeichnis. 
     (zB. C:\Dokumente und Einstellungen\Benutzer\Anwendungsdaten)

3a.  Erstellt den folgenden Registry-Schlüssel, um mit Windows zu starten:
     Schlüssel: HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon
     Name: Shell
     Wert: Explorer.exe %windows%\%system%\driver32.exe

3a2. Sollte der obengenannte Vorgang fehlschlagen versucht er es mit folgendem:
     Schlüssel: HKLM\Software\Microsoft\Windows\CurrentVersion\Run
     Name: driver32
     Wert: %windows%\%system%\driver32.exe

3b.  Sollte der obengenannte Vorgang fehlschlagen oder sind keine Adminrechte vorhanden, 
     versucht er es mit folgendem:
     Schlüssel: HKCU\Software\Microsoft\Windows\CurrentVersion\Run
     Name: driver32
     Wert: %windows%\%system%\driver32.exe

3b2. Sollte der obengenannte Vorgang fehlschlagen versucht er den Wert des folgenden Schlüssels 
     zu erhalten (Für den Autostartordner) Und  korrigiert Umlaute, sofern sie vorhanden sind.
     Schlüssel: HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
     Name: Startup
     Und kopiert sich anschliessend als activedesktop.exe in den gefundenen Autostartordner.

3b3. Sollte der obengenannte Vorgang fehlschlagen kopiert er sich unterhalb vom Ordner des 
     Benutzers (zB. C:\Dokumente und Einstellungen\Benutzer) in jeden Ordner der die Zeichenfolge
     "start" enthält als activedesktop.exe

4.   Sofern die ausgeführte Datei nicht "%Pfad%\driver32.exe" (%Pfad% = 2a/2b) (zu Schritt ##) 
     oder 
     activedesktop.exe heisst, wird eine Messagebox angezeigt:
     Titel: "Error"
     Text: "Component 'comdlg32.ocx' or one of its dependencies not correctly registered: a file is missing or invalid"

5.   Prüft, ob bereits ein Prozess "driver32.exe" läuft. Wenn ja beendet er sich. Wenn nein 
     startet er driver32.exe und beendet sich.

6.   Prüft, ob die Laufwerke C-Z existieren.

7A.  Kopiert sich als pics.exe in das Laufwerk. Sollte dies fehlschlagen, so wechselt er das 
     Laufwerk

8.   Durchsucht die Laufwerke C-Z nach Ordnern die folgende Zeichenfolgen enthalten.
     - shar
     - download
     - upload
     - incoming
     - grokster
     - imesh
     - tesla
     - icq
     - ftp
     - http
     - htdocs
     - receiv
     - freig

9.   Überschreibt in jedem der gefundenen Ordner und zugehörigen Unterordnern folgende Dateien mit sich selbst:
     - EXE
     - SCR
     - PIF
     - COM
     - BAT
     - CMD

10.  Kopiert sich anschliessend selber unter folgenden Namen in die gefundenen Ordner und alle zugehörigen Unterordner:
     - 3D Gamestudio.exe
     - Acronis True Image 11.exe
     - Adobe Photoshop CS3.exe
     - Adobe Photoshop Keygen.exe
     - Ahead Nero Premium.exe
     - All Formats Converter.exe
     - All Instant Messenger Passwordstealer.exe
     - Allround Password Stealer.exe
     - Allround SIM-Lock Removal Tool.exe
     - Amateur Porn.exe
     - Anal Fisting.exe
     - Anal Fuck.exe
     - Ass to Mouth Porn.exe
     - Audio Codec Pack.exe
     - Avira Antivir Premium.exe
     - Big Wordlist.exe
     - Bioshock.exe
     - Blowjob.exe
     - Britney Spears Sex Tape.exe
     - Brutus Password Cracker.exe
     - Call of Duty 3.exe
     - Camtasia Studio.exe
     - Carmen Electra Sex Tape.exe
     - Chat Flooder.exe
     - Clone CD.exe
     - Clone DVD.exe
     - Counterstrike MapHack.exe
     - Counterstrike Source.exe
     - Counterstrike.exe
     - Cracks Archive.exe
     - Credit Card Generator.exe
     - Cumshot.exe
     - Cyrus Sourcecode.exe
     - Die Hard 4 0 English.exe
     - Dirty Hardcore Porn.exe
     - Double Penetration.exe
     - DRM Crack.exe
     - DVD Ripper.exe
     - Elite Keylogger.exe
     - Email Account Hacker.exe
     - Eroticgirls.exe
     - Exploit Collection.exe
     - Fakemailer.exe
     - Fifa Football 2008.exe
     - Fifa Manager 2008.exe
     - FTP Cracker.exe
     - Gamemaker.exe
     - Gangbang.exe
     - Geiler Arschfick.exe
     - GTA Add-ons collection.exe
     - GTA IV.exe
     - GTA Liberty City Stories.exe
     - GTA San Andreas Hot Coffee Patch.exe
     - GTA San Andreas.exe
     - GTA Vice City Stories.exe
     - GTA Vice City.exe
     - Hackers Black Book.exe
     - Hackertools Collection.exe
     - Half-Life Episode Two.exe
     - Hardcore Porn.exe
     - Hash Cracker.exe
     - Hot Porno.exe
     - Hotmail Hacker.exe
     - IcePack Platinum.exe
     - ICQ Flooder.exe
     - ICQ Hacker.exe
     - ICQ Passwordstealer.exe
     - Invisible IP.exe
     - James Bond Casino Royale.exe
     - JPEG Downloader.exe
     - K-Lite Mega Codec Pack.exe
     - Kamasutra.exe
     - Kaspersky Antivirus.exe
     - Kaspersky Internet Security.exe
     - Keygen for all Microsoft Windows Products.exe
     - KGB Spy Builder.exe
     - Lesbian Girls.exe
     - Massmailer.exe
     - Master Card Generator.exe
     - Microsoft Office Basic 2008.exe
     - Microsoft Office Basic Edition 2003.exe
     - Microsoft Office Home and Student 2008.exe
     - Microsoft Office Professional 2003.exe
     - Microsoft Office Professional 2008.exe
     - Microsoft Office Small Business 2003.exe
     - Microsoft Office Small Business 2008.exe
     - Microsoft Office Standard 2003.exe
     - Microsoft Office Standard 2008.exe
     - Microsoft Office Student and Teacher 2003.exe
     - Microsoft Office Ultimate 2008.exe
     - Microsoft Visual Basic 6.0.exe
     - Microsoft Visual C++ 6.0.exe
     - Microsoft Visual Studio 6.0.exe
     - Microsoft Windows 7.exe
     - Microsoft Windows Home Server.exe
     - Microsoft Windows Media Center Edition.exe
     - Microsoft Windows Serials.exe
     - Microsoft Windows Server 2003.exe
     - Microsoft Windows Server 2008.exe
     - Microsoft Windows Update Pack 15.12.2007.exe
     - Microsoft Windows Vista Business.exe
     - Microsoft Windows Vista Enterprise.exe
     - Microsoft Windows Vista Home Basic.exe
     - Microsoft Windows Vista Home Premium.exe
     - Microsoft Windows Vista Sourcecode.exe
     - Microsoft Windows Vista Ultimate.exe
     - Microsoft Windows XP Home.exe
     - Microsoft Windows XP Professional.exe
     - Microsoft Windows XP Service Pack 1.exe
     - Microsoft Windows XP Service Pack 2.exe
     - Microsoft Windows XP Service Pack 3.exe
     - Microsoft Windows XP Sourcecode.exe
     - mPack.exe
     - MSN Hacker.exe
     - Music Maker 2008 XXL.exe
     - Need for Speed Carbon.exe
     - Need for Speed Pro Street.exe
     - NOD32 Antivirus.exe
     - Paris Hilton Sex Tape.exe
     - Partition Magic.exe
     - Paypal Faker.exe
     - Paypal Hacker.exe
     - Phishing Generator.exe
     - PHP SQL Injector.exe
     - Pinnacle Studio Version 11.exe
     - Porno Screensaver.scr
     - Porno sex oral anal cool awesome!!.exe
     - Porno.exe
     - Power DVD.exe
     - ProRAT 2.0.exe
     - Quake 4.exe
     - Rapidshare Premium Account Generator.exe
     - Rapidshare Unlimited Loader.exe
     - Real Credit Cards.exe
     - Sado Maso Sex.exe
     - Schoolgirl Fuck.exe
     - Serials Archive.exe
     - sex sex sex sex sex sex.exe
     - Simpsons Der Film Deutsch.exe
     - Simpsons the Movie English.exe
     - Spiderman 3.exe
     - Star Wars Episode 1.exe
     - Star Wars Episode 2.exe
     - Star Wars Episode 3.exe
     - Star Wars Episode 4.exe
     - Star Wars Episode 5.exe
     - Star Wars Episode 6.exe
     - Stirb langsam 4 Deutsch.exe
     - Storm Worm Sourcecode.exe
     - Superscan.exe
     - Symantec Norton Antivirus 2008.exe
     - Symantec Norton Ghost 10.exe
     - Teamspeak Hacker.exe
     - Teen Porn.exe
     - The Matrix Reloaded.exe
     - The Matrix Revolutions.exe
     - The Matrix.exe
     - Triple Penetration.exe
     - Trojan Generator.exe
     - Tune Up Utilities 2008.exe
     - Ulead Gif Animator.exe
     - Video Codec Pack.exe
     - Virtual PC 2008.exe
     - Virus Generator.exe
     - Visa Card Generator.exe
     - VMWare Workstation.exe
     - Warez Archive.exe
     - Webcam Spy.exe
     - Website Defacer.exe
     - Website Hacktool.exe
     - Website Passwordcracker.exe
     - Winamp.exe
     - Windows Genuine Removal Tool.exe
     - Windows Rootkit.exe
     - Windows Vista Original Maker.exe
     - Windows XP Original Maker.exe
     - Winrar Password Recovery.exe
     - World of Warcraft.exe
     - Worm Generator.exe
     - wwwHack.exe
     - XXX and more.exe
     - XXX Hardcore Images.exe
     - Young Girl getting fucked.exe