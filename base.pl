use strict;
use warnings;
use Data::Dumper;
no warnings 'experimental::smartmatch';

sub getParent($$) {
	( my $hash, local $_ ) = @_;
	$hash = $hash->{$1} while (s/^([^\.]+)\.//);
	return $hash;
}

sub setData($$$) {
	( my $hash, my $name, local $_ ) = @_;
	if ( ref( $hash->{$name} ) =~ /ARRAY/ ) {
		push( @{ $hash->{$name} }, split /\|/ );
	}
	elsif ( ref( $hash->{$name} ) =~ /HASH/ ) {
		$hash->{$name}->{$_} = 1 foreach ( split /\|/ );
	}
	else {
		$hash->{$name} = $_;
	}
}

sub applyShortCuts($$$) {
	my ( $name, $value, $shortcuts ) = @_;
	local $_ = '';
	for ( my $i = 0 ; $i < scalar @$shortcuts ; $i += 2 ) {
		my $shortcut = @$shortcuts[$i];
		my @names = $shortcut =~ /^ARRAY\(.+\)$/ ? @$shortcut : $shortcut;
		if ( $name ~~ @names ) {
			$_ = @$shortcuts[ $i + 1 ];
			s/\$/$name/;
			last;
		}
	}
	( $name, $value ) = ( $1, $2 // $value ) if (s/^([^\=]+)\=*(.+)*//);
	return ( $name, $value );
}

sub processMetaData($$$) {
	( my $template, local $_, my $shortcuts ) = @_;
	while ($_) {
		die "Can't match tokens in meta-data."
		  unless (s/^\s*([^\=\s+]+)(?:(?:\=(?|(?:"\s*(.+?)\s*")|(\S+))))*\s*//);
		my ( $name, $value ) = applyShortCuts( $1, $2 // 1, $shortcuts );
		my $parent = getParent( $template, $name );
		$name =~ s/.+\.//;
		setData( $parent, $name, $value );
	}
}

sub getRegInfo($$) {
	my ( $environment, $regname ) = @_;

	foreach my $key ( keys %{ $environment->{registers} } ) {
		my $hash = $environment->{registers}->{$key};
		return ( name => '', type => $hash->{type}, size => $hash->{size} ) if ( $key eq $regname );
	}

	foreach my $key ( keys %{ $environment->{registers} } ) {
		my $hash = $environment->{registers}->{$key};
		foreach ( @{ $hash->{names} } ) {
			return ( name => $_, type => $hash->{type}, size => $hash->{size} ) if ( $_ eq $regname );
		}
	}
	();
}
1;
