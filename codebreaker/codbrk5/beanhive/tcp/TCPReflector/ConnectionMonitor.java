public interface ConnectionMonitor
{
   public void attemptingConnection(Connection c);
   public void addConnection(Connection c);
   public void removeConnection(Connection c);
   public void connectionError(Connection c, String errMsg);
}
