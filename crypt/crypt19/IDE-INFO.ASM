;********************************************************************************
; IDE-INFO.ASM
; VERSION:     1.0
; AUTHOR:      K”hntark
; DATE:        Sept 26 1993
;********************************************************************************

MAIN    SEGMENT BYTE
        ASSUME cs:main,ds:main,ss:nothing      ;all part in one segment=com file
        org    100h
 
START:
         
         mov  ah,09   
         lea  dx,[FIRST_MSG]                   ;display KREATOR's msg
         int  21h

;********************************
; Determine # of IDE devices
;********************************
         
         mov  ax,0040h
         mov  ds,ax             ;DS=0040
         mov  si,0075h
         mov  cl,BYTE PTR [si]  ;
         cmp  cl,03
         jb   CONT
         
         mov  ah,09   
         lea  dx,[ERROR_MSG]    ;more than 2 HD devices
         int  21h
         int  20h

CONT:    push cs
         pop  ds                ;DS=CS
         
         
;********************************
; Wait until Controller not busy
;********************************

          mov  dx,01F7h
          in   al,dx
          cmp  al,50h
          jne  AGAIN

;********************************
; Specify 1st / 2nd Drive
;********************************

AGAIN:
             mov  dx,01F6h
             cmp  cl,02
             je   SEC_DRIVE
             mov  al,0A0h
             jmp  short DO_IT
SEC_DRIVE:
             mov  al,0B0h
DO_IT:       out  dx,al
             inc  dx

;********************************
; Send Identify Drive Command
;********************************

          mov  al,0ECh
          out  dx,ax

;********************************
; Wait for Data Ready
;********************************

NOT_READY:   
          in    ax,dx
          cmp   al,58h
          jne   NOT_READY

;****************************************
; Get / Store Identify drive information
;****************************************
          
          mov   dx,01F0h
          push  cx                      ;save # of IDE devices
          mov   cx,0FFh
          mov   di,OFFSET DATA_BUFFER
MORE:          
          in    ax,dx
          xchg  ah,al
          stosw
          loop  MORE

;****************************************
; Display Identify drive information
;****************************************

         call  DDISPLAY
         pop   cx          ;restore # of IDE devices
         loop  AGAIN       ;next IDE drive if any...
         int   20h

;*****************************************************************************

DDISPLAY:
;********************************
; Display Results
;********************************
         
         mov  ah,09                            
         lea  dx,[MSG49]  
         int  21h
         
         mov  bx,WORD PTR [General_configuration]
         xchg bh,bl
         
         test bx,0000000000000010b
         jz   GO_ON
         lea  dx,[MSG35]  
         int  21h

GO_ON:
         test bx,0000000000000100b
         jz   GO_ON1
         lea  dx,[MSG36]  
         int  21h
GO_ON1:
         test bx,0000000000001000b
         jz   GO_ON2
         lea  dx,[MSG37]  
         int  21h
GO_ON2:
         test bx,0000000000010000b
         jz   GO_ON3
         lea  dx,[MSG38]  
         int  21h
GO_ON3:
         test bx,0000000000100000b
         jz   GO_ON4
         lea  dx,[MSG39]  
         int  21h
GO_ON4:
         test bx,0000000001000000b
         jz   GO_ON5
         lea  dx,[MSG40]  
         int  21h
GO_ON5:
         test bx,0000000010000000b
         jz   GO_ON6
         lea  dx,[MSG41]  
         int  21h
GO_ON6:
         test bx,0000000100000000b    
         jz   GO_ON7
         lea  dx,[MSG42]  
         int  21h
GO_ON7:
         test bx,0000001000000000b
         jz   GO_ON8
         lea  dx,[MSG43]  
         int  21h
GO_ON8:
         test bx,0000010000000000b
         jz   GO_ON9
         lea  dx,[MSG44]  
         int  21h
GO_ON9:
         test bx,0000100000000000b
         jz   GO_ON10
         lea  dx,[MSG45]  
         int  21h
