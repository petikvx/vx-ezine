//=============================================================
//
// Title:  a98b34f2.java
// Author: Landing Camel International
// Date:   January 1999
//
// Notes:  This class will keep track of and update the fpointer
//
//=============================================================

import java.io.*;

public class a98b34f2 {

   public int fpointer = 0;
   private RandomAccessFile file;

   //----------------------------------------------------------
   public a98b34f2(RandomAccessFile file) throws IOException {
   	
      this.file = file;
      
   } // end Pointer()
   //----------------------------------------------------------	

   //----------------------------------------------------------
   public void seek() throws IOException {
   	
      file.seek(fpointer);
      
   } //end seek()
   //----------------------------------------------------------

   //----------------------------------------------------------
   public void seek(int offset) throws IOException {
   	
      fpointer = offset;
      file.seek(fpointer);
      
   } //end seek()
   //----------------------------------------------------------

   //----------------------------------------------------------
   public void update(int offset) throws IOException {
      
      fpointer += offset;
      file.seek(fpointer);

   } // end update()
   //----------------------------------------------------------
   
}
