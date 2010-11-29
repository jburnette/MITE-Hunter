#!/usr/bin/perl -w
use strict;

=head1 NAME

fasta_splitter

=head1 USAGE

 -i or --input  Input filename
 -o or --output Output filename
 -n or --num    Number of chunks to split to
 -h or --help   Display help

=cut

# Written by vehell
# 5/7/106
#-----------------------------------------------------
use Getopt::Long;
#-----------------------------------------------------
my ($Number,$Output,$Input) = (5,'group');

GetOptions(
	   'n|num:i'   => \$Number,
	   'i|input:s' => \$Input,
	   'o|output:s'=> \$Output,
	   'h|help'    => sub { &usage() },
	   );
    
&usage() unless $Input;
#-----------------------------------------------------

open(IF, $Input)||die "cannot open $Input: $!\n";
my $Count = 0;
while(<IF>) {
    if(/^>/) { $Count ++ }
}
close(IF);

my $Group_Num = int($Count / $Number) + 1;

print "$Group_Num / $Count\n";

$Count = 0;
my $i = 0;
open(IF, $Input)||die "$!\n";
while(<IF>) {
    if(/^>/) {
	if($Count % $Group_Num == 0) {
	    print "$Count $Group_Num\n";
	    $i++;
	    if($Count > 0) {
		close(OF);
	    }
	    open(OF, ">$Output.$i")||die "$!\n";	
	}
	$Count++;
    }
    print OF $_; 
}
close(IF);
close(OF);

#-----------------------------------------------------
#-----------------------------------------------------
sub usage {
    exec('perldoc',$0);
    exit;
}
