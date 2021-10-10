;=============================================================================
.xlist
;-----------------------------------------------------------------------------
dwo             equ     dword ptr
qwo             equ     qword ptr
wo              equ     word ptr
by              equ     byte ptr
ofs             equ     offset
L               equ     <large>
S               equ     <small>
W?              equ     1111h
BIT             equ     1 SHL

;-----------------------------------------------------------------------------
stDWORD         STRUC
		wLO     dw      ?
		wHI     dw      ?
stDWORD         ENDS

stWORD          STRUC
		bLO     db      ?
		bHI     db      ?
stWORD          ENDS

;-----------------------------------------------------------------------------
STOW            MACRO   xx
		mov     ax,xx
		stosw
		ENDM

STOB            MACRO   xx
   	        mov     al,xx
		stosb
		ENDM

STOD            MACRO   xx
                mov     eax,xx
                stosd
                ENDM

OUTB            MACRO   p,v
		mov     al, &v
		out     &p, al
		ENDM

OUTW            MACRO   p,v
		mov     ax, &v
		out     &p, ax
		ENDM

OUTD            MACRO   p,v
                mov     eax, &v
                out     &p, eax
                ENDM

;-----------------------------------------------------------------------------
ENABLE          MACRO   COND
		COND = 1
		ENDM

DISABLE         MACRO   COND
		ENDM

;-----------------------------------------------------------------------------
max             MACRO   o,l
		local   j1
		cmp     o,l
		jbe     j1
		mov     o,l
	j1:
		ENDM


min             MACRO   o,l
		local   j1
		cmp     o,l
		jae     j1
		mov     o,l
	j1:
		ENDM

limit           MACRO   dest, cond, src
		local j1
		cmp     dest,src
		j&cond  j1
		mov     dest,src
	j1:
		ENDM

;-----------------------------------------------------------------------------
dbw             MACRO   b,w
		db      b
		dw      w
		ENDM

;-----------------------------------------------------------------------------
mvs             MACRO   dest, src
		push    &src
		pop     &dest
		ENDM

;-----------------------------------------------------------------------------
PLABEL          MACRO   name
		&name   LABEL
		PUBLIC  &name
		ENDM

;-----------------------------------------------------------------------------
.list
;=============================================================================

