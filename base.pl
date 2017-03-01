use strict;
use warnings;

sub unpackShortCuts($) {
	my $packed    = shift;
	my @shortcuts = ();
	foreach (@$packed) {
		my @names = ();
		my ($type) = grep( /^(expand|map)$/, keys %$_ );
		my $to = $_->{to};
		push( @names, ref( $_->{$type} ) eq 'ARRAY' ? @{ $_->{$type} } : $_->{$type} );
		push( @shortcuts, { name => $_, $type => $to } ) foreach (@names);
	}
	\@shortcuts;
}

sub mapShortCuts($$) {
	my ( $fields, $shortcuts ) = @_;
	foreach (@$fields) {
		foreach my $shortcut (@$shortcuts) {
			if ( exists $shortcut->{map} && $shortcut->{name} eq $_ ) {
				$_ = "$shortcut->{map}=$_";
				last;
			}
		}
	}
}

sub expandShortCuts($$) {
	my ( $fields, $shortcuts ) = @_;
	foreach (@$fields) {
		/^(\S+?)=/;
		my $name = $1;
		foreach my $shortcut (@$shortcuts) {
			if ( exists $shortcut->{expand} && $shortcut->{name} eq $name ) {
				s/\Q$_\E/$shortcut->{expand}.$_/;
				last;
			}
		}
	}
}

sub getParent($$) {
	my ( $hash, $name ) = @_;
	my @names = split( /\./, $name );
	my $i = 0;
	foreach (@names) {
		return $hash if ( $i == $#names );
		$hash = $hash->{$_};
		$i++;
	}
	return undef;
}

sub setData($$$) {
	my ( $parent, $field, $value ) = @_;
	if ( ref( $parent->{$field} ) =~ /ARRAY/ ) {
		push( @{ $parent->{$field} }, split( /\|/, $value ) );
	}
	elsif ( ref( $parent->{$field} ) =~  /HASH/ ) {
		$parent->{$field}->{$_} = 1 foreach ( split( ':', $value ) );
	}
	else {
		$parent->{$field} = $value;
	}
}

sub processMetaData($$) {
	my ( $insn, $data ) = @_;
	my @fields = $data =~ /(\S+)/g;
	mapShortCuts( \@fields, $insn->{environment}->{shortcuts} );
	expandShortCuts( \@fields, $insn->{environment}->{shortcuts} );
	foreach (@fields) {
		my $parent = $insn;
		/^(.+?)([=:])(.+)$/ || /(\S+)/;
		my $name = $1;
		my $value =  $3 // 1;
		$parent = getParent( $insn, $name );
		$name =~ s/.+\.//;
		setData( $parent, $name, $value );
	}
}

sub getRegInfo($$) {
	my ( $environment, $regname ) = @_;
	foreach my $key ( keys %{ $environment->{registers} } ) {
		my $value = $environment->{registers}->{$key};
		return ( name => '', type => $key, map => $value->{map}, size => $value->{size} ) if ( $key eq $regname );
	}
	foreach my $key ( keys %{ $environment->{registers} } ) {
		my $value = $environment->{registers}->{$key};
		foreach ( @{ $value->{names} } ) {
			return ( name => $_, type => $key, map => $value->{map}, size => $value->{size} ) if ( $_ eq $regname );
		}
	}
	();
}

1;
