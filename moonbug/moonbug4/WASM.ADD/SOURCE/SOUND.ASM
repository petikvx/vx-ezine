;****************************;
; WASM Sound Module	     ;
; By Eric Tauck 	     ;
;			     ;
; Defines:		     ;
;			     ;
;   SndOn   turn speaker on  ;
;   SndOff  turn speaker off ;
;****************************;

	jmps	_sound_end

;--- local definitions

_snd_TIMER	 EQU	 40H		;8253 timer port
_snd_PORTB	 EQU	 61H		;8255 controller port B
_snd_SBITS	 EQU	 00000011B	;sound bits of port B
_snd_HZDHI	 EQU	 0012H		;hertz conversion constant, high word
_snd_HZDLO	 EQU	 34DDH		;hertz conversion constant, low word

;========================================
; Turn on speaker.
;
; In: AX= hertz.

SndOn	PROC	NEAR

;--- calculate frequency value

	mov	bx, ax
	mov	ax, _snd_HZDLO		;
	mov	dx, _snd_HZDHI		;load divisor
	div	ax, bx			;get frequency value
	mov	dx, ax			;save in DX

;--- check sound bits

	in	al, _snd_PORTB		;get current settings
	test	al, _snd_SBITS		;check if sound bits set
	jnz	_sdon1			;skip if so

	or	al, _snd_SBITS		;turn sound on
	out	_snd_PORTB, al		;send data
	mov	al, 10110110B		;select timer 2, MSB, LSB
	out	_snd_TIMER+3, al	;write timer mode

;--- set frequency

_sdon1	mov	al, dl
	out	_snd_TIMER+2, al	;send low byte
	mov	al, dh
	out	_snd_TIMER+2, al	;send high byte
	ret
	ENDP

;========================================
; Turn off speaker.

SndOff	PROC   NEAR
	in	al, _snd_PORTB		;get current settings
	and	al, NOT _snd_SBITS	;clear sound bits
	out	_snd_PORTB, al		;send data
	ret
	ENDP

_sound_end
