
# Statistical Executable Trash Generator -- example #1

$MIN_COUNT = 10;

# process db, build associative arrays

  open(F, "<n_chains.txt") || die "cant open file: n_chains.txt";
  @data = <F>;
  close F;
  chomp(@data);
  for($j = 0; $j < scalar @data; $j++)
  {
    # count instr next1 [next2]
    ($c, $i, $n1, $n2) = split(" ", $data[$j]);

#   $c += 10;   # force rare instructions to be more frequent

    if ($c >= $MIN_COUNT)
    {

      $cnt  {$i}[ $num{$i} ] = $c;
      $next1{$i}[ $num{$i} ] = $n1;
      $next2{$i}[ $num{$i} ] = $n2;
      $num  {$i} += 1;
      $count{$i} += $c;

      if (($total_num > 0) && ($i eq @name[$total_num - 1]))
      {
        @n_cnt[$total_num] += $c;
      }
      else
      {
        @name[$total_num] = $i;
        $total_num++;
        @n_cnt[$total_num] = $c;
      }

      $total_cnt += $c;

    }
  }
  @data = ();

#  print "$total_num unique chains, $total_cnt total\n";
#
#  foreach $t (@name)
#  {
#    print "instr=" . $t . " num=" . $num{$t} . " weight=" . $count{$t} . "\n";
#    for($i = 0; $i < $num{$t}; $i++)
#    {
#      print "     weight=" . $cnt{$t}[$i] . "  next=" . $next1{$t}[$i] . " next=" . $next2{$t}[$i]. "\n";
#    }
#  }

# generate some random instructions

  open(F1, ">setg_sample.bin") || die "cant create file";
  binmode(F1);
  open(F2, ">setg_sample.txt") || die "cant create file";

  $prev = "";
  $next = "";

  for($t = 0; $t < 10000; $t++)
  {

    if ($prev eq "")
    {
r1:
      # choose 1st instruction (using weights)

      $r = int rand($total_cnt);
      $q = 0;
      for($j = 0; $q + @n_cnt[$j] < $r; $j++)
      {
        $q += @n_cnt[$j];
      }
      $ins = $name[$j];

    }
    else
    {
      # choose Nth instruction (using weights)

      if (((int rand(5)) == 0) && ($next ne ""))
      {
        $ins = $next;
      }
      else
      {
        $r = int rand($count{$prev});
        $q = 0;
        for($j = 0; $q + $cnt{$prev}[$j] < $r; $j++)
        {
          $q += $cnt{$prev}[$j];
        }
        $ins  = $next1{$prev}[$j];
        if ($ins eq "") { goto r1; }
        $next = $next2{$prev}[$j];
      }

    }

    if ($ins eq $prev)
    {
      goto r1;
    }

    @chars = split("",$ins);
    $s = "";
    for($x = 0; $x < scalar @chars; $x += 2)
    {
      $s .= chr(hex($chars[$x+0] . $chars[$x+1]));
    }
    print F1 $s;
    print F2 "$ins\n";

    $prev = $ins;
  }

  close F1;
  close F2;

# EOF
