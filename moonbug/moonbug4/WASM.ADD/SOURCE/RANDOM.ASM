;********************************************;
; WASM Random Number Generator               ;
; By Eric Tauck                              ;
;                                            ;
; Defines:                                   ;
;                                            ;
;   RndSed   seed the number generator       ;
;   RndNum   return a random number          ;
;   RndNumN  return a random number 0 to N-1 ;
;                                            ;
; Note: Algorithm is based on the one pub-   ;
; lished in March 1987 Byte magazine         ;
;********************************************;

;--- seed generator, uses time, month, and date

        mov     ah, 2CH         ;get time function
        int     21H             ;execute
        push    dx
        push    cx
        mov     ah, 2AH         ;get date
        int     21H             ;execute
        pop     bx
        pop     ax
        call    RndSed          ;seed generator
        jmps    _random_end

;--- data

_rnd_count      EQU     3                       ;number of generators
_rnd_data       DW      0, 253, 65497           ;first generator data
                DW      0, 254, 65519           ;second generator data
                DW      0, 255, 65521           ;third gernerator data

;================================================
; Seed the random number generator.  Note: the
; generator is automatically seeded.  Use this
; routine if wish a reproduceable sequence of
; random numbers.
;
; In: AX,BX,CX= three 16 bit seeds.

RndSed  PROC    NEAR
        mov     _rnd_data, ax
        mov     _rnd_data+6, bx
        mov     _rnd_data+12, cx
        ret
        ENDP

;================================================
; Generate a 16 bit random number.
;
; Out: AX= random number.

RndNum  PROC    NEAR
        push    si
        sub     bx, bx                  ;sum of components
        mov     cx, _rnd_count          ;number of components
        mov     si, OFFSET _rnd_data    ;start of data

_rdnum1 mov     ax, [si]                ;get seed
        mul     ax, [si+2]              ;times multiplier
        div     ax, [si+4]              ;divide by prime
        mov     [si], dx                ;save remaider for next seed
        add     bx, dx                  ;add in component
        add     si, 6                   ;next entry
        loop    _rdnum1                 ;loop for each component

        mov     ax, bx
        pop     si
        ret
        ENDP

;================================================
; Generate a random number from 0 to n-1.
;
; In: AX= max random number + 1 (i.e. 'n').
;
; Out: AX= random number (0 <= AX < in_AX).

RndNumN PROC    NEAR
        push    ax
        call    RndNum          ;get random number
        pop     bx
        sub     dx, dx          ;zero for divide
        div     ax, bx          ;divide
        mov     ax, dx          ;return modulus
        ret
        ENDP

_random_end
