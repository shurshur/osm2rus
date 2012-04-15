#!/usr/bin/perl
use strict;

$|=1;
mkdir "b";
sub runtask;
sub runreg;
1;

sub runreg {
  my ($reg)=@_;
  my $ret;
  $ret = runtask $reg, "get", "wget http://gis-lab.info/projects/osm_dump/dump/latest/$reg.osm.bz2 -O -|bunzip2 > b/$reg.osm";
  return if $ret;
  $ret = runtask $reg, "osm2mp", "perl ./osm2mp_new.pl --config russa.yml --shorelines --background --navitel b/$reg.osm > b/$reg.mp";
  return if $ret;
  $ret = runtask $reg, "mp2rus", "./mp2rus b/$reg.mp -o b/$reg.rus";
  return if $ret;
}

sub runtask {
  my ($reg, $task, $c)=@_;
  my $p = "$reg.$task";
  print "$reg $task: ";
  my $t1 = time;
  my $ret = system "sh -c '$c' > b/$p.out.log 2> b/$p.err.log";
  my $t2 = time;
  print "ret=$ret, elapsed ".($t2-$t1)." seconds\n";
  return $ret;
}

open REGS,"<regs";
while(my $reg = <REGS>) {
  chomp $reg;
  runreg $reg;
}

