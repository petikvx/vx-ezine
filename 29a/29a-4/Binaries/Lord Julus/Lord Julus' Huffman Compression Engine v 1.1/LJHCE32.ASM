
comment $

  ÄÄÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÄÄ

                 Lord Julus' Huffman Compression Engine V1.1

  ÄÄÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÄÄ

        Hello  and welcome to my very first compression engine demo. First, a
 few words about the demo itself. The demo part lies at the beginning of this
 source  code. To see the compression code you might skip this part. In order
 for  this  demo  to work you need to put a file called INPUT.DAT in the same
 directory  with  the  demo  executable.  This  is  the  file  which will get
 compressed.  In  the  first  part  of  the  demo  the file input.dat will be
 compressed  into  an  output  file called COMPRESS.DAT. After both files are
 closed, the second part of the demo starts. Here, the compress.dat file will
 be  opened as an input file and decompressed into a file called DECOMPR.DAT.
 This file should be exactly the same as the original input.dat. By comparing
 the  sizes  of  the compress.dat file and input.dat file you can compute the
 compression ratio.

        Now,   about  the  compression  algorithm  itself.  This  compression
 algorithm  follows  the exact definition of the Huffman codes. There are two
 procedures and a data area used here, like this:

  lj_huffman_compress    size   633 bytes  (compression routine)
  lj_huffman_decompress  size   429 bytes  (decompression routine)
  lj_huffman_data        size   5036 bytes (can be allocated dynamically)

        Both procedures have the same parameters:

        EDI = pointer to input buffer
        ESI = pointer to output buffer
        ECX = input data length

        The output for both procedures is the same:

        EAX = error number
        ECX = length of output buffer

        The compressed data has a special header, presented below in the data
 section,  which holds the length of the original data. By reading that value
 you  can  know  what  ammount of bytes is necessary for the output buffer at
 decompression. Here is the header of the compressed data:

     Offset  Name       Size        Explanation
     ---------------------------------------------------------
     0       sign        4          header signature ("LJ")
     4       ver         4          compressor version (1010h)
     8       orig_size   8          original file size
     16      comp_size   8          compressed file size
     24      file_crc    8          file CRC
     32      dic_size    4          dictionary size


        As  for  the  speed, regardless the size of the file which alters the
 speed  if the file is too big, because of the specific implementation of the
 Huffman  tree solving the compression algorithm works with the same speed no
 matter  what  file  we  are  working  on.  The  same  thing  applies  to the
 decompression  routine.  Again, the only think which lowers the speed is the
 length  of  the  file  and the speed is influenced by the machine's specific
 read  and  write  speed.  However, I have to say that this version is poorly
 optimized  for  speed.  I  have  to do some really optimization works on the
 decompression routine to make it faster...

        The  two  routines are thought as to be placeble in a self relocating
 code, which means that all variable addressings are done via a delta handle,
 which  is  held  by  the  EBP  register. So, if you want to use the routines
 outside  this  demo be sure to set the EBP register properly (this demo sets
 it to 0).

        So, as I said, the two procedures and the data (which they share) can
 be  taken  out of this demo and will work without any problems. Just be sure
 to  also  take  out the structures definitions. Note, also, that you can use
 only  the  structure  definitions  and  allocate  the  rest  of  the  memory
 dynamically.  This  is  another  black  mark  for  this version. In a future
 version  I  will  remove  all  data  definitions with a huge STRUC structure
 called HUFFMAN_DATA, and all the refferences to the memory will be done like
 this:  [ebp+<buffer_address>+<data  offset>. In this way you will be able to
 allocate dinamically all the data and then wipe them... As for now I suggest
 using all the data definitions as I use them.

        Finally here are the error messages returned by the two procedures in
 the EAX register:

   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
    lj_huffman_compress   ³ Error   ³  Reason
   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
                          ³ 0       ³  No error
                      (*) ³ 1       ³  Cannot write to output buffer
                      (*) ³ 2       ³  Cannot read until end of input buffer
                          ³ 3       ³  Result is equal or bigger than input
   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
    lj_huffman_decompress ³ Error   ³  Reason
   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ
                          ³ 0       ³  No error
                      (*) ³ 1       ³  Cannot write to output buffer
                      (*) ³ 2       ³  Cannot read until end of input buffer
                          ³ 3       ³  Invalid Huffman table
                          ³ 4       ³  Invalid Huffman code
                          ³ 5       ³  File CRC failed
   ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

        The  errors marked with (*) will only be returned if you turn the SEH
 protection on. The SEH protection can be removed by setting the SEH value to
 false. This will make the code smaller but the program will crash in case of
 a  general  fault  error. If the SEH is on when an error occurs, the process
 will  return  to  the  caller  with the specific error set. Please note that
 this  demo version does not contain a SEH handler within the compression and
 decompression  routines.  There is however a SEH handler protecting the demo
 part from unexpected errors.

        The CRC32 used is the widely know CRC32 formula. You can also set the
 CRC  calculation off to make the code smaller (in this case the error 5 will
 not be returned when decompressing and no CRC will be checked.)

 !!!!!! One important notice: as the compression engine works on the existing
 bytes,  you  must  be  *sure*  that the output buffer is filled with zeroes!
 Beware that the mapping of a file can sometimes get memory areas filled with
 junk when you want to create a mapping bigger than the size of the file...

        This  is  a  specific  Win32 application (the demo), but the routines
 themselfes  can  be  used  in  any 32bit kind of code. Please note that this
 being  a  Windows  application,  on  really  big  files  the  compression or
 decompression  algorithms  might take a little longer. In the next version I
 will add a time counter.

        And  as  a  final  note,  I  have to say that by applying the huffman
 algorithm  the compression ratio is not as good as one could expect. From my
 tests  I  obtained  compression  ratios  of  around 59%-70%, which is pretty
 lousy.  My  next project will be a LZ compression algorithm, as I think will
 be better.

        If  you  want  to  know  more  about  how  I  implemented the huffman
 algorithm search for my article on compression on my site:

        http:\\lordjulus.cjb.net

        Also,  for  any  bug  reports,  suggestions or anything else, you may
 write me here:

        lordjulus@geocities.com

        Now, peace and enjoy!!

                                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                                            ³    Lord Julus / 29A    ³Ü
                                            ³    - january 2000 -    ³Û
                                            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙÛ
                                              ßßßßßßßßßßßßßßßßßßßßßßßßß

  Compile:

        tasm32 -m -ml ljhce32
        tlink32 -Tpe -ap -c ljhce32,,,import32.lib
        pewrsec ljhce32.exe

        $

;ÄÄ´ LJHCE32 V.1.1 Demo ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.486p                                       ;
.model flat                                 ;
locals                                      ;
                                            ;
extrn ExitProcess:proc                      ;for demo only...
extrn WriteFile:proc                        ;
extrn CreateFileA:proc                      ;
extrn WriteFileA:proc                       ;
extrn CloseHandle:proc                      ;
extrn MapViewOfFile:proc                    ;
extrn CreateFileMappingA:proc               ;
extrn FlushViewOfFile:proc                  ;
extrn GetFileSize:proc                      ;
extrn GetLastError:proc                     ;
extrn SetFilePointer:proc                   ;
extrn SetEndOfFile:proc                     ;
extrn UnmapViewOfFile:proc                  ;
extrn MessageBoxA:proc                      ;
extrn GetStdHandle:proc                     ;
extrn lstrlen:proc                          ;
                                            ;
.data                                       ;
db 0                                        ;
                                            ;
.code                                       ;
                                            ;
main:                                       ;

;ÄÄ´ Demo part only ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄ´ Prepare the DEMO ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       push -11                             ;get the standard output handle
       call GetStdHandle                    ;
       mov dchandle, eax                    ;
                                            ;
       lea edi, str1                        ;
       call write_string                    ;
                                            ;
       lea eax, ExceptionExit               ; set up a SEH frame...
       push eax                             ;
       xor ebx, ebx                         ;
       push dword ptr fs:[ebx]              ;
       mov fs:[ebx], esp                    ;
                                            ;
       xor ebp, ebp                         ; our fake delta (take care!!!)

;ÄÄ´ First open the input file (for compression) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       push 0                               ; file attributes
       push 0                               ; ""
       push 3                               ; Open existing
       push 0                               ; Security option = default
       push 0                               ; File share
       push 80000000h or 40000000h          ; General write and read
       push offset input_file               ; pointer to filename
       call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov input_handle, eax                ;
                                            ;
       push offset input_size               ; get the input data size
       push input_handle                    ;
       call GetFileSize                     ;
       mov input_size, eax                  ;
                                            ;
       push 0                               ; filename handle = NULL
       mov eax, input_size                  ;
       add eax, 1000h                       ;
       push eax                             ; max size
       push 0                               ; min size (no need)
       push 4                               ; Page read & write
       push 0                               ; security attributes
       push input_handle                    ;
       Call CreateFileMappingA              ; create mapping
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_maphandle, eax             ;
                                            ;
       push input_size                      ; bytes to map
       push 0                               ; blah, blah, blah...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; map the file
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_mapaddress, eax            ; and save buffer address

;ÄÄ´ Open the output file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       push 0                               ; file attributes
       push 0                               ; ""
       push 2                               ; Create New File
       push 0                               ; Security option = default
       push 0                               ; File share
       push 80000000h or 40000000h          ; General write and read
       push offset output_file              ; pointer to filename
       Call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov output_handle, eax               ;
                                            ;
       push 0                               ; filename handle = NULL
       mov eax, input_size                  ;
       add eax, 1000h                       ;
       push eax                             ; max size
       push 0                               ; min size (no need)
       push 4                               ; Page read & write
       push 0                               ; security attributes
       push output_handle                   ;
       Call CreateFileMappingA              ; create it's mapping
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_maphandle, eax            ;
                                            ;
       push input_size                      ; bytes to map
       push 0                               ; blah, blah, blah...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; map the file!
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_mapaddress, eax           ;
                                            ;
       mov edi, eax                         ; be sure that the output
       mov eax, 0                           ; buffer is zeroed...
       mov ecx, input_size                  ;
       rep stosb                            ;
                                            ;
       lea edi, str2                        ;
       call write_string                    ;

;ÄÄ´ Now compress the data ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       mov edi, input_mapaddress            ; input data address
       mov esi, output_mapaddress           ; output data address
       mov ecx, input_size                  ; data length
       call lj_huffman_compress             ; compress!
       jc compression_error                 ;

;ÄÄ´ Close the input and output files ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       xor edx, edx                         ; compute the compression
       mov eax, compressed_size             ; ratio
       mov ecx, 100d                        ;
       mul ecx                              ;
       mov ecx, input_size                  ;
       idiv ecx                             ;
       push eax                             ;
       mov ecx, 10d                         ;
       xor edx, edx                         ;
       idiv ecx                             ;
       add al, '0'                          ;
       mov byte ptr [ratio+2], al           ;
       sub al, '0'                          ;
       xor edx, edx                         ;
       mul ecx                              ;
       xchg ebx, eax                        ;
       pop eax                              ;
       sub eax, ebx                         ;
       add al, '0'                          ;
       mov byte ptr [ratio+3], al           ;
                                            ;
close_files_1:                              ;
       push output_mapaddress               ; close map
       call UnmapViewOfFile                 ;
                                            ;
       push output_maphandle                ; close mapping object
       call CloseHandle                     ;
                                            ;
       push 0                               ;
       push 0                               ;
       push compressed_size                 ;
       push output_handle                   ;
       call SetFilePointer                  ;
                                            ;
       push output_handle                   ;
       call SetEndOfFile                    ;
                                            ;
       push output_handle                   ; close file
       call CloseHandle                     ;
                                            ;
       push input_mapaddress                ; close map
       call UnmapViewOfFile                 ;
                                            ;
       push input_maphandle                 ; close mapping object
       call CloseHandle                     ;
                                            ;
       push 0                               ;
       push 0                               ;
       push input_size                      ;
       push input_handle                    ;
       call SetFilePointer                  ;
                                            ;
       push input_handle                    ;
       call SetEndOfFile                    ;
                                            ;
       push input_handle                    ; close file
       call CloseHandle                     ;
                                            ;
       cmp fail, 1                          ;
       je quit                              ;
                                            ;
       lea edi, ratio                       ;
       call write_string                    ;
       lea edi, str4                        ;
       call write_string                    ;

;ÄÄ´ Second part of the demo ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄ´ First open the input file (for decompression) ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       push 0                               ; file attributes
       push 0                               ; ""
       push 3                               ; Open existing
       push 0                               ; Security option = default
       push 1                               ; File share for read
       push 80000000h or 40000000h          ; General write and read
       push offset output_file              ; pointer to filename
       call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov input_handle, eax                ;
                                            ;
       push offset input_size               ; get the input data size
       push input_handle                    ;
       call GetFileSize                     ;
       mov input_size, eax                  ;
                                            ;
       push 0                               ; filename handle = NULL
       push input_size                      ; max size
       push 0                               ; min size (no need)
       push 4                               ; Page read & write
       push 0                               ; security attributes
       push input_handle                    ;
       Call CreateFileMappingA              ; create mapping
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_maphandle, eax            ;
                                            ;
       push input_size                      ; bytes to map
       push 0                               ; blah, blah, blah...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; map the file
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov input_mapaddress, eax            ; and save buffer address
                                            ;
       cmp word ptr [eax.sign], 'JL'        ; check the input buffer for
       jne quit                             ; correctness
       cmp word ptr [eax.ver], 1010h        ; check compressor version
       jne quit                             ;
       mov ebx, [eax.orig_size]             ; get the size of original
       mov out_size, ebx                    ; file

;ÄÄ´ Open the output file ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       push 0                               ; file attributes
       push 0                               ; ""
       push 2                               ; Create New File
       push 0                               ; Security option = default
       push 1                               ; File share for read
       push 80000000h or 40000000h          ; General write and read
       push offset output2_file             ; pointer to filename
       Call CreateFileA                     ;
                                            ;
       cmp eax, -1                          ;
       je quit                              ;
       mov output_handle, eax               ;
                                            ;
       mov ebx, out_size                    ;
       add ebx, 100h                        ;
       push 0                               ; filename handle = NULL
       push ebx                             ; max size
       push 0                               ; min size (no need)
       push 4                               ; Page read & write
       push 0                               ; security attributes
       push output_handle                   ;
       Call CreateFileMappingA              ; create it's mapping
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_maphandle, eax            ;
                                            ;
       push ebx                             ; bytes to map
       push 0                               ; blah, blah, blah...
       push 0                               ;
       push 2                               ; File Map Write Mode
       push eax                             ; File Map Handle
       Call MapViewOfFile                   ; map the file!
                                            ;
       or eax, eax                          ;
       jz quit                              ;
       mov output_mapaddress, eax           ;
                                            ;
       lea edi, str3                        ;
       call write_string                    ;

;ÄÄ´ Now decompress the data ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

       mov edi, input_mapaddress            ; input data address
       mov esi, output_mapaddress           ; output data address
       mov ecx, out_size                    ; data length
       call lj_huffman_decompress           ; decompress!
       jc decompression_error               ;

;ÄÄ´ Close the input and output files ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

close_files_2:                              ;
       push output_mapaddress               ; close map
       call UnmapViewOfFile                 ;
                                            ;
       push output_maphandle                ; close mapping object
       call CloseHandle                     ;
                                            ;
       push 0                               ;
       push 0                               ;
       push out_size                        ;
       push output_handle                   ;
       call SetFilePointer                  ;
                                            ;
       push output_handle                   ;
       call SetEndOfFile                    ;
                                            ;
       push output_handle                   ; close file
       call CloseHandle                     ;
                                            ;
       push input_mapaddress                ; close map
       call UnmapViewOfFile                 ;
                                            ;
       push input_maphandle                 ; close mapping object
       call CloseHandle                     ;
                                            ;
       push input_handle                    ; close file
       call CloseHandle                     ;
                                            ;
       cmp fail, 1                          ;
       je quit                              ;
                                            ;
       lea edi, str4                        ;
       call write_string                    ;
                                            ;
quit:                                       ;
       lea edi, str5                        ;
       call write_string                    ;
                                            ;
       push 0                               ; exit
       call ExitProcess                     ;
                                            ;
compression_error:                          ;
       cmp eax, 3                           ;
       jne not__1                           ;
       lea edi, compe1                      ;
       call write_string                    ;
                                            ;
not__1:                                     ;
       mov fail, 1                          ;
       jmp close_files_1                    ;
                                            ;
decompression_error:                        ;
       cmp eax, 3                           ;
       jne not__2                           ;
       lea edi, decoe1                      ;
       call write_string                    ;
       jmp not__4                           ;
                                            ;
not__2:                                     ;
       cmp eax, 4                           ;
       jne not__3                           ;
       lea edi, decoe2                      ;
       call write_string                    ;
       jmp not__4                           ;
                                            ;
not__3:                                     ;
       cmp eax, 5                           ;
       jne not__4                           ;
       lea edi, decoe3                      ;
       call write_string                    ;
                                            ;
not__4:                                     ;
       mov fail, 1                          ;
       jmp close_files_2                    ;
                                            ;
write_string:                               ;write string to dos screen
; EDI = pointer to ACIIZ string             ;
                                            ;
       push edi                             ;
       call lstrlen                         ;
                                            ;
       push 0                               ;
       push offset nob                      ;
       push eax                             ;
       push edi                             ;
       push dchandle                        ;
       call WriteFile                       ;
       ret                                  ;
                                            ;
ExceptionExit:                              ;
       mov esp, [esp+8]                     ;if some GPF occured...
       pop dword ptr fs:[0]                 ;
       add esp, 4                           ;
       lea edi, str6                        ;
       call write_string                    ;
       jmp quit                             ;

str1   db 10,13
       db 'LJHCE32 V1.0           (c) Lord Julus / 29A - January 2000',10,13
       db '----------------------------------------------------------',10,13
       db '------------------------- DEMO ---------------------------',10,13
       db '----------------------------------------------------------',10,13,0
str2   db 'Compressing (to file compress.dat)  - Please wait... ',0
str3   db 'Decompressing (to file decompr.dat) - Please wait... ',0
str4   db 'Done!',13,10, 0
str5   db 10,13,'Demo over !',10,13,0
str6   db 10,13,10,13, 'Demo will stop due to an exception error!',10,13,0
compe1 db 10,13,'Compression error #3: Result is bigger or equal.',10,13,0
decoe1 db 10,13,'Decompression error #3: Invalid Huffman table.',10,13,0
decoe2 db 10,13,'Decompression error #4: Invalid Huffman code.',10,13,0
decoe3 db 10,13,'Decompression error #5: File CRC failed.',10,13,0
ratio  db ' (  %) ',0

fail              dd 0                      ; demo specific data
nob               dd 0                      ;
dchandle          dd 0                      ;
output_handle     dd 0                      ;
output_maphandle  dd 0                      ;
output_mapaddress dd 0                      ;
input_handle      dd 0                      ;
input_maphandle   dd 0                      ;
input_mapaddress  dd 0                      ;
input_size        dd 0                      ;
out_size          dd 0                      ;
output_file       db 'compress.dat', 0      ;
input_file        db 'input.dat', 0         ;
output2_file      db 'decompr.dat', 0       ;

;ÍÍ( Lord Julus' Huffman Compression Engine )ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

;ÄÄ´ Compression engine data ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

 TRUE   = 1                                 ;
 FALSE  = 0                                 ;
                                            ;
;SEH    = TRUE                              ; Trap errors? (N/A)
 CRC    = TRUE                              ; Calculate CRC32?
                                            ;
data_begin label                            ; data starts here
                                            ;
element struc                               ;this is the structure for
        value dd ?                          ;the branch of the huffman tree
        start dd ?                          ;
element ends                                ;
element_size equ size element               ;
                                            ;
list struc                                  ;the character list structure
     char db ?                              ;
     next dd ?                              ;
list ends                                   ;
list_size equ size list                     ;
                                            ;
huffman element 256 dup(<0>)                ;the huffman tree
                                            ;
huffman_code struc                          ;the huffman codes go in
             code     dw ?                  ;this kind of structure...
             huff_len dw 0                  ;
huffman_code ends                           ;
huffman_size equ size huffman_code          ;
                                            ;
codes huffman_code 256 dup(<0>)             ;...here
                                            ;
chars label                                 ;the character set
I=0                                         ;initial definition
REPT 256                                    ;
   db I                                     ;
   dd 0                                     ;
   I=I+1                                    ;
ENDM                                        ;
                                            ;
header struc                                ;compressed data header
       sign            dw 0                 ;header signature
       ver             dw 0                 ;compressor version
       orig_size       dd 0                 ;original file size
       comp_size       dd 0                 ;compressed file size
       file_crc        dd 0                 ;file CRC
       dic_size        dw 0                 ;dictionary size
header ends                                 ;
header_size equ size header                 ;
                                            ;
huffman_header header <'JL',1010h,0,0,0,0>  ;initial header fill up
                                            ;
PUSH_POP STRUCT                             ;
         pop_edi dd ?                       ;helps us to pop stuff...
         pop_esi dd ?                       ;
         pop_ebp dd ?                       ;
         pop_esp dd ?                       ;
         pop_ebx dd ?                       ;
         pop_edx dd ?                       ;
         pop_ecx dd ?                       ;
         pop_eax dd ?                       ;
PUSH_POP ENDS                               ;
                                            ;
depth           dd 0                        ;depth of huffman tree
current_depth   dd 0                        ;
compressed_size dd 0                        ;size of compressed data
buffer          dd 0                        ;input data save area
output_buffer   dd 0                        ;output data save area
length          dd 0                        ;input data size
_100            dd 100d                     ;
alreadydone     db 0                        ;
killed          db 0                        ;
temp            dw 0                        ;
data_end label                              ;

;ÄÄ´ Compression routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

lj_huffman_compress proc near               ;
                                            ;
; Input:                                    ;
; EDI = pointer to data to compress         ;
; ESI = pointer to output buffer            ;
; ECX = length of data to compress          ;
;                                           ;
; Output:                                   ;
; If no error: CF clear                     ;
;              ECX = compressed data size   ;
; If error:    CF set                       ;
;              EAX = error code             ;
                                            ;
       pusha                                ;
       mov [ebp+length], ecx                ;first save the data here
       mov [ebp+buffer], edi                ;
       mov [ebp+output_buffer], esi         ;
                                            ;
       lea edi, [ebp+huffman]               ;appeareances we have for
       mov esi, [ebp+buffer]                ;each character...
                                            ;
fill_array:                                 ;
       xor eax, eax                         ;
       lodsb                                ;
       shl eax, 3                           ;
       inc dword ptr [edi+eax]              ;...and mark it in the list
       loop fill_array                      ;
                                            ;
       mov ecx, 256                         ;then we must init the
       push ecx                             ;
       lea edi, [ebp+huffman]               ;matrix and link each position
       lea esi, [ebp+chars]                 ;with a character in the
                                            ;characters' list
init_array:                                 ;
       fild dword ptr [edi.value]           ;transform the number of
       fild dword ptr [ebp+_100]            ;appearances into a floating
       fmul                                 ;percent relative to the
       fild dword ptr [ebp+length]          ;length
       fdiv                                 ;
       fstp dword ptr [edi.value]           ;
                                            ;
       mov [edi.start], esi                 ;this points to the character #
       mov [esi.next], 0                    ;no next character...
       add edi, element_size                ;get next...
       add esi, list_size                   ;
       loop init_array                      ;
                                            ;
       pop ecx                              ;now order the list
       push ecx                             ;
       call do_bubble                       ;descending.
                                            ;
       pop ecx                              ;now check out the depth of
       lea edi, [ebp+huffman]               ;our algorithm by scanning
       xor ebx, ebx                         ;until the zeroed value
                                            ;
scan:                                       ;
       cmp [edi.value], 0                   ;
       je ok_length                         ;
       add edi, element_size                ;
       inc ebx                              ;
       loop scan                            ;
                                            ;
ok_length:                                  ;
       mov [ebp+depth], ebx                 ;save depth.
       mov ecx, ebx                         ;
       mov [ebp+current_depth], ecx         ;
                                            ;
start_chaining_branches:                    ;now we start to join the
       lea edi, [ebp+huffman]               ;branches...
       dec ecx                              ;first locate the last value
       mov eax, element_size                ;pointed by EDI
       xor edx, edx                         ;and the before last
       mul ecx                              ;pointed by EBX
       add edi, eax                         ;
       mov ebx, edi                         ;
       sub edi, element_size                ;
                                            ;
       pusha                                ;
       mov edx, [edi.start]                 ;set the bit 1 for the chars in
       xor eax, eax                         ;the higher branch
       inc eax                              ;
       call set_up                          ;
       mov edx, [ebx.start]                 ;and bit 0 for the chars in the
       xor eax, eax                         ;lower branch
       call set_up                          ;
       popa                                 ;
       jmp done_setting                     ;
                                            ;
set_up:                                     ;
       lea esi, [ebp+codes]                 ;go to the codes array
       push eax                             ;
       xor eax, eax                         ;
       mov al, [edx.char]                   ;locate the character
       shl eax, 2                           ;
       add esi, eax                         ;
       inc [esi.huff_len]                   ;and increase the code length
       pop eax                              ;now go and set the specific
       push eax                             ;bit there...
                                            ;
       shl ax, 15                           ;
       shr word ptr [esi.code], 1           ;
       or word ptr [esi.code], ax           ;...done...
                                            ;
       mov edx, dword ptr [edx.next]        ;any more characters in the list?
       pop eax                              ;
       or edx, edx                          ;
       jnz set_up                           ;
       ret                                  ;
                                            ;
done_setting:                               ;
       fld dword ptr [edi.value]            ;add the last two values
       fld dword ptr [ebx.value]            ;
       fadd                                 ;
       fstp dword ptr [edi.value]           ;
                                            ;
       mov eax, [ebx.start]                 ;locate the pointers to the
       mov edx, [edi.start]                 ;lists to join them...
                                            ;
do_it_again:                                ;
       cmp dword ptr [edx.next], 0          ;find the end of the first list
       je ok_zero                           ;
       mov edx, dword ptr [edx.next]        ;
       jmp do_it_again                      ;
                                            ;
ok_zero:                                    ;
       mov dword ptr [edx.next], eax        ;and join there the second list.
                                            ;
       mov [ebp+current_depth], ecx         ;save the current depth
       dec ecx                              ;
       jz unchain_my_heart                  ;
       inc ecx                              ;
       call do_bubble                       ;rearrange...
       jmp start_chaining_branches          ;
                                            ;
unchain_my_heart:                           ;
       mov edi, [ebp+output_buffer]         ;finished generating...
       lea esi, [ebp+huffman_header]        ;let's output the file header
       mov ecx, header_size                 ;to the output buffer
       rep movsb                            ;
                                            ;
       mov ecx, 256                         ;and now let's output our
       lea esi, [ebp+codes]                 ;dictionary definition codes
       xor ebx, ebx                         ;
                                            ;
put:                                        ;
       cmp [esi.huff_len], 0                ;check for non zeroes
       je go_on                             ;
       inc ebx                              ;
       mov eax, esi                         ;get the ascii character
       sub eax, offset codes                ;..hmmm... ;-<
       sub eax, ebp                         ;
       shr eax, 2                           ;
       stosb                                ;store it
       mov ax, [esi.huff_len]               ;get the length
       stosb                                ;store it
       mov ax, [esi.code]                   ;get the code
       cmp byte ptr [esi.huff_len], 8       ;
       ja store_word                        ;
       xchg ah, al                          ;if so, store byte
       stosb                                ;
       jmp go_on                            ;
                                            ;
store_word:                                 ;
       stosw                                ;otherwise store word
                                            ;
go_on:                                      ;
       add esi, 4                           ;get next
       loop put                             ;
                                            ;
       mov eax, [ebp+output_buffer]         ;mark dictionary size
       mov [eax.dic_size], bx               ;
                                            ;
       lea esi, [ebp+codes]                 ;and now prepare to compress...
       mov edx, [ebp+buffer]                ;
       mov ebx, [ebp+length]                ;
       mov ch, 16                           ;
                                            ;
do_it:                                      ;
       push ebx                             ;
       xor eax, eax                         ;
       mov al, byte ptr [edx]               ;get a byte
       inc edx                              ;
       shl eax, 2                           ;
       mov bx, word ptr [esi+eax.huff_len]  ;get it's code length
       mov ax, word ptr [esi+eax.value]     ;get it's code
                                            ;
       cmp ch, bl                           ;and do all the stuff to fill it
       jbe renumber                         ;in...
                                            ;
       mov cl, 16                           ;
       sub cl, ch                           ;
       shr ax, cl                           ;
       xchg ah, al                          ;
       or word ptr [edi], ax                ;
       sub ch, bl                           ;
       jnz out                              ;
       mov ch, 16                           ;
       inc edi                              ;
                                            ;
renumber:                                   ;
       mov cl, 16                           ;
       sub cl, ch                           ;
       push ax                              ;
       shr ax, cl                           ;
       xchg ah, al                          ;
       or word ptr [edi], ax                ;
       inc edi                              ;
       inc edi                              ;
       pop ax                               ;
       xchg ch, cl                          ;
       shl ax, cl                           ;
       xchg ah, al                          ;
       or word ptr [edi], ax                ;
       mov bh, bl                           ;
       sub bh, cl                           ;
       mov ch, 16                           ;
       sub ch, bh                           ;
                                            ;
out:                                        ;
       pop ebx                              ;
       push edi                             ;
       sub edi, [ebp+output_buffer]         ;
       cmp edi, [ebp+length]                ;
       jb no_error_yet                      ;
       pop edi                              ;
       jae error_in_compression             ;
                                            ;
no_error_yet:                               ;
       pop edi                              ;
       dec ebx                              ;
       jnz do_it                            ;
       inc edi                              ;
       or byte ptr [edi], 0                 ;
       jz no_change_                        ;
       inc edi                              ;
                                            ;
no_change_:                                 ;
       mov eax, [ebp+output_buffer]         ;
       mov ebx, [ebp+input_size]            ;mark original data size
       mov [eax.orig_size], ebx             ;
       sub edi, eax                         ;
       mov [ebp+compressed_size], edi       ;
       sub edi, header_size                 ;
       mov [eax.comp_size], edi             ;mark the compressed data size
                                            ;
       IF CRC                               ;If CRC calculation is on
       push eax                             ;compute the CRC of the
       mov esi, [ebp+buffer]                ;non-compressed data.
       mov edi, [ebp+length]                ;
       call CRC32                           ;
       xchg eax, ebx                        ;
       pop eax                              ;
       mov [eax.file_crc], ebx              ;
       ELSE                                 ;
       ENDIF                                ;
                                            ;
       mov ecx, [ebp+compressed_size]       ;
       clc                                  ;
                                            ;
return__:                                   ;
       popa                                 ;
       ret                                  ;
                                            ;
error_in_compression:                       ;
       mov [esp.pop_eax], 3                 ;mark the error
       xor ecx, ecx                         ;
       stc                                  ;
       jmp return__                         ;
                                            ;
do_bubble:                                  ;here we sort our huffman
       push ecx                             ;tree descending
       lea edi, [ebp+huffman]               ;
       lea esi, [ebp+chars]                 ;
                                            ;
bubble:                                     ;
       finit                                ;init the copro
       push ecx                             ;start to bubble
       dec ecx                              ;
       jz finished                          ;
       mov ebx, edi                         ;
       add ebx, element_size                ;
                                            ;
bubble2:                                    ;
       fld dword ptr [edi.value]            ;take first value
       fld dword ptr [ebx.value]            ;take next value
       fcompp                               ;compare them
       fstsw ax                             ;get status word
       sahf                                 ;load flags with it
       jc no_change                         ;is it bigger?
                                            ;
       mov eax, [edi.value]                 ;if not, change it with the
       xchg [ebx.value], eax                ;bigger one...
       mov [edi.value], eax                 ;
       mov eax, [edi.start]                 ;
       xchg [ebx.start], eax                ;
       mov [edi.start], eax                 ;
                                            ;
no_change:                                  ;
       add ebx, element_size                ;
       loop bubble2                         ;
                                            ;
       pop ecx                              ;
       add edi, element_size                ;
       loop bubble                          ;
       jmp done                             ;until the end...
                                            ;
finished:                                   ;
       pop ecx                              ;
                                            ;
done:                                       ;
       pop ecx                              ;
       ret                                  ;
lj_huffman_compress endp                    ;

;ÄÄ´ End of compression routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄ´ Decompression routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

lj_huffman_decompress proc near             ;
                                            ;
; Input:                                    ;
; EDI = pointer to data to decompress       ;
; ESI = pointer to output buffer            ;
; ECX = length of data to decompress        ;
;                                           ;
; Output: CF set if fail, CF clear if ok    ;
                                            ;
       pushad                               ;
       mov [ebp+buffer], edi                ;save the data
       mov [ebp+output_buffer], esi         ;
       mov [ebp+length], ecx                ;
                                            ;
       cmp word ptr [edi.sign], 'JL'        ;verify header
       jne error_1                          ;
       cmp word ptr [edi.ver], 1010h        ;verify version
       jne error_2                          ;
       xor ecx, ecx                         ;
       mov cx, [edi.dic_size]               ;get dictionary size
       mov [ebp+temp], cx                   ;
       mov edx, [edi.orig_size]             ;get original file size
       mov [ebp+current_depth], edx         ;
       mov eax, [edi.file_crc]              ;
       mov [ebp+depth], eax                 ;
                                            ;
       mov esi, edi                         ;prepare to read the dictionary
       add esi, header_size                 ;
       lea edi, [ebp+codes]                 ;
                                            ;
read_dictionary:                            ;
       xor ebx, ebx                         ;
       xor eax, eax                         ;
       lodsb                                ;read character
       mov ah, al                           ;
       lodsb                                ;read code length
       mov byte ptr [edi.huff_len], al      ;store them
       mov byte ptr [edi.huff_len+1], ah    ;
       cmp al, 16                           ;bad table?
       ja error_2                           ;
       cmp al, 8                            ;is it bigger then 8 bits?
       ja get_word                          ;
       lodsb                                ;
       xor ah, ah                           ;
       xchg ah, al                          ;
       jmp put_it                           ;
                                            ;
get_word:                                   ;
       lodsw                                ;
                                            ;
put_it:                                     ;
       mov [edi.code], ax                   ;
       add edi, huffman_size                ;get next...
       loop read_dictionary                 ;
                                            ;
       mov edi, [ebp+output_buffer]         ;start to decompress
       mov [ebp+alreadydone], 0             ;
                                            ;
       lodsw                                ;first code
       xchg ah, al                          ;
       jmp compute_code                     ;
                                            ;
decompress_loop:                            ;
       mov bx, word ptr [esi]               ;next word
       xchg bh, bl                          ;how much of it?
       mov cl, [ebp+alreadydone]            ;
       cmp cl, 16                           ;
       je restore                           ;
       shl bx, cl                           ;
                                            ;
do:                                         ;
       xor ecx, ecx                         ;
       mov cl, [ebp+killed]                 ;
                                            ;
bit_bit:                                    ;
       push bx                              ;not store the new bits on
       and bx, 8000h                        ;the current word
       rol bx, cl                           ;
       or ax, bx                            ;
       pop bx                               ;
       shl bx, 1                            ;
       inc [ebp+alreadydone]                ;
       cmp [ebp+alreadydone], 16            ;
       je reached_end                       ;
                                            ;
loop_again:                                 ;
       loop bit_bit                         ;
                                            ;
       jmp compute_code                     ;
                                            ;
reached_end:                                ;
       call reset                           ;
       jmp loop_again                       ;
                                            ;
restore:                                    ;
       call reset                           ;
       jmp do                               ;
                                            ;
reset:                                      ;
       add esi, 2                           ;
       mov bx, word ptr [esi]               ;
       xchg bh, bl                          ;
       mov [ebp+alreadydone], 0             ;
       ret                                  ;
                                            ;
compute_code:                               ;
       push eax                             ;now compute the code
       call compare_codes                   ;
       or ebx, ebx                          ;wrong code?
       jnz ok_3                             ;
                                            ;
       pop eax                              ;
       jmp error_3                          ;
                                            ;
ok_3:                                       ;
       stosb                                ;store the character
       pop eax                              ;
       dec edx                              ;
       jz no_error                          ;finished?
                                            ;
       mov cl, bl                           ;
       shl ax, cl                           ;
       mov [ebp+killed], cl                 ;
       jmp decompress_loop                  ;
                                            ;
error_1:                                    ;
       mov [esp.pop_eax], 5                 ;
       stc                                  ;
       jmp return_                          ;
                                            ;
error_2:                                    ;
       mov [esp.pop_eax], 3                 ;
       stc                                  ;
       jmp return_                          ;
                                            ;
error_3:                                    ;
       mov [esp.pop_eax], 4                 ;
       stc                                  ;
       jmp return_                          ;
                                            ;
no_error:                                   ;
       IF CRC                               ;
       mov esi, [ebp+output_buffer]         ;
       mov edi, [ebp+current_depth]         ;
       call CRC32                           ;
       cmp eax, [ebp+depth]                 ;
       jne error_1                          ;
       ELSE                                 ;
       ENDIF                                ;
       clc                                  ;
                                            ;
return_:                                    ;
       popad                                ;
       ret                                  ;
                                            ;
compare_codes:                              ;this routine should be
; AX = code to compare                      ;optimized for speed...
; Returns: EAX = decompressed character     ;
;          EBX = length of found code       ;
;          CF clear if ok, CF set if not    ;
                                            ;
       push edi                             ;save the regs
       push ecx                             ;
       push edx                             ;
                                            ;
       lea ebx, [ebp+codes]                 ;point the codes
       xor ecx, ecx                         ;
       mov cx, [ebp+temp]                   ;dictionary size
                                            ;
compare_loop:                               ;
       cmp [ebx.huff_len], 0                ;
       je not_good                          ;
                                            ;
       push ecx                             ;
       xor ecx, ecx                         ;
                                            ;
       mov dx, [ebx.code]                   ;get a code
       mov di, 8000h                        ;bit separator
       xor cx, cx                           ;
       mov cl, byte ptr [ebx.huff_len]      ;get length
                                            ;
check_bit:                                  ;
       push eax                             ;
       push edx                             ;
       and ax, di                           ;separate the bit
       and dx, di                           ; "        "   "
       cmp ax, dx                           ;compare the bit...
       jne not_equal                        ;
                                            ;
       pop edx                              ;
       pop eax                              ;
       shr di, 1                            ;next bit position
       loop check_bit                       ;
       jmp good                             ;
                                            ;
not_equal:                                  ;
       pop edx                              ;restore the registers
       pop eax                              ;
       pop ecx                              ;
                                            ;
not_good:                                   ;
       add ebx, huffman_size                ;next code
       dec ecx                              ;
       jns compare_loop                     ;
       jmp not_good_at_all                  ;
                                            ;
good:                                       ;found the code
       pop ecx                              ;
       xor eax, eax                         ;
       mov al, byte ptr [ebx.huff_len+1]    ;get the character
       mov bx, [ebx.huff_len]               ;
       and ebx, 000000FFh                   ;and it's length
       jmp return                           ;
                                            ;
not_good_at_all:                            ;
       xor ebx, ebx                         ;code not found
                                            ;
return:                                     ;
       pop edx                              ;
       pop ecx                              ;
       pop edi                              ;
       ret                                  ;
lj_huffman_decompress endp                  ;

;ÄÄ´ End of decompression routine ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;ÄÄ´ Additional usefull code ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

IF CRC                                      ;
CRC32 proc near                             ;
; ESI = address to CRC from                 ;
; EDI = length to CRC32                     ;
; Returns EAX = CRC32                       ;
;                                           ;
; Credits for this routine go to Vecna      ;
                                            ;
       cld                                  ;
       xor ecx, ecx                         ;
       dec ecx                              ;
       mov edx, ecx                         ;
       push ebx                             ;
                                            ;
nextbyteCRC:                                ;
       xor eax, eax                         ;
       xor ebx, ebx                         ;
       lodsb                                ;
       xor al, cl                           ;
       mov cl, ch                           ;
       mov ch, dl                           ;
       mov dl, dh                           ;
       mov dh, 8                            ;
                                            ;
nextbitCRC:                                 ;
       shr bx, 1                            ;
       rcr ax, 1                            ;
       jnc noCRC                            ;
       xor ax, 08320h                       ;
       xor bx, 0EDB8h                       ;
                                            ;
noCRC:                                      ;
       dec dh                               ;
       jnz nextbitCRC                       ;
       xor ecx, eax                         ;
       xor edx, ebx                         ;
       dec edi                              ;
       jnz nextbyteCRC                      ;
       pop ebx                              ;
       not edx                              ;
       not ecx                              ;
       mov eax, edx                         ;
       rol eax, 16                          ;
       mov ax, cx                           ;
       ret                                  ;
CRC32 endp                                  ;
ELSE                                        ;
ENDIF                                       ;

;ÍÍ( Lord Julus' Huffman Compression Engine )ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ

end main                                    ;
end                                         ;

;ÄÄ´ End of demo ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
