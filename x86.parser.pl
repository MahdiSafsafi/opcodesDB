use strict;
use warnings;
use Storable 'dclone';
use Data::Dumper;
no warnings 'experimental::smartmatch';
require 'base.pl';
require 'utils.pl';

my %char2size = ( b => 8, w => 16, d => 32, p => 48, q => 64, x => 128, y => 256, z => 512 );
my %char2vsibSize = ();
grep { /^([xyz])$/ && ( $char2vsibSize{$1} = $char2size{$1} ) } keys %char2size;

sub processOperands($$) {
	( my $insn, local $_ ) = @_;
	my $log = $_;
	s|\br/m(\d+)|r$1/m$1|g;

	my @args = ();
	$insn->{operands} = \@args;
	my $encoding = $insn->{private}->{opencoding};
	my $tuple    = $insn->{private}->{tuple};
	my $initMem  = sub($) {
		my $arg = shift;
		return 0 if ( %{ $arg->{mem} } );

		$arg->{mem} = {
			type      => '',
			segment   => '',
			base      => '',
			index     => '',
			scale     => 0,
			size      => 0,
			broadcast => 0,
			vsibSize  => 0,
			tuple     => '',
		};
		return 1;
	};

	my @access = ( 'X', ('R') x ( ( my $count = () = /,/g ) + 1 ) );
	foreach ( split /,\s*/ ) {
		my $arg = {
			type       => '',
			optional   => 0,
			embedded   => 0,
			masking    => 0,
			zeroing    => 0,
			size       => 0,
			signed     => 0,
			value      => '',
			vectorHint => 0,
			mem        => {},
			read       => 0,
			write      => 0,
		};
		push( @args, $arg );
		my $access = shift @access;
		$access = $1 if (s/^([RWX]):\s*//);    # override access.
		( $arg->{read}, $arg->{write} ) = ( @{ { R => [ 1, 0 ], W => [ 0, 1 ], X => [ 1, 1 ] }->{$access} } );

		$arg->{embedded} = $arg->{optional} = s/<\s*(.+)\s*>/$1/ || 0;
		my @types = ();
		foreach ( split '/' ) {
			if ( s/\s*\{(\w+)\}\s*// && ( my $inside = $1 ) ) {

				# process inside {...}.
				( $arg->{masking}, $arg->{zeroing} ) = ( 1, $1 // 0 ) if ( $inside =~ /^k(z)*$/ );
				$insn->{suppressAllExceptions} = $arg->{vectorHint} = $inside eq 'sae';
				$insn->{embeddedRounding}      = $arg->{vectorHint} = $inside eq 'er';
			}
			if (/^b(\d+)$/) {
				$initMem->($arg);
				$arg->{mem}->{broadcast} = $1;
			}
			elsif (/^\d+$/) {

				# embedded constant
				( $arg->{value}, $arg->{size}, $arg->{embedded} ) = ( $_, 8, 1 );
				push( @types, "imm8" );
			}
			elsif (/^(rel|moffs|[p]*imm|ptr)(\d+):*(\d+)*$/) {
				$arg->{size} = my $sz = $2 + ( $3 // 0 );
				push( @types, "$1$sz" );
				$arg->{signed} = !/pimm/ || 0;
			}
			elsif (/^m(\d+)([&:])(\d+)$/) {

				# memory looks like : ('xxxxxxxx:yyyyyyyy') || ('selector:offset')
				my $sz = $1 + $3;
				my $type = { '&' => "m$1-m$3", ':' => "ptr$sz" }->{$2};
				$initMem->($arg);
				( $arg->{mem}->{size}, $arg->{mem}->{type} ) = ( $sz, $type );
				push( @types, "mem" );
			}
			elsif ( s/\[(.+)\]/$1/ && s/(?:(\w+):)*(\**\w+)*(?:\+(\w+))*// ) {

				# memory = [seg:base+index]
				$initMem->($arg);
				( $arg->{embedded}, $arg->{mem}->{segment}, $arg->{mem}->{base}, $arg->{mem}->{index} ) = ( 1, $1, $2, $3 );
				push( @types, 'mem' );
			}

			# The following block must be before the memory block !
			elsif ( my %reginfo = getRegInfo( $insn->{private}->{environment}, $_ ) ) {
				( $arg->{size}, $arg->{embedded} ) = ( $reginfo{size}, $reginfo{name} ne '' || 0 );
				$arg->{value} = $_ if ( $arg->{embedded} );
				push( @types, $reginfo{type} );
			}
			elsif (/^(v)*(?:me)*m(\d+)*(.+)*$/) {

				# mem|m\d+|vm\d+[xyz]|m\d+xx
				my $sz = $2 // 0;
				my $vsibSize = defined $1 && defined $3 ? $char2vsibSize{$3} : 0;
				my $type = '';
				$type .= $sz if ($sz);
				$type .= $3  if ( defined $3 );
				$type = 'm' . $type if ($type);
				$initMem->($arg);
				( $arg->{mem}->{size}, $arg->{mem}->{type}, $arg->{mem}->{vsibSize} ) = ( $sz, $type, $vsibSize );
				$arg->{mem}->{tuple} = $tuple;
				push( @types, 'mem' );
			}
			else {
				warn "symbol '$_' not handled in operands.";
			}
		}
		@types = rmdup( sort { ( $a =~ /mem/ ) - ( $b =~ /mem/ ) } @types );
		@types = grep( !/mem/, @types ) if ( scalar @types > 1 );
		$arg->{type} = join( '|', @types );
		if ( !$arg->{embedded} && $encoding =~ s/^(.)// ) {
			local $_ = $1;
			my %char2encoding = (
				r => 'modrm.reg',
				m => 'modrm.rm',
				v => 'vvvv',
				i => 'imm',
				d => 'offset',
				x => 'drex.dst',
				o => 'opcode.reg'
			);
			my $sz = '';
			$sz = $arg->{size} if (/^i|d$/);
			my $encoding = $char2encoding{$_};
			$encoding = 'moffs' if ( $arg->{type} =~ /moffs/ );
			$encoding .= $sz;
			$encoding = 'imm8.low'  if ( $_ eq 'i' && $sz =~ /^4$/ );
			$encoding = 'imm8.high' if ( $_ eq 'i' && $arg->{type} =~ /reg/ );
			$arg->{encoding} = $encoding;
		}
	}
}

sub processOpcodes($$) {
	( my $insn, local $_ ) = @_;
	
	my $architectures = $insn->{private}->{environment}->{architectures};
	$insn->{architecture} = join( '|', sort keys %$architectures );
	$insn->{architecture} = $1 if ( /^\s*(\w+):/ && exists $architectures->{$1} && $_ =~ s/^\s*(\w+):\s*// );
	$insn->{private}->{opencoding} = $1 if (s/^\s*(\w+):\s*//);
	$insn->{private}->{tuple}      = $1 if (s/^\s*(\w+):\s*//);

	s/0f\s+(0f|38|3a)/0f$1/;    # easy way to handle escape !
	s/\./ /g;

	my $opcodes = {
		escape            => '',
		opsize            => 0,
		addressSize       => 0,
		encoding          => '',
		vvvv              => '',
		length            => 0,
		oc0               => undef,
		w                 => undef,
		regcode           => undef,
		modrm             => 0,
		vsib              => 0,
		mandatoryPrefixes => [],
		opcodes           => [],
		fields            => [],
	};
	$insn->{opcodes} = $opcodes;

	while (s/\s*(\S+)\s*//) {
		local $_ = $1;
		$opcodes->{encoding} = $1 if (s/^([e]*vex|xop|[d]*rex)$//);
		$opcodes->{vvvv}     = $1 if (s/^(nds|ndd|dds)$//);
		$opcodes->{length} = ( $1 // { lig => 0, l0 => 128, lz => 128, l1 => 256 }->{$2} ) if (s/^(128|256|512)|(lz|l0|l1|lig)$//);
		$opcodes->{oc0} = $1 if (s/^oc(\d+)$//);
		$opcodes->{w} = { wig => 'ignore', w0 => 0, w => 1, w1 => 1 }->{$1} if (s/^(wig|w\d+|w)$//);
		push( @{ $opcodes->{mandatoryPrefixes} }, $1 ) if ( $opcodes->{escape} eq '' && s/^(66|f0|f2|f3)$// );
		$opcodes->{escape}      = $1 if ( ( $opcodes->{escape} eq '' && s/^(0f|d[8-9a-f]|0f3[8a]|0f0f|m8|m9)$// ) );
		$opcodes->{opsize}      = $1 if (s/^os(\d+)$//);
		$opcodes->{addressSize} = $1 if (s/^as(\d+)$//);
		$opcodes->{vsib}        = 1  if (s/^vsib$//);
		push( @{ $opcodes->{fields} }, 'imm8' ) if (s/^is4$//);

		if (s/^([0-9a-f]+)\+*(\w+)*//) {
			push( @{ $opcodes->{opcodes} }, $1 );
			$opcodes->{regcode} = $2 if ( defined $2 );
		}
		elsif (s'/r|/(\d+)'') {
			$opcodes->{modrm} = 1;
			push( @{ $opcodes->{opcodes} }, "/$1" ) if ( defined $1 );
		}
		elsif (s/^([mio])([bwdqp])$//) {
			my $name = { i => 'imm', o => 'offset', m => 'moffs' }->{$1} . $char2size{$2};
			push( @{ $opcodes->{fields} }, $name );
		}
		warn "'$_' not handled in opcodes." if ($_);
	}
	( $opcodes->{w}, $opcodes->{encoding} ) = ( 1, 'rex' ) if ( $opcodes->{opsize} == 64 );

}

sub processInstruction($$) {
	my ( $environment, $fields ) = @_;
	my ( $mnemonic, $operands, $opcodes, $meta ) = @$fields;
	my $insn = dclone $environment->{template};
	$insn->{private}->{environment} = $environment;
	$insn->{mnemonic} = $mnemonic;
	processMetaData( $insn, $meta, $environment->{private}->{shortcuts} );
	processOpcodes( $insn, $opcodes );
	processOperands( $insn, $operands );
	delete $insn->{private};
	return $insn;
}

sub processInstructions($) {
	my $environment = shift;
	foreach ( @{ $environment->{instructions} } ) {
		$_ = processInstruction( $environment, $_ );

		#print Dumper $_;
	}
}

sub parser($) {
	my $environment = shift;
	processInstructions($environment);
}

1;
