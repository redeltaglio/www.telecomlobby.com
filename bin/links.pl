#!/usr/bin/perl

# slurp the entire file
local $/ = undef;
open INFILE, $ARGV[0] or die "Could not open file. $!";
$string = <INFILE>;
close INFILE;

while ($string =~ s/<strong>(.*)<\/strong> (.*)\[(\d+)\]<\/a>/$2 $1<\/a>/) {}

print "$string";

