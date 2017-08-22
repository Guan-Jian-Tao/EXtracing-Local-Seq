use strict;
use warnings;
use POSIX qw(tmpnam);
use Getopt::Long;
use File::Basename;
use File::Path qw(make_path);
use Cwd qw(abs_path);
use List::MoreUtils qw(uniq);
use Time::localtime;

## ======================================
## Usage: see -h
## ======================================

sub usage{
  warn <<END;
  Usage:
  Run by typing: perl Exteact_Local_Seq.pl -genomefile [run directory] -chr [chromosome id] -start [start point (bp)] -end [end point (bp)] -outfile [output file]
    Required params:
	-g|genomefile						[s]	Genome file (.fa)
	-c|chr								[s]	Chrmosome ID
	-s|start							[i]	Start Pos (bp)
	-e|end								[i]	End Pos (bp)
	-o|outfile							[s]	Outfile (.fa)
   
END
  exit;
}
## ======================================
## Get options
## ======================================

my %opt;
%opt = (
	'help'				=> undef,
	'debug'				=> undef,
	'start'		    => undef,
	'outfile'			=> undef,
	'genomefile'		=> undef,
	'chr'		=> undef,
	'end'		=> undef
);

die usage() if @ARGV == 0;
GetOptions (
  'h|help'				=> \$opt{help},
  'debug'				=> \$opt{debug},
  's|start=i'			=> \$opt{start},
  'o|outfile=s'			=> \$opt{outfile},
  'g|genomefile=s'		=> \$opt{genomefile},
  'e|end=i'				=> \$opt{end},
  'c|chr=s'				=> \$opt{chr}
) or die usage();

#check input paramaters
die usage() if $opt{help};
die usage() unless ( $opt{start} );
die usage() unless ( $opt{outfile} );
die usage() unless ( $opt{genomefile} );
die usage() unless ( $opt{end} );
die usage() unless ( $opt{chr} );

## ======================================
## Input Genome fasta
## ======================================

print "The input genome file is $opt{genomefile} \n";
my %seq;
open(FA,$opt{genomefile}) or die "No Genome fasta file input \n";
$/=">";
my $i=0;
while(<FA>){
	if (/^(\S+).*?\n(.*)/ms){
		my $key = $1; my $value = $2;
		$value =~ s/>//gm;
		$value =~ s/\*$//gm;
		$value =~ s/\n//gm;
		$key =~ s/\n//mg;
		$seq{$key} = $value;
		$i++;
	}
}
close FA;
$/="\n";
print "The Contigs in $opt{genomefile} is $i \n";

## ======================================
## Input VCF File and extract flanking sequence
## ======================================

my $chr = $opt{chr};
print "Searching for $chr $opt{start} $opt{end} \n";
open(OUT,">$opt{outfile}");
if (exists $seq{$chr}){
	my $chr_len = length($seq{$chr})-1;
	my $start = $opt{start}-1;
	my $end = $opt{end}-1;
	die "The end is valid \n" if $end > $chr_len;
	die "The end is valid \n" if $start < 0;
	my $outseq = substr($seq{$chr},$start,($end-$start+1));
	my $id = ">".$chr."_".$opt{start}."\-".$opt{end};
	print OUT $id."\n".$outseq."\n";
} else {
	die "There is no this Chromosome \n";
}
close OUT;
print "Extracting is done \n";