GO_ON10:
         test bx,0001000000000000b
         jz   GO_ON11
         lea  dx,[MSG46]  
         int  21h
GO_ON11:
         test bx,0010000000000000b
         jz   GO_ON12
         lea  dx,[MSG47]  
         int  21h
GO_ON12:
         test bx,0100000000000000b
         jz   GO_ON13
         lea  dx,[MSG48]  
         int  21h
GO_ON13:
         
         lea  dx,[LINE]  
         int  21h

         lea  dx,[MSG1]  
         int  21h

         mov  bx,WORD PTR [General_configuration]
         call BIN_TO_HEX
         
;----------------------------------------------------------------------------
         
         lea  dx,[MSG2]  
         int  21h

         mov  bx,WORD PTR [Number_of_cylinders]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG4]  
         int  21h

         mov  bx,WORD PTR [Number_of_heads]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG5]  
         int  21h

         mov  bx,WORD PTR [Number_unformatted_bytes_per_track]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG6]  
         int  21h

         mov  bx,WORD PTR [Number_unformatted_bytes_per_sector]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG7]  
         int  21h

         mov  bx,WORD PTR [Number_sectors_per_track]
         call DEC16OUT
         
;----------------------------------------------------------------------------
         lea  dx,[MSG8]  
         int  21h

         mov  bx,WORD PTR [Vendor_unique1]
         call BIN_TO_HEX
         mov  bx,WORD PTR [Vendor_unique1 + 1]
         call BIN_TO_HEX
         mov  bx,WORD PTR [Vendor_unique1 + 2]
         call BIN_TO_HEX

;----------------------------------------------------------------------------
         
         lea  dx,[MSG9]  
         int  21h
         
         mov  WORD PTR [Serial_number + 18],'$'
         lea  dx,[Serial_number]
         int  21h

;----------------------------------------------------------------------------
         
         lea  dx,[MSG10]  
         int  21h

         mov  bx,WORD PTR [Buffer_type]
         call DEC16OUT
         
         cmp  BYTE PTR [Buffer_type + 1],01
         lea  dx,[MSG52]  
         je   SKIP0
         
         cmp  BYTE PTR [Buffer_type + 1],02
         lea  dx,[MSG53]  
         je   SKIP0
         
         cmp  BYTE PTR [Buffer_type + 1],03
         lea  dx,[MSG54]  
         je   SKIP0
         
         lea  dx,[MSG55]                ;=0 not specified

SKIP0:   int 21h
         
;----------------------------------------------------------------------------
         
         lea  dx,[MSG11]  
         int  21h

         mov  bx,WORD PTR [Buffer_size]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG12]  
         int  21h

         mov  bx,WORD PTR [Num_ECC_bytes_read_write_long_cmds]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG13]  
         int  21h
         
         mov  WORD PTR [Firmware_revision + 6],'$'
         lea  dx,[Firmware_revision]
         int  21h

;----------------------------------------------------------------------------
         
         lea  dx,[MSG14]  
         int  21h
         
         mov  WORD PTR [Model_number + 39],'$'
         lea  dx,[Model_number]
         int  21h

;----------------------------------------------------------------------------
         
         lea  dx,[MSG15]  
         int  21h
         
         mov  bx,WORD PTR [Vendor_unique2]
         call DEC16OUT
         
         cmp  BYTE PTR [Vendor_unique2 + 1],00
         je   RWMCNI
         lea  dx,[MSG51]  
         jmp  short SKIP1

RWMCNI:                     ;read / write multiple command not implemented
         lea  dx,[MSG50]  
SKIP1:   int 21h
         
;----------------------------------------------------------------------------
         
         lea   dx,[MSG16]  
         int   21h

         mov   bx,WORD PTR [Doubleword_performance]
         call  DEC16OUT
         
         cmp   WORD PTR [Doubleword_performance],00
         je    NO_DD_IO
         lea   dx,[MSG33]  
         jmp   short SKIP2

NO_DD_IO:
         lea   dx,[MSG34]  
SKIP2:   int   21h


