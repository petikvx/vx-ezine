model   tiny
codeseg
org     100h
start:
xchg    ax,bp
xchg    dx,si
int     21h
retn


end     start