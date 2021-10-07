import java.io.*;

public class VirusMethod {

	public static void main(String argv[]) {

		if ((argv.length == 0) || (!argv[0].endsWith(".class"))) {
			System.out.println("Usage: java VirusMethod file.class");
			System.exit(1);
		}

      try {
		//create an instance of the RandomAccessFile class
		RandomAccessFile file = new RandomAccessFile(argv[0],"rw");

		  System.out.println();
		  System.out.println("Virus Method Recovery (c) 1998");
                  System.out.println("Landing Camel International");	

		//read in const_count
                int fpointer = 8;
                file.seek(fpointer);
                int cp_entries = file.readUnsignedShort();

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

		int tmp;

		//read the number of methods
		int num_methods = file.readUnsignedShort();
		fpointer += 2;
		file.seek(fpointer);		

		for (int z = 1; z <= num_methods; z++) {
		
		  System.out.println("------------------------------------------------");

		//print the current method
		System.out.println(" method_info["+z+"]");

		//read and print access_flags 
		tmp = file.readUnsignedShort();
		System.out.println("    access_flags "+tmp);
		fpointer += 2;
		file.seek(fpointer);

		//read and print name_index
		tmp = file.readUnsignedShort();
		System.out.println("    name_index constant_pool["+tmp+"]");
		fpointer += 2;
		file.seek(fpointer);

		//read and print desc_index
		tmp = file.readUnsignedShort();
		System.out.println("    descriptor_index constant_pool["+tmp+"]");
		fpointer += 2;
		file.seek(fpointer);

		//read and print attr_count
		tmp = file.readUnsignedShort();
		System.out.println("    attribute_count "+tmp);
		fpointer += 2;
		file.seek(fpointer);

		//read in attribute_name_index
		tmp = file.readUnsignedShort();
		System.out.println("    attribute_name_index constant_pool["+tmp+"]");
                fpointer += 2;
                file.seek(fpointer);

		//read in current attribute_length
		tmp = file.readInt();
		System.out.println("    attribute_length "+tmp);
		fpointer += 4;
		file.seek(fpointer);

		//read and print max_stack 
		tmp = file.readUnsignedShort();
		System.out.println("    max_stack "+tmp);
		fpointer += 2;
		file.seek(fpointer);

		//read and print max_locals
		tmp = file.readUnsignedShort();
		System.out.println("    max_locals "+tmp);
		fpointer += 2;
		file.seek(fpointer);

		//read in current code_length
		int code_length = file.readInt();
		System.out.println("    code_length "+code_length+" fpointer = "+(fpointer+4));
		fpointer += 4;
		file.seek(fpointer);

		//read in code and print out byte by byte
		System.out.print("    code");
		for (int p = 0; p < code_length; p++) {
			tmp = file.readUnsignedByte();
                        System.out.print(p+"   ");
                        if (tmp <= 15) System.out.print("0");
			System.out.println(Integer.toHexString(tmp));
			fpointer ++;
			file.seek(fpointer);
		}
		System.out.println();

		//print exception_table_length 
		int exception_length = file.readUnsignedShort();
		System.out.println("    exception_table_length "+exception_length);
		fpointer += 2;
		file.seek(fpointer);

		//print exception table
		for (int q = 1; q <= exception_length; q++) {

			//print the exception_table[]
			System.out.println("\t       exception_info["+q+"]");

			//print start_pc
			tmp = file.readUnsignedShort();
			System.out.println("\t          start_pc "+tmp);
			fpointer += 2;
			file.seek(fpointer);

			//print end_pc
			tmp = file.readUnsignedShort();
			System.out.println("\t          end_pc "+tmp);
			fpointer += 2;
			file.seek(fpointer);

			//print handler_pc
			tmp = file.readUnsignedShort();
			System.out.println("\t          handler_pc "+tmp);
			fpointer += 2;
			file.seek(fpointer);

			//print catch_type
			tmp = file.readUnsignedShort();
			System.out.println("\t          catch_type constant_pool["+tmp+"]");
			fpointer += 2;
			file.seek(fpointer);
		}		

		//print attribute_count
		int m_attr_count = file.readUnsignedShort();
		System.out.println("    attribute_count "+m_attr_count);
		fpointer += 2;
		file.seek(fpointer);

		//iterate through attributes
		int m_attr_length;
		for (int s = 1; s <= m_attr_count; s++) {

			//print attribute number
			System.out.println("       attribute_info["+s+"]");
			
			//print attribute_name_index
			tmp = file.readUnsignedShort();
			System.out.println("          attribute_name_index constant_pool["+tmp+"]");
			fpointer += 2;
			file.seek(fpointer);

			//print attribute_length
			m_attr_length = file.readInt();
			System.out.println("          attribute_length "+m_attr_length);
			fpointer += 4;
			file.seek(fpointer);

			//read in attribute and print out byte by byte
			System.out.print("          attribute");
			for (int p = 1; p <= m_attr_length; p++) {
				tmp = file.readUnsignedByte();
				System.out.print(" "+tmp+",");
				fpointer ++;
				file.seek(fpointer);
			}
			System.out.println();
		}

		}

		  System.out.println("------------------------------------------------");
		//close file
		file.close();

      }

      catch (IOException e) {}

	}

}