
open(IN, "$ARGV[0]");
open(POS, "$ARGV[1]");
open(OUT, ">$ARGV[2]");

foreach(<POS>) {

	if ($_ =~ /^(.*?)\t(.*)\n$/) {
	
		$pos{$1}=$2;
	
	}


}

$count1=0;
$count2=0;

foreach(<IN>) {

	$theline=$_;
	chomp $theline;
	if ($theline =~ /^(.*?)$/) {
	
		printf(OUT "$theline\t$count2\t$count1\t$pos{$1}\n");
		$count1++;
		if ($count1 == 25) {
		
			$count2++;
			$count1=0;
		
		}
	
	
	}









}