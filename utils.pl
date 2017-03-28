use strict;
use warnings;

sub rmdup(@) {
	my %seen;
	grep !$seen{$_}++, @_;
}

1;
