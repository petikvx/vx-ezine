Attribute VB_Name = "Module1"
'Api que verifica la conexion a internet
Public Declare Function InternetGetConnectedState Lib "wininet.dll" (ByRef IpdwFlags As Long, ByVal dwReserved As Long) As Long

'copia tantos bytes o caracteres como se indique en cb,
'desde Src a Dest
Public Declare Sub MemCopy Lib "kernel32" Alias "RtlMoveMemory" _
(Dest As Any, ByVal Src As Long, ByVal cb&)

'obtiene informacion sobre el ultimo error de las api
'del winsock
Public Declare Function WSAGetLastError Lib "wsock32.dll" () As Long

'la usamos para poner al socket en modo de no blokeo
Public Declare Function WSAAsyncSelect Lib "wsock32.dll" (ByVal s As Long, ByVal hWnd As Long, ByVal wMsg As Long, ByVal lEvent As Long) As Long

'funcion para inicializar la dll winsock, debe ser usada
'antes de usar las demas funciones
Public Declare Function WSAStartup Lib "wsock32.dll" (ByVal wVR As Long, lpWSAD As WSADATAType) As Long

'api que termina la secion de la dll winsock
Public Declare Function WSACleanup Lib "wsock32.dll" () As Long

'determina si winsock esta bloqueado por una funcion pendiente
'o que aun no termina
Public Declare Function WSAIsBlocking Lib "wsock32.dll" () As Long

'Anula la funcion pendiente, y desbloquea winsock
Public Declare Function WSACancelBlockingCall Lib "wsock32.dll" () As Long

'funcion que cierra el socket
Public Declare Function closesocket Lib "wsock32.dll" (ByVal s As Long) As Long

'funcion que recibe los datos que se le envian al socket
Public Declare Function recv Lib "wsock32.dll" (ByVal s As Long, buf As Any, ByVal buflen As Long, ByVal flags As Long) As Long

'obtiene el nombre de dominio del host local osea de la Pc
Public Declare Function gethostname Lib "wsock32.dll" (ByVal hostname$, ByVal HostLen As Long) As Long

'la usamos para obtener la ip de un host, por ejemplo
'si pasamos smtp.server.com nos devuelve su ip en una
'estructura HostEnt
Public Declare Function gethostbyname Lib "wsock32.dll" (ByVal hostname$) As Long

'funcion para conectar el socket
Public Declare Function connect Lib "wsock32.dll" (ByVal s As Long, addr As sockaddr, ByVal namelen As Long) As Long

'Obtiene opciones asociadas con el socket
Public Declare Function getsockopt Lib "wsock32.dll" (ByVal s As Long, ByVal level As Long, ByVal optname As Long, optval As Any, optlen As Long) As Long

'Esta funcion se usa por ejemplo si queremos conectar el
'puerto 25, tenemos que especificar el numero de puerto
'en "valor de red"(big Endian) entonces llamamos a
'htons(25), que nos devuelve el numero en "valor de red"
Public Declare Function htons Lib "wsock32.dll" (ByVal hostshort As Long) As Integer

'convierte una direccion ip a "valor de red"
Public Declare Function inet_addr Lib "wsock32.dll" (ByVal cp As String) As Long

'funcion para enviar datos
Public Declare Function send Lib "wsock32.dll" (ByVal s As Long, buf As Any, ByVal buflen As Long, ByVal flags As Long) As Long

'Establece opciones para el socket
Public Declare Function setsockopt Lib "wsock32.dll" (ByVal s As Long, ByVal level As Long, ByVal optname As Long, optval As Any, ByVal optlen As Long) As Long

'funcion para crear un socket
Public Declare Function socket Lib "wsock32.dll" (ByVal af As Long, ByVal s_type As Long, ByVal protocol As Long) As Long


'Para entender mejor el funcionamiento de SetWindowLong
'y CallWindowProc puedes leer:
'http://www.hackemate.com.ar/mirrors/karpoff/manuales/asm_win32/tut20_es.html

Public Declare Function SetWindowLong Lib "user32" Alias "SetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long, ByVal dwNewLong As Long) As Long

'la usamos luego de usar SetWindowLong para enviar los mensages
'que no deseamos procesar al procedimiento de ventana original
Public Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByVal Msg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long

