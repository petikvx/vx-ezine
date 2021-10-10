;(****************************************************************************)
;(*****                     ASMAV (c) 2001 by RedArc                     *****)
;(*****     Антивирусная программа на языке Turbo Assembler Version 3.2  *****)
;(*****       специально для электронного журнала "Земский Фершал"       *****)
;(****************************************************************************)

        .model tiny
        .486
        .code
        .startup
        org 100h
start:
       call Ctrl
       lea dx,AboutMSG
       call Write
       call Ctrl
       call Ctrl
       cmp byte ptr ds:[80h],0
       je Info
       jne Info1
AboutMSG db ' Example for ZF (c) 2000 by RedArc ','$'
Info1:
       call _SetO
       call GetParamLine
       cmp ah,1
       je Info
       mov AllKnownVirus,2
       call AllocMem
       call ScanDir
       call ClrEol
       cmp LoMode,1
       jne Beenden
       call TextProt
       jmp short Beenden
Info:
       lea dx,InfoMSG
       call Write
Beenden:
       call _SetN
       mov ax,4c00h
       int 21h
;*************************************************************************
include library.inc
end start
