use strict;
use warnings;
use Data::Dumper;
require 'environments.pl';
my $environment = getEnvironment('x86');
foreach my $instruction ( @{ $environment->{instructions} } ) {
	print Dumper $instruction;

	# do something with $instruction ...
}

print "Done\n";
