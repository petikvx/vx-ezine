comment %

 "Técnicas antidebugger v1.1" es un programa que rastrea el tracing de un debugger y lo conduce
 a su muerte, bujujuu bujuajuaja.

 Medida ideal para ser utilizada (como ya lo ha sido) en el diseño de virus
 para aplicaciones Win32.

 Escrito por Jtag y ErGrone. Enero del 2003. y experimentando un compendio de técnicas de
 protección software.
 Ensamblado con Turbo assembler 32-bits v5.0, debuggeado 
 y testeado con Turbo debugger 32-bits v5.0 - SoftIce 4.05 - W32Dasm 8.9 - y OllyDbg 1.08

        %



.386p
.model flat,STDCALL


extrn GetCommandLineA       :PROC
extrn GetModuleHandleA      :PROC
extrn GetProcAddress        :PROC
extrn ExitProcess           :PROC
extrn MessageBoxA           :PROC
extrn FindWindowA           :PROC
extrn GetEnvironmentStrings :PROC
extrn lstrlen               :PROC
extrn lstrcmp               :PROC




.DATA

Titulo1         DB 'Técnicas antidebugger v1.1',0
Mensaje1        DB 'No hay ningún debugger en ejecución',0
Mensaje2        DB 'very guud! very guud! lo has crackeado.',13,10
		DB 'eres todo un cracker, ahora ponte a llorar de la emoción',0
Intro           DB 'Instrucciones de uso: ',13,10
                DB 'Si ejecuta el programa directamente desde Windows',13,10
                DB 'notará que aparece una ventana donde se le notifica',13,10
                DB 'que efectivamente no ha sido ejecutado por algun debugger.',13,10,13,10
                DB 'Si ejecuta en cambio este programa traceándolo, paso a paso',13,10
		DB 'o haciéndolo correr bajo un debugger notará que efectivamente',13,10
                DB 'se genera un error en el depurador.',13,10,13,10
                DB 'Desea seguir adelante?',13,10,0

Presente        DB 'IsDebuggerPresent',0
Kernel          DB 'KERNEL32',0
elsice          DB 'CMDLINE=winice',0
Sdos            DB 'Símbolo del sistema',0     ;Para saber si sólo es la ventana DOS.
elretorno       DD ?
xData           DD ?


SEH:            mov ecx,fs:[20h]              ;Observamos el estado del registro para saber 
                jecxz naah                    ;si hay o no hay un debugger en ejecución.
                push dword ptr fs:[00000000h] ;Guardamos y establecemos el SEH (luego podríamos 
					      ;recuperarlo, pero no lo haremos.)
                mov fs:[00000000h],esp        ;Movemos el offset de nuestro handler
                   		              ;(por defecto esta el nuestro)
                xor eax,eax
                mov dword ptr [eax],400h      ;Intentamos generar un error.
		jmp Otravez
naah:           ret

Otravez:        push dword ptr fs:[00000000h]  ;Sí, una vez más el SEH con otro tipo de error.
		mov fs:[00000000h],esp
		mov eax,-1 		       
		mov eax,[eax]		       ;he aqui el error
		ret

API:            push OFFSET Kernel            ;Metemos la cadena 'KERNEL32' para la búsqueda de 
					      ;la DLL.
                call GetModuleHandleA         ;Obtenemos el handle.
                push OFFSET Presente          ;Metemos el nombre de la función de la cual 
					      ;deseamos obtener la dirección.
                push eax		      ;Handle anterior.
                call GetProcAddress           ;Obtenemos la direccion!
                call eax                      ;Testeamos a ver si hay otra vez
                or eax,eax		      ;el debugger en ejecución
                jz upsss                      ;valor distinto de cero = SÍ hay debugger

uepa:	        call aqui		      ;Este es un viejo truco para Win.
                int 20h			      ;Gran pantallazo azul si CS no posee la dirección 
                int 21h			      ;del PSP al finalizar proceso.
aqui:           mov word ptr [uepa],4CB4h     ;4CB4h es el opcode de mov ah,4C

upsss:          ret

; Esta función queda oculta ante el desensamblado con W32Dasm 8.9
; si debugeamos un programa que contenga llamada a la API IsdebugerPresent podremos ver algo 
; parecido a ésto:

Detectadebug1:  mov eax, FS:[edi+5h]
                mov eax, [eax+30h]
                cmp byte ptr[eax+2],1
                jnz sigo
                call edx                      ;Detectamos debug, fuuulck yu
                sigo:
                ret


; Detectaremos la actividad de SoftIce, la de Turbo Debugger o la de OllyDebug. 
; (No he testeado con TRW). 
; Cuando nuestra aplicación es ejecutada normalmente el primer byte que
; vemos en el lugar donde apunta eax luego de GetCommandlineA es 22h, o sea una "
; si esta " no existe es porque nos estan ejecutando por ventana DOS o bien
; porque SoftIce esta presente.
; podemos detectar si sólo esta la ventana DOS con la api FindWindowA y asi
; evitar una falsa detección.
; - Solo nos haría fallar una sola situación
; si abrimos una ventana DOS y ejecutamos SoftIce, nuestra rutina falla.

DetectaSoftice:  call GetCommandLineA
                 cmp byte ptr [eax], 22h    
                 je Bien			   
                 push offset Sdos
                 push 0
                 call FindWindowA
                 cmp eax,0
                 jne Bien
                 pop eax ;Fulck you
Bien:            ret


; Detectaremos softice utilizando la API GetEnvironmentStrings
; si encontramos CMDLINE=winice , es porque SoftIce esta en memoria y podemos
; tomar medidas.  Testeado en Win98.

DetectaSoftice2: push ebx
                 push ebp
                 push edi

                 call GetEnvironmentStrings  ;En eax queda el offset donde comienzan los 
                                             ;strings de entorno.
bucle_:          mov ebx,eax
                 push ebx
                 call lstrlen                ;La longitud del string
                 cmp eax,0                   ;es 0? entonces no hay mas strings y nos retiramos.
                 je limpio
                 mov ebp,eax
                 push offset elsice
                 push ebx
                 call lstrcmp                ;Comparamos strings
                 cmp eax,0                   ;si eax retorna 0, softice esta en memoria
                 je fulkyou
                 inc ebp                     ;Le sumamos 1 a la longitud del string
                 add ebx,ebp                 ;Le sumamos la longitud+1 a la offset y asi poder 
				             ;leer el siguiente string.
                 mov eax,ebx                 ;Estos string terminan en null.
                 jmp bucle_


limpio:          pop edi
                 pop edx
                 pop ebp

fulkyou:         ret




.CODE

Inicio:
                push 00000004h               ;00000004h = MB_YesNo
                push OFFSET Titulo1
                push OFFSET Intro
                push 0
                call MessageBoxA
                cmp  eax,6h                  ;ha presionado el botón "No"?
                jnz  Adios                   ;si es así pues Adios Lucas.

                mov edi,13h

                call Detectadebug1
                call DetectaSoftice
                call DetectaSoftice2
		call SEH
		call API
		jmp  NoDetectado

                push 00000040h
                push OFFSET Titulo1
                push OFFSET Mensaje2
                push 0h
                call MessageBoxA
		jmp  Adios

NoDetectado:    push 00000040h
                push OFFSET Titulo1
                push OFFSET Mensaje1
                push 0h
                call MessageBoxA

Adios:          push 0h
                call ExitProcess


end Inicio




