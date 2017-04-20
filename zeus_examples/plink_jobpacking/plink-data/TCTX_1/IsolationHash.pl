# Script to pull all lines found in first input file that also contain
# (regexp-wise) a line from the second file

open(IN, "$ARGV[0]");
open(IN2, "$ARGV[1]");
open(OUT, ">$ARGV[2]");


foreach(<IN2>) {

	$theline=$_;
	chomp $theline;
	$hashy{$theline}=1;


}


foreach (<IN>) {

	$line=$_;
	chomp $line;
	
	if ($line =~ /^.*?:.*?:(.*?)\t/) {
	
		if (exists $hashy{$1}) {
		
			printf(OUT "$line\n");
		
		
		}	
	
	}
	

}