;----------------------------------------------------------------------------
         
         lea  dx,[MSG17]  
         int  21h

         mov  bx,WORD PTR [Capabilities]
         call DEC16OUT
         
;----------------------------------------------------------------------------
         
         lea  dx,[MSG19]  
         int  21h

         mov  bx,WORD PTR [PIO_data_transfer_cycle_timing_mode]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG20]  
         int  21h

         mov  bx,WORD PTR [DMA_data_transfer_cycle_timing_mode]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG22]  
         int  21h

         mov  bx,WORD PTR [Number_of_current_cylinders]
         call DEC16OUT
         
;----------------------------------------------------------------------------
         
         lea  dx,[MSG23]  
         int  21h

         mov  bx,WORD PTR [Number_of_current_heads]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG24]  
         int  21h

         mov  bx,WORD PTR [Number_of_current_sectors_per_track]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG25]  
         int  21h

         mov  bx,WORD PTR [Current_capacity_in_sectors]
         call BIN_TO_HEX
         mov  bx,WORD PTR [Current_capacity_in_sectors + 1]
         call BIN_TO_HEX

;----------------------------------------------------------------------------
         
         lea  dx,[MSG27]  
         int  21h

         mov  bx,WORD PTR [Total_number_user_addressable_sectors]
         call BIN_TO_HEX
         
         mov  bx,WORD PTR [Total_number_user_addressable_sectors + 1]
         call BIN_TO_HEX

;----------------------------------------------------------------------------
         
         lea  dx,[MSG28]  
         int  21h

         mov  bx,WORD PTR [Single_word_DMA_transfer_mode]
         call DEC16OUT

;----------------------------------------------------------------------------
         
         lea  dx,[MSG29]  
         int  21h

         mov  bx,WORD PTR [Multiword_DMA_transfer_mode]
         call DEC16OUT
         
         ret

;****************************************************************************

BIN_TO_HEX:
            xchg bh,bl
            push cx       ;save registers
            push dx
            push ax

            mov  ch,04    ;# of digits to process
ROTATE:     mov  cl,04    ;# of bits to rotate
            rol  bx,cl    ;rotate bx l to r
            mov  al,bl    ;move to al  (2 digits)
            and  al,0Fh   ;mask off upper digit
            add  al,30h   ;convert to ASCII
            cmp  al,3Ah   ;is it > 9?
            jl   PRINTIT  ;jump of digit =0 to 9
            add  al,07h   ;digit is A to F
PRINTIT:
            mov dl,al
            mov ah,2     ;INT 21h function
            int 21h      ;print character
            dec ch
            jnz ROTATE

            pop  ax      ;restore registers
            pop  dx
            pop  cx
            ret

;****************************************************************************
;Routine to convert from internal 16-bit binary to ASCII decimal

DEC16OUT:

;------------------------
;A binary number is in DX
;------------------------

          xchg bh,bl
          xchg bx,dx
          
          push   DS                    ;Save registers
          push   DI
          push   DX
          push   CX
          push   AX

;--------------------------
;Put the digits in a buffer
;--------------------------

          xor    cx,cx                 ;Initialize the counter
          lea    di,[TBUFF]            ;Point to the buffer
DEC16OUT1:
          push   cx                    ;Save CX
          mov    ax,dx                 ;Numerator
          xor    dx,dx                 ;Clear upper half
          mov    cx,10                 ;Divisor of 10
          div    cx                    ;Divide dx:ax by cx
          xchg   ax,dx                 ;Get quotient
          add    al,30h                ;Add 30H
          mov    [di],al               ;Put in buffer
          inc    di                    ;Next byte
          pop    cx                    ;Restore CX
          inc    cx                    ;Count the digit
          cmp    dx,0                  ;Done?
          jnz    DEC16OUT1

;-------------------
;Dump the buffer out
;-------------------

DEC16OUT2:
          dec    di                    ;Back up through the buffer
          mov    al,[di]               ;Get byte from buffer
          call   STDOUT                ;Send it out
          loop   DEC16OUT2
          pop    AX                    ;Restore registers
          pop    CX
          pop    DX
          pop    DI
          pop    DS
          ret                          ;Return

