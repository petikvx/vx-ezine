import java.io.*;

public class HexDump {

    public static void main(String argv[]) {

	if (argv.length == 0) {
		System.out.println("Usage: java HexDump <filename>");
		System.exit(1);
	}
	HexDump hexdump = new HexDump(argv[0]);

    }

    public byte[] asciiz = new byte[16];
    public int ind = 0, counter = 0;

    public HexDump(String fname) {

	try {
		RandomAccessFile file = new RandomAccessFile(fname,"rw");
		printCounter();
		for (int i = 1; i <= file.length(); i++) { 
			int tmp = (byte)file.readUnsignedByte();
			printHex(tmp);
			System.out.print(" ");
			createAsciiz(tmp);
		}
		for (int i = 0; i <= (15-ind); i++) System.out.print("   ");
		for (int i = 0; i <= ind; i++) {
			char c; 
			if ((asciiz[i] < 32) || (asciiz[i] > 126)) c = 46;
			else c = (char)asciiz[i];
			System.out.print(c);
		}

	}
	catch (IOException e) {}

    }

    private void createAsciiz(int b) {

    if ((b < 32) || (b > 126)) b = 46;
    asciiz[ind] = (byte)b;
    if (ind == 15) {
     	String s = new String(asciiz);
    	System.out.println(s);
	ind = 0;
	counter += 16;
	printCounter();
    }
    else ind++;
    }

    private void printCounter() {

    int highest, high, low, lowest;
    highest = counter & 0xFF000000;
    highest = counter >> 24;
    printHex(highest);
    high    = counter & 0x00FF0000;
    high    = counter >> 16;
    printHex(high);
    low     = counter & 0x0000FF00;
    low     = counter >> 8;
    printHex(low);
    lowest  = counter & 0x000000FF;
    printHex(lowest);
    System.out.print(" ");
    }

    private void printHex(int b) {

	b = b & 0x000000FF;
	int high = (b/16);
	int low  = b%16;

	switch(high) {
		case 10: System.out.print("A");
			 break;
		case 11: System.out.print("B");
			 break;
		case 12: System.out.print("C");
			 break;
		case 13: System.out.print("D");
			 break;
		case 14: System.out.print("E");
			 break;
		case 15: System.out.print("F");
			 break;
		default: System.out.print(high);
			 break;
	}

	switch(low) {
		case 10: System.out.print("A");
			 break;
		case 11: System.out.print("B");
			 break;
		case 12: System.out.print("C");
			 break;
		case 13: System.out.print("D");
			 break;
		case 14: System.out.print("E");
			 break;
		case 15: System.out.print("F");
			 break;
		default: System.out.print(low);
			 break;
	}

    }

}
