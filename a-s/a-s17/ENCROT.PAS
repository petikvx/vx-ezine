{Basic encryption using ROT-13 theory to encode 8 character password, this
{could easily be modified to encode most things......internal email whatever
{you wanted to impliment it into I guess.  The code here is more for demo then
{for specific use, after all this code could be modified in countles ways    }
{   Example modification.......make the array be capable of taking numbers   }
{                                                                            }
{                        Written by : Armageddon                             }
{____________________________________________________________________________}


program AMGrot13;
uses crt;
const
   encoder   :   array [1..52] of char = ('a','b','c','d','e','f','g','h','i'
                                         ,'j','k','l','m','n','o','p','q','r'
                                         ,'s','t','u','v','w','x','y','z','A'
                                         ,'B','C','D','E','F','G','H','I','J'
                                         ,'K','L','M','N','O','P','Q','R','S'
                                         ,'T','U','V','W','X','Y','Z');

VAR
  text   :  array[1..8] of char;
  number :  integer;

procedure rot;
VAR
  location : integer;
begin
  number   := 0;
  location := 1;
  while (number <> 8) do
  BEGIN
    clrScr;
    number := (number + 1);
    while text[number] <> encoder[location] do
    BEGIN
      location := (location + 1);
    end;
    location := (location + 13);
    IF (location > 52) then
    BEGIN
      location := (location - 52);
    END;
    text[number] := encoder[location];  {change number in array to encrypt
                                        version}
    location := 0;
  end;
  GOTOXY(25,10);
  writeln ('ENCRYPTED');
end;

procedure derot;
VAR
  location : integer;
begin
  number   := 0;
  location := 1;
  while (number <> 8) do
  BEGIN
    clrScr;
    number := (number + 1);
    while text[number] <> encoder[location] do
    BEGIN
      location := (location + 1);
    end;
    location := (location - 13);
    IF (location > 52) then
    BEGIN
      location := (location - 52);
    END;
    text[number] := encoder[location];  {change number in array to encrypt
                                        version}
    location := 0;
  end;
  GOTOXY(25,10);
  writeln ('DECRYPTED');
end;

procedure testEncode;             {dumps array to screen}
VAR
 letMove  : integer;
 txtCount : integer;
begin
  letMove := 1;
  txtCount:= 9;
  while (txtCount <> 0) do         {loops are efficient}
  begin
    txtCount := (txtCount - 1);
    GOTOXY(0+letMove,10);
    write (text[txtCount]);
    letmove := (letmove +1);
  end;
  readln;
end;

procedure inputPass;
VAR
  letCount : integer;
begin
  write ('Enter your password:-');
  letCount := 1;
  number := 8;
  while (number <> 0) do
  begin
    GOTOXY (20,10);
    writeln('Password characters remaining : ' , number);
    GOTOXY(4+letCount,4);       {Move X accross by 1 each time - notice as I
                                 am working with the keyboard buffer nothing
                                 will echo to screen but its nice to have it
                                 here all the same}
    text[number] := readKey;
    number := number - 1;
    letCount := letCount + 1;
  end;
  rot;                        {jump to procedure to encode using ROT13 idea}
end;


BEGIN
   clrScr;
   inputPass;
   testEncode;
   derot;
   testEncode;
end.

