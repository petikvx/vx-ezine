// Decompiled by Jad v1.5.5.3. Copyright 1997-98 Pavel Kouznetsov.
// Jad home page:      http://web.unicom.com.cy/~kpd/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   NetscapeApplet.java

import netscape.application.FoundationApplet;

public class BeanHiveApplet extends FoundationApplet
{

    public Class classForName(String s)
        throws ClassNotFoundException
    {
        return Class.forName(s);
    }

}