STDOUT: 
            push  dx
            mov   dl,al
            mov   ah,02     ;INT 21h function
            int   21h       ;print character
            pop   dx
            ret


;****************************************************************************

FIRST_MSG      db  'ออออออออออออออออออออออออออออออออ',13d,10d
               db  '      K”hntark',027h,'s  IDE-INFO      ',13d,10d
               db  '     Version 1.0  (C) 1993      ',13d,10d
               db  'ออออออออออออออออออออออออออออออออ',13d,10d,13d,10d,'$'

MSG1           db  13d,10d,'              General configuration: ','$'
MSG2           db  13d,10d,'                Number of cylinders: ','$'
MSG4           db  13d,10d,'                    Number of heads: ','$'
MSG5           db  13d,10d,'   # of unformatted bytes per track: ','$'
MSG6           db  13d,10d,'  # of unformatted bytes per sector: ','$'
MSG7           db  13d,10d,'           Number sectors per track: ','$'
MSG8           db  13d,10d,'                      Vendor unique: ','$'
MSG9           db  13d,10d,'                      Serial number: ','$'
MSG10          db  13d,10d,'                        Buffer type: ','$'
MSG11          db  13d,10d,'         Buffer size (in 512 bytes): ','$'
MSG12          db  13d,10d,'       # of ECC bytes R/W long cmds: ','$'
MSG13          db  13d,10d,'                  Firmware revision: ','$'
MSG14          db  13d,10d,'                       Model number: ','$'
MSG15          db  13d,10d,' # of sectors transferred/interrupt: ','$'
MSG16          db  13d,10d,'             Doubleword performance: ','$'
MSG17          db  13d,10d,'                       Capabilities: ','$'
MSG19          db  13d,10d,'PIO data transfer cycle timing mode: ','$'
MSG20          db  13d,10d,'DMA data transfer cycle timing mode: ','$'
MSG22          db  13d,10d,'             # of current cylinders: ','$'
MSG23          db  13d,10d,'                 # of current heads: ','$'
MSG24          db  13d,10d,'     # of current sectors per track: ','$'
MSG25          db  13d,10d,'        Current capacity in sectors: ','$'
MSG27          db  13d,10d,'Total # of user addressable sectors: ','$'
MSG28          db  13d,10d,'      Single word DMA transfer mode: ','$'
MSG29          db  13d,10d,'        Multiword DMA transfer mode: ','$'
MSG31          db  13d,10d,'                      Vendor unique: ','$'

MSG33          db  ' => Able to do Double word I/O','$'
MSG34          db  ' => NOT Able to do Double word I/O','$'                           

MSG35          db  13d,10d,' Hard sectored','$'                           
MSG36          db  13d,10d,' Soft sectored','$'                           
MSG37          db  13d,10d,' Not MFM encoded','$'                           

MSG38          db  13d,10d,' Head switch time > 15 microseconds','$'                           
MSG39          db  13d,10d,' Spindle motor control option implemented','$'                           
MSG40          db  13d,10d,' Fixed drive','$'                           
MSG41          db  13d,10d,' Removable cartridge drive','$'                           

MSG42          db  13d,10d,' Disk transfer rate <= 5Mbs','$'                           
MSG43          db  13d,10d,' Disk transfer rate > 5Mbs but <= 10Mbs','$'                           
MSG44          db  13d,10d,' Disk transfer rate > 10 Mbs','$'                           
MSG45          db  13d,10d,' Rotational speed tolerance is > 0,5%','$'                           

MSG46          db  13d,10d,' Data strobe offset option available','$'                           
MSG47          db  13d,10d,' Track offset option available','$'                           
MSG48          db  13d,10d,' Format speed tolerance gap required','$'                           

MSG49          db  13d,10d,' General configuration bit-significant information:'    
LINE:          db  13d,10d,'อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ','$'
MSG50          db  ' => R/W multiple commands not implemented','$'
MSG51          db  ' => # sectors transferred / interrupt','$'                           

