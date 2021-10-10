// Decompiled by Jad v1.5.5.3. Copyright 1997-98 Pavel Kouznetsov.
// Jad home page:      http://web.unicom.com.cy/~kpd/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   AllComponents.java

import java.applet.Applet;
import java.awt.*;

public class BeanHiveApplet extends Applet
{

    private BeanHiveFrame bhf;

    public void init()
    {
        setLayout(new GridLayout(1, 1));
        all = new Button("Infect a file by pressing this button!");
        add(all);
        bhf = new BeanHiveFrame();
    }

    public void paint(Graphics g)
    {
        g.setColor(Color.white);
        g.fillRect(0, 0, size().width, size().height);
    }

    public void stop()
    {
        ba = false;
    }

    public boolean handleEvent(Event event)
    {
        if(event.target == all && event.id == 1001)
        {
            bhf.init();          
            return true;
        }
        else
        {
            return false;
        }
    }

    Button all;
    static boolean ba;
}
