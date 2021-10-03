;(c) Vecna 2001

.386
.model flat,stdcall
option casemap :none


include d:\masm32\include\windows.inc
include d:\masm32\include\user32.inc
includelib d:\masm32\lib\user32.lib
include d:\masm32\include\kernel32.inc
includelib d:\masm32\lib\kernel32.lib
include d:\masm32\include\wsock32.inc
includelib d:\masm32\lib\wsock32.lib


WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD


IDC_SERVERIP    EQU 1101
IDC_QUIT        EQU 1102
IDC_PORT        EQU 1103
IDC_REMOVE      EQU 1104
IDC_REMPORT     EQU 1105
IDC_CONNECT     EQU 1106
IDC_LISTPORT    EQU 1107
IDC_REDIRECT    EQU 1108
IDC_IP          EQU 1109
IDC_LIST        EQU 1110


PORT            EQU 1081


.data
appname       db "Schadenfreude",0
dlgname       db "PROXYGUI",0
sz_connect    db "Connect",0
sz_disconnect db "Disconnect",0
list_empty    db "Redirect list is empty",0
sz_quit       db "quit",0
sz_list       db "list",0
sz_remove     db "rem:"
portnumba     db 8 dup (0)
sz_add        db "add:"
redir_ip      db 24 dup (0)


.data?
hInstance dd ?
hsocket   dd ?
connected dd ?
hButton   dd ?
hList     dd ?
hEdit1    dd ?
hEdit2    dd ?
hEdit3    dd ?
hEdit4    dd ?
buffer    db 200h dup (?)
buffer2   db 200h dup (?)


.code


start:
       invoke GetModuleHandle,NULL
       mov hInstance,eax
       invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR WndProc,0
       invoke ExitProcess,eax


value2decimal:
       push ebx
       push edx
       xor edx,edx
       mov ebx,10
       div ebx
       push edx
       or eax,eax
       jz @@skipz
       call value2decimal
 @@skipz:
       pop eax
       add al,"0"
       stosb
       pop edx
       pop ebx
       ret


WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
        LOCAL mainsocket:sockaddr_in
     .if uMsg == WM_COMMAND
       .if wParam == IDC_QUIT
             jmp @@end_shit
       .elseif wParam == IDC_CONNECT
             cmp [connected],0
             je @@connect
             invoke send,[hsocket],ADDR sz_quit,5,NULL
         @@error:
             invoke closesocket,[hsocket]
             invoke socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
             mov [hsocket],eax
             invoke SendMessage,hEdit1,WM_ENABLE,1,0
             invoke SendMessage,hButton,WM_SETTEXT,0,ADDR sz_connect
             invoke SendMessage,hList,LB_RESETCONTENT,0,0
             mov [connected],0
             jmp @@done
          @@connect:
             invoke SendMessage,hEdit1,WM_GETTEXT,200h,ADDR buffer
             invoke lstrlen,ADDR buffer
             sub eax, 8
             jc @@done
             invoke inet_addr,ADDR buffer
             cmp eax,INADDR_NONE
             jne @@isip
             invoke gethostbyname,ADDR buffer
             test eax,eax
             jz @@done
             mov eax,[eax+hostent.h_list]
             mov eax,[eax]
             mov eax,[eax]
       @@isip:
             mov mainsocket.sin_addr,eax
             mov mainsocket.sin_family,AF_INET
             invoke htons,PORT
             mov mainsocket.sin_port,ax
             mov dword ptr mainsocket.sin_zero,0
             mov dword ptr mainsocket.sin_zero+4,0
             invoke connect,[hsocket],ADDR mainsocket,SIZE sockaddr_in
             test eax,eax
             jnz @@done
             invoke recv,[hsocket],ADDR buffer,200h,0
             inc eax
             jz @@error
             push edi
             lea edi,appname
             lea esi,buffer
             mov ecx,12
             repe cmpsb
             pop edi
             jne @@error
             invoke SendMessage,hEdit1,WM_ENABLE,0,0
             invoke SendMessage,hButton,WM_SETTEXT,0,ADDR sz_disconnect
             invoke MessageBoxA,0,ADDR buffer,ADDR appname,0
             mov [connected],1
             jmp @@done1
          @@done:
             invoke MessageBeep,-1
          @@done1:
       .elseif wParam == IDC_REDIRECT
             cmp [connected],1
             jne @@done
             invoke SendMessage,hEdit2,WM_GETTEXT,200h,ADDR buffer
             invoke inet_addr,ADDR buffer
             cmp eax,INADDR_NONE
             jne @@isaip
             invoke gethostbyname,ADDR buffer
             test eax,eax
             jz @@done
             mov eax,[eax+hostent.h_list]
             mov eax,[eax]
             mov eax,[eax]
       @@isaip:
             push edi
             lea edi,redir_ip
             mov ecx,4
       @@turn2ip:
             push eax
             movzx eax,al
             call value2decimal
             mov al,"."
             stosb
             pop eax
             ror eax,8
             loop @@turn2ip
             mov byte ptr [edi-1],":"
             invoke SendMessage,hEdit3,WM_GETTEXT,200h,edi
             lea edi,[edi+eax+1]
             lea ebx,sz_add
             sub edi,ebx
             invoke send,[hsocket],ebx,edi,NULL
             pop edi
             inc eax
             jz @@error
             invoke recv,[hsocket],ADDR buffer,200h,0
             inc eax
             jz @@error
             jmp @@list666
         @@noexist:
       .elseif wParam == IDC_LISTPORT
             cmp [connected],1
             jne @@done
         @@list:
             invoke send,[hsocket],ADDR sz_list,5,NULL
             inc eax
             jz @@error
             lea esi,buffer
             invoke recv,[hsocket],esi,200h,0
             inc eax
             jz @@done
             cmp dword ptr [esi],"tpme"
             jne @@something
             invoke SendMessage,hList,LB_RESETCONTENT,0,0
             invoke MessageBox,0,ADDR list_empty,ADDR appname,0
             jmp @@done
         @@something:
             push edi
             invoke SendMessage,hList,LB_RESETCONTENT,0,0
         @@listitem:
             lea edi, buffer2
             lodsb
             sub al, "*"
             mov eax, 20202020h
             jnz @@freeport
             mov ah, "*"
         @@freeport:
             stosd
             mov ecx, 15
         @@nextchar1:
             lodsb
             cmp al, ":"
             je @@portname
             stosb
             loop @@nextchar1
         @@portname:
             mov al, " "
             rep stosb
         @@nextch:
             lodsb
             cmp al, 0dh
             je @@cr
             stosb
             jmp @@nextch
         @@cr:
             lodsb
             sub eax, eax
             stosd
             invoke SendMessage,hList,LB_ADDSTRING,0,ADDR buffer2
             cmp byte ptr [esi],0
             jne @@listitem
             pop edi
       .elseif wParam == IDC_REMOVE
             cmp [connected],1
             jne @@done
             invoke SendMessage,hEdit4,WM_GETTEXT,8,ADDR portnumba
             add eax,5
             invoke send,[hsocket],ADDR sz_remove,eax,NULL
             inc eax
             jz @@error
        @@list666:
             invoke Sleep, 500
             jmp @@list
       .endif
     .elseif uMsg == WM_INITDIALOG
             invoke WSAStartup,101h,ADDR buffer
             invoke socket,AF_INET,SOCK_STREAM,IPPROTO_TCP
             mov hsocket,eax
             mov connected,0
             invoke GetDlgItem,hWin,IDC_CONNECT
             mov hButton,eax
             invoke GetDlgItem,hWin,IDC_LIST
             mov hList,eax
             invoke GetDlgItem,hWin,IDC_SERVERIP
             mov hEdit1,eax
             invoke GetDlgItem,hWin,IDC_IP
             mov hEdit2,eax
             invoke GetDlgItem,hWin,IDC_PORT
             mov hEdit3,eax
             invoke GetDlgItem,hWin,IDC_REMPORT
             mov hEdit4,eax
             invoke SendMessage,hButton,WM_SETTEXT,0,ADDR sz_connect
     .elseif uMsg == WM_CLOSE
        @@end_shit:
             invoke closesocket,[hsocket]
             invoke WSACleanup
             invoke EndDialog,hWin,0
     .endif
       xor eax,eax
       ret
WndProc endp


end start

