my $file=$ARGV[0];
my $cutoff=$ARGV[1];
my $out=$ARGV[2];
open(IN,$file) or die "not find $file!\n";
open(OUT,">$out");
my $line=<IN>;
while($line=~m/^##/){ # discrad anno
	print OUT $line;
	$line=<IN>;	
}
my @title=split "\t",$line; #title
print OUT $line;
my $snpCount=0;
my $filterCount=0;
while(<IN>) {
	chomp ;
	my @b=split "\t";	
	my $heterCount=0;
	foreach $i (9 .. @title-1){		
		my @c=split ":",$b[$i];		
		my @d=split "/",$c[0];
                if ($d[0] ne $d[1]) {
			$heterCount++;	
		}			
	}
	if ($heterCount/(@title-9) >$cutoff){
		$filterCount++;
	}else{
		print OUT $_,"\n";
	}
	$snpCount++;
}
close(IN);
close(OUT);
print "$snpCount snp , $filterCount heter be filtered!\n";
