use strict;
use warnings;
use JSON;
require 'environments.pl';

sub exportEnvironment2json($$) {
	my $environment = shift;
	my $file        = shift;
	open F, '>', $file || die "Enable to create '$file' $!\n";
	my $json = JSON->new->pretty->encode($environment);
	print F $json;
	close F;
}

if ( scalar @ARGV ) {
	my $environmentName = $ARGV[0];
	my $dstFile         = $ARGV[1];
	print "Fetching environment ...\n";
	my $environment = getEnvironment($environmentName);
	print "Exporting to JSON ('$dstFile') ...\n";
	exportEnvironment2json( $environment, $dstFile );
	print "Done\n";
}

1;