'usamos con SetWindowLong para hacer una subclasificacion de
'ventanas
Public Const GWL_WNDPROC = -4

'declaramos como long
Public lpPrevWndProc As Long

'Constantes para la declaracion de WSADATAType
Public Const WSADescription_Len = 256
Public Const WSASYS_Status_Len = 128

'Constante que indica el tipo de opciones que se van a
'implementar setsockopt o leer con getsockopt
'SOL_SOCKET indica que son opciones a nivel del socket
Public Const SOL_SOCKET = &HFFFF&

'Permite especificar qué hacer si quedan datos pendientes en
'el buffer de envío cuando se cierra la conexión
Public Const SO_LINGER = &H80&

'Tamaño de la structura HostEnt
Public Const hostent_size = 16

'indica el protocolo a utilizar, en este caso tcp
Public Const IPPROTO_TCP = 6

'si ha inet_addr() se le pasa un parametro erroneo
'devuelve INADDR_NONE indicando error
Public Const INADDR_NONE = &HFFFF

'tamaño de la estructura SOCKADDR_IN
Public Const sockaddr_size = 16

'si la funcion socket no tiene exito regresa este valor
Public Const INVALID_SOCKET = -1

'indica error, algunas funciones devuelven este valor
'para indicar error
Public Const SOCKET_ERROR = -1

'indica el tipo de socket, en este caso socket de stream
Public Const SOCK_STREAM = 1

'Estructura LingerType o Linger
Public Type LingerType
 l_onoff As Integer    'activar/desactivar demora
 l_linger As Integer   'segundos de demora
End Type

'Estructura HostEnt
Type HostEnt
 h_name As Long        'nombre del hostlocal o remoto
 h_aliases As Long     'Lista de Alias del host
 h_addrtype As Integer 'El tipo de dirección que está siendo
                       'regresada; para Sockets de Windows
                       'este tipo siempre es PF_INET
 h_length As Integer   'El tamaño, en bytes, de cada dirección
                       'para PF_INET, éste siempre es 4
 h_addr_list As Long   'Puntero a una lista de direcciones ip
                       'del host (osea la ip del host)
End Type

Public Type sockaddr
 sin_family As Integer  'colocamos AF_INET que significa
                        'comunicacion por red/internet
 sin_port As Integer    'puerto del host remoto al que se
                        'conectara el socket
 sin_addr As Long       'ip del host remoto
 sin_zero As String * 8 'no manejamos este dato, lo dejamos
End Type

'Constantes que indican el tipo de accion que se realiza
'sobre el socket
Public Const FD_WRITE = &H2&     'escribir en el socket
                                 'osea enviar datos
Public Const FD_CONNECT = &H10&  'conexcion del socket
Public Const FD_CLOSE = &H20&    'indica que se cerro la conexion
Public Const FD_READ = &H1&      'el socket esta recibiendo datos

'declaracion de la estructura WSADATAType
Public Type WSADATAType
 wversion As Integer
 wHighVersion As Integer
 szDescription(0 To WSADescription_Len) As Byte
 szSystemStatus(0 To WSASYS_Status_Len) As Byte
 iMaxSockets As Integer
 iMaxUdpDg As Integer
 lpszVendorInfo As Long
End Type

'declaramos algunas variables
Public mysock As Long, Progress As Integer, do_cancel As Boolean, MySocket As Integer, rtncode As Integer

'declaracion de los objetos FSO y wsl como globales
Global fso As Object, wsl As Object

'funcion que inicializa el winsock
Public Function StartWinsock() As Boolean
On Error Resume Next

'declaramos StartupData como una structura WSADATAType
Dim StartupData As WSADATAType

'llamamos a api WSAStartup(), si devuelve 0, no hubo
'error y devolvemos true, en otro caso false
'le pasamos &H101 que indica la version de
'winsock que queremos usar, en este caso la 1.1 que viene
'en los win9x, si se quiere usar la 2 enviar &H200 (Win NT)
'tambien le pasamos StartupData vacia, se llenara al llamar
'a la funcion
StartWinsock = IIf(WSAStartup(&H101, StartupData) = 0, True, False)
End Function

