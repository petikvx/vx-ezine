
; Dynamic Huffman includes
;
; (c) 451 2002/03

SORT_LESS		equ	0
SORT_MORE		equ	1


tree_sorted	struc

		    sorted_sym		dw	?
		    sorted_count	dd      ?
		    sorted_l		dw      ?
		    sorted_r		dw      ?
		ends


tree_node	struc

		    sym         	dw	?
		    l           	dw	?
		    r           	dw	?
		ends


hfind		struc

	  	    hprefix 		db 33 dup (?)
		    hsize		dw	?				
		ends
