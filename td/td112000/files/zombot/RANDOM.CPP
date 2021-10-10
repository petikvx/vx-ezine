
#define rndR(a,b)       ((a)+rnd((b)-(a)+1))            // [a..b]

DWORD randseed;

DWORD random()
{
  return randseed = randseed * 214013 + 2531011;
}

// rnd(0)=0
DWORD rnd(DWORD d)
{
  return ((random() >> 16) * d) >> 16;
}

void randomize(DWORD anydata)
{
  randseed -= anydata;
  randseed = (randseed << 1) | (randseed >> 31);        // rol 1
}
