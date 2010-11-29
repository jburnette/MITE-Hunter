#!/usr/bin/perl -w
use strict;

=head1 NAME

 fasta_windows_maker

=head1 USAGE

 -i or --input   Input filename
 -o or --output  Output filename (default Inputname.split)
 -w or --window  Window size (12000 bp default)
 -s or --step    Stepsize (4000 default)
 -h or --help    Show help

=cut

# 11/28/2010
# --Jason Stajich
# 1. use strict
# 2. Getopt::Long
# 8/13/2010
# add: 
# split the given fasta file into small segments for blast, etc.
# Written by vehell
# 30/6/106
#-----------------------------------------------------
use Getopt::Long;
#-----------------------------------------------------

my $Input;
my $Window = 12000;
my $Step   = 4000;
my $Per    = 1;
my $Output;

GetOptions (
	    'i|input:s'      => \$Input,
	    'w|window:i'     => \$Window,
	    's|step:i'       => \$Step,
	    'P|per:i'        => \$Per,
	    'o|output:s'     => \$Output,
	    'h|help'         => sub { &usage(); },
	    );

$Output ||= "$Input.split";

usage() unless $Input;

#-----------------------------------------------------
my %Name_Seq;
{ 
    open(IF, $Input) ||die"cannot open $Input: $!\n";
    my $Name;
    while(<IF>) {
	chomp;
	if(/^>(\S+)/) {
	    $Name = $1;
	}else{
	    $Name_Seq{$Name} .= $_;
	}
    }
    close(IF);
}

open(OF, ">$Output")||die"$!\n";
for my $Name (keys %Name_Seq ) {

    my $Seq  = $Name_Seq{$Name};
    my $Len  = length($Seq);
    if($Len > $Window) {
	my $First = 1;
	my $Sub_Per = 0;
	for(my $i = 0; $i < $Len - $Window; $i += $Step) {
	    if($First == 1) {
		my $Win;
		if($i + $Window < $Len) {
		    $Win = substr($Seq, $i, $Window);
		} else{
		    $Win = substr($Seq, $i);
		}
		print OF ">$Name.$i\n$Win\n";
		$First = 0;
		$Sub_Per = 0;
	    } else{
		$Sub_Per += $Per;
		
		if($Sub_Per < 1) {
		    next;
		}else {
		    my $Win;
		    if($i + $Window < $Len) {
			$Win = substr($Seq, $i, $Window);
		    }else{
			$Win = substr($Seq, $i);
		    }
		    print OF ">$Name.$i\n$Win\n";
		    $Sub_Per = 0;
		}
	    }
	}
    }else{
	print OF ">$Name.0\n$Seq\n";
    }
}
close(OF);

#-----------------------------------------------------
#-----------------------------------------------------
sub usage {
    exec('perldoc',$0);
    exit(1)
}
