import java.net.ServerSocket;
import java.net.Socket;
import java.util.Vector;
import java.io.IOException;
import java.util.Date;

public class TCPReflector implements ConnectionMonitor
{
   private int          portNumber     = -1;
   private String       destHost       = null;
   private int          destPortNumber = -1;
   private boolean      echo           = false;
   private boolean      quiet          = false;
   private ServerSocket mainSocket     = null;
   private Vector       connections    = null;

   private static final String border =
   "########################################################################";

   public TCPReflector(String args[]) throws Exception
   {
      boolean error = false;

      try
      {
         processArgs(args);
      }
      catch(Exception e)
      {
         System.out.println("ERROR: " + e.getMessage() + "\n");
         error = true;
      }

System.out.println(portNumber +" "+ destPortNumber +" "+ destHost);

      if(portNumber <= 0 || destPortNumber <= 0 || destHost == null)
         error = true;

      if(error)
      {
         usage();
         System.exit(-1);
      }

      connections = new Vector();
      mainSocket  = new ServerSocket(portNumber);

      printMsg(
         "Starting program: " + getClass().getName(),
         "On port number  : " + portNumber,
         "Dest host:port  : " + destHost + ":" + destPortNumber
      );
   }

   private int parsePort(int i, String args[]) throws Exception
   {
      int value = 0;

      if(i >= args.length)
      {
         throw new Exception(
            "Expected numeric argument after -port"
         );
      }

      try
      {
         value = Integer.parseInt(args[i]);
      }
      catch(NumberFormatException e) {}

      if(value <= 0)
      {
         throw new Exception(
            "Value for -port must be a valid integer > 0 [" + args[i] + "]"
         );
      }

      return(value);
   }

   private void parseDest(int i, String args[]) throws Exception
   {
      if(i >= args.length)
      {
         throw new Exception(
            "Expected argument after -dest"
         );
      }

      int colonIndex = args[i].indexOf(':');

      if(colonIndex == -1)
      {
         throw new Exception(
            "Expected ':' separator in argument to -dest [" + args[i] + "]"
         );
      }

      String s1 = args[i].substring(0, colonIndex).trim();
      String s2 = args[i].substring(colonIndex + 1).trim();

      if(s1.equals(""))
      {
         throw new Exception(
            "Missing host name in argument to -dest [" + args[i] + "]"
         );
      }

      int value = 0;

      try
      {
         value = Integer.parseInt(s2);
      }
      catch(NumberFormatException e) {}

      if(value <= 0)
      {
         throw new Exception(
            "Port number for -dest argument must be an integer > 0 [" +
            args[i] + "]"
         );
      }

      destHost       = s1;
      destPortNumber = value;
   }

   private void processArgs(String args[]) throws Exception
   {
      int i = 0;

      while(i < args.length)
      {
         String s = args[i].toLowerCase();

         if(s.equals("-echo"))
            echo = true;

         else if(s.equals("-quiet"))
            quiet = true;

         else if(s.equals("-port"))
         {
            portNumber = parsePort(++i, args);
         }

         else if(s.equals("-dest"))
         {
            parseDest(++i, args);
         }
         else
         {
            throw new Exception(
               "Unrecognized argument: [" + args[i] + "]"
            );
         }
         i++;
      }
   }

   public static void usage()
   {
      System.out.println("Usage: program <args>");
      System.out.println("   -port listenPort");
      System.out.println("   -dest destHost:destPortNumber");
      System.out.println("   -echo");
      System.out.println("   -quiet");
      System.out.println("");
      System.out.println("-port and -dest are required");
   }

   private void printMsg(String s1)
   {
      String msg[] = new String[1];
      msg[0]       = s1;
      printMsg(msg);
   }

   private void printMsg(String s1, String s2)
   {
      String msg[] = new String[2];
      msg[0]       = s1;
      msg[1]       = s2;
      printMsg(msg);
   }

   private void printMsg(String s1, String s2, String s3)
   {
      String msg[] = new String[3];
      msg[0]       = s1;
      msg[1]       = s2;
      msg[2]       = s3;
      printMsg(msg);
   }

   private void printMsg(String msg[])
   {
      if(!quiet)
      {
         System.out.println(border);
         System.out.println("# " + new Date().toString());

         for(int i = 0; i < msg.length; i ++)
            System.out.println("# " + msg[i]);

         System.out.println(border + "\n");
      }
   }

   public void serve()
   {
      while(true)
      {
         try
         {
            Socket newSocket = mainSocket.accept();

            new Connection(newSocket, (ConnectionMonitor)this, 
               destHost, destPortNumber, echo);
         }
         catch(IOException e) {}
      }
   }

   public void attemptingConnection(Connection c)
   {
      printMsg(
         getClass().getName(),
         "Connection initiated from: " + c.getSrcHost()
      );
   }

   public void addConnection(Connection c)
   {
      printMsg(
         getClass().getName(),
         "Connection established from: " + c.getSrcHost()  + ":" +
            portNumber, 
         "To                         : " + c.getDestHost() + ":" + 
            c.getDestPort()
      );

      synchronized(connections)
      {
         connections.addElement(c);
      }
   }

   public void removeConnection(Connection c)
   {
      printMsg(
         getClass().getName(),
         "Removing connection from: " + c.getSrcHost()  + ":" +
            portNumber, 
         "To                      : " + c.getDestHost() + ":" + 
            c.getDestPort()
      );

      synchronized(connections)
      {
         connections.removeElement(c);
      }
   }

   public void connectionError(Connection c, String errMsg)
   {
      printMsg(
         getClass().getName(),
         "Error involving connection from:" + c.getSrcHost()  + ":" +
            portNumber, 
         errMsg
      );
   }

   public static void main(String args[]) throws Exception
   {
      TCPReflector t = new TCPReflector(args);
      t.serve();
   }
}
