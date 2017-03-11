# ===>                          ARM instruction set                        <===

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

# MNEMONIC
# ========
# Instruction mnemonic:
#   - %c = specifies the condition under which the instruction is executed.
#   - %q = optional assembler qualifiers.
#   - %X = depends on instruction !

# OPERANDS
# ========
# Instruction operands. I used same representation found in ARM doc.
#   - .c = ExpandImm with carry. 
#   - .s = SignExtend.
#   - .x = ExpandImm.
#   - .z = ZeroExtend.

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
 
 
# Page's title was added just for bugs tracking ! 

my $locked = 1;  # Don't edit instructions until ($locked == 0) !

warn "Work still in progress and data may contain some bugs.\n";

my @instructions = (

  # ===>                     AArch32.Base instructions                     <===

  # ADC, ADCS (immediate)
  ['adc{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1010|0|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['adcs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1010|1|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['adc{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|101|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['adcs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|101|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # ADC, ADCS (register)
  ['adc%c{%q}'         , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0101|Rm:3|Rdn:3'                                                   , ''  ],
  ['adcs{%q}'          , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0101|Rm:3|Rdn:3'                                                   , ''  ],
  ['adc{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1010|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['adc%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1010|0|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['adc{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1010|0|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['adcs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1010|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['adcs.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1010|1|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['adcs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1010|1|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['adc{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|101|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['adc{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|101|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['adcs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|101|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['adcs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|101|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # ADC, ADCS (register-shifted register)
  ['adcs{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|101|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['adc{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|101|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # ADD, ADDS (immediate)
  ['add%c{%q}'         , 'Rd, Rn, #imm.z'                        , 'T16: 000111|0|imm:3|Rn:3|Rd:3'                                                 , ''  ],
  ['adds{%q}'          , 'Rd, Rn, #imm.z'                        , 'T16: 000111|0|imm:3|Rn:3|Rd:3'                                                 , ''  ],
  ['add%c{%q}'         , 'Rdn, #imm.z'                           , 'T16: 001|10|Rdn:3|imm:8'                                                       , ''  ],
  ['add%c{%q}'         , '{Rdn,} Rdn, #imm.z'                    , 'T16: 001|10|Rdn:3|imm:8'                                                       , ''  ],
  ['adds{%q}'          , 'Rdn, #imm.z'                           , 'T16: 001|10|Rdn:3|imm:8'                                                       , ''  ],
  ['adds{%q}'          , '{Rdn,} Rdn, #imm.z'                    , 'T16: 001|10|Rdn:3|imm:8'                                                       , ''  ],
  ['add%c.W'           , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|0|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|0|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['adds.W'            , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|1|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|1|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, #imm.z'                      , 'T32: 11110|imm:1|10|0|0|0|0|Rn!=11x1|0|imm:3|Rd:4|imm:8'                       , ''  ],
  ['addw{%c}{%q}'      , '{Rd,} Rn, #imm.z'                      , 'T32: 11110|imm:1|10|0|0|0|0|Rn!=11x1|0|imm:3|Rd:4|imm:8'                       , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|100|0|Rn!=11x1|Rd:4|cnst:12'                              , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|100|1|Rn!=1101|Rd:4|cnst:12'                              , ''  ],

  # ADD, ADDS (register)
  ['add%c{%q}'         , 'Rd, Rn, Rm'                            , 'T16: 000110|0|Rm:3|Rn:3|Rd:3'                                                  , ''  ],
  ['adds{%q}'          , '{Rd,} Rn, Rm'                          , 'T16: 000110|0|Rm:3|Rn:3|Rd:3'                                                  , ''  ],
  ['add%c{%q}'         , 'Rdn, Rm'                               , 'T16: 010001|00|Rdn!=1|Rm!=1101|Rdn!=101'                                       , ''  ],
  ['add{%c}{%q}'       , '{Rdn,} Rdn, Rm'                        , 'T16: 010001|00|Rdn!=1|Rm!=1101|Rdn!=101'                                       , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1000|0|Rn!=1101|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['add%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1000|0|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['add{%c}.W'         , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1000|0|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1000|0|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1000|1|Rn!=1101|0|000|Rd!=1111|00|11|Rm:4'                        , ''  ],
  ['adds.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1000|1|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'      , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1000|1|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4' , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|100|0|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|100|0|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'       , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|100|1|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|100|1|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'       , ''  ],

  # ADD, ADDS (register-shifted register)
  ['adds{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|100|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['add{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|100|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # ADD, ADDS (SP plus immediate)
  ['add{%c}{%q}'       , 'Rd, SP, #imm.z*4'                      , 'T16: 1010|1|Rd:3|imm:8'                                                        , ''  ],
  ['add{%c}{%q}'       , '{SP,} SP, #imm.z*4'                    , 'T16: 10110000|0|imm:7'                                                         , ''  ],
  ['add{%c}.W'         , '{Rd,} SP, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|0|1101|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|0|1101|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} SP, #cnst.x'                     , 'T32: 11110|cnst:1|0|1000|1|1101|0|cnst:3|Rd!=1111|cnst:8'                      , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, #imm.z'                      , 'T32: 11110|imm:1|10|0|0|0|0|1101|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['addw{%c}{%q}'      , '{Rd,} SP, #imm.z'                      , 'T32: 11110|imm:1|10|0|0|0|0|1101|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, #cnst.x'                     , 'A32: cond!=1111|0010|100|0|1101|Rd:4|cnst:12'                                  , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} SP, #cnst.x'                     , 'A32: cond!=1111|0010|100|1|1101|Rd:4|cnst:12'                                  , ''  ],

  # ADD, ADDS (SP plus register)
  ['add{%c}{%q}'       , '{Rdm,} SP, Rdm'                        , 'T16: 010001|00|DM:1|1101|Rdm:3'                                                , ''  ],
  ['add{%c}{%q}'       , '{SP,} SP, Rm'                          , 'T16: 010001|00|1|Rm!=1101|101'                                                 , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, Rm, RRX'                     , 'T32: 1110101|1000|0|1101|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['add{%c}.W'         , '{Rd,} SP, Rm'                          , 'T32: 1110101|1000|0|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, Rm {, shift #amount}'        , 'T32: 1110101|1000|0|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} SP, Rm, RRX'                     , 'T32: 1110101|1000|1|1101|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} SP, Rm {, shift #amount}'        , 'T32: 1110101|1000|1|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, Rm , RRX'                    , 'A32: cond!=1111|0000|100|0|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['add{%c}{%q}'       , '{Rd,} SP, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|100|0|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} SP, Rm , RRX'                    , 'A32: cond!=1111|0000|100|1|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['adds{%c}{%q}'      , '{Rd,} SP, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|100|1|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # ADD (immediate, to PC)
  ['add{%c}{%q}'       , 'Rd, PC, #imm.z*4'                      , 'T16: 1010|0|Rd:3|imm:8'                                                        , ''  ],
  ['addw{%c}{%q}'      , 'Rd, PC, #imm.z'                        , 'T32: 11110|imm:1|10|0|0|0|0|1111|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['add{%c}{%q}'       , 'Rd, PC, #imm.z'                        , 'T32: 11110|imm:1|10|0|0|0|0|1111|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['add{%c}{%q}'       , 'Rd, PC, #cnst.x'                       , 'A32: cond!=1111|0010|100|0|1111|Rd:4|cnst:12'                                  , ''  ],

  # ADR
  ['adr{%c}{%q}'       , 'Rd, rel.z*4'                           , 'T16: 1010|0|Rd:3|rel:8'                                                        , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.z'                             , 'T32: 11110|rel:1|10|1|0|1|0|1111|0|rel:3|Rd:4|rel:8'                           , ''  ],
  ['adr{%c}.W'         , 'Rd, rel.z'                             , 'T32: 11110|rel:1|10|0|0|0|0|1111|0|rel:3|Rd:4|rel:8'                           , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.z'                             , 'T32: 11110|rel:1|10|0|0|0|0|1111|0|rel:3|Rd:4|rel:8'                           , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.x'                             , 'A32: cond!=1111|0010|100|0|1111|Rd:4|rel:12'                                   , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.x'                             , 'A32: cond!=1111|0010|010|0|1111|Rd:4|rel:12'                                   , ''  ],

  # AND, ANDS (immediate)
  ['and{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0000|0|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['ands{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0000|1|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                      , ''  ],
  ['and{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|0010|000|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['ands{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|0010|000|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # AND, ANDS (register)
  ['and%c{%q}'         , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0000|Rm:3|Rdn:3'                                                   , ''  ],
  ['ands{%q}'          , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0000|Rm:3|Rdn:3'                                                   , ''  ],
  ['and{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0000|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['and%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0000|0|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['and{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0000|0|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['ands{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0000|1|Rn:4|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['ands.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0000|1|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['ands{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0000|1|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['and{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|000|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['and{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|000|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['ands{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|000|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['ands{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|000|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # AND, ANDS (register-shifted register)
  ['ands{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|000|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['and{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|000|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # ASR (immediate)
  ['asr%c{%q}'         , '{Rd,} Rm, #imm'                        , 'T16: 000|10|imm:5|Rm:3|Rd:3'                                                   , ''  ],
  ['asr%c.W'           , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , ''  ],
  ['asr{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , ''  ],
  ['asr{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|0|0000|Rd:4|imm:5|10|0|Rm:4'                          , ''  ],

  # ASR (register)
  ['asr%c{%q}'         , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , ''  ],
  ['asr%c.W'           , '{Rd,} Rm, Rs'                          , 'T32: 111110100|10|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asr{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'T32: 111110100|10|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asr{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|10|1|Rm:4'                         , ''  ],

  # ASRS (immediate)
  ['asrs{%q}'          , '{Rd,} Rm, #imm'                        , 'T16: 000|10|imm:5|Rm:3|Rd:3'                                                   , ''  ],
  ['asrs.W'            , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , ''  ],
  ['asrs{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , ''  ],
  ['asrs{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|1|0000|Rd:4|imm:5|10|0|Rm:4'                          , ''  ],

  # ASRS (register)
  ['asrs{%q}'          , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , ''  ],
  ['asrs.W'            , '{Rd,} Rm, Rs'                          , 'T32: 111110100|10|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asrs{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'T32: 111110100|10|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asrs{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|10|1|Rm:4'                         , ''  ],

  # B
  ['b%c{%q}'           , 'rel.s*2'                               , 'T16: 1101|cond!=111x|rel:8'                                                    , ''  ],
  ['b{%c}{%q}'         , 'rel.s*2'                               , 'T16: 11100|rel:11'                                                             , ''  ],
  ['b%c.W'             , 'rel.s*2'                               , 'T32: 11110|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'           , ''  ],
  ['b%c{%q}'           , 'rel.s*2'                               , 'T32: 11110|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'           , ''  ],
  ['b{%c}.W'           , 'rel.s*2'                               , 'T32: 11110|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                           , ''  ],
  ['b{%c}{%q}'         , 'rel.s*2'                               , 'T32: 11110|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                           , ''  ],
  ['b{%c}{%q}'         , 'rel.s*4'                               , 'A32: cond!=1111|101|0|rel:24'                                                  , ''  ],

  # BFC
  ['bfc{%c}{%q}'       , 'Rd, #lsb, #width'                      , 'T32: 11110|0|11|01|1|0|1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                      , ''  ],
  ['bfc{%c}{%q}'       , 'Rd, #lsb, #width'                      , 'A32: cond!=1111|0111110|width:5|Rd:4|lsb:5|001|1111'                           , ''  ],

  # BFI
  ['bfi{%c}{%q}'       , 'Rd, Rn, #lsb, #width'                  , 'T32: 11110|0|11|01|1|0|Rn!=1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                  , ''  ],
  ['bfi{%c}{%q}'       , 'Rd, Rn, #lsb, #width'                  , 'A32: cond!=1111|0111110|width:5|Rd:4|lsb:5|001|Rn!=1111'                       , ''  ],

  # BIC, BICS (immediate)
  ['bic{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0001|0|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['bics{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0001|1|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['bic{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|00111|10|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['bics{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|00111|10|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # BIC, BICS (register)
  ['bic%c{%q}'         , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|1110|Rm:3|Rdn:3'                                                   , ''  ],
  ['bics{%q}'          , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|1110|Rm:3|Rdn:3'                                                   , ''  ],
  ['bic{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0001|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['bic%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0001|0|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['bic{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0001|0|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['bics{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0001|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['bics.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0001|1|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['bics{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0001|1|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['bic{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|00011|10|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['bic{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|00011|10|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['bics{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|00011|10|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['bics{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|00011|10|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # BIC, BICS (register-shifted register)
  ['bics{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|00011|10|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['bic{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|00011|10|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # BKPT
  ['bkpt{%q}'          , '{#}imm.z'                              , 'T16: 10111110|imm:8'                                                           , ''  ],
  ['bkpt{%q}'          , '{#}imm'                                , 'A32: cond!=1111|00010|01|0|imm:12|0111|imm:4'                                  , ''  ],

  # BL, BLX (immediate)
  ['bl{%c}{%q}'        , 'rel.s*2'                               , 'T32: 11110|rel.A:1|rel.D:10|11|J1:1|1|J2:1|rel.E:11'                           , ''  ],
  ['blx{%c}{%q}'       , 'rel.s*4'                               , 'T32: 11110|rel.A:1|rel.D:10|11|J1:1|0|J2:1|rel.E:10|H'                         , ''  ],
  ['bl{%c}{%q}'        , 'rel.s*4'                               , 'A32: cond!=1111|101|1|rel:24'                                                  , ''  ],
  ['blx{%c}{%q}'       , 'rel.s*2'                               , 'A32: 1111|101|rel.B:1|rel.A:24'                                                , ''  ],

  # BLX (register)
  ['blx{%c}{%q}'       , 'Rm'                                    , 'T16: 01000111|1|Rm:4|0|0|0'                                                    , ''  ],
  ['blx{%c}{%q}'       , 'Rm'                                    , 'A32: cond!=1111|00010010|1|1|1|1|1|1|1|1|1|1|1|1|0011|Rm:4'                    , ''  ],

  # BX
  ['bx{%c}{%q}'        , 'Rm'                                    , 'T16: 01000111|0|Rm:4|0|0|0'                                                    , ''  ],
  ['bx{%c}{%q}'        , 'Rm'                                    , 'A32: cond!=1111|00010010|1|1|1|1|1|1|1|1|1|1|1|1|0001|Rm:4'                    , ''  ],

  # BXJ
  ['bxj{%c}{%q}'       , 'Rm'                                    , 'T32: 111100111100|Rm:4|10|0|0|1|1|1|1|0|0|0|0|0|0|0|0'                         , ''  ],
  ['bxj{%c}{%q}'       , 'Rm'                                    , 'A32: cond!=1111|00010010|1|1|1|1|1|1|1|1|1|1|1|1|0010|Rm:4'                    , ''  ],

  # CBNZ, CBZ
  ['cbnz{%q}'          , 'Rn, rel.z*2'                           , 'T16: 1011|1|0|rel:1|1|rel:5|Rn:3'                                              , ''  ],
  ['cbz{%q}'           , 'Rn, rel.z*2'                           , 'T16: 1011|0|0|rel:1|1|rel:5|Rn:3'                                              , ''  ],

  # CLREX
  ['clrex{%c}{%q}'     , ''                                      , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0010|1111'                            , ''  ],
  ['clrex{%c}{%q}'     , ''                                      , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0001|1111'                           , ''  ],

  # CLZ
  ['clz{%c}{%q}'       , 'Rd, Rm'                                , 'T32: 111110101|011|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['clz{%c}{%q}'       , 'Rd, Rm'                                , 'A32: cond!=1111|00010110|1|1|1|1|Rd:4|1|1|1|1|0001|Rm:4'                       , ''  ],

  # CMN (immediate)
  ['cmn{%c}{%q}'       , 'Rn, #cnst.x'                           , 'T32: 11110|cnst:1|0|1000|1|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, #cnst.x'                           , 'A32: cond!=1111|00110|11|1|Rn:4|0|0|0|0|cnst:12'                               , ''  ],

  # CMN (register)
  ['cmn{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 010000|1011|Rm:3|Rn:3'                                                    , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110101|1000|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['cmn{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110101|1000|1|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'T32: 1110101|1000|1|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|00010|11|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'A32: cond!=1111|00010|11|1|Rn:4|0|0|0|0|amount!=00000|shift!=11|0|Rm:4'        , ''  ],

  # CMN (register-shifted register)
  ['cmn{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|00010|11|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  # CMP (immediate)
  ['cmp{%c}{%q}'       , 'Rn, #imm.z'                            , 'T16: 001|01|Rn:3|imm:8'                                                        , ''  ],
  ['cmp{%c}.W'         , 'Rn, #cnst.x'                           , 'T32: 11110|cnst:1|0|1101|1|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, #cnst.x'                           , 'T32: 11110|cnst:1|0|1101|1|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, #cnst.x'                           , 'A32: cond!=1111|00110|10|1|Rn:4|0|0|0|0|cnst:12'                               , ''  ],

  # CMP (register)
  ['cmp{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 010000|1010|Rm:3|Rn:3'                                                    , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 010001|01|Rn:1|Rm:3|Rn:4'                                                 , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110101|1101|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['cmp{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110101|1101|1|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, shift #amount'                 , 'T32: 1110101|1101|1|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|00010|10|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'A32: cond!=1111|00010|10|1|Rn:4|0|0|0|0|amount!=00000|shift!=11|0|Rm:4'        , ''  ],

  # CMP (register-shifted register)
  ['cmp{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|00010|10|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  # CPS, CPSID, CPSIE
  ['cpsid{%q}'         , 'iflags'                                , 'T16: 1011011001|1|1|0|A|I|F'                                                   , ''  ],
  ['cpsie{%q}'         , 'iflags'                                , 'T16: 1011011001|1|0|0|A|I|F'                                                   , ''  ],
  ['cps{%q}'           , '#mode'                                 , 'T32: 111100111010|1|1|1|1|10|0|0|0|00|1|A|I|F|mode:5'                          , ''  ],
  ['cpsid.W'           , 'iflags'                                , 'T32: 111100111010|1|1|1|1|10|0|0|0|11|0|A|I|F|mode:5'                          , ''  ],
  ['cpsid{%q}'         , 'iflags, #mode'                         , 'T32: 111100111010|1|1|1|1|10|0|0|0|11|1|A|I|F|mode:5'                          , ''  ],
  ['cpsie.W'           , 'iflags'                                , 'T32: 111100111010|1|1|1|1|10|0|0|0|10|0|A|I|F|mode:5'                          , ''  ],
  ['cpsie{%q}'         , 'iflags, #mode'                         , 'T32: 111100111010|1|1|1|1|10|0|0|0|10|1|A|I|F|mode:5'                          , ''  ],
  ['cps{%q}'           , '#mode'                                 , 'A32: 111100010000|00|1|0|0|0|0|0|0|0|0|A|I|F|0|mode:5'                         , ''  ],
  ['cpsid{%q}'         , 'iflags'                                , 'A32: 111100010000|11|0|0|0|0|0|0|0|0|0|A|I|F|0|mode:5'                         , ''  ],
  ['cpsid{%q}'         , 'iflags , #mode'                        , 'A32: 111100010000|11|1|0|0|0|0|0|0|0|0|A|I|F|0|mode:5'                         , ''  ],
  ['cpsie{%q}'         , 'iflags'                                , 'A32: 111100010000|10|0|0|0|0|0|0|0|0|0|A|I|F|0|mode:5'                         , ''  ],
  ['cpsie{%q}'         , 'iflags , #mode'                        , 'A32: 111100010000|10|1|0|0|0|0|0|0|0|0|A|I|F|0|mode:5'                         , ''  ],

  # CRC32
  ['crc32b{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|0|Rn:4|1111|Rd:4|10|00|Rm:4'                                 , ''  ],
  ['crc32h{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|0|Rn:4|1111|Rd:4|10|01|Rm:4'                                 , ''  ],
  ['crc32w{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|0|Rn:4|1111|Rd:4|10|10|Rm:4'                                 , ''  ],
  ['crc32b{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|00010|00|0|Rn:4|Rd:4|0|0|0|0|0100|Rm:4'                        , ''  ],
  ['crc32h{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|00010|01|0|Rn:4|Rd:4|0|0|0|0|0100|Rm:4'                        , ''  ],
  ['crc32w{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|00010|10|0|Rn:4|Rd:4|0|0|0|0|0100|Rm:4'                        , ''  ],

  # CRC32C
  ['crc32cb{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|1|Rn:4|1111|Rd:4|10|00|Rm:4'                                 , ''  ],
  ['crc32ch{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|1|Rn:4|1111|Rd:4|10|01|Rm:4'                                 , ''  ],
  ['crc32cw{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|1|Rn:4|1111|Rd:4|10|10|Rm:4'                                 , ''  ],
  ['crc32cb{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|00010|00|0|Rn:4|Rd:4|0|0|1|0|0100|Rm:4'                        , ''  ],
  ['crc32ch{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|00010|01|0|Rn:4|Rd:4|0|0|1|0|0100|Rm:4'                        , ''  ],
  ['crc32cw{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|00010|10|0|Rn:4|Rd:4|0|0|1|0|0100|Rm:4'                        , ''  ],

  # DBG
  ['dbg{%c}{%q}'       , '#option'                               , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|1111|option:4'                          , ''  ],
  ['dbg{%c}{%q}'       , '#option'                               , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|00001111|option:4'                    , ''  ],

  # DCPS1, DCPS2, DCPS3
  ['dcps1'             , ''                                      , 'T32: 111101111000|1111|1000|0000000000|01'                                     , ''  ],
  ['dcps2'             , ''                                      , 'T32: 111101111000|1111|1000|0000000000|10'                                     , ''  ],
  ['dcps3'             , ''                                      , 'T32: 111101111000|1111|1000|0000000000|11'                                     , ''  ],

  # DMB
  ['dmb{%c}{%q}'       , '{option}'                              , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0101|option:4'                        , ''  ],
  ['dmb{%c}{%q}'       , '{option}'                              , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0101|option:4'                       , ''  ],

  # DSB
  ['dsb{%c}{%q}'       , '{option}'                              , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0100|option:4'                        , ''  ],
  ['dsb{%c}{%q}'       , '{option}'                              , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0100|option:4'                       , ''  ],

  # EOR, EORS (immediate)
  ['eor{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0100|0|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['eors{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0100|1|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                      , ''  ],
  ['eor{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|0010|001|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['eors{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|0010|001|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # EOR, EORS (register)
  ['eor%c{%q}'         , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0001|Rm:3|Rdn:3'                                                   , ''  ],
  ['eors{%q}'          , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0001|Rm:3|Rdn:3'                                                   , ''  ],
  ['eor{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0100|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['eor%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0100|0|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['eor{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0100|0|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['eors{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0100|1|Rn:4|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['eors.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0100|1|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['eors{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0100|1|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['eor{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|001|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['eor{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|001|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['eors{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|001|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['eors{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|001|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # EOR, EORS (register-shifted register)
  ['eors{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|001|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['eor{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|001|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # ERET
  ['eret{%c}{%q}'      , ''                                      , 'T32: 111100111101|1110|10|0|0|1|1|1|1|00000000'                                , ''  ],
  ['eret{%c}{%q}'      , ''                                      , 'A32: cond!=1111|00010110|0|0|0|0|0|0|0|0|0|0|0|0|0110|1|1|1|0'                 , ''  ],

  # HLT
  ['hlt{%q}'           , '{#}imm'                                , 'T16: 1011101010|imm:6'                                                         , ''  ],
  ['hlt{%q}'           , '{#}imm'                                , 'A32: cond!=1111|00010|00|0|imm:12|0111|imm:4'                                  , ''  ],

  # HVC
  ['hvc{%q}'           , '{#}imm'                                , 'T32: 11110111111|0|imm:4|10|0|0|imm:12'                                        , ''  ],
  ['hvc{%q}'           , '{#}imm'                                , 'A32: cond!=1111|00010|10|0|imm:12|0111|imm:4'                                  , ''  ],

  # ISB
  ['isb{%c}{%q}'       , '{option}'                              , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0110|option:4'                        , ''  ],
  ['isb{%c}{%q}'       , '{option}'                              , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0110|option:4'                       , ''  ],

  # IT
  ['it{%x{%y{%z}}}{%q}', 'cond'                                  , 'T16: 10111111|cond:4|x/y/z!=0000'                                              , ''  ],

  # LDA
  ['lda{%c}{%q}'       , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|0|10|1111'                                 , ''  ],
  ['lda{%c}{%q}'       , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|00|1|Rn:4|Rt:4|1|1|0|0|1001|1111'                        , ''  ],

  # LDAB
  ['ldab{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|0|00|1111'                                 , ''  ],
  ['ldab{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|10|1|Rn:4|Rt:4|1|1|0|0|1001|1111'                        , ''  ],

  # LDAEX
  ['ldaex{%c}{%q}'     , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|1|10|1111'                                 , ''  ],
  ['ldaex{%c}{%q}'     , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|00|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  # LDAEXB
  ['ldaexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|1|00|1111'                                 , ''  ],
  ['ldaexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|10|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  # LDAEXD
  ['ldaexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'T32: 11101000110|1|Rn:4|Rt:4|Rt2:4|1|1|11|1111'                                , ''  ],
  ['ldaexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'A32: cond!=1111|00011|01|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  # LDAEXH
  ['ldaexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|1|01|1111'                                 , ''  ],
  ['ldaexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|11|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  # LDAH
  ['ldah{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|0|01|1111'                                 , ''  ],
  ['ldah{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|11|1|Rn:4|Rt:4|1|1|0|0|1001|1111'                        , ''  ],

  # LDC (immediate)
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn{, #{+/-}imm.z*4}]'        , 'T32: 111|0|110|1|U|0|0|1|Rn!=1111|0101|111|0|imm:8'                            , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'T32: 111|0|110|0|U|0|1|1|Rn!=1111|0101|111|0|imm:8'                            , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'T32: 111|0|110|1|U|0|1|1|Rn!=1111|0101|111|0|imm:8'                            , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'T32: 111|0|110|0|1|0|0|1|Rn!=1111|0101|111|0|option:8'                         , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn{, #{+/-}imm.z*4}]'        , 'A32: cond!=1111|110|1|U|0|0|1|Rn!=1111|0101|111|0|imm:8'                       , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'A32: cond!=1111|110|0|U|0|1|1|Rn!=1111|0101|111|0|imm:8'                       , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'A32: cond!=1111|110|1|U|0|1|1|Rn!=1111|0101|111|0|imm:8'                       , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'A32: cond!=1111|110|0|1|0|0|1|Rn!=1111|0101|111|0|option:8'                    , ''  ],

  # LDC (literal)
  ['ldc{%c}{%q}'       , 'p14, c5, rel.z*4'                      , 'T32: 111|0|110|P!=0|U!=0|0|W!=0|1|1111|0101|111|0|rel:8'                       , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC, #{+/-}imm.z*4]'          , 'T32: 111|0|110|P!=0|U!=0|0|W!=0|1|1111|0101|111|0|imm:8'                       , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, rel.z*4'                      , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1|1111|0101|111|0|rel:8'                  , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC, #{+/-}imm.z*4]'          , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1|1111|0101|111|0|imm:8'                  , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC], option'                 , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1|1111|0101|111|0|option:8'               , ''  ],

  # LDM, LDMIA, LDMFD
  ['ldm{IA}{%c}{%q}'   , 'Rn{!}, list'                           , 'T16: 1100|1|Rn:3|list:8'                                                       , ''  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T16: 1100|1|Rn:3|list:8'                                                       , ''  ],
  ['ldm{IA}{%c}.W'     , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmfd{%c}.W'       , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldm{IA}{%c}{%q}'   , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldm{IA}{%c}{%q}'   , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|1|0|W|1|Rn:4|list:16'                                    , ''  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|1|0|W|1|Rn:4|list:16'                                    , ''  ],

  # LDM (exception return)
  ['ldm{%amode}{%c}{%q}', 'Rn{!}, list'                           , 'A32: cond!=1111|100|P|U|1|W|1|Rn:4|1|list:15'                                  , ''  ],

  # LDM (User registers)
  ['ldm{%amode}{%c}{%q}', 'Rn, list'                              , 'A32: cond!=1111|100|P|U|1|0|1|Rn:4|0|list:15'                                  , ''  ],

  # LDMDA, LDMFA
  ['ldmda{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|0|0|W|1|Rn:4|list:16'                                    , ''  ],
  ['ldmfa{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|0|0|W|1|Rn:4|list:16'                                    , ''  ],

  # LDMDB, LDMEA
  ['ldmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110100|10|0|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmea{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110100|10|0|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|0|0|W|1|Rn:4|list:16'                                    , ''  ],
  ['ldmea{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|0|0|W|1|Rn:4|list:16'                                    , ''  ],

  # LDMIB, LDMED
  ['ldmib{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|1|0|W|1|Rn:4|list:16'                                    , ''  ],
  ['ldmed{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|1|0|W|1|Rn:4|list:16'                                    , ''  ],

  # LDR (immediate)
  ['ldr{%c}{%q}'       , 'Rt, [Rn {, #{+}imm.z*4}]'              , 'T16: 011|0|1|imm:5|Rn:3|Rt:3'                                                  , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [SP{, #{+}imm.z*4}]'               , 'T16: 1001|1|Rt:3|imm:8'                                                        , ''  ],
  ['ldr{%c}.W'         , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|10|1|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|10|1|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1|1|0|0|imm:8'                             , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|010|1|U|0|0|1|Rn!=1111|Rt:4|imm:12'                            , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|010|0|U|0|0|1|Rn!=1111|Rt:4|imm:12'                            , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|010|1|U|0|1|1|Rn!=1111|Rt:4|imm:12'                            , ''  ],

  # LDR (literal)
  ['ldr{%c}{%q}'       , 'Rt, rel.z*4'                           , 'T16: 01001|Rt:3|rel:8'                                                         , ''  ],
  ['ldr{%c}.W'         , 'Rt, rel.z'                             , 'T32: 1111100|0|U|10|1|1111|Rt:4|rel:12'                                        , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, rel.z'                             , 'T32: 1111100|0|U|10|1|1111|Rt:4|rel:12'                                        , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111100|0|U|10|1|1111|Rt:4|imm:12'                                        , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, rel.z'                             , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1|1111|Rt:4|rel:12'                          , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1|1111|Rt:4|imm:12'                          , ''  ],

  # LDR (register)
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|0|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldr{%c}.W'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|000000|imm2:2|Rm:4'                        , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|000000|imm:2|Rm:4'                         , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]'  , 'A32: cond!=1111|011|1|U|0|0|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|0|0|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]!' , 'A32: cond!=1111|011|1|U|0|1|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # LDRB (immediate)
  ['ldrb{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T16: 011|1|1|imm:5|Rn:3|Rt:3'                                                  , ''  ],
  ['ldrb{%c}.W'        , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|00|1|Rn!=1111|Rt!=1111|imm:12'                                , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|00|1|Rn!=1111|Rt!=1111|imm:12'                                , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt!=1111|1|1|0|0|imm:8'                         , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|010|1|U|1|0|1|Rn!=1111|Rt:4|imm:12'                            , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|010|0|U|1|0|1|Rn!=1111|Rt:4|imm:12'                            , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|010|1|U|1|1|1|Rn!=1111|Rt:4|imm:12'                            , ''  ],

  # LDRB (literal)
  ['ldrb{%c}{%q}'      , 'Rt, rel.z'                             , 'T32: 1111100|0|U|00|1|1111|Rt!=1111|rel:12'                                    , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111100|0|U|00|1|1111|Rt!=1111|imm:12'                                    , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, rel.z'                             , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1|1111|Rt:4|rel:12'                          , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1|1111|Rt:4|imm:12'                          , ''  ],

  # LDRB (register)
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|1|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrb{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt!=1111|000000|imm2:2|Rm:4'                    , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt!=1111|000000|imm:2|Rm:4'                     , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]'  , 'A32: cond!=1111|011|1|U|1|0|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|1|0|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]!' , 'A32: cond!=1111|011|1|U|1|1|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # LDRBT
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|010|0|U|1|1|1|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|1|1|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # LDRD (immediate)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn {, #{+/-}imm.z*4}]'       , 'T32: 1110100|1|U|1|0|1|Rn!=1111|Rt:4|Rt2:4|imm:8'                              , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z*4'          , 'T32: 1110100|0|U|1|1|1|Rn!=1111|Rt:4|Rt2:4|imm:8'                              , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110100|1|U|1|1|1|Rn!=1111|Rt:4|Rt2:4|imm:8'                              , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn {, #{+/-}imm.z}]'         , 'A32: cond!=1111|000|1|U|1|0|0|Rn!=1111|Rt:4|imm:4|1|10|1|imm:4'                , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z'            , 'A32: cond!=1111|000|0|U|1|0|0|Rn!=1111|Rt:4|imm:4|1|10|1|imm:4'                , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z]!'           , 'A32: cond!=1111|000|1|U|1|1|0|Rn!=1111|Rt:4|imm:4|1|10|1|imm:4'                , ''  ],

  # LDRD (literal)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, rel.z*4'                      , 'T32: 1110100|P!=0|U|1|W!=0|1|1111|Rt:4|Rt2:4|rel:8'                            , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [PC, #{+/-}imm.z]'            , 'T32: 1110100|P!=0|U|1|W!=0|1|1111|Rt:4|Rt2:4|imm:8'                            , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, rel.z'                        , 'A32: cond!=1111|000|1|U|1|0|0|1111|Rt:4|rel:4|1|10|1|rel:4'                    , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [PC, #{+/-}imm.z]'            , 'A32: cond!=1111|000|1|U|1|0|0|1111|Rt:4|imm:4|1|10|1|imm:4'                    , ''  ],

  # LDRD (register)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]'                , 'A32: cond!=1111|000|1|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], {+/-}Rm'                , 'A32: cond!=1111|000|0|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]!'               , 'A32: cond!=1111|000|1|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],

  # LDREX
  ['ldrex{%c}{%q}'     , 'Rt, [Rn {, #imm.z*4}]'                 , 'T32: 11101000010|1|Rn:4|Rt:4|1111|imm:8'                                       , ''  ],
  ['ldrex{%c}{%q}'     , 'Rt, [Rn {, {#}imm}]'                   , 'A32: cond!=1111|00011|00|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  # LDREXB
  ['ldrexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|01|00|1111'                                  , ''  ],
  ['ldrexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|10|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  # LDREXD
  ['ldrexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'T32: 11101000110|1|Rn:4|Rt:4|Rt2:4|01|11|1111'                                 , ''  ],
  ['ldrexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'A32: cond!=1111|00011|01|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  # LDREXH
  ['ldrexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|01|01|1111'                                  , ''  ],
  ['ldrexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|11|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  # LDRH (immediate)
  ['ldrh{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z*2}]'              , 'T16: 1000|1|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['ldrh{%c}.W'        , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|01|1|Rn!=1111|Rt!=1111|imm:12'                                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|01|1|Rn!=1111|Rt!=1111|imm:12'                                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt!=1111|1|1|0|0|imm:8'                         , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|000|1|U|1|0|1|Rn!=1111|Rt:4|imm:4|1|01|1|imm:4'                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|000|0|U|1|0|1|Rn!=1111|Rt:4|imm:4|1|01|1|imm:4'                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|000|1|U|1|1|1|Rn!=1111|Rt:4|imm:4|1|01|1|imm:4'                , ''  ],

  # LDRH (literal)
  ['ldrh{%c}{%q}'      , 'Rt, rel.z'                             , 'T32: 1111100|0|U|01|1|1111|Rt!=1111|rel:12'                                    , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111100|0|U|01|1|1111|Rt!=1111|imm:12'                                    , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1|1111|Rt:4|rel:4|1|01|1|rel:4'              , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1|1111|Rt:4|imm:4|1|01|1|imm:4'              , ''  ],

  # LDRH (register)
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|0|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrh{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt!=1111|000000|imm2:2|Rm:4'                    , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt!=1111|000000|imm:2|Rm:4'                     , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|000|1|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|000|1|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  # LDRHT
  ['ldrht{%c}{%q}'     , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['ldrht{%c}{%q}'     , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|000|0|U|1|1|1|Rn:4|Rt:4|imm:4|1|01|1|imm:4'                    , ''  ],
  ['ldrht{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  # LDRSB (immediate)
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|1|1|00|1|Rn!=1111|Rt!=1111|imm:12'                                , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1|1|0|0|imm:8'                             , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|000|1|U|1|0|1|Rn!=1111|Rt:4|imm:4|1|10|1|imm:4'                , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|000|0|U|1|0|1|Rn!=1111|Rt:4|imm:4|1|10|1|imm:4'                , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|000|1|U|1|1|1|Rn!=1111|Rt:4|imm:4|1|10|1|imm:4'                , ''  ],

  # LDRSB (literal)
  ['ldrsb{%c}{%q}'     , 'Rt, rel.z'                             , 'T32: 1111100|1|U|00|1|1111|Rt!=1111|rel:12'                                    , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111100|1|U|00|1|1111|Rt!=1111|imm:12'                                    , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1|1111|Rt:4|rel:4|1|10|1|rel:4'              , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1|1111|Rt:4|imm:4|1|10|1|imm:4'              , ''  ],

  # LDRSB (register)
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|1|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrsb{%c}.W'       , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt!=1111|000000|imm2:2|Rm:4'                    , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt!=1111|000000|imm:2|Rm:4'                     , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|000|1|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|000|1|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],

  # LDRSBT
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|000|0|U|1|1|1|Rn:4|Rt:4|imm:4|1|10|1|imm:4'                    , ''  ],
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],

  # LDRSH (immediate)
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|1|1|01|1|Rn!=1111|Rt!=1111|imm:12'                                , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt!=1111|1|1|0|0|imm:8'                         , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|000|1|U|1|0|1|Rn!=1111|Rt:4|imm:4|1|11|1|imm:4'                , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|000|0|U|1|0|1|Rn!=1111|Rt:4|imm:4|1|11|1|imm:4'                , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|000|1|U|1|1|1|Rn!=1111|Rt:4|imm:4|1|11|1|imm:4'                , ''  ],

  # LDRSH (literal)
  ['ldrsh{%c}{%q}'     , 'Rt, rel.z'                             , 'T32: 1111100|1|U|01|1|1111|Rt!=1111|rel:12'                                    , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111100|1|U|01|1|1111|Rt!=1111|imm:12'                                    , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1|1111|Rt:4|rel:4|1|11|1|rel:4'              , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1|1111|Rt:4|imm:4|1|11|1|imm:4'              , ''  ],

  # LDRSH (register)
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|1|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrsh{%c}.W'       , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt!=1111|000000|imm2:2|Rm:4'                    , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt!=1111|000000|imm:2|Rm:4'                     , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|000|1|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|000|1|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],

  # LDRSHT
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|000|0|U|1|1|1|Rn:4|Rt:4|imm:4|1|11|1|imm:4'                    , ''  ],
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],

  # LDRT
  ['ldrt{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['ldrt{%c}{%q}'      , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|010|0|U|0|1|1|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['ldrt{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|0|1|1|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # LSL (immediate)
  ['lsl%c{%q}'         , '{Rd,} Rm, #imm'                        , 'T16: 000|00|imm!=00000|Rm:3|Rd:3'                                              , ''  ],
  ['lsl%c.W'           , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , ''  ],
  ['lsl{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , ''  ],
  ['lsl{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|0|0000|Rd:4|imm!=00000|00|0|Rm:4'                     , ''  ],

  # LSL (register)
  ['lsl%c{%q}'         , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , ''  ],
  ['lsl%c.W'           , '{Rd,} Rm, Rs'                          , 'T32: 111110100|00|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsl{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'T32: 111110100|00|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsl{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|00|1|Rm:4'                         , ''  ],

  # LSLS (immediate)
  ['lsls{%q}'          , '{Rd,} Rm, #imm'                        , 'T16: 000|00|imm!=00000|Rm:3|Rd:3'                                              , ''  ],
  ['lsls.W'            , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , ''  ],
  ['lsls{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , ''  ],
  ['lsls{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|1|0000|Rd:4|imm!=00000|00|0|Rm:4'                     , ''  ],

  # LSLS (register)
  ['lsls{%q}'          , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , ''  ],
  ['lsls.W'            , '{Rd,} Rm, Rs'                          , 'T32: 111110100|00|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsls{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'T32: 111110100|00|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsls{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|00|1|Rm:4'                         , ''  ],

  # LSR (immediate)
  ['lsr%c{%q}'         , '{Rd,} Rm, #imm'                        , 'T16: 000|01|imm:5|Rm:3|Rd:3'                                                   , ''  ],
  ['lsr%c.W'           , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , ''  ],
  ['lsr{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , ''  ],
  ['lsr{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|0|0000|Rd:4|imm:5|01|0|Rm:4'                          , ''  ],

  # LSR (register)
  ['lsr%c{%q}'         , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , ''  ],
  ['lsr%c.W'           , '{Rd,} Rm, Rs'                          , 'T32: 111110100|01|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsr{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'T32: 111110100|01|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsr{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|01|1|Rm:4'                         , ''  ],

  # LSRS (immediate)
  ['lsrs{%q}'          , '{Rd,} Rm, #imm'                        , 'T16: 000|01|imm:5|Rm:3|Rd:3'                                                   , ''  ],
  ['lsrs.W'            , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , ''  ],
  ['lsrs{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , ''  ],
  ['lsrs{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|1|0000|Rd:4|imm:5|01|0|Rm:4'                          , ''  ],

  # LSRS (register)
  ['lsrs{%q}'          , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , ''  ],
  ['lsrs.W'            , '{Rd,} Rm, Rs'                          , 'T32: 111110100|01|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsrs{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'T32: 111110100|01|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsrs{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|01|1|Rm:4'                         , ''  ],

  # MCR
  ['mcr{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm{, {#}opc2}', 'T32: 111|0|1110|opc1:3|0|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                , ''  ],
  ['mcr{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm{, {#}opc2}', 'A32: cond!=1111|1110|opc1:3|0|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'           , ''  ],

  # MCRR
  ['mcrr{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'T32: 111|0|11000|1|0|0|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                    , ''  ],
  ['mcrr{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'A32: cond!=1111|11000|1|0|0|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'               , ''  ],

  # MLA, MLAS
  ['mla{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|000|Rn:4|Ra!=1111|Rd:4|00|00|Rm:4'                              , ''  ],
  ['mlas{%c}{%q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|001|1|Rd:4|Ra:4|Rm:4|1001|Rn:4'                           , ''  ],
  ['mla{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|001|0|Rd:4|Ra:4|Rm:4|1001|Rn:4'                           , ''  ],

  # MLS
  ['mls{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|000|Rn:4|Ra:4|Rd:4|00|01|Rm:4'                                  , ''  ],
  ['mls{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|011|0|Rd:4|Ra:4|Rm:4|1001|Rn:4'                           , ''  ],

  # MOV, MOVS (immediate)
  ['mov%c{%q}'         , 'Rd, #imm.z'                            , 'T16: 001|00|Rd:3|imm:8'                                                        , ''  ],
  ['movs{%q}'          , 'Rd, #imm.z'                            , 'T16: 001|00|Rd:3|imm:8'                                                        , ''  ],
  ['mov%c.W'           , 'Rd, #cnst.c'                           , 'T32: 11110|cnst:1|0|0010|0|1111|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #cnst.c'                           , 'T32: 11110|cnst:1|0|0010|0|1111|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['movs.W'            , 'Rd, #cnst.c'                           , 'T32: 11110|cnst:1|0|0010|1|1111|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['movs{%c}{%q}'      , 'Rd, #cnst.c'                           , 'T32: 11110|cnst:1|0|0010|1|1111|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #imm.z'                            , 'T32: 11110|imm.B:1|10|0|100|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , ''  ],
  ['movw{%c}{%q}'      , 'Rd, #imm.z'                            , 'T32: 11110|imm.B:1|10|0|100|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #cnst.c'                           , 'A32: cond!=1111|00111|01|0|0000|Rd:4|cnst:12'                                  , ''  ],
  ['movs{%c}{%q}'      , 'Rd, #cnst.c'                           , 'A32: cond!=1111|00111|01|1|0000|Rd:4|cnst:12'                                  , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #imm.z'                            , 'A32: cond!=1111|00110|0|00|imm:4|Rd:4|imm:12'                                  , ''  ],
  ['movw{%c}{%q}'      , 'Rd, #imm.z'                            , 'A32: cond!=1111|00110|0|00|imm:4|Rd:4|imm:12'                                  , ''  ],

  # MOV, MOVS (register)
  ['mov{%c}{%q}'       , 'Rd, Rm'                                , 'T16: 010001|10|Rd:1|Rm:3|Rd:4'                                                 , ''  ],
  ['mov%c{%q}'         , 'Rd, Rm {, shift #amount}'              , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                         , ''  ],
  ['movs{%q}'          , 'Rd, Rm {, shift #amount}'              , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                         , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'T32: 1110101|0010|0|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['mov{%c}.W'         , 'Rd, Rm {, LSL #0}'                     , 'T32: 1110101|0010|0|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['mov%c.W'           , 'Rd, Rm {, shift #amount}'              , 'T32: 1110101|0010|0|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm {, shift #amount}'              , 'T32: 1110101|0010|0|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'T32: 1110101|0010|1|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['movs.W'            , 'Rd, Rm {, shift #amount}'              , 'T32: 1110101|0010|1|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm {, shift #amount}'              , 'T32: 1110101|0010|1|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|00011|01|0|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm {, shift #amount}'              , 'A32: cond!=1111|00011|01|0|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|00011|01|1|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm {, shift #amount}'              , 'A32: cond!=1111|00011|01|1|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # MOV, MOVS (register-shifted register)
  ['mov%c{%q}'         , 'Rdm, Rdm, ASR Rs'                      , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , ''  ],
  ['movs{%q}'          , 'Rdm, Rdm, ASR Rs'                      , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , ''  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, LSL Rs'                      , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , ''  ],
  ['movs{%q}'          , 'Rdm, Rdm, LSL Rs'                      , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , ''  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, LSR Rs'                      , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , ''  ],
  ['movs{%q}'          , 'Rdm, Rdm, LSR Rs'                      , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , ''  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, ROR Rs'                      , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , ''  ],
  ['movs{%q}'          , 'Rdm, Rdm, ROR Rs'                      , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , ''  ],
  ['movs.W'            , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                              , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                              , ''  ],
  ['mov%c.W'           , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                              , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                              , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # MOVT
  ['movt{%c}{%q}'      , 'Rd, #imm'                              , 'T32: 11110|imm.B:1|10|1|100|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , ''  ],
  ['movt{%c}{%q}'      , 'Rd, #imm'                              , 'A32: cond!=1111|00110|1|00|imm:4|Rd:4|imm:12'                                  , ''  ],

  # MRC
  ['mrc{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm{, {#}opc2}', 'T32: 111|0|1110|opc1:3|1|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                , ''  ],
  ['mrc{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm{, {#}opc2}', 'A32: cond!=1111|1110|opc1:3|1|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'           , ''  ],

  # MRRC
  ['mrrc{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'T32: 111|0|11000|1|0|1|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                    , ''  ],
  ['mrrc{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'A32: cond!=1111|11000|1|0|1|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'               , ''  ],

  # MRS
  ['mrs{%c}{%q}'       , 'Rd, sreg'                              , 'T32: 11110011111|sreg:1|1|1|1|1|10|0|0|Rd:4|0|0|0|0|0|0|0|0'                   , ''  ],
  ['mrs{%c}{%q}'       , 'Rd, sreg'                              , 'A32: cond!=1111|00010|sreg:1|0|0|1111|Rd:4|0|0|0|0|0000|0000'                  , ''  ],

  # MRS (Banked register)
  ['mrs{%c}{%q}'       , 'Rd, breg'                              , 'T32: 11110011111|breg.A:1|breg.C:4|10|0|0|Rd:4|0|0|1|breg.B:1|0|0|0|0'         , ''  ],
  ['mrs{%c}{%q}'       , 'Rd, breg'                              , 'A32: cond!=1111|00010|breg.A:1|0|0|breg.C:4|Rd:4|0|0|1|breg.B:1|0000|0000'     , ''  ],

  # MSR (Banked register)
  ['msr{%c}{%q}'       , 'breg, Rn'                              , 'T32: 11110011100|breg.A:1|Rn:4|10|0|0|breg.C:4|0|0|1|breg.B:1|0|0|0|0'         , ''  ],
  ['msr{%c}{%q}'       , 'breg, Rn'                              , 'A32: cond!=1111|00010|breg.A:1|1|0|breg.C:4|1111|0|0|1|breg.B:1|0000|Rn:4'     , ''  ],

  # MSR (immediate)
  ['msr{%c}{%q}'       , 'sreg, #imm.x'                          , 'A32: cond!=1111|00110|R!=0|10|mask!=0000|1|1|1|1|imm:12'                       , ''  ],

  # MSR (register)
  ['msr{%c}{%q}'       , 'sreg, Rn'                              , 'T32: 11110011100|R|Rn:4|10|0|0|mask:4|0|0|0|0|0|0|0|0'                         , ''  ],
  ['msr{%c}{%q}'       , 'sreg, Rn'                              , 'A32: cond!=1111|00010|R|1|0|mask:4|1111|0|0|0|0|0000|Rn:4'                     , ''  ],

  # MUL, MULS
  ['mul%c{%q}'         , 'Rdm, Rn{, Rdm}'                        , 'T16: 010000|1101|Rn:3|Rdm:3'                                                   , ''  ],
  ['muls{%q}'          , 'Rdm, Rn{, Rdm}'                        , 'T16: 010000|1101|Rn:3|Rdm:3'                                                   , ''  ],
  ['mul%c.W'           , 'Rd, Rn{, Rm}'                          , 'T32: 111110110|000|Rn:4|1111|Rd:4|00|00|Rm:4'                                  , ''  ],
  ['mul{%c}{%q}'       , 'Rd, Rn{, Rm}'                          , 'T32: 111110110|000|Rn:4|1111|Rd:4|00|00|Rm:4'                                  , ''  ],
  ['muls{%c}{%q}'      , 'Rd, Rn{, Rm}'                          , 'A32: cond!=1111|0000|000|1|Rd:4|0000|Rm:4|1001|Rn:4'                           , ''  ],
  ['mul{%c}{%q}'       , 'Rd, Rn{, Rm}'                          , 'A32: cond!=1111|0000|000|0|Rd:4|0000|Rm:4|1001|Rn:4'                           , ''  ],

  # MVN, MVNS (immediate)
  ['mvn{%c}{%q}'       , 'Rd, #cnst.c'                           , 'T32: 11110|cnst:1|0|0011|0|1111|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, #cnst.c'                           , 'T32: 11110|cnst:1|0|0011|1|1111|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, #cnst.c'                           , 'A32: cond!=1111|00111|11|0|0000|Rd:4|cnst:12'                                  , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, #cnst.c'                           , 'A32: cond!=1111|00111|11|1|0000|Rd:4|cnst:12'                                  , ''  ],

  # MVN, MVNS (register)
  ['mvn%c{%q}'         , 'Rd, Rm'                                , 'T16: 010000|1111|Rm:3|Rd:3'                                                    , ''  ],
  ['mvns{%q}'          , 'Rd, Rm'                                , 'T16: 010000|1111|Rm:3|Rd:3'                                                    , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'T32: 1110101|0011|0|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['mvn%c.W'           , 'Rd, Rm'                                , 'T32: 1110101|0011|0|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm {, shift #amount}'              , 'T32: 1110101|0011|0|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'T32: 1110101|0011|1|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['mvns.W'            , 'Rd, Rm'                                , 'T32: 1110101|0011|1|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm {, shift #amount}'              , 'T32: 1110101|0011|1|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|00011|11|0|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm {, shift #amount}'              , 'A32: cond!=1111|00011|11|0|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|00011|11|1|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm {, shift #amount}'              , 'A32: cond!=1111|00011|11|1|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # MVN, MVNS (register-shifted register)
  ['mvns{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|00011|11|1|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|00011|11|0|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # NOP
  ['nop{%c}{%q}'       , ''                                      , 'T16: 10111111|0000|0000'                                                       , ''  ],
  ['nop{%c}.W'         , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0000'                              , ''  ],
  ['nop{%c}{%q}'       , ''                                      , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|000000000000'                         , ''  ],

  # ORN, ORNS (immediate)
  ['orns{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0011|1|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['orn{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0011|0|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],

  # ORN, ORNS (register)
  ['orn{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0011|0|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orn{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0011|0|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['orns{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0011|1|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orns{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0011|1|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],

  # ORR, ORRS (immediate)
  ['orr{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0010|0|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['orrs{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'T32: 11110|cnst:1|0|0010|1|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['orr{%c}{%q}'       , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|00111|00|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['orrs{%c}{%q}'      , '{Rd,} Rn, #cnst.c'                     , 'A32: cond!=1111|00111|00|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # ORR, ORRS (register)
  ['orr%c{%q}'         , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|1100|Rm:3|Rdn:3'                                                   , ''  ],
  ['orrs{%q}'          , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|1100|Rm:3|Rdn:3'                                                   , ''  ],
  ['orr{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0010|0|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orr%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0010|0|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['orr{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0010|0|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['orrs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|0010|1|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orrs.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|0010|1|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['orrs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|0010|1|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['orr{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|00011|00|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['orr{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|00011|00|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['orrs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|00011|00|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['orrs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|00011|00|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # ORR, ORRS (register-shifted register)
  ['orrs{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|00011|00|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['orr{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|00011|00|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # PKHBT, PKHTB
  ['pkhbt{%c}{%q}'     , '{Rd,} Rn, Rm {, LSL #imm}'             , 'T32: 1110101|0110|0|Rn:4|0|imm3:3|Rd:4|imm2:2|0|0|Rm:4'                        , ''  ],
  ['pkhtb{%c}{%q}'     , '{Rd,} Rn, Rm {, ASR #imm}'             , 'T32: 1110101|0110|0|Rn:4|0|imm3:3|Rd:4|imm2:2|1|0|Rm:4'                        , ''  ],
  ['pkhbt{%c}{%q}'     , '{Rd,} Rn, Rm {, LSL #imm}'             , 'A32: cond!=1111|01101000|Rn:4|Rd:4|imm5:5|0|01|Rm:4'                           , ''  ],
  ['pkhtb{%c}{%q}'     , '{Rd,} Rn, Rm {, ASR #imm}'             , 'A32: cond!=1111|01101000|Rn:4|Rd:4|imm5:5|1|01|Rm:4'                           , ''  ],

  # PLD, PLDW (immediate)
  ['pld{%c}{%q}'       , '[Rn {, #{+}imm.z}]'                    , 'T32: 1111100|0|1|0|0|1|Rn!=1111|1111|imm:12'                                   , ''  ],
  ['pldw{%c}{%q}'      , '[Rn {, #{+}imm.z}]'                    , 'T32: 1111100|0|1|0|1|1|Rn!=1111|1111|imm:12'                                   , ''  ],
  ['pld{%c}{%q}'       , '[Rn {, #-imm.z}]'                      , 'T32: 1111100|0|0|0|0|1|Rn!=1111|1111|1100|imm:8'                               , ''  ],
  ['pldw{%c}{%q}'      , '[Rn {, #-imm.z}]'                      , 'T32: 1111100|0|0|0|1|1|Rn!=1111|1111|1100|imm:8'                               , ''  ],
  ['pld{%c}{%q}'       , '[Rn {, #{+/-}imm.z}]'                  , 'A32: 1111010|1|U|1|01|Rn!=1111|1|1|1|1|imm:12'                                 , ''  ],
  ['pldw{%c}{%q}'      , '[Rn {, #{+/-}imm.z}]'                  , 'A32: 1111010|1|U|0|01|Rn!=1111|1|1|1|1|imm:12'                                 , ''  ],

  # PLD (literal)
  ['pld{%c}{%q}'       , 'rel.z'                                 , 'T32: 1111100|0|U|0|0|1|1111|1111|rel:12'                                       , ''  ],
  ['pld{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'T32: 1111100|0|U|0|0|1|1111|1111|imm:12'                                       , ''  ],
  ['pld{%c}{%q}'       , 'rel.z'                                 , 'A32: 1111010|1|U|1|01|1111|1|1|1|1|rel:12'                                     , ''  ],
  ['pld{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'A32: 1111010|1|U|1|01|1111|1|1|1|1|imm:12'                                     , ''  ],

  # PLD, PLDW (register)
  ['pld{%c}{%q}'       , '[Rn, {+}Rm {, LSL #amount}]'           , 'T32: 1111100|0|0|0|0|1|Rn!=1111|1111|000000|amount:2|Rm:4'                     , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {+}Rm {, LSL #amount}]'           , 'T32: 1111100|0|0|0|1|1|Rn!=1111|1111|000000|amount:2|Rm:4'                     , ''  ],
  ['pld{%c}{%q}'       , '[Rn, {+/-}Rm {, shift #amount}]'       , 'A32: 1111011|1|U|1|01|Rn:4|1|1|1|1|amount!=00000|shift!=11|0|Rm:4'             , ''  ],
  ['pld{%c}{%q}'       , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111011|1|U|1|01|Rn:4|1|1|1|1|00000|11|0|Rm:4'                            , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {+/-}Rm {, shift #amount}]'       , 'A32: 1111011|1|U|0|01|Rn:4|1|1|1|1|amount!=00000|shift!=11|0|Rm:4'             , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111011|1|U|0|01|Rn:4|1|1|1|1|00000|11|0|Rm:4'                            , ''  ],

  # PLI (immediate, literal)
  ['pli{%c}{%q}'       , '[Rn {, #{+}imm.z}]'                    , 'T32: 1111100|1|1|00|1|Rn!=1111|1111|imm:12'                                    , ''  ],
  ['pli{%c}{%q}'       , '[Rn {, #-imm.z}]'                      , 'T32: 1111100|1|0|00|1|Rn!=1111|1111|1100|imm:8'                                , ''  ],
  ['pli{%c}{%q}'       , 'rel.z'                                 , 'T32: 1111100|1|U|00|1|1111|1111|rel:12'                                        , ''  ],
  ['pli{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'T32: 1111100|1|U|00|1|1111|1111|imm:12'                                        , ''  ],
  ['pli{%c}{%q}'       , '[Rn {, #{+/-}imm.z}]'                  , 'A32: 1111010|0|U|1|01|Rn:4|1|1|1|1|imm:12'                                     , ''  ],
  ['pli{%c}{%q}'       , 'rel.z'                                 , 'A32: 1111010|0|U|1|01|Rn:4|1|1|1|1|rel:12'                                     , ''  ],
  ['pli{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'A32: 1111010|0|U|1|01|Rn:4|1|1|1|1|imm:12'                                     , ''  ],

  # PLI (register)
  ['pli{%c}{%q}'       , '[Rn, {+}Rm {, LSL #amount}]'           , 'T32: 1111100|1|0|00|1|Rn!=1111|1111|000000|amount:2|Rm:4'                      , ''  ],
  ['pli{%c}{%q}'       , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111011|0|U|1|01|Rn:4|1|1|1|1|00000|11|0|Rm:4'                            , ''  ],
  ['pli{%c}{%q}'       , '[Rn, {+/-}Rm {, shift #amount}]'       , 'A32: 1111011|0|U|1|01|Rn:4|1|1|1|1|amount!=00000|shift!=11|0|Rm:4'             , ''  ],

  # POP
  ['pop{%c}{%q}'       , 'list'                                  , 'T16: 1011|1|10|list.A:1|list.I:8'                                              , ''  ],
  ['ldm{%c}{%q}'       , 'SP!, list'                             , 'T16: 1011|1|10|list.A:1|list.I:8'                                              , ''  ],

  # POP (multiple registers)
  ['pop{%c}.W'         , 'list'                                  , 'T32: 1110100|01|0|1|1|1101|list:1|list:1|0|list:13'                            , ''  ],
  ['pop{%c}{%q}'       , 'list'                                  , 'T32: 1110100|01|0|1|1|1101|list:1|list:1|0|list:13'                            , ''  ],
  ['pop{%c}{%q}'       , 'list'                                  , 'A32: cond!=1111|100|0|1|0|1|1|1101|list:16'                                    , ''  ],

  # POP (single register)
  ['pop{%c}{%q}'       , 'RtList'                                , 'T32: 1111100|0|0|10|1|1101|Rt:4|1|0|1|1|00000100'                              , ''  ],
  ['pop{%c}{%q}'       , 'RtList'                                , 'A32: cond!=1111|010|0|1|0|0|1|1101|Rt:4|000000000100'                          , ''  ],

  # PUSH
  ['push{%c}{%q}'      , 'list'                                  , 'T16: 1011|0|10|list.A:1|list.H:8'                                              , ''  ],
  ['stmdb{%c}{%q}'     , 'SP!, list'                             , 'T16: 1011|0|10|list.A:1|list.H:8'                                              , ''  ],

  # PUSH (multiple registers)
  ['push{%c}.W'        , 'list'                                  , 'T32: 1110100|10|0|1|0|1101|0|list.B:1|0|list.C:13'                             , ''  ],
  ['push{%c}{%q}'      , 'list'                                  , 'T32: 1110100|10|0|1|0|1101|0|list.B:1|0|list.C:13'                             , ''  ],
  ['push{%c}{%q}'      , 'list'                                  , 'A32: cond!=1111|100|1|0|0|1|0|1101|list:16'                                    , ''  ],

  # PUSH (single register)
  ['push{%c}{%q}'      , 'RtList'                                , 'T32: 1111100|0|0|10|0|1101|Rt:4|1|1|0|1|00000100'                              , ''  ],
  ['push{%c}{%q}'      , 'RtList'                                , 'A32: cond!=1111|010|1|0|0|1|0|1101|Rt:4|000000000100'                          , ''  ],

  # QADD
  ['qadd{%c}{%q}'      , '{Rd,} Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['qadd{%c}{%q}'      , '{Rd,} Rm, Rn'                          , 'A32: cond!=1111|00010|00|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  # QADD16
  ['qadd16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|1|Rm:4'                   , ''  ],
  ['qadd16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|0|1|0|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  # QADD8
  ['qadd8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qadd8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  # QASX
  ['qasx{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qasx{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  # QDADD
  ['qdadd{%c}{%q}'     , '{Rd,} Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|01|Rm:4'                                  , ''  ],
  ['qdadd{%c}{%q}'     , '{Rd,} Rm, Rn'                          , 'A32: cond!=1111|00010|10|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  # QDSUB
  ['qdsub{%c}{%q}'     , '{Rd,} Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|11|Rm:4'                                  , ''  ],
  ['qdsub{%c}{%q}'     , '{Rd,} Rm, Rn'                          , 'A32: cond!=1111|00010|11|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  # QSAX
  ['qsax{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qsax{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  # QSUB
  ['qsub{%c}{%q}'      , '{Rd,} Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|10|Rm:4'                                  , ''  ],
  ['qsub{%c}{%q}'      , '{Rd,} Rm, Rn'                          , 'A32: cond!=1111|00010|01|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  # QSUB16
  ['qsub16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|1|Rm:4'                   , ''  ],
  ['qsub16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|0|1|0|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  # QSUB8
  ['qsub8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qsub8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  # RBIT
  ['rbit{%c}{%q}'      , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|10|Rm:4'                                  , ''  ],
  ['rbit{%c}{%q}'      , 'Rd, Rm'                                , 'A32: cond!=1111|01101|1|11|1|1|1|1|Rd:4|1|1|1|1|0|011|Rm:4'                    , ''  ],

  # REV
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'T16: 10111010|00|Rm:3|Rd:3'                                                    , ''  ],
  ['rev{%c}.W'         , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'A32: cond!=1111|01101|0|11|1|1|1|1|Rd:4|1|1|1|1|0|011|Rm:4'                    , ''  ],

  # REV16
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'T16: 10111010|01|Rm:3|Rd:3'                                                    , ''  ],
  ['rev16{%c}.W'       , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|01|Rm:4'                                  , ''  ],
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|01|Rm:4'                                  , ''  ],
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'A32: cond!=1111|01101|0|11|1|1|1|1|Rd:4|1|1|1|1|1|011|Rm:4'                    , ''  ],

  # REVSH
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'T16: 10111010|11|Rm:3|Rd:3'                                                    , ''  ],
  ['revsh{%c}.W'       , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|11|Rm:4'                                  , ''  ],
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'T32: 111110101|001|Rn:4|1111|Rd:4|10|11|Rm:4'                                  , ''  ],
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'A32: cond!=1111|01101|1|11|1|1|1|1|Rd:4|1|1|1|1|1|011|Rm:4'                    , ''  ],

  # RFE, RFEDA, RFEDB, RFEIA, RFEIB
  ['rfedb{%c}{%q}'     , 'Rn{!}'                                 , 'T32: 1110100|00|0|W|1|Rn:4|1|1|0|0000000000000'                                , ''  ],
  ['rfe{IA}{%c}{%q}'   , 'Rn{!}'                                 , 'T32: 1110100|11|0|W|1|Rn:4|1|1|0|0000000000000'                                , ''  ],
  ['rfeda{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111100|0|0|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],
  ['rfedb{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111100|1|0|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],
  ['rfe{IA}{%c}{%q}'   , 'Rn{!}'                                 , 'A32: 1111100|0|1|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],
  ['rfeib{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111100|1|1|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],

  # ROR (immediate)
  ['ror{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|0|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                      , ''  ],
  ['ror{%c}{%q}'       , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|0|0000|Rd:4|imm!=00000|11|0|Rm:4'                     , ''  ],

  # ROR (register)
  ['ror%c{%q}'         , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , ''  ],
  ['ror%c.W'           , '{Rd,} Rm, Rs'                          , 'T32: 111110100|11|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['ror{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'T32: 111110100|11|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['ror{%c}{%q}'       , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|11|1|Rm:4'                         , ''  ],

  # RORS (immediate)
  ['rors{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'T32: 1110101|0010|1|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                      , ''  ],
  ['rors{%c}{%q}'      , '{Rd,} Rm, #imm'                        , 'A32: cond!=1111|00011|01|1|0000|Rd:4|imm!=00000|11|0|Rm:4'                     , ''  ],

  # RORS (register)
  ['rors{%q}'          , '{Rdm,} Rdm, Rs'                        , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , ''  ],
  ['rors.W'            , '{Rd,} Rm, Rs'                          , 'T32: 111110100|11|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['rors{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'T32: 111110100|11|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['rors{%c}{%q}'      , '{Rd,} Rm, Rs'                          , 'A32: cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|11|1|Rm:4'                         , ''  ],

  # RRX
  ['rrx{%c}{%q}'       , '{Rd,} Rm'                              , 'T32: 1110101|0010|0|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rrx{%c}{%q}'       , '{Rd,} Rm'                              , 'A32: cond!=1111|00011|01|0|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],

  # RRXS
  ['rrxs{%c}{%q}'      , '{Rd,} Rm'                              , 'T32: 1110101|0010|1|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rrxs{%c}{%q}'      , '{Rd,} Rm'                              , 'A32: cond!=1111|00011|01|1|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],

  # RSB, RSBS (immediate)
  ['rsb%c{%q}'         , '{Rd, }Rn, #0'                          , 'T16: 010000|1001|Rn:3|Rd:3'                                                    , ''  ],
  ['rsbs{%q}'          , '{Rd, }Rn, #0'                          , 'T16: 010000|1001|Rn:3|Rd:3'                                                    , ''  ],
  ['rsb%c.W'           , '{Rd,} Rn, #0'                          , 'T32: 11110|i|0|1110|0|Rn:4|0|imm3:3|Rd:4|imm8:8'                               , ''  ],
  ['rsb{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1110|0|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['rsbs.W'            , '{Rd,} Rn, #0'                          , 'T32: 11110|i|0|1110|1|Rn:4|0|imm3:3|Rd:4|imm8:8'                               , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1110|1|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['rsb{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|011|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|011|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # RSB, RSBS (register)
  ['rsb{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1110|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rsb{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1110|0|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1110|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1110|1|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['rsb{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|011|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rsb{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|011|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|011|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|011|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # RSB, RSBS (register-shifted register)
  ['rsbs{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|011|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['rsb{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|011|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # RSC, RSCS (immediate)
  ['rsc{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|111|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['rscs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|111|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # RSC, RSCS (register)
  ['rsc{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|111|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rsc{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|111|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['rscs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|111|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rscs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|111|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # RSC, RSCS (register-shifted register)
  ['rscs{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|111|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['rsc{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|111|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # SADD16
  ['sadd16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|0|Rm:4'                   , ''  ],
  ['sadd16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|0|0|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  # SADD8
  ['sadd8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['sadd8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  # SASX
  ['sasx{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['sasx{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  # SBC, SBCS (immediate)
  ['sbc{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1011|0|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1011|1|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['sbc{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|110|0|Rn:4|Rd:4|cnst:12'                                  , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|110|1|Rn:4|Rd:4|cnst:12'                                  , ''  ],

  # SBC, SBCS (register)
  ['sbc%c{%q}'         , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0110|Rm:3|Rdn:3'                                                   , ''  ],
  ['sbcs{%q}'          , '{Rdn,} Rdn, Rm'                        , 'T16: 010000|0110|Rm:3|Rdn:3'                                                   , ''  ],
  ['sbc{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1011|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['sbc%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1011|0|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['sbc{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1011|0|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1011|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['sbcs.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1011|1|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1011|1|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['sbc{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|110|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['sbc{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|110|0|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|110|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|110|1|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # SBC, SBCS (register-shifted register)
  ['sbcs{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|110|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['sbc{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|110|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # SBFX
  ['sbfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width'                  , 'T32: 11110|0|11|01|0|0|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                      , ''  ],
  ['sbfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width'                  , 'A32: cond!=1111|01111|0|1|width:5|Rd:4|lsb:5|101|Rn:4'                         , ''  ],

  # SDIV
  ['sdiv{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110111|001|Rn:4|1111|Rd:4|1111|Rm:4'                                   , ''  ],
  ['sdiv{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|001|Rd:4|1111|Rm:4|000|1|Rn:4'                           , ''  ],

  # SEL
  ['sel{%c}{%q}'       , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['sel{%c}{%q}'       , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01101000|Rn:4|Rd:4|1|1|1|1|1011|Rm:4'                          , ''  ],

  # SETEND
  ['setend{%q}'        , 'endian_specifier'                      , 'T16: 1011011001|0|1|endian_specifier:1|000'                                    , ''  ],
  ['setend{%q}'        , 'endian_specifier'                      , 'A32: 111100010000|00|0|1|0|0|0|0|0|0|endian_specifier:1|0|0|0|0|00000'         , ''  ],

  # SEV
  ['sev{%c}{%q}'       , ''                                      , 'T16: 10111111|0100|0000'                                                       , ''  ],
  ['sev{%c}.W'         , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0100'                              , ''  ],
  ['sev{%c}{%q}'       , ''                                      , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|000000000100'                         , ''  ],

  # SEVL
  ['sevl{%c}{%q}'      , ''                                      , 'T16: 10111111|0101|0000'                                                       , ''  ],
  ['sevl{%c}.W'        , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0101'                              , ''  ],
  ['sevl{%c}{%q}'      , ''                                      , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|000000000101'                         , ''  ],

  # SHADD16
  ['shadd16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|0|1|0|Rm:4'                   , ''  ],
  ['shadd16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|0|1|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  # SHADD8
  ['shadd8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shadd8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  # SHASX
  ['shasx{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shasx{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  # SHSAX
  ['shsax{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shsax{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  # SHSUB16
  ['shsub16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|0|1|0|Rm:4'                   , ''  ],
  ['shsub16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|0|1|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  # SHSUB8
  ['shsub8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shsub8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  # SMC
  ['smc{%c}{%q}'       , '{#}imm'                                , 'T32: 11110111111|1|imm:4|10|0|0|000000000000'                                  , ''  ],
  ['smc{%c}{%q}'       , '{#}imm'                                , 'A32: cond!=1111|00010|11|0|000000000000|0111|imm:4'                            , ''  ],

  # SMLABB, SMLABT, SMLATB, SMLATT
  ['smlabb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smlabt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlatb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|1|0|Rm:4'                             , ''  ],
  ['smlatt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|1|1|Rm:4'                             , ''  ],
  ['smlabb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|0|0|0|Rn:4'                        , ''  ],
  ['smlabt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|1|0|0|Rn:4'                        , ''  ],
  ['smlatb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|0|1|0|Rn:4'                        , ''  ],
  ['smlatt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|1|1|0|Rn:4'                        , ''  ],

  # SMLAD, SMLADX
  ['smlad{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|010|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smladx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|010|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlad{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|00|0|1|Rn:4'                      , ''  ],
  ['smladx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|00|1|1|Rn:4'                      , ''  ],

  # SMLAL, SMLALS
  ['smlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['smlals{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|111|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['smlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|111|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  # SMLALBB, SMLALBT, SMLALTB, SMLALTT
  ['smlalbb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|0|0|Rm:4'                             , ''  ],
  ['smlalbt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|0|1|Rm:4'                             , ''  ],
  ['smlaltb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|1|0|Rm:4'                             , ''  ],
  ['smlaltt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|1|1|Rm:4'                             , ''  ],
  ['smlalbb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|0|0|0|Rn:4'                    , ''  ],
  ['smlalbt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|1|0|0|Rn:4'                    , ''  ],
  ['smlaltb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|0|1|0|Rn:4'                    , ''  ],
  ['smlaltt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|1|1|0|Rn:4'                    , ''  ],

  # SMLALD, SMLALDX
  ['smlald{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|110|0|Rm:4'                              , ''  ],
  ['smlaldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|110|1|Rm:4'                              , ''  ],
  ['smlald{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|00|0|1|Rn:4'                      , ''  ],
  ['smlaldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|00|1|1|Rn:4'                      , ''  ],

  # SMLAWB, SMLAWT
  ['smlawb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|011|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smlawt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|011|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlawb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|00010|01|0|Rd:4|Ra:4|Rm:4|1|0|0|0|Rn:4'                        , ''  ],
  ['smlawt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|00010|01|0|Rd:4|Ra:4|Rm:4|1|1|0|0|Rn:4'                        , ''  ],

  # SMLSD, SMLSDX
  ['smlsd{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|100|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smlsdx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|100|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlsd{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|01|0|1|Rn:4'                      , ''  ],
  ['smlsdx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|01|1|1|Rn:4'                      , ''  ],

  # SMLSLD, SMLSLDX
  ['smlsld{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|101|Rn:4|RdLo:4|RdHi:4|110|0|Rm:4'                              , ''  ],
  ['smlsldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|101|Rn:4|RdLo:4|RdHi:4|110|1|Rm:4'                              , ''  ],
  ['smlsld{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|01|0|1|Rn:4'                      , ''  ],
  ['smlsldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|01|1|1|Rn:4'                      , ''  ],

  # SMMLA, SMMLAR
  ['smmla{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|101|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smmlar{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|101|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smmla{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|101|Rd:4|Ra!=1111|Rm:4|00|0|1|Rn:4'                      , ''  ],
  ['smmlar{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|101|Rd:4|Ra!=1111|Rm:4|00|1|1|Rn:4'                      , ''  ],

  # SMMLS, SMMLSR
  ['smmls{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|110|Rn:4|Ra:4|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smmlsr{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|110|Rn:4|Ra:4|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smmls{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|101|Rd:4|Ra:4|Rm:4|11|0|1|Rn:4'                          , ''  ],
  ['smmlsr{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01110|101|Rd:4|Ra:4|Rm:4|11|1|1|Rn:4'                          , ''  ],

  # SMMUL, SMMULR
  ['smmul{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110110|101|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smmulr{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|101|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smmul{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|101|Rd:4|1111|Rm:4|00|0|1|Rn:4'                          , ''  ],
  ['smmulr{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|101|Rd:4|1111|Rm:4|00|1|1|Rn:4'                          , ''  ],

  # SMUAD, SMUADX
  ['smuad{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110110|010|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smuadx{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|010|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smuad{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|000|Rd:4|1111|Rm:4|00|0|1|Rn:4'                          , ''  ],
  ['smuadx{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|000|Rd:4|1111|Rm:4|00|1|1|Rn:4'                          , ''  ],

  # SMULBB, SMULBT, SMULTB, SMULTT
  ['smulbb{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smulbt{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smultb{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|1|0|Rm:4'                                 , ''  ],
  ['smultt{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|1|1|Rm:4'                                 , ''  ],
  ['smulbb{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|0|0|0|Rn:4'                        , ''  ],
  ['smulbt{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|1|0|0|Rn:4'                        , ''  ],
  ['smultb{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|0|1|0|Rn:4'                        , ''  ],
  ['smultt{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|1|1|0|Rn:4'                        , ''  ],

  # SMULL, SMULLS
  ['smull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|000|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['smulls{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|110|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['smull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|110|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  # SMULWB, SMULWT
  ['smulwb{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|011|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smulwt{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|011|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smulwb{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|00010|01|0|Rd:4|0000|Rm:4|1|0|1|0|Rn:4'                        , ''  ],
  ['smulwt{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|00010|01|0|Rd:4|0000|Rm:4|1|1|1|0|Rn:4'                        , ''  ],

  # SMUSD, SMUSDX
  ['smusd{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110110|100|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smusdx{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110110|100|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smusd{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|000|Rd:4|1111|Rm:4|01|0|1|Rn:4'                          , ''  ],
  ['smusdx{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|000|Rd:4|1111|Rm:4|01|1|1|Rn:4'                          , ''  ],

  # SRS, SRSDA, SRSDB, SRSIA, SRSIB
  ['srsdb{%c}{%q}'     , 'SP{!}, #mode'                          , 'T32: 1110100|00|0|W|0|1101|1|1|0|00000000|mode:5'                              , ''  ],
  ['srs{IA}{%c}{%q}'   , 'SP{!}, #mode'                          , 'T32: 1110100|11|0|W|0|1101|1|1|0|00000000|mode:5'                              , ''  ],
  ['srsda{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111100|0|0|1|W|0|1101|00000101000|mode:5'                                , ''  ],
  ['srsdb{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111100|1|0|1|W|0|1101|00000101000|mode:5'                                , ''  ],
  ['srs{IA}{%c}{%q}'   , 'SP{!}, #mode'                          , 'A32: 1111100|0|1|1|W|0|1101|00000101000|mode:5'                                , ''  ],
  ['srsib{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111100|1|1|1|W|0|1101|00000101000|mode:5'                                , ''  ],

  # SSAT
  ['ssat{%c}{%q}'      , 'Rd, #imm, Rn, ASR #amount'             , 'T32: 11110|0|11|00|1|0|Rn:4|0|amount!=000|Rd:4|amount!=00|0|imm:5'             , ''  ],
  ['ssat{%c}{%q}'      , 'Rd, #imm, Rn {, LSL #amount}'          , 'T32: 11110|0|11|00|0|0|Rn:4|0|amount:3|Rd:4|amount:2|0|imm:5'                  , ''  ],
  ['ssat{%c}{%q}'      , 'Rd, #imm, Rn, ASR #amount'             , 'A32: cond!=1111|01101|0|1|imm:5|Rd:4|amount:5|1|01|Rn:4'                       , ''  ],
  ['ssat{%c}{%q}'      , 'Rd, #imm, Rn {, LSL #amount}'          , 'A32: cond!=1111|01101|0|1|imm:5|Rd:4|amount:5|0|01|Rn:4'                       , ''  ],

  # SSAT16
  ['ssat16{%c}{%q}'    , 'Rd, #imm, Rn'                          , 'T32: 11110|0|11|00|1|0|Rn:4|0|000|Rd:4|00|0|0|imm:4'                           , ''  ],
  ['ssat16{%c}{%q}'    , 'Rd, #imm, Rn'                          , 'A32: cond!=1111|01101|0|10|imm:4|Rd:4|1|1|1|1|0011|Rn:4'                       , ''  ],

  # SSAX
  ['ssax{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['ssax{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  # SSUB16
  ['ssub16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|0|Rm:4'                   , ''  ],
  ['ssub16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|0|0|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  # SSUB8
  ['ssub8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['ssub8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  # STC
  ['stc{%c}{%q}'       , 'p14, c5, [Rn{, #{+/-}imm.z*4}]'        , 'T32: 111|0|110|1|U|0|0|0|Rn:4|0101|111|0|imm:8'                                , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'T32: 111|0|110|0|U|0|1|0|Rn:4|0101|111|0|imm:8'                                , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'T32: 111|0|110|1|U|0|1|0|Rn:4|0101|111|0|imm:8'                                , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'T32: 111|0|110|0|1|0|0|0|Rn:4|0101|111|0|option:8'                             , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn{, #{+/-}imm.z*4}]'        , 'A32: cond!=1111|110|1|U|0|0|0|Rn:4|0101|111|0|imm:8'                           , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'A32: cond!=1111|110|0|U|0|1|0|Rn:4|0101|111|0|imm:8'                           , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'A32: cond!=1111|110|1|U|0|1|0|Rn:4|0101|111|0|imm:8'                           , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'A32: cond!=1111|110|0|1|0|0|0|Rn:4|0101|111|0|option:8'                        , ''  ],

  # STL
  ['stl{%c}{%q}'       , 'Rt, [Rn]'                              , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|0|10|1111'                                 , ''  ],
  ['stl{%c}{%q}'       , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|00|0|Rn:4|1111|1|1|0|0|1001|Rt:4'                        , ''  ],

  # STLB
  ['stlb{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|0|00|1111'                                 , ''  ],
  ['stlb{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|10|0|Rn:4|1111|1|1|0|0|1001|Rt:4'                        , ''  ],

  # STLEX
  ['stlex{%c}{%q}'     , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|1|10|Rd:4'                                 , ''  ],
  ['stlex{%c}{%q}'     , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|00011|00|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  # STLEXB
  ['stlexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|1|00|Rd:4'                                 , ''  ],
  ['stlexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|00011|10|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  # STLEXD
  ['stlexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 11101000110|0|Rn:4|Rt:4|Rt2:4|1|1|11|Rd:4'                                , ''  ],
  ['stlexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'A32: cond!=1111|00011|01|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  # STLEXH
  ['stlexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|1|01|Rd:4'                                 , ''  ],
  ['stlexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|00011|11|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  # STLH
  ['stlh{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|0|01|1111'                                 , ''  ],
  ['stlh{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|00011|11|0|Rn:4|1111|1|1|0|0|1001|Rt:4'                        , ''  ],

  # STM, STMIA, STMEA
  ['stm{IA}{%c}{%q}'   , 'Rn!, list'                             , 'T16: 1100|0|Rn:3|list:8'                                                       , ''  ],
  ['stmea{%c}{%q}'     , 'Rn!, list'                             , 'T16: 1100|0|Rn:3|list:8'                                                       , ''  ],
  ['stm{IA}{%c}.W'     , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmea{%c}.W'       , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stm{IA}{%c}{%q}'   , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmea{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stm{IA}{%c}{%q}'   , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|1|0|W|0|Rn:4|list:16'                                    , ''  ],
  ['stmea{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|1|0|W|0|Rn:4|list:16'                                    , ''  ],

  # STM (User registers)
  ['stm{%amode}{%c}{%q}', 'Rn, list'                              , 'A32: cond!=1111|100|P|U|1|0|0|Rn:4|list:16'                                    , ''  ],

  # STMDA, STMED
  ['stmda{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|0|0|W|0|Rn:4|list:16'                                    , ''  ],
  ['stmed{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|0|0|0|W|0|Rn:4|list:16'                                    , ''  ],

  # STMDB, STMFD
  ['stmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110100|10|0|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110100|10|0|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|0|0|W|0|Rn:4|list:16'                                    , ''  ],
  ['stmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|0|0|W|0|Rn:4|list:16'                                    , ''  ],

  # STMIB, STMFA
  ['stmib{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|1|0|W|0|Rn:4|list:16'                                    , ''  ],
  ['stmfa{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|100|1|1|0|W|0|Rn:4|list:16'                                    , ''  ],

  # STR (immediate)
  ['str{%c}{%q}'       , 'Rt, [Rn {, #{+}imm.z*4}]'              , 'T16: 011|0|0|imm:5|Rn:3|Rt:3'                                                  , ''  ],
  ['str{%c}{%q}'       , 'Rt, [SP{, #{+}imm.z*4}]'               , 'T16: 1001|0|Rt:3|imm:8'                                                        , ''  ],
  ['str{%c}.W'         , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|10|0|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|10|0|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1|1|0|0|imm:8'                             , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|010|1|U|0|0|0|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|010|0|U|0|0|0|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|010|1|U|0|1|0|Rn:4|Rt:4|imm:12'                                , ''  ],

  # STR (register)
  ['str{%c}{%q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|0|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['str{%c}.W'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|000000|imm2:2|Rm:4'                        , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|000000|imm:2|Rm:4'                         , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]'  , 'A32: cond!=1111|011|1|U|0|0|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|0|0|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]!' , 'A32: cond!=1111|011|1|U|0|1|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # STRB (immediate)
  ['strb{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T16: 011|1|0|imm:5|Rn:3|Rt:3'                                                  , ''  ],
  ['strb{%c}.W'        , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|00|0|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|00|0|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1|1|0|0|imm:8'                             , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|010|1|U|1|0|0|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|010|0|U|1|0|0|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|010|1|U|1|1|0|Rn:4|Rt:4|imm:12'                                , ''  ],

  # STRB (register)
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|1|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['strb{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|000000|imm2:2|Rm:4'                        , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|000000|imm:2|Rm:4'                         , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]'  , 'A32: cond!=1111|011|1|U|1|0|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|1|0|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm{, shift {#amount}}]!' , 'A32: cond!=1111|011|1|U|1|1|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # STRBT
  ['strbt{%c}{%q}'     , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['strbt{%c}{%q}'     , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|010|0|U|1|1|0|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['strbt{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|1|1|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # STRD (immediate)
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn {, #{+/-}imm.z*4}]'       , 'T32: 1110100|1|U|1|0|0|Rn!=1111|Rt:4|Rt2:4|imm:8'                              , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z*4'          , 'T32: 1110100|0|U|1|1|0|Rn!=1111|Rt:4|Rt2:4|imm:8'                              , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110100|1|U|1|1|0|Rn!=1111|Rt:4|Rt2:4|imm:8'                              , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn {, #{+/-}imm.z}]'         , 'A32: cond!=1111|000|1|U|1|0|0|Rn:4|Rt:4|imm:4|1|11|1|imm:4'                    , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z'            , 'A32: cond!=1111|000|0|U|1|0|0|Rn:4|Rt:4|imm:4|1|11|1|imm:4'                    , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z]!'           , 'A32: cond!=1111|000|1|U|1|1|0|Rn:4|Rt:4|imm:4|1|11|1|imm:4'                    , ''  ],

  # STRD (register)
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]'                , 'A32: cond!=1111|000|1|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], {+/-}Rm'                , 'A32: cond!=1111|000|0|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]!'               , 'A32: cond!=1111|000|1|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],

  # STREX
  ['strex{%c}{%q}'     , 'Rd, Rt, [Rn {, #imm.z*4}]'             , 'T32: 11101000010|0|Rn:4|Rt:4|Rd:4|imm:8'                                       , ''  ],
  ['strex{%c}{%q}'     , 'Rd, Rt, [Rn {, {#}imm}]'               , 'A32: cond!=1111|00011|00|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  # STREXB
  ['strexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|01|00|Rd:4'                                  , ''  ],
  ['strexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|00011|10|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  # STREXD
  ['strexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 11101000110|0|Rn:4|Rt:4|Rt2:4|01|11|Rd:4'                                 , ''  ],
  ['strexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'A32: cond!=1111|00011|01|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  # STREXH
  ['strexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|01|01|Rd:4'                                  , ''  ],
  ['strexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|00011|11|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  # STRH (immediate)
  ['strh{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z*2}]'              , 'T16: 1000|0|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['strh{%c}.W'        , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|01|0|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|1|01|0|Rn!=1111|Rt:4|imm:12'                                    , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn {, #-imm.z}]'                  , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1|1|0|0|imm:8'                             , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1|0|U|1|imm:8'                             , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1|1|U|1|imm:8'                             , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn {, #{+/-}imm.z}]'              , 'A32: cond!=1111|000|1|U|1|0|0|Rn:4|Rt:4|imm:4|1|01|1|imm:4'                    , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|000|0|U|1|0|0|Rn:4|Rt:4|imm:4|1|01|1|imm:4'                    , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|000|1|U|1|1|0|Rn:4|Rt:4|imm:4|1|01|1|imm:4'                    , ''  ],

  # STRH (register)
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|0|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['strh{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|000000|imm2:2|Rm:4'                        , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+}Rm{, LSL #imm}]'           , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|000000|imm:2|Rm:4'                         , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|000|1|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|000|1|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  # STRHT
  ['strht{%c}{%q}'     , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['strht{%c}{%q}'     , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|000|0|U|1|1|0|Rn:4|Rt:4|imm:4|1|01|1|imm:4'                    , ''  ],
  ['strht{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|000|0|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  # STRT
  ['strt{%c}{%q}'      , 'Rt, [Rn {, #{+}imm.z}]'                , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1110|imm:8'                                , ''  ],
  ['strt{%c}{%q}'      , 'Rt, [Rn] {, #{+/-}imm.z}'              , 'A32: cond!=1111|010|0|U|0|1|0|Rn:4|Rt:4|imm:12'                                , ''  ],
  ['strt{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm{, shift {#amount}}'  , 'A32: cond!=1111|011|0|U|0|1|0|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'               , ''  ],

  # SUB (immediate, from PC)
  ['sub{%c}{%q}'       , 'Rd, PC, #imm.z'                        , 'T32: 11110|imm:1|10|1|0|1|0|1111|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['sub{%c}{%q}'       , 'Rd, PC, #cnst.x'                       , 'A32: cond!=1111|0010|010|0|1111|Rd:4|cnst:12'                                  , ''  ],

  # SUB, SUBS (immediate)
  ['sub%c{%q}'         , 'Rd, Rn, #imm.z'                        , 'T16: 000111|1|imm:3|Rn:3|Rd:3'                                                 , ''  ],
  ['subs{%q}'          , 'Rd, Rn, #imm.z'                        , 'T16: 000111|1|imm:3|Rn:3|Rd:3'                                                 , ''  ],
  ['sub%c{%q}'         , 'Rdn, #imm.z'                           , 'T16: 001|11|Rdn:3|imm:8'                                                       , ''  ],
  ['sub%c{%q}'         , '{Rdn,} Rdn, #imm.z'                    , 'T16: 001|11|Rdn:3|imm:8'                                                       , ''  ],
  ['subs{%q}'          , 'Rdn, #imm.z'                           , 'T16: 001|11|Rdn:3|imm:8'                                                       , ''  ],
  ['subs{%q}'          , '{Rdn,} Rdn, #imm.z'                    , 'T16: 001|11|Rdn:3|imm:8'                                                       , ''  ],
  ['sub%c.W'           , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|0|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|0|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['subs.W'            , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|1|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|1|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, #imm.z'                      , 'T32: 11110|imm:1|10|1|0|1|0|Rn!=11x1|0|imm:3|Rd:4|imm:8'                       , ''  ],
  ['subw{%c}{%q}'      , '{Rd,} Rn, #imm.z'                      , 'T32: 11110|imm:1|10|1|0|1|0|Rn!=11x1|0|imm:3|Rd:4|imm:8'                       , ''  ],
  ['subs{%c}{%q}'      , 'PC, LR, #imm.z'                        , 'T32: 111100111101|1110|10|0|0|1|1|1|1|imm!=00000000'                           , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|010|0|Rn!=11x1|Rd:4|cnst:12'                              , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} Rn, #cnst.x'                     , 'A32: cond!=1111|0010|010|1|Rn!=1101|Rd:4|cnst:12'                              , ''  ],

  # SUB, SUBS (register)
  ['sub%c{%q}'         , 'Rd, Rn, Rm'                            , 'T16: 000110|1|Rm:3|Rn:3|Rd:3'                                                  , ''  ],
  ['subs{%q}'          , '{Rd,} Rn, Rm'                          , 'T16: 000110|1|Rm:3|Rn:3|Rd:3'                                                  , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1101|0|Rn!=1101|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['sub%c.W'           , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1101|0|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1101|0|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'T32: 1110101|1101|1|Rn!=1101|0|000|Rd!=1111|00|11|Rm:4'                        , ''  ],
  ['subs.W'            , '{Rd,} Rn, Rm'                          , 'T32: 1110101|1101|1|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'      , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'T32: 1110101|1101|1|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4' , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|010|0|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|010|0|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'       , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|010|1|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} Rn, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|010|1|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'       , ''  ],

  # SUB, SUBS (register-shifted register)
  ['subs{%c}{%q}'      , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|010|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|010|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  # SUB, SUBS (SP minus immediate)
  ['sub{%c}{%q}'       , '{SP,} SP, #imm.z*4'                    , 'T16: 10110000|1|imm:7'                                                         , ''  ],
  ['sub{%c}.W'         , '{Rd,} SP, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|0|1101|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} SP, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|0|1101|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} SP, #cnst.x'                     , 'T32: 11110|cnst:1|0|1101|1|1101|0|cnst:3|Rd!=1111|cnst:8'                      , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} SP, #imm.z'                      , 'T32: 11110|imm:1|10|1|0|1|0|1101|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['subw{%c}{%q}'      , '{Rd,} SP, #imm.z'                      , 'T32: 11110|imm:1|10|1|0|1|0|1101|0|imm:3|Rd:4|imm:8'                           , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} SP, #cnst.x'                     , 'A32: cond!=1111|0010|010|0|1101|Rd:4|cnst:12'                                  , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} SP, #cnst.x'                     , 'A32: cond!=1111|0010|010|1|1101|Rd:4|cnst:12'                                  , ''  ],

  # SUB, SUBS (SP minus register)
  ['sub{%c}{%q}'       , '{Rd,} SP, Rm, RRX'                     , 'T32: 1110101|1101|0|1101|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['sub{%c}.W'         , '{Rd,} SP, Rm'                          , 'T32: 1110101|1101|0|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} SP, Rm {, shift #amount}'        , 'T32: 1110101|1101|0|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} SP, Rm, RRX'                     , 'T32: 1110101|1101|1|1101|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} SP, Rm {, shift #amount}'        , 'T32: 1110101|1101|1|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} SP, Rm , RRX'                    , 'A32: cond!=1111|0000|010|0|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['sub{%c}{%q}'       , '{Rd,} SP, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|010|0|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} SP, Rm , RRX'                    , 'A32: cond!=1111|0000|010|1|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['subs{%c}{%q}'      , '{Rd,} SP, Rm {, shift #amount}'        , 'A32: cond!=1111|0000|010|1|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'           , ''  ],

  # SVC
  ['svc{%c}{%q}'       , '{#}imm.z'                              , 'T16: 1101111|1|imm:8'                                                          , ''  ],
  ['svc{%c}{%q}'       , '{#}imm.z'                              , 'A32: cond!=1111|1111|imm:24'                                                   , ''  ],

  # SXTAB
  ['sxtab{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'T32: 111110100|10|0|Rn!=1111|1111|Rd:4|1|0|amount:2|Rm:4'                      , ''  ],
  ['sxtab{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'A32: cond!=1111|01101|0|10|Rn!=1111|Rd:4|amount:2|0|0|0111|Rm:4'               , ''  ],

  # SXTAB16
  ['sxtab16{%c}{%q}'   , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'T32: 111110100|01|0|Rn!=1111|1111|Rd:4|1|0|amount:2|Rm:4'                      , ''  ],
  ['sxtab16{%c}{%q}'   , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'A32: cond!=1111|01101|0|00|Rn!=1111|Rd:4|amount:2|0|0|0111|Rm:4'               , ''  ],

  # SXTAH
  ['sxtah{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'T32: 111110100|00|0|Rn!=1111|1111|Rd:4|1|0|amount:2|Rm:4'                      , ''  ],
  ['sxtah{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'A32: cond!=1111|01101|0|11|Rn!=1111|Rd:4|amount:2|0|0|0111|Rm:4'               , ''  ],

  # SXTB
  ['sxtb{%c}{%q}'      , '{Rd,} Rm'                              , 'T16: 10110010|0|1|Rm:3|Rd:3'                                                   , ''  ],
  ['sxtb{%c}.W'        , '{Rd,} Rm'                              , 'T32: 111110100|10|0|1111|1111|Rd:4|1|0|rotate:2|Rm:4'                          , ''  ],
  ['sxtb{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'T32: 111110100|10|0|1111|1111|Rd:4|1|0|amount:2|Rm:4'                          , ''  ],
  ['sxtb{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'A32: cond!=1111|01101|0|10|1111|Rd:4|amount:2|0|0|0111|Rm:4'                   , ''  ],

  # SXTB16
  ['sxtb16{%c}{%q}'    , '{Rd,} Rm {, ROR #amount*8}'            , 'T32: 111110100|01|0|1111|1111|Rd:4|1|0|amount:2|Rm:4'                          , ''  ],
  ['sxtb16{%c}{%q}'    , '{Rd,} Rm {, ROR #amount*8}'            , 'A32: cond!=1111|01101|0|00|1111|Rd:4|amount:2|0|0|0111|Rm:4'                   , ''  ],

  # SXTH
  ['sxth{%c}{%q}'      , '{Rd,} Rm'                              , 'T16: 10110010|0|0|Rm:3|Rd:3'                                                   , ''  ],
  ['sxth{%c}.W'        , '{Rd,} Rm'                              , 'T32: 111110100|00|0|1111|1111|Rd:4|1|0|rotate:2|Rm:4'                          , ''  ],
  ['sxth{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'T32: 111110100|00|0|1111|1111|Rd:4|1|0|amount:2|Rm:4'                          , ''  ],
  ['sxth{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'A32: cond!=1111|01101|0|11|1111|Rd:4|amount:2|0|0|0111|Rm:4'                   , ''  ],

  # TBB, TBH
  ['tbb{%c}{%q}'       , '[Rn, Rm]'                              , 'T32: 111010001101|Rn:4|1|1|1|1|0|0|0|0|000|0|Rm:4'                             , ''  ],
  ['tbh{%c}{%q}'       , '[Rn, Rm, LSL #1]'                      , 'T32: 111010001101|Rn:4|1|1|1|1|0|0|0|0|000|1|Rm:4'                             , ''  ],

  # TEQ (immediate)
  ['teq{%c}{%q}'       , 'Rn, #cnst.c'                           , 'T32: 11110|cnst:1|0|0100|1|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['teq{%c}{%q}'       , 'Rn, #cnst.c'                           , 'A32: cond!=1111|00110|01|1|Rn:4|0|0|0|0|cnst:12'                               , ''  ],

  # TEQ (register)
  ['teq{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110101|0100|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['teq{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'T32: 1110101|0100|1|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|00010|01|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['teq{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'A32: cond!=1111|00010|01|1|Rn:4|0|0|0|0|amount!=00000|shift!=11|0|Rm:4'        , ''  ],

  # TEQ (register-shifted register)
  ['teq{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|00010|01|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  # TST (immediate)
  ['tst{%c}{%q}'       , 'Rn, #cnst.c'                           , 'T32: 11110|cnst:1|0|0000|1|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['tst{%c}{%q}'       , 'Rn, #cnst.c'                           , 'A32: cond!=1111|00110|00|1|Rn:4|0|0|0|0|cnst:12'                               , ''  ],

  # TST (register)
  ['tst{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 010000|1000|Rm:3|Rn:3'                                                    , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110101|0000|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['tst{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110101|0000|1|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'T32: 1110101|0000|1|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|00010|00|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm {, shift #amount}'              , 'A32: cond!=1111|00010|00|1|Rn:4|0|0|0|0|amount!=00000|shift!=11|0|Rm:4'        , ''  ],

  # TST (register-shifted register)
  ['tst{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|00010|00|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  # UADD16
  ['uadd16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|0|Rm:4'                   , ''  ],
  ['uadd16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|1|0|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  # UADD8
  ['uadd8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['uadd8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  # UASX
  ['uasx{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['uasx{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  # UBFX
  ['ubfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width'                  , 'T32: 11110|0|11|11|0|0|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                      , ''  ],
  ['ubfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width'                  , 'A32: cond!=1111|01111|1|1|width:5|Rd:4|lsb:5|101|Rn:4'                         , ''  ],

  # UDF
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'T16: 1101111|0|imm:8'                                                          , ''  ],
  ['udf{%c}.W'         , '{#}imm.z'                              , 'T32: 11110111111|1|imm:4|10|1|0|imm:12'                                        , ''  ],
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'T32: 11110111111|1|imm:4|10|1|0|imm:12'                                        , ''  ],
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'A32: 1110|01111111|imm:12|1111|imm:4'                                          , ''  ],

  # UDIV
  ['udiv{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110111|011|Rn:4|1111|Rd:4|1111|Rm:4'                                   , ''  ],
  ['udiv{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01110|011|Rd:4|1111|Rm:4|000|1|Rn:4'                           , ''  ],

  # UHADD16
  ['uhadd16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|1|1|0|Rm:4'                   , ''  ],
  ['uhadd16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|1|1|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  # UHADD8
  ['uhadd8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhadd8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  # UHASX
  ['uhasx{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhasx{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  # UHSAX
  ['uhsax{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhsax{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  # UHSUB16
  ['uhsub16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|1|1|0|Rm:4'                   , ''  ],
  ['uhsub16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|1|1|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  # UHSUB8
  ['uhsub8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhsub8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  # UMAAL
  ['umaal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|110|Rn:4|RdLo:4|RdHi:4|0110|Rm:4'                               , ''  ],
  ['umaal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|010|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  # UMLAL, UMLALS
  ['umlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|110|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['umlals{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|101|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['umlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|101|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  # UMULL, UMULLS
  ['umull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|010|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['umulls{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|100|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['umull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|100|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  # UQADD16
  ['uqadd16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|1|Rm:4'                   , ''  ],
  ['uqadd16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|1|1|0|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  # UQADD8
  ['uqadd8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqadd8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  # UQASX
  ['uqasx{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqasx{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  # UQSAX
  ['uqsax{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqsax{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  # UQSUB16
  ['uqsub16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|1|Rm:4'                   , ''  ],
  ['uqsub16{%c}{%q}'   , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|1|1|0|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  # UQSUB8
  ['uqsub8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqsub8{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  # USAD8
  ['usad8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|1|0|1|1|1|Rn:4|1|1|1|1|Rd:4|0|0|0|0|Rm:4'                   , ''  ],
  ['usad8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|1|1|0|0|0|Rd:4|1|1|1|1|Rm:4|0|0|0|1|Rn:4'                , ''  ],

  # USADA8
  ['usada8{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|111|Rn:4|Ra!=1111|Rd:4|00|00|Rm:4'                              , ''  ],
  ['usada8{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|01111000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                         , ''  ],

  # USAT
  ['usat{%c}{%q}'      , 'Rd, #imm, Rn, ASR #amount'             , 'T32: 11110|0|11|10|1|0|Rn:4|0|amount!=000|Rd:4|amount!=00|0|imm:5'             , ''  ],
  ['usat{%c}{%q}'      , 'Rd, #imm, Rn {, LSL #amount}'          , 'T32: 11110|0|11|10|0|0|Rn:4|0|amount:3|Rd:4|amount:2|0|imm:5'                  , ''  ],
  ['usat{%c}{%q}'      , 'Rd, #imm, Rn, ASR #amount'             , 'A32: cond!=1111|01101|1|1|imm:5|Rd:4|amount:5|1|01|Rn:4'                       , ''  ],
  ['usat{%c}{%q}'      , 'Rd, #imm, Rn {, LSL #amount}'          , 'A32: cond!=1111|01101|1|1|imm:5|Rd:4|amount:5|0|01|Rn:4'                       , ''  ],

  # USAT16
  ['usat16{%c}{%q}'    , 'Rd, #imm, Rn'                          , 'T32: 11110|0|11|10|1|0|Rn:4|0|000|Rd:4|00|0|0|imm:4'                           , ''  ],
  ['usat16{%c}{%q}'    , 'Rd, #imm, Rn'                          , 'A32: cond!=1111|01101|1|10|imm:4|Rd:4|1|1|1|1|0011|Rn:4'                       , ''  ],

  # USAX
  ['usax{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['usax{%c}{%q}'      , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  # USUB16
  ['usub16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|0|Rm:4'                   , ''  ],
  ['usub16{%c}{%q}'    , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|0|1|1|0|0|1|0|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  # USUB8
  ['usub8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['usub8{%c}{%q}'     , '{Rd,} Rn, Rm'                          , 'A32: cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  # UXTAB
  ['uxtab{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'T32: 111110100|10|1|Rn!=1111|1111|Rd:4|1|0|amount:2|Rm:4'                      , ''  ],
  ['uxtab{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'A32: cond!=1111|01101|1|10|Rn!=1111|Rd:4|amount:2|0|0|0111|Rm:4'               , ''  ],

  # UXTAB16
  ['uxtab16{%c}{%q}'   , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'T32: 111110100|01|1|Rn!=1111|1111|Rd:4|1|0|amount:2|Rm:4'                      , ''  ],
  ['uxtab16{%c}{%q}'   , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'A32: cond!=1111|01101|1|00|Rn!=1111|Rd:4|amount:2|0|0|0111|Rm:4'               , ''  ],

  # UXTAH
  ['uxtah{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'T32: 111110100|00|1|Rn!=1111|1111|Rd:4|1|0|amount:2|Rm:4'                      , ''  ],
  ['uxtah{%c}{%q}'     , '{Rd,} Rn, Rm {, ROR #amount*8}'        , 'A32: cond!=1111|01101|1|11|Rn!=1111|Rd:4|amount:2|0|0|0111|Rm:4'               , ''  ],

  # UXTB
  ['uxtb{%c}{%q}'      , '{Rd,} Rm'                              , 'T16: 10110010|1|1|Rm:3|Rd:3'                                                   , ''  ],
  ['uxtb{%c}.W'        , '{Rd,} Rm'                              , 'T32: 111110100|10|1|1111|1111|Rd:4|1|0|rotate:2|Rm:4'                          , ''  ],
  ['uxtb{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'T32: 111110100|10|1|1111|1111|Rd:4|1|0|amount:2|Rm:4'                          , ''  ],
  ['uxtb{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'A32: cond!=1111|01101|1|10|1111|Rd:4|amount:2|0|0|0111|Rm:4'                   , ''  ],

  # UXTB16
  ['uxtb16{%c}{%q}'    , '{Rd,} Rm {, ROR #amount*8}'            , 'T32: 111110100|01|1|1111|1111|Rd:4|1|0|amount:2|Rm:4'                          , ''  ],
  ['uxtb16{%c}{%q}'    , '{Rd,} Rm {, ROR #amount*8}'            , 'A32: cond!=1111|01101|1|00|1111|Rd:4|amount:2|0|0|0111|Rm:4'                   , ''  ],

  # UXTH
  ['uxth{%c}{%q}'      , '{Rd,} Rm'                              , 'T16: 10110010|1|0|Rm:3|Rd:3'                                                   , ''  ],
  ['uxth{%c}.W'        , '{Rd,} Rm'                              , 'T32: 111110100|00|1|1111|1111|Rd:4|1|0|rotate:2|Rm:4'                          , ''  ],
  ['uxth{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'T32: 111110100|00|1|1111|1111|Rd:4|1|0|amount:2|Rm:4'                          , ''  ],
  ['uxth{%c}{%q}'      , '{Rd,} Rm {, ROR #amount*8}'            , 'A32: cond!=1111|01101|1|11|1111|Rd:4|amount:2|0|0|0111|Rm:4'                   , ''  ],

  # WFE
  ['wfe{%c}{%q}'       , ''                                      , 'T16: 10111111|0010|0000'                                                       , ''  ],
  ['wfe{%c}.W'         , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0010'                              , ''  ],
  ['wfe{%c}{%q}'       , ''                                      , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|000000000010'                         , ''  ],

  # WFI
  ['wfi{%c}{%q}'       , ''                                      , 'T16: 10111111|0011|0000'                                                       , ''  ],
  ['wfi{%c}.W'         , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0011'                              , ''  ],
  ['wfi{%c}{%q}'       , ''                                      , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|000000000011'                         , ''  ],

  # YIELD
  ['yield{%c}{%q}'     , ''                                      , 'T16: 10111111|0001|0000'                                                       , ''  ],
  ['yield{%c}.W'       , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0001'                              , ''  ],
  ['yield{%c}{%q}'     , ''                                      , 'A32: cond!=1111|00110|0|10|00|00|1|1|1|1|000000000001'                         , ''  ],

);
