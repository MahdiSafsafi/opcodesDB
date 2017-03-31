
# ===> x86 instruction set <===

# Author = Mahdi Safsafi.

# https://github.com/MahdiSafsafi/opcodesDB

# INSTRUCTIONS
# ------------
#
# Each instruction definition consists of 4 strings:
#
#   [0] - Instruction mnemonic.
#   [1] - Instruction operands.
#   [2] - Instruction opcode.
#   [3] - Instruction metadata - CPU requirements, FLAGS (read/write), and other metadata.

# OPCODE
# ------
# Pattern : [arch]*:[openc]*:[tuple]*:opcode.
# * means optional.
# arch   = x86|x64. Default to (Both) if absent.
# openc  = Instruction operands encoding. Default to NONE if absent.
#   - x => DREX.
#   - r => MODRM.REG.
#   - m => MODRM.R/M.
#   - v => VEX.vvvv.
#   - i => Imm.
#   - d => Data offset.
#   - o => Opcode.
# tuple  = evex memory tuple. Must present when there is a memory with evex encoding.
#          If tuple is present, openc must too !
# opcode = Similar to Intel notation. However there is some difference here:
#   - m[bwdq] = moffs.
#   - o[bwdq] = code offset for branch.
#   - as16|as32|as64 = instruction must be encoded with specific address size.
#   - os16 = 66 prefix is required for instruction.
#   - os32 = rex prefix can't be used if (arch == x64).
#   - os64 = instruction requires rex.w.
#   - os   = opsize can be [16,32,64].
#   - osv  = opsize can only be [32,64].
#   - osz  = opsize can only be [16,32].
#   - e*vex.vu = vector length can't be 128 => VL in [256,512].
#   - e*vex.vx = vector length can't be 512 => VL in [128,256]. 

# OPERANDS
# --------
# Notations: length is opsize length for legacy instruction 
#            and is vector length (VL) for SIMD instructions.
#
# All inside <> are optional.
# Read|Write info:
#  - R: Read.
#  - W: Write.
#  - X: Read && Write.
# If absent it defaults to (X,R,R,R,R,...).
# * means any sub register eg: *di means di|edi|rdi.
# b[n] = n = broadcast size in bits.
# 
# Packed form: 
# vmm  = register size = length.
# vm   = memory size   = length.
# .N   = size = (length/N). eg: vm.2 => Size of memory is half of length.
# .low = size = LowOf(length):
#                  - VL:512 => 256.
#                  - VL:256 => 128.
#                  - VL:128 => 128.
#                  - OS:64  => 32.
#                  - OS:32  => 16.
#                  - OS:16  => 16.
# vm[sz][n]: 'sz' is memory size in bits. 'n' is vsib size:
#                  - x => vsibSize = 128.
#                  - y => vsibSize = 256.
#                  - z => vsibSize = 512.
#                  - v => vsibSize = VL .
#                  - l => vsibSize = LowOf(VL).

# META-DATA
# ---------
# deprecated = Instruction no longer supported.
#
# abandoned  = There is no available CPU that decodes the instruction (eg: AMD SSE5).
#
# undocumented = There is no official documentation about the instruction.
#
# level = Privilege level. Default to 3 if absent.
#
# cpuid = Instruction cpuid fields (separated by '|').
#         Carefully interpret cpuid when cpuid = [avx-2|avx512*-vl]:
#                             - avx-2 => AVX2 applies only when VL = 256.
#                                        AVX  applies only when VL = 128.
#                             - avx512*-vl => AVX512*VL applies only when VL != 512.
#                                             AVX512*   applies only when VL =  512.
# 
#
# branchType = short|near|far.
#
# lock=[ATTRIBUTES]*
# lock:If present it means that the instruction is lockable.
# ATTRIBUTES:
#  - hardware: Hardware lock is supported.
#  - legacy  : Locking using legacy LOCK prefix is supported.
#  - implied : Instruction is lockable either with or without the presence of the LOCK.
#  - explicit: LOCK prefix is required for hardware lock.
#  - ignore  : Accept LOCK but ignore it because memory is not the destination operand.
#
# bnd = Instruction supports BND prefix.
#
# rep|repe|repne = Prefix is allowed.
#
# stackPtr = N. Instruction increments/decrements stack pointer by N bytes.
#
# fpuStackPtr = N. Instruction increments/decrements fpu stack pointer by N bytes.
#
# aliasOf = Instruction is an alias to another instruction.
#
# form = Instruction has more than one form for encoding and decoding.
#        disassembler should select either the preferred form or the alternative form.
#
# eflags|x87Flags|mxcsr:
#  - T = instruction Tests flag.
#  - M = instruction Modifies flag.
#  - C = instruction sets flag to zero (Clear).
#  - S = instruction Sets flag to 1 (Set).
#  - U = Undefined.
#  - N = Not affected.
#  - X = TM.


# TODO
# ----
# Fix mov instruction (Add: mov,r32,sreg).

use strict;
use warnings;
use File::Basename;

my $PLATFORM_SIZE = qw(PLATFORM_SIZE);

my %architectures = (
	'x86' => { size => 32 },
	'x64' => { size => 64 },
);

my %registers = (
	r8  => { type => 'reg8',  size => 8,  names => [qw/al cl dl bl ah ch dh bh/] },
	r8x => { type => 'reg8x', size => 8,  names => [ qw/al cl dl bl spl bpl sil dil/, map "r${_}b", 0 .. 15 ] },
	r16 => { type => 'reg16', size => 16, names => [ qw/ax cx dx bx sp bp si di/, map "r${_}w", 0 .. 15 ] },
	r32 => { type => 'reg32', size => 32, names => [ qw/eax ecx edx ebx esp ebp esi edi/, map "r${_}d", 0 .. 15 ] },
	r64 => { type => 'reg64', size => 64, names => [ qw/rax rcx rdx rbx rsp rbp rsi rdi/, map "r$_", 0 .. 15 ] },
	'st(i)' => { type => 'fpureg', size => 64,             names => [ map "st($_)",   0 .. 07 ] },
	mm      => { type => 'mmreg',  size => 64,             names => [ map 'mm' . $_,  0 .. 07 ] },
	creg    => { type => 'creg',   size => $PLATFORM_SIZE, names => [ map 'cr' . $_,  0 .. 15 ] },
	dreg    => { type => 'dreg',   size => $PLATFORM_SIZE, names => [ map 'dr' . $_,  0 .. 15 ] },
	k       => { type => 'kreg',   size => 64,             names => [ map 'k' . $_,   0 .. 07 ] },
	bnd     => { type => 'bndreg', size => 128,            names => [ map 'bnd' . $_, 0 .. 03 ] },
	xmm     => { type => 'xmmreg', size => 128,            names => [ map 'xmm' . $_, 0 .. 31 ] },
	ymm     => { type => 'ymmreg', size => 256,            names => [ map 'zmm' . $_, 0 .. 31 ] },
	zmm     => { type => 'zmmreg', size => 512,            names => [ map 'zmm' . $_, 0 .. 31 ] },
	sreg    => { type => 'sreg',   size => 16,             names => [qw/es cs ss ds fs gs/] },
	reg     => { type => 'reg',    size => $PLATFORM_SIZE, names => [] },
);

my %flags = (
	mxcsr  => { size => 32,             names => [qw/DUE MM FZ RC PM UM OM ZM DM IM DAZ PE UE OE ZE DE IE/] },
	x87cw  => { size => 16,             names => [qw/X RC PC PM UM OM ZM DM IM/] },
	x87sw  => { size => 16,             names => [qw/B C3 TOP C2 C1 C0 ES SF PE UE OE ZE DE IE/] },
	eflags => { size => $PLATFORM_SIZE, names => [qw/ID VIP VIF AC VM RF NT IOPL OF DF IF TF SF ZF AF PF CF/] },
);

my @shortcuts = ( 'amd' => 'vendor=$', );

my %template = (
	mnemonic     => '',
	aliasOf      => '',
	form         => '',
	branchType   => '',
	deprecated   => 0,
	abandoned    => 0,
	undocumented => 0,
	level        => 3,
	rep          => 0,
	repe         => 0,
	repne        => 0,
	bnd          => 0,
	stackPtr     => 0,
	fpuStackPtr  => 0,
	lock         => { legacy => 0, hardware => 0, implied => 0, explicit => 0, ignore => 0 },
	cpuid        => [],
	eflags       => {},
	x87Flags              => { cw => {}, sw => {} },
	mxcsr                 => {},
	suppressAllExceptions => 0,
	embeddedRounding      => 0,
);

my $version      = 2;
my @instructions = ();

# ===> Export <===

require 'x86.parser.pl';

our $environment = {
	name          => 'x86',
	version       => $version,
	architectures => \%architectures,
	registers     => \%registers,
	flags         => \%flags,
	template      => \%template,
	instructions  => \@instructions,
	private       => {
		shortcuts => \@shortcuts,
		parser    => \&parser,
	},
};


@instructions = (


  # ===>                               A to L instructions                               <===

  # => AAA-ASCII Adjust After Addition
  ['aaa'      , '<al>'               , 'x86: 37'                                , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=TM eflags.pf=U eflags.cf=M'],

  # => AAD-ASCII Adjust AX Before Division
  #['aad'      , '<ax>'                , 'x86:   d5 0a           '                , 'deprecated eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=U'],
  ['aad'      , 'pimm8, X:<ax>'       , 'x86:i: d5 ib           '                , 'deprecated eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=U'],

  # => AAM-ASCII Adjust AX After Multiply
  #['aam'      , '<ax>'                , 'x86:   d4 0a           '                , 'deprecated eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=U'],
  ['aam'      , 'pimm8, X:<ax>'       , 'x86:i: d4 ib           '                , 'deprecated eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=U'],

  # => AAS-ASCII Adjust AL After Subtraction
  ['aas'      , '<al>'               , 'x86: 3f'                                , 'deprecated eflags.of=U eflags.sf=U eflags.zf=U eflags.af=TM eflags.pf=U eflags.cf=M'],

  # => ADC-Add with Carry
  ['adc'      , 'al, imm8'           , 'i:           14 ib           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , '*ax, imm.low'       , 'i:      os   15 iz           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'vr/vm, vr'          , 'mr:     os   11 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'vr, vr/vm'          , 'rm:     os   13 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'vr/vm, imm8'        , 'mi:     os   83 /2 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'r8x, r8x/m8'        , 'rm:          12 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'r8x/m8, imm8'       , 'mi:          80 /2 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'vr/vm, imm.low'     , 'mi:     os   81 /2 iz        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['adc'      , 'r8x/m8, r8x'        , 'mr:          10 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],

  # => ADCX-Unsigned Integer Addition of Two Operands with Carry Flag
  ['adcx'     , 'vr, vr/vm'          , 'rm:     osv  66 0f 38 f6 /r  '          , 'cpuid=adx eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => ADD-Add
  ['add'      , 'al, imm8'           , 'i:           04 ib           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , '*ax, imm.low'       , 'i:      os   05 iz           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'vr/vm, imm8'        , 'mi:     os   83 /0 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'vr/vm, imm.low'     , 'mi:     os   81 /0 iz        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'vr, vr/vm'          , 'rm:     os   03 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'vr/vm, vr'          , 'mr:     os   01 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'r8x/m8, imm8'       , 'mi:          80 /0 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'r8x/m8, r8x'        , 'mr:          00 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['add'      , 'r8x, r8x/m8'        , 'rm:          02 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => ADDPD-Add Packed Double-Precision Floating-Point Values
  ['addpd'    , 'xmm, xmm/m128'                            , 'rm:     66 0f 58 /r                  '  , 'cpuid=sse2'],
  ['vaddpd'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f.wig 58 /r   '  , 'cpuid=avx'],
  ['vaddpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f.w1 58 /r   '  , 'cpuid=avx512f-vl'],

  # => ADDPS-Add Packed Single-Precision Floating-Point Values
  ['addps'    , 'xmm, xmm/m128'                            , 'rm:     0f 58 /r                  '     , 'cpuid=sse'],
  ['vaddps'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.0f.wig 58 /r   '     , 'cpuid=avx'],
  ['vaddps'   , 'W:vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.0f.w0 58 /r   '     , 'cpuid=avx512f-vl'],

  # => ADDSD-Add Scalar Double-Precision Floating-Point Values
  ['addsd'    , 'xmm, xmm/m64'                        , 'rm:      f2 0f 58 /r                  ' , 'cpuid=sse2'],
  ['vaddsd'   , 'W:xmm, xmm, xmm/m64'                 , 'rvm:     vex.nds.128.f2.0f.wig 58 /r  ' , 'cpuid=avx'],
  ['vaddsd'   , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 58 /r  ' , 'cpuid=avx512f'],

  # => ADDSS-Add Scalar Single-Precision Floating-Point Values
  ['addss'    , 'xmm, xmm/m32'                        , 'rm:      f3 0f 58 /r                  ' , 'cpuid=sse'],
  ['vaddss'   , 'W:xmm, xmm, xmm/m32'                 , 'rvm:     vex.nds.128.f3.0f.wig 58 /r  ' , 'cpuid=avx'],
  ['vaddss'   , 'W:xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 58 /r  ' , 'cpuid=avx512f'],

  # => ADDSUBPD-Packed Double-FP Add/Subtract
  ['addsubpd'  , 'xmm, xmm/m128'              , 'rm:  66 0f d0 /r                  '     , 'cpuid=sse3'],
  ['vaddsubpd' , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f.wig d0 /r   '     , 'cpuid=avx'],

  # => ADDSUBPS-Packed Single-FP Add/Subtract
  ['addsubps'  , 'xmm, xmm/m128'              , 'rm:  f2 0f d0 /r                  '     , 'cpuid=sse3'],
  ['vaddsubps' , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.f2.0f.wig d0 /r   '     , 'cpuid=avx'],

  # => ADOX-Unsigned Integer Addition of Two Operands with Overflow Flag
  ['adox'     , 'vr, vr/vm'          , 'rm:     osv  f3 0f 38 f6 /r  '          , 'cpuid=adx eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => AESDEC-Perform One Round of an AES Decryption Flow
  ['aesdec'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 de /r                 '   , 'cpuid=aes'],
  ['vaesdec'  , 'W:xmm, xmm, xmm/m128'       , 'rvm: vex.nds.128.66.0f38.wig de /r  '   , 'cpuid=aes|avx'],

  # => AESDECLAST-Perform Last Round of an AES Decryption Flow
  ['aesdeclast'  , 'xmm, xmm/m128'              , 'rm:  66 0f 38 df /r                 '   , 'cpuid=aes'],
  ['vaesdeclast' , 'W:xmm, xmm, xmm/m128'       , 'rvm: vex.nds.128.66.0f38.wig df /r  '   , 'cpuid=aes|avx'],

  # => AESENC-Perform One Round of an AES Encryption Flow
  ['aesenc'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 dc /r                 '   , 'cpuid=aes'],
  ['vaesenc'  , 'W:xmm, xmm, xmm/m128'       , 'rvm: vex.nds.128.66.0f38.wig dc /r  '   , 'cpuid=aes|avx'],

  # => AESENCLAST-Perform Last Round of an AES Encryption Flow
  ['aesenclast'  , 'xmm, xmm/m128'              , 'rm:  66 0f 38 dd /r                 '   , 'cpuid=aes'],
  ['vaesenclast' , 'W:xmm, xmm, xmm/m128'       , 'rvm: vex.nds.128.66.0f38.wig dd /r  '   , 'cpuid=aes|avx'],

  # => AESIMC-Perform the AES InvMixColumn Transformation
  ['aesimc'   , 'W:xmm, xmm/m128'       , 'rm: 66 0f 38 db /r             '        , 'cpuid=aes'],
  ['vaesimc'  , 'W:xmm, xmm/m128'       , 'rm: vex.128.66.0f38.wig db /r  '        , 'cpuid=aes|avx'],

  # => AESKEYGENASSIST-AES Round Key Generation Assist
  ['aeskeygenassist'  , 'W:xmm, xmm/m128, pimm8'       , 'rmi: 66 0f 3a df /r ib             '    , 'cpuid=aes'],
  ['vaeskeygenassist' , 'W:xmm, xmm/m128, pimm8'       , 'rmi: vex.128.66.0f3a.wig df /r ib  '    , 'cpuid=aes|avx'],

  # => AND-Logical AND
  ['and'      , '*ax, imm.low'       , 'i:      os   25 iz           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'al, imm8'           , 'i:           24 ib           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'vr/vm, imm.low'     , 'mi:     os   81 /4 iz        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'vr/vm, imm8'        , 'mi:     os   83 /4 ib        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'vr/vm, vr'          , 'mr:     os   21 /r           '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'r8x, r8x/m8'        , 'rm:          22 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'r8x/m8, imm8'       , 'mi:          80 /4 ib        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'vr, vr/vm'          , 'rm:     os   23 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['and'      , 'r8x/m8, r8x'        , 'mr:          20 /r           '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],

  # => ANDN-Logical AND NOT
  ['andn'     , 'W:r32, r32, r/m32'       , 'rvm:     vex.nds.lz.0f38.w0 f2 /r  '    , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=C'],
  ['andn'     , 'W:r64, r64, r/m64'       , 'x64:rvm: vex.nds.lz.0f38.w1 f2 /r  '    , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=C'],

  # => ANDPD-Bitwise Logical AND of Packed Double Precision Floating-Point Values
  ['andpd'    , 'xmm, xmm/m128'                       , 'rm:     66 0f 54 /r                  '  , 'cpuid=sse2'],
  ['vandpd'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f 54 /r       '  , 'cpuid=avx'],
  ['vandpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 54 /r   '  , 'cpuid=avx512dq-vl'],

  # => ANDPS-Bitwise Logical AND of Packed Single Precision Floating-Point Values
  ['andps'    , 'xmm, xmm/m128'                       , 'rm:     0f 54 /r                  '     , 'cpuid=sse'],
  ['vandps'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.0f 54 /r       '     , 'cpuid=avx'],
  ['vandps'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.0f.w0 54 /r   '     , 'cpuid=avx512dq-vl'],

  # => ANDNPD-Bitwise Logical AND NOT of Packed Double Precision Floating-Point Values
  ['andnpd'   , 'xmm, xmm/m128'                       , 'rm:     66 0f 55 /r                  '  , 'cpuid=sse2'],
  ['vandnpd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f 55 /r       '  , 'cpuid=avx'],
  ['vandnpd'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 55 /r   '  , 'cpuid=avx512dq-vl'],

  # => ANDNPS-Bitwise Logical AND NOT of Packed Single Precision Floating-Point Values
  ['andnps'   , 'xmm, xmm/m128'                       , 'rm:     0f 55 /r                  '     , 'cpuid=sse'],
  ['vandnps'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.0f 55 /r       '     , 'cpuid=avx'],
  ['vandnps'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.0f.w0 55 /r   '     , 'cpuid=avx512dq-vl'],

  # => ARPL-Adjust RPL Field of Segment Selector
  ['arpl'     , 'W:r/m16, r16'       , 'x86:mr: 63 /r'                          , 'deprecated eflags.zf=M'],

  # => BLENDPD-Blend Packed Double Precision Floating-Point Values
  ['blendpd'  , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 0d /r ib                 ' , 'cpuid=sse4v1'],
  ['vblendpd' , 'W:vmm, vmm, vmm/vm, pimm8'         , 'rvmi: vex.nds.vl.66.0f3a.wig 0d /r ib   ' , 'cpuid=avx'],

  # => BEXTR-Bit Field Extract
  ['bextr'    , 'W:r32, r/m32, r32'       , 'rmv:     vex.nds.lz.0f38.w0 f7 /r  '    , 'cpuid=bmi1 eflags.of=M eflags.sf=U eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M eflags.tf=M eflags.if=M eflags.df=M eflags.nt=M eflags.rf=M'],
  ['bextr'    , 'W:r64, r/m64, r64'       , 'x64:rmv: vex.nds.lz.0f38.w1 f7 /r  '    , 'cpuid=bmi1 eflags.of=M eflags.sf=U eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M eflags.tf=M eflags.if=M eflags.df=M eflags.nt=M eflags.rf=M'],

  # => BLENDPS-Blend Packed Single Precision Floating-Point Values
  ['blendps'  , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 0c /r ib                 ' , 'cpuid=sse4v1'],
  ['vblendps' , 'W:vmm, vmm, vmm/vm, pimm8'         , 'rvmi: vex.nds.vl.66.0f3a.wig 0c /r ib   ' , 'cpuid=avx'],

  # => BLENDVPD-Variable Blend Packed Double Precision Floating-Point Values
  ['blendvpd'  , 'xmm, xmm/m128, <xmm0>'           , 'rm:   66 0f 38 15 /r                    ' , 'cpuid=sse4v1'],
  ['vblendvpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 4b /r is4   ' , 'cpuid=avx'],

  # => BLENDVPS-Variable Blend Packed Single Precision Floating-Point Values
  ['blendvps'  , 'xmm, xmm/m128, <xmm0>'           , 'rm:   66 0f 38 14 /r                    ' , 'cpuid=sse4v1'],
  ['vblendvps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 4a /r is4   ' , 'cpuid=avx'],

  # => BLSI-Extract Lowest Set Isolated Bit
  ['blsi'     , 'W:r32, r/m32'       , 'vm:     vex.ndd.lz.0f38.w0 f3 /3  '     , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],
  ['blsi'     , 'W:r64, r/m64'       , 'x64:vm: vex.ndd.lz.0f38.w1 f3 /3  '     , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BLSMSK-Get Mask Up to Lowest Set Bit
  ['blsmsk'   , 'W:r32, r/m32'       , 'vm:     vex.ndd.lz.0f38.w0 f3 /2  '     , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=C eflags.af=U eflags.pf=U eflags.cf=M'],
  ['blsmsk'   , 'W:r64, r/m64'       , 'x64:vm: vex.ndd.lz.0f38.w1 f3 /2  '     , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=C eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BLSR-Reset Lowest Set Bit
  ['blsr'     , 'W:r32, r/m32'       , 'vm:     vex.ndd.lz.0f38.w0 f3 /1  '     , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],
  ['blsr'     , 'W:r64, r/m64'       , 'x64:vm: vex.ndd.lz.0f38.w1 f3 /1  '     , 'cpuid=bmi1 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BNDCL-Check Lower Bound
  ['bndcl'    , 'W:bnd, vr/vm'       , 'rm:     osv f3 0f 1a /r     '           , 'cpuid=mpx'],

  # => BNDCU/BNDCN-Check Upper Bound
  ['bndcn'    , 'W:bnd, vr/vm'       , 'rm:     osv f2 0f 1b /r     '           , 'cpuid=mpx'],
  ['bndcu'    , 'W:bnd, vr/vm'       , 'rm:     osv f2 0f 1a /r     '           , 'cpuid=mpx'],

  # => BNDLDX-Load Extended Bounds Using Address Translation
  ['bndldx'   , 'W:bnd, mib'         , 'rm: 0f 1a /r'                           , 'cpuid=mpx'],

  # => BNDMK-Make Bounds
  ['bndmk'    , 'W:bnd, vm'          , 'rm:     osv f3 0f 1b /r     '           , 'cpuid=mpx'],

  # => BNDMOV-Move Bounds
  ['bndmov'   , 'W:bnd/m64, bnd'        , 'x86:mr: 66 0f 1b /r     '               , 'cpuid=mpx'],
  ['bndmov'   , 'W:bnd/m128, bnd'       , 'x64:mr: 66 0f 1b /r     '               , 'cpuid=mpx'],
  ['bndmov'   , 'W:bnd, bnd/m64'        , 'x86:rm: 66 0f 1a /r     '               , 'cpuid=mpx'],
  ['bndmov'   , 'W:bnd, bnd/m128'       , 'x64:rm: 66 0f 1a /r     '               , 'cpuid=mpx'],

  # => BNDSTX-Store Extended Bounds Using Address Translation
  ['bndstx'   , 'R:mib, bnd'         , 'mr: 0f 1b /r'                           , 'cpuid=mpx'],

  # => BOUND-Check Array Index Against Bounds
  ['bound'    , 'R:r16, m16&16'       , 'x86:rm: os16 62 /r           '          , 'deprecated'],
  ['bound'    , 'R:r32, m32&32'       , 'x86:rm:      62 /r           '          , 'deprecated'],

  # => BSF-Bit Scan Forward
  ['bsf'      , 'W:vr, vr/vm'        , 'rm:     os   0f bc /r        '          , 'eflags.of=U eflags.sf=U eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=U'],

  # => BSR-Bit Scan Reverse
  ['bsr'      , 'W:vr, vr/vm'        , 'rm:     os   0f bd /r        '          , 'eflags.of=U eflags.sf=U eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=U'],

  # => BSWAP-Byte Swap
  ['bswap'    , 'vr'                 , 'o:     osv  0f c8+r         '           , ''],

  # => BT-Bit Test
  ['bt'       , 'R:vr/vm, pimm8'       , 'mi:     os   0f ba /4 ib     '          , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['bt'       , 'R:vr/vm, vr'          , 'mr:     os   0f a3 /r        '          , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BTC-Bit Test and Complement
  ['btc'      , 'vr/vm, pimm8'       , 'mi:     os   0f ba /7 ib     '          , 'lock=legacy|hardware|explicit eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['btc'      , 'vr/vm, vr'          , 'mr:     os   0f bb /r        '          , 'lock=legacy|hardware|explicit eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BTR-Bit Test and Reset
  ['btr'      , 'vr/vm, pimm8'       , 'mi:     os   0f ba /6 ib     '          , 'lock=legacy|hardware|explicit eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['btr'      , 'vr/vm, vr'          , 'mr:     os   0f b3 /r        '          , 'lock=legacy|hardware|explicit eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BTS-Bit Test and Set
  ['bts'      , 'vr/vm, vr'          , 'mr:     os   0f ab /r        '          , 'lock=legacy|hardware|explicit eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['bts'      , 'vr/vm, pimm8'       , 'mi:     os   0f ba /5 ib     '          , 'lock=legacy|hardware|explicit eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],

  # => BZHI-Zero High Bits Starting with Specified Bit Position
  ['bzhi'     , 'W:r32, r/m32, r32'       , 'rmv:     vex.nds.lz.0f38.w0 f5 /r  '    , 'cpuid=bmi2 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],
  ['bzhi'     , 'W:r64, r/m64, r64'       , 'x64:rmv: vex.nds.lz.0f38.w1 f5 /r  '    , 'cpuid=bmi2 eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],

  # => CALL-Call Procedure
  ['call'     , 'rel'                , 'm:     osz  e8 oz           '           , 'branchType=near bnd'],
  ['call'     , 'm16:mv'             , 'm:     os   ff /3           '           , 'branchType=far'],
  ['call'     , 'R:vr/vm'            , 'm:     os   ff /2           '           , 'branchType=near bnd'],
  ['call'     , 'ptr16:ptr'          , 'x86:d: osz  9a od           '           , 'deprecated branchType=far'],

  # => CBW/CWDE/CDQE-Convert Byte to Word/Convert Word to Doubleword/Convert Doubleword to Quadword
  ['cwde'     , 'R:<eax>'            , '     os32 98              '             , ''],
  ['cbw'      , 'R:<ax>'             , '     os16 98              '             , ''],
  ['cdqe'     , 'R:<rax>'            , 'x64: os64 98              '             , ''],

  # => CLAC-Clear AC Flag in EFLAGS Register
  ['clac'     , ''                   , '0f 01 ca'                               , 'cpuid=smap'],

  # => CLC-Clear Carry Flag
  ['clc'      , ''                   , 'f8'                                     , 'eflags.cf=C'],

  # => CLD-Clear Direction Flag
  ['cld'      , ''                   , 'fc'                                     , 'eflags.df=C'],

  # => CLFLUSH-Flush Cache Line
  ['clflush'  , 'W:m8'               , 'm: 0f ae /7'                            , 'cpuid=clfsh'],

  # => CLFLUSHOPT-Flush Cache Line Optimized
  ['clflushopt' , 'W:m8'               , 'm: 66 0f ae /7'                         , 'cpuid=clflushopt'],

  # => CLI-Clear Interrupt Flag
  ['cli'      , ''                   , 'fa'                                     , 'eflags.if=C'],

  # => CLTS-Clear Task-Switched Flag in CR0
  ['clts'     , 'W:<cr0>'            , '0f 06'                                  , 'level=0'],

  # => CLWB-Cache Line Write Back
  ['clwb'     , 'W:m8'               , 'm: 66 0f ae /6'                         , 'cpuid=clwb'],

  # => CMC-Complement Carry Flag
  ['cmc'      , ''                   , 'f5'                                     , 'eflags.cf=M'],

  # => CMOVcc-Conditional Move
  ['cmove'    , 'vr, vr/vm'          , 'rm:     os   0f 44 /r        '          , 'cpuid=cmov eflags.zf=T'],
  ['cmovno'   , 'vr, vr/vm'          , 'rm:     os   0f 41 /r        '          , 'cpuid=cmov eflags.of=T'],
  ['cmovnge'  , 'vr, vr/vm'          , 'rm:     os   0f 4c /r        '          , 'aliasOf=cmovl cpuid=cmov eflags.sf=T eflags.of=T'],
  ['cmovb'    , 'vr, vr/vm'          , 'rm:     os   0f 42 /r        '          , 'cpuid=cmov eflags.cf=T'],
  ['cmovne'   , 'vr, vr/vm'          , 'rm:     os   0f 45 /r        '          , 'cpuid=cmov eflags.zf=T'],
  ['cmovbe'   , 'vr, vr/vm'          , 'rm:     os   0f 46 /r        '          , 'cpuid=cmov eflags.cf=T eflags.zf=T'],
  ['cmovz'    , 'vr, vr/vm'          , 'rm:     os   0f 44 /r        '          , 'aliasOf=cmove cpuid=cmov eflags.zf=T'],
  ['cmovs'    , 'vr, vr/vm'          , 'rm:     os   0f 48 /r        '          , 'cpuid=cmov eflags.sf=T'],
  ['cmovnb'   , 'vr, vr/vm'          , 'rm:     os   0f 43 /r        '          , 'aliasOf=cmovae cpuid=cmov eflags.cf=T'],
  ['cmovnp'   , 'vr, vr/vm'          , 'rm:     os   0f 4b /r        '          , 'cpuid=cmov eflags.pf=T'],
  ['cmovae'   , 'vr, vr/vm'          , 'rm:     os   0f 43 /r        '          , 'cpuid=cmov eflags.cf=T'],
  ['cmovnle'  , 'vr, vr/vm'          , 'rm:     os   0f 4f /r        '          , 'aliasOf=cmovg cpuid=cmov eflags.zf=T eflags.sf=T eflags.of=T'],
  ['cmovc'    , 'vr, vr/vm'          , 'rm:     os   0f 42 /r        '          , 'aliasOf=cmovb cpuid=cmov eflags.cf=T'],
  ['cmovnl'   , 'vr, vr/vm'          , 'rm:     os   0f 4d /r        '          , 'aliasOf=cmovge cpuid=cmov eflags.sf=T eflags.of=T'],
  ['cmovnae'  , 'vr, vr/vm'          , 'rm:     os   0f 42 /r        '          , 'aliasOf=cmovb cpuid=cmov eflags.cf=T'],
  ['cmovnbe'  , 'vr, vr/vm'          , 'rm:     os   0f 47 /r        '          , 'aliasOf=cmova cpuid=cmov eflags.cf=T eflags.zf=T'],
  ['cmovle'   , 'vr, vr/vm'          , 'rm:     os   0f 4e /r        '          , 'cpuid=cmov eflags.zf=T eflags.sf=T eflags.of=T'],
  ['cmovl'    , 'vr, vr/vm'          , 'rm:     os   0f 4c /r        '          , 'cpuid=cmov eflags.sf=T eflags.of=T'],
  ['cmovna'   , 'vr, vr/vm'          , 'rm:     os   0f 46 /r        '          , 'aliasOf=cmovbe cpuid=cmov eflags.cf=T eflags.zf=T'],
  ['cmovng'   , 'vr, vr/vm'          , 'rm:     os   0f 4e /r        '          , 'aliasOf=cmovle cpuid=cmov eflags.zf=T eflags.sf=T eflags.of=T'],
  ['cmovo'    , 'vr, vr/vm'          , 'rm:     os   0f 40 /r        '          , 'cpuid=cmov eflags.of=T'],
  ['cmova'    , 'vr, vr/vm'          , 'rm:     os   0f 47 /r        '          , 'cpuid=cmov eflags.cf=T eflags.zf=T'],
  ['cmovg'    , 'vr, vr/vm'          , 'rm:     os   0f 4f /r        '          , 'cpuid=cmov eflags.zf=T eflags.sf=T eflags.of=T'],
  ['cmovnz'   , 'vr, vr/vm'          , 'rm:     os   0f 45 /r        '          , 'aliasOf=cmovne cpuid=cmov eflags.zf=T'],
  ['cmovpo'   , 'vr, vr/vm'          , 'rm:     os   0f 4b /r        '          , 'aliasOf=cmovnp cpuid=cmov eflags.pf=T'],
  ['cmovnc'   , 'vr, vr/vm'          , 'rm:     os   0f 43 /r        '          , 'aliasOf=cmovae cpuid=cmov eflags.cf=T'],
  ['cmovge'   , 'vr, vr/vm'          , 'rm:     os   0f 4d /r        '          , 'cpuid=cmov eflags.sf=T eflags.of=T'],
  ['cmovpe'   , 'vr, vr/vm'          , 'rm:     os   0f 4a /r        '          , 'aliasOf=cmovp cpuid=cmov eflags.pf=T'],
  ['cmovns'   , 'vr, vr/vm'          , 'rm:     os   0f 49 /r        '          , 'cpuid=cmov eflags.sf=T'],
  ['cmovp'    , 'vr, vr/vm'          , 'rm:     os   0f 4a /r        '          , 'cpuid=cmov eflags.pf=T'],

  # => CMP-Compare Two Operands
  ['cmp'      , 'R:al, imm8'           , 'i:           3c ib           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:*ax, imm.low'       , 'i:      os   3d iz           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:vr/vm, vr'          , 'mr:     os   39 /r           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:vr/vm, imm8'        , 'mi:     os   83 /7 ib        '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:r8x/m8, imm8'       , 'mi:          80 /7 ib        '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:vr, vr/vm'          , 'rm:     os   3b /r           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:r8x, r8x/m8'        , 'rm:          3a /r           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:r8x/m8, r8x'        , 'mr:          38 /r           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmp'      , 'R:vr/vm, imm.low'     , 'mi:     os   81 /7 iz        '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => CMPPD-Compare Packed Double-Precision Floating-Point Values
  ['cmppd'    , 'xmm, xmm/m128, pimm8'                          , 'rmi:     66 0f c2 /r ib                  ' , 'cpuid=sse2'],
  ['vcmppd'   , 'W:vmm, vmm, vmm/vm, pimm8'                     , 'rvmi:    vex.nds.vl.66.0f.wig c2 /r ib   ' , 'cpuid=avx'],
  ['vcmppd'   , 'W:k {k}, vmm, vmm/vm/b64 {sae}, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f.w1 c2 /r ib   ' , 'cpuid=avx512f-vl'],

  # => CMPPS-Compare Packed Single-Precision Floating-Point Values
  ['cmpps'    , 'xmm, xmm/m128, pimm8'                          , 'rmi:     0f c2 /r ib                  ' , 'cpuid=sse'],
  ['vcmpps'   , 'W:vmm, vmm, vmm/vm, pimm8'                     , 'rvmi:    vex.nds.vl.0f.wig c2 /r ib   ' , 'cpuid=avx'],
  ['vcmpps'   , 'W:k {k}, vmm, vmm/vm/b32 {sae}, pimm8'         , 'rvmi:fv: evex.nds.vl.0f.w0 c2 /r ib   ' , 'cpuid=avx512f-vl'],

  # => CMPS/CMPSB/CMPSW/CMPSD/CMPSQ-Compare String Operands
  ['cmpsd'    , 'R:<[ds:*si]>, <[*di]>'       , '     os32 a7              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  #['cmps'     , 'm8, m8'                      , '          a6              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  ['cmpsb'    , 'R:<[ds:*si]>, <[*di]>'       , '          a6              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmpsw'    , 'R:<[ds:*si]>, <[*di]>'       , '     os16 a7              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  #['cmps'     , 'vm, vm'                      , '     os   a7              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  ['cmpsq'    , 'R:<[*si]>, <[*di]>'          , 'x64: os64 a7              '             , 'repe eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => CMPSD-Compare Scalar Double-Precision Floating-Point Value
  ['cmpsd'    , 'xmm, xmm/m64, pimm8'                      , 'rmi:      f2 0f c2 /r ib                  ' , 'cpuid=sse2'],
  ['vcmpsd'   , 'W:xmm, xmm, xmm/m64, pimm8'               , 'rvmi:     vex.nds.128.f2.0f.wig c2 /r ib  ' , 'cpuid=avx'],
  ['vcmpsd'   , 'W:k {k}, xmm, xmm/m64 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.f2.0f.w1 c2 /r ib  ' , 'cpuid=avx512f'],

  # => CMPSS-Compare Scalar Single-Precision Floating-Point Value
  ['cmpss'    , 'xmm, xmm/m32, pimm8'                      , 'rmi:      f3 0f c2 /r ib                  ' , 'cpuid=sse'],
  ['vcmpss'   , 'W:xmm, xmm, xmm/m32, pimm8'               , 'rvmi:     vex.nds.128.f3.0f.wig c2 /r ib  ' , 'cpuid=avx'],
  ['vcmpss'   , 'W:k {k}, xmm, xmm/m32 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.f3.0f.w0 c2 /r ib  ' , 'cpuid=avx512f'],

  # => CMPXCHG-Compare and Exchange
  ['cmpxchg'  , 'vr/vm, vr, <*ax>'        , 'mr:     os   0f b1 /r        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['cmpxchg'  , 'r8x/m8, r8x, <al>'       , 'mr:          0f b0 /r        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => CMPXCHG8B/CMPXCHG16B-Compare and Exchange Bytes
  ['cmpxchg8b'  , 'm64, X:<edx>, X:<eax>, W:<ecx>, W:<ebx>'        , 'm:     os32 0f c7 /1        '           , 'lock=legacy|hardware|explicit cpuid=cmpxchg16b eflags.zf=M'],
  ['cmpxchg16b' , 'm128, X:<rdx>, X:<rax>, W:<rcx>, W:<rbx>'       , 'x64:m: os64 0f c7 /1        '           , 'lock=legacy|hardware|explicit cpuid=cmpxchg16b eflags.zf=M'],

  # => COMISD-Compare Scalar Ordered Double-Precision Floating-Point Values and Set EFLAGS
  ['comisd'   , 'W:xmm, xmm/m64'             , 'rm:     66 0f 2f /r              '      , 'cpuid=sse2'],
  ['vcomisd'  , 'W:xmm, xmm/m64'             , 'rm:     vex.128.66.0f.wig 2f /r  '      , 'cpuid=avx'],
  ['vcomisd'  , 'W:xmm, xmm/m64 {sae}'       , 'rm:t1s: evex.lig.66.0f.w1 2f /r  '      , 'cpuid=avx512f'],

  # => COMISS-Compare Scalar Ordered Single-Precision Floating-Point Values and Set EFLAGS
  ['comiss'   , 'W:xmm, xmm/m32'             , 'rm:     0f 2f /r              '         , 'cpuid=sse eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=M eflags.cf=M'],
  ['vcomiss'  , 'W:xmm, xmm/m32'             , 'rm:     vex.128.0f.wig 2f /r  '         , 'cpuid=avx'],
  ['vcomiss'  , 'W:xmm, xmm/m32 {sae}'       , 'rm:t1s: evex.lig.0f.w0 2f /r  '         , 'cpuid=avx512f'],

  # => CPUID-CPU Identification
  ['cpuid'    , '<eax>, W:<ebx>, X:<ecx>, W:<edx>'       , '0f a2'                                  , ''],

  # => CRC32-Accumulate CRC32 Value
  ['crc32'    , 'r32, r/m16'         , 'rm:     os16 f2 0f 38 f1 /r      '      , 'cpuid=sse4v2'],
  ['crc32'    , 'r32, r/m32'         , 'rm:     os32 f2 0f 38 f1 /r      '      , 'cpuid=sse4v2'],
  ['crc32'    , 'r32, r8x/m8'        , 'rm:          f2 0f 38 f0 /r      '      , 'cpuid=sse4v2'],
  ['crc32'    , 'r64, r/m64'         , 'x64:rm: os64 f2 0f 38 f1 /r      '      , 'cpuid=sse4v2'],
  ['crc32'    , 'r64, r/m8'          , 'x64:rm: os64 f2 0f 38 f0 /r      '      , 'cpuid=sse4v2'],

  # => CVTDQ2PD-Convert Packed Doubleword Integers to Packed Double-Precision Floating-Point Values
  ['cvtdq2pd'  , 'W:xmm, xmm/m64'                 , 'rm:    f3 0f e6 /r              '       , 'cpuid=sse2'],
  ['vcvtdq2pd' , 'W:vmm, xmm/vm.2'                , 'rm:    vex.vl.f3.0f.wig e6 /r   '       , 'cpuid=avx'],
  ['vcvtdq2pd' , 'W:vmm {kz}, vmm.low/vm.low/b32' , 'rm:hv: evex.vl.f3.0f.w0 e6 /r   '       , 'cpuid=avx512f-vl'],

  # => CVTDQ2PS-Convert Packed Doubleword Integers to Packed Single-Precision Floating-Point Values
  ['cvtdq2ps'  , 'W:xmm, xmm/m128'                     , 'rm:    0f 5b /r              '          , 'cpuid=sse2'],
  ['vcvtdq2ps' , 'W:vmm, vmm/vm'                       , 'rm:    vex.vl.0f.wig 5b /r   '          , 'cpuid=avx'],
  ['vcvtdq2ps' , 'W:vmm {kz}, vmm/vm/b32 {er}'         , 'rm:fv: evex.vl.0f.w0 5b /r   '          , 'cpuid=avx512f-vl'],

  # => CVTPD2DQ-Convert Packed Double-Precision Floating-Point Values to Packed Doubleword Integers
  ['cvtpd2dq'  , 'W:xmm, xmm/m128'                     , 'rm:    f2 0f e6 /r              '       , 'cpuid=sse2'],
  ['vcvtpd2dq' , 'W:xmm, vmm/vm'                       , 'rm:    vex.vl.f2.0f.wig e6 /r   '       , 'cpuid=avx'],
  ['vcvtpd2dq' , 'W:vmm.low {kz}, vmm/vm/b64 {er}'     , 'rm:fv: evex.vl.f2.0f.w1 e6 /r   '       , 'cpuid=avx512f-vl'],

  # => CVTPD2PI-Convert Packed Double-Precision FP Values to Packed Dword Integers
  ['cvtpd2pi' , 'W:mm, xmm/m128'       , 'rm: 66 0f 2d /r'                        , ''],

  # => CVTPD2PS-Convert Packed Double-Precision Floating-Point Values to Packed Single-Precision Floating-Point Values
  ['cvtpd2ps'  , 'W:xmm, xmm/m128'                     , 'rm:    66 0f 5a /r              '       , 'cpuid=sse2'],
  ['vcvtpd2ps' , 'W:xmm, vmm/vm'                       , 'rm:    vex.vl.66.0f.wig 5a /r   '       , 'cpuid=avx'],
  ['vcvtpd2ps' , 'W:vmm.low {kz}, vmm/vm/b64 {er}'     , 'rm:fv: evex.vl.66.0f.w1 5a /r   '       , 'cpuid=avx512f-vl'],

  # => CVTPI2PD-Convert Packed Dword Integers to Packed Double-Precision FP Values
  ['cvtpi2pd' , 'W:xmm, mm/m64'       , 'rm: 66 0f 2a /r'                        , ''],

  # => CVTPI2PS-Convert Packed Dword Integers to Packed Single-Precision FP Values
  ['cvtpi2ps' , 'W:xmm, mm/m64'       , 'rm: 0f 2a /r'                           , ''],

  # => CVTPS2DQ-Convert Packed Single-Precision Floating-Point Values to Packed Signed Doubleword Integer Values
  ['cvtps2dq'  , 'W:xmm, xmm/m128'                     , 'rm:    66 0f 5b /r              '       , 'cpuid=sse2'],
  ['vcvtps2dq' , 'W:vmm, vmm/vm'                       , 'rm:    vex.vl.66.0f.wig 5b /r   '       , 'cpuid=avx'],
  ['vcvtps2dq' , 'W:vmm {kz}, vmm/vm/b32 {er}'         , 'rm:fv: evex.vl.66.0f.w0 5b /r   '       , 'cpuid=avx512f-vl'],

  # => CVTPS2PD-Convert Packed Single-Precision Floating-Point Values to Packed Double-Precision Floating-Point Values
  ['cvtps2pd'  , 'W:xmm, xmm/m64'                       , 'rm:    0f 5a /r              '          , 'cpuid=sse2'],
  ['vcvtps2pd' , 'W:vmm, xmm/vm.2'                      , 'rm:    vex.vl.0f.wig 5a /r   '          , 'cpuid=avx'],
  ['vcvtps2pd' , 'W:vmm {kz}, vmm.low/vm.2/b32 {sae}'   , 'rm:hv: evex.vl.0f.w0 5a /r   '          , 'cpuid=avx512f-vl'],

  # => CVTPS2PI-Convert Packed Single-Precision FP Values to Packed Dword Integers
  ['cvtps2pi' , 'W:mm, xmm/m64'       , 'rm: 0f 2d /r'                           , ''],

  # => CVTSD2SI-Convert Scalar Double-Precision Floating-Point Value to Doubleword Integer
  ['cvtsd2si'  , 'W:vr, xmm/m64'             , 'rm:         osv f2 0f 2d /r              ' , 'cpuid=sse2'],
  ['vcvtsd2si' , 'W:r32, xmm/m64'            , 'rm:         vex.128.f2.0f.w0 2d /r   '  , 'cpuid=avx'],
  ['vcvtsd2si' , 'W:r64, xmm/m64'            , 'x64:rm:     vex.128.f2.0f.w1 2d /r   '  , 'cpuid=avx'],
  ['vcvtsd2si' , 'W:r32, xmm/m64 {er}'       , 'rm:t1f:     evex.lig.f2.0f.w0 2d /r  '  , 'cpuid=avx512f'],
  ['vcvtsd2si' , 'W:r64, xmm/m64 {er}'       , 'x64:rm:t1f: evex.lig.f2.0f.w1 2d /r  '  , 'cpuid=avx512f'],

  # => CVTSD2SS-Convert Scalar Double-Precision Floating-Point Value to Scalar Single-Precision Floating-Point Value
  ['cvtsd2ss'  , 'W:xmm, xmm/m64'                      , 'rm:      f2 0f 5a /r                  ' , 'cpuid=sse2'],
  ['vcvtsd2ss' , 'W:xmm, xmm, xmm/m64'                 , 'rvm:     vex.nds.128.f2.0f.wig 5a /r  ' , 'cpuid=avx'],
  ['vcvtsd2ss' , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 5a /r  ' , 'cpuid=avx512f'],

  # => CVTSI2SD-Convert Doubleword Integer to Scalar Double-Precision Floating-Point Value
  ['cvtsi2sd'  , 'W:xmm, vr/vm'                 , 'rm:          osv f2 0f 2a /r                  ' , 'cpuid=sse2'],
  ['vcvtsi2sd' , 'W:xmm, xmm, r/m32'            , 'rvm:         vex.nds.128.f2.0f.w0 2a /r   ' , 'cpuid=avx'],
  ['vcvtsi2sd' , 'W:xmm, xmm, r/m64'            , 'x64:rvm:     vex.nds.128.f2.0f.w1 2a /r   ' , 'cpuid=avx'],
  ['vcvtsi2sd' , 'W:xmm, xmm, r/m32'            , 'rvm:t1s:     evex.nds.lig.f2.0f.w0 2a /r  ' , 'cpuid=avx512f'],
  ['vcvtsi2sd' , 'W:xmm, xmm, r/m64 {er}'       , 'x64:rvm:t1s: evex.nds.lig.f2.0f.w1 2a /r  ' , 'cpuid=avx512f'],

  # => CVTSI2SS-Convert Doubleword Integer to Scalar Single-Precision Floating-Point Value
  ['cvtsi2ss'  , 'W:xmm, vr/vm'                 , 'rm:          osv f3 0f 2a /r                  ' , 'cpuid=sse'],
  ['vcvtsi2ss' , 'W:xmm, xmm, r/m32'            , 'rvm:         vex.nds.128.f3.0f.w0 2a /r   ' , 'cpuid=avx'],
  ['vcvtsi2ss' , 'W:xmm, xmm, r/m64'            , 'x64:rvm:     vex.nds.128.f3.0f.w1 2a /r   ' , 'cpuid=avx'],
  ['vcvtsi2ss' , 'W:xmm, xmm, r/m32 {er}'       , 'rvm:t1s:     evex.nds.lig.f3.0f.w0 2a /r  ' , 'cpuid=avx512f'],
  ['vcvtsi2ss' , 'W:xmm, xmm, r/m64 {er}'       , 'x64:rvm:t1s: evex.nds.lig.f3.0f.w1 2a /r  ' , 'cpuid=avx512f'],

  # => CVTSS2SD-Convert Scalar Single-Precision Floating-Point Value to Scalar Double-Precision Floating-Point Value
  ['cvtss2sd'  , 'W:xmm, xmm/m32'                       , 'rm:      f3 0f 5a /r                  ' , 'cpuid=sse2'],
  ['vcvtss2sd' , 'W:xmm, xmm, xmm/m32'                  , 'rvm:     vex.nds.128.f3.0f.wig 5a /r  ' , 'cpuid=avx'],
  ['vcvtss2sd' , 'W:xmm {kz}, xmm, xmm/m32 {sae}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 5a /r  ' , 'cpuid=avx512f'],

  # => CVTSS2SI-Convert Scalar Single-Precision Floating-Point Value to Doubleword Integer
  ['cvtss2si'  , 'W:vr, xmm/m32'             , 'rm:         osv f3 0f 2d /r              ' , 'cpuid=sse'],
  ['vcvtss2si' , 'W:r32, xmm/m32'            , 'rm:         vex.128.f3.0f.w0 2d /r   '  , 'cpuid=avx'],
  ['vcvtss2si' , 'W:r64, xmm/m32'            , 'x64:rm:     vex.128.f3.0f.w1 2d /r   '  , 'cpuid=avx'],
  ['vcvtss2si' , 'W:r32, xmm/m32 {er}'       , 'rm:t1f:     evex.lig.f3.0f.w0 2d /r  '  , 'cpuid=avx512f'],
  ['vcvtss2si' , 'W:r64, xmm/m32 {er}'       , 'x64:rm:t1f: evex.lig.f3.0f.w1 2d /r  '  , 'cpuid=avx512f'],

  # => CVTTPD2DQ-Convert with Truncation Packed Double-Precision Floating-Point Values to Packed Doubleword Integers
  ['cvttpd2dq'  , 'W:xmm, xmm/m128'                      , 'rm:    66 0f e6 /r              '       , 'cpuid=sse2'],
  ['vcvttpd2dq' , 'W:xmm, vmm/vm'                        , 'rm:    vex.vl.66.0f.wig e6 /r   '       , 'cpuid=avx'],
  ['vcvttpd2dq' , 'W:vmm.low {kz}, vmm/vm/b64 {sae}'     , 'rm:fv: evex.vl.66.0f.w1 e6 /r   '       , 'cpuid=avx512f-vl'],

  # => CVTTPD2PI-Convert with Truncation Packed Double-Precision FP Values to Packed Dword Integers
  ['cvttpd2pi' , 'W:mm, xmm/m128'       , 'rm: 66 0f 2c /r'                        , ''],

  # => CVTTPS2DQ-Convert with Truncation Packed Single-Precision Floating-Point Values to Packed Signed Doubleword Integer Values
  ['cvttps2dq'  , 'W:xmm, xmm/m128'                      , 'rm:    f3 0f 5b /r              '       , 'cpuid=sse2'],
  ['vcvttps2dq' , 'W:vmm, vmm/vm'                        , 'rm:    vex.vl.f3.0f.wig 5b /r   '       , 'cpuid=avx'],
  ['vcvttps2dq' , 'W:vmm {kz}, vmm/vm/b32 {sae}'         , 'rm:fv: evex.vl.f3.0f.w0 5b /r   '       , 'cpuid=avx512f-vl'],

  # => CVTTPS2PI-Convert with Truncation Packed Single-Precision FP Values to Packed Dword Integers
  ['cvttps2pi' , 'W:mm, xmm/m64'       , 'rm: 0f 2c /r'                           , ''],

  # => CVTTSD2SI-Convert with Truncation Scalar Double-Precision Floating-Point Value to Signed Integer
  ['cvttsd2si'  , 'W:vr, xmm/m64'              , 'rm:         osv f2 0f 2c /r              ' , 'cpuid=sse2'],
  ['vcvttsd2si' , 'W:r32, xmm/m64'             , 'rm:         vex.128.f2.0f.w0 2c /r   '  , 'cpuid=avx'],
  ['vcvttsd2si' , 'W:r64, xmm/m64'             , 'x64:rm:     vex.128.f2.0f.w1 2c /r   '  , 'cpuid=avx'],
  ['vcvttsd2si' , 'W:r32, xmm/m64 {sae}'       , 'rm:t1f:     evex.lig.f2.0f.w0 2c /r  '  , 'cpuid=avx512f'],
  ['vcvttsd2si' , 'W:r64, xmm/m64 {sae}'       , 'x64:rm:t1f: evex.lig.f2.0f.w1 2c /r  '  , 'cpuid=avx512f'],

  # => CVTTSS2SI-Convert with Truncation Scalar Single-Precision Floating-Point Value to Integer
  ['cvttss2si'  , 'W:vr, xmm/m32'              , 'rm:         osv f3 0f 2c /r              ' , 'cpuid=sse'],
  ['vcvttss2si' , 'W:r32, xmm/m32'             , 'rm:         vex.128.f3.0f.w0 2c /r   '  , 'cpuid=avx'],
  ['vcvttss2si' , 'W:r64, xmm/m32'             , 'x64:rm:     vex.128.f3.0f.w1 2c /r   '  , 'cpuid=avx'],
  ['vcvttss2si' , 'W:r32, xmm/m32 {sae}'       , 'rm:t1f:     evex.lig.f3.0f.w0 2c /r  '  , 'cpuid=avx512f'],
  ['vcvttss2si' , 'W:r64, xmm/m32 {sae}'       , 'x64:rm:t1f: evex.lig.f3.0f.w1 2c /r  '  , 'cpuid=avx512f'],

  # => CWD/CDQ/CQO-Convert Word to Doubleword/Convert Doubleword to Quadword
  ['cdq'      , 'W:<edx>, X:<eax>'       , '     os32 99              '             , ''],
  ['cwd'      , 'W:<dx>, X:<ax>'         , '     os16 99              '             , ''],
  ['cqo'      , 'W:<rdx>, X:<rax>'       , 'x64: os64 99              '             , ''],

  # => DAA-Decimal Adjust AL after Addition
  ['daa'      , '<al>'               , 'x86: 27'                                , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=TM eflags.pf=M eflags.cf=TM'],

  # => DAS-Decimal Adjust AL after Subtraction
  ['das'      , '<al>'               , 'x86: 2f'                                , 'deprecated eflags.of=U eflags.sf=M eflags.zf=M eflags.af=TM eflags.pf=M eflags.cf=TM'],

  # => DEC-Decrement by 1
  ['dec'      , 'r8x/m8'             , 'm:          fe /1           '           , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M'],
  ['dec'      , 'vr/vm'              , 'm:     os   ff /1           '           , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M'],
  ['dec'      , 'vr'                 , 'x86:o: osz  48+r            '           , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M'],

  # => DIV-Unsigned Divide
  ['div'      , 'W:r8x/m8, X:<ax>'                , 'm:          f6 /6           '           , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],
  ['div'      , 'W:vr/vm, X:<*dx>, X:<*ax>'       , 'm:     os   f7 /6           '           , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],

  # => DIVPD-Divide Packed Double-Precision Floating-Point Values
  ['divpd'    , 'xmm, xmm/m128'                            , 'rm:     66 0f 5e /r                  '  , 'cpuid=sse2'],
  ['vdivpd'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f.wig 5e /r   '  , 'cpuid=avx'],
  ['vdivpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f.w1 5e /r   '  , 'cpuid=avx512f-vl'],

  # => DIVPS-Divide Packed Single-Precision Floating-Point Values
  ['divps'    , 'xmm, xmm/m128'                            , 'rm:     0f 5e /r                  '     , 'cpuid=sse'],
  ['vdivps'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.0f.wig 5e /r   '     , 'cpuid=avx'],
  ['vdivps'   , 'W:vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.0f.w0 5e /r   '     , 'cpuid=avx512f-vl'],

  # => DIVSD-Divide Scalar Double-Precision Floating-Point Value
  ['divsd'    , 'xmm, xmm/m64'                        , 'rm:      f2 0f 5e /r                  ' , 'cpuid=sse2'],
  ['vdivsd'   , 'W:xmm, xmm, xmm/m64'                 , 'rvm:     vex.nds.128.f2.0f.wig 5e /r  ' , 'cpuid=avx'],
  ['vdivsd'   , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 5e /r  ' , 'cpuid=avx512f'],

  # => DIVSS-Divide Scalar Single-Precision Floating-Point Values
  ['divss'    , 'xmm, xmm/m32'                        , 'rm:      f3 0f 5e /r                  ' , 'cpuid=sse'],
  ['vdivss'   , 'W:xmm, xmm, xmm/m32'                 , 'rvm:     vex.nds.128.f3.0f.wig 5e /r  ' , 'cpuid=avx'],
  ['vdivss'   , 'W:xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 5e /r  ' , 'cpuid=avx512f'],

  # => DPPD-Dot Product of Packed Double Precision Floating-Point Values
  ['dppd'     , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 41 /r ib                 ' , 'cpuid=sse4v1'],
  ['vdppd'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: vex.nds.128.66.0f3a.wig 41 /r ib  ' , 'cpuid=avx'],

  # => DPPS-Dot Product of Packed Single Precision Floating-Point Values
  ['dpps'     , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 40 /r ib                 ' , 'cpuid=sse4v1'],
  ['vdpps'    , 'W:vmm, vmm, vmm/vm, pimm8'         , 'rvmi: vex.nds.vl.66.0f3a.wig 40 /r ib   ' , 'cpuid=avx'],

  # => EMMS-Empty MMX Technology State
  ['emms'     , ''                   , '0f 77'                                  , ''],

  # => ENTER-Make Stack Frame for Procedure Parameters
  ['enter'    , 'pimm16, pimm8'       , 'ii: c8 iw ib        '                   , ''],
  #['enter'    , 'pimm16, 1'           , 'ii: c8 iw 01        '                   , ''],
  #['enter'    , 'pimm16, 0'           , 'ii: c8 iw 00        '                   , ''],

  # => EXTRACTPS-Extract Packed Floating-Point Values
  ['extractps'  , 'W:r/m32, xmm, pimm8'       , 'mri:     66 0f 3a 17 /r ib              ' , 'cpuid=sse4v1'],
  ['vextractps' , 'W:r/m32, xmm, pimm8'       , 'mri:     vex.128.66.0f3a.wig 17 /r ib   ' , 'cpuid=avx'],
  ['vextractps' , 'W:r/m32, xmm, pimm8'       , 'mri:t1s: evex.128.66.0f3a.wig 17 /r ib  ' , 'cpuid=avx512f'],

  # => F2XM1-Compute 2x-1
  ['f2xm1'    , ''                   , 'd9 f0'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FABS-Absolute Value
  ['fabs'     , ''                   , 'd9 e1'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=C x87Flags.sw.c0=U'],

  # => FADD/FADDP/FIADD-Add
  ['faddp'    , ''                   , '   de c1           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fadd'     , 'st(0), st(i)'       , 'o: d8 c0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fadd'     , 'st(i), st(0)'       , 'o: dc c0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fiadd'    , 'm32int'             , 'm: da /0           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fiadd'    , 'm16int'             , 'm: de /0           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fadd'     , 'm64fp'              , 'm: dc /0           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['faddp'    , 'st(i), st(0)'       , 'o: de c0+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fadd'     , 'm32fp'              , 'm: d8 /0           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FBLD-Load Binary Coded Decimal
  ['fbld'     , 'm80dec'             , 'm: df /4'                               , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FBSTP-Store BCD Integer and Pop
  ['fbstp'    , 'm80bcd'             , 'm: df /6'                               , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FCHS-Change Sign
  ['fchs'     , ''                   , 'd9 e0'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=C x87Flags.sw.c0=U'],

  # => FCLEX/FNCLEX-Clear Exceptions
  ['fnclex'   , ''                   , 'db e2           '                       , 'cpuid=fpu x87Flags.sw.b=C x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U x87Flags.sw.es=C x87Flags.sw.sf=C x87Flags.sw.pe=C x87Flags.sw.ue=C x87Flags.sw.oe=C x87Flags.sw.ze=C x87Flags.sw.de=C x87Flags.sw.ie=C'],
  ['fclex'    , ''                   , '9b db e2        '                       , 'cpuid=fpu x87Flags.sw.b=C x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U x87Flags.sw.es=C x87Flags.sw.sf=C x87Flags.sw.pe=C x87Flags.sw.ue=C x87Flags.sw.oe=C x87Flags.sw.ze=C x87Flags.sw.de=C x87Flags.sw.ie=C'],

  # => FCMOVcc-Floating-Point Conditional Move
  ['fcmovnbe' , 'st(0), st(i)'       , 'o: db d0+i         '                    , 'cpuid=fpu|cmov eflags.cf=T eflags.zf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmovne'  , 'st(0), st(i)'       , 'o: db c8+i         '                    , 'cpuid=fpu|cmov eflags.zf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmove'   , 'st(0), st(i)'       , 'o: da c8+i         '                    , 'cpuid=fpu|cmov eflags.zf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmovbe'  , 'st(0), st(i)'       , 'o: da d0+i         '                    , 'cpuid=fpu|cmov eflags.cf=T eflags.zf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmovnu'  , 'st(0), st(i)'       , 'o: db d8+i         '                    , 'cpuid=fpu|cmov eflags.pf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmovu'   , 'st(0), st(i)'       , 'o: da d8+i         '                    , 'cpuid=fpu|cmov eflags.pf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmovb'   , 'st(0), st(i)'       , 'o: da c0+i         '                    , 'cpuid=fpu|cmov eflags.cf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fcmovnb'  , 'st(0), st(i)'       , 'o: db c0+i         '                    , 'cpuid=fpu|cmov eflags.cf=T x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FCOM/FCOMP/FCOMPP-Compare Floating Point Values
  ['fcomp'    , ''                   , '   d8 d9           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcompp'   , ''                   , '   de d9           '                    , 'fpuStackPtr=24 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcom'     , ''                   , '   d8 d1           '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcom'     , 'm32fp'              , 'm: d8 /2           '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcomp'    , 'st(i)'              , 'o: d8 d8+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcom'     , 'm64fp'              , 'm: dc /2           '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcomp'    , 'm32fp'              , 'm: d8 /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcomp'    , 'm64fp'              , 'm: dc /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcom'     , 'st(i)'              , 'o: d8 d0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],

  # => FCOMI/FCOMIP/FUCOMI/FUCOMIP-Compare Floating Point Values and Set EFLAGS
  ['fucomip'  , 'st(i)'              , 'o: df e8+i         '                    , 'fpuStackPtr=12 cpuid=fpu eflags.zf=M eflags.pf=M eflags.cf=M x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fucomi'   , 'st(i)'              , 'o: db e8+i         '                    , 'cpuid=fpu eflags.zf=M eflags.pf=M eflags.cf=M x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcomip'   , 'st(i)'              , 'o: df f0+i         '                    , 'fpuStackPtr=12 cpuid=fpu eflags.zf=M eflags.pf=M eflags.cf=M x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['fcomi'    , 'st(i)'              , 'o: db f0+i         '                    , 'cpuid=fpu eflags.zf=M eflags.pf=M eflags.cf=M x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],

  # => FCOS-Cosine
  ['fcos'     , ''                   , 'd9 ff'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FDECSTP-Decrement Stack-Top Pointer
  ['fdecstp'  , ''                   , 'd9 f6'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=C x87Flags.sw.c0=U'],

  # => FDIV/FDIVP/FIDIV-Divide
  ['fdivp'    , ''                   , '   de f9           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fidiv'    , 'm32int'             , 'm: da /6           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdiv'     , 'm64fp'              , 'm: dc /6           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdiv'     , 'st(0), st(i)'       , 'o: d8 f0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdiv'     , 'st(i), st(0)'       , 'o: dc f8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdivp'    , 'st(i), st(0)'       , 'o: de f8+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fidiv'    , 'm16int'             , 'm: de /6           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdiv'     , 'm32fp'              , 'm: d8 /6           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FDIVR/FDIVRP/FIDIVR-Reverse Divide
  ['fdivrp'   , ''                   , '   de f1           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdivrp'   , 'st(i), st(0)'       , 'o: de f0+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdivr'    , 'm64fp'              , 'm: dc /7           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdivr'    , 'st(i), st(0)'       , 'o: dc f0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fidivr'   , 'm32int'             , 'm: da /7           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fidivr'   , 'm16int'             , 'm: de /7           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdivr'    , 'st(0), st(i)'       , 'o: d8 f8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fdivr'    , 'm32fp'              , 'm: d8 /7           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FFREE-Free Floating-Point Register
  ['ffree'    , 'st(i)'              , 'o: dd c0+i'                             , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => FICOM/FICOMP-Compare Integer
  ['ficomp'   , 'm32int'             , 'm: da /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['ficom'    , 'm32int'             , 'm: da /2           '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['ficomp'   , 'm16int'             , 'm: de /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],
  ['ficom'    , 'm16int'             , 'm: de /2           '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],

  # => FILD-Load Integer
  ['fild'     , 'm32int'             , 'm: db /0           '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fild'     , 'm64int'             , 'm: df /5           '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fild'     , 'm16int'             , 'm: df /0           '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FINCSTP-Increment Stack-Top Pointer
  ['fincstp'  , ''                   , 'd9 f7'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=C x87Flags.sw.c0=U'],

  # => FINIT/FNINIT-Initialize Floating-Point Unit
  ['finit'    , ''                   , '9b db e3        '                       , 'cpuid=fpu x87Flags.sw.c3=C x87Flags.sw.c2=C x87Flags.sw.c1=C x87Flags.sw.c0=C'],
  ['fninit'   , ''                   , 'db e3           '                       , 'cpuid=fpu x87Flags.sw.c3=C x87Flags.sw.c2=C x87Flags.sw.c1=C x87Flags.sw.c0=C'],

  # => FIST/FISTP-Store Integer
  ['fistp'    , 'm16int'             , 'm: df /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fistp'    , 'm32int'             , 'm: db /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fist'     , 'm32int'             , 'm: db /2           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fist'     , 'm16int'             , 'm: df /2           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fistp'    , 'm64int'             , 'm: df /7           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FISTTP-Store Integer with Truncation
  ['fisttp'   , 'm32int'             , 'm: db /1           '                    , 'cpuid=sse3|fpu'],
  ['fisttp'   , 'm64int'             , 'm: dd /1           '                    , 'cpuid=sse3|fpu'],
  ['fisttp'   , 'm16int'             , 'm: df /1           '                    , 'cpuid=sse3|fpu'],

  # => FLD-Load Floating Point Value
  ['fld'      , 'm64fp'              , 'm: dd /0           '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fld'      , 'm32fp'              , 'm: d9 /0           '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fld'      , 'st(i)'              , 'o: d9 c0+i         '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fld'      , 'm80fp'              , 'm: db /5           '                    , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FLD1/FLDL2T/FLDL2E/FLDPI/FLDLG2/FLDLN2/FLDZ-Load Constant
  ['fldpi'    , ''                   , 'd9 eb           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fldlg2'   , ''                   , 'd9 ec           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fldz'     , ''                   , 'd9 ee           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fldl2t'   , ''                   , 'd9 e9           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fldl2e'   , ''                   , 'd9 ea           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fldln2'   , ''                   , 'd9 ed           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fld1'     , ''                   , 'd9 e8           '                       , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FLDCW-Load x87 FPU Control Word
  ['fldcw'    , 'm16'                , 'm: d9 /5'                               , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => FLDENV-Load x87 FPU Environment
  ['fldenv'   , 'm112'               , 'm: os16 d9 /4           '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fldenv'   , 'm224'               , 'm:      d9 /4           '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FMUL/FMULP/FIMUL-Multiply
  ['fmulp'    , ''                   , '   de c9           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fmulp'    , 'st(i), st(0)'       , 'o: de c8+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fimul'    , 'm32int'             , 'm: da /1           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fmul'     , 'm32fp'              , 'm: d8 /1           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fimul'    , 'm16int'             , 'm: de /1           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fmul'     , 'st(0), st(i)'       , 'o: d8 c8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fmul'     , 'st(i), st(0)'       , 'o: dc c8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fmul'     , 'm64fp'              , 'm: dc /1           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FNOP-No Operation
  ['fnop'     , ''                   , 'd9 d0'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => FPATAN-Partial Arctangent
  ['fpatan'   , ''                   , 'd9 f3'                                  , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FPREM-Partial Remainder
  ['fprem'    , ''                   , 'd9 f8'                                  , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FPREM1-Partial Remainder
  ['fprem1'   , ''                   , 'd9 f5'                                  , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FPTAN-Partial Tangent
  ['fptan'    , ''                   , 'd9 f2'                                  , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FRNDINT-Round to Integer
  ['frndint'  , ''                   , 'd9 fc'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FRSTOR-Restore x87 FPU State
  ['frstor'   , 'm752'               , 'm: os16 dd /4           '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['frstor'   , 'm864'               , 'm:      dd /4           '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FSAVE/FNSAVE-Store x87 FPU State
  ['fsave'    , 'm752'               , 'm: os16 9b dd /6        '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fsave'    , 'm864'               , 'm:      9b dd /6        '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fnsave'   , 'm752'               , 'm: os16 dd /6           '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fnsave'   , 'm864'               , 'm:      dd /6           '               , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FSCALE-Scale
  ['fscale'   , ''                   , 'd9 fd'                                  , 'cpuid=fpu'],

  # => FSIN-Sine
  ['fsin'     , ''                   , 'd9 fe'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FSINCOS-Sine and Cosine
  ['fsincos'  , ''                   , 'd9 fb'                                  , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FSQRT-Square Root
  ['fsqrt'    , ''                   , 'd9 fa'                                  , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FST/FSTP-Store Floating Point Value
  ['fst'      , 'm32fp'              , 'm: d9 /2           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fstp'     , 'm80fp'              , 'm: db /7           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fstp'     , 'm64fp'              , 'm: dd /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fstp'     , 'm32fp'              , 'm: d9 /3           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fst'      , 'st(i)'              , 'o: dd d0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fstp'     , 'st(i)'              , 'o: dd d8+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fst'      , 'm64fp'              , 'm: dd /2           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FSTCW/FNSTCW-Store x87 FPU Control Word
  ['fnstcw'   , 'm16'                , 'm: d9 /7           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fstcw'    , 'm16'                , 'm: 9b d9 /7        '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => FSTENV/FNSTENV-Store x87 FPU Environment
  ['fnstenv'  , 'm112'               , 'm: os16 d9 /6           '               , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fnstenv'  , 'm224'               , 'm:      d9 /6           '               , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fstenv'   , 'm112'               , 'm: os16 9b d9 /6        '               , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fstenv'   , 'm224'               , 'm:      9b d9 /6        '               , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => FSTSW/FNSTSW-Store x87 FPU Status Word
  ['fstsw'    , 'ax'                 , '   9b df e0        '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fnstsw'   , 'ax'                 , '   df e0           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fstsw'    , 'm16'                , 'm: 9b dd /7        '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fnstsw'   , 'm16'                , 'm: dd /7           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => FSUB/FSUBP/FISUB-Subtract
  ['fsubp'    , ''                   , '   de e9           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fisub'    , 'm16int'             , 'm: de /4           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsub'     , 'st(i), st(0)'       , 'o: dc e8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsub'     , 'm32fp'              , 'm: d8 /4           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsubp'    , 'st(i), st(0)'       , 'o: de e8+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsub'     , 'm64fp'              , 'm: dc /4           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fisub'    , 'm32int'             , 'm: da /4           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsub'     , 'st(0), st(i)'       , 'o: d8 e0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FSUBR/FSUBRP/FISUBR-Reverse Subtract
  ['fsubrp'   , ''                   , '   de e1           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsubr'    , 'm64fp'              , 'm: dc /5           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fisubr'   , 'm16int'             , 'm: de /5           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsubrp'   , 'st(i), st(0)'       , 'o: de e0+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsubr'    , 'st(i), st(0)'       , 'o: dc e0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsubr'    , 'm32fp'              , 'm: d8 /5           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fsubr'    , 'st(0), st(i)'       , 'o: d8 e8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],
  ['fisubr'   , 'm32int'             , 'm: da /5           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FTST-TEST
  ['ftst'     , ''                   , 'd9 e4'                                  , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=C x87Flags.sw.c0=M'],

  # => FUCOM/FUCOMP/FUCOMPP-Unordered Compare Floating Point Values
  ['fucompp'  , ''                   , '   da e9           '                    , 'fpuStackPtr=24 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fucom'    , ''                   , '   dd e1           '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fucomp'   , ''                   , '   dd e9           '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fucom'    , 'st(i)'              , 'o: dd e0+i         '                    , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],
  ['fucomp'   , 'st(i)'              , 'o: dd e8+i         '                    , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FXAM-Examine Floating-Point
  ['fxam'     , ''                   , 'd9 e5'                                  , 'cpuid=fpu x87Flags.sw.c3=M x87Flags.sw.c2=M x87Flags.sw.c1=M x87Flags.sw.c0=M'],

  # => FXCH-Exchange Register Contents
  ['fxch'     , ''                   , '   d9 c9           '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=C x87Flags.sw.c0=U'],
  ['fxch'     , 'st(i)'              , 'o: d9 c8+i         '                    , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=C x87Flags.sw.c0=U'],

  # => FXRSTOR-Restore x87 FPU, MMX, XMM, and MXCSR State
  ['fxrstor'   , 'R:m4096'            , 'm:     os32 0f ae /1        '           , 'cpuid=fxsr|fpu'],
  ['fxrstor64' , 'R:m4096'            , 'x64:m: os64 0f ae /1        '           , 'cpuid=fxsr|fpu'],

  # => FXSAVE-Save x87 FPU, MMX Technology, and SSE State
  ['fxsave'   , 'W:m4096'            , 'm:     os32 0f ae /0        '           , 'cpuid=fxsr|fpu'],
  ['fxsave64' , 'W:m4096'            , 'x64:m: os64 0f ae /0        '           , 'cpuid=fxsr|fpu'],

  # => FXTRACT-Extract Exponent and Significand
  ['fxtract'  , ''                   , 'd9 f4'                                  , 'fpuStackPtr=-12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FYL2X-Compute y * log2x
  ['fyl2x'    , ''                   , 'd9 f1'                                  , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => FYL2XP1-Compute y * log2(x +1)
  ['fyl2xp1'  , ''                   , 'd9 f9'                                  , 'fpuStackPtr=12 cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=M x87Flags.sw.c0=U'],

  # => HADDPD-Packed Double-FP Horizontal Add
  ['haddpd'   , 'xmm, xmm/m128'              , 'rm:  66 0f 7c /r                  '     , 'cpuid=sse3'],
  ['vhaddpd'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f.wig 7c /r   '     , 'cpuid=avx'],

  # => HADDPS-Packed Single-FP Horizontal Add
  ['haddps'   , 'xmm, xmm/m128'              , 'rm:  f2 0f 7c /r                  '     , 'cpuid=sse3'],
  ['vhaddps'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.f2.0f.wig 7c /r   '     , 'cpuid=avx'],

  # => HLT-Halt
  ['hlt'      , ''                   , 'f4'                                     , 'level=0'],

  # => HSUBPD-Packed Double-FP Horizontal Subtract
  ['hsubpd'   , 'xmm, xmm/m128'              , 'rm:  66 0f 7d /r                  '     , 'cpuid=sse3'],
  ['vhsubpd'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f.wig 7d /r   '     , 'cpuid=avx'],

  # => HSUBPS-Packed Single-FP Horizontal Subtract
  ['hsubps'   , 'xmm, xmm/m128'              , 'rm:  f2 0f 7d /r                  '     , 'cpuid=sse3'],
  ['vhsubps'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.f2.0f.wig 7d /r   '     , 'cpuid=avx'],

  # => IDIV-Signed Divide
  ['idiv'     , 'R:r8x/m8, X:<ax>'                , 'm:          f6 /7           '           , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],
  ['idiv'     , 'R:vr/vm, X:<*dx>, X:<*ax>'       , 'm:     os   f7 /7           '           , 'eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],

  # => IMUL-Signed Multiply
  ['imul'     , 'r/m8, X:<ax>'                  , 'm:            f6 /5           '         , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['imul'     , 'vr/vm, W:<*dx>, X:<*ax>'       , 'm:       os   f7 /5           '         , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['imul'     , 'vr, vr/vm'                     , 'rm:      os   0f af /r        '         , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['imul'     , 'vr, vr/vm, imm8'               , 'rmi:     os   6b /r ib        '         , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['imul'     , 'vr, vr/vm, imm.low'            , 'rmi:     os   69 /r iz        '         , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],

  # => IN-Input from Port
  ['in'       , '*ax, dx'            , '   osz  ed              '               , ''],
  ['in'       , 'al, dx'             , '        ec              '               , ''],
  ['in'       , 'al, pimm8'          , 'i:      e4 ib           '               , ''],
  ['in'       , '*ax, pimm8'         , 'i: osz  e5 ib           '               , ''],

  # => INC-Increment by 1
  ['inc'      , 'vr/vm'              , 'm:     os   ff /0           '           , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M'],
  ['inc'      , 'r8x/m8'             , 'm:          fe /0           '           , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M'],
  ['inc'      , 'vr'                 , 'x86:o: osz  40+r            '           , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M'],

  # => INS/INSB/INSW/INSD-Input from Port to String
  ['insd'     , 'W:<[es:*di]>, <dx>'       , 'os32 6d              '                  , 'rep eflags.df=T'],
  ['insb'     , 'W:<[es:*di]>, <dx>'       , '     6c              '                  , 'rep eflags.df=T'],
  #['ins'      , 'vm, dx'                   , 'osz  6d              '                  , 'rep eflags.df=T'],
  #['ins'      , 'm8, dx'                   , '     6c              '                  , 'rep eflags.df=T'],
  ['insw'     , 'W:<[es:*di]>, <dx>'       , 'os16 6d              '                  , 'rep eflags.df=T'],

  # => INSERTPS-Insert Scalar Single-Precision Floating-Point Value
  ['insertps'  , 'xmm, xmm/m32, pimm8'              , 'rmi:      66 0f 3a 21 /r ib                 ' , 'cpuid=sse4v1'],
  ['vinsertps' , 'W:xmm, xmm, xmm/m32, pimm8'       , 'rvmi:     vex.nds.128.66.0f3a.wig 21 /r ib  ' , 'cpuid=avx'],
  ['vinsertps' , 'W:xmm, xmm, xmm/m32, pimm8'       , 'rvmi:t1s: evex.nds.128.66.0f3a.w0 21 /r ib  ' , 'cpuid=avx512f'],

  # => INT n/INTO/INT 3-Call to Interrupt Procedure
  ['int'      , '3'                  , '     cc              '                  , 'eflags.tf=C eflags.nt=C'],
  ['int'      , 'pimm8'              , 'i:   cd ib           '                  , 'eflags.tf=C eflags.nt=C'],
  ['into'     , ''                   , 'x86: ce              '                  , 'deprecated eflags.of=T eflags.tf=C eflags.nt=C'],

  # => INVD-Invalidate Internal Caches
  ['invd'     , ''                   , '0f 08'                                  , 'level=0'],

  # => INVLPG-Invalidate TLB Entries
  ['invlpg'   , 'R:mem'              , 'm: 0f 01 /7'                            , 'level=0'],

  # => INVPCID-Invalidate Process-Context Identifier
  ['invpcid'  , 'vr, m128'           , 'rm:     osv 66 0f 38 82 /r  '           , 'level=0 cpuid=invpcid'],

  # => IRET/IRETD-Interrupt Return
  ['iret'     , ''                   , '     os16 cf              '             , 'eflags.of=P eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P eflags.tf=P eflags.if=P eflags.df=P eflags.nt=T'],
  ['iretd'    , ''                   , '     os32 cf              '             , 'eflags.of=P eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P eflags.tf=P eflags.if=P eflags.df=P eflags.nt=T'],
  ['iretq'    , ''                   , 'x64: os64 cf              '             , 'eflags.of=P eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P eflags.tf=P eflags.if=P eflags.df=P eflags.nt=T'],

  # => Jcc-Jump if Condition Is Met
  ['jnl'      , 'rel8'               , 'd:          7d ob           '           , 'aliasOf=jge branchType=short bnd eflags.sf=T eflags.of=T'],
  ['jns'      , 'rel'                , 'd:     osz  0f 89 oz        '           , 'branchType=near bnd eflags.sf=T'],
  ['ja'       , 'rel8'               , 'd:          77 ob           '           , 'branchType=short bnd eflags.cf=T eflags.zf=T'],
  ['jng'      , 'rel'                , 'd:     osz  0f 8e oz        '           , 'aliasOf=jle branchType=near bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['jna'      , 'rel'                , 'd:     osz  0f 86 oz        '           , 'aliasOf=jbe branchType=near bnd eflags.cf=T eflags.zf=T'],
  ['jnz'      , 'rel8'               , 'd:          75 ob           '           , 'aliasOf=jne branchType=short bnd eflags.zf=T'],
  ['jnp'      , 'rel'                , 'd:     osz  0f 8b oz        '           , 'branchType=near bnd eflags.pf=T'],
  ['jnbe'     , 'rel8'               , 'd:          77 ob           '           , 'aliasOf=ja branchType=short bnd eflags.cf=T eflags.zf=T'],
  ['jge'      , 'rel'                , 'd:     osz  0f 8d oz        '           , 'branchType=near bnd eflags.sf=T eflags.of=T'],
  ['jl'       , 'rel8'               , 'd:          7c ob           '           , 'branchType=short bnd eflags.sf=T eflags.of=T'],
  ['jpe'      , 'rel'                , 'd:     osz  0f 8a oz        '           , 'aliasOf=jp branchType=near bnd eflags.pf=T'],
  ['jnae'     , 'rel8'               , 'd:          72 ob           '           , 'aliasOf=jb branchType=short bnd eflags.cf=T'],
  ['jnl'      , 'rel'                , 'd:     osz  0f 8d oz        '           , 'aliasOf=jge branchType=near bnd eflags.sf=T eflags.of=T'],
  ['jnbe'     , 'rel'                , 'd:     osz  0f 87 oz        '           , 'aliasOf=ja branchType=near bnd eflags.cf=T eflags.zf=T'],
  ['jo'       , 'rel8'               , 'd:          70 ob           '           , 'branchType=short bnd eflags.of=T'],
  ['jpo'      , 'rel8'               , 'd:          7b ob           '           , 'aliasOf=jnp branchType=short bnd eflags.pf=T'],
  ['jae'      , 'rel8'               , 'd:          73 ob           '           , 'branchType=short bnd eflags.cf=T'],
  ['jnle'     , 'rel'                , 'd:     osz  0f 8f oz        '           , 'aliasOf=jg branchType=near bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['jz'       , 'rel8'               , 'd:          74 ob           '           , 'aliasOf=je branchType=short bnd eflags.zf=T'],
  ['jnge'     , 'rel'                , 'd:     osz  0f 8c oz        '           , 'aliasOf=jl branchType=near bnd eflags.sf=T eflags.of=T'],
  ['jge'      , 'rel8'               , 'd:          7d ob           '           , 'branchType=short bnd eflags.sf=T eflags.of=T'],
  ['jg'       , 'rel'                , 'd:     osz  0f 8f oz        '           , 'branchType=near bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['jne'      , 'rel8'               , 'd:          75 ob           '           , 'branchType=short bnd eflags.zf=T'],
  ['jbe'      , 'rel8'               , 'd:          76 ob           '           , 'branchType=short bnd eflags.cf=T eflags.zf=T'],
  ['jb'       , 'rel8'               , 'd:          72 ob           '           , 'branchType=short bnd eflags.cf=T'],
  ['jnc'      , 'rel'                , 'd:     osz  0f 83 oz        '           , 'aliasOf=jae branchType=near bnd eflags.cf=T'],
  ['jne'      , 'rel'                , 'd:     osz  0f 85 oz        '           , 'branchType=near bnd eflags.zf=T'],
  ['jz'       , 'rel'                , 'd:     osz  0f 84 oz        '           , 'aliasOf=je branchType=near bnd eflags.zf=T'],
  ['jno'      , 'rel8'               , 'd:          71 ob           '           , 'branchType=short bnd eflags.of=T'],
  ['jnb'      , 'rel'                , 'd:     osz  0f 83 oz        '           , 'aliasOf=jae branchType=near bnd eflags.cf=T'],
  ['jnp'      , 'rel8'               , 'd:          7b ob           '           , 'branchType=short bnd eflags.pf=T'],
  ['jng'      , 'rel8'               , 'd:          7e ob           '           , 'aliasOf=jle branchType=short bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['jns'      , 'rel8'               , 'd:          79 ob           '           , 'branchType=short bnd eflags.sf=T'],
  ['jnae'     , 'rel'                , 'd:     osz  0f 82 oz        '           , 'aliasOf=jb branchType=near bnd eflags.cf=T'],
  ['je'       , 'rel'                , 'd:     osz  0f 84 oz        '           , 'branchType=near bnd eflags.zf=T'],
  ['jpo'      , 'rel'                , 'd:     osz  0f 8b oz        '           , 'aliasOf=jnp branchType=near bnd eflags.pf=T'],
  ['ja'       , 'rel'                , 'd:     osz  0f 87 oz        '           , 'branchType=near bnd eflags.cf=T eflags.zf=T'],
  ['jp'       , 'rel8'               , 'd:          7a ob           '           , 'branchType=short bnd eflags.pf=T'],
  ['jc'       , 'rel8'               , 'd:          72 ob           '           , 'aliasOf=jb branchType=short bnd eflags.cf=T'],
  ['jg'       , 'rel8'               , 'd:          7f ob           '           , 'branchType=short bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['js'       , 'rel8'               , 'd:          78 ob           '           , 'branchType=short bnd eflags.sf=T'],
  ['jnge'     , 'rel8'               , 'd:          7c ob           '           , 'aliasOf=jl branchType=short bnd eflags.sf=T eflags.of=T'],
  ['jnb'      , 'rel8'               , 'd:          73 ob           '           , 'aliasOf=jae branchType=short bnd eflags.cf=T'],
  ['jo'       , 'rel'                , 'd:     osz  0f 80 oz        '           , 'branchType=near bnd eflags.of=T'],
  ['jnle'     , 'rel8'               , 'd:          7f ob           '           , 'aliasOf=jg branchType=short bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['jbe'      , 'rel'                , 'd:     osz  0f 86 oz        '           , 'branchType=near bnd eflags.cf=T eflags.zf=T'],
  ['jb'       , 'rel'                , 'd:     osz  0f 82 oz        '           , 'branchType=near bnd eflags.cf=T'],
  ['jecxz'    , 'rel8'               , 'd:          as32 e3 ob      '           , 'branchType=short'],
  ['jna'      , 'rel8'               , 'd:          76 ob           '           , 'aliasOf=jbe branchType=short bnd eflags.cf=T eflags.zf=T'],
  ['jle'      , 'rel8'               , 'd:          7e ob           '           , 'branchType=short bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['jp'       , 'rel'                , 'd:     osz  0f 8a oz        '           , 'branchType=near bnd eflags.pf=T'],
  ['jle'      , 'rel'                , 'd:     osz  0f 8e oz        '           , 'branchType=near bnd eflags.zf=T eflags.sf=T eflags.of=T'],
  ['je'       , 'rel8'               , 'd:          74 ob           '           , 'branchType=short bnd eflags.zf=T'],
  ['jae'      , 'rel'                , 'd:     osz  0f 83 oz        '           , 'branchType=near bnd eflags.cf=T'],
  ['jnz'      , 'rel'                , 'd:     osz  0f 85 oz        '           , 'aliasOf=jne branchType=near bnd eflags.zf=T'],
  ['jc'       , 'rel'                , 'd:     osz  0f 82 oz        '           , 'aliasOf=jb branchType=near bnd eflags.cf=T'],
  ['jno'      , 'rel'                , 'd:     osz  0f 81 oz        '           , 'branchType=near bnd eflags.of=T'],
  ['jnc'      , 'rel8'               , 'd:          73 ob           '           , 'aliasOf=jae branchType=short bnd eflags.cf=T'],
  ['jpe'      , 'rel8'               , 'd:          7a ob           '           , 'aliasOf=jp branchType=short bnd eflags.pf=T'],
  ['jl'       , 'rel'                , 'd:     osz  0f 8c oz        '           , 'branchType=near bnd eflags.sf=T eflags.of=T'],
  ['js'       , 'rel'                , 'd:     osz  0f 88 oz        '           , 'branchType=near bnd eflags.sf=T'],
  ['jcxz'     , 'rel8'               , 'x86:d:      as16 e3 ob      '           , 'branchType=short'],
  ['jrcxz'    , 'rel8'               , 'x64:d:      as64 e3 ob      '           , 'branchType=short'],

  # => JMP-Jump
  ['jmp'      , 'm16:mv'             , 'm:     os   ff /5           '           , 'branchType=far'],
  ['jmp'      , 'rel'                , 'd:     osz  e9 oz           '           , 'branchType=near bnd'],
  ['jmp'      , 'rel8'               , 'd:          eb ob           '           , 'branchType=short bnd'],
  ['jmp'      , 'R:vr/vm'            , 'm:     os   ff /4           '           , 'branchType=near bnd'],
  ['jmp'      , 'ptr16:ptr'          , 'x86:d: osz  ea od           '           , 'deprecated branchType=far'],

  # => KADDW/KADDB/KADDQ/KADDD-ADD Two Masks
  ['kaddw'    , 'W:k, k, k'          , 'rvm: vex.l1.0f.w0 4a /r     '           , 'cpuid=avx512dq'],
  ['kaddb'    , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w0 4a /r  '           , 'cpuid=avx512dq'],
  ['kaddd'    , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w1 4a /r  '           , 'cpuid=avx512bw'],
  ['kaddq'    , 'W:k, k, k'          , 'rvm: vex.l1.0f.w1 4a /r     '           , 'cpuid=avx512bw'],

  # => KANDW/KANDB/KANDQ/KANDD-Bitwise Logical AND Masks
  ['kandb'    , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w0 41 /r   '          , 'cpuid=avx512dq'],
  ['kandw'    , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w0 41 /r  '          , 'cpuid=avx512f'],
  ['kandq'    , 'W:k, k, k'          , 'rvm: vex.l1.0f.w1 41 /r      '          , 'cpuid=avx512bw'],
  ['kandd'    , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w1 41 /r   '          , 'cpuid=avx512bw'],

  # => KANDNW/KANDNB/KANDNQ/KANDND-Bitwise Logical AND NOT Masks
  ['kandnb'   , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w0 42 /r   '          , 'cpuid=avx512dq'],
  ['kandnq'   , 'W:k, k, k'          , 'rvm: vex.l1.0f.w1 42 /r      '          , 'cpuid=avx512bw'],
  ['kandnd'   , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w1 42 /r   '          , 'cpuid=avx512bw'],
  ['kandnw'   , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w0 42 /r  '          , 'cpuid=avx512f'],

  # => KMOVW/KMOVB/KMOVQ/KMOVD-Move from and to Mask Registers
  ['kmovb'    , 'W:k, r32'           , 'rm:     vex.l0.66.0f.w0 92 /r  '        , 'cpuid=avx512dq'],
  ['kmovb'    , 'W:r32, k'           , 'rm:     vex.l0.66.0f.w0 93 /r  '        , 'cpuid=avx512dq'],
  ['kmovb'    , 'W:m8, k'            , 'mr:     vex.l0.66.0f.w0 91 /r  '        , 'cpuid=avx512dq'],
  ['kmovd'    , 'W:r32, k'           , 'rm:     vex.l0.f2.0f.w0 93 /r  '        , 'cpuid=avx512bw'],
  ['kmovd'    , 'W:k, k/m32'         , 'rm:     vex.l0.66.0f.w1 90 /r  '        , 'cpuid=avx512bw'],
  ['kmovq'    , 'W:k, k/m64'         , 'rm:     vex.l0.0f.w1 90 /r     '        , 'cpuid=avx512bw'],
  ['kmovw'    , 'W:r32, k'           , 'rm:     vex.l0.0f.w0 93 /r     '        , 'cpuid=avx512f'],
  ['kmovd'    , 'W:k, r32'           , 'rm:     vex.l0.f2.0f.w0 92 /r  '        , 'cpuid=avx512bw'],
  ['kmovw'    , 'W:k, r32'           , 'rm:     vex.l0.0f.w0 92 /r     '        , 'cpuid=avx512f'],
  ['kmovw'    , 'W:m16, k'           , 'mr:     vex.l0.0f.w0 91 /r     '        , 'cpuid=avx512f'],
  ['kmovb'    , 'W:k, k/m8'          , 'rm:     vex.l0.66.0f.w0 90 /r  '        , 'cpuid=avx512dq'],
  ['kmovw'    , 'W:k, k/m16'         , 'rm:     vex.l0.0f.w0 90 /r     '        , 'cpuid=avx512f'],
  ['kmovq'    , 'W:m64, k'           , 'mr:     vex.l0.0f.w1 91 /r     '        , 'cpuid=avx512bw'],
  ['kmovd'    , 'W:m32, k'           , 'mr:     vex.l0.66.0f.w1 91 /r  '        , 'cpuid=avx512bw'],
  ['kmovq'    , 'W:r64, k'           , 'x64:rm: vex.l0.f2.0f.w1 93 /r  '        , 'cpuid=avx512bw'],
  ['kmovq'    , 'W:k, r64'           , 'x64:rm: vex.l0.f2.0f.w1 92 /r  '        , 'cpuid=avx512bw'],

  # => KNOTW/KNOTB/KNOTQ/KNOTD-NOT Mask Register
  ['knotq'    , 'W:k, k'             , 'rm: vex.l0.0f.w1 44 /r     '            , 'cpuid=avx512bw'],
  ['knotd'    , 'W:k, k'             , 'rm: vex.l0.66.0f.w1 44 /r  '            , 'cpuid=avx512bw'],
  ['knotb'    , 'W:k, k'             , 'rm: vex.l0.66.0f.w0 44 /r  '            , 'cpuid=avx512dq'],
  ['knotw'    , 'W:k, k'             , 'rm: vex.l0.0f.w0 44 /r     '            , 'cpuid=avx512f'],

  # => KORW/KORB/KORQ/KORD-Bitwise Logical OR Masks
  ['korb'     , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w0 45 /r   '          , 'cpuid=avx512dq'],
  ['korw'     , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w0 45 /r  '          , 'cpuid=avx512f'],
  ['kord'     , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w1 45 /r   '          , 'cpuid=avx512bw'],
  ['korq'     , 'W:k, k, k'          , 'rvm: vex.l1.0f.w1 45 /r      '          , 'cpuid=avx512bw'],

  # => KORTESTW/KORTESTB/KORTESTQ/KORTESTD-OR Masks And Set Flags
  ['kortestq' , 'W:k, k'             , 'rm: vex.l0.0f.w1 98 /r     '            , 'cpuid=avx512bw eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],
  ['kortestb' , 'W:k, k'             , 'rm: vex.l0.66.0f.w0 98 /r  '            , 'cpuid=avx512dq eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],
  ['kortestw' , 'W:k, k'             , 'rm: vex.l0.0f.w0 98 /r     '            , 'cpuid=avx512f eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],
  ['kortestd' , 'W:k, k'             , 'rm: vex.l0.66.0f.w1 98 /r  '            , 'cpuid=avx512bw eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],

  # => KSHIFTLW/KSHIFTLB/KSHIFTLQ/KSHIFTLD-Shift Left Mask Registers
  ['kshiftlw' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w1 32 /r ib  '      , 'cpuid=avx512f'],
  ['kshiftld' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w0 33 /r ib  '      , 'cpuid=avx512bw'],
  ['kshiftlb' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w0 32 /r ib  '      , 'cpuid=avx512dq'],
  ['kshiftlq' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w1 33 /r ib  '      , 'cpuid=avx512bw'],

  # => KSHIFTRW/KSHIFTRB/KSHIFTRQ/KSHIFTRD-Shift Right Mask Registers
  ['kshiftrd' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w0 31 /r ib  '      , 'cpuid=avx512bw'],
  ['kshiftrq' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w1 31 /r ib  '      , 'cpuid=avx512bw'],
  ['kshiftrb' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w0 30 /r ib  '      , 'cpuid=avx512dq'],
  ['kshiftrw' , 'W:k, k, pimm8'       , 'rmi: vex.l0.66.0f3a.w1 30 /r ib  '      , 'cpuid=avx512f'],

  # => KTESTW/KTESTB/KTESTQ/KTESTD-Packed Bit Test Masks and Set Flags
  ['ktestw'   , 'R:k, k'             , 'rm: vex.l0.0f.w0 99 /r     '            , 'cpuid=avx512dq'],
  ['ktestq'   , 'R:k, k'             , 'rm: vex.l0.0f.w1 99 /r     '            , 'cpuid=avx512bw'],
  ['ktestd'   , 'R:k, k'             , 'rm: vex.l0.66.0f.w1 99 /r  '            , 'cpuid=avx512bw'],
  ['ktestb'   , 'R:k, k'             , 'rm: vex.l0.66.0f.w0 99 /r  '            , 'cpuid=avx512dq'],

  # => KUNPCKBW/KUNPCKWD/KUNPCKDQ-Unpack for Mask Registers
  ['kunpckdq' , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w1 4b /r     '       , 'cpuid=avx512bw'],
  ['kunpckbw' , 'W:k, k, k'          , 'rvm: vex.nds.l1.66.0f.w0 4b /r  '       , 'cpuid=avx512f'],
  ['kunpckwd' , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w0 4b /r     '       , 'cpuid=avx512bw'],

  # => KXNORW/KXNORB/KXNORQ/KXNORD-Bitwise Logical XNOR Masks
  ['kxnorw'   , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w0 46 /r  '          , 'cpuid=avx512f'],
  ['kxnord'   , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w1 46 /r   '          , 'cpuid=avx512bw'],
  ['kxnorq'   , 'W:k, k, k'          , 'rvm: vex.l1.0f.w1 46 /r      '          , 'cpuid=avx512bw'],
  ['kxnorb'   , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w0 46 /r   '          , 'cpuid=avx512dq'],

  # => KXORW/KXORB/KXORQ/KXORD-Bitwise Logical XOR Masks
  ['kxorq'    , 'W:k, k, k'          , 'rvm: vex.l1.0f.w1 47 /r      '          , 'cpuid=avx512bw'],
  ['kxorw'    , 'W:k, k, k'          , 'rvm: vex.nds.l1.0f.w0 47 /r  '          , 'cpuid=avx512f'],
  ['kxord'    , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w1 47 /r   '          , 'cpuid=avx512bw'],
  ['kxorb'    , 'W:k, k, k'          , 'rvm: vex.l1.66.0f.w0 47 /r   '          , 'cpuid=avx512dq'],

  # => LAHF-Load Status Flags into AH Register
  ['lahf'     , 'W:<ah>'             , 'x86: 9f'                                , 'cpuid=sahf'],

  # => LAR-Load Access Rights Byte
  ['lar'      , 'W:r16, r/m16'         , 'rm: os16 0f 02 /r        '              , 'eflags.zf=M'],
  ['lar'      , 'W:reg, r32/m16'       , 'rm: os32 0f 02 /r        '              , 'eflags.zf=M'],

  # => LDDQU-Load Unaligned Integer 128 Bits
  ['lddqu'    , 'W:xmm, mem'         , 'rm: f2 0f f0 /r              '          , 'cpuid=sse3'],
  ['vlddqu'   , 'W:vmm, vm'          , 'rm: vex.vl.f2.0f.wig f0 /r   '          , 'cpuid=avx'],

  # => LDMXCSR-Load MXCSR Register
  ['ldmxcsr'  , 'R:m32'              , 'm: 0f ae /2             '               , 'cpuid=sse'],
  ['vldmxcsr' , 'R:m32'              , 'm: vex.lz.0f.wig ae /2  '               , 'cpuid=avx'],

  # => LDS/LES/LFS/LGS/LSS-Load Far Pointer
  ['lfs'      , 'W:vr, m16:mv'        , 'rm:     os   0f b4 /r        '          , ''],
  ['lgs'      , 'W:vr, m16:mv'        , 'rm:     os   0f b5 /r        '          , ''],
  ['lss'      , 'W:vr, m16:mv'        , 'rm:     os   0f b2 /r        '          , ''],
  ['lds'      , 'W:vr, m16:mv'        , 'x86:rm: osz  c5 /r           '          , 'deprecated'],
  ['les'      , 'W:vr, m16:mv'        , 'x86:rm: osz  c4 /r           '          , 'deprecated'],

  # => LEA-Load Effective Address
  ['lea'      , 'W:vr, mem'          , 'rm:     os   8d /r           '          , ''],

  # => LEAVE-High Level Procedure Exit
  ['leave'    , '<*sp>, X:<*bp>'       , '     os   c9              '             , ''],

  # => LFENCE-Load Fence
  ['lfence'   , ''                   , '0f ae e8'                               , ''],

  # => LGDT/LIDT-Load Global/Interrupt Descriptor Table Register
  ['lgdt'     , 'R:m16&32'           , 'x86:m: 0f 01 /2        '                , 'level=0'],
  ['lgdt'     , 'R:m16&64'           , 'x64:m: 0f 01 /2        '                , 'level=0'],
  ['lidt'     , 'R:m16&32'           , 'x86:m: 0f 01 /3        '                , 'level=0'],
  ['lidt'     , 'R:m16&64'           , 'x64:m: 0f 01 /3        '                , 'level=0'],

  # => LLDT-Load Local Descriptor Table Register
  ['lldt'     , 'R:r/m16'            , 'm: 0f 00 /2'                            , 'level=0'],

  # => LMSW-Load Machine Status Word
  ['lmsw'     , 'R:r/m16, W:<cr0>'       , 'm: 0f 01 /6'                            , 'level=0'],

  # => LODS/LODSB/LODSW/LODSD/LODSQ-Load String
  #['lods'     , 'm8'                        , '          ac              '             , 'rep eflags.df=T'],
  #['lods'     , 'vm'                        , '     os   ad              '             , 'rep eflags.df=T'],
  ['lodsd'    , 'W:<eax>, <[ds:*si]>'       , '     os32 ad              '             , 'rep eflags.df=T'],
  ['lodsb'    , 'W:<al>, <[ds:*si]>'        , '          ac              '             , 'rep eflags.df=T'],
  ['lodsw'    , 'W:<ax>, <[ds:*si]>'        , '     os16 ad              '             , 'rep eflags.df=T'],
  ['lodsq'    , 'W:<rax>, <[*si]>'          , 'x64: os64 ad              '             , 'rep eflags.df=T'],

  # => LOOP/LOOPcc-Loop According to ECX Counter
  ['loop'     , 'rel8'               , 'd: e2 ob           '                    , 'branchType=short'],
  ['loopne'   , 'rel8'               , 'd: e0 ob           '                    , 'branchType=short eflags.zf=T'],
  ['loope'    , 'rel8'               , 'd: e1 ob           '                    , 'branchType=short eflags.zf=T'],

  # => LSL-Load Segment Limit
  ['lsl'      , 'W:vr, vr.low/m16'     , 'rm:     os   0f 03 /r        '          , 'eflags.zf=M'],

  # => LTR-Load Task Register
  ['ltr'      , 'R:r/m16'            , 'm: 0f 00 /3'                            , 'level=0'],

  # => LZCNT-Count the Number of Leading Zero Bits
  ['lzcnt'    , 'W:vr, vr/vm'        , 'rm:     os   f3 0f bd /r     '          , 'cpuid=lzcnt eflags.of=U eflags.sf=U eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],



  # ===>                               M to U instructions                               <===

  # => MASKMOVDQU-Store Selected Bytes of Double Quadword
  ['maskmovdqu'  , 'W:<[ds:*di]>, xmm, xmm'       , 'rm: 66 0f f7 /r              '          , 'cpuid=sse2'],
  ['vmaskmovdqu' , 'W:<[ds:*di]>, xmm, xmm'       , 'rm: vex.128.66.0f.wig f7 /r  '          , 'cpuid=avx'],

  # => MASKMOVQ-Store Selected Bytes of Quadword
  ['maskmovq' , 'W:<[ds:*di]>, mm, mm'       , 'rm: 0f f7 /r'                           , ''],

  # => MAXPD-Maximum of Packed Double-Precision Floating-Point Values
  ['maxpd'    , 'xmm, xmm/m128'                             , 'rm:     66 0f 5f /r                  '  , 'cpuid=sse2'],
  ['vmaxpd'   , 'W:vmm, vmm, vmm/vm'                        , 'rvm:    vex.nds.vl.66.0f.wig 5f /r   '  , 'cpuid=avx'],
  ['vmaxpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64 {sae}'         , 'rvm:fv: evex.nds.vl.66.0f.w1 5f /r   '  , 'cpuid=avx512f-vl'],

  # => MAXPS-Maximum of Packed Single-Precision Floating-Point Values
  ['maxps'    , 'xmm, xmm/m128'                             , 'rm:     0f 5f /r                  '     , 'cpuid=sse'],
  ['vmaxps'   , 'W:vmm, vmm, vmm/vm'                        , 'rvm:    vex.nds.vl.0f.wig 5f /r   '     , 'cpuid=avx'],
  ['vmaxps'   , 'W:vmm {kz}, vmm, vmm/vm/b32 {sae}'         , 'rvm:fv: evex.nds.vl.0f.w0 5f /r   '     , 'cpuid=avx512f-vl'],

  # => MAXSD-Return Maximum Scalar Double-Precision Floating-Point Value
  ['maxsd'    , 'xmm, xmm/m64'                         , 'rm:      f2 0f 5f /r                  ' , 'cpuid=sse2'],
  ['vmaxsd'   , 'W:xmm, xmm, xmm/m64'                  , 'rvm:     vex.nds.128.f2.0f.wig 5f /r  ' , 'cpuid=avx'],
  ['vmaxsd'   , 'W:xmm {kz}, xmm, xmm/m64 {sae}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 5f /r  ' , 'cpuid=avx512f'],

  # => MAXSS-Return Maximum Scalar Single-Precision Floating-Point Value
  ['maxss'    , 'xmm, xmm/m32'                         , 'rm:      f3 0f 5f /r                  ' , 'cpuid=sse'],
  ['vmaxss'   , 'W:xmm, xmm, xmm/m32'                  , 'rvm:     vex.nds.128.f3.0f.wig 5f /r  ' , 'cpuid=avx'],
  ['vmaxss'   , 'W:xmm {kz}, xmm, xmm/m32 {sae}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 5f /r  ' , 'cpuid=avx512f'],

  # => MFENCE-Memory Fence
  ['mfence'   , ''                   , '0f ae f0'                               , ''],

  # => MINPD-Minimum of Packed Double-Precision Floating-Point Values
  ['minpd'    , 'xmm, xmm/m128'                             , 'rm:     66 0f 5d /r                  '  , 'cpuid=sse2'],
  ['vminpd'   , 'W:vmm, vmm, vmm/vm'                        , 'rvm:    vex.nds.vl.66.0f.wig 5d /r   '  , 'cpuid=avx'],
  ['vminpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64 {sae}'         , 'rvm:fv: evex.nds.vl.66.0f.w1 5d /r   '  , 'cpuid=avx512f-vl'],

  # => MINPS-Minimum of Packed Single-Precision Floating-Point Values
  ['minps'    , 'xmm, xmm/m128'                             , 'rm:     0f 5d /r                  '     , 'cpuid=sse'],
  ['vminps'   , 'W:vmm, vmm, vmm/vm'                        , 'rvm:    vex.nds.vl.0f.wig 5d /r   '     , 'cpuid=avx'],
  ['vminps'   , 'W:vmm {kz}, vmm, vmm/vm/b32 {sae}'         , 'rvm:fv: evex.nds.vl.0f.w0 5d /r   '     , 'cpuid=avx512f-vl'],

  # => MINSD-Return Minimum Scalar Double-Precision Floating-Point Value
  ['minsd'    , 'xmm, xmm/m64'                         , 'rm:      f2 0f 5d /r                  ' , 'cpuid=sse2'],
  ['vminsd'   , 'W:xmm, xmm, xmm/m64'                  , 'rvm:     vex.nds.128.f2.0f.wig 5d /r  ' , 'cpuid=avx'],
  ['vminsd'   , 'W:xmm {kz}, xmm, xmm/m64 {sae}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 5d /r  ' , 'cpuid=avx512f'],

  # => MINSS-Return Minimum Scalar Single-Precision Floating-Point Value
  ['minss'    , 'xmm, xmm/m32'                         , 'rm:      f3 0f 5d /r                  ' , 'cpuid=sse'],
  ['vminss'   , 'W:xmm, xmm, xmm/m32'                  , 'rvm:     vex.nds.128.f3.0f.wig 5d /r  ' , 'cpuid=avx'],
  ['vminss'   , 'W:xmm {kz}, xmm, xmm/m32 {sae}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 5d /r  ' , 'cpuid=avx512f'],

  # => MONITOR-Set Up Monitor Address
  ['monitor'  , ''                   , '0f 01 c8'                               , 'level=0 cpuid=monitor'],

  # => MOV-Move
  ['mov'      , 'W:al, moffs8'         , 'd:      osv  a0 mb           '          , ''],
  ['mov'      , 'W:moffs, *ax'         , 'd:      os   a3 mv           '          , ''],
  ['mov'      , 'W:*ax, moffs'         , 'd:      os   a1 mv           '          , ''],
  ['mov'      , 'W:moffs8, al'         , 'd:      osv  a2 mb           '          , ''],
  ['mov'      , 'W:r8x, r8x/m8'        , 'rm:          8a /r           '          , ''],
  ['mov'      , 'W:r8x/m8, r8x'        , 'mr:          88 /r           '          , 'lock=hardware'],
  ['mov'      , 'W:vr/vm, imm.low'     , 'mi:     os   c7 /0 iz        '          , 'lock=hardware'],
  ['mov'      , 'W:vr/vm, sreg'        , 'mr:     wq   8c /r           '          , ''],
  ['mov'      , 'W:r8x/m8, imm8'       , 'mi:          c6 /0 ib        '          , 'lock=hardware'],
  ['mov'      , 'W:vr/vm, vr'          , 'mr:     os   89 /r           '          , 'lock=hardware'],
  ['mov'      , 'W:sreg, vr/vm'        , 'rm:     wq   8e /r           '          , ''],
  ['mov'      , 'W:r8x, imm8'          , 'oi:          b0+rb ib        '          , ''],
  ['mov'      , 'W:vr, vr/vm'          , 'rm:     os   8b /r           '          , ''],
  ['mov'      , 'W:vr, imm'            , 'oi:     os   b8+r iv         '          , ''],

  # => MOV-Move to/from Control Registers
  ['mov'      , 'W:creg, vr'         , 'rm:     osv 0f 22 /r        '           , 'level=0 eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],
  ['mov'      , 'W:vr, creg'         , 'mr:     osv 0f 20 /r        '           , 'level=0 eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],
  #['mov'      , 'W:r64, cr8'         , 'x64:mr: rex.r 0f 20 /0  '               , 'level=0 eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],
  #['mov'      , 'W:cr8, r64'         , 'x64:rm: rex.r 0f 22 /0  '               , 'level=0 eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],

  # => MOV-Move to/from Debug Registers
  ['mov'      , 'W:dreg, vr'         , 'rm:     osv 0f 23 /r        '           , 'level=0 eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],
  ['mov'      , 'W:vr, dreg'         , 'mr:     osv 0f 21 /r        '           , 'level=0 eflags.of=U eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=U'],

  # => MOVAPD-Move Aligned Packed Double-Precision Floating-Point Values
  ['movapd'   , 'W:xmm, xmm/m128'            , 'rm:     66 0f 28 /r              '      , 'cpuid=sse2'],
  ['movapd'   , 'W:xmm/m128, xmm'            , 'mr:     66 0f 29 /r              '      , 'cpuid=sse2'],
  ['vmovapd'  , 'W:vmm/vm, vmm'              , 'mr:     vex.vl.66.0f.wig 29 /r   '      , 'cpuid=avx'],
  ['vmovapd'  , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.66.0f.wig 28 /r   '      , 'cpuid=avx'],
  ['vmovapd'  , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.66.0f.w1 29 /r   '      , 'cpuid=avx512f-vl'],
  ['vmovapd'  , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.66.0f.w1 28 /r   '      , 'cpuid=avx512f-vl'],

  # => MOVAPS-Move Aligned Packed Single-Precision Floating-Point Values
  ['movaps'   , 'W:xmm/m128, xmm'            , 'mr:     0f 29 /r              '         , 'cpuid=sse'],
  ['movaps'   , 'W:xmm, xmm/m128'            , 'rm:     0f 28 /r              '         , 'cpuid=sse'],
  ['vmovaps'  , 'W:vmm/vm, vmm'              , 'mr:     vex.vl.0f.wig 29 /r   '         , 'cpuid=avx'],
  ['vmovaps'  , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.0f.wig 28 /r   '         , 'cpuid=avx'],
  ['vmovaps'  , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.0f.w0 28 /r   '         , 'cpuid=avx512f-vl'],
  ['vmovaps'  , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.0f.w0 29 /r   '         , 'cpuid=avx512f-vl'],

  # => MOVBE-Move Data After Swapping Bytes
  ['movbe'    , 'W:vm, vr'           , 'mr:     os   0f 38 f1 /r     '          , 'cpuid=movbe|sse4v2'],
  ['movbe'    , 'W:vr, vm'           , 'rm:     os   0f 38 f0 /r     '          , 'cpuid=movbe|sse4v2'],

  # => MOVD/MOVQ-Move Doubleword/Move Quadword
  ['movd'     , 'W:r/m32, mm'        , 'mr:         0f 7e /r                 '  , 'cpuid=mmx'],
  ['movd'     , 'W:mm, r/m32'        , 'rm:         0f 6e /r                 '  , 'cpuid=mmx'],
  ['movq'     , 'W:mm, r/m64'        , 'x64:rm:     rex.w 0f 6e /r           '  , 'cpuid=mmx'],
  ['movq'     , 'W:r/m64, mm'        , 'x64:mr:     rex.w 0f 7e /r           '  , 'cpuid=mmx'],
  ['movd'     , 'W:r/m32, xmm'       , 'mr:         66 0f 7e /r              '  , 'cpuid=sse2'],
  ['movd'     , 'W:xmm, r/m32'       , 'rm:         66 0f 6e /r              '  , 'cpuid=sse2'],
  ['movq'     , 'W:xmm, r/m64'       , 'x64:rm:     66 rex.w 0f 6e /r        '  , 'cpuid=sse2'],
  ['movq'     , 'W:r/m64, xmm'       , 'x64:mr:     66 rex.w 0f 7e /r        '  , 'cpuid=sse2'],
  ['vmovd'    , 'W:xmm, r/m32'       , 'rm:         vex.128.66.0f.w0 6e /r   '  , 'cpuid=avx'],
  ['vmovd'    , 'W:r/m32, xmm'       , 'mr:         vex.128.66.0f.w0 7e /r   '  , 'cpuid=avx'],
  ['vmovq'    , 'W:r/m64, xmm'       , 'x64:mr:     vex.128.66.0f.w1 7e /r   '  , 'cpuid=avx'],
  ['vmovq'    , 'W:xmm, r/m64'       , 'x64:rm:     vex.128.66.0f.w1 6e /r   '  , 'cpuid=avx'],
  ['vmovd'    , 'W:r/m32, xmm'       , 'mr:t1s:     evex.128.66.0f.w0 7e /r  '  , 'cpuid=avx512f'],
  ['vmovd'    , 'W:xmm, r/m32'       , 'rm:t1s:     evex.128.66.0f.w0 6e /r  '  , 'cpuid=avx512f'],
  ['vmovq'    , 'W:r/m64, xmm'       , 'x64:mr:t1s: evex.128.66.0f.w1 7e /r  '  , 'cpuid=avx512f'],
  ['vmovq'    , 'W:xmm, r/m64'       , 'x64:rm:t1s: evex.128.66.0f.w1 6e /r  '  , 'cpuid=avx512f'],

  # => MOVDDUP-Replicate Double FP Values
  ['movddup'  , 'W:xmm, xmm/m64'             , 'rm:     f2 0f 12 /r              '      , 'cpuid=sse3'],
  ['vmovddup' , 'W:xmm, xmm/m64'             , 'rm:     vex.128.f2.0f.wig 12 /r  '      , 'cpuid=avx'],
  ['vmovddup' , 'W:ymm, ymm/m256'            , 'rm:     vex.256.f2.0f.wig 12 /r  '      , 'cpuid=avx'],
  ['vmovddup' , 'W:xmm {kz}, xmm/m64'        , 'rm:dup: evex.128.f2.0f.w1 12 /r  '      , 'cpuid=avx512f-vl'],
  ['vmovddup' , 'W:ymm {kz}, ymm/m256'       , 'rm:dup: evex.256.f2.0f.w1 12 /r  '      , 'cpuid=avx512f-vl'],
  ['vmovddup' , 'W:zmm {kz}, zmm/m512'       , 'rm:dup: evex.512.f2.0f.w1 12 /r  '      , 'cpuid=avx512f'],

  # => MOVDQA,VMOVDQA32/64-Move Aligned Packed Integer Values
  ['movdqa'    , 'W:xmm/m128, xmm'            , 'mr:     66 0f 7f /r              '      , 'cpuid=sse2'],
  ['movdqa'    , 'W:xmm, xmm/m128'            , 'rm:     66 0f 6f /r              '      , 'cpuid=sse2'],
  ['vmovdqa'   , 'W:vmm/vm, vmm'              , 'mr:     vex.vl.66.0f.wig 7f /r   '      , 'cpuid=avx'],
  ['vmovdqa'   , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.66.0f.wig 6f /r   '      , 'cpuid=avx'],
  ['vmovdqa64' , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.66.0f.w1 7f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqa64' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.66.0f.w1 6f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqa32' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.66.0f.w0 6f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqa32' , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.66.0f.w0 7f /r   '      , 'cpuid=avx512f-vl'],

  # => MOVDQU,VMOVDQU8/16/32/64-Move Unaligned Packed Integer Values
  ['movdqu'    , 'W:xmm/m128, xmm'            , 'mr:     f3 0f 7f /r              '      , 'cpuid=sse2'],
  ['movdqu'    , 'W:xmm, xmm/m128'            , 'rm:     f3 0f 6f /r              '      , 'cpuid=sse2'],
  ['vmovdqu'   , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.f3.0f.wig 6f /r   '      , 'cpuid=avx'],
  ['vmovdqu'   , 'W:vmm/vm, vmm'              , 'mr:     vex.vl.f3.0f.wig 7f /r   '      , 'cpuid=avx'],
  ['vmovdqu32' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.f3.0f.w0 6f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqu64' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.f3.0f.w1 6f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqu32' , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.f3.0f.w0 7f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqu8'  , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.f2.0f.w0 6f /r   '      , 'cpuid=avx512bw-vl'],
  ['vmovdqu64' , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.f3.0f.w1 7f /r   '      , 'cpuid=avx512f-vl'],
  ['vmovdqu16' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.f2.0f.w1 6f /r   '      , 'cpuid=avx512bw-vl'],
  ['vmovdqu8'  , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.f2.0f.w0 7f /r   '      , 'cpuid=avx512bw-vl'],
  ['vmovdqu16' , 'W:vmm/vm {kz}, vmm'         , 'mr:fvm: evex.vl.f2.0f.w1 7f /r   '      , 'cpuid=avx512bw-vl'],

  # => MOVDQ2Q-Move Quadword from XMM to MMX Technology Register
  ['movdq2q'  , 'W:mm, xmm'          , 'rm: f2 0f d6 /r'                        , 'cpuid=sse2'],

  # => MOVHLPS-Move Packed Single-Precision Floating-Point Values High to Low
  ['movhlps'  , 'W:xmm, xmm'            , 'rm:  0f 12 /r                  '        , 'cpuid=sse'],
  ['vmovhlps' , 'W:xmm, xmm, xmm'       , 'rvm: vex.nds.128.0f.wig 12 /r  '        , 'cpuid=avx'],
  ['vmovhlps' , 'W:xmm, xmm, xmm'       , 'rvm: evex.nds.128.0f.w0 12 /r  '        , 'cpuid=avx512f'],

  # => MOVHPD-Move High Packed Double-Precision Floating-Point Value
  ['movhpd'   , 'W:xmm, m64'            , 'rm:      66 0f 16 /r                  ' , 'cpuid=sse2'],
  ['movhpd'   , 'W:m64, xmm'            , 'mr:      66 0f 17 /r                  ' , 'cpuid=sse2'],
  ['vmovhpd'  , 'W:m64, xmm'            , 'mr:      vex.128.66.0f.wig 17 /r      ' , 'cpuid=avx'],
  ['vmovhpd'  , 'W:xmm, xmm, m64'       , 'rvm:     vex.nds.128.66.0f.wig 16 /r  ' , 'cpuid=avx'],
  ['vmovhpd'  , 'W:m64, xmm'            , 'mr:t1s:  evex.128.66.0f.w1 17 /r      ' , 'cpuid=avx512f'],
  ['vmovhpd'  , 'W:xmm, xmm, m64'       , 'rvm:t1s: evex.nds.128.66.0f.w1 16 /r  ' , 'cpuid=avx512f'],

  # => MOVHPS-Move High Packed Single-Precision Floating-Point Values
  ['movhps'   , 'W:m64, xmm'            , 'mr:     0f 17 /r                  '     , 'cpuid=sse'],
  ['movhps'   , 'W:xmm, m64'            , 'rm:     0f 16 /r                  '     , 'cpuid=sse'],
  ['vmovhps'  , 'W:m64, xmm'            , 'mr:     vex.128.0f.wig 17 /r      '     , 'cpuid=avx'],
  ['vmovhps'  , 'W:xmm, xmm, m64'       , 'rvm:    vex.nds.128.0f.wig 16 /r  '     , 'cpuid=avx'],
  ['vmovhps'  , 'W:m64, xmm'            , 'mr:t2:  evex.128.0f.w0 17 /r      '     , 'cpuid=avx512f'],
  ['vmovhps'  , 'W:xmm, xmm, m64'       , 'rvm:t2: evex.nds.128.0f.w0 16 /r  '     , 'cpuid=avx512f'],

  # => MOVLHPS-Move Packed Single-Precision Floating-Point Values Low to High
  ['movlhps'  , 'W:xmm, xmm'            , 'rm:  0f 16 /r                  '        , 'cpuid=sse'],
  ['vmovlhps' , 'W:xmm, xmm, xmm'       , 'rvm: vex.nds.128.0f.wig 16 /r  '        , 'cpuid=avx'],
  ['vmovlhps' , 'W:xmm, xmm, xmm'       , 'rvm: evex.nds.128.0f.w0 16 /r  '        , 'cpuid=avx512f'],

  # => MOVLPD-Move Low Packed Double-Precision Floating-Point Value
  ['movlpd'   , 'W:xmm, m64'            , 'rm:      66 0f 12 /r                  ' , 'cpuid=sse2'],
  ['movlpd'   , 'W:m64, xmm'            , 'mr:      66 0f 13 /r                  ' , 'cpuid=sse2'],
  ['vmovlpd'  , 'W:m64, xmm'            , 'mr:      vex.128.66.0f.wig 13 /r      ' , 'cpuid=avx'],
  ['vmovlpd'  , 'W:xmm, xmm, m64'       , 'rvm:     vex.nds.128.66.0f.wig 12 /r  ' , 'cpuid=avx'],
  ['vmovlpd'  , 'W:m64, xmm'            , 'mr:t1s:  evex.128.66.0f.w1 13 /r      ' , 'cpuid=avx512f'],
  ['vmovlpd'  , 'W:xmm, xmm, m64'       , 'rvm:t1s: evex.nds.128.66.0f.w1 12 /r  ' , 'cpuid=avx512f'],

  # => MOVLPS-Move Low Packed Single-Precision Floating-Point Values
  ['movlps'   , 'W:m64, xmm'            , 'mr:     0f 13 /r                  '     , 'cpuid=sse'],
  ['movlps'   , 'W:xmm, m64'            , 'rm:     0f 12 /r                  '     , 'cpuid=sse'],
  ['vmovlps'  , 'W:m64, xmm'            , 'mr:     vex.128.0f.wig 13 /r      '     , 'cpuid=avx'],
  ['vmovlps'  , 'W:xmm, xmm, m64'       , 'rvm:    vex.nds.128.0f.wig 12 /r  '     , 'cpuid=avx'],
  ['vmovlps'  , 'W:m64, xmm'            , 'mr:t2:  evex.128.0f.w0 13 /r      '     , 'cpuid=avx512f'],
  ['vmovlps'  , 'W:xmm, xmm, m64'       , 'rvm:t2: evex.nds.128.0f.w0 12 /r  '     , 'cpuid=avx512f'],

  # => MOVMSKPD-Extract Packed Double-Precision Floating-Point Sign Mask
  ['movmskpd'  , 'W:reg, xmm'         , 'rm: 66 0f 50 /r              '          , 'cpuid=sse2'],
  ['vmovmskpd' , 'W:reg, vmm'         , 'rm: vex.vl.66.0f.wig 50 /r   '          , 'cpuid=avx'],

  # => MOVMSKPS-Extract Packed Single-Precision Floating-Point Sign Mask
  ['movmskps'  , 'W:reg, xmm'         , 'rm: 0f 50 /r              '             , 'cpuid=sse'],
  ['vmovmskps' , 'W:reg, vmm'         , 'rm: vex.vl.0f.wig 50 /r   '             , 'cpuid=avx'],

  # => MOVNTDQA-Load Double Quadword Non-Temporal Aligned Hint
  ['movntdqa'  , 'W:xmm, m128'        , 'rm:     66 0f 38 2a /r             '    , 'cpuid=sse4v1'],
  ['vmovntdqa' , 'W:vmm, vm'          , 'rm:     vex.vl.66.0f38.wig 2a /r   '    , 'cpuid=avx-2'],
  ['vmovntdqa' , 'W:vmm, vm'          , 'rm:fvm: evex.vl.66.0f38.w0 2a /r   '    , 'cpuid=avx512f-vl'],

  # => MOVNTDQ-Store Packed Integers Using Non-Temporal Hint
  ['movntdq'  , 'W:m128, xmm'        , 'mr:     66 0f e7 /r              '      , 'cpuid=sse2'],
  ['vmovntdq' , 'W:vm, vmm'          , 'mr:     vex.vl.66.0f.wig e7 /r   '      , 'cpuid=avx'],
  ['vmovntdq' , 'W:vm, vmm'          , 'mr:fvm: evex.vl.66.0f.w0 e7 /r   '      , 'cpuid=avx512f-vl'],

  # => MOVNTI-Store Doubleword Using Non-Temporal Hint
  ['movnti'   , 'W:vm, vr'           , 'mr:     osv  0f c3 /r        '          , 'cpuid=sse2'],

  # => MOVNTPD-Store Packed Double-Precision Floating-Point Values Using Non-Temporal Hint
  ['movntpd'  , 'W:m128, xmm'        , 'mr:     66 0f 2b /r              '      , 'cpuid=sse2'],
  ['vmovntpd' , 'W:vm, vmm'          , 'mr:     vex.vl.66.0f.wig 2b /r   '      , 'cpuid=avx'],
  ['vmovntpd' , 'W:vm, vmm'          , 'mr:fvm: evex.vl.66.0f.w1 2b /r   '      , 'cpuid=avx512f-vl'],

  # => MOVNTPS-Store Packed Single-Precision Floating-Point Values Using Non-Temporal Hint
  ['movntps'  , 'W:m128, xmm'        , 'mr:     0f 2b /r              '         , 'cpuid=sse'],
  ['vmovntps' , 'W:vm, vmm'          , 'mr:     vex.vl.0f.wig 2b /r   '         , 'cpuid=avx'],
  ['vmovntps' , 'W:vm, vmm'          , 'mr:fvm: evex.vl.0f.w0 2b /r   '         , 'cpuid=avx512f-vl'],

  # => MOVNTQ-Store of Quadword Using Non-Temporal Hint
  ['movntq'   , 'W:m64, mm'          , 'mr: 0f e7 /r'                           , ''],

  # => MOVQ-Move Quadword
  ['movq'     , 'W:mm/m64, mm'         , 'mr:     0f 7f /r                 '      , 'cpuid=mmx'],
  ['movq'     , 'W:mm, mm/m64'         , 'rm:     0f 6f /r                 '      , 'cpuid=mmx'],
  ['movq'     , 'W:xmm/m64, xmm'       , 'mr:     66 0f d6 /r              '      , 'cpuid=sse2'],
  ['movq'     , 'W:xmm, xmm/m64'       , 'rm:     f3 0f 7e /r              '      , 'cpuid=sse2'],
  ['vmovq'    , 'W:xmm/m64, xmm'       , 'mr:     vex.128.66.0f.wig d6 /r  '      , 'cpuid=avx'],
  ['vmovq'    , 'W:xmm, xmm/m64'       , 'rm:     vex.128.f3.0f.wig 7e /r  '      , 'cpuid=avx'],
  ['vmovq'    , 'W:xmm, xmm/m64'       , 'rm:t1s: evex.128.f3.0f.w1 7e /r  '      , 'cpuid=avx512f'],
  ['vmovq'    , 'W:xmm/m64, xmm'       , 'mr:t1s: evex.128.66.0f.w1 d6 /r  '      , 'cpuid=avx512f'],

  # => MOVQ2DQ-Move Quadword from MMX Technology to XMM Register
  ['movq2dq'  , 'W:xmm, mm'          , 'rm: f3 0f d6 /r'                        , 'cpuid=sse2'],

  # => MOVS/MOVSB/MOVSW/MOVSD/MOVSQ-Move Data from String to String
  ['movsw'    , 'W:<[es:*di]>, <[ds:*si]>'       , '     os16 a5              '             , 'rep eflags.df=T'],
  #['movs'     , 'vm, vm'                         , '     os   a5              '             , 'rep eflags.df=T'],
  #['movs'     , 'm8, m8'                         , '          a4              '             , 'rep eflags.df=T'],
  ['movsb'    , 'W:<[es:*di]>, <[ds:*si]>'       , '          a4              '             , 'rep eflags.df=T'],
  ['movsd'    , 'W:<[es:*di]>, <[ds:*si]>'       , '     os32 a5              '             , 'rep eflags.df=T'],
  ['movsq'    , 'W:<[*di]>, <[*si]>'             , 'x64: os64 a5              '             , 'rep eflags.df=T'],

  # => MOVSD-Move or Merge Scalar Double-Precision Floating-Point Value
  ['movsd'    , 'W:xmm, xmm/m64'             , 'rm:     f2 0f 10 /r                  '  , 'cpuid=sse2 eflags.df=T'],
  ['movsd'    , 'W:xmm/m64, xmm'             , 'mr:     f2 0f 11 /r                  '  , 'cpuid=sse2 eflags.df=T'],
  ['vmovsd'   , 'W:m64, xmm'                 , 'mr:     vex.lig.f2.0f.wig 11 /r      '  , 'cpuid=avx'],
  ['vmovsd'   , 'W:xmm, m64'                 , 'rm:     vex.lig.f2.0f.wig 10 /r      '  , 'cpuid=avx'],
  ['vmovsd'   , 'W:xmm, xmm, xmm'            , 'rvm:    vex.nds.lig.f2.0f.wig 10 /r  '  , 'cpuid=avx'],
  ['vmovsd'   , 'W:xmm, xmm, xmm'            , 'mvr:    vex.nds.lig.f2.0f.wig 11 /r  '  , 'cpuid=avx'],
  ['vmovsd'   , 'W:xmm {kz}, xmm, xmm'       , 'rvm:    evex.nds.lig.f2.0f.w1 10 /r  '  , 'cpuid=avx512f'],
  ['vmovsd'   , 'W:xmm {kz}, xmm, xmm'       , 'mvr:    evex.nds.lig.f2.0f.w1 11 /r  '  , 'cpuid=avx512f'],
  ['vmovsd'   , 'W:m64 {k}, xmm'             , 'mr:t1s: evex.lig.f2.0f.w1 11 /r      '  , 'cpuid=avx512f'],
  ['vmovsd'   , 'W:xmm {kz}, m64'            , 'rm:t1s: evex.lig.f2.0f.w1 10 /r      '  , 'cpuid=avx512f'],

  # => MOVSHDUP-Replicate Single FP Values
  ['movshdup'  , 'W:xmm, xmm/m128'            , 'rm:     f3 0f 16 /r              '      , 'cpuid=sse3'],
  ['vmovshdup' , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.f3.0f.wig 16 /r   '      , 'cpuid=avx'],
  ['vmovshdup' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.f3.0f.w0 16 /r   '      , 'cpuid=avx512f-vl'],

  # => MOVSLDUP-Replicate Single FP Values
  ['movsldup'  , 'W:xmm, xmm/m128'            , 'rm:     f3 0f 12 /r              '      , 'cpuid=sse3'],
  ['vmovsldup' , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.f3.0f.wig 12 /r   '      , 'cpuid=avx'],
  ['vmovsldup' , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.f3.0f.w0 12 /r   '      , 'cpuid=avx512f-vl'],

  # => MOVSS-Move or Merge Scalar Single-Precision Floating-Point Value
  ['movss'    , 'W:xmm, xmm/m32'             , 'rm:     f3 0f 10 /r                  '  , 'cpuid=sse'],
  ['movss'    , 'W:xmm/m32, xmm'             , 'mr:     f3 0f 11 /r                  '  , 'cpuid=sse'],
  ['vmovss'   , 'W:m32, xmm'                 , 'mr:     vex.lig.f3.0f.wig 11 /r      '  , 'cpuid=avx'],
  ['vmovss'   , 'W:xmm, m32'                 , 'rm:     vex.lig.f3.0f.wig 10 /r      '  , 'cpuid=avx'],
  ['vmovss'   , 'W:xmm, xmm, xmm'            , 'rvm:    vex.nds.lig.f3.0f.wig 10 /r  '  , 'cpuid=avx'],
  ['vmovss'   , 'W:xmm, xmm, xmm'            , 'mvr:    vex.nds.lig.f3.0f.wig 11 /r  '  , 'cpuid=avx'],
  ['vmovss'   , 'W:xmm {kz}, xmm, xmm'       , 'rvm:    evex.nds.lig.f3.0f.w0 10 /r  '  , 'cpuid=avx512f'],
  ['vmovss'   , 'W:xmm {kz}, xmm, xmm'       , 'mvr:    evex.nds.lig.f3.0f.w0 11 /r  '  , 'cpuid=avx512f'],
  ['vmovss'   , 'W:xmm {kz}, m32'            , 'rm:t1s: evex.lig.f3.0f.w0 10 /r      '  , 'cpuid=avx512f'],
  ['vmovss'   , 'W:m32 {k}, xmm'             , 'mr:t1s: evex.lig.f3.0f.w0 11 /r      '  , 'cpuid=avx512f'],

  # => MOVSX/MOVSXD-Move with Sign-Extension
  ['movsx'    , 'W:r16, r/m8'         , 'rm:     os16 0f be /r        '          , ''],
  ['movsx'    , 'W:r32, r/m8'         , 'rm:     os32 0f be /r        '          , ''],
  ['movsx'    , 'W:r64, r8x/m8'       , 'rm:          0f be /r        '          , ''],
  ['movsx'    , 'W:vr, r16/m16'       , 'rm:     osv  0f bf /r        '          , ''],
  ['movsxd'   , 'W:r64, r/m32'        , 'x64:rm:      rex.w 63 /r     '          , ''],

  # => MOVUPD-Move Unaligned Packed Double-Precision Floating-Point Values
  ['movupd'   , 'W:xmm, xmm/m128'            , 'rm:     66 0f 10 /r              '      , 'cpuid=sse2'],
  ['movupd'   , 'W:xmm/m128, xmm'            , 'mr:     66 0f 11 /r              '      , 'cpuid=sse2'],
  ['vmovupd'  , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.66.0f.wig 10 /r   '      , 'cpuid=avx'],
  ['vmovupd'  , 'W:vmm/vm, vmm'              , 'mr:     vex.vl.66.0f.wig 11 /r   '      , 'cpuid=avx'],
  ['vmovupd'  , 'W:vmm/vm {kz}, vmm'         , 'rm:fvm: evex.vl.66.0f.w1 11 /r   '      , 'cpuid=avx512f-vl'],
  ['vmovupd'  , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.66.0f.w1 10 /r   '      , 'cpuid=avx512f-vl'],

  # => MOVUPS-Move Unaligned Packed Single-Precision Floating-Point Values
  ['movups'   , 'W:xmm/m128, xmm'            , 'mr:     0f 11 /r              '         , 'cpuid=sse'],
  ['movups'   , 'W:xmm, xmm/m128'            , 'rm:     0f 10 /r              '         , 'cpuid=sse'],
  ['vmovups'  , 'W:vmm/vm, vmm'              , 'mr:     vex.vl.0f.wig 11 /r   '         , 'cpuid=avx'],
  ['vmovups'  , 'W:vmm, vmm/vm'              , 'rm:     vex.vl.0f.wig 10 /r   '         , 'cpuid=avx'],
  ['vmovups'  , 'W:vmm/vm {kz}, vmm'         , 'rm:fvm: evex.vl.0f.w0 11 /r   '         , 'cpuid=avx512f-vl'],
  ['vmovups'  , 'W:vmm {kz}, vmm/vm'         , 'rm:fvm: evex.vl.0f.w0 10 /r   '         , 'cpuid=avx512f-vl'],

  # => MOVZX-Move with Zero-Extend
  ['movzx'    , 'W:vr, r16/m16'      , 'rm:     osv  0f b7 /r        '          , ''],
  ['movzx'    , 'W:vr, r8/m8'        , 'rm:     os   0f b6 /r        '          , ''],

  # => MPSADBW-Compute Multiple Packed Sums of Absolute Difference
  ['mpsadbw'  , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 42 /r ib                 ' , 'cpuid=sse4v1'],
  ['vmpsadbw' , 'W:vmm, vmm, vmm/vm, pimm8'         , 'rvmi: vex.nds.vl.66.0f3a.wig 42 /r ib   ' , 'cpuid=avx-2'],

  # => MUL-Unsigned Multiply
  ['mul'      , 'R:r8x/m8, X:<ax>'                , 'm:          f6 /4           '           , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],
  ['mul'      , 'R:vr/vm, X:<*dx>, X:<*ax>'       , 'm:     os   f7 /4           '           , 'eflags.of=M eflags.sf=U eflags.zf=U eflags.af=U eflags.pf=U eflags.cf=M'],

  # => MULPD-Multiply Packed Double-Precision Floating-Point Values
  ['mulpd'    , 'xmm, xmm/m128'                            , 'rm:     66 0f 59 /r                  '  , 'cpuid=sse2'],
  ['vmulpd'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f.wig 59 /r   '  , 'cpuid=avx'],
  ['vmulpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f.w1 59 /r   '  , 'cpuid=avx512f-vl'],

  # => MULPS-Multiply Packed Single-Precision Floating-Point Values
  ['mulps'    , 'xmm, xmm/m128'                            , 'rm:     0f 59 /r                  '     , 'cpuid=sse'],
  ['vmulps'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.0f.wig 59 /r   '     , 'cpuid=avx'],
  ['vmulps'   , 'W:vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.0f.w0 59 /r   '     , 'cpuid=avx512f-vl'],

  # => MULSD-Multiply Scalar Double-Precision Floating-Point Value
  ['mulsd'    , 'xmm, xmm/m64'                        , 'rm:      f2 0f 59 /r                  ' , 'cpuid=sse2'],
  ['vmulsd'   , 'W:xmm, xmm, xmm/m64'                 , 'rvm:     vex.nds.128.f2.0f.wig 59 /r  ' , 'cpuid=avx'],
  ['vmulsd'   , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 59 /r  ' , 'cpuid=avx512f'],

  # => MULSS-Multiply Scalar Single-Precision Floating-Point Values
  ['mulss'    , 'xmm, xmm/m32'                        , 'rm:      f3 0f 59 /r                  ' , 'cpuid=sse'],
  ['vmulss'   , 'W:xmm, xmm, xmm/m32'                 , 'rvm:     vex.nds.128.f3.0f.wig 59 /r  ' , 'cpuid=avx'],
  ['vmulss'   , 'W:xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 59 /r  ' , 'cpuid=avx512f'],

  # => MULX-Unsigned Multiply Without Affecting Flags
  ['mulx'     , 'W:r32, W:r32, r/m32, <edx>'       , 'rvm:     vex.ndd.lz.f2.0f38.w0 f6 /r  ' , 'cpuid=bmi2'],
  ['mulx'     , 'W:r64, W:r64, r/m64, <rdx>'       , 'x64:rvm: vex.ndd.lz.f2.0f38.w1 f6 /r  ' , 'cpuid=bmi2'],

  # => MWAIT-Monitor Wait
  ['mwait'    , ''                   , '0f 01 c9'                               , 'level=0 cpuid=monitor'],

  # => NEG-Two's Complement Negation
  ['neg'      , 'r8x/m8'             , 'm:          f6 /3           '           , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['neg'      , 'vr/vm'              , 'm:     os   f7 /3           '           , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => NOP-No Operation
  ['nop'      , ''                   , '            90              '           , ''],
  ['nop'      , 'R:vr/vm'            , 'm:     os   0f 1f /0        '           , ''],

  # => NOT-One's Complement Negation
  ['not'      , 'vr/vm'              , 'm:     os   f7 /2           '           , 'lock=legacy|hardware|explicit'],
  ['not'      , 'r8x/m8'             , 'm:          f6 /2           '           , 'lock=legacy|hardware|explicit'],

  # => OR-Logical Inclusive OR
  ['or'       , 'al, imm8'           , 'i:           0c ib           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , '*ax, imm.low'       , 'i:      os   0d iz           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'r8x/m8, imm8'       , 'mi:          80 /1 ib        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'vr/vm, vr'          , 'mr:     os   09 /r           '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'r8x, r8x/m8'        , 'rm:          0a /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'vr/vm, imm.low'     , 'mi:     os   81 /1 iz        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'vr, vr/vm'          , 'rm:     os   0b /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'vr/vm, imm8'        , 'mi:     os   83 /1 ib        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['or'       , 'r8x/m8, r8x'        , 'mr:          08 /r           '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],

  # => ORPD-Bitwise Logical OR of Packed Double Precision Floating-Point Values
  ['orpd'     , 'xmm, xmm/m128'                       , 'rm:     66 0f 56 /r                  '  , 'cpuid=sse2'],
  ['vorpd'    , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f 56 /r       '  , 'cpuid=avx'],
  ['vorpd'    , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 56 /r   '  , 'cpuid=avx512dq-vl'],

  # => ORPS-Bitwise Logical OR of Packed Single Precision Floating-Point Values
  ['orps'     , 'xmm, xmm/m128'                       , 'rm:     0f 56 /r                  '     , 'cpuid=sse'],
  ['vorps'    , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.0f 56 /r       '     , 'cpuid=avx'],
  ['vorps'    , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.0f.w0 56 /r   '     , 'cpuid=avx512dq-vl'],

  # => OUT-Output to Port
  ['out'      , 'dx, al'             , '        ee              '               , ''],
  ['out'      , 'dx, *ax'            , '   osz  ef              '               , ''],
  ['out'      , 'pimm8, *ax'         , 'i: osz  e7 ib           '               , ''],
  ['out'      , 'pimm8, al'          , 'i:      e6 ib           '               , ''],

  # => OUTS/OUTSB/OUTSW/OUTSD-Output String to Port
  #['outs'     , 'dx, vm'                   , 'osz  6f              '                  , 'rep eflags.df=T'],
  ['outsd'    , 'R:<dx>, <[ds:*si]>'       , 'os32 6f              '                  , 'rep eflags.df=T'],
  ['outsw'    , 'R:<dx>, <[ds:*si]>'       , 'os16 6f              '                  , 'rep eflags.df=T'],
  ['outsb'    , 'R:<dx>, <[ds:*si]>'       , '     6e              '                  , 'rep eflags.df=T'],
  #['outs'     , 'dx, m8'                   , '     6e              '                  , 'rep eflags.df=T'],

  # => PABSB/PABSW/PABSD/PABSQ-Packed Absolute Value
  ['pabsd'    , 'W:mm, mm/m64'                   , 'rm:     0f 38 1e /r                 '   , 'cpuid=ssse3'],
  ['pabsd'    , 'W:xmm, xmm/m128'                , 'rm:     66 0f 38 1e /r              '   , 'cpuid=ssse3'],
  ['pabsb'    , 'W:mm, mm/m64'                   , 'rm:     0f 38 1c /r                 '   , 'cpuid=ssse3'],
  ['pabsb'    , 'W:xmm, xmm/m128'                , 'rm:     66 0f 38 1c /r              '   , 'cpuid=ssse3'],
  ['pabsw'    , 'W:mm, mm/m64'                   , 'rm:     0f 38 1d /r                 '   , 'cpuid=ssse3'],
  ['pabsw'    , 'W:xmm, xmm/m128'                , 'rm:     66 0f 38 1d /r              '   , 'cpuid=ssse3'],
  ['vpabsw'   , 'W:vmm, vmm/vm'                  , 'rm:     vex.vl.66.0f38.wig 1d /r    '   , 'cpuid=avx-2'],
  ['vpabsd'   , 'W:vmm, vmm/vm'                  , 'rm:     vex.vl.66.0f38.wig 1e /r    '   , 'cpuid=avx-2'],
  ['vpabsb'   , 'W:vmm, vmm/vm'                  , 'rm:     vex.vl.66.0f38.wig 1c /r    '   , 'cpuid=avx-2'],
  ['vpabsd'   , 'W:vmm {kz}, vmm/vm/b32'         , 'rm:fv:  evex.vl.66.0f38.w0 1e /r    '   , 'cpuid=avx512f-vl'],
  ['vpabsq'   , 'W:vmm {kz}, vmm/vm/b64'         , 'rm:fv:  evex.vl.66.0f38.w1 1f /r    '   , 'cpuid=avx512f-vl'],
  ['vpabsb'   , 'W:vmm {kz}, vmm/vm'             , 'rm:fvm: evex.vl.66.0f38.wig 1c /r   '   , 'cpuid=avx512bw-vl'],
  ['vpabsw'   , 'W:vmm {kz}, vmm/vm'             , 'rm:fvm: evex.vl.66.0f38.wig 1d /r   '   , 'cpuid=avx512bw-vl'],

  # => PACKSSWB/PACKSSDW-Pack with Signed Saturation
  ['packssdw'  , 'mm, mm/m64'                          , 'rm:      0f 6b /r                      ' , 'cpuid=mmx'],
  ['packsswb'  , 'mm, mm/m64'                          , 'rm:      0f 63 /r                      ' , 'cpuid=mmx'],
  ['packssdw'  , 'xmm, xmm/m128'                       , 'rm:      66 0f 6b /r                   ' , 'cpuid=sse2'],
  ['packsswb'  , 'xmm, xmm/m128'                       , 'rm:      66 0f 63 /r                   ' , 'cpuid=sse2'],
  ['vpackssdw' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 6b /r    ' , 'cpuid=avx-2'],
  ['vpacksswb' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 63 /r    ' , 'cpuid=avx-2'],
  ['vpackssdw' , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 6b /r    ' , 'cpuid=avx512bw-vl'],
  ['vpacksswb' , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 63 /r   ' , 'cpuid=avx512bw-vl'],

  # => PACKUSDW-Pack with Unsigned Saturation
  ['packusdw'  , 'xmm, xmm/m128'                       , 'rm:     66 0f 38 2b /r                 ' , 'cpuid=sse4v1'],
  ['vpackusdw' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f38 2b /r       ' , 'cpuid=avx-2'],
  ['vpackusdw' , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 2b /r   ' , 'cpuid=avx512bw-vl'],

  # => PACKUSWB-Pack with Unsigned Saturation
  ['packuswb'  , 'mm, mm/m64'                      , 'rm:      0f 67 /r                      ' , 'cpuid=mmx'],
  ['packuswb'  , 'xmm, xmm/m128'                   , 'rm:      66 0f 67 /r                   ' , 'cpuid=sse2'],
  ['vpackuswb' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig 67 /r    ' , 'cpuid=avx-2'],
  ['vpackuswb' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig 67 /r   ' , 'cpuid=avx512bw-vl'],

  # => PADDB/PADDW/PADDD/PADDQ-Add Packed Integers
  ['paddb'    , 'mm, mm/m64'                          , 'rm:      0f fc /r                      ' , 'cpuid=mmx'],
  ['paddw'    , 'mm, mm/m64'                          , 'rm:      0f fd /r                      ' , 'cpuid=mmx'],
  ['paddb'    , 'xmm, xmm/m128'                       , 'rm:      66 0f fc /r                   ' , 'cpuid=sse2'],
  ['paddw'    , 'xmm, xmm/m128'                       , 'rm:      66 0f fd /r                   ' , 'cpuid=sse2'],
  ['paddq'    , 'xmm, xmm/m128'                       , 'rm:      66 0f d4 /r                   ' , 'cpuid=sse2'],
  ['paddd'    , 'xmm, xmm/m128'                       , 'rm:      66 0f fe /r                   ' , 'cpuid=sse2'],
  ['vpaddq'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig d4 /r    ' , 'cpuid=avx-2'],
  ['vpaddw'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig fd /r    ' , 'cpuid=avx-2'],
  ['vpaddd'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig fe /r    ' , 'cpuid=avx-2'],
  ['vpaddb'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig fc /r    ' , 'cpuid=avx-2'],
  ['vpaddq'   , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f.w1 d4 /r    ' , 'cpuid=avx512f-vl'],
  ['vpaddd'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 fe /r    ' , 'cpuid=avx512f-vl'],
  ['vpaddb'   , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig fc /r   ' , 'cpuid=avx512bw-vl'],
  ['vpaddw'   , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig fd /r   ' , 'cpuid=avx512bw-vl'],

  # => PADDSB/PADDSW-Add Packed Signed Integers with Signed Saturation
  ['paddsw'   , 'mm, mm/m64'                      , 'rm:      0f ed /r                      ' , 'cpuid=mmx'],
  ['paddsb'   , 'mm, mm/m64'                      , 'rm:      0f ec /r                      ' , 'cpuid=mmx'],
  ['paddsw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f ed /r                   ' , 'cpuid=sse2'],
  ['paddsb'   , 'xmm, xmm/m128'                   , 'rm:      66 0f ec /r                   ' , 'cpuid=sse2'],
  ['vpaddsw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig ed /r    ' , 'cpuid=avx-2'],
  ['vpaddsb'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig ec /r    ' , 'cpuid=avx-2'],
  ['vpaddsb'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig ec /r   ' , 'cpuid=avx512bw-vl'],
  ['vpaddsw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig ed /r   ' , 'cpuid=avx512bw-vl'],

  # => PADDUSB/PADDUSW-Add Packed Unsigned Integers with Unsigned Saturation
  ['paddusb'  , 'mm, mm/m64'                      , 'rm:      0f dc /r                      ' , 'cpuid=mmx'],
  ['paddusw'  , 'mm, mm/m64'                      , 'rm:      0f dd /r                      ' , 'cpuid=mmx'],
  ['paddusb'  , 'xmm, xmm/m128'                   , 'rm:      66 0f dc /r                   ' , 'cpuid=sse2'],
  ['paddusw'  , 'xmm, xmm/m128'                   , 'rm:      66 0f dd /r                   ' , 'cpuid=sse2'],
  ['vpaddusb' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig dc /r    ' , 'cpuid=avx-2'],
  ['vpaddusw' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig dd /r    ' , 'cpuid=avx-2'],
  ['vpaddusb' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig dc /r   ' , 'cpuid=avx512bw-vl'],
  ['vpaddusw' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig dd /r   ' , 'cpuid=avx512bw-vl'],

  # => PALIGNR-Packed Align Right
  ['palignr'  , 'mm, mm/m64, pimm8'                      , 'rmi:      0f 3a 0f /r ib                     ' , 'cpuid=ssse3'],
  ['palignr'  , 'xmm, xmm/m128, pimm8'                   , 'rmi:      66 0f 3a 0f /r ib                  ' , 'cpuid=ssse3'],
  ['vpalignr' , 'W:vmm, vmm, vmm/vm, pimm8'              , 'rvmi:     vex.nds.vl.66.0f3a.wig 0f /r ib    ' , 'cpuid=avx-2'],
  ['vpalignr' , 'W:vmm {kz}, vmm, vmm/vm, pimm8'         , 'rvmi:fvm: evex.nds.vl.66.0f3a.wig 0f /r ib   ' , 'cpuid=avx512bw-vl'],

  # => PAND-Logical AND
  ['pand'     , 'mm, mm/m64'                          , 'rm:     0f db /r                     '  , 'cpuid=mmx'],
  ['pand'     , 'xmm, xmm/m128'                       , 'rm:     66 0f db /r                  '  , 'cpuid=sse2'],
  ['vpand'    , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig db /r   '  , 'cpuid=avx-2'],
  ['vpandd'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f.w0 db /r   '  , 'cpuid=avx512f-vl'],
  ['vpandq'   , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 db /r   '  , 'cpuid=avx512f-vl'],

  # => PANDN-Logical AND NOT
  ['pandn'    , 'mm, mm/m64'                          , 'rm:     0f df /r                     '  , 'cpuid=mmx'],
  ['pandn'    , 'xmm, xmm/m128'                       , 'rm:     66 0f df /r                  '  , 'cpuid=sse2'],
  ['vpandn'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig df /r   '  , 'cpuid=avx-2'],
  ['vpandnq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 df /r   '  , 'cpuid=avx512f-vl'],
  ['vpandnd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f.w0 df /r   '  , 'cpuid=avx512f-vl'],

  # => PAUSE-Spin Loop Hint
  ['pause'    , ''                   , 'f3 90'                                  , ''],

  # => PAVGB/PAVGW-Average Packed Integers
  ['pavgb'    , 'mm, mm/m64'                      , 'rm:      0f e0 /r                      ' , 'cpuid=sse'],
  ['pavgb'    , 'xmm, xmm/m128'                   , 'rm:      66 0f e0 /r                   ' , 'cpuid=sse2'],
  ['pavgw'    , 'mm, mm/m64'                      , 'rm:      0f e3 /r                      ' , 'cpuid=sse'],
  ['pavgw'    , 'xmm, xmm/m128'                   , 'rm:      66 0f e3 /r                   ' , 'cpuid=sse2'],
  ['vpavgb'   , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig e0 /r    ' , 'cpuid=avx-2'],
  ['vpavgw'   , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig e3 /r    ' , 'cpuid=avx-2'],
  ['vpavgw'   , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig e3 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpavgb'   , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig e0 /r   ' , 'cpuid=avx512bw-vl'],

  # => PBLENDVB-Variable Blend Packed Bytes
  ['pblendvb'  , 'xmm, xmm/m128, <xmm0>'           , 'rm:   66 0f 38 10 /r                    ' , 'cpuid=sse4v1'],
  ['vpblendvb' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 4c /r is4   ' , 'cpuid=avx-2'],

  # => PBLENDW-Blend Packed Words
  ['pblendw'  , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 0e /r ib                 ' , 'cpuid=sse4v1'],
  ['vpblendw' , 'W:vmm, vmm, vmm/vm, pimm8'         , 'rvmi: vex.nds.vl.66.0f3a.wig 0e /r ib   ' , 'cpuid=avx-2'],

  # => PCLMULQDQ-Carry-Less Multiplication Quadword
  ['pclmulqdq'  , 'xmm, xmm/m128, pimm8'              , 'rmi:  66 0f 3a 44 /r ib                 ' , 'cpuid=pclmulqdq'],
  ['vpclmulqdq' , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: vex.nds.128.66.0f3a.wig 44 /r ib  ' , 'cpuid=pclmulqdq|avx'],

  # => PCMPEQB/PCMPEQW/PCMPEQD-Compare Packed Data for Equal
  ['pcmpeqw'  , 'mm, mm/m64'                       , 'rm:      0f 75 /r                      ' , 'cpuid=mmx'],
  ['pcmpeqb'  , 'mm, mm/m64'                       , 'rm:      0f 74 /r                      ' , 'cpuid=mmx'],
  ['pcmpeqd'  , 'mm, mm/m64'                       , 'rm:      0f 76 /r                      ' , 'cpuid=mmx'],
  ['pcmpeqw'  , 'xmm, xmm/m128'                    , 'rm:      66 0f 75 /r                   ' , 'cpuid=sse2'],
  ['pcmpeqb'  , 'xmm, xmm/m128'                    , 'rm:      66 0f 74 /r                   ' , 'cpuid=sse2'],
  ['pcmpeqd'  , 'xmm, xmm/m128'                    , 'rm:      66 0f 76 /r                   ' , 'cpuid=sse2'],
  ['vpcmpeqb' , 'W:vmm, vmm, vmm/vm'               , 'rvm:     vex.nds.vl.66.0f.wig 74 /r    ' , 'cpuid=avx-2'],
  ['vpcmpeqw' , 'W:vmm, vmm, vmm/vm'               , 'rvm:     vex.nds.vl.66.0f.wig 75 /r    ' , 'cpuid=avx-2'],
  ['vpcmpeqd' , 'W:vmm, vmm, vmm/vm'               , 'rvm:     vex.nds.vl.66.0f.wig 76 /r    ' , 'cpuid=avx-2'],
  ['vpcmpeqd' , 'W:k {k}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 76 /r    ' , 'cpuid=avx512f-vl'],
  ['vpcmpeqw' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 75 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpcmpeqb' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 74 /r   ' , 'cpuid=avx512bw-vl'],

  # => PCMPEQQ-Compare Packed Qword Data for Equal
  ['pcmpeqq'  , 'xmm, xmm/m128'                    , 'rm:     66 0f 38 29 /r                 ' , 'cpuid=sse4v1'],
  ['vpcmpeqq' , 'W:vmm, vmm, vmm/vm'               , 'rvm:    vex.nds.vl.66.0f38.wig 29 /r   ' , 'cpuid=avx-2'],
  ['vpcmpeqq' , 'W:k {k}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 29 /r   ' , 'cpuid=avx512f-vl'],

  # => PCMPESTRI-Packed Compare Explicit Length Strings, Return Index
  ['pcmpestri'  , 'R:xmm, xmm/m128, pimm8, W:<ecx>'       , 'rmi: 66 0f 3a 61 /r ib         '        , 'cpuid=sse4v2'],
  ['vpcmpestri' , 'R:xmm, xmm/m128, pimm8, W:<ecx>'       , 'rmi: vex.128.66.0f3a 61 /r ib  '        , 'cpuid=avx'],

  # => PCMPESTRM-Packed Compare Explicit Length Strings, Return Mask
  ['pcmpestrm'  , 'R:xmm, xmm/m128, pimm8, W:<xmm0>'       , 'rmi: 66 0f 3a 60 /r ib         '        , 'cpuid=sse4v2'],
  ['vpcmpestrm' , 'R:xmm, xmm/m128, pimm8, W:<xmm0>'       , 'rmi: vex.128.66.0f3a 60 /r ib  '        , 'cpuid=avx'],

  # => PCMPGTB/PCMPGTW/PCMPGTD-Compare Packed Signed Integers for Greater Than
  ['pcmpgtd'  , 'mm, mm/m64'                       , 'rm:      0f 66 /r                      ' , 'cpuid=mmx'],
  ['pcmpgtw'  , 'mm, mm/m64'                       , 'rm:      0f 65 /r                      ' , 'cpuid=mmx'],
  ['pcmpgtb'  , 'mm, mm/m64'                       , 'rm:      0f 64 /r                      ' , 'cpuid=mmx'],
  ['pcmpgtd'  , 'xmm, xmm/m128'                    , 'rm:      66 0f 66 /r                   ' , 'cpuid=sse2'],
  ['pcmpgtw'  , 'xmm, xmm/m128'                    , 'rm:      66 0f 65 /r                   ' , 'cpuid=sse2'],
  ['pcmpgtb'  , 'xmm, xmm/m128'                    , 'rm:      66 0f 64 /r                   ' , 'cpuid=sse2'],
  ['vpcmpgtw' , 'W:vmm, vmm, vmm/vm'               , 'rvm:     vex.nds.vl.66.0f.wig 65 /r    ' , 'cpuid=avx-2'],
  ['vpcmpgtb' , 'W:vmm, vmm, vmm/vm'               , 'rvm:     vex.nds.vl.66.0f.wig 64 /r    ' , 'cpuid=avx-2'],
  ['vpcmpgtd' , 'W:vmm, vmm, vmm/vm'               , 'rvm:     vex.nds.vl.66.0f.wig 66 /r    ' , 'cpuid=avx-2'],
  ['vpcmpgtd' , 'W:k {k}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 66 /r    ' , 'cpuid=avx512f-vl'],
  ['vpcmpgtb' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 64 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpcmpgtw' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 65 /r   ' , 'cpuid=avx512bw-vl'],

  # => PCMPGTQ-Compare Packed Data for Greater Than
  ['pcmpgtq'  , 'xmm, xmm/m128'                    , 'rm:     66 0f 38 37 /r                 ' , 'cpuid=sse4v2'],
  ['vpcmpgtq' , 'W:vmm, vmm, vmm/vm'               , 'rvm:    vex.nds.vl.66.0f38.wig 37 /r   ' , 'cpuid=avx-2'],
  ['vpcmpgtq' , 'W:k {k}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 37 /r   ' , 'cpuid=avx512f-vl'],

  # => PCMPISTRI-Packed Compare Implicit Length Strings, Return Index
  ['pcmpistri'  , 'R:xmm, xmm/m128, pimm8, W:<ecx>'       , 'rmi: 66 0f 3a 63 /r ib             '    , 'cpuid=sse4v2'],
  ['vpcmpistri' , 'R:xmm, xmm/m128, pimm8, W:<ecx>'       , 'rmi: vex.128.66.0f3a.wig 63 /r ib  '    , 'cpuid=avx'],

  # => PCMPISTRM-Packed Compare Implicit Length Strings, Return Mask
  ['pcmpistrm'  , 'R:xmm, xmm/m128, pimm8, W:<xmm0>'       , 'rmi: 66 0f 3a 62 /r ib             '    , 'cpuid=sse4v2'],
  ['vpcmpistrm' , 'R:xmm, xmm/m128, pimm8, W:<xmm0>'       , 'rmi: vex.128.66.0f3a.wig 62 /r ib  '    , 'cpuid=avx'],

  # => PDEP-Parallel Bits Deposit
  ['pdep'     , 'W:r32, r32, r/m32'       , 'rvm:     vex.nds.lz.f2.0f38.w0 f5 /r  ' , 'cpuid=bmi2'],
  ['pdep'     , 'W:r64, r64, r/m64'       , 'x64:rvm: vex.nds.lz.f2.0f38.w1 f5 /r  ' , 'cpuid=bmi2'],

  # => PEXT-Parallel Bits Extract
  ['pext'     , 'W:r32, r32, r/m32'       , 'rvm:     vex.nds.lz.f3.0f38.w0 f5 /r  ' , 'cpuid=bmi2'],
  ['pext'     , 'W:r64, r64, r/m64'       , 'x64:rvm: vex.nds.lz.f3.0f38.w1 f5 /r  ' , 'cpuid=bmi2'],

  # => PEXTRB/PEXTRD/PEXTRQ-Extract Byte/Dword/Qword
  ['pextrd'   , 'W:r/m32, xmm, pimm8'       , 'mri:         66 0f 3a 16 /r ib              ' , 'cpuid=sse4v1'],
  ['pextrb'   , 'W:r/m8, xmm, pimm8'        , 'mri:         66 0f 3a 14 /r ib              ' , 'cpuid=sse4v1'],
  ['pextrq'   , 'W:r/m64, xmm, pimm8'       , 'x64:mri:     66 rex.w 0f 3a 16 /r ib        ' , 'cpuid=sse4v1'],
  ['vpextrb'  , 'W:r/m8, xmm, pimm8'        , 'mri:         vex.128.66.0f3a.w0 14 /r ib    ' , 'cpuid=avx'],
  ['vpextrd'  , 'W:r/m32, xmm, pimm8'       , 'mri:         vex.128.66.0f3a.w0 16 /r ib    ' , 'cpuid=avx'],
  ['vpextrq'  , 'W:r/m64, xmm, pimm8'       , 'x64:mri:     vex.128.66.0f3a.w1 16 /r ib    ' , 'cpuid=avx'],
  ['vpextrd'  , 'W:r/m32, xmm, pimm8'       , 'mri:t1s:     evex.128.66.0f3a.w0 16 /r ib   ' , 'cpuid=avx512dq'],
  ['vpextrb'  , 'W:r/m8, xmm, pimm8'        , 'mri:t1s:     evex.128.66.0f3a.wig 14 /r ib  ' , 'cpuid=avx512bw'],
  ['vpextrq'  , 'W:r/m64, xmm, pimm8'       , 'x64:mri:t1s: evex.128.66.0f3a.w1 16 /r ib   ' , 'cpuid=avx512dq'],

  # => PEXTRW-Extract Word
  ['pextrw'   , 'W:reg, mm, pimm8'          , 'rmi:     0f c5 /r ib                    ' , 'cpuid=sse'],
  ['pextrw'   , 'W:reg, xmm, pimm8'         , 'rmi:     66 0f c5 /r ib                 ' , 'cpuid=sse2'],
  ['pextrw'   , 'W:r/m16, xmm, pimm8'       , 'mri:     66 0f 3a 15 /r ib              ' , 'cpuid=sse4v1'],
  ['vpextrw'  , 'W:reg, xmm, pimm8'         , 'rmi:     vex.128.66.0f.w0 c5 /r ib      ' , 'cpuid=avx'],
  ['vpextrw'  , 'W:r/m16, xmm, pimm8'       , 'mri:     vex.128.66.0f3a.w0 15 /r ib    ' , 'cpuid=avx'],
  ['vpextrw'  , 'W:reg, xmm, pimm8'         , 'rmi:     evex.128.66.0f.wig c5 /r ib    ' , 'cpuid=avx512bw'],
  ['vpextrw'  , 'W:r/m16, xmm, pimm8'       , 'mri:fvm: evex.128.66.0f3a.wig 15 /r ib  ' , 'cpuid=avx512bw'],

  # => PHADDW/PHADDD-Packed Horizontal Add
  ['phaddw'   , 'mm, mm/m64'                 , 'rm:  0f 38 01 /r                    '   , 'cpuid=ssse3'],
  ['phaddw'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 01 /r                 '   , 'cpuid=ssse3'],
  ['phaddd'   , 'mm, mm/m64'                 , 'rm:  0f 38 02 /r                    '   , 'cpuid=ssse3'],
  ['phaddd'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 02 /r                 '   , 'cpuid=ssse3'],
  ['vphaddd'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 02 /r   '   , 'cpuid=avx-2'],
  ['vphaddw'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 01 /r   '   , 'cpuid=avx-2'],

  # => PHADDSW-Packed Horizontal Add and Saturate
  ['phaddsw'  , 'mm, mm/m64'                 , 'rm:  0f 38 03 /r                    '   , 'cpuid=ssse3'],
  ['phaddsw'  , 'xmm, xmm/m128'              , 'rm:  66 0f 38 03 /r                 '   , 'cpuid=ssse3'],
  ['vphaddsw' , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 03 /r   '   , 'cpuid=avx-2'],

  # => PHMINPOSUW-Packed Horizontal Word Minimum
  ['phminposuw'  , 'W:xmm, xmm/m128'       , 'rm: 66 0f 38 41 /r             '        , 'cpuid=sse4v1'],
  ['vphminposuw' , 'W:xmm, xmm/m128'       , 'rm: vex.128.66.0f38.wig 41 /r  '        , 'cpuid=avx'],

  # => PHSUBW/PHSUBD-Packed Horizontal Subtract
  ['phsubd'   , 'mm, mm/m64'               , 'rm:  0f 38 06 /r                    '   , 'cpuid=ssse3'],
  ['phsubd'   , 'xmm, xmm/m128'            , 'rm:  66 0f 38 06 /r                 '   , 'cpuid=ssse3'],
  ['phsubw'   , 'mm, mm/m64'               , 'rm:  0f 38 05 /r                    '   , 'cpuid=ssse3'],
  ['phsubw'   , 'xmm, xmm/m128'            , 'rm:  66 0f 38 05 /r                 '   , 'cpuid=ssse3'],
  ['vphsubd'  , 'vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 06 /r   '   , 'cpuid=avx-2'],
  ['vphsubw'  , 'vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 05 /r   '   , 'cpuid=avx-2'],

  # => PHSUBSW-Packed Horizontal Subtract and Saturate
  ['phsubsw'  , 'mm, mm/m64'               , 'rm:  0f 38 07 /r                    '   , 'cpuid=ssse3'],
  ['phsubsw'  , 'xmm, xmm/m128'            , 'rm:  66 0f 38 07 /r                 '   , 'cpuid=ssse3'],
  ['vphsubsw' , 'vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 07 /r   '   , 'cpuid=avx-2'],

  # => PINSRB/PINSRD/PINSRQ-Insert Byte/Dword/Qword
  ['pinsrb'   , 'W:xmm, r32/m8, pimm8'            , 'rmi:          66 0f 3a 20 /r ib                  ' , 'cpuid=sse4v1'],
  ['pinsrd'   , 'W:xmm, r/m32, pimm8'             , 'rmi:          66 0f 3a 22 /r ib                  ' , 'cpuid=sse4v1'],
  ['pinsrq'   , 'W:xmm, r/m64, pimm8'             , 'x64:rmi:      66 rex.w 0f 3a 22 /r ib            ' , 'cpuid=sse4v1'],
  ['vpinsrb'  , 'W:xmm, xmm, r32/m8, pimm8'       , 'rvmi:         vex.nds.128.66.0f3a.w0 20 /r ib    ' , 'cpuid=avx'],
  ['vpinsrd'  , 'W:xmm, xmm, r/m32, pimm8'        , 'rvmi:         vex.nds.128.66.0f3a.w0 22 /r ib    ' , 'cpuid=avx'],
  ['vpinsrq'  , 'W:xmm, xmm, r/m64, pimm8'        , 'x64:rvmi:     vex.nds.128.66.0f3a.w1 22 /r ib    ' , 'cpuid=avx'],
  ['vpinsrd'  , 'W:xmm, xmm, r/m32, pimm8'        , 'rvmi:fvm:     evex.nds.128.66.0f3a.w0 22 /r ib   ' , 'cpuid=avx512dq'],
  ['vpinsrb'  , 'W:xmm, xmm, r32/m8, pimm8'       , 'rvmi:fvm:     evex.nds.128.66.0f3a.wig 20 /r ib  ' , 'cpuid=avx512bw'],
  ['vpinsrq'  , 'W:xmm, xmm, r/m64, pimm8'        , 'x64:rvmi:fvm: evex.nds.128.66.0f3a.w1 22 /r ib   ' , 'cpuid=avx512dq'],

  # => PINSRW-Insert Word
  ['pinsrw'   , 'W:mm, r32/m16, pimm8'             , 'rmi:      0f c4 /r ib                      ' , 'cpuid=sse'],
  ['pinsrw'   , 'W:xmm, r32/m16, pimm8'            , 'rmi:      66 0f c4 /r ib                   ' , 'cpuid=sse2'],
  ['vpinsrw'  , 'W:xmm, xmm, r32/m16, pimm8'       , 'rvmi:     vex.nds.128.66.0f.w0 c4 /r ib    ' , 'cpuid=avx'],
  ['vpinsrw'  , 'W:xmm, xmm, r32/m16, pimm8'       , 'rvmi:fvm: evex.nds.128.66.0f.wig c4 /r ib  ' , 'cpuid=avx512bw'],

  # => PMADDUBSW-Multiply and Add Packed Signed and Unsigned Bytes
  ['pmaddubsw'  , 'mm, mm/m64'                      , 'rm:      0f 38 04 /r                     ' , 'cpuid=ssse3'],
  ['pmaddubsw'  , 'xmm, xmm/m128'                   , 'rm:      66 0f 38 04 /r                  ' , 'cpuid=ssse3'],
  ['vpmaddubsw' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f38.wig 04 /r    ' , 'cpuid=avx-2'],
  ['vpmaddubsw' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.wig 04 /r   ' , 'cpuid=avx512bw-vl'],

  # => PMADDWD-Multiply and Add Packed Integers
  ['pmaddwd'  , 'mm, mm/m64'                      , 'rm:      0f f5 /r                      ' , 'cpuid=mmx'],
  ['pmaddwd'  , 'xmm, xmm/m128'                   , 'rm:      66 0f f5 /r                   ' , 'cpuid=sse2'],
  ['vpmaddwd' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig f5 /r    ' , 'cpuid=avx-2'],
  ['vpmaddwd' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig f5 /r   ' , 'cpuid=avx512bw-vl'],

  # => PMAXSB/PMAXSW/PMAXSD/PMAXSQ-Maximum of Packed Signed Integers
  ['pmaxsw'   , 'mm, mm/m64'                          , 'rm:      0f ee /r                        ' , 'cpuid=sse'],
  ['pmaxsw'   , 'xmm, xmm/m128'                       , 'rm:      66 0f ee /r                     ' , 'cpuid=sse2'],
  ['pmaxsd'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 38 3d /r                  ' , 'cpuid=sse4v1'],
  ['pmaxsb'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 38 3c /r                  ' , 'cpuid=sse4v1'],
  ['vpmaxsw'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig ee /r      ' , 'cpuid=avx-2'],
  ['vpmaxsb'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.wig 3c /r    ' , 'cpuid=avx-2'],
  ['vpmaxsd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.wig 3d /r    ' , 'cpuid=avx-2'],
  ['vpmaxsd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f38.w0 3d /r    ' , 'cpuid=avx512f-vl'],
  ['vpmaxsq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f38.w1 3d /r    ' , 'cpuid=avx512f-vl'],
  ['vpmaxsb'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.wig 3c /r   ' , 'cpuid=avx512bw-vl'],
  ['vpmaxsw'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig ee /r     ' , 'cpuid=avx512bw-vl'],

  # => PMAXUB/PMAXUW-Maximum of Packed Unsigned Integers
  ['pmaxub'   , 'mm, mm/m64'                      , 'rm:      0f de /r                        ' , 'cpuid=sse'],
  ['pmaxub'   , 'xmm, xmm/m128'                   , 'rm:      66 0f de /r                     ' , 'cpuid=sse2'],
  ['pmaxuw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f 38 3e /r                  ' , 'cpuid=sse4v1'],
  ['vpmaxuw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f38 3e /r        ' , 'cpuid=avx-2'],
  ['vpmaxub'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f de /r          ' , 'cpuid=avx-2'],
  ['vpmaxub'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig de /r     ' , 'cpuid=avx512bw-vl'],
  ['vpmaxuw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.wig 3e /r   ' , 'cpuid=avx512bw-vl'],

  # => PMAXUD/PMAXUQ-Maximum of Packed Unsigned Integers
  ['pmaxud'   , 'xmm, xmm/m128'                       , 'rm:     66 0f 38 3f /r                 ' , 'cpuid=sse4v1'],
  ['vpmaxud'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f38.wig 3f /r   ' , 'cpuid=avx-2'],
  ['vpmaxuq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 3f /r   ' , 'cpuid=avx512f-vl'],
  ['vpmaxud'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 3f /r   ' , 'cpuid=avx512f-vl'],

  # => PMINSB/PMINSW-Minimum of Packed Signed Integers
  ['pminsw'   , 'mm, mm/m64'                      , 'rm:      0f ea /r                        ' , 'cpuid=sse'],
  ['pminsw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f ea /r                     ' , 'cpuid=sse2'],
  ['pminsb'   , 'xmm, xmm/m128'                   , 'rm:      66 0f 38 38 /r                  ' , 'cpuid=sse4v1'],
  ['vpminsb'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f38 38 /r        ' , 'cpuid=avx-2'],
  ['vpminsw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f ea /r          ' , 'cpuid=avx-2'],
  ['vpminsb'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.wig 38 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpminsw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig ea /r     ' , 'cpuid=avx512bw-vl'],

  # => PMINSD/PMINSQ-Minimum of Packed Signed Integers
  ['pminsd'   , 'xmm, xmm/m128'                       , 'rm:     66 0f 38 39 /r                 ' , 'cpuid=sse4v1'],
  ['vpminsd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f38.wig 39 /r   ' , 'cpuid=avx-2'],
  ['vpminsq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 39 /r   ' , 'cpuid=avx512f-vl'],
  ['vpminsd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 39 /r   ' , 'cpuid=avx512f-vl'],

  # => PMINUB/PMINUW-Minimum of Packed Unsigned Integers
  ['pminub'   , 'mm, mm/m64'                      , 'rm:      0f da /r                    '  , 'cpuid=sse'],
  ['pminub'   , 'xmm, xmm/m128'                   , 'rm:      66 0f da /r                 '  , 'cpuid=sse2'],
  ['pminuw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f 38 3a /r              '  , 'cpuid=sse4v1'],
  ['vpminuw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f38 3a /r    '  , 'cpuid=avx-2'],
  ['vpminub'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f da /r      '  , 'cpuid=avx-2'],
  ['vpminub'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f da /r     '  , 'cpuid=avx512bw-vl'],
  ['vpminuw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38 3a /r   '  , 'cpuid=avx512bw-vl'],

  # => PMINUD/PMINUQ-Minimum of Packed Unsigned Integers
  ['pminud'   , 'xmm, xmm/m128'                       , 'rm:     66 0f 38 3b /r                 ' , 'cpuid=sse4v1'],
  ['vpminud'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f38.wig 3b /r   ' , 'cpuid=avx-2'],
  ['vpminud'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 3b /r   ' , 'cpuid=avx512f-vl'],
  ['vpminuq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 3b /r   ' , 'cpuid=avx512f-vl'],

  # => PMOVMSKB-Move Byte Mask
  ['pmovmskb'  , 'W:reg, mm'          , 'rm: 0f d7 /r                 '          , 'cpuid=sse'],
  ['pmovmskb'  , 'W:reg, xmm'         , 'rm: 66 0f d7 /r              '          , 'cpuid=sse2'],
  ['vpmovmskb' , 'W:reg, vmm'         , 'rm: vex.vl.66.0f.wig d7 /r   '          , 'cpuid=avx-2'],

  # => PMOVSX-Packed Move with Sign Extend
  ['pmovsxwd'  , 'W:xmm, xmm/m64'             , 'rm:     66 0f 38 23 /r              '   , 'cpuid=sse4v1'],
  ['pmovsxbd'  , 'W:xmm, xmm/m32'             , 'rm:     66 0f 38 21 /r              '   , 'cpuid=sse4v1'],
  ['pmovsxbq'  , 'W:xmm, xmm/m16'             , 'rm:     66 0f 38 22 /r              '   , 'cpuid=sse4v1'],
  ['pmovsxdq'  , 'W:xmm, xmm/m64'             , 'rm:     66 0f 38 25 /r              '   , 'cpuid=sse4v1'],
  ['pmovsxbw'  , 'W:xmm, xmm/m64'             , 'rm:     66 0f 38 20 /r              '   , 'cpuid=sse4v1'],
  ['pmovsxwq'  , 'W:xmm, xmm/m32'             , 'rm:     66 0f 38 24 /r              '   , 'cpuid=sse4v1'],
  ['vpmovsxdq' , 'W:vmm, xmm/vm.2'            , 'rm:     vex.vl.66.0f38.wig 25 /r    '   , 'cpuid=avx-2'],
  ['vpmovsxbw' , 'W:vmm, xmm/vm.2'            , 'rm:     vex.vl.66.0f38.wig 20 /r    '   , 'cpuid=avx-2'],
  ['vpmovsxbd' , 'W:vmm, xmm/vm.4'            , 'rm:     vex.vl.66.0f38.wig 21 /r    '   , 'cpuid=avx-2'],
  ['vpmovsxwq' , 'W:vmm, xmm/vm.4'            , 'rm:     vex.vl.66.0f38.wig 24 /r    '   , 'cpuid=avx-2'],
  ['vpmovsxwd' , 'W:vmm, xmm/vm.2'            , 'rm:     vex.vl.66.0f38.wig 23 /r    '   , 'cpuid=avx-2'],
  ['vpmovsxbq' , 'W:vmm, xmm/vm.8'            , 'rm:     vex.vl.66.0f38.wig 22 /r    '   , 'cpuid=avx-2'],
  ['vpmovsxbw' , 'W:vmm {kz}, vmm.low/vm.2'   , 'rm:hvm: evex.vl.66.0f38.wig 20 /r   '   , 'cpuid=avx512bw-vl'],
  ['vpmovsxbd' , 'W:vmm {kz}, xmm/vm.4'       , 'rm:qvm: evex.vl.66.0f38.wig 21 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovsxdq' , 'W:vmm {kz}, vmm.low/vm.2'   , 'rm:hvm: evex.vl.66.0f38.w0 25 /r    '   , 'cpuid=avx512f-vl'],
  ['vpmovsxbq' , 'W:vmm {kz}, xmm/vm.8'       , 'rm:ovm: evex.vl.66.0f38.wig 22 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovsxwd' , 'W:vmm {kz}, vmm.low/vm.2'   , 'rm:hvm: evex.vl.66.0f38.wig 23 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovsxwq' , 'W:vmm {kz}, xmm/vm.4'       , 'rm:qvm: evex.vl.66.0f38.wig 24 /r   '   , 'cpuid=avx512f-vl'],

  # => PMOVZX-Packed Move with Zero Extend
  ['pmovzxwd'  , 'W:xmm, xmm/m64'             , 'rm:     66 0f 38 33 /r              '   , 'cpuid=sse4v1'],
  ['pmovzxbw'  , 'W:xmm, xmm/m64'             , 'rm:     66 0f 38 30 /r              '   , 'cpuid=sse4v1'],
  ['pmovzxbq'  , 'W:xmm, xmm/m16'             , 'rm:     66 0f 38 32 /r              '   , 'cpuid=sse4v1'],
  ['pmovzxbd'  , 'W:xmm, xmm/m32'             , 'rm:     66 0f 38 31 /r              '   , 'cpuid=sse4v1'],
  ['pmovzxwq'  , 'W:xmm, xmm/m32'             , 'rm:     66 0f 38 34 /r              '   , 'cpuid=sse4v1'],
  ['pmovzxdq'  , 'W:xmm, xmm/m64'             , 'rm:     66 0f 38 35 /r              '   , 'cpuid=sse4v1'],
  ['vpmovzxbd' , 'W:vmm, xmm/vm.4'            , 'rm:     vex.vl.66.0f38.wig 31 /r    '   , 'cpuid=avx-2'],
  ['vpmovzxbq' , 'W:vmm, xmm/vm.8'            , 'rm:     vex.vl.66.0f38.wig 32 /r    '   , 'cpuid=avx-2'],
  ['vpmovzxbw' , 'W:vmm, xmm/vm.2'            , 'rm:     vex.vl.66.0f38.wig 30 /r    '   , 'cpuid=avx-2'],
  ['vpmovzxwd' , 'W:vmm, xmm/vm.2'            , 'rm:     vex.vl.66.0f38.wig 33 /r    '   , 'cpuid=avx-2'],
  ['vpmovzxwq' , 'W:vmm, xmm/vm.4'            , 'rm:     vex.vl.66.0f38.wig 34 /r    '   , 'cpuid=avx-2'],
  ['vpmovzxdq' , 'W:vmm, xmm/vm.2'            , 'rm:     vex.vl.66.0f38.wig 35 /r    '   , 'cpuid=avx-2'],
  ['vpmovzxwq' , 'W:vmm {kz}, xmm/vm.4'       , 'rm:qvm: evex.vl.66.0f38.wig 34 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovzxwd' , 'W:vmm {kz}, vmm.low/vm.2'   , 'rm:hvm: evex.vl.66.0f38.wig 33 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovzxbq' , 'W:vmm {kz}, xmm/vm.8'       , 'rm:ovm: evex.vl.66.0f38.wig 32 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovzxbd' , 'W:vmm {kz}, xmm/vm.4'       , 'rm:qvm: evex.vl.66.0f38.wig 31 /r   '   , 'cpuid=avx512f-vl'],
  ['vpmovzxdq' , 'W:vmm {kz}, vmm.low/vm.2'   , 'rm:hvm: evex.vl.66.0f38.w0 35 /r    '   , 'cpuid=avx512f-vl'],
  ['vpmovzxbw' , 'W:vmm {kz}, vmm.low/vm.2'   , 'rm:hvm: evex.vl.66.0f38.wig 30 /r   '   , 'cpuid=avx512bw-vl'],

  # => PMULDQ-Multiply Packed Doubleword Integers
  ['pmuldq'   , 'xmm, xmm/m128'                       , 'rm:     66 0f 38 28 /r                 ' , 'cpuid=sse4v1'],
  ['vpmuldq'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f38.wig 28 /r   ' , 'cpuid=avx-2'],
  ['vpmuldq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 28 /r   ' , 'cpuid=avx512f-vl'],

  # => PMULHRSW-Packed Multiply High with Round and Scale
  ['pmulhrsw'  , 'mm, mm/m64'                      , 'rm:      0f 38 0b /r                     ' , 'cpuid=ssse3'],
  ['pmulhrsw'  , 'xmm, xmm/m128'                   , 'rm:      66 0f 38 0b /r                  ' , 'cpuid=ssse3'],
  ['vpmulhrsw' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f38.wig 0b /r    ' , 'cpuid=avx-2'],
  ['vpmulhrsw' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.wig 0b /r   ' , 'cpuid=avx512bw-vl'],

  # => PMULHUW-Multiply Packed Unsigned Integers and Store High Result
  ['pmulhuw'  , 'mm, mm/m64'                      , 'rm:      0f e4 /r                      ' , 'cpuid=sse'],
  ['pmulhuw'  , 'xmm, xmm/m128'                   , 'rm:      66 0f e4 /r                   ' , 'cpuid=sse2'],
  ['vpmulhuw' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig e4 /r    ' , 'cpuid=avx-2'],
  ['vpmulhuw' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig e4 /r   ' , 'cpuid=avx512bw-vl'],

  # => PMULHW-Multiply Packed Signed Integers and Store High Result
  ['pmulhw'   , 'mm, mm/m64'                      , 'rm:      0f e5 /r                      ' , 'cpuid=mmx'],
  ['pmulhw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f e5 /r                   ' , 'cpuid=sse2'],
  ['vpmulhw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig e5 /r    ' , 'cpuid=avx-2'],
  ['vpmulhw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig e5 /r   ' , 'cpuid=avx512bw-vl'],

  # => PMULLD/PMULLQ-Multiply Packed Integers and Store Low Result
  ['pmulld'   , 'xmm, xmm/m128'                       , 'rm:     66 0f 38 40 /r                 ' , 'cpuid=sse4v1'],
  ['vpmulld'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f38.wig 40 /r   ' , 'cpuid=avx-2'],
  ['vpmulld'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 40 /r   ' , 'cpuid=avx512f-vl'],
  ['vpmullq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 40 /r   ' , 'cpuid=avx512dq-vl'],

  # => PMULLW-Multiply Packed Signed Integers and Store Low Result
  ['pmullw'   , 'mm, mm/m64'                      , 'rm:      0f d5 /r                      ' , 'cpuid=mmx'],
  ['pmullw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f d5 /r                   ' , 'cpuid=sse2'],
  ['vpmullw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig d5 /r    ' , 'cpuid=avx-2'],
  ['vpmullw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig d5 /r   ' , 'cpuid=avx512bw-vl'],

  # => PMULUDQ-Multiply Packed Unsigned Doubleword Integers
  ['pmuludq'  , 'mm, mm/m64'                          , 'rm:     0f f4 /r                     '  , 'cpuid=sse2'],
  ['pmuludq'  , 'xmm, xmm/m128'                       , 'rm:     66 0f f4 /r                  '  , 'cpuid=sse2'],
  ['vpmuludq' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig f4 /r   '  , 'cpuid=avx-2'],
  ['vpmuludq' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 f4 /r   '  , 'cpuid=avx512f-vl'],

  # => POP-Pop a Value from the Stack
  ['pop'      , 'W:gs'               , '       os   0f a9           '           , ''],
  ['pop'      , 'W:fs'               , '       os   0f a1           '           , ''],
  ['pop'      , 'W:vr'               , 'o:     os   58+r            '           , ''],
  ['pop'      , 'W:vr/vm'            , 'm:     os   8f /0           '           , ''],
  ['pop'      , 'W:ss'               , 'x86:        17              '           , ''],
  ['pop'      , 'W:ds'               , 'x86:        1f              '           , ''],
  ['pop'      , 'W:es'               , 'x86:        07              '           , ''],

  # => POPA/POPAD-Pop All General-Purpose Registers
  ['popad'    , 'W:<edi>, W:<esi>, W:<ebp>, W:<ebx>, W:<edx>, W:<ecx>, W:<eax>'       , 'x86:      61              '             , 'deprecated'],
  ['popa'     , 'W:<di>, W:<si>, W:<bp>, W:<bx>, W:<dx>, W:<cx>, W:<ax>'              , 'x86: os16 61              '             , 'deprecated'],

  # => POPCNT-Return the Count of Number of Bits Set to 1
  ['popcnt'   , 'W:vr, vr/vm'        , 'rm:     os   f3 0f b8 /r     '          , 'cpuid=popcnt eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=C'],

  # => POPF/POPFD/POPFQ-Pop Stack into EFLAGS Register
  ['popf'     , ''                   , '     os16 9d              '             , 'eflags.of=P eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P eflags.tf=P eflags.if=P eflags.df=P eflags.nt=P'],
  ['popfd'    , ''                   , 'x86:      9d              '             , 'eflags.of=P eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P eflags.tf=P eflags.if=P eflags.df=P eflags.nt=P'],
  ['popfq'    , ''                   , 'x64:      9d              '             , 'eflags.of=P eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P eflags.tf=P eflags.if=P eflags.df=P eflags.nt=P'],

  # => POR-Bitwise Logical OR
  ['por'      , 'mm, mm/m64'                          , 'rm:     0f eb /r                     '  , 'cpuid=mmx'],
  ['por'      , 'xmm, xmm/m128'                       , 'rm:     66 0f eb /r                  '  , 'cpuid=sse2'],
  ['vpor'     , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig eb /r   '  , 'cpuid=avx-2'],
  ['vpord'    , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f.w0 eb /r   '  , 'cpuid=avx512f-vl'],
  ['vporq'    , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 eb /r   '  , 'cpuid=avx512f-vl'],

  # => PREFETCHh-Prefetch Data Into Caches
  ['prefetcht1'  , 'R:m8'               , 'm: 0f 18 /2        '                    , ''],
  ['prefetcht2'  , 'R:m8'               , 'm: 0f 18 /3        '                    , ''],
  ['prefetchnta' , 'R:m8'               , 'm: 0f 18 /0        '                    , ''],
  ['prefetcht0'  , 'R:m8'               , 'm: 0f 18 /1        '                    , ''],

  # => PREFETCHW-Prefetch Data into Caches in Anticipation of a Write
  ['prefetchw' , 'R:m8'               , 'm: 0f 0d /1'                            , 'cpuid=prfchw'],

  # => PREFETCHWT1-Prefetch Vector Data Into Caches with Intent to Write and T1 Hint
  ['prefetchwt1' , 'R:m8'               , 'm: 0f 0d /2'                            , 'cpuid=prefetchwt1'],

  # => PSADBW-Compute Sum of Absolute Differences
  ['psadbw'   , 'mm, mm/m64'                 , 'rm:      0f f6 /r                      ' , 'cpuid=sse'],
  ['psadbw'   , 'xmm, xmm/m128'              , 'rm:      66 0f f6 /r                   ' , 'cpuid=sse2'],
  ['vpsadbw'  , 'W:vmm, vmm, vmm/vm'         , 'rvm:     vex.nds.vl.66.0f.wig f6 /r    ' , 'cpuid=avx-2'],
  ['vpsadbw'  , 'W:vmm, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig f6 /r   ' , 'cpuid=avx512bw-vl'],

  # => PSHUFB-Packed Shuffle Bytes
  ['pshufb'   , 'mm, mm/m64'                      , 'rm:      0f 38 00 /r                     ' , 'cpuid=ssse3'],
  ['pshufb'   , 'xmm, xmm/m128'                   , 'rm:      66 0f 38 00 /r                  ' , 'cpuid=ssse3'],
  ['vpshufb'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f38.wig 00 /r    ' , 'cpuid=avx-2'],
  ['vpshufb'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.wig 00 /r   ' , 'cpuid=avx512bw-vl'],

  # => PSHUFD-Shuffle Packed Doublewords
  ['pshufd'   , 'W:xmm, xmm/m128, pimm8'                , 'rmi:    66 0f 70 /r ib              '   , 'cpuid=sse2'],
  ['vpshufd'  , 'W:vmm, vmm/vm, pimm8'                  , 'rmi:    vex.vl.66.0f.wig 70 /r ib   '   , 'cpuid=avx-2'],
  ['vpshufd'  , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'rmi:fv: evex.vl.66.0f.w0 70 /r ib   '   , 'cpuid=avx512f-vl'],

  # => PSHUFHW-Shuffle Packed High Words
  ['pshufhw'  , 'W:xmm, xmm/m128, pimm8'            , 'rmi:     f3 0f 70 /r ib               ' , 'cpuid=sse2'],
  ['vpshufhw' , 'W:vmm, vmm/vm, pimm8'              , 'rmi:     vex.vl.f3.0f.wig 70 /r ib    ' , 'cpuid=avx-2'],
  ['vpshufhw' , 'W:vmm {kz}, vmm/vm, pimm8'         , 'rmi:fvm: evex.vl.f3.0f.wig 70 /r ib   ' , 'cpuid=avx512bw-vl'],

  # => PSHUFLW-Shuffle Packed Low Words
  ['pshuflw'  , 'W:xmm, xmm/m128, pimm8'            , 'rmi:     f2 0f 70 /r ib               ' , 'cpuid=sse2'],
  ['vpshuflw' , 'W:vmm, vmm/vm, pimm8'              , 'rmi:     vex.vl.f2.0f.wig 70 /r ib    ' , 'cpuid=avx-2'],
  ['vpshuflw' , 'W:vmm {kz}, vmm/vm, pimm8'         , 'rmi:fvm: evex.vl.f2.0f.wig 70 /r ib   ' , 'cpuid=avx512bw-vl'],

  # => PSHUFW-Shuffle Packed Words
  ['pshufw'   , 'W:mm, mm/m64, pimm8'       , 'rmi: 0f 70 /r ib'                       , ''],

  # => PSIGNB/PSIGNW/PSIGND-Packed SIGN
  ['psignb'   , 'mm, mm/m64'                 , 'rm:  0f 38 08 /r                    '   , 'cpuid=ssse3'],
  ['psignb'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 08 /r                 '   , 'cpuid=ssse3'],
  ['psignd'   , 'mm, mm/m64'                 , 'rm:  0f 38 0a /r                    '   , 'cpuid=ssse3'],
  ['psignd'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 0a /r                 '   , 'cpuid=ssse3'],
  ['psignw'   , 'mm, mm/m64'                 , 'rm:  0f 38 09 /r                    '   , 'cpuid=ssse3'],
  ['psignw'   , 'xmm, xmm/m128'              , 'rm:  66 0f 38 09 /r                 '   , 'cpuid=ssse3'],
  ['vpsignw'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 09 /r   '   , 'cpuid=avx-2'],
  ['vpsignd'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 0a /r   '   , 'cpuid=avx-2'],
  ['vpsignb'  , 'W:vmm, vmm, vmm/vm'         , 'rvm: vex.nds.vl.66.0f38.wig 08 /r   '   , 'cpuid=avx-2'],

  # => PSLLDQ-Shift Double Quadword Left Logical
  ['pslldq'   , 'xmm, pimm8'                   , 'mi:      66 0f 73 /7 ib                   ' , 'cpuid=sse2'],
  ['vpslldq'  , 'W:vmm, vmm, pimm8'            , 'vmi:     vex.ndd.vl.66.0f.wig 73 /7 ib    ' , 'cpuid=avx-2'],
  ['vpslldq'  , 'W:vmm, vmm/vm, pimm8'         , 'vmi:fvm: evex.ndd.vl.66.0f.wig 73 /7 ib   ' , 'cpuid=avx512bw-vl'],

  # => PSLLW/PSLLD/PSLLQ-Shift Packed Data Left Logical
  ['psllw'    , 'mm, pimm8'                             , 'mi:       0f 71 /6 ib                      ' , 'cpuid=mmx'],
  ['psllq'    , 'mm, pimm8'                             , 'mi:       0f 73 /6 ib                      ' , 'cpuid=mmx'],
  ['psllw'    , 'mm, mm/m64'                            , 'rm:       0f f1 /r                         ' , 'cpuid=mmx'],
  ['pslld'    , 'mm, mm/m64'                            , 'rm:       0f f2 /r                         ' , 'cpuid=mmx'],
  ['pslld'    , 'mm, pimm8'                             , 'mi:       0f 72 /6 ib                      ' , 'cpuid=mmx'],
  ['psllq'    , 'mm, mm/m64'                            , 'rm:       0f f3 /r                         ' , 'cpuid=mmx'],
  ['psllw'    , 'xmm, pimm8'                            , 'mi:       66 0f 71 /6 ib                   ' , 'cpuid=sse2'],
  ['psllq'    , 'xmm, pimm8'                            , 'mi:       66 0f 73 /6 ib                   ' , 'cpuid=sse2'],
  ['psllw'    , 'xmm, xmm/m128'                         , 'rm:       66 0f f1 /r                      ' , 'cpuid=sse2'],
  ['pslld'    , 'xmm, xmm/m128'                         , 'rm:       66 0f f2 /r                      ' , 'cpuid=sse2'],
  ['pslld'    , 'xmm, pimm8'                            , 'mi:       66 0f 72 /6 ib                   ' , 'cpuid=sse2'],
  ['psllq'    , 'xmm, xmm/m128'                         , 'rm:       66 0f f3 /r                      ' , 'cpuid=sse2'],
  ['vpsllw'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig f1 /r       ' , 'cpuid=avx-2'],
  ['vpslld'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig f2 /r       ' , 'cpuid=avx-2'],
  ['vpsllq'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 73 /6 ib    ' , 'cpuid=avx-2'],
  ['vpsllw'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 71 /6 ib    ' , 'cpuid=avx-2'],
  ['vpsllq'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig f3 /r       ' , 'cpuid=avx-2'],
  ['vpslld'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 72 /6 ib    ' , 'cpuid=avx-2'],
  ['vpslld'   , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'vmi:fv:   evex.ndd.vl.66.0f.w0 72 /6 ib    ' , 'cpuid=avx512f-vl'],
  ['vpsllq'   , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'vmi:fv:   evex.ndd.vl.66.0f.w1 73 /6 ib    ' , 'cpuid=avx512f-vl'],
  ['vpsllw'   , 'W:vmm {kz}, vmm/vm, pimm8'             , 'vmi:fvm:  evex.ndd.vl.66.0f.wig 71 /6 ib   ' , 'cpuid=avx512bw-vl'],
  ['vpsllq'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.w1 f3 /r       ' , 'cpuid=avx512f-vl'],
  ['vpslld'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.w0 f2 /r       ' , 'cpuid=avx512f-vl'],
  ['vpsllw'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.wig f1 /r      ' , 'cpuid=avx512bw-vl'],

  # => PSRAW/PSRAD/PSRAQ-Shift Packed Data Right Arithmetic
  ['psrad'    , 'mm, mm/m64'                            , 'rm:       0f e2 /r                         ' , 'cpuid=mmx'],
  ['psraw'    , 'mm, pimm8'                             , 'mi:       0f 71 /4 ib                      ' , 'cpuid=mmx'],
  ['psraw'    , 'mm, mm/m64'                            , 'rm:       0f e1 /r                         ' , 'cpuid=mmx'],
  ['psrad'    , 'mm, pimm8'                             , 'mi:       0f 72 /4 ib                      ' , 'cpuid=mmx'],
  ['psrad'    , 'xmm, xmm/m128'                         , 'rm:       66 0f e2 /r                      ' , 'cpuid=sse2'],
  ['psraw'    , 'xmm, pimm8'                            , 'mi:       66 0f 71 /4 ib                   ' , 'cpuid=sse2'],
  ['psraw'    , 'xmm, xmm/m128'                         , 'rm:       66 0f e1 /r                      ' , 'cpuid=sse2'],
  ['psrad'    , 'xmm, pimm8'                            , 'mi:       66 0f 72 /4 ib                   ' , 'cpuid=sse2'],
  ['vpsraw'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig e1 /r       ' , 'cpuid=avx-2'],
  ['vpsrad'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 72 /4 ib    ' , 'cpuid=avx-2'],
  ['vpsraw'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 71 /4 ib    ' , 'cpuid=avx-2'],
  ['vpsrad'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig e2 /r       ' , 'cpuid=avx-2'],
  ['vpsraq'   , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'vmi:fv:   evex.ndd.vl.66.0f.w1 72 /4 ib    ' , 'cpuid=avx512f-vl'],
  ['vpsrad'   , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'vmi:fv:   evex.ndd.vl.66.0f.w0 72 /4 ib    ' , 'cpuid=avx512f-vl'],
  ['vpsraw'   , 'W:vmm {kz}, vmm/vm, pimm8'             , 'vmi:fvm:  evex.ndd.vl.66.0f.wig 71 /4 ib   ' , 'cpuid=avx512bw-vl'],
  ['vpsrad'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.w0 e2 /r       ' , 'cpuid=avx512f-vl'],
  ['vpsraq'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.w1 e2 /r       ' , 'cpuid=avx512f-vl'],
  ['vpsraw'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.wig e1 /r      ' , 'cpuid=avx512bw-vl'],

  # => PSRLDQ-Shift Double Quadword Right Logical
  ['psrldq'   , 'xmm, pimm8'                   , 'mi:      66 0f 73 /3 ib                   ' , 'cpuid=sse2'],
  ['vpsrldq'  , 'W:vmm, vmm, pimm8'            , 'vmi:     vex.ndd.vl.66.0f.wig 73 /3 ib    ' , 'cpuid=avx-2'],
  ['vpsrldq'  , 'W:vmm, vmm/vm, pimm8'         , 'vmi:fvm: evex.ndd.vl.66.0f.wig 73 /3 ib   ' , 'cpuid=avx512bw-vl'],

  # => PSRLW/PSRLD/PSRLQ-Shift Packed Data Right Logical
  ['psrlw'    , 'mm, mm/m64'                            , 'rm:       0f d1 /r                         ' , 'cpuid=mmx'],
  ['psrlq'    , 'mm, pimm8'                             , 'mi:       0f 73 /2 ib                      ' , 'cpuid=mmx'],
  ['psrlq'    , 'mm, mm/m64'                            , 'rm:       0f d3 /r                         ' , 'cpuid=mmx'],
  ['psrld'    , 'mm, pimm8'                             , 'mi:       0f 72 /2 ib                      ' , 'cpuid=mmx'],
  ['psrld'    , 'mm, mm/m64'                            , 'rm:       0f d2 /r                         ' , 'cpuid=mmx'],
  ['psrlw'    , 'mm, pimm8'                             , 'mi:       0f 71 /2 ib                      ' , 'cpuid=mmx'],
  ['psrlw'    , 'xmm, xmm/m128'                         , 'rm:       66 0f d1 /r                      ' , 'cpuid=sse2'],
  ['psrlq'    , 'xmm, pimm8'                            , 'mi:       66 0f 73 /2 ib                   ' , 'cpuid=sse2'],
  ['psrlq'    , 'xmm, xmm/m128'                         , 'rm:       66 0f d3 /r                      ' , 'cpuid=sse2'],
  ['psrld'    , 'xmm, pimm8'                            , 'mi:       66 0f 72 /2 ib                   ' , 'cpuid=sse2'],
  ['psrld'    , 'xmm, xmm/m128'                         , 'rm:       66 0f d2 /r                      ' , 'cpuid=sse2'],
  ['psrlw'    , 'xmm, pimm8'                            , 'mi:       66 0f 71 /2 ib                   ' , 'cpuid=sse2'],
  ['vpsrlq'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 73 /2 ib    ' , 'cpuid=avx-2'],
  ['vpsrld'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 72 /2 ib    ' , 'cpuid=avx-2'],
  ['vpsrlq'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig d3 /r       ' , 'cpuid=avx-2'],
  ['vpsrlw'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig d1 /r       ' , 'cpuid=avx-2'],
  ['vpsrld'   , 'W:vmm, vmm, xmm/m128'                  , 'rvm:      vex.nds.vl.66.0f.wig d2 /r       ' , 'cpuid=avx-2'],
  ['vpsrlw'   , 'W:vmm, vmm, pimm8'                     , 'vmi:      vex.ndd.vl.66.0f.wig 71 /2 ib    ' , 'cpuid=avx-2'],
  ['vpsrlq'   , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'vmi:fv:   evex.ndd.vl.66.0f.w1 73 /2 ib    ' , 'cpuid=avx512f-vl'],
  ['vpsrld'   , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'vmi:fv:   evex.ndd.vl.66.0f.w0 72 /2 ib    ' , 'cpuid=avx512f-vl'],
  ['vpsrlw'   , 'W:vmm {kz}, vmm/vm, pimm8'             , 'vmi:fvm:  evex.ndd.vl.66.0f.wig 71 /2 ib   ' , 'cpuid=avx512bw-vl'],
  ['vpsrlq'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.w1 d3 /r       ' , 'cpuid=avx512f-vl'],
  ['vpsrld'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.w0 d2 /r       ' , 'cpuid=avx512f-vl'],
  ['vpsrlw'   , 'W:vmm {kz}, vmm, xmm/m128'             , 'rvm:m128: evex.nds.vl.66.0f.wig d1 /r      ' , 'cpuid=avx512bw-vl'],

  # => PSUBB/PSUBW/PSUBD-Subtract Packed Integers
  ['psubd'    , 'mm, mm/m64'                          , 'rm:      0f fa /r                      ' , 'cpuid=mmx'],
  ['psubb'    , 'mm, mm/m64'                          , 'rm:      0f f8 /r                      ' , 'cpuid=mmx'],
  ['psubw'    , 'mm, mm/m64'                          , 'rm:      0f f9 /r                      ' , 'cpuid=mmx'],
  ['psubd'    , 'xmm, xmm/m128'                       , 'rm:      66 0f fa /r                   ' , 'cpuid=sse2'],
  ['psubb'    , 'xmm, xmm/m128'                       , 'rm:      66 0f f8 /r                   ' , 'cpuid=sse2'],
  ['psubw'    , 'xmm, xmm/m128'                       , 'rm:      66 0f f9 /r                   ' , 'cpuid=sse2'],
  ['vpsubd'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig fa /r    ' , 'cpuid=avx-2'],
  ['vpsubw'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig f9 /r    ' , 'cpuid=avx-2'],
  ['vpsubb'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig f8 /r    ' , 'cpuid=avx-2'],
  ['vpsubd'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 fa /r    ' , 'cpuid=avx512f-vl'],
  ['vpsubw'   , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig f9 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpsubb'   , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig f8 /r   ' , 'cpuid=avx512bw-vl'],

  # => PSUBQ-Subtract Packed Quadword Integers
  ['psubq'    , 'mm, mm/m64'                          , 'rm:     0f fb /r                     '  , 'cpuid=sse2'],
  ['psubq'    , 'xmm, xmm/m128'                       , 'rm:     66 0f fb /r                  '  , 'cpuid=sse2'],
  ['vpsubq'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig fb /r   '  , 'cpuid=avx-2'],
  ['vpsubq'   , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 fb /r   '  , 'cpuid=avx512f-vl'],

  # => PSUBSB/PSUBSW-Subtract Packed Signed Integers with Signed Saturation
  ['psubsw'   , 'mm, mm/m64'                      , 'rm:      0f e9 /r                      ' , 'cpuid=mmx'],
  ['psubsb'   , 'mm, mm/m64'                      , 'rm:      0f e8 /r                      ' , 'cpuid=mmx'],
  ['psubsw'   , 'xmm, xmm/m128'                   , 'rm:      66 0f e9 /r                   ' , 'cpuid=sse2'],
  ['psubsb'   , 'xmm, xmm/m128'                   , 'rm:      66 0f e8 /r                   ' , 'cpuid=sse2'],
  ['vpsubsw'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig e9 /r    ' , 'cpuid=avx-2'],
  ['vpsubsb'  , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig e8 /r    ' , 'cpuid=avx-2'],
  ['vpsubsb'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig e8 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpsubsw'  , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig e9 /r   ' , 'cpuid=avx512bw-vl'],

  # => PSUBUSB/PSUBUSW-Subtract Packed Unsigned Integers with Unsigned Saturation
  ['psubusw'  , 'mm, mm/m64'                      , 'rm:      0f d9 /r                      ' , 'cpuid=mmx'],
  ['psubusb'  , 'mm, mm/m64'                      , 'rm:      0f d8 /r                      ' , 'cpuid=mmx'],
  ['psubusw'  , 'xmm, xmm/m128'                   , 'rm:      66 0f d9 /r                   ' , 'cpuid=sse2'],
  ['psubusb'  , 'xmm, xmm/m128'                   , 'rm:      66 0f d8 /r                   ' , 'cpuid=sse2'],
  ['vpsubusw' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig d9 /r    ' , 'cpuid=avx-2'],
  ['vpsubusb' , 'W:vmm, vmm, vmm/vm'              , 'rvm:     vex.nds.vl.66.0f.wig d8 /r    ' , 'cpuid=avx-2'],
  ['vpsubusb' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig d8 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpsubusw' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f.wig d9 /r   ' , 'cpuid=avx512bw-vl'],

  # => PTEST-Logical Compare
  ['ptest'    , 'R:xmm, xmm/m128'       , 'rm: 66 0f 38 17 /r             '        , 'cpuid=sse4v1 eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],
  ['vptest'   , 'R:vmm, vmm/vm'         , 'rm: vex.vl.66.0f38.wig 17 /r   '        , 'cpuid=avx eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],

  # => PTWRITE-Write Data to a Processor Trace Packet
  ['ptwrite'  , 'R:vr/vm'            , 'm:     osv  f3 0f ae /4     '           , 'cpuid=ptwrite'],

  # => PUNPCKHBW/PUNPCKHWD/PUNPCKHDQ/PUNPCKHQDQ-Unpack High Data
  ['punpckhwd'   , 'mm, mm/m64'                          , 'rm:      0f 69 /r                      ' , 'cpuid=mmx'],
  ['punpckhdq'   , 'mm, mm/m64'                          , 'rm:      0f 6a /r                      ' , 'cpuid=mmx'],
  ['punpckhbw'   , 'mm, mm/m64'                          , 'rm:      0f 68 /r                      ' , 'cpuid=mmx'],
  ['punpckhwd'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 69 /r                   ' , 'cpuid=sse2'],
  ['punpckhdq'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 6a /r                   ' , 'cpuid=sse2'],
  ['punpckhbw'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 68 /r                   ' , 'cpuid=sse2'],
  ['punpckhqdq'  , 'xmm, xmm/m128'                       , 'rm:      66 0f 6d /r                   ' , 'cpuid=sse2'],
  ['vpunpckhbw'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 68 /r    ' , 'cpuid=avx-2'],
  ['vpunpckhqdq' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 6d /r    ' , 'cpuid=avx-2'],
  ['vpunpckhdq'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 6a /r    ' , 'cpuid=avx-2'],
  ['vpunpckhwd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 69 /r    ' , 'cpuid=avx-2'],
  ['vpunpckhqdq' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f.w1 6d /r    ' , 'cpuid=avx512f-vl'],
  ['vpunpckhdq'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 6a /r    ' , 'cpuid=avx512f-vl'],
  ['vpunpckhwd'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 69 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpunpckhbw'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 68 /r   ' , 'cpuid=avx512bw-vl'],

  # => PUNPCKLBW/PUNPCKLWD/PUNPCKLDQ/PUNPCKLQDQ-Unpack Low Data
  ['punpcklwd'   , 'mm, mm/m32'                          , 'rm:      0f 61 /r                      ' , 'cpuid=mmx'],
  ['punpcklbw'   , 'mm, mm/m32'                          , 'rm:      0f 60 /r                      ' , 'cpuid=mmx'],
  ['punpckldq'   , 'mm, mm/m32'                          , 'rm:      0f 62 /r                      ' , 'cpuid=mmx'],
  ['punpcklwd'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 61 /r                   ' , 'cpuid=sse2'],
  ['punpcklqdq'  , 'xmm, xmm/m128'                       , 'rm:      66 0f 6c /r                   ' , 'cpuid=sse2'],
  ['punpcklbw'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 60 /r                   ' , 'cpuid=sse2'],
  ['punpckldq'   , 'xmm, xmm/m128'                       , 'rm:      66 0f 62 /r                   ' , 'cpuid=sse2'],
  ['vpunpcklwd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 61 /r    ' , 'cpuid=avx-2'],
  ['vpunpckldq'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 62 /r    ' , 'cpuid=avx-2'],
  ['vpunpcklqdq' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 6c /r    ' , 'cpuid=avx-2'],
  ['vpunpcklbw'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f.wig 60 /r    ' , 'cpuid=avx-2'],
  ['vpunpckldq'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f.w0 62 /r    ' , 'cpuid=avx512f-vl'],
  ['vpunpcklqdq' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f.w1 6c /r    ' , 'cpuid=avx512f-vl'],
  ['vpunpcklbw'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 60 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpunpcklwd'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f.wig 61 /r   ' , 'cpuid=avx512bw-vl'],

  # => PUSH-Push Word, Doubleword or Quadword Onto the Stack
  ['push'     , 'R:gs'               , '            0f a8           '           , ''],
  ['push'     , 'R:fs'               , '            0f a0           '           , ''],
  ['push'     , 'imm8'               , 'i:          6a ib           '           , ''],
  ['push'     , 'R:vr'               , 'o:     os   50+r            '           , ''],
  ['push'     , 'R:vr/vm'            , 'm:     os   ff /6           '           , ''],
  ['push'     , 'imm'                , 'i:     osz  68 iz           '           , ''],
  ['push'     , 'R:ds'               , 'x86:        1e              '           , ''],
  ['push'     , 'R:ss'               , 'x86:        16              '           , ''],
  ['push'     , 'R:es'               , 'x86:        06              '           , ''],
  ['push'     , 'R:cs'               , 'x86:        0e              '           , ''],

  # => PUSHA/PUSHAD-Push All General-Purpose Registers
  ['pusha'    , 'R:<ax>, <cx>, <dx>, <bx>, <sp>, <bp>, <si>, <di>'               , 'x86: os16 60              '             , 'deprecated'],
  ['pushad'   , 'R:<eax>, <ecx>, <edx>, <ebx>, <esp>, <ebp>, <esi>, <edi>'       , 'x86:      60              '             , 'deprecated'],

  # => PUSHF/PUSHFD-Push EFLAGS Register onto the Stack
  ['pushf'    , ''                   , '     os16 9c              '             , ''],
  ['pushfq'   , ''                   , 'x64:      9c              '             , ''],
  ['pushfd'   , ''                   , 'x86:      9c              '             , ''],

  # => PXOR-Logical Exclusive OR
  ['pxor'     , 'mm, mm/m64'                          , 'rm:     0f ef /r                     '  , 'cpuid=mmx'],
  ['pxor'     , 'xmm, xmm/m128'                       , 'rm:     66 0f ef /r                  '  , 'cpuid=sse2'],
  ['vpxor'    , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig ef /r   '  , 'cpuid=avx-2'],
  ['vpxord'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f.w0 ef /r   '  , 'cpuid=avx512f-vl'],
  ['vpxorq'   , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 ef /r   '  , 'cpuid=avx512f-vl'],

  # => RCL/RCR/ROL/ROR-Rotate
  ['rcr'      , 'W:r8x/m8, 1'           , 'm:           d0 /3           '          , 'eflags.of=M eflags.cf=TM eflags.of=U eflags.cf=TM'],
  ['rol'      , 'W:vr/vm, cl'           , 'm:      os   d3 /0           '          , 'eflags.of=U eflags.cf=M'],
  ['ror'      , 'W:r8x/m8, 1'           , 'm:           d0 /1           '          , 'eflags.of=M eflags.cf=M eflags.of=U eflags.cf=M'],
  ['rol'      , 'W:vr/vm, 1'            , 'm:      os   d1 /0           '          , 'eflags.of=M eflags.cf=M eflags.of=U eflags.cf=M'],
  ['ror'      , 'W:r8x/m8, cl'          , 'm:           d2 /1           '          , 'eflags.of=U eflags.cf=M'],
  ['rol'      , 'W:r8x/m8, cl'          , 'm:           d2 /0           '          , 'eflags.of=U eflags.cf=M'],
  ['rcr'      , 'W:r8x/m8, cl'          , 'm:           d2 /3           '          , 'eflags.of=U eflags.cf=TM'],
  ['rcl'      , 'W:r8x/m8, cl'          , 'm:           d2 /2           '          , 'eflags.of=U eflags.cf=TM'],
  ['ror'      , 'W:vr/vm, cl'           , 'm:      os   d3 /1           '          , 'eflags.of=U eflags.cf=M'],
  ['rol'      , 'W:r8x/m8, 1'           , 'm:           d0 /0           '          , 'eflags.of=M eflags.cf=M eflags.of=U eflags.cf=M'],
  ['rcl'      , 'W:r8x/m8, 1'           , 'm:           d0 /2           '          , 'eflags.of=M eflags.cf=TM eflags.of=U eflags.cf=TM'],
  ['rcr'      , 'W:vr/vm, cl'           , 'm:      os   d3 /3           '          , 'eflags.of=U eflags.cf=TM'],
  ['rcl'      , 'W:vr/vm, 1'            , 'm:      os   d1 /2           '          , 'eflags.of=M eflags.cf=TM eflags.of=U eflags.cf=TM'],
  ['ror'      , 'W:vr/vm, 1'            , 'm:      os   d1 /1           '          , 'eflags.of=M eflags.cf=M eflags.of=U eflags.cf=M'],
  ['rcr'      , 'W:vr/vm, 1'            , 'm:      os   d1 /3           '          , 'eflags.of=M eflags.cf=TM eflags.of=U eflags.cf=TM'],
  ['rcl'      , 'W:vr/vm, cl'           , 'm:      os   d3 /2           '          , 'eflags.of=U eflags.cf=TM'],
  ['rcl'      , 'W:r8x/m8, pimm8'       , 'mi:          c0 /2 ib        '          , 'eflags.of=U eflags.cf=TM'],
  ['rol'      , 'W:r8x/m8, pimm8'       , 'mi:          c0 /0 ib        '          , 'eflags.of=U eflags.cf=M'],
  ['rcr'      , 'W:r8x/m8, pimm8'       , 'mi:          c0 /3 ib        '          , 'eflags.of=U eflags.cf=TM'],
  ['rcr'      , 'W:vr/vm, pimm8'        , 'mi:     os   c1 /3 ib        '          , 'eflags.of=U eflags.cf=TM'],
  ['rcl'      , 'W:vr/vm, pimm8'        , 'mi:     os   c1 /2 ib        '          , 'eflags.of=U eflags.cf=TM'],
  ['rol'      , 'W:vr/vm, pimm8'        , 'mi:     os   c1 /0 ib        '          , 'eflags.of=U eflags.cf=M'],
  ['ror'      , 'W:r8x/m8, pimm8'       , 'mi:          c0 /1 ib        '          , 'eflags.of=U eflags.cf=M'],
  ['ror'      , 'W:vr/vm, pimm8'        , 'mi:     os   c1 /1 ib        '          , 'eflags.of=U eflags.cf=M'],

  # => RCPPS-Compute Reciprocals of Packed Single-Precision Floating-Point Values
  ['rcpps'    , 'W:xmm, xmm/m128'       , 'rm: 0f 53 /r              '             , 'cpuid=sse'],
  ['vrcpps'   , 'W:vmm, vmm/vm'         , 'rm: vex.vl.0f.wig 53 /r   '             , 'cpuid=avx'],

  # => RCPSS-Compute Reciprocal of Scalar Single-Precision Floating-Point Values
  ['rcpss'    , 'W:xmm, xmm/m32'            , 'rm:  f3 0f 53 /r                  '     , 'cpuid=sse'],
  ['vrcpss'   , 'W:xmm, xmm, xmm/m32'       , 'rvm: vex.nds.lig.f3.0f.wig 53 /r  '     , 'cpuid=avx'],

  # => RDFSBASE/RDGSBASE-Read FS/GS Segment Base
  ['rdgsbase' , 'W:vr'               , 'x64:m: osv  f3 0f ae /1     '           , 'cpuid=fsgsbase'],
  ['rdfsbase' , 'W:vr'               , 'x64:m: osv  f3 0f ae /0     '           , 'cpuid=fsgsbase'],

  # => RDMSR-Read from Model Specific Register
  ['rdmsr'    , 'R:<ecx>, W:<edx>, W:<eax>'       , '0f 32'                                  , 'level=0'],

  # => RDPID-Read Processor ID
  ['rdpid'    , 'W:vr'               , 'm:     osv f3 0f c7 /7     '            , 'cpuid=rdpid'],

  # => RDPKRU-Read Protection Key Rights for User Pages
  ['rdpkru'   , 'W:<eax>'            , '0f 01 ee'                               , 'cpuid=ospke'],

  # => RDPMC-Read Performance-Monitoring Counters
  ['rdpmc'    , 'R:<ecx>, W:<edx>, W:<eax>'       , '0f 33'                                  , 'level=0'],

  # => RDRAND-Read Random Number
  ['rdrand'   , 'W:vr'               , 'm:     os   0f c7 /6        '           , 'cpuid=rdrand eflags.of=C eflags.sf=C eflags.zf=C eflags.af=C eflags.pf=C eflags.cf=M'],

  # => RDSEED-Read Random SEED
  ['rdseed'   , 'W:vr'               , 'm:     os   0f c7 /7        '           , 'cpuid=rdseed eflags.of=C eflags.sf=C eflags.zf=C eflags.af=C eflags.pf=C eflags.cf=M'],

  # => RDTSC-Read Time-Stamp Counter
  ['rdtsc'    , 'W:<edx>, W:<eax>'       , '0f 31'                                  , ''],

  # => RDTSCP-Read Time-Stamp Counter and Processor ID
  ['rdtscp'   , 'W:<edx>, W:<eax>, W:<ecx>'       , '0f 01 f9'                               , 'cpuid=rdtscp'],

  # => RET-Return from Procedure
  ['ret'      , ''                   , '   c3              '                    , 'branchType=near bnd'],
  ['ret'      , ''                   , '   cb              '                    , 'branchType=far'],
  ['ret'      , 'pimm16'             , 'i: ca iw           '                    , 'branchType=far'],
  ['ret'      , 'pimm16'             , 'i: c2 iw           '                    , 'branchType=near bnd'],

  # => RORX-Rotate Right Logical Without Affecting Flags
  ['rorx'     , 'W:r32, r/m32, pimm8'       , 'rmi:     vex.lz.f2.0f3a.w0 f0 /r ib  '  , 'cpuid=bmi2'],
  ['rorx'     , 'W:r64, r/m64, pimm8'       , 'x64:rmi: vex.lz.f2.0f3a.w1 f0 /r ib  '  , 'cpuid=bmi2'],

  # => ROUNDPD-Round Packed Double Precision Floating-Point Values
  ['roundpd'  , 'W:xmm, xmm/m128, pimm8'       , 'rmi: 66 0f 3a 09 /r ib             '    , 'cpuid=sse4v1'],
  ['vroundpd' , 'W:vmm, vmm/vm, pimm8'         , 'rmi: vex.vl.66.0f3a.wig 09 /r ib   '    , 'cpuid=avx'],

  # => ROUNDPS-Round Packed Single Precision Floating-Point Values
  ['roundps'  , 'W:xmm, xmm/m128, pimm8'       , 'rmi: 66 0f 3a 08 /r ib             '    , 'cpuid=sse4v1'],
  ['vroundps' , 'W:vmm, vmm/vm, pimm8'         , 'rmi: vex.vl.66.0f3a.wig 08 /r ib   '    , 'cpuid=avx'],

  # => ROUNDSD-Round Scalar Double Precision Floating-Point Values
  ['roundsd'  , 'W:xmm, xmm/m64, pimm8'            , 'rmi:  66 0f 3a 0b /r ib                 ' , 'cpuid=sse4v1'],
  ['vroundsd' , 'W:xmm, xmm, xmm/m64, pimm8'       , 'rvmi: vex.nds.lig.66.0f3a.wig 0b /r ib  ' , 'cpuid=avx'],

  # => ROUNDSS-Round Scalar Single Precision Floating-Point Values
  ['roundss'  , 'W:xmm, xmm/m32, pimm8'            , 'rmi:  66 0f 3a 0a /r ib                 ' , 'cpuid=sse4v1'],
  ['vroundss' , 'W:xmm, xmm, xmm/m32, pimm8'       , 'rvmi: vex.nds.lig.66.0f3a.wig 0a /r ib  ' , 'cpuid=avx'],

  # => RSM-Resume from System Management Mode
  ['rsm'      , ''                   , '0f aa'                                  , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.tf=M eflags.if=M eflags.df=M eflags.nt=M eflags.rf=M'],

  # => RSQRTPS-Compute Reciprocals of Square Roots of Packed Single-Precision Floating-Point Values
  ['rsqrtps'  , 'W:xmm, xmm/m128'       , 'rm: 0f 52 /r              '             , 'cpuid=sse'],
  ['vrsqrtps' , 'W:vmm, vmm/vm'         , 'rm: vex.vl.0f.wig 52 /r   '             , 'cpuid=avx'],

  # => RSQRTSS-Compute Reciprocal of Square Root of Scalar Single-Precision Floating-Point Value
  ['rsqrtss'  , 'W:xmm, xmm/m32'            , 'rm:  f3 0f 52 /r                  '     , 'cpuid=sse'],
  ['vrsqrtss' , 'W:xmm, xmm, xmm/m32'       , 'rvm: vex.nds.lig.f3.0f.wig 52 /r  '     , 'cpuid=avx'],

  # => SAHF-Store AH into Flags
  ['sahf'     , 'R:<ah>'             , 'x86: 9e'                                , 'eflags.sf=P eflags.zf=P eflags.af=P eflags.pf=P eflags.cf=P'],

  # => SAL/SAR/SHL/SHR-Shift
  ['sal'      , 'vr/vm, 1'            , 'm:      os   d1 /4           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shr'      , 'vr/vm, cl'           , 'm:      os   d3 /5           '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sal'      , 'r8x/m8, cl'          , 'm:           d2 /4           '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shl'      , 'r8x/m8, cl'          , 'm:           d2 /4           '          , 'aliasOf=sal eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sar'      , 'r8x/m8, 1'           , 'm:           d0 /7           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sar'      , 'vr/vm, cl'           , 'm:      os   d3 /7           '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sar'      , 'vr/vm, 1'            , 'm:      os   d1 /7           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shr'      , 'vr/vm, 1'            , 'm:      os   d1 /5           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sar'      , 'r8x/m8, cl'          , 'm:           d2 /7           '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shr'      , 'r8x/m8, cl'          , 'm:           d2 /5           '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sal'      , 'vr/vm, cl'           , 'm:      os   d3 /4           '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shl'      , 'vr/vm, cl'           , 'm:      os   d3 /4           '          , 'aliasOf=sal eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shr'      , 'r8x/m8, 1'           , 'm:           d0 /5           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shl'      , 'r8x/m8, 1'           , 'm:           d0 /4           '          , 'aliasOf=sal eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sal'      , 'r8x/m8, 1'           , 'm:           d0 /4           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shl'      , 'vr/vm, 1'            , 'm:      os   d1 /4           '          , 'aliasOf=sal eflags.of=M eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sal'      , 'vr/vm, pimm8'        , 'mi:     os   c1 /4 ib        '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shr'      , 'vr/vm, pimm8'        , 'mi:     os   c1 /5 ib        '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shl'      , 'vr/vm, pimm8'        , 'mi:     os   c1 /4 ib        '          , 'aliasOf=sal eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shr'      , 'r8x/m8, pimm8'       , 'mi:          c0 /5 ib        '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sal'      , 'r8x/m8, pimm8'       , 'mi:          c0 /4 ib        '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sar'      , 'vr/vm, pimm8'        , 'mi:     os   c1 /7 ib        '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['sar'      , 'r8x/m8, pimm8'       , 'mi:          c0 /7 ib        '          , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shl'      , 'r8x/m8, pimm8'       , 'mi:          c0 /4 ib        '          , 'aliasOf=sal eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],

  # => SARX/SHLX/SHRX-Shift Without Affecting Flags
  ['shlx'     , 'W:r32, r/m32, r32'       , 'rmv:     vex.nds.lz.66.0f38.w0 f7 /r  ' , 'cpuid=bmi2'],
  ['shrx'     , 'W:r32, r/m32, r32'       , 'rmv:     vex.nds.lz.f2.0f38.w0 f7 /r  ' , 'cpuid=bmi2'],
  ['sarx'     , 'W:r32, r/m32, r32'       , 'rmv:     vex.nds.lz.f3.0f38.w0 f7 /r  ' , 'cpuid=bmi2'],
  ['shrx'     , 'W:r64, r/m64, r64'       , 'x64:rmv: vex.nds.lz.f2.0f38.w1 f7 /r  ' , 'cpuid=bmi2'],
  ['shlx'     , 'W:r64, r/m64, r64'       , 'x64:rmv: vex.nds.lz.66.0f38.w1 f7 /r  ' , 'cpuid=bmi2'],
  ['sarx'     , 'W:r64, r/m64, r64'       , 'x64:rmv: vex.nds.lz.f3.0f38.w1 f7 /r  ' , 'cpuid=bmi2'],

  # => SBB-Integer Subtraction with Borrow
  ['sbb'      , 'W:al, imm8'           , 'i:           1c ib           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:*ax, imm.low'       , 'i:      os   1d iz           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:vr/vm, imm8'        , 'mi:     os   83 /3 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:vr, vr/vm'          , 'rm:     os   1b /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:vr/vm, vr'          , 'mr:     os   19 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:r8x/m8, imm8'       , 'mi:          80 /3 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:vr/vm, imm.low'     , 'mi:     os   81 /3 iz        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:r8x, r8x/m8'        , 'rm:          1a /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],
  ['sbb'      , 'W:r8x/m8, r8x'        , 'mr:          18 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=TM'],

  # => SCAS/SCASB/SCASW/SCASD-Scan String
  #['scas'     , 'vm, <rax>, <rdi>'          , '     os   af              '             , 'repe eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  ['scasd'    , 'R:<eax>, <[es:*di]>'       , '     os32 af              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  #['scas'     , 'm8'                        , '          ae              '             , 'repe eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  ['scasw'    , 'R:<ax>, <[es:*di]>'        , '     os16 af              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  ['scasb'    , 'R:<al>, <[es:*di]>'        , '          ae              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],
  ['scasq'    , 'R:<rax>, <[rdi]>'          , 'x64: os64 af              '             , 'repe repne eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M eflags.df=T'],

  # => SETcc-Set Byte on Condition
  ['setnb'    , 'R:r8x/m8'           , 'm:         0f 93           '            , 'aliasOf=setae eflags.cf=T'],
  ['setb'     , 'R:r8x/m8'           , 'm:         0f 92           '            , 'eflags.cf=T'],
  ['setnz'    , 'R:r8x/m8'           , 'm:         0f 95           '            , 'aliasOf=setne eflags.zf=T'],
  ['setnc'    , 'R:r8x/m8'           , 'm:         0f 93           '            , 'aliasOf=setae eflags.cf=T'],
  ['seto'     , 'R:r8x/m8'           , 'm:         0f 90           '            , 'eflags.of=T'],
  ['setna'    , 'R:r8x/m8'           , 'm:         0f 96           '            , 'aliasOf=setbe eflags.cf=T eflags.zf=T'],
  ['sete'     , 'R:r8x/m8'           , 'm:         0f 94           '            , 'eflags.zf=T'],
  ['seta'     , 'R:r8x/m8'           , 'm:         0f 97           '            , 'eflags.cf=T eflags.zf=T'],
  ['setno'    , 'R:r8x/m8'           , 'm:         0f 91           '            , 'eflags.of=T'],
  ['setnl'    , 'R:r8x/m8'           , 'm:         0f 9d           '            , 'aliasOf=setge eflags.sf=T eflags.of=T'],
  ['setc'     , 'R:r8x/m8'           , 'm:         0f 92           '            , 'aliasOf=setb eflags.cf=T'],
  ['setns'    , 'R:r8x/m8'           , 'm:         0f 99           '            , 'eflags.sf=T'],
  ['setpo'    , 'R:r8x/m8'           , 'm:         0f 9b           '            , 'aliasOf=setnp eflags.pf=T'],
  ['setng'    , 'R:r8x/m8'           , 'm:         0f 9e           '            , 'aliasOf=setle eflags.zf=T eflags.sf=T eflags.of=T'],
  ['setg'     , 'R:r8x/m8'           , 'm:         0f 9f           '            , 'eflags.zf=T eflags.sf=T eflags.of=T'],
  ['setnp'    , 'R:r8x/m8'           , 'm:         0f 9b           '            , 'eflags.pf=T'],
  ['setne'    , 'R:r8x/m8'           , 'm:         0f 95           '            , 'eflags.zf=T'],
  ['sets'     , 'R:r8x/m8'           , 'm:         0f 98           '            , 'eflags.sf=T'],
  ['setbe'    , 'R:r8x/m8'           , 'm:         0f 96           '            , 'eflags.cf=T eflags.zf=T'],
  ['setpe'    , 'R:r8x/m8'           , 'm:         0f 9a           '            , 'aliasOf=setp eflags.pf=T'],
  ['setae'    , 'R:r8x/m8'           , 'm:         0f 93           '            , 'eflags.cf=T'],
  ['setle'    , 'R:r8x/m8'           , 'm:         0f 9e           '            , 'eflags.zf=T eflags.sf=T eflags.of=T'],
  ['setnge'   , 'R:r8x/m8'           , 'm:         0f 9c           '            , 'aliasOf=setl eflags.sf=T eflags.of=T'],
  ['setp'     , 'R:r8x/m8'           , 'm:         0f 9a           '            , 'eflags.pf=T'],
  ['setl'     , 'R:r8x/m8'           , 'm:         0f 9c           '            , 'eflags.sf=T eflags.of=T'],
  ['setnbe'   , 'R:r8x/m8'           , 'm:         0f 97           '            , 'aliasOf=seta eflags.cf=T eflags.zf=T'],
  ['setz'     , 'R:r8x/m8'           , 'm:         0f 94           '            , 'aliasOf=sete eflags.zf=T'],
  ['setnle'   , 'R:r8x/m8'           , 'm:         0f 9f           '            , 'aliasOf=setg eflags.zf=T eflags.sf=T eflags.of=T'],
  ['setnae'   , 'R:r8x/m8'           , 'm:         0f 92           '            , 'aliasOf=setb eflags.cf=T'],
  ['setge'    , 'R:r8x/m8'           , 'm:         0f 9d           '            , 'eflags.sf=T eflags.of=T'],

  # => SFENCE-Store Fence
  ['sfence'   , ''                   , '0f ae f8'                               , ''],

  # => SGDT-Store Global Descriptor Table Register
  ['sgdt'     , 'W:mem'              , 'm: 0f 01 /0'                            , ''],

  # => SHA1RNDS4-Perform Four Rounds of SHA1 Operation
  ['sha1rnds4' , 'xmm, xmm/m128, pimm8'       , 'rmi: 0f 3a cc /r ib'                    , 'cpuid=sha'],

  # => SHA1NEXTE-Calculate SHA1 State Variable E after Four Rounds
  ['sha1nexte' , 'xmm, xmm/m128'       , 'rm: 0f 38 c8 /r'                        , 'cpuid=sha'],

  # => SHA1MSG1-Perform an Intermediate Calculation for the Next Four SHA1 Message Dwords
  ['sha1msg1' , 'xmm, xmm/m128'       , 'rm: 0f 38 c9 /r'                        , 'cpuid=sha'],

  # => SHA1MSG2-Perform a Final Calculation for the Next Four SHA1 Message Dwords
  ['sha1msg2' , 'xmm, xmm/m128'       , 'rm: 0f 38 ca /r'                        , 'cpuid=sha'],

  # => SHA256RNDS2-Perform Two Rounds of SHA256 Operation
  ['sha256rnds2' , 'xmm, xmm/m128, <xmm0>'       , 'rm: 0f 38 cb /r'                        , 'cpuid=sha'],

  # => SHA256MSG1-Perform an Intermediate Calculation for the Next Four SHA256 Message Dwords
  ['sha256msg1' , 'xmm, xmm/m128'       , 'rm: 0f 38 cc /r'                        , 'cpuid=sha'],

  # => SHA256MSG2-Perform a Final Calculation for the Next Four SHA256 Message Dwords
  ['sha256msg2' , 'xmm, xmm/m128'       , 'rm: 0f 38 cd /r'                        , 'cpuid=sha'],

  # => SHLD-Double Precision Shift Left
  ['shld'     , 'W:vr/vm, vr, cl'           , 'mr:      os   0f a5 /r        '         , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shld'     , 'W:vr/vm, vr, pimm8'        , 'mri:     os   0f a4 /r ib     '         , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],

  # => SHRD-Double Precision Shift Right
  ['shrd'     , 'W:vr/vm, vr, cl'           , 'mr:      os   0f ad /r        '         , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],
  ['shrd'     , 'W:vr/vm, vr, pimm8'        , 'mri:     os   0f ac /r ib     '         , 'eflags.of=U eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=M'],

  # => SHUFPD-Packed Interleave Shuffle of Pairs of Double-Precision Floating-Point Values
  ['shufpd'   , 'xmm, xmm/m128, pimm8'                       , 'rmi:     66 0f c6 /r ib                  ' , 'cpuid=sse2'],
  ['vshufpd'  , 'W:vmm, vmm, vmm/vm, pimm8'                  , 'rvmi:    vex.nds.vl.66.0f.wig c6 /r ib   ' , 'cpuid=avx'],
  ['vshufpd'  , 'W:vmm {kz}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f.w1 c6 /r ib   ' , 'cpuid=avx512f-vl'],

  # => SHUFPS-Packed Interleave Shuffle of Quadruplets of Single-Precision Floating-Point Values
  ['shufps'   , 'xmm, xmm/m128, pimm8'                       , 'rmi:     0f c6 /r ib                  ' , 'cpuid=sse'],
  ['vshufps'  , 'W:vmm, vmm, vmm/vm, pimm8'                  , 'rvmi:    vex.nds.vl.0f.wig c6 /r ib   ' , 'cpuid=avx'],
  ['vshufps'  , 'W:vmm {kz}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.nds.vl.0f.w0 c6 /r ib   ' , 'cpuid=avx512f-vl'],

  # => SIDT-Store Interrupt Descriptor Table Register
  ['sidt'     , 'W:mem'              , 'm: 0f 01 /1'                            , ''],

  # => SLDT-Store Local Descriptor Table Register
  ['sldt'     , 'W:vr/m16'           , 'm:     wq   0f 00 /0        '           , ''],

  # => SMSW-Store Machine Status Word
  ['smsw'     , 'W:vr/m16'           , 'm:     os   0f 01 /4        '           , ''],

  # => SQRTPD-Square Root of Double-Precision Floating-Point Values
  ['sqrtpd'   , 'W:xmm, xmm/m128'                     , 'rm:    66 0f 51 /r              '       , 'cpuid=sse2'],
  ['vsqrtpd'  , 'W:vmm, vmm/vm'                       , 'rm:    vex.vl.66.0f.wig 51 /r   '       , 'cpuid=avx'],
  ['vsqrtpd'  , 'W:xmm {kz}, xmm/m128/b32'            , 'rm:fv: evex.128.66.0f.w1 51 /r  '       , 'cpuid=avx512f-vl'],
  ['vsqrtpd'  , 'W:ymm {kz}, ymm/m256/b32'            , 'rm:fv: evex.256.66.0f.w1 51 /r  '       , 'cpuid=avx512f-vl'],
  ['vsqrtpd'  , 'W:zmm {kz}, zmm/m512/b64 {er}'       , 'rm:fv: evex.512.66.0f.w1 51 /r  '       , 'cpuid=avx512f'],

  # => SQRTPS-Square Root of Single-Precision Floating-Point Values
  ['sqrtps'   , 'W:xmm, xmm/m128'                     , 'rm:    0f 51 /r              '          , 'cpuid=sse'],
  ['vsqrtps'  , 'W:vmm, vmm/vm'                       , 'rm:    vex.vl.0f.wig 51 /r   '          , 'cpuid=avx'],
  ['vsqrtps'  , 'W:vmm {kz}, vmm/vm/b32 {er}'         , 'rm:fv: evex.vl.0f.w0 51 /r   '          , 'cpuid=avx512f-vl'],

  # => SQRTSD-Compute Square Root of Scalar Double-Precision Floating-Point Value
  ['sqrtsd'   , 'W:xmm, xmm/m64'                      , 'rm:      f2 0f 51 /r                  ' , 'cpuid=sse2'],
  ['vsqrtsd'  , 'W:xmm, xmm, xmm/m64'                 , 'rvm:     vex.nds.128.f2.0f.wig 51 /r  ' , 'cpuid=avx'],
  ['vsqrtsd'  , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 51 /r  ' , 'cpuid=avx512f'],

  # => SQRTSS-Compute Square Root of Scalar Single-Precision Value
  ['sqrtss'   , 'W:xmm, xmm/m32'                      , 'rm:      f3 0f 51 /r                  ' , 'cpuid=sse'],
  ['vsqrtss'  , 'W:xmm, xmm, xmm/m32'                 , 'rvm:     vex.nds.128.f3.0f.wig 51 /r  ' , 'cpuid=avx'],
  ['vsqrtss'  , 'W:xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 51 /r  ' , 'cpuid=avx512f'],

  # => STAC-Set AC Flag in EFLAGS Register
  ['stac'     , ''                   , '0f 01 cb'                               , 'cpuid=smap'],

  # => STC-Set Carry Flag
  ['stc'      , ''                   , 'f9'                                     , 'eflags.cf=S'],

  # => STD-Set Direction Flag
  ['std'      , ''                   , 'fd'                                     , 'eflags.df=S'],

  # => STI-Set Interrupt Flag
  ['sti'      , ''                   , 'fb'                                     , 'eflags.if=S'],

  # => STMXCSR-Store MXCSR Register State
  ['stmxcsr'  , 'W:m32'              , 'm: 0f ae /3             '               , 'cpuid=sse'],
  ['vstmxcsr' , 'W:m32'              , 'm: vex.lz.0f.wig ae /3  '               , 'cpuid=avx'],

  # => STOS/STOSB/STOSW/STOSD/STOSQ-Store String
  ['stosw'    , 'W:<[es:*di]>, <ax>'        , '       os16 ab              '           , 'rep eflags.df=T'],
  ['stosb'    , 'W:<[es:*di]>, <al>'        , '            aa              '           , 'rep eflags.df=T'],
  ['stosd'    , 'W:<[es:*di]>, <eax>'       , '       os32 ab              '           , 'rep eflags.df=T'],
  #['stos'     , 'vm, <rax>, <rdi>'          , 'm:     os   ab              '           , 'rep eflags.df=T'],
  #['stos'     , 'm8'                        , 'm:          aa              '           , 'rep eflags.df=T'],
  ['stosq'    , 'W:<[rdi]>, <rax>'          , 'x64:   os64 ab              '           , 'rep eflags.df=T'],

  # => STR-Store Task Register
  ['str'      , 'W:r/m16'            , 'm: 0f 00 /1'                            , ''],

  # => SUB-Subtract
  ['sub'      , 'al, imm8'           , 'i:           2c ib           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , '*ax, imm.low'       , 'i:      os   2d iz           '          , 'eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'r8x, r8x/m8'        , 'rm:          2a /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'vr, vr/vm'          , 'rm:     os   2b /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'r8x/m8, imm8'       , 'mi:          80 /5 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'vr/vm, imm8'        , 'mi:     os   83 /5 ib        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'r8x/m8, r8x'        , 'mr:          28 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'vr/vm, imm.low'     , 'mi:     os   81 /5 iz        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['sub'      , 'vr/vm, vr'          , 'mr:     os   29 /r           '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => SUBPD-Subtract Packed Double-Precision Floating-Point Values
  ['subpd'    , 'xmm, xmm/m128'                            , 'rm:     66 0f 5c /r                  '  , 'cpuid=sse2'],
  ['vsubpd'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f.wig 5c /r   '  , 'cpuid=avx'],
  ['vsubpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f.w1 5c /r   '  , 'cpuid=avx512f-vl'],

  # => SUBPS-Subtract Packed Single-Precision Floating-Point Values
  ['subps'    , 'xmm, xmm/m128'                            , 'rm:     0f 5c /r                  '     , 'cpuid=sse'],
  ['vsubps'   , 'W:vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.0f.wig 5c /r   '     , 'cpuid=avx'],
  ['vsubps'   , 'W:vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.0f.w0 5c /r   '     , 'cpuid=avx512f-vl'],

  # => SUBSD-Subtract Scalar Double-Precision Floating-Point Value
  ['subsd'    , 'xmm, xmm/m64'                        , 'rm:      f2 0f 5c /r                  ' , 'cpuid=sse2'],
  ['vsubsd'   , 'W:xmm, xmm, xmm/m64'                 , 'rvm:     vex.nds.128.f2.0f.wig 5c /r  ' , 'cpuid=avx'],
  ['vsubsd'   , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.f2.0f.w1 5c /r  ' , 'cpuid=avx512f'],

  # => SUBSS-Subtract Scalar Single-Precision Floating-Point Value
  ['subss'    , 'xmm, xmm/m32'                        , 'rm:      f3 0f 5c /r                  ' , 'cpuid=sse'],
  ['vsubss'   , 'W:xmm, xmm, xmm/m32'                 , 'rvm:     vex.nds.128.f3.0f.wig 5c /r  ' , 'cpuid=avx'],
  ['vsubss'   , 'W:xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.nds.lig.f3.0f.w0 5c /r  ' , 'cpuid=avx512f'],

  # => SWAPGS-Swap GS Base Register
  ['swapgs'   , ''                   , 'x64: 0f 01 f8'                          , ''],

  # => SYSCALL-Fast System Call
  ['syscall'  , ''                   , 'x64: 0f 05'                             , ''],

  # => SYSENTER-Fast System Call
  ['sysenter' , ''                   , '0f 34'                                  , 'eflags.if=M eflags.vm=M'],

  # => SYSEXIT-Fast Return from Fast System Call
  ['sysexit'   , ''                   , '     os32 0f 35           '             , ''],
  ['sysexit64' , ''                   , 'x64: os64 0f 35           '             , ''],

  # => SYSRET-Return From Fast System Call
  ['sysret64' , ''                   , 'x64: os64 0f 07           '             , ''],
  ['sysret'   , ''                   , 'x64: os32 0f 07           '             , ''],

  # => TEST-Logical Compare
  ['test'     , 'R:*ax, imm.low'       , 'i:      os   a9 iz           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['test'     , 'R:al, imm8'           , 'i:           a8 ib           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['test'     , 'R:vr/vm, vr'          , 'mr:     os   85 /r           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['test'     , 'R:vr/vm, imm.low'     , 'mi:     os   f7 /0 iz        '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['test'     , 'R:r8x/m8, imm8'       , 'mi:          f6 /0 ib        '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['test'     , 'R:r8x/m8, r8x'        , 'mr:          84 /r           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],

  # => TZCNT-Count the Number of Trailing Zero Bits
  ['tzcnt'    , 'W:vr, vr/vm'        , 'rm:     os   f3 0f bc /r     '          , 'cpuid=bmi1 eflags.of=U eflags.sf=U eflags.zf=M eflags.af=U eflags.pf=U eflags.cf=M'],

  # => UCOMISD-Unordered Compare Scalar Double-Precision Floating-Point Values and Set EFLAGS
  ['ucomisd'  , 'R:xmm, xmm/m64'             , 'rm:     66 0f 2e /r              '      , 'cpuid=sse2'],
  ['vucomisd' , 'R:xmm, xmm/m64'             , 'rm:     vex.128.66.0f.wig 2e /r  '      , 'cpuid=avx'],
  ['vucomisd' , 'W:xmm, xmm/m64 {sae}'       , 'rm:t1s: evex.lig.66.0f.w1 2e /r  '      , 'cpuid=avx512f'],

  # => UCOMISS-Unordered Compare Scalar Single-Precision Floating-Point Values and Set EFLAGS
  ['ucomiss'  , 'R:xmm, xmm/m32'             , 'rm:     0f 2e /r              '         , 'cpuid=sse eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=M eflags.cf=M'],
  ['vucomiss' , 'R:xmm, xmm/m32'             , 'rm:     vex.128.0f.wig 2e /r  '         , 'cpuid=avx'],
  ['vucomiss' , 'W:xmm, xmm/m32 {sae}'       , 'rm:t1s: evex.lig.0f.w0 2e /r  '         , 'cpuid=avx512f'],

  # => UD2-Undefined Instruction
  ['ud2'      , ''                   , '0f 0b'                                  , ''],

  # => UNPCKHPD-Unpack and Interleave High Packed Double-Precision Floating-Point Values
  ['unpckhpd'  , 'xmm, xmm/m128'                       , 'rm:     66 0f 15 /r                  '  , 'cpuid=sse2'],
  ['vunpckhpd' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig 15 /r   '  , 'cpuid=avx'],
  ['vunpckhpd' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 15 /r   '  , 'cpuid=avx512f-vl'],

  # => UNPCKHPS-Unpack and Interleave High Packed Single-Precision Floating-Point Values
  ['unpckhps'  , 'xmm, xmm/m128'                       , 'rm:     0f 15 /r                  '     , 'cpuid=sse'],
  ['vunpckhps' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.0f.wig 15 /r   '     , 'cpuid=avx'],
  ['vunpckhps' , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.0f.w0 15 /r   '     , 'cpuid=avx512f-vl'],

  # => UNPCKLPD-Unpack and Interleave Low Packed Double-Precision Floating-Point Values
  ['unpcklpd'  , 'xmm, xmm/m128'                       , 'rm:     66 0f 14 /r                  '  , 'cpuid=sse2'],
  ['vunpcklpd' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig 14 /r   '  , 'cpuid=avx'],
  ['vunpcklpd' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 14 /r   '  , 'cpuid=avx512f-vl'],

  # => UNPCKLPS-Unpack and Interleave Low Packed Single-Precision Floating-Point Values
  ['unpcklps'  , 'xmm, xmm/m128'                       , 'rm:     0f 14 /r                  '     , 'cpuid=sse'],
  ['vunpcklps' , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.0f.wig 14 /r   '     , 'cpuid=avx'],
  ['vunpcklps' , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.0f.w0 14 /r   '     , 'cpuid=avx512f-vl'],



  # ===>                               V to Z instructions                               <===

  # => VALIGND/VALIGNQ-Align Doubleword/Quadword Vectors
  ['valignd'  , 'W:vmm {kz}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w0 03 /r ib   ' , 'cpuid=avx512f-vl'],
  ['valignq'  , 'W:vmm {kz}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w1 03 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VBLENDMPD/VBLENDMPS-Blend Float64/Float32 Vectors Using an OpMask Control
  ['vblendmpd' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 65 /r   ' , 'cpuid=avx512f-vl'],
  ['vblendmps' , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 65 /r   ' , 'cpuid=avx512f-vl'],

  # => VBROADCAST-Load with Broadcast Floating-Point Data
  ['vbroadcastsd'    , 'W:ymm, m64'                , 'rm:     vex.256.66.0f38.w0 19 /r   '    , 'cpuid=avx'],
  ['vbroadcastf128'  , 'W:ymm, m128'               , 'rm:     vex.256.66.0f38.w0 1a /r   '    , 'cpuid=avx'],
  ['vbroadcastss'    , 'W:vmm, m32'                , 'rm:     vex.vl.66.0f38.w0 18 /r    '    , 'cpuid=avx'],
  ['vbroadcastf32x8' , 'W:zmm {kz}, m256'          , 'rm:t8:  evex.512.66.0f38.w0 1b /r  '    , 'cpuid=avx512dq'],
  ['vbroadcastf64x2' , 'W:vmm {kz}, m128'          , 'rm:t2:  evex.vu.66.0f38.w1 1a /r   '    , 'cpuid=avx512dq-vl'],
  ['vbroadcastf32x2' , 'W:vmm {kz}, xmm/m64'       , 'rm:t2:  evex.vu.66.0f38.w0 19 /r   '    , 'cpuid=avx512dq-vl'],
  ['vbroadcastf64x4' , 'W:zmm {kz}, m256'          , 'rm:t4:  evex.512.66.0f38.w1 1b /r  '    , 'cpuid=avx512f'],
  ['vbroadcastf32x4' , 'W:vmm {kz}, m128'          , 'rm:t4:  evex.vu.66.0f38.w0 1a /r   '    , 'cpuid=avx512f-vl'],
  ['vbroadcastss'    , 'W:vmm {kz}, xmm/m32'       , 'rm:t1s: evex.vl.66.0f38.w0 18 /r   '    , 'cpuid=avx512f-vl'],
  ['vbroadcastsd'    , 'W:vmm {kz}, xmm/m64'       , 'rm:t1s: evex.vu.66.0f38.w1 19 /r   '    , 'cpuid=avx512f-vl'],

  # => VPBROADCASTM-Broadcast Mask to Vector Register
  ['vpbroadcastmb2q' , 'W:vmm, k'           , 'rm: evex.vl.f3.0f38.w1 2a /r   '        , 'cpuid=avx512cd-vl'],
  ['vpbroadcastmw2d' , 'W:vmm, k'           , 'rm: evex.vl.f3.0f38.w0 3a /r   '        , 'cpuid=avx512cd-vl'],

  # => VCOMPRESSPD-Store Sparse Packed Double-Precision Floating-Point Values into Dense Memory
  ['vcompresspd' , 'W:vmm/vm {kz}, vmm'         , 'mr:t1s: evex.vl.66.0f38.w1 8a /r   '    , 'cpuid=avx512f-vl'],

  # => VCOMPRESSPS-Store Sparse Packed Single-Precision Floating-Point Values into Dense Memory
  ['vcompressps' , 'W:vmm/vm {kz}, vmm'         , 'mr:t1s: evex.vl.66.0f38.w0 8a /r   '    , 'cpuid=avx512f-vl'],

  # => VCVTPD2QQ-Convert Packed Double-Precision Floating-Point Values to Packed Quadword Integers
  ['vcvtpd2qq' , 'W:vmm {kz}, vmm/vm/b64 {er}'         , 'rm:fv: evex.vl.66.0f.w1 7b /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTPD2UDQ-Convert Packed Double-Precision Floating-Point Values to Packed Unsigned Doubleword Integers
  ['vcvtpd2udq' , 'W:vmm.low {kz}, vmm/vm/b64 {er}'     , 'rm:fv: evex.vl.0f.w1 79 /r   '          , 'cpuid=avx512f-vl'],

  # => VCVTPD2UQQ-Convert Packed Double-Precision Floating-Point Values to Packed Unsigned Quadword Integers
  ['vcvtpd2uqq' , 'W:vmm {kz}, vmm/vm/b64 {er}'         , 'rm:fv: evex.vl.66.0f.w1 79 /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTPH2PS-Convert 16-bit FP values to Single-Precision FP values
  ['vcvtph2ps' , 'W:vmm, xmm/vm.2'                  , 'rm:     vex.vl.66.0f38.w0 13 /r    '    , 'cpuid=f16c'],
  ['vcvtph2ps' , 'W:vmm {kz}, vmm.low/vm.2 {sae}'   , 'rm:hvm: evex.vl.66.0f38.w0 13 /r   '    , 'cpuid=avx512f-vl'],

  # => VCVTPS2PH-Convert Single-Precision FP value to 16-bit FP value
  ['vcvtps2ph' , 'W:xmm/vm.2, vmm, pimm8'                  , 'mri:     vex.vl.66.0f3a.w0 1d /r ib    ' , 'cpuid=f16c'],
  ['vcvtps2ph' , 'W:vmm.low/vm.2 {kz}, vmm {sae}, pimm8'   , 'mri:hvm: evex.vl.66.0f3a.w0 1d /r ib   ' , 'cpuid=avx512f-vl'],

  # => VCVTPS2UDQ-Convert Packed Single-Precision Floating-Point Values to Packed Unsigned Doubleword Integer Values
  ['vcvtps2udq' , 'W:vmm {kz}, vmm/vm/b32 {er}'         , 'rm:fv: evex.vl.0f.w0 79 /r   '          , 'cpuid=avx512f-vl'],

  # => VCVTPS2QQ-Convert Packed Single Precision Floating-Point Values to Packed Singed Quadword Integer Values
  ['vcvtps2qq' , 'W:vmm {kz}, vmm.low/vm.2/b32 {er}'   , 'rm:hv: evex.vl.66.0f.w0 7b /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTPS2UQQ-Convert Packed Single Precision Floating-Point Values to Packed Unsigned Quadword Integer Values
  ['vcvtps2uqq' , 'W:vmm {kz}, vmm.low/vm.2/b32 {er}'   , 'rm:hv: evex.vl.66.0f.w0 79 /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTQQ2PD-Convert Packed Quadword Integers to Packed Double-Precision Floating-Point Values
  ['vcvtqq2pd' , 'W:vmm {kz}, vmm/vm/b64 {er}'         , 'rm:fv: evex.vl.f3.0f.w1 e6 /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTQQ2PS-Convert Packed Quadword Integers to Packed Single-Precision Floating-Point Values
  ['vcvtqq2ps' , 'W:vmm.low {kz}, vmm/vm/b64 {er}'     , 'rm:fv: evex.vl.0f.w1 5b /r   '          , 'cpuid=avx512dq-vl'],

  # => VCVTSD2USI-Convert Scalar Double-Precision Floating-Point Value to Unsigned Doubleword Integer
  ['vcvtsd2usi' , 'W:r32, xmm/m64 {er}'       , 'rm:t1f:     evex.lig.f2.0f.w0 79 /r  '  , 'cpuid=avx512f'],
  ['vcvtsd2usi' , 'W:r64, xmm/m64 {er}'       , 'x64:rm:t1f: evex.lig.f2.0f.w1 79 /r  '  , 'cpuid=avx512f'],

  # => VCVTSS2USI-Convert Scalar Single-Precision Floating-Point Value to Unsigned Doubleword Integer
  ['vcvtss2usi' , 'W:r32, xmm/m32 {er}'       , 'rm:t1f:     evex.lig.f3.0f.w0 79 /r  '  , 'cpuid=avx512f'],
  ['vcvtss2usi' , 'W:r64, xmm/m32 {er}'       , 'x64:rm:t1f: evex.lig.f3.0f.w1 79 /r  '  , 'cpuid=avx512f'],

  # => VCVTTPD2QQ-Convert with Truncation Packed Double-Precision Floating-Point Values to Packed Quadword Integers
  ['vcvttpd2qq' , 'W:vmm {kz}, vmm/vm/b64 {sae}'         , 'rm:fv: evex.vl.66.0f.w1 7a /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTTPD2UDQ-Convert with Truncation Packed Double-Precision Floating-Point Values to Packed Unsigned Doubleword Integers
  ['vcvttpd2udq' , 'W:vmm.low {kz}, vmm/vm/b64 {sae}'     , 'rm:fv: evex.vl.0f.w1 78 /r   '          , 'cpuid=avx512f-vl'],

  # => VCVTTPD2UQQ-Convert with Truncation Packed Double-Precision Floating-Point Values to Packed Unsigned Quadword Integers
  ['vcvttpd2uqq' , 'W:vmm {kz}, vmm/vm/b64 {sae}'         , 'rm:fv: evex.vl.66.0f.w1 78 /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTTPS2UDQ-Convert with Truncation Packed Single-Precision Floating-Point Values to Packed Unsigned Doubleword Integer Values
  ['vcvttps2udq' , 'W:vmm {kz}, vmm/vm/b32 {sae}'         , 'rm:fv: evex.vl.0f.w0 78 /r   '          , 'cpuid=avx512f-vl'],

  # => VCVTTPS2QQ-Convert with Truncation Packed Single Precision Floating-Point Values to Packed Singed Quadword Integer Values
  ['vcvttps2qq' , 'W:vmm {kz}, vmm.low/vm.2/b32 {sae}'   , 'rm:hv: evex.vl.66.0f.w0 7a /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTTPS2UQQ-Convert with Truncation Packed Single Precision Floating-Point Values to Packed Unsigned Quadword Integer Values
  ['vcvttps2uqq' , 'W:vmm {kz}, vmm.low/vm.2/b32 {sae}'   , 'rm:hv: evex.vl.66.0f.w0 78 /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTTSD2USI-Convert with Truncation Scalar Double-Precision Floating-Point Value to Unsigned Integer
  ['vcvttsd2usi' , 'W:r32, xmm/m64 {sae}'       , 'rm:t1f:     evex.lig.f2.0f.w0 78 /r  '  , 'cpuid=avx512f'],
  ['vcvttsd2usi' , 'W:r64, xmm/m64 {sae}'       , 'x64:rm:t1f: evex.lig.f2.0f.w1 78 /r  '  , 'cpuid=avx512f'],

  # => VCVTTSS2USI-Convert with Truncation Scalar Single-Precision Floating-Point Value to Unsigned Integer
  ['vcvttss2usi' , 'W:r32, xmm/m32 {sae}'       , 'rm:t1f:     evex.lig.f3.0f.w0 78 /r  '  , 'cpuid=avx512f'],
  ['vcvttss2usi' , 'W:r64, xmm/m32 {sae}'       , 'x64:rm:t1f: evex.lig.f3.0f.w1 78 /r  '  , 'cpuid=avx512f'],

  # => VCVTUDQ2PD-Convert Packed Unsigned Doubleword Integers to Packed Double-Precision Floating-Point Values
  ['vcvtudq2pd' , 'W:vmm {kz}, vmm.low/vm.2/b32'   , 'rm:hv: evex.vl.f3.0f.w0 7a /r   '       , 'cpuid=avx512f-vl'],

  # => VCVTUDQ2PS-Convert Packed Unsigned Doubleword Integers to Packed Single-Precision Floating-Point Values
  ['vcvtudq2ps' , 'W:vmm {kz}, vmm/vm/b32 {er}'         , 'rm:fv: evex.vl.f2.0f.w0 7a /r   '       , 'cpuid=avx512f-vl'],

  # => VCVTUQQ2PD-Convert Packed Unsigned Quadword Integers to Packed Double-Precision Floating-Point Values
  ['vcvtuqq2pd' , 'W:vmm {kz}, vmm/vm/b64 {er}'         , 'rm:fv: evex.vl.f3.0f.w1 7a /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTUQQ2PS-Convert Packed Unsigned Quadword Integers to Packed Single-Precision Floating-Point Values
  ['vcvtuqq2ps' , 'W:vmm.low {kz}, vmm/vm/b64 {er}'     , 'rm:fv: evex.vl.f2.0f.w1 7a /r   '       , 'cpuid=avx512dq-vl'],

  # => VCVTUSI2SD-Convert Unsigned Integer to Scalar Double-Precision Floating-Point Value
  ['vcvtusi2sd' , 'W:xmm, xmm, r/m32'            , 'rvm:t1s:     evex.nds.lig.f2.0f.w0 7b /r  ' , 'cpuid=avx512f'],
  ['vcvtusi2sd' , 'W:xmm, xmm, r/m64 {er}'       , 'x64:rvm:t1s: evex.nds.lig.f2.0f.w1 7b /r  ' , 'cpuid=avx512f'],

  # => VCVTUSI2SS-Convert Unsigned Integer to Scalar Single-Precision Floating-Point Value
  ['vcvtusi2ss' , 'W:xmm, xmm, r/m32 {er}'       , 'rvm:t1s:     evex.nds.lig.f3.0f.w0 7b /r  ' , 'cpuid=avx512f'],
  ['vcvtusi2ss' , 'W:xmm, xmm, r/m64 {er}'       , 'x64:rvm:t1s: evex.nds.lig.f3.0f.w1 7b /r  ' , 'cpuid=avx512f'],

  # => VDBPSADBW-Double Block Packed Sum-Absolute-Differences (SAD) on Unsigned Bytes
  ['vdbpsadbw' , 'W:vmm {kz}, vmm, vmm/vm, pimm8'         , 'rvmi:fvm: evex.nds.vl.66.0f3a.w0 42 /r ib   ' , 'cpuid=avx512bw-vl'],

  # => VEXPANDPD-Load Sparse Packed Double-Precision Floating-Point Values from Dense Memory
  ['vexpandpd' , 'W:vmm {kz}, vmm/vm'         , 'rm:t1s: evex.vl.66.0f38.w1 88 /r   '    , 'cpuid=avx512f-vl'],

  # => VEXPANDPS-Load Sparse Packed Single-Precision Floating-Point Values from Dense Memory
  ['vexpandps' , 'W:vmm {kz}, vmm/vm'         , 'rm:t1s: evex.vl.66.0f38.w0 88 /r   '    , 'cpuid=avx512f-vl'],

  # => VERR/VERW-Verify a Segment for Reading or Writing
  ['verw'     , 'R:r/m16'            , 'm: 0f 00 /5        '                    , 'eflags.zf=M'],
  ['verr'     , 'R:r/m16'            , 'm: 0f 00 /4        '                    , 'eflags.zf=M'],

  # => VEXP2PD-Approximation to the Exponential 2^x of Packed Double-Precision Floating-Point Values with Less Than 2^-23 Relative Error
  ['vexp2pd'  , 'zmm {kz}, zmm/m512/b64 {sae}'       , 'rm:fv: evex.512.66.0f38.w1 c8 /r'       , 'cpuid=avx512er'],

  # => VEXP2PS-Approximation to the Exponential 2^x of Packed Single-Precision Floating-Point Values with Less Than 2^-23 Relative Error
  ['vexp2ps'  , 'zmm {kz}, zmm/m512/b32 {sae}'       , 'rm:fv: evex.512.66.0f38.w0 c8 /r'       , 'cpuid=avx512er'],

  # => VEXTRACTF128/VEXTRACTF32x4/VEXTRACTF64x2/VEXTRACTF32x8/VEXTRACTF64x4-Extr act Packed Floating-Point Values
  ['vextractf128'  , 'W:xmm/m128, ymm, pimm8'            , 'mri:    vex.256.66.0f3a.w0 19 /r ib   ' , 'cpuid=avx'],
  ['vextractf64x4' , 'W:ymm/m256 {kz}, zmm, pimm8'       , 'mri:t4: evex.512.66.0f3a.w1 1b /r ib  ' , 'cpuid=avx512f'],
  ['vextractf64x2' , 'W:xmm/m128 {kz}, vmm, pimm8'       , 'mri:t2: evex.vu.66.0f3a.w1 19 /r ib   ' , 'cpuid=avx512dq-vl'],
  ['vextractf32x8' , 'W:ymm/m256 {kz}, zmm, pimm8'       , 'mri:t8: evex.512.66.0f3a.w0 1b /r ib  ' , 'cpuid=avx512dq'],
  ['vextractf32x4' , 'W:xmm/m128 {kz}, vmm, pimm8'       , 'mri:t4: evex.vu.66.0f3a.w0 19 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VEXTRACTI128/VEXTRACTI32x4/VEXTRACTI64x2/VEXTRACTI32x8/VEXTRACTI64x4-Extract packed Integer Values
  ['vextracti128'  , 'W:xmm/m128, ymm, pimm8'            , 'mri:    vex.256.66.0f3a.w0 39 /r ib   ' , 'cpuid=avx2'],
  ['vextracti32x4' , 'W:xmm/m128 {kz}, vmm, pimm8'       , 'mri:t4: evex.vu.66.0f3a.w0 39 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vextracti64x2' , 'W:xmm/m128 {kz}, vmm, pimm8'       , 'mri:t2: evex.vu.66.0f3a.w1 39 /r ib   ' , 'cpuid=avx512dq-vl'],
  ['vextracti32x8' , 'W:ymm/m256 {kz}, zmm, pimm8'       , 'mri:t8: evex.512.66.0f3a.w0 3b /r ib  ' , 'cpuid=avx512dq'],
  ['vextracti64x4' , 'W:ymm/m256 {kz}, zmm, pimm8'       , 'mri:t4: evex.512.66.0f3a.w1 3b /r ib  ' , 'cpuid=avx512f'],

  # => VFIXUPIMMPD-Fix Up Special Packed Float64 Values
  ['vfixupimmpd' , 'vmm {kz}, vmm, vmm/vm/b64 {sae}, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w1 54 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VFIXUPIMMPS-Fix Up Special Packed Float32 Values
  ['vfixupimmps' , 'vmm {kz}, vmm, vmm/vm/b32 {sae}, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w0 54 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VFIXUPIMMSD-Fix Up Special Scalar Float64 Value
  ['vfixupimmsd' , 'xmm {kz}, xmm, xmm/m64 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w1 55 /r ib' , 'cpuid=avx512f'],

  # => VFIXUPIMMSS-Fix Up Special Scalar Float32 Value
  ['vfixupimmss' , 'xmm {kz}, xmm, xmm/m32 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w0 55 /r ib' , 'cpuid=avx512f'],

  # => VFMADD132PD/VFMADD213PD/VFMADD231PD-Fused Multiply-Add of Packed Double-Precision Floating-Point Values
  ['vfmadd213pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 a8 /r    ' , 'cpuid=fma'],
  ['vfmadd231pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 b8 /r    ' , 'cpuid=fma'],
  ['vfmadd132pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 98 /r    ' , 'cpuid=fma'],
  ['vfmadd231pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 b8 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmadd132pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 98 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmadd213pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 a8 /r   ' , 'cpuid=avx512f-vl'],

  # => VFMADD132PS/VFMADD213PS/VFMADD231PS-Fused Multiply-Add of Packed Single-Precision Floating-Point Values
  ['vfmadd231ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 b8 /r    ' , 'cpuid=fma'],
  ['vfmadd132ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 98 /r    ' , 'cpuid=fma'],
  ['vfmadd213ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 a8 /r    ' , 'cpuid=fma'],
  ['vfmadd231ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 b8 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmadd213ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 a8 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmadd132ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 98 /r   ' , 'cpuid=avx512f-vl'],

  # => VFMADD132SD/VFMADD213SD/VFMADD231SD-Fused Multiply-Add of Scalar Double-Precision Floating-Point Values
  ['vfmadd132sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 99 /r   ' , 'cpuid=fma'],
  ['vfmadd231sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 b9 /r   ' , 'cpuid=fma'],
  ['vfmadd213sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 a9 /r   ' , 'cpuid=fma'],
  ['vfmadd213sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 a9 /r  ' , 'cpuid=avx512f'],
  ['vfmadd132sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 99 /r  ' , 'cpuid=avx512f'],
  ['vfmadd231sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 b9 /r  ' , 'cpuid=avx512f'],

  # => VFMADD132SS/VFMADD213SS/VFMADD231SS-Fused Multiply-Add of Scalar Single-Precision Floating-Point Values
  ['vfmadd231ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 b9 /r   ' , 'cpuid=fma'],
  ['vfmadd213ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 a9 /r   ' , 'cpuid=fma'],
  ['vfmadd132ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 99 /r   ' , 'cpuid=fma'],
  ['vfmadd132ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 99 /r  ' , 'cpuid=avx512f'],
  ['vfmadd213ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 a9 /r  ' , 'cpuid=avx512f'],
  ['vfmadd231ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 b9 /r  ' , 'cpuid=avx512f'],

  # => VFMADDSUB132PD/VFMADDSUB213PD/VFMADDSUB231PD-Fused Multiply-Alternating Add/Subtract of Packed Double-Precision Floating-Point Values
  ['vfmaddsub231pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w1 b6 /r    ' , 'cpuid=fma'],
  ['vfmaddsub213pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w1 a6 /r    ' , 'cpuid=fma'],
  ['vfmaddsub132pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w1 96 /r    ' , 'cpuid=fma'],
  ['vfmaddsub231pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w1 b6 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmaddsub132pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w1 96 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmaddsub213pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w1 a6 /r   ' , 'cpuid=avx512f-vl'],

  # => VFMADDSUB132PS/VFMADDSUB213PS/VFMADDSUB231PS-Fused Multiply-Alternating Add/Subtract of Packed Single-Precision Floating-Point Values
  ['vfmaddsub231ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w0 b6 /r    ' , 'cpuid=fma'],
  ['vfmaddsub132ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w0 96 /r    ' , 'cpuid=fma'],
  ['vfmaddsub213ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w0 a6 /r    ' , 'cpuid=fma'],
  ['vfmaddsub132ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w0 96 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmaddsub231ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w0 b6 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmaddsub213ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w0 a6 /r   ' , 'cpuid=avx512f-vl'],

  # => VFMSUBADD132PD/VFMSUBADD213PD/VFMSUBADD231PD-Fused Multiply-Alternating Subtract/Add of Packed Double-Precision Floating-Point Values
  ['vfmsubadd132pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w1 97 /r    ' , 'cpuid=fma'],
  ['vfmsubadd213pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w1 a7 /r    ' , 'cpuid=fma'],
  ['vfmsubadd231pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w1 b7 /r    ' , 'cpuid=fma'],
  ['vfmsubadd132pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w1 97 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsubadd213pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w1 a7 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsubadd231pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w1 b7 /r   ' , 'cpuid=avx512f-vl'],

  # => VFMSUBADD132PS/VFMSUBADD213PS/VFMSUBADD231PS-Fused Multiply-Alternating Subtract/Add of Packed Single-Precision Floating-Point Values
  ['vfmsubadd231ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w0 b7 /r    ' , 'cpuid=fma'],
  ['vfmsubadd132ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w0 97 /r    ' , 'cpuid=fma'],
  ['vfmsubadd213ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.dds.vl.66.0f38.w0 a7 /r    ' , 'cpuid=fma'],
  ['vfmsubadd213ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w0 a7 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsubadd132ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w0 97 /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsubadd231ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.dds.vl.66.0f38.w0 b7 /r   ' , 'cpuid=avx512f-vl'],

  # => VFMSUB132PD/VFMSUB213PD/VFMSUB231PD-Fused Multiply-Subtract of Packed Double-Precision Floating-Point Values
  ['vfmsub231pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 ba /r    ' , 'cpuid=fma'],
  ['vfmsub132pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 9a /r    ' , 'cpuid=fma'],
  ['vfmsub213pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 aa /r    ' , 'cpuid=fma'],
  ['vfmsub132pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 9a /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsub231pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 ba /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsub213pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 aa /r   ' , 'cpuid=avx512f-vl'],

  # => VFMSUB132PS/VFMSUB213PS/VFMSUB231PS-Fused Multiply-Subtract of Packed Single-Precision Floating-Point Values
  ['vfmsub231ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 ba /r    ' , 'cpuid=fma'],
  ['vfmsub132ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 9a /r    ' , 'cpuid=fma'],
  ['vfmsub213ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 aa /r    ' , 'cpuid=fma'],
  ['vfmsub213ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 aa /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsub132ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 9a /r   ' , 'cpuid=avx512f-vl'],
  ['vfmsub231ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 ba /r   ' , 'cpuid=avx512f-vl'],

  # => VFMSUB132SD/VFMSUB213SD/VFMSUB231SD-Fused Multiply-Subtract of Scalar Double-Precision Floating-Point Values
  ['vfmsub231sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 bb /r   ' , 'cpuid=fma'],
  ['vfmsub213sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 ab /r   ' , 'cpuid=fma'],
  ['vfmsub132sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 9b /r   ' , 'cpuid=fma'],
  ['vfmsub231sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 bb /r  ' , 'cpuid=avx512f'],
  ['vfmsub213sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 ab /r  ' , 'cpuid=avx512f'],
  ['vfmsub132sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 9b /r  ' , 'cpuid=avx512f'],

  # => VFMSUB132SS/VFMSUB213SS/VFMSUB231SS-Fused Multiply-Subtract of Scalar Single-Precision Floating-Point Values
  ['vfmsub231ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 bb /r   ' , 'cpuid=fma'],
  ['vfmsub213ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 ab /r   ' , 'cpuid=fma'],
  ['vfmsub132ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 9b /r   ' , 'cpuid=fma'],
  ['vfmsub231ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 bb /r  ' , 'cpuid=avx512f'],
  ['vfmsub132ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 9b /r  ' , 'cpuid=avx512f'],
  ['vfmsub213ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 ab /r  ' , 'cpuid=avx512f'],

  # => VFNMADD132PD/VFNMADD213PD/VFNMADD231PD-Fused Negative Multiply-Add of Packed Double-Precision Floating-Point Values
  ['vfnmadd213pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 ac /r    ' , 'cpuid=fma'],
  ['vfnmadd132pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 9c /r    ' , 'cpuid=fma'],
  ['vfnmadd231pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 bc /r    ' , 'cpuid=fma'],
  ['vfnmadd231pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 bc /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmadd213pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 ac /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmadd132pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 9c /r   ' , 'cpuid=avx512f-vl'],

  # => VFNMADD132PS/VFNMADD213PS/VFNMADD231PS-Fused Negative Multiply-Add of Packed Single-Precision Floating-Point Values
  ['vfnmadd132ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 9c /r    ' , 'cpuid=fma'],
  ['vfnmadd213ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 ac /r    ' , 'cpuid=fma'],
  ['vfnmadd231ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 bc /r    ' , 'cpuid=fma'],
  ['vfnmadd213ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 ac /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmadd132ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 9c /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmadd231ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 bc /r   ' , 'cpuid=avx512f-vl'],

  # => VFNMADD132SD/VFNMADD213SD/VFNMADD231SD-Fused Negative Multiply-Add of Scalar Double-Precision Floating-Point Values
  ['vfnmadd213sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 ad /r   ' , 'cpuid=fma'],
  ['vfnmadd231sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 bd /r   ' , 'cpuid=fma'],
  ['vfnmadd132sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 9d /r   ' , 'cpuid=fma'],
  ['vfnmadd213sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 ad /r  ' , 'cpuid=avx512f'],
  ['vfnmadd132sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 9d /r  ' , 'cpuid=avx512f'],
  ['vfnmadd231sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 bd /r  ' , 'cpuid=avx512f'],

  # => VFNMADD132SS/VFNMADD213SS/VFNMADD231SS-Fused Negative Multiply-Add of Scalar Single-Precision Floating-Point Values
  ['vfnmadd231ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 bd /r   ' , 'cpuid=fma'],
  ['vfnmadd213ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 ad /r   ' , 'cpuid=fma'],
  ['vfnmadd132ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 9d /r   ' , 'cpuid=fma'],
  ['vfnmadd231ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 bd /r  ' , 'cpuid=avx512f'],
  ['vfnmadd132ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 9d /r  ' , 'cpuid=avx512f'],
  ['vfnmadd213ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 ad /r  ' , 'cpuid=avx512f'],

  # => VFNMSUB132PD/VFNMSUB213PD/VFNMSUB231PD-Fused Negative Multiply-Subtract of Packed Double-Precision Floating-Point Values
  ['vfnmsub231pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 be /r    ' , 'cpuid=fma'],
  ['vfnmsub132pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 9e /r    ' , 'cpuid=fma'],
  ['vfnmsub213pd' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w1 ae /r    ' , 'cpuid=fma'],
  ['vfnmsub231pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 be /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmsub132pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 9e /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmsub213pd' , 'vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 ae /r   ' , 'cpuid=avx512f-vl'],

  # => VFNMSUB132PS/VFNMSUB213PS/VFNMSUB231PS-Fused Negative Multiply-Subtract of Packed Single-Precision Floating-Point Values
  ['vfnmsub231ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 be /r    ' , 'cpuid=fma'],
  ['vfnmsub213ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 ae /r    ' , 'cpuid=fma'],
  ['vfnmsub132ps' , 'vmm, vmm, vmm/vm'                       , 'rvm:    vex.nds.vl.66.0f38.w0 9e /r    ' , 'cpuid=fma'],
  ['vfnmsub213ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 ae /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmsub132ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 9e /r   ' , 'cpuid=avx512f-vl'],
  ['vfnmsub231ps' , 'vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 be /r   ' , 'cpuid=avx512f-vl'],

  # => VFNMSUB132SD/VFNMSUB213SD/VFNMSUB231SD-Fused Negative Multiply-Subtract of Scalar Double-Precision Floating-Point Values
  ['vfnmsub231sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 bf /r   ' , 'cpuid=fma'],
  ['vfnmsub132sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 9f /r   ' , 'cpuid=fma'],
  ['vfnmsub213sd' , 'xmm, xmm, xmm/m64'                 , 'rvm:     vex.dds.lig.66.0f38.w1 af /r   ' , 'cpuid=fma'],
  ['vfnmsub213sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 af /r  ' , 'cpuid=avx512f'],
  ['vfnmsub231sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 bf /r  ' , 'cpuid=avx512f'],
  ['vfnmsub132sd' , 'xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w1 9f /r  ' , 'cpuid=avx512f'],

  # => VFNMSUB132SS/VFNMSUB213SS/VFNMSUB231SS-Fused Negative Multiply-Subtract of Scalar Single-Precision Floating-Point Values
  ['vfnmsub231ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 bf /r   ' , 'cpuid=fma'],
  ['vfnmsub132ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 9f /r   ' , 'cpuid=fma'],
  ['vfnmsub213ss' , 'xmm, xmm, xmm/m32'                 , 'rvm:     vex.dds.lig.66.0f38.w0 af /r   ' , 'cpuid=fma'],
  ['vfnmsub231ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 bf /r  ' , 'cpuid=avx512f'],
  ['vfnmsub132ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 9f /r  ' , 'cpuid=avx512f'],
  ['vfnmsub213ss' , 'xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.dds.lig.66.0f38.w0 af /r  ' , 'cpuid=avx512f'],

  # => VFPCLASSPD-Tests Types Of a Packed Float64 Values
  ['vfpclasspd' , 'W:k {k}, vmm/vm/b64, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w1 66 /r ib   ' , 'cpuid=avx512dq-vl'],

  # => VFPCLASSPS-Tests Types Of a Packed Float32 Values
  ['vfpclassps' , 'W:k {k}, vmm/vm/b32, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w0 66 /r ib   ' , 'cpuid=avx512dq-vl'],

  # => VFPCLASSSD-Tests Types Of a Scalar Float64 Values
  ['vfpclasssd' , 'W:k {k}, xmm/m64, pimm8'       , 'rmi:t1s: evex.lig.66.0f3a.w1 67 /r ib'  , 'cpuid=avx512dq'],

  # => VFPCLASSSS-Tests Types Of a Scalar Float32 Values
  ['vfpclassss' , 'W:k {k}, xmm/m32, pimm8'       , 'rmi:t1s: evex.lig.66.0f3a.w0 67 /r ib'  , 'cpuid=avx512dq'],

  # => VGATHERDPD/VGATHERQPD-Gather Packed DP FP Values Using Signed Dword/Qword Indices
  ['vgatherdpd' , 'vmm, vm32x, X:vmm'       , 'rmv: vex.dds.vl.66.0f38.w1 92 /r vsib   ' , 'cpuid=avx2'],
  ['vgatherqpd' , 'vmm, vm64v, X:vmm'       , 'rmv: vex.dds.vl.66.0f38.w1 93 /r vsib   ' , 'cpuid=avx2'],

  # => VGATHERDPS/VGATHERQPS-Gather Packed SP FP values Using Signed Dword/Qword Indices
  ['vgatherqps' , 'xmm, vm64v, X:xmm'       , 'rmv: vex.dds.vl.66.0f38.w0 93 /r vsib   ' , 'cpuid=avx2'],
  ['vgatherdps' , 'vmm, vm32v, X:vmm'       , 'rmv: vex.dds.vl.66.0f38.w0 92 /r vsib   ' , 'cpuid=avx2'],

  # => VGATHERDPS/VGATHERDPD-Gather Packed Single, Packed Double with Signed Dword
  ['vgatherdpd' , 'W:vmm {k}, vm32l'       , 'rm:t1s: evex.vl.66.0f38.w1 92 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vgatherdps' , 'W:vmm {k}, vm32v'       , 'rm:t1s: evex.vl.66.0f38.w0 92 /r vsib   ' , 'cpuid=avx512f-vl'],

  # => VGATHERPF0DPS/VGATHERPF0QPS/VGATHERPF0DPD/VGATHERPF0QPD-Sparse Prefetch Packed SP/DP Data Values with Signed Dword, Signed Qword Indices Using T0 Hint
  ['vgatherpf0dpd' , 'vm32y {k}'          , 'm:t1s: evex.512.66.0f38.w1 c6 /1  '     , 'cpuid=avx512pf'],
  ['vgatherpf0dps' , 'vm32z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c6 /1  '     , 'cpuid=avx512pf'],
  ['vgatherpf0qps' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c7 /1  '     , 'cpuid=avx512pf'],
  ['vgatherpf0qpd' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w1 c7 /1  '     , 'cpuid=avx512pf'],

  # => VGATHERPF1DPS/VGATHERPF1QPS/VGATHERPF1DPD/VGATHERPF1QPD-Sparse Prefetch Packed SP/DP Data Values with Signed Dword, Signed Qword Indices Using T1 Hint
  ['vgatherpf1qpd' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w1 c7 /2  '     , 'cpuid=avx512pf'],
  ['vgatherpf1dps' , 'vm32z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c6 /2  '     , 'cpuid=avx512pf'],
  ['vgatherpf1dpd' , 'vm32y {k}'          , 'm:t1s: evex.512.66.0f38.w1 c6 /2  '     , 'cpuid=avx512pf'],
  ['vgatherpf1qps' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c7 /2  '     , 'cpuid=avx512pf'],

  # => VGATHERQPS/VGATHERQPD-Gather Packed Single, Packed Double with Signed Qword Indices
  ['vgatherqpd' , 'W:vmm {k}, vm64v'       , 'rm:t1s: evex.vl.66.0f38.w1 93 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vgatherqps' , 'W:vmm.low {k}, vm64v'   , 'rm:t1s: evex.vl.66.0f38.w0 93 /r vsib   ' , 'cpuid=avx512f-vl'],

  # => VPGATHERDD/VPGATHERQD-Gather Packed Dword Values Using Signed Dword/Qword Indices
  ['vpgatherdd' , 'vmm, vm32v, X:vmm'       , 'rmv: vex.dds.vl.66.0f38.w0 90 /r vsib   ' , 'cpuid=avx2'],
  ['vpgatherqd' , 'xmm, vm64v, X:xmm'       , 'rmv: vex.dds.vl.66.0f38.w0 91 /r vsib   ' , 'cpuid=avx2'],

  # => VPGATHERDD/VPGATHERDQ-Gather Packed Dword, Packed Qword with Signed Dword Indices
  ['vpgatherdd' , 'W:vmm {k}, vm32v'       , 'rm:t1s: evex.vl.66.0f38.w0 90 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vpgatherdq' , 'W:vmm {k}, vm32l'       , 'rm:t1s: evex.vl.66.0f38.w1 90 /r vsib   ' , 'cpuid=avx512f-vl'],

  # => VPGATHERDQ/VPGATHERQQ-Gather Packed Qword Values Using Signed Dword/Qword Indices
  ['vpgatherdq' , 'vmm, vm32x, X:vmm'       , 'rmv: vex.dds.vl.66.0f38.w1 90 /r vsib   ' , 'cpuid=avx2'],
  ['vpgatherqq' , 'vmm, vm64v, X:vmm'       , 'rmv: vex.dds.vl.66.0f38.w1 91 /r vsib   ' , 'cpuid=avx2'],

  # => VPGATHERQD/VPGATHERQQ-Gather Packed Dword, Packed Qword with Signed Qword Indices
  ['vpgatherqd' , 'W:vmm.low {k}, vm64v'   , 'rm:t1s: evex.vl.66.0f38.w0 91 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vpgatherqq' , 'W:vmm {k}, vm64v'       , 'rm:t1s: evex.vl.66.0f38.w1 91 /r vsib   ' , 'cpuid=avx512f-vl'],

  # => VGETEXPPD-Convert Exponents of Packed DP FP Values to DP FP Values
  ['vgetexppd' , 'W:vmm {kz}, vmm/vm/b64 {sae}'         , 'rm:fv: evex.vl.66.0f38.w1 42 /r   '     , 'cpuid=avx512f-vl'],

  # => VGETEXPPS-Convert Exponents of Packed SP FP Values to SP FP Values
  ['vgetexpps' , 'W:vmm {kz}, vmm/vm/b32 {sae}'         , 'rm:fv: evex.vl.66.0f38.w0 42 /r   '     , 'cpuid=avx512f-vl'],

  # => VGETEXPSD-Convert Exponents of Scalar DP FP Values to DP FP Value
  ['vgetexpsd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w1 43 /r' , 'cpuid=avx512f'],

  # => VGETEXPSS-Convert Exponents of Scalar SP FP Values to SP FP Value
  ['vgetexpss' , 'W:xmm {kz}, xmm, xmm/m32 {sae}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w0 43 /r' , 'cpuid=avx512f'],

  # => VGETMANTPD-Extract Float64 Vector of Normalized Mantissas from Float64 Vector
  ['vgetmantpd' , 'W:vmm {kz}, vmm/vm/b64 {sae}, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w1 26 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VGETMANTPS-Extract Float32 Vector of Normalized Mantissas from Float32 Vector
  ['vgetmantps' , 'W:vmm {kz}, vmm/vm/b32 {sae}, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w0 26 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VGETMANTSD-Extract Float64 of Normalized Mantissas from Float64 Scalar
  ['vgetmantsd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w1 27 /r ib' , 'cpuid=avx512f'],

  # => VGETMANTSS-Extract Float32 Vector of Normalized Mantissa from Float32 Vector
  ['vgetmantss' , 'W:xmm {kz}, xmm, xmm/m32 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w0 27 /r ib' , 'cpuid=avx512f'],

  # => VINSERTF128/VINSERTF32x4/VINSERTF64x2/VINSERTF32x8/VINSERTF64x4-Insert Packed Floating-Point Values
  ['vinsertf128'  , 'W:ymm, ymm, xmm/m128, pimm8'            , 'rvmi:    vex.nds.256.66.0f3a.w0 18 /r ib   ' , 'cpuid=avx'],
  ['vinsertf64x4' , 'W:zmm {kz}, zmm, ymm/m256, pimm8'       , 'rvmi:t4: evex.nds.512.66.0f3a.w1 1a /r ib  ' , 'cpuid=avx512f'],
  ['vinsertf64x2' , 'W:vmm {kz}, vmm, xmm/m128, pimm8'       , 'rvmi:t2: evex.nds.vu.66.0f3a.w1 18 /r ib   ' , 'cpuid=avx512dq-vl'],
  ['vinsertf32x4' , 'W:vmm {kz}, vmm, xmm/m128, pimm8'       , 'rvmi:t4: evex.nds.vu.66.0f3a.w0 18 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vinsertf32x8' , 'W:zmm {kz}, zmm, ymm/m256, pimm8'       , 'rvmi:t8: evex.nds.512.66.0f3a.w0 1a /r ib  ' , 'cpuid=avx512dq'],

  # => VINSERTI128/VINSERTI32x4/VINSERTI64x2/VINSERTI32x8/VINSERTI64x4-Insert Packed Integer Values
  ['vinserti128'  , 'W:ymm, ymm, xmm/m128, pimm8'            , 'rvmi:    vex.nds.256.66.0f3a.w0 38 /r ib   ' , 'cpuid=avx2'],
  ['vinserti32x8' , 'W:zmm {kz}, zmm, ymm/m256, pimm8'       , 'rvmi:t8: evex.nds.512.66.0f3a.w0 3a /r ib  ' , 'cpuid=avx512dq'],
  ['vinserti32x4' , 'W:vmm {kz}, vmm, xmm/m128, pimm8'       , 'rvmi:t4: evex.nds.vu.66.0f3a.w0 38 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vinserti64x2' , 'W:vmm {kz}, vmm, xmm/m128, pimm8'       , 'rvmi:t2: evex.nds.vu.66.0f3a.w1 38 /r ib   ' , 'cpuid=avx512dq-vl'],
  ['vinserti64x4' , 'W:zmm {kz}, zmm, ymm/m256, pimm8'       , 'rvmi:t4: evex.nds.512.66.0f3a.w1 3a /r ib  ' , 'cpuid=avx512f'],

  # => VMASKMOV-Conditional SIMD Packed Loads and Stores
  ['vmaskmovps' , 'W:vmm, vmm, vm'         , 'rvm: vex.nds.vl.66.0f38.w0 2c /r   '    , 'cpuid=avx'],
  ['vmaskmovps' , 'W:vm, vmm, vmm'         , 'mvr: vex.nds.vl.66.0f38.w0 2e /r   '    , 'cpuid=avx'],
  ['vmaskmovpd' , 'W:vm, vmm, vmm'         , 'mvr: vex.nds.vl.66.0f38.w0 2f /r   '    , 'cpuid=avx'],
  ['vmaskmovpd' , 'W:vmm, vmm, vm'         , 'rvm: vex.nds.vl.66.0f38.w0 2d /r   '    , 'cpuid=avx'],

  # => VPBLENDD-Blend Packed Dwords
  ['vpblendd' , 'W:vmm, vmm, vmm/vm, pimm8'         , 'rvmi: vex.nds.vl.66.0f3a.w0 02 /r ib   ' , 'cpuid=avx2'],

  # => VPBLENDMB/VPBLENDMW-Blend Byte/Word Vectors Using an Opmask Control
  ['vpblendmb' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.w0 66 /r   ' , 'cpuid=avx512bw-vl'],
  ['vpblendmw' , 'W:vmm {kz}, vmm, vmm/vm'         , 'rvm:fvm: evex.nds.vl.66.0f38.w1 66 /r   ' , 'cpuid=avx512bw-vl'],

  # => VPBLENDMD/VPBLENDMQ-Blend Int32/Int64 Vectors Using an OpMask Control
  ['vpblendmd' , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 64 /r   ' , 'cpuid=avx512f-vl'],
  ['vpblendmq' , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 64 /r   ' , 'cpuid=avx512f-vl'],

  # => VPBROADCASTB/W/D/Q-Load with Broadcast Integer Data from General Purpose Register
  ['vpbroadcastb' , 'W:vmm {kz}, reg'       , 'rm:     evex.vl.66.0f38.w0 7a /r   '    , 'cpuid=avx512bw-vl'],
  ['vpbroadcastd' , 'W:vmm {kz}, r32'       , 'rm:     evex.vl.66.0f38.w0 7c /r   '    , 'cpuid=avx512f-vl'],
  ['vpbroadcastw' , 'W:vmm {kz}, reg'       , 'rm:     evex.vl.66.0f38.w0 7b /r   '    , 'cpuid=avx512bw-vl'],
  ['vpbroadcastq' , 'W:vmm {kz}, r64'       , 'x64:rm: evex.vl.66.0f38.w1 7c /r   '    , 'cpuid=avx512f-vl'],

  # => VPBROADCAST-Load Integer and Broadcast
  ['vpbroadcastw'    , 'W:vmm, xmm/m16'            , 'rm:     vex.vl.66.0f38.w0 79 /r    '    , 'cpuid=avx2'],
  ['vpbroadcastq'    , 'W:vmm, xmm/m64'            , 'rm:     vex.vl.66.0f38.w0 59 /r    '    , 'cpuid=avx2'],
  ['vpbroadcastd'    , 'W:vmm, xmm/m32'            , 'rm:     vex.vl.66.0f38.w0 58 /r    '    , 'cpuid=avx2'],
  ['vbroadcasti128'  , 'W:ymm, m128'               , 'rm:     vex.256.66.0f38.w0 5a /r   '    , 'cpuid=avx2'],
  ['vpbroadcastb'    , 'W:vmm, xmm/m8'             , 'rm:     vex.vl.66.0f38.w0 78 /r    '    , 'cpuid=avx2'],
  ['vbroadcasti64x2' , 'W:vmm {kz}, m128'          , 'rm:t2:  evex.vu.66.0f38.w1 5a /r   '    , 'cpuid=avx512dq-vl'],
  ['vbroadcasti32x2' , 'W:vmm {kz}, xmm/m64'       , 'rm:t2:  evex.vl.66.0f38.w0 59 /r   '    , 'cpuid=avx512dq-vl'],
  ['vbroadcasti32x8' , 'W:zmm {kz}, m256'          , 'rm:t8:  evex.512.66.0f38.w0 5b /r  '    , 'cpuid=avx512dq'],
  ['vbroadcasti32x4' , 'W:vmm {kz}, m128'          , 'rm:t4:  evex.vu.66.0f38.w0 5a /r   '    , 'cpuid=avx512f-vl'],
  ['vbroadcasti64x4' , 'W:zmm {kz}, m256'          , 'rm:t4:  evex.512.66.0f38.w1 5b /r  '    , 'cpuid=avx512f'],
  ['vpbroadcastw'    , 'W:vmm {kz}, xmm/m16'       , 'rm:t1s: evex.vl.66.0f38.w0 79 /r   '    , 'cpuid=avx512bw-vl'],
  ['vpbroadcastb'    , 'W:vmm {kz}, xmm/m8'        , 'rm:t1s: evex.vl.66.0f38.w0 78 /r   '    , 'cpuid=avx512bw-vl'],
  ['vpbroadcastd'    , 'W:vmm {kz}, xmm/m32'       , 'rm:t1s: evex.vl.66.0f38.w0 58 /r   '    , 'cpuid=avx512f-vl'],
  ['vpbroadcastq'    , 'W:vmm {kz}, xmm/m64'       , 'rm:t1s: evex.vl.66.0f38.w1 59 /r   '    , 'cpuid=avx512f-vl'],

  # => VPCMPB/VPCMPUB-Compare Packed Byte Values Into Mask
  ['vpcmpb'   , 'W:k {k}, vmm, vmm/vm, pimm8'         , 'rvmi:fvm: evex.nds.vl.66.0f3a.w0 3f /r ib   ' , 'cpuid=avx512bw-vl'],
  ['vpcmpub'  , 'W:k {k}, vmm, vmm/vm, pimm8'         , 'rvmi:fvm: evex.nds.vl.66.0f3a.w0 3e /r ib   ' , 'cpuid=avx512bw-vl'],

  # => VPCMPD/VPCMPUD-Compare Packed Integer Values into Mask
  ['vpcmpud'  , 'W:k {k}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w0 1e /r ib   ' , 'cpuid=avx512f-vl'],
  ['vpcmpd'   , 'W:k {k}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w0 1f /r ib   ' , 'cpuid=avx512f-vl'],

  # => VPCMPQ/VPCMPUQ-Compare Packed Integer Values into Mask
  ['vpcmpq'   , 'W:k {k}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w1 1f /r ib   ' , 'cpuid=avx512f-vl'],
  ['vpcmpuq'  , 'W:k {k}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w1 1e /r ib   ' , 'cpuid=avx512f-vl'],

  # => VPCMPW/VPCMPUW-Compare Packed Word Values Into Mask
  ['vpcmpw'   , 'W:k {k}, vmm, vmm/vm, pimm8'         , 'rvmi:fvm: evex.nds.vl.66.0f3a.w1 3f /r ib   ' , 'cpuid=avx512bw-vl'],
  ['vpcmpuw'  , 'W:k {k}, vmm, vmm/vm, pimm8'         , 'rvmi:fvm: evex.nds.vl.66.0f3a.w1 3e /r ib   ' , 'cpuid=avx512bw-vl'],

  # => VPCOMPRESSD-Store Sparse Packed Doubleword Integer Values into Dense Memory/Register
  ['vpcompressd' , 'W:vmm/vm {kz}, vmm'         , 'mr:t1s: evex.vl.66.0f38.w0 8b /r   '    , 'cpuid=avx512f-vl'],

  # => VPCOMPRESSQ-Store Sparse Packed Quadword Integer Values into Dense Memory/Register
  ['vpcompressq' , 'W:vmm/vm {kz}, vmm'         , 'mr:t1s: evex.vl.66.0f38.w1 8b /r   '    , 'cpuid=avx512f-vl'],

  # => VPCONFLICTD/Q-Detect Conflicts Within a Vector of Packed Dword/Qword Values into Dense Memory/Register
  ['vpconflictd' , 'W:vmm {kz}, vmm/vm/b32'         , 'rm:fv: evex.vl.66.0f38.w0 c4 /r   '     , 'cpuid=avx512cd-vl'],
  ['vpconflictq' , 'W:vmm {kz}, vmm/vm/b64'         , 'rm:fv: evex.vl.66.0f38.w1 c4 /r   '     , 'cpuid=avx512cd-vl'],

  # => VPERM2F128-Permute Floating-Point Values
  ['vperm2f128' , 'W:ymm, ymm, ymm/m256, pimm8'       , 'rvmi: vex.nds.256.66.0f3a.w0 06 /r ib'  , 'cpuid=avx'],

  # => VPERM2I128-Permute Integer Values
  ['vperm2i128' , 'W:ymm, ymm, ymm/m256, pimm8'       , 'rvmi: vex.nds.256.66.0f3a.w0 46 /r ib'  , 'cpuid=avx2'],

  # => VPERMD/VPERMW-Permute Packed Doublewords/Words Elements
  ['vpermd'   , 'W:ymm, ymm, ymm/m256'                , 'rvm:     vex.nds.256.66.0f38.w0 36 /r   ' , 'cpuid=avx2'],
  ['vpermd'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vu.66.0f38.w0 36 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermw'   , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.w1 8d /r   ' , 'cpuid=avx512bw-vl'],

  # => VPERMI2W/D/Q/PS/PD-Full Permute From Two Tables Overwriting the Index
  ['vpermi2d'  , 'vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.dds.vl.66.0f38.w0 76 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermi2q'  , 'vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.dds.vl.66.0f38.w1 76 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermi2pd' , 'vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.dds.vl.66.0f38.w1 77 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermi2ps' , 'vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.dds.vl.66.0f38.w0 77 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermi2w'  , 'vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.dds.vl.66.0f38.w1 75 /r   ' , 'cpuid=avx512bw-vl'],

  # => VPERMILPD-Permute In-Lane of Pairs of Double-Precision Floating-Point Values
  ['vpermilpd' , 'W:vmm, vmm/vm, pimm8'                  , 'rmi:    vex.vl.66.0f3a.w0 05 /r ib     ' , 'cpuid=avx'],
  ['vpermilpd' , 'W:vmm, vmm, vmm/vm'                    , 'rvm:    vex.nds.vl.66.0f38.w0 0d /r    ' , 'cpuid=avx'],
  ['vpermilpd' , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w1 05 /r ib    ' , 'cpuid=avx512f-vl'],
  ['vpermilpd' , 'W:vmm {kz}, vmm, vmm/vm/b64'           , 'rvm:fv: evex.nds.vl.66.0f38.w1 0d /r   ' , 'cpuid=avx512f-vl'],

  # => VPERMILPS-Permute In-Lane of Quadruples of Single-Precision Floating-Point Values
  ['vpermilps' , 'W:vmm, vmm/vm, pimm8'                  , 'rmi:    vex.vl.66.0f3a.w0 04 /r ib     ' , 'cpuid=avx'],
  ['vpermilps' , 'W:vmm, vmm, vmm/vm'                    , 'rvm:    vex.nds.vl.66.0f38.w0 0c /r    ' , 'cpuid=avx'],
  ['vpermilps' , 'W:vmm {kz}, vmm, vmm/vm/b32'           , 'rvm:fv: evex.nds.vl.66.0f38.w0 0c /r   ' , 'cpuid=avx512f-vl'],
  ['vpermilps' , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w0 04 /r ib    ' , 'cpuid=avx512f-vl'],

  # => VPERMPD-Permute Double-Precision Floating-Point Elements
  ['vpermpd'  , 'W:ymm, ymm/m256, pimm8'                , 'rmi:    vex.256.66.0f3a.w1 01 /r ib    ' , 'cpuid=avx2'],
  ['vpermpd'  , 'W:vmm {kz}, vmm, vmm/vm/b64'           , 'rvm:fv: evex.nds.vu.66.0f38.w1 16 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermpd'  , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'rmi:fv: evex.vu.66.0f3a.w1 01 /r ib    ' , 'cpuid=avx512f-vl'],

  # => VPERMPS-Permute Single-Precision Floating-Point Elements
  ['vpermps'  , 'W:ymm, ymm, ymm/m256'                , 'rvm:    vex.256.66.0f38.w0 16 /r       ' , 'cpuid=avx2'],
  ['vpermps'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vu.66.0f38.w0 16 /r   ' , 'cpuid=avx512f-vl'],

  # => VPERMQ-Qwords Element Permutation
  ['vpermq'   , 'W:ymm, ymm/m256, pimm8'                , 'rmi:    vex.256.66.0f3a.w1 00 /r ib    ' , 'cpuid=avx2'],
  ['vpermq'   , 'W:vmm {kz}, vmm, vmm/vm/b64'           , 'rvm:fv: evex.nds.vu.66.0f38.w1 36 /r   ' , 'cpuid=avx512f-vl'],
  ['vpermq'   , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'rmi:fv: evex.vu.66.0f3a.w1 00 /r ib    ' , 'cpuid=avx512f-vl'],

  # => VPEXPANDD-Load Sparse Packed Doubleword Integer Values from Dense Memory/Register
  ['vpexpandd' , 'W:vmm {kz}, vmm/vm'         , 'rm:t1s: evex.vl.66.0f38.w0 89 /r   '    , 'cpuid=avx512f-vl'],

  # => VPEXPANDQ-Load Sparse Packed Quadword Integer Values from Dense Memory/Register
  ['vpexpandq' , 'W:vmm {kz}, vmm/vm'         , 'rm:t1s: evex.vl.66.0f38.w1 89 /r   '    , 'cpuid=avx512f-vl'],

  # => VPLZCNTD/Q-Count the Number of Leading Zero Bits for Packed Dword, Packed Qword Values
  ['vplzcntd' , 'W:vmm {kz}, vmm/vm/b32'         , 'rm:fv: evex.vl.66.0f38.w0 44 /r   '     , 'cpuid=avx512cd-vl'],
  ['vplzcntq' , 'W:vmm {kz}, vmm/vm/b64'         , 'rm:fv: evex.vl.66.0f38.w1 44 /r   '     , 'cpuid=avx512cd-vl'],

  # => VPMASKMOV-Conditional SIMD Integer Packed Loads and Stores
  ['vpmaskmovq' , 'W:vm, vmm, vmm'         , 'mvr: vex.nds.vl.66.0f38.w1 8e /r   '    , 'cpuid=avx2'],
  ['vpmaskmovd' , 'W:vm, vmm, vmm'         , 'mvr: vex.nds.vl.66.0f38.w0 8e /r   '    , 'cpuid=avx2'],
  ['vpmaskmovd' , 'W:vmm, vmm, vm'         , 'rvm: vex.nds.vl.66.0f38.w0 8c /r   '    , 'cpuid=avx2'],
  ['vpmaskmovq' , 'W:vmm, vmm, vm'         , 'rvm: vex.nds.vl.66.0f38.w1 8c /r   '    , 'cpuid=avx2'],

  # => VPMOVM2B/VPMOVM2W/VPMOVM2D/VPMOVM2Q-Convert a Mask Register to a Vector Register
  ['vpmovm2d' , 'W:vmm, k'           , 'rm: evex.vl.f3.0f38.w0 38 /r   '        , 'cpuid=avx512dq-vl'],
  ['vpmovm2q' , 'W:vmm, k'           , 'rm: evex.vl.f3.0f38.w1 38 /r   '        , 'cpuid=avx512dq-vl'],
  ['vpmovm2w' , 'W:vmm, k'           , 'rm: evex.vl.f3.0f38.w1 28 /r   '        , 'cpuid=avx512bw-vl'],
  ['vpmovm2b' , 'W:vmm, k'           , 'rm: evex.vl.f3.0f38.w0 28 /r   '        , 'cpuid=avx512bw-vl'],

  # => VPMOVB2M/VPMOVW2M/VPMOVD2M/VPMOVQ2M-Convert a Vector Register to a Mask
  ['vpmovd2m' , 'W:k, vmm'           , 'rm: evex.vl.f3.0f38.w0 39 /r   '        , 'cpuid=avx512dq-vl'],
  ['vpmovb2m' , 'W:k, vmm'           , 'rm: evex.vl.f3.0f38.w0 29 /r   '        , 'cpuid=avx512bw-vl'],
  ['vpmovw2m' , 'W:k, vmm'           , 'rm: evex.vl.f3.0f38.w1 29 /r   '        , 'cpuid=avx512bw-vl'],
  ['vpmovq2m' , 'W:k, vmm'           , 'rm: evex.vl.f3.0f38.w1 39 /r   '        , 'cpuid=avx512dq-vl'],

  # => VPMOVQB/VPMOVSQB/VPMOVUSQB-Down Convert QWord to Byte
  ['vpmovsqb'  , 'W:xmm/vm.8 {kz}, vmm'      , 'mr:ovm: evex.vl.f3.0f38.w0 22 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovusqb' , 'W:xmm/vm.8 {kz}, vmm'      , 'mr:ovm: evex.vl.f3.0f38.w0 12 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovqb'   , 'W:xmm/vm.8 {kz}, vmm'      , 'mr:ovm: evex.vl.f3.0f38.w0 32 /r   '    , 'cpuid=avx512f-vl'],

  # => VPMOVQW/VPMOVSQW/VPMOVUSQW-Down Convert QWord to Word
  ['vpmovqw'   , 'W:xmm/vm.4 {kz}, vmm'       , 'mr:qvm: evex.vl.f3.0f38.w0 34 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovsqw'  , 'W:xmm/vm.4 {kz}, vmm'       , 'mr:qvm: evex.vl.f3.0f38.w0 24 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovusqw' , 'W:xmm/vm.4 {kz}, vmm'       , 'mr:qvm: evex.vl.f3.0f38.w0 14 /r   '    , 'cpuid=avx512f-vl'],

  # => VPMOVQD/VPMOVSQD/VPMOVUSQD-Down Convert QWord to DWord
  ['vpmovusqd' , 'W:ymm/m256 {kz}, zmm'       , 'mr:hvm: evex.512.f3.0f38.w0 15 /r  '    , 'cpuid=avx512f'],
  ['vpmovsqd'  , 'W:xmm/vm.2 {kz}, vmm'       , 'mr:fvm: evex.vx.f3.0f38.w0 25 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovqd'   , 'W:xmm/m128 {kz}, vmm'       , 'mr:fvm: evex.vx.f3.0f38.w0 35 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovsqd'  , 'W:ymm/m256 {kz}, zmm'       , 'mr:hvm: evex.512.f3.0f38.w0 25 /r  '    , 'cpuid=avx512f'],
  ['vpmovusqd' , 'W:xmm/vm.2 {kz}, vmm'       , 'mr:fvm: evex.vx.f3.0f38.w0 15 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovqd'   , 'W:ymm/m256 {kz}, zmm'       , 'mr:hvm: evex.512.f3.0f38.w0 35 /r  '    , 'cpuid=avx512f'],

  # => VPMOVDB/VPMOVSDB/VPMOVUSDB-Down Convert DWord to Byte
  ['vpmovusdb' , 'W:xmm/vm.4 {kz}, vmm'       , 'mr:qvm: evex.vl.f3.0f38.w0 11 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovdb'   , 'W:xmm/vm.4 {kz}, vmm'       , 'mr:qvm: evex.vl.f3.0f38.w0 31 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovsdb'  , 'W:xmm/vm.4 {kz}, vmm'       , 'mr:qvm: evex.vl.f3.0f38.w0 21 /r   '    , 'cpuid=avx512f-vl'],

  # => VPMOVDW/VPMOVSDW/VPMOVUSDW-Down Convert DWord to Word
  ['vpmovsdw'  , 'W:vmm.low/vm.2 {kz}, vmm'   , 'mr:hvm: evex.vl.f3.0f38.w0 23 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovusdw' , 'W:vmm.low/vm.2 {kz}, vmm'   , 'mr:hvm: evex.vl.f3.0f38.w0 13 /r   '    , 'cpuid=avx512f-vl'],
  ['vpmovdw'   , 'W:vmm.low/vm.2 {kz}, vmm'   , 'mr:hvm: evex.vl.f3.0f38.w0 33 /r   '    , 'cpuid=avx512f-vl'],

  # => VPMOVWB/VPMOVSWB/VPMOVUSWB-Down Convert Word to Byte
  ['vpmovwb'   , 'W:vmm.low/vm.2 {kz}, vmm'   , 'mr:hvm: evex.vl.f3.0f38.w0 30 /r   '    , 'cpuid=avx512bw-vl'],
  ['vpmovswb'  , 'W:vmm.low/vm.2 {kz}, vmm'   , 'mr:hvm: evex.vl.f3.0f38.w0 20 /r   '    , 'cpuid=avx512bw-vl'],
  ['vpmovuswb' , 'W:vmm.low/vm.2 {kz}, vmm'   , 'mr:hvm: evex.vl.f3.0f38.w0 10 /r   '    , 'cpuid=avx512bw-vl'],

  # => PROLD/PROLVD/PROLQ/PROLVQ-Bit Rotate Left
  ['vprold'   , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'vmi:fv: evex.ndd.vl.66.0f.w0 72 /1 ib   ' , 'cpuid=avx512f-vl'],
  ['vprolq'   , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'vmi:fv: evex.ndd.vl.66.0f.w1 72 /1 ib   ' , 'cpuid=avx512f-vl'],
  ['vprolvd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'           , 'rvm:fv: evex.nds.vl.66.0f38.w0 15 /r    ' , 'cpuid=avx512f-vl'],
  ['vprolvq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'           , 'rvm:fv: evex.nds.vl.66.0f38.w1 15 /r    ' , 'cpuid=avx512f-vl'],

  # => PRORD/PRORVD/PRORQ/PRORVQ-Bit Rotate Right
  ['vprorq'   , 'W:vmm {kz}, vmm/vm/b64, pimm8'         , 'vmi:fv: evex.ndd.vl.66.0f.w1 72 /0 ib   ' , 'cpuid=avx512f-vl'],
  ['vprord'   , 'W:vmm {kz}, vmm/vm/b32, pimm8'         , 'vmi:fv: evex.ndd.vl.66.0f.w0 72 /0 ib   ' , 'cpuid=avx512f-vl'],
  ['vprorvq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'           , 'rvm:fv: evex.nds.vl.66.0f38.w1 14 /r    ' , 'cpuid=avx512f-vl'],
  ['vprorvd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'           , 'rvm:fv: evex.nds.vl.66.0f38.w0 14 /r    ' , 'cpuid=avx512f-vl'],

  # => VPSCATTERDD/VPSCATTERDQ/VPSCATTERQD/VPSCATTERQQ-Scatter Packed Dword, Packed Qword with Signed Dword, Signed Qword Indices
  ['vpscatterqq' , 'vm64v {k}, vmm'       , 'mr:t1s: evex.vl.66.0f38.w1 a1 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vpscatterdq' , 'vm32l {k}, vmm'       , 'mr:t1s: evex.vl.66.0f38.w1 a0 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vpscatterdd' , 'vm32v {k}, vmm'       , 'mr:t1s: evex.vl.66.0f38.w0 a0 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vpscatterqd' , 'vm64v {k}, vmm.low'   , 'mr:t1s: evex.vl.66.0f38.w0 a1 /r vsib   ' , 'cpuid=avx512f-vl'],

  # => VPSLLVW/VPSLLVD/VPSLLVQ-Variable Bit Shift Left Logical
  ['vpsllvq'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.w1 47 /r    ' , 'cpuid=avx2'],
  ['vpsllvd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.w0 47 /r    ' , 'cpuid=avx2'],
  ['vpsllvd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f38.w0 47 /r   ' , 'cpuid=avx512f-vl'],
  ['vpsllvq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f38.w1 47 /r   ' , 'cpuid=avx512f-vl'],
  ['vpsllvw'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.w1 12 /r   ' , 'cpuid=avx512bw-vl'],

  # => VPSRAVW/VPSRAVD/VPSRAVQ-Variable Bit Shift Right Arithmetic
  ['vpsravd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.w0 46 /r    ' , 'cpuid=avx2'],
  ['vpsravd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f38.w0 46 /r   ' , 'cpuid=avx512f-vl'],
  ['vpsravq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f38.w1 46 /r   ' , 'cpuid=avx512f-vl'],
  ['vpsravw'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.w1 11 /r   ' , 'cpuid=avx512bw-vl'],

  # => VPSRLVW/VPSRLVD/VPSRLVQ-Variable Bit Shift Right Logical
  ['vpsrlvd'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.w0 45 /r    ' , 'cpuid=avx2'],
  ['vpsrlvq'  , 'W:vmm, vmm, vmm/vm'                  , 'rvm:     vex.nds.vl.66.0f38.w1 45 /r    ' , 'cpuid=avx2'],
  ['vpsrlvq'  , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f38.w1 45 /r   ' , 'cpuid=avx512f-vl'],
  ['vpsrlvd'  , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f38.w0 45 /r   ' , 'cpuid=avx512f-vl'],
  ['vpsrlvw'  , 'W:vmm {kz}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.w1 10 /r   ' , 'cpuid=avx512bw-vl'],

  # => VPTERNLOGD/VPTERNLOGQ-Bitwise Ternary Logic
  ['vpternlogd' , 'vmm {kz}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.dds.vl.66.0f3a.w0 25 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vpternlogq' , 'vmm {kz}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.dds.vl.66.0f3a.w1 25 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VPTESTMB/VPTESTMW/VPTESTMD/VPTESTMQ-Logical AND and Set Mask
  ['vptestmq' , 'W:k {k}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.66.0f38.w1 27 /r   ' , 'cpuid=avx512f-vl'],
  ['vptestmd' , 'W:k {k}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.66.0f38.w0 27 /r   ' , 'cpuid=avx512f-vl'],
  ['vptestmb' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.w0 26 /r   ' , 'cpuid=avx512bw-vl'],
  ['vptestmw' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.66.0f38.w1 26 /r   ' , 'cpuid=avx512bw-vl'],

  # => VPTESTNMB/W/D/Q-Logical NAND and Set
  ['vptestnmd' , 'W:k {k}, vmm, vmm/vm/b32'         , 'rvm:fv:  evex.nds.vl.f3.0f38.w0 27 /r   ' , 'cpuid=avx512f-vl'],
  ['vptestnmq' , 'W:k {k}, vmm, vmm/vm/b64'         , 'rvm:fv:  evex.nds.vl.f3.0f38.w1 27 /r   ' , 'cpuid=avx512f-vl'],
  ['vptestnmw' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.f3.0f38.w1 26 /r   ' , 'cpuid=avx512bw-vl'],
  ['vptestnmb' , 'W:k {k}, vmm, vmm/vm'             , 'rvm:fvm: evex.nds.vl.f3.0f38.w0 26 /r   ' , 'cpuid=avx512bw-vl'],

  # => VRANGEPD-Range Restriction Calculation For Packed Pairs of Float64 Values
  ['vrangepd' , 'W:vmm {kz}, vmm, vmm/vm/b64 {sae}, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w1 50 /r ib   ' , 'cpuid=avx512dq-vl'],

  # => VRANGEPS-Range Restriction Calculation For Packed Pairs of Float32 Values
  ['vrangeps' , 'W:vmm {kz}, vmm, vmm/vm/b32 {sae}, pimm8'         , 'rvmi:fv: evex.nds.vl.66.0f3a.w0 50 /r ib   ' , 'cpuid=avx512dq-vl'],

  # => VRANGESD-Range Restriction Calculation From a pair of Scalar Float64 Values
  ['vrangesd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w1 51 /r ib' , 'cpuid=avx512dq'],

  # => VRANGESS-Range Restriction Calculation From a Pair of Scalar Float32 Values
  ['vrangess' , 'W:xmm {kz}, xmm, xmm/m32 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w0 51 /r ib' , 'cpuid=avx512dq'],

  # => VRCP14PD-Compute Approximate Reciprocals of Packed Float64 Values
  ['vrcp14pd' , 'W:vmm {kz}, vmm/vm/b64'         , 'rm:fv: evex.vl.66.0f38.w1 4c /r   '     , 'cpuid=avx512f-vl'],

  # => VRCP14SD-Compute Approximate Reciprocal of Scalar Float64 Value
  ['vrcp14sd' , 'W:xmm {kz}, xmm, xmm/m64'       , 'rvm:t1s: evex.nds.lig.66.0f38.w1 4d /r' , 'cpuid=avx512f'],

  # => VRCP14PS-Compute Approximate Reciprocals of Packed Float32 Values
  ['vrcp14ps' , 'W:vmm {kz}, vmm/vm/b32'         , 'rm:fv: evex.vl.66.0f38.w0 4c /r   '     , 'cpuid=avx512f-vl'],

  # => VRCP14SS-Compute Approximate Reciprocal of Scalar Float32 Value
  ['vrcp14ss' , 'W:xmm {kz}, xmm, xmm/m32'       , 'rvm:t1s: evex.nds.lig.66.0f38.w0 4d /r' , 'cpuid=avx512f'],

  # => VRCP28PD-Approximation to the Reciprocal of Packed Double-Precision Floating-Point Values with Less Than 2^-28 Relative Error
  ['vrcp28pd' , 'W:zmm {kz}, zmm/m512/b64 {sae}'       , 'rm:fv: evex.512.66.0f38.w1 ca /r'       , 'cpuid=avx512er'],

  # => VRCP28SD-Approximation to the Reciprocal of Scalar Double-Precision Floating-Point Value with Less Than 2^-28 Relative Error
  ['vrcp28sd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w1 cb /r' , 'cpuid=avx512er'],

  # => VRCP28PS-Approximation to the Reciprocal of Packed Single-Precision Floating-Point Values with Less Than 2^-28 Relative Error
  ['vrcp28ps' , 'W:zmm {kz}, zmm/m512/b32 {sae}'       , 'rm:fv: evex.512.66.0f38.w0 ca /r'       , 'cpuid=avx512er'],

  # => VRCP28SS-Approximation to the Reciprocal of Scalar Single-Precision Floating-Point Value with Less Than 2^-28 Relative Error
  ['vrcp28ss' , 'W:xmm {kz}, xmm, xmm/m32 {sae}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w0 cb /r' , 'cpuid=avx512er'],

  # => VREDUCEPD-Perform Reduction Transformation on Packed Float64 Values
  ['vreducepd' , 'W:vmm {kz}, vmm/vm/b64 {sae}, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w1 56 /r ib   ' , 'cpuid=avx512dq-vl'],

  # => VREDUCESD-Perform a Reduction Transformation on a Scalar Float64 Value
  ['vreducesd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w1 57 /r ib' , 'cpuid=avx512dq'],

  # => VREDUCEPS-Perform Reduction Transformation on Packed Float32 Values
  ['vreduceps' , 'W:vmm {kz}, vmm/vm/b32 {sae}, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w0 56 /r ib   ' , 'cpuid=avx512dq-vl'],

  # => VREDUCESS-Perform a Reduction Transformation on a Scalar Float32 Value
  ['vreducess' , 'W:xmm {kz}, xmm, xmm/m32 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w0 57 /r ib' , 'cpuid=avx512dq'],

  # => VRNDSCALEPD-Round Packed Float64 Values To Include A Given Number Of Fraction Bits
  ['vrndscalepd' , 'W:vmm {kz}, vmm/vm/b64 {sae}, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w1 09 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VRNDSCALESD-Round Scalar Float64 Value To Include A Given Number Of Fraction Bits
  ['vrndscalesd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w1 0b /r ib' , 'cpuid=avx512f'],

  # => VRNDSCALEPS-Round Packed Float32 Values To Include A Given Number Of Fraction Bits
  ['vrndscaleps' , 'W:vmm {kz}, vmm/vm/b32 {sae}, pimm8'         , 'rmi:fv: evex.vl.66.0f3a.w0 08 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VRNDSCALESS-Round Scalar Float32 Value To Include A Given Number Of Fraction Bits
  ['vrndscaless' , 'W:xmm {kz}, xmm, xmm/m32 {sae}, pimm8'       , 'rvmi:t1s: evex.nds.lig.66.0f3a.w0 0a /r ib' , 'cpuid=avx512f'],

  # => VRSQRT14PD-Compute Approximate Reciprocals of Square Roots of Packed Float64 Values
  ['vrsqrt14pd' , 'W:vmm {kz}, vmm/vm/b64'         , 'rm:fv: evex.vl.66.0f38.w1 4e /r   '     , 'cpuid=avx512f-vl'],

  # => VRSQRT14SD-Compute Approximate Reciprocal of Square Root of Scalar Float64 Value
  ['vrsqrt14sd' , 'W:xmm {kz}, xmm, xmm/m64'       , 'rvm:t1s: evex.nds.lig.66.0f38.w1 4f /r' , 'cpuid=avx512f'],

  # => VRSQRT14PS-Compute Approximate Reciprocals of Square Roots of Packed Float32 Values
  ['vrsqrt14ps' , 'W:vmm {kz}, vmm/vm/b32'         , 'rm:fv: evex.vl.66.0f38.w0 4e /r   '     , 'cpuid=avx512f-vl'],

  # => VRSQRT14SS-Compute Approximate Reciprocal of Square Root of Scalar Float32 Value
  ['vrsqrt14ss' , 'W:xmm {kz}, xmm, xmm/m32'       , 'rvm:t1s: evex.nds.lig.66.0f38.w0 4f /r' , 'cpuid=avx512f'],

  # => VRSQRT28PD-Approximation to the Reciprocal Square Root of Packed Double-Precision Floating-Point Values with Less Than 2^-28 Relative Error
  ['vrsqrt28pd' , 'W:zmm {kz}, zmm/m512/b64 {sae}'       , 'rm:fv: evex.512.66.0f38.w1 cc /r'       , 'cpuid=avx512er'],

  # => VRSQRT28SD-Approximation to the Reciprocal Square Root of Scalar Double-Precision Floating-Point Value with Less Than 2^-28 Relative Error
  ['vrsqrt28sd' , 'W:xmm {kz}, xmm, xmm/m64 {sae}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w1 cd /r' , 'cpuid=avx512er'],

  # => VRSQRT28PS-Approximation to the Reciprocal Square Root of Packed Single-Precision Floating-Point Values with Less Than 2^-28 Relative Error
  ['vrsqrt28ps' , 'W:zmm {kz}, zmm/m512/b32 {sae}'       , 'rm:fv: evex.512.66.0f38.w0 cc /r'       , 'cpuid=avx512er'],

  # => VRSQRT28SS-Approximation to the Reciprocal Square Root of Scalar Single-Precision Floating-Point Value with Less Than 2^-28 Relative Error
  ['vrsqrt28ss' , 'W:xmm {kz}, xmm, xmm/m32 {sae}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w0 cd /r' , 'cpuid=avx512er'],

  # => VSCALEFPD-Scale Packed Float64 Values With Float64 Values
  ['vscalefpd' , 'W:vmm {kz}, vmm, vmm/vm/b64 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w1 2c /r   ' , 'cpuid=avx512f-vl'],

  # => VSCALEFSD-Scale Scalar Float64 Values With Float64 Values
  ['vscalefsd' , 'W:xmm {kz}, xmm, xmm/m64 {er}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w1 2d /r' , 'cpuid=avx512f'],

  # => VSCALEFPS-Scale Packed Float32 Values With Float32 Values
  ['vscalefps' , 'W:vmm {kz}, vmm, vmm/vm/b32 {er}'         , 'rvm:fv: evex.nds.vl.66.0f38.w0 2c /r   ' , 'cpuid=avx512f-vl'],

  # => VSCALEFSS-Scale Scalar Float32 Value With Float32 Value
  ['vscalefss' , 'W:xmm {kz}, xmm, xmm/m32 {er}'       , 'rvm:t1s: evex.nds.lig.66.0f38.w0 2d /r' , 'cpuid=avx512f'],

  # => VSCATTERDPS/VSCATTERDPD/VSCATTERQPS/VSCATTERQPD-Scatter Packed Single, Packed Double with Signed Dword and Qword Indices
  ['vscatterdps' , 'vm32v {k}, vmm'       , 'mr:t1s: evex.vl.66.0f38.w0 a2 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vscatterqps' , 'vm64v {k}, vmm.low'   , 'mr:t1s: evex.vl.66.0f38.w0 a3 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vscatterdpd' , 'vm32l {k}, vmm'       , 'mr:t1s: evex.vl.66.0f38.w1 a2 /r vsib   ' , 'cpuid=avx512f-vl'],
  ['vscatterqpd' , 'vm64v {k}, vmm'       , 'mr:t1s: evex.vl.66.0f38.w1 a3 /r vsib   ' , 'cpuid=avx512f-vl'],

  # => VSCATTERPF0DPS/VSCATTERPF0QPS/VSCATTERPF0DPD/VSCATTERPF0QPD-Sparse Prefetch Packed SP/DP Data Values with Signed Dword, Signed Qword Indices Using T0 Hint with Intent to Write
  ['vscatterpf0dps' , 'vm32z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c6 /5  '     , 'cpuid=avx512pf'],
  ['vscatterpf0dpd' , 'vm32y {k}'          , 'm:t1s: evex.512.66.0f38.w1 c6 /5  '     , 'cpuid=avx512pf'],
  ['vscatterpf0qpd' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w1 c7 /5  '     , 'cpuid=avx512pf'],
  ['vscatterpf0qps' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c7 /5  '     , 'cpuid=avx512pf'],

  # => VSCATTERPF1DPS/VSCATTERPF1QPS/VSCATTERPF1DPD/VSCATTERPF1QPD-Sparse Prefetch Packed SP/DP Data Values with Signed Dword, Signed Qword Indices Using T1 Hint with Intent to Write
  ['vscatterpf1qps' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c7 /6  '     , 'cpuid=avx512pf'],
  ['vscatterpf1dpd' , 'vm32y {k}'          , 'm:t1s: evex.512.66.0f38.w1 c6 /6  '     , 'cpuid=avx512pf'],
  ['vscatterpf1dps' , 'vm32z {k}'          , 'm:t1s: evex.512.66.0f38.w0 c6 /6  '     , 'cpuid=avx512pf'],
  ['vscatterpf1qpd' , 'vm64z {k}'          , 'm:t1s: evex.512.66.0f38.w1 c7 /6  '     , 'cpuid=avx512pf'],

  # => VSHUFF32x4/VSHUFF64x2/VSHUFI32x4/VSHUFI64x2-Shuffle Packed Values at 128-bit Granularity
  ['vshuff64x2' , 'W:vmm {kz}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.nds.vu.66.0f3a.w1 23 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vshufi64x2' , 'W:vmm {kz}, vmm, vmm/vm/b64, pimm8'         , 'rvmi:fv: evex.nds.vu.66.0f3a.w1 43 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vshufi32x4' , 'W:vmm {kz}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.nds.vu.66.0f3a.w0 43 /r ib   ' , 'cpuid=avx512f-vl'],
  ['vshuff32x4' , 'W:vmm {kz}, vmm, vmm/vm/b32, pimm8'         , 'rvmi:fv: evex.nds.vu.66.0f3a.w0 23 /r ib   ' , 'cpuid=avx512f-vl'],

  # => VTESTPD/VTESTPS-Packed Bit Test
  ['vtestps'  , 'R:vmm, vmm/vm'         , 'rm: vex.vl.66.0f38.w0 0e /r   '         , 'cpuid=avx eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],
  ['vtestpd'  , 'R:vmm, vmm/vm'         , 'rm: vex.vl.66.0f38.w0 0f /r   '         , 'cpuid=avx eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=M'],

  # => VZEROALL-Zero All YMM Registers
  ['vzeroall' , ''                   , 'vex.256.0f.wig 77'                      , 'cpuid=avx'],

  # => VZEROUPPER-Zero Upper Bits of YMM Registers
  ['vzeroupper' , ''                   , 'vex.128.0f.wig 77'                      , 'cpuid=avx'],

  # => WAIT/FWAIT-Wait
  ['wait'     , ''                   , '9b              '                       , 'aliasOf=fwait cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],
  ['fwait'    , ''                   , '9b              '                       , 'cpuid=fpu x87Flags.sw.c3=U x87Flags.sw.c2=U x87Flags.sw.c1=U x87Flags.sw.c0=U'],

  # => WBINVD-Write Back and Invalidate Cache
  ['wbinvd'   , ''                   , '0f 09'                                  , 'level=0'],

  # => WRFSBASE/WRGSBASE-Write FS/GS Segment Base
  ['wrfsbase' , 'R:vr'               , 'x64:m: osv  f3 0f ae /2     '           , 'cpuid=fsgsbase'],
  ['wrgsbase' , 'R:vr'               , 'x64:m: osv  f3 0f ae /3     '           , 'cpuid=fsgsbase'],

  # => WRMSR-Write to Model Specific Register
  ['wrmsr'    , 'R:<edx>, <eax>, <ecx>'       , '0f 30'                                  , 'level=0'],

  # => WRPKRU-Write Data to User Page Key Register
  ['wrpkru'   , 'R:<eax>'            , '0f 01 ef'                               , 'cpuid=ospke'],

  # => XABORT-Transactional Abort
  ['xabort'   , 'pimm8'              , 'i: c6 f8 ib'                            , 'cpuid=rtm'],

  # => XADD-Exchange and Add
  ['xadd'     , 'r8x/m8, X:r8x'       , 'mr:          0f c0 /r        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],
  ['xadd'     , 'vr/vm, X:vr'         , 'mr:     os   0f c1 /r        '          , 'lock=legacy|hardware|explicit eflags.of=M eflags.sf=M eflags.zf=M eflags.af=M eflags.pf=M eflags.cf=M'],

  # => XBEGIN-Transactional Begin
  ['xbegin'   , 'rel'                , 'd: osz  c7 f8           '               , 'cpuid=rtm'],

  # => XCHG-Exchange Register/Memory with Register
  ['xchg'     , 'ax, X:r16'           , 'o:      os16 90+rw           '          , 'form=preferred'],
  ['xchg'     , 'eax, X:r32'          , 'o:      os32 90+rd           '          , 'form=preferred'],
  ['xchg'     , 'r16, X:ax'           , 'o:      os16 90+rw           '          , 'form=alternative'],
  ['xchg'     , 'r32, X:eax'          , 'o:      os32 90+rd           '          , 'form=alternative'],
  ['xchg'     , 'r8x/m8, X:r8x'       , 'mr:          86 /r           '          , 'form=alternative lock=legacy|hardware|implied'],
  ['xchg'     , 'vr/vm, X:vr'         , 'mr:     os   87 /r           '          , 'form=preferred lock=legacy|hardware|implied'],
  ['xchg'     , 'vr, X:vr/vm'         , 'rm:     os   87 /r           '          , 'form=alternative lock=legacy|hardware|implied'],
  ['xchg'     , 'r8x, X:r8x/m8'       , 'rm:          86 /r           '          , 'form=alternative lock=legacy|hardware|implied'],
  ['xchg'     , 'rax, X:r64'          , 'x64:o:  os64 90+rd           '          , 'form=preferred'],
  ['xchg'     , 'r64, X:rax'          , 'x64:o:  os64 90+rd           '          , 'form=alternative'],

  # => XEND-Transactional End
  ['xend'     , ''                   , '0f 01 d5'                               , 'cpuid=rtm'],

  # => XGETBV-Get Value of Extended Control Register
  ['xgetbv'   , 'R:<ecx>, W:<edx>, W:<eax>'       , '0f 01 d0'                               , 'cpuid=xg1|xsave'],

  # => XLAT/XLATB-Table Look-up Translation
  ['xlatb'    , ''                     , '     osv d7              '              , 'form=alternative'],
  ['xlat'     , 'al, <[*bx+al]>'       , '     d7              '                  , 'form=preferred'],

  # => XOR-Logical Exclusive OR
  ['xor'      , '*ax, imm.low'       , 'i:      os   35 iz           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'al, imm8'           , 'i:           34 ib           '          , 'eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'vr/vm, imm.low'     , 'mi:     os   81 /6 iz        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'r8x/m8, r8x'        , 'mr:          30 /r           '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'r8x/m8, imm8'       , 'mi:          80 /6 ib        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'vr/vm, imm8'        , 'mi:     os   83 /6 ib        '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'vr/vm, vr'          , 'mr:     os   31 /r           '          , 'lock=legacy|hardware|explicit eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'vr, vr/vm'          , 'rm:     os   33 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],
  ['xor'      , 'r8x, r8x/m8'        , 'rm:          32 /r           '          , 'lock=legacy|hardware|explicit|ignore eflags.of=C eflags.sf=M eflags.zf=M eflags.af=U eflags.pf=M eflags.cf=C'],

  # => XORPD-Bitwise Logical XOR of Packed Double Precision Floating-Point Values
  ['xorpd'    , 'xmm, xmm/m128'                       , 'rm:     66 0f 57 /r                  '  , 'cpuid=sse2'],
  ['vxorpd'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.66.0f.wig 57 /r   '  , 'cpuid=avx'],
  ['vxorpd'   , 'W:vmm {kz}, vmm, vmm/vm/b64'         , 'rvm:fv: evex.nds.vl.66.0f.w1 57 /r   '  , 'cpuid=avx512dq-vl'],

  # => XORPS-Bitwise Logical XOR of Packed Single Precision Floating-Point Values
  ['xorps'    , 'xmm, xmm/m128'                       , 'rm:     0f 57 /r                  '     , 'cpuid=sse'],
  ['vxorps'   , 'W:vmm, vmm, vmm/vm'                  , 'rvm:    vex.nds.vl.0f.wig 57 /r   '     , 'cpuid=avx'],
  ['vxorps'   , 'W:vmm {kz}, vmm, vmm/vm/b32'         , 'rvm:fv: evex.nds.vl.0f.w0 57 /r   '     , 'cpuid=avx512dq-vl'],

  # => XRSTOR-Restore Processor Extended States
  ['xrstor'   , 'R:mem, <edx>, <eax>'       , 'm:     os32 0f ae /5        '           , 'cpuid=xsavec|xsave'],
  ['xrstor64' , 'R:mem, <edx>, <eax>'       , 'x64:m: os64 0f ae /5        '           , 'cpuid=xsavec|xsave'],

  # => XRSTORS-Restore Processor Extended States Supervisor
  ['xrstors'   , 'R:mem, <edx>, <eax>'       , 'm:     os32 0f c7 /3        '           , 'cpuid=xsave|xss'],
  ['xrstors64' , 'R:mem, <edx>, <eax>'       , 'x64:m: os64 0f c7 /3        '           , 'cpuid=xsave|xss'],

  # => XSAVE-Save Processor Extended States
  ['xsave'    , 'W:mem, <edx>, <eax>'       , 'm:     os32 0f ae /4        '           , 'cpuid=xsave'],
  ['xsave64'  , 'W:mem, <edx>, <eax>'       , 'x64:m: os64 0f ae /4        '           , 'cpuid=xsave'],

  # => XSAVEC-Save Processor Extended States with Compaction
  ['xsavec'   , 'W:mem, <edx>, <eax>'       , 'm:     os32 0f c7 /4        '           , 'cpuid=xsave|xsavec'],
  ['xsavec64' , 'W:mem, <edx>, <eax>'       , 'x64:m: os64 0f c7 /4        '           , 'cpuid=xsave|xsavec'],

  # => XSAVEOPT-Save Processor Extended States Optimized
  ['xsaveopt'   , 'W:mem, <edx>, <eax>'       , 'm:     os32 0f ae /6        '           , 'cpuid=xsaveopt'],
  ['xsaveopt64' , 'W:mem, <edx>, <eax>'       , 'x64:m: os64 0f ae /6        '           , 'cpuid=xsaveopt'],

  # => XSAVES-Save Processor Extended States Supervisor
  ['xsaves'   , 'W:mem, <edx>, <eax>'       , 'm:     os32 0f c7 /5        '           , 'cpuid=xsave|xss'],
  ['xsaves64' , 'W:mem, <edx>, <eax>'       , 'x64:m: os64 0f c7 /5        '           , 'cpuid=xsave|xss'],

  # => XSETBV-Set Extended Control Register
  ['xsetbv'   , 'R:<edx>, <eax>, <ecx>'       , '0f 01 d1'                               , 'level=0 cpuid=xsave'],

  # => XTEST-Test If In Transactional Execution
  ['xtest'    , ''                   , '0f 01 d6'                               , 'cpuid=hle|rtm eflags.of=C eflags.sf=C eflags.zf=M eflags.af=C eflags.pf=C eflags.cf=C'],



  # ===>                               AMD 3DNOW instructions                               <===

  # => femms
  ['femms'    , ''                   , '0f 0e'                                  , 'AMD deprecated cpuid=3dnow'],

  # => pavgusb
  ['pavgusb'  , 'mm, mm/m64'         , 'rm: 0f 0f /r bf'                        , 'AMD deprecated cpuid=3dnow'],

  # => pf2id
  ['pf2id'    , 'W:mm, mm/m64'       , 'rm: 0f 0f /r 1d'                        , 'AMD deprecated cpuid=3dnow'],

  # => pf2iw
  ['pf2iw'    , 'W:mm, mm/m64'       , 'rm: 0f 0f /r 1c'                        , 'AMD deprecated cpuid=3dnow2'],

  # => pfacc
  ['pfacc'    , 'mm, mm/m64'         , 'rm: 0f 0f /r ae'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfadd
  ['pfadd'    , 'mm, mm/m64'         , 'rm: 0f 0f /r 9e'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfcmpeq
  ['pfcmpeq'  , 'mm, mm/m64'         , 'rm: 0f 0f /r b0'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfcmpge
  ['pfcmpge'  , 'mm, mm/m64'         , 'rm: 0f 0f /r 90'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfcmpgt
  ['pfcmpgt'  , 'mm, mm/m64'         , 'rm: 0f 0f /r a0'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfmax
  ['pfmax'    , 'mm, mm/m64'         , 'rm: 0f 0f /r a4'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfmin
  ['pfmin'    , 'mm, mm/m64'         , 'rm: 0f 0f /r 94'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfmul
  ['pfmul'    , 'mm, mm/m64'         , 'rm: 0f 0f /r b4'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfnacc
  ['pfnacc'   , 'mm, mm/m64'         , 'rm: 0f 0f /r 8a'                        , 'AMD deprecated cpuid=3dnow2'],

  # => pfpnacc
  ['pfpnacc'  , 'mm, mm/m64'         , 'rm: 0f 0f /r 8e'                        , 'AMD deprecated cpuid=3dnow2'],

  # => pfrcp
  ['pfrcp'    , 'W:mm, mm/m64'       , 'rm: 0f 0f /r 96'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfrcpit1
  ['pfrcpit1' , 'mm, mm/m64'         , 'rm: 0f 0f /r a6'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfrcpit2
  ['pfrcpit2' , 'mm, mm/m64'         , 'rm: 0f 0f /r b6'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfrsqit1
  ['pfrsqit1' , 'W:mm, mm/m64'       , 'rm: 0f 0f /r a7'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfrsqrt
  ['pfrsqrt'  , 'W:mm, mm/m64'       , 'rm: 0f 0f /r 97'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfsub
  ['pfsub'    , 'mm, mm/m64'         , 'rm: 0f 0f /r 9a'                        , 'AMD deprecated cpuid=3dnow'],

  # => pfsubr
  ['pfsubr'   , 'mm, mm/m64'         , 'rm: 0f 0f /r aa'                        , 'AMD deprecated cpuid=3dnow'],

  # => pi2fd
  ['pi2fd'    , 'W:mm, mm/m64'       , 'rm: 0f 0f /r 0d'                        , 'AMD deprecated cpuid=3dnow'],

  # => pi2fw
  ['pi2fw'    , 'W:mm, mm/m64'       , 'rm: 0f 0f /r 0c'                        , 'AMD deprecated cpuid=3dnow2'],

  # => prefetchw
  ['prefetchw' , 'R:m8'               , 'm: 0f 0d'                               , 'AMD deprecated cpuid=3dnow'],

  # => pswapd
  ['pswapd'   , 'W:mm, mm/m64'       , 'rm: 0f 0f /r bb'                        , 'AMD deprecated cpuid=3dnow2'],



  # ===>                               AMD XOP & FMA instructions                               <===

  # => pmacssdql
  ['pmacssdql' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 87 /r is4'      , 'AMD cpuid=xop'],

  # => pmacssww
  ['pmacssww' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 85 /r is4'      , 'AMD cpuid=xop'],

  # => pmadcswd
  ['pmadcswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 b6 /r is4'      , 'AMD cpuid=xop'],

  # => vfmaddpd
  ['vfmaddpd' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 69 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmaddpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 69 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmaddps
  ['vfmaddps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 68 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmaddps' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 68 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmaddsd
  ['vfmaddsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 6b /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmaddsd' , 'W:xmm, xmm, xmm, xmm/m64'       , 'rvim: vex.nds.128.66.0f3a.w1 6b /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmaddss
  ['vfmaddss' , 'W:xmm, xmm, xmm, xmm/m32'       , 'rvim: vex.nds.128.66.0f3a.w1 6a /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmaddss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 6a /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmaddsubpd
  ['vfmaddsubpd' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 5d /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmaddsubpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 5d /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmaddsubps
  ['vfmaddsubps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 5c /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmaddsubps' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 5c /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmsubaddpd
  ['vfmsubaddpd' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 5f /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmsubaddpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 5f /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmsubaddps
  ['vfmsubaddps' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 5e /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmsubaddps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 5e /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmsubpd
  ['vfmsubpd' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 6d /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmsubpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 6d /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmsubps
  ['vfmsubps' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 6c /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmsubps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 6c /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmsubsd
  ['vfmsubsd' , 'W:xmm, xmm, xmm, xmm/m64'       , 'rvim: vex.nds.128.66.0f3a.w1 6f /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmsubsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 6f /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfmsubss
  ['vfmsubss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 6e /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfmsubss' , 'W:xmm, xmm, xmm, xmm/m32'       , 'rvim: vex.nds.128.66.0f3a.w1 6e /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmaddpd
  ['vfnmaddpd' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 79 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmaddpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 79 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmaddps
  ['vfnmaddps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 78 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmaddps' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 78 /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmaddsd
  ['vfnmaddsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 7b /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmaddsd' , 'W:xmm, xmm, xmm, xmm/m64'       , 'rvim: vex.nds.128.66.0f3a.w1 7b /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmaddss
  ['vfnmaddss' , 'W:xmm, xmm, xmm, xmm/m32'       , 'rvim: vex.nds.128.66.0f3a.w1 7a /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmaddss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 7a /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmsubpd
  ['vfnmsubpd' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 7d /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmsubpd' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 7d /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmsubps
  ['vfnmsubps' , 'W:vmm, vmm, vmm, vmm/vm'         , 'rvim: vex.nds.vl.66.0f3a.w1 7c /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmsubps' , 'W:vmm, vmm, vmm/vm, vmm'         , 'rvmi: vex.nds.vl.66.0f3a.w0 7c /r is4   ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmsubsd
  ['vfnmsubsd' , 'W:xmm, xmm, xmm, xmm/m64'       , 'rvim: vex.nds.128.66.0f3a.w1 7f /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmsubsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 7f /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfnmsubss
  ['vfnmsubss' , 'W:xmm, xmm, xmm, xmm/m32'       , 'rvim: vex.nds.128.66.0f3a.w1 7e /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['vfnmsubss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'rvmi: vex.nds.128.66.0f3a.w0 7e /r is4  ' , 'AMD cpuid=fma4 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => vfrczpd
  ['vfrczpd'  , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 81 /r  '              , 'AMD cpuid=xop mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],
  ['vfrczpd'  , 'W:ymm, ymm/m256'       , 'rm: xop.256.m9.w0 81 /r  '              , 'AMD cpuid=xop mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => vfrczps
  ['vfrczps'  , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 80 /r  '              , 'AMD cpuid=xop mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],
  ['vfrczps'  , 'W:ymm, ymm/m256'       , 'rm: xop.256.m9.w0 80 /r  '              , 'AMD cpuid=xop mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => vfrczsd
  ['vfrczsd'  , 'W:xmm, xmm/m64'       , 'rm: xop.128.m9.w0 83 /r'                , 'AMD cpuid=xop mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => vfrczss
  ['vfrczss'  , 'W:xmm, xmm/m32'       , 'rm: xop.128.m9.w0 82 /r'                , 'AMD cpuid=xop mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => vpcmov
  ['vpcmov'   , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 a2 /r is4  '    , 'AMD cpuid=xop'],
  ['vpcmov'   , 'W:ymm, ymm, ymm/m256, ymm'       , 'rvmi: xop.nds.256.m8.w0 a2 /r is4  '    , 'AMD cpuid=xop'],
  ['vpcmov'   , 'W:xmm, xmm, xmm, xmm/m128'       , 'rvim: xop.nds.128.m8.w1 a2 /r is4  '    , 'AMD cpuid=xop'],
  ['vpcmov'   , 'W:ymm, ymm, ymm, ymm/m256'       , 'rvim: xop.nds.256.m8.w1 a2 /r is4  '    , 'AMD cpuid=xop'],

  # => vpcomb
  ['vpcomb'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 cc /r ib'       , 'AMD cpuid=xop'],

  # => vpcomd
  ['vpcomd'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 ce /r ib'       , 'AMD cpuid=xop'],

  # => vpcomq
  ['vpcomq'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 cf /r ib'       , 'AMD cpuid=xop'],

  # => vpcomub
  ['vpcomub'  , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 ec /r ib'       , 'AMD cpuid=xop'],

  # => vpcomud
  ['vpcomud'  , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 ee /r ib'       , 'AMD cpuid=xop'],

  # => vpcomuq
  ['vpcomuq'  , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 ef /r ib'       , 'AMD cpuid=xop'],

  # => vpcomuw
  ['vpcomuw'  , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 ed /r ib'       , 'AMD cpuid=xop'],

  # => vpcomw
  ['vpcomw'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'rvmi: xop.nds.128.m8.w0 cd /r ib'       , 'AMD cpuid=xop'],

  # => vpermil2pd
  ['vpermil2pd' , 'W:vmm, vmm, vmm/vm, vmm, pimm4'         , 'rvmi: vex.nds.vl.0f3a.w0 49 /r is4   '  , 'AMD cpuid=xop'],
  ['vpermil2pd' , 'W:vmm, vmm, vmm, vmm/vm, pimm4'         , 'rvim: vex.nds.vl.0f3a.w1 49 /r is4   '  , 'AMD cpuid=xop'],

  # => vpermil2ps
  ['vpermil2ps' , 'W:vmm, vmm, vmm, vmm/vm, pimm4'         , 'rvim: vex.nds.vl.0f3a.w1 48 /r is4   '  , 'AMD cpuid=xop'],
  ['vpermil2ps' , 'W:vmm, vmm, vmm/vm, vmm, pimm4'         , 'rvmi: vex.nds.vl.0f3a.w0 48 /r is4   '  , 'AMD cpuid=xop'],

  # => vphaddbd
  ['vphaddbd' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 c2 /r'                , 'AMD cpuid=xop'],

  # => vphaddbq
  ['vphaddbq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 c3 /r'                , 'AMD cpuid=xop'],

  # => vphaddbw
  ['vphaddbw' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 c1 /r'                , 'AMD cpuid=xop'],

  # => vphadddq
  ['vphadddq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 cb /r'                , 'AMD cpuid=xop'],

  # => vphaddubd
  ['vphaddubd' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 d2 /r'                , 'AMD cpuid=xop'],

  # => vphaddubq
  ['vphaddubq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 d3 /r'                , 'AMD cpuid=xop'],

  # => vphaddubwd
  ['vphaddubwd' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 d1 /r'                , 'AMD cpuid=xop'],

  # => vphaddudq
  ['vphaddudq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 db /r'                , 'AMD cpuid=xop'],

  # => vphadduwd
  ['vphadduwd' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 d6 /r'                , 'AMD cpuid=xop'],

  # => vphadduwq
  ['vphadduwq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 d7 /r'                , 'AMD cpuid=xop'],

  # => vphaddwd
  ['vphaddwd' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 c6 /r'                , 'AMD cpuid=xop'],

  # => vphaddwq
  ['vphaddwq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 c7 /r'                , 'AMD cpuid=xop'],

  # => vphsubbw
  ['vphsubbw' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 e1 /r'                , 'AMD cpuid=xop'],

  # => vphsubdq
  ['vphsubdq' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 e3 /r'                , 'AMD cpuid=xop'],

  # => vphsubwd
  ['vphsubwd' , 'W:xmm, xmm/m128'       , 'rm: xop.128.m9.w0 e2 /r'                , 'AMD cpuid=xop'],

  # => vpmacsdd
  ['vpmacsdd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 9e /r is4'      , 'AMD cpuid=xop'],

  # => vpmacsdqh
  ['vpmacsdqh' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 9f /r is4'      , 'AMD cpuid=xop'],

  # => vpmacsdql
  ['vpmacsdql' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 97 /r is4'      , 'AMD cpuid=xop'],

  # => vpmacssdd
  ['vpmacssdd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 8e /r is4'      , 'AMD cpuid=xop'],

  # => vpmacssdqh
  ['vpmacssdqh' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 8f /r is4'      , 'AMD cpuid=xop'],

  # => vpmacsswd
  ['vpmacsswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 86 /r is4'      , 'AMD cpuid=xop'],

  # => vpmacswd
  ['vpmacswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 96 /r is4'      , 'AMD cpuid=xop'],

  # => vpmacsww
  ['vpmacsww' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 95 /r is4'      , 'AMD cpuid=xop'],

  # => vpmadcsswd
  ['vpmadcsswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 a6 /r is4'      , 'AMD cpuid=xop'],

  # => vpperm
  ['vpperm'   , 'W:xmm, xmm, xmm/m128, xmm'       , 'rvmi: xop.nds.128.m8.w0 a3 /r is4  '    , 'AMD cpuid=xop'],
  ['vpperm'   , 'W:xmm, xmm, xmm, xmm/m128'       , 'rvim: xop.nds.128.m8.w1 a3 /r is4  '    , 'AMD cpuid=xop'],

  # => vprotb
  ['vprotb'   , 'W:xmm, xmm, xmm/m128'         , 'rvm: xop.nds.128.m9.w1 90 /r  '         , 'AMD cpuid=xop'],
  ['vprotb'   , 'W:xmm, xmm/m128, pimm8'       , 'rmi: xop.128.m8.w0 c0 /r ib   '         , 'AMD cpuid=xop'],
  ['vprotb'   , 'W:xmm, xmm/m128, xmm'         , 'rmv: xop.nds.128.m9.w0 90 /r  '         , 'AMD cpuid=xop'],

  # => vprotd
  ['vprotd'   , 'W:xmm, xmm/m128, xmm'         , 'rmv: xop.nds.128.m9.w0 92 /r  '         , 'AMD cpuid=xop'],
  ['vprotd'   , 'W:xmm, xmm/m128, pimm8'       , 'rmi: xop.128.m8.w0 c2 /r ib   '         , 'AMD cpuid=xop'],
  ['vprotd'   , 'W:xmm, xmm, xmm/m128'         , 'rvm: xop.nds.128.m9.w1 92 /r  '         , 'AMD cpuid=xop'],

  # => vprotq
  ['vprotq'   , 'W:xmm, xmm/m128, xmm'         , 'rmv: xop.nds.128.m9.w0 93 /r  '         , 'AMD cpuid=xop'],
  ['vprotq'   , 'W:xmm, xmm/m128, pimm8'       , 'rmi: xop.128.m8.w0 c3 /r ib   '         , 'AMD cpuid=xop'],
  ['vprotq'   , 'W:xmm, xmm, xmm/m128'         , 'rvm: xop.nds.128.m9.w1 93 /r  '         , 'AMD cpuid=xop'],

  # => vprotw
  ['vprotw'   , 'W:xmm, xmm/m128, pimm8'       , 'rmi: xop.128.m8.w0 c1 /r ib   '         , 'AMD cpuid=xop'],
  ['vprotw'   , 'W:xmm, xmm/m128, xmm'         , 'rmv: xop.nds.128.m9.w0 91 /r  '         , 'AMD cpuid=xop'],
  ['vprotw'   , 'W:xmm, xmm, xmm/m128'         , 'rvm: xop.nds.128.m9.w1 91 /r  '         , 'AMD cpuid=xop'],

  # => vpshab
  ['vpshab'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 98 /r  '         , 'AMD cpuid=xop'],
  ['vpshab'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 98 /r  '         , 'AMD cpuid=xop'],

  # => vpshad
  ['vpshad'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 9a /r  '         , 'AMD cpuid=xop'],
  ['vpshad'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 9a /r  '         , 'AMD cpuid=xop'],

  # => vpshaq
  ['vpshaq'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 9b /r  '         , 'AMD cpuid=xop'],
  ['vpshaq'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 9b /r  '         , 'AMD cpuid=xop'],

  # => vpshaw
  ['vpshaw'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 99 /r  '         , 'AMD cpuid=xop'],
  ['vpshaw'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 99 /r  '         , 'AMD cpuid=xop'],

  # => vpshlb
  ['vpshlb'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 94 /r  '         , 'AMD cpuid=xop'],
  ['vpshlb'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 94 /r  '         , 'AMD cpuid=xop'],

  # => vpshld
  ['vpshld'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 96 /r  '         , 'AMD cpuid=xop'],
  ['vpshld'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 96 /r  '         , 'AMD cpuid=xop'],

  # => vpshlq
  ['vpshlq'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 97 /r  '         , 'AMD cpuid=xop'],
  ['vpshlq'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 97 /r  '         , 'AMD cpuid=xop'],

  # => vpshlw
  ['vpshlw'   , 'W:xmm, xmm/m128, xmm'       , 'rmv: xop.nds.128.m9.w0 95 /r  '         , 'AMD cpuid=xop'],
  ['vpshlw'   , 'W:xmm, xmm, xmm/m128'       , 'rvm: xop.nds.128.m9.w1 95 /r  '         , 'AMD cpuid=xop'],



  # ===>                               AMD SSE5 instructions                               <===

  # => compd
  ['compd'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 2d /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5 mxcsr.de=M mxcsr.ie=M'],

  # => comps
  ['comps'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 2c /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5 mxcsr.de=M mxcsr.ie=M'],

  # => comsd
  ['comsd'    , 'W:xmm, xmm, xmm/m64, pimm8'       , 'xrmi: 0f 25 2f /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5 mxcsr.de=M mxcsr.ie=M'],

  # => comss
  ['comss'    , 'W:xmm, xmm, xmm/m32, pimm8'       , 'xrmi: 0f 25 2e /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5 mxcsr.de=M mxcsr.ie=M'],

  # => cvtph2ps
  ['cvtph2ps' , 'W:xmm, xmm/m64'       , 'rm: 0f 7a 30 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => cvtps2ph
  ['cvtps2ph' , 'W:xmm/m64, xmm'       , 'mr: 0f 7a 31 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => fmaddpd
  ['fmaddpd'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 05 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddpd'  , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 05 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddpd'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 01 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddpd'  , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 01 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmaddps
  ['fmaddps'  , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 04 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddps'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 04 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddps'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 00 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddps'  , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 00 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmaddsd
  ['fmaddsd'  , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 03 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddsd'  , 'W:xmm, xmm, xmm, xmm/m64'       , 'xxrm: 0f 24 03 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddsd'  , 'W:xmm, xmm/m64, xmm, xmm'       , 'xmrx: 0f 24 07 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddsd'  , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 07 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmaddss
  ['fmaddss'  , 'W:xmm, xmm, xmm, xmm/m32'       , 'xxrm: 0f 24 02 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddss'  , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 02 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddss'  , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 06 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmaddss'  , 'W:xmm, xmm/m32, xmm, xmm'       , 'xmrx: 0f 24 06 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmsubpd
  ['fmsubpd'  , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 0d /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubpd'  , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 09 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubpd'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 0d /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubpd'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 09 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmsubps
  ['fmsubps'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 08 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubps'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 0c /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubps'  , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 08 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubps'  , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 0c /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmsubsd
  ['fmsubsd'  , 'W:xmm, xmm, xmm, xmm/m64'       , 'xxrm: 0f 24 0b /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubsd'  , 'W:xmm, xmm/m64, xmm, xmm'       , 'xmrx: 0f 24 0f /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubsd'  , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 0f /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubsd'  , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 0b /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fmsubss
  ['fmsubss'  , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 0a /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubss'  , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 0e /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubss'  , 'W:xmm, xmm, xmm, xmm/m32'       , 'xxrm: 0f 24 0a /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fmsubss'  , 'W:xmm, xmm/m32, xmm, xmm'       , 'xmrx: 0f 24 0e /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmaddpd
  ['fnmaddpd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 15 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddpd' , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 11 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddpd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 11 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddpd' , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 15 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmaddps
  ['fnmaddps' , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 14 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddps' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 10 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddps' , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 10 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddps' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 14 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmaddsd
  ['fnmaddsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 17 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddsd' , 'W:xmm, xmm/m64, xmm, xmm'       , 'xmrx: 0f 24 17 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddsd' , 'W:xmm, xmm, xmm, xmm/m64'       , 'xxrm: 0f 24 13 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 13 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmaddss
  ['fnmaddss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 12 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddss' , 'W:xmm, xmm/m32, xmm, xmm'       , 'xmrx: 0f 24 16 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 16 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmaddss' , 'W:xmm, xmm, xmm, xmm/m32'       , 'xxrm: 0f 24 12 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmsubpd
  ['fnmsubpd' , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 19 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubpd' , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 1d /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubpd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 1d /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubpd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 19 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmsubps
  ['fnmsubps' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 18 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubps' , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 18 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubps' , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 1c /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubps' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 1c /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmsubsd
  ['fnmsubsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 1b /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubsd' , 'W:xmm, xmm, xmm, xmm/m64'       , 'xxrm: 0f 24 1b /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubsd' , 'W:xmm, xmm/m64, xmm, xmm'       , 'xmrx: 0f 24 1f /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubsd' , 'W:xmm, xmm, xmm/m64, xmm'       , 'xrmx: 0f 24 1f /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => fnmsubss
  ['fnmsubss' , 'W:xmm, xmm, xmm, xmm/m32'       , 'xxrm: 0f 24 1a /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubss' , 'W:xmm, xmm/m32, xmm, xmm'       , 'xmrx: 0f 24 1e /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 1e /r drex.oc0  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],
  ['fnmsubss' , 'W:xmm, xmm, xmm/m32, xmm'       , 'xrmx: 0f 24 1a /r drex.oc1  '           , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.oe=M mxcsr.de=M mxcsr.ie=M'],

  # => frczpd
  ['frczpd'   , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 11 /r'                        , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => frczps
  ['frczps'   , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 10 /r'                        , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => frczsd
  ['frczsd'   , 'W:xmm, xmm/m64'       , 'rm: 0f 7a 13 /r'                        , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => frczss
  ['frczss'   , 'W:xmm, xmm/m32'       , 'rm: 0f 7a 12 /r'                        , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ue=M mxcsr.de=M mxcsr.ie=M'],

  # => pcmov
  ['pcmov'    , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 26 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],
  ['pcmov'    , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 26 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['pcmov'    , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 22 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],
  ['pcmov'    , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 22 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],

  # => pcomb
  ['pcomb'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 4c /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomd
  ['pcomd'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 4e /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomq
  ['pcomq'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 4f /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomub
  ['pcomub'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 6c /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomud
  ['pcomud'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 6e /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomuq
  ['pcomuq'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 6f /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomuw
  ['pcomuw'   , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 6d /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => pcomw
  ['pcomw'    , 'W:xmm, xmm, xmm/m128, pimm8'       , 'xrmi: 0f 25 4d /r drex.oc0 ib'          , 'AMD abandoned cpuid=sse5'],

  # => permpd
  ['permpd'   , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 25 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],
  ['permpd'   , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 21 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['permpd'   , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 25 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['permpd'   , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 21 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],

  # => permps
  ['permps'   , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 24 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['permps'   , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 20 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],
  ['permps'   , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 20 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['permps'   , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 24 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],

  # => phaddbd
  ['phaddbd'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 42 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddbq
  ['phaddbq'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 43 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddbw
  ['phaddbw'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 41 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phadddq
  ['phadddq'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 4b /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddubd
  ['phaddubd' , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 52 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddubq
  ['phaddubq' , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 53 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddubw
  ['phaddubw' , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 51 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddudq
  ['phaddudq' , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 5b /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phadduwd
  ['phadduwd' , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 56 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phadduwq
  ['phadduwq' , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 57 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddwd
  ['phaddwd'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 46 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phaddwq
  ['phaddwq'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 47 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phsubbw
  ['phsubbw'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 61 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phsubdq
  ['phsubdq'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 63 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => phsubwd
  ['phsubwd'  , 'W:xmm, xmm/m128'       , 'rm: 0f 7a 62 /r'                        , 'AMD abandoned cpuid=sse5'],

  # => pmacsdd
  ['pmacsdd'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 9e /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacsdqh
  ['pmacsdqh' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 9f /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacsdql
  ['pmacsdql' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 97 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacssdd
  ['pmacssdd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 8e /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacssdqh
  ['pmacssdqh' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 8f /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacssdql
  ['pmacssdql' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 87 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacsswd
  ['pmacsswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 86 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacssww
  ['pmacssww' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 85 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacswd
  ['pmacswd'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 96 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmacsww
  ['pmacsww'  , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 95 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmadcsswd
  ['pmadcsswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 a6 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pmadcswd
  ['pmadcswd' , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 b6 /r drex.oc0'             , 'AMD abandoned cpuid=sse5'],

  # => pperm
  ['pperm'    , 'W:xmm, xmm/m128, xmm, xmm'       , 'xmrx: 0f 24 27 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['pperm'    , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 23 /r drex.oc1  '           , 'AMD abandoned cpuid=sse5'],
  ['pperm'    , 'W:xmm, xmm, xmm, xmm/m128'       , 'xxrm: 0f 24 23 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],
  ['pperm'    , 'W:xmm, xmm, xmm/m128, xmm'       , 'xrmx: 0f 24 27 /r drex.oc0  '           , 'AMD abandoned cpuid=sse5'],

  # => protb
  ['protb'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 40 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['protb'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 40 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => protd
  ['protd'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 42 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['protd'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 42 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => protq
  ['protq'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 43 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['protq'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 43 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => protw
  ['protw'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 41 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],
  ['protw'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 41 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],

  # => pshab
  ['pshab'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 48 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],
  ['pshab'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 48 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],

  # => pshad
  ['pshad'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 4a /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['pshad'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 4a /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => pshaq
  ['pshaq'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 4b /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],
  ['pshaq'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 4b /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],

  # => pshaw
  ['pshaw'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 49 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['pshaw'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 49 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => pshlb
  ['pshlb'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 44 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['pshlb'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 44 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => pshld
  ['pshld'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 46 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['pshld'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 46 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => pshlq
  ['pshlq'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 47 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],
  ['pshlq'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 47 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],

  # => pshlw
  ['pshlw'    , 'W:xmm, xmm, xmm/m128'       , 'xrm: 0f 24 45 /r drex.oc0  '            , 'AMD abandoned cpuid=sse5'],
  ['pshlw'    , 'W:xmm, xmm/m128, xmm'       , 'xmr: 0f 24 45 /r drex.oc1  '            , 'AMD abandoned cpuid=sse5'],

  # => ptest
  ['ptest'    , 'W:xmm, xmm/m128'       , 'rm: 66 0f 38 17 /r'                     , 'AMD abandoned cpuid=sse5 eflags.zf=U eflags.cf=U'],

  # => roundpd
  ['roundpd'  , 'W:xmm, xmm/m128, pimm8'       , 'rmi: 66 0f 3a 09 /r ib'                 , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ie=M'],

  # => roundps
  ['roundps'  , 'W:xmm, xmm/m128, pimm8'       , 'rmi: 66 0f 3a 08 /r ib'                 , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ie=M'],

  # => roundsd
  ['roundsd'  , 'W:xmm, xmm/m64, pimm8'       , 'rmi: 66 0f 3a 0b /r ib'                 , 'AMD abandoned cpuid=sse5 mxcsr.pe=M mxcsr.ie=M'],



  # ===>                               Undocumented instructions                               <===

  # => ffreep
  ['ffreep'   , 'st(i)'              , 'o: df c0+i'                             , 'undocumented cpuid=fpu'],

  # => hint_nop
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /4        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 18 /7        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 18 /5        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1c /r        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /7        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 18 /4        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /5        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1d /r        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 19 /r        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /6        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 18 /6        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /3        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /2        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1e /r        '           , 'undocumented'],
  ['hint_nop' , 'R:vr/vm'            , 'm:     os   0f 1f /1        '           , 'undocumented'],

  # => ibts
  ['ibts'     , 'vr/vm, vr, <*ax>, <cl>'        , 'mr: osz  0f a7 /r        '              , 'deprecated undocumented'],

  # => salc
  ['salc'     , ''                   , 'd6'                                     , 'undocumented'],

  # => smi
  ['smi'      , ''                   , 'f1'                                     , 'undocumented'],

  # => ud0
  ['ud0'      , ''                   , '0f ff'                                  , 'undocumented'],

  # => ud1
  ['ud1'      , ''                   , '0f b9'                                  , 'undocumented'],

  # => ud2b
  ['ud2b'     , ''                   , '0f b9'                                  , 'undocumented'],

  # => umov
  ['umov'     , 'W:r/m8, r8'         , 'mr:      0f 10 /r        '              , 'undocumented'],
  ['umov'     , 'W:vr/vm, vr'        , 'mr: osz  0f 11 /r        '              , 'undocumented'],
  ['umov'     , 'W:vr, vr/vm'        , 'rm: osz  0f 13 /r        '              , 'undocumented'],
  ['umov'     , 'W:r8, r/m8'         , 'rm:      0f 12 /r        '              , 'undocumented'],

  # => xbts
  ['xbts'     , 'W:vr, vr/vm, <*ax>, <cl>'        , 'rm: osz  0f a6 /r        '              , 'deprecated undocumented'],


);

1;
