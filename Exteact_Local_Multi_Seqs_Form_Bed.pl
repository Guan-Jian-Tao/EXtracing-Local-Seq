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
	Run by typing: perl Exteact_Local_Seq.pl -genomefile [run directory] -bedfile [Bed file] -outfile [output file]
	Required params:
	-g|genomefile						[s]	Genome file (.fa)
	-b|bedfile							[b]	Bed file
	-o|outfile							[s]	Outfile (.fa)
	Multiple bed file:
		Id	Chromosome	Start	End
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
	'outfile'			=> undef,
	'genomefile'		=> undef,
	'bedfile'		=> undef
);

die usage() if @ARGV == 0;
GetOptions (
  'h|help'				=> \$opt{help},
  'debug'				=> \$opt{debug},
  'o|outfile=s'			=> \$opt{outfile},
  'g|genomefile=s'		=> \$opt{genomefile},
  'b|bedfile=s'				=> \$opt{bedfile}
) or die usage();

#check input paramaters
die usage() if $opt{help};
die usage() unless ( $opt{outfile} );
die usage() unless ( $opt{genomefile} );
die usage() unless ( $opt{bedfile} );

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

my $bed = $opt{bedfile};
open(IN,$bed);
open(OUT,">$opt{outfile}");
while(<IN>){
	chomp;s/\r//;
	my ($id,$chr,$start,$end) = split /\t/,$_;
	print "Searching for $chr $start $end \n";
	if (exists $seq{$chr}){
		my $chr_len = length($seq{$chr})-1;
		my $start = $start-1;
		my $end = $end-1;
		die "The end is valid \n" if $end > $chr_len;
		die "The end is valid \n" if $start < 0;
		my $outseq = substr($seq{$chr},$start,($end-$start+1));
		my $outid = ">".$id."_".$chr."_".$start."\-".$end;
		print OUT $outid."\n".$outseq."\n";
	} else {
		die "There is no this Chromosome \n";
	}
}
close OUT;
close IN;
print "Extracting is done \n";

