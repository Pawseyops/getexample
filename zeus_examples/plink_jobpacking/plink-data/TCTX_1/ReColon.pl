
open(IN, "$ARGV[0]");
open(OUT, ">$ARGV[1]");

foreach(<IN>) {

	if ($_ =~ /^(.+?)\t(.+?)\t(.*?)\t(.*)\n/) {

		printf(OUT "$1:$2:$3\t$4\n");
		
		
	}

}
