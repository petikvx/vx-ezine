 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 ------------------------------------ Viewer )=-
 -=( ---------------------------------------------------------------------- )=-

 -=( 0 : Viewer Design Goals ---------------------------------------------- )=-

 Every zine needs a viewer, right?   Well no, but we figured that it would look
 better if we made one anyways.

 To make the  experience informative,   the choice was made  to code it in pure
 asm.   The result came out well.   With the source published,  it'll also help
 for those  of you who are implicity distrustful of running anything  in a zine
 and maybe you'll enjoy the viewer too.

 The viewer is  a window with  a bmp background  with vertical  scroll bar  and
 menus.  The menu will open and display the appropriate text file.  That's  all
 the viewer does - no hidden games or anything.

 The actual implementation of a viewer under  Windows is  a  trying experience.
 A lot of the APIs have subtle bugs.   For example,  the API CreatePatternBrush
 doesn't always work (seems to be a memory thing) but decides to return success
 anyways  (resulting in a  last minute  work  around).   Special  thanks to our
 offical beta-tester for catching this one.

 -=( 1 : Viewer Compile Instructions -------------------------------------- )=-

 TASM32 5.0  &  TLINK32 1.6.71.0

 tasm32 /m /ml viewer.asm
 brc32 -r viewer.rc
 tlink32 /Tpe /aa /x viewer.obj, viewer.exe,, import32.lib,, viewer.res

 -=( 2 : Viewer ----------------------------------------------------------- ) `

.386
.model flat, stdcall
warn

include viewer.inc              ; lots of struct and constant definitions

MYPAGESIZE = 36
MAXLINESPERPAGE = 38
TEXTCOLOR  = 00C0C0C0h

ICONNUM  = 101
BITMAPNUM= 102

.data?
MenuHnd         dd              ?
hdc             dd              ?
msg             MSGSTRUCT       ?
ps              PAINTSTRUCT     ?
rect            RECT            ?
bmphnd          dd              ?


.data                                   ;the data area
WinName         db      'Natural Selection #1',0
classname       db      'ClassName',0
MenuName        db      'Todays_Menu',0
filename        db      'ns#1-0_0.txt',0
ErrorMsg        db      'Bad command or file name',0
FileHnd         dd      0
MapHnd          dd      0
MemMap          dd      0
FileSize        dd      0
FileLines       dd      0
DisplayPos      dd      0

wc      WNDCLASSEX      <30h, \                 ; size of WNDCLASSEX
                CS_HREDRAW or CS_VREDRAW, \     ; Window style
                offset Winproc, \               ; Window event handler
                0, \                            ; # bytes after WinClass struct
                0, \                            ; # bytes after Window Instance
                0, \                            ; hInstance
                0, \                            ; hIcon
                0, \                            ; hCursor
                COLOR_WINDOW+1, \               ; background color (1-19)
                0, \                            ; Menu Name
                offset classname, \             ; Class Name
                0>                              ; Handle to small Icon
_si     SCROLLINFO      <size SCROLLINFO,0,0,0,0,0,0>




.CODE                                   ; executable code starts here

start:
        call    FileOpen                ; Open default file and MemMap it
        call    GetModuleHandleA, 0     ; Get the handle of this program
                                        ; NULL returns handle used to create
                                        ; process (usually the param is a
                                        ; string to a lib name [dll])
; Register a Parent Window
        mov     wc._hInstance,eax
        xchg    eax,ebx
        call    LoadIconA, ebx, ICONNUM
        mov     wc.hIcon, eax
        call    LoadCursorA, dword ptr 0, IDC_ARROW
        mov     wc.hCursor,eax
        call    LoadBitmapA, ebx, BITMAPNUM
        mov     bmphnd, eax
        call    GetStockObject, BLACK_BRUSH     ; Work around another Win bug
        mov     wc.hbrBackground, eax
RegIt:
        call    RegisterClassExA, offset wc

; Create Menu
        call    LoadMenuA, ebx, offset MenuName
        mov     MenuHnd, eax

; Create Parent Window
        call CreateWindowExA,   dword ptr 0 \           ; Ex_Win_style
                                , offset classname \    ; Class Name
                                , offset WinName \      ; Window Name
                                , WS_SYSMENU or WS_DLGFRAME or WS_VSCROLL or WS_MINIMIZEBOX \
                                , CW_USEDEFAULT \       ; Horiz Pos.
                                , CW_USEDEFAULT \       ; Vert. Pos.
                                , 664 \ CW_USEDEFAULT   \       ; Width
                                , 500 \ CW_USEDEFAULT   \       ; Height
                                , dword ptr 0 \         ; Parent Handle
                                , eax \                 ; Menu Handle
                                , ebx \                 ; hinst
                                , dword ptr 0           ; Addr(WinCreationData)
        xchg    eax,ebx
        call    SetScrollInfo, ebx, SB_VERT, offset _si, 0

        call    GetStockObject, OEM_FIXED_FONT


; Display Window
        call    ShowWindow, ebx, dword ptr SW_SHOW
        call    UpdateWindow, ebx


MainLoop:
        call    GetMessageA, offset msg, dword ptr 0, dword ptr 0, dword ptr 0
        test    eax,eax
        jz      short ProgDone
        call    TranslateMessage, offset msg
        call    DispatchMessageA, offset msg
        jmp     MainLoop

ProgDone:
        call    DeleteObject, bmphnd
        call    ExitProcess, 0   ;ends the program


; -=( --------------------------------------------------------------------- )=-
;
;               Event Handler
;
; -=( --------------------------------------------------------------------- )=-

Winproc proc hWnd:dword, uMsg:dword, wParam:dword, lParam:dword
        mov     eax, uMsg
        cmp     eax, WM_PAINT                   ; Redraw Screen?
        je      WinRedraw
        cmp     eax, WM_COMMAND                 ; Menu Item Picked
        je      PickMenu
        cmp     eax, WM_VSCROLL                 ; Scroll?
        je      DoVScroll
        cmp     eax, WM_KEYDOWN                 ; Key pressed?
        je      short WinChar
        cmp     eax, WM_DESTROY                 ; End Prog?
        je      WinQuit

WinDefault:
        call    DefWindowProcA, hWnd, uMsg, wParam, lParam
ExitWinProc:
        ret

GotoBegin:
        mov     eax, MemMap
        mov     DisplayPos, eax
        lea     esi, _si
        mov     [esi].SInPos, ecx               ; set to 0
        jmp     ResumeScroll


WinChar:
        mov     eax,wParam
        cmp     al,'Q'                          ; q= quit
        je      WinQuit
        cmp     eax, VK_ESCAPE                  ; as does Esc
        je      WinQuit
        xor     ecx, ecx                        ;  mov  ecx, SB_LINEUP
        cmp     MemMap, ecx
        je      WinDefault
        cmp     eax, VK_HOME
        je      GotoBegin
        cmp     eax, VK_UP
        je      short ScrollUpMsg
        inc     ecx                             ;  mov  ecx, SB_LINEDOWN
        cmp     eax, VK_DOWN
        je      short ScrollUpMsg
        inc     ecx                             ;  mov  ecx, SB_PAGEUP
        cmp     eax, VK_PRIOR
        je      short ScrollUpMsg
        inc     ecx                             ;  mov  ecx, SB_PAGEDOWN
        cmp     eax, VK_NEXT
        jne     WinDefault
ScrollUpMsg:
        call    SendMessageA, hWnd, WM_VSCROLL, ecx, 0
        jmp     WinDefault



PickMenu:                                       ; Menu Choices
        mov     ecx, MemMap
        jecxz   ResetFile
        call    UnmapViewOfFile, ecx
        call    CloseHandle, MapHnd
        call    CloseHandle, FileHnd
ResetFile:
        movzx   eax, word ptr wParam
        cmp     eax, 1
        je      short MenuExit
        mov     ebx, eax
        shr     ebx, 4
        and     eax, 7
        add     eax, '0'
        add     ebx, '0'-1
        mov     filename+5, bl
        mov     filename+7, al
        call    FileOpen
        call    SetScrollInfo, hWnd, SB_VERT, esi, 1
        call    InvalidateRect, hWnd, 0, 1              ; Refresh screen
        jmp     WinDefault
MenuExit:
        call    DestroyWindow, hWnd
        jmp     ExitWinProc

WinQuit:
        call    PostQuitMessage, dword ptr 0
        xor     eax,eax
        jmp     ExitWinProc


WinRedraw:
        call    GetClientRect, hWnd, offset rect        ; Draw Text
        inc     rect.rcTop
        call    BeginPaint, hWnd, offset ps
        xchg    eax,ebx
        call    CreateCompatibleDC, ebx
        xchg    esi, eax
        call    SelectObject, esi, bmphnd
        xor     ecx,ecx
        call    BitBlt, ebx, ecx, ecx, 664, 500, esi, ecx, ecx, SRCCOPY
        call    DeleteDC, esi

        call    SetBkMode, ebx, TRANSPARENT
        call    SetTextColor, ebx, TEXTCOLOR
        call    GetStockObject, OEM_FIXED_FONT
        call    SelectObject, ebx, eax
        mov     ecx, DisplayPos
        jecxz   DispError
        mov     eax, MemMap
        sub     eax, ecx
        add     eax, FileSize
        cmp     eax, 10000h                     ; Work around windows bug
        jb      short WillFit                   ;  (uses only bottom 16 bits)
        mov     eax, 0FFFFh
WillFit:
        call    DrawTextA, ebx, ecx, eax, offset rect, DT_NOPREFIX
        jmp     short FinishRedraw
DispError:
        call    DrawTextA, ebx, offset ErrorMsg, -1, offset rect, DT_NOPREFIX
FinishRedraw:
        call    EndPaint, hWnd, offset ps
        jmp     ExitWinProc



DoVScroll:
        mov     edi, DisplayPos
        test    edi, edi
        je      short ExitScroll
        lea     esi, _si
        call    GetScrollInfo, hWnd, SB_VERT, esi
        movzx   eax, word ptr wParam
        cmp     eax, SB_LINEDOWN
        je      short LineDown
        cmp     eax, SB_LINEUP
        je      short LineUp
        cmp     eax, SB_PAGEUP
        je      short PageUp
        cmp     eax, SB_PAGEDOWN
        je      PageDown
        jmp     short ExitScroll
ResumeScroll:
        mov     [esi].SIfMask, SIF_POS
        call    SetScrollInfo, hWnd, SB_VERT, esi, 1
        call    InvalidateRect, hWnd, 0, 1
ExitScroll:
        xor     eax, eax
        ret
LineDown:
        mov     eax, [esi].SInPos
        cmp     eax, [esi].SInMax
        jae     ExitScroll
        inc     [esi].SInPos
        mov     ecx, MemMap
        sub     ecx, edi
        add     ecx, FileSize
NextLineLoop:
        jz      short NextLineLoopDone
        cmp     byte ptr [edi],0Ah
        je      short NextLineLoopDone2
        inc     edi
        dec     ecx
        jmp     NextLineLoop
NextLineLoopDone2:
        inc     edi
NextLineLoopDone:
        mov     DisplayPos, edi
        jmp     ResumeScroll
LineUp:
        cmp     [esi].SInPos, 0
        jle     ExitScroll
        dec     [esi].SInPos
        mov     ecx, MemMap
        dec     edi
LineUpLoop:
        dec     edi
        cmp     ecx, edi
        jg      NextLineLoopDone2
        cmp     byte ptr [edi], 0Ah
        je      NextLineLoopDone2
        jmp     LineUpLoop
PageUp:
        mov     ecx, [esi].SInPos
        cmp     ecx, 0
        jle     ExitScroll
        cmp     ecx, MYPAGESIZE
        jb      short UseMinPageUp
        mov     ecx, MYPAGESIZE
UseMinPageUp:
        sub     [esi].SInPos, ecx
        mov     edx, MemMap
        dec     edi
PageUpLoop:
        dec     edi
        cmp     edx, edi
        jg      NextLineLoopDone2
        cmp     byte ptr [edi], 0Ah
        jne     PageUpLoop
        dec     ecx
        jz      NextLineLoopDone2
        jmp     PageUpLoop
PageDown:
        mov     ecx, [esi].SInMax
        sub     ecx, [esi].SInPos
        jle     ExitScroll
        cmp     ecx, MYPAGESIZE
        jb      short UseMinPageDown
        mov     ecx, MYPAGESIZE
UseMinPageDown:
        add     [esi].SInPos, ecx
        mov     edx, MemMap
        sub     edx, edi
        add     edx, FileSize
PageDownLoop:
        jz      NextLineLoopDone
        cmp     byte ptr [edi],0Ah
        je      short PageDownTestDone
PageDownNotDone:
        inc     edi
        dec     edx
        jmp     PageDownLoop
PageDownTestDone:
        dec     ecx
        jz      NextLineLoopDone2
        jmp     PageDownNotDone

Winproc endp


FileOpen PROC                   ; returns vars set and esi = offset _si
        xor     ebx, ebx
        mov     FileHnd, ebx
        mov     MapHnd, ebx
        mov     MemMap, ebx
        mov     FileSize, ebx
        mov     FileLines, ebx
        mov     DisplayPos, ebx
        call    CreateFileA, offset filename, GENERIC_READ, FILE_SHARE_READ, \
                             ebx, OPEN_EXISTING, ebx, ebx
        cmp     eax,-1
        je      short OpenFile_exit
        mov     FileHnd, eax
        call    CreateFileMappingA, eax, ebx, PAGE_READONLY, ebx, ebx, ebx
        mov     MapHnd, eax
        call    MapViewOfFile, eax, FILE_MAP_READ, ebx, ebx, ebx
        mov     MemMap, eax
        mov     DisplayPos, eax
        mov     edi, eax
        call    GetFileSize, FileHnd, ebx
        mov     FileSize, eax

        xor     ecx, ecx
CountLines:
        cmp     ecx, eax
        jae     short CountDone
        cmp     byte ptr [edi+ecx], 0Ah
        lea     ecx, [ecx+1]
        jne     CountLines
        inc     FileLines
        jmp     CountLines
CountDone:
        inc     FileLines

OpenFile_exit:
        lea     esi, _si
        mov     eax, -36
        add     eax, FileLines
        mov     [esi].SInMax, eax
        xor     eax, eax
        mov     [esi].SInMin, eax
        mov     [esi].SInPos, eax
        mov     [esi].SInPage, eax
        mov     [esi].SIfMask, SIF_ALL
        ret
endp


        end     start

 COMMENT ` ---------------------------------------------------------------- )=-
 -=( Natural Selection Issue #1 --------------- (c) 2002 Feathered Serpents )=-
 -=( ---------------------------------------------------------------------- ) `
