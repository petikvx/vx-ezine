import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

class Agent implements Runnable
{
   private InputStream in           = null;
   private OutputStream out         = null;
   private AgentMonitor am          = null;
   private byte buffer[]            = null;
   private static int BUFFER_SIZE   = 4096;
   private String name              = null;
   private boolean echo             = false;

   public Agent(
      InputStream in,
      OutputStream out,
      AgentMonitor am,
      String name,
      boolean echo
   )
   {
      this.in   = in;
      this.out  = out;
      this.am   = am;
      this.name = new String(name);
      this.echo = echo;

      buffer = new byte[BUFFER_SIZE];

      Thread t = new Thread(this);
      t.start();
   }

   public void run()
   {
      try 
      {
         int bytesRead = 0;

         while(true)
         {
            if((bytesRead = in.read(buffer, 0, BUFFER_SIZE)) == -1)
               break;

            if(echo)
               doEcho(buffer, bytesRead);

            out.write(buffer, 0, bytesRead);
         }
      }
      catch(IOException e) {}
      am.agentHasDied(this);
   }

   private void doEcho(byte buffer[], int nBytes)
   {
      synchronized(System.out)
      {
         System.out.println("[" + name + ", (" + nBytes + " bytes)]");

         StringBuffer sb = new StringBuffer("");

         for(int i = 0; i < nBytes; i ++)
         {
            int value = (buffer[i] & 0xFF);

            if(value == '\r' || value == '\n' || 
               (value >= ' ' && value <= '~'))
            
            {
               sb.append((char)value);
            }
            else
               sb.append("[" + value + "]");
         }
         System.out.println(sb.toString());
      }
   }
}
