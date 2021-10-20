; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; windows data...

w_l_u db 'Ï'	;
w_r_u db 'Ğ'	;
w_l_d db 'Ñ'	;
w_r_d db 'Ò'	;
w_v_l db 'Ó'	;
w_v_r db 'Ô'	;
w_h_u db 'Ö'	;
w_h_d db 'Õ'	;
w_head db 'Û'	;

w_x1 db 0
w_x2 db 0
w_y1 db 0
w_y2 db 0
wintitle_attr db 0

windows label

; Help window for menu browser

;	  nr, x1, y1, x2, y2, color attr, ...

	db 1, 5, 4, 73, 22, 03 shl 4 + 0Fh
	db 03h shl 4 + 0fh
	db "	  Help	   ", 0
	db 03 shl 4 + 0fh
db "		 This is the quick refference help	     ", 0
db "							     ", 0
db "		    Up/Down - Move up or down the popup      ", 0
db "		 Left/Right - Move left or right on the menu ", 0
db "	  Page Up/Page Down - Top/Bottom of popup	     ", 0
db "		   Home/End - First/Last Menu		     ", 0
db "			Esc - Close/Exit		     ", 0
db "		      Enter - Select menu/popup 	     ", 0
db "   Alt+hotkey - select menu / hotkey - select popup item ", 0
db "   F1 - Help    /	 F8 - Music ON/OFF   /	 F4 - Boss   ", 0
db "   Alt-X - Exit Boss Screen  /  TAB - choose crt. button ", 0
db "   You can also use the mouse to select or open popups   ", 0
db " ",0
db 0ffh

; Not implemented yet window

	db 2, 18, 7, 62, 14, 04 shl 4 + 0Fh
	db 04h shl 4 + 0fh
	db "	Warning    ", 0
	db 04 shl 4 + 0fh
db "Not implemented yet !! ", 0
db 0ffh

; Help window for text viewr

	db 3, 5, 4, 73, 22, 03 shl 4 + 0Fh
	db 03h shl 4 + 0fh
	db "	  Help	   ", 0
	db 03 shl 4 + 0fh
db "		 This is the quick refference help	     ", 0
db "							     ", 0
db "		     Arrow Up - Move up the text	     ", 0
db "		   Arrow Down - Move down the text	     ", 0
db "		   Arrow Left - Move left the text	     ", 0
db "		  Arrow Right - Move right the text	     ", 0
db "	    Page Up/Page Down - Top/Bottom of text	     ", 0
db "	     F4 - Boss screen / Alt-X - Exit Boss screen     ", 0
db "	   ESC/ENTER - Return / F8 - Music ON/OFF	     ", 0
db "  F7  - Change text color / Shift+F7 - Default text color", 0
db "  You can use the mouse to scroll using the scroll bar   ", 0
db "  and you can hit the return button to go back to menu   ", 0
db " ",0
db 0ffh

db 0ffh



windows_end label


