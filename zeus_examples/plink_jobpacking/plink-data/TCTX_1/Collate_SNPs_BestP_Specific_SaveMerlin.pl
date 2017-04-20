# $ARGV[0] is positions file
# $ARGV[1] is file of gene inclusion filenames (all ending in .txt)
# $ARGV[2] is distance (in bp) that a SNP can be from a gene while counting as CIS
# $ARGV[3] eq 0 for initial runs, 1 if you want to include prior runs
# $ARGV[4] is inner loop count from calling script
# $ARGV[5] is batch number

# Need to make sure the 'all' file containing the full complement of genes goes through first in the namefile!
# Or it might mess up the %namehash below!!

$count=1;
$flag=0;
$flag2=0;
$output[0]="\t";
$num++;

# open(NAM, "$ARGV[0]");

# foreach(<NAM>) {

# if ($_ =~ /\d*\t\d*\t\d*\t(GI.*)\n/) {
 
#	$output[0]=join("\t", $output[0], $1);
#	chomp $output[0];
 
# }


# }

 opendir(thedir, ".");
 @contents = grep !/^\.\.?$/, readdir thedir;

$numarray=0;
@allgenes;
%logp5;
%logp05;
@bestp_CIS;
@bestp_TRANSCIS;

%bestp2;
%countp5;
%countp05;



open(NAMO, "$ARGV[0]");

foreach(<NAMO>) {

	$theline=$_;
	chomp $theline;

	if ($theline =~ /^.*?\t(\d*\t\d*)\t(\w*)\t(\d*)\t(\d*)$/) {
	
#		$namo{$1}=1;
		$chromo{$1}=$2;
		$starto{$1}=$3;
		$endo{$1}=$4;
	
	}

}

close(NAMO);

open(NAM2, "$ARGV[1]");
@namefiles=<NAM2>;

foreach(@namefiles) {

	$thefile=$_;
	chomp $thefile;
	open(NAM3, "$thefile");
	$thefile=$_;
	chomp $thefile;

	foreach(<NAM3>) {

		$theline=$_;
		chomp $theline;

		if ($theline =~ /^.*?\t(\d*\t\d*)(\t|\n)/) {
#		if ($theline =~ /^(\d*)$/) {	
			$namo{$thefile}{$1}=1;
	
		}
	
	}
	
	close(NAM3);

}

close(NAM2);
%namehash;

# push (@contents, "MAGI1_JH_CON_tab.qassoc");
# push (@contents, "MAGI2_JH_CON_tab.qassoc");
# push (@contents, "MAGI3_Genevar_tab.qassoc");
# push (@contents, "PTPRZ1_JH_CON_tab.qassoc");

$output[0]="\t\t";
$count=0;
$max=0;

if ($ARGV[3] != 0) {

	foreach(@namefiles) {

		$thefile=$_;
		chomp $thefile;
	
		if ($thefile =~ /^(.*)(.txt)/) {

			open(PRE, "$1_Collated_TRANSCIS.txt");
		
			foreach(<PRE>) {
			
				if ($_ =~ /^(.*)\t(.*)\n/) {
		
					if (exists $namehash{$1}) {
				
						$bestp_TRANSCIS[$count][$namehash{$1}]=$2;
	
					} else {
					
						$namehash{$1}=$max;
						$max++;
						$bestp_TRANSCIS[$count][$namehash{$1}]=$2;
					
					}
				
				}

			}
			
			close(PRE);

			open(PRE, "$1_Collated_CIS.txt");
		
			foreach(<PRE>) {
		
				if ($_ =~ /^(.*)\t(.*)\n/) {
				
					if (exists $namehash{$1}) {
				
						$bestp_CIS[$count][$namehash{$1}]=$2;
	
					} else {
					
						$namehash{$1}=$max;
						$max++;
						$bestp_CIS[$count][$namehash{$1}]=$2;
					
					}
	
				}

			}
			
			close(PRE);
			
		}
	
	
		$count++;
	
	}

}

close(START);

foreach(@contents) {

	if ($_ =~ /plink\.B${ARGV[5]}.(\d*)\.qassoc$/) {

		# This bit assumes the outer script is running in 4-file cycles, and corrects the numbers accordingly to match the name files

	$zug=$ARGV[4];
	$zag=$1-1;

	
	$elnombre="$zug\t$zag";

#	if ($namo{$zoggle}==1 || $ARGV[4]== 0) {
	
#	if ($_ =~ /plink\.P(\d*)\.qassoc$/) {	
	
		open(IN, "$_");
		$bestp=1;
		$bestp2=1;
		@hold=();
		
		foreach(<IN>) {

			if ($_ =~ /^\s*(\d+)\s+(.*?)\s+(.*?)\s+.*?\s+.*?\s+.*?\s+.*?\s+.*?\s+(.*?)\s*\n/) {
			
				$chr=$1;
				$name=$2;
				$pos=$3;
				$pval=$4;
				
				if (exists ($namehash{$name})) {
				
				
				} else {
				
					$namehash{$name}=$max;
					$max++;
				
				}
				
				if ($pval == 0 && $pval ne "NA") {
				
					$pval=$pval+0.0000000000000000000000000000000001;
				
				}
				
				$count=0;
				

				foreach(@namefiles) {
				
					$thefile=$_;
					chomp $thefile;

					if (exists($bestp_CIS[$count][$namehash{$name}])) {
				
						if ($namo{$thefile}{$elnombre} == 1 && $bestp_CIS[$count][$namehash{$name}] >= $pval && $pval ne "NA" && $chr==$chromo{$elnombre} && $pos>($starto{$elnombre}-$ARGV[2]) && $pos<($endo{$elnombre}+$ARGV[2])) {
					
							$bestp_CIS[$count][$namehash{$name}] = $pval;
					
						}
	
					} elsif ($namo{$thefile}{$elnombre} == 1 && $pval ne "NA" && $chr==$chromo{$elnombre} && $pos>($starto{$elnombre}-$ARGV[2]) && $pos<($endo{$elnombre}+$ARGV[2])) {

				
						$bestp_CIS[$count][$namehash{$name}]=$pval;
				
					}
				
					if (exists($bestp_TRANSCIS[$count][$namehash{$name}])) {
				
						if ($namo{$thefile}{$elnombre} == 1 && $bestp_TRANSCIS[$count][$namehash{$name}] >= $pval && $pval ne "NA") {
							
							$bestp_TRANSCIS[$count][$namehash{$name}] = $pval;
					
						}
	
					} elsif ($namo{$thefile}{$elnombre} == 1 && $pval ne "NA") {
				
						$bestp_TRANSCIS[$count][$namehash{$name}]=$pval;
				
					}

					$count++;

				}
		
			}
			
		}
		
		close(IN);
	
	}
	
}

$count=0;

foreach(@namefiles) {
	
	$thefile=$_;
	chomp $thefile;
	
	if ($thefile =~ /^(.*)(.txt)/) {
		
		open(PRE, ">$1_Collated_CIS.txt");
		
		for $out(sort keys %namehash) {
		
			if (exists $bestp_CIS[$count][$namehash{$out}]) {
			
				printf(PRE "$out\t$bestp_CIS[$count][$namehash{$out}]\n");
			
			}
			
		}


			
		close(PRE);
			
		open(PRE, ">$1_Collated_TRANSCIS.txt");
		
		for $out(sort keys %namehash) {
		
			if (exists $bestp_TRANSCIS[$count][$namehash{$out}]) {
			
				printf(PRE "$out\t$bestp_TRANSCIS[$count][$namehash{$out}]\n");
			
			}

		}

	
		close(PRE);

	}
	
	$count++;
	
}
