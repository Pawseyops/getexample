# Run_GV_eQTLs.pl  November 09  Alex Richards
# Usage: Run_GV_eQTLs.pl 0 166 0 NamesList.txt CEU_indep
# Runs CIS and CIS/TRANS eQTLs for every 'GV_split_0.txt' file in the directory
# and for each name file in NamesList.txt
# Collates as it goes along
# First two arguments are numbers of first and last 'GV_split_0.txt' file to use
# Third arg is '0' if you want to start afresh or '1' if you want to collate into an already present file

$startnum=$ARGV[0];
$endnum=$ARGV[1];
$innercount=0;
$flag=$ARGV[2];

open(NAM, "$ARGV[3]");

foreach(<NAM>) {

	push(@namefiles, $_);


}

opendir(thedir, ".");
@contents = grep !/^\.\.?$/, readdir thedir;


for (my $i=$startnum; $i <= $endnum; $i++) {


	system("plink-1.05 --assoc --bfile $ARGV[4] --pheno PONS_split_$i.txt --all-pheno");


#	for (my $y=1; $y <= 25; $y++) {
		
#		$newnum=($innercount*25)+$y+99;
#		system("move plink.P$y.qassoc plink.P$newnum.qassoc");
		
#	}
	
	

#	$innercount++;
	


#	if ($innercount == 4 || $i == $endnum) {
	
#		$innercount=0;
		
		if ($flag != 0) {
		
			system("perl Collate_SNPs_BestP_Specific_SaveMemE.pl PONS_Full_SansNonPosB.txt Namefiles.txt 100000 1 $i");		

		
		# Collation bit
		
		} else {
		
		# Initial collation bit
		
		
			system("perl Collate_SNPs_BestP_Specific_SaveMemE.pl PONS_Full_SansNonPosB.txt Namefiles.txt 100000 0 $i");
			$flag++;
	
			
		
		}
		
	
#	}
	
#	for (my $y=1; $y <= 25; $y++) {
		
#		$newnum=($innercount*25)+$y+99;
#		system("move plink.P$y.qassoc plink.P$newnum.qassoc");
		
#	}


	print("$i\n");

}
