comment ■

Exe_Head.Inc, Exe2Com - Структура заголовка exe-файла.

//Scout [SPS] ■

exe_header	struc
exe_sig 	dw	?		; +00h
part_pag	dw	?		; +02h
page_cnt	dw	?		; +04h
relo_cnt	dw	?		; +06h
hdr_size	dw	?		; +08h
min_mem 	dw	?		; +0ah
max_mem 	dw	?		; +0ch
relo_ss 	dw	?		; +0eh
exe_sp		dw	?		; +10h
chk_sum 	dw	?		; +12h
exe_ip		dw	?		; +14h
relo_cs 	dw	?		; +16h
tabl_off	dw	?		; +18h
overlay 	dw	?		; +1ah
		ends
