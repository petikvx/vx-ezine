import java.io.*;

public class Insert {

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

		//length of the new code to be inserted
		int code_length = 10;

		//this is the actual to be inserted
		int old_code[] = {0x00,
				0x00,
				0x00,
				0x00,
				0x00,
				0x00,
				0x00,
				0x00,
				0x00,
				0x00,};

		//change the code into an array of bytes
        	byte[] new_code = new byte[old_code.length];
        	for (int i=0; i < old_code.length; i++) {
            		new_code[i] = (byte)old_code[i];
        	}

		if ((argv.length == 0) || (!argv[0].endsWith(".class"))) {
			System.out.println("Usage: java Insert file.class");
			System.exit(1);
		}

		RandomAccessFile file = new RandomAccessFile(argv[0],"rw");

		//read in const_count
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
        	int _offset = (int)file.length() - fpointer;
        	byte[] _end = new byte[_offset];
        	file.read(_end, 0, _offset);

		//append our new constant to the end of the file
		file.seek(fpointer);
		file.write(new_consts);

		//restore tail of file
		file.write(_end);

		//fix up the file pointer
		fpointer += new_consts.length;
		file.seek(fpointer);

		//read in the number of interfaces
                fpointer += 6;
               	file.seek(fpointer);
               	int num_interfaces = file.readUnsignedShort();

		//iterate through the interface information 
                fpointer = fpointer + 2*(num_interfaces) + 2;
                file.seek(fpointer);

		//read in the number of fields
                int num_fields = file.readUnsignedShort();
                fpointer += 2;
                file.seek(fpointer);

		//iterate through the fields
                for (int j=0; j<num_fields; j++) {

			//skip to the attribute_count
                        fpointer += 6;
                        file.seek(fpointer);
                        int num_f_attributes = file.readUnsignedShort();

			//iterate through atribute_info
                        fpointer = fpointer + 8*(num_f_attributes) + 2;
                        file.seek(fpointer);
		}

		//read the number of methods
		int num_methods = file.readUnsignedShort();

		//read the number of method_attributes
		fpointer += 8;
		file.seek(fpointer);
		int num_m_attributes = file.readUnsignedShort();

		//read in current attribute_length
                fpointer += 4;
                file.seek(fpointer);
		int attribute_length = file.readInt();

		//write new attribute_length
		file.seek(fpointer);
		file.writeInt(attribute_length + code_length);

		//read in current code_length
		fpointer += 8;
		file.seek(fpointer);
		int old_code_length = file.readInt();

		//write new code_length
		file.seek(fpointer);
		file.writeInt(old_code_length + code_length);
		fpointer += 4;
		file.seek(fpointer);

		//save the end of the file
        	int offset = (int)file.length() - fpointer;
        	byte[] end = new byte[offset];
        	file.read(end, 0, offset);

		//append our new code to the end of the file
		file.seek(fpointer);
		file.write(new_code);

		//restore tail of file
		file.write(end);

		//close file
		file.close();

	}

}