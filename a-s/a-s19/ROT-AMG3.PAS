{UPGRADE on the code released in A-S18 - I think most will agree its a BIG   }
{upgrade.  Before you could only encrypt a 8 character password, now it can  }
{encrypt/decrypt an entire text file.                                        }
{                                                                            }
{Still uses the two methods of encryption, decided on by a random number.    }
{However, I've now changed the character which is stored (now stored within  }
{the encrypted output file) the new characters used means that if opened in  }
{text editor, insted of 1 or 2 being seen - which over a few examples would  }
{give away the characters purpose - the user will now only see a "þ" which   }
{will remain constant whether method 1 or 2 was used.....the option is still }
{there to add more varients on the encryption and this is a section I'll be  }
{working new routines into, most likely next month.                          }
{                                                                            }
{Known bug : Not exactly a bug, as much as a warning to those who upgrade the}
{            array to carry more characters. The array seems to need 12 or so}
{            extra characters in it then your going to be en/decrypting, if  }
{            they aren't there then for some reason when encrypting you'll   }
{            lose certain characters, for example if the last 12 weren't in  }
{            the array below, it wouldn't encrypt characters from and past * }
{            with the extra characters added it won't effect you at all.     }
{            Instead all you'd see when decrypted was a blank space where you}
{            had those characters.                                           }
{                                                                            }
{More updates to come in future issues etc.                                  }
{                             Written by : Armageddon                        }
{____________________________________________________________________________}

program AMGrot13;
uses crt;
const
   encoder1  :  array [1..101] of char = ( '.',' ','-','Ä','[',']',':','>','<'
                                         ,'a','b','c','d','e','f','g','h','i'
                                         ,'j','k','l','m','n','o','p','q','r'
                                         ,'s','t','u','v','w','x','y','z','A'
                                         ,'B','C','D','E','F','G','H','I','J'
                                         ,'K','L','M','N','O','P','Q','R','S'
                                         ,'T','U','V','W','X','Y','Z','1','2'
                                         ,'3','4','5','6','7','8','9','0','!'
                                         ,'@','#','$','%',',','&','*','(',')'
                                         ,'"','?','/','\','|','=',';','®','ß'
                                         ,'û','Ç','','Ý','à','á','ä','å','ã'
                                         ,'â','æ');


  maxValue = 101; {Size of the array, if you change the size of the array,
                  make sure this matches it or you'll get en/decryption
                  problems}

VAR
  version       : char;
  location      : integer;
  code          : integer;
  originalFile  : text;   {inputted clear text file}
  encryptedFile : text;   {output file containing encrypted text}
  decryptedFile : text;   {output file containing decrypted text}
  c             : char;   {char used to read the text, character by character}
  state         : string; {Used to tell user whether encrypting/decrypting}
  stop          : boolean;{TRUE : Program stops - FALSE : program continues}

{============================================================================}
{-----Assigns the original file variable to its actual disk file name etc.---}
{-----By using "state" we save ourselves from haveing to write this----------}
{-----code out twice, originalFile just gets used for whatever the-----------}
{-----"original file" happens to be for the task in hand.--------------------}
{============================================================================}
procedure initialise;
VAR
  filename : string;
BEGIN
  writeln ('Enter filename of the text document you wish to ', state , ':-');
  readln(filename);
  filename := filename + '.txt';      {Adds file extention to the filename}
  assign (originalFile, fileName);
  {$I-}                    {Switch OFF I/O checking : Stops potential crash}
  reset(originalFile);
  while IOresult <> 0 do
  BEGIN
    clrScr;
    writeln ('File can not be found.........');
    write ('Hit [Enter] to exit');
    stop := TRUE;                 {make sure program stops}
    readln;
  END;
  {$I+}                   {Switch ON I/O checking}
END;

{============================================================================}
{------------Decides the version of Encryption it will use-------------------}
{----Generates a random number, which decides whether we'll move the char----}
{----forward 13 or 15 places when we encrypt the text.-----------------------}
{============================================================================}
procedure decideEnc;
VAR
  ans      :  integer;
BEGIN
  randomize;
  repeat
    ans := random(1000);
  until ((ans > 0) AND (ans < 3));  {make sure ans is within valid perameters}
  GOTOXY(1,3);
  write('Encryption version ' , ans);
  delay(1000);
  IF (ans = 1) then
  BEGIN
    version := '—';    {<---use non-alphanumerical characters so they aren't}
    code := 13;            {readble on a text editor, unlike in old version }
  END;
  IF (ans = 2) then
  BEGIN
    version := '˜';
    code := 15;
  END;
END;

{============================================================================}
{-----Encodes the text, reads text character by character decides------------}
{-----on that characters encrypted alternative and writes it to file---------}
{============================================================================}
procedure encode;
BEGIN
  assign (encryptedFile, 'encode.txt');   {assign variable to disk file name}
  reset(originalFile);  {Make sure we're at the start of the file to encrypt}
  rewrite(encryptedFile);             {create the file to dump encryption to}
  location := 1;
  decideEnc;              {Decide which encryption method to use for this run}
  write (encryptedFile, version);         {save that method to encrypted file}
  WHILE NOT eof(originalFile) do                {while not end of file.....do}
  BEGIN
    WHILE NOT eoln(originalFile) do          {while not end of the line....do}
    BEGIN
      read(originalFile,c);           {read character from file save to "c"}
      WHILE (c <> encoder1[location]) do           {Keep looping until the}
      BEGIN                                        {character entered matches}
        location := (location + 1);                {that in the text}
      END;
      location := (location + code);      {Move forward in array to encrypted}
                                          {version of the text}
      IF (location > maxValue) then
      BEGIN
        location := (location - maxValue);
      END;
      c := encoder1[location];          {change text to its encrypted version}
      location := 0;
      write (encryptedFile, c);{write encrypted character to the output file}
      write (c);               {write character to screen}
    END;
    writeln (encryptedFile);    {take us to a new line in the output file}
    writeln;                    {so we don't start writing in a long line}
    readln(originalFile);       {go to next line in clear text file.....}
  END;{WHILE}
  reset(encryptedFile);
END;

{============================================================================}
{----------------------DECRYPTION PROCEDURE----------------------------------}
{---works out what encryption routine was used, then simply reverses the-----}
{---encrpytion to leave a nice piece of clear text, simple but effective-----}
{============================================================================}
procedure decode;
VAR
  num   :   char;
BEGIN
  assign (decryptedFile, 'decode.txt');
  reset(originalFile);
  rewrite(decryptedFile);
  location := 1;
  read(originalFile, num);
  IF (num = '—') then
  BEGIN
    code := 13;
  END;
  IF (num = '˜') then
  BEGIN
    code := 15;
  END;
  WHILE NOT eof(originalFile) do
  BEGIN
    read(originalfile);
    WHILE NOT eoln(originalFile) do
    BEGIN
      read(originalFile,c);
      WHILE (c <> encoder1[location]) do           {Keep looping until the}
      BEGIN                                        {character entered matches}
        location := (location + 1);                {that in the text}
      END;
      location := (location - code);      {Move forward in array to encrypted}
                                          {version of the text}
      IF (location > maxValue) then
      BEGIN
        location := (location + maxValue);
      END;
      c := encoder1[location];          {change text to its encrypted version}
      location := 0;
      write (decryptedFile, c);
      write (c);
    END;
    writeln (decryptedFile);
    writeln;
    readln(originalFile);
  END;{WHILE}
  reset(decryptedFile);
END;

{============================================================================}
{-----------------------------MENU SCREEN------------------------------------}
{----Gives us some options of what we want to do, and woooh we're using a----}
{----a bit of colour too, aren't we dareing.  You never know there might-----}
{----we might even put in some design to our menu next time.-----------------}
{============================================================================}
procedure menu;
VAR
  menu : char;
BEGIN
  stop := false;        {make sure 'stop' is in the right state before test}
  GOTOXY(20,10);
  repeat
    textColor(red);
    write ('SELECT WHAT TASK YOU WISH TO PERFORM');
    GOTOXY(20,12);
    textColor(white);
    write ('[E]ncode a text file');
    GOTOXY(20,13);
    write ('[D]ecode a text file');
    writeln;
    readln(menu);
  until (menu = 'E') or (menu = 'D') or (menu = 'e') or (menu = 'd');
  IF (menu = 'E') or (menu ='e') then
  BEGIN
    state := 'encrypt';
    initialise;
    IF (stop = FAlSE) then
    encode;
  END;
  IF (menu = 'D') or (menu = 'd') then
  BEGIN
    state := 'decrypt';
    initialise;
    IF (stop = FALSE) then
    decode;
  END;
end;

{============================================================================}
{------Bit of text at the end to say "I wrote this....." blah, blah etc.-----}
{============================================================================}
procedure endText;
BEGIN
  clrScr;
  writeln ('Written by Armageddon (A-S Mag / HNC) - Copyright 1999-2000');
  writeln ('Released in Anti-Social Magazine Issue 19');
  writeln ('http://www.antisocial.cjb.net');
  writeln ('http://www.hackers-uk.com/A-S');
  delay(2500);    {delay for 2.5 seconds}
END;

{###---MAIN PROGRAM----###}
BEGIN
   clrScr;        {Nice and short main program.....}
   menu;          {Could clear the screen in Menu but we won't}
   endText;
end.

