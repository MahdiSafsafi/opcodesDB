
use strict;
use warnings;
use Data::Dumper;

require'x86.pl';

my $environment = getEnvironment();
foreach my $instruction ( @{ $environment->{instructions} } ) {
	print Dumper $instruction;
	# do something with $instruction ...
}

print "Done\n";
