; LME v0.9
;
; gme_seed_offset - ᬥ饭�� �⭮�-� gme_start seed'�
; gme_start       - ��-� �����樨     
; esi - source
; edi - buffer
; ecx - length

lme_start:
db  060h,0E8h,00Fh,000h,000h,000h
lme_seed_offset:
db  031h,002h,000h,000h
db  05Bh,04Ch,04Dh,045h
db  033h,032h,02Eh,031h,031h,035h,039h,05Dh,081h,0EDh,079h,024h,040h,000h
db  0C1h,0E9h,002h,041h,089h,08Dh,03Fh,026h,040h,000h,089h,0BDh,051h,026h
db  040h,000h,089h,0B5h,03Ah,026h,040h,000h,0C7h,085h,099h,026h,040h,000h
db  0EFh,000h,000h,000h,08Dh,0B5h,09Dh,026h,040h,000h,0E8h,021h,003h,000h
db  000h,0B0h,003h,0FFh,0D6h,040h,091h,051h,0E8h,082h,002h,000h,000h,059h
db  0E2h,0F7h,0B0h,0E8h,0AAh,02Bh,0C0h,0ABh,08Bh,0C7h,02Bh,085h,051h,026h
db  040h,000h,089h,085h,028h,026h,040h,000h,0E8h,0F9h,002h,000h,000h,0E8h
db  0A4h,001h,000h,000h,088h,085h,0B7h,025h,040h,000h,050h,00Fh,0B6h,0C0h
db  00Fh,0B3h,085h,099h,026h,040h,000h,058h,00Ch,058h,0AAh,0E8h,08Ah,001h
db  000h,000h,050h,00Fh,0B6h,0C0h,00Fh,0B3h,085h,099h,026h,040h,000h,058h
db  088h,085h,0E8h,025h,040h,000h,08Bh,095h,03Fh,026h,040h,000h,0E8h,04Ch
db  001h,000h,000h,0E8h,0B8h,002h,000h,000h,0E8h,0C3h,002h,000h,000h,06Ah
db  0FFh,058h,0E8h,070h,001h,000h,000h,089h,085h,053h,025h,040h,000h,0B0h
db  081h,0AAh,0E8h,044h,001h,000h,000h,0B0h,0E8h,074h,002h,0B0h,0C0h,09Ch
db  00Ah,085h,0B7h,025h,040h,000h,0AAh,089h,0BDh,0F3h,025h,040h,000h,0B8h
db  02Ch,059h,0CEh,01Bh,0ABh,09Dh,074h,006h,0F7h,09Dh,053h,025h,040h,000h
db  0E8h,075h,002h,000h,000h,0B0h,003h,0FFh,0D6h,003h,0C0h,08Bh,09Ch,005h
db  061h,026h,040h,000h,066h,089h,09Dh,049h,026h,040h,000h,08Bh,084h,005h
db  05Bh,026h,040h,000h,00Ah,0A5h,0B7h,025h,040h,000h,066h,0ABh,089h,0BDh
db  033h,026h,040h,000h,0ABh,06Ah,0FFh,058h,0E8h,008h,001h,000h,000h,089h
db  085h,044h,026h,040h,000h,0ABh,0E8h,037h,002h,000h,000h,0B0h,083h,0AAh
db  0E8h,0D6h,000h,000h,000h,066h,0B8h,0C0h,004h,074h,004h,066h,0B8h,0E8h
db  0FCh,00Ch,000h,066h,0ABh,0E8h,01Ch,002h,000h,000h,0B0h,048h,00Ah,085h
db  0E8h,025h,040h,000h,0AAh,0E8h,00Eh,002h,000h,000h,0E8h,019h,002h,000h
db  000h,0B0h,003h,0FFh,0D6h,08Dh,09Dh,067h,026h,040h,000h,0D7h,0AAh,08Ah
db  085h,0E8h,025h,040h,000h,0C0h,0E0h,003h,00Ch,001h,00Ch,0C0h,0AAh,066h
db  0B8h,00Fh,085h,066h,0ABh,0B8h,08Eh,02Bh,040h,000h,02Bh,0C7h,0ABh,050h
db  00Fh,0B6h,085h,0B7h,025h,040h,000h,00Fh,0ABh,085h,099h,026h,040h,000h
db  058h,050h,00Fh,0B6h,085h,0E8h,025h,040h,000h,00Fh,0ABh,085h,099h,026h
db  040h,000h,058h,0E8h,0BCh,001h,000h,000h,08Bh,0C7h,02Bh,085h,051h,026h
db  040h,000h,02Dh,05Fh,002h,000h,000h,003h,085h,053h,025h,040h,000h,0BAh
db  098h,02Bh,040h,000h,089h,002h,0BEh,08Bh,020h,040h,000h,0B9h,0FBh,000h
db  000h,000h,0BAh,0FDh,068h,033h,0A6h,0ADh,02Bh,0C2h,0ABh,0E2h,0FAh,08Bh
db  0C7h,02Dh,0FDh,028h,040h,000h,089h,044h,024h,01Ch,061h,0C3h,081h,0B0h
db  081h,080h,081h,0A8h,033h,0C2h,02Bh,0C2h,003h,0C2h,085h,023h,00Bh,0E8h
db  013h,000h,000h,000h,074h,006h,00Ch,0B8h,0AAh,092h,0ABh,0C3h,050h,0B0h
db  068h,0AAh,092h,0ABh,058h,00Ch,058h,0AAh,0C3h,050h,0B0h,002h,0FFh,0D6h
db  085h,0C0h,058h,0C3h,0B0h,008h,0FFh,0D6h,00Fh,0A3h,085h,099h,026h,040h
db  000h,073h,0F3h,0C3h,0EFh,000h,000h,000h,00Fh,0B6h,0C0h,052h,051h,050h
db  0B8h,058h,06Dh,001h,0F2h,069h,0C0h,005h,084h,008h,008h,040h,089h,085h
db  0A4h,026h,040h,000h,059h,033h,0D2h,0F7h,0F1h,092h,059h,05Ah,0C3h,080h
db  0CCh,0C0h,0C0h,0E0h,003h,00Ah,0C4h,0AAh,0C3h,008h,047h,0FFh,0C3h,00Ch
db  0C0h,0AAh,0B0h,008h,0FFh,0D6h,03Ch,006h,074h,0F8h,0C0h,0E0h,003h,008h
db  047h,0FFh,0C3h,00Ch,0C0h,0C0h,0E4h,003h,00Ah,0C4h,0AAh,0B0h,0FFh,0FFh
db  0D6h,0AAh,0C3h,08Bh,0BEh,006h,07Fh,0B7h,0BEh,006h,040h,0BFh,0BEh,006h
db  040h,087h,0BEh,006h,0BFh,003h,0BEh,006h,07Fh,013h,0BEh,006h,07Fh,023h
db  0BEh,006h,07Fh,00Bh,0BEh,006h,07Fh,02Bh,0BEh,006h,07Fh,01Bh,0BEh,006h
db  07Fh,033h,0BEh,006h,07Fh,040h,0C8h,006h,07Fh,048h,0C8h,006h,07Fh,039h
db  0BEh,006h,03Fh,085h,0BEh,006h,03Fh,0D1h,0CCh,006h,07Fh,0D3h,0CCh,006h
db  07Fh,0A4h,0DEh,006h,040h,0ACh,0DEh,006h,040h,0C8h,0C8h,006h,040h,0ABh
db  0BEh,006h,080h,0B3h,0BEh,006h,080h,0BBh,0BEh,006h,080h,0E8h,09Eh,000h
db  000h,000h,0B8h,064h,067h,0FFh,036h,0ABh,02Bh,0C0h,066h,0ABh,0E8h,07Fh
db  000h,000h,000h,0E8h,08Ah,000h,000h,000h,0B0h,0E8h,0AAh,0ABh,057h,0E8h
db  070h,000h,000h,000h,0E8h,07Bh,000h,000h,000h,0B8h,064h,067h,08Fh,006h
db  0ABh,02Bh,0C0h,066h,0ABh,0E8h,05Ch,000h,000h,000h,0E8h,067h,000h,000h
db  000h,0B0h,0E9h,0AAh,0ABh,08Bh,0D7h,0E8h,04Ch,000h,000h,000h,0E8h,057h
db  000h,000h,000h,058h,08Bh,0DFh,02Bh,0D8h,089h,058h,0FCh,0E8h,03Ah,000h
db  000h,000h,0E8h,045h,000h,000h,000h,0B8h,064h,067h,08Fh,006h,0ABh,02Bh
db  0C0h,066h,0ABh,0E8h,026h,000h,000h,000h,0E8h,031h,000h,000h,000h,0B8h
db  064h,067h,0FFh,026h,0ABh,02Bh,0C0h,066h,0ABh,0E8h,012h,000h,000h,000h
db  0B0h,0FFh,0FFh,0D6h,0AAh,0E8h,008h,000h,000h,000h,08Bh,0C7h,02Bh,0C2h
db  089h,042h,0FCh,0C3h,0B0h,005h,0FFh,0D6h,040h,091h,051h,0E8h,013h,000h
db  000h,000h,059h,0E2h,0F7h,0C3h,080h,0BDh,003h,028h,040h,000h,001h,075h
db  005h,0E8h,009h,000h,000h,000h,0C3h,0B0h,004h,0FFh,0D6h,022h,0C0h,075h
db  048h,0B0h,001h,084h,0C0h,075h,012h,0FEh,085h,003h,028h,040h,000h,0B0h
db  0E8h,0AAh,089h,0BDh,023h,028h,040h,000h,0ABh,0EBh,030h,0E8h,06Ch,0FEh
db  0FFh,0FFh,00Ch,0B8h,0AAh,0B8h,0DFh,02Bh,040h,000h,08Bh,0DFh,02Bh,0D8h
db  057h,097h,093h,083h,0E8h,004h,0ABh,05Fh,0B0h,0C3h,0AAh,06Ah,0FFh,058h
db  0E8h,062h,0FEh,0FFh,0FFh,066h,0ABh,0C1h,0E8h,010h,0AAh,0FEh,08Dh,003h
db  028h,040h,000h,0B0h,019h,0FFh,0D6h,03Ch,018h,075h,016h,052h,06Ah,0FFh
db  058h,0E8h,045h,0FEh,0FFh,0FFh,092h,0E8h,02Ah,0FEh,0FFh,0FFh,0E8h,004h
db  0FEh,0FFh,0FFh,05Ah,0C3h,03Ch,017h,075h,01Ch,0B0h,08Dh,0AAh,0E8h,017h
db  0FEh,0FFh,0FFh,03Ch,005h,074h,0F7h,0C0h,0E0h,003h,00Ch,005h,0AAh,06Ah
db  0FFh,058h,0E8h,01Ah,0FEh,0FFh,0FFh,0ABh,0C3h,08Dh,09Ch,085h,0ECh,026h
db  040h,000h,0E8h,0EEh,0FDh,0FFh,0FFh,074h,003h,0B0h,066h,0AAh,0F6h,043h
db  003h,03Fh,075h,003h,0B0h,00Fh,0AAh,08Ah,003h,0AAh,08Ah,043h,003h,024h
db  0C0h,03Ch,000h,075h,014h,0B0h,008h,0E8h,0EBh,0FDh,0FFh,0FFh,08Ah,0C8h
db  0B0h,008h,0E8h,0E2h,0FDh,0FFh,0FFh,08Ah,0E1h,0EBh,02Ah,03Ch,040h,075h
db  014h,0E8h,0C0h,0FDh,0FFh,0FFh,08Ah,0C8h,0B0h,008h,0E8h,0CCh,0FDh,0FFh
db  0FFh,08Ah,0E0h,08Ah,0C1h,0EBh,012h,0E8h,0ACh,0FDh,0FFh,0FFh,08Ah,0C8h
db  0E8h,0A5h,0FDh,0FFh,0FFh,03Ah,0C1h,074h,0F0h,08Ah,0E1h,00Fh,0B7h,05Bh
db  001h,08Dh,09Ch,01Dh,000h,020h,040h,000h,0FFh,0D3h,0C3h
