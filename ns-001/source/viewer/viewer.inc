BeginPaint              PROCDESC   :DWORD, :DWORD
BitBlt                  PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                                   :DWORD, :DWORD, :DWORD, :DWORD
CloseHandle             PROCDESC   :DWORD
CreateCompatibleDC      PROCDESC   :DWORD
CreatePatternBrush      PROCDESC   :DWORD
CreateFileA             PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                                   :DWORD, :DWORD
CreateFileMappingA      PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                                   :DWORD
CreateWindowExA         PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                                   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, \
                                   :DWORD, :DWORD
DefWindowProcA          PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD
DeleteDC                PROCDESC   :DWORD
DeleteObject            PROCDESC   :DWORD
DestroyWindow           PROCDESC   :DWORD
DispatchMessageA        PROCDESC   :DWORD
DrawTextA               PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
EndPaint                PROCDESC   :DWORD, :DWORD
ExitProcess             PROCDESC   :DWORD
GetClientRect           PROCDESC   :DWORD, :DWORD
GetFileSize             PROCDESC   :DWORD, :DWORD
GetMessageA             PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD
GetModuleHandleA        PROCDESC   :DWORD
GetScrollInfo           PROCDESC   :DWORD, :DWORD, :DWORD
GetStockObject          PROCDESC   :DWORD
InvalidateRect          PROCDESC   :DWORD, :DWORD, :DWORD
LoadBitmapA             PROCDESC   :DWORD, :DWORD
LoadCursorA             PROCDESC   :DWORD, :DWORD
LoadIconA               PROCDESC   :DWORD, :DWORD
LoadMenuA               PROCDESC   :DWORD, :DWORD
MapViewOfFile           PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
PostQuitMessage         PROCDESC   :DWORD
RegisterClassExA        PROCDESC   :DWORD
SelectObject            PROCDESC   :DWORD, :DWORD
SendMessageA            PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD
SetBkMode               PROCDESC   :DWORD, :DWORD
SetScrollInfo           PROCDESC   :DWORD, :DWORD, :DWORD, :DWORD
SetTextColor            PROCDESC   :DWORD, :DWORD
ShowWindow              PROCDESC   :DWORD, :DWORD
TranslateMessage        PROCDESC   :DWORD
UnmapViewOfFile         PROCDESC   :DWORD
UpdateWindow            PROCDESC   :DWORD


MSGSTRUCT struc
    msHWND          dd    ?
    msMESSAGE       dd    ?
    msWPARAM        dd    ?
    msLPARAM        dd    ?
    msTIME          dd    ?
    msPT            dd    2 dup(?)
MSGSTRUCT ends
RECT    struc
        rcLeft          dd ?
        rcTop           dd ?
        rcRight         dd ?
        rcBottom        dd ?
RECT    ends
PAINTSTRUCT STRUC
    PShdc         dd             ?
    PSfErase      dd             ?
    PSrcPaint     dd             size RECT dup(?)
    PSfRestore    dd             ?
    PSfIncUpdate  dd             ?
    PSrgbReserved db             32 dup(?)
PAINTSTRUCT ENDS
SCROLLINFO STRUC
    SIcbSize    dd      ?
    SIfMask     dd      ?
    SInMin      dd      ?
    SInMax      dd      ?
    SInPage     dd      ?
    SInPos      dd      ?
    SInTrackPos dd      ?
SCROLLINFO ENDS
WNDCLASSEX struct
        cbSize          dd      ?
        cbStyle         dd      ?
        lpfnWndProc     dd      ?
        cbclsExtra      dd      ?
        cbWndExtra      dd      ?
        _hInstance      dd      ?
        hIcon           dd      ?
        hCursor         dd      ?
        hbrBackground   dd      ?
        lpszMenuName    dd      ?
        lpszClassName   dd      ?
        _hIconSm        dd      ?
WNDCLASSEX ends


IDI_APPLICATION = 32512
IDC_ARROW       = 32512
CW_USEDEFAULT   EQU    8000h
WM_DESTROY          = 0002h
WM_PAINT            = 000Fh
WM_COMMAND          = 0111h
WM_KEYDOWN                      equ     0100h
WM_VSCROLL                      equ     0115h
SW_SHOW            = 5
DT_SINGLELINE   = 20H
WS_OVERLAPPED   = 000000000h
WS_ICONICPOPUP  = 0C0000000h
WS_POPUP        = 080000000h
WS_CHILD        = 040000000h
WS_MINIMIZE     = 020000000h
WS_VISIBLE      = 010000000h
WS_DISABLED     = 008000000h
WS_CLIPSIBLINGS = 004000000h
WS_CLIPCHILDREN = 002000000h
WS_MAXIMIZE     = 001000000h
WS_CAPTION      = 000C00000h
WS_BORDER       = 000800000h
WS_DLGFRAME     = 000400000h
WS_VSCROLL      = 000200000h
WS_HSCROLL      = 000100000h
WS_SYSMENU      = 000080000h
WS_THICKFRAME   = 000040000h
WS_HREDRAW      = 000020000h
WS_VREDRAW      = 000010000h
WS_GROUP        = 000020000h
WS_TABSTOP      = 000010000h
WS_MINIMIZEBOX  = 000020000h
WS_MAXIMIZEBOX  = 000010000h
WS_OVERLAPPED   = 000000000h
WS_OVERLAPPEDWINDOW = WS_OVERLAPPED OR WS_CAPTION OR WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR WS_MAXIMIZEBOX
CS_VREDRAW         = 0001h
CS_HREDRAW         = 0002h
DEFAULT_QUALITY         equ     000h
CLIP_DEFAULT_PRECIS     equ     000h
DT_VCENTER      = 04H
COLOR_WINDOW              = 5
BLACK_BRUSH         =  4
FILE_SHARE_READ         equ     0001h
FILE_SHARE_WRITE        equ     0002h
GENERIC_READ            equ     80000000h
OPEN_EXISTING           equ     3
PAGE_READONLY                   equ     00000002h
FILE_MAP_READ   = 0004
DT_NOPREFIX                     equ     00000800h
OEM_FIXED_FONT                  equ     10
TRANSPARENT                     equ     1
SIF_RANGE           = 0001h
SIF_PAGE            = 0002h
SIF_POS             = 0004h
SIF_DISABLENOSCROLL = 0008h
SIF_TRACKPOS        = 0010h
SIF_ALL             = SIF_RANGE or SIF_PAGE or SIF_POS or SIF_TRACKPOS
SB_VERT                         equ     1
SB_LINEUP                       equ     0
SB_LINEDOWN                     equ     1
SB_PAGEUP                       equ     2
SB_PAGEDOWN                     equ     3
SB_THUMBPOSITION                equ     4
SB_THUMBTRACK                   equ     5
SB_TOP                          equ     6
SB_LEFT                         equ     6
SB_BOTTOM                       equ     7
SB_RIGHT                        equ     7
SB_ENDSCROLL                    equ     8
VK_ESCAPE                       equ     1Bh
VK_PRIOR                        equ     21h
VK_NEXT                         equ     22h
VK_END                          equ     23h
VK_HOME                         equ     24h
VK_UP                           equ     26h
VK_DOWN                         equ     28h
SRCCOPY                         equ     00CC0020h       ;dest = src

