#!/usr/bin/perl

=head1 Program Description

    This program is simply designed to filter the SNP and INDEL sites
    that are marked by the GATK Hard Filter algorithm.
    Delection of multi-altenative SNP sites can be chosen.

=head1 Contact & Version

    Author: Shangzhe Zhang, shangzhezhang@gmail.com
    Date: 2019.2.5
    Version: None

=head1 Command-line Option

    --input <str> Input VCF format file, MUST be gziped;
    --output <str> Output VCF format file, will be gziped by default;
    --multi Set this option if you want to delete the multi-alt SNPs (DON'T use when --type INDEL)
    --marker The marker you used in the Hard Filter Process, e.g. my_snp_filter
    --type <str> Set the variant type: SNP or INDEL;
    --help Show this help text

=head1 Usage Example

    remove.hdfilter.pl --input IN.vcf.gz --output OUT.vcf.gz --type SNP --marker my_snp_filter --multi

=cut

use strict;
use warnings;
use Getopt::Long;

my ($infile, $outfile, $multi, $marker, $type, $help);
GetOptions(
    "input:s" =>\$infile,
    "output:s" =>\$outfile,
    "multi"=>\$multi,
    "help"=>\$help,
    "type:s"=>\$type,
    "marker:s"=>\$marker
)；
die `pod2text $0` if ($Help || ! $marker);
undef($multi) if ($type eq "INDEL");
die `pod2text $0` if ($infile !~ /.*\.gz$/);
if ($outfile !~ /.*\.gz$/){
    $outfile = $outfile.".gz";
}

open OUT, "| pigz - > $outfile";
open IN, "zcat $infile |";
while(<IN>){
    chomp;
    if (/^#/){
        print OUT "$_\n";
        next;
    }
    my @a = split/\s+/;
    next if ($a[6] eq $marker);
    if ($multi){
         next if ($a[4] =~ /,/);
    }
    print OUT "$_\n";
}
close IN;
close OUT;
