void poly_start(void)
{
  return;
}

#include "poly.c"

void poly_end(void);

int poly_size(void)
{
  return (int) ((char *) poly_end - (char *) poly_start);
}

void poly_end(void)
{
  return;
}