


open(IN, "$ARGV[0]");

open(OUT, ">$ARGV[1]");

$flag0=0;
$flag1=0;


foreach(<IN>) {

	$theline=$_;
	chomp $theline;
	
	@theline=split("\t",$theline);
	
	foreach(@theline) {
	
		if ($flag0 == 0) {
		
			printf(OUT "$_");
			$flag0++;
		
		
		
		
		} elsif ($flag1 == 0) {
		
			printf(OUT "\t$_");
			$flag1++;
		
		
		
		} elsif ($flag1 == 1) {
		
			$flag1--;
		
		}
	
	
	
	
	
	}


	printf(OUT "\n");
	$flag0=0;
	$flag1=0;











}