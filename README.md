# opcodesDB:
opcodesDB is a CPU low level environment representation (registers, flags, instructions, ...).  Data are listed in a packed dynamic structure which can be unpacked by a parser at any time.

This project is a fruit of many years of development and a lot of attempts ([Parsable-Instructions](https://github.com/MahdiSafsafi/Parsable-Instructions), [asmdb](https://github.com/MahdiSafsafi/asmdb)) to standardize CPU environment.

Currently, only two architecture are supported (x86 and x64).

# TODO:
- Implement ARM parser.

# Using opcodesDB:
If you’re a Perl developer, you can directly start exploring x86 environment by calling ```getEnvironment``` function:
```pl
require 'x86.pl';
my $environment = getEnvironment('x86');
# explore ...
```
If not, that’s not a problem, all what you need to do is to export the environment to a JSON file and use your favorite programming language to parse the environment as a pure JSON:
```
# open a cmd in the opcodesDB folder and run this command:
# export.pl environmentName outputFile
export.pl x86 x86.json
```
This will produce a 'x86.json' file that contains all x86 environment informations (registers, instructions,...).

## x86 environment:
-	**name** = environment name.
-	**version** = environment version.
-	**architectures** = x86 architectures (x86,x64 or both ‘x86-64’).
-	**registers** = contains a hash of all registers used by x86.
-	**flags** = contains all registers flags (mxcsr, x87cw, x87sw,(e|r)flags).
-	**instructions** = contains a list of all instructions used by x86 environment (Intel and AMD).

### Instructions:
opcodesDB supports all instructions found in Intel and AMD documentation. Including:
- FPU, MMX, SSE, SSE2, SSE3, SSSE3, SSE4.1, SSE4.2 instructions.
- AMD 3DNOW and SSE5 instructions.
- AES, MPX, F16C, VME, BMI, BMI2... instructions.
- FMA, FMA4, AVX, AVX2, AVX512 instructions.

Each instruction is represented as a hash and contains the following info:
- **mnemonic**: instruction mnemonic (name).
- **architecture**: required architecture for instruction.
- **deprecated**: if true, it means that manufacturing (Intel or AMD) stopped supporting such instruction.
- **abandoned**: abandoned instruction.
- **undocumented**: instruction was not documented in official (AMD|Intel) documentations.
- **bnd|rep|repe|repne**: if true, instruction supports that prefix.
- **level**: privilege level required to execute the instruction (3 or 0).
- **aliasOf** = X: instruction is an alias to X instruction.
- **cupid**: a list of required flags of cupid to run this instruction.
- **suppressAllExceptions**: AVX512 instruction supports suppressing all exceptions {sae}.
- **embeddedRounding**: AVX512 instruction supports embedded rounding {er}.
- **stackPtr|fpuStackPtr** = +/- N: instruction increments/decrements stack pointer by N byte.
- **branchType**: if instruction is branch, this field contains branch type (short|near|far).
- **form**: Instruction has more than one form for encoding and decoding. disassembler should select either the preferred form or the alternative form.
- **lock**: provides lock info for the instruction. Instruction is lockable if **hardware|legacy** is set.
  - **hardware** : hardware lock is supported.
  - **legacy** : locking using legacy lock prefix is supported.
  - **implied** : instruction is lockable either with or without the presence of the lock.
  - **explicit** : lock prefix is required for hardware lock.
  - **ignore** : accept lock but ignore it because memory is not the destination operand.
- **opcodes**: 
  - encoding = instruction prefix encoding: (rex|drex|vex|evex|xop).
  - escape = escape opcodes. It can be one of this:
    - 0f = twoByte.
    - 0f0f = 3dnow.
    - 0f38 = threeByte38.
    - 0f3a = threeByte3A.
    - m8 = xop.m8.
    - m9 = xop.m9.
    - [d8-df] = fpu.
  - opsize = instruction opsize: (16|32|64).
  - addressSize = instruction address size: (16|32|64).
  - vvvv = vector vvvv field: (nds|ndd|dds).
  - length = vector length: (128|256|512).
  - w = (vector|rex).w field: (0,1,ignore).
  - oc0 = drex.oc0 field: (0|1).
  - regcode = registed operand is encoded in opcodes. It can be one of this:
    - rw = 16 byte register.
    - rd = 32 byte register.
    - i  = fpu register.
  - modrm = if set, instruction has a modrm field.
  - vsib = if set, instruction has a vsib field.
  - opcodes = list of instruction opcodes. If a slash(/N) used, it means that modrm.reg must be equal to N.
  - mandatoryPrefixes = list of mandatory prefixes required to encode the instruction: (66|f0|f2|f3).
  - fields = dynamic fields: (imm|offset|moffs).	  
- **operands**: a list of hash representing arguments used by the instruction. Each operand contains standard info about the operand. An operand can have more than one form (eg: r/m where the argument could be a register OR a memory). To make the parsing easy, opcodesDB uses the variants notation. Each variant contains a specific info that applies only to that variant.
  - **Standars info**:
    - **optional**: if true, it means that this argument is optional and assembler/dissembler may omit it.
    - **embedded**: argument is built-in instruction and it does not require encoding.
    - **encoding**: info about how to encode/decode this argument.
    - **read**: if true, the operand is read.
    - **write**: if true, the operand is written.
    - **masking**: register|memory supports AVX512 masking.
    - **zeroing**: register supports masking with zeroing.
    - **variants**: a list of hash representing possible variants that argument can support. To distinguish between variants, each one has a unique **variant** property: **(register|memory|immediate)**.
  - **Register variant**:
    - **value**: if(embedded), it contains register name.
    - **size**: register size in bits.
    - **type**: register type: (sreg|reg8|reg8x|reg16|reg32|reg64|fpureg|mmreg|creg|dreg|bndreg|kreg|xmmreg|ymmreg|zmmreg).
  - **Immediate variant**:
    - **value**: if(embedded), it contains immediate value.
    - **size**: immediate size in bits.
    - **type**: immediate type: (moffs|ptr|imm|rel).
    - **signed**: if set, immediate is signed. Otherwise it is unsigned.
  - **Memory variant**:
    - **segment**: memory segment.
    - **index**: memory index register.
    - **base**: memory base register.
    - **size**: memory size in bits.
    - **tuple**: AVX512 tuple used to encode/decode compressed displacement (DISP8*N).
    - **broadcast**: AVX512 memory broadcast size.
    - **vsibSize**: AVX vsib size (128|256|512).
    - **type**: memory type (m8,m128, ptr16,m16-m32,...).
- **eflags|x87Flags|mxcsr**: modified flags by instruction. Each flag is represented as follow :
  - **T** = instruction Tests flag.
  - **M** = instruction Modifies flag.
  - **C** = instruction sets flag to zero (Clear).
  - **S** = instruction Sets flag to 1 (Set).
  - **U** = Undefined.
  - **N** = Not affected.
  - **X** = TM.

#### Accessing instructions
The snippet below, just shown how to iterate all instructions.```$instruction``` is a hash representing all feature listed above.
```pl
use strict;
use warnings;
use Data::Dumper;
require 'environments.pl';

my $environment = getEnvironment('x86');
foreach my $instruction ( @{ $environment->{instructions} } ) {
	print Dumper $instruction;

	# do something with $instruction ...
}
```
## Example:
Consider this instruction: ```'evex.nds.512.0f.w0 58 /r' 'vaddps zmm {k} {z}, zmm, zmm/m512/b32 {er}'``` . After parsing it, the parser reports the following result:
```pl
{
	'mnemonic'     => 'vaddps',
	'architecture' => 'x64|x86',
	'level'        => 3,
	'form'         => '',
	'aliasOf'      => '',
	'deprecated'   => 0,
	'undocumented' => 0,
	'abandoned'    => 0,
	'branchType'   => '',
	'rep'          => 0,
	'repe'         => 0,
	'repne'        => 0,
	'bnd'          => 0,
	'lock'         => {
		'legacy'   => 0,
		'hardware' => 0,
		'implied'  => 0,
		'explicit' => 0,
		'ignore'   => 0
	},
	'suppressAllExceptions' => 0,
	'embeddedRounding'      => 1,
	'fpuStackPtr'           => 0,
	'stackPtr'              => 0,
	'cpuid'                 => ['avx512f'],
	'operands'              => [
		{
			'encoding'   => 'modrm.reg',
			'embedded'   => 0,
			'optional'   => 0,
			'read'       => 0,
			'write'      => 1,
			'masking'    => 1,
			'zeroing'    => 1,
			'vectorHint' => 0,
			'variants'   => [
				{
					'variant' => 'register',
					'type'    => 'zmmreg',
					'value'   => '',
					'size'    => 512
				}
			]
		},
		{
			'encoding'   => 'vvvv',
			'embedded'   => 0,
			'optional'   => 0,
			'read'       => 1,
			'write'      => 0,
			'masking'    => 0,
			'zeroing'    => 0,
			'vectorHint' => 0,
			'variants'   => [
				{
					'variant' => 'register',
					'type'    => 'zmmreg',
					'value'   => '',
					'size'    => 512
				}
			]
		},
		{
			'encoding'   => 'modrm.rm',
			'embedded'   => 0,
			'optional'   => 0,
			'read'       => 1,
			'write'      => 0,
			'masking'    => 0,
			'zeroing'    => 0,
			'vectorHint' => 1,
			'variants'   => [
				{
					'variant' => 'register',
					'type'    => 'zmmreg',
					'value'   => '',
					'size'    => 512
				},
				{
					'variant'   => 'memory',
					'type'      => 'm512',
					'segment'   => '',
					'base'      => '',
					'index'     => '',
					'scale'     => 0,
					'size'      => '512',
					'broadcast' => 32,
					'vsibSize'  => 0,
					'tuple'     => 'fv'
				}
			]
		}
	],
	'opcodes' => {
		'encoding'          => 'evex',
		'escape'            => '0f',
		'opsize'            => 0,
		'addressSize'       => 0,
		'vvvv'              => 'nds',
		'length'            => '512',
		'w'                 => 0,
		'oc0'               => undef,
		'modrm'             => 1,
		'vsib'              => 0,
		'regcode'           => undef,
		'mandatoryPrefixes' => [],
		'opcodes'           => ['58'],
		'fields'            => []
	},
	'eflags'   => {},
	'mxcsr'    => {},
	'x87Flags' => {
		'sw' => {},
		'cw' => {}
	}
};
```
