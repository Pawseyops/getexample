
$loopcount=0;
$innercount=0;
$outercount=0;
$flag=0;
$flag2=0;
$flag3=0;

open(IN, "$ARGV[0]");
open(OUT, ">$ARGV[1]_$outercount.txt");
open(GEN, ">$ARGV[2].txt");

foreach(<IN>) {

	if ($flag == 0) {

		$theline=$_;
		chomp $theline;
	
		@title=split("\t", $theline);
		$flag++;
		shift(@title);
	
	
	} elsif ($flag == 1) {

		$theline=$_;
		chomp $theline;

		@title2=split("\t", $theline);
		$flag++;
		shift(@title2);
	
	} else {
	
		$theline=$_;
		chomp $theline;
	
		my @holder=split("\t", $theline);
		$name[$innercount]=shift(@holder);
		
		foreach(@holder) {
		
			$ExpG2[$innercount][$loopcount]=$_;
			$loopcount++;		
		
		}
		
		
		$max = $loopcount;
		$loopcount=0;
		$innercount++;
		$flag3=0;
		
		if ($innercount == 25) {
		
			for (my $i=0; $i < $max; $i++) {
			
			
				for (my $z=0; $z < $innercount; $z++) {

					if ($flag3 == 0) {

						printf(GEN "$name[$z]\t$outercount\t$z\n");
				
					}
				
					if ($flag2 == 0) {
					
						printf(OUT "$title[$i]\t$title2[$i]");
						$flag2++;

					}
				
					printf(OUT "\t$ExpG2[$z][$i]");
				
				}

				printf(OUT "\n");
				$flag2=0;
				$flag3=1;
			
			}
		
		
			close(OUT);
			$innercount=0;
			$outercount++;
			open(OUT, ">$ARGV[1]_$outercount.txt");
		
		
		}
		
	
	
	}

}

for (my $i=0; $i < $max; $i++) {
			
			
	for (my $z=0; $z < $innercount; $z++) {

		if ($flag3 == 0) {

			printf(GEN "$name[$z]\t$outercount\t$z\n");
				
		}
				
		if ($flag2 == 0) {
					
			printf(OUT "$title[$i]\t$title2[$i]");
			$flag2++;

		}
				
		printf(OUT "\t$ExpG2[$z][$i]");
				
	}

	printf(OUT "\n");
	$flag2=0;
	$flag3=1;
			
}
		
		
close(OUT);
$innercount=0;
$outercount++;
