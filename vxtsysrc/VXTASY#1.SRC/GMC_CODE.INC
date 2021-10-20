; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000                Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

; Menu reader...                            ;
                                            ;
gmc_start:                                  ;
        call initialize1                    ; initialize stuff
                                            ;
        pusha                               ;
        push es                             ;
        push ds                             ;
        call bmp_intro                      ;
        pop ds                              ;
        pop es                              ;
        popa                                ;
                                            ;
        call initialize2                    ;
                                            ;
        call makescreen                     ; draw browser screen
        call display_menu_bar               ;
        call init_mouse                     ;
        call show_mouse                     ;
        call browse_menu                    ;
        call finish                         ; end all
        ret                                 ;
                                            ;
data1_seg dw 0                              ;
data2_seg dw 0                              ;
video_seg dw 0b800h                         ;
                                            ;
;============================================================================
                                            ;
include misc\mouse.inc                      ; mouse
include gmc_inm\other.inm                   ; other stuff
include gmc_inm\keyhandl.inm                ; keyhandlers
include gmc_inm\key.inm                     ; keyboard codes
include gmc_inm\video.inm                   ; video routines
include gmc_inm\keyboard.inm                ; keyboard wait routines
include gmc_inm\initend.inm                 ; init and finish routines
include gmc_inm\procs.inm                   ; procedures
include gmc_inm\misc.inm                    ; ;-)
include gmc_inm\events.inm                  ;

