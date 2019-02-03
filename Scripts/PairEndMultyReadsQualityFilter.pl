#! /usr/bin/perl
use strict;
use warnings;

my $out_prefix=shift @ARGV;
my @file=@ARGV;
if(scalar(@ARGV) == 0 || scalar(@ARGV)%2 > 0){
    die "Usage:\n$0 \$out_prefix a.fq1 a.fq2 b.fq1 b.fq2 ...\n";
}
my $baseQ=&getBaseQ();
my $out1="$out_prefix.1.filter.fq.gz";
my $out2="$out_prefix.2.filter.fq.gz";
print "baseQ is $baseQ\noutput files: $out1\t$out2\n";
open(O1,"| gzip -c - >$out1")||die("$!\n");
open(O2,"| gzip -c - >$out2")||die("$!\n");

for (my $j=0;$j<@file;$j=$j+2){
    my $file1=$file[$j];
    my $file2=$file[$j+1];
    print  "filter $file1 $file2\n";
    if ($file1=~/gz$/){
        open(I1,"zcat $file1 | ")||die("$!\n");
        open(I2,"zcat $file2 | ")||die("$!\n");
    }else{
        open(I1,"< $file1")||die("$!\n");
        open(I2,"< $file2")||die("$!\n");
    }
    while(<I1>){
        my $l1=$_;
        my $l2=<I1>;
        my $l3=<I1>;
        my $l4=<I1>;
        my $l5=<I2>;
        my $l6=<I2>;
        my $l7=<I2>;
        my $l8=<I2>;
        
        my $test2=&filter($l2,$l4);
        #print "$test2\n";
        next if($test2==0);
        my $test6=&filter($l6,$l8);
        #print "$test6\n";
        next if($test6==0);
        
        if ($baseQ == 64){
            $l4=&quality33($l4);
            $l8=&quality33($l8);
        }
        #$l1=~/^(\S+)/;
        #$l1=$1."/1\n";
        #$l5=~/^(\S+)/;
        #$l5=$1."/2\n";
        print O1 "$l1","$l2","+\n","$l4\n";
        print O2 "$l5","$l6","+\n","$l8\n";
        #last;
    }
    close I1;
    close I2;
    print "done\n";
}
close O1;
close O2;

sub getBaseQ{
    my $infile=$file[0];
    if ($infile=~/(gz|gzip)$/){
        open (F,"zcat $infile| ");
    }else{
        open (F,"$infile");
    }
    my $i=0;
    my $min=0;
    my ($lenmin,$lenmax)=(0,0);
    while (<F>) {
        chomp;
        $i++;
        if ($i%4 == 0){
            my $len=length($_);
            $lenmin=$len if ($len<$lenmin || $lenmin==0);
            $lenmax=$len if ($len>$lenmax || $lenmax==0);
            my @Q=split(//,$_);
            for my $q (@Q){
	$q=ord("$q");
	$min=$q if ($q<=$min || $min==0);
	#print "$_\n$q\n$min\n";exit;
            }
        }
        last if $i==100000;
    }
    close F;
    $min>=64 ? $min=64 : $min=33;
    return ($min);
}

sub filter{
    my ($seq,$qual)=@_;
    chomp $seq;
    chomp $qual;
    #print "SEQO $seq\n";
    my $len=length($seq);
    #print "LEN $len\n";
    return(0) if($len==0);
    my $n=$seq;
    $n=~s/N//g;
    #print "SEQ $n\n";
    my $lenN=length($n);
    #print "LENN $lenN\n";
    return(0) if($lenN/$len<0.95);
    my @quality=split(//,$qual);
    my $invalid=0;
    #print "\n";
    foreach my $a(@quality){
        my $b=ord($a)-$baseQ;
        #$b=10 if($b==-2);
        $invalid++ if($b<=7);
        #print "$b ";
    }
    #print "\n";
    #print "INVA $invalid\n";
    return(0) if($invalid/$len>=0.65);
    return(1);
}

sub quality33 {
    my ($line)=@_;
    chomp $line;
    my @line=split(//,$line);
    my @newline;
    for my $q (@line){
        my $Q=ord($q)-64;
        my $newq=chr(($Q<=93 ? $Q : 93) + 33);
        push @newline,$newq;
    }
    my $newline=join("",@newline);
    return $newline;
}
