
                      +---------------------------+
                      |   ANTI-SOCIAL  MAGAZINE   |
                      +===========================+    
                      |       R E A D   M E       |
                      +---------------------------+
                      |  www.antisocial.cjb.net   | 
                      +---------------------------+
                               
                                 01/01/2000
                               =============


  TROUBLE SHOOTING
=====================

Q.  I've downloaded an issue of A-S Magazine, but have nothing to view the
    .DAT file with, what's wrong??

A.  You need to download the correct viewer for the issue you've downloaded,
    Issues 1-18 use the DOS viewer, found on our web site as "as-view.zip"
    Issues 19+ will use the new Win32 viewer which is available from our 
    web site, file named :  "asviewX.zip"   [X = the number of the version
    for the win32, starting with "as-view4.zip" later versions might be 
    released in the months to come]


Q.  I've downloaded A-S #19 (or later) and the correct viewer but can not 
    get it to work, what do I need to do??

A.  It's most likely that you don't have DirectX installed.  The viewer 
    will work with various versions of directX, but it works best with 
    Version 6.0 or later.  You can download a copy of DirectX 6.0 at the 
    following web site:-
                http://www.matroxusers.com/Driver/DirectX.html


Q.  The interface is running slowly, is there anyway of making it run faster?

A.  This viewer was designed for P133 processors or above, as most people 
    won't have anything slower then this, it should still run fine.  However,
    if you do find it running a bit slow you can make it run faster by
    limiting the viewer to 16 Bits Per Pixel, to do this load the viewer 
    from the command line with the /hicolor switch.


Q.  I've tried the search mode, it seem to work fine, but when I have search
    for a world and get multiple articles to pick from containing that word.
    When I select any article but the first, I still get taken to the first,
    is this a bug??

A.  Not really, your simply using an old COMCTL32.DLL which is characteristic
    with an old version of Windows Explorer.  Update this libery file and you
    should have no problems - in future versions of the viewer plan to work
    around any chance of this occuring.


Q.  I want to keep the colours high, but the when various effects in the
    interface occur (i.e. crossfading) the viewer really slows down, how
    do I correct this problem???

A.  Switch off the viewers effects by using the command line switch
    /noeffects  This will reduce the power needed by the interface, but will 
    also limit the overall look of the interface as you'll be losing out on
    lots of good effects including smooth scrolling and cross-fading.


Q.  I have a scroll wheel, you claim to support these but I can not get mine
    to work in your interface - how do I fix this problem???

A.  The problem with scroll wheels is the fact there are 3 standards, your
    problem is most likely being caused because your mouse wheel is sending
    WM_VSCROLL messages.  In order to make your scroll wheel work, you will
    need to load the interface up with the command line switch /weirdwheel


Q.  The interface locks up on the opening screen.......How do I fix this??

A.  This is a rare problem, but in the event that it does happen, you can
    get the viewer to load by using the  /novsync  switch.








