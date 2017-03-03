use strict;
use warnings;
use Data::Dumper;
use Storable 'dclone';
no warnings 'experimental::smartmatch';
use feature 'say';

require 'base.pl';
require 'x86data.pl';
our $environment;

my %char2size = ( b => 8, w => 16, d => 32, p => 48, q => 64, x => 128, y => 256, z => 512 );
my %char2vsibSize = ();
grep { /^([xyz])$/ && ( $char2vsibSize{$1} = $char2size{$1} ) } keys %char2size;

# ---> Utils <---
{
	my @log = ();

	sub logOnce($) {
		local $_ = shift;
		return unless ( defined $_ );
		unless ( $_ ~~ @log ) {
			say $_;
			push( @log, $_ );
		}
	}
}

sub rmdup {
	my %seen;
	grep !$seen{$_}++, @_;
}

sub prettifyHashKeys {

	# prettify hash keys
	# eg:
	# my_key => myKey.
	# FOO    => foo.
	# foo    => foo.
	no warnings qw/recursion/;
	my $ref = $_[0];

	my $getPrettyName = sub($) {
		local $_ = $_[0];
		$_ = lc $_;
		s/_(.)/\u$1/g;
		$_;
	};

	if ( ref($ref) =~ /HASH/ ) {
		foreach ( keys %$ref ) {
			prettifyHashKeys( $ref->{$_} );
			my $prettyName = $getPrettyName->($_);
			$ref->{$prettyName} = delete $ref->{$_};
		}
	}
	elsif ( ref($ref) eq 'ARRAY' ) {
		prettifyHashKeys($_) foreach (@$ref);
	}
}

sub sortInsnKeys($) {
	my $insn = shift;
	eval 'require Tie::IxHash;';
	return $insn if ($@);    # not installed !
	tie my %sorted, 'Tie::IxHash';
	my @orders = qw/
	  mnemonic architecture vendor level deprecated lock
	  rep repe repne bnd branchType
	  suppressAllExceptions embeddedRounding
	  fpuTop fpuPush fpuPop
	  cpuid operands opcode
	  flags x87flags mxcsr
	  /;
	my %orders = ();
	my $order  = 1000;
	$orders{$_} = $order-- foreach (@orders);
	$sorted{$_} = $insn->{$_} foreach ( sort { ( $orders{$b} || 0 ) - ( $orders{$a} || 0 ) } keys %$insn );
	undef $insn;
	return \%sorted;
}

