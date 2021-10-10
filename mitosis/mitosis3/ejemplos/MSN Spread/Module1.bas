Attribute VB_Name = "Module1"
Public Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Public Declare Function PostMessage Lib "user32" Alias "PostMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
Public Declare Function PostMessageString Lib "user32" Alias "PostMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As String) As Long
Public Declare Function FindWindowEx Lib "user32" Alias "FindWindowExA" (ByVal hWnd1 As Long, ByVal hWnd2 As Long, ByVal lpsz1 As String, ByVal lpsz2 As String) As Long
Public Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long
Public Declare Function SendMessageByString Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As String) As Long
Public Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hwnd As Long, ByVal nIndex As Long) As Long
Public Declare Function GetForegroundWindow Lib "user32" () As Long
Public Declare Function SetForegroundWindow Lib "user32" (ByVal hwnd As Long) As Long
Public Declare Function GetWindowTextLength Lib "user32" Alias "GetWindowTextLengthA" (ByVal hwnd As Long) As Long
Public Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hwnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Public Declare Function GetDesktopWindow Lib "user32" () As Long
Public Declare Function GetWindow Lib "user32" (ByVal hwnd As Long, ByVal wFlag As Long) As Long
Public Declare Function ShowWindow Lib "user32" (ByVal hwnd As Long, ByVal nCmdShow As Long) As Long

Private Const GW_HWNDFIRST = 0&
Private Const GW_HWNDNEXT = 2&
Private Const GW_CHILD = 5&
Public Const GWL_HWNDPARENT = (-8)
Public Const WM_SETTEXT = &HC
Public Const WM_GETTEXT = &HD
Public Const WM_GETTEXTLENGTH = &HE
Public Const WM_KEYDOWN = &H100
Public Const WM_KEYUP = &H101
Public Const WM_CHAR = &H102
Public Const WM_COMMAND = &H111
Public Const VK_RETURN = &HD

Public Function EnviarFile(ByVal DirPath As String, hwn As Long) As Boolean
    Dim X           As Long
    Dim Edit        As Long
    Dim ParentHWnd  As Long
    Dim hWndText    As String
    Dim t           As Single

    Call PostMessage(GetWindowLong(hwn, GWL_HWNDPARENT), WM_COMMAND, 40275, 0)
    DoEvents
    X = GetWindow(GetDesktopWindow(), GW_CHILD)
    hWndText = fWindowText(X)
    t = Timer
    Do Until (InStr(hWndText, "Enviar") <> 0 And InStr(hWndText, "fichero") <> 0) Or (InStr(hWndText, "Send") <> 0 And InStr(hWndText, "File") <> 0)
        X = GetWindow(X, GW_HWNDNEXT)
        hWndText = fWindowText(X)
        If Format(Timer - t, "0.00") > 5 Then GoTo FIN
    Loop
    ShowWindow X, 0&
    Edit = FindWindowEx(X, 0, "Edit", vbNullString)
    If Edit = 0 Then
        Edit = FindWindowEx(X, 0, "ComboBoxEx32", vbNullString)
        Edit = FindWindowEx(Edit, 0, "ComboBox", vbNullString)
    End If
    If Edit = 0 Then Exit Function
    Call SendMessageByString(Edit, WM_SETTEXT, 0, DirPath)
    Call PostMessage(Edit, WM_KEYDOWN, VK_RETURN, 0&)
    Call PostMessage(Edit, WM_KEYUP, VK_RETURN, 0&)
    EnviarFile = True
FIN:
End Function
Public Function fWindowText(hwnd As Long) As String
    Dim lLength     As Long
    Dim sText       As String
    lLength = SendMessage(hwnd, WM_GETTEXTLENGTH, 0, ByVal 0&)
    sText = Space$(lLength + 1)
    Call SendMessage(hwnd, WM_GETTEXT, lLength + 1, ByVal sText)
    fWindowText = Left$(sText, lLength)
End Function
