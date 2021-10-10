;*********************************;
; WASM Stack Allocation           ;
; By Eric Tauck                   ;
;                                 ;
; Defines:                        ;
;                                 ;
;   StkAll  allocate stack memory ;
;   StkRel  release stack memory  ;
;*********************************;

;========================================
; Macro to allocate memory from the
; stack.
;
; In: m1..m5= bytes to allocate; v1..v5=
;     variables to store address.

StkAll  MACRO   v1, m1, v2, m2, v3, m3, v4, m4, v5, m5
        IF      (TYPE(m1)=TYPE())=0
        sub     sp, m1
        mov     v1, sp
        ENDIF
        IF      (TYPE(m2)=TYPE())=0
        sub     sp, m2
        mov     v2, sp
        ENDIF
        IF      (TYPE(m3)=TYPE())=0
        sub     sp, m3
        mov     v3, sp
        ENDIF
        IF      (TYPE(m4)=TYPE())=0
        sub     sp, m4
        mov     v4, sp
        ENDIF
        IF      (TYPE(m5)=TYPE())=0
        sub     sp, m5
        mov     v5, sp
        ENDIF
        ENDM

;========================================
; Macro to release memory allocated from
; the stack.
;
; In: m1..m5= bytes to deallocate.

StkRel  MACRO   m1, m2, m3, m4, m5
        IF      TYPE(m1)=TYPE(bx)
        mov     sp, m1
        ELSE
        IF      TYPE(m2)=TYPE()
        add     sp, m1
        ELSEIF  TYPE(m3)=TYPE()
        add     sp, (m1) + (m2)
        ELSEIF  TYPE(m4)=TYPE()
        add     sp, (m1) + (m2) + (m3)
        ELSEIF  TYPE(m5)=TYPE()
        add     sp, (m1) + (m2) + (m3) + (m4)
        ELSE
        add     sp, (m1) + (m2) + (m3) + (m4) + (m5)
        ENDIF
        ENDIF
        ENDM
