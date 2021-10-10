
unsigned long randseed;

unsigned long my_random(unsigned long range)
{
  randseed = randseed * 214013 + 2531011;
  return ((randseed >> 16) * range) >> 16;
}
