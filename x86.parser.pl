use strict;
use warnings;
use Storable 'dclone';
use Data::Dumper;
no warnings 'experimental::smartmatch';

require 'base.pl';
require 'utils.pl';

# Useful conversions
my %char2size = ( b => 8, w => 16, d => 32, p => 48, q => 64, x => 128, y => 256, z => 512 );
my %char2vsibSize = ();
grep { /^([xyz])$/ && ( $char2vsibSize{$1} = $char2size{$1} ) } keys %char2size;
my %char2encoding = (
	r => 'modrm.reg',
	m => 'modrm.rm',
	v => 'vvvv',
	i => 'imm',
	d => 'offset',
	x => 'drex.dst',
	o => 'opcode.reg'
);

sub processOperands($$) {
	( my $insn, local $_ ) = @_;
	s|\br/m(\d+)|r$1/m$1|g;

	my @args = ();
	$insn->{operands} = \@args;
	my $encoding = $insn->{private}->{opencoding};
	my $tuple    = $insn->{private}->{tuple};
	my $initMem  = sub($) {
		%{ $_[0] } = (
			variant   => 'memory',
			type      => '',
			segment   => '',
			base      => '',
			index     => '',
			scale     => 0,
			size      => 0,
			broadcast => 0,
			vsibSize  => 0,
			tuple     => '',
		);
	};
	my @access = ( 'X', ('R') x ( ( my $count = () = /,/g ) + 1 ) );
	foreach ( split /,\s*/ ) {
		my $arg = {
			optional   => 0,
			embedded   => 0,
			masking    => 0,
			zeroing    => 0,
			vectorHint => 0,
			read       => 0,
			write      => 0,
			variants   => [],
		};
		push( @args, $arg );

		# Set access (read|write)
		my $access = shift @access;    # default access.
		$access = $1 if (s/^([RWX]):\s*//);    # override access.
		( $arg->{read}, $arg->{write} ) = ( @{ { R => [ 1, 0 ], W => [ 0, 1 ], X => [ 1, 1 ] }->{$access} } );
		$arg->{embedded} = $arg->{optional} = s/<\s*(.+)\s*>/$1/ || 0;

		# Extract broadcast size.
		my $broadcast = s'/b(\d+)'' ? $1 | 0 : 0;

		# Process multiple operands (varaints).
		foreach ( split '/' ) {
			my $variant = {};
			push( @{ $arg->{variants} }, $variant );

			if ( s/\s*\{(\w+)\}\s*// && ( my $inside = $1 ) ) {

				# process inside {...} : {k}{z}{er}{sae}.
				( $arg->{masking}, $arg->{zeroing} ) = ( 1, defined $1 || 0 ) if ( $inside =~ /^k(z)*$/ );
				$insn->{suppressAllExceptions} = $arg->{vectorHint} = $inside eq 'sae' || 0;
				$insn->{embeddedRounding}      = $arg->{vectorHint} = $inside eq 'er'  || 0;
			}
			if (/^\d+$/) {

				# embedded constant
				( $arg->{embedded}, $variant->{value}, $variant->{size}, $variant->{signed}, $variant->{variant}, $variant->{type} ) =
				  ( 1, $_, 8, 0, qw/immediate pimm8/ );
			}
			elsif (/^(rel|moffs|p*imm|ptr)(\d+):*(\d+)*$/) {
				$variant->{size} = my $sz = $2 + ( $3 // 0 );
				( $variant->{variant}, $variant->{type}, $variant->{signed}, $variant->{value} ) = ( q/immediate/, qq/$1$sz/, !/pimm/ || 0, '' );
			}
			elsif (/^m(\d+)([&:])(\d+)$/) {

				# memory looks like : ('xxxxxxxx:yyyyyyyy') || ('selector:offset')
				my $sz = $1 + $3;
				my $type = { '&' => "m$1-m$3", ':' => "ptr$sz" }->{$2};
				$initMem->($variant);
				( $variant->{size}, $variant->{type} ) = ( $sz, $type );

			}
			elsif (s/\[(?:(\w+):)*(\**\w+)*(?:\+(\w+))*\]//) {

				# memory = [seg:base+index]
				$initMem->($variant);
				( $arg->{embedded}, $variant->{segment}, $variant->{base}, $variant->{index} ) = ( 1, $1, $2, $3 );
			}

			# The following block must be before the memory block !
			elsif ( my %reginfo = getRegInfo( $insn->{private}->{environment}, $_ ) ) {

				# Process register
				( $variant->{variant}, $variant->{type}, $variant->{size}, $arg->{embedded} ) =
				  ( 'register', $reginfo{type}, $reginfo{size}, $reginfo{name} ne '' || 0 );
				$variant->{value} = $arg->{embedded} ? $_ : '';
			}
			elsif (/^(v)*(?:me)*m(\d+)*(.+)*$/) {

				# Process memory...
				# mem|m\d+|vm\d+[xyz]|m\d+xx
				my $sz = $2 // 0;
				my $vsibSize = defined $1 && defined $3 ? $char2vsibSize{$3} : 0;
				my $type = '';
				$type .= $sz if ($sz);
				$type .= $3  if ( defined $3 );
				$type = 'm' . $type if ($type);
				$initMem->($variant);
				( $variant->{size}, $variant->{type}, $variant->{vsibSize}, $variant->{broadcast}, $variant->{tuple} ) =
				  ( $sz, $type, $vsibSize, $broadcast, $tuple );
			}
			else {
				warn "symbol '$_' not handled in operands.";
			}
		}

		# Apply encoding.
		if ( !$arg->{embedded} && $encoding =~ s/^(.)// ) {
			local $_ = $1;
			my $sz = /^i|d$/ ? $arg->{variants}[0]->{size} : '';
			my $encoding = $char2encoding{$_};
			$encoding = 'moffs' if ( $arg->{variants}[0]->{type} =~ /moffs/ );
			$encoding .= $sz;
			$encoding = 'imm8.low'  if ( $_ eq 'i' && $sz =~ /^4$/ );
			$encoding = 'imm8.high' if ( $_ eq 'i' && $arg->{variants}[0]->{type} =~ /reg/ );
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
		$opcodes->{encoding} = $1 if (s/^(e*vex|xop|d*rex)$//);
		$opcodes->{vvvv}     = $1 if (s/^(nds|ndd|dds)$//);
		$opcodes->{length} = ( $1 // { lig => 0, l0 => 128, lz => 128, l1 => 256 }->{$2} ) if (s/^(128|256|512)|(lz|l0|l1|lig)$//);
		$opcodes->{oc0} = $1 if (s/^oc(\d+)$//);
		$opcodes->{w} = { wig => 'ignore', w0 => 0, w => 1, w1 => 1 }->{$1} if (s/^(wig|w\d+|w)$//);
		push( @{ $opcodes->{mandatoryPrefixes} }, $1 ) if ( $opcodes->{escape} eq '' && s/^(66|f0|f2|f3)$// );
		$opcodes->{escape}      = $1 if ( ( $opcodes->{escape} eq '' && s/^(0f|d[8-9a-f]|0f3[8a]|0f0f|m8|m9)$// ) );
		$opcodes->{opsize}      = $1 if (s/^os(\d+)$//);
		$opcodes->{addressSize} = $1 if (s/^as(\d+)$//);
		$opcodes->{vsib}        = 1  if (s/^vsib$//);

		if (s/^([0-9a-f]+)\+*(\w+)*$//) {
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

		# Special case !
		push( @{ $opcodes->{fields} }, 'imm8' ) if (s/^is4$//);

		warn "'$_' not handled in opcodes." if ($_);
	}

	# Opsize == 64 ? => Include REX.W !
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

sub parser($) {
	my $environment = shift;
	$_ = processInstruction( $environment, $_ ) foreach ( @{ $environment->{instructions} } );
}

1;
