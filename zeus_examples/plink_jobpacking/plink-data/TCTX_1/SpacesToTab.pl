$caserisk=0;
$casetotal=0;
$controlrisk=0;
$controltotal=0;


opendir(thedir, ".");
@contents = grep !/^\.\.?$/, readdir thedir;

foreach(@contents) {

	if ($_ =~ /(.*)\.profile/) {
	
		open(IN, "$_");
		open(OUT, ">$1.tsv");
		
		foreach(<IN>) {
		
			$theline=$_;
			chomp $theline;
			$theline=~s/\s+/\t/g;
			printf(OUT "$theline\n");
		
		
		}
	
	}

}