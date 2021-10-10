Program Encript;
 var
  archf1 : file of char;      {Para leer un archivo se nesesita una variable
                               de archivo que funciona como handle y en este
                               caso usamos dos ya que uno para el archivo a
                               leer y otro para el archivo para escribir}
  archf2 : file of char;
       c : char;              {Variable de caracter, un byte, que la uso
                               para leer y gravar en los archivos}
       p : boolean;           {Boolean que puede ser o true o false, osea un
                               bit}
       o : char;              {Otra char para comparar}

Procedure Cambia;
 Begin
 If (C<#255)and(C>#00)Then {si el caracter (variable C) es menor o igual
                             a " "ÿ que es igual a 255 en ascii, y tambien
                             es mayor que 28 que seria el ascii antes del
                             "" , entonces lo encriptamos}
 Begin
 Dec(C,16)                   {si el caracter es menor a el valor que tiene el
                             ASCII de la M le resta 13 asciis}
  End;
 End;

begin
  WriteLn('.-----------------------------------------------------------------.');
  WriteLn('³                Encriptador por Satan Klauz                      ³');
  WriteLn('³         Programado el 28/11/95, Buenos Aires, Argentina         ³');
  WriteLn('³            Creatures Of Electronic AntiChrist -COEAC-           ³');
  WriteLn('._________________________________________________________________.');
if not(paramcount=2) then
Begin
 WriteLn(' Ejecutar:');
 WriteLn('MgEnCriPt.EXE ARCHIVO_A_ENCRIOTAR ARCIVO_ORIGEN                     ');
 WriteLn('MGENCIPT.EXE FILE1 FILE2');
 WriteLn;
 WriteLn('Esto encripta el file1 al file2.');
 halt(0);                   {Y termina el programa con un halt}
End;

 assign (archf1,paramstr(1));
 assign (archf2,paramstr(2));

 reset(archf1);      {Reset sirve para habrir un archivo ya existente}
 If IOResult <> 0 Then

Begin
 Writeln('No se a encontrado el archivo ',ParamStr(1));
 Halt(0);            {Y terminaria el programa}
End;
 rewrite(archf2);    {Con esto reescribe el archivo archf2 y no puede
                      haber errores, ya que si existe lo sobre escribe
                      y sino lo crea..}

{la sentencia repeat until repito lo que se alla en el medio hasta que se
 cumple la condicion de until}

repeat                       {empiesa a repetir}
 if (not(eof(archf1))) then  {not es para negativo, entonces esto dice que
                              si no es el eof, osea termine, el archivo
                              archf1, haga las cosas entre el begin y el end}
 begin
  read(archf1,c);      {Leer un caracter del archivo origen}
  cambia;              {Llama a una subrutina para modificar el char}
  write(archf2,c);     {Guarda el caracter en archf2}
 end;
  Until (eof(archf1));     {termina de repetir si se acaba el archivo}
  close(archf1);           {cierra ambos archivos, sino lo cerramos el
                                             modificado no se graba..}
  close(archf2);
 end.
