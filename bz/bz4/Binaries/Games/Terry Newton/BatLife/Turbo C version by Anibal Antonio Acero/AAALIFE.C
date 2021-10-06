
/*  This is an implementation of Conway's Life simulation
    using an algorithm hinted at by J. Francis, in Usenet's
    rec.games.programmer on Jan 25, 1988.

                           by

    *****************************************************
    *                     Copyright 1989                *
    *  Anibal Antonio Acero         (312) 702-7234      *
    *  5513 S. Everett Ave.     acero@tank.uchicago.edu *
    *  Chicago, IL 60637         ace3@tank.uchicago.edu *
    *                                                   *
    *          LIFE for IBM PC/AT ver 1.0               *
    *                  May 11, 1989                     *
    *  compiled with Borland's TurboC ver. 1.5          *
    *                                                   *
    *****************************************************


*/

/*       The following is the Turbo C source code to a fast implementation
    of Life. It tracks the fate of the famous r-pentomino (1103 generations) in
    under 2 minutes on a 12 MHz AT clone.  The excutable included with
    this code supports CGA, EGA, VGA and Hercules graphics. 128K RAM is
    the minimum required.  A filename can be specified on the commandline
    which contains the X,Y coordinates of cells in the starting con-
    figuration. RPENT.LIF is included as an example; it has the coordinates
    for 4 r-pentominoes.  The decision "engine" comes from the Usenet article
    mentioned above. I have a copy I can mail to anyone interested.  Feel free
    to modify or improve upon this; I would appreciate it if you would mail any
    improvements or optimizations so I could incorporate them in later versions.
    Enjoy! (but use at your own risk; all standard disclaimers apply; this
    program has been tested on EGA/286 and VGA/386 machines, the graphics
    drivers are those provided by Borland's Turbo C v. 1.5; it SHOULD work)

    A few words on the idiosyncrasies of this version.  The "world" is "spherical".
    If a glider goes out the bottom it will reappear at the top of the screen.
    If it goes out one side it will reappear on the other.  A very easy optimization
    that can be performed immediately is to replace all the far pointers with near
    pointers (and recompile).  The "world" is limited to less than 64K but the
    program runs about 70% faster.  If any key is pressed (except 'x') the program
    will pause and display the number of generations that have passed.

    PLEASE DO NOT REMOVE THE CREDITS FROM ANY IMPROVED VERSIONS THAT ARE
    DISTRIBUTED TO THE WORLD AT LARGE.

*/


#include <alloc.h>
#include <stdlib.h>
#include <stdio.h>
#include <graphics.h>

typedef struct cell {            /* each of these replaces an array element*/
     unsigned int t:2;           /* 3-state flag: birth(3),death(2),nc(0)  */
     unsigned int neighbors:5;   /* 5-bit num field, holds n-hood info     */
     unsigned int age:9;         /* 9 bits left to play with (use for age?)*/
     unsigned int x;             /* x coordinate of cell                   */
     struct cell far *NextCell;  /* pointer to next cell                   */
} CELL, far *CELLPTR;


typedef struct row {
     unsigned int y;
	CELLPTR FirstCell;
	struct row far *NextRow;
} ROW, far *ROWPTR;


/********************
 * GLOBAL variables *
 ********************/

ROWPTR FirstRow;
CELLPTR top;    /* top of stack of unused cells */
ROW ROI[3];

unsigned char MAXCOLOR;         /* these 3 variables are semi-con- */
unsigned int MAXROW, MAXCOL;    /* stant; they are assigned once   */

unsigned int n;                 /* the number of generations       */


/************************
 * Function Definitions *
 ************************/


     void credits(){


     printf("\tThis implementation of Conway's Life simulation was coded\n");
     printf("\tusing an algorithm hinted at by J. Francis, on the Usenet\n");
     printf("\tforum, rec.games.programmer, on Jan 25, 1988.\n");
     printf("\n\t\t\t\t  by\n");
     printf("\t*****************************************************\n");
     printf("\t*                  Copyright 1989                   *\n");
     printf("\t*  Anibal Antonio Acero         (312) 702-7234      *\n");
     printf("\t*  5513 S. Everett Ave.     acero@tank.uchicago.edu *\n");
     printf("\t*  Chicago, IL 60637         ace3@tank.uchicago.edu *\n");
     printf("\t*                                                   *\n");
     printf("\t*         LIFE for IBM PC/AT etc. ver 1.0           *\n");
     printf("\t*                 May 11, 1989                      *\n");
     printf("\t*                                                   *\n");
     printf("\t* This program may be freely copied.  It MAY NOT be *\n");
     printf("\t* used in ANY commercial venture.  Please send sug- *\n");
     printf("\t* gestions, improvements, comments, etc., to the    *\n");
     printf("\t* address above.  Enjoy!                            *\n");
     printf("\t*****************************************************\n\n\n");
}

