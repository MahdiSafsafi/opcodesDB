use strict;
use warnings;
use JSON;

sub exportEnvironment2json($$) {
	my $environment = shift;
	my $file        = shift;
	open F, '>', $file || die "Enable to create '$file' $!\n";
	my $json = JSON->new->pretty->encode($environment);
	print F $json;
	close F;
}

if ( scalar @ARGV ) {
	require 'x86.pl';
	my $dstFile = $ARGV[0];
	print "Fetching environment ...\n";
	my $environment = getEnvironment();
	print "Exporting to JSON ('$dstFile') ...\n";
	exportEnvironment2json($environment,$dstFile);
	print "Done\n";
}

1;