MSG52          db  ' => Single Ported / Multisector','$'
MSG53          db  ' => Dual Ported / Multisector','$'                           
MSG54          db  ' => Dual Ported/Multisector/Caching','$'
MSG55          db  ' => Not specified','$'                           

ERROR_MSG     db   13d,10d,' More than 2 HD devices reported by BIOS','$'                           
;********************************************************************************

DATA_BUFFER:

General_configuration                 dw  0
Number_of_cylinders                   dw  0                                       
Reserved                              dw  0                                       
Number_of_heads                       dw  0                                       
Number_unformatted_bytes_per_track    dw  0
Number_unformatted_bytes_per_sector   dw  0
Number_sectors_per_track              dw  0
Vendor_unique1                        dw  0,0,0
Serial_number                         dw  10 dup (0) ;(20 ASCII characters, 0000h=not specified)         
Buffer_type                           dw  0
Buffer_size                           dw  0          ;in 512 byte increments (0000h=not specified)         
Num_ECC_bytes_read_write_long_cmds    dw  0          ;(0000h=not spec'd)  
Firmware_revision                     dw  4 dup (0)  ;(8 ASCII characters, 0000h=not specified)      
Model_number                          dw  20 dup (0) ;(40 ASCII characters, 0000h=not specified)          
Vendor_unique2                        dw  0          ;15-8  Vendor unique                                             
                                                     ;7-0  00h = Read/write multiple commands not implemented         
                                                     ;xxh = Maximum number of sectors that can be transferred    
                                                     ;      per interrupt on read and write multiple commands    
Doubleword_performance                dw  0          ;0000h = cannot perform doubleword I/O    Included for backwards  
                                                     ;0001h = can perform doubleword I/O       Compatible VU use       
Capabilities                          dw  0          ;15-10  0=reserved 
                                                     ;9  1=LBA supported 
                                                     ;8  1=DMA supported               
                                                     ;7- 0  Vendor unique                                
Reserved2                             dw  0                        
PIO_data_transfer_cycle_timing_mode   dw  0          ;15-8  PIO data transfer cycle timing mode 
                                                     ;7-0  Vendor unique
DMA_data_transfer_cycle_timing_mode   dw  0          ;15-8  DMA data transfer cycle timing mode
                                                     ;7-0  Vendor unique
Reserved3                             dw  0          ;15-1  Reserved                                                   
                                                     ;1=the fields reported in words 54-58 are valid
                                                     ;0=the fields reported in words 54-58 may be valid 
Number_of_current_cylinders           dw  0
Number_of_current_heads               dw  0
Number_of_current_sectors_per_track   dw  0
Current_capacity_in_sectors           dw  0,0
Reserved4                             dw  0          ;15-9  Reserved                                               
                                                     ;8  1 = Multiple sector setting is valid                      
                                                     ;7-0  xxh = Current setting for number of sectors that can be 
                                                     ;           transferred per interrupt on R/W multiple commands 
Total_number_user_addressable_sectors dw  0,0        ;(LBA mode only)
Single_word_DMA_transfer_mode         dw  0          ;15-8  Single word DMA transfer mode active    
                                                     ;7-0  Single word DMA transfer modes supported                 
Multiword_DMA_transfer_mode           dw  0          ;15-8  Multiword DMA transfer mode active      
                                                     ;7-0  Multiword DMA transfer modes supported          
Reserved5                             dw  64 dup (0) ;Reserved
Vendor_unique3                        dw  32 dup (0) ;Vendor unique
Reserved6                             dw  96 dup (0) ;Reserved

TBUFF                                 dd 0
;********************************************************************************

MAIN ENDS
     END START

;********************************************************************************

comment $

---------------------
Technical Information
---------------------

Identify drive Command

The Identify Drive command enables the host to receive parameter information
from the drive.  When the command is issued, the drive sets BSY, stores the
required parameter information in the sector buffer, sets DRQ, and generates
an interrupt.  The host then reads the information out of the sector buffer. 
The parameter words in the buffer have the arrangement and meanings defined
in Table 1.  All reserved bits or words shall be zero.



                     Table 1 - Identify drive information
;=======-==================================================================
;|  Word |                                                                  |
;|-------+------------------------------------------------------------------|
;|    0  | General configuration bit-significant information:               |
;|       |   15  0   reserved for non-magnetic drives                       |
;|       |   14  1=format speed tolerance gap required                      |
;|       |   13  1=track offset option available                            |
;|       |   12  1=data strobe offset option available                      |
;|       |   11  1=rotational speed tolerance is > 0,5%                     |
;|       |   10  1=disk transfer rate > 10 Mbs                              |
;|       |    9  1=disk transfer rate > 5Mbs but <= 10Mbs                   |
;|       |    8  1=disk transfer rate <= 5Mbs                               |
;|       |    7  1=removable cartridge drive                                |
;|       |    6  1=fixed drive                                              |
;|       |    5  1=spindle motor control option implemented                 |
;|       |    4  1=head switch time > 15 usec                               |
;|       |    3  1=not MFM encoded                                          |
;|       |    2  1=soft sectored                                            |
;|       |    1  1=hard sectored                                            |
;|       |    0  0=reserved                                                 |
;|    1  | Number of cylinders                                              |
;|    2  | Reserved                                                         |
;|    3  | Number of heads                                                  |
;|    4  | Number of unformatted bytes per track                            |
;|    5  | Number of unformatted bytes per sector                           |
;|    6  | Number of sectors per track                                      |
;|  7-9  | Vendor unique                                                    |
;| 10-19 | Serial number (20 ASCII characters, 0000h=not specified)         |
;|   20  | Buffer type                                                      |
;|   21  | Buffer size in 512 byte increments (0000h=not specified)         |
;|   22  | # of ECC bytes avail on read/write long cmds (0000h=not spec'd)  |
;| 23-26 | Firmware revision (8 ASCII characters, 0000h=not specified)      |
;| 27-46 | Model number (40 ASCII characters, 0000h=not specified)          |
;|   47  | 15-8  Vendor unique                                              |
;|       |  7-0  00h = Read/write multiple commands not implemented         |
;|       |       xxh = Maximum number of sectors that can be transferred    |
;|       |             per interrupt on read and write multiple commands    |
;|   48  | 0000h = cannot perform doubleword I/O    Included for backwards  |
;|       | 0001h = can perform doubleword I/O       Compatible VU use       |
;|   49  | Capabilities                                                     |
;|       | 15-10  0=reserved                                                |
;|       |     9  1=LBA supported                                           |
;|       |     8  1=DMA supported                                           |
;|       |  7- 0  Vendor unique                                             |
;|   50  | Reserved                                                         |
;|   51  | 15-8  PIO data transfer cycle timing mode                        |
;|       |  7-0  Vendor unique                                              |
;|   52  | 15-8  DMA data transfer cycle timing mode                        |
;|       |  7-0  Vendor unique                                              |
;|   53  | 15-1  Reserved                                                   |
;|       |    0  1=the fields reported in words 54-58 are valid             |
;|       |       0=the fields reported in words 54-58 may be valid          |
;|   54  | Number of current cylinders                                      |
;|   55  | Number of current heads                                          |
;|   56  | Number of current sectors per track                              |
;| 57-58 | Current capacity in sectors                                      |
;|   59  | 15-9  Reserved                                                   |
;|       |    8  1 = Multiple sector setting is valid                       |
;|       |  7-0  xxh = Current setting for number of sectors that can be    |
;|       |             transferred per interrupt on R/W multiple commands   |
;| 60-61 | Total number of user addressable sectors (LBA mode only)         |
;|   62  | 15-8  Single word DMA transfer mode active                       |
;|       |  7-0  Single word DMA transfer modes supported (see 11-3a)       |
;|   63  | 15-8  Multiword DMA transfer mode active                         |
;|       |  7-0  Multiword DMA transfer modes supported (see 11-3b)         |
;| 64-127| Reserved                                                         |
;|128-159| Vendor unique                                                    |
;|160-255| Reserved                                                         |
;==========================================================================

---------------------
Description of Fields
---------------------

---------------------------
Word 1: Number of cylinders
---------------------------

The number of user-addressable cylinders in the default translation mode.

---------------------------
Word 3: Number of heads
---------------------------

The number of user-addressable heads in the default translation mode.

---------------------------------------------
Word 4: Number of unformatted bytes per track
---------------------------------------------

The number of unformatted bytes per translated track in the default
translation mode.

----------------------------------------------
Word 5: Number of unformatted bytes per sector
----------------------------------------------

The number of unformatted bytes per sector in the default translation mode.

-----------------------------------
Word 6: Number of sectors per track
------------------------------------

The number of user-addressable sectors per track in the default translation
mode.

-------------------------
Word 10-19: Serial Number
-------------------------

The contents of this field are right justified and padded with spaces (20h).

--------------------
Word 20: Buffer Type
--------------------

The contents of the field are determined by the manufacturer.

      000h      =  not specified.
      0001h        =  a single ported single sector buffer which is not
                      capable of simultaneous data transfers to or from the
                      host and the disk.
      0002h     =  a dual ported multi-sector buffer capable of simultaneous
                   data transfers to or from the host and the disk.
      0003h     =  a dual ported multi-sector buffer capable of simultaneous
                   transfers with a read caching capability.
      0004-FFFFh   =  reserved

These codes are typically not used by the operating system, however, they are
useful for diagnostic programs which perform initialization routines e.g.  a
different interleave may be desirable for 0001h vs 0002h or 0003h.

--------------------------------------------------------
Word 22: ECC bytes available on read/write long commands 
--------------------------------------------------------

If the contents of this field are set to a value other than 4, the only way
to use this information is via the Set Features commands.

-----------------------------
Word 23-26: Firmware revision
-----------------------------

The contents of this field are left justified and padded with spaces (20h).

------------------------
Word 27-46: Model number
------------------------

The contents of this field are left justified and padded with spaces (20h).

--------------------------------------------
Word 51: PIO data transfer cycle timing mode
--------------------------------------------

N/A

--------------------------------------------
Word 52: DMA data transfer cycle timing mode
--------------------------------------------

N/A
The contents of this word shall be ignored if Words 62 or 63 are supported.

------------------------------------
Word 54: Number of current cylinders
-------------------------------------

The number of user-addressable cylinders in the current translation mode.

--------------------------------
Word 55: Number of current heads
--------------------------------

The number of user-addressable heads in the current translation mode.

--------------------------------------------
Word 56: Number of current sectors per track
--------------------------------------------

The number of user-addressable sectors per track in the current translation
mode.

---------------------------------------
Word 57-58: Current capacity in sectors
---------------------------------------

The current capacity in sectors excludes all sectors used for device-specific
purposes.  The number of sectors of available capacity may be calculated as: 
   (Number of current cylinders * Number of current heads * Number of current
   sectors per track)

--------------------------------
Word 59: Multiple sector setting
--------------------------------

If the valid bit is set, then bits 7-0 reflect the number of sectors currently
set to transfer on a Read or Write Multiple command.

----------------------------------------------------
Word 60-61: Total number of user addressable sectors
----------------------------------------------------

If the drive supports LBA Mode, these words reflect the total number of user
addressable sectors.  This value does not depend on the current drive
geometry.  If the drive does not support LBA mode, these words shall be set
to 0.

---------------------------------
Word 62: Single word DMA transfer
---------------------------------

The low order byte identifies by bit all of the Modes which are supported e.g. 
if Mode 0 is supported, bit 0 is set.  The high order byte contains a single
bit set to indicate which mode is active.

-------------------------------
Word 63: Multiword DMA transfer
-------------------------------

The low order byte identifies by bit all of the Modes which are supported e.g. 
if Mode 0 is supported, bit 0 is set.  The high order byte contains a single
bit set to indicate which mode is active.

$