void initgraf(){
     CELLPTR tmp;
     int graphdriver=DETECT;
     int graphmode;

     if (registerbgidriver(EGAVGA_driver) < 0) exit(1);
     if (registerbgidriver(Herc_driver) < 0) exit(1);
     if (registerbgidriver(CGA_driver) < 0) exit(1);
     credits();  /* show something interesting during stack initialization */

     top=farmalloc(sizeof(CELL));  /* create stack of cells */
     top->NextCell=NULL;           /* last in, first out */
     while (farcoreleft() > 15000){/* save 15K for rows and other bookkeeping */
         tmp=top;
         top=farmalloc(sizeof(CELL));
         top->NextCell=tmp;
     }
     initgraph(&graphdriver,&graphmode,"");

     MAXCOLOR=getmaxcolor()+1;
     MAXCOL=getmaxx();
     MAXROW=getmaxy();

}/* end initgraf */

CELLPTR aaamalloc(){ /* set address of new cell from top of stack */
                  CELLPTR tmp;

                  if (top!=NULL){
                      tmp=top;
                      top=top->NextCell;
                      return(tmp);
                  }
                  else
                      exit(1);  /* not enough memory */
}

void aaafree(CELLPTR pcell){  /* add dead cell to top of stack */

             pcell->NextCell=top;
             top=pcell;
}

CELLPTR new_cell(unsigned int x){
                 CELLPTR tempc;

                 tempc=aaamalloc();
                 tempc->x=x;
                 tempc->t=0;
                 tempc->neighbors=0;
                 tempc->NextCell=NULL;
                 return (tempc);
}

ROWPTR new_row(ROWPTR next, unsigned int x, unsigned int y){
               ROWPTR temp;

               temp=farmalloc(sizeof(ROW));
               temp->y=y;
               temp->NextRow=next;
               if (x==MAXCOL) {
                    temp->FirstCell=new_cell(0);
                    temp->FirstCell->NextCell=new_cell(1);
                    temp->FirstCell->NextCell->NextCell=new_cell(x);
               }
               else if (x==(MAXCOL-1)){
                    temp->FirstCell=new_cell(0);
                    temp->FirstCell->NextCell=new_cell(x);
                    temp->FirstCell->NextCell->NextCell=new_cell(x+1);
               }
               else{
                    temp->FirstCell=new_cell(x);
                    temp->FirstCell->NextCell=new_cell(x+1);
                    temp->FirstCell->NextCell->NextCell=new_cell(x+2);
               } /* end if */
               return(temp);
}

CELLPTR find_cell(ROW try, unsigned int x, unsigned int y){
              ROWPTR crow;
              ROWPTR prow;
              CELLPTR ccell;
              CELLPTR pcell;

              if (try.FirstCell == NULL){
                  if (try.NextRow == NULL){
                      prow=crow=FirstRow;
                      while (crow->y < y && crow->NextRow != NULL){
                          prow=crow;
                          crow=crow->NextRow;
                      }
                      if (crow == FirstRow && y < crow->y){
                          try.NextRow=FirstRow=new_row(crow,x,y);
                          crow=FirstRow;
                      }
                      else if (crow->NextRow == NULL && y > crow->y){
                          try.NextRow=crow->NextRow=new_row(NULL,x,y);
                          crow=crow->NextRow;
                      }
                      else if (y < crow->y){
                          try.NextRow=prow->NextRow=new_row(prow->NextRow,x,y);
                          crow=prow->NextRow;
                      }
                      else try.NextRow=crow;
                  }
                  else
                      crow=try.NextRow;

                  /* at this pt crow points at the row which
                     contains the cell sought, if it exists  */

                  pcell=ccell=crow->FirstCell;
              }  /* start at the beginning of the row */
              else
                  pcell=ccell=try.FirstCell;

              while (ccell->x < x && ccell->NextCell != NULL){
                  pcell=ccell;
                  ccell=ccell->NextCell;
              }
              if (ccell == crow->FirstCell && x < ccell->x){
                  crow->FirstCell=new_cell(x);
                  crow->FirstCell->NextCell=ccell;
                  return (crow->FirstCell);
              }
              else if (ccell->NextCell == NULL && x > ccell->x)
                  return(ccell->NextCell=new_cell(x));
              else if (x < ccell->x){
                  pcell->NextCell=new_cell(x);
                  pcell->NextCell->NextCell=ccell;
                  return(pcell->NextCell);
              }
              return (ccell);
} /* find_cell */


