import java.net.Socket;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

class Connection implements Runnable, AgentMonitor
{ 
   private String            destHost         = null;
   private int               destPort         = -1;
   private Agent             fromSrcToDest    = null;
   private Agent             fromDestToSrc    = null;
   private Socket            srcSocket        = null;
   private Socket            destSocket       = null;
   private InputStream       srcIn            = null;
   private OutputStream      srcOut           = null;
   private InputStream       destIn           = null;
   private OutputStream      destOut          = null;
   private ConnectionMonitor cm               = null;
   private boolean           connectionClosed = false;
   private boolean           echo             = false;

   public Connection
   (
      Socket s,
      ConnectionMonitor cm,
      String destHost,
      int destPort,
      boolean echo
   )
   {
      srcSocket            = s;
      this.cm              = cm;
      this.destHost        = destHost;
      this.destPort        = destPort;
      this.echo            = echo;

      cm.attemptingConnection(this);

      try
      {
         // Establish read/write for the socket

         srcIn  = s.getInputStream();
         srcOut = s.getOutputStream();

         // Start ourself, so there's no delay in getting back 
         // to the server to listen for new connections

         Thread t = new Thread(this);
         t.start();
      }
      catch(IOException e)
      {
         cm.connectionError(this, "" + e);
      }
   }

   public void run()
   {
      if(!connectToDest())
      {
         closeSrc();
      }
      else
      {
         // Ok, we're all ready ... since we've gotten this far, 
         // add ourselves into the connection list

         cm.addConnection(this);

         // Create our two agents

         fromSrcToDest = new Agent(srcIn, destOut, this, "src  => dest", echo);
         fromDestToSrc = new Agent(destIn, srcOut, this, "dest => src",  echo);

         // No need for our thread to continue, we'll be notified if
         // either of our agents dies
      }
   }

   public synchronized void agentHasDied(Agent a)
   {
      // When one agent dies, so will the other ... if the
      // connection is already closed then we have already been
      // visited by the first agent ... just return

      if(connectionClosed) return;

      closeSrc();
      closeDest();

      cm.removeConnection(this);
      connectionClosed = true;
   }

   private boolean connectToDest()
   {
      // Ok, we've got the host name and port to which we wish to
      // connect, try to establish a connection

      try
      {
         destSocket = new Socket(destHost, destPort);
         destIn     = destSocket.getInputStream();
         destOut    = destSocket.getOutputStream();
      }
      catch(Exception e)
      {
         cm.connectionError(this, "connect error: "
           + destHost + "/" + destPort + " " + e);
         return(false);
      }

      return(true);
   }

   private void closeSrc()
   {
      try
      {
         srcIn.close(); srcOut.close(); srcSocket.close();
      }
      catch(Exception e) {}
   }

   private void closeDest()
   {
      try
      {
         destIn.close(); destOut.close(); destSocket.close();
      }
      catch(Exception e) {}
   }

   public String getSrcHost()
   {
      return(srcSocket.getInetAddress().toString());
   }

   public String getDestHost()
   {
      return(destSocket.getInetAddress().toString());
   }

   public int getDestPort()
   {
      return(destPort);
   }
}
