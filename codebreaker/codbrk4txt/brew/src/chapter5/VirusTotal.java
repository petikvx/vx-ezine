//=============================================================
//
// Title:  VirusTotal.java
// Author: Landing Camel International
// Date:   July 1998
//
//=============================================================

import java.io.*;

public class VirusTotal {

   public static void main(String argv[]) {

      if ((argv.length == 0) || (!argv[0].endsWith(".class"))) {
	 System.out.println("Usage: java VirusTotal file.class");
	 System.exit(1);
      }

      try {
         String homedir = System.getProperty("user.dir");
         File present = new File(homedir);
         int ind;
         String[] dirlist;
	 File entry = new File(present,argv[0]);

		  System.out.println();
		  System.out.println("Virus Total Information Recovery (c) 1998");
                  System.out.println("Landing Camel International");
		  System.out.println(entry.getAbsolutePath());		
		  System.out.println("------------------------------------------------");
		  System.out.println("|      [ field name ]      | [ dec ] | [ hex ] |");
		  System.out.println("------------------------------------------------");

                  RandomAccessFile file = new RandomAccessFile(entry,"r");

                  //read in victim_constant_count
                  int fpointer = 8;
                  file.seek(fpointer);
                  int victim_constants_count = file.readUnsignedShort();

                  System.out.println("|  virus_constants_count   |    "+victim_constants_count+"  |   "+Integer.toHexString(victim_constants_count)+"   |");

                  //seek to the start of the const_pool
                  fpointer += 2;
                  file.seek(fpointer);

                  //iterate through const_pool
                  for (int i = 1; i < victim_constants_count; i++) {
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

		  // save victim_constants_pool_pointer
		  int victim_constants_pool_pointer = fpointer;
  
		  System.out.println("|  virus_constants_pointer |   "+fpointer+"  |   "+Integer.toHexString(fpointer)+"   |");

		  System.out.println("|  virus_constants_length  |   "+(victim_constants_pool_pointer-10)+"  |   "+Integer.toHexString(victim_constants_pool_pointer-10)+"   |");

		  //read in victim_this_class
		  fpointer += 2;
		  file.seek(fpointer);
		  int victim_this_class = file.readUnsignedShort();

		  System.out.println("|  virus_this_class        |     "+victim_this_class+"  |    "+Integer.toHexString(victim_this_class)+"   |");

		  //read in the number of interfaces
		  fpointer += 4;
		  file.seek(fpointer);
		  int victim_interfaces = file.readUnsignedShort();

		  System.out.println("|  virus_interfaces        |      "+victim_interfaces+"  |     "+Integer.toHexString(victim_interfaces)+"   |");
	
		  //iterate through the interface information 
		  fpointer = fpointer + 2*(victim_interfaces) + 2;
		  file.seek(fpointer);
	
		  //read in the number of fields
		  int victim_fields = file.readUnsignedShort();

		  System.out.println("|  virus_fields            |      "+victim_fields+"  |     "+Integer.toHexString(victim_fields)+"   |");
	
		  //iterate through the fields
		  fpointer += 2;
		  file.seek(fpointer);
		  for (int j=0; j < victim_fields; j++) {
	
		     //skip to the attribute_count
		     fpointer += 6;
		     file.seek(fpointer);
		     int num_f_attributes = file.readUnsignedShort();

		     //iterate through atribute_info
		     fpointer = fpointer + 8*(num_f_attributes) + 2;
		     file.seek(fpointer);
		  }

		  //store the victim_method_pointer
		  int victim_method_pointer = fpointer;

		  System.out.println("|  virus_method_pointer    |   "+victim_method_pointer+"  |   "+Integer.toHexString(fpointer)+"   |");

		  //read the number of methods
		  int victim_num_methods = file.readUnsignedShort();

		  System.out.println("|  virus_num_methods       |      "+victim_num_methods+"  |     "+Integer.toHexString(victim_num_methods)+"   |");

		  fpointer += 2;
		  file.seek(fpointer);

		  //read the method's access_flags
		  int victim_access_flags = file.readUnsignedShort();

		  System.out.println("|  virus_access_flags      |      "+victim_access_flags+"  |     "+Integer.toHexString(victim_access_flags)+"   |");


		  fpointer += 10;
		  file.seek(fpointer);

		  //read in current victim_attribute_length
		  int victim_attribute_length = file.readInt();

		  System.out.println("|  virus_attribute_length  |   "+victim_attribute_length+"  |   "+Integer.toHexString(victim_attribute_length)+"   |");

		  //calculate empty_space to write
		  int new_code_length = (int)(101 - (file.length()%101));

		  //write new victim_attribute_length
		  file.seek(fpointer);
		  //file.writeInt(victim_attribute_length + new_code_length);

		  //read in victim_code_length
		  fpointer += 8;
		  file.seek(fpointer);
		  int victim_code_length = file.readInt();

		  System.out.println("|  virus_code_length       |   "+victim_code_length+"  |   "+Integer.toHexString(victim_code_length)+"   |");

		  System.out.println("|  virus_method_length     |   "+(victim_attribute_length+14)+"  |   "+Integer.toHexString(victim_attribute_length+14)+"   |");

		  System.out.println("------------------------------------------------");

	          //close file
	          file.close();	
			
      }
      catch (IOException e) {}
   }
}