void do_neighbors(CELLPTR ccell){
     unsigned int x;
     char t,i;

     x=ccell->x;

     if (ccell->t == 3)  t=2;
     else t = -2;

     if (x==0){
         for (i=0; i < 3; i++){
             ROI[i].FirstCell=find_cell(ROI[i],0,ROI[i].y);
             if (i != 1)
                 ROI[i].FirstCell->neighbors+=t;
             if (ROI[i].FirstCell->NextCell==NULL || ROI[i].FirstCell->NextCell->x != 1)
                 ROI[i].FirstCell->NextCell=find_cell(ROI[i],1,ROI[i].y);
             ROI[i].FirstCell->NextCell->neighbors+=t;   /* don't do current cell */
             ROI[i].FirstCell=NULL;
             find_cell(ROI[i],MAXCOL,ROI[i].y)->neighbors+=t;
             ROI[i].FirstCell=NULL;
         }
         return;
     }
     if (x == MAXCOL){
         for (i=0; i < 3; i++){
              if (ROI[i].FirstCell==NULL || ROI[i].FirstCell->x != (x-1))
                  ROI[i].FirstCell=find_cell(ROI[i],x-1,ROI[i].y);
              ROI[i].FirstCell->neighbors+=t;
              if (ROI[i].FirstCell->NextCell==NULL || ROI[i].FirstCell->NextCell->x != x)
                      ROI[i].FirstCell->NextCell=find_cell(ROI[i],x,ROI[i].y);
              if (i != 1)
                  ROI[i].FirstCell->NextCell->neighbors+=t;
              ROI[i].FirstCell=NULL;
              ROI[i].FirstCell=find_cell(ROI[i],0,ROI[i].y);
              ROI[i].FirstCell->neighbors+=t;
              }
         return;
         }

     for (i=0; i < 3; i++){
         if (ROI[i].FirstCell==NULL || ROI[i].FirstCell->x != (x-1))
             ROI[i].FirstCell=find_cell(ROI[i],x-1,ROI[i].y);
         ROI[i].FirstCell->neighbors+=t;
         if (ROI[i].FirstCell->NextCell->x != x)
             ROI[i].FirstCell=find_cell(ROI[i],x,ROI[i].y);
         else ROI[i].FirstCell=ROI[i].FirstCell->NextCell;
         if (i != 1)
             ROI[i].FirstCell->neighbors+=t;
         if (ROI[i].FirstCell->NextCell->x != (x+1))
             ROI[i].FirstCell->NextCell=find_cell(ROI[i],x+1,ROI[i].y);
         ROI[i].FirstCell->NextCell->neighbors+=t;
   }
}


void find_changers(){
                  ROWPTR crow;
                  CELLPTR ccell;
                  unsigned char color;
                  
                  color=n%MAXCOLOR;
                  /* cycle thru colors to give sense of time */
                  if (!color) color=9%MAXCOLOR;

                  crow=FirstRow;


                  while (crow != NULL){

                      ccell=crow->FirstCell;

/* initialize ROI*/   ROI[0].NextRow=NULL;
/* dont know FC  */   ROI[0].FirstCell=NULL;
/* do know y val */   if (!crow->y) ROI[0].y=MAXROW;
                      else ROI[0].y=crow->y-1;

                      ROI[1].NextRow=crow;
                      ROI[1].FirstCell=NULL;
                      ROI[1].y=crow->y;

                      ROI[2].NextRow=NULL;
                      ROI[2].FirstCell=NULL;
                      if (crow->y==MAXROW) ROI[2].y=0;
                      else ROI[2].y=crow->y+1;


                      while(ccell != NULL){
                          if (ccell->t){
                              do_neighbors(ccell);
                              if (ccell->t == 2){
                                  (ccell->neighbors)--;
                                  putpixel(ccell->x,crow->y,0);
                              }
                              else {
                                  (ccell->neighbors)++;
                                  putpixel(ccell->x,crow->y,color);
                              }
                              ccell->t=0;
                          }
                          ccell=ccell->NextCell;
                      }
                      crow=crow->NextRow;
                  }
}