# ------------------------------------ ------------------------------------
sub processOperands($$) {
	( my $insn, local $_ ) = @_;
	s|\br/m(\d+)|r$1/m$1|;
	my @operands = ();
	$insn->{operands} = \@operands;
	my @args = split(/,\s*/);
	return unless ( scalar @args );
	my $initMem = sub($) {
		return 0 if ( defined $_[0]->{mem} );    # not initialized (exists before).
		$_[0]->{mem} = {
			type      => undef,
			size      => undef,
			seg       => undef,
			base      => undef,
			index     => undef,
			brdcst    => undef,
			vsib_size => undef,
		};
	};

	# set up default access.
	my @access = ( { read => 1, write => 1 }, ( { read => 1, write => 0 } ) x scalar @args - 1 );
	my $i = -1;
	foreach (@args) {
		$i++;
		s/(^\s+)|(\s+$)//g;
		warn("Argument is empty !\n") if (/^\s*$/);
		my $access = $access[$i];
		my $arg    = {
			optional => 0,
			embedded => 0,
			size     => undef,
			type     => undef,
			value    => undef,
			encoding => undef,
			mem      => undef,
			read     => $access->{read},
			write    => $access->{write}
		};

		# override access.
		{ ( $arg->{read}, $arg->{write} ) = ( /R|X/ || 0, /W|X/ || 0 ) if ( s/^([RXW]):\s*// && ( local $_ = $1 ) ) };

		$arg->{embedded} = $arg->{optional} = s/<\s*(.+)\s*>/$1/ || 0;

		my $brdcst = s|/b(\d+)|| ? $1 : undef;    # memory broadcast.

		# multiple tokens (XX/YY).
		my @types = ();
		foreach ( split '/' ) {
			s/(^\s+)|(\s+$)//g;
			if ( s/\s*\{(\w+)\}\s*// && ( my $word = $1 ) ) {

				# process inside {..}.
				( $arg->{mask}, $arg->{zeroing} ) = ( 1, defined($1) || 0 ) if ( $word =~ /^k(z)*$/ );
				$insn->{suppress_all_exceptions} = $arg->{vector_hint} = $word eq 'sae' || 0;
				$insn->{embedded_rounding}       = $arg->{vector_hint} = $word eq 'er'  || 0;
			}

			if (/^(rel|moffs|imm)(\d+)$/) {
				$arg->{size} = $2;
				push( @types, "$1$2" );
			}
			elsif (/ptr16:(\d+)/) {

				# no memory => only offset directly encoded in opcode.
				# selector:offset
				$arg->{size} = 16 + $1;
				push( @types, "ptr$1" );    # selector is always 16-bits !
			}
			elsif (/m(\d+)&(\d+)/) {

				# memory looks like : 'xxxxxxxx:yyyyyyyy'
				$initMem->($arg);
				my $size = $1 + $2;
				$arg->{mem}->{size} = $size;
				$arg->{mem}->{type} = "m$1-m$2";
				push( @types, "mem" );
			}
			elsif (/m16:(\d+)/) {
				my $size = 16 + $1;

				# memory contains 'selector:offset'
				$initMem->($arg);
				$arg->{mem}->{size} = $size;
				$arg->{mem}->{type} = "ptr$1";    # selector is always 16-bits !
				push( @types, "mem" );
			}
			elsif (s/\[(.+)\]//) {

				# memory = [seg:base+index]
				local $_ = $1;
				my $segment = my $base = my $index = '';
				$segment = $1 if (s/^(\w+)://);
				$base    = $1 if (s/^(\**\w+)//);
				$index   = $1 if (s/\+(\w+)//);
				$initMem->($arg);
				$arg->{mem}->{base}  = $base;
				$arg->{mem}->{index} = $index;
				$arg->{mem}->{seg}   = $segment;
				$arg->{embedded}     = 1;
				my $size = $insn->{mnemonic} =~ /([bwdq])$/ ? $char2size{$1} : undef;
				$arg->{mem}->{size} = $size;
				$arg->{mem}->{type} = "m$size" if ( defined $size );
			}
			elsif (/^reg$/) {
				$arg->{size} = 'PLATFORM_SIZE';
				push( @types, 'reg' );
			}
			elsif (/^\d+$/) {
				$arg->{value}    = $_;
				$arg->{size}     = 8;
				$arg->{embedded} = 1;
				push( @types, "imm8" );
			}
			elsif ( my %reginfo = getRegInfo( $insn->{environment}, $_ ) ) {
				$arg->{size}     = $reginfo{size};
				$arg->{embedded} = $reginfo{name} ne '' || 0;
				$arg->{value}    = $_ if ( $arg->{embedded} );
				push( @types, $reginfo{map} );
			}
			elsif (/^(v)*m[e]*[m]*(\d+)*(.+)*$/) {
				my $size = $2 // undef;
				my $vsibSize = $char2vsibSize{$3} if ( defined $1 && defined $3 );
				my $memtype = 'm';
				$memtype .= $size if ( defined $size );
				$memtype .= $3 if ( defined $3 && !defined $1 );
				$memtype = undef if ( $memtype eq 'm' );

				if ( !( $initMem->($arg) ) ) {

					#warn "arg in '$insn->{mnemonic} $data' has more than one memory\n";
					$arg->{mem}->{size} .= "|$size";
					$arg->{mem}->{type} .= "|$memtype";
				}
				else {
					$arg->{mem}->{size} = $size;
					$arg->{mem}->{type} = $memtype;
				}
				$arg->{mem}->{vsib_size} = $vsibSize;
				push( @types, "mem" );
			}
			else {
				warn "symbol '$_' not handled in operands\n";
			}

		}

		# make type looks nicely.
		@types = rmdup sort { ( $a =~ /mem/ ) - ( $b =~ /mem/ ) } @types;
		@types = grep( !/mem/, @types ) if ( scalar @types > 1 );
		my $type = join( '|', @types );
		$arg->{type} = $type;
		$arg->{mem}->{brdcst} = $brdcst if ( defined $brdcst );
		push( @operands, $arg );
	}
}

sub handleVectorPrefix($$) {
	( my $hash, local $_ ) = @_;
	my $full = $_;
	foreach ( split /\./ ) {
		if (/^(evex|vex|xop)$/) {
			$hash->{name} = $1;
			$hash->{size} = { xop => 3, evex => 4, vex => -1 }->{$1};
			$hash->{size} = $full =~ /((0f(38|3a)*))|(w([01]|ig))/ ? 3 : 2 if ( $hash->{size} == -1 );
		}
		elsif (/^(nds|ndd|dds)$/) {
			$hash->{vvvv} = $1;
		}
		elsif (/^(128|256|512)|(lz|l0|l1|lig)$/) {
			$hash->{length} = $1 // { lig => 'ignore', l0 => 128, lz => 128, l1 => 256 }->{$2};
		}
		elsif (/^(66|f3|f2)$/) {
			$hash->{pp} = $1;
		}
		elsif (/^(m8|m9|0f|0f3a|0f38)$/) {
			$hash->{mmmmm} = $1;
		}
		elsif (/^(wig|w\d+)$/) {
			$hash->{w} = { wig => 'ignore', w0 => 0, w1 => 1 }->{$1};
		}

		else {
			warn "'$_' not handled\n";
		}
	}
}

sub handleRexPrefix($$) {
	( my $hash, local $_ ) = @_;
	foreach ( split /\./ ) {
		if (/(drex|rex)/) {
			$hash->{size} = 1;
			$hash->{name} = $1;
			$hash->{oc0}  = $1 if (/drex(\d+)/);
		}
		elsif (/^w$/) {
			$hash->{w} = 1;
		}
		else {
			warn "'$_' not handled in rex\n";
		}
	}
}

sub fix_opcode($) {
	local $_ = shift;
	s-((/drex\d+)|(/is4))-/r $1- unless (m</r>);
	$_;
}

sub processOpcode($$) {
	( my $insn, local $_ ) = @_;

	# Easy way to handle 3dnow|escape.
	s/0f 0f/0f0f/;
	s/0f 38/0f38/;
	s/0f 3a/0f3a/;

	my @opcodes       = ();
	my $architecture  = $insn->{environment}->{internal}->{default_architecture};
	my @architectures = @{ $insn->{environment}->{internal}->{architectures} };
	my $openc         = '';
	my $tuple         = '';
	$architecture = $1 if ( /^\s*(\w+):\s*/ && $1 ~~ @architectures && s/^\s*(\w+):\s*// );
	$openc        = $1 if (s/^\s*(\w+):\s*//);
	$tuple        = $1 if (s/^\s*(\w+):\s*//);
	$insn->{internal}->{openc}  = $openc;
	$insn->{internal}->{tuple}  = $tuple;
	$_                          = fix_opcode $_;
	$insn->{internal}->{opcode} = $_;
	$insn->{architecture}       = $architecture;

	my @bytes  = ();
	my $escape = '';
	foreach (/(\S+)/g) {
		my $hash = { size => 1 };
		push( @opcodes, $hash );
		if (/[e]*vex|xop/) {
			handleVectorPrefix( $hash, $_ );
		}
		elsif (/rex|drex/) {
			handleRexPrefix( $hash, $_ );
		}
		elsif (/os(\d+)/) {
			$hash->{name}   = 'opsize';
			$hash->{value} = $1;
		}
		elsif (/as(\d+)/) {
			$hash->{name} = 'adsize';
			$hash->{value} = $1;
		}
		elsif (/^0f0f$/) {
			my $byte = hex($_);
			$hash->{name} = '3dnow';
			$escape = $hash->{value} = $byte;
			$hash->{size} = 2;
		}
		elsif (/^(0f(38|3a))$/) {
			my $byte = hex($1);
			$hash->{name} = 'escape';
			$escape = $hash->{value} = $byte;
			$hash->{size} = 2;
		}
		elsif ( /^0f$/ && !$escape && !( 0x0f ~~ @bytes ) ) {
			my $byte = hex($_);
			$hash->{name} = 'escape';
			$escape = $hash->{value} = $byte;
			push( @bytes, $byte );
		}
		elsif ( /^(66|f2|f3)$/ && !$escape ) {
			$hash->{name}  = "prefix";
			$hash->{value} = hex($1);
		}
		elsif (m</(\d+)|r>) {
			$hash->{name} = 'modrm';
			$hash->{reg} = $1 // undef;
		}
		elsif (/^([a-f0-9]{2})$/) {
			my $byte = hex($1);
			$hash->{name}  = 'opcode';
			$hash->{value} = $byte;
			$hash->{reg}   = undef;
			push( @bytes, $byte );
		}
		elsif (/^([iom])([bwdpq])$/) {
			my $name = { i => 'imm', o => 'offset', m => 'moffs' }->{$1};
			my $sz = $char2size{$2};
			$hash->{name} = "$name$sz";
			$hash->{size} = $sz / 8;
		}
		elsif (/is4$/) {
			$hash->{name} = 'imm8';
		}
		elsif (/^([a-f0-9]{2})\+(\w+)$/) {
			$hash->{name} = 'opcode';
			( $hash->{value}, $hash->{reg} ) = ( $1, $2 );
		}
		else {
			warn "'$_' not handled in opcode\n";
		}
	}
	$insn->{opcode} = \@opcodes;
}

sub applyEncoding($) {
	my $insn  = shift;
	my $openc = $insn->{internal}->{openc};
	my $tuple = $insn->{internal}->{tuple};
	my $count = length($openc);

	# check if openc is valid
	my $i = 0;
	foreach my $operand ( @{ $insn->{operands} } ) {
		next if ( $operand->{embedded} || $operand->{type} eq 'imm4' );
		$i++;
	}
	warn "op-encoding '$openc' is wrong in '$insn->{mnemonic} $insn->{internal}->{syntax}'\n" if ( $i != $count );

	my $tmp_openc = $openc;
	foreach my $operand ( @{ $insn->{operands} } ) {
		next if ( $operand->{embedded} );
		$operand->{mem}->{tuple} = $tuple if ( $operand->{type} =~ /mem/ );
		if ( $operand->{type} eq 'imm4' ) {

			# special case
			$operand->{encoding} = 'imm8.low';
			next;
		}
		$tmp_openc =~ s/(.)//;
		my $char = $1;
		if ( $char eq 'i' ) {

			# if register => imm8.high [4..7].
			$operand->{encoding} = $operand->{type} =~ /reg/ ? 'imm8.high' : "imm$operand->{size}";
		}
		elsif ( $char =~ /(r|m)/ ) {
			$operand->{encoding} = 'modrm.' . { r => 'reg', m => 'rm' }->{$1};
		}
		elsif ( $char eq 'v' ) {
			$insn->{internal}->{opcode} =~ /(evex|vex|xop)/;
			$operand->{encoding} = "$1.vvvv";
		}
		elsif ( my $value = { x => 'drex', o => 'opcode.reg' }->{$char} ) {
			$operand->{encoding} = $value;
		}
		elsif ( $char eq 'd' ) {
			my $field = 'offset';
			$field = 'moffs' if ( $insn->{internal}->{syntax} =~ /moffs/ );
			$operand->{encoding} = "$field$operand->{size}";
		}
		else {
			warn "'$char' not handled in encoding.\n";
		}
	}
}

sub processInstruction($$) {
	my ( $environment, $insnFields ) = @_;
	my $insn = dclone $environment->{template};
	$insn->{mnemonic}           = @$insnFields[0];
	$insn->{environment}        = $environment;
	$insn->{internal}->{syntax} = @$insnFields[1];
	processOpcode( $insn, @$insnFields[2] );
	processMetaData( $insn, @$insnFields[3] );
	processOperands( $insn, @$insnFields[1] );
	applyEncoding($insn);
	$insn->{ALIAS_OF} = lc $insn->{ALIAS_OF} if ( $insn->{ALIAS_OF} );
	delete $insn->{environment};
	delete $insn->{internal};
	return $insn;
}

sub processInstructions($) {
	my $environment = shift;
	my $insn;
	my @unpackedInstructions = ();
	foreach ( @{ $environment->{instructions} } ) {
		$insn = processInstruction( $environment, $_ );
		prettifyHashKeys($insn);
		push( @unpackedInstructions, $insn );

		#print Dumper $insn;
	}
	$environment->{instructions} = \@unpackedInstructions;
}

sub processEnvironment($) {
	my $environment = shift;
	$environment->{shortcuts} = unpackShortCuts( $environment->{shortcuts} );
	foreach ( keys %{ $environment->{architectures} } ) {
		my $hash = $environment->{architectures}->{$_};
		$hash->{default} ? $environment->{internal}->{default_architecture} = $_ : push( @{ $environment->{internal}->{architectures} }, $_ );
	}
	processInstructions($environment);

	my %registers = ();
	while ( my ( $key, $value ) = each %{ $environment->{registers} } ) {
		my $name = $value->{map};
		$registers{$name} = { %{ $environment->{registers}->{$key} } };
		delete $registers{$name}->{map};
	}
	$environment->{registers} = \%registers;
	delete $environment->{internal};
	delete $environment->{shortcuts};
	delete $environment->{template};
}

sub getEnvironment() {
	processEnvironment($environment);
	return $environment;
}

1;
