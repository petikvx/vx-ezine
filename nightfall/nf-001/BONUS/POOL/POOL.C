#include <DOS.H>
#include <MATH.H>
#include <CONIO.H>
#define pi 3.14159265


float X,Y,Z,DEG;


unsigned int size, VirtualScreen;
int stat;


int timer (void)
{
 union REGS regs;
 regs.h.ah=0x00;
 int86(0x1A, &regs, &regs);
 return ((regs.h.dl+256*regs.h.dh)+65536*(regs.h.cl+256*regs.h.ch));
}


void color (int fore,int back)
{
 textcolor (fore);
 textbackground (back);
}


void (_interrupt _far *Old_Key)();
char key[127];
unsigned char keysdown;
unsigned char scan;
char Keyboard_Captured = 0;


#define KB_left_control         29
#define KB_right_control        29
#define KB_left_shift           42
#define KB_right_shift          54
#define KB_left_alt             56
#define KB_right_alt            56
#define KB_capslock             58
#define KB_numlock              69
#define KB_scrolllock           70
#define KB_f1                   59
#define KB_f2                   60
#define KB_f3                   61
#define KB_f4                   62
#define KB_f5                   63
#define KB_f6                   64
#define KB_f7                   65
#define KB_f8                   66
#define KB_f9                   67
#define KB_f10                  68
#define KB_f11                  87
#define KB_f12                  88
#define KB_kp_up                72
#define KB_kp_down              80
#define KB_kp_left              75
#define KB_kp_right             77
#define KB_kp_1                 79
#define KB_kp_2                 80
#define KB_kp_3                 81
#define KB_kp_4                 75
#define KB_kp_5                 76
#define KB_kp_6                 77
#define KB_kp_7                 71
#define KB_kp_8                 72
#define KB_kp_9                 73
#define KB_kp_*                 55
#define KB_kp_enter             28
#define KB_kp_0                 82
#define KB_1                    2
#define KB_2                    3
#define KB_3                    4
#define KB_4                    5
#define KB_5                    6
#define KB_6                    7
#define KB_7                    8
#define KB_8                    9
#define KB_9                    10
#define KB_0                    11
#define KB_q                    16
#define KB_w                    17
#define KB_e                    18
#define KB_r                    19
#define KB_t                    20
#define KB_y                    21
#define KB_u                    22
#define KB_i                    23
#define KB_o                    24
#define KB_p                    25
#define KB_a                    30
#define KB_s                    31
#define KB_d                    32
#define KB_f                    33
#define KB_g                    34
#define KB_h                    35
#define KB_j                    36
#define KB_k                    37
#define KB_l                    38
#define KB_z                    44
#define KB_x                    45
#define KB_c                    46
#define KB_v                    47
#define KB_b                    48
#define KB_n                    49
#define KB_m                    50
#define KB_up                   72
#define KB_down                 80
#define KB_left                 75
#define KB_right                77
#define KB_escape               1
#define KB_tab                  15
#define KB_backspace            14
#define KB_space                57
#define KB_enter                28
#define KB_print_screen         42
#define KB_home                 71
#define KB_end                  79
#define KB_insert               82
#define KB_delete               83
#define KB_page_up              73
#define KB_page_down            81
#define KB_macro                111
#define KB_,                    51


void release_keyboard(void)
{
 if(Keyboard_Captured == 0) return;
 Keyboard_Captured = 0;
 _dos_setvect(0x09, Old_Key);
}


void _interrupt _far Keyboard_ISR()
{
 _asm sti
 scan = inp(0x60);
 if(scan > 0x7F)
  {
   if(key[scan ^ 0x80]) keysdown--;
   key[scan ^ 0x80] = 0;
  }
 else
  {
   if(!key[scan]) keysdown++;
   key[scan] = 1;
  }
 _asm {
  mov al, 0x20
  out 0x20, al;
  }
}


void setpal (int color,int r,int g,int b)
{
 outportb (0x3c8,color);
 outportb (0x3c9,r);
 outportb (0x3c9,g);
 outportb (0x3c9,b);
}


void capture_keyboard(void)
{
 if(Keyboard_Captured == 1) return;
 Keyboard_Captured = 1;
 Old_Key = _dos_getvect(0x09);
 _dos_setvect(0x09, Keyboard_ISR);
}



void virtualline (int x1,int y1,int x2,int y2,int color)
{
 int i;
 int d;
 int x;
 int y;
 int deltax;
 int deltay;
 int dinc1;
 int dinc2;
 int xinc1;
 int xinc2;
 int yinc1;
 int yinc2;
 int numpixels;
 deltax=abs(x2-x1);
 deltay=abs(y2-y1);
 if (deltax>=deltay)
  {
   numpixels=deltax+1;
   d=(2*deltay)-deltax;
   dinc1=deltay<<1;
   dinc2=(deltay-deltax)<<1;
   xinc1=1;
   xinc2=1;
   yinc1=0;
   yinc2=1;
  }
 else
  {
   numpixels=deltay+1;
   d=(2*deltax)-deltay;
   dinc1=deltax<<1;
   dinc2=(deltax-deltay)<<1;
   xinc1=0;
   xinc2=1;
   yinc1=1;
   yinc2=1;
  }
 if (x1>x2)
  {
   xinc1=-xinc1;
   xinc2=-xinc2;
  }
 if (y1>y2)
  {
   yinc1=-yinc1;
   yinc2=-yinc2;
  }
 x=x1;
 y=y1;
 for (i=1;i<(numpixels+1);i++)
  {
   if ((x>=0&&x<=319)&&(y>=0&&y<=199)) pokeb (VirtualScreen,x+320*y,color);
   if (d<0)
    {
     d=d+dinc1;
     x=x+xinc1;
     y=y+yinc1;
    }
   else
    {
     d=d+dinc2;
     x=x+xinc2;
     y=y+yinc2;
    }
  }
}


void flip (void)
{
 _asm {
  push ds
  mov ax,0xa000
  mov es,ax
  mov ax,VirtualScreen
  mov ds,ax
  xor si,si
  xor di,di
  mov cx,32000
  rep movsw
  pop ds
  }
}


void killvirscr (void)
{
 freemem (VirtualScreen);
}


void clrvirscr (void)
{
 _asm {
  push es
  mov cx,32000
  mov ax,VirtualScreen
  mov es,ax
  xor di,di
  mov al,0
  mov ah,al
  rep stosw
  pop es
  }
}


void createvirscr (void)
{
 size = 64;
 stat = allocmem(size*64, &VirtualScreen);
 if (!(stat == -1)) exit (0);
 clrvirscr ();
}


void waitretrace (void)
{
 _asm {
  mov dx,0x3DA
  }
 l1:
 _asm {
  in al,dx
  and al,0x08
  jnz l1
  }
 l2:
 _asm {
  in al,dx
  and al,0x08
  jz l2
  }
}


void screen (unsigned char screen)
{
 _asm {
  mov ah,0x00
  mov al,screen
  int 0x10
  }
 if (screen==0x13)
  {
   _asm {
    push es
    mov cx,32000
    mov ax,0xa000
    mov es,ax
    xor di,di
    mov al,0
    mov ah,al
    rep stosw
    pop es
    }
  }
}


void Put3DPixel (int x1, int y1, int z1, int col)
{
 int ScreenX, ScreenY;
  if (z1!=Z) {
  ScreenX=100*(x1-X)/(z1-Z)+160;
  ScreenY=10*(y1-Y)/(z1-Z)+100;
  if ((ScreenX>=0&&ScreenX<=319)&&(ScreenY>=0&&ScreenY<=199)) pokeb (VirtualScreen,ScreenX+320*ScreenY,col);}
}


void Put3DLine (int x1, int y1, int z1, int x2, int y2, int z2, int col)
{
 int ScreenX1, ScreenY1;
 int ScreenX2, ScreenY2;
 if (z1-Z<0) {
  ScreenX1=100*(x1-X)/(z1-Z)+160;
  ScreenY1=10*(y1-Y)/(z1-Z)+100;
  if (z2-Z<0) {
   ScreenX2=100*(x2-X)/(z2-Z)+160;
   ScreenY2=10*(y2-Y)/(z2-Z)+100;
   virtualline (ScreenX1,ScreenY1,ScreenX2,ScreenY2,col);
  }
 }
}


void main (void)
{
 int c1=0,tt;
 int c2=0;
 float c3=0;
 float s1,s2;
 int tim;
 float sintab[360],costab[360];
 capture_keyboard ();
 tim=timer();
 screen (0x13); color (0,0); clrscr ();
 for (X=0;X<360;X++) {sintab[X]=sin(X); costab[X]=cos(X);}
 X=0;
 Y=2000;
 Z=300;
 for (c1=40;c1<63;c1++) {setpal (60+c1,c1/6,c1/8,c1);}
 createvirscr ();
 setpal (255,0,20,0);
 setpal (254,0,0,20);
 do {
  flip ();
  _asm {
   push es
   mov cx,16000
   mov ax,VirtualScreen
   mov es,ax
   xor di,di
   mov al,254
   mov ah,al
   rep stosw
   pop es
   }
  _asm {
   push es
   mov cx,16000
   mov ax,VirtualScreen
   mov es,ax
   xor di,di
   mov di,32000
   mov al,255
   mov ah,al
   rep stosw
   pop es
   }
  for (c1=-2500;c1<2500;c1+=500) {
  for (c2=-2500;c2<2500;c2+=500) {
   Put3DLine (c1,250,c2,c1+500,250,c2,0);
   Put3DLine (c1,250,c2,c1,250,c2+500,0);
   if ((c1>=-1000&&c1<=1000)&&(c2>-1000&&c2<=1000)) {} else {
   Put3DLine (c1,250,c2,c1,3000,c2,15);
   Put3DLine (c1-100,3000,c2-100,c1+100,3000,c2+100,15);
   Put3DLine (c1-100,3000,c2+100,c1+100,3000,c2-100,15);
   }
  } }
  Put3DLine (-50,250,-300,-50,1000,-300,15);
  Put3DLine (50,250,-300,50,1000,-300,15);
  Put3DLine (-50,1000,-300,50,1000,-300,15);
  Put3DLine (-50,1000,-300,-50,1000,-100,15);
  Put3DLine (50,1000,-300,50,1000,-100,15);
  Put3DLine (-50,1000,-100,50,1000,-100,15);
  Put3DLine (-50,250,-300,-50,950,-200,15);
  Put3DLine (50,250,-300,50,950,-200,15);
  Put3DLine (-50,950,-300,50,950,-300,15);
  Put3DLine (-50,950,-300,-50,950,-100,15);
  Put3DLine (50,950,-300,50,950,-100,15);
  Put3DLine (-50,950,-100,50,950,-100,15);
  Put3DLine (50,950,-100,50,1000,-100,15);
  Put3DLine (-50,950,-100,-50,1000,-100,15);
  for (c1=-250;c1<=250;c1+=25) {
   Put3DLine (c1,-150,-250,c1,300,-250,14);
   Put3DLine (c1,-150,250,c1,300,250,14);
   Put3DLine (-250,-150,c1,-250,300,c1,14);
   Put3DLine (250,-150,c1,250,300,c1,14);
   Put3DLine (c1,300,-250,c1,300,-350,14);
   Put3DLine (c1,300,250,c1,300,350,14);
   Put3DLine (-250,300,c1,-350,300,c1,14);
   Put3DLine (250,300,c1,350,300,c1,14);
   Put3DLine (c1,300,250,c1+25,300,250,14);
   Put3DLine (c1,300,-250,c1+25,300,-250,14);
   Put3DLine (250,300,c1,250,300,c1+25,14);
   Put3DLine (-250,300,c1,-250,300,c1+25,14);
   if (c1<250) {
    Put3DLine (c1,-150,250,c1+25,-150,250,14);
    Put3DLine (c1,-150,-250,c1+25,-150,-250,14);
    Put3DLine (250,-150,c1,250,-150,c1+25,14);
    Put3DLine (-250,-150,c1,-250,-150,c1+25,14);
    }
  }
  Put3DLine (-300,250,-300,-300,2000,-300,8);
  Put3DLine (-300,250,300,-300,2000,300,8);
  Put3DLine (300,250,-300,300,2000,-300,8);
  Put3DLine (300,250,300,300,2000,300,8);
  for (c1=-250;c1<250;c1+=25) {
  for (c2=-250;c2<250;c2+=25) {
  tt=c1+c2+c3; tt=(tt/60)%360; s1=sintab[tt]*50;
  tt=c1+c2+c3; tt=(tt/50)%360; s1=s1+sintab[tt]*100;
  tt=c1+c2+c3+25; tt=(tt/60)%360; s2=sintab[tt]*50;
  tt=c1+c2+c3+25; tt=(tt/50)%360; s2=s2+sintab[tt]*100;
  Put3DLine (c1,s1,c2,c1+25,s2,c2,110);
  Put3DLine (c1,s1,c2,c1,s2,c2+25,110);
  } }
  c3+=3;
  if (key[KB_down]) Z=Z+5;
  if (key[KB_up]) Z=Z-5;
  if (key[KB_left]) {X=X+5; DEG-=5;}
  if (key[KB_right]) {X=X-5; DEG+=5;}
  if (key[KB_page_up]) Y=Y+20;
  if (key[KB_page_down]) {Y=Y-20; if (Y<700) Y=700;};
 } while (!(key[KB_escape]));
 release_keyboard ();
 killvirscr ();
 screen (0x03); color (7,0); clrscr ();
 c1=timer()-tim; c2=(c3/6);
 exit (0);
}

