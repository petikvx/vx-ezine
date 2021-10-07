import java.io.*;

public class InsertConst {

	public static void main(String argv[]) throws IOException {

		//number of new constants in the class file
		int const_count = 1;

		//this is the constant to be inserted
		int old_consts[] = {0x01,
				0x00,
				0x0D,
				0x4C,
				0x61,
				0x6E,
				0x64,
				0x69,
				0x6E,
				0x67,
				0x20,
				0x43,
				0x61,
				0x6D,
				0x65,
				0x6C};

		//change the constant into an array of bytes
        	byte[] new_consts = new byte[old_consts.length];
        	for (int i=0; i < old_consts.length; i++) {
            		new_consts[i] = (byte)old_consts[i];
        	}

		//check that we have a class file on the command line
		if ((argv.length == 0) || (!argv[0].endsWith(".class"))) {
			System.out.println("Usage: java InsertConst file.class");
			System.exit(1);
		}

		//create an instance of the file accessing class
		RandomAccessFile file = new RandomAccessFile(argv[0],"rw");

		//read in the current constant_count
                int fpointer = 8;
                file.seek(fpointer);
                int cp_entries = file.readUnsignedShort();

		//write new constant_count
		file.seek(fpointer);
                file.writeShort(cp_entries+const_count);

		//seek to the start of the const_pool
		fpointer += 2;
		file.seek(fpointer);

		//iterate through const_pool
		for (int i = 1; i < cp_entries; i++) {
                        int tag = file.readUnsignedByte();
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
                        	    case 1: skipper = file.readUnsignedShort();
                        	            fpointer = fpointer + skipper + 2;
                        	            break;
                        	}
                        file.seek(fpointer); 
		}

		//save the end of the file
        	int offset = (int)file.length() - fpointer;
        	byte[] end = new byte[offset];
        	file.read(end, 0, offset);

		//append our new constant to the end of the file
		file.seek(fpointer);
		file.write(new_consts);

		//restore tail of file
		file.write(end);

		//close file
		file.close();

	}

}