Attribute VB_Name = "Module1"
'api para copiar tantos bytes de una var a otra var
Private Declare Sub MemCopy Lib "kernel32" Alias "RtlMoveMemory" (Dest As Any, ByVal Src As Long, ByVal cb&)

'Apis y constantes del winsock
'Parte del codigo de este modulo esta explicado en el code del
'articulo sobre smtp  (smtp.zip)  solo explico las partes
'nuevas pa no repetir, a lo de mas solo una explicacion ligera
Public Declare Function setsockopt Lib "wsock32.dll" (ByVal s As Long, ByVal level As Long, ByVal optname As Long, optval As Any, ByVal optlen As Long) As Long
Private Declare Function WSAStartup Lib "wsock32.dll" (ByVal wVR As Long, lpWSAD As WSADATAType) As Long
Private Declare Function WSACleanup Lib "wsock32.dll" () As Long
Private Declare Function WSAIsBlocking Lib "wsock32.dll" () As Long
Private Declare Function WSACancelBlockingCall Lib "wsock32.dll" () As Long
Public Declare Function closesocket Lib "wsock32.dll" (ByVal s As Long) As Long
Public Declare Function recv Lib "wsock32.dll" (ByVal s As Long, buf As Any, ByVal buflen As Long, ByVal flags As Long) As Long
Private Declare Function gethostbyname Lib "wsock32.dll" (ByVal hostname$) As Long
Private Declare Function connect Lib "wsock32.dll" (ByVal s As Long, addr As sockaddr, ByVal namelen As Long) As Long
Private Declare Function htons Lib "wsock32.dll" (ByVal hostshort As Long) As Integer
Private Declare Function inet_addr Lib "wsock32.dll" (ByVal cp As String) As Long
Private Declare Function send Lib "wsock32.dll" (ByVal s As Long, buf As Any, ByVal buflen As Long, ByVal flags As Long) As Long
Private Declare Function socket Lib "wsock32.dll" (ByVal af As Long, ByVal s_type As Long, ByVal protocol As Long) As Long
Private Const WSADescription_Len = 256
Private Const WSASYS_Status_Len = 128
Private Const hostent_size = 16
Private Const IPPROTO_TCP = 6
Private Const INADDR_NONE = &HFFFF
Private Const sockaddr_size = 16
Private Const INVALID_SOCKET = -1
Private Const SOCKET_ERROR = -1
Private Const SOCK_STREAM = 1

'constante que indica que se accederan a opciones del socket
'con setsockopt o getsockopt
Public Const SOL_SOCKET = &HFFFF&

'constante que indica que se activara un timeout (tiempo de
'espera maximo) en el socket para la funcion recv
Public Const SO_RCVTIMEO = &H1006

Private Type HostEnt
 h_name As Long
 h_aliases As Long
 h_addrtype As Integer
 h_length As Integer
 h_addr_list As Long
End Type

Private Type sockaddr
 sin_family As Integer
 sin_port As Integer
 sin_addr As Long
 sin_zero As String * 8
End Type

Private Type WSADATAType
 wversion As Integer
 wHighVersion As Integer
 szDescription(0 To WSADescription_Len) As Byte
 szSystemStatus(0 To WSASYS_Status_Len) As Byte
 iMaxSockets As Integer
 iMaxUdpDg As Integer
 lpszVendorInfo As Long
End Type

'declaramos la var que contendra el handle del socket como
'public
Public sk As Long

'inicializa el winsock, si no hay error devuelve true, sino
'false
Public Function StartWinsock() As Boolean
On Error Resume Next
Dim StartupData As WSADATAType
StartWinsock = IIf(WSAStartup(&H101, StartupData) = 0, True, False)
End Function

'termina nuestra secion con el winsock
Public Sub EndWinsock()
On Error Resume Next
Dim ret As Long
If WSAIsBlocking() Then ret = WSACancelBlockingCall()
ret = WSACleanup()
End Sub

'nos devuelve la ip de un host en "Numero de red"
'(tambien llamado "orden de red", "byte de red")
'a partir de una url o una ip
Private Function GetHostByNameAlias(ByVal hostname) As Long
On Error Resume Next
Dim phe As Long, heDestHost As HostEnt, addrList As Long, retIP As Long
retIP = inet_addr(hostname)
If retIP = INADDR_NONE Then
 phe = gethostbyname(hostname)
   If phe <> 0 Then
    MemCopy heDestHost, ByVal phe, hostent_size
    MemCopy addrList, ByVal heDestHost.h_addr_list, 4
    MemCopy retIP, ByVal addrList, heDestHost.h_length
    Else
    retIP = INADDR_NONE
  End If
End If
GetHostByNameAlias = retIP
End Function

'para enviar datos por el socket, devuelve el numero de bytes
'enviados
Public Function SendData(ByVal s As Long, vMessage As String) As Long
On Error Resume Next
    SendData = send(s, ByVal vMessage, Len(vMessage), 0)
End Function

'conecta el socket al host remoto, en caso de exito devuelve el
'Handle del socket, sino devuelve INVALID_SOCKET (-1)
Public Function ConnectSock(ByVal Host As String) As Long
On Error Resume Next

Dim s As Long, SelectOps As Long, sockin As sockaddr, RcvTimeOut As Long

sockin.sin_family = 2
sockin.sin_port = htons(80)

If sockin.sin_port = INVALID_SOCKET Then: ConnectSock = INVALID_SOCKET: Exit Function

sockin.sin_addr = GetHostByNameAlias(Host)

If sockin.sin_addr = INADDR_NONE Then ConnectSock = INVALID_SOCKET: Exit Function

s = socket(2, SOCK_STREAM, IPPROTO_TCP)

'Esta var long sera nuestro timeout, la igualamos a 30 seg.
'que son 30000 en milisegundos
RcvTimeOut = 30000

'llamamos a setsockopt pasandole el handle del socket
'SOL_SOCKET para indicar que se actuara sobre las opciones
'del socket, SO_RCVTIMEO para indicar que se usara un timeout
'RcvTimeOut es el tiempo especificado en milisegundos
'y 4 el tamaño del dato de RcvTimeOut, si tiene exito la
'funcion devuelve diferente de 0, pero aqui no evaluamos el
'resultado
Call setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, RcvTimeOut, 4)

If s < 0 Then ConnectSock = INVALID_SOCKET: Exit Function

If connect(s, sockin, sockaddr_size) = -1 Then
 If s > 0 Then Call closesocket(s)
 ConnectSock = INVALID_SOCKET: Exit Function
End If

ConnectSock = s
End Function
