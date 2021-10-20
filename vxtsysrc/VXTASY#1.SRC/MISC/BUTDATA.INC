; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; buttons data

b_ok	 db '	  OK	', 0
b_cancel db '	Cancel	', 0
b_help	 db '	 Help	', 0
b_length db $-offset b_help
b_shadow db 'ßßßßßßßßßßßß', 0
b_norm_attr db 01 shl 4 + 0Fh
b_sele_attr db 02 shl 4 + 0Fh
b_shad_attr db 07 shl 4 + 00h
b_current   dw 1
b_style     dw 0
b_pos       dw 0