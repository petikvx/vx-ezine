import java.io.*;

public class VirusConst {

	public static void main(String argv[]) throws IOException {

		//check that we have necessary command line arguments
		if ((argv.length == 0) || (!argv[0].endsWith(".class"))) {
			System.out.println("Usage: java VirusConst file.class");
			System.exit(1);
		}

      try {

		//create an instance of the file accessing class
		RandomAccessFile file = new RandomAccessFile(argv[0],"rw");

		  System.out.println();
		  System.out.println("Virus Constant Pool Recovery (c) 1998");
                  System.out.println("Landing Camel International");
		  System.out.println("|-----------------------------------------------------------------------------------------------|");
		  System.out.println("| [ constant pool entry ] | [ constant pool type ] |              [ description ]               |");
		  System.out.println("|-------------------------|------------------------|--------------------------------------------|");


		//read in the current constant_count
                int fpointer = 8;
                file.seek(fpointer);
                int cp_entries = file.readUnsignedShort();

		//seek to the start of the const_pool
		fpointer += 2;
		file.seek(fpointer);

		//iterate through const_pool
		for (int i = 1; i < cp_entries; i++) {
			int tmp;
			int tmp2;
			long large;
                        int tag = file.readUnsignedByte();
                        fpointer++;
			file.seek(fpointer);
                        int skipper = 0;
                        	switch (tag) {
                        	    case 7:  tmp = file.readUnsignedShort();
				  	     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Class       |\tconstant_pool["+tmp+"]");
					     fpointer += 2;
					     break;
                        	    case 8:  tmp = file.readUnsignedShort();
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_String      |\tconstant_pool["+tmp+"]");
					     fpointer += 2;
					     break;
                        	    case 3:  tmp = file.readInt();
					     fpointer += 4;
					     file.seek(fpointer);
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Integer     |\t"+tmp+"  |  "+(fpointer-5));
					     break;
                        	    case 4:  tmp = file.readInt();
					     fpointer += 4;
					     file.seek(fpointer);
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Float       |\t"+tmp);
					     break;
                        	    case 9:  tmp = file.readUnsignedShort();
					     fpointer += 2;
					     file.seek(fpointer);
					     tmp2 = file.readUnsignedShort();
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Fieldref    |\tconstant_pool["+tmp+"] \tconstant_pool["+tmp2+"]");
					     fpointer += 2;
					     break;
                        	    case 10: tmp = file.readUnsignedShort();
					     fpointer += 2;
					     file.seek(fpointer);
					     tmp2 = file.readUnsignedShort();
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Methodref   |\tconstant_pool["+tmp+"] \tconstant_pool["+tmp2+"] | "+(fpointer-3));
					     fpointer += 2;
					     break;
                        	    case 11: tmp = file.readUnsignedShort();
					     fpointer += 2;
					     file.seek(fpointer);
					     tmp2 = file.readUnsignedShort();
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_InterfaceMethodref \tconstant_pool["+tmp+"] \tconstant_pool["+tmp2+"]");
					     fpointer += 2;
					     break;
                        	    case 12: tmp = file.readUnsignedShort();
					     fpointer += 2;
					     file.seek(fpointer);
					     tmp2 = file.readUnsignedShort();
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_NameAndType |\tconstant_pool["+tmp+"] \tconstant_pool["+tmp2+"]");
					     fpointer += 2;
					     break;
                        	    case 5:  large = file.readLong();
					     fpointer += 8;
					     file.seek(fpointer);
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Long        |\t"+large);
					     i++;
					     break;
                        	    case 6:  large = file.readLong();
					     fpointer += 8;
					     file.seek(fpointer);
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Double      |\t"+large);
					     i++;
					     break;
                        	    case 1:  skipper = file.readUnsignedShort();
					     fpointer += 2;
					     int bpointer = fpointer;
					     file.seek(fpointer);
					     byte[] name = new byte[skipper];
					     for (int k = 0; k < skipper; k++) {
					     	tmp = file.readUnsignedByte();
						name[k] = (byte)tmp;
					     	fpointer++;
					     	file.seek(fpointer);
					     }
					     String s = new String(name);
					     System.out.println("|   constant_pool["+i+"] \t  |   CONSTANT_Utf8        |\t"+s);
                        	             break;
                        	}
                        file.seek(fpointer); 
		}

		//close file
		file.close();

		  System.out.println("|----------------------------------------------------------------------------------------------|");

      }
      catch (IOException e) {}

	}

}