void update_world(){
                  ROWPTR crow, prow;
                  CELLPTR ccell, pcell;

                  crow=prow=FirstRow;
                  while (crow != NULL){
                      pcell=ccell=crow->FirstCell;

                      /* while n=0 of FirstCell       */
                      /* update pointer to first cell */
                      /* free mem of unused cell      */
                      /* re-establish first */
                      while (ccell != NULL  && !(ccell->neighbors)){
                          ccell=ccell->NextCell;
                          aaafree(pcell);
                          crow->FirstCell=pcell=ccell;
                      }

                      while (ccell != NULL){
                          switch(ccell->neighbors){
                          case 0:
                                  pcell->NextCell=ccell->NextCell;
                                  aaafree(ccell);
                                  ccell = NULL;
                                  break;
                          case 6: /* cell born */
                                  ccell->t=3;
                                  break;
                          case 1:    /*  cell  */
                          case 9:
                          case 3:    /*  dies  */
                          case 11:
                          case 13:   /*  next  */
                          case 15:
                          case 17:   /*  time  */
                                  ccell->t=2;
                          } /* end switch */

                          if (ccell==NULL)
                              ccell=pcell->NextCell;
                          else {
                              pcell=ccell;
                              ccell=ccell->NextCell;
                          }
                      }
                  if (crow->FirstCell == NULL){
                      if (crow == FirstRow){
                          FirstRow=crow->NextRow;
                          farfree(crow);
                          crow=FirstRow;
                      }
                      else{
                          prow->NextRow=crow->NextRow;
                          farfree(crow);
                          crow=prow->NextRow;
                      }
                  }
                  else{
                      prow=crow;
                      crow=crow->NextRow;
                  }
              }
}  /* end update_world */


void r_pent(){
            CELLPTR temp;

            FirstRow->y=MAXROW/2-1;
            FirstRow->FirstCell->x=MAXCOL/2;
            FirstRow->FirstCell->t=3;

            temp=find_cell(ROI[0],MAXCOL/2,MAXROW/2); temp->t=3;
            ROI[0].NextRow=NULL;
            temp=find_cell(ROI[0],MAXCOL/2,MAXROW/2+1); temp->t=3;
            ROI[0].NextRow=NULL;
            temp=find_cell(ROI[0],MAXCOL/2-1,MAXROW/2); temp->t=3;
            ROI[0].NextRow=NULL;
            temp=find_cell(ROI[0],MAXCOL/2+1,MAXROW/2-1); temp->t=3;
}


void initworld(int argc, char *argv[]){
     /* open file with x,y coordinates of cells */
     /* or default to r-pentomino if no args    */
     CELLPTR tmp;
     FILE *life;
     unsigned int c,x,y;


     FirstRow=new_row(NULL,0,0);
     for (c=0; c<3; c++){ /* Initialize Region of Interest */
         ROI[c].y=0;
         ROI[c].FirstCell=NULL;
         ROI[c].NextRow=NULL;
     }

     if (argc > 1) {
          life=fopen(argv[1],"r");
          if (life==NULL){
              outtext(argv[1]);
              outtext(" not found!");
              outtextxy(1,10,"Continuing with default start-up: one r-pentomino");
              delay(2000);
              clearviewport();
              r_pent();
              return;
          }
          c=fscanf(life, "%d %d", &x,&y);
          FirstRow->y=y;
          FirstRow->FirstCell->x=x;   /* initialize first cell */
          FirstRow->FirstCell->t=3;
          while (c!=EOF){
              tmp=find_cell(ROI[0],x,y);
              tmp->t=3;
              ROI[0].NextRow=NULL;
              c=fscanf(life, "%d %d", &x,&y);
          }
          c=fclose(life);
     }
     else
          r_pent();
}/* end initworld */

main (int argc, char *argv[]) {
     unsigned done=0,size;
     void far *buffer;
     char c[5];

     initgraf();
     size=imagesize(0,0,MAXCOL,8);
     buffer=farmalloc(size);

     initworld(argc,argv);  /* place cells in list */

     while (!done){
          ++n;
          find_changers();
          update_world();
          if (kbhit()){
               if ((*c=getch())=='x') done=1;
               else{
                     getimage(0,MAXROW-7,MAXCOL,MAXROW,buffer);
                     putimage(0,MAXROW-7,buffer,XOR_PUT);
                     moveto(MAXCOL/5,MAXROW-7);
                     outtext(itoa(n,c,10));
                     outtext(" generations; Space bar to continue, x to quit ");
                     while(!kbhit());
                     if ((*c=getch())=='x') done=1;
                     putimage(0,MAXROW-7,buffer,COPY_PUT);
               }
          }
     }
     closegraph();
     printf("\t\t\t%d generations\n\n",n);
     credits();

}/* end main */