'funcion que termina la secion de winsock
Public Sub EndWinsock()
On Error Resume Next
Dim ret As Long

'usamos api WSAIsBlocking para saber si la dll winsock esta
'bloqueada, osea si hay alguna funcion pendiente, por ejemplo
'esperando recibir datos o terminar de enviar, etc.
'si esta bloqueada la desbloqueamos con WSACancelBlockingCall
'anulando la funcion pendiente
If WSAIsBlocking() Then ret = WSACancelBlockingCall()

'termina la secion de winsock
ret = WSACleanup()
End Sub

'funcion a la que redirigimos los msg de windows con
'SetWindowLog
Function WindowProc(ByVal hw As Long, ByVal uMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
On Error Resume Next

'declaramos vars
Dim x As Long, a As String, ReadBuffer(1000) As Byte, e_err

'si el mensage enviado por win es 1025, estamos esperando el
'1025, porque al conectar el socket le indicamos que enviara
'ese numero para indicar eventos relacionados con el socket
'podria ser otro numero que ubieramos indicado
Select Case uMsg

 Case 1025
 'si hay error igualamos do_cancel a True
 e_err = WSAGetAsyncError(lParam)
 If e_err <> 0 Then do_cancel = True
               
'iniciamos un case para ver ante que evento del socket estamos
   Select Case lParam
   
   'indica que el socket esta recibiendo informacion
   'y debemos leerla con api recv
    Case FD_READ
    
    'usamos recv para leer, por ser un socket de stream
    'a la funcion le pasamos el numero del socket
    'el buffer donde se almacenran los datos, en este caso
    'el array ReadBuffer, el tamaño del bufeer(el tamaño
    'del array), y luego podemos especificar banderas
    'o flags para definir el comportamiento de la funcion
    'en este caso solo pasamos 0, la funcion devuelve
    'el numero de datos leidos, si error devuelve socket_error
    '(-1), si devuelve 0 el socket remoto se cerro
    x = recv(mysock, ReadBuffer(0), 1000, 0)
    If x > 0 Then
    
    'obtenemos los 3 primeros caracteres de la respuesta del
    'server y los almacenamos en rtncode
    a = StrConv(ReadBuffer, vbUnicode)
    rtncode = Val(Mid(a, 1, 3))
    
    'si rtncode es igual a algunos de estos numeros, entonces
    'hubo error y igualamos do_cancel a True
     Select Case rtncode
     Case 550, 551, 552, 553, 554, 451, 452, 500
     do_cancel = True
     End Select
    End If
            
 'este evento indica que el socket conecto
 Case FD_CONNECT
 'en wParam esta el numero del socket, lo igualamos a la var
 'global mysock, para poder usarlo desde cualquier parte del
 'programa
 mysock = wParam
 'aumentamos progress en 1
 Progress = Progress + 1

'indica que se cerro la conexion
 Case FD_CLOSE
 'cerramos el socket
 Call closesocket(mysock)
 
 End Select
 End Select

'pasamos al procedimiento de ventana de nuestro form los msg
'que no nos interesa procesar
    WindowProc = CallWindowProc(lpPrevWndProc, hw, uMsg, wParam, lParam)
End Function

Public Function WSAGetAsyncError(ByVal lParam As Long) As Integer
On Error Resume Next: WSAGetAsyncError = (lParam And &HFFFF0000) \ &H10000
End Function

Public Function SetSockLinger(ByVal SockNum As Long, ByVal OnOff As Integer, ByVal LingerTime As Integer) As Long
On Error Resume Next

'declaramos linger como una structura LingerType
Dim Linger As LingerType
'igualamos a On o Off dependiendo del parametro de la funcion
'si es On habra una espera si hay datos pendientes de enviar
'al momento de cerrar la conexion
Linger.l_onoff = OnOff

'tiempo de espera(valor en segundos)
Linger.l_linger = LingerTime

'usamos setsockopt para especificar opciones del socket
'le pasamos el numero del socket, SOL_SOCKET que indica que
'se van a especificar opciones a nivel de socket, SO_LINGER que
'indica que se tome en cuenta los datos de la estructura
'LingerType, pasamos la estructura LingerType, luego pa
'samos el tamaño de la structura LingerType en bytes
'si exito devuelve 0
If setsockopt(SockNum, SOL_SOCKET, SO_LINGER, Linger, 4) <> 0 Then

'devolvemos socket error
SetSockLinger = SOCKET_ERROR
Else
        
'esta parte no es necesaria, pero getsockopt es casi igual
'mismos argumentos, solo que el tercer parametro indica
'que opciones queremos leer en este caso las opciones de
'linger y debemos pasar como cuarto argumento una estructura
'que contendra los valores leidos, en este caso una estructura
'linger, si exito devuelve 0
If getsockopt(SockNum, SOL_SOCKET, SO_LINGER, Linger, 4) <> 0 Then
End If

End If
End Function

'funcion que nos devuelve la ip de la url que pasemos
'como argumento, nos la devolvera en "valor de red"
Function GetHostByNameAlias(ByVal hostname) As Long
On Error Resume Next

'declaramos vars y una estructura HostEnt
Dim phe As Long, heDestHost As HostEnt, addrList As Long, retIP As Long

'inet_addr devuelve en "valor de red", cuando se le pasa
'una ip, pero si le pasamos una url devuelve INADDR_NONE
retIP = inet_addr(hostname)

'entonces obtener la ip de la url
If retIP = INADDR_NONE Then

'le pasamos la url a gethostbyname, que regresa una direccion
'a la estructura HostEnt
 phe = gethostbyname(hostname)
 
 'si hubo exito, accedemos a la estructura
  If phe <> 0 Then
   'para poder acceder a la structura, usamos MemCopy para
   '"copiarla" a la variable que hemos declarado como
   'HostEnt
    MemCopy heDestHost, ByVal phe, hostent_size
   'copiamos el miembro h_addr_list de la structura
   'que contiene la direccion ip a la var addrList
    MemCopy addrList, ByVal heDestHost.h_addr_list, 4
   'copiamos a de addrList a retIP, tantos bytes como indique
   'h_length (que indica el tamaño de la direccion)
    MemCopy retIP, ByVal addrList, heDestHost.h_length
    Else
    'sino hubo exito devolvemos INADDR_NONE
    retIP = INADDR_NONE
  End If
End If
    
'devolvemos la direccion ip, en "valor de red"
GetHostByNameAlias = retIP
End Function

'funcion para enviar datos por un socket
Public Function SendData(ByVal s As Long, vMessage As Variant) As Long
On Error Resume Next
'declaramos TheMsg() como un array tipo Byte
Dim TheMsg() As Byte
            'pasamos los datos que vamos a enviar al array
            TheMsg = StrConv(vMessage, vbFromUnicode)
            
'si el array no esta vacio, osea su mayor indice es mayor a -1
If UBound(TheMsg) > -1 Then
'enviamos los datos con la api send por ser un socket stream
'le pasamos el numero de socket, el buffer donde estan almacenados
'los datos, en este caso el array, cantidad de datos a enviar
'banderas que se puede colocar para definir el comportamiento
'de la funcion, en este caso solo 0
'si error devuelve socket_error, sino el numero de bytes
'enviados
    SendData = send(s, TheMsg(0), (UBound(TheMsg) - LBound(TheMsg) + 1), 0)
End If
End Function

'funcion que conecta el socket al socket remoto, recibe como
'argumentos la url o ip del host remoto y el handle de nuestro
'form1
Public Function ConnectSock(ByVal Host As String, ByVal HWndToMsg As Long) As Long
On Error Resume Next

'declaramos variables y una estructura sockaddr
Dim s As Long, SelectOps As Long, sockin As sockaddr

'igualamos a 2 o AF_INET que indica que conexion en una red o
'internet
sockin.sin_family = 2

'lo igualamos al numero de puerto remoto al que vamos a
'conectar en este caso el 25, usamos htons porque el
'numero debe ir en "valor de red"
sockin.sin_port = htons(25)

'si la funcion htons no tuvo exito, devolvemos invalid_socket
'y salimos
If sockin.sin_port = INVALID_SOCKET Then: ConnectSock = INVALID_SOCKET: Exit Function

''igualamos a la ip en "valor de red" del host remoto
sockin.sin_addr = GetHostByNameAlias(Host)

'si GetHostByNameAlias nos devuelve una direccion incvalida
'salimos
If sockin.sin_addr = INADDR_NONE Then ConnectSock = INVALID_SOCKET: Exit Function

'creamos el socket con la funcion api socket, que le pasamos
'2 o AF_INET(PF_INET es igual a AF_INET), luego que sera
' un socket de stream, y que el protocolo sera TCP
'si exito devuelve el numero o descriptor de socket
s = socket(2, SOCK_STREAM, IPPROTO_TCP)

'si fallo salimos
If s < 0 Then ConnectSock = INVALID_SOCKET: Exit Function

'establecemos la opcion linger en el socket, si error
If SetSockLinger(s, 1, 0) = SOCKET_ERROR Then
'cerramos el socket y salimos
    If s > 0 Then Call closesocket(s)
    ConnectSock = INVALID_SOCKET: Exit Function
End If

'seleccionamos los eventos del socket sobre los cuales queremos
'que winsock nos notifique, ya que sera en modo asincronico
SelectOps = FD_READ Or FD_CONNECT Or FD_CLOSE
 
'usamos WSAAsyncSelect indicando el numero de socket para poner
'el socket en modo asincronico, le decimos que envie los
'eventos seleccionados a nuestro form1, para eso le pasamos
'el hanlde en HWndToMsg, y como ya tenemos interceptado eso
'con SetWinodwLong, podremos procesar los eventos, le decimos
'que envie el mensage 1025(puede ser otro numero) al form1
'y como 4° argumento pasamos las opciones seleccionadas
Call WSAAsyncSelect(s, HWndToMsg, ByVal 1025, ByVal SelectOps)
    
'ahora conectamos el socket, pasamos el numero de socket
'la structura sockaddr, y el tamaño de la estructura
'como estamos en modo asincronico, regresara Socket_error (-1)
'pero no es error
If connect(s, sockin, sockaddr_size) <> -1 Then

'si no exito cerramos el socket y salimos
 If s > 0 Then Call closesocket(s)
 ConnectSock = INVALID_SOCKET: Exit Function
End If

'devolvemos el numero del socket
ConnectSock = s
End Function

Function bSmtpProgress(b As Long) As Boolean
'recibe un numero en argumento b
On Error Resume Next

'declara TimeOut como variant
Dim TimeOut As Variant

'iguala TimeOut al tiempo actual + 60 seg.
TimeOut = Timer + 60

'mientras el progreso de la transaccion(Indicado en la var
'Progress) no alcance el numero especificado en b, no saldra
'del bucle
While Progress <> b
        DoEvents
        
        'si hubo error en la transaccion cerramos el socket
        'y devolvemos false
        If do_cancel = True Then
        Call closesocket(mysock): mysock = 0
        bSmtpProgress = False
            Exit Function
        End If
        
        'si pasados más de 60 seg. no se alcanza el progreso
        'cerramos el socket y devolvemos false
        If Timer > TimeOut Then
            Call closesocket(mysock): mysock = 0
            bSmtpProgress = False
            Exit Function
        End If
Wend

'si alcanzo el progreso y salio del bucle devolvemos true
bSmtpProgress = True
End Function

Function bSmtpProgress1(b As Long) As Boolean
'recibe un numero en argumento b
On Error Resume Next

'declara TimeOut como variant
Dim TimeOut As Variant

'iguala TimeOut al tiempo actual + 60 seg.
TimeOut = Timer + 60

'mientras la respuesta del server(Indicado en la var
'Progress) no sea = al numero especificado en b, no saldra
'del bucle
While rtncode <> b
        DoEvents
        
        'si hubo error en la transaccion cerramos el socket
        'y devolvemos false
        If do_cancel = True Then
        Call closesocket(mysock): mysock = 0
        bSmtpProgress1 = False
            Exit Function
        End If
        
        'si pasados más de 60 seg. no recibimos la respuesta
        'esperada, cerramos el socket y devolvemos false
        If Timer > TimeOut Then
            Call closesocket(mysock): mysock = 0
            bSmtpProgress1 = False
            Exit Function
        End If
Wend

'si recibimos la respuesta esperada y salio del bucle
'igualamos rtncode a 0 y devolvemos true
rtncode = 0
bSmtpProgress1 = True
End Function
