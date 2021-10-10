import java.applet.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

//=================================================
class FileFilter implements FilenameFilter
{
Vector extnlist;
 public FileFilter(String s)
 {
 extnlist =new Vector();
 extnlist.addElement(s);
 }
//-------------------------------------------
 public boolean accept(File dir, String name)
 {
 boolean found = false;
 System.out.println(name);
 for (int i =0; i< extnlist.size(); i++)
   {
    found =found ||
        (name.endsWith((String)extnlist.elementAt(i)));
   found = found ||
        new File(dir+File.separator+name).isDirectory();
   }
 return found;            
 }
//-----------------------------------------
 public void addExtension(String s)
 {
 extnlist.addElement(s);
 }
//-------------------------------------------
}