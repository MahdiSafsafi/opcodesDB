use strict;
use warnings;
use Data::Dumper;

my $environments = {};

sub getEnvironment($) {
	my $name        = shift;
	my $environment = $environments->{$name};
	$environment->{private}->{parser}->($environment);
	delete $environment->{private};
	return $environment;
}

sub registerEnvironment($) {
	my $script = shift;
	our $environment = {};
	require $script;
	my $name = $environment->{name};
	die "Duplicated environment '$environment->{name}' !" if ( exists $environments->{$name} );
	$environments->{$name} = $environment;
}

sub registerEnvironments() {
	registerEnvironment('x86.pl');
}

registerEnvironments();
1;
