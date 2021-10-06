.386 
.model flat,stdcall
option casemap:none 

include c:\masm32\include\windows.inc 
include c:\masm32\include\user32.inc 
includelib c:\masm32\lib\user32.lib            
include c:\masm32\include\kernel32.inc 
includelib c:\masm32\lib\kernel32.lib


WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 

.data

classname   db "GUI Example",0
appname     db "GUI Example",0
wintext     db "Some text on the screen",0
themenu     db "GUIexample",0
text1       db "BeLiALs GUIExample About Window",0
text2       db "Coded by BeLiAL/bcvg",0
editclass   db "edit",0
ButtonText  db "test",0
ButtonClassName db "button",0

.data?

hInstance       HINSTANCE ?
edithandle      HWND ?
serialbuffer    db 512 dup(?)
byteflag        db ? 
hwndButton      HWND ?

.const

IDM_GOODBYE   EQU 2
IDM_ABOUT     EQU 3
EDITID        EQU 4
ButtonID      EQU 1

.code

start:

invoke GetModuleHandle,NULL
mov hInstance,eax

invoke WinMain, hInstance,NULL,NULL, SW_SHOWDEFAULT 
  
invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 

LOCAL wc:WNDCLASSEX 
LOCAL msg:MSG 
LOCAL hwnd:HWND 

mov   wc.cbSize,SIZEOF WNDCLASSEX
mov   wc.style, CS_HREDRAW or CS_VREDRAW 
mov   wc.lpfnWndProc, offset WinProc
mov   wc.cbClsExtra,NULL 
mov   wc.cbWndExtra,NULL 
mov   eax,hInstance
mov   wc.hInstance,eax

invoke LoadIcon,NULL,IDI_APPLICATION
mov   wc.hIcon,eax
mov   wc.hIconSm,eax 

invoke LoadCursor,NULL,IDC_ARROW	
mov    wc.hCursor,eax

mov   wc.hbrBackground,2 
mov   wc.lpszMenuName,OFFSET themenu
mov   wc.lpszClassName,OFFSET classname 

invoke RegisterClassEx, addr wc
invoke CreateWindowEx,NULL,addr classname,addr appname,00cf0000h,\
                      CW_USEDEFAULT,CW_USEDEFAULT,200,140,\
                      NULL,NULL,hInst,NULL
mov   hwnd,eax 

invoke ShowWindow, hwnd,CmdShow 
invoke UpdateWindow, hwnd 

 .WHILE TRUE 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax) 
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
 .ENDW
 
mov     eax,msg.wParam 
ret                         
 	
WinMain endp
 
WinProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 

LOCAL hdc:HDC 
LOCAL ps:PAINTSTRUCT 
LOCAL rect:RECT 
 
 .IF uMsg==WM_DESTROY                         
        invoke PostQuitMessage,NULL
        
 .ELSEIF uMsg==WM_PAINT
        invoke CreateWindowEx,WS_EX_CLIENTEDGE, ADDR editclass,NULL,\ 
                        WS_CHILD or WS_VISIBLE or WS_BORDER or ES_LEFT or\ 
                        ES_AUTOHSCROLL,\ 
                        0,24,90,20,hWnd,8,hInstance,NULL
        mov edithandle,eax

        invoke CreateWindowEx,NULL, ADDR ButtonClassName,ADDR ButtonText,\
                        WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,\
                        0,50,40,20,hWnd,ButtonID,hInstance,NULL
        mov  hwndButton,eax
                 
        invoke BeginPaint,hWnd, addr ps 
        mov    hdc,eax 
        invoke GetClientRect,hWnd, addr rect
        mov rect.right,170       
        invoke DrawText, hdc,addr wintext,-1, ADDR rect, \ 
                     DT_SINGLELINE  
        invoke EndPaint,hWnd, addr ps 

 .ELSEIF uMsg==WM_COMMAND 
        mov eax,wParam
   .IF lParam==0    
     .IF ax==IDM_ABOUT
        invoke MessageBox,NULL,offset text2,offset text1, MB_OK 
     .ELSE   
        invoke DestroyWindow,hWnd
     .ENDIF
   .ELSE 
     .IF ax==EDITID
        shr eax,16
     .ENDIF                         
   .ENDIF
 .ELSE 
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam   
        ret
 .ENDIF
  
xor eax,eax 
ret 
    
WinProc endp

end start