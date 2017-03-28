
# ===>                          ARM instruction set                        <===

# Author = Mahdi Safsafi.

# https://github.com/MahdiSafsafi/opcodesDB

# GROUPS
# ------
#
# Each group definition consists of 4 strings:
# [0] - Group ID.
# [1] - Reserved.
# [2] - Group opcodes
# [3] - Group metadata.

# INSTRUCTIONS
# ------------
#
# Each instruction definition consists of 4 strings:
#
#   [0] - Instruction mnemonic.
#   [1] - Instruction operands.
#   [2] - Instruction opcodes.
#   [3] - Instruction metadata - CPU requirements, FLAGS (read/write), and other metadata.

# MNEMONIC
# ========
# Instruction mnemonic:
#   - %c = specifies the condition under which the instruction is executed.
#   - %q = optional assembler qualifiers.
#   - %X = depends on instruction !

# OPERANDS
# ========
# Instruction operands. I used same representation found in ARM doc.
#   - rel.cnst = Expand rel. 

# OPCODE
# ======
# Pattern = [Arch]:[Fields].
# Arch   = ARM architecture [T16,T32,A32,A64].
# Fields = represents instruction opcodes. Fields are separated by '|'.
# Each field is represented as follow: [name(s)]*[match]*[value]*[:size]*
#  - name(s) : field's name.
#  - match   : '=' or '!='.
#  - value   : field's value in binary format [01x]+.
#  - size    : field's size in bits.
#  * means optional => However, a field can't be empty !
#
# Operands are encoded in opcodes fields, and if an operand requires more than
# one field, all used fields will have the same name as the operand.
#
# - If order (right to left) wasn't respected, an alphabetical suffix is used to indicate
#   the correct order. 
# - If the alphabetical order was used but wasn't respected, it means that
#   the gap in between (previous and next suffix) must be filled by zero !
#   eg: Foo.B|xx|Foo.A|Foo.E => Foo operand is encoded as : Foo.A:Foo.B:0:0:Foo.E 
 
# META-DATA
# --------
# - it = [in|out|last]        => Instruction IT block execution.
# - aliasOf = X               => The instruction is an alias to X instruction.
# - preferredIf = Conditions  => Conditions required to decode the alias instruction.
# - group = X                 => Group ID that decodes the instruction.
# - form = [alternative/alternative] => If more than one instruction have the same opcodes, this tells what form is. 
#                                       It's totally up to you to choose the form you to decode.
# - flags.nzcv                => affected flags.
#   Each flag can have one of this:
#     - R = Read.
#     - W = Write.
#     - X = Read AND Write.

# Page's title was added just for bugs tracking ! 


my $locked = 1;  # Don't edit instructions until ($locked == 0) !


my @groups = (

  # => A64 instruction index by encoding
  [1   , '' ,        'A64: xxx|op0:4|xxxxxxxxxxxxxxxxxxxxxxxxx'                                                 , 'group=0' ],

  # => Data processing - immediate
  [2   , '' ,        'A64: xxx|100|op0:3|xxxxxxxxxxxxxxxxxxxxxxx'                                               , 'group=1' ],

  # => Add/subtract (immediate)
  [3   , '' ,        'A64: sf:1|op:1|S|1000|1|shift:2|imm12:12|Rn:5|Rd:5'                                       , 'group=2' ],

  # => Bitfield
  [4   , '' ,        'A64: sf:1|opc:2|1001|10|N|immr:6|imms:6|Rn:5|Rd:5'                                        , 'group=2' ],

  # => Extract
  [5   , '' ,        'A64: sf:1|op21:2|1001|11|N|o0:1|Rm:5|imms:6|Rn:5|Rd:5'                                    , 'group=2' ],

  # => Logical (immediate)
  [6   , '' ,        'A64: sf:1|opc:2|1001|00|N|immr:6|imms:6|Rn:5|Rd:5'                                        , 'group=2' ],

  # => Move wide (immediate)
  [7   , '' ,        'A64: sf:1|opc:2|1001|01|hw:2|imm16:16|Rd:5'                                               , 'group=2' ],

  # => PC-rel. addressing
  [8   , '' ,        'A64: op:1|immlo:2|1000|0|immhi:19|Rd:5'                                                   , 'group=2' ],

  # => Branches, exception generating and system instructions
  [9   , '' ,        'A64: op0:3|101|op1:4|xxxxxxxxxxxxxxxxxxxxxx'                                              , 'group=1' ],

  # => Compare & branch (immediate)
  [10  , '' ,        'A64: sf:1|0110|10|op:1|imm19:19|Rt:5'                                                     , 'group=9' ],

  # => Conditional branch (immediate)
  [11  , '' ,        'A64: 0101|010|o1:1|imm19:19|o0:1|cond:4'                                                  , 'group=9' ],

  # => Exception generation
  [12  , '' ,        'A64: 1101|0100|opc:3|imm16:16|op2:3|LL:2'                                                 , 'group=9' ],

  # => System
  [13  , '' ,        'A64: 1101|0101|00|L|op0:2|op1:3|CRn:4|CRm:4|op2:3|Rt:5'                                   , 'group=9' ],

  # => Test & branch (immediate)
  [14  , '' ,        'A64: b5:1|0110|11|op:1|b40:5|imm14:14|Rt:5'                                               , 'group=9' ],

  # => Unconditional branch (immediate)
  [15  , '' ,        'A64: op:1|0010|1|imm26:26'                                                                , 'group=9' ],

  # => Unconditional branch (register)
  [16  , '' ,        'A64: 1101|011|opc:4|op2:5|op3:6|Rn:5|op4:5'                                               , 'group=9' ],

  # => Loads and stores
  [17  , '' ,        'A64: op0:1|x|op1:2|1|op2:1|0|op3:2|x|op4:6|xxxx|op5:2|xxxxxxxxxx'                         , 'group=1' ],

  # => Advanced SIMD load/store multiple structures
  [18  , '' ,        'A64: 0|Q|0011|000|L|0000|00|opcode:4|size:2|Rn:5|Rt:5'                                    , 'group=17' ],

  # => Advanced SIMD load/store multiple structures (post-indexed)
  [19  , '' ,        'A64: 0|Q|0011|001|L|0|Rm:5|opcode:4|size:2|Rn:5|Rt:5'                                     , 'group=17' ],

  # => Advanced SIMD load/store single structure
  [20  , '' ,        'A64: 0|Q|0011|010|L|R|0000|0|opcode:3|S|size:2|Rn:5|Rt:5'                                 , 'group=17' ],

  # => Advanced SIMD load/store single structure (post-indexed)
  [21  , '' ,        'A64: 0|Q|0011|011|L|R|Rm:5|opcode:3|S|size:2|Rn:5|Rt:5'                                   , 'group=17' ],

  # => Load register (literal)
  [22  , '' ,        'A64: opc:2|011|V|00|imm19:19|Rt:5'                                                        , 'group=17' ],

  # => Load/store exclusive
  [23  , '' ,        'A64: size:2|0010|00|o2:1|L|o1:1|Rs:5|o0:1|Rt2:5|Rn:5|Rt:5'                                , 'group=17' ],

  # => Load/store no-allocate pair (offset)
  [24  , '' ,        'A64: opc:2|101|V|000|L|imm7:7|Rt2:5|Rn:5|Rt:5'                                            , 'group=17' ],

  # => Load/store register (immediate post-indexed)
  [25  , '' ,        'A64: size:2|111|V|00|opc:2|0|imm9:9|01|Rn:5|Rt:5'                                         , 'group=17' ],

  # => Load/store register (immediate pre-indexed)
  [26  , '' ,        'A64: size:2|111|V|00|opc:2|0|imm9:9|11|Rn:5|Rt:5'                                         , 'group=17' ],

  # => Load/store register (register offset)
  [27  , '' ,        'A64: size:2|111|V|00|opc:2|1|Rm:5|option:3|S|10|Rn:5|Rt:5'                                , 'group=17' ],

  # => Load/store register (unprivileged)
  [28  , '' ,        'A64: size:2|111|V|00|opc:2|0|imm9:9|10|Rn:5|Rt:5'                                         , 'group=17' ],

  # => Load/store register (unscaled immediate)
  [29  , '' ,        'A64: size:2|111|V|00|opc:2|0|imm9:9|00|Rn:5|Rt:5'                                         , 'group=17' ],

  # => Load/store register (unsigned immediate)
  [30  , '' ,        'A64: size:2|111|V|01|opc:2|imm12:12|Rn:5|Rt:5'                                            , 'group=17' ],

  # => Load/store register pair (offset)
  [31  , '' ,        'A64: opc:2|101|V|010|L|imm7:7|Rt2:5|Rn:5|Rt:5'                                            , 'group=17' ],

  # => Load/store register pair (post-indexed)
  [32  , '' ,        'A64: opc:2|101|V|001|L|imm7:7|Rt2:5|Rn:5|Rt:5'                                            , 'group=17' ],

  # => Load/store register pair (pre-indexed)
  [33  , '' ,        'A64: opc:2|101|V|011|L|imm7:7|Rt2:5|Rn:5|Rt:5'                                            , 'group=17' ],

  # => Data processing - register
  [34  , '' ,        'A64: x|op0:1|x|op1:1|101|op2:4|xxxxxxxxx|op3:1|xxxxxxxxxxx'                               , 'group=1' ],

  # => Add/subtract (extended register)
  [35  , '' ,        'A64: sf:1|op:1|S|0101|1|opt:2|1|Rm:5|option:3|imm3:3|Rn:5|Rd:5'                           , 'group=34' ],

  # => Add/subtract (shifted register)
  [36  , '' ,        'A64: sf:1|op:1|S|0101|1|shift:2|0|Rm:5|imm6:6|Rn:5|Rd:5'                                  , 'group=34' ],

  # => Add/subtract (with carry)
  [37  , '' ,        'A64: sf:1|op:1|S|1101|0000|Rm:5|opcode2:6|Rn:5|Rd:5'                                      , 'group=34' ],

  # => Conditional compare (immediate)
  [38  , '' ,        'A64: sf:1|op:1|S|1101|0010|imm5:5|cond:4|1|o2:1|Rn:5|o3:1|nzcv:4'                         , 'group=34' ],

  # => Conditional compare (register)
  [39  , '' ,        'A64: sf:1|op:1|S|1101|0010|Rm:5|cond:4|0|o2:1|Rn:5|o3:1|nzcv:4'                           , 'group=34' ],

  # => Conditional select
  [40  , '' ,        'A64: sf:1|op:1|S|1101|0100|Rm:5|cond:4|op2:2|Rn:5|Rd:5'                                   , 'group=34' ],

  # => Data-processing (1 source)
  [41  , '' ,        'A64: sf:1|1|S|1101|0110|opcode2:5|opcode:6|Rn:5|Rd:5'                                     , 'group=34' ],

  # => Data-processing (2 source)
  [42  , '' ,        'A64: sf:1|0|S|1101|0110|Rm:5|opcode:6|Rn:5|Rd:5'                                          , 'group=34' ],

  # => Data-processing (3 source)
  [43  , '' ,        'A64: sf:1|op54:2|1101|1|op31:3|Rm:5|o0:1|Ra:5|Rn:5|Rd:5'                                  , 'group=34' ],

  # => Logical (shifted register)
  [44  , '' ,        'A64: sf:1|opc:2|0101|0|shift:2|N|Rm:5|imm6:6|Rn:5|Rd:5'                                   , 'group=34' ],

  # => Data processing - SIMD and floating point
  [45  , '' ,        'A64: op0:4|111|op1:2|op2:4|op3:2|x|op4:6|xxxxxxxxxx'                                      , 'group=1' ],

  # => Advanced SIMD across lanes
  [46  , '' ,        'A64: 0|Q|U|0111|0|size:2|1100|0|opcode:5|10|Rn:5|Rd:5'                                    , 'group=45' ],

  # => Advanced SIMD copy
  [47  , '' ,        'A64: 0|Q|op:1|0111|0000|imm5:5|0|imm4:4|1|Rn:5|Rd:5'                                      , 'group=45' ],

  # => Advanced SIMD extract
  [48  , '' ,        'A64: 0|Q|1011|10|op2:2|0|Rm:5|0|imm4:4|0|Rn:5|Rd:5'                                       , 'group=45' ],

  # => Advanced SIMD modified immediate
  [49  , '' ,        'A64: 0|Q|op:1|0111|1000|00|a|b|c|cmode:4|o2:1|1|d|e|f|g|h|Rd:5'                           , 'group=45' ],

  # => Advanced SIMD permute
  [50  , '' ,        'A64: 0|Q|0011|10|size:2|0|Rm:5|0|opcode:3|10|Rn:5|Rd:5'                                   , 'group=45' ],

  # => Advanced SIMD scalar copy
  [51  , '' ,        'A64: 01|op:1|1111|0000|imm5:5|0|imm4:4|1|Rn:5|Rd:5'                                       , 'group=45' ],

  # => Advanced SIMD scalar pairwise
  [52  , '' ,        'A64: 01|U|1111|0|size:2|1100|0|opcode:5|10|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Advanced SIMD scalar shift by immediate
  [53  , '' ,        'A64: 01|U|1111|10|immh:4|immb:3|opcode:5|1|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Advanced SIMD scalar three different
  [54  , '' ,        'A64: 01|U|1111|0|size:2|1|Rm:5|opcode:4|00|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Advanced SIMD scalar three same
  [55  , '' ,        'A64: 01|U|1111|0|size:2|1|Rm:5|opcode:5|1|Rn:5|Rd:5'                                      , 'group=45' ],

  # => Advanced SIMD scalar two-register miscellaneous
  [56  , '' ,        'A64: 01|U|1111|0|size:2|1000|0|opcode:5|10|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Advanced SIMD scalar x indexed element
  [57  , '' ,        'A64: 01|U|1111|1|size:2|L|M|Rm:5|opcode:4|H|0|Rn:5|Rd:4'                                  , 'group=45' ],

  # => Advanced SIMD shift by immediate
  [58  , '' ,        'A64: 0|Q|U|0111|10|immh!=0000|immb:3|opcode:5|1|Rn:5|Rd:5'                                , 'group=45' ],

  # => Advanced SIMD table lookup
  [59  , '' ,        'A64: 0|Q|0011|10|op2:2|0|Rm:5|0|len:2|op:1|00|Rn:5|Rd:5'                                  , 'group=45' ],

  # => Advanced SIMD three different
  [60  , '' ,        'A64: 0|Q|U|0111|0|size:2|1|Rm:5|opcode:4|00|Rn:5|Rd:5'                                    , 'group=45' ],

  # => Advanced SIMD three same
  [61  , '' ,        'A64: 0|Q|U|0111|0|size:2|1|Rm:5|opcode:5|1|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Advanced SIMD two-register miscellaneous
  [62  , '' ,        'A64: 0|Q|U|0111|0|size:2|1000|0|opcode:5|10|Rn:5|Rd:5'                                    , 'group=45' ],

  # => Advanced SIMD vector x indexed element
  [63  , '' ,        'A64: 0|Q|U|0111|1|size:2|L|M|Rm:5|opcode:4|H|0|Rn:5|Rd:4'                                 , 'group=45' ],

  # => Cryptographic AES
  [64  , '' ,        'A64: 0100|1110|size:2|1010|0|opcode:5|10|Rn:5|Rd:5'                                       , 'group=45' ],

  # => Cryptographic three-register SHA
  [65  , '' ,        'A64: 0101|1110|size:2|0|Rm:5|0|opcode:3|00|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Cryptographic two-register SHA
  [66  , '' ,        'A64: 0101|1110|size:2|1010|0|opcode:5|10|Rn:5|Rd:5'                                       , 'group=45' ],

  # => Floating-point compare
  [67  , '' ,        'A64: M|0|S|1111|0|type:2|1|Rm:5|op:2|1000|Rn:5|opcode2:5'                                 , 'group=45' ],

  # => Floating-point conditional compare
  [68  , '' ,        'A64: M|0|S|1111|0|type:2|1|Rm:5|cond:4|01|Rn:5|op:1|nzcv:4'                               , 'group=45' ],

  # => Floating-point conditional select
  [69  , '' ,        'A64: M|0|S|1111|0|type:2|1|Rm:5|cond:4|11|Rn:5|Rd:5'                                      , 'group=45' ],

  # => Floating-point data-processing (1 source)
  [70  , '' ,        'A64: M|0|S|1111|0|type:2|1|opcode:6|1000|0|Rn:5|Rd:5'                                     , 'group=45' ],

  # => Floating-point data-processing (2 source)
  [71  , '' ,        'A64: M|0|S|1111|0|type:2|1|Rm:5|opcode:4|10|Rn:5|Rd:5'                                    , 'group=45' ],

  # => Floating-point data-processing (3 source)
  [72  , '' ,        'A64: M|0|S|1111|1|type:2|o1:1|Rm:5|o0:1|Ra:5|Rn:5|Rd:5'                                   , 'group=45' ],

  # => Floating-point immediate
  [73  , '' ,        'A64: M|0|S|1111|0|type:2|1|imm8:8|100|imm5:5|Rd:5'                                        , 'group=45' ],

  # => Conversion between floating-point and fixed-point
  [74  , '' ,        'A64: sf:1|0|S|1111|0|type:2|0|rmode:2|opcode:3|scale:6|Rn:5|Rd:5'                         , 'group=45' ],

  # => Conversion between floating-point and integer
  [75  , '' ,        'A64: sf:1|0|S|1111|0|type:2|1|rmode:2|opcode:3|0000|00|Rn:5|Rd:5'                         , 'group=45' ],

  # => Top level T32 instruction set encoding
  [1   , '' ,        'T32: op0:3|op1:2|xxxxxxxxxxxxxxxxxxxxxxxxxxx'                                             , 'group=0' ],

  # => 16-bit T32 instruction encoding
  [2   , '' ,        'T16: op0:6|xxxxxxxxxx'                                                                    , 'group=1' ],

  # => Shift (immediate), add, subtract, move, and compare
  [3   , '' ,        'T16: 00|op0:1|op1:2|op2:1|xxxxxxxxxx'                                                     , 'group=2' ],

  # => Add, subtract (three low registers)
  [4   , '' ,        'T16: 0001|10|S|Rm:3|Rn:3|Rd:3'                                                            , 'group=3' ],

  # => Add, subtract (two low registers and immediate)
  [5   , '' ,        'T16: 0001|11|S|imm3:3|Rn:3|Rd:3'                                                          , 'group=3' ],

  # => Add, subtract, compare, move (one low register and immediate)
  [6   , '' ,        'T16: 001|op:2|Rd:3|imm8:8'                                                                , 'group=3' ],

  # => Data-processing (two low registers)
  [7   , '' ,        'T16: 0100|00|op:4|Rs:3|Rd:3'                                                              , 'group=2' ],

  # => Special data instructions and branch and exchange
  [8   , '' ,        'T16: 0100|01|op0:2|xxxxxxxx'                                                              , 'group=2' ],

  # => Branch and exchange
  [9   , '' ,        'T16: 0100|0111|L|Rm:4|000'                                                                , 'group=8' ],

  # => Add, subtract, compare, move (two high registers)
  [10  , '' ,        'T16: 0100|01|op!=11|D|Rs:4|Rd:3'                                                          , 'group=8' ],

  # => Load/Store (register offset)
  [11  , '' ,        'T16: 0101|L|B|H|Rm:3|Rn:3|Rt:3'                                                           , 'group=2' ],

  # => Load/Store word/byte (immediate offset)
  [12  , '' ,        'T16: 011|B|L|imm5:5|Rn:3|Rt:3'                                                            , 'group=2' ],

  # => Load/Store halfword (immediate offset)
  [13  , '' ,        'T16: 1000|L|imm5:5|Rn:3|Rt:3'                                                             , 'group=2' ],

  # => Load/Store (SP-relative)
  [14  , '' ,        'T16: 1001|L|Rt:3|imm8:8'                                                                  , 'group=2' ],

  # => Add PC/SP (immediate)
  [15  , '' ,        'T16: 1010|SP:1|Rd:3|imm8:8'                                                               , 'group=2' ],

  # => Miscellaneous 16-bit instructions
  [16  , '' ,        'T16: 1011|op0:4|op1:2|op2:4|x|op3:1'                                                      , 'group=2' ],

  # => Adjust SP (immediate)
  [17  , '' ,        'T16: 1011|0000|S|imm7:7'                                                                  , 'group=16' ],

  # => Extend
  [18  , '' ,        'T16: 1011|0010|U|B|Rm:3|Rd:3'                                                             , 'group=16' ],

  # => Change Processor State
  [19  , '' ,        'T16: 1011|0110|01|op:1|flags:5'                                                           , 'group=16' ],

  # => Reverse bytes
  [20  , '' ,        'T16: 1011|1010|op!=10|Rm:3|Rd:3'                                                          , 'group=16' ],

  # => Hints
  [21  , '' ,        'T16: 1011|1111|hint:4|0000'                                                               , 'group=16' ],

  # => Push and Pop
  [22  , '' ,        'T16: 1011|L|10|P|register_list:8'                                                         , 'group=16' ],

  # => Load/Store multiple
  [23  , '' ,        'T16: 1100|L|Rn:3|register_list:8'                                                         , 'group=2' ],

  # => Conditional branch, and Supervisor Call
  [24  , '' ,        'T16: 1101|op0:4|xxxxxxxx'                                                                 , 'group=2' ],

  # => Exception generation
  [25  , '' ,        'T16: 1101|111|S|imm8:8'                                                                   , 'group=24' ],

  # => 32-bit T32 instruction encoding
  [26  , '' ,        'T32: 111|op0:4|op1:5|xxxx|op3:1|xxxxxxxxxxxxxxx'                                          , 'group=1' ],

  # => System register access, Advanced SIMD, and floating-point instructions
  [27  , '' ,        'T32: 111|x|11|op0:2|xxxxxxxx|xxxx|op1:3|xxxx|op2:1|xxxx'                                  , 'group=26' ],

  # => Advanced SIMD and floating-point Load/Store and 64-bit register moves
  [28  , '' ,        'T32: 1110|110|op0:4|xxxxx|xxxx|101|xxxxxxxxx'                                             , 'group=27' ],

  # => Advanced SIMD and floating-point 64-bit move
  [29  , '' ,        'T32: 1110|1100|0|D|0|op:1|Rt2:4|Rt:4|101|sz:1|opc2:2|M|o3:1|Vm:4'                         , 'group=27' ],

  # => Advanced SIMD and floating-point Load/Store
  [30  , '' ,        'T32: 1110|110|P|U|D|W|L|Rn:4|Vd:4|101|sz:1|imm8:8'                                        , 'group=27' ],

  # => Floating-point data-processing
  [31  , '' ,        'T32: 111|op0:1|1110|op1:4|op2:1|xxx|xxxx|101|xx|op3:1|x|0|xxxx'                           , 'group=27' ],

  # => Floating-point data-processing (two registers)
  [32  , '' ,        'T32: 1110|1110|1|D|11|o1:1|opc2:3|Vd:4|101|sz:1|o3:1|1|M|0|Vm:4'                          , 'group=27' ],

  # => Floating-point data-processing (three registers)
  [33  , '' ,        'T32: 1110|1110|o0:1|D|o1:2|Vn:4|Vd:4|101|sz:1|N|o2:1|M|0|Vm:4'                            , 'group=27' ],

  # => Floating-point minNum/maxNum
  [34  , '' ,        'T32: 1111|1110|1|D|00|Vn:4|Vd:4|101|sz:1|N|op:1|M|0|Vm:4'                                 , 'group=27' ],

  # => Floating-point directed convert to integer
  [35  , '' ,        'T32: 1111|1110|1|D|111|o1:1|rm:2|Vd:4|101|sz:1|op:1|1|M|0|Vm:4'                           , 'group=27' ],

  # => Floating-point and Advanced SIMD 32-bit register moves
  [36  , '' ,        'T32: 1110|1110|op0:3|xxxxx|xxxx|101|op1:1|xxx|1|xxxx'                                     , 'group=27' ],

  # => Floating-point move special register
  [37  , '' ,        'T32: 1110|1110|111|L|reg:4|Rt:4|1010|0001|0000'                                           , 'group=27' ],

  # => Advanced SIMD 8/16/32-bit element move/duplicate
  [38  , '' ,        'T32: 1110|1110|opc1:3|L|Vn:4|Rt:4|1011|N|opc2:2|1000|0'                                   , 'group=27' ],

  # => Advanced SIMD data-processing
  [39  , '' ,        'T32: 111|op0:1|1111|op1:1|x|op2:15|op3:1|x|op4:1|xxxx'                                    , 'group=27' ],

  # => Advanced SIMD two registers misc
  [40  , '' ,        'T32: 1111|1111|1|D|11|size:2|opc1:2|Vd:4|0|opc2:4|Q|M|0|Vm:4'                             , 'group=27' ],

  # => Advanced SIMD duplicate (scalar)
  [41  , '' ,        'T32: 1111|1111|1|D|11|imm4:4|Vd:4|11|opc:3|Q|M|0|Vm:4'                                    , 'group=27' ],

  # => Advanced SIMD three registers of the same length
  [42  , '' ,        'T32: 111|U|1111|0|D|size:2|Vn:4|Vd:4|opc:4|N|Q|M|o1:1|Vm:4'                               , 'group=27' ],

  # => Advanced SIMD one register and modified immediate
  [43  , '' ,        'T32: 111|i|1111|1|D|000|imm3:3|Vd:4|cmode:4|0|Q|op:1|1|imm4:4'                            , 'group=27' ],

  # => Advanced SIMD three registers of different lengths
  [44  , '' ,        'T32: 111|U|1111|1|D|size!=11|Vn:4|Vd:4|opc:4|N|0|M|0|Vm:4'                                , 'group=27' ],

  # => Advanced SIMD two registers and a scalar
  [45  , '' ,        'T32: 111|Q|1111|1|D|size!=11|Vn:4|Vd:4|opc:4|N|1|M|0|Vm:4'                                , 'group=27' ],

  # => Advanced SIMD two registers and shift amount
  [46  , '' ,        'T32: 111|U|1111|1|D|imm3H:3|imm3L:3|Vd:4|opc:4|L|Q|M|1|Vm:4'                              , 'group=27' ],

  # => System register access
  [47  , '' ,        'T32: 111|x|11|op0:1|op1:4|xxxxx|xxxx|coproc=111x|xxx|op2:1|xxxx'                          , 'group=27' ],

  # => System register 64-bit move
  [48  , '' ,        'T32: 111|o0:1|1100|0|D|0|L|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                           , 'group=27' ],

  # => System register Load/Store
  [49  , '' ,        'T32: 111|o0:1|110|P|U|0|W|L|Rn:4|CRd:4|coproc=111x|imm8:8'                                , 'group=27' ],

  # => System register 32-bit move
  [50  , '' ,        'T32: 111|o0:1|1110|opc1:3|L|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                        , 'group=27' ],

  # => Load/Store multiple
  [51  , '' ,        'T32: 1110|100|opc:2|0|W|L|Rn:4|P|M|0|register_list:13'                                    , 'group=26' ],

  # => Load/Store dual, Load/Store Exclusive, Load-Acquire/Store-Release, and table branch
  [52  , '' ,        'T32: 1110|100|op0:4|op1:1|op2:4|xxxxxxxx|op3:3|xxxxx'                                     , 'group=26' ],

  # => Load/Store Exclusive word
  [53  , '' ,        'T32: 1110|1000|010|L|Rn:4|Rt:4|Rd:4|imm8:8'                                               , 'group=52' ],

  # => Load/Store Exclusive byte/half/dual
  [54  , '' ,        'T32: 1110|1000|110|L|Rn:4|Rt:4|Rt2:4|01|sz:2|Rd:4'                                        , 'group=52' ],

  # => Load-Acquire/Store-Release
  [55  , '' ,        'T32: 1110|1000|110|L|Rn:4|Rt:4|Rt2:4|1|op:1|sz:2|Rd:4'                                    , 'group=52' ],

  # => Load/Store dual (immediate, post-indexed)
  [56  , '' ,        'T32: 1110|1000|U|11|L|Rn!=1111|Rt:4|Rt2:4|imm8:8'                                         , 'group=52' ],

  # => Load/Store dual (immediate)
  [57  , '' ,        'T32: 1110|1001|U|10|L|Rn!=1111|Rt:4|Rt2:4|imm8:8'                                         , 'group=52' ],

  # => Load/Store dual (immediate, pre-indexed)
  [58  , '' ,        'T32: 1110|1001|U|11|L|Rn!=1111|Rt:4|Rt2:4|imm8:8'                                         , 'group=52' ],

  # => Data-processing (shifted register)
  [59  , '' ,        'T32: 1110|101|op1:4|S|Rn:4|0|imm3:3|Rd:4|imm2:2|type:2|Rm:4'                              , 'group=26' ],

  # => Branches and miscellaneous control
  [60  , '' ,        'T32: 1111|0|op0:1|op1:4|op2:2|xxxx|1|op3:3|x|op4:3|xx|op5:1|xxxxx'                        , 'group=26' ],

  # => Hints
  [61  , '' ,        'T32: 1111|0011|1010|1111|1000|0000|hint:4|option:4'                                       , 'group=60' ],

  # => Change processor state
  [62  , '' ,        'T32: 1111|0011|1010|1111|1000|0|imod:2|M|A|I|F|mode:5'                                    , 'group=60' ],

  # => Miscellaneous system
  [63  , '' ,        'T32: 1111|0011|1011|1111|1000|1111|opc:4|option:4'                                        , 'group=60' ],

  # => Exception return
  [64  , '' ,        'T32: 1111|0011|1101|Rn:4|1000|1111|imm8:8'                                                , 'group=60' ],

  # => DCPS
  [65  , '' ,        'T32: 1111|0111|1000|imm4:4|1000|imm10:10|opt:2'                                           , 'group=60' ],

  # => Exception generation
  [66  , '' ,        'T32: 1111|0111|111|o1:1|imm4:4|10|o2:1|0|imm12:12'                                        , 'group=60' ],

  # => Data-processing (modified immediate)
  [67  , '' ,        'T32: 1111|0|i|0|op1:4|S|Rn:4|0|imm3:3|Rd:4|imm8:8'                                        , 'group=26' ],

  # => Data-processing (plain binary immediate)
  [68  , '' ,        'T32: 1111|0|x|1|op0:1|x|op1:2|0|xxxx|0|xxxxxxxxxxxxxxx'                                   , 'group=26' ],

  # => Data-processing (simple immediate)
  [69  , '' ,        'T32: 1111|0|i|10|o1:1|0|o2:1|0|Rn:4|0|imm3:3|Rd:4|imm8:8'                                 , 'group=68' ],

  # => Move Wide (16-bit immediate)
  [70  , '' ,        'T32: 1111|0|i|10|o1:1|100|imm4:4|0|imm3:3|Rd:4|imm8:8'                                    , 'group=68' ],

  # => Saturate, Bitfield
  [71  , '' ,        'T32: 1111|0011|op1:3|0|Rn:4|0|imm3:3|Rd:4|imm2:2|0|widthm1:5'                             , 'group=68' ],

  # => Advanced SIMD element or structure Load/Store
  [72  , '' ,        'T32: 1111|1001|op0:1|xx|0|xxxx|xxxx|op1:2|xxxxxx|op2:4'                                   , 'group=26' ],

  # => Advanced SIMD Load/Store multiple structures (immediate, post-indexed)
  [73  , '' ,        'T32: 1111|1001|0|D|L|0|Rn:4|Vd:4|type:4|size:2|align:2|1101'                              , 'group=72' ],

  # => Advanced SIMD Load/Store multiple structures (no writeback)
  [74  , '' ,        'T32: 1111|1001|0|D|L|0|Rn:4|Vd:4|type:4|size:2|align:2|1111'                              , 'group=72' ],

  # => Advanced SIMD Load/Store multiple structures (register, post-indexed)
  [75  , '' ,        'T32: 1111|1001|0|D|L|0|Rn:4|Vd:4|type:4|size:2|align:2|Rm:4'                              , 'group=72' ],

  # => Advanced SIMD Load single structure to all lanes (immediate, post-indexed)
  [76  , '' ,        'T32: 1111|1001|1|D|L|0|Rn:4|Vd:4|11|N:2|size:2|T|a|1101'                                  , 'group=72' ],

  # => Advanced SIMD load single structure to all lanes (no writeback)
  [77  , '' ,        'T32: 1111|1001|1|D|L|0|Rn:4|Vd:4|11|N:2|size:2|T|a|1111'                                  , 'group=72' ],

  # => Advanced SIMD load single structure to all lanes (register, post-indexed)
  [78  , '' ,        'T32: 1111|1001|1|D|L|0|Rn:4|Vd:4|11|N:2|size:2|T|a|Rm:4'                                  , 'group=72' ],

  # => Advanced SIMD Load/Store single structure to one lane (immediate, post-indexed)
  [79  , '' ,        'T32: 1111|1001|1|D|L|0|Rn:4|Vd:4|size!=11|N:2|index_align:4|1101'                         , 'group=72' ],

  # => Advanced SIMD Load/Store single structure to one lane (no writeback)
  [80  , '' ,        'T32: 1111|1001|1|D|L|0|Rn:4|Vd:4|size!=11|N:2|index_align:4|1111'                         , 'group=72' ],

  # => Advanced SIMD Load/Store single structure to one lane (register, post-indexed)
  [81  , '' ,        'T32: 1111|1001|1|D|L|0|Rn:4|Vd:4|size!=11|N:2|index_align:4|Rm:4'                         , 'group=72' ],

  # => Load/Store single
  [82  , '' ,        'T32: 1111|100|!=1xxx0|op0:4|xxxx|op1:6|xxxxxx'                                            , 'group=26' ],

  # => Load/Store (register offset)
  [83  , '' ,        'T32: 1111|100|S|0|size:2|L|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                             , 'group=82' ],

  # => Load/Store (immediate, post-indexed)
  [84  , '' ,        'T32: 1111|100|S|0|size:2|L|Rn!=1111|Rt:4|10|U|1|imm8:8'                                   , 'group=82' ],

  # => Load/Store (negative immediate)
  [85  , '' ,        'T32: 1111|100|S|0|size:2|L|Rn!=1111|Rt:4|1100|imm8:8'                                     , 'group=82' ],

  # => Load/Store (unprivileged)
  [86  , '' ,        'T32: 1111|100|S|0|size:2|L|Rn!=1111|Rt:4|1110|imm8:8'                                     , 'group=82' ],

  # => Load/Store (immediate, pre-indexed)
  [87  , '' ,        'T32: 1111|100|S|0|size:2|L|Rn!=1111|Rt:4|11|U|1|imm8:8'                                   , 'group=82' ],

  # => Load/Store (positive immediate)
  [88  , '' ,        'T32: 1111|100|S|1|size:2|L|Rn!=1111|Rt:4|imm12:12'                                        , 'group=82' ],

  # => Load literal
  [89  , '' ,        'T32: 1111|100|S|U|size:2|L|1111|Rt:4|imm12:12'                                            , 'group=82' ],

  # => Data-processing (register)
  [90  , '' ,        'T32: 1111|1010|op0:1|xxxxxxx|1111|xxxx|op1:4|xxxx'                                        , 'group=26' ],

  # => Register extends
  [91  , '' ,        'T32: 1111|1010|0|op1:2|U|Rn:4|1111|Rd:4|10|rotate:2|Rm:4'                                 , 'group=90' ],

  # => Parallel add-subtract
  [92  , '' ,        'T32: 1111|1010|1|op1:3|Rn:4|1111|Rd:4|0|U|H|S|Rm:4'                                       , 'group=90' ],

  # => Data-processing (two source registers)
  [93  , '' ,        'T32: 1111|1010|1|op1:3|Rn:4|1111|Rd:4|10|op2:2|Rm:4'                                      , 'group=90' ],

  # => Multiply, multiply accumulate, and absolute difference
  [94  , '' ,        'T32: 1111|1011|0|xxxxxxx|xxxxxxxx|op0:2|xxxxxx'                                           , 'group=26' ],

  # => Multiply and absolute difference
  [95  , '' ,        'T32: 1111|1011|0|op1:3|Rn:4|Ra:4|Rd:4|00|op2:2|Rm:4'                                      , 'group=94' ],

  # => Long multiply and divide
  [96  , '' ,        'T32: 1111|1011|1|op1:3|Rn:4|RdLo:4|RdHi:4|op2:4|Rm:4'                                     , 'group=26' ],

  # => Top level A32 instruction set encoding
  [1   , '' ,        'A32: cond:4|op0:3|xxxxxxxxxxxxxxxxxxxx|op1:1|xxxx'                                        , 'group=0' ],

  # => Data-processing and miscellaneous instructions
  [2   , '' ,        'A32: !=1111|00|op0:1|op1:5|xxxxxxxxxxxx|op2:1|op3:2|op4:1|xxxx'                           , 'group=1' ],

  # => Extra Load/Store
  [3   , '' ,        'A32: !=1111|000|xx|op0:1|xxxxxxxxxxxxxx|1|!=00|1|xxxx'                                    , 'group=2' ],

  # => Load/Store Dual, Half, Signed byte (register)
  [4   , '' ,        'A32: cond!=1111|000|P|U|0|W|o1:1|Rn:4|Rt:4|0000|1|op2!=00|1|Rm:4'                         , 'group=3' ],

  # => Load/Store Dual, Half, Signed byte (immediate, literal)
  [5   , '' ,        'A32: cond!=1111|000|P|U|1|W|o1:1|Rn:4|Rt:4|imm4H:4|1|op2!=00|1|imm4L:4'                   , 'group=3' ],

  # => Multiply and Accumulate
  [6   , '' ,        'A32: cond!=1111|0000|opc:3|S|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                                , 'group=2' ],

  # => Synchronization primitives and Load-Acquire/Store-Release
  [7   , '' ,        'A32: !=1111|0001|op0:1|xxxxxxxxxxx|11|xx|1001|xxxx'                                       , 'group=2' ],

  # => Load/Store Exclusive and Load-Acquire/Store-Release
  [8   , '' ,        'A32: cond!=1111|0001|1|type:2|L|Rn:4|xRd:4|11|ex:1|ord:1|1001|xRt:4'                      , 'group=7' ],

  # => Miscellaneous
  [9   , '' ,        'A32: !=1111|0001|0|op0:2|0|xxxxxxxxxxxx|0|op1:3|xxxx'                                     , 'group=2' ],

  # => Exception Generation
  [10  , '' ,        'A32: cond!=1111|0001|0|opc:2|0|imm12:12|0111|imm4:4'                                      , 'group=9' ],

  # => Move special register (register)
  [11  , '' ,        'A32: cond!=1111|0001|0|opc:2|0|mask:4|Rd:4|00|B|m|0000|Rn:4'                              , 'group=9' ],

  # => Cyclic Redundancy Check
  [12  , '' ,        'A32: cond!=1111|0001|0|sz:2|0|Rn:4|Rd:4|00|C|0010|0|Rm:4'                                 , 'group=9' ],

  # => Integer Saturating Arithmetic
  [13  , '' ,        'A32: cond!=1111|0001|0|opc:2|0|Rn:4|Rd:4|0000|0101|Rm:4'                                  , 'group=9' ],

  # => Halfword Multiply and Accumulate
  [14  , '' ,        'A32: cond!=1111|0001|0|opc:2|0|Rd:4|Ra:4|Rm:4|1|M|N|0|Rn:4'                               , 'group=2' ],

  # => Data-processing register (immediate shift)
  [15  , '' ,        'A32: !=1111|000|op0:2|xx|op1:1|xxxxxxxxxxxxxxx|0|xxxx'                                    , 'group=2' ],

  # => Integer Data Processing (three register, immediate shift)
  [16  , '' ,        'A32: cond!=1111|0000|opc:3|S|Rn:4|Rd:4|imm5:5|type:2|0|Rm:4'                              , 'group=15' ],

  # => Integer Test & Compare (two register, immediate shift)
  [17  , '' ,        'A32: cond!=1111|0001|0|opc:2|1|Rn:4|0000|imm5:5|type:2|0|Rm:4'                            , 'group=15' ],

  # => Logical Arithmetic (three register, immediate shift)
  [18  , '' ,        'A32: cond!=1111|0001|1|opc:2|S|Rn:4|Rd:4|imm5:5|type:2|0|Rm:4'                            , 'group=15' ],

  # => Data-processing register (register shift)
  [19  , '' ,        'A32: !=1111|000|op0:2|xx|op1:1|xxxxxxxxxxxx|0|xx|1|xxxx'                                  , 'group=2' ],

  # => Integer Data Processing (three register, register shift)
  [20  , '' ,        'A32: cond!=1111|0000|opc:3|S|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                              , 'group=19' ],

  # => Integer Test & Compare (two register, register shift)
  [21  , '' ,        'A32: cond!=1111|0001|0|opc:2|1|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                            , 'group=19' ],

  # => Logical Arithmetic (three register, register shift)
  [22  , '' ,        'A32: cond!=1111|0001|1|opc:2|S|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                            , 'group=19' ],

  # => Data-processing immediate
  [23  , '' ,        'A32: !=1111|001|op0:2|x|op1:2|xxxxxxxxxxxxxxxxxxxx'                                       , 'group=2' ],

  # => Integer Data Processing (two register and immediate)
  [24  , '' ,        'A32: cond!=1111|0010|opc:3|S|Rn:4|Rd:4|imm12:12'                                          , 'group=23' ],

  # => Move Halfword (immediate)
  [25  , '' ,        'A32: cond!=1111|0011|0|H|00|imm4:4|Rd:4|imm12:12'                                         , 'group=23' ],

  # => Move Special Register & Hints (immediate)
  [26  , '' ,        'A32: cond!=1111|0011|0|R|10|imm4:4|1111|imm12:12'                                         , 'group=23' ],

  # => Integer Test & Compare (one register and immediate)
  [27  , '' ,        'A32: cond!=1111|0011|0|opc:2|1|Rn:4|0000|imm12:12'                                        , 'group=23' ],

  # => Logical Arithmetic (two register and immediate)
  [28  , '' ,        'A32: cond!=1111|0011|1|opc:2|S|Rn:4|Rd:4|imm12:12'                                        , 'group=23' ],

  # => Load/Store Word, Unsigned byte (immediate, literal)
  [29  , '' ,        'A32: cond!=1111|010|P|U|o2:1|W|o1:1|Rn:4|Rt:4|imm12:12'                                   , 'group=1' ],

  # => Load/Store Word, Unsigned byte (register)
  [30  , '' ,        'A32: cond!=1111|011|P|U|o2:1|W|o1:1|Rn:4|Rt:4|imm5:5|type:2|0|Rm:4'                       , 'group=1' ],

  # => Media instructions
  [31  , '' ,        'A32: !=1111|011|op0:5|xxxxxxxxxxxx|op1:3|1|xxxx'                                          , 'group=1' ],

  # => Parallel Arithmetic
  [32  , '' ,        'A32: cond!=1111|0110|0|op1:3|Rn:4|Rd:4|1111|B|op2:2|1|Rm:4'                               , 'group=31' ],

  # => Saturate 16-bit
  [33  , '' ,        'A32: cond!=1111|0110|1|U|10|sat_imm:4|Rd:4|1111|0011|Rn:4'                                , 'group=31' ],

  # => Reverse Bit/Byte
  [34  , '' ,        'A32: cond!=1111|0110|1|o1:1|1111|11|Rd:4|1111|o2:1|011|Rm:4'                              , 'group=31' ],

  # => Saturate 32-bit
  [35  , '' ,        'A32: cond!=1111|0110|1|U|1|sat_imm:5|Rd:4|imm5:5|sh:1|01|Rn:4'                            , 'group=31' ],

  # => Extend and Add
  [36  , '' ,        'A32: cond!=1111|0110|1|U|op:2|Rn:4|Rd:4|rotate:2|0001|11|Rm:4'                            , 'group=31' ],

  # => Signed multiply, Divide
  [37  , '' ,        'A32: cond!=1111|0111|0|op1:3|Rd:4|Ra:4|Rm:4|op2:3|1|Rn:4'                                 , 'group=31' ],

  # => Unsigned Sum of Absolute Differences
  [38  , '' ,        'A32: cond!=1111|0111|1000|Rd:4|Ra:4|Rm:4|0001|Rn:4'                                       , 'group=31' ],

  # => Bitfield Insert
  [39  , '' ,        'A32: cond!=1111|0111|110|msb:5|Rd:4|lsb:5|001|Rn:4'                                       , 'group=31' ],

  # => Permanently UNDEFINED
  [40  , '' ,        'A32: cond!=1111|0111|1111|imm12:12|1111|imm4:4'                                           , 'group=31' ],

  # => Bitfield Extract
  [41  , '' ,        'A32: cond!=1111|0111|1|U|1|widthm1:5|Rd:4|lsb:5|101|Rn:4'                                 , 'group=31' ],

  # => Branch, branch with link, and block data transfer
  [42  , '' ,        'A32: cond:4|10|op0:1|xxxxxxxxxxxxxxxxxxxxxxxxx'                                           , 'group=1' ],

  # => Exception Save/Restore
  [43  , '' ,        'A32: 1111|100|P|U|S|W|L|Rn:4|op:11|mode:5'                                                , 'group=42' ],

  # => Load/Store Multiple
  [44  , '' ,        'A32: cond!=1111|100|P|U|op:1|W|L|Rn:4|register_list:16'                                   , 'group=42' ],

  # => Branch (immediate)
  [45  , '' ,        'A32: cond:4|101|H|imm24:24'                                                               , 'group=42' ],

  # => System register access, Advanced SIMD, floating-point, and Supervisor Call
  [46  , '' ,        'A32: xxxx|11|op0:2|xxxxxxxxxxxx|op1:3|xxxx|op2:1|xxxx'                                    , 'group=1' ],

  # => Floating-point and Advanced SIMD Load/Store and 64-bit register moves
  [47  , '' ,        'A32: !=1111|110|op0:4|xxxxxxxxx|101|xxxxxxxxx'                                            , 'group=46' ],

  # => Advanced SIMD and floating-point 64-bit move
  [48  , '' ,        'A32: cond!=1111|1100|0|D|0|op:1|Rt2:4|Rt:4|101|sz:1|opc2:2|M|o3:1|Vm:4'                   , 'group=47' ],

  # => Advanced SIMD and floating-point Load/Store
  [49  , '' ,        'A32: cond!=1111|110|P|U|D|W|L|Rn:4|Vd:4|101|sz:1|imm8:8'                                  , 'group=47' ],

  # => Floating-point data-processing
  [50  , '' ,        'A32: cond:4|1110|op0:4|op1:1|xxxxxxx|101|xx|op2:1|x|0|xxxx'                               , 'group=46' ],

  # => Floating-point minNum/maxNum
  [51  , '' ,        'A32: 1111|1110|1|D|00|Vn:4|Vd:4|101|sz:1|N|op:1|M|0|Vm:4'                                 , 'group=50' ],

  # => Floating-point directed convert to integer
  [52  , '' ,        'A32: 1111|1110|1|D|111|o1:1|rm:2|Vd:4|101|sz:1|op:1|1|M|0|Vm:4'                           , 'group=50' ],

  # => Floating-point data-processing (two registers)
  [53  , '' ,        'A32: cond!=1111|1110|1|D|11|o1:1|opc2:3|Vd:4|101|sz:1|o3:1|1|M|0|Vm:4'                    , 'group=50' ],

  # => Floating-point data-processing (three registers)
  [54  , '' ,        'A32: cond!=1111|1110|o0:1|D|o1:2|Vn:4|Vd:4|101|sz:1|N|o2:1|M|0|Vm:4'                      , 'group=50' ],

  # => Floating-point and Advanced SIMD 32-bit register moves
  [55  , '' ,        'A32: !=1111|1110|op0:3|xxxxxxxxx|101|op1:1|xxx|1|xxxx'                                    , 'group=46' ],

  # => Floating-point move special register
  [56  , '' ,        'A32: cond!=1111|1110|111|L|reg:4|Rt:4|1010|0001|0000'                                     , 'group=55' ],

  # => Advanced SIMD 8/16/32-bit element move/duplicate
  [57  , '' ,        'A32: cond!=1111|1110|opc1:3|L|Vn:4|Rt:4|1011|N|opc2:2|1000|0'                             , 'group=55' ],

  # => Supervisor call
  [58  , '' ,        'A32: cond:4|1111|xxxxxxxxxxxxxxxxxxxxxxxx'                                                , 'group=46' ],

  # => System register access
  [59  , '' ,        'A32: xxxx|11|op0:1|op1:4|xxxxxxxxx|coproc=111x|xxx|op2:1|xxxx'                            , 'group=46' ],

  # => System register 64-bit move
  [60  , '' ,        'A32: cond:4|1100|0|D|0|L|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                             , 'group=59' ],

  # => System register Load/Store
  [61  , '' ,        'A32: cond:4|110|P|U|0|W|L|Rn:4|CRd:4|coproc=111x|imm8:8'                                  , 'group=59' ],

  # => System register 32-bit move
  [62  , '' ,        'A32: cond:4|1110|opc1:3|L|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                          , 'group=59' ],

  # => Unconditional instructions
  [63  , '' ,        'A32: 1111|0|op0:2|xxxx|op1:1|xxxxxxxxxxxxxxxxxxxx'                                        , 'group=1' ],

  # => Miscellaneous
  [64  , '' ,        'A32: 1111|000|op0:5|xxxxxxxxxxxx|op1:4|xxxx'                                              , 'group=63' ],

  # => Change Process State
  [65  , '' ,        'A32: 1111|0001|0000|imod:2|M|op:1|0000|00|E|A|I|F|0|mode:5'                               , 'group=64' ],

  # => Advanced SIMD data-processing
  [66  , '' ,        'A32: 1111|001|op0:2|x|op1:15|op2:1|x|op3:1|xxxx'                                          , 'group=63' ],

  # => Advanced SIMD two registers misc
  [67  , '' ,        'A32: 1111|0011|1|D|11|size:2|opc1:2|Vd:4|0|opc2:4|Q|M|0|Vm:4'                             , 'group=66' ],

  # => Advanced SIMD duplicate (scalar)
  [68  , '' ,        'A32: 1111|0011|1|D|11|imm4:4|Vd:4|11|opc:3|Q|M|0|Vm:4'                                    , 'group=66' ],

  # => Advanced SIMD three registers of the same length
  [69  , '' ,        'A32: 1111|001|U|0|D|size:2|Vn:4|Vd:4|opc:4|N|Q|M|o1:1|Vm:4'                               , 'group=66' ],

  # => Advanced SIMD one register and modified immediate
  [70  , '' ,        'A32: 1111|001|i|1|D|000|imm3:3|Vd:4|cmode:4|0|Q|op:1|1|imm4:4'                            , 'group=66' ],

  # => Advanced SIMD three registers of different lengths
  [71  , '' ,        'A32: 1111|001|U|1|D|size!=11|Vn:4|Vd:4|opc:4|N|0|M|0|Vm:4'                                , 'group=66' ],

  # => Advanced SIMD two registers and a scalar
  [72  , '' ,        'A32: 1111|001|Q|1|D|size!=11|Vn:4|Vd:4|opc:4|N|1|M|0|Vm:4'                                , 'group=66' ],

  # => Advanced SIMD two registers and shift amount
  [73  , '' ,        'A32: 1111|001|U|1|D|imm3H:3|imm3L:3|Vd:4|opc:4|L|Q|M|1|Vm:4'                              , 'group=66' ],

  # => Memory hints and barriers
  [74  , '' ,        'A32: 1111|01|op0:5|1|xxxxxxxxxxxxxxx|op1:1|xxxx'                                          , 'group=63' ],

  # => Barriers
  [75  , '' ,        'A32: 1111|0101|0111|1111|1111|0000|opcode:4|option:4'                                     , 'group=74' ],

  # => Preload (immediate)
  [76  , '' ,        'A32: 1111|010|D|U|R|01|Rn:4|1111|imm12:12'                                                , 'group=74' ],

  # => Preload (register)
  [77  , '' ,        'A32: 1111|011|D|U|o2:1|01|Rn:4|1111|imm5:5|type:2|0|Rm:4'                                 , 'group=74' ],

  # => Advanced SIMD element or structure Load/Store
  [78  , '' ,        'A32: 1111|0100|op0:1|xx|0|xxxxxxxx|op1:2|xxxxxx|op2:4'                                    , 'group=63' ],

  # => Advanced SIMD Load/Store multiple structures (immediate, post-indexed)
  [79  , '' ,        'A32: 1111|0100|0|D|L|0|Rn:4|Vd:4|type:4|size:2|align:2|1101'                              , 'group=78' ],

  # => Advanced SIMD Load/Store multiple structures (no writeback)
  [80  , '' ,        'A32: 1111|0100|0|D|L|0|Rn:4|Vd:4|type:4|size:2|align:2|1111'                              , 'group=78' ],

  # => Advanced SIMD Load/Store multiple structures (register, post-indexed)
  [81  , '' ,        'A32: 1111|0100|0|D|L|0|Rn:4|Vd:4|type:4|size:2|align:2|Rm:4'                              , 'group=78' ],

  # => Advanced SIMD load single structure to all lanes (immediate, post-indexed)
  [82  , '' ,        'A32: 1111|0100|1|D|L|0|Rn:4|Vd:4|11|N:2|size:2|T|a|1101'                                  , 'group=78' ],

  # => Advanced SIMD load single structure to all lanes (no writeback)
  [83  , '' ,        'A32: 1111|0100|1|D|L|0|Rn:4|Vd:4|11|N:2|size:2|T|a|1111'                                  , 'group=78' ],

  # => Advanced SIMD load single structure to all lanes (register, post-indexed)
  [84  , '' ,        'A32: 1111|0100|1|D|L|0|Rn:4|Vd:4|11|N:2|size:2|T|a|Rm:4'                                  , 'group=78' ],

  # => Advanced SIMD Load/Store single structure to one lane (immediate, post-indexed)
  [85  , '' ,        'A32: 1111|0100|1|D|L|0|Rn:4|Vd:4|size!=11|N:2|index_align:4|1101'                         , 'group=78' ],

  # => Advanced SIMD Load/Store single structure to one lane (no writeback)
  [86  , '' ,        'A32: 1111|0100|1|D|L|0|Rn:4|Vd:4|size!=11|N:2|index_align:4|1111'                         , 'group=78' ],

  # => Advanced SIMD Load/Store single structure to one lane (register, post-indexed)
  [87  , '' ,        'A32: 1111|0100|1|D|L|0|Rn:4|Vd:4|size!=11|N:2|index_align:4|Rm:4'                         , 'group=78' ],

);

my @instructions = (


  # ===>                                 AArch32.Base                                 <===

  # => ADC, ADCS (immediate)
  ['adc{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0101|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=UURU base' ],
  ['adcs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0101|01|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=WWXW base' ],
  ['adc{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1010|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UURU base' ],
  ['adcs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1011|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWXW base' ],

  # => ADC, ADCS (register)
  ['adc%c{%q}'               , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0001|01|Rm:3|Rdn:3'                                                   , 'group=7 it=in flags.nzcv=WWXW base' ],
  ['adcs{%q}'                , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0001|01|Rm:3|Rdn:3'                                                   , 'group=7 it=out flags.nzcv=WWXW base' ],
  ['adc{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|0100|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['adc%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0100|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=in flags.nzcv=UURU base' ],
  ['adc{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|0100|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['adcs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|0101|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXW base' ],
  ['adcs.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0101|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=out flags.nzcv=WWXW base' ],
  ['adcs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|0101|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXW base' ],
  ['adc{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['adc{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['adcs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXW base' ],
  ['adcs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXW base' ],

  # => ADC, ADCS (register-shifted register)
  ['adcs{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXW base' ],
  ['adc{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => ADD, ADDS (immediate)
  ['add%c{%q}'               , 'Rd, Rn, #imm'                           , 'T16: 0001|110|imm:3|Rn:3|Rd:3'                                                  , 'group=5 it=in flags.nzcv=WWWW base' ],
  ['adds{%q}'                , 'Rd, Rn, #imm'                           , 'T16: 0001|110|imm:3|Rn:3|Rd:3'                                                  , 'group=5 it=out flags.nzcv=WWWW base' ],
  ['add%c{%q}'               , 'Rdn, #imm'                              , 'T16: 0011|0|Rdn:3|imm:8'                                                        , 'group=6 it=in flags.nzcv=WWWW base' ],
  ['add%c{%q}'               , '{Rdn}, Rdn, #imm'                       , 'T16: 0011|0|Rdn:3|imm:8'                                                        , 'group=6 it=in flags.nzcv=WWWW base' ],
  ['adds{%q}'                , 'Rdn, #imm'                              , 'T16: 0011|0|Rdn:3|imm:8'                                                        , 'group=6 it=out flags.nzcv=WWWW base' ],
  ['adds{%q}'                , '{Rdn}, Rdn, #imm'                       , 'T16: 0011|0|Rdn:3|imm:8'                                                        , 'group=6 it=out flags.nzcv=WWWW base' ],
  ['add%c.W'                 , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0100|00|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 it=in flags.nzcv=UUUU base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0100|00|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 flags.nzcv=UUUU base' ],
  ['adds.W'                  , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0100|01|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                   , 'group=67 it=out flags.nzcv=WWWW base' ],
  ['adds{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0100|01|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                   , 'group=67 flags.nzcv=WWWW base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, #imm'                         , 'T32: 1111|0|imm:1|1000|00|Rn!=11x1|0|imm:3|Rd:4|imm:8'                          , 'group=69 flags.nzcv=UUUU base' ],
  ['addw{%c}{%q}'            , '{Rd}, Rn, #imm'                         , 'T32: 1111|0|imm:1|1000|00|Rn!=11x1|0|imm:3|Rd:4|imm:8'                          , 'group=69 flags.nzcv=UUUU base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1000|Rn!=11x1|Rd:4|cnst:12'                                , 'group=24 flags.nzcv=UUUU base' ],
  ['adds{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1001|Rn!=1101|Rd:4|cnst:12'                                , 'group=24 flags.nzcv=WWWW base' ],

  # => ADD, ADDS (register)
  ['add%c{%q}'               , 'Rd, Rn, Rm'                             , 'T16: 0001|100|Rm:3|Rn:3|Rd:3'                                                   , 'group=4 it=in flags.nzcv=WWXW base' ],
  ['adds{%q}'                , '{Rd}, Rn, Rm'                           , 'T16: 0001|100|Rm:3|Rn:3|Rd:3'                                                   , 'group=4 it=out flags.nzcv=WWXW base' ],
  ['add%c{%q}'               , 'Rdn, Rm'                                , 'T16: 0100|0100|Rdn!=1|Rm!=1101|Rdn!=101'                                        , 'group=10 it=in form=preferred flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0100|Rdn!=1|Rm!=1101|Rdn!=101'                                        , 'group=10 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|0000|Rn!=1101|0000|Rd:4|0011|Rm:4'                               , 'group=59 flags.nzcv=UURU base' ],
  ['add%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0000|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'           , 'group=59 it=in flags.nzcv=UURU base' ],
  ['add{%c}.W'               , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0000|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'           , 'group=59 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|0000|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=UURU base' ],
  ['adds{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|0001|Rn!=1101|0000|Rd!=1111|0011|Rm:4'                           , 'group=59 flags.nzcv=WWXW base' ],
  ['adds.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0001|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'       , 'group=59 it=out flags.nzcv=WWXW base' ],
  ['adds{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|0001|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'  , 'group=59 flags.nzcv=WWXW base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1000|Rn!=1101|Rd:4|0000|0110|Rm:4'                         , 'group=16 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1000|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'         , 'group=16 flags.nzcv=UURU base' ],
  ['adds{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1001|Rn!=1101|Rd:4|0000|0110|Rm:4'                         , 'group=16 flags.nzcv=WWXW base' ],
  ['adds{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1001|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'         , 'group=16 flags.nzcv=WWXW base' ],

  # => ADD, ADDS (register-shifted register)
  ['adds{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXW base' ],
  ['add{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => ADD, ADDS (SP plus immediate)
  ['add{%c}{%q}'             , 'Rd, SP, #imm*4'                         , 'T16: 1010|1|Rd:3|imm:8'                                                         , 'group=15 flags.nzcv=UUUU base' ],
  ['add{%c}{%q}'             , '{SP}, SP, #imm*4'                       , 'T16: 1011|0000|0|imm:7'                                                         , 'group=17 flags.nzcv=UUUU base' ],
  ['add{%c}.W'               , '{Rd}, SP, #cnst'                        , 'T32: 1111|0|cnst:1|0100|0011|010|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=UUUU base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, #cnst'                        , 'T32: 1111|0|cnst:1|0100|0011|010|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=UUUU base' ],
  ['adds{%c}{%q}'            , '{Rd}, SP, #cnst'                        , 'T32: 1111|0|cnst:1|0100|0111|010|cnst:3|Rd!=1111|cnst:8'                        , 'group=67 flags.nzcv=WWWW base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, #imm'                         , 'T32: 1111|0|imm:1|1000|0011|010|imm:3|Rd:4|imm:8'                               , 'group=69 flags.nzcv=UUUU base' ],
  ['addw{%c}{%q}'            , '{Rd}, SP, #imm'                         , 'T32: 1111|0|imm:1|1000|0011|010|imm:3|Rd:4|imm:8'                               , 'group=69 flags.nzcv=UUUU base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, #cnst'                        , 'A32: cond!=1111|0010|1000|1101|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UUUU base' ],
  ['adds{%c}{%q}'            , '{Rd}, SP, #cnst'                        , 'A32: cond!=1111|0010|1001|1101|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWWW base' ],

  # => ADD, ADDS (SP plus register)
  ['add{%c}{%q}'             , '{Rdm}, SP, Rdm'                         , 'T16: 0100|0100|Rdm:1|1101|Rdm:3'                                                , 'group=10 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{SP}, SP, Rm'                           , 'T16: 0100|0100|1|Rm!=1101|101'                                                  , 'group=10 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, Rm, RRX'                      , 'T32: 1110|1011|0000|1101|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['add{%c}.W'               , '{Rd}, SP, Rm'                           , 'T32: 1110|1011|0000|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, Rm, {shift #amount}'          , 'T32: 1110|1011|0000|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['adds{%c}{%q}'            , '{Rd}, SP, Rm, RRX'                      , 'T32: 1110|1011|0001|1101|0000|Rd!=1111|0011|Rm:4'                               , 'group=59 flags.nzcv=WWXW base' ],
  ['adds{%c}{%q}'            , '{Rd}, SP, Rm, {shift #amount}'          , 'T32: 1110|1011|0001|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=WWXW base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, Rm, RRX'                      , 'A32: cond!=1111|0000|1000|1101|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['add{%c}{%q}'             , '{Rd}, SP, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1000|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['adds{%c}{%q}'            , '{Rd}, SP, Rm, RRX'                      , 'A32: cond!=1111|0000|1001|1101|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXW base' ],
  ['adds{%c}{%q}'            , '{Rd}, SP, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1001|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXW base' ],

  # => ADD (immediate, to PC)
  ['add{%c}{%q}'             , 'Rd, PC, #imm*4'                         , 'T16: 1010|0|Rd:3|imm:8'                                                         , 'group=15 aliasOf=adr preferredIf=never base' ],
  ['addw{%c}{%q}'            , 'Rd, PC, #imm'                           , 'T32: 1111|0|imm:1|1000|0011|110|imm:3|Rd:4|imm:8'                               , 'group=69 aliasOf=adr preferredIf=never base' ],
  ['add{%c}{%q}'             , 'Rd, PC, #imm'                           , 'T32: 1111|0|imm:1|1000|0011|110|imm:3|Rd:4|imm:8'                               , 'group=69 aliasOf=adr preferredIf=never base' ],
  ['add{%c}{%q}'             , 'Rd, PC, #cnst'                          , 'A32: cond!=1111|0010|1000|1111|Rd:4|cnst:12'                                    , 'group=24 aliasOf=adr preferredIf=never base' ],

  # => ADR
  ['adr{%c}{%q}'             , 'Rd, rel*4'                              , 'T16: 1010|0|Rd:3|rel:8'                                                         , 'group=15 base' ],
  ['adr{%c}{%q}'             , 'Rd, rel'                                , 'T32: 1111|0|rel:1|1010|1011|110|rel:3|Rd:4|rel:8'                               , 'group=69 base' ],
  ['adr{%c}.W'               , 'Rd, rel'                                , 'T32: 1111|0|rel:1|1000|0011|110|rel:3|Rd:4|rel:8'                               , 'group=69 base' ],
  ['adr{%c}{%q}'             , 'Rd, rel'                                , 'T32: 1111|0|rel:1|1000|0011|110|rel:3|Rd:4|rel:8'                               , 'group=69 base' ],
  ['adr{%c}{%q}'             , 'Rd, rel.cnst'                           , 'A32: cond!=1111|0010|1000|1111|Rd:4|rel:12'                                     , 'group=24 base' ],
  ['adr{%c}{%q}'             , 'Rd, rel.cnst'                           , 'A32: cond!=1111|0010|0100|1111|Rd:4|rel:12'                                     , 'group=24 base' ],

  # => AND, ANDS (immediate)
  ['and{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0000|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=UUUU base' ],
  ['ands{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0000|01|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                       , 'group=67 flags.nzcv=WWWU base' ],
  ['and{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0000|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UUUU base' ],
  ['ands{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0001|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWWU base' ],

  # => AND, ANDS (register)
  ['and%c{%q}'               , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0000|00|Rm:3|Rdn:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['ands{%q}'                , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0000|00|Rm:3|Rdn:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['and{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0000|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['and%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|0000|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=in flags.nzcv=UURU base' ],
  ['and{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0000|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['ands{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0001|Rn:4|0000|Rd!=1111|0011|Rm:4'                               , 'group=59 flags.nzcv=WWXU base' ],
  ['ands.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|0001|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'           , 'group=59 it=out flags.nzcv=WWXU base' ],
  ['ands{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0001|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=WWXU base' ],
  ['and{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['and{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['ands{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXU base' ],
  ['ands{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXU base' ],

  # => AND, ANDS (register-shifted register)
  ['ands{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXU base' ],
  ['and{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => ASR (immediate)
  ['asr%c{%q}'               , '{Rd}, Rm, #imm'                         , 'T16: 0001|0|imm:5|Rm:3|Rd:3'                                                    , 'group=3 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['asr%c.W'                 , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                            , 'group=59 aliasOf=mov preferredIf=always it=in flags.nzcv=UURU base' ],
  ['asr{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                            , 'group=59 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],
  ['asr{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm:5|100|Rm:4'                             , 'group=18 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => ASR (register)
  ['asr%c{%q}'               , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['asr%c.W'                 , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0100|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always it=in flags.nzcv=WWXU base' ],
  ['asr{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0100|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always flags.nzcv=WWXU base' ],
  ['asr{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0101|Rm:4'                             , 'group=22 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => ASRS (immediate)
  ['asrs{%q}'                , '{Rd}, Rm, #imm'                         , 'T16: 0001|0|imm:5|Rm:3|Rd:3'                                                    , 'group=3 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['asrs.W'                  , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                            , 'group=59 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['asrs{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                            , 'group=59 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['asrs{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm:5|100|Rm:4'                             , 'group=18 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => ASRS (register)
  ['asrs{%q}'                , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['asrs.W'                  , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0101|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['asrs{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0101|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['asrs{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0101|Rm:4'                             , 'group=22 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => B
  ['b%c{%q}'                 , 'rel*2'                                  , 'T16: 1101|cond!=111x|rel:8'                                                     , 'group=24 it=out base' ],
  ['b{%c}{%q}'               , 'rel*2'                                  , 'T16: 1110|0|rel:11'                                                             , 'group=1 it=in|last|out base' ],
  ['b%c.W'                   , 'rel*2'                                  , 'T32: 1111|0|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'           , 'group=60 it=out base' ],
  ['b%c{%q}'                 , 'rel*2'                                  , 'T32: 1111|0|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'           , 'group=60 it=out base' ],
  ['b{%c}.W'                 , 'rel*2'                                  , 'T32: 1111|0|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                           , 'group=60 base' ],
  ['b{%c}{%q}'               , 'rel*2'                                  , 'T32: 1111|0|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                           , 'group=60 base' ],
  ['b{%c}{%q}'               , 'rel*4'                                  , 'A32: cond!=1111|1010|rel:24'                                                    , 'group=45 base' ],

  # => BFC
  ['bfc{%c}{%q}'             , 'Rd, #lsb, #width'                       , 'T32: 1111|0011|0110|1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                          , 'group=71 base' ],
  ['bfc{%c}{%q}'             , 'Rd, #lsb, #width'                       , 'A32: cond!=1111|0111|110|width:5|Rd:4|lsb:5|0011|111'                           , 'group=39 base' ],

  # => BFI
  ['bfi{%c}{%q}'             , 'Rd, Rn, #lsb, #width'                   , 'T32: 1111|0011|0110|Rn!=1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                      , 'group=71 base' ],
  ['bfi{%c}{%q}'             , 'Rd, Rn, #lsb, #width'                   , 'A32: cond!=1111|0111|110|width:5|Rd:4|lsb:5|001|Rn!=1111'                       , 'group=39 base' ],

  # => BIC, BICS (immediate)
  ['bic{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0000|10|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=UUUU base' ],
  ['bics{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0000|11|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=WWWU base' ],
  ['bic{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0011|1100|Rn:4|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=UUUU base' ],
  ['bics{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0011|1101|Rn:4|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=WWWU base' ],

  # => BIC, BICS (register)
  ['bic%c{%q}'               , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0011|10|Rm:3|Rdn:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['bics{%q}'                , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0011|10|Rm:3|Rdn:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['bic{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0010|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['bic%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|0010|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=in flags.nzcv=UURU base' ],
  ['bic{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0010|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['bics{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0011|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXU base' ],
  ['bics.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|0011|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=out flags.nzcv=WWXU base' ],
  ['bics{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0011|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXU base' ],
  ['bic{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=UURU base' ],
  ['bic{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=UURU base' ],
  ['bics{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=WWXU base' ],
  ['bics{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=WWXU base' ],

  # => BIC, BICS (register-shifted register)
  ['bics{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=WWXU base' ],
  ['bic{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=UURU base' ],

  # => BKPT
  ['bkpt{%q}'                , '{#}imm'                                 , 'T16: 1011|1110|imm:8'                                                           , 'group=16 base' ],
  ['bkpt{%q}'                , '{#}imm'                                 , 'A32: cond!=1111|0001|0010|imm:12|0111|imm:4'                                    , 'group=10 base' ],

  # => BL, BLX (immediate)
  ['bl{%c}{%q}'              , 'rel*2'                                  , 'T32: 1111|0|rel.A:1|rel.D:10|11|J1:1|1|J2:1|rel.E:11'                           , 'group=60 base' ],
  ['blx{%c}{%q}'             , 'rel*4'                                  , 'T32: 1111|0|rel.A:1|rel.D:10|11|J1:1|0|J2:1|rel.E:10|H'                         , 'group=60 base' ],
  ['bl{%c}{%q}'              , 'rel*4'                                  , 'A32: cond!=1111|1011|rel:24'                                                    , 'group=45 base' ],
  ['blx{%c}{%q}'             , 'rel*2'                                  , 'A32: 1111|101|rel.B:1|rel.A:24'                                                 , 'group=45 base' ],

  # => BLX (register)
  ['blx{%c}{%q}'             , 'Rm'                                     , 'T16: 0100|0111|1|Rm:4|000'                                                      , 'group=9 base' ],
  ['blx{%c}{%q}'             , 'Rm'                                     , 'A32: cond!=1111|0001|0010|1111|1111|1111|0011|Rm:4'                             , 'group=9 base' ],

  # => BX
  ['bx{%c}{%q}'              , 'Rm'                                     , 'T16: 0100|0111|0|Rm:4|000'                                                      , 'group=9 base' ],
  ['bx{%c}{%q}'              , 'Rm'                                     , 'A32: cond!=1111|0001|0010|1111|1111|1111|0001|Rm:4'                             , 'group=9 base' ],

  # => BXJ
  ['bxj{%c}{%q}'             , 'Rm'                                     , 'T32: 1111|0011|1100|Rm:4|1000|1111|0000|0000'                                   , 'group=60 base' ],
  ['bxj{%c}{%q}'             , 'Rm'                                     , 'A32: cond!=1111|0001|0010|1111|1111|1111|0010|Rm:4'                             , 'group=9 base' ],

  # => CBNZ, CBZ
  ['cbnz{%q}'                , 'Rn, rel*4'                              , 'T16: 1011|10|rel:1|1|rel:5|Rn:3'                                                , 'group=16 base' ],
  ['cbz{%q}'                 , 'Rn, rel*4'                              , 'T16: 1011|00|rel:1|1|rel:5|Rn:3'                                                , 'group=16 base' ],

  # => CLREX
  ['clrex{%c}{%q}'           , ''                                       , 'T32: 1111|0011|1011|1111|1000|1111|0010|1111'                                   , 'group=63 base' ],
  ['clrex{%c}{%q}'           , ''                                       , 'A32: 1111|0101|0111|1111|1111|0000|0001|1111'                                   , 'group=75 base' ],

  # => CLZ
  ['clz{%c}{%q}'             , 'Rd, Rm'                                 , 'T32: 1111|1010|1011|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['clz{%c}{%q}'             , 'Rd, Rm'                                 , 'A32: cond!=1111|0001|0110|1111|Rd:4|1111|0001|Rm:4'                             , 'group=9 base' ],

  # => CMN (immediate)
  ['cmn{%c}{%q}'             , 'Rn, #cnst'                              , 'T32: 1111|0|cnst:1|0100|01|Rn:4|0|cnst:3|1111|cnst:8'                           , 'group=67 flags.nzcv=WWWW base' ],
  ['cmn{%c}{%q}'             , 'Rn, #cnst'                              , 'A32: cond!=1111|0011|0111|Rn:4|0000|cnst:12'                                    , 'group=27 flags.nzcv=WWWW base' ],

  # => CMN (register)
  ['cmn{%c}{%q}'             , 'Rn, Rm'                                 , 'T16: 0100|0010|11|Rm:3|Rn:3'                                                    , 'group=7 flags.nzcv=WWXW base' ],
  ['cmn{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'T32: 1110|1011|0001|Rn:4|0000|1111|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXW base' ],
  ['cmn{%c}.W'               , 'Rn, Rm'                                 , 'T32: 1110|1011|0001|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'               , 'group=59 flags.nzcv=WWXW base' ],
  ['cmn{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'T32: 1110|1011|0001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXW base' ],
  ['cmn{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'A32: cond!=1111|0001|0111|Rn:4|0000|0000|0110|Rm:4'                             , 'group=17 flags.nzcv=WWXW base' ],
  ['cmn{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|0111|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'             , 'group=17 flags.nzcv=WWXW base' ],

  # => CMN (register-shifted register)
  ['cmn{%c}{%q}'             , 'Rn, Rm, type Rs'                        , 'A32: cond!=1111|0001|0111|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                       , 'group=21 flags.nzcv=WWXW base' ],

  # => CMP (immediate)
  ['cmp{%c}{%q}'             , 'Rn, #imm'                               , 'T16: 0010|1|Rn:3|imm:8'                                                         , 'group=6 flags.nzcv=WWWW base' ],
  ['cmp{%c}.W'               , 'Rn, #cnst'                              , 'T32: 1111|0|cnst:1|0110|11|Rn:4|0|cnst:3|1111|cnst:8'                           , 'group=67 flags.nzcv=WWWW base' ],
  ['cmp{%c}{%q}'             , 'Rn, #cnst'                              , 'T32: 1111|0|cnst:1|0110|11|Rn:4|0|cnst:3|1111|cnst:8'                           , 'group=67 flags.nzcv=WWWW base' ],
  ['cmp{%c}{%q}'             , 'Rn, #cnst'                              , 'A32: cond!=1111|0011|0101|Rn:4|0000|cnst:12'                                    , 'group=27 flags.nzcv=WWWW base' ],

  # => CMP (register)
  ['cmp{%c}{%q}'             , 'Rn, Rm'                                 , 'T16: 0100|0010|10|Rm:3|Rn:3'                                                    , 'group=7 flags.nzcv=WWXW base' ],
  ['cmp{%c}{%q}'             , 'Rn, Rm'                                 , 'T16: 0100|0101|Rn:1|Rm:3|Rn:4'                                                  , 'group=10 flags.nzcv=WWXW base' ],
  ['cmp{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'T32: 1110|1011|1011|Rn:4|0000|1111|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXW base' ],
  ['cmp{%c}.W'               , 'Rn, Rm'                                 , 'T32: 1110|1011|1011|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'               , 'group=59 flags.nzcv=WWXW base' ],
  ['cmp{%c}{%q}'             , 'Rn, Rm, shift #amount'                  , 'T32: 1110|1011|1011|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXW base' ],
  ['cmp{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'A32: cond!=1111|0001|0101|Rn:4|0000|0000|0110|Rm:4'                             , 'group=17 flags.nzcv=WWXW base' ],
  ['cmp{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|0101|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'             , 'group=17 flags.nzcv=WWXW base' ],

  # => CMP (register-shifted register)
  ['cmp{%c}{%q}'             , 'Rn, Rm, type Rs'                        , 'A32: cond!=1111|0001|0101|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                       , 'group=21 flags.nzcv=WWXW base' ],

  # => CPS, CPSID, CPSIE
  ['cpsid{%q}'               , 'iflags'                                 , 'T16: 1011|0110|0111|0|A|I|F'                                                    , 'group=19 it=out base' ],
  ['cpsie{%q}'               , 'iflags'                                 , 'T16: 1011|0110|0110|0|A|I|F'                                                    , 'group=19 it=out base' ],
  ['cps{%q}'                 , '#mode'                                  , 'T32: 1111|0011|1010|1111|1000|0001|A|I|F|mode:5'                                , 'group=62 it=out base' ],
  ['cpsid.W'                 , 'iflags'                                 , 'T32: 1111|0011|1010|1111|1000|0110|A|I|F|mode:5'                                , 'group=62 it=out base' ],
  ['cpsid{%q}'               , 'iflags, #mode'                          , 'T32: 1111|0011|1010|1111|1000|0111|A|I|F|mode:5'                                , 'group=62 it=out base' ],
  ['cpsie.W'                 , 'iflags'                                 , 'T32: 1111|0011|1010|1111|1000|0100|A|I|F|mode:5'                                , 'group=62 it=out base' ],
  ['cpsie{%q}'               , 'iflags, #mode'                          , 'T32: 1111|0011|1010|1111|1000|0101|A|I|F|mode:5'                                , 'group=62 it=out base' ],
  ['cps{%q}'                 , '#mode'                                  , 'A32: 1111|0001|0000|0010|0000|000|A|I|F|0|mode:5'                               , 'group=65 base' ],
  ['cpsid{%q}'               , 'iflags'                                 , 'A32: 1111|0001|0000|1100|0000|000|A|I|F|0|mode:5'                               , 'group=65 base' ],
  ['cpsid{%q}'               , 'iflags, #mode'                          , 'A32: 1111|0001|0000|1110|0000|000|A|I|F|0|mode:5'                               , 'group=65 base' ],
  ['cpsie{%q}'               , 'iflags'                                 , 'A32: 1111|0001|0000|1000|0000|000|A|I|F|0|mode:5'                               , 'group=65 base' ],
  ['cpsie{%q}'               , 'iflags, #mode'                          , 'A32: 1111|0001|0000|1010|0000|000|A|I|F|0|mode:5'                               , 'group=65 base' ],

  # => CRC32
  ['crc32b{%q}'              , 'Rd, Rn, Rm'                             , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['crc32h{%q}'              , 'Rd, Rn, Rm'                             , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1001|Rm:4'                                   , 'group=93 base' ],
  ['crc32w{%q}'              , 'Rd, Rn, Rm'                             , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1010|Rm:4'                                   , 'group=93 base' ],
  ['crc32b{%q}'              , 'Rd, Rn, Rm'                             , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0000|0100|Rm:4'                             , 'group=12 base' ],
  ['crc32h{%q}'              , 'Rd, Rn, Rm'                             , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0000|0100|Rm:4'                             , 'group=12 base' ],
  ['crc32w{%q}'              , 'Rd, Rn, Rm'                             , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0000|0100|Rm:4'                             , 'group=12 base' ],

  # => CRC32C
  ['crc32cb{%q}'             , 'Rd, Rn, Rm'                             , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['crc32ch{%q}'             , 'Rd, Rn, Rm'                             , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1001|Rm:4'                                   , 'group=93 base' ],
  ['crc32cw{%q}'             , 'Rd, Rn, Rm'                             , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1010|Rm:4'                                   , 'group=93 base' ],
  ['crc32cb{%q}'             , 'Rd, Rn, Rm'                             , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0010|0100|Rm:4'                             , 'group=12 base' ],
  ['crc32ch{%q}'             , 'Rd, Rn, Rm'                             , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0010|0100|Rm:4'                             , 'group=12 base' ],
  ['crc32cw{%q}'             , 'Rd, Rn, Rm'                             , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0010|0100|Rm:4'                             , 'group=12 base' ],

  # => DBG
  ['dbg{%c}{%q}'             , '#option'                                , 'T32: 1111|0011|1010|1111|1000|0000|1111|option:4'                               , 'group=61 base' ],
  ['dbg{%c}{%q}'             , '#option'                                , 'A32: cond!=1111|0011|0010|0000|1111|0000|1111|option:4'                         , 'group=26 base' ],

  # => DCPS1, DCPS2, DCPS3
  ['dcps1'                   , ''                                       , 'T32: 1111|0111|1000|1111|1000|0000|0000|0001'                                   , 'group=65 base' ],
  ['dcps2'                   , ''                                       , 'T32: 1111|0111|1000|1111|1000|0000|0000|0010'                                   , 'group=65 base' ],
  ['dcps3'                   , ''                                       , 'T32: 1111|0111|1000|1111|1000|0000|0000|0011'                                   , 'group=65 base' ],

  # => DMB
  ['dmb{%c}{%q}'             , '{option}'                               , 'T32: 1111|0011|1011|1111|1000|1111|0101|option:4'                               , 'group=63 base' ],
  ['dmb{%c}{%q}'             , '{option}'                               , 'A32: 1111|0101|0111|1111|1111|0000|0101|option:4'                               , 'group=75 base' ],

  # => DSB
  ['dsb{%c}{%q}'             , '{option}'                               , 'T32: 1111|0011|1011|1111|1000|1111|0100|option:4'                               , 'group=63 base' ],
  ['dsb{%c}{%q}'             , '{option}'                               , 'A32: 1111|0101|0111|1111|1111|0000|0100|option:4'                               , 'group=75 base' ],

  # => EOR, EORS (immediate)
  ['eor{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0010|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=UUUU base' ],
  ['eors{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0010|01|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                       , 'group=67 flags.nzcv=WWWU base' ],
  ['eor{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0010|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UUUU base' ],
  ['eors{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0011|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWWU base' ],

  # => EOR, EORS (register)
  ['eor%c{%q}'               , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0000|01|Rm:3|Rdn:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['eors{%q}'                , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0000|01|Rm:3|Rdn:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['eor{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|1000|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['eor%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|1000|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=in flags.nzcv=UURU base' ],
  ['eor{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|1000|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['eors{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|1001|Rn:4|0000|Rd!=1111|0011|Rm:4'                               , 'group=59 flags.nzcv=WWXU base' ],
  ['eors.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|1001|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'           , 'group=59 it=out flags.nzcv=WWXU base' ],
  ['eors{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|1001|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=WWXU base' ],
  ['eor{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['eor{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['eors{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXU base' ],
  ['eors{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXU base' ],

  # => EOR, EORS (register-shifted register)
  ['eors{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXU base' ],
  ['eor{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => ERET
  ['eret{%c}{%q}'            , ''                                       , 'T32: 1111|0011|1101|1110|1000|1111|0000|0000'                                   , 'group=64 base' ],
  ['eret{%c}{%q}'            , ''                                       , 'A32: cond!=1111|0001|0110|0000|0000|0000|0110|1110'                             , 'group=9 base' ],

  # => HLT
  ['hlt{%q}'                 , '{#}imm'                                 , 'T16: 1011|1010|10|imm:6'                                                        , 'group=16 base' ],
  ['hlt{%q}'                 , '{#}imm'                                 , 'A32: cond!=1111|0001|0000|imm:12|0111|imm:4'                                    , 'group=10 base' ],

  # => HVC
  ['hvc{%q}'                 , '{#}imm'                                 , 'T32: 1111|0111|1110|imm:4|1000|imm:12'                                          , 'group=66 base' ],
  ['hvc{%q}'                 , '{#}imm'                                 , 'A32: cond!=1111|0001|0100|imm:12|0111|imm:4'                                    , 'group=10 base' ],

  # => ISB
  ['isb{%c}{%q}'             , '{option}'                               , 'T32: 1111|0011|1011|1111|1000|1111|0110|option:4'                               , 'group=63 base' ],
  ['isb{%c}{%q}'             , '{option}'                               , 'A32: 1111|0101|0111|1111|1111|0000|0110|option:4'                               , 'group=75 base' ],

  # => IT
  ['it{x{y{z}}}{%q}'         , 'cond'                                   , 'T16: 1011|1111|cond:4|mask!=0000'                                               , 'group=16 base' ],

  # => LDA
  ['lda{%c}{%q}'             , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1010|1111'                                   , 'group=55 base' ],
  ['lda{%c}{%q}'             , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1100|1001|1111'                             , 'group=8 base' ],

  # => LDAB
  ['ldab{%c}{%q}'            , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1000|1111'                                   , 'group=55 base' ],
  ['ldab{%c}{%q}'            , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1100|1001|1111'                             , 'group=8 base' ],

  # => LDAEX
  ['ldaex{%c}{%q}'           , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1110|1111'                                   , 'group=55 base' ],
  ['ldaex{%c}{%q}'           , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1110|1001|1111'                             , 'group=8 base' ],

  # => LDAEXB
  ['ldaexb{%c}{%q}'          , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1100|1111'                                   , 'group=55 base' ],
  ['ldaexb{%c}{%q}'          , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1110|1001|1111'                             , 'group=8 base' ],

  # => LDAEXD
  ['ldaexd{%c}{%q}'          , 'Rt, Rt2, [Rn]'                          , 'T32: 1110|1000|1101|Rn:4|Rt:4|Rt2:4|1111|1111'                                  , 'group=55 base' ],
  ['ldaexd{%c}{%q}'          , 'Rt, Rt2, [Rn]'                          , 'A32: cond!=1111|0001|1011|Rn:4|Rt:4|1110|1001|1111'                             , 'group=8 base' ],

  # => LDAEXH
  ['ldaexh{%c}{%q}'          , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1101|1111'                                   , 'group=55 base' ],
  ['ldaexh{%c}{%q}'          , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1110|1001|1111'                             , 'group=8 base' ],

  # => LDAH
  ['ldah{%c}{%q}'            , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1001|1111'                                   , 'group=55 base' ],
  ['ldah{%c}{%q}'            , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1100|1001|1111'                             , 'group=8 base' ],

  # => LDC (immediate)
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn, {#{+/-}imm*4}]'           , 'T32: 1110|1101|U|001|Rn!=1111|0101|1110|imm:8'                                  , 'group=49 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn], #{+/-}imm*4'             , 'T32: 1110|1100|U|011|Rn!=1111|0101|1110|imm:8'                                  , 'group=49 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn, #{+/-}imm*4]!'            , 'T32: 1110|1101|U|011|Rn!=1111|0101|1110|imm:8'                                  , 'group=49 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn], option'                  , 'T32: 1110|1100|1001|Rn!=1111|0101|1110|option:8'                                , 'group=49 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn, {#{+/-}imm*4}]'           , 'A32: cond!=1111|1101|U|001|Rn!=1111|0101|1110|imm:8'                            , 'group=61 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn], #{+/-}imm*4'             , 'A32: cond!=1111|1100|U|011|Rn!=1111|0101|1110|imm:8'                            , 'group=61 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn, #{+/-}imm*4]!'            , 'A32: cond!=1111|1101|U|011|Rn!=1111|0101|1110|imm:8'                            , 'group=61 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [Rn], option'                  , 'A32: cond!=1111|1100|1001|Rn!=1111|0101|1110|option:8'                          , 'group=61 base' ],

  # => LDC (literal)
  ['ldc{%c}{%q}'             , 'p14, c5, {+/-}rel*4'                    , 'T32: 1110|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|rel:8'                          , 'group=49 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [PC, #{+/-}imm*4]'             , 'T32: 1110|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|imm:8'                          , 'group=49 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, {+/-}rel*4'                    , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|rel:8'                    , 'group=61 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [PC, #{+/-}imm*4]'             , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|imm:8'                    , 'group=61 base' ],
  ['ldc{%c}{%q}'             , 'p14, c5, [PC], option'                  , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|option:8'                 , 'group=61 base' ],

  # => LDM, LDMIA, LDMFD
  ['ldm{IA}{%c}{%q}'         , 'Rn{!}, list'                            , 'T16: 1100|1|Rn:3|list:8'                                                        , 'group=23 form=preferred base' ],
  ['ldmfd{%c}{%q}'           , 'Rn{!}, list'                            , 'T16: 1100|1|Rn:3|list:8'                                                        , 'group=23 form=alternative base' ],
  ['ldm{IA}{%c}.W'           , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                             , 'group=51 form=preferred base' ],
  ['ldmfd{%c}.W'             , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                             , 'group=51 form=alternative base' ],
  ['ldm{IA}{%c}{%q}'         , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                             , 'group=51 form=preferred base' ],
  ['ldmfd{%c}{%q}'           , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                             , 'group=51 form=alternative base' ],
  ['ldm{IA}{%c}{%q}'         , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|10|W|1|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['ldmfd{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|10|W|1|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => LDM (exception return)
  ['ldm{amode}{%c}{%q}'      , 'Rn{!}, list'                            , 'A32: cond!=1111|100|P|U|1|W|1|Rn:4|1|list:15'                                   , 'group=44 base' ],

  # => LDM (User registers)
  ['ldm{amode}{%c}{%q}'      , 'Rn, list'                               , 'A32: cond!=1111|100|P|U|101|Rn:4|0|list:15'                                     , 'group=44 base' ],

  # => LDMDA, LDMFA
  ['ldmda{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|00|W|1|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['ldmfa{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|00|W|1|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => LDMDB, LDMEA
  ['ldmdb{%c}{%q}'           , 'Rn{!}, list'                            , 'T32: 1110|1001|00|W|1|Rn:4|list:1|list:1|0|list:13'                             , 'group=51 form=preferred base' ],
  ['ldmea{%c}{%q}'           , 'Rn{!}, list'                            , 'T32: 1110|1001|00|W|1|Rn:4|list:1|list:1|0|list:13'                             , 'group=51 form=alternative base' ],
  ['ldmdb{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|00|W|1|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['ldmea{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|00|W|1|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => LDMIB, LDMED
  ['ldmib{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|10|W|1|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['ldmed{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|10|W|1|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => LDR (immediate)
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {#{+}imm*4}]'                  , 'T16: 0110|1|imm:5|Rn:3|Rt:3'                                                    , 'group=12 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [SP, {#{+}imm*4}]'                  , 'T16: 1001|1|Rt:3|imm:8'                                                         , 'group=14 base' ],
  ['ldr{%c}.W'               , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1101|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1101|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|1100|imm:8'                                   , 'group=87 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0101|U|001|Rn!=1111|Rt:4|imm:12'                                , 'group=29 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0100|U|001|Rn!=1111|Rt:4|imm:12'                                , 'group=29 base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0101|U|011|Rn!=1111|Rt:4|imm:12'                                , 'group=29 base' ],

  # => LDR (literal)
  ['ldr{%c}{%q}'             , 'Rt, rel*4'                              , 'T16: 0100|1|Rt:3|rel:8'                                                         , 'group=2 form=preferred base' ],
  ['ldr{%c}.W'               , 'Rt, {+/-}rel'                           , 'T32: 1111|1000|U|1011|111|Rt:4|rel:12'                                          , 'group=89 form=preferred base' ],
  ['ldr{%c}{%q}'             , 'Rt, {+/-}rel'                           , 'T32: 1111|1000|U|1011|111|Rt:4|rel:12'                                          , 'group=89 form=preferred base' ],
  ['ldr{%c}{%q}'             , 'Rt, [PC, #{+/-}imm]'                    , 'T32: 1111|1000|U|1011|111|Rt:4|imm:12'                                          , 'group=89 form=alternative base' ],
  ['ldr{%c}{%q}'             , 'Rt, {+/-}rel'                           , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1111|1|Rt:4|rel:12'                           , 'group=29 form=preferred base' ],
  ['ldr{%c}{%q}'             , 'Rt, [PC, #{+/-}imm]'                    , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1111|1|Rt:4|imm:12'                           , 'group=29 form=alternative base' ],

  # => LDR (register)
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|100|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['ldr{%c}.W'               , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                          , 'group=83 flags.nzcv=UURU base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                           , 'group=83 flags.nzcv=UURU base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {+/-}Rm, {shift #amount}]'     , 'A32: cond!=1111|0111|U|001|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|001|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['ldr{%c}{%q}'             , 'Rt, [Rn, {+/-}Rm, {shift #amount}]!'    , 'A32: cond!=1111|0111|U|011|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => LDRB (immediate)
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T16: 0111|1|imm:5|Rn:3|Rt:3'                                                    , 'group=12 base' ],
  ['ldrb{%c}.W'              , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1001|Rn!=1111|Rt!=1111|imm:12'                                   , 'group=88 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1001|Rn!=1111|Rt!=1111|imm:12'                                   , 'group=88 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|1100|imm:8'                               , 'group=87 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0101|U|101|Rn!=1111|Rt:4|imm:12'                                , 'group=29 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0100|U|101|Rn!=1111|Rt:4|imm:12'                                , 'group=29 base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0101|U|111|Rn!=1111|Rt:4|imm:12'                                , 'group=29 base' ],

  # => LDRB (literal)
  ['ldrb{%c}{%q}'            , 'Rt, {+/-}rel'                           , 'T32: 1111|1000|U|0011|111|Rt!=1111|rel:12'                                      , 'group=89 form=preferred base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [PC, #{+/-}imm]'                    , 'T32: 1111|1000|U|0011|111|Rt!=1111|imm:12'                                      , 'group=89 form=alternative base' ],
  ['ldrb{%c}{%q}'            , 'Rt, {+/-}rel'                           , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1111|1|Rt:4|rel:12'                           , 'group=29 form=preferred base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [PC, #{+/-}imm]'                    , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1111|1|Rt:4|imm:12'                           , 'group=29 form=alternative base' ],

  # => LDRB (register)
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|110|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['ldrb{%c}.W'              , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                      , 'group=83 flags.nzcv=UURU base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                       , 'group=83 flags.nzcv=UURU base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm, {shift #amount}]'     , 'A32: cond!=1111|0111|U|101|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|101|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['ldrb{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm, {shift #amount}]!'    , 'A32: cond!=1111|0111|U|111|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => LDRBT
  ['ldrbt{%c}{%q}'           , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 flags.nzcv=UURU base' ],
  ['ldrbt{%c}{%q}'           , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0100|U|111|Rn:4|Rt:4|imm:12'                                    , 'group=29 flags.nzcv=UURU base' ],
  ['ldrbt{%c}{%q}'           , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|111|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => LDRD (immediate)
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn, {#{+/-}imm*4}]'           , 'T32: 1110|1001|U|101|Rn!=1111|Rt:4|Rt2:4|imm:8'                                 , 'group=58 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn], #{+/-}imm*4'             , 'T32: 1110|1000|U|111|Rn!=1111|Rt:4|Rt2:4|imm:8'                                 , 'group=58 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn, #{+/-}imm*4]!'            , 'T32: 1110|1001|U|111|Rn!=1111|Rt:4|Rt2:4|imm:8'                                 , 'group=58 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn, {#{+/-}imm}]'             , 'A32: cond!=1111|0001|U|100|Rn!=1111|Rt:4|imm:4|1101|imm:4'                      , 'group=5 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn], #{+/-}imm'               , 'A32: cond!=1111|0000|U|100|Rn!=1111|Rt:4|imm:4|1101|imm:4'                      , 'group=5 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn, #{+/-}imm]!'              , 'A32: cond!=1111|0001|U|110|Rn!=1111|Rt:4|imm:4|1101|imm:4'                      , 'group=5 base' ],

  # => LDRD (literal)
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, {+/-}rel*4'                    , 'T32: 1110|100|P!=0|U|1|W!=0|1111|1|Rt:4|Rt2:4|rel:8'                            , 'group=52 form=preferred base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [PC, #{+/-}imm]'               , 'T32: 1110|100|P!=0|U|1|W!=0|1111|1|Rt:4|Rt2:4|imm:8'                            , 'group=52 form=alternative base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, {+/-}rel'                      , 'A32: cond!=1111|0001|U|1001|111|Rt:4|rel:4|1101|rel:4'                          , 'group=5 form=preferred base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [PC, #{+/-}imm]'               , 'A32: cond!=1111|0001|U|1001|111|Rt:4|imm:4|1101|imm:4'                          , 'group=5 form=alternative base' ],

  # => LDRD (register)
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn, {+/-}Rm]'                 , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn], {+/-}Rm'                 , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 base' ],
  ['ldrd{%c}{%q}'            , 'Rt, Rt2, [Rn, {+/-}Rm]!'                , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 base' ],

  # => LDREX
  ['ldrex{%c}{%q}'           , 'Rt, [Rn, {#imm*4}]'                     , 'T32: 1110|1000|0101|Rn:4|Rt:4|1111|imm:8'                                       , 'group=53 base' ],
  ['ldrex{%c}{%q}'           , 'Rt, [Rn, {{#}imm}]'                     , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1111|1001|1111'                             , 'group=8 base' ],

  # => LDREXB
  ['ldrexb{%c}{%q}'          , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|0100|1111'                                   , 'group=54 base' ],
  ['ldrexb{%c}{%q}'          , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1111|1001|1111'                             , 'group=8 base' ],

  # => LDREXD
  ['ldrexd{%c}{%q}'          , 'Rt, Rt2, [Rn]'                          , 'T32: 1110|1000|1101|Rn:4|Rt:4|Rt2:4|0111|1111'                                  , 'group=54 base' ],
  ['ldrexd{%c}{%q}'          , 'Rt, Rt2, [Rn]'                          , 'A32: cond!=1111|0001|1011|Rn:4|Rt:4|1111|1001|1111'                             , 'group=8 base' ],

  # => LDREXH
  ['ldrexh{%c}{%q}'          , 'Rt, [Rn]'                               , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|0101|1111'                                   , 'group=54 base' ],
  ['ldrexh{%c}{%q}'          , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1111|1001|1111'                             , 'group=8 base' ],

  # => LDRH (immediate)
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {#{+}imm*2}]'                  , 'T16: 1000|1|imm:5|Rn:3|Rt:3'                                                    , 'group=13 base' ],
  ['ldrh{%c}.W'              , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1011|Rn!=1111|Rt!=1111|imm:12'                                   , 'group=88 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1011|Rn!=1111|Rt!=1111|imm:12'                                   , 'group=88 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|1100|imm:8'                               , 'group=87 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1011|imm:4'                      , 'group=5 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1011|imm:4'                      , 'group=5 base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1011|imm:4'                      , 'group=5 base' ],

  # => LDRH (literal)
  ['ldrh{%c}{%q}'            , 'Rt, {+/-}rel'                           , 'T32: 1111|1000|U|0111|111|Rt!=1111|rel:12'                                      , 'group=89 form=preferred base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [PC, #{+/-}imm]'                    , 'T32: 1111|1000|U|0111|111|Rt!=1111|imm:12'                                      , 'group=89 form=alternative base' ],
  ['ldrh{%c}{%q}'            , 'Rt, {+/-}rel'                           , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1011|rel:4'                 , 'group=5 form=preferred base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [PC, #{+/-}imm]'                    , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1011|imm:4'                 , 'group=5 form=alternative base' ],

  # => LDRH (register)
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|101|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['ldrh{%c}.W'              , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                      , 'group=83 flags.nzcv=UURU base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                       , 'group=83 flags.nzcv=UURU base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm]'                      , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['ldrh{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm]!'                     , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],

  # => LDRHT
  ['ldrht{%c}{%q}'           , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 base' ],
  ['ldrht{%c}{%q}'           , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1011|imm:4'                          , 'group=5 base' ],
  ['ldrht{%c}{%q}'           , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 base' ],

  # => LDRSB (immediate)
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1001|1001|Rn!=1111|Rt!=1111|imm:12'                                   , 'group=88 base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|1100|imm:8'                                   , 'group=87 base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1101|imm:4'                      , 'group=5 base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1101|imm:4'                      , 'group=5 base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1101|imm:4'                      , 'group=5 base' ],

  # => LDRSB (literal)
  ['ldrsb{%c}{%q}'           , 'Rt, {+/-}rel'                           , 'T32: 1111|1001|U|0011|111|Rt!=1111|rel:12'                                      , 'group=89 form=preferred base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [PC, #{+/-}imm]'                    , 'T32: 1111|1001|U|0011|111|Rt!=1111|imm:12'                                      , 'group=89 form=alternative base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, {+/-}rel'                           , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1101|rel:4'                 , 'group=5 form=preferred base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [PC, #{+/-}imm]'                    , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1101|imm:4'                 , 'group=5 form=alternative base' ],

  # => LDRSB (register)
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|011|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['ldrsb{%c}.W'             , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1001|0001|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                      , 'group=83 flags.nzcv=UURU base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1001|0001|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                       , 'group=83 flags.nzcv=UURU base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {+/-}Rm]'                      , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['ldrsb{%c}{%q}'           , 'Rt, [Rn, {+/-}Rm]!'                     , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],

  # => LDRSBT
  ['ldrsbt{%c}{%q}'          , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 base' ],
  ['ldrsbt{%c}{%q}'          , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1101|imm:4'                          , 'group=5 base' ],
  ['ldrsbt{%c}{%q}'          , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1101|Rm:4'                            , 'group=4 base' ],

  # => LDRSH (immediate)
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1001|1011|Rn!=1111|Rt!=1111|imm:12'                                   , 'group=88 base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|1100|imm:8'                               , 'group=87 base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1111|imm:4'                      , 'group=5 base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1111|imm:4'                      , 'group=5 base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1111|imm:4'                      , 'group=5 base' ],

  # => LDRSH (literal)
  ['ldrsh{%c}{%q}'           , 'Rt, {+/-}rel'                           , 'T32: 1111|1001|U|0111|111|Rt!=1111|rel:12'                                      , 'group=89 form=preferred base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [PC, #{+/-}imm]'                    , 'T32: 1111|1001|U|0111|111|Rt!=1111|imm:12'                                      , 'group=89 form=alternative base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, {+/-}rel'                           , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1111|rel:4'                 , 'group=5 form=preferred base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [PC, #{+/-}imm]'                    , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1111|imm:4'                 , 'group=5 form=alternative base' ],

  # => LDRSH (register)
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|111|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['ldrsh{%c}.W'             , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                      , 'group=83 flags.nzcv=UURU base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                       , 'group=83 flags.nzcv=UURU base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {+/-}Rm]'                      , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['ldrsh{%c}{%q}'           , 'Rt, [Rn, {+/-}Rm]!'                     , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],

  # => LDRSHT
  ['ldrsht{%c}{%q}'          , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 base' ],
  ['ldrsht{%c}{%q}'          , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1111|imm:4'                          , 'group=5 base' ],
  ['ldrsht{%c}{%q}'          , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 base' ],

  # => LDRT
  ['ldrt{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 flags.nzcv=UURU base' ],
  ['ldrt{%c}{%q}'            , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0100|U|011|Rn:4|Rt:4|imm:12'                                    , 'group=29 flags.nzcv=UURU base' ],
  ['ldrt{%c}{%q}'            , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|011|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => LSL (immediate)
  ['lsl%c{%q}'               , '{Rd}, Rm, #imm'                         , 'T16: 0000|0|imm!=00000|Rm:3|Rd:3'                                               , 'group=3 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['lsl%c.W'                 , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                            , 'group=59 aliasOf=mov preferredIf=always it=in flags.nzcv=UURU base' ],
  ['lsl{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                            , 'group=59 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],
  ['lsl{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm!=00000|000|Rm:4'                        , 'group=18 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => LSL (register)
  ['lsl%c{%q}'               , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['lsl%c.W'                 , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0000|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always it=in flags.nzcv=WWXU base' ],
  ['lsl{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0000|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always flags.nzcv=WWXU base' ],
  ['lsl{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0001|Rm:4'                             , 'group=22 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => LSLS (immediate)
  ['lsls{%q}'                , '{Rd}, Rm, #imm'                         , 'T16: 0000|0|imm!=00000|Rm:3|Rd:3'                                               , 'group=3 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['lsls.W'                  , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                            , 'group=59 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['lsls{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                            , 'group=59 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['lsls{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm!=00000|000|Rm:4'                        , 'group=18 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => LSLS (register)
  ['lsls{%q}'                , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['lsls.W'                  , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0001|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['lsls{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0001|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['lsls{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0001|Rm:4'                             , 'group=22 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => LSR (immediate)
  ['lsr%c{%q}'               , '{Rd}, Rm, #imm'                         , 'T16: 0000|1|imm:5|Rm:3|Rd:3'                                                    , 'group=3 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['lsr%c.W'                 , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                            , 'group=59 aliasOf=mov preferredIf=always it=in flags.nzcv=UURU base' ],
  ['lsr{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                            , 'group=59 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],
  ['lsr{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm:5|010|Rm:4'                             , 'group=18 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => LSR (register)
  ['lsr%c{%q}'               , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['lsr%c.W'                 , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0010|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always it=in flags.nzcv=WWXU base' ],
  ['lsr{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0010|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always flags.nzcv=WWXU base' ],
  ['lsr{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0011|Rm:4'                             , 'group=22 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => LSRS (immediate)
  ['lsrs{%q}'                , '{Rd}, Rm, #imm'                         , 'T16: 0000|1|imm:5|Rm:3|Rd:3'                                                    , 'group=3 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['lsrs.W'                  , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                            , 'group=59 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['lsrs{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                            , 'group=59 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['lsrs{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm:5|010|Rm:4'                             , 'group=18 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => LSRS (register)
  ['lsrs{%q}'                , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['lsrs.W'                  , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0011|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['lsrs{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0011|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['lsrs{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0011|Rm:4'                             , 'group=22 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => MCR
  ['mcr{%c}{%q}'             , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}' , 'T32: 1110|1110|opc1:3|0|CRn:4|Rt:4|coproc[0]=111x|opc2:3|1|CRm:4'               , 'group=50 base' ],
  ['mcr{%c}{%q}'             , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}' , 'A32: cond!=1111|1110|opc1:3|0|CRn:4|Rt:4|coproc[0]=111x|opc2:3|1|CRm:4'         , 'group=62 base' ],

  # => MCRR
  ['mcrr{%c}{%q}'            , 'coproc, {#}opc1, Rt, Rt2, CRm'          , 'T32: 1110|1100|0100|Rt2:4|Rt:4|coproc[0]=111x|opc1:4|CRm:4'                     , 'group=48 base' ],
  ['mcrr{%c}{%q}'            , 'coproc, {#}opc1, Rt, Rt2, CRm'          , 'A32: cond!=1111|1100|0100|Rt2:4|Rt:4|coproc[0]=111x|opc1:4|CRm:4'               , 'group=60 base' ],

  # => MLA, MLAS
  ['mla{%c}{%q}'             , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0000|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 flags.nzcv=UUUU base' ],
  ['mlas{%c}{%q}'            , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0000|0011|Rd:4|Ra:4|Rm:4|1001|Rn:4'                             , 'group=6 flags.nzcv=WWUU base' ],
  ['mla{%c}{%q}'             , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0000|0010|Rd:4|Ra:4|Rm:4|1001|Rn:4'                             , 'group=6 flags.nzcv=UUUU base' ],

  # => MLS
  ['mls{%c}{%q}'             , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0000|Rn:4|Ra:4|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['mls{%c}{%q}'             , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0000|0110|Rd:4|Ra:4|Rm:4|1001|Rn:4'                             , 'group=6 base' ],

  # => MOV, MOVS (immediate)
  ['mov%c{%q}'               , 'Rd, #imm'                               , 'T16: 0010|0|Rd:3|imm:8'                                                         , 'group=6 it=in flags.nzcv=WWWU base' ],
  ['movs{%q}'                , 'Rd, #imm'                               , 'T16: 0010|0|Rd:3|imm:8'                                                         , 'group=6 it=out flags.nzcv=WWWU base' ],
  ['mov%c.W'                 , 'Rd, #cnst'                              , 'T32: 1111|0|cnst:1|0001|0011|110|cnst:3|Rd:4|cnst:8'                            , 'group=67 it=in flags.nzcv=UUUU base' ],
  ['mov{%c}{%q}'             , 'Rd, #cnst'                              , 'T32: 1111|0|cnst:1|0001|0011|110|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=UUUU base' ],
  ['movs.W'                  , 'Rd, #cnst'                              , 'T32: 1111|0|cnst:1|0001|0111|110|cnst:3|Rd:4|cnst:8'                            , 'group=67 it=out flags.nzcv=WWWU base' ],
  ['movs{%c}{%q}'            , 'Rd, #cnst'                              , 'T32: 1111|0|cnst:1|0001|0111|110|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=WWWU base' ],
  ['mov{%c}{%q}'             , 'Rd, #imm'                               , 'T32: 1111|0|imm.B:1|1001|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                     , 'group=70 flags.nzcv=UUUU base' ],
  ['movw{%c}{%q}'            , 'Rd, #imm'                               , 'T32: 1111|0|imm.B:1|1001|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                     , 'group=70 flags.nzcv=UUUU base' ],
  ['mov{%c}{%q}'             , 'Rd, #cnst'                              , 'A32: cond!=1111|0011|1010|0000|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=UUUU base' ],
  ['movs{%c}{%q}'            , 'Rd, #cnst'                              , 'A32: cond!=1111|0011|1011|0000|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=WWWU base' ],
  ['mov{%c}{%q}'             , 'Rd, #imm'                               , 'A32: cond!=1111|0011|0000|imm:4|Rd:4|imm:12'                                    , 'group=25 flags.nzcv=UUUU base' ],
  ['movw{%c}{%q}'            , 'Rd, #imm'                               , 'A32: cond!=1111|0011|0000|imm:4|Rd:4|imm:12'                                    , 'group=25 flags.nzcv=UUUU base' ],

  # => MOV, MOVS (register)
  ['mov{%c}{%q}'             , 'Rd, Rm'                                 , 'T16: 0100|0110|Rd:1|Rm:3|Rd:4'                                                  , 'group=10 flags.nzcv=UURU base' ],
  ['mov%c{%q}'               , 'Rd, Rm, {shift #amount}'                , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                          , 'group=3 it=in flags.nzcv=WWXU base' ],
  ['movs{%q}'                , 'Rd, Rm, {shift #amount}'                , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                          , 'group=3 it=out flags.nzcv=WWXU base' ],
  ['mov{%c}{%q}'             , 'Rd, Rm, RRX'                            , 'T32: 1110|1010|0100|1111|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['mov{%c}.W'               , 'Rd, Rm, {LSL #0}'                       , 'T32: 1110|1010|0100|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 flags.nzcv=UURU base' ],
  ['mov%c.W'                 , 'Rd, Rm, {shift #amount}'                , 'T32: 1110|1010|0100|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 it=in flags.nzcv=UURU base' ],
  ['mov{%c}{%q}'             , 'Rd, Rm, {shift #amount}'                , 'T32: 1110|1010|0100|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['movs{%c}{%q}'            , 'Rd, Rm, RRX'                            , 'T32: 1110|1010|0101|1111|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXU base' ],
  ['movs.W'                  , 'Rd, Rm, {shift #amount}'                , 'T32: 1110|1010|0101|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 it=out flags.nzcv=WWXU base' ],
  ['movs{%c}{%q}'            , 'Rd, Rm, {shift #amount}'                , 'T32: 1110|1010|0101|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXU base' ],
  ['mov{%c}{%q}'             , 'Rd, Rm, RRX'                            , 'A32: cond!=1111|0001|1010|0000|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=UURU base' ],
  ['mov{%c}{%q}'             , 'Rd, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|1010|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=UURU base' ],
  ['movs{%c}{%q}'            , 'Rd, Rm, RRX'                            , 'A32: cond!=1111|0001|1011|0000|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=WWXU base' ],
  ['movs{%c}{%q}'            , 'Rd, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|1011|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=WWXU base' ],

  # => MOV, MOVS (register-shifted register)
  ['mov%c{%q}'               , 'Rdm, Rdm, ASR Rs'                       , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['movs{%q}'                , 'Rdm, Rdm, ASR Rs'                       , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['mov%c{%q}'               , 'Rdm, Rdm, LSL Rs'                       , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['movs{%q}'                , 'Rdm, Rdm, LSL Rs'                       , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['mov%c{%q}'               , 'Rdm, Rdm, LSR Rs'                       , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['movs{%q}'                , 'Rdm, Rdm, LSR Rs'                       , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['mov%c{%q}'               , 'Rdm, Rdm, ROR Rs'                       , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['movs{%q}'                , 'Rdm, Rdm, ROR Rs'                       , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['movs.W'                  , 'Rd, Rm, type Rs'                        , 'T32: 1111|1010|0|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                             , 'group=90 it=out flags.nzcv=WWXU base' ],
  ['movs{%c}{%q}'            , 'Rd, Rm, type Rs'                        , 'T32: 1111|1010|0|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                             , 'group=90 flags.nzcv=WWXU base' ],
  ['mov%c.W'                 , 'Rd, Rm, type Rs'                        , 'T32: 1111|1010|0|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                             , 'group=90 it=in flags.nzcv=UURU base' ],
  ['mov{%c}{%q}'             , 'Rd, Rm, type Rs'                        , 'T32: 1111|1010|0|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                             , 'group=90 flags.nzcv=UURU base' ],
  ['movs{%c}{%q}'            , 'Rd, Rm, type Rs'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=WWXU base' ],
  ['mov{%c}{%q}'             , 'Rd, Rm, type Rs'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=UURU base' ],

  # => MOVT
  ['movt{%c}{%q}'            , 'Rd, #imm'                               , 'T32: 1111|0|imm.B:1|1011|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                     , 'group=70 base' ],
  ['movt{%c}{%q}'            , 'Rd, #imm'                               , 'A32: cond!=1111|0011|0100|imm:4|Rd:4|imm:12'                                    , 'group=25 base' ],

  # => MRC
  ['mrc{%c}{%q}'             , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}' , 'T32: 1110|1110|opc1:3|1|CRn:4|Rt:4|coproc[0]=111x|opc2:3|1|CRm:4'               , 'group=50 flags.nzcv=WWWW base' ],
  ['mrc{%c}{%q}'             , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}' , 'A32: cond!=1111|1110|opc1:3|1|CRn:4|Rt:4|coproc[0]=111x|opc2:3|1|CRm:4'         , 'group=62 flags.nzcv=WWWW base' ],

  # => MRRC
  ['mrrc{%c}{%q}'            , 'coproc, {#}opc1, Rt, Rt2, CRm'          , 'T32: 1110|1100|0101|Rt2:4|Rt:4|coproc[0]=111x|opc1:4|CRm:4'                     , 'group=48 base' ],
  ['mrrc{%c}{%q}'            , 'coproc, {#}opc1, Rt, Rt2, CRm'          , 'A32: cond!=1111|1100|0101|Rt2:4|Rt:4|coproc[0]=111x|opc1:4|CRm:4'               , 'group=60 base' ],

  # => MRS
  ['mrs{%c}{%q}'             , 'Rd, spreg'                              , 'T32: 1111|0011|111|spreg:1|1111|1000|Rd:4|0000|0000'                            , 'group=60 base' ],
  ['mrs{%c}{%q}'             , 'Rd, spreg'                              , 'A32: cond!=1111|0001|0|spreg:1|0011|11|Rd:4|0000|0000|0000'                     , 'group=11 base' ],

  # => MRS (Banked register)
  ['mrs{%c}{%q}'             , 'Rd, bkreg'                              , 'T32: 1111|0011|111|bkreg.A:1|bkreg.C:4|1000|Rd:4|001|bkreg.B:1|0000'            , 'group=60 base' ],
  ['mrs{%c}{%q}'             , 'Rd, bkreg'                              , 'A32: cond!=1111|0001|0|bkreg.A:1|00|bkreg.C:4|Rd:4|001|bkreg.B:1|0000|0000'     , 'group=11 base' ],

  # => MSR (Banked register)
  ['msr{%c}{%q}'             , 'bkreg, Rn'                              , 'T32: 1111|0011|100|bkreg.A:1|Rn:4|1000|bkreg.C:4|001|bkreg.B:1|0000'            , 'group=60 base' ],
  ['msr{%c}{%q}'             , 'bkreg, Rn'                              , 'A32: cond!=1111|0001|0|bkreg.A:1|10|bkreg.C:4|1111|001|bkreg.B:1|0000|Rn:4'     , 'group=11 base' ],

  # => MSR (immediate)
  ['msr{%c}{%q}'             , 'spreg, #cnst'                           , 'A32: cond!=1111|0011|0|R!=0|10|mask!=0000|1111|cnst:12'                         , 'group=26 base' ],

  # => MSR (register)
  ['msr{%c}{%q}'             , 'spreg, Rn'                              , 'T32: 1111|0011|100|R|Rn:4|1000|mask:4|0000|0000'                                , 'group=60 base' ],
  ['msr{%c}{%q}'             , 'spreg, Rn'                              , 'A32: cond!=1111|0001|0|R|10|mask:4|1111|0000|0000|Rn:4'                         , 'group=11 base' ],

  # => MUL, MULS
  ['mul%c{%q}'               , 'Rdm, Rn, {Rdm}'                         , 'T16: 0100|0011|01|Rn:3|Rdm:3'                                                   , 'group=7 it=in flags.nzcv=WWUU base' ],
  ['muls{%q}'                , 'Rdm, Rn, {Rdm}'                         , 'T16: 0100|0011|01|Rn:3|Rdm:3'                                                   , 'group=7 it=out flags.nzcv=WWUU base' ],
  ['mul%c.W'                 , 'Rd, Rn, {Rm}'                           , 'T32: 1111|1011|0000|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 it=in flags.nzcv=UUUU base' ],
  ['mul{%c}{%q}'             , 'Rd, Rn, {Rm}'                           , 'T32: 1111|1011|0000|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 flags.nzcv=UUUU base' ],
  ['muls{%c}{%q}'            , 'Rd, Rn, {Rm}'                           , 'A32: cond!=1111|0000|0001|Rd:4|0000|Rm:4|1001|Rn:4'                             , 'group=6 flags.nzcv=WWUU base' ],
  ['mul{%c}{%q}'             , 'Rd, Rn, {Rm}'                           , 'A32: cond!=1111|0000|0000|Rd:4|0000|Rm:4|1001|Rn:4'                             , 'group=6 flags.nzcv=UUUU base' ],

  # => MVN, MVNS (immediate)
  ['mvn{%c}{%q}'             , 'Rd, #cnst'                              , 'T32: 1111|0|cnst:1|0001|1011|110|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=UUUU base' ],
  ['mvns{%c}{%q}'            , 'Rd, #cnst'                              , 'T32: 1111|0|cnst:1|0001|1111|110|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=WWWU base' ],
  ['mvn{%c}{%q}'             , 'Rd, #cnst'                              , 'A32: cond!=1111|0011|1110|0000|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=UUUU base' ],
  ['mvns{%c}{%q}'            , 'Rd, #cnst'                              , 'A32: cond!=1111|0011|1111|0000|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=WWWU base' ],

  # => MVN, MVNS (register)
  ['mvn%c{%q}'               , 'Rd, Rm'                                 , 'T16: 0100|0011|11|Rm:3|Rd:3'                                                    , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['mvns{%q}'                , 'Rd, Rm'                                 , 'T16: 0100|0011|11|Rm:3|Rd:3'                                                    , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['mvn{%c}{%q}'             , 'Rd, Rm, RRX'                            , 'T32: 1110|1010|0110|1111|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['mvn%c.W'                 , 'Rd, Rm'                                 , 'T32: 1110|1010|0110|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=in flags.nzcv=UURU base' ],
  ['mvn{%c}{%q}'             , 'Rd, Rm, {shift #amount}'                , 'T32: 1110|1010|0110|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['mvns{%c}{%q}'            , 'Rd, Rm, RRX'                            , 'T32: 1110|1010|0111|1111|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXU base' ],
  ['mvns.W'                  , 'Rd, Rm'                                 , 'T32: 1110|1010|0111|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=out flags.nzcv=WWXU base' ],
  ['mvns{%c}{%q}'            , 'Rd, Rm, {shift #amount}'                , 'T32: 1110|1010|0111|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXU base' ],
  ['mvn{%c}{%q}'             , 'Rd, Rm, RRX'                            , 'A32: cond!=1111|0001|1110|0000|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=UURU base' ],
  ['mvn{%c}{%q}'             , 'Rd, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|1110|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=UURU base' ],
  ['mvns{%c}{%q}'            , 'Rd, Rm, RRX'                            , 'A32: cond!=1111|0001|1111|0000|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=WWXU base' ],
  ['mvns{%c}{%q}'            , 'Rd, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|1111|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=WWXU base' ],

  # => MVN, MVNS (register-shifted register)
  ['mvns{%c}{%q}'            , 'Rd, Rm, type Rs'                        , 'A32: cond!=1111|0001|1111|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=WWXU base' ],
  ['mvn{%c}{%q}'             , 'Rd, Rm, type Rs'                        , 'A32: cond!=1111|0001|1110|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=UURU base' ],

  # => NOP
  ['nop{%c}{%q}'             , ''                                       , 'T16: 1011|1111|0000|0000'                                                       , 'group=21 base' ],
  ['nop{%c}.W'               , ''                                       , 'T32: 1111|0011|1010|1111|1000|0000|0000|0000'                                   , 'group=61 base' ],
  ['nop{%c}{%q}'             , ''                                       , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0000'                             , 'group=26 base' ],

  # => ORN, ORNS (immediate)
  ['orns{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0001|11|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 flags.nzcv=WWWU base' ],
  ['orn{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0001|10|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 flags.nzcv=UUUU base' ],

  # => ORN, ORNS (register)
  ['orn{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0110|Rn!=1111|0000|Rd:4|0011|Rm:4'                               , 'group=59 flags.nzcv=UURU base' ],
  ['orn{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0110|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=UURU base' ],
  ['orns{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0111|Rn!=1111|0000|Rd:4|0011|Rm:4'                               , 'group=59 flags.nzcv=WWXU base' ],
  ['orns{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0111|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=WWXU base' ],

  # => ORR, ORRS (immediate)
  ['orr{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0001|00|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 flags.nzcv=UUUU base' ],
  ['orrs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0001|01|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 flags.nzcv=WWWU base' ],
  ['orr{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0011|1000|Rn:4|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=UUUU base' ],
  ['orrs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0011|1001|Rn:4|Rd:4|cnst:12'                                    , 'group=28 flags.nzcv=WWWU base' ],

  # => ORR, ORRS (register)
  ['orr%c{%q}'               , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0011|00|Rm:3|Rdn:3'                                                   , 'group=7 it=in flags.nzcv=WWXU base' ],
  ['orrs{%q}'                , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0011|00|Rm:3|Rdn:3'                                                   , 'group=7 it=out flags.nzcv=WWXU base' ],
  ['orr{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0100|Rn!=1111|0000|Rd:4|0011|Rm:4'                               , 'group=59 flags.nzcv=UURU base' ],
  ['orr%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|0100|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'           , 'group=59 it=in flags.nzcv=UURU base' ],
  ['orr{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0100|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=UURU base' ],
  ['orrs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1010|0101|Rn!=1111|0000|Rd:4|0011|Rm:4'                               , 'group=59 flags.nzcv=WWXU base' ],
  ['orrs.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1010|0101|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'           , 'group=59 it=out flags.nzcv=WWXU base' ],
  ['orrs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1010|0101|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=WWXU base' ],
  ['orr{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=UURU base' ],
  ['orr{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=UURU base' ],
  ['orrs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=18 flags.nzcv=WWXU base' ],
  ['orrs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=18 flags.nzcv=WWXU base' ],

  # => ORR, ORRS (register-shifted register)
  ['orrs{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=WWXU base' ],
  ['orr{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=22 flags.nzcv=UURU base' ],

  # => PKHBT, PKHTB
  ['pkhbt{%c}{%q}'           , '{Rd}, Rn, Rm, {LSL #imm}'               , 'T32: 1110|1010|1100|Rn:4|0|imm:3|Rd:4|imm2:2|00|Rm:4'                           , 'group=59 flags.nzcv=UURU base' ],
  ['pkhtb{%c}{%q}'           , '{Rd}, Rn, Rm, {ASR #imm}'               , 'T32: 1110|1010|1100|Rn:4|0|imm:3|Rd:4|imm2:2|10|Rm:4'                           , 'group=59 flags.nzcv=UURU base' ],
  ['pkhbt{%c}{%q}'           , '{Rd}, Rn, Rm, {LSL #imm}'               , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|imm:5|001|Rm:4'                             , 'group=31 flags.nzcv=UURU base' ],
  ['pkhtb{%c}{%q}'           , '{Rd}, Rn, Rm, {ASR #imm}'               , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|imm:5|101|Rm:4'                             , 'group=31 flags.nzcv=UURU base' ],

  # => PLD, PLDW (immediate)
  ['pld{%c}{%q}'             , '[Rn, {#{+}imm}]'                        , 'T32: 1111|1000|1001|Rn!=1111|1111|imm:12'                                       , 'group=88 base' ],
  ['pldw{%c}{%q}'            , '[Rn, {#{+}imm}]'                        , 'T32: 1111|1000|1011|Rn!=1111|1111|imm:12'                                       , 'group=88 base' ],
  ['pld{%c}{%q}'             , '[Rn, {#-imm}]'                          , 'T32: 1111|1000|0001|Rn!=1111|1111|1100|imm:8'                                   , 'group=85 base' ],
  ['pldw{%c}{%q}'            , '[Rn, {#-imm}]'                          , 'T32: 1111|1000|0011|Rn!=1111|1111|1100|imm:8'                                   , 'group=85 base' ],
  ['pld{%c}{%q}'             , '[Rn, {#{+/-}imm}]'                      , 'A32: 1111|0101|U|101|Rn!=1111|1111|imm:12'                                      , 'group=76 base' ],
  ['pldw{%c}{%q}'            , '[Rn, {#{+/-}imm}]'                      , 'A32: 1111|0101|U|001|Rn!=1111|1111|imm:12'                                      , 'group=76 base' ],

  # => PLD (literal)
  ['pld{%c}{%q}'             , '{+/-}rel'                               , 'T32: 1111|1000|U|0011|1111|111|rel:12'                                          , 'group=89 form=preferred base' ],
  ['pld{%c}{%q}'             , '[PC, #{+/-}imm]'                        , 'T32: 1111|1000|U|0011|1111|111|imm:12'                                          , 'group=89 form=alternative base' ],
  ['pld{%c}{%q}'             , '{+/-}rel'                               , 'A32: 1111|0101|U|1011|1111|111|rel:12'                                          , 'group=76 form=preferred base' ],
  ['pld{%c}{%q}'             , '[PC, #{+/-}imm]'                        , 'A32: 1111|0101|U|1011|1111|111|imm:12'                                          , 'group=76 form=alternative base' ],

  # => PLD, PLDW (register)
  ['pld{%c}{%q}'             , '[Rn, {+}Rm, {LSL #amount}]'             , 'T32: 1111|1000|0001|Rn!=1111|1111|0000|00|amount:2|Rm:4'                        , 'group=83 flags.nzcv=UURU base' ],
  ['pldw{%c}{%q}'            , '[Rn, {+}Rm, {LSL #amount}]'             , 'T32: 1111|1000|0011|Rn!=1111|1111|0000|00|amount:2|Rm:4'                        , 'group=83 flags.nzcv=UURU base' ],
  ['pld{%c}{%q}'             , '[Rn, {+/-}Rm, {shift #amount}]'         , 'A32: 1111|0111|U|101|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                  , 'group=77 flags.nzcv=UURU base' ],
  ['pld{%c}{%q}'             , '[Rn, {+/-}Rm, RRX]'                     , 'A32: 1111|0111|U|101|Rn:4|1111|0000|0110|Rm:4'                                  , 'group=77 flags.nzcv=UURU base' ],
  ['pldw{%c}{%q}'            , '[Rn, {+/-}Rm, {shift #amount}]'         , 'A32: 1111|0111|U|001|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                  , 'group=77 flags.nzcv=UURU base' ],
  ['pldw{%c}{%q}'            , '[Rn, {+/-}Rm, RRX]'                     , 'A32: 1111|0111|U|001|Rn:4|1111|0000|0110|Rm:4'                                  , 'group=77 flags.nzcv=UURU base' ],

  # => PLI (immediate, literal)
  ['pli{%c}{%q}'             , '[Rn, {#{+}imm}]'                        , 'T32: 1111|1001|1001|Rn!=1111|1111|imm:12'                                       , 'group=89 base' ],
  ['pli{%c}{%q}'             , '[Rn, {#-imm}]'                          , 'T32: 1111|1001|0001|Rn!=1111|1111|1100|imm:8'                                   , 'group=89 base' ],
  ['pli{%c}{%q}'             , '{+/-}rel'                               , 'T32: 1111|1001|U|0011|1111|111|rel:12'                                          , 'group=89 form=preferred base' ],
  ['pli{%c}{%q}'             , '[PC, #{+/-}imm]'                        , 'T32: 1111|1001|U|0011|1111|111|imm:12'                                          , 'group=89 form=alternative base' ],
  ['pli{%c}{%q}'             , '[Rn, {#{+/-}imm}]'                      , 'A32: 1111|0100|U|101|Rn:4|1111|imm:12'                                          , 'group=76 base' ],
  ['pli{%c}{%q}'             , '{+/-}rel'                               , 'A32: 1111|0100|U|101|Rn:4|1111|rel:12'                                          , 'group=76 form=preferred base' ],
  ['pli{%c}{%q}'             , '[PC, #{+/-}imm]'                        , 'A32: 1111|0100|U|101|Rn:4|1111|imm:12'                                          , 'group=76 form=alternative base' ],

  # => PLI (register)
  ['pli{%c}{%q}'             , '[Rn, {+}Rm, {LSL #amount}]'             , 'T32: 1111|1001|0001|Rn!=1111|1111|0000|00|amount:2|Rm:4'                        , 'group=83 flags.nzcv=UURU base' ],
  ['pli{%c}{%q}'             , '[Rn, {+/-}Rm, RRX]'                     , 'A32: 1111|0110|U|101|Rn:4|1111|0000|0110|Rm:4'                                  , 'group=77 flags.nzcv=UURU base' ],
  ['pli{%c}{%q}'             , '[Rn, {+/-}Rm, {shift #amount}]'         , 'A32: 1111|0110|U|101|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                  , 'group=77 flags.nzcv=UURU base' ],

  # => POP
  ['pop{%c}{%q}'             , 'list'                                   , 'T16: 1011|110|list.A:1|list.I:8'                                                , 'group=22 form=preferred base' ],
  ['ldm{%c}{%q}'             , 'SP!, list'                              , 'T16: 1011|110|list.A:1|list.I:8'                                                , 'group=22 form=alternative base' ],

  # => POP (multiple registers)
  ['pop{%c}.W'               , 'list'                                   , 'T32: 1110|1000|1011|1101|list:1|list:1|0|list:13'                               , 'group=51 aliasOf=ldm preferredIf=BitCount(list.A:list.B:list.C)>1 base' ],
  ['pop{%c}{%q}'             , 'list'                                   , 'T32: 1110|1000|1011|1101|list:1|list:1|0|list:13'                               , 'group=51 aliasOf=ldm preferredIf=BitCount(list.A:list.B:list.C)>1 base' ],
  ['pop{%c}{%q}'             , 'list'                                   , 'A32: cond!=1111|1000|1011|1101|list:16'                                         , 'group=44 aliasOf=ldm preferredIf=BitCount(list)>1 base' ],

  # => POP (single register)
  ['pop{%c}{%q}'             , 'RtList'                                 , 'T32: 1111|1000|0101|1101|RtList:4|1011|0000|0100'                               , 'group=84 aliasOf=ldr preferredIf=always base' ],
  ['pop{%c}{%q}'             , 'RtList'                                 , 'A32: cond!=1111|0100|1001|1101|RtList:4|0000|0000|0100'                         , 'group=29 aliasOf=ldr preferredIf=always base' ],

  # => PUSH
  ['push{%c}{%q}'            , 'list'                                   , 'T16: 1011|010|list.A:1|list.H:8'                                                , 'group=22 form=preferred base' ],
  ['stmdb{%c}{%q}'           , 'SP!, list'                              , 'T16: 1011|010|list.A:1|list.H:8'                                                , 'group=22 form=alternative base' ],

  # => PUSH (multiple registers)
  ['push{%c}.W'              , 'list'                                   , 'T32: 1110|1001|0010|1101|list=0|list:1|0|list:13'                               , 'group=51 aliasOf=stmdb preferredIf=BitCount(list.B:list.C)>1 base' ],
  ['push{%c}{%q}'            , 'list'                                   , 'T32: 1110|1001|0010|1101|list=0|list:1|0|list:13'                               , 'group=51 aliasOf=stmdb preferredIf=BitCount(list.B:list.C)>1 base' ],
  ['push{%c}{%q}'            , 'list'                                   , 'A32: cond!=1111|1001|0010|1101|list:16'                                         , 'group=44 aliasOf=stmdb preferredIf=BitCount(list)>1 base' ],

  # => PUSH (single register)
  ['push{%c}{%q}'            , 'RtList'                                 , 'T32: 1111|1000|0100|1101|RtList:4|1101|0000|0100'                               , 'group=87 aliasOf=str preferredIf=always base' ],
  ['push{%c}{%q}'            , 'RtList'                                 , 'A32: cond!=1111|0101|0010|1101|RtList:4|0000|0000|0100'                         , 'group=29 aliasOf=str preferredIf=always base' ],

  # => QADD
  ['qadd{%c}{%q}'            , '{Rd}, Rm, Rn'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['qadd{%c}{%q}'            , '{Rd}, Rm, Rn'                           , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0000|0101|Rm:4'                             , 'group=13 base' ],

  # => QADD16
  ['qadd16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=92 base' ],
  ['qadd16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0001|Rm:4'                             , 'group=32 base' ],

  # => QADD8
  ['qadd8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=92 base' ],
  ['qadd8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|1001|Rm:4'                             , 'group=32 base' ],

  # => QASX
  ['qasx{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=92 base' ],
  ['qasx{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0011|Rm:4'                             , 'group=32 base' ],

  # => QDADD
  ['qdadd{%c}{%q}'           , '{Rd}, Rm, Rn'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1001|Rm:4'                                   , 'group=93 base' ],
  ['qdadd{%c}{%q}'           , '{Rd}, Rm, Rn'                           , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0000|0101|Rm:4'                             , 'group=13 base' ],

  # => QDSUB
  ['qdsub{%c}{%q}'           , '{Rd}, Rm, Rn'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1011|Rm:4'                                   , 'group=93 base' ],
  ['qdsub{%c}{%q}'           , '{Rd}, Rm, Rn'                           , 'A32: cond!=1111|0001|0110|Rn:4|Rd:4|0000|0101|Rm:4'                             , 'group=13 base' ],

  # => QSAX
  ['qsax{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=92 base' ],
  ['qsax{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0101|Rm:4'                             , 'group=32 base' ],

  # => QSUB
  ['qsub{%c}{%q}'            , '{Rd}, Rm, Rn'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1010|Rm:4'                                   , 'group=93 base' ],
  ['qsub{%c}{%q}'            , '{Rd}, Rm, Rn'                           , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0000|0101|Rm:4'                             , 'group=13 base' ],

  # => QSUB16
  ['qsub16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=92 base' ],
  ['qsub16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0111|Rm:4'                             , 'group=32 base' ],

  # => QSUB8
  ['qsub8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=92 base' ],
  ['qsub8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|1111|Rm:4'                             , 'group=32 base' ],

  # => RBIT
  ['rbit{%c}{%q}'            , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1010|Rm:4'                                   , 'group=93 base' ],
  ['rbit{%c}{%q}'            , 'Rd, Rm'                                 , 'A32: cond!=1111|0110|1111|1111|Rd:4|1111|0011|Rm:4'                             , 'group=34 base' ],

  # => REV
  ['rev{%c}{%q}'             , 'Rd, Rm'                                 , 'T16: 1011|1010|00|Rm:3|Rd:3'                                                    , 'group=20 base' ],
  ['rev{%c}.W'               , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['rev{%c}{%q}'             , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['rev{%c}{%q}'             , 'Rd, Rm'                                 , 'A32: cond!=1111|0110|1011|1111|Rd:4|1111|0011|Rm:4'                             , 'group=34 base' ],

  # => REV16
  ['rev16{%c}{%q}'           , 'Rd, Rm'                                 , 'T16: 1011|1010|01|Rm:3|Rd:3'                                                    , 'group=20 base' ],
  ['rev16{%c}.W'             , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1001|Rm:4'                                   , 'group=93 base' ],
  ['rev16{%c}{%q}'           , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1001|Rm:4'                                   , 'group=93 base' ],
  ['rev16{%c}{%q}'           , 'Rd, Rm'                                 , 'A32: cond!=1111|0110|1011|1111|Rd:4|1111|1011|Rm:4'                             , 'group=34 base' ],

  # => REVSH
  ['revsh{%c}{%q}'           , 'Rd, Rm'                                 , 'T16: 1011|1010|11|Rm:3|Rd:3'                                                    , 'group=20 base' ],
  ['revsh{%c}.W'             , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1011|Rm:4'                                   , 'group=93 base' ],
  ['revsh{%c}{%q}'           , 'Rd, Rm'                                 , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1011|Rm:4'                                   , 'group=93 base' ],
  ['revsh{%c}{%q}'           , 'Rd, Rm'                                 , 'A32: cond!=1111|0110|1111|1111|Rd:4|1111|1011|Rm:4'                             , 'group=34 base' ],

  # => RFE, RFEDA, RFEDB, RFEIA, RFEIB
  ['rfedb{%c}{%q}'           , 'Rn{!}'                                  , 'T32: 1110|1000|00|W|1|Rn:4|1100|0000|0000|0000'                                 , 'group=51 it=in|last|out base' ],
  ['rfe{IA}{%c}{%q}'         , 'Rn{!}'                                  , 'T32: 1110|1001|10|W|1|Rn:4|1100|0000|0000|0000'                                 , 'group=51 it=in|last|out base' ],
  ['rfeda{%c}{%q}'           , 'Rn{!}'                                  , 'A32: 1111|1000|00|W|1|Rn:4|0000|1010|0000|0000'                                 , 'group=43 base' ],
  ['rfedb{%c}{%q}'           , 'Rn{!}'                                  , 'A32: 1111|1001|00|W|1|Rn:4|0000|1010|0000|0000'                                 , 'group=43 base' ],
  ['rfe{IA}{%c}{%q}'         , 'Rn{!}'                                  , 'A32: 1111|1000|10|W|1|Rn:4|0000|1010|0000|0000'                                 , 'group=43 base' ],
  ['rfeib{%c}{%q}'           , 'Rn{!}'                                  , 'A32: 1111|1001|10|W|1|Rn:4|0000|1010|0000|0000'                                 , 'group=43 base' ],

  # => ROR (immediate)
  ['ror{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0100|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                       , 'group=59 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],
  ['ror{%c}{%q}'             , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm!=00000|110|Rm:4'                        , 'group=18 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => ROR (register)
  ['ror%c{%q}'               , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=mov it=in flags.nzcv=WWXU base' ],
  ['ror%c.W'                 , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0110|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always it=in flags.nzcv=WWXU base' ],
  ['ror{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0110|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=mov preferredIf=always flags.nzcv=WWXU base' ],
  ['ror{%c}{%q}'             , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0111|Rm:4'                             , 'group=22 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => RORS (immediate)
  ['rors{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'T32: 1110|1010|0101|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                       , 'group=59 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['rors{%c}{%q}'            , '{Rd}, Rm, #imm'                         , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm!=00000|110|Rm:4'                        , 'group=18 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => RORS (register)
  ['rors{%q}'                , '{Rdm}, Rdm, Rs'                         , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                   , 'group=7 aliasOf=movs it=out flags.nzcv=WWXU base' ],
  ['rors.W'                  , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0111|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always it=out flags.nzcv=WWXU base' ],
  ['rors{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'T32: 1111|1010|0111|Rm:4|1111|Rd:4|0000|Rs:4'                                   , 'group=90 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['rors{%c}{%q}'            , '{Rd}, Rm, Rs'                           , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0111|Rm:4'                             , 'group=22 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => RRX
  ['rrx{%c}{%q}'             , '{Rd}, Rm'                               , 'T32: 1110|1010|0100|1111|0000|Rd:4|0011|Rm:4'                                   , 'group=59 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],
  ['rrx{%c}{%q}'             , '{Rd}, Rm'                               , 'A32: cond!=1111|0001|1010|0000|Rd:4|0000|0110|Rm:4'                             , 'group=18 aliasOf=mov preferredIf=always flags.nzcv=UURU base' ],

  # => RRXS
  ['rrxs{%c}{%q}'            , '{Rd}, Rm'                               , 'T32: 1110|1010|0101|1111|0000|Rd:4|0011|Rm:4'                                   , 'group=59 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],
  ['rrxs{%c}{%q}'            , '{Rd}, Rm'                               , 'A32: cond!=1111|0001|1011|0000|Rd:4|0000|0110|Rm:4'                             , 'group=18 aliasOf=movs preferredIf=always flags.nzcv=WWXU base' ],

  # => RSB, RSBS (immediate)
  ['rsb%c{%q}'               , '{Rd}, Rn, #0'                           , 'T16: 0100|0010|01|Rn:3|Rd:3'                                                    , 'group=7 it=in flags.nzcv=WWWW base' ],
  ['rsbs{%q}'                , '{Rd}, Rn, #0'                           , 'T16: 0100|0010|01|Rn:3|Rd:3'                                                    , 'group=7 it=out flags.nzcv=WWWW base' ],
  ['rsb%c.W'                 , '{Rd}, Rn, #0'                           , 'T32: 1111|0|i|0111|00|Rn:4|0|imm3:3|Rd:4|imm8:8'                                , 'group=67 it=in flags.nzcv=UUUU base' ],
  ['rsb{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0111|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=UUUU base' ],
  ['rsbs.W'                  , '{Rd}, Rn, #0'                           , 'T32: 1111|0|i|0111|01|Rn:4|0|imm3:3|Rd:4|imm8:8'                                , 'group=67 it=out flags.nzcv=WWWW base' ],
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0111|01|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=WWWW base' ],
  ['rsb{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0110|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UUUU base' ],
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0111|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWWW base' ],

  # => RSB, RSBS (register)
  ['rsb{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|1100|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['rsb{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|1100|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|1101|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXW base' ],
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|1101|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXW base' ],
  ['rsb{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['rsb{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXW base' ],
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXW base' ],

  # => RSB, RSBS (register-shifted register)
  ['rsbs{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXW base' ],
  ['rsb{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => RSC, RSCS (immediate)
  ['rsc{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1110|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UURU base' ],
  ['rscs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1111|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWXW base' ],

  # => RSC, RSCS (register)
  ['rsc{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['rsc{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['rscs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXW base' ],
  ['rscs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXW base' ],

  # => RSC, RSCS (register-shifted register)
  ['rscs{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXW base' ],
  ['rsc{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => SADD16
  ['sadd16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=92 base' ],
  ['sadd16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0001|Rm:4'                             , 'group=32 base' ],

  # => SADD8
  ['sadd8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=92 base' ],
  ['sadd8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|1001|Rm:4'                             , 'group=32 base' ],

  # => SASX
  ['sasx{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=92 base' ],
  ['sasx{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0011|Rm:4'                             , 'group=32 base' ],

  # => SBC, SBCS (immediate)
  ['sbc{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0101|10|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=UURU base' ],
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0101|11|Rn:4|0|cnst:3|Rd:4|cnst:8'                           , 'group=67 flags.nzcv=WWXW base' ],
  ['sbc{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1100|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UURU base' ],
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|1101|Rn:4|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWXW base' ],

  # => SBC, SBCS (register)
  ['sbc%c{%q}'               , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0001|10|Rm:3|Rdn:3'                                                   , 'group=7 it=in flags.nzcv=WWXW base' ],
  ['sbcs{%q}'                , '{Rdn}, Rdn, Rm'                         , 'T16: 0100|0001|10|Rm:3|Rdn:3'                                                   , 'group=7 it=out flags.nzcv=WWXW base' ],
  ['sbc{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|0110|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['sbc%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0110|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=in flags.nzcv=UURU base' ],
  ['sbc{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|0110|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|0111|Rn:4|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXW base' ],
  ['sbcs.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|0111|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 it=out flags.nzcv=WWXW base' ],
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|0111|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXW base' ],
  ['sbc{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['sbc{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXW base' ],
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXW base' ],

  # => SBC, SBCS (register-shifted register)
  ['sbcs{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXW base' ],
  ['sbc{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => SBFX
  ['sbfx{%c}{%q}'            , 'Rd, Rn, #lsb, #width'                   , 'T32: 1111|0011|0100|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                          , 'group=71 base' ],
  ['sbfx{%c}{%q}'            , 'Rd, Rn, #lsb, #width'                   , 'A32: cond!=1111|0111|101|width:5|Rd:4|lsb:5|101|Rn:4'                           , 'group=41 base' ],

  # => SDIV
  ['sdiv{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|1001|Rn:4|1111|Rd:4|1111|Rm:4'                                   , 'group=96 base' ],
  ['sdiv{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0001|Rd:4|1111|Rm:4|0001|Rn:4'                             , 'group=37 base' ],

  # => SEL
  ['sel{%c}{%q}'             , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|1000|Rm:4'                                   , 'group=93 base' ],
  ['sel{%c}{%q}'             , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|1111|1011|Rm:4'                             , 'group=31 base' ],

  # => SETEND
  ['setend{%q}'              , 'endian'                                 , 'T16: 1011|0110|0101|endian:1|000'                                               , 'group=19 it=out base' ],
  ['setend{%q}'              , 'endian'                                 , 'A32: 1111|0001|0000|0001|0000|00|endian:1|0000|0000|0'                          , 'group=65 base' ],

  # => SEV
  ['sev{%c}{%q}'             , ''                                       , 'T16: 1011|1111|0100|0000'                                                       , 'group=21 base' ],
  ['sev{%c}.W'               , ''                                       , 'T32: 1111|0011|1010|1111|1000|0000|0000|0100'                                   , 'group=61 base' ],
  ['sev{%c}{%q}'             , ''                                       , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0100'                             , 'group=26 base' ],

  # => SEVL
  ['sevl{%c}{%q}'            , ''                                       , 'T16: 1011|1111|0101|0000'                                                       , 'group=21 base' ],
  ['sevl{%c}.W'              , ''                                       , 'T32: 1111|0011|1010|1111|1000|0000|0000|0101'                                   , 'group=61 base' ],
  ['sevl{%c}{%q}'            , ''                                       , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0101'                             , 'group=26 base' ],

  # => SHADD16
  ['shadd16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=92 base' ],
  ['shadd16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0001|Rm:4'                             , 'group=32 base' ],

  # => SHADD8
  ['shadd8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=92 base' ],
  ['shadd8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|1001|Rm:4'                             , 'group=32 base' ],

  # => SHASX
  ['shasx{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=92 base' ],
  ['shasx{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0011|Rm:4'                             , 'group=32 base' ],

  # => SHSAX
  ['shsax{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=92 base' ],
  ['shsax{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0101|Rm:4'                             , 'group=32 base' ],

  # => SHSUB16
  ['shsub16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=92 base' ],
  ['shsub16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0111|Rm:4'                             , 'group=32 base' ],

  # => SHSUB8
  ['shsub8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=92 base' ],
  ['shsub8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|1111|Rm:4'                             , 'group=32 base' ],

  # => SMC
  ['smc{%c}{%q}'             , '{#}imm'                                 , 'T32: 1111|0111|1111|imm:4|1000|0000|0000|0000'                                  , 'group=66 base' ],
  ['smc{%c}{%q}'             , '{#}imm'                                 , 'A32: cond!=1111|0001|0110|0000|0000|0000|0111|imm:4'                            , 'group=10 base' ],

  # => SMLABB, SMLABT, SMLATB, SMLATT
  ['smlabb{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 base' ],
  ['smlabt{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                               , 'group=95 base' ],
  ['smlatb{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0010|Rm:4'                               , 'group=95 base' ],
  ['smlatt{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0011|Rm:4'                               , 'group=95 base' ],
  ['smlabb{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1000|Rn:4'                             , 'group=14 base' ],
  ['smlabt{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1100|Rn:4'                             , 'group=14 base' ],
  ['smlatb{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1010|Rn:4'                             , 'group=14 base' ],
  ['smlatt{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1110|Rn:4'                             , 'group=14 base' ],

  # => SMLAD, SMLADX
  ['smlad{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0010|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 base' ],
  ['smladx{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0010|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                               , 'group=95 base' ],
  ['smlad{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                         , 'group=37 base' ],
  ['smladx{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0011|Rn:4'                         , 'group=37 base' ],

  # => SMLAL, SMLALS
  ['smlal{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , 'group=96 flags.nzcv=UUUU base' ],
  ['smlals{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1111|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=WWUU base' ],
  ['smlal{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1110|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=UUUU base' ],

  # => SMLALBB, SMLALBT, SMLALTB, SMLALTT
  ['smlalbb{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1000|Rm:4'                               , 'group=96 base' ],
  ['smlalbt{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1001|Rm:4'                               , 'group=96 base' ],
  ['smlaltb{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1010|Rm:4'                               , 'group=96 base' ],
  ['smlaltt{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1011|Rm:4'                               , 'group=96 base' ],
  ['smlalbb{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1000|Rn:4'                         , 'group=14 base' ],
  ['smlalbt{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1100|Rn:4'                         , 'group=14 base' ],
  ['smlaltb{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1010|Rn:4'                         , 'group=14 base' ],
  ['smlaltt{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1110|Rn:4'                         , 'group=14 base' ],

  # => SMLALD, SMLALDX
  ['smlald{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1100|Rm:4'                               , 'group=96 base' ],
  ['smlaldx{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1101|Rm:4'                               , 'group=96 base' ],
  ['smlald{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0001|Rn:4'                         , 'group=37 base' ],
  ['smlaldx{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0011|Rn:4'                         , 'group=37 base' ],

  # => SMLAWB, SMLAWT
  ['smlawb{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0011|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 base' ],
  ['smlawt{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0011|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                               , 'group=95 base' ],
  ['smlawb{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0001|0010|Rd:4|Ra:4|Rm:4|1000|Rn:4'                             , 'group=14 base' ],
  ['smlawt{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0001|0010|Rd:4|Ra:4|Rm:4|1100|Rn:4'                             , 'group=14 base' ],

  # => SMLSD, SMLSDX
  ['smlsd{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0100|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 base' ],
  ['smlsdx{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0100|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                               , 'group=95 base' ],
  ['smlsd{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0101|Rn:4'                         , 'group=37 base' ],
  ['smlsdx{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0111|Rn:4'                         , 'group=37 base' ],

  # => SMLSLD, SMLSLDX
  ['smlsld{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1101|Rn:4|RdLo:4|RdHi:4|1100|Rm:4'                               , 'group=96 base' ],
  ['smlsldx{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1101|Rn:4|RdLo:4|RdHi:4|1101|Rm:4'                               , 'group=96 base' ],
  ['smlsld{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0101|Rn:4'                         , 'group=37 base' ],
  ['smlsldx{%c}{%q}'         , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0111|Rn:4'                         , 'group=37 base' ],

  # => SMMLA, SMMLAR
  ['smmla{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0101|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 base' ],
  ['smmlar{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0101|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                               , 'group=95 base' ],
  ['smmla{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0101|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                         , 'group=37 base' ],
  ['smmlar{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0101|Rd:4|Ra!=1111|Rm:4|0011|Rn:4'                         , 'group=37 base' ],

  # => SMMLS, SMMLSR
  ['smmls{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0110|Rn:4|Ra:4|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['smmlsr{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0110|Rn:4|Ra:4|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['smmls{%c}{%q}'           , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0101|Rd:4|Ra:4|Rm:4|1101|Rn:4'                             , 'group=37 base' ],
  ['smmlsr{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|0101|Rd:4|Ra:4|Rm:4|1111|Rn:4'                             , 'group=37 base' ],

  # => SMMUL, SMMULR
  ['smmul{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0101|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['smmulr{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0101|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['smmul{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0101|Rd:4|1111|Rm:4|0001|Rn:4'                             , 'group=37 base' ],
  ['smmulr{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0101|Rd:4|1111|Rm:4|0011|Rn:4'                             , 'group=37 base' ],

  # => SMUAD, SMUADX
  ['smuad{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0010|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['smuadx{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0010|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['smuad{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0001|Rn:4'                             , 'group=37 base' ],
  ['smuadx{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0011|Rn:4'                             , 'group=37 base' ],

  # => SMULBB, SMULBT, SMULTB, SMULTT
  ['smulbb{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['smulbt{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['smultb{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0010|Rm:4'                                   , 'group=95 base' ],
  ['smultt{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0011|Rm:4'                                   , 'group=95 base' ],
  ['smulbb{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1000|Rn:4'                             , 'group=14 base' ],
  ['smulbt{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1100|Rn:4'                             , 'group=14 base' ],
  ['smultb{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1010|Rn:4'                             , 'group=14 base' ],
  ['smultt{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1110|Rn:4'                             , 'group=14 base' ],

  # => SMULL, SMULLS
  ['smull{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1000|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , 'group=96 flags.nzcv=UUUU base' ],
  ['smulls{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1101|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=WWUU base' ],
  ['smull{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1100|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=UUUU base' ],

  # => SMULWB, SMULWT
  ['smulwb{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0011|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['smulwt{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0011|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['smulwb{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0001|0010|Rd:4|0000|Rm:4|1010|Rn:4'                             , 'group=14 base' ],
  ['smulwt{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0001|0010|Rd:4|0000|Rm:4|1110|Rn:4'                             , 'group=14 base' ],

  # => SMUSD, SMUSDX
  ['smusd{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0100|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['smusdx{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0100|Rn:4|1111|Rd:4|0001|Rm:4'                                   , 'group=95 base' ],
  ['smusd{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0101|Rn:4'                             , 'group=37 base' ],
  ['smusdx{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0111|Rn:4'                             , 'group=37 base' ],

  # => SRS, SRSDA, SRSDB, SRSIA, SRSIB
  ['srsdb{%c}{%q}'           , 'SP{!}, #mode'                           , 'T32: 1110|1000|00|W|0110|1110|0000|0000|mode:5'                                 , 'group=51 base' ],
  ['srs{IA}{%c}{%q}'         , 'SP{!}, #mode'                           , 'T32: 1110|1001|10|W|0110|1110|0000|0000|mode:5'                                 , 'group=51 base' ],
  ['srsda{%c}{%q}'           , 'SP{!}, #mode'                           , 'A32: 1111|1000|01|W|0110|1000|0010|1000|mode:5'                                 , 'group=43 base' ],
  ['srsdb{%c}{%q}'           , 'SP{!}, #mode'                           , 'A32: 1111|1001|01|W|0110|1000|0010|1000|mode:5'                                 , 'group=43 base' ],
  ['srs{IA}{%c}{%q}'         , 'SP{!}, #mode'                           , 'A32: 1111|1000|11|W|0110|1000|0010|1000|mode:5'                                 , 'group=43 base' ],
  ['srsib{%c}{%q}'           , 'SP{!}, #mode'                           , 'A32: 1111|1001|11|W|0110|1000|0010|1000|mode:5'                                 , 'group=43 base' ],

  # => SSAT
  ['ssat{%c}{%q}'            , 'Rd, #sat, Rn, ASR #amount'              , 'T32: 1111|0011|0010|Rn:4|0|amount!=000|Rd:4|amount!=00|0|sat:5'                 , 'group=71 flags.nzcv=UURU base' ],
  ['ssat{%c}{%q}'            , 'Rd, #sat, Rn, {LSL #amount}'            , 'T32: 1111|0011|0000|Rn:4|0|amount:3|Rd:4|amount:2|0|sat:5'                      , 'group=71 flags.nzcv=UURU base' ],
  ['ssat{%c}{%q}'            , 'Rd, #sat, Rn, ASR #amount'              , 'A32: cond!=1111|0110|101|sat:5|Rd:4|amount:5|101|Rn:4'                          , 'group=35 flags.nzcv=UURU base' ],
  ['ssat{%c}{%q}'            , 'Rd, #sat, Rn, {LSL #amount}'            , 'A32: cond!=1111|0110|101|sat:5|Rd:4|amount:5|001|Rn:4'                          , 'group=35 flags.nzcv=UURU base' ],

  # => SSAT16
  ['ssat16{%c}{%q}'          , 'Rd, #sat, Rn'                           , 'T32: 1111|0011|0010|Rn:4|0000|Rd:4|0000|sat:4'                                  , 'group=71 base' ],
  ['ssat16{%c}{%q}'          , 'Rd, #sat, Rn'                           , 'A32: cond!=1111|0110|1010|sat:4|Rd:4|1111|0011|Rn:4'                            , 'group=33 base' ],

  # => SSAX
  ['ssax{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=92 base' ],
  ['ssax{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0101|Rm:4'                             , 'group=32 base' ],

  # => SSUB16
  ['ssub16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=92 base' ],
  ['ssub16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0111|Rm:4'                             , 'group=32 base' ],

  # => SSUB8
  ['ssub8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=92 base' ],
  ['ssub8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|1111|Rm:4'                             , 'group=32 base' ],

  # => STC
  ['stc{%c}{%q}'             , 'p14, c5, [Rn, {#{+/-}imm*4}]'           , 'T32: 1110|1101|U|000|Rn:4|0101|1110|imm:8'                                      , 'group=49 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn], #{+/-}imm*4'             , 'T32: 1110|1100|U|010|Rn:4|0101|1110|imm:8'                                      , 'group=49 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn, #{+/-}imm*4]!'            , 'T32: 1110|1101|U|010|Rn:4|0101|1110|imm:8'                                      , 'group=49 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn], option'                  , 'T32: 1110|1100|1000|Rn:4|0101|1110|option:8'                                    , 'group=49 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn, {#{+/-}imm*4}]'           , 'A32: cond!=1111|1101|U|000|Rn:4|0101|1110|imm:8'                                , 'group=61 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn], #{+/-}imm*4'             , 'A32: cond!=1111|1100|U|010|Rn:4|0101|1110|imm:8'                                , 'group=61 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn, #{+/-}imm*4]!'            , 'A32: cond!=1111|1101|U|010|Rn:4|0101|1110|imm:8'                                , 'group=61 base' ],
  ['stc{%c}{%q}'             , 'p14, c5, [Rn], option'                  , 'A32: cond!=1111|1100|1000|Rn:4|0101|1110|option:8'                              , 'group=61 base' ],

  # => STL
  ['stl{%c}{%q}'             , 'Rt, [Rn]'                               , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1010|1111'                                   , 'group=55 base' ],
  ['stl{%c}{%q}'             , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1000|Rn:4|1111|1100|1001|Rt:4'                             , 'group=8 base' ],

  # => STLB
  ['stlb{%c}{%q}'            , 'Rt, [Rn]'                               , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1000|1111'                                   , 'group=55 base' ],
  ['stlb{%c}{%q}'            , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1100|Rn:4|1111|1100|1001|Rt:4'                             , 'group=8 base' ],

  # => STLEX
  ['stlex{%c}{%q}'           , 'Rd, Rt, [Rn]'                           , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1110|Rd:4'                                   , 'group=55 base' ],
  ['stlex{%c}{%q}'           , 'Rd, Rt, [Rn]'                           , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|1110|1001|Rt:4'                             , 'group=8 base' ],

  # => STLEXB
  ['stlexb{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1100|Rd:4'                                   , 'group=55 base' ],
  ['stlexb{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|1110|1001|Rt:4'                             , 'group=8 base' ],

  # => STLEXD
  ['stlexd{%c}{%q}'          , 'Rd, Rt, Rt2, [Rn]'                      , 'T32: 1110|1000|1100|Rn:4|Rt:4|Rt2:4|1111|Rd:4'                                  , 'group=55 base' ],
  ['stlexd{%c}{%q}'          , 'Rd, Rt, Rt2, [Rn]'                      , 'A32: cond!=1111|0001|1010|Rn:4|Rd:4|1110|1001|Rt:4'                             , 'group=8 base' ],

  # => STLEXH
  ['stlexh{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1101|Rd:4'                                   , 'group=55 base' ],
  ['stlexh{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'A32: cond!=1111|0001|1110|Rn:4|Rd:4|1110|1001|Rt:4'                             , 'group=8 base' ],

  # => STLH
  ['stlh{%c}{%q}'            , 'Rt, [Rn]'                               , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1001|1111'                                   , 'group=55 base' ],
  ['stlh{%c}{%q}'            , 'Rt, [Rn]'                               , 'A32: cond!=1111|0001|1110|Rn:4|1111|1100|1001|Rt:4'                             , 'group=8 base' ],

  # => STM, STMIA, STMEA
  ['stm{IA}{%c}{%q}'         , 'Rn!, list'                              , 'T16: 1100|0|Rn:3|list:8'                                                        , 'group=23 form=preferred base' ],
  ['stmea{%c}{%q}'           , 'Rn!, list'                              , 'T16: 1100|0|Rn:3|list:8'                                                        , 'group=23 form=alternative base' ],
  ['stm{IA}{%c}.W'           , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|0|Rn:4|list=0|list:1|0|list:13'                             , 'group=51 form=preferred base' ],
  ['stmea{%c}.W'             , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|0|Rn:4|list=0|list:1|0|list:13'                             , 'group=51 form=alternative base' ],
  ['stm{IA}{%c}{%q}'         , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|0|Rn:4|list=0|list:1|0|list:13'                             , 'group=51 form=preferred base' ],
  ['stmea{%c}{%q}'           , 'Rn{!}, list'                            , 'T32: 1110|1000|10|W|0|Rn:4|list=0|list:1|0|list:13'                             , 'group=51 form=alternative base' ],
  ['stm{IA}{%c}{%q}'         , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|10|W|0|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['stmea{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|10|W|0|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => STM (User registers)
  ['stm{amode}{%c}{%q}'      , 'Rn, list'                               , 'A32: cond!=1111|100|P|U|100|Rn:4|list:16'                                       , 'group=44 base' ],

  # => STMDA, STMED
  ['stmda{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|00|W|0|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['stmed{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1000|00|W|0|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => STMDB, STMFD
  ['stmdb{%c}{%q}'           , 'Rn{!}, list'                            , 'T32: 1110|1001|00|W|0|Rn:4|list=0|list:1|0|list:13'                             , 'group=51 form=preferred base' ],
  ['stmfd{%c}{%q}'           , 'Rn{!}, list'                            , 'T32: 1110|1001|00|W|0|Rn:4|list=0|list:1|0|list:13'                             , 'group=51 form=alternative base' ],
  ['stmdb{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|00|W|0|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['stmfd{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|00|W|0|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => STMIB, STMFA
  ['stmib{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|10|W|0|Rn:4|list:16'                                       , 'group=44 form=preferred base' ],
  ['stmfa{%c}{%q}'           , 'Rn{!}, list'                            , 'A32: cond!=1111|1001|10|W|0|Rn:4|list:16'                                       , 'group=44 form=alternative base' ],

  # => STR (immediate)
  ['str{%c}{%q}'             , 'Rt, [Rn, {#{+}imm*4}]'                  , 'T16: 0110|0|imm:5|Rn:3|Rt:3'                                                    , 'group=12 base' ],
  ['str{%c}{%q}'             , 'Rt, [SP, {#{+}imm*4}]'                  , 'T16: 1001|0|Rt:3|imm:8'                                                         , 'group=14 base' ],
  ['str{%c}.W'               , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1100|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1100|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|1100|imm:8'                                   , 'group=87 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0101|U|000|Rn:4|Rt:4|imm:12'                                    , 'group=29 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0100|U|000|Rn:4|Rt:4|imm:12'                                    , 'group=29 base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0101|U|010|Rn:4|Rt:4|imm:12'                                    , 'group=29 base' ],

  # => STR (register)
  ['str{%c}{%q}'             , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|000|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['str{%c}.W'               , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                          , 'group=83 flags.nzcv=UURU base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                           , 'group=83 flags.nzcv=UURU base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, {+/-}Rm, {shift #amount}]'     , 'A32: cond!=1111|0111|U|000|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|000|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['str{%c}{%q}'             , 'Rt, [Rn, {+/-}Rm, {shift #amount}]!'    , 'A32: cond!=1111|0111|U|010|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => STRB (immediate)
  ['strb{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T16: 0111|0|imm:5|Rn:3|Rt:3'                                                    , 'group=12 base' ],
  ['strb{%c}.W'              , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1000|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1000|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|1100|imm:8'                                   , 'group=87 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0101|U|100|Rn:4|Rt:4|imm:12'                                    , 'group=29 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0100|U|100|Rn:4|Rt:4|imm:12'                                    , 'group=29 base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0101|U|110|Rn:4|Rt:4|imm:12'                                    , 'group=29 base' ],

  # => STRB (register)
  ['strb{%c}{%q}'            , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|010|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['strb{%c}.W'              , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                          , 'group=83 flags.nzcv=UURU base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                           , 'group=83 flags.nzcv=UURU base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm, {shift #amount}]'     , 'A32: cond!=1111|0111|U|100|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|100|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],
  ['strb{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm, {shift #amount}]!'    , 'A32: cond!=1111|0111|U|110|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => STRBT
  ['strbt{%c}{%q}'           , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 flags.nzcv=UURU base' ],
  ['strbt{%c}{%q}'           , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0100|U|110|Rn:4|Rt:4|imm:12'                                    , 'group=29 flags.nzcv=UURU base' ],
  ['strbt{%c}{%q}'           , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|110|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => STRD (immediate)
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn, {#{+/-}imm*4}]'           , 'T32: 1110|1001|U|100|Rn!=1111|Rt:4|Rt2:4|imm:8'                                 , 'group=58 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn], #{+/-}imm*4'             , 'T32: 1110|1000|U|110|Rn!=1111|Rt:4|Rt2:4|imm:8'                                 , 'group=58 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn, #{+/-}imm*4]!'            , 'T32: 1110|1001|U|110|Rn!=1111|Rt:4|Rt2:4|imm:8'                                 , 'group=58 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn, {#{+/-}imm}]'             , 'A32: cond!=1111|0001|U|100|Rn:4|Rt:4|imm:4|1111|imm:4'                          , 'group=5 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn], #{+/-}imm'               , 'A32: cond!=1111|0000|U|100|Rn:4|Rt:4|imm:4|1111|imm:4'                          , 'group=5 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn, #{+/-}imm]!'              , 'A32: cond!=1111|0001|U|110|Rn:4|Rt:4|imm:4|1111|imm:4'                          , 'group=5 base' ],

  # => STRD (register)
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn, {+/-}Rm]'                 , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn], {+/-}Rm'                 , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 base' ],
  ['strd{%c}{%q}'            , 'Rt, Rt2, [Rn, {+/-}Rm]!'                , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1111|Rm:4'                            , 'group=4 base' ],

  # => STREX
  ['strex{%c}{%q}'           , 'Rd, Rt, [Rn, {#imm*4}]'                 , 'T32: 1110|1000|0100|Rn:4|Rt:4|Rd:4|imm:8'                                       , 'group=53 base' ],
  ['strex{%c}{%q}'           , 'Rd, Rt, [Rn, {{#}imm}]'                 , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|1111|1001|Rt:4'                             , 'group=8 base' ],

  # => STREXB
  ['strexb{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|0100|Rd:4'                                   , 'group=54 base' ],
  ['strexb{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|1111|1001|Rt:4'                             , 'group=8 base' ],

  # => STREXD
  ['strexd{%c}{%q}'          , 'Rd, Rt, Rt2, [Rn]'                      , 'T32: 1110|1000|1100|Rn:4|Rt:4|Rt2:4|0111|Rd:4'                                  , 'group=54 base' ],
  ['strexd{%c}{%q}'          , 'Rd, Rt, Rt2, [Rn]'                      , 'A32: cond!=1111|0001|1010|Rn:4|Rd:4|1111|1001|Rt:4'                             , 'group=8 base' ],

  # => STREXH
  ['strexh{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|0101|Rd:4'                                   , 'group=54 base' ],
  ['strexh{%c}{%q}'          , 'Rd, Rt, [Rn]'                           , 'A32: cond!=1111|0001|1110|Rn:4|Rd:4|1111|1001|Rt:4'                             , 'group=8 base' ],

  # => STRH (immediate)
  ['strh{%c}{%q}'            , 'Rt, [Rn, {#{+}imm*2}]'                  , 'T16: 1000|0|imm:5|Rn:3|Rt:3'                                                    , 'group=13 base' ],
  ['strh{%c}.W'              , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1010|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|1010|Rn!=1111|Rt:4|imm:12'                                       , 'group=88 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, {#-imm}]'                      , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|1100|imm:8'                                   , 'group=87 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|10|U|1|imm:8'                                 , 'group=87 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|11|U|1|imm:8'                                 , 'group=87 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, {#{+/-}imm}]'                  , 'A32: cond!=1111|0001|U|100|Rn:4|Rt:4|imm:4|1011|imm:4'                          , 'group=5 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn], #{+/-}imm'                    , 'A32: cond!=1111|0000|U|100|Rn:4|Rt:4|imm:4|1011|imm:4'                          , 'group=5 base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, #{+/-}imm]!'                   , 'A32: cond!=1111|0001|U|110|Rn:4|Rt:4|imm:4|1011|imm:4'                          , 'group=5 base' ],

  # => STRH (register)
  ['strh{%c}{%q}'            , 'Rt, [Rn, {+}Rm]'                        , 'T16: 0101|001|Rm:3|Rn:3|Rt:3'                                                   , 'group=11 flags.nzcv=UURU base' ],
  ['strh{%c}.W'              , 'Rt, [Rn, {+}Rm]'                        , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                          , 'group=83 flags.nzcv=UURU base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, {+}Rm, {LSL #imm}]'            , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                           , 'group=83 flags.nzcv=UURU base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm]'                      , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],
  ['strh{%c}{%q}'            , 'Rt, [Rn, {+/-}Rm]!'                     , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 flags.nzcv=UURU base' ],

  # => STRHT
  ['strht{%c}{%q}'           , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 base' ],
  ['strht{%c}{%q}'           , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0000|U|110|Rn:4|Rt:4|imm:4|1011|imm:4'                          , 'group=5 base' ],
  ['strht{%c}{%q}'           , 'Rt, [Rn], {+/-}Rm'                      , 'A32: cond!=1111|0000|U|010|Rn:4|Rt:4|0000|1011|Rm:4'                            , 'group=4 base' ],

  # => STRT
  ['strt{%c}{%q}'            , 'Rt, [Rn, {#{+}imm}]'                    , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|1110|imm:8'                                   , 'group=86 flags.nzcv=UURU base' ],
  ['strt{%c}{%q}'            , 'Rt, [Rn], {#{+/-}imm}'                  , 'A32: cond!=1111|0100|U|010|Rn:4|Rt:4|imm:12'                                    , 'group=29 flags.nzcv=UURU base' ],
  ['strt{%c}{%q}'            , 'Rt, [Rn], {+/-}Rm, {shift #amount}'     , 'A32: cond!=1111|0110|U|010|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                   , 'group=30 flags.nzcv=UURU base' ],

  # => SUB (immediate, from PC)
  ['sub{%c}{%q}'             , 'Rd, PC, #imm'                           , 'T32: 1111|0|imm:1|1010|1011|110|imm:3|Rd:4|imm:8'                               , 'group=69 aliasOf=adr preferredIf=imm.A:imm.B:imm.C==0 base' ],
  ['sub{%c}{%q}'             , 'Rd, PC, #cnst'                          , 'A32: cond!=1111|0010|0100|1111|Rd:4|cnst:12'                                    , 'group=24 aliasOf=adr preferredIf=cnst==0 base' ],

  # => SUB, SUBS (immediate)
  ['sub%c{%q}'               , 'Rd, Rn, #imm'                           , 'T16: 0001|111|imm:3|Rn:3|Rd:3'                                                  , 'group=5 it=in flags.nzcv=WWWW base' ],
  ['subs{%q}'                , 'Rd, Rn, #imm'                           , 'T16: 0001|111|imm:3|Rn:3|Rd:3'                                                  , 'group=5 it=out flags.nzcv=WWWW base' ],
  ['sub%c{%q}'               , 'Rdn, #imm'                              , 'T16: 0011|1|Rdn:3|imm:8'                                                        , 'group=6 it=in flags.nzcv=WWWW base' ],
  ['sub%c{%q}'               , '{Rdn}, Rdn, #imm'                       , 'T16: 0011|1|Rdn:3|imm:8'                                                        , 'group=6 it=in flags.nzcv=WWWW base' ],
  ['subs{%q}'                , 'Rdn, #imm'                              , 'T16: 0011|1|Rdn:3|imm:8'                                                        , 'group=6 it=out flags.nzcv=WWWW base' ],
  ['subs{%q}'                , '{Rdn}, Rdn, #imm'                       , 'T16: 0011|1|Rdn:3|imm:8'                                                        , 'group=6 it=out flags.nzcv=WWWW base' ],
  ['sub%c.W'                 , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0110|10|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 it=in flags.nzcv=UUUU base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0110|10|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                       , 'group=67 flags.nzcv=UUUU base' ],
  ['subs.W'                  , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0110|11|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                   , 'group=67 it=out flags.nzcv=WWWW base' ],
  ['subs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'T32: 1111|0|cnst:1|0110|11|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                   , 'group=67 flags.nzcv=WWWW base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, #imm'                         , 'T32: 1111|0|imm:1|1010|10|Rn!=11x1|0|imm:3|Rd:4|imm:8'                          , 'group=69 flags.nzcv=UUUU base' ],
  ['subw{%c}{%q}'            , '{Rd}, Rn, #imm'                         , 'T32: 1111|0|imm:1|1010|10|Rn!=11x1|0|imm:3|Rd:4|imm:8'                          , 'group=69 flags.nzcv=UUUU base' ],
  ['subs{%c}{%q}'            , 'PC, LR, #imm'                           , 'T32: 1111|0011|1101|1110|1000|1111|imm!=00000000'                               , 'group=64 flags.nzcv=WWWW base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0100|Rn!=11x1|Rd:4|cnst:12'                                , 'group=24 flags.nzcv=UUUU base' ],
  ['subs{%c}{%q}'            , '{Rd}, Rn, #cnst'                        , 'A32: cond!=1111|0010|0101|Rn!=1101|Rd:4|cnst:12'                                , 'group=24 flags.nzcv=WWWW base' ],

  # => SUB, SUBS (register)
  ['sub%c{%q}'               , 'Rd, Rn, Rm'                             , 'T16: 0001|101|Rm:3|Rn:3|Rd:3'                                                   , 'group=4 it=in flags.nzcv=WWXW base' ],
  ['subs{%q}'                , '{Rd}, Rn, Rm'                           , 'T16: 0001|101|Rm:3|Rn:3|Rd:3'                                                   , 'group=4 it=out flags.nzcv=WWXW base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|1010|Rn!=1101|0000|Rd:4|0011|Rm:4'                               , 'group=59 flags.nzcv=UURU base' ],
  ['sub%c.W'                 , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|1010|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'           , 'group=59 it=in flags.nzcv=UURU base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|1010|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=UURU base' ],
  ['subs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'T32: 1110|1011|1011|Rn!=1101|0000|Rd!=1111|0011|Rm:4'                           , 'group=59 flags.nzcv=WWXW base' ],
  ['subs.W'                  , '{Rd}, Rn, Rm'                           , 'T32: 1110|1011|1011|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'       , 'group=59 it=out flags.nzcv=WWXW base' ],
  ['subs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'T32: 1110|1011|1011|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'  , 'group=59 flags.nzcv=WWXW base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0100|Rn!=1101|Rd:4|0000|0110|Rm:4'                         , 'group=16 flags.nzcv=UURU base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0100|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'         , 'group=16 flags.nzcv=UURU base' ],
  ['subs{%c}{%q}'            , '{Rd}, Rn, Rm, RRX'                      , 'A32: cond!=1111|0000|0101|Rn!=1101|Rd:4|0000|0110|Rm:4'                         , 'group=16 flags.nzcv=WWXW base' ],
  ['subs{%c}{%q}'            , '{Rd}, Rn, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0101|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'         , 'group=16 flags.nzcv=WWXW base' ],

  # => SUB, SUBS (register-shifted register)
  ['subs{%c}{%q}'            , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=WWXW base' ],
  ['sub{%c}{%q}'             , '{Rd}, Rn, Rm, type Rs'                  , 'A32: cond!=1111|0000|0100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                       , 'group=20 flags.nzcv=UURU base' ],

  # => SUB, SUBS (SP minus immediate)
  ['sub{%c}{%q}'             , '{SP}, SP, #imm*4'                       , 'T16: 1011|0000|1|imm:7'                                                         , 'group=17 flags.nzcv=UUUU base' ],
  ['sub{%c}.W'               , '{Rd}, SP, #cnst'                        , 'T32: 1111|0|cnst:1|0110|1011|010|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=UUUU base' ],
  ['sub{%c}{%q}'             , '{Rd}, SP, #cnst'                        , 'T32: 1111|0|cnst:1|0110|1011|010|cnst:3|Rd:4|cnst:8'                            , 'group=67 flags.nzcv=UUUU base' ],
  ['subs{%c}{%q}'            , '{Rd}, SP, #cnst'                        , 'T32: 1111|0|cnst:1|0110|1111|010|cnst:3|Rd!=1111|cnst:8'                        , 'group=67 flags.nzcv=WWWW base' ],
  ['sub{%c}{%q}'             , '{Rd}, SP, #imm'                         , 'T32: 1111|0|imm:1|1010|1011|010|imm:3|Rd:4|imm:8'                               , 'group=69 flags.nzcv=UUUU base' ],
  ['subw{%c}{%q}'            , '{Rd}, SP, #imm'                         , 'T32: 1111|0|imm:1|1010|1011|010|imm:3|Rd:4|imm:8'                               , 'group=69 flags.nzcv=UUUU base' ],
  ['sub{%c}{%q}'             , '{Rd}, SP, #cnst'                        , 'A32: cond!=1111|0010|0100|1101|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=UUUU base' ],
  ['subs{%c}{%q}'            , '{Rd}, SP, #cnst'                        , 'A32: cond!=1111|0010|0101|1101|Rd:4|cnst:12'                                    , 'group=24 flags.nzcv=WWWW base' ],

  # => SUB, SUBS (SP minus register)
  ['sub{%c}{%q}'             , '{Rd}, SP, Rm, RRX'                      , 'T32: 1110|1011|1010|1101|0000|Rd:4|0011|Rm:4'                                   , 'group=59 flags.nzcv=UURU base' ],
  ['sub{%c}.W'               , '{Rd}, SP, Rm'                           , 'T32: 1110|1011|1010|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'               , 'group=59 flags.nzcv=UURU base' ],
  ['sub{%c}{%q}'             , '{Rd}, SP, Rm, {shift #amount}'          , 'T32: 1110|1011|1010|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=UURU base' ],
  ['subs{%c}{%q}'            , '{Rd}, SP, Rm, RRX'                      , 'T32: 1110|1011|1011|1101|0000|Rd!=1111|0011|Rm:4'                               , 'group=59 flags.nzcv=WWXW base' ],
  ['subs{%c}{%q}'            , '{Rd}, SP, Rm, {shift #amount}'          , 'T32: 1110|1011|1011|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'      , 'group=59 flags.nzcv=WWXW base' ],
  ['sub{%c}{%q}'             , '{Rd}, SP, Rm, RRX'                      , 'A32: cond!=1111|0000|0100|1101|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=UURU base' ],
  ['sub{%c}{%q}'             , '{Rd}, SP, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0100|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=UURU base' ],
  ['subs{%c}{%q}'            , '{Rd}, SP, Rm, RRX'                      , 'A32: cond!=1111|0000|0101|1101|Rd:4|0000|0110|Rm:4'                             , 'group=16 flags.nzcv=WWXW base' ],
  ['subs{%c}{%q}'            , '{Rd}, SP, Rm, {shift #amount}'          , 'A32: cond!=1111|0000|0101|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'             , 'group=16 flags.nzcv=WWXW base' ],

  # => SVC
  ['svc{%c}{%q}'             , '{#}imm'                                 , 'T16: 1101|1111|imm:8'                                                           , 'group=25 base' ],
  ['svc{%c}{%q}'             , '{#}imm'                                 , 'A32: cond!=1111|1111|imm:24'                                                    , 'group=58 base' ],

  # => SXTAB
  ['sxtab{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'T32: 1111|1010|0100|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                        , 'group=91 base' ],
  ['sxtab{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'A32: cond!=1111|0110|1010|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                  , 'group=36 base' ],

  # => SXTAB16
  ['sxtab16{%c}{%q}'         , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'T32: 1111|1010|0010|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                        , 'group=91 base' ],
  ['sxtab16{%c}{%q}'         , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'A32: cond!=1111|0110|1000|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                  , 'group=36 base' ],

  # => SXTAH
  ['sxtah{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'T32: 1111|1010|0000|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                        , 'group=91 base' ],
  ['sxtah{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'A32: cond!=1111|0110|1011|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                  , 'group=36 base' ],

  # => SXTB
  ['sxtb{%c}{%q}'            , '{Rd}, Rm'                               , 'T16: 1011|0010|01|Rm:3|Rd:3'                                                    , 'group=18 base' ],
  ['sxtb{%c}.W'              , '{Rd}, Rm'                               , 'T32: 1111|1010|0100|1111|1111|Rd:4|10|rotate:2|Rm:4'                            , 'group=91 base' ],
  ['sxtb{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'T32: 1111|1010|0100|1111|1111|Rd:4|10|amount:2|Rm:4'                            , 'group=91 base' ],
  ['sxtb{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'A32: cond!=1111|0110|1010|1111|Rd:4|amount:2|0001|11|Rm:4'                      , 'group=36 base' ],

  # => SXTB16
  ['sxtb16{%c}{%q}'          , '{Rd}, Rm, {ROR #amount*8}'              , 'T32: 1111|1010|0010|1111|1111|Rd:4|10|amount:2|Rm:4'                            , 'group=91 base' ],
  ['sxtb16{%c}{%q}'          , '{Rd}, Rm, {ROR #amount*8}'              , 'A32: cond!=1111|0110|1000|1111|Rd:4|amount:2|0001|11|Rm:4'                      , 'group=36 base' ],

  # => SXTH
  ['sxth{%c}{%q}'            , '{Rd}, Rm'                               , 'T16: 1011|0010|00|Rm:3|Rd:3'                                                    , 'group=18 base' ],
  ['sxth{%c}.W'              , '{Rd}, Rm'                               , 'T32: 1111|1010|0000|1111|1111|Rd:4|10|rotate:2|Rm:4'                            , 'group=91 base' ],
  ['sxth{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'T32: 1111|1010|0000|1111|1111|Rd:4|10|amount:2|Rm:4'                            , 'group=91 base' ],
  ['sxth{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'A32: cond!=1111|0110|1011|1111|Rd:4|amount:2|0001|11|Rm:4'                      , 'group=36 base' ],

  # => TBB, TBH
  ['tbb{%c}{%q}'             , '[Rn, Rm]'                               , 'T32: 1110|1000|1101|Rn:4|1111|0000|0000|Rm:4'                                   , 'group=52 it=in|last|out base' ],
  ['tbh{%c}{%q}'             , '[Rn, Rm, LSL #1]'                       , 'T32: 1110|1000|1101|Rn:4|1111|0000|0001|Rm:4'                                   , 'group=52 it=in|last|out base' ],

  # => TEQ (immediate)
  ['teq{%c}{%q}'             , 'Rn, #cnst'                              , 'T32: 1111|0|cnst:1|0010|01|Rn:4|0|cnst:3|1111|cnst:8'                           , 'group=67 flags.nzcv=WWWU base' ],
  ['teq{%c}{%q}'             , 'Rn, #cnst'                              , 'A32: cond!=1111|0011|0011|Rn:4|0000|cnst:12'                                    , 'group=27 flags.nzcv=WWWU base' ],

  # => TEQ (register)
  ['teq{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'T32: 1110|1010|1001|Rn:4|0000|1111|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXU base' ],
  ['teq{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'T32: 1110|1010|1001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXU base' ],
  ['teq{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'A32: cond!=1111|0001|0011|Rn:4|0000|0000|0110|Rm:4'                             , 'group=17 flags.nzcv=WWXU base' ],
  ['teq{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|0011|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'             , 'group=17 flags.nzcv=WWXU base' ],

  # => TEQ (register-shifted register)
  ['teq{%c}{%q}'             , 'Rn, Rm, type Rs'                        , 'A32: cond!=1111|0001|0011|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                       , 'group=21 flags.nzcv=WWXU base' ],

  # => TST (immediate)
  ['tst{%c}{%q}'             , 'Rn, #cnst'                              , 'T32: 1111|0|cnst:1|0000|01|Rn:4|0|cnst:3|1111|cnst:8'                           , 'group=67 flags.nzcv=WWWU base' ],
  ['tst{%c}{%q}'             , 'Rn, #cnst'                              , 'A32: cond!=1111|0011|0001|Rn:4|0000|cnst:12'                                    , 'group=27 flags.nzcv=WWWU base' ],

  # => TST (register)
  ['tst{%c}{%q}'             , 'Rn, Rm'                                 , 'T16: 0100|0010|00|Rm:3|Rn:3'                                                    , 'group=7 flags.nzcv=WWXU base' ],
  ['tst{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'T32: 1110|1010|0001|Rn:4|0000|1111|0011|Rm:4'                                   , 'group=59 flags.nzcv=WWXU base' ],
  ['tst{%c}.W'               , 'Rn, Rm'                                 , 'T32: 1110|1010|0001|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'               , 'group=59 flags.nzcv=WWXU base' ],
  ['tst{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'T32: 1110|1010|0001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'          , 'group=59 flags.nzcv=WWXU base' ],
  ['tst{%c}{%q}'             , 'Rn, Rm, RRX'                            , 'A32: cond!=1111|0001|0001|Rn:4|0000|0000|0110|Rm:4'                             , 'group=17 flags.nzcv=WWXU base' ],
  ['tst{%c}{%q}'             , 'Rn, Rm, {shift #amount}'                , 'A32: cond!=1111|0001|0001|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'             , 'group=17 flags.nzcv=WWXU base' ],

  # => TST (register-shifted register)
  ['tst{%c}{%q}'             , 'Rn, Rm, type Rs'                        , 'A32: cond!=1111|0001|0001|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                       , 'group=21 flags.nzcv=WWXU base' ],

  # => UADD16
  ['uadd16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0100|Rm:4'                                   , 'group=92 base' ],
  ['uadd16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0001|Rm:4'                             , 'group=32 base' ],

  # => UADD8
  ['uadd8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0100|Rm:4'                                   , 'group=92 base' ],
  ['uadd8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|1001|Rm:4'                             , 'group=32 base' ],

  # => UASX
  ['uasx{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0100|Rm:4'                                   , 'group=92 base' ],
  ['uasx{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0011|Rm:4'                             , 'group=32 base' ],

  # => UBFX
  ['ubfx{%c}{%q}'            , 'Rd, Rn, #lsb, #width'                   , 'T32: 1111|0011|1100|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                          , 'group=71 base' ],
  ['ubfx{%c}{%q}'            , 'Rd, Rn, #lsb, #width'                   , 'A32: cond!=1111|0111|111|width:5|Rd:4|lsb:5|101|Rn:4'                           , 'group=41 base' ],

  # => UDF
  ['udf{%c}{%q}'             , '{#}imm'                                 , 'T16: 1101|1110|imm:8'                                                           , 'group=25 base' ],
  ['udf{%c}.W'               , '{#}imm'                                 , 'T32: 1111|0111|1111|imm:4|1010|imm:12'                                          , 'group=66 base' ],
  ['udf{%c}{%q}'             , '{#}imm'                                 , 'T32: 1111|0111|1111|imm:4|1010|imm:12'                                          , 'group=66 base' ],
  ['udf{%c}{%q}'             , '{#}imm'                                 , 'A32: 1110|0111|1111|imm:12|1111|imm:4'                                          , 'group=40 base' ],

  # => UDIV
  ['udiv{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|1011|Rn:4|1111|Rd:4|1111|Rm:4'                                   , 'group=96 base' ],
  ['udiv{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|0011|Rd:4|1111|Rm:4|0001|Rn:4'                             , 'group=37 base' ],

  # => UHADD16
  ['uhadd16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0110|Rm:4'                                   , 'group=92 base' ],
  ['uhadd16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0001|Rm:4'                             , 'group=32 base' ],

  # => UHADD8
  ['uhadd8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0110|Rm:4'                                   , 'group=92 base' ],
  ['uhadd8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|1001|Rm:4'                             , 'group=32 base' ],

  # => UHASX
  ['uhasx{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0110|Rm:4'                                   , 'group=92 base' ],
  ['uhasx{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0011|Rm:4'                             , 'group=32 base' ],

  # => UHSAX
  ['uhsax{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0110|Rm:4'                                   , 'group=92 base' ],
  ['uhsax{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0101|Rm:4'                             , 'group=32 base' ],

  # => UHSUB16
  ['uhsub16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0110|Rm:4'                                   , 'group=92 base' ],
  ['uhsub16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0111|Rm:4'                             , 'group=32 base' ],

  # => UHSUB8
  ['uhsub8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0110|Rm:4'                                   , 'group=92 base' ],
  ['uhsub8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|1111|Rm:4'                             , 'group=32 base' ],

  # => UMAAL
  ['umaal{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1110|Rn:4|RdLo:4|RdHi:4|0110|Rm:4'                               , 'group=96 base' ],
  ['umaal{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|0100|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 base' ],

  # => UMLAL, UMLALS
  ['umlal{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1110|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , 'group=96 flags.nzcv=UUUU base' ],
  ['umlals{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1011|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=WWUU base' ],
  ['umlal{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1010|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=UUUU base' ],

  # => UMULL, UMULLS
  ['umull{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'T32: 1111|1011|1010|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , 'group=96 flags.nzcv=UUUU base' ],
  ['umulls{%c}{%q}'          , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1001|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=WWUU base' ],
  ['umull{%c}{%q}'           , 'RdLo, RdHi, Rn, Rm'                     , 'A32: cond!=1111|0000|1000|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                         , 'group=6 flags.nzcv=UUUU base' ],

  # => UQADD16
  ['uqadd16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0101|Rm:4'                                   , 'group=92 base' ],
  ['uqadd16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0001|Rm:4'                             , 'group=32 base' ],

  # => UQADD8
  ['uqadd8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0101|Rm:4'                                   , 'group=92 base' ],
  ['uqadd8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|1001|Rm:4'                             , 'group=32 base' ],

  # => UQASX
  ['uqasx{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0101|Rm:4'                                   , 'group=92 base' ],
  ['uqasx{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0011|Rm:4'                             , 'group=32 base' ],

  # => UQSAX
  ['uqsax{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0101|Rm:4'                                   , 'group=92 base' ],
  ['uqsax{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0101|Rm:4'                             , 'group=32 base' ],

  # => UQSUB16
  ['uqsub16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0101|Rm:4'                                   , 'group=92 base' ],
  ['uqsub16{%c}{%q}'         , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0111|Rm:4'                             , 'group=32 base' ],

  # => UQSUB8
  ['uqsub8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0101|Rm:4'                                   , 'group=92 base' ],
  ['uqsub8{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|1111|Rm:4'                             , 'group=32 base' ],

  # => USAD8
  ['usad8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1011|0111|Rn:4|1111|Rd:4|0000|Rm:4'                                   , 'group=95 base' ],
  ['usad8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0111|1000|Rd:4|1111|Rm:4|0001|Rn:4'                             , 'group=38 base' ],

  # => USADA8
  ['usada8{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'T32: 1111|1011|0111|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                               , 'group=95 base' ],
  ['usada8{%c}{%q}'          , 'Rd, Rn, Rm, Ra'                         , 'A32: cond!=1111|0111|1000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                         , 'group=38 base' ],

  # => USAT
  ['usat{%c}{%q}'            , 'Rd, #sat, Rn, ASR #amount'              , 'T32: 1111|0011|1010|Rn:4|0|amount!=000|Rd:4|amount!=00|0|sat:5'                 , 'group=71 flags.nzcv=UURU base' ],
  ['usat{%c}{%q}'            , 'Rd, #sat, Rn, {LSL #amount}'            , 'T32: 1111|0011|1000|Rn:4|0|amount:3|Rd:4|amount:2|0|sat:5'                      , 'group=71 flags.nzcv=UURU base' ],
  ['usat{%c}{%q}'            , 'Rd, #sat, Rn, ASR #amount'              , 'A32: cond!=1111|0110|111|sat:5|Rd:4|amount:5|101|Rn:4'                          , 'group=35 flags.nzcv=UURU base' ],
  ['usat{%c}{%q}'            , 'Rd, #sat, Rn, {LSL #amount}'            , 'A32: cond!=1111|0110|111|sat:5|Rd:4|amount:5|001|Rn:4'                          , 'group=35 flags.nzcv=UURU base' ],

  # => USAT16
  ['usat16{%c}{%q}'          , 'Rd, #sat, Rn'                           , 'T32: 1111|0011|1010|Rn:4|0000|Rd:4|0000|sat:4'                                  , 'group=71 base' ],
  ['usat16{%c}{%q}'          , 'Rd, #sat, Rn'                           , 'A32: cond!=1111|0110|1110|sat:4|Rd:4|1111|0011|Rn:4'                            , 'group=33 base' ],

  # => USAX
  ['usax{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0100|Rm:4'                                   , 'group=92 base' ],
  ['usax{%c}{%q}'            , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0101|Rm:4'                             , 'group=32 base' ],

  # => USUB16
  ['usub16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0100|Rm:4'                                   , 'group=92 base' ],
  ['usub16{%c}{%q}'          , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0111|Rm:4'                             , 'group=32 base' ],

  # => USUB8
  ['usub8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0100|Rm:4'                                   , 'group=92 base' ],
  ['usub8{%c}{%q}'           , '{Rd}, Rn, Rm'                           , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|1111|Rm:4'                             , 'group=32 base' ],

  # => UXTAB
  ['uxtab{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'T32: 1111|1010|0101|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                        , 'group=91 base' ],
  ['uxtab{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'A32: cond!=1111|0110|1110|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                  , 'group=36 base' ],

  # => UXTAB16
  ['uxtab16{%c}{%q}'         , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'T32: 1111|1010|0011|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                        , 'group=91 base' ],
  ['uxtab16{%c}{%q}'         , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'A32: cond!=1111|0110|1100|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                  , 'group=36 base' ],

  # => UXTAH
  ['uxtah{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'T32: 1111|1010|0001|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                        , 'group=91 base' ],
  ['uxtah{%c}{%q}'           , '{Rd}, Rn, Rm, {ROR #amount*8}'          , 'A32: cond!=1111|0110|1111|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                  , 'group=36 base' ],

  # => UXTB
  ['uxtb{%c}{%q}'            , '{Rd}, Rm'                               , 'T16: 1011|0010|11|Rm:3|Rd:3'                                                    , 'group=18 base' ],
  ['uxtb{%c}.W'              , '{Rd}, Rm'                               , 'T32: 1111|1010|0101|1111|1111|Rd:4|10|rotate:2|Rm:4'                            , 'group=91 base' ],
  ['uxtb{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'T32: 1111|1010|0101|1111|1111|Rd:4|10|amount:2|Rm:4'                            , 'group=91 base' ],
  ['uxtb{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'A32: cond!=1111|0110|1110|1111|Rd:4|amount:2|0001|11|Rm:4'                      , 'group=36 base' ],

  # => UXTB16
  ['uxtb16{%c}{%q}'          , '{Rd}, Rm, {ROR #amount*8}'              , 'T32: 1111|1010|0011|1111|1111|Rd:4|10|amount:2|Rm:4'                            , 'group=91 base' ],
  ['uxtb16{%c}{%q}'          , '{Rd}, Rm, {ROR #amount*8}'              , 'A32: cond!=1111|0110|1100|1111|Rd:4|amount:2|0001|11|Rm:4'                      , 'group=36 base' ],

  # => UXTH
  ['uxth{%c}{%q}'            , '{Rd}, Rm'                               , 'T16: 1011|0010|10|Rm:3|Rd:3'                                                    , 'group=18 base' ],
  ['uxth{%c}.W'              , '{Rd}, Rm'                               , 'T32: 1111|1010|0001|1111|1111|Rd:4|10|rotate:2|Rm:4'                            , 'group=91 base' ],
  ['uxth{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'T32: 1111|1010|0001|1111|1111|Rd:4|10|amount:2|Rm:4'                            , 'group=91 base' ],
  ['uxth{%c}{%q}'            , '{Rd}, Rm, {ROR #amount*8}'              , 'A32: cond!=1111|0110|1111|1111|Rd:4|amount:2|0001|11|Rm:4'                      , 'group=36 base' ],

  # => WFE
  ['wfe{%c}{%q}'             , ''                                       , 'T16: 1011|1111|0010|0000'                                                       , 'group=21 base' ],
  ['wfe{%c}.W'               , ''                                       , 'T32: 1111|0011|1010|1111|1000|0000|0000|0010'                                   , 'group=61 base' ],
  ['wfe{%c}{%q}'             , ''                                       , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0010'                             , 'group=26 base' ],

  # => WFI
  ['wfi{%c}{%q}'             , ''                                       , 'T16: 1011|1111|0011|0000'                                                       , 'group=21 base' ],
  ['wfi{%c}.W'               , ''                                       , 'T32: 1111|0011|1010|1111|1000|0000|0000|0011'                                   , 'group=61 base' ],
  ['wfi{%c}{%q}'             , ''                                       , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0011'                             , 'group=26 base' ],

  # => YIELD
  ['yield{%c}{%q}'           , ''                                       , 'T16: 1011|1111|0001|0000'                                                       , 'group=21 base' ],
  ['yield{%c}.W'             , ''                                       , 'T32: 1111|0011|1010|1111|1000|0000|0000|0001'                                   , 'group=61 base' ],
  ['yield{%c}{%q}'           , ''                                       , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0001'                             , 'group=26 base' ],



  # ===>                                 AArch64.Base                                 <===

  # => ADC
  ['adc'                     , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                      , 'group=37 flags.nzcv=UURU base' ],
  ['adc'                     , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                      , 'group=37 flags.nzcv=UURU base' ],

  # => ADCS
  ['adcs'                    , 'Wd, Wn, Wm'                             , 'A64: 0011|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                      , 'group=37 flags.nzcv=WWXW base' ],
  ['adcs'                    , 'Xd, Xn, Xm'                             , 'A64: 1011|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                      , 'group=37 flags.nzcv=WWXW base' ],

  # => ADD (extended register)
  ['add'                     , '$Wd, $Wn, Wm, {extend {#amount}}'       , 'A64: 0000|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                            , 'group=35 base' ],
  ['add'                     , '$Xd, $Xn, R.m, {extend {#amount}}'      , 'A64: 1000|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                           , 'group=35 base' ],

  # => ADD (immediate)
  ['add'                     , '$Wd, $Wn, #imm, {LSL #amount*12}'       , 'A64: 0001|0001|amount:2|imm:12|Wn:5|Wd:5'                                       , 'group=3 base' ],
  ['add'                     , '$Xd, $Xn, #imm, {LSL #amount*12}'       , 'A64: 1001|0001|amount:2|imm:12|Xn:5|Xd:5'                                       , 'group=3 base' ],

  # => ADD (shifted register)
  ['add'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0000|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=36 base' ],
  ['add'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1000|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=36 base' ],

  # => ADDS (extended register)
  ['adds'                    , 'Wd, $Wn, Wm, {extend {#amount}}'        , 'A64: 0010|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                            , 'group=35 flags.nzcv=WWWW base' ],
  ['adds'                    , 'Xd, $Xn, R.m, {extend {#amount}}'       , 'A64: 1010|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                           , 'group=35 flags.nzcv=WWWW base' ],

  # => ADDS (immediate)
  ['adds'                    , 'Wd, $Wn, #imm, {LSL #amount*12}'        , 'A64: 0011|0001|amount:2|imm:12|Wn:5|Wd:5'                                       , 'group=3 flags.nzcv=WWWW base' ],
  ['adds'                    , 'Xd, $Xn, #imm, {LSL #amount*12}'        , 'A64: 1011|0001|amount:2|imm:12|Xn:5|Xd:5'                                       , 'group=3 flags.nzcv=WWWW base' ],

  # => ADDS (shifted register)
  ['adds'                    , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0010|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=36 flags.nzcv=WWWW base' ],
  ['adds'                    , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1010|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=36 flags.nzcv=WWWW base' ],

  # => ADR
  ['adr'                     , 'Xd, rel'                                , 'A64: 0|rel.B:2|1000|0|rel.A:19|Xd:5'                                            , 'group=8 base' ],

  # => ADRP
  ['adrp'                    , 'Xd, rel*4096'                           , 'A64: 1|rel.B:2|1000|0|rel.A:19|Xd:5'                                            , 'group=8 base' ],

  # => AND (immediate)
  ['and'                     , '$Wd, Wn, #bimm'                         , 'A64: 0001|0010|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=6 base' ],
  ['and'                     , '$Xd, Xn, #bimm'                         , 'A64: 1001|0010|0|N|immr:6|imms:6|Xn:5|Xd:5'                                     , 'group=6 base' ],

  # => AND (shifted register)
  ['and'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0000|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 base' ],
  ['and'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1000|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 base' ],

  # => ANDS (immediate)
  ['ands'                    , 'Wd, Wn, #bimm'                          , 'A64: 0111|0010|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=6 flags.nzcv=WWWW base' ],
  ['ands'                    , 'Xd, Xn, #bimm'                          , 'A64: 1111|0010|0|N|immr:6|imms:6|Xn:5|Xd:5'                                     , 'group=6 flags.nzcv=WWWW base' ],

  # => ANDS (shifted register)
  ['ands'                    , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0110|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 flags.nzcv=WWWW base' ],
  ['ands'                    , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1110|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 flags.nzcv=WWWW base' ],

  # => ASR (register)
  ['asr'                     , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|10|Wn:5|Wd:5'                                      , 'group=42 aliasOf=asrv preferredIf=always base' ],
  ['asr'                     , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|10|Xn:5|Xd:5'                                      , 'group=42 aliasOf=asrv preferredIf=always base' ],

  # => ASR (immediate)
  ['asr'                     , 'Wd, Wn, #shift'                         , 'A64: 0001|0011|00|shift:6|0111|11|Wn:5|Wd:5'                                    , 'group=4 aliasOf=sbfm preferredIf=always base' ],
  ['asr'                     , 'Xd, Xn, #shift'                         , 'A64: 1001|0011|01|shift:6|1111|11|Xn:5|Xd:5'                                    , 'group=4 aliasOf=sbfm preferredIf=always base' ],

  # => ASRV
  ['asrv'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|10|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['asrv'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|10|Xn:5|Xd:5'                                      , 'group=42 base' ],

  # => AT
  ['at'                      , 'at_op, Xt'                              , 'A64: 1101|0101|0000|1|at_op:3|0111|at_op[0]=100x|at_op:3|Xt:5'                  , 'group=13 aliasOf=sys preferredIf=SysOp(at_op.A,0111,at_op.B,at_op.C)==Sys_AT base' ],

  # => B.cond
  ['b.cond'                  , 'rel*4'                                  , 'A64: 0101|0100|rel:19|0|cond:4'                                                 , 'group=11 base' ],

  # => B
  ['b'                       , 'rel*4'                                  , 'A64: 0001|01|rel:26'                                                            , 'group=15 base' ],

  # => BFI
  ['bfi'                     , 'Wd, Wn, #lsb, #width'                   , 'A64: 0011|0011|0|N=0|immr:6|imms:6|Wn!=11111|Wd:5'                              , 'group=4 aliasOf=bfm preferredIf=UInt(imms)<UInt(immr) base' ],
  ['bfi'                     , 'Xd, Xn, #lsb, #width'                   , 'A64: 1011|0011|0|N=1|immr:6|imms:6|Xn!=11111|Xd:5'                              , 'group=4 aliasOf=bfm preferredIf=UInt(imms)<UInt(immr) base' ],

  # => BFM
  ['bfm'                     , 'Wd, Wn, #immr, #imms'                   , 'A64: 0011|0011|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=4 base' ],
  ['bfm'                     , 'Xd, Xn, #immr, #imms'                   , 'A64: 1011|0011|0|N=1|immr:6|imms:6|Xn:5|Xd:5'                                   , 'group=4 base' ],

  # => BFXIL
  ['bfxil'                   , 'Wd, Wn, #lsb, #width'                   , 'A64: 0011|0011|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=4 aliasOf=bfm preferredIf=UInt(imms)>=UInt(immr) base' ],
  ['bfxil'                   , 'Xd, Xn, #lsb, #width'                   , 'A64: 1011|0011|0|N=1|immr:6|imms:6|Xn:5|Xd:5'                                   , 'group=4 aliasOf=bfm preferredIf=UInt(imms)>=UInt(immr) base' ],

  # => BIC (shifted register)
  ['bic'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0000|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 base' ],
  ['bic'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1000|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 base' ],

  # => BICS (shifted register)
  ['bics'                    , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0110|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 flags.nzcv=WWWW base' ],
  ['bics'                    , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1110|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 flags.nzcv=WWWW base' ],

  # => BL
  ['bl'                      , 'rel*4'                                  , 'A64: 1001|01|rel:26'                                                            , 'group=15 base' ],

  # => BLR
  ['blr'                     , 'Xn'                                     , 'A64: 1101|0110|0011|1111|0000|00|Xn:5|0000|0'                                   , 'group=16 base' ],

  # => BR
  ['br'                      , 'Xn'                                     , 'A64: 1101|0110|0001|1111|0000|00|Xn:5|0000|0'                                   , 'group=16 base' ],

  # => BRK
  ['brk'                     , '#imm'                                   , 'A64: 1101|0100|001|imm:16|0000|0'                                               , 'group=12 base' ],

  # => CBNZ
  ['cbnz'                    , 'Wt, rel*4'                              , 'A64: 0011|0101|rel:19|Wt:5'                                                     , 'group=10 base' ],
  ['cbnz'                    , 'Xt, rel*4'                              , 'A64: 1011|0101|rel:19|Xt:5'                                                     , 'group=10 base' ],

  # => CBZ
  ['cbz'                     , 'Wt, rel*4'                              , 'A64: 0011|0100|rel:19|Wt:5'                                                     , 'group=10 base' ],
  ['cbz'                     , 'Xt, rel*4'                              , 'A64: 1011|0100|rel:19|Xt:5'                                                     , 'group=10 base' ],

  # => CCMN (immediate)
  ['ccmn'                    , 'Wn, #imm, #nzcv, cond'                  , 'A64: 0011|1010|010|imm:5|cond:4|10|Wn:5|0|nzcv:4'                               , 'group=38 flags.nzcv=WWWW base' ],
  ['ccmn'                    , 'Xn, #imm, #nzcv, cond'                  , 'A64: 1011|1010|010|imm:5|cond:4|10|Xn:5|0|nzcv:4'                               , 'group=38 flags.nzcv=WWWW base' ],

  # => CCMN (register)
  ['ccmn'                    , 'Wn, Wm, #nzcv, cond'                    , 'A64: 0011|1010|010|Wm:5|cond:4|00|Wn:5|0|nzcv:4'                                , 'group=39 flags.nzcv=WWWW base' ],
  ['ccmn'                    , 'Xn, Xm, #nzcv, cond'                    , 'A64: 1011|1010|010|Xm:5|cond:4|00|Xn:5|0|nzcv:4'                                , 'group=39 flags.nzcv=WWWW base' ],

  # => CCMP (immediate)
  ['ccmp'                    , 'Wn, #imm, #nzcv, cond'                  , 'A64: 0111|1010|010|imm:5|cond:4|10|Wn:5|0|nzcv:4'                               , 'group=38 flags.nzcv=WWWW base' ],
  ['ccmp'                    , 'Xn, #imm, #nzcv, cond'                  , 'A64: 1111|1010|010|imm:5|cond:4|10|Xn:5|0|nzcv:4'                               , 'group=38 flags.nzcv=WWWW base' ],

  # => CCMP (register)
  ['ccmp'                    , 'Wn, Wm, #nzcv, cond'                    , 'A64: 0111|1010|010|Wm:5|cond:4|00|Wn:5|0|nzcv:4'                                , 'group=39 flags.nzcv=WWWW base' ],
  ['ccmp'                    , 'Xn, Xm, #nzcv, cond'                    , 'A64: 1111|1010|010|Xm:5|cond:4|00|Xn:5|0|nzcv:4'                                , 'group=39 flags.nzcv=WWWW base' ],

  # => CINC
  ['cinc'                    , 'Wd, Wn, cond'                           , 'A64: 0001|1010|100|Rm!=11111|cond!=111x|01|Wn!=11111|Wd:5'                      , 'group=40 aliasOf=csinc preferredIf=Wn==Rm base' ],
  ['cinc'                    , 'Xd, Xn, cond'                           , 'A64: 1001|1010|100|Rm!=11111|cond!=111x|01|Xn!=11111|Xd:5'                      , 'group=40 aliasOf=csinc preferredIf=Xn==Rm base' ],

  # => CINV
  ['cinv'                    , 'Wd, Wn, cond'                           , 'A64: 0101|1010|100|Rm!=11111|cond!=111x|00|Wn!=11111|Wd:5'                      , 'group=40 aliasOf=csinv preferredIf=Wn==Rm base' ],
  ['cinv'                    , 'Xd, Xn, cond'                           , 'A64: 1101|1010|100|Rm!=11111|cond!=111x|00|Xn!=11111|Xd:5'                      , 'group=40 aliasOf=csinv preferredIf=Xn==Rm base' ],

  # => CLREX
  ['clrex'                   , '{#imm}'                                 , 'A64: 1101|0101|0000|0011|0011|imm:4|0101|1111'                                  , 'group=13 base' ],

  # => CLS
  ['cls'                     , 'Wd, Wn'                                 , 'A64: 0101|1010|1100|0000|0001|01|Wn:5|Wd:5'                                     , 'group=41 base' ],
  ['cls'                     , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0001|01|Xn:5|Xd:5'                                     , 'group=41 base' ],

  # => CLZ
  ['clz'                     , 'Wd, Wn'                                 , 'A64: 0101|1010|1100|0000|0001|00|Wn:5|Wd:5'                                     , 'group=41 base' ],
  ['clz'                     , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0001|00|Xn:5|Xd:5'                                     , 'group=41 base' ],

  # => CMN (extended register)
  ['cmn'                     , '$Wn, Wm, {extend {#amount}}'            , 'A64: 0010|1011|001|Wm:5|extend:3|amount:3|Wn:5|1111|1'                          , 'group=35 aliasOf=adds preferredIf=always flags.nzcv=WWWW base' ],
  ['cmn'                     , '$Xn, R.m, {extend {#amount}}'           , 'A64: 1010|1011|001|m:5|R/extend:3|amount:3|Xn:5|1111|1'                         , 'group=35 aliasOf=adds preferredIf=always flags.nzcv=WWWW base' ],

  # => CMN (immediate)
  ['cmn'                     , '$Wn, #imm, {LSL #amount*12}'            , 'A64: 0011|0001|amount:2|imm:12|Wn:5|1111|1'                                     , 'group=3 aliasOf=adds preferredIf=always flags.nzcv=WWWW base' ],
  ['cmn'                     , '$Xn, #imm, {LSL #amount*12}'            , 'A64: 1011|0001|amount:2|imm:12|Xn:5|1111|1'                                     , 'group=3 aliasOf=adds preferredIf=always flags.nzcv=WWWW base' ],

  # => CMN (shifted register)
  ['cmn'                     , 'Wn, Wm, {shift #amount}'                , 'A64: 0010|1011|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                             , 'group=36 aliasOf=adds preferredIf=always flags.nzcv=WWWW base' ],
  ['cmn'                     , 'Xn, Xm, {shift #amount}'                , 'A64: 1010|1011|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                             , 'group=36 aliasOf=adds preferredIf=always flags.nzcv=WWWW base' ],

  # => CMP (extended register)
  ['cmp'                     , '$Wn, Wm, {extend {#amount}}'            , 'A64: 0110|1011|001|Wm:5|extend:3|amount:3|Wn:5|1111|1'                          , 'group=35 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],
  ['cmp'                     , '$Xn, R.m, {extend {#amount}}'           , 'A64: 1110|1011|001|m:5|R/extend:3|amount:3|Xn:5|1111|1'                         , 'group=35 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],

  # => CMP (immediate)
  ['cmp'                     , '$Wn, #imm, {LSL #amount*12}'            , 'A64: 0111|0001|amount:2|imm:12|Wn:5|1111|1'                                     , 'group=3 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],
  ['cmp'                     , '$Xn, #imm, {LSL #amount*12}'            , 'A64: 1111|0001|amount:2|imm:12|Xn:5|1111|1'                                     , 'group=3 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],

  # => CMP (shifted register)
  ['cmp'                     , 'Wn, Wm, {shift #amount}'                , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                             , 'group=36 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],
  ['cmp'                     , 'Xn, Xm, {shift #amount}'                , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                             , 'group=36 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],

  # => CNEG
  ['cneg'                    , 'Wd, Wn, cond'                           , 'A64: 0101|1010|100|Rm:5|cond!=111x|01|Wn:5|Wd:5'                                , 'group=40 aliasOf=csneg preferredIf=Wn==Rm base' ],
  ['cneg'                    , 'Xd, Xn, cond'                           , 'A64: 1101|1010|100|Rm:5|cond!=111x|01|Xn:5|Xd:5'                                , 'group=40 aliasOf=csneg preferredIf=Xn==Rm base' ],

  # => CRC32B, CRC32H, CRC32W, CRC32X
  ['crc32b'                  , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0100|00|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['crc32h'                  , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0100|01|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['crc32w'                  , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0100|10|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['crc32x'                  , 'Wd, Wn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0100|11|Wn:5|Wd:5'                                      , 'group=42 base' ],

  # => CRC32CB, CRC32CH, CRC32CW, CRC32CX
  ['crc32cb'                 , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0101|00|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['crc32ch'                 , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0101|01|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['crc32cw'                 , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0101|10|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['crc32cx'                 , 'Wd, Wn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0101|11|Wn:5|Wd:5'                                      , 'group=42 base' ],

  # => CSEL
  ['csel'                    , 'Wd, Wn, Wm, cond'                       , 'A64: 0001|1010|100|Wm:5|cond:4|00|Wn:5|Wd:5'                                    , 'group=40 base' ],
  ['csel'                    , 'Xd, Xn, Xm, cond'                       , 'A64: 1001|1010|100|Xm:5|cond:4|00|Xn:5|Xd:5'                                    , 'group=40 base' ],

  # => CSET
  ['cset'                    , 'Wd, cond'                               , 'A64: 0001|1010|1001|1111|cond!=111x|0111|111|Wd:5'                              , 'group=40 aliasOf=csinc preferredIf=always base' ],
  ['cset'                    , 'Xd, cond'                               , 'A64: 1001|1010|1001|1111|cond!=111x|0111|111|Xd:5'                              , 'group=40 aliasOf=csinc preferredIf=always base' ],

  # => CSETM
  ['csetm'                   , 'Wd, cond'                               , 'A64: 0101|1010|1001|1111|cond!=111x|0011|111|Wd:5'                              , 'group=40 aliasOf=csinv preferredIf=always base' ],
  ['csetm'                   , 'Xd, cond'                               , 'A64: 1101|1010|1001|1111|cond!=111x|0011|111|Xd:5'                              , 'group=40 aliasOf=csinv preferredIf=always base' ],

  # => CSINC
  ['csinc'                   , 'Wd, Wn, Wm, cond'                       , 'A64: 0001|1010|100|Wm:5|cond:4|01|Wn:5|Wd:5'                                    , 'group=40 base' ],
  ['csinc'                   , 'Xd, Xn, Xm, cond'                       , 'A64: 1001|1010|100|Xm:5|cond:4|01|Xn:5|Xd:5'                                    , 'group=40 base' ],

  # => CSINV
  ['csinv'                   , 'Wd, Wn, Wm, cond'                       , 'A64: 0101|1010|100|Wm:5|cond:4|00|Wn:5|Wd:5'                                    , 'group=40 base' ],
  ['csinv'                   , 'Xd, Xn, Xm, cond'                       , 'A64: 1101|1010|100|Xm:5|cond:4|00|Xn:5|Xd:5'                                    , 'group=40 base' ],

  # => CSNEG
  ['csneg'                   , 'Wd, Wn, Wm, cond'                       , 'A64: 0101|1010|100|Wm:5|cond:4|01|Wn:5|Wd:5'                                    , 'group=40 base' ],
  ['csneg'                   , 'Xd, Xn, Xm, cond'                       , 'A64: 1101|1010|100|Xm:5|cond:4|01|Xn:5|Xd:5'                                    , 'group=40 base' ],

  # => DC
  ['dc'                      , 'dc_op, Xt'                              , 'A64: 1101|0101|0000|1|dc_op:3|0111|dc_op:4|dc_op:3|Xt:5'                        , 'group=13 aliasOf=sys preferredIf=SysOp(dc_op.A,0111,dc_op.B,dc_op.C)==Sys_DC base' ],

  # => DCPS1
  ['dcps1'                   , '{#imm}'                                 , 'A64: 1101|0100|101|imm:16|0000|1'                                               , 'group=12 base' ],

  # => DCPS2
  ['dcps2'                   , '{#imm}'                                 , 'A64: 1101|0100|101|imm:16|0001|0'                                               , 'group=12 base' ],

  # => DCPS3
  ['dcps3'                   , '{#imm}'                                 , 'A64: 1101|0100|101|imm:16|0001|1'                                               , 'group=12 base' ],

  # => DMB
  ['dmb'                     , 'option'                                 , 'A64: 1101|0101|0000|0011|0011|option:4|1011|1111'                               , 'group=13 base' ],

  # => DRPS
  ['drps'                    , ''                                       , 'A64: 1101|0110|1011|1111|0000|0011|1110|0000'                                   , 'group=16 base' ],

  # => DSB
  ['dsb'                     , 'option'                                 , 'A64: 1101|0101|0000|0011|0011|option:4|1001|1111'                               , 'group=13 base' ],

  # => EON (shifted register)
  ['eon'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0100|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 base' ],
  ['eon'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1100|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 base' ],

  # => EOR (immediate)
  ['eor'                     , '$Wd, Wn, #bimm'                         , 'A64: 0101|0010|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=6 base' ],
  ['eor'                     , '$Xd, Xn, #bimm'                         , 'A64: 1101|0010|0|N|immr:6|imms:6|Xn:5|Xd:5'                                     , 'group=6 base' ],

  # => EOR (shifted register)
  ['eor'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0100|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 base' ],
  ['eor'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1100|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 base' ],

  # => ERET
  ['eret'                    , ''                                       , 'A64: 1101|0110|1001|1111|0000|0011|1110|0000'                                   , 'group=16 base' ],

  # => EXTR
  ['extr'                    , 'Wd, Wn, Wm, #lsb'                       , 'A64: 0001|0011|1|N=0|0|Wm:5|lsb=0xxxxx|Wn:5|Wd:5'                               , 'group=5 base' ],
  ['extr'                    , 'Xd, Xn, Xm, #lsb'                       , 'A64: 1001|0011|1|N=1|0|Xm:5|lsb:6|Xn:5|Xd:5'                                    , 'group=5 base' ],

  # => HINT
  ['hint'                    , '#imm'                                   , 'A64: 1101|0101|0000|0011|0010|imm=0000|imm=11x|1111|1'                          , 'group=13 base' ],
  ['hint'                    , '#imm'                                   , 'A64: 1101|0101|0000|0011|0010|imm!=0000|imm:3|1111|1'                           , 'group=13 base' ],

  # => HLT
  ['hlt'                     , '#imm'                                   , 'A64: 1101|0100|010|imm:16|0000|0'                                               , 'group=12 base' ],

  # => HVC
  ['hvc'                     , '#imm'                                   , 'A64: 1101|0100|000|imm:16|0001|0'                                               , 'group=12 base' ],

  # => IC
  ['ic'                      , 'ic_op, {Xt}'                            , 'A64: 1101|0101|0000|1|ic_op:3|0111|ic_op:4|ic_op:3|Xt:5'                        , 'group=13 aliasOf=sys preferredIf=SysOp(ic_op.A,0111,ic_op.B,ic_op.C)==Sys_IC base' ],

  # => ISB
  ['isb'                     , '{option}'                               , 'A64: 1101|0101|0000|0011|0011|option:4|1101|1111'                               , 'group=13 base' ],

  # => LDAR
  ['ldar'                    , 'Wt, [$Xn, {#0}]'                        , 'A64: 1000|1000|1101|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],
  ['ldar'                    , 'Xt, [$Xn, {#0}]'                        , 'A64: 1100|1000|1101|1111|1111|11|Xn:5|Xt:5'                                     , 'group=23 base' ],

  # => LDARB
  ['ldarb'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 0000|1000|1101|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => LDARH
  ['ldarh'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 0100|1000|1101|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => LDAXP
  ['ldaxp'                   , 'Wt1, Wt2, [$Xn, {#0}]'                  , 'A64: 1000|1000|0111|1111|1|Wt2:5|Xn:5|Wt1:5'                                    , 'group=23 base' ],
  ['ldaxp'                   , 'Xt1, Xt2, [$Xn, {#0}]'                  , 'A64: 1100|1000|0111|1111|1|Xt2:5|Xn:5|Xt1:5'                                    , 'group=23 base' ],

  # => LDAXR
  ['ldaxr'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 1000|1000|0101|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],
  ['ldaxr'                   , 'Xt, [$Xn, {#0}]'                        , 'A64: 1100|1000|0101|1111|1111|11|Xn:5|Xt:5'                                     , 'group=23 base' ],

  # => LDAXRB
  ['ldaxrb'                  , 'Wt, [$Xn, {#0}]'                        , 'A64: 0000|1000|0101|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => LDAXRH
  ['ldaxrh'                  , 'Wt, [$Xn, {#0}]'                        , 'A64: 0100|1000|0101|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => LDNP
  ['ldnp'                    , 'Wt1, Wt2, [$Xn, {#imm*4}]'              , 'A64: 0010|1000|01|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=24 base' ],
  ['ldnp'                    , 'Xt1, Xt2, [$Xn, {#imm*8}]'              , 'A64: 1010|1000|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=24 base' ],

  # => LDP
  ['ldp'                     , 'Wt1, Wt2, [$Xn], #imm*4'                , 'A64: 0010|1000|11|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=32 base' ],
  ['ldp'                     , 'Xt1, Xt2, [$Xn], #imm*8'                , 'A64: 1010|1000|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=32 base' ],
  ['ldp'                     , 'Wt1, Wt2, [$Xn, #imm*4]!'               , 'A64: 0010|1001|11|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=33 base' ],
  ['ldp'                     , 'Xt1, Xt2, [$Xn, #imm*8]!'               , 'A64: 1010|1001|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=33 base' ],
  ['ldp'                     , 'Wt1, Wt2, [$Xn, {#imm*4}]'              , 'A64: 0010|1001|01|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=31 base' ],
  ['ldp'                     , 'Xt1, Xt2, [$Xn, {#imm*8}]'              , 'A64: 1010|1001|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=31 base' ],

  # => LDPSW
  ['ldpsw'                   , 'Xt1, Xt2, [$Xn], #imm*4'                , 'A64: 0110|1000|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=32 base' ],
  ['ldpsw'                   , 'Xt1, Xt2, [$Xn, #imm*4]!'               , 'A64: 0110|1001|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=33 base' ],
  ['ldpsw'                   , 'Xt1, Xt2, [$Xn, {#imm*4}]'              , 'A64: 0110|1001|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=31 base' ],

  # => LDR (immediate)
  ['ldr'                     , 'Wt, [$Xn], #simm'                       , 'A64: 1011|1000|010|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['ldr'                     , 'Xt, [$Xn], #simm'                       , 'A64: 1111|1000|010|simm:9|01|Xn:5|Xt:5'                                         , 'group=25 base' ],
  ['ldr'                     , 'Wt, [$Xn, #simm]!'                      , 'A64: 1011|1000|010|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['ldr'                     , 'Xt, [$Xn, #simm]!'                      , 'A64: 1111|1000|010|simm:9|11|Xn:5|Xt:5'                                         , 'group=26 base' ],
  ['ldr'                     , 'Wt, [$Xn, {#pimm*4}]'                   , 'A64: 1011|1001|01|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],
  ['ldr'                     , 'Xt, [$Xn, {#pimm*8}]'                   , 'A64: 1111|1001|01|pimm:12|Xn:5|Xt:5'                                            , 'group=30 base' ],

  # => LDR (literal)
  ['ldr'                     , 'Wt, rel*4'                              , 'A64: 0001|1000|rel:19|Wt:5'                                                     , 'group=22 base' ],
  ['ldr'                     , 'Xt, rel*4'                              , 'A64: 0101|1000|rel:19|Xt:5'                                                     , 'group=22 base' ],

  # => LDR (register)
  ['ldr'                     , 'Wt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 1011|1000|011|m:5|R[0]/extend:3|amount:1|10|Xn:5|Wt:5'                     , 'group=27 base' ],
  ['ldr'                     , 'Xt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 1111|1000|011|m:5|R[0]/extend:3|amount:1|10|Xn:5|Xt:5'                     , 'group=27 base' ],

  # => LDRB (immediate)
  ['ldrb'                    , 'Wt, [$Xn], #simm'                       , 'A64: 0011|1000|010|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['ldrb'                    , 'Wt, [$Xn, #simm]!'                      , 'A64: 0011|1000|010|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['ldrb'                    , 'Wt, [$Xn, {#pimm}]'                     , 'A64: 0011|1001|01|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],

  # => LDRB (register)
  ['ldrb'                    , 'Wt, [$Xn, R.m, extend {#amount}]'       , 'A64: 0011|1000|011|m:5|R[0]/extend!=011|amount:1|10|Xn:5|Wt:5'                  , 'group=27 base' ],
  ['ldrb'                    , 'Wt, [$Xn, Xm, {LSL #amount}]'           , 'A64: 0011|1000|011|Xm:5|011|amount:1|10|Xn:5|Wt:5'                              , 'group=27 base' ],

  # => LDRH (immediate)
  ['ldrh'                    , 'Wt, [$Xn], #simm'                       , 'A64: 0111|1000|010|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['ldrh'                    , 'Wt, [$Xn, #simm]!'                      , 'A64: 0111|1000|010|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['ldrh'                    , 'Wt, [$Xn, {#pimm*2}]'                   , 'A64: 0111|1001|01|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],

  # => LDRH (register)
  ['ldrh'                    , 'Wt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 0111|1000|011|m:5|R[0]/extend:3|amount:1|10|Xn:5|Wt:5'                     , 'group=27 base' ],

  # => LDRSB (immediate)
  ['ldrsb'                   , 'Wt, [$Xn], #simm'                       , 'A64: 0011|1000|110|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['ldrsb'                   , 'Xt, [$Xn], #simm'                       , 'A64: 0011|1000|100|simm:9|01|Xn:5|Xt:5'                                         , 'group=25 base' ],
  ['ldrsb'                   , 'Wt, [$Xn, #simm]!'                      , 'A64: 0011|1000|110|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['ldrsb'                   , 'Xt, [$Xn, #simm]!'                      , 'A64: 0011|1000|100|simm:9|11|Xn:5|Xt:5'                                         , 'group=26 base' ],
  ['ldrsb'                   , 'Wt, [$Xn, {#pimm}]'                     , 'A64: 0011|1001|11|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],
  ['ldrsb'                   , 'Xt, [$Xn, {#pimm}]'                     , 'A64: 0011|1001|10|pimm:12|Xn:5|Xt:5'                                            , 'group=30 base' ],

  # => LDRSB (register)
  ['ldrsb'                   , 'Wt, [$Xn, R.m, extend {#amount}]'       , 'A64: 0011|1000|111|m:5|R[0]/extend!=011|amount:1|10|Xn:5|Wt:5'                  , 'group=27 base' ],
  ['ldrsb'                   , 'Wt, [$Xn, Xm, {LSL #amount}]'           , 'A64: 0011|1000|111|Xm:5|011|amount:1|10|Xn:5|Wt:5'                              , 'group=27 base' ],
  ['ldrsb'                   , 'Xt, [$Xn, R.m, extend {#amount}]'       , 'A64: 0011|1000|101|m:5|R[0]/extend!=011|amount:1|10|Xn:5|Xt:5'                  , 'group=27 base' ],
  ['ldrsb'                   , 'Xt, [$Xn, Xm, {LSL #amount}]'           , 'A64: 0011|1000|101|Xm:5|011|amount:1|10|Xn:5|Xt:5'                              , 'group=27 base' ],

  # => LDRSH (immediate)
  ['ldrsh'                   , 'Wt, [$Xn], #simm'                       , 'A64: 0111|1000|110|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['ldrsh'                   , 'Xt, [$Xn], #simm'                       , 'A64: 0111|1000|100|simm:9|01|Xn:5|Xt:5'                                         , 'group=25 base' ],
  ['ldrsh'                   , 'Wt, [$Xn, #simm]!'                      , 'A64: 0111|1000|110|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['ldrsh'                   , 'Xt, [$Xn, #simm]!'                      , 'A64: 0111|1000|100|simm:9|11|Xn:5|Xt:5'                                         , 'group=26 base' ],
  ['ldrsh'                   , 'Wt, [$Xn, {#pimm*2}]'                   , 'A64: 0111|1001|11|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],
  ['ldrsh'                   , 'Xt, [$Xn, {#pimm*2}]'                   , 'A64: 0111|1001|10|pimm:12|Xn:5|Xt:5'                                            , 'group=30 base' ],

  # => LDRSH (register)
  ['ldrsh'                   , 'Wt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 0111|1000|111|m:5|R[0]/extend:3|amount:1|10|Xn:5|Wt:5'                     , 'group=27 base' ],
  ['ldrsh'                   , 'Xt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 0111|1000|101|m:5|R[0]/extend:3|amount:1|10|Xn:5|Xt:5'                     , 'group=27 base' ],

  # => LDRSW (immediate)
  ['ldrsw'                   , 'Xt, [$Xn], #simm'                       , 'A64: 1011|1000|100|simm:9|01|Xn:5|Xt:5'                                         , 'group=25 base' ],
  ['ldrsw'                   , 'Xt, [$Xn, #simm]!'                      , 'A64: 1011|1000|100|simm:9|11|Xn:5|Xt:5'                                         , 'group=26 base' ],
  ['ldrsw'                   , 'Xt, [$Xn, {#pimm*4}]'                   , 'A64: 1011|1001|10|pimm:12|Xn:5|Xt:5'                                            , 'group=30 base' ],

  # => LDRSW (literal)
  ['ldrsw'                   , 'Xt, rel*4'                              , 'A64: 1001|1000|rel:19|Xt:5'                                                     , 'group=22 base' ],

  # => LDRSW (register)
  ['ldrsw'                   , 'Xt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 1011|1000|101|m:5|R[0]/extend:3|amount:1|10|Xn:5|Xt:5'                     , 'group=27 base' ],

  # => LDTR
  ['ldtr'                    , 'Wt, [$Xn, {#simm}]'                     , 'A64: 1011|1000|010|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],
  ['ldtr'                    , 'Xt, [$Xn, {#simm}]'                     , 'A64: 1111|1000|010|simm:9|10|Xn:5|Xt:5'                                         , 'group=28 base' ],

  # => LDTRB
  ['ldtrb'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|010|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],

  # => LDTRH
  ['ldtrh'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|010|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],

  # => LDTRSB
  ['ldtrsb'                  , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|110|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],
  ['ldtrsb'                  , 'Xt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|100|simm:9|10|Xn:5|Xt:5'                                         , 'group=28 base' ],

  # => LDTRSH
  ['ldtrsh'                  , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|110|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],
  ['ldtrsh'                  , 'Xt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|100|simm:9|10|Xn:5|Xt:5'                                         , 'group=28 base' ],

  # => LDTRSW
  ['ldtrsw'                  , 'Xt, [$Xn, {#simm}]'                     , 'A64: 1011|1000|100|simm:9|10|Xn:5|Xt:5'                                         , 'group=28 base' ],

  # => LDUR
  ['ldur'                    , 'Wt, [$Xn, {#simm}]'                     , 'A64: 1011|1000|010|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],
  ['ldur'                    , 'Xt, [$Xn, {#simm}]'                     , 'A64: 1111|1000|010|simm:9|00|Xn:5|Xt:5'                                         , 'group=29 base' ],

  # => LDURB
  ['ldurb'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|010|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],

  # => LDURH
  ['ldurh'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|010|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],

  # => LDURSB
  ['ldursb'                  , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|110|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],
  ['ldursb'                  , 'Xt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|100|simm:9|00|Xn:5|Xt:5'                                         , 'group=29 base' ],

  # => LDURSH
  ['ldursh'                  , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|110|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],
  ['ldursh'                  , 'Xt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|100|simm:9|00|Xn:5|Xt:5'                                         , 'group=29 base' ],

  # => LDURSW
  ['ldursw'                  , 'Xt, [$Xn, {#simm}]'                     , 'A64: 1011|1000|100|simm:9|00|Xn:5|Xt:5'                                         , 'group=29 base' ],

  # => LDXP
  ['ldxp'                    , 'Wt1, Wt2, [$Xn, {#0}]'                  , 'A64: 1000|1000|0111|1111|0|Wt2:5|Xn:5|Wt1:5'                                    , 'group=23 base' ],
  ['ldxp'                    , 'Xt1, Xt2, [$Xn, {#0}]'                  , 'A64: 1100|1000|0111|1111|0|Xt2:5|Xn:5|Xt1:5'                                    , 'group=23 base' ],

  # => LDXR
  ['ldxr'                    , 'Wt, [$Xn, {#0}]'                        , 'A64: 1000|1000|0101|1111|0111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],
  ['ldxr'                    , 'Xt, [$Xn, {#0}]'                        , 'A64: 1100|1000|0101|1111|0111|11|Xn:5|Xt:5'                                     , 'group=23 base' ],

  # => LDXRB
  ['ldxrb'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 0000|1000|0101|1111|0111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => LDXRH
  ['ldxrh'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 0100|1000|0101|1111|0111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => LSL (register)
  ['lsl'                     , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|00|Wn:5|Wd:5'                                      , 'group=42 aliasOf=lslv preferredIf=always base' ],
  ['lsl'                     , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|00|Xn:5|Xd:5'                                      , 'group=42 aliasOf=lslv preferredIf=always base' ],

  # => LSL (immediate)
  ['lsl'                     , 'Wd, Wn, #shift'                         , 'A64: 0101|0011|00|immr:6|imms!=011111|Wn:5|Wd:5'                                , 'group=4 aliasOf=ubfm preferredIf=imms+1==immr base' ],
  ['lsl'                     , 'Xd, Xn, #shift'                         , 'A64: 1101|0011|01|immr:6|imms!=111111|Xn:5|Xd:5'                                , 'group=4 aliasOf=ubfm preferredIf=imms+1==immr base' ],

  # => LSLV
  ['lslv'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|00|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['lslv'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|00|Xn:5|Xd:5'                                      , 'group=42 base' ],

  # => LSR (register)
  ['lsr'                     , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|01|Wn:5|Wd:5'                                      , 'group=42 aliasOf=lsrv preferredIf=always base' ],
  ['lsr'                     , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|01|Xn:5|Xd:5'                                      , 'group=42 aliasOf=lsrv preferredIf=always base' ],

  # => LSR (immediate)
  ['lsr'                     , 'Wd, Wn, #shift'                         , 'A64: 0101|0011|00|shift:6|0111|11|Wn:5|Wd:5'                                    , 'group=4 aliasOf=ubfm preferredIf=always base' ],
  ['lsr'                     , 'Xd, Xn, #shift'                         , 'A64: 1101|0011|01|shift:6|1111|11|Xn:5|Xd:5'                                    , 'group=4 aliasOf=ubfm preferredIf=always base' ],

  # => LSRV
  ['lsrv'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|01|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['lsrv'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|01|Xn:5|Xd:5'                                      , 'group=42 base' ],

  # => MADD
  ['madd'                    , 'Wd, Wn, Wm, Wa'                         , 'A64: 0001|1011|000|Wm:5|0|Wa:5|Wn:5|Wd:5'                                       , 'group=43 base' ],
  ['madd'                    , 'Xd, Xn, Xm, Xa'                         , 'A64: 1001|1011|000|Xm:5|0|Xa:5|Xn:5|Xd:5'                                       , 'group=43 base' ],

  # => MNEG
  ['mneg'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1011|000|Wm:5|1111|11|Wn:5|Wd:5'                                      , 'group=43 aliasOf=msub preferredIf=always base' ],
  ['mneg'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1011|000|Xm:5|1111|11|Xn:5|Xd:5'                                      , 'group=43 aliasOf=msub preferredIf=always base' ],

  # => MOV (to/from SP)
  ['mov'                     , '$Wd, $Wn'                               , 'A64: 0001|0001|0000|0000|0000|00|Wn:5|Wd:5'                                     , 'group=3 aliasOf=add preferredIf=(Wd==11111||Wn==11111) base' ],
  ['mov'                     , '$Xd, $Xn'                               , 'A64: 1001|0001|0000|0000|0000|00|Xn:5|Xd:5'                                     , 'group=3 aliasOf=add preferredIf=(Xd==11111||Xn==11111) base' ],

  # => MOV (inverted wide immediate)
  ['mov'                     , 'Wd, #imm'                               , 'A64: 0001|0010|1|imm.B:2|imm.A:16|Wd:5'                                         , 'group=7 aliasOf=movn preferredIf="!(IsZero(imm.A) && imm.B!=0) && !IsOnes(imm.A)" base' ],
  ['mov'                     , 'Xd, #imm'                               , 'A64: 1001|0010|1|imm.B:2|imm.A:16|Xd:5'                                         , 'group=7 aliasOf=movn preferredIf="!(IsZero(imm.A) && imm.B!=0)" base' ],

  # => MOV (wide immediate)
  ['mov'                     , 'Wd, #imm'                               , 'A64: 0101|0010|1|imm.B:2|imm.A:16|Wd:5'                                         , 'group=7 aliasOf=movz preferredIf="!(IsZero(imm.A) && imm.B!=0)" base' ],
  ['mov'                     , 'Xd, #imm'                               , 'A64: 1101|0010|1|imm.B:2|imm.A:16|Xd:5'                                         , 'group=7 aliasOf=movz preferredIf="!(IsZero(imm.A) && imm.B!=0)" base' ],

  # => MOV (bitmask immediate)
  ['mov'                     , '$Wd, #bimm'                             , 'A64: sf=0|0110|0100|N=0|immr:6|imms:6|1111|1|Wd:5'                              , 'group=6 aliasOf=orr preferredIf=!MoveWidePreferred(sf,N,imms,immr) base' ],
  ['mov'                     , '$Xd, #bimm'                             , 'A64: sf=1|0110|0100|N|immr:6|imms:6|1111|1|Xd:5'                                , 'group=6 aliasOf=orr preferredIf=!MoveWidePreferred(sf,N,imms,immr) base' ],

  # => MOV (register)
  ['mov'                     , 'Wd, Wm'                                 , 'A64: 0010|1010|000|Wm:5|0000|0011|111|Wd:5'                                     , 'group=44 aliasOf=orr preferredIf=always base' ],
  ['mov'                     , 'Xd, Xm'                                 , 'A64: 1010|1010|000|Xm:5|0000|0011|111|Xd:5'                                     , 'group=44 aliasOf=orr preferredIf=always base' ],

  # => MOVK
  ['movk'                    , 'Wd, #imm, {LSL #amount*16}'             , 'A64: 0111|0010|1|amount:2|imm:16|Wd:5'                                          , 'group=7 base' ],
  ['movk'                    , 'Xd, #imm, {LSL #amount*16}'             , 'A64: 1111|0010|1|amount:2|imm:16|Xd:5'                                          , 'group=7 base' ],

  # => MOVN
  ['movn'                    , 'Wd, #imm, {LSL #amount*16}'             , 'A64: 0001|0010|1|amount:2|imm:16|Wd:5'                                          , 'group=7 base' ],
  ['movn'                    , 'Xd, #imm, {LSL #amount*16}'             , 'A64: 1001|0010|1|amount:2|imm:16|Xd:5'                                          , 'group=7 base' ],

  # => MOVZ
  ['movz'                    , 'Wd, #imm, {LSL #amount*16}'             , 'A64: 0101|0010|1|amount:2|imm:16|Wd:5'                                          , 'group=7 base' ],
  ['movz'                    , 'Xd, #imm, {LSL #amount*16}'             , 'A64: 1101|0010|1|amount:2|imm:16|Xd:5'                                          , 'group=7 base' ],

  # => MRS
  ['mrs'                     , 'Xt, sysreg'                             , 'A64: 1101|0101|0011|sysreg:1|sysreg:3|sysreg:4|sysreg:4|sysreg:3|Xt:5'          , 'group=13 base' ],

  # => MSR (immediate)
  ['msr'                     , 'pstate, #imm'                           , 'A64: 1101|0101|0000|0|pstate:3|0100|imm:4|pstate:3|1111|1'                      , 'group=13 base' ],

  # => MSR (register)
  ['msr'                     , 'sysreg, Xt'                             , 'A64: 1101|0101|0001|sysreg:1|sysreg:3|sysreg:4|sysreg:4|sysreg:3|Xt:5'          , 'group=13 base' ],

  # => MSUB
  ['msub'                    , 'Wd, Wn, Wm, Wa'                         , 'A64: 0001|1011|000|Wm:5|1|Wa:5|Wn:5|Wd:5'                                       , 'group=43 base' ],
  ['msub'                    , 'Xd, Xn, Xm, Xa'                         , 'A64: 1001|1011|000|Xm:5|1|Xa:5|Xn:5|Xd:5'                                       , 'group=43 base' ],

  # => MUL
  ['mul'                     , 'Wd, Wn, Wm'                             , 'A64: 0001|1011|000|Wm:5|0111|11|Wn:5|Wd:5'                                      , 'group=43 aliasOf=madd preferredIf=always base' ],
  ['mul'                     , 'Xd, Xn, Xm'                             , 'A64: 1001|1011|000|Xm:5|0111|11|Xn:5|Xd:5'                                      , 'group=43 aliasOf=madd preferredIf=always base' ],

  # => MVN
  ['mvn'                     , 'Wd, Wm, {shift #amount}'                , 'A64: 0010|1010|shift:2|1|Wm:5|amount:6|1111|1|Wd:5'                             , 'group=44 aliasOf=orn preferredIf=always base' ],
  ['mvn'                     , 'Xd, Xm, {shift #amount}'                , 'A64: 1010|1010|shift:2|1|Xm:5|amount:6|1111|1|Xd:5'                             , 'group=44 aliasOf=orn preferredIf=always base' ],

  # => NEG (shifted register)
  ['neg'                     , 'Wd, Wm, {shift #amount}'                , 'A64: 0100|1011|shift:2|0|Wm:5|amount:6|1111|1|Wd:5'                             , 'group=36 aliasOf=sub preferredIf=always base' ],
  ['neg'                     , 'Xd, Xm, {shift #amount}'                , 'A64: 1100|1011|shift:2|0|Xm:5|amount:6|1111|1|Xd:5'                             , 'group=36 aliasOf=sub preferredIf=always base' ],

  # => NEGS
  ['negs'                    , 'Wd, Wm, {shift #amount}'                , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|1111|1|Wd:5'                             , 'group=36 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],
  ['negs'                    , 'Xd, Xm, {shift #amount}'                , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|1111|1|Xd:5'                             , 'group=36 aliasOf=subs preferredIf=always flags.nzcv=WWWW base' ],

  # => NGC
  ['ngc'                     , 'Wd, Wm'                                 , 'A64: 0101|1010|000|Wm:5|0000|0011|111|Wd:5'                                     , 'group=37 aliasOf=sbc preferredIf=always flags.nzcv=UURU base' ],
  ['ngc'                     , 'Xd, Xm'                                 , 'A64: 1101|1010|000|Xm:5|0000|0011|111|Xd:5'                                     , 'group=37 aliasOf=sbc preferredIf=always flags.nzcv=UURU base' ],

  # => NGCS
  ['ngcs'                    , 'Wd, Wm'                                 , 'A64: 0111|1010|000|Wm:5|0000|0011|111|Wd:5'                                     , 'group=37 aliasOf=sbcs preferredIf=always flags.nzcv=WWXW base' ],
  ['ngcs'                    , 'Xd, Xm'                                 , 'A64: 1111|1010|000|Xm:5|0000|0011|111|Xd:5'                                     , 'group=37 aliasOf=sbcs preferredIf=always flags.nzcv=WWXW base' ],

  # => NOP
  ['nop'                     , ''                                       , 'A64: 1101|0101|0000|0011|0010|0000|0001|1111'                                   , 'group=13 base' ],

  # => ORN (shifted register)
  ['orn'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0010|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 base' ],
  ['orn'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1010|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 base' ],

  # => ORR (immediate)
  ['orr'                     , '$Wd, Wn, #bimm'                         , 'A64: 0011|0010|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=6 base' ],
  ['orr'                     , '$Xd, Xn, #bimm'                         , 'A64: 1011|0010|0|N|immr:6|imms:6|Xn:5|Xd:5'                                     , 'group=6 base' ],

  # => ORR (shifted register)
  ['orr'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0010|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=44 base' ],
  ['orr'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1010|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=44 base' ],

  # => PRFM (immediate)
  ['prfm'                    , 'prfop, [$Xn, {#pimm*8}]'                , 'A64: 1111|1001|10|pimm:12|Xn:5|prfop:5'                                         , 'group=30 base' ],

  # => PRFM (literal)
  ['prfm'                    , 'prfop, rel*4'                           , 'A64: 1101|1000|rel:19|prfop:5'                                                  , 'group=22 base' ],

  # => PRFM (register)
  ['prfm'                    , 'prfop, [$Xn, R.m, {extend {#amount}}]'  , 'A64: 1111|1000|101|m:5|R[0]/extend:3|amount:1|10|Xn:5|prfop:5'                  , 'group=27 base' ],

  # => PRFM (unscaled offset)
  ['prfum'                   , 'prfop, [$Xn, {#simm}]'                  , 'A64: 1111|1000|100|simm:9|00|Xn:5|prfop:5'                                      , 'group=29 base' ],

  # => RBIT
  ['rbit'                    , 'Wd, Wn'                                 , 'A64: 0101|1010|1100|0000|0000|00|Wn:5|Wd:5'                                     , 'group=41 base' ],
  ['rbit'                    , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0000|00|Xn:5|Xd:5'                                     , 'group=41 base' ],

  # => RET
  ['ret'                     , '{Xn}'                                   , 'A64: 1101|0110|0101|1111|0000|00|Xn:5|0000|0'                                   , 'group=16 base' ],

  # => REV
  ['rev'                     , 'Wd, Wn'                                 , 'A64: 0101|1010|1100|0000|0000|1x|Wn:5|Wd:5'                                     , 'group=41 base' ],
  ['rev'                     , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0000|1x|Xn:5|Xd:5'                                     , 'group=41 base' ],

  # => REV16
  ['rev16'                   , 'Wd, Wn'                                 , 'A64: 0101|1010|1100|0000|0000|01|Wn:5|Wd:5'                                     , 'group=41 base' ],
  ['rev16'                   , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0000|01|Xn:5|Xd:5'                                     , 'group=41 base' ],

  # => REV32
  ['rev32'                   , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0000|10|Xn:5|Xd:5'                                     , 'group=41 base' ],

  # => REV64
  ['rev64'                   , 'Xd, Xn'                                 , 'A64: 1101|1010|1100|0000|0000|11|Xn:5|Xd:5'                                     , 'group=41 aliasOf=rev preferredIf=never base' ],

  # => ROR (immediate)
  ['ror'                     , 'Wd, Ws, #shift'                         , 'A64: 0001|0011|100|Rm:5|shift=0xxxxx|Ws:5|Wd:5'                                 , 'group=5 aliasOf=extr preferredIf=Ws==Rm base' ],
  ['ror'                     , 'Xd, Xs, #shift'                         , 'A64: 1001|0011|110|Rm:5|shift:6|Xs:5|Xd:5'                                      , 'group=5 aliasOf=extr preferredIf=Xs==Rm base' ],

  # => ROR (register)
  ['ror'                     , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|11|Wn:5|Wd:5'                                      , 'group=42 aliasOf=rorv preferredIf=always base' ],
  ['ror'                     , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|11|Xn:5|Xd:5'                                      , 'group=42 aliasOf=rorv preferredIf=always base' ],

  # => RORV
  ['rorv'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0010|11|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['rorv'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0010|11|Xn:5|Xd:5'                                      , 'group=42 base' ],

  # => SBC
  ['sbc'                     , 'Wd, Wn, Wm'                             , 'A64: 0101|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                      , 'group=37 flags.nzcv=UURU base' ],
  ['sbc'                     , 'Xd, Xn, Xm'                             , 'A64: 1101|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                      , 'group=37 flags.nzcv=UURU base' ],

  # => SBCS
  ['sbcs'                    , 'Wd, Wn, Wm'                             , 'A64: 0111|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                      , 'group=37 flags.nzcv=WWXW base' ],
  ['sbcs'                    , 'Xd, Xn, Xm'                             , 'A64: 1111|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                      , 'group=37 flags.nzcv=WWXW base' ],

  # => SBFIZ
  ['sbfiz'                   , 'Wd, Wn, #lsb, #width'                   , 'A64: 0001|0011|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=4 aliasOf=sbfm preferredIf=UInt(imms)<UInt(immr) base' ],
  ['sbfiz'                   , 'Xd, Xn, #lsb, #width'                   , 'A64: 1001|0011|0|N=1|immr:6|imms:6|Xn:5|Xd:5'                                   , 'group=4 aliasOf=sbfm preferredIf=UInt(imms)<UInt(immr) base' ],

  # => SBFM
  ['sbfm'                    , 'Wd, Wn, #immr, #imms'                   , 'A64: 0001|0011|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=4 base' ],
  ['sbfm'                    , 'Xd, Xn, #immr, #imms'                   , 'A64: 1001|0011|0|N=1|immr:6|imms:6|Xn:5|Xd:5'                                   , 'group=4 base' ],

  # => SBFX
  ['sbfx'                    , 'Wd, Wn, #lsb, #width'                   , 'A64: sf=0|opc=00|1001|10|N=0|immr:6|imms:6|Wn:5|Wd:5'                           , 'group=4 aliasOf=sbfm preferredIf=BFXPreferred(sf,opc[1],imms,immr) base' ],
  ['sbfx'                    , 'Xd, Xn, #lsb, #width'                   , 'A64: sf=1|opc=00|1001|10|N=1|immr:6|imms:6|Xn:5|Xd:5'                           , 'group=4 aliasOf=sbfm preferredIf=BFXPreferred(sf,opc[1],imms,immr) base' ],

  # => SDIV
  ['sdiv'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0000|11|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['sdiv'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0000|11|Xn:5|Xd:5'                                      , 'group=42 base' ],

  # => SEV
  ['sev'                     , ''                                       , 'A64: 1101|0101|0000|0011|0010|0000|1001|1111'                                   , 'group=13 base' ],

  # => SEVL
  ['sevl'                    , ''                                       , 'A64: 1101|0101|0000|0011|0010|0000|1011|1111'                                   , 'group=13 base' ],

  # => SMADDL
  ['smaddl'                  , 'Xd, Wn, Wm, Xa'                         , 'A64: 1001|1011|001|Wm:5|0|Xa:5|Wn:5|Xd:5'                                       , 'group=43 base' ],

  # => SMC
  ['smc'                     , '#imm'                                   , 'A64: 1101|0100|000|imm:16|0001|1'                                               , 'group=12 base' ],

  # => SMNEGL
  ['smnegl'                  , 'Xd, Wn, Wm'                             , 'A64: 1001|1011|001|Wm:5|1111|11|Wn:5|Xd:5'                                      , 'group=43 aliasOf=smsubl preferredIf=always base' ],

  # => SMSUBL
  ['smsubl'                  , 'Xd, Wn, Wm, Xa'                         , 'A64: 1001|1011|001|Wm:5|1|Xa:5|Wn:5|Xd:5'                                       , 'group=43 base' ],

  # => SMULH
  ['smulh'                   , 'Xd, Xn, Xm'                             , 'A64: 1001|1011|010|Xm:5|0111|11|Xn:5|Xd:5'                                      , 'group=43 base' ],

  # => SMULL
  ['smull'                   , 'Xd, Wn, Wm'                             , 'A64: 1001|1011|001|Wm:5|0111|11|Wn:5|Xd:5'                                      , 'group=43 aliasOf=smaddl preferredIf=always base' ],

  # => STLR
  ['stlr'                    , 'Wt, [$Xn, {#0}]'                        , 'A64: 1000|1000|1001|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],
  ['stlr'                    , 'Xt, [$Xn, {#0}]'                        , 'A64: 1100|1000|1001|1111|1111|11|Xn:5|Xt:5'                                     , 'group=23 base' ],

  # => STLRB
  ['stlrb'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 0000|1000|1001|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => STLRH
  ['stlrh'                   , 'Wt, [$Xn, {#0}]'                        , 'A64: 0100|1000|1001|1111|1111|11|Xn:5|Wt:5'                                     , 'group=23 base' ],

  # => STLXP
  ['stlxp'                   , 'Ws, Wt1, Wt2, [$Xn, {#0}]'              , 'A64: 1000|1000|001|Ws:5|1|Wt2:5|Xn:5|Wt1:5'                                     , 'group=23 base' ],
  ['stlxp'                   , 'Ws, Xt1, Xt2, [$Xn, {#0}]'              , 'A64: 1100|1000|001|Ws:5|1|Xt2:5|Xn:5|Xt1:5'                                     , 'group=23 base' ],

  # => STLXR
  ['stlxr'                   , 'Ws, Wt, [$Xn, {#0}]'                    , 'A64: 1000|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                      , 'group=23 base' ],
  ['stlxr'                   , 'Ws, Xt, [$Xn, {#0}]'                    , 'A64: 1100|1000|000|Ws:5|1111|11|Xn:5|Xt:5'                                      , 'group=23 base' ],

  # => STLXRB
  ['stlxrb'                  , 'Ws, Wt, [$Xn, {#0}]'                    , 'A64: 0000|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                      , 'group=23 base' ],

  # => STLXRH
  ['stlxrh'                  , 'Ws, Wt, [$Xn, {#0}]'                    , 'A64: 0100|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                      , 'group=23 base' ],

  # => STNP
  ['stnp'                    , 'Wt1, Wt2, [$Xn, {#imm*4}]'              , 'A64: 0010|1000|00|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=24 base' ],
  ['stnp'                    , 'Xt1, Xt2, [$Xn, {#imm*8}]'              , 'A64: 1010|1000|00|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=24 base' ],

  # => STP
  ['stp'                     , 'Wt1, Wt2, [$Xn], #imm*4'                , 'A64: 0010|1000|10|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=32 base' ],
  ['stp'                     , 'Xt1, Xt2, [$Xn], #imm*8'                , 'A64: 1010|1000|10|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=32 base' ],
  ['stp'                     , 'Wt1, Wt2, [$Xn, #imm*4]!'               , 'A64: 0010|1001|10|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=33 base' ],
  ['stp'                     , 'Xt1, Xt2, [$Xn, #imm*8]!'               , 'A64: 1010|1001|10|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=33 base' ],
  ['stp'                     , 'Wt1, Wt2, [$Xn, {#imm*4}]'              , 'A64: 0010|1001|00|imm:7|Wt2:5|Xn:5|Wt1:5'                                       , 'group=31 base' ],
  ['stp'                     , 'Xt1, Xt2, [$Xn, {#imm*8}]'              , 'A64: 1010|1001|00|imm:7|Xt2:5|Xn:5|Xt1:5'                                       , 'group=31 base' ],

  # => STR (immediate)
  ['str'                     , 'Wt, [$Xn], #simm'                       , 'A64: 1011|1000|000|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['str'                     , 'Xt, [$Xn], #simm'                       , 'A64: 1111|1000|000|simm:9|01|Xn:5|Xt:5'                                         , 'group=25 base' ],
  ['str'                     , 'Wt, [$Xn, #simm]!'                      , 'A64: 1011|1000|000|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['str'                     , 'Xt, [$Xn, #simm]!'                      , 'A64: 1111|1000|000|simm:9|11|Xn:5|Xt:5'                                         , 'group=26 base' ],
  ['str'                     , 'Wt, [$Xn, {#pimm*4}]'                   , 'A64: 1011|1001|00|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],
  ['str'                     , 'Xt, [$Xn, {#pimm*8}]'                   , 'A64: 1111|1001|00|pimm:12|Xn:5|Xt:5'                                            , 'group=30 base' ],

  # => STR (register)
  ['str'                     , 'Wt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 1011|1000|001|m:5|R[0]/extend:3|amount:1|10|Xn:5|Wt:5'                     , 'group=27 base' ],
  ['str'                     , 'Xt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 1111|1000|001|m:5|R[0]/extend:3|amount:1|10|Xn:5|Xt:5'                     , 'group=27 base' ],

  # => STRB (immediate)
  ['strb'                    , 'Wt, [$Xn], #simm'                       , 'A64: 0011|1000|000|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['strb'                    , 'Wt, [$Xn, #simm]!'                      , 'A64: 0011|1000|000|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['strb'                    , 'Wt, [$Xn, {#pimm}]'                     , 'A64: 0011|1001|00|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],

  # => STRB (register)
  ['strb'                    , 'Wt, [$Xn, R.m, extend {#amount}]'       , 'A64: 0011|1000|001|m:5|R[0]/extend!=011|amount:1|10|Xn:5|Wt:5'                  , 'group=27 base' ],
  ['strb'                    , 'Wt, [$Xn, Xm, {LSL #amount}]'           , 'A64: 0011|1000|001|Xm:5|011|amount:1|10|Xn:5|Wt:5'                              , 'group=27 base' ],

  # => STRH (immediate)
  ['strh'                    , 'Wt, [$Xn], #simm'                       , 'A64: 0111|1000|000|simm:9|01|Xn:5|Wt:5'                                         , 'group=25 base' ],
  ['strh'                    , 'Wt, [$Xn, #simm]!'                      , 'A64: 0111|1000|000|simm:9|11|Xn:5|Wt:5'                                         , 'group=26 base' ],
  ['strh'                    , 'Wt, [$Xn, {#pimm*2}]'                   , 'A64: 0111|1001|00|pimm:12|Xn:5|Wt:5'                                            , 'group=30 base' ],

  # => STRH (register)
  ['strh'                    , 'Wt, [$Xn, R.m, {extend {#amount}}]'     , 'A64: 0111|1000|001|m:5|R[0]/extend:3|amount:1|10|Xn:5|Wt:5'                     , 'group=27 base' ],

  # => STTR
  ['sttr'                    , 'Wt, [$Xn, {#simm}]'                     , 'A64: 1011|1000|000|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],
  ['sttr'                    , 'Xt, [$Xn, {#simm}]'                     , 'A64: 1111|1000|000|simm:9|10|Xn:5|Xt:5'                                         , 'group=28 base' ],

  # => STTRB
  ['sttrb'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|000|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],

  # => STTRH
  ['sttrh'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|000|simm:9|10|Xn:5|Wt:5'                                         , 'group=28 base' ],

  # => STUR
  ['stur'                    , 'Wt, [$Xn, {#simm}]'                     , 'A64: 1011|1000|000|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],
  ['stur'                    , 'Xt, [$Xn, {#simm}]'                     , 'A64: 1111|1000|000|simm:9|00|Xn:5|Xt:5'                                         , 'group=29 base' ],

  # => STURB
  ['sturb'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0011|1000|000|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],

  # => STURH
  ['sturh'                   , 'Wt, [$Xn, {#simm}]'                     , 'A64: 0111|1000|000|simm:9|00|Xn:5|Wt:5'                                         , 'group=29 base' ],

  # => STXP
  ['stxp'                    , 'Ws, Wt1, Wt2, [$Xn, {#0}]'              , 'A64: 1000|1000|001|Ws:5|0|Wt2:5|Xn:5|Wt1:5'                                     , 'group=23 base' ],
  ['stxp'                    , 'Ws, Xt1, Xt2, [$Xn, {#0}]'              , 'A64: 1100|1000|001|Ws:5|0|Xt2:5|Xn:5|Xt1:5'                                     , 'group=23 base' ],

  # => STXR
  ['stxr'                    , 'Ws, Wt, [$Xn, {#0}]'                    , 'A64: 1000|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                      , 'group=23 base' ],
  ['stxr'                    , 'Ws, Xt, [$Xn, {#0}]'                    , 'A64: 1100|1000|000|Ws:5|0111|11|Xn:5|Xt:5'                                      , 'group=23 base' ],

  # => STXRB
  ['stxrb'                   , 'Ws, Wt, [$Xn, {#0}]'                    , 'A64: 0000|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                      , 'group=23 base' ],

  # => STXRH
  ['stxrh'                   , 'Ws, Wt, [$Xn, {#0}]'                    , 'A64: 0100|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                      , 'group=23 base' ],

  # => SUB (extended register)
  ['sub'                     , '$Wd, $Wn, Wm, {extend {#amount}}'       , 'A64: 0100|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                            , 'group=35 base' ],
  ['sub'                     , '$Xd, $Xn, R.m, {extend {#amount}}'      , 'A64: 1100|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                           , 'group=35 base' ],

  # => SUB (immediate)
  ['sub'                     , '$Wd, $Wn, #imm, {LSL #amount*12}'       , 'A64: 0101|0001|amount:2|imm:12|Wn:5|Wd:5'                                       , 'group=3 base' ],
  ['sub'                     , '$Xd, $Xn, #imm, {LSL #amount*12}'       , 'A64: 1101|0001|amount:2|imm:12|Xn:5|Xd:5'                                       , 'group=3 base' ],

  # => SUB (shifted register)
  ['sub'                     , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0100|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=36 base' ],
  ['sub'                     , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1100|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=36 base' ],

  # => SUBS (extended register)
  ['subs'                    , 'Wd, $Wn, Wm, {extend {#amount}}'        , 'A64: 0110|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                            , 'group=35 flags.nzcv=WWWW base' ],
  ['subs'                    , 'Xd, $Xn, R.m, {extend {#amount}}'       , 'A64: 1110|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                           , 'group=35 flags.nzcv=WWWW base' ],

  # => SUBS (immediate)
  ['subs'                    , 'Wd, $Wn, #imm, {LSL #amount*12}'        , 'A64: 0111|0001|amount:2|imm:12|Wn:5|Wd:5'                                       , 'group=3 flags.nzcv=WWWW base' ],
  ['subs'                    , 'Xd, $Xn, #imm, {LSL #amount*12}'        , 'A64: 1111|0001|amount:2|imm:12|Xn:5|Xd:5'                                       , 'group=3 flags.nzcv=WWWW base' ],

  # => SUBS (shifted register)
  ['subs'                    , 'Wd, Wn, Wm, {shift #amount}'            , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                               , 'group=36 flags.nzcv=WWWW base' ],
  ['subs'                    , 'Xd, Xn, Xm, {shift #amount}'            , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                               , 'group=36 flags.nzcv=WWWW base' ],

  # => SVC
  ['svc'                     , '#imm'                                   , 'A64: 1101|0100|000|imm:16|0000|1'                                               , 'group=12 base' ],

  # => SXTB
  ['sxtb'                    , 'Wd, Wn'                                 , 'A64: 0001|0011|0000|0000|0001|11|Wn:5|Wd:5'                                     , 'group=4 aliasOf=sbfm preferredIf=always base' ],
  ['sxtb'                    , 'Xd, Wn'                                 , 'A64: 1001|0011|0100|0000|0001|11|Wn:5|Xd:5'                                     , 'group=4 aliasOf=sbfm preferredIf=always base' ],

  # => SXTH
  ['sxth'                    , 'Wd, Wn'                                 , 'A64: 0001|0011|0000|0000|0011|11|Wn:5|Wd:5'                                     , 'group=4 aliasOf=sbfm preferredIf=always base' ],
  ['sxth'                    , 'Xd, Wn'                                 , 'A64: 1001|0011|0100|0000|0011|11|Wn:5|Xd:5'                                     , 'group=4 aliasOf=sbfm preferredIf=always base' ],

  # => SXTW
  ['sxtw'                    , 'Xd, Wn'                                 , 'A64: 1001|0011|0100|0000|0111|11|Wn:5|Xd:5'                                     , 'group=4 aliasOf=sbfm preferredIf=always base' ],

  # => SYS
  ['sys'                     , '#op1, Cn, Cm, #op2, {Xt}'               , 'A64: 1101|0101|0000|1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                               , 'group=13 base' ],

  # => SYSL
  ['sysl'                    , 'Xt, #op1, Cn, Cm, #op2'                 , 'A64: 1101|0101|0010|1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                               , 'group=13 base' ],

  # => TBNZ
  ['tbnz'                    , 'R.t, #imm, rel*4'                       , 'A64: R/imm:1|0110|111|imm:5|rel:14|t:5'                                         , 'group=14 base' ],

  # => TBZ
  ['tbz'                     , 'R.t, #imm, rel*4'                       , 'A64: R/imm:1|0110|110|imm:5|rel:14|t:5'                                         , 'group=14 base' ],

  # => TLBI
  ['tlbi'                    , 'tlbi_op, {Xt}'                          , 'A64: 1101|0101|0000|1|tlbi_op:3|1000|tlbi_op:4|tlbi_op:3|Xt:5'                  , 'group=13 aliasOf=sys preferredIf=SysOp(tlbi_op.A,1000,tlbi_op.B,tlbi_op.C)==Sys_TLBI base' ],

  # => TST (immediate)
  ['tst'                     , 'Wn, #bimm'                              , 'A64: 0111|0010|0|N=0|immr:6|imms:6|Wn:5|1111|1'                                 , 'group=6 aliasOf=ands preferredIf=always flags.nzcv=WWWW base' ],
  ['tst'                     , 'Xn, #bimm'                              , 'A64: 1111|0010|0|N|immr:6|imms:6|Xn:5|1111|1'                                   , 'group=6 aliasOf=ands preferredIf=always flags.nzcv=WWWW base' ],

  # => TST (shifted register)
  ['tst'                     , 'Wn, Wm, {shift #amount}'                , 'A64: 0110|1010|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                             , 'group=44 aliasOf=ands preferredIf=always flags.nzcv=WWWW base' ],
  ['tst'                     , 'Xn, Xm, {shift #amount}'                , 'A64: 1110|1010|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                             , 'group=44 aliasOf=ands preferredIf=always flags.nzcv=WWWW base' ],

  # => UBFIZ
  ['ubfiz'                   , 'Wd, Wn, #lsb, #width'                   , 'A64: 0101|0011|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=4 aliasOf=ubfm preferredIf=UInt(imms)<UInt(immr) base' ],
  ['ubfiz'                   , 'Xd, Xn, #lsb, #width'                   , 'A64: 1101|0011|0|N=1|immr:6|imms:6|Xn:5|Xd:5'                                   , 'group=4 aliasOf=ubfm preferredIf=UInt(imms)<UInt(immr) base' ],

  # => UBFM
  ['ubfm'                    , 'Wd, Wn, #immr, #imms'                   , 'A64: 0101|0011|0|N=0|immr:6|imms:6|Wn:5|Wd:5'                                   , 'group=4 base' ],
  ['ubfm'                    , 'Xd, Xn, #immr, #imms'                   , 'A64: 1101|0011|0|N=1|immr:6|imms:6|Xn:5|Xd:5'                                   , 'group=4 base' ],

  # => UBFX
  ['ubfx'                    , 'Wd, Wn, #lsb, #width'                   , 'A64: sf=0|opc=10|1001|10|N=0|immr:6|imms:6|Wn:5|Wd:5'                           , 'group=4 aliasOf=ubfm preferredIf=BFXPreferred(sf,opc[1],imms,immr) base' ],
  ['ubfx'                    , 'Xd, Xn, #lsb, #width'                   , 'A64: sf=1|opc=10|1001|10|N=1|immr:6|imms:6|Xn:5|Xd:5'                           , 'group=4 aliasOf=ubfm preferredIf=BFXPreferred(sf,opc[1],imms,immr) base' ],

  # => UDIV
  ['udiv'                    , 'Wd, Wn, Wm'                             , 'A64: 0001|1010|110|Wm:5|0000|10|Wn:5|Wd:5'                                      , 'group=42 base' ],
  ['udiv'                    , 'Xd, Xn, Xm'                             , 'A64: 1001|1010|110|Xm:5|0000|10|Xn:5|Xd:5'                                      , 'group=42 base' ],

  # => UMADDL
  ['umaddl'                  , 'Xd, Wn, Wm, Xa'                         , 'A64: 1001|1011|101|Wm:5|0|Xa:5|Wn:5|Xd:5'                                       , 'group=43 base' ],

  # => UMNEGL
  ['umnegl'                  , 'Xd, Wn, Wm'                             , 'A64: 1001|1011|101|Wm:5|1111|11|Wn:5|Xd:5'                                      , 'group=43 aliasOf=umsubl preferredIf=always base' ],

  # => UMSUBL
  ['umsubl'                  , 'Xd, Wn, Wm, Xa'                         , 'A64: 1001|1011|101|Wm:5|1|Xa:5|Wn:5|Xd:5'                                       , 'group=43 base' ],

  # => UMULH
  ['umulh'                   , 'Xd, Xn, Xm'                             , 'A64: 1001|1011|110|Xm:5|0111|11|Xn:5|Xd:5'                                      , 'group=43 base' ],

  # => UMULL
  ['umull'                   , 'Xd, Wn, Wm'                             , 'A64: 1001|1011|101|Wm:5|0111|11|Wn:5|Xd:5'                                      , 'group=43 aliasOf=umaddl preferredIf=always base' ],

  # => UXTB
  ['uxtb'                    , 'Wd, Wn'                                 , 'A64: 0101|0011|0000|0000|0001|11|Wn:5|Wd:5'                                     , 'group=4 aliasOf=ubfm preferredIf=always base' ],

  # => UXTH
  ['uxth'                    , 'Wd, Wn'                                 , 'A64: 0101|0011|0000|0000|0011|11|Wn:5|Wd:5'                                     , 'group=4 aliasOf=ubfm preferredIf=always base' ],

  # => WFE
  ['wfe'                     , ''                                       , 'A64: 1101|0101|0000|0011|0010|0000|0101|1111'                                   , 'group=13 base' ],

  # => WFI
  ['wfi'                     , ''                                       , 'A64: 1101|0101|0000|0011|0010|0000|0111|1111'                                   , 'group=13 base' ],

  # => YIELD
  ['yield'                   , ''                                       , 'A64: 1101|0101|0000|0011|0010|0000|0011|1111'                                   , 'group=13 base' ],


);
