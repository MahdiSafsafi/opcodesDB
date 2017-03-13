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
#
#   - width.w = DecodeWidth => width = width + 1 - lsb.

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
  ['adc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|01|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1010|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1011|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # ADC, ADCS (register)
  ['adc%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|01|Rm:3|Rdn:3'                                                  , 'IT:IN'  ],
  ['adcs{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|01|Rm:3|Rdn:3'                                                  , 'IT:OUT'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0100|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['adc%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0100|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:IN'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0100|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0101|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['adcs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0101|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:OUT'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0101|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # ADC, ADCS (register-shifted register)
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # ADD, ADDS (immediate)
  ['add%c{%q}'         , 'Rd, Rn, #imm.z'                        , 'T16: 0001|110|imm:3|Rn:3|Rd:3'                                                 , 'IT:IN'  ],
  ['adds{%q}'          , 'Rd, Rn, #imm.z'                        , 'T16: 0001|110|imm:3|Rn:3|Rd:3'                                                 , 'IT:OUT'  ],
  ['add%c{%q}'         , 'Rdn, #imm.z'                           , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'IT:IN'  ],
  ['add%c{%q}'         , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'IT:IN'  ],
  ['adds{%q}'          , 'Rdn, #imm.z'                           , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'IT:OUT'  ],
  ['adds{%q}'          , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'IT:OUT'  ],
  ['add%c.W'           , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|00|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , 'IT:IN'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|00|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['adds.W'            , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|01|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , 'IT:OUT'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|01|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1000|00|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , ''  ],
  ['addw{%c}{%q}'      , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1000|00|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1000|Rn!=11x1|Rd:4|cnst:12'                               , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1001|Rn!=1101|Rd:4|cnst:12'                               , ''  ],

  # ADD, ADDS (register)
  ['add%c{%q}'         , 'Rd, Rn, Rm'                            , 'T16: 0001|100|Rm:3|Rn:3|Rd:3'                                                  , 'IT:IN'  ],
  ['adds{%q}'          , '{Rd}, Rn, Rm'                          , 'T16: 0001|100|Rm:3|Rn:3|Rd:3'                                                  , 'IT:OUT'  ],
  ['add%c{%q}'         , 'Rdn, Rm'                               , 'T16: 0100|0100|Rdn!=1|Rm!=1101|Rdn!=101'                                       , 'IT:IN'  ],
  ['add{%c}{%q}'       , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0100|Rdn!=1|Rm!=1101|Rdn!=101'                                       , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0000|Rn!=1101|0000|Rd:4|0011|Rm:4'                              , ''  ],
  ['add%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0000|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'IT:IN'  ],
  ['add{%c}.W'         , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0000|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0000|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0001|Rn!=1101|0000|Rd!=1111|0011|Rm:4'                          , ''  ],
  ['adds.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0001|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'      , 'IT:OUT'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0001|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4' , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1000|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1000|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1001|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1001|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , ''  ],

  # ADD, ADDS (register-shifted register)
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # ADD, ADDS (SP plus immediate)
  ['add{%c}{%q}'       , 'Rd, SP, #imm.z*4'                      , 'T16: 1010|1|Rd:3|imm:8'                                                        , ''  ],
  ['add{%c}{%q}'       , '{SP}, SP, #imm.z*4'                    , 'T16: 1011|0000|0|imm:7'                                                        , ''  ],
  ['add{%c}.W'         , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|0011|010|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|0011|010|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|0111|010|cnst:3|Rd!=1111|cnst:8'                       , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1000|0011|010|imm:3|Rd:4|imm:8'                              , ''  ],
  ['addw{%c}{%q}'      , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1000|0011|010|imm:3|Rd:4|imm:8'                              , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|1000|1101|Rd:4|cnst:12'                                   , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|1001|1101|Rd:4|cnst:12'                                   , ''  ],

  # ADD, ADDS (SP plus register)
  ['add{%c}{%q}'       , '{Rdm}, SP, Rdm'                        , 'T16: 0100|0100|DM:1|1101|Rdm:3'                                                , ''  ],
  ['add{%c}{%q}'       , '{SP}, SP, Rm'                          , 'T16: 0100|0100|1|Rm!=1101|101'                                                 , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|0000|1101|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['add{%c}.W'         , '{Rd}, SP, Rm'                          , 'T32: 1110|1011|0000|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|0000|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|0001|1101|0000|Rd!=1111|0011|Rm:4'                              , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|0001|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|1000|1101|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1000|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|1001|1101|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1001|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # ADD (immediate, to PC)
  ['add{%c}{%q}'       , 'Rd, PC, #imm.z*4'                      , 'T16: 1010|0|Rd:3|imm:8'                                                        , ''  ],
  ['addw{%c}{%q}'      , 'Rd, PC, #imm.z'                        , 'T32: 1111|0|imm:1|1000|0011|110|imm:3|Rd:4|imm:8'                              , ''  ],
  ['add{%c}{%q}'       , 'Rd, PC, #imm.z'                        , 'T32: 1111|0|imm:1|1000|0011|110|imm:3|Rd:4|imm:8'                              , ''  ],
  ['add{%c}{%q}'       , 'Rd, PC, #cnst.x'                       , 'A32: cond!=1111|0010|1000|1111|Rd:4|cnst:12'                                   , ''  ],

  # ADR
  ['adr{%c}{%q}'       , 'Rd, rel.z*4'                           , 'T16: 1010|0|Rd:3|rel:8'                                                        , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.z'                             , 'T32: 1111|0|rel:1|1010|1011|110|rel:3|Rd:4|rel:8'                              , ''  ],
  ['adr{%c}.W'         , 'Rd, rel.z'                             , 'T32: 1111|0|rel:1|1000|0011|110|rel:3|Rd:4|rel:8'                              , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.z'                             , 'T32: 1111|0|rel:1|1000|0011|110|rel:3|Rd:4|rel:8'                              , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.x'                             , 'A32: cond!=1111|0010|1000|1111|Rd:4|rel:12'                                    , ''  ],
  ['adr{%c}{%q}'       , 'Rd, rel.x'                             , 'A32: cond!=1111|0010|0100|1111|Rd:4|rel:12'                                    , ''  ],

  # AND, ANDS (immediate)
  ['and{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|01|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                      , ''  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0000|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0001|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # AND, ANDS (register)
  ['and%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|00|Rm:3|Rdn:3'                                                  , 'IT:IN'  ],
  ['ands{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|00|Rm:3|Rdn:3'                                                  , 'IT:OUT'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0000|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['and%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0000|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:IN'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0000|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0001|Rn:4|0000|Rd!=1111|0011|Rm:4'                              , ''  ],
  ['ands.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0001|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'          , 'IT:OUT'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0001|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # AND, ANDS (register-shifted register)
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # ASR (immediate)
  ['asr%c{%q}'         , '{Rd}, Rm, #imm'                        , 'T16: 0001|0|imm:5|Rm:3|Rd:3'                                                   , 'IT:IN'  ],
  ['asr%c.W'           , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , 'IT:IN'  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , ''  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm:5|100|Rm:4'                            , ''  ],

  # ASR (register)
  ['asr%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['asr%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0100|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0100|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0101|Rm:4'                            , ''  ],

  # ASRS (immediate)
  ['asrs{%q}'          , '{Rd}, Rm, #imm'                        , 'T16: 0001|0|imm:5|Rm:3|Rd:3'                                                   , 'IT:OUT'  ],
  ['asrs.W'            , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , 'IT:OUT'  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , ''  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm:5|100|Rm:4'                            , ''  ],

  # ASRS (register)
  ['asrs{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['asrs.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0101|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0101|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0101|Rm:4'                            , ''  ],

  # B
  ['b%c{%q}'           , 'rel.s*2'                               , 'T16: 1101|cond!=111x|rel:8'                                                    , ''  ],
  ['b{%c}{%q}'         , 'rel.s*2'                               , 'T16: 1110|0|rel:11'                                                            , 'IT:IN:LAST:OUT'  ],
  ['b%c.W'             , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'          , ''  ],
  ['b%c{%q}'           , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'          , ''  ],
  ['b{%c}.W'           , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                          , ''  ],
  ['b{%c}{%q}'         , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                          , ''  ],
  ['b{%c}{%q}'         , 'rel.s*4'                               , 'A32: cond!=1111|1010|rel:24'                                                   , ''  ],

  # BFC
  ['bfc{%c}{%q}'       , 'Rd, #lsb, #width.w'                    , 'T32: 1111|0011|0110|1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                         , ''  ],
  ['bfc{%c}{%q}'       , 'Rd, #lsb, #width.w'                    , 'A32: cond!=1111|0111|110|width:5|Rd:4|lsb:5|0011|111'                          , ''  ],

  # BFI
  ['bfi{%c}{%q}'       , 'Rd, Rn, #lsb, #width.w'                , 'T32: 1111|0011|0110|Rn!=1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                     , ''  ],
  ['bfi{%c}{%q}'       , 'Rd, Rn, #lsb, #width.w'                , 'A32: cond!=1111|0111|110|width:5|Rd:4|lsb:5|001|Rn!=1111'                      , ''  ],

  # BIC, BICS (immediate)
  ['bic{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|10|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|11|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1100|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1101|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # BIC, BICS (register)
  ['bic%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|10|Rm:3|Rdn:3'                                                  , 'IT:IN'  ],
  ['bics{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|10|Rm:3|Rdn:3'                                                  , 'IT:OUT'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0010|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['bic%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0010|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:IN'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0010|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0011|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['bics.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0011|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:OUT'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0011|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # BIC, BICS (register-shifted register)
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # BKPT
  ['bkpt{%q}'          , '{#}imm.z'                              , 'T16: 1011|1110|imm:8'                                                          , ''  ],
  ['bkpt{%q}'          , '{#}imm'                                , 'A32: cond!=1111|0001|0010|imm:12|0111|imm:4'                                   , ''  ],

  # BL, BLX (immediate)
  ['bl{%c}{%q}'        , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|rel.D:10|11|J1:1|1|J2:1|rel.E:11'                          , ''  ],
  ['blx{%c}{%q}'       , 'rel.s*4'                               , 'T32: 1111|0|rel.A:1|rel.D:10|11|J1:1|0|J2:1|rel.E:10|H'                        , ''  ],
  ['bl{%c}{%q}'        , 'rel.s*4'                               , 'A32: cond!=1111|1011|rel:24'                                                   , ''  ],
  ['blx{%c}{%q}'       , 'rel.s*2'                               , 'A32: 1111|101|rel.B:1|rel.A:24'                                                , ''  ],

  # BLX (register)
  ['blx{%c}{%q}'       , 'Rm'                                    , 'T16: 0100|0111|1|Rm:4|000'                                                     , ''  ],
  ['blx{%c}{%q}'       , 'Rm'                                    , 'A32: cond!=1111|0001|0010|1111|1111|1111|0011|Rm:4'                            , ''  ],

  # BX
  ['bx{%c}{%q}'        , 'Rm'                                    , 'T16: 0100|0111|0|Rm:4|000'                                                     , ''  ],
  ['bx{%c}{%q}'        , 'Rm'                                    , 'A32: cond!=1111|0001|0010|1111|1111|1111|0001|Rm:4'                            , ''  ],

  # BXJ
  ['bxj{%c}{%q}'       , 'Rm'                                    , 'T32: 1111|0011|1100|Rm:4|1000|1111|0000|0000'                                  , ''  ],
  ['bxj{%c}{%q}'       , 'Rm'                                    , 'A32: cond!=1111|0001|0010|1111|1111|1111|0010|Rm:4'                            , ''  ],

  # CBNZ, CBZ
  ['cbnz{%q}'          , 'Rn, rel.z*2'                           , 'T16: 1011|10|rel:1|1|rel:5|Rn:3'                                               , ''  ],
  ['cbz{%q}'           , 'Rn, rel.z*2'                           , 'T16: 1011|00|rel:1|1|rel:5|Rn:3'                                               , ''  ],

  # CLREX
  ['clrex{%c}{%q}'     , ''                                      , 'T32: 1111|0011|1011|1111|1000|1111|0010|1111'                                  , ''  ],
  ['clrex{%c}{%q}'     , ''                                      , 'A32: 1111|0101|0111|1111|1111|0000|0001|1111'                                  , ''  ],

  # CLZ
  ['clz{%c}{%q}'       , 'Rd, Rm'                                , 'T32: 1111|1010|1011|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['clz{%c}{%q}'       , 'Rd, Rm'                                , 'A32: cond!=1111|0001|0110|1111|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # CMN (immediate)
  ['cmn{%c}{%q}'       , 'Rn, #cnst.x'                           , 'T32: 1111|0|cnst:1|0100|01|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, #cnst.x'                           , 'A32: cond!=1111|0011|0111|Rn:4|0000|cnst:12'                                   , ''  ],

  # CMN (register)
  ['cmn{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0010|11|Rm:3|Rn:3'                                                   , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1011|0001|Rn:4|0000|1111|0011|Rm:4'                                  , ''  ],
  ['cmn{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110|1011|0001|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'T32: 1110|1011|0001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0111|Rn:4|0000|0000|0110|Rm:4'                            , ''  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0111|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # CMN (register-shifted register)
  ['cmn{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0111|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # CMP (immediate)
  ['cmp{%c}{%q}'       , 'Rn, #imm.z'                            , 'T16: 0010|1|Rn:3|imm:8'                                                        , ''  ],
  ['cmp{%c}.W'         , 'Rn, #cnst.x'                           , 'T32: 1111|0|cnst:1|0110|11|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, #cnst.x'                           , 'T32: 1111|0|cnst:1|0110|11|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, #cnst.x'                           , 'A32: cond!=1111|0011|0101|Rn:4|0000|cnst:12'                                   , ''  ],

  # CMP (register)
  ['cmp{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0010|10|Rm:3|Rn:3'                                                   , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0101|Rn:1|Rm:3|Rn:4'                                                 , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1011|1011|Rn:4|0000|1111|0011|Rm:4'                                  , ''  ],
  ['cmp{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110|1011|1011|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, shift #amount'                 , 'T32: 1110|1011|1011|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0101|Rn:4|0000|0000|0110|Rm:4'                            , ''  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0101|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # CMP (register-shifted register)
  ['cmp{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0101|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # CPS, CPSID, CPSIE
  ['cpsid{%q}'         , 'iflags'                                , 'T16: 1011|0110|0111|0|A|I|F'                                                   , ''  ],
  ['cpsie{%q}'         , 'iflags'                                , 'T16: 1011|0110|0110|0|A|I|F'                                                   , ''  ],
  ['cps{%q}'           , '#mode'                                 , 'T32: 1111|0011|1010|1111|1000|0001|A|I|F|mode:5'                               , ''  ],
  ['cpsid.W'           , 'iflags'                                , 'T32: 1111|0011|1010|1111|1000|0110|A|I|F|mode:5'                               , ''  ],
  ['cpsid{%q}'         , 'iflags, #mode'                         , 'T32: 1111|0011|1010|1111|1000|0111|A|I|F|mode:5'                               , ''  ],
  ['cpsie.W'           , 'iflags'                                , 'T32: 1111|0011|1010|1111|1000|0100|A|I|F|mode:5'                               , ''  ],
  ['cpsie{%q}'         , 'iflags, #mode'                         , 'T32: 1111|0011|1010|1111|1000|0101|A|I|F|mode:5'                               , ''  ],
  ['cps{%q}'           , '#mode'                                 , 'A32: 1111|0001|0000|0010|0000|000|A|I|F|0|mode:5'                              , ''  ],
  ['cpsid{%q}'         , 'iflags'                                , 'A32: 1111|0001|0000|1100|0000|000|A|I|F|0|mode:5'                              , ''  ],
  ['cpsid{%q}'         , 'iflags , #mode'                        , 'A32: 1111|0001|0000|1110|0000|000|A|I|F|0|mode:5'                              , ''  ],
  ['cpsie{%q}'         , 'iflags'                                , 'A32: 1111|0001|0000|1000|0000|000|A|I|F|0|mode:5'                              , ''  ],
  ['cpsie{%q}'         , 'iflags , #mode'                        , 'A32: 1111|0001|0000|1010|0000|000|A|I|F|0|mode:5'                              , ''  ],

  # CRC32
  ['crc32b{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['crc32h{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1001|Rm:4'                                  , ''  ],
  ['crc32w{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1010|Rm:4'                                  , ''  ],
  ['crc32b{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0000|0100|Rm:4'                            , ''  ],
  ['crc32h{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0000|0100|Rm:4'                            , ''  ],
  ['crc32w{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0000|0100|Rm:4'                            , ''  ],

  # CRC32C
  ['crc32cb{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['crc32ch{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1001|Rm:4'                                  , ''  ],
  ['crc32cw{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1010|Rm:4'                                  , ''  ],
  ['crc32cb{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0010|0100|Rm:4'                            , ''  ],
  ['crc32ch{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0010|0100|Rm:4'                            , ''  ],
  ['crc32cw{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0010|0100|Rm:4'                            , ''  ],

  # DBG
  ['dbg{%c}{%q}'       , '#option'                               , 'T32: 1111|0011|1010|1111|1000|0000|1111|option:4'                              , ''  ],
  ['dbg{%c}{%q}'       , '#option'                               , 'A32: cond!=1111|0011|0010|0000|1111|0000|1111|option:4'                        , ''  ],

  # DCPS1, DCPS2, DCPS3
  ['dcps1'             , ''                                      , 'T32: 1111|0111|1000|1111|1000|0000|0000|0001'                                  , ''  ],
  ['dcps2'             , ''                                      , 'T32: 1111|0111|1000|1111|1000|0000|0000|0010'                                  , ''  ],
  ['dcps3'             , ''                                      , 'T32: 1111|0111|1000|1111|1000|0000|0000|0011'                                  , ''  ],

  # DMB
  ['dmb{%c}{%q}'       , '{option}'                              , 'T32: 1111|0011|1011|1111|1000|1111|0101|option:4'                              , ''  ],
  ['dmb{%c}{%q}'       , '{option}'                              , 'A32: 1111|0101|0111|1111|1111|0000|0101|option:4'                              , ''  ],

  # DSB
  ['dsb{%c}{%q}'       , '{option}'                              , 'T32: 1111|0011|1011|1111|1000|1111|0100|option:4'                              , ''  ],
  ['dsb{%c}{%q}'       , '{option}'                              , 'A32: 1111|0101|0111|1111|1111|0000|0100|option:4'                              , ''  ],

  # EOR, EORS (immediate)
  ['eor{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0010|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0010|01|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                      , ''  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0010|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0011|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # EOR, EORS (register)
  ['eor%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|01|Rm:3|Rdn:3'                                                  , 'IT:IN'  ],
  ['eors{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|01|Rm:3|Rdn:3'                                                  , 'IT:OUT'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|1000|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['eor%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|1000|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:IN'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|1000|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|1001|Rn:4|0000|Rd!=1111|0011|Rm:4'                              , ''  ],
  ['eors.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|1001|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'          , 'IT:OUT'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|1001|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # EOR, EORS (register-shifted register)
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # ERET
  ['eret{%c}{%q}'      , ''                                      , 'T32: 1111|0011|1101|1110|1000|1111|0000|0000'                                  , ''  ],
  ['eret{%c}{%q}'      , ''                                      , 'A32: cond!=1111|0001|0110|0000|0000|0000|0110|1110'                            , ''  ],

  # HLT
  ['hlt{%q}'           , '{#}imm'                                , 'T16: 1011|1010|10|imm:6'                                                       , ''  ],
  ['hlt{%q}'           , '{#}imm'                                , 'A32: cond!=1111|0001|0000|imm:12|0111|imm:4'                                   , ''  ],

  # HVC
  ['hvc{%q}'           , '{#}imm'                                , 'T32: 1111|0111|1110|imm:4|1000|imm:12'                                         , ''  ],
  ['hvc{%q}'           , '{#}imm'                                , 'A32: cond!=1111|0001|0100|imm:12|0111|imm:4'                                   , ''  ],

  # ISB
  ['isb{%c}{%q}'       , '{option}'                              , 'T32: 1111|0011|1011|1111|1000|1111|0110|option:4'                              , ''  ],
  ['isb{%c}{%q}'       , '{option}'                              , 'A32: 1111|0101|0111|1111|1111|0000|0110|option:4'                              , ''  ],

  # IT
  ['it{%x{%y{%z}}}{%q}', 'cond'                                  , 'T16: 1011|1111|cond:4|x/y/z!=0000'                                             , ''  ],

  # LDA
  ['lda{%c}{%q}'       , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1010|1111'                                  , ''  ],
  ['lda{%c}{%q}'       , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1100|1001|1111'                            , ''  ],

  # LDAB
  ['ldab{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1000|1111'                                  , ''  ],
  ['ldab{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1100|1001|1111'                            , ''  ],

  # LDAEX
  ['ldaex{%c}{%q}'     , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1110|1111'                                  , ''  ],
  ['ldaex{%c}{%q}'     , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1110|1001|1111'                            , ''  ],

  # LDAEXB
  ['ldaexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1100|1111'                                  , ''  ],
  ['ldaexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1110|1001|1111'                            , ''  ],

  # LDAEXD
  ['ldaexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'T32: 1110|1000|1101|Rn:4|Rt:4|Rt2:4|1111|1111'                                 , ''  ],
  ['ldaexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'A32: cond!=1111|0001|1011|Rn:4|Rt:4|1110|1001|1111'                            , ''  ],

  # LDAEXH
  ['ldaexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1101|1111'                                  , ''  ],
  ['ldaexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1110|1001|1111'                            , ''  ],

  # LDAH
  ['ldah{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1001|1111'                                  , ''  ],
  ['ldah{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1100|1001|1111'                            , ''  ],

  # LDC (immediate)
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1101|U|001|Rn!=1111|0101|1110|imm:8'                                 , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1100|U|011|Rn!=1111|0101|1110|imm:8'                                 , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1101|U|011|Rn!=1111|0101|1110|imm:8'                                 , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'T32: 1110|1100|1001|Rn!=1111|0101|1110|option:8'                               , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'A32: cond!=1111|1101|U|001|Rn!=1111|0101|1110|imm:8'                           , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'A32: cond!=1111|1100|U|011|Rn!=1111|0101|1110|imm:8'                           , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'A32: cond!=1111|1101|U|011|Rn!=1111|0101|1110|imm:8'                           , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'A32: cond!=1111|1100|1001|Rn!=1111|0101|1110|option:8'                         , ''  ],

  # LDC (literal)
  ['ldc{%c}{%q}'       , 'p14, c5, rel.z*4'                      , 'T32: 1110|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|rel:8'                         , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC, #{+/-}imm.z*4]'          , 'T32: 1110|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|imm:8'                         , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, rel.z*4'                      , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|rel:8'                   , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC, #{+/-}imm.z*4]'          , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|imm:8'                   , ''  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC], option'                 , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|option:8'                , ''  ],

  # LDM, LDMIA, LDMFD
  ['ldm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'T16: 1100|1|Rn:3|list:8'                                                       , ''  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T16: 1100|1|Rn:3|list:8'                                                       , ''  ],
  ['ldm{ia}{%c}.W'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmfd{%c}.W'       , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|1|Rn:4|list:16'                                      , ''  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|1|Rn:4|list:16'                                      , ''  ],

  # LDM (exception return)
  ['ldm{%amode}{%c}{%q}', 'Rn{!}, list'                           , 'A32: cond!=1111|100|P|U|1|W|1|Rn:4|1|list:15'                                  , ''  ],

  # LDM (User registers)
  ['ldm{%amode}{%c}{%q}', 'Rn, list'                              , 'A32: cond!=1111|100|P|U|101|Rn:4|0|list:15'                                    , ''  ],

  # LDMDA, LDMFA
  ['ldmda{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|1|Rn:4|list:16'                                      , ''  ],
  ['ldmfa{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|1|Rn:4|list:16'                                      , ''  ],

  # LDMDB, LDMEA
  ['ldmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmea{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|1|Rn:4|list:1|list:1|0|list:13'                            , ''  ],
  ['ldmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|1|Rn:4|list:16'                                      , ''  ],
  ['ldmea{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|1|Rn:4|list:16'                                      , ''  ],

  # LDMIB, LDMED
  ['ldmib{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|1|Rn:4|list:16'                                      , ''  ],
  ['ldmed{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|1|Rn:4|list:16'                                      , ''  ],

  # LDR (immediate)
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z*4}]'               , 'T16: 0110|1|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [SP, {#{+}imm.z*4}]'               , 'T16: 1001|1|Rt:3|imm:8'                                                        , ''  ],
  ['ldr{%c}.W'         , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1101|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1101|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|1100|imm:8'                                  , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|001|Rn!=1111|Rt:4|imm:12'                               , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|001|Rn!=1111|Rt:4|imm:12'                               , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|011|Rn!=1111|Rt:4|imm:12'                               , ''  ],

  # LDR (literal)
  ['ldr{%c}{%q}'       , 'Rt, rel.z*4'                           , 'T16: 0100|1|Rt:3|rel:8'                                                        , ''  ],
  ['ldr{%c}.W'         , 'Rt, rel.z'                             , 'T32: 1111|1000|U|1011|111|Rt:4|rel:12'                                         , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, rel.z'                             , 'T32: 1111|1000|U|1011|111|Rt:4|rel:12'                                         , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1000|U|1011|111|Rt:4|imm:12'                                         , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, rel.z'                             , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1111|1|Rt:4|rel:12'                          , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1111|1|Rt:4|imm:12'                          , ''  ],

  # LDR (register)
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|100|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['ldr{%c}.W'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|001|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|001|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|011|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # LDRB (immediate)
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T16: 0111|1|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['ldrb{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1001|Rn!=1111|Rt!=1111|imm:12'                                  , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1001|Rn!=1111|Rt!=1111|imm:12'                                  , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|1100|imm:8'                              , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|101|Rn!=1111|Rt:4|imm:12'                               , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|101|Rn!=1111|Rt:4|imm:12'                               , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|111|Rn!=1111|Rt:4|imm:12'                               , ''  ],

  # LDRB (literal)
  ['ldrb{%c}{%q}'      , 'Rt, rel.z'                             , 'T32: 1111|1000|U|0011|111|Rt!=1111|rel:12'                                     , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1000|U|0011|111|Rt!=1111|imm:12'                                     , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, rel.z'                             , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1111|1|Rt:4|rel:12'                          , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1111|1|Rt:4|imm:12'                          , ''  ],

  # LDRB (register)
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|110|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['ldrb{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|101|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|101|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|111|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # LDRBT
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|111|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|111|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # LDRD (immediate)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1001|U|101|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1000|U|111|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1001|U|111|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z}]'          , 'A32: cond!=1111|0001|U|100|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z'            , 'A32: cond!=1111|0000|U|100|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z]!'           , 'A32: cond!=1111|0001|U|110|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , ''  ],

  # LDRD (literal)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, rel.z*4'                      , 'T32: 1110|100|P!=0|U|1|W!=0|1111|1|Rt:4|Rt2:4|rel:8'                           , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [PC, #{+/-}imm.z]'            , 'T32: 1110|100|P!=0|U|1|W!=0|1111|1|Rt:4|Rt2:4|imm:8'                           , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, rel.z'                        , 'A32: cond!=1111|0001|U|1001|111|Rt:4|rel:4|1101|rel:4'                         , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [PC, #{+/-}imm.z]'            , 'A32: cond!=1111|0001|U|1001|111|Rt:4|imm:4|1101|imm:4'                         , ''  ],

  # LDRD (register)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]'                , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], {+/-}Rm'                , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]!'               , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],

  # LDREX
  ['ldrex{%c}{%q}'     , 'Rt, [Rn, {#imm.z*4}]'                  , 'T32: 1110|1000|0101|Rn:4|Rt:4|1111|imm:8'                                      , ''  ],
  ['ldrex{%c}{%q}'     , 'Rt, [Rn, {{#}0}]'                      , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1111|1001|1111'                            , ''  ],

  # LDREXB
  ['ldrexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|0100|1111'                                  , ''  ],
  ['ldrexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1111|1001|1111'                            , ''  ],

  # LDREXD
  ['ldrexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'T32: 1110|1000|1101|Rn:4|Rt:4|Rt2:4|0111|1111'                                 , ''  ],
  ['ldrexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'A32: cond!=1111|0001|1011|Rn:4|Rt:4|1111|1001|1111'                            , ''  ],

  # LDREXH
  ['ldrexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|0101|1111'                                  , ''  ],
  ['ldrexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1111|1001|1111'                            , ''  ],

  # LDRH (immediate)
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z*2}]'               , 'T16: 1000|1|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['ldrh{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1011|Rn!=1111|Rt!=1111|imm:12'                                  , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1011|Rn!=1111|Rt!=1111|imm:12'                                  , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|1100|imm:8'                              , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1011|imm:4'                     , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1011|imm:4'                     , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1011|imm:4'                     , ''  ],

  # LDRH (literal)
  ['ldrh{%c}{%q}'      , 'Rt, rel.z'                             , 'T32: 1111|1000|U|0111|111|Rt!=1111|rel:12'                                     , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1000|U|0111|111|Rt!=1111|imm:12'                                     , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1011|rel:4'                , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1011|imm:4'                , ''  ],

  # LDRH (register)
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|101|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['ldrh{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],

  # LDRHT
  ['ldrht{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['ldrht{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1011|imm:4'                         , ''  ],
  ['ldrht{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],

  # LDRSB (immediate)
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|1001|Rn!=1111|Rt!=1111|imm:12'                                  , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|1100|imm:8'                                  , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , ''  ],

  # LDRSB (literal)
  ['ldrsb{%c}{%q}'     , 'Rt, rel.z'                             , 'T32: 1111|1001|U|0011|111|Rt!=1111|rel:12'                                     , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1001|U|0011|111|Rt!=1111|imm:12'                                     , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1101|rel:4'                , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1101|imm:4'                , ''  ],

  # LDRSB (register)
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|011|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['ldrsb{%c}.W'       , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1001|0001|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1001|0001|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],

  # LDRSBT
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1101|imm:4'                         , ''  ],
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1101|Rm:4'                           , ''  ],

  # LDRSH (immediate)
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|1011|Rn!=1111|Rt!=1111|imm:12'                                  , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|1100|imm:8'                              , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1111|imm:4'                     , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1111|imm:4'                     , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1111|imm:4'                     , ''  ],

  # LDRSH (literal)
  ['ldrsh{%c}{%q}'     , 'Rt, rel.z'                             , 'T32: 1111|1001|U|0111|111|Rt!=1111|rel:12'                                     , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1001|U|0111|111|Rt!=1111|imm:12'                                     , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1111|rel:4'                , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1111|imm:4'                , ''  ],

  # LDRSH (register)
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|111|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['ldrsh{%c}.W'       , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],

  # LDRSHT
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1111|imm:4'                         , ''  ],
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],

  # LDRT
  ['ldrt{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['ldrt{%c}{%q}'      , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|011|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['ldrt{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|011|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # LSL (immediate)
  ['lsl%c{%q}'         , '{Rd}, Rm, #imm'                        , 'T16: 0000|0|imm!=00000|Rm:3|Rd:3'                                              , 'IT:IN'  ],
  ['lsl%c.W'           , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , 'IT:IN'  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , ''  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm!=00000|000|Rm:4'                       , ''  ],

  # LSL (register)
  ['lsl%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['lsl%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0000|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0000|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0001|Rm:4'                            , ''  ],

  # LSLS (immediate)
  ['lsls{%q}'          , '{Rd}, Rm, #imm'                        , 'T16: 0000|0|imm!=00000|Rm:3|Rd:3'                                              , 'IT:OUT'  ],
  ['lsls.W'            , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , 'IT:OUT'  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , ''  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm!=00000|000|Rm:4'                       , ''  ],

  # LSLS (register)
  ['lsls{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['lsls.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0001|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0001|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0001|Rm:4'                            , ''  ],

  # LSR (immediate)
  ['lsr%c{%q}'         , '{Rd}, Rm, #imm'                        , 'T16: 0000|1|imm:5|Rm:3|Rd:3'                                                   , 'IT:IN'  ],
  ['lsr%c.W'           , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , 'IT:IN'  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , ''  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm:5|010|Rm:4'                            , ''  ],

  # LSR (register)
  ['lsr%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['lsr%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0010|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0010|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0011|Rm:4'                            , ''  ],

  # LSRS (immediate)
  ['lsrs{%q}'          , '{Rd}, Rm, #imm'                        , 'T16: 0000|1|imm:5|Rm:3|Rd:3'                                                   , 'IT:OUT'  ],
  ['lsrs.W'            , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , 'IT:OUT'  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , ''  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm:5|010|Rm:4'                            , ''  ],

  # LSRS (register)
  ['lsrs{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['lsrs.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0011|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0011|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0011|Rm:4'                            , ''  ],

  # MCR
  ['mcr{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'T32: 1110|1110|opc1:3|0|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                 , ''  ],
  ['mcr{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'A32: cond!=1111|1110|opc1:3|0|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'           , ''  ],

  # MCRR
  ['mcrr{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'T32: 1110|1100|0100|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                       , ''  ],
  ['mcrr{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'A32: cond!=1111|1100|0100|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                 , ''  ],

  # MLA, MLAS
  ['mla{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0000|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['mlas{%c}{%q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|0011|Rd:4|Ra:4|Rm:4|1001|Rn:4'                            , ''  ],
  ['mla{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|0010|Rd:4|Ra:4|Rm:4|1001|Rn:4'                            , ''  ],

  # MLS
  ['mls{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0000|Rn:4|Ra:4|Rd:4|0001|Rm:4'                                  , ''  ],
  ['mls{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|0110|Rd:4|Ra:4|Rm:4|1001|Rn:4'                            , ''  ],

  # MOV, MOVS (immediate)
  ['mov%c{%q}'         , 'Rd, #imm.z'                            , 'T16: 0010|0|Rd:3|imm:8'                                                        , 'IT:IN'  ],
  ['movs{%q}'          , 'Rd, #imm.z'                            , 'T16: 0010|0|Rd:3|imm:8'                                                        , 'IT:OUT'  ],
  ['mov%c.W'           , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0011|110|cnst:3|Rd:4|cnst:8'                           , 'IT:IN'  ],
  ['mov{%c}{%q}'       , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0011|110|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['movs.W'            , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0111|110|cnst:3|Rd:4|cnst:8'                           , 'IT:OUT'  ],
  ['movs{%c}{%q}'      , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0111|110|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #imm.z'                            , 'T32: 1111|0|imm.B:1|1001|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , ''  ],
  ['movw{%c}{%q}'      , 'Rd, #imm.z'                            , 'T32: 1111|0|imm.B:1|1001|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1010|0000|Rd:4|cnst:12'                                   , ''  ],
  ['movs{%c}{%q}'      , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1011|0000|Rd:4|cnst:12'                                   , ''  ],
  ['mov{%c}{%q}'       , 'Rd, #imm.z'                            , 'A32: cond!=1111|0011|0000|imm:4|Rd:4|imm:12'                                   , ''  ],
  ['movw{%c}{%q}'      , 'Rd, #imm.z'                            , 'A32: cond!=1111|0011|0000|imm:4|Rd:4|imm:12'                                   , ''  ],

  # MOV, MOVS (register)
  ['mov{%c}{%q}'       , 'Rd, Rm'                                , 'T16: 0100|0110|Rd:1|Rm:3|Rd:4'                                                 , ''  ],
  ['mov%c{%q}'         , 'Rd, Rm, {shift #amount}'               , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                         , 'IT:IN'  ],
  ['movs{%q}'          , 'Rd, Rm, {shift #amount}'               , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                         , 'IT:OUT'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0100|1111|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['mov{%c}.W'         , 'Rd, Rm, {LSL #0}'                      , 'T32: 1110|1010|0100|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['mov%c.W'           , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0100|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'IT:IN'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0100|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0101|1111|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['movs.W'            , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0101|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'IT:OUT'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0101|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1010|0000|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1010|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1011|0000|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1011|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # MOV, MOVS (register-shifted register)
  ['mov%c{%q}'         , 'Rdm, Rdm, ASR Rs'                      , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, ASR Rs'                      , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, LSL Rs'                      , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, LSL Rs'                      , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, LSR Rs'                      , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, LSR Rs'                      , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, ROR Rs'                      , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, ROR Rs'                      , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['movs.W'            , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                            , 'IT:OUT'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                            , ''  ],
  ['mov%c.W'           , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                            , 'IT:IN'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                            , ''  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # MOVT
  ['movt{%c}{%q}'      , 'Rd, #imm'                              , 'T32: 1111|0|imm.B:1|1011|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , ''  ],
  ['movt{%c}{%q}'      , 'Rd, #imm'                              , 'A32: cond!=1111|0011|0100|imm:4|Rd:4|imm:12'                                   , ''  ],

  # MRC
  ['mrc{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'T32: 1110|1110|opc1:3|1|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                 , ''  ],
  ['mrc{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'A32: cond!=1111|1110|opc1:3|1|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'           , ''  ],

  # MRRC
  ['mrrc{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'T32: 1110|1100|0101|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                       , ''  ],
  ['mrrc{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'A32: cond!=1111|1100|0101|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                 , ''  ],

  # MRS
  ['mrs{%c}{%q}'       , 'Rd, sreg'                              , 'T32: 1111|0011|111|sreg:1|1111|1000|Rd:4|0000|0000'                            , ''  ],
  ['mrs{%c}{%q}'       , 'Rd, sreg'                              , 'A32: cond!=1111|0001|0|sreg:1|0011|11|Rd:4|0000|0000|0000'                     , ''  ],

  # MRS (Banked register)
  ['mrs{%c}{%q}'       , 'Rd, breg'                              , 'T32: 1111|0011|111|breg.A:1|breg.C:4|1000|Rd:4|001|breg.B:1|0000'              , ''  ],
  ['mrs{%c}{%q}'       , 'Rd, breg'                              , 'A32: cond!=1111|0001|0|breg.A:1|00|breg.C:4|Rd:4|001|breg.B:1|0000|0000'       , ''  ],

  # MSR (Banked register)
  ['msr{%c}{%q}'       , 'breg, Rn'                              , 'T32: 1111|0011|100|breg.A:1|Rn:4|1000|breg.C:4|001|breg.B:1|0000'              , ''  ],
  ['msr{%c}{%q}'       , 'breg, Rn'                              , 'A32: cond!=1111|0001|0|breg.A:1|10|breg.C:4|1111|001|breg.B:1|0000|Rn:4'       , ''  ],

  # MSR (immediate)
  ['msr{%c}{%q}'       , 'sreg, #imm.x'                          , 'A32: cond!=1111|0011|0|R!=0|10|mask!=0000|1111|imm:12'                         , ''  ],

  # MSR (register)
  ['msr{%c}{%q}'       , 'sreg, Rn'                              , 'T32: 1111|0011|100|R|Rn:4|1000|mask:4|0000|0000'                               , ''  ],
  ['msr{%c}{%q}'       , 'sreg, Rn'                              , 'A32: cond!=1111|0001|0|R|10|mask:4|1111|0000|0000|Rn:4'                        , ''  ],

  # MUL, MULS
  ['mul%c{%q}'         , 'Rdm, Rn, {Rdm}'                        , 'T16: 0100|0011|01|Rn:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['muls{%q}'          , 'Rdm, Rn, {Rdm}'                        , 'T16: 0100|0011|01|Rn:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['mul%c.W'           , 'Rd, Rn, {Rm}'                          , 'T32: 1111|1011|0000|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'IT:IN'  ],
  ['mul{%c}{%q}'       , 'Rd, Rn, {Rm}'                          , 'T32: 1111|1011|0000|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['muls{%c}{%q}'      , 'Rd, Rn, {Rm}'                          , 'A32: cond!=1111|0000|0001|Rd:4|0000|Rm:4|1001|Rn:4'                            , ''  ],
  ['mul{%c}{%q}'       , 'Rd, Rn, {Rm}'                          , 'A32: cond!=1111|0000|0000|Rd:4|0000|Rm:4|1001|Rn:4'                            , ''  ],

  # MVN, MVNS (immediate)
  ['mvn{%c}{%q}'       , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|1011|110|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|1111|110|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1110|0000|Rd:4|cnst:12'                                   , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1111|0000|Rd:4|cnst:12'                                   , ''  ],

  # MVN, MVNS (register)
  ['mvn%c{%q}'         , 'Rd, Rm'                                , 'T16: 0100|0011|11|Rm:3|Rd:3'                                                   , 'IT:IN'  ],
  ['mvns{%q}'          , 'Rd, Rm'                                , 'T16: 0100|0011|11|Rm:3|Rd:3'                                                   , 'IT:OUT'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0110|1111|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['mvn%c.W'           , 'Rd, Rm'                                , 'T32: 1110|1010|0110|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:IN'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0110|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0111|1111|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['mvns.W'            , 'Rd, Rm'                                , 'T32: 1110|1010|0111|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:OUT'  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0111|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1110|0000|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1110|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1111|0000|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1111|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # MVN, MVNS (register-shifted register)
  ['mvns{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1111|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1110|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # NOP
  ['nop{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0000|0000'                                                      , ''  ],
  ['nop{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0000'                                  , ''  ],
  ['nop{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0000'                            , ''  ],

  # ORN, ORNS (immediate)
  ['orns{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|11|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['orn{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|10|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],

  # ORN, ORNS (register)
  ['orn{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0110|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , ''  ],
  ['orn{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0110|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['orns{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0111|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , ''  ],
  ['orns{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0111|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],

  # ORR, ORRS (immediate)
  ['orr{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|00|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|01|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1000|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1001|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # ORR, ORRS (register)
  ['orr%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|00|Rm:3|Rdn:3'                                                  , 'IT:IN'  ],
  ['orrs{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|00|Rm:3|Rdn:3'                                                  , 'IT:OUT'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0100|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , ''  ],
  ['orr%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0100|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'IT:IN'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0100|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0101|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , ''  ],
  ['orrs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0101|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'IT:OUT'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0101|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # ORR, ORRS (register-shifted register)
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # PKHBT, PKHTB
  ['pkhbt{%c}{%q}'     , '{Rd}, Rn, Rm, {LSL #imm}'              , 'T32: 1110|1010|1100|Rn:4|0|imm:3|Rd:4|imm2:2|00|Rm:4'                          , ''  ],
  ['pkhtb{%c}{%q}'     , '{Rd}, Rn, Rm, {ASR #imm}'              , 'T32: 1110|1010|1100|Rn:4|0|imm:3|Rd:4|imm2:2|10|Rm:4'                          , ''  ],
  ['pkhbt{%c}{%q}'     , '{Rd}, Rn, Rm, {LSL #imm}'              , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|imm:5|001|Rm:4'                            , ''  ],
  ['pkhtb{%c}{%q}'     , '{Rd}, Rn, Rm, {ASR #imm}'              , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|imm:5|101|Rm:4'                            , ''  ],

  # PLD, PLDW (immediate)
  ['pld{%c}{%q}'       , '[Rn, {#{+}imm.z}]'                     , 'T32: 1111|1000|1001|Rn!=1111|1111|imm:12'                                      , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {#{+}imm.z}]'                     , 'T32: 1111|1000|1011|Rn!=1111|1111|imm:12'                                      , ''  ],
  ['pld{%c}{%q}'       , '[Rn, {#-imm.z}]'                       , 'T32: 1111|1000|0001|Rn!=1111|1111|1100|imm:8'                                  , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {#-imm.z}]'                       , 'T32: 1111|1000|0011|Rn!=1111|1111|1100|imm:8'                                  , ''  ],
  ['pld{%c}{%q}'       , '[Rn, {#{+/-}imm.z}]'                   , 'A32: 1111|0101|U|101|Rn!=1111|1111|imm:12'                                     , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {#{+/-}imm.z}]'                   , 'A32: 1111|0101|U|001|Rn!=1111|1111|imm:12'                                     , ''  ],

  # PLD (literal)
  ['pld{%c}{%q}'       , 'rel.z'                                 , 'T32: 1111|1000|U|0011|1111|111|rel:12'                                         , ''  ],
  ['pld{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'T32: 1111|1000|U|0011|1111|111|imm:12'                                         , ''  ],
  ['pld{%c}{%q}'       , 'rel.z'                                 , 'A32: 1111|0101|U|1011|1111|111|rel:12'                                         , ''  ],
  ['pld{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'A32: 1111|0101|U|1011|1111|111|imm:12'                                         , ''  ],

  # PLD, PLDW (register)
  ['pld{%c}{%q}'       , '[Rn, {+}Rm, {LSL #amount}]'            , 'T32: 1111|1000|0001|Rn!=1111|1111|0000|00|amount:2|Rm:4'                       , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {+}Rm, {LSL #amount}]'            , 'T32: 1111|1000|0011|Rn!=1111|1111|0000|00|amount:2|Rm:4'                       , ''  ],
  ['pld{%c}{%q}'       , '[Rn, {+/-}Rm, {shift #amount}]'        , 'A32: 1111|0111|U|101|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                 , ''  ],
  ['pld{%c}{%q}'       , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111|0111|U|101|Rn:4|1111|0000|0110|Rm:4'                                 , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {+/-}Rm, {shift #amount}]'        , 'A32: 1111|0111|U|001|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                 , ''  ],
  ['pldw{%c}{%q}'      , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111|0111|U|001|Rn:4|1111|0000|0110|Rm:4'                                 , ''  ],

  # PLI (immediate, literal)
  ['pli{%c}{%q}'       , '[Rn, {#{+}imm.z}]'                     , 'T32: 1111|1001|1001|Rn!=1111|1111|imm:12'                                      , ''  ],
  ['pli{%c}{%q}'       , '[Rn, {#-imm.z}]'                       , 'T32: 1111|1001|0001|Rn!=1111|1111|1100|imm:8'                                  , ''  ],
  ['pli{%c}{%q}'       , 'rel.z'                                 , 'T32: 1111|1001|U|0011|1111|111|rel:12'                                         , ''  ],
  ['pli{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'T32: 1111|1001|U|0011|1111|111|imm:12'                                         , ''  ],
  ['pli{%c}{%q}'       , '[Rn, {#{+/-}imm.z}]'                   , 'A32: 1111|0100|U|101|Rn:4|1111|imm:12'                                         , ''  ],
  ['pli{%c}{%q}'       , 'rel.z'                                 , 'A32: 1111|0100|U|101|Rn:4|1111|rel:12'                                         , ''  ],
  ['pli{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'A32: 1111|0100|U|101|Rn:4|1111|imm:12'                                         , ''  ],

  # PLI (register)
  ['pli{%c}{%q}'       , '[Rn, {+}Rm, {LSL #amount}]'            , 'T32: 1111|1001|0001|Rn!=1111|1111|0000|00|amount:2|Rm:4'                       , ''  ],
  ['pli{%c}{%q}'       , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111|0110|U|101|Rn:4|1111|0000|0110|Rm:4'                                 , ''  ],
  ['pli{%c}{%q}'       , '[Rn, {+/-}Rm, {shift #amount}]'        , 'A32: 1111|0110|U|101|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                 , ''  ],

  # POP
  ['pop{%c}{%q}'       , 'list'                                  , 'T16: 1011|110|list.A:1|list.I:8'                                               , ''  ],
  ['ldm{%c}{%q}'       , 'SP!, list'                             , 'T16: 1011|110|list.A:1|list.I:8'                                               , ''  ],

  # POP (multiple registers)
  ['pop{%c}.W'         , 'list'                                  , 'T32: 1110|1000|1011|1101|list:1|list:1|0|list:13'                              , ''  ],
  ['pop{%c}{%q}'       , 'list'                                  , 'T32: 1110|1000|1011|1101|list:1|list:1|0|list:13'                              , ''  ],
  ['pop{%c}{%q}'       , 'list'                                  , 'A32: cond!=1111|1000|1011|1101|list:16'                                        , ''  ],

  # POP (single register)
  ['pop{%c}{%q}'       , 'RtList'                                , 'T32: 1111|1000|0101|1101|Rt:4|1011|0000|0100'                                  , ''  ],
  ['pop{%c}{%q}'       , 'RtList'                                , 'A32: cond!=1111|0100|1001|1101|Rt:4|0000|0000|0100'                            , ''  ],

  # PUSH
  ['push{%c}{%q}'      , 'list'                                  , 'T16: 1011|010|list.A:1|list.H:8'                                               , ''  ],
  ['stmdb{%c}{%q}'     , 'SP!, list'                             , 'T16: 1011|010|list.A:1|list.H:8'                                               , ''  ],

  # PUSH (multiple registers)
  ['push{%c}.W'        , 'list'                                  , 'T32: 1110|1001|0010|1101|0|list.B:1|0|list.C:13'                               , ''  ],
  ['push{%c}{%q}'      , 'list'                                  , 'T32: 1110|1001|0010|1101|0|list.B:1|0|list.C:13'                               , ''  ],
  ['push{%c}{%q}'      , 'list'                                  , 'A32: cond!=1111|1001|0010|1101|list:16'                                        , ''  ],

  # PUSH (single register)
  ['push{%c}{%q}'      , 'RtList'                                , 'T32: 1111|1000|0100|1101|Rt:4|1101|0000|0100'                                  , ''  ],
  ['push{%c}{%q}'      , 'RtList'                                , 'A32: cond!=1111|0101|0010|1101|Rt:4|0000|0000|0100'                            , ''  ],

  # QADD
  ['qadd{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['qadd{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0000|0101|Rm:4'                            , ''  ],

  # QADD16
  ['qadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['qadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # QADD8
  ['qadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['qadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|1001|Rm:4'                            , ''  ],

  # QASX
  ['qasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['qasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # QDADD
  ['qdadd{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1001|Rm:4'                                  , ''  ],
  ['qdadd{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0000|0101|Rm:4'                            , ''  ],

  # QDSUB
  ['qdsub{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1011|Rm:4'                                  , ''  ],
  ['qdsub{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0110|Rn:4|Rd:4|0000|0101|Rm:4'                            , ''  ],

  # QSAX
  ['qsax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['qsax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0101|Rm:4'                            , ''  ],

  # QSUB
  ['qsub{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1010|Rm:4'                                  , ''  ],
  ['qsub{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0000|0101|Rm:4'                            , ''  ],

  # QSUB16
  ['qsub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['qsub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0111|Rm:4'                            , ''  ],

  # QSUB8
  ['qsub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['qsub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|1111|Rm:4'                            , ''  ],

  # RBIT
  ['rbit{%c}{%q}'      , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1010|Rm:4'                                  , ''  ],
  ['rbit{%c}{%q}'      , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1111|1111|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # REV
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'T16: 1011|1010|00|Rm:3|Rd:3'                                                   , ''  ],
  ['rev{%c}.W'         , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1011|1111|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # REV16
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'T16: 1011|1010|01|Rm:3|Rd:3'                                                   , ''  ],
  ['rev16{%c}.W'       , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1001|Rm:4'                                  , ''  ],
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1001|Rm:4'                                  , ''  ],
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1011|1111|Rd:4|1111|1011|Rm:4'                            , ''  ],

  # REVSH
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'T16: 1011|1010|11|Rm:3|Rd:3'                                                   , ''  ],
  ['revsh{%c}.W'       , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1011|Rm:4'                                  , ''  ],
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1011|Rm:4'                                  , ''  ],
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1111|1111|Rd:4|1111|1011|Rm:4'                            , ''  ],

  # RFE, RFEDA, RFEDB, RFEIA, RFEIB
  ['rfedb{%c}{%q}'     , 'Rn{!}'                                 , 'T32: 1110|1000|00|W|1|Rn:4|1100|0000|0000|0000'                                , 'IT:IN:LAST:OUT'  ],
  ['rfe{ia}{%c}{%q}'   , 'Rn{!}'                                 , 'T32: 1110|1001|10|W|1|Rn:4|1100|0000|0000|0000'                                , 'IT:IN:LAST:OUT'  ],
  ['rfeda{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111|1000|00|W|1|Rn:4|0000|1010|0000|0000'                                , ''  ],
  ['rfedb{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111|1001|00|W|1|Rn:4|0000|1010|0000|0000'                                , ''  ],
  ['rfe{ia}{%c}{%q}'   , 'Rn{!}'                                 , 'A32: 1111|1000|10|W|1|Rn:4|0000|1010|0000|0000'                                , ''  ],
  ['rfeib{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111|1001|10|W|1|Rn:4|0000|1010|0000|0000'                                , ''  ],

  # ROR (immediate)
  ['ror{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                      , ''  ],
  ['ror{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm!=00000|110|Rm:4'                       , ''  ],

  # ROR (register)
  ['ror%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'IT:IN'  ],
  ['ror%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0110|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['ror{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0110|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['ror{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0111|Rm:4'                            , ''  ],

  # RORS (immediate)
  ['rors{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                      , ''  ],
  ['rors{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm!=00000|110|Rm:4'                       , ''  ],

  # RORS (register)
  ['rors{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'IT:OUT'  ],
  ['rors.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0111|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['rors{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0111|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['rors{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0111|Rm:4'                            , ''  ],

  # RRX
  ['rrx{%c}{%q}'       , '{Rd}, Rm'                              , 'T32: 1110|1010|0100|1111|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['rrx{%c}{%q}'       , '{Rd}, Rm'                              , 'A32: cond!=1111|0001|1010|0000|Rd:4|0000|0110|Rm:4'                            , ''  ],

  # RRXS
  ['rrxs{%c}{%q}'      , '{Rd}, Rm'                              , 'T32: 1110|1010|0101|1111|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['rrxs{%c}{%q}'      , '{Rd}, Rm'                              , 'A32: cond!=1111|0001|1011|0000|Rd:4|0000|0110|Rm:4'                            , ''  ],

  # RSB, RSBS (immediate)
  ['rsb%c{%q}'         , '{Rd,}Rn, #0'                           , 'T16: 0100|0010|01|Rn:3|Rd:3'                                                   , 'IT:IN'  ],
  ['rsbs{%q}'          , '{Rd,}Rn, #0'                           , 'T16: 0100|0010|01|Rn:3|Rd:3'                                                   , 'IT:OUT'  ],
  ['rsb%c.W'           , '{Rd}, Rn, #0'                          , 'T32: 1111|0|i|0111|00|Rn:4|0|imm3:3|Rd:4|imm8:8'                               , 'IT:IN'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0111|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['rsbs.W'            , '{Rd}, Rn, #0'                          , 'T32: 1111|0|i|0111|01|Rn:4|0|imm3:3|Rd:4|imm8:8'                               , 'IT:OUT'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0111|01|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0110|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0111|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # RSB, RSBS (register)
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1100|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1100|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1101|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1101|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # RSB, RSBS (register-shifted register)
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # RSC, RSCS (immediate)
  ['rsc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1110|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['rscs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1111|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # RSC, RSCS (register)
  ['rsc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['rsc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['rscs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['rscs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # RSC, RSCS (register-shifted register)
  ['rscs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['rsc{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # SADD16
  ['sadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['sadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # SADD8
  ['sadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['sadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|1001|Rm:4'                            , ''  ],

  # SASX
  ['sasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['sasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # SBC, SBCS (immediate)
  ['sbc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|10|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|11|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , ''  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1100|Rn:4|Rd:4|cnst:12'                                   , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1101|Rn:4|Rd:4|cnst:12'                                   , ''  ],

  # SBC, SBCS (register)
  ['sbc%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|10|Rm:3|Rdn:3'                                                  , 'IT:IN'  ],
  ['sbcs{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|10|Rm:3|Rdn:3'                                                  , 'IT:OUT'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0110|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['sbc%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0110|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:IN'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0110|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0111|Rn:4|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['sbcs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0111|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'IT:OUT'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0111|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # SBC, SBCS (register-shifted register)
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # SBFX
  ['sbfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'T32: 1111|0011|0100|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                         , ''  ],
  ['sbfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'A32: cond!=1111|0111|101|width:5|Rd:4|lsb:5|101|Rn:4'                          , ''  ],

  # SDIV
  ['sdiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|1001|Rn:4|1111|Rd:4|1111|Rm:4'                                  , ''  ],
  ['sdiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0001|Rd:4|1111|Rm:4|0001|Rn:4'                            , ''  ],

  # SEL
  ['sel{%c}{%q}'       , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|1000|Rm:4'                                  , ''  ],
  ['sel{%c}{%q}'       , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|1111|1011|Rm:4'                            , ''  ],

  # SETEND
  ['setend{%q}'        , 'endian'                                , 'T16: 1011|0110|0101|endian:1|000'                                              , ''  ],
  ['setend{%q}'        , 'endian'                                , 'A32: 1111|0001|0000|0001|0000|00|endian:1|0000|0000|0'                         , ''  ],

  # SEV
  ['sev{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0100|0000'                                                      , ''  ],
  ['sev{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0100'                                  , ''  ],
  ['sev{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0100'                            , ''  ],

  # SEVL
  ['sevl{%c}{%q}'      , ''                                      , 'T16: 1011|1111|0101|0000'                                                      , ''  ],
  ['sevl{%c}.W'        , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0101'                                  , ''  ],
  ['sevl{%c}{%q}'      , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0101'                            , ''  ],

  # SHADD16
  ['shadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['shadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # SHADD8
  ['shadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['shadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|1001|Rm:4'                            , ''  ],

  # SHASX
  ['shasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['shasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # SHSAX
  ['shsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['shsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0101|Rm:4'                            , ''  ],

  # SHSUB16
  ['shsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['shsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0111|Rm:4'                            , ''  ],

  # SHSUB8
  ['shsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['shsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|1111|Rm:4'                            , ''  ],

  # SMC
  ['smc{%c}{%q}'       , '{#}imm'                                , 'T32: 1111|0111|1111|imm:4|1000|0000|0000|0000'                                 , ''  ],
  ['smc{%c}{%q}'       , '{#}imm'                                , 'A32: cond!=1111|0001|0110|0000|0000|0000|0111|imm:4'                           , ''  ],

  # SMLABB, SMLABT, SMLATB, SMLATT
  ['smlabb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['smlabt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , ''  ],
  ['smlatb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0010|Rm:4'                              , ''  ],
  ['smlatt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0011|Rm:4'                              , ''  ],
  ['smlabb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1000|Rn:4'                            , ''  ],
  ['smlabt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1100|Rn:4'                            , ''  ],
  ['smlatb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1010|Rn:4'                            , ''  ],
  ['smlatt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1110|Rn:4'                            , ''  ],

  # SMLAD, SMLADX
  ['smlad{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0010|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['smladx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0010|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , ''  ],
  ['smlad{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                        , ''  ],
  ['smladx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0011|Rn:4'                        , ''  ],

  # SMLAL, SMLALS
  ['smlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , ''  ],
  ['smlals{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1111|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],
  ['smlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1110|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],

  # SMLALBB, SMLALBT, SMLALTB, SMLALTT
  ['smlalbb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1000|Rm:4'                              , ''  ],
  ['smlalbt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1001|Rm:4'                              , ''  ],
  ['smlaltb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1010|Rm:4'                              , ''  ],
  ['smlaltt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1011|Rm:4'                              , ''  ],
  ['smlalbb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1000|Rn:4'                        , ''  ],
  ['smlalbt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1100|Rn:4'                        , ''  ],
  ['smlaltb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1010|Rn:4'                        , ''  ],
  ['smlaltt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1110|Rn:4'                        , ''  ],

  # SMLALD, SMLALDX
  ['smlald{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1100|Rm:4'                              , ''  ],
  ['smlaldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1101|Rm:4'                              , ''  ],
  ['smlald{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0001|Rn:4'                        , ''  ],
  ['smlaldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0011|Rn:4'                        , ''  ],

  # SMLAWB, SMLAWT
  ['smlawb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0011|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['smlawt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0011|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , ''  ],
  ['smlawb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0010|Rd:4|Ra:4|Rm:4|1000|Rn:4'                            , ''  ],
  ['smlawt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0010|Rd:4|Ra:4|Rm:4|1100|Rn:4'                            , ''  ],

  # SMLSD, SMLSDX
  ['smlsd{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0100|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['smlsdx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0100|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , ''  ],
  ['smlsd{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0101|Rn:4'                        , ''  ],
  ['smlsdx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0111|Rn:4'                        , ''  ],

  # SMLSLD, SMLSLDX
  ['smlsld{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1101|Rn:4|RdLo:4|RdHi:4|1100|Rm:4'                              , ''  ],
  ['smlsldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1101|Rn:4|RdLo:4|RdHi:4|1101|Rm:4'                              , ''  ],
  ['smlsld{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0101|Rn:4'                        , ''  ],
  ['smlsldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0111|Rn:4'                        , ''  ],

  # SMMLA, SMMLAR
  ['smmla{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0101|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['smmlar{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0101|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , ''  ],
  ['smmla{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                        , ''  ],
  ['smmlar{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra!=1111|Rm:4|0011|Rn:4'                        , ''  ],

  # SMMLS, SMMLSR
  ['smmls{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0110|Rn:4|Ra:4|Rd:4|0000|Rm:4'                                  , ''  ],
  ['smmlsr{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0110|Rn:4|Ra:4|Rd:4|0001|Rm:4'                                  , ''  ],
  ['smmls{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra:4|Rm:4|1101|Rn:4'                            , ''  ],
  ['smmlsr{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra:4|Rm:4|1111|Rn:4'                            , ''  ],

  # SMMUL, SMMULR
  ['smmul{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0101|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['smmulr{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0101|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['smmul{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0101|Rd:4|1111|Rm:4|0001|Rn:4'                            , ''  ],
  ['smmulr{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0101|Rd:4|1111|Rm:4|0011|Rn:4'                            , ''  ],

  # SMUAD, SMUADX
  ['smuad{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0010|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['smuadx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0010|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['smuad{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0001|Rn:4'                            , ''  ],
  ['smuadx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0011|Rn:4'                            , ''  ],

  # SMULBB, SMULBT, SMULTB, SMULTT
  ['smulbb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['smulbt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['smultb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0010|Rm:4'                                  , ''  ],
  ['smultt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0011|Rm:4'                                  , ''  ],
  ['smulbb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1000|Rn:4'                            , ''  ],
  ['smulbt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1100|Rn:4'                            , ''  ],
  ['smultb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1010|Rn:4'                            , ''  ],
  ['smultt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1110|Rn:4'                            , ''  ],

  # SMULL, SMULLS
  ['smull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1000|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , ''  ],
  ['smulls{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1101|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],
  ['smull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1100|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],

  # SMULWB, SMULWT
  ['smulwb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0011|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['smulwt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0011|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['smulwb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0010|Rd:4|0000|Rm:4|1010|Rn:4'                            , ''  ],
  ['smulwt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0010|Rd:4|0000|Rm:4|1110|Rn:4'                            , ''  ],

  # SMUSD, SMUSDX
  ['smusd{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0100|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['smusdx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0100|Rn:4|1111|Rd:4|0001|Rm:4'                                  , ''  ],
  ['smusd{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0101|Rn:4'                            , ''  ],
  ['smusdx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0111|Rn:4'                            , ''  ],

  # SRS, SRSDA, SRSDB, SRSIA, SRSIB
  ['srsdb{%c}{%q}'     , 'SP{!}, #mode'                          , 'T32: 1110|1000|00|W|0110|1110|0000|0000|mode:5'                                , ''  ],
  ['srs{ia}{%c}{%q}'   , 'SP{!}, #mode'                          , 'T32: 1110|1001|10|W|0110|1110|0000|0000|mode:5'                                , ''  ],
  ['srsda{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111|1000|01|W|0110|1000|0010|1000|mode:5'                                , ''  ],
  ['srsdb{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111|1001|01|W|0110|1000|0010|1000|mode:5'                                , ''  ],
  ['srs{ia}{%c}{%q}'   , 'SP{!}, #mode'                          , 'A32: 1111|1000|11|W|0110|1000|0010|1000|mode:5'                                , ''  ],
  ['srsib{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111|1001|11|W|0110|1000|0010|1000|mode:5'                                , ''  ],

  # SSAT
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, ASR #amount'           , 'T32: 1111|0011|0010|Rn:4|0|amount!=000|Rd:4|amount!=00|0|sat:5'                , ''  ],
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, {LSL #amount}'         , 'T32: 1111|0011|0000|Rn:4|0|amount:3|Rd:4|amount:2|0|sat:5'                     , ''  ],
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, ASR #amount'           , 'A32: cond!=1111|0110|101|sat:5|Rd:4|amount:5|101|Rn:4'                         , ''  ],
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, {LSL #amount}'         , 'A32: cond!=1111|0110|101|sat:5|Rd:4|amount:5|001|Rn:4'                         , ''  ],

  # SSAT16
  ['ssat16{%c}{%q}'    , 'Rd, #sat+1, Rn'                        , 'T32: 1111|0011|0010|Rn:4|0000|Rd:4|0000|sat:4'                                 , ''  ],
  ['ssat16{%c}{%q}'    , 'Rd, #sat+1, Rn'                        , 'A32: cond!=1111|0110|1010|sat:4|Rd:4|1111|0011|Rn:4'                           , ''  ],

  # SSAX
  ['ssax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['ssax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0101|Rm:4'                            , ''  ],

  # SSUB16
  ['ssub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['ssub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0111|Rm:4'                            , ''  ],

  # SSUB8
  ['ssub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['ssub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|1111|Rm:4'                            , ''  ],

  # STC
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1101|U|000|Rn:4|0101|1110|imm:8'                                     , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1100|U|010|Rn:4|0101|1110|imm:8'                                     , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1101|U|010|Rn:4|0101|1110|imm:8'                                     , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'T32: 1110|1100|1000|Rn:4|0101|1110|option:8'                                   , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'A32: cond!=1111|1101|U|000|Rn:4|0101|1110|imm:8'                               , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'A32: cond!=1111|1100|U|010|Rn:4|0101|1110|imm:8'                               , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'A32: cond!=1111|1101|U|010|Rn:4|0101|1110|imm:8'                               , ''  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'A32: cond!=1111|1100|1000|Rn:4|0101|1110|option:8'                             , ''  ],

  # STL
  ['stl{%c}{%q}'       , 'Rt, [Rn]'                              , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1010|1111'                                  , ''  ],
  ['stl{%c}{%q}'       , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1000|Rn:4|1111|1100|1001|Rt:4'                            , ''  ],

  # STLB
  ['stlb{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1000|1111'                                  , ''  ],
  ['stlb{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1100|Rn:4|1111|1100|1001|Rt:4'                            , ''  ],

  # STLEX
  ['stlex{%c}{%q}'     , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1110|Rd:4'                                  , ''  ],
  ['stlex{%c}{%q}'     , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|1110|1001|Rt:4'                            , ''  ],

  # STLEXB
  ['stlexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1100|Rd:4'                                  , ''  ],
  ['stlexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|1110|1001|Rt:4'                            , ''  ],

  # STLEXD
  ['stlexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 1110|1000|1100|Rn:4|Rt:4|Rt2:4|1111|Rd:4'                                 , ''  ],
  ['stlexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'A32: cond!=1111|0001|1010|Rn:4|Rd:4|1110|1001|Rt:4'                            , ''  ],

  # STLEXH
  ['stlexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1101|Rd:4'                                  , ''  ],
  ['stlexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1110|Rn:4|Rd:4|1110|1001|Rt:4'                            , ''  ],

  # STLH
  ['stlh{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1001|1111'                                  , ''  ],
  ['stlh{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1110|Rn:4|1111|1100|1001|Rt:4'                            , ''  ],

  # STM, STMIA, STMEA
  ['stm{ia}{%c}{%q}'   , 'Rn!, list'                             , 'T16: 1100|0|Rn:3|list:8'                                                       , ''  ],
  ['stmea{%c}{%q}'     , 'Rn!, list'                             , 'T16: 1100|0|Rn:3|list:8'                                                       , ''  ],
  ['stm{ia}{%c}.W'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmea{%c}.W'       , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmea{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|0|Rn:4|list:16'                                      , ''  ],
  ['stmea{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|0|Rn:4|list:16'                                      , ''  ],

  # STM (User registers)
  ['stm{%amode}{%c}{%q}', 'Rn, list'                              , 'A32: cond!=1111|100|P|U|100|Rn:4|list:16'                                      , ''  ],

  # STMDA, STMED
  ['stmda{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|0|Rn:4|list:16'                                      , ''  ],
  ['stmed{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|0|Rn:4|list:16'                                      , ''  ],

  # STMDB, STMFD
  ['stmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , ''  ],
  ['stmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|0|Rn:4|list:16'                                      , ''  ],
  ['stmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|0|Rn:4|list:16'                                      , ''  ],

  # STMIB, STMFA
  ['stmib{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|0|Rn:4|list:16'                                      , ''  ],
  ['stmfa{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|0|Rn:4|list:16'                                      , ''  ],

  # STR (immediate)
  ['str{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z*4}]'               , 'T16: 0110|0|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['str{%c}{%q}'       , 'Rt, [SP, {#{+}imm.z*4}]'               , 'T16: 1001|0|Rt:3|imm:8'                                                        , ''  ],
  ['str{%c}.W'         , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1100|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1100|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|1100|imm:8'                                  , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|000|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|000|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|010|Rn:4|Rt:4|imm:12'                                   , ''  ],

  # STR (register)
  ['str{%c}{%q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|000|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['str{%c}.W'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|000|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|000|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|010|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # STRB (immediate)
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T16: 0111|0|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['strb{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1000|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1000|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|1100|imm:8'                                  , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|100|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|100|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|110|Rn:4|Rt:4|imm:12'                                   , ''  ],

  # STRB (register)
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|010|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['strb{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|100|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|100|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|110|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # STRBT
  ['strbt{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['strbt{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|110|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['strbt{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|110|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # STRD (immediate)
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1001|U|100|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1000|U|110|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1001|U|110|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z}]'          , 'A32: cond!=1111|0001|U|100|Rn:4|Rt:4|imm:4|1111|imm:4'                         , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z'            , 'A32: cond!=1111|0000|U|100|Rn:4|Rt:4|imm:4|1111|imm:4'                         , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z]!'           , 'A32: cond!=1111|0001|U|110|Rn:4|Rt:4|imm:4|1111|imm:4'                         , ''  ],

  # STRD (register)
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]'                , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], {+/-}Rm'                , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]!'               , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1111|Rm:4'                           , ''  ],

  # STREX
  ['strex{%c}{%q}'     , 'Rd, Rt, [Rn, {#imm.z*4}]'              , 'T32: 1110|1000|0100|Rn:4|Rt:4|Rd:4|imm:8'                                      , ''  ],
  ['strex{%c}{%q}'     , 'Rd, Rt, [Rn, {{#}0}]'                  , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|1111|1001|Rt:4'                            , ''  ],

  # STREXB
  ['strexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|0100|Rd:4'                                  , ''  ],
  ['strexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|1111|1001|Rt:4'                            , ''  ],

  # STREXD
  ['strexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 1110|1000|1100|Rn:4|Rt:4|Rt2:4|0111|Rd:4'                                 , ''  ],
  ['strexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'A32: cond!=1111|0001|1010|Rn:4|Rd:4|1111|1001|Rt:4'                            , ''  ],

  # STREXH
  ['strexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|0101|Rd:4'                                  , ''  ],
  ['strexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1110|Rn:4|Rd:4|1111|1001|Rt:4'                            , ''  ],

  # STRH (immediate)
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z*2}]'               , 'T16: 1000|0|imm:5|Rn:3|Rt:3'                                                   , ''  ],
  ['strh{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1010|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1010|Rn!=1111|Rt:4|imm:12'                                      , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|1100|imm:8'                                  , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|10|U|1|imm:8'                                , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|11|U|1|imm:8'                                , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|100|Rn:4|Rt:4|imm:4|1011|imm:4'                         , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|100|Rn:4|Rt:4|imm:4|1011|imm:4'                         , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|110|Rn:4|Rt:4|imm:4|1011|imm:4'                         , ''  ],

  # STRH (register)
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|001|Rm:3|Rn:3|Rt:3'                                                  , ''  ],
  ['strh{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],

  # STRHT
  ['strht{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['strht{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|110|Rn:4|Rt:4|imm:4|1011|imm:4'                         , ''  ],
  ['strht{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|010|Rn:4|Rt:4|0000|1011|Rm:4'                           , ''  ],

  # STRT
  ['strt{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|1110|imm:8'                                  , ''  ],
  ['strt{%c}{%q}'      , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|010|Rn:4|Rt:4|imm:12'                                   , ''  ],
  ['strt{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|010|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , ''  ],

  # SUB (immediate, from PC)
  ['sub{%c}{%q}'       , 'Rd, PC, #imm.z'                        , 'T32: 1111|0|imm:1|1010|1011|110|imm:3|Rd:4|imm:8'                              , ''  ],
  ['sub{%c}{%q}'       , 'Rd, PC, #cnst.x'                       , 'A32: cond!=1111|0010|0100|1111|Rd:4|cnst:12'                                   , ''  ],

  # SUB, SUBS (immediate)
  ['sub%c{%q}'         , 'Rd, Rn, #imm.z'                        , 'T16: 0001|111|imm:3|Rn:3|Rd:3'                                                 , 'IT:IN'  ],
  ['subs{%q}'          , 'Rd, Rn, #imm.z'                        , 'T16: 0001|111|imm:3|Rn:3|Rd:3'                                                 , 'IT:OUT'  ],
  ['sub%c{%q}'         , 'Rdn, #imm.z'                           , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'IT:IN'  ],
  ['sub%c{%q}'         , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'IT:IN'  ],
  ['subs{%q}'          , 'Rdn, #imm.z'                           , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'IT:OUT'  ],
  ['subs{%q}'          , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'IT:OUT'  ],
  ['sub%c.W'           , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|10|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , 'IT:IN'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|10|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , ''  ],
  ['subs.W'            , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|11|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , 'IT:OUT'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|11|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1010|10|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , ''  ],
  ['subw{%c}{%q}'      , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1010|10|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , ''  ],
  ['subs{%c}{%q}'      , 'PC, LR, #imm.z'                        , 'T32: 1111|0011|1101|1110|1000|1111|imm!=00000000'                              , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0100|Rn!=11x1|Rd:4|cnst:12'                               , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0101|Rn!=1101|Rd:4|cnst:12'                               , ''  ],

  # SUB, SUBS (register)
  ['sub%c{%q}'         , 'Rd, Rn, Rm'                            , 'T16: 0001|101|Rm:3|Rn:3|Rd:3'                                                  , 'IT:IN'  ],
  ['subs{%q}'          , '{Rd}, Rn, Rm'                          , 'T16: 0001|101|Rm:3|Rn:3|Rd:3'                                                  , 'IT:OUT'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1010|Rn!=1101|0000|Rd:4|0011|Rm:4'                              , ''  ],
  ['sub%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|1010|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'IT:IN'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1010|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1011|Rn!=1101|0000|Rd!=1111|0011|Rm:4'                          , ''  ],
  ['subs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|1011|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'      , 'IT:OUT'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1011|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4' , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0100|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0100|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0101|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0101|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , ''  ],

  # SUB, SUBS (register-shifted register)
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # SUB, SUBS (SP minus immediate)
  ['sub{%c}{%q}'       , '{SP}, SP, #imm.z*4'                    , 'T16: 1011|0000|1|imm:7'                                                        , ''  ],
  ['sub{%c}.W'         , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|1011|010|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|1011|010|cnst:3|Rd:4|cnst:8'                           , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|1111|010|cnst:3|Rd!=1111|cnst:8'                       , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1010|1011|010|imm:3|Rd:4|imm:8'                              , ''  ],
  ['subw{%c}{%q}'      , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1010|1011|010|imm:3|Rd:4|imm:8'                              , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|0100|1101|Rd:4|cnst:12'                                   , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|0101|1101|Rd:4|cnst:12'                                   , ''  ],

  # SUB, SUBS (SP minus register)
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|1010|1101|0000|Rd:4|0011|Rm:4'                                  , ''  ],
  ['sub{%c}.W'         , '{Rd}, SP, Rm'                          , 'T32: 1110|1011|1010|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|1010|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|1011|1101|0000|Rd!=1111|0011|Rm:4'                              , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|1011|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|0100|1101|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0100|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|0101|1101|Rd:4|0000|0110|Rm:4'                            , ''  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0101|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # SVC
  ['svc{%c}{%q}'       , '{#}imm.z'                              , 'T16: 1101|1111|imm:8'                                                          , ''  ],
  ['svc{%c}{%q}'       , '{#}imm.z'                              , 'A32: cond!=1111|1111|imm:24'                                                   , ''  ],

  # SXTAB
  ['sxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0100|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , ''  ],
  ['sxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1010|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , ''  ],

  # SXTAB16
  ['sxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0010|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , ''  ],
  ['sxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1000|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , ''  ],

  # SXTAH
  ['sxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0000|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , ''  ],
  ['sxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1011|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , ''  ],

  # SXTB
  ['sxtb{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|01|Rm:3|Rd:3'                                                   , ''  ],
  ['sxtb{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0100|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , ''  ],
  ['sxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0100|1111|1111|Rd:4|10|amount:2|Rm:4'                           , ''  ],
  ['sxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1010|1111|Rd:4|amount:2|0001|11|Rm:4'                     , ''  ],

  # SXTB16
  ['sxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0010|1111|1111|Rd:4|10|amount:2|Rm:4'                           , ''  ],
  ['sxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1000|1111|Rd:4|amount:2|0001|11|Rm:4'                     , ''  ],

  # SXTH
  ['sxth{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|00|Rm:3|Rd:3'                                                   , ''  ],
  ['sxth{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0000|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , ''  ],
  ['sxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0000|1111|1111|Rd:4|10|amount:2|Rm:4'                           , ''  ],
  ['sxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1011|1111|Rd:4|amount:2|0001|11|Rm:4'                     , ''  ],

  # TBB, TBH
  ['tbb{%c}{%q}'       , '[Rn, Rm]'                              , 'T32: 1110|1000|1101|Rn:4|1111|0000|0000|Rm:4'                                  , 'IT:IN:LAST:OUT'  ],
  ['tbh{%c}{%q}'       , '[Rn, Rm, LSL #1]'                      , 'T32: 1110|1000|1101|Rn:4|1111|0000|0001|Rm:4'                                  , 'IT:IN:LAST:OUT'  ],

  # TEQ (immediate)
  ['teq{%c}{%q}'       , 'Rn, #cnst.c'                           , 'T32: 1111|0|cnst:1|0010|01|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['teq{%c}{%q}'       , 'Rn, #cnst.c'                           , 'A32: cond!=1111|0011|0011|Rn:4|0000|cnst:12'                                   , ''  ],

  # TEQ (register)
  ['teq{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1010|1001|Rn:4|0000|1111|0011|Rm:4'                                  , ''  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'T32: 1110|1010|1001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0011|Rn:4|0000|0000|0110|Rm:4'                            , ''  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0011|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # TEQ (register-shifted register)
  ['teq{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0011|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # TST (immediate)
  ['tst{%c}{%q}'       , 'Rn, #cnst.c'                           , 'T32: 1111|0|cnst:1|0000|01|Rn:4|0|cnst:3|1111|cnst:8'                          , ''  ],
  ['tst{%c}{%q}'       , 'Rn, #cnst.c'                           , 'A32: cond!=1111|0011|0001|Rn:4|0000|cnst:12'                                   , ''  ],

  # TST (register)
  ['tst{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0010|00|Rm:3|Rn:3'                                                   , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1010|0001|Rn:4|0000|1111|0011|Rm:4'                                  , ''  ],
  ['tst{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110|1010|0001|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'T32: 1110|1010|0001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0001|Rn:4|0000|0000|0110|Rm:4'                            , ''  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0001|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , ''  ],

  # TST (register-shifted register)
  ['tst{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0001|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , ''  ],

  # UADD16
  ['uadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0100|Rm:4'                                  , ''  ],
  ['uadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # UADD8
  ['uadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0100|Rm:4'                                  , ''  ],
  ['uadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|1001|Rm:4'                            , ''  ],

  # UASX
  ['uasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0100|Rm:4'                                  , ''  ],
  ['uasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # UBFX
  ['ubfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'T32: 1111|0011|1100|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                         , ''  ],
  ['ubfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'A32: cond!=1111|0111|111|width:5|Rd:4|lsb:5|101|Rn:4'                          , ''  ],

  # UDF
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'T16: 1101|1110|imm:8'                                                          , ''  ],
  ['udf{%c}.W'         , '{#}imm.z'                              , 'T32: 1111|0111|1111|imm:4|1010|imm:12'                                         , ''  ],
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'T32: 1111|0111|1111|imm:4|1010|imm:12'                                         , ''  ],
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'A32: 1110|0111|1111|imm:12|1111|imm:4'                                         , ''  ],

  # UDIV
  ['udiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|1011|Rn:4|1111|Rd:4|1111|Rm:4'                                  , ''  ],
  ['udiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0011|Rd:4|1111|Rm:4|0001|Rn:4'                            , ''  ],

  # UHADD16
  ['uhadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0110|Rm:4'                                  , ''  ],
  ['uhadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # UHADD8
  ['uhadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0110|Rm:4'                                  , ''  ],
  ['uhadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|1001|Rm:4'                            , ''  ],

  # UHASX
  ['uhasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0110|Rm:4'                                  , ''  ],
  ['uhasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # UHSAX
  ['uhsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0110|Rm:4'                                  , ''  ],
  ['uhsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0101|Rm:4'                            , ''  ],

  # UHSUB16
  ['uhsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0110|Rm:4'                                  , ''  ],
  ['uhsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0111|Rm:4'                            , ''  ],

  # UHSUB8
  ['uhsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0110|Rm:4'                                  , ''  ],
  ['uhsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|1111|Rm:4'                            , ''  ],

  # UMAAL
  ['umaal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1110|Rn:4|RdLo:4|RdHi:4|0110|Rm:4'                              , ''  ],
  ['umaal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|0100|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],

  # UMLAL, UMLALS
  ['umlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1110|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , ''  ],
  ['umlals{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1011|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],
  ['umlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1010|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],

  # UMULL, UMULLS
  ['umull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1010|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , ''  ],
  ['umulls{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1001|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],
  ['umull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1000|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , ''  ],

  # UQADD16
  ['uqadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0101|Rm:4'                                  , ''  ],
  ['uqadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0001|Rm:4'                            , ''  ],

  # UQADD8
  ['uqadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0101|Rm:4'                                  , ''  ],
  ['uqadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|1001|Rm:4'                            , ''  ],

  # UQASX
  ['uqasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0101|Rm:4'                                  , ''  ],
  ['uqasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0011|Rm:4'                            , ''  ],

  # UQSAX
  ['uqsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0101|Rm:4'                                  , ''  ],
  ['uqsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0101|Rm:4'                            , ''  ],

  # UQSUB16
  ['uqsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0101|Rm:4'                                  , ''  ],
  ['uqsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0111|Rm:4'                            , ''  ],

  # UQSUB8
  ['uqsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0101|Rm:4'                                  , ''  ],
  ['uqsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|1111|Rm:4'                            , ''  ],

  # USAD8
  ['usad8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0111|Rn:4|1111|Rd:4|0000|Rm:4'                                  , ''  ],
  ['usad8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|1000|Rd:4|1111|Rm:4|0001|Rn:4'                            , ''  ],

  # USADA8
  ['usada8{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0111|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , ''  ],
  ['usada8{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|1000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                        , ''  ],

  # USAT
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, ASR #amount'             , 'T32: 1111|0011|1010|Rn:4|0|amount!=000|Rd:4|amount!=00|0|sat:5'                , ''  ],
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, {LSL #amount}'           , 'T32: 1111|0011|1000|Rn:4|0|amount:3|Rd:4|amount:2|0|sat:5'                     , ''  ],
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, ASR #amount'             , 'A32: cond!=1111|0110|111|sat:5|Rd:4|amount:5|101|Rn:4'                         , ''  ],
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, {LSL #amount}'           , 'A32: cond!=1111|0110|111|sat:5|Rd:4|amount:5|001|Rn:4'                         , ''  ],

  # USAT16
  ['usat16{%c}{%q}'    , 'Rd, #sat, Rn'                          , 'T32: 1111|0011|1010|Rn:4|0000|Rd:4|0000|sat:4'                                 , ''  ],
  ['usat16{%c}{%q}'    , 'Rd, #sat, Rn'                          , 'A32: cond!=1111|0110|1110|sat:4|Rd:4|1111|0011|Rn:4'                           , ''  ],

  # USAX
  ['usax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0100|Rm:4'                                  , ''  ],
  ['usax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0101|Rm:4'                            , ''  ],

  # USUB16
  ['usub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0100|Rm:4'                                  , ''  ],
  ['usub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0111|Rm:4'                            , ''  ],

  # USUB8
  ['usub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0100|Rm:4'                                  , ''  ],
  ['usub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|1111|Rm:4'                            , ''  ],

  # UXTAB
  ['uxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0101|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , ''  ],
  ['uxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1110|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , ''  ],

  # UXTAB16
  ['uxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0011|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , ''  ],
  ['uxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1100|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , ''  ],

  # UXTAH
  ['uxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0001|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , ''  ],
  ['uxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1111|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , ''  ],

  # UXTB
  ['uxtb{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|11|Rm:3|Rd:3'                                                   , ''  ],
  ['uxtb{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0101|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , ''  ],
  ['uxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0101|1111|1111|Rd:4|10|amount:2|Rm:4'                           , ''  ],
  ['uxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1110|1111|Rd:4|amount:2|0001|11|Rm:4'                     , ''  ],

  # UXTB16
  ['uxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0011|1111|1111|Rd:4|10|amount:2|Rm:4'                           , ''  ],
  ['uxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1100|1111|Rd:4|amount:2|0001|11|Rm:4'                     , ''  ],

  # UXTH
  ['uxth{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|10|Rm:3|Rd:3'                                                   , ''  ],
  ['uxth{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0001|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , ''  ],
  ['uxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0001|1111|1111|Rd:4|10|amount:2|Rm:4'                           , ''  ],
  ['uxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1111|1111|Rd:4|amount:2|0001|11|Rm:4'                     , ''  ],

  # WFE
  ['wfe{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0010|0000'                                                      , ''  ],
  ['wfe{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0010'                                  , ''  ],
  ['wfe{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0010'                            , ''  ],

  # WFI
  ['wfi{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0011|0000'                                                      , ''  ],
  ['wfi{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0011'                                  , ''  ],
  ['wfi{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0011'                            , ''  ],

  # YIELD
  ['yield{%c}{%q}'     , ''                                      , 'T16: 1011|1111|0001|0000'                                                      , ''  ],
  ['yield{%c}.W'       , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0001'                                  , ''  ],
  ['yield{%c}{%q}'     , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0001'                            , ''  ],


  # ===>                     AArch64.Base instructions                     <===

  # ADC
  ['adc'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , ''  ],
  ['adc'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , ''  ],

  # ADCS
  ['adcs'              , 'Wd, Wn, Wm'                            , 'A64: 0011|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , ''  ],
  ['adcs'              , 'Xd, Xn, Xm'                            , 'A64: 1011|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , ''  ],

  # ADD (extended register)
  ['add'               , '$Wd, $Wn, Wm, {extend {#amount}}'      , 'A64: 0000|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , ''  ],
  ['add'               , '$Xd, $Xn, R.m, {extend {#amount}}'     , 'A64: 1000|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , ''  ],

  # ADD (immediate)
  ['add'               , '$Wd, $Wn, #imm.z, {shift {#amount}}'   , 'A64: 0001|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , ''  ],
  ['add'               , '$Xd, $Xn, #imm.z, {shift {#amount}}'   , 'A64: 1001|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , ''  ],

  # ADD (shifted register)
  ['add'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0000|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['add'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1000|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # ADDS (extended register)
  ['adds'              , 'Wd, $Wn, Wm, {extend {#amount}}'       , 'A64: 0010|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , ''  ],
  ['adds'              , 'Xd, $Xn, R.m, {extend {#amount}}'      , 'A64: 1010|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , ''  ],

  # ADDS (immediate)
  ['adds'              , 'Wd, $Wn, #imm.z, {shift {#amount}}'    , 'A64: 0011|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , ''  ],
  ['adds'              , 'Xd, $Xn, #imm.z, {shift {#amount}}'    , 'A64: 1011|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , ''  ],

  # ADDS (shifted register)
  ['adds'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0010|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['adds'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1010|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # ADR
  ['adr'               , 'Xd, rel.s'                             , 'A64: 0|rel.B:2|1000|0|rel.A:19|Xd:5'                                           , ''  ],

  # ADRP
  ['adrp'              , 'Xd, rel.s'                             , 'A64: 1|rel.B:2|1000|0|rel.A:19|Xd:5'                                           , ''  ],

  # AND (immediate)
  ['and'               , '$Wd, Wn, #bimm'                        , 'A64: 0001|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , ''  ],
  ['and'               , '$Xd, Xn, #bimm'                        , 'A64: 1001|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , ''  ],

  # AND (shifted register)
  ['and'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0000|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['and'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1000|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # ANDS (immediate)
  ['ands'              , 'Wd, Wn, #bimm'                         , 'A64: 0111|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , ''  ],
  ['ands'              , 'Xd, Xn, #bimm'                         , 'A64: 1111|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , ''  ],

  # ANDS (shifted register)
  ['ands'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0110|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['ands'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1110|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # ASR (register)
  ['asr'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|10|Wn:5|Wd:5'                                     , ''  ],
  ['asr'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|10|Xn:5|Xd:5'                                     , ''  ],

  # ASR (immediate)
  ['asr'               , 'Wd, Wn, #shift'                        , 'A64: 0001|0011|00|shift:6|0111|11|Wn:5|Wd:5'                                   , ''  ],
  ['asr'               , 'Xd, Xn, #shift'                        , 'A64: 1001|0011|01|shift:6|1111|11|Xn:5|Xd:5'                                   , ''  ],

  # ASRV
  ['asrv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|10|Wn:5|Wd:5'                                     , ''  ],
  ['asrv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|10|Xn:5|Xd:5'                                     , ''  ],

  # AT
  ['at'                , 'at_op, Xt'                             , 'A64: 1101|0101|0000|1|at_op.A:3|0111|CRm=100x|at_op.C:3|Xt:5'                  , ''  ],

  # B.cond
  ['b.%c'              , 'rel.s*4'                               , 'A64: 0101|0100|rel:19|0|cond:4'                                                , ''  ],

  # B
  ['b'                 , 'rel.s*4'                               , 'A64: 0001|01|rel:26'                                                           , ''  ],

  # BFI
  ['bfi'               , 'Wd, Wn, #lsb, #width'                  , 'A64: 0011|0011|00|immr:6|imms:6|Wn!=11111|Wd:5'                                , ''  ],
  ['bfi'               , 'Xd, Xn, #lsb, #width'                  , 'A64: 1011|0011|01|immr:6|imms:6|Xn!=11111|Xd:5'                                , ''  ],

  # BFM
  ['bfm'               , 'Wd, Wn, #immr, #imms'                  , 'A64: 0011|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['bfm'               , 'Xd, Xn, #immr, #imms'                  , 'A64: 1011|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # BFXIL
  ['bfxil'             , 'Wd, Wn, #lsb, #width'                  , 'A64: 0011|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['bfxil'             , 'Xd, Xn, #lsb, #width'                  , 'A64: 1011|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # BIC (shifted register)
  ['bic'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0000|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['bic'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1000|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # BICS (shifted register)
  ['bics'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0110|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['bics'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1110|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # BL
  ['bl'                , 'rel.s*4'                               , 'A64: 1001|01|rel:26'                                                           , ''  ],

  # BLR
  ['blr'               , 'Xn'                                    , 'A64: 1101|0110|0011|1111|0000|00|Xn:5|0000|0'                                  , ''  ],

  # BR
  ['br'                , 'Xn'                                    , 'A64: 1101|0110|0001|1111|0000|00|Xn:5|0000|0'                                  , ''  ],

  # BRK
  ['brk'               , '#imm'                                  , 'A64: 1101|0100|001|imm:16|0000|0'                                              , ''  ],

  # CBNZ
  ['cbnz'              , 'Wt, rel.s*4'                           , 'A64: 0011|0101|rel:19|Wt:5'                                                    , ''  ],
  ['cbnz'              , 'Xt, rel.s*4'                           , 'A64: 1011|0101|rel:19|Xt:5'                                                    , ''  ],

  # CBZ
  ['cbz'               , 'Wt, rel.s*4'                           , 'A64: 0011|0100|rel:19|Wt:5'                                                    , ''  ],
  ['cbz'               , 'Xt, rel.s*4'                           , 'A64: 1011|0100|rel:19|Xt:5'                                                    , ''  ],

  # CCMN (immediate)
  ['ccmn'              , 'Wn, #imm.z, #nzcv, cond'               , 'A64: 0011|1010|010|imm:5|cond:4|10|Wn:5|0|nzcv:4'                              , ''  ],
  ['ccmn'              , 'Xn, #imm.z, #nzcv, cond'               , 'A64: 1011|1010|010|imm:5|cond:4|10|Xn:5|0|nzcv:4'                              , ''  ],

  # CCMN (register)
  ['ccmn'              , 'Wn, Wm, #nzcv, cond'                   , 'A64: 0011|1010|010|Wm:5|cond:4|00|Wn:5|0|nzcv:4'                               , ''  ],
  ['ccmn'              , 'Xn, Xm, #nzcv, cond'                   , 'A64: 1011|1010|010|Xm:5|cond:4|00|Xn:5|0|nzcv:4'                               , ''  ],

  # CCMP (immediate)
  ['ccmp'              , 'Wn, #imm.z, #nzcv, cond'               , 'A64: 0111|1010|010|imm:5|cond:4|10|Wn:5|0|nzcv:4'                              , ''  ],
  ['ccmp'              , 'Xn, #imm.z, #nzcv, cond'               , 'A64: 1111|1010|010|imm:5|cond:4|10|Xn:5|0|nzcv:4'                              , ''  ],

  # CCMP (register)
  ['ccmp'              , 'Wn, Wm, #nzcv, cond'                   , 'A64: 0111|1010|010|Wm:5|cond:4|00|Wn:5|0|nzcv:4'                               , ''  ],
  ['ccmp'              , 'Xn, Xm, #nzcv, cond'                   , 'A64: 1111|1010|010|Xm:5|cond:4|00|Xn:5|0|nzcv:4'                               , ''  ],

  # CINC
  ['cinc'              , 'Wd, Wn, cond'                          , 'A64: 0001|1010|100|cond!=11111|!=111x|01|!=11111|Wd:5'                         , ''  ],
  ['cinc'              , 'Xd, Xn, cond'                          , 'A64: 1001|1010|100|cond!=11111|!=111x|01|!=11111|Xd:5'                         , ''  ],

  # CINV
  ['cinv'              , 'Wd, Wn, cond'                          , 'A64: 0101|1010|100|cond!=11111|!=111x|00|!=11111|Wd:5'                         , ''  ],
  ['cinv'              , 'Xd, Xn, cond'                          , 'A64: 1101|1010|100|cond!=11111|!=111x|00|!=11111|Xd:5'                         , ''  ],

  # CLREX
  ['clrex'             , '{#imm}'                                , 'A64: 1101|0101|0000|0011|0011|imm:4|0101|1111'                                 , ''  ],

  # CLS
  ['cls'               , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0001|01|Wn:5|Wd:5'                                    , ''  ],
  ['cls'               , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0001|01|Xn:5|Xd:5'                                    , ''  ],

  # CLZ
  ['clz'               , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0001|00|Wn:5|Wd:5'                                    , ''  ],
  ['clz'               , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0001|00|Xn:5|Xd:5'                                    , ''  ],

  # CMN (extended register)
  ['cmn'               , '$Wn, Wm, {extend {#amount}}'           , 'A64: 0010|1011|001|Wm:5|extend:3|amount:3|Wn:5|1111|1'                         , ''  ],
  ['cmn'               , '$Xn, R.m, {extend {#amount}}'          , 'A64: 1010|1011|001|m:5|R/extend:3|amount:3|Xn:5|1111|1'                        , ''  ],

  # CMN (immediate)
  ['cmn'               , '$Wn, #imm.z, {shift {#amount}}'        , 'A64: 0011|0001|shift:2|imm:12|Wn:5|1111|1'                                     , ''  ],
  ['cmn'               , '$Xn, #imm.z, {shift {#amount}}'        , 'A64: 1011|0001|shift:2|imm:12|Xn:5|1111|1'                                     , ''  ],

  # CMN (shifted register)
  ['cmn'               , 'Wn, Wm, {shift #amount}'               , 'A64: 0010|1011|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                            , ''  ],
  ['cmn'               , 'Xn, Xm, {shift #amount}'               , 'A64: 1010|1011|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                            , ''  ],

  # CMP (extended register)
  ['cmp'               , '$Wn, Wm, {extend {#amount}}'           , 'A64: 0110|1011|001|Wm:5|extend:3|amount:3|Wn:5|1111|1'                         , ''  ],
  ['cmp'               , '$Xn, R.m, {extend {#amount}}'          , 'A64: 1110|1011|001|m:5|R/extend:3|amount:3|Xn:5|1111|1'                        , ''  ],

  # CMP (immediate)
  ['cmp'               , '$Wn, #imm.z, {shift {#amount}}'        , 'A64: 0111|0001|shift:2|imm:12|Wn:5|1111|1'                                     , ''  ],
  ['cmp'               , '$Xn, #imm.z, {shift {#amount}}'        , 'A64: 1111|0001|shift:2|imm:12|Xn:5|1111|1'                                     , ''  ],

  # CMP (shifted register)
  ['cmp'               , 'Wn, Wm, {shift #amount}'               , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                            , ''  ],
  ['cmp'               , 'Xn, Xm, {shift #amount}'               , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                            , ''  ],

  # CNEG
  ['cneg'              , 'Wd, Wn, cond'                          , 'A64: 0101|1010|100|Rm:5|cond!=111x|01|Rn:5|Wd:5'                               , ''  ],
  ['cneg'              , 'Xd, Xn, cond'                          , 'A64: 1101|1010|100|Rm:5|cond!=111x|01|Rn:5|Xd:5'                               , ''  ],

  # CRC32B, CRC32H, CRC32W, CRC32X
  ['crc32b'            , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0100|00|Wn:5|Wd:5'                                     , ''  ],
  ['crc32h'            , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0100|01|Wn:5|Wd:5'                                     , ''  ],
  ['crc32w'            , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0100|10|Wn:5|Wd:5'                                     , ''  ],
  ['crc32x'            , 'Wd, Wn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0100|11|Wn:5|Wd:5'                                     , ''  ],

  # CRC32CB, CRC32CH, CRC32CW, CRC32CX
  ['crc32cb'           , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0101|00|Wn:5|Wd:5'                                     , ''  ],
  ['crc32ch'           , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0101|01|Wn:5|Wd:5'                                     , ''  ],
  ['crc32cw'           , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0101|10|Wn:5|Wd:5'                                     , ''  ],
  ['crc32cx'           , 'Wd, Wn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0101|11|Wn:5|Wd:5'                                     , ''  ],

  # CSEL
  ['csel'              , 'Wd, Wn, Wm, cond'                      , 'A64: 0001|1010|100|Wm:5|cond:4|00|Wn:5|Wd:5'                                   , ''  ],
  ['csel'              , 'Xd, Xn, Xm, cond'                      , 'A64: 1001|1010|100|Xm:5|cond:4|00|Xn:5|Xd:5'                                   , ''  ],

  # CSET
  ['cset'              , 'Wd, cond'                              , 'A64: 0001|1010|1001|1111|cond!=111x|0111|111|Wd:5'                             , ''  ],
  ['cset'              , 'Xd, cond'                              , 'A64: 1001|1010|1001|1111|cond!=111x|0111|111|Xd:5'                             , ''  ],

  # CSETM
  ['csetm'             , 'Wd, cond'                              , 'A64: 0101|1010|1001|1111|cond!=111x|0011|111|Wd:5'                             , ''  ],
  ['csetm'             , 'Xd, cond'                              , 'A64: 1101|1010|1001|1111|cond!=111x|0011|111|Xd:5'                             , ''  ],

  # CSINC
  ['csinc'             , 'Wd, Wn, Wm, cond'                      , 'A64: 0001|1010|100|Wm:5|cond:4|01|Wn:5|Wd:5'                                   , ''  ],
  ['csinc'             , 'Xd, Xn, Xm, cond'                      , 'A64: 1001|1010|100|Xm:5|cond:4|01|Xn:5|Xd:5'                                   , ''  ],

  # CSINV
  ['csinv'             , 'Wd, Wn, Wm, cond'                      , 'A64: 0101|1010|100|Wm:5|cond:4|00|Wn:5|Wd:5'                                   , ''  ],
  ['csinv'             , 'Xd, Xn, Xm, cond'                      , 'A64: 1101|1010|100|Xm:5|cond:4|00|Xn:5|Xd:5'                                   , ''  ],

  # CSNEG
  ['csneg'             , 'Wd, Wn, Wm, cond'                      , 'A64: 0101|1010|100|Wm:5|cond:4|01|Wn:5|Wd:5'                                   , ''  ],
  ['csneg'             , 'Xd, Xn, Xm, cond'                      , 'A64: 1101|1010|100|Xm:5|cond:4|01|Xn:5|Xd:5'                                   , ''  ],

  # DC
  ['dc'                , 'dc_op, Xt'                             , 'A64: 1101|0101|0000|1|dc_op:3|0111|dc_op:4|dc_op:3|Xt:5'                       , ''  ],

  # DCPS1
  ['dcps1'             , '{#imm}'                                , 'A64: 1101|0100|101|imm:16|0000|1'                                              , ''  ],

  # DCPS2
  ['dcps2'             , '{#imm}'                                , 'A64: 1101|0100|101|imm:16|0001|0'                                              , ''  ],

  # DCPS3
  ['dcps3'             , '{#imm}'                                , 'A64: 1101|0100|101|imm:16|0001|1'                                              , ''  ],

  # DMB
  ['dmb'               , 'option|#imm'                           , 'A64: 1101|0101|0000|0011|0011|imm:4|1011|1111'                                 , ''  ],

  # DRPS
  ['drps'              , ''                                      , 'A64: 1101|0110|1011|1111|0000|0011|1110|0000'                                  , ''  ],

  # DSB
  ['dsb'               , 'option|#imm'                           , 'A64: 1101|0101|0000|0011|0011|imm:4|1001|1111'                                 , ''  ],

  # EON (shifted register)
  ['eon'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0100|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['eon'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1100|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # EOR (immediate)
  ['eor'               , '$Wd, Wn, #bimm'                        , 'A64: 0101|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , ''  ],
  ['eor'               , '$Xd, Xn, #bimm'                        , 'A64: 1101|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , ''  ],

  # EOR (shifted register)
  ['eor'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0100|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['eor'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1100|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # ERET
  ['eret'              , ''                                      , 'A64: 1101|0110|1001|1111|0000|0011|1110|0000'                                  , ''  ],

  # EXTR
  ['extr'              , 'Wd, Wn, Wm, #lsb'                      , 'A64: 0001|0011|100|Wm:5|lsb=0xxxxx|Wn:5|Wd:5'                                  , ''  ],
  ['extr'              , 'Xd, Xn, Xm, #lsb'                      , 'A64: 1001|0011|110|Xm:5|lsb:6|Xn:5|Xd:5'                                       , ''  ],

  # HINT
  ['hint'              , '#imm'                                  , 'A64: 1101|0101|0000|0011|0010|0000|imm=11x|1111|1'                             , ''  ],
  ['hint'              , '#imm'                                  , 'A64: 1101|0101|0000|0011|0010|imm!=0000|imm:3|1111|1'                          , ''  ],

  # HLT
  ['hlt'               , '#imm'                                  , 'A64: 1101|0100|010|imm:16|0000|0'                                              , ''  ],

  # HVC
  ['hvc'               , '#imm'                                  , 'A64: 1101|0100|000|imm:16|0001|0'                                              , ''  ],

  # IC
  ['ic'                , 'ic_op, {Xt}'                           , 'A64: 1101|0101|0000|1|ic_op:3|0111|ic_op:4|ic_op:3|Xt:5'                       , ''  ],

  # ISB
  ['isb'               , '{option|#imm}'                         , 'A64: 1101|0101|0000|0011|0011|imm:4|1101|1111'                                 , ''  ],

  # LDAR
  ['ldar'              , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|1101|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],
  ['ldar'              , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|1101|1111|1111|11|Xn:5|Xt:5'                                    , ''  ],

  # LDARB
  ['ldarb'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|1101|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],

  # LDARH
  ['ldarh'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|1101|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],

  # LDAXP
  ['ldaxp'             , 'Wt1, Wt2, [$Xn, {#0}]'                 , 'A64: 1000|1000|0111|1111|1|Wt2:5|Xn:5|Wt1:5'                                   , ''  ],
  ['ldaxp'             , 'Xt1, Xt2, [$Xn, {#0}]'                 , 'A64: 1100|1000|0111|1111|1|Xt2:5|Xn:5|Xt1:5'                                   , ''  ],

  # LDAXR
  ['ldaxr'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|0101|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],
  ['ldaxr'             , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|0101|1111|1111|11|Xn:5|Xt:5'                                    , ''  ],

  # LDAXRB
  ['ldaxrb'            , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|0101|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],

  # LDAXRH
  ['ldaxrh'            , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|0101|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],

  # LDNP
  ['ldnp'              , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1000|01|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['ldnp'              , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1000|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],

  # LDP
  ['ldp'               , 'Wt1, Wt2, [$Xn], #imm*4'               , 'A64: 0010|1000|11|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['ldp'               , 'Xt1, Xt2, [$Xn], #imm*8'               , 'A64: 1010|1000|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],
  ['ldp'               , 'Wt1, Wt2, [$Xn, #imm*4]!'              , 'A64: 0010|1001|11|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['ldp'               , 'Xt1, Xt2, [$Xn, #imm*8]!'              , 'A64: 1010|1001|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],
  ['ldp'               , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1001|01|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['ldp'               , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1001|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],

  # LDPSW
  ['ldpsw'             , 'Xt1, Xt2, [$Xn], #imm*4'               , 'A64: 0110|1000|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],
  ['ldpsw'             , 'Xt1, Xt2, [$Xn, #imm*4]!'              , 'A64: 0110|1001|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],
  ['ldpsw'             , 'Xt1, Xt2, [$Xn, {#imm*4}]'             , 'A64: 0110|1001|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],

  # LDR (immediate)
  ['ldr'               , 'Wt, [$Xn], #imm.s'                     , 'A64: 1011|1000|010|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['ldr'               , 'Xt, [$Xn], #imm.s'                     , 'A64: 1111|1000|010|imm:9|01|Xn:5|Xt:5'                                         , ''  ],
  ['ldr'               , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 1011|1000|010|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['ldr'               , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 1111|1000|010|imm:9|11|Xn:5|Xt:5'                                         , ''  ],
  ['ldr'               , 'Wt, [$Xn, {#imm.z*4}]'                 , 'A64: 1011|1001|01|imm:12|Xn:5|Wt:5'                                            , ''  ],
  ['ldr'               , 'Xt, [$Xn, {#imm.z*8}]'                 , 'A64: 1111|1001|01|imm:12|Xn:5|Xt:5'                                            , ''  ],

  # LDR (literal)
  ['ldr'               , 'Wt, rel.s*4'                           , 'A64: 0001|1000|rel:19|Wt:5'                                                    , ''  ],
  ['ldr'               , 'Xt, rel.s*4'                           , 'A64: 0101|1000|rel:19|Xt:5'                                                    , ''  ],

  # LDR (register)
  ['ldr'               , 'Wt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 1011|1000|011|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Wt:5'                     , ''  ],
  ['ldr'               , 'Xt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 1111|1000|011|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Xt:5'                     , ''  ],

  # LDRB (immediate)
  ['ldrb'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0011|1000|010|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['ldrb'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|010|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['ldrb'              , 'Wt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|01|imm:12|Xn:5|Wt:5'                                            , ''  ],

  # LDRB (register)
  ['ldrb'              , 'Wt, [$Xn, (Wm|Xm), extend {amount}]'   , 'A64: 0011|1000|011|Wm/Xm:5|extend!=011|amount:1|10|Xn:5|Wt:5'                  , ''  ],
  ['ldrb'              , 'Wt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|011|Xm:5|011|amount:1|10|Xn:5|Wt:5'                             , ''  ],

  # LDRH (immediate)
  ['ldrh'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0111|1000|010|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['ldrh'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|010|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['ldrh'              , 'Wt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|01|imm:12|Xn:5|Wt:5'                                            , ''  ],

  # LDRH (register)
  ['ldrh'              , 'Wt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 0111|1000|011|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Wt:5'                     , ''  ],

  # LDRSB (immediate)
  ['ldrsb'             , 'Wt, [$Xn], #imm.s'                     , 'A64: 0011|1000|110|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['ldrsb'             , 'Xt, [$Xn], #imm.s'                     , 'A64: 0011|1000|100|imm:9|01|Xn:5|Xt:5'                                         , ''  ],
  ['ldrsb'             , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|110|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['ldrsb'             , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|100|imm:9|11|Xn:5|Xt:5'                                         , ''  ],
  ['ldrsb'             , 'Wt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|11|imm:12|Xn:5|Wt:5'                                            , ''  ],
  ['ldrsb'             , 'Xt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|10|imm:12|Xn:5|Xt:5'                                            , ''  ],

  # LDRSB (register)
  ['ldrsb'             , 'Wt, [$Xn, (Wm|Xm), extend {amount}]'   , 'A64: 0011|1000|111|Wm/Xm:5|extend!=011|amount:1|10|Xn:5|Wt:5'                  , ''  ],
  ['ldrsb'             , 'Wt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|111|Xm:5|011|amount:1|10|Xn:5|Wt:5'                             , ''  ],
  ['ldrsb'             , 'Xt, [$Xn, (Wm|Xm), extend {amount}]'   , 'A64: 0011|1000|101|Wm/Xm:5|extend!=011|amount:1|10|Xn:5|Xt:5'                  , ''  ],
  ['ldrsb'             , 'Xt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|101|Xm:5|011|amount:1|10|Xn:5|Xt:5'                             , ''  ],

  # LDRSH (immediate)
  ['ldrsh'             , 'Wt, [$Xn], #imm.s'                     , 'A64: 0111|1000|110|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['ldrsh'             , 'Xt, [$Xn], #imm.s'                     , 'A64: 0111|1000|100|imm:9|01|Xn:5|Xt:5'                                         , ''  ],
  ['ldrsh'             , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|110|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['ldrsh'             , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|100|imm:9|11|Xn:5|Xt:5'                                         , ''  ],
  ['ldrsh'             , 'Wt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|11|imm:12|Xn:5|Wt:5'                                            , ''  ],
  ['ldrsh'             , 'Xt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|10|imm:12|Xn:5|Xt:5'                                            , ''  ],

  # LDRSH (register)
  ['ldrsh'             , 'Wt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 0111|1000|111|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Wt:5'                     , ''  ],
  ['ldrsh'             , 'Xt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 0111|1000|101|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Xt:5'                     , ''  ],

  # LDRSW (immediate)
  ['ldrsw'             , 'Xt, [$Xn], #imm.s'                     , 'A64: 1011|1000|100|imm:9|01|Xn:5|Xt:5'                                         , ''  ],
  ['ldrsw'             , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 1011|1000|100|imm:9|11|Xn:5|Xt:5'                                         , ''  ],
  ['ldrsw'             , 'Xt, [$Xn, {#imm.z*4}]'                 , 'A64: 1011|1001|10|imm:12|Xn:5|Xt:5'                                            , ''  ],

  # LDRSW (literal)
  ['ldrsw'             , 'Xt, rel.s*4'                           , 'A64: 1001|1000|rel:19|Xt:5'                                                    , ''  ],

  # LDRSW (register)
  ['ldrsw'             , 'Xt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 1011|1000|101|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Xt:5'                     , ''  ],

  # LDTR
  ['ldtr'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|010|imm:9|10|Xn:5|Wt:5'                                         , ''  ],
  ['ldtr'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|010|imm:9|10|Xn:5|Xt:5'                                         , ''  ],

  # LDTRB
  ['ldtrb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|010|imm:9|10|Xn:5|Wt:5'                                         , ''  ],

  # LDTRH
  ['ldtrh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|010|imm:9|10|Xn:5|Wt:5'                                         , ''  ],

  # LDTRSB
  ['ldtrsb'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|110|imm:9|10|Xn:5|Wt:5'                                         , ''  ],
  ['ldtrsb'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|100|imm:9|10|Xn:5|Xt:5'                                         , ''  ],

  # LDTRSH
  ['ldtrsh'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|110|imm:9|10|Xn:5|Wt:5'                                         , ''  ],
  ['ldtrsh'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|100|imm:9|10|Xn:5|Xt:5'                                         , ''  ],

  # LDTRSW
  ['ldtrsw'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|100|imm:9|10|Xn:5|Xt:5'                                         , ''  ],

  # LDUR
  ['ldur'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|010|imm:9|00|Xn:5|Wt:5'                                         , ''  ],
  ['ldur'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|010|imm:9|00|Xn:5|Xt:5'                                         , ''  ],

  # LDURB
  ['ldurb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|010|imm:9|00|Xn:5|Wt:5'                                         , ''  ],

  # LDURH
  ['ldurh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|010|imm:9|00|Xn:5|Wt:5'                                         , ''  ],

  # LDURSB
  ['ldursb'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|110|imm:9|00|Xn:5|Wt:5'                                         , ''  ],
  ['ldursb'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|100|imm:9|00|Xn:5|Xt:5'                                         , ''  ],

  # LDURSH
  ['ldursh'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|110|imm:9|00|Xn:5|Wt:5'                                         , ''  ],
  ['ldursh'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|100|imm:9|00|Xn:5|Xt:5'                                         , ''  ],

  # LDURSW
  ['ldursw'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|100|imm:9|00|Xn:5|Xt:5'                                         , ''  ],

  # LDXP
  ['ldxp'              , 'Wt1, Wt2, [$Xn, {#0}]'                 , 'A64: 1000|1000|0111|1111|0|Wt2:5|Xn:5|Wt1:5'                                   , ''  ],
  ['ldxp'              , 'Xt1, Xt2, [$Xn, {#0}]'                 , 'A64: 1100|1000|0111|1111|0|Xt2:5|Xn:5|Xt1:5'                                   , ''  ],

  # LDXR
  ['ldxr'              , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|0101|1111|0111|11|Xn:5|Wt:5'                                    , ''  ],
  ['ldxr'              , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|0101|1111|0111|11|Xn:5|Xt:5'                                    , ''  ],

  # LDXRB
  ['ldxrb'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|0101|1111|0111|11|Xn:5|Wt:5'                                    , ''  ],

  # LDXRH
  ['ldxrh'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|0101|1111|0111|11|Xn:5|Wt:5'                                    , ''  ],

  # LSL (register)
  ['lsl'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|00|Wn:5|Wd:5'                                     , ''  ],
  ['lsl'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|00|Xn:5|Xd:5'                                     , ''  ],

  # LSL (immediate)
  ['lsl'               , 'Wd, Wn, #shift'                        , 'A64: 0101|0011|00|immr:6|imms!=011111|Wn:5|Wd:5'                               , ''  ],
  ['lsl'               , 'Xd, Xn, #shift'                        , 'A64: 1101|0011|01|immr:6|imms!=111111|Xn:5|Xd:5'                               , ''  ],

  # LSLV
  ['lslv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|00|Wn:5|Wd:5'                                     , ''  ],
  ['lslv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|00|Xn:5|Xd:5'                                     , ''  ],

  # LSR (register)
  ['lsr'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|01|Wn:5|Wd:5'                                     , ''  ],
  ['lsr'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|01|Xn:5|Xd:5'                                     , ''  ],

  # LSR (immediate)
  ['lsr'               , 'Wd, Wn, #shift'                        , 'A64: 0101|0011|00|shift:6|0111|11|Wn:5|Wd:5'                                   , ''  ],
  ['lsr'               , 'Xd, Xn, #shift'                        , 'A64: 1101|0011|01|shift:6|1111|11|Xn:5|Xd:5'                                   , ''  ],

  # LSRV
  ['lsrv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|01|Wn:5|Wd:5'                                     , ''  ],
  ['lsrv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|01|Xn:5|Xd:5'                                     , ''  ],

  # MADD
  ['madd'              , 'Wd, Wn, Wm, Wa'                        , 'A64: 0001|1011|000|Wm:5|0|Wa:5|Wn:5|Wd:5'                                      , ''  ],
  ['madd'              , 'Xd, Xn, Xm, Xa'                        , 'A64: 1001|1011|000|Xm:5|0|Xa:5|Xn:5|Xd:5'                                      , ''  ],

  # MNEG
  ['mneg'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1011|000|Wm:5|1111|11|Wn:5|Wd:5'                                     , ''  ],
  ['mneg'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|000|Xm:5|1111|11|Xn:5|Xd:5'                                     , ''  ],

  # MOV (to/from SP)
  ['mov'               , '$Wd, $Wn'                              , 'A64: 0001|0001|0000|0000|0000|00|Wn:5|Wd:5'                                    , ''  ],
  ['mov'               , '$Xd, $Xn'                              , 'A64: 1001|0001|0000|0000|0000|00|Xn:5|Xd:5'                                    , ''  ],

  # MOV (inverted wide immediate)
  ['mov'               , 'Wd, #imm'                              , 'A64: 0001|0010|1|imm.B:2|imm.A:16|Wd:5'                                        , ''  ],
  ['mov'               , 'Xd, #imm'                              , 'A64: 1001|0010|1|imm.B:2|imm.A:16|Xd:5'                                        , ''  ],

  # MOV (wide immediate)
  ['mov'               , 'Wd, #imm'                              , 'A64: 0101|0010|1|imm.B:2|imm.A:16|Wd:5'                                        , ''  ],
  ['mov'               , 'Xd, #imm'                              , 'A64: 1101|0010|1|imm.B:2|imm.A:16|Xd:5'                                        , ''  ],

  # MOV (bitmask immediate)
  ['mov'               , '$Wd, #bimm'                            , 'A64: 0011|0010|00|bimm.B:6|bimm.A:6|1111|1|Wd:5'                               , ''  ],
  ['mov'               , '$Xd, #bimm'                            , 'A64: 1011|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|1111|1|Xd:5'                       , ''  ],

  # MOV (register)
  ['mov'               , 'Wd, Wm'                                , 'A64: 0010|1010|000|Wm:5|0000|0011|111|Wd:5'                                    , ''  ],
  ['mov'               , 'Xd, Xm'                                , 'A64: 1010|1010|000|Xm:5|0000|0011|111|Xd:5'                                    , ''  ],

  # MOVK
  ['movk'              , 'Wd, #imm, {LSL #shift*16}'             , 'A64: 0111|0010|1|shift:2|imm:16|Wd:5'                                          , ''  ],
  ['movk'              , 'Xd, #imm, {LSL #shift*16}'             , 'A64: 1111|0010|1|shift:2|imm:16|Xd:5'                                          , ''  ],

  # MOVN
  ['movn'              , 'Wd, #imm, {LSL #shift*16}'             , 'A64: 0001|0010|1|shift:2|imm:16|Wd:5'                                          , ''  ],
  ['movn'              , 'Xd, #imm, {LSL #shift*16}'             , 'A64: 1001|0010|1|shift:2|imm:16|Xd:5'                                          , ''  ],

  # MOVZ
  ['movz'              , 'Wd, #imm, {LSL #shift*16}'             , 'A64: 0101|0010|1|shift:2|imm:16|Wd:5'                                          , ''  ],
  ['movz'              , 'Xd, #imm, {LSL #shift*16}'             , 'A64: 1101|0010|1|shift:2|imm:16|Xd:5'                                          , ''  ],

  # MRS
  ['mrs'               , 'Xt, (systemreg|Sop0_op1_Cn_Cm_op2)'    , 'A64: 1101|0101|0011|op0:1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                          , ''  ],

  # MSR (immediate)
  ['msr'               , 'pstatefield, #imm'                     , 'A64: 1101|0101|0000|0|pstatefield:3|0100|imm:4|pstatefield:3|1111|1'           , ''  ],

  # MSR (register)
  ['msr'               , '(systemreg|Sop0_op1_Cn_Cm_op2), Xt'    , 'A64: 1101|0101|0001|op0:1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                          , ''  ],

  # MSUB
  ['msub'              , 'Wd, Wn, Wm, Wa'                        , 'A64: 0001|1011|000|Wm:5|1|Wa:5|Wn:5|Wd:5'                                      , ''  ],
  ['msub'              , 'Xd, Xn, Xm, Xa'                        , 'A64: 1001|1011|000|Xm:5|1|Xa:5|Xn:5|Xd:5'                                      , ''  ],

  # MUL
  ['mul'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1011|000|Wm:5|0111|11|Wn:5|Wd:5'                                     , ''  ],
  ['mul'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|000|Xm:5|0111|11|Xn:5|Xd:5'                                     , ''  ],

  # MVN
  ['mvn'               , 'Wd, Wm, {shift #amount}'               , 'A64: 0010|1010|shift:2|1|Wm:5|amount:6|1111|1|Wd:5'                            , ''  ],
  ['mvn'               , 'Xd, Xm, {shift #amount}'               , 'A64: 1010|1010|shift:2|1|Xm:5|amount:6|1111|1|Xd:5'                            , ''  ],

  # NEG (shifted register)
  ['neg'               , 'Wd, Wm, {shift #amount}'               , 'A64: 0100|1011|shift:2|0|Wm:5|amount:6|1111|1|Wd:5'                            , ''  ],
  ['neg'               , 'Xd, Xm, {shift #amount}'               , 'A64: 1100|1011|shift:2|0|Xm:5|amount:6|1111|1|Xd:5'                            , ''  ],

  # NEGS
  ['negs'              , 'Wd, Wm, {shift #amount}'               , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|1111|1|Wd:5'                            , ''  ],
  ['negs'              , 'Xd, Xm, {shift #amount}'               , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|1111|1|Xd:5'                            , ''  ],

  # NGC
  ['ngc'               , 'Wd, Wm'                                , 'A64: 0101|1010|000|Wm:5|0000|0011|111|Wd:5'                                    , ''  ],
  ['ngc'               , 'Xd, Xm'                                , 'A64: 1101|1010|000|Xm:5|0000|0011|111|Xd:5'                                    , ''  ],

  # NGCS
  ['ngcs'              , 'Wd, Wm'                                , 'A64: 0111|1010|000|Wm:5|0000|0011|111|Wd:5'                                    , ''  ],
  ['ngcs'              , 'Xd, Xm'                                , 'A64: 1111|1010|000|Xm:5|0000|0011|111|Xd:5'                                    , ''  ],

  # NOP
  ['nop'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0001|1111'                                  , ''  ],

  # ORN (shifted register)
  ['orn'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0010|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['orn'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1010|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # ORR (immediate)
  ['orr'               , '$Wd, Wn, #bimm'                        , 'A64: 0011|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , ''  ],
  ['orr'               , '$Xd, Xn, #bimm'                        , 'A64: 1011|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , ''  ],

  # ORR (shifted register)
  ['orr'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0010|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['orr'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1010|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # PRFM (immediate)
  ['prfm'              , 'prfop, [$Xn, {#imm.z*8}]'              , 'A64: 1111|1001|10|imm:12|Xn:5|prfop:5'                                         , ''  ],

  # PRFM (literal)
  ['prfm'              , 'prfop, rel.s*4'                        , 'A64: 1101|1000|rel:19|prfop:5'                                                 , ''  ],

  # PRFM (register)
  ['prfm'              , 'prfop, [$Xn, (Wm|Xm), {extend {amount}}]', 'A64: 1111|1000|101|Wm/Xm:5|extend:3|amount:1|10|Xn:5|prfop:5'                  , ''  ],

  # PRFM (unscaled offset)
  ['prfum'             , 'prfop, [$Xn, {#imm.s}]'                , 'A64: 1111|1000|100|imm:9|00|Xn:5|prfop:5'                                      , ''  ],

  # RBIT
  ['rbit'              , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0000|00|Wn:5|Wd:5'                                    , ''  ],
  ['rbit'              , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|00|Xn:5|Xd:5'                                    , ''  ],

  # RET
  ['ret'               , '{Xn}'                                  , 'A64: 1101|0110|0101|1111|0000|00|Xn:5|0000|0'                                  , ''  ],

  # REV
  ['rev'               , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0000|10|Wn:5|Wd:5'                                    , ''  ],
  ['rev'               , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|11|Xn:5|Xd:5'                                    , ''  ],

  # REV16
  ['rev16'             , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0000|01|Wn:5|Wd:5'                                    , ''  ],
  ['rev16'             , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|01|Xn:5|Xd:5'                                    , ''  ],

  # REV32
  ['rev32'             , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|10|Xn:5|Xd:5'                                    , ''  ],

  # REV64
  ['rev64'             , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|11|Xn:5|Xd:5'                                    , ''  ],

  # ROR (immediate)
  ['ror'               , 'Wd, Ws, #shift'                        , 'A64: 0001|0011|100|Rm:5|shift=0xxxxx|Rn:5|Wd:5'                                , ''  ],
  ['ror'               , 'Xd, Xs, #shift'                        , 'A64: 1001|0011|110|Rm:5|shift:6|Rn:5|Xd:5'                                     , ''  ],

  # ROR (register)
  ['ror'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|11|Wn:5|Wd:5'                                     , ''  ],
  ['ror'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|11|Xn:5|Xd:5'                                     , ''  ],

  # RORV
  ['rorv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|11|Wn:5|Wd:5'                                     , ''  ],
  ['rorv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|11|Xn:5|Xd:5'                                     , ''  ],

  # SBC
  ['sbc'               , 'Wd, Wn, Wm'                            , 'A64: 0101|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , ''  ],
  ['sbc'               , 'Xd, Xn, Xm'                            , 'A64: 1101|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , ''  ],

  # SBCS
  ['sbcs'              , 'Wd, Wn, Wm'                            , 'A64: 0111|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , ''  ],
  ['sbcs'              , 'Xd, Xn, Xm'                            , 'A64: 1111|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , ''  ],

  # SBFIZ
  ['sbfiz'             , 'Wd, Wn, #lsb, #width'                  , 'A64: 0001|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['sbfiz'             , 'Xd, Xn, #lsb, #width'                  , 'A64: 1001|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # SBFM
  ['sbfm'              , 'Wd, Wn, #immr, #imms'                  , 'A64: 0001|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['sbfm'              , 'Xd, Xn, #immr, #imms'                  , 'A64: 1001|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # SBFX
  ['sbfx'              , 'Wd, Wn, #lsb, #width'                  , 'A64: 0001|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['sbfx'              , 'Xd, Xn, #lsb, #width'                  , 'A64: 1001|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # SDIV
  ['sdiv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0000|11|Wn:5|Wd:5'                                     , ''  ],
  ['sdiv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0000|11|Xn:5|Xd:5'                                     , ''  ],

  # SEV
  ['sev'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|1001|1111'                                  , ''  ],

  # SEVL
  ['sevl'              , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|1011|1111'                                  , ''  ],

  # SMADDL
  ['smaddl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|001|Wm:5|0|Xa:5|Wn:5|Xd:5'                                      , ''  ],

  # SMC
  ['smc'               , '#imm'                                  , 'A64: 1101|0100|000|imm:16|0001|1'                                              , ''  ],

  # SMNEGL
  ['smnegl'            , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|001|Wm:5|1111|11|Wn:5|Xd:5'                                     , ''  ],

  # SMSUBL
  ['smsubl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|001|Wm:5|1|Xa:5|Wn:5|Xd:5'                                      , ''  ],

  # SMULH
  ['smulh'             , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|010|Xm:5|0111|11|Xn:5|Xd:5'                                     , ''  ],

  # SMULL
  ['smull'             , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|001|Wm:5|0111|11|Wn:5|Xd:5'                                     , ''  ],

  # STLR
  ['stlr'              , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|1001|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],
  ['stlr'              , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|1001|1111|1111|11|Xn:5|Xt:5'                                    , ''  ],

  # STLRB
  ['stlrb'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|1001|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],

  # STLRH
  ['stlrh'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|1001|1111|1111|11|Xn:5|Wt:5'                                    , ''  ],

  # STLXP
  ['stlxp'             , 'Ws, Wt1, Wt2, [$Xn, {#0}]'             , 'A64: 1000|1000|001|Ws:5|1|Wt2:5|Xn:5|Wt1:5'                                    , ''  ],
  ['stlxp'             , 'Ws, Xt1, Xt2, [$Xn, {#0}]'             , 'A64: 1100|1000|001|Ws:5|1|Xt2:5|Xn:5|Xt1:5'                                    , ''  ],

  # STLXR
  ['stlxr'             , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 1000|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                     , ''  ],
  ['stlxr'             , 'Ws, Xt, [$Xn, {#0}]'                   , 'A64: 1100|1000|000|Ws:5|1111|11|Xn:5|Xt:5'                                     , ''  ],

  # STLXRB
  ['stlxrb'            , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0000|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                     , ''  ],

  # STLXRH
  ['stlxrh'            , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0100|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                     , ''  ],

  # STNP
  ['stnp'              , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1000|00|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['stnp'              , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1000|00|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],

  # STP
  ['stp'               , 'Wt1, Wt2, [$Xn], #imm*4'               , 'A64: 0010|1000|10|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['stp'               , 'Xt1, Xt2, [$Xn], #imm*8'               , 'A64: 1010|1000|10|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],
  ['stp'               , 'Wt1, Wt2, [$Xn, #imm*4]!'              , 'A64: 0010|1001|10|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['stp'               , 'Xt1, Xt2, [$Xn, #imm*8]!'              , 'A64: 1010|1001|10|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],
  ['stp'               , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1001|00|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , ''  ],
  ['stp'               , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1001|00|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , ''  ],

  # STR (immediate)
  ['str'               , 'Wt, [$Xn], #imm.s'                     , 'A64: 1011|1000|000|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['str'               , 'Xt, [$Xn], #imm.s'                     , 'A64: 1111|1000|000|imm:9|01|Xn:5|Xt:5'                                         , ''  ],
  ['str'               , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 1011|1000|000|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['str'               , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 1111|1000|000|imm:9|11|Xn:5|Xt:5'                                         , ''  ],
  ['str'               , 'Wt, [$Xn, {#imm.z*4}]'                 , 'A64: 1011|1001|00|imm:12|Xn:5|Wt:5'                                            , ''  ],
  ['str'               , 'Xt, [$Xn, {#imm.z*8}]'                 , 'A64: 1111|1001|00|imm:12|Xn:5|Xt:5'                                            , ''  ],

  # STR (register)
  ['str'               , 'Wt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 1011|1000|001|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Wt:5'                     , ''  ],
  ['str'               , 'Xt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 1111|1000|001|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Xt:5'                     , ''  ],

  # STRB (immediate)
  ['strb'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0011|1000|000|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['strb'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|000|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['strb'              , 'Wt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|00|imm:12|Xn:5|Wt:5'                                            , ''  ],

  # STRB (register)
  ['strb'              , 'Wt, [$Xn, (Wm|Xm), extend {amount}]'   , 'A64: 0011|1000|001|Wm/Xm:5|extend!=011|amount:1|10|Xn:5|Wt:5'                  , ''  ],
  ['strb'              , 'Wt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|001|Xm:5|011|amount:1|10|Xn:5|Wt:5'                             , ''  ],

  # STRH (immediate)
  ['strh'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0111|1000|000|imm:9|01|Xn:5|Wt:5'                                         , ''  ],
  ['strh'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|000|imm:9|11|Xn:5|Wt:5'                                         , ''  ],
  ['strh'              , 'Wt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|00|imm:12|Xn:5|Wt:5'                                            , ''  ],

  # STRH (register)
  ['strh'              , 'Wt, [$Xn, (Wm|Xm), {extend {amount}}]' , 'A64: 0111|1000|001|Wm/Xm:5|extend:3|amount:1|10|Xn:5|Wt:5'                     , ''  ],

  # STTR
  ['sttr'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|000|imm:9|10|Xn:5|Wt:5'                                         , ''  ],
  ['sttr'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|000|imm:9|10|Xn:5|Xt:5'                                         , ''  ],

  # STTRB
  ['sttrb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|000|imm:9|10|Xn:5|Wt:5'                                         , ''  ],

  # STTRH
  ['sttrh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|000|imm:9|10|Xn:5|Wt:5'                                         , ''  ],

  # STUR
  ['stur'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|000|imm:9|00|Xn:5|Wt:5'                                         , ''  ],
  ['stur'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|000|imm:9|00|Xn:5|Xt:5'                                         , ''  ],

  # STURB
  ['sturb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|000|imm:9|00|Xn:5|Wt:5'                                         , ''  ],

  # STURH
  ['sturh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|000|imm:9|00|Xn:5|Wt:5'                                         , ''  ],

  # STXP
  ['stxp'              , 'Ws, Wt1, Wt2, [$Xn, {#0}]'             , 'A64: 1000|1000|001|Ws:5|0|Wt2:5|Xn:5|Wt1:5'                                    , ''  ],
  ['stxp'              , 'Ws, Xt1, Xt2, [$Xn, {#0}]'             , 'A64: 1100|1000|001|Ws:5|0|Xt2:5|Xn:5|Xt1:5'                                    , ''  ],

  # STXR
  ['stxr'              , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 1000|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                     , ''  ],
  ['stxr'              , 'Ws, Xt, [$Xn, {#0}]'                   , 'A64: 1100|1000|000|Ws:5|0111|11|Xn:5|Xt:5'                                     , ''  ],

  # STXRB
  ['stxrb'             , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0000|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                     , ''  ],

  # STXRH
  ['stxrh'             , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0100|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                     , ''  ],

  # SUB (extended register)
  ['sub'               , '$Wd, $Wn, Wm, {extend {#amount}}'      , 'A64: 0100|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , ''  ],
  ['sub'               , '$Xd, $Xn, R.m, {extend {#amount}}'     , 'A64: 1100|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , ''  ],

  # SUB (immediate)
  ['sub'               , '$Wd, $Wn, #imm.z, {shift {#amount}}'   , 'A64: 0101|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , ''  ],
  ['sub'               , '$Xd, $Xn, #imm.z, {shift {#amount}}'   , 'A64: 1101|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , ''  ],

  # SUB (shifted register)
  ['sub'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0100|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['sub'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1100|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # SUBS (extended register)
  ['subs'              , 'Wd, $Wn, Wm, {extend {#amount}}'       , 'A64: 0110|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , ''  ],
  ['subs'              , 'Xd, $Xn, R.m, {extend {#amount}}'      , 'A64: 1110|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , ''  ],

  # SUBS (immediate)
  ['subs'              , 'Wd, $Wn, #imm.z, {shift {#amount}}'    , 'A64: 0111|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , ''  ],
  ['subs'              , 'Xd, $Xn, #imm.z, {shift {#amount}}'    , 'A64: 1111|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , ''  ],

  # SUBS (shifted register)
  ['subs'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , ''  ],
  ['subs'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , ''  ],

  # SVC
  ['svc'               , '#imm'                                  , 'A64: 1101|0100|000|imm:16|0000|1'                                              , ''  ],

  # SXTB
  ['sxtb'              , 'Wd, Wn'                                , 'A64: 0001|0011|0000|0000|0001|11|Wn:5|Wd:5'                                    , ''  ],
  ['sxtb'              , 'Xd, Wn'                                , 'A64: 1001|0011|0100|0000|0001|11|Wn:5|Xd:5'                                    , ''  ],

  # SXTH
  ['sxth'              , 'Wd, Wn'                                , 'A64: 0001|0011|0000|0000|0011|11|Wn:5|Wd:5'                                    , ''  ],
  ['sxth'              , 'Xd, Wn'                                , 'A64: 1001|0011|0100|0000|0011|11|Wn:5|Xd:5'                                    , ''  ],

  # SXTW
  ['sxtw'              , 'Xd, Wn'                                , 'A64: 1001|0011|0100|0000|0111|11|Wn:5|Xd:5'                                    , ''  ],

  # SYS
  ['sys'               , '#op1, Cn, Cm, #op2, {Xt}'              , 'A64: 1101|0101|0000|1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                              , ''  ],

  # SYSL
  ['sysl'              , 'Xt, #op1, Cn, Cm, #op2'                , 'A64: 1101|0101|0010|1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                              , ''  ],

  # TBNZ
  ['tbnz'              , 'R.t, #imm.s, rel.s*4'                  , 'A64: R/imm:1|0110|111|imm:5|rel:14|t:5'                                        , ''  ],

  # TBZ
  ['tbz'               , 'R.t, #imm.s, rel.s*4'                  , 'A64: R/imm:1|0110|110|imm:5|rel:14|t:5'                                        , ''  ],

  # TLBI
  ['tlbi'              , 'tlbi_op, {Xt}'                         , 'A64: 1101|0101|0000|1|tlbi_op:3|1000|tlbi_op:4|tlbi_op:3|Xt:5'                 , ''  ],

  # TST (immediate)
  ['tst'               , 'Wn, #bimm'                             , 'A64: 0111|0010|00|bimm.B:6|bimm.A:6|Wn:5|1111|1'                               , ''  ],
  ['tst'               , 'Xn, #bimm'                             , 'A64: 1111|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|1111|1'                       , ''  ],

  # TST (shifted register)
  ['tst'               , 'Wn, Wm, {shift #amount}'               , 'A64: 0110|1010|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                            , ''  ],
  ['tst'               , 'Xn, Xm, {shift #amount}'               , 'A64: 1110|1010|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                            , ''  ],

  # UBFIZ
  ['ubfiz'             , 'Wd, Wn, #lsb, #width'                  , 'A64: 0101|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['ubfiz'             , 'Xd, Xn, #lsb, #width'                  , 'A64: 1101|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # UBFM
  ['ubfm'              , 'Wd, Wn, #immr, #imms'                  , 'A64: 0101|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['ubfm'              , 'Xd, Xn, #immr, #imms'                  , 'A64: 1101|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # UBFX
  ['ubfx'              , 'Wd, Wn, #lsb, #width'                  , 'A64: 0101|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , ''  ],
  ['ubfx'              , 'Xd, Xn, #lsb, #width'                  , 'A64: 1101|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , ''  ],

  # UDIV
  ['udiv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0000|10|Wn:5|Wd:5'                                     , ''  ],
  ['udiv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0000|10|Xn:5|Xd:5'                                     , ''  ],

  # UMADDL
  ['umaddl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|101|Wm:5|0|Xa:5|Wn:5|Xd:5'                                      , ''  ],

  # UMNEGL
  ['umnegl'            , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|101|Wm:5|1111|11|Wn:5|Xd:5'                                     , ''  ],

  # UMSUBL
  ['umsubl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|101|Wm:5|1|Xa:5|Wn:5|Xd:5'                                      , ''  ],

  # UMULH
  ['umulh'             , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|110|Xm:5|0111|11|Xn:5|Xd:5'                                     , ''  ],

  # UMULL
  ['umull'             , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|101|Wm:5|0111|11|Wn:5|Xd:5'                                     , ''  ],

  # UXTB
  ['uxtb'              , 'Wd, Wn'                                , 'A64: 0101|0011|0000|0000|0001|11|Wn:5|Wd:5'                                    , ''  ],

  # UXTH
  ['uxth'              , 'Wd, Wn'                                , 'A64: 0101|0011|0000|0000|0011|11|Wn:5|Wd:5'                                    , ''  ],

  # WFE
  ['wfe'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0101|1111'                                  , ''  ],

  # WFI
  ['wfi'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0111|1111'                                  , ''  ],

  # YIELD
  ['yield'             , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0011|1111'                                  , ''  ],

);
