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

  # ==> ADC, ADCS (immediate)
  ['adc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|01|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1010|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1011|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> ADC, ADCS (register)
  ['adc%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|01|Rm:3|Rdn:3'                                                  , 'BASE IT=IN'  ],
  ['adcs{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|01|Rm:3|Rdn:3'                                                  , 'BASE IT=OUT'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0100|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['adc%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0100|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=IN'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0100|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0101|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['adcs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0101|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=OUT'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0101|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> ADC, ADCS (register-shifted register)
  ['adcs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1011|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['adc{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1010|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> ADD, ADDS (immediate)
  ['add%c{%q}'         , 'Rd, Rn, #imm.z'                        , 'T16: 0001|110|imm:3|Rn:3|Rd:3'                                                 , 'BASE IT=IN'  ],
  ['adds{%q}'          , 'Rd, Rn, #imm.z'                        , 'T16: 0001|110|imm:3|Rn:3|Rd:3'                                                 , 'BASE IT=OUT'  ],
  ['add%c{%q}'         , 'Rdn, #imm.z'                           , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'BASE IT=IN'  ],
  ['add%c{%q}'         , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'BASE IT=IN'  ],
  ['adds{%q}'          , 'Rdn, #imm.z'                           , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'BASE IT=OUT'  ],
  ['adds{%q}'          , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|0|Rdn:3|imm:8'                                                       , 'BASE IT=OUT'  ],
  ['add%c.W'           , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|00|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , 'BASE IT=IN'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|00|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , 'BASE'  ],
  ['adds.W'            , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|01|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , 'BASE IT=OUT'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|01|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1000|00|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , 'BASE'  ],
  ['addw{%c}{%q}'      , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1000|00|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1000|Rn!=11x1|Rd:4|cnst:12'                               , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1001|Rn!=1101|Rd:4|cnst:12'                               , 'BASE'  ],

  # ==> ADD, ADDS (register)
  ['add%c{%q}'         , 'Rd, Rn, Rm'                            , 'T16: 0001|100|Rm:3|Rn:3|Rd:3'                                                  , 'BASE IT=IN'  ],
  ['adds{%q}'          , '{Rd}, Rn, Rm'                          , 'T16: 0001|100|Rm:3|Rn:3|Rd:3'                                                  , 'BASE IT=OUT'  ],
  ['add%c{%q}'         , 'Rdn, Rm'                               , 'T16: 0100|0100|Rdn!=1|Rm!=1101|Rdn!=101'                                       , 'BASE IT=IN FORM=PREFERRED'  ],
  ['add{%c}{%q}'       , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0100|Rdn!=1|Rm!=1101|Rdn!=101'                                       , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0000|Rn!=1101|0000|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['add%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0000|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'BASE IT=IN'  ],
  ['add{%c}.W'         , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0000|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0000|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0001|Rn!=1101|0000|Rd!=1111|0011|Rm:4'                          , 'BASE'  ],
  ['adds.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0001|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'      , 'BASE IT=OUT'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0001|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4' , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1000|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1000|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1001|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1001|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , 'BASE'  ],

  # ==> ADD, ADDS (register-shifted register)
  ['adds{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> ADD, ADDS (SP plus immediate)
  ['add{%c}{%q}'       , 'Rd, SP, #imm.z*4'                      , 'T16: 1010|1|Rd:3|imm:8'                                                        , 'BASE'  ],
  ['add{%c}{%q}'       , '{SP}, SP, #imm.z*4'                    , 'T16: 1011|0000|0|imm:7'                                                        , 'BASE'  ],
  ['add{%c}.W'         , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|0011|010|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|0011|010|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0100|0111|010|cnst:3|Rd!=1111|cnst:8'                       , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1000|0011|010|imm:3|Rd:4|imm:8'                              , 'BASE'  ],
  ['addw{%c}{%q}'      , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1000|0011|010|imm:3|Rd:4|imm:8'                              , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|1000|1101|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|1001|1101|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> ADD, ADDS (SP plus register)
  ['add{%c}{%q}'       , '{Rdm}, SP, Rdm'                        , 'T16: 0100|0100|Rdm:1|1101|Rdm:3'                                               , 'BASE'  ],
  ['add{%c}{%q}'       , '{SP}, SP, Rm'                          , 'T16: 0100|0100|1|Rm!=1101|101'                                                 , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|0000|1101|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['add{%c}.W'         , '{Rd}, SP, Rm'                          , 'T32: 1110|1011|0000|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|0000|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|0001|1101|0000|Rd!=1111|0011|Rm:4'                              , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|0001|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|1000|1101|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['add{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1000|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|1001|1101|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['adds{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1001|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> ADD (immediate, to PC)
  ['add{%c}{%q}'       , 'Rd, PC, #imm.z*4'                      , 'T16: 1010|0|Rd:3|imm:8'                                                        , 'BASE ALIAS_OF=adr PREFERRED_IF=NEVER'  ],
  ['addw{%c}{%q}'      , 'Rd, PC, #imm.z'                        , 'T32: 1111|0|imm:1|1000|0011|110|imm:3|Rd:4|imm:8'                              , 'BASE ALIAS_OF=adr PREFERRED_IF=NEVER'  ],
  ['add{%c}{%q}'       , 'Rd, PC, #imm.z'                        , 'T32: 1111|0|imm:1|1000|0011|110|imm:3|Rd:4|imm:8'                              , 'BASE ALIAS_OF=adr PREFERRED_IF=NEVER'  ],
  ['add{%c}{%q}'       , 'Rd, PC, #cnst.x'                       , 'A32: cond!=1111|0010|1000|1111|Rd:4|cnst:12'                                   , 'BASE ALIAS_OF=adr PREFERRED_IF=NEVER'  ],

  # ==> ADR
  ['adr{%c}{%q}'       , 'Rd, rel.z*4'                           , 'T16: 1010|0|Rd:3|rel:8'                                                        , 'BASE'  ],
  ['adr{%c}{%q}'       , 'Rd, rel.z'                             , 'T32: 1111|0|rel:1|1010|1011|110|rel:3|Rd:4|rel:8'                              , 'BASE'  ],
  ['adr{%c}.W'         , 'Rd, rel.z'                             , 'T32: 1111|0|rel:1|1000|0011|110|rel:3|Rd:4|rel:8'                              , 'BASE'  ],
  ['adr{%c}{%q}'       , 'Rd, rel.z'                             , 'T32: 1111|0|rel:1|1000|0011|110|rel:3|Rd:4|rel:8'                              , 'BASE'  ],
  ['adr{%c}{%q}'       , 'Rd, rel.x'                             , 'A32: cond!=1111|0010|1000|1111|Rd:4|rel:12'                                    , 'BASE'  ],
  ['adr{%c}{%q}'       , 'Rd, rel.x'                             , 'A32: cond!=1111|0010|0100|1111|Rd:4|rel:12'                                    , 'BASE'  ],

  # ==> AND, ANDS (immediate)
  ['and{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|01|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                      , 'BASE'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0000|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0001|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> AND, ANDS (register)
  ['and%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|00|Rm:3|Rdn:3'                                                  , 'BASE IT=IN'  ],
  ['ands{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|00|Rm:3|Rdn:3'                                                  , 'BASE IT=OUT'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0000|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['and%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0000|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=IN'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0000|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0001|Rn:4|0000|Rd!=1111|0011|Rm:4'                              , 'BASE'  ],
  ['ands.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0001|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'          , 'BASE IT=OUT'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0001|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> AND, ANDS (register-shifted register)
  ['ands{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['and{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> ASR (immediate)
  ['asr%c{%q}'         , '{Rd}, Rm, #imm'                        , 'T16: 0001|0|imm:5|Rm:3|Rd:3'                                                   , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['asr%c.W'           , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm:5|100|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> ASR (register)
  ['asr%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['asr%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0100|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0100|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['asr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0101|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> ASRS (immediate)
  ['asrs{%q}'          , '{Rd}, Rm, #imm'                        , 'T16: 0001|0|imm:5|Rm:3|Rd:3'                                                   , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['asrs.W'            , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|10|Rm:4'                           , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm:5|100|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> ASRS (register)
  ['asrs{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['asrs.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0101|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0101|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['asrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0101|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> B
  ['b%c{%q}'           , 'rel.s*2'                               , 'T16: 1101|cond!=111x|rel:8'                                                    , 'BASE IT=OUT'  ],
  ['b{%c}{%q}'         , 'rel.s*2'                               , 'T16: 1110|0|rel:11'                                                            , 'BASE IT=IN|LAST|OUT'  ],
  ['b%c.W'             , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'          , 'BASE IT=OUT'  ],
  ['b%c{%q}'           , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|cond!=111x|rel.D:6|10|rel.C:1|0|rel.B:1|rel.E:11'          , 'BASE IT=OUT'  ],
  ['b{%c}.W'           , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                          , 'BASE'  ],
  ['b{%c}{%q}'         , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|rel.D:10|10|J1:1|1|J2:1|rel.E:11'                          , 'BASE'  ],
  ['b{%c}{%q}'         , 'rel.s*4'                               , 'A32: cond!=1111|1010|rel:24'                                                   , 'BASE'  ],

  # ==> BFC
  ['bfc{%c}{%q}'       , 'Rd, #lsb, #width.w'                    , 'T32: 1111|0011|0110|1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                         , 'BASE'  ],
  ['bfc{%c}{%q}'       , 'Rd, #lsb, #width.w'                    , 'A32: cond!=1111|0111|110|width:5|Rd:4|lsb:5|0011|111'                          , 'BASE'  ],

  # ==> BFI
  ['bfi{%c}{%q}'       , 'Rd, Rn, #lsb, #width.w'                , 'T32: 1111|0011|0110|Rn!=1111|0|lsb:3|Rd:4|lsb:2|0|width:5'                     , 'BASE'  ],
  ['bfi{%c}{%q}'       , 'Rd, Rn, #lsb, #width.w'                , 'A32: cond!=1111|0111|110|width:5|Rd:4|lsb:5|001|Rn!=1111'                      , 'BASE'  ],

  # ==> BIC, BICS (immediate)
  ['bic{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|10|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0000|11|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1100|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1101|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> BIC, BICS (register)
  ['bic%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|10|Rm:3|Rdn:3'                                                  , 'BASE IT=IN'  ],
  ['bics{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|10|Rm:3|Rdn:3'                                                  , 'BASE IT=OUT'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0010|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['bic%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0010|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=IN'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0010|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0011|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['bics.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0011|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=OUT'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0011|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> BIC, BICS (register-shifted register)
  ['bics{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['bic{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> BKPT
  ['bkpt{%q}'          , '{#}imm.z'                              , 'T16: 1011|1110|imm:8'                                                          , 'BASE'  ],
  ['bkpt{%q}'          , '{#}imm'                                , 'A32: cond!=1111|0001|0010|imm:12|0111|imm:4'                                   , 'BASE'  ],

  # ==> BL, BLX (immediate)
  ['bl{%c}{%q}'        , 'rel.s*2'                               , 'T32: 1111|0|rel.A:1|rel.D:10|11|J1:1|1|J2:1|rel.E:11'                          , 'BASE'  ],
  ['blx{%c}{%q}'       , 'rel.s*4'                               , 'T32: 1111|0|rel.A:1|rel.D:10|11|J1:1|0|J2:1|rel.E:10|H'                        , 'BASE'  ],
  ['bl{%c}{%q}'        , 'rel.s*4'                               , 'A32: cond!=1111|1011|rel:24'                                                   , 'BASE'  ],
  ['blx{%c}{%q}'       , 'rel.s*2'                               , 'A32: 1111|101|rel.B:1|rel.A:24'                                                , 'BASE'  ],

  # ==> BLX (register)
  ['blx{%c}{%q}'       , 'Rm'                                    , 'T16: 0100|0111|1|Rm:4|000'                                                     , 'BASE'  ],
  ['blx{%c}{%q}'       , 'Rm'                                    , 'A32: cond!=1111|0001|0010|1111|1111|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> BX
  ['bx{%c}{%q}'        , 'Rm'                                    , 'T16: 0100|0111|0|Rm:4|000'                                                     , 'BASE'  ],
  ['bx{%c}{%q}'        , 'Rm'                                    , 'A32: cond!=1111|0001|0010|1111|1111|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> BXJ
  ['bxj{%c}{%q}'       , 'Rm'                                    , 'T32: 1111|0011|1100|Rm:4|1000|1111|0000|0000'                                  , 'BASE'  ],
  ['bxj{%c}{%q}'       , 'Rm'                                    , 'A32: cond!=1111|0001|0010|1111|1111|1111|0010|Rm:4'                            , 'BASE'  ],

  # ==> CBNZ, CBZ
  ['cbnz{%q}'          , 'Rn, rel.z*2'                           , 'T16: 1011|10|rel:1|1|rel:5|Rn:3'                                               , 'BASE'  ],
  ['cbz{%q}'           , 'Rn, rel.z*2'                           , 'T16: 1011|00|rel:1|1|rel:5|Rn:3'                                               , 'BASE'  ],

  # ==> CLREX
  ['clrex{%c}{%q}'     , ''                                      , 'T32: 1111|0011|1011|1111|1000|1111|0010|1111'                                  , 'BASE'  ],
  ['clrex{%c}{%q}'     , ''                                      , 'A32: 1111|0101|0111|1111|1111|0000|0001|1111'                                  , 'BASE'  ],

  # ==> CLZ
  ['clz{%c}{%q}'       , 'Rd, Rm'                                , 'T32: 1111|1010|1011|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['clz{%c}{%q}'       , 'Rd, Rm'                                , 'A32: cond!=1111|0001|0110|1111|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> CMN (immediate)
  ['cmn{%c}{%q}'       , 'Rn, #cnst.x'                           , 'T32: 1111|0|cnst:1|0100|01|Rn:4|0|cnst:3|1111|cnst:8'                          , 'BASE'  ],
  ['cmn{%c}{%q}'       , 'Rn, #cnst.x'                           , 'A32: cond!=1111|0011|0111|Rn:4|0000|cnst:12'                                   , 'BASE'  ],

  # ==> CMN (register)
  ['cmn{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0010|11|Rm:3|Rn:3'                                                   , 'BASE'  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1011|0001|Rn:4|0000|1111|0011|Rm:4'                                  , 'BASE'  ],
  ['cmn{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110|1011|0001|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , 'BASE'  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'T32: 1110|1011|0001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0111|Rn:4|0000|0000|0110|Rm:4'                            , 'BASE'  ],
  ['cmn{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0111|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> CMN (register-shifted register)
  ['cmn{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0111|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> CMP (immediate)
  ['cmp{%c}{%q}'       , 'Rn, #imm.z'                            , 'T16: 0010|1|Rn:3|imm:8'                                                        , 'BASE'  ],
  ['cmp{%c}.W'         , 'Rn, #cnst.x'                           , 'T32: 1111|0|cnst:1|0110|11|Rn:4|0|cnst:3|1111|cnst:8'                          , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, #cnst.x'                           , 'T32: 1111|0|cnst:1|0110|11|Rn:4|0|cnst:3|1111|cnst:8'                          , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, #cnst.x'                           , 'A32: cond!=1111|0011|0101|Rn:4|0000|cnst:12'                                   , 'BASE'  ],

  # ==> CMP (register)
  ['cmp{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0010|10|Rm:3|Rn:3'                                                   , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0101|Rn:1|Rm:3|Rn:4'                                                 , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1011|1011|Rn:4|0000|1111|0011|Rm:4'                                  , 'BASE'  ],
  ['cmp{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110|1011|1011|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, shift #amount'                 , 'T32: 1110|1011|1011|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0101|Rn:4|0000|0000|0110|Rm:4'                            , 'BASE'  ],
  ['cmp{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0101|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> CMP (register-shifted register)
  ['cmp{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0101|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> CPS, CPSID, CPSIE
  ['cpsid{%q}'         , 'iflags'                                , 'T16: 1011|0110|0111|0|A|I|F'                                                   , 'BASE IT=OUT'  ],
  ['cpsie{%q}'         , 'iflags'                                , 'T16: 1011|0110|0110|0|A|I|F'                                                   , 'BASE IT=OUT'  ],
  ['cps{%q}'           , '#mode'                                 , 'T32: 1111|0011|1010|1111|1000|0001|A|I|F|mode:5'                               , 'BASE IT=OUT'  ],
  ['cpsid.W'           , 'iflags'                                , 'T32: 1111|0011|1010|1111|1000|0110|A|I|F|mode:5'                               , 'BASE IT=OUT'  ],
  ['cpsid{%q}'         , 'iflags, #mode'                         , 'T32: 1111|0011|1010|1111|1000|0111|A|I|F|mode:5'                               , 'BASE IT=OUT'  ],
  ['cpsie.W'           , 'iflags'                                , 'T32: 1111|0011|1010|1111|1000|0100|A|I|F|mode:5'                               , 'BASE IT=OUT'  ],
  ['cpsie{%q}'         , 'iflags, #mode'                         , 'T32: 1111|0011|1010|1111|1000|0101|A|I|F|mode:5'                               , 'BASE IT=OUT'  ],
  ['cps{%q}'           , '#mode'                                 , 'A32: 1111|0001|0000|0010|0000|000|A|I|F|0|mode:5'                              , 'BASE'  ],
  ['cpsid{%q}'         , 'iflags'                                , 'A32: 1111|0001|0000|1100|0000|000|A|I|F|0|mode:5'                              , 'BASE'  ],
  ['cpsid{%q}'         , 'iflags , #mode'                        , 'A32: 1111|0001|0000|1110|0000|000|A|I|F|0|mode:5'                              , 'BASE'  ],
  ['cpsie{%q}'         , 'iflags'                                , 'A32: 1111|0001|0000|1000|0000|000|A|I|F|0|mode:5'                              , 'BASE'  ],
  ['cpsie{%q}'         , 'iflags , #mode'                        , 'A32: 1111|0001|0000|1010|0000|000|A|I|F|0|mode:5'                              , 'BASE'  ],

  # ==> CRC32
  ['crc32b{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['crc32h{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1001|Rm:4'                                  , 'BASE'  ],
  ['crc32w{%q}'        , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|1010|Rm:4'                                  , 'BASE'  ],
  ['crc32b{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0000|0100|Rm:4'                            , 'BASE'  ],
  ['crc32h{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0000|0100|Rm:4'                            , 'BASE'  ],
  ['crc32w{%q}'        , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0000|0100|Rm:4'                            , 'BASE'  ],

  # ==> CRC32C
  ['crc32cb{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['crc32ch{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1001|Rm:4'                                  , 'BASE'  ],
  ['crc32cw{%q}'       , 'Rd, Rn, Rm'                            , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|1010|Rm:4'                                  , 'BASE'  ],
  ['crc32cb{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0010|0100|Rm:4'                            , 'BASE'  ],
  ['crc32ch{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0010|0100|Rm:4'                            , 'BASE'  ],
  ['crc32cw{%q}'       , 'Rd, Rn, Rm'                            , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0010|0100|Rm:4'                            , 'BASE'  ],

  # ==> DBG
  ['dbg{%c}{%q}'       , '#option'                               , 'T32: 1111|0011|1010|1111|1000|0000|1111|option:4'                              , 'BASE'  ],
  ['dbg{%c}{%q}'       , '#option'                               , 'A32: cond!=1111|0011|0010|0000|1111|0000|1111|option:4'                        , 'BASE'  ],

  # ==> DCPS1, DCPS2, DCPS3
  ['dcps1'             , ''                                      , 'T32: 1111|0111|1000|1111|1000|0000|0000|0001'                                  , 'BASE'  ],
  ['dcps2'             , ''                                      , 'T32: 1111|0111|1000|1111|1000|0000|0000|0010'                                  , 'BASE'  ],
  ['dcps3'             , ''                                      , 'T32: 1111|0111|1000|1111|1000|0000|0000|0011'                                  , 'BASE'  ],

  # ==> DMB
  ['dmb{%c}{%q}'       , '{option}'                              , 'T32: 1111|0011|1011|1111|1000|1111|0101|option:4'                              , 'BASE'  ],
  ['dmb{%c}{%q}'       , '{option}'                              , 'A32: 1111|0101|0111|1111|1111|0000|0101|option:4'                              , 'BASE'  ],

  # ==> DSB
  ['dsb{%c}{%q}'       , '{option}'                              , 'T32: 1111|0011|1011|1111|1000|1111|0100|option:4'                              , 'BASE'  ],
  ['dsb{%c}{%q}'       , '{option}'                              , 'A32: 1111|0101|0111|1111|1111|0000|0100|option:4'                              , 'BASE'  ],

  # ==> EOR, EORS (immediate)
  ['eor{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0010|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0010|01|Rn:4|0|cnst:3|Rd!=1111|cnst:8'                      , 'BASE'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0010|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0010|0011|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> EOR, EORS (register)
  ['eor%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|01|Rm:3|Rdn:3'                                                  , 'BASE IT=IN'  ],
  ['eors{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0000|01|Rm:3|Rdn:3'                                                  , 'BASE IT=OUT'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|1000|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['eor%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|1000|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=IN'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|1000|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|1001|Rn:4|0000|Rd!=1111|0011|Rm:4'                              , 'BASE'  ],
  ['eors.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|1001|Rn:4|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'          , 'BASE IT=OUT'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|1001|Rn:4|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> EOR, EORS (register-shifted register)
  ['eors{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0011|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['eor{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0010|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> ERET
  ['eret{%c}{%q}'      , ''                                      , 'T32: 1111|0011|1101|1110|1000|1111|0000|0000'                                  , 'BASE'  ],
  ['eret{%c}{%q}'      , ''                                      , 'A32: cond!=1111|0001|0110|0000|0000|0000|0110|1110'                            , 'BASE'  ],

  # ==> HLT
  ['hlt{%q}'           , '{#}imm'                                , 'T16: 1011|1010|10|imm:6'                                                       , 'BASE'  ],
  ['hlt{%q}'           , '{#}imm'                                , 'A32: cond!=1111|0001|0000|imm:12|0111|imm:4'                                   , 'BASE'  ],

  # ==> HVC
  ['hvc{%q}'           , '{#}imm'                                , 'T32: 1111|0111|1110|imm:4|1000|imm:12'                                         , 'BASE'  ],
  ['hvc{%q}'           , '{#}imm'                                , 'A32: cond!=1111|0001|0100|imm:12|0111|imm:4'                                   , 'BASE'  ],

  # ==> ISB
  ['isb{%c}{%q}'       , '{option}'                              , 'T32: 1111|0011|1011|1111|1000|1111|0110|option:4'                              , 'BASE'  ],
  ['isb{%c}{%q}'       , '{option}'                              , 'A32: 1111|0101|0111|1111|1111|0000|0110|option:4'                              , 'BASE'  ],

  # ==> IT
  ['it{%x{%y{%z}}}{%q}', 'cond'                                  , 'T16: 1011|1111|cond:4|x/y/z!=0000'                                             , 'BASE'  ],

  # ==> LDA
  ['lda{%c}{%q}'       , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1010|1111'                                  , 'BASE'  ],
  ['lda{%c}{%q}'       , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1100|1001|1111'                            , 'BASE'  ],

  # ==> LDAB
  ['ldab{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1000|1111'                                  , 'BASE'  ],
  ['ldab{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1100|1001|1111'                            , 'BASE'  ],

  # ==> LDAEX
  ['ldaex{%c}{%q}'     , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1110|1111'                                  , 'BASE'  ],
  ['ldaex{%c}{%q}'     , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1110|1001|1111'                            , 'BASE'  ],

  # ==> LDAEXB
  ['ldaexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1100|1111'                                  , 'BASE'  ],
  ['ldaexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1110|1001|1111'                            , 'BASE'  ],

  # ==> LDAEXD
  ['ldaexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'T32: 1110|1000|1101|Rn:4|Rt:4|Rt2:4|1111|1111'                                 , 'BASE'  ],
  ['ldaexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'A32: cond!=1111|0001|1011|Rn:4|Rt:4|1110|1001|1111'                            , 'BASE'  ],

  # ==> LDAEXH
  ['ldaexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1101|1111'                                  , 'BASE'  ],
  ['ldaexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1110|1001|1111'                            , 'BASE'  ],

  # ==> LDAH
  ['ldah{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|1001|1111'                                  , 'BASE'  ],
  ['ldah{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1100|1001|1111'                            , 'BASE'  ],

  # ==> LDC (immediate)
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1101|U|001|Rn!=1111|0101|1110|imm:8'                                 , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1100|U|011|Rn!=1111|0101|1110|imm:8'                                 , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1101|U|011|Rn!=1111|0101|1110|imm:8'                                 , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'T32: 1110|1100|1001|Rn!=1111|0101|1110|option:8'                               , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'A32: cond!=1111|1101|U|001|Rn!=1111|0101|1110|imm:8'                           , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'A32: cond!=1111|1100|U|011|Rn!=1111|0101|1110|imm:8'                           , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'A32: cond!=1111|1101|U|011|Rn!=1111|0101|1110|imm:8'                           , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'A32: cond!=1111|1100|1001|Rn!=1111|0101|1110|option:8'                         , 'BASE'  ],

  # ==> LDC (literal)
  ['ldc{%c}{%q}'       , 'p14, c5, rel.z*4'                      , 'T32: 1110|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|rel:8'                         , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC, #{+/-}imm.z*4]'          , 'T32: 1110|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|imm:8'                         , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, rel.z*4'                      , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|rel:8'                   , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC, #{+/-}imm.z*4]'          , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|imm:8'                   , 'BASE'  ],
  ['ldc{%c}{%q}'       , 'p14, c5, [PC], option'                 , 'A32: cond!=1111|110|P!=0|U!=0|0|W!=0|1111|1010|1111|0|option:8'                , 'BASE'  ],

  # ==> LDM, LDMIA, LDMFD
  ['ldm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'T16: 1100|1|Rn:3|list:8'                                                       , 'BASE FORM=PREFERRED'  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T16: 1100|1|Rn:3|list:8'                                                       , 'BASE FORM=ALTERNATIVE'  ],
  ['ldm{ia}{%c}.W'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , 'BASE FORM=PREFERRED'  ],
  ['ldmfd{%c}.W'       , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , 'BASE FORM=ALTERNATIVE'  ],
  ['ldm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , 'BASE FORM=PREFERRED'  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|1|Rn:4|list:1|list:1|0|list:13'                            , 'BASE FORM=ALTERNATIVE'  ],
  ['ldm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|1|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['ldmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|1|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDM (exception return)
  ['ldm{%amode}{%c}{%q}', 'Rn{!}, list'                           , 'A32: cond!=1111|100|P|U|1|W|1|Rn:4|1|list:15'                                  , 'BASE'  ],

  # ==> LDM (User registers)
  ['ldm{%amode}{%c}{%q}', 'Rn, list'                              , 'A32: cond!=1111|100|P|U|101|Rn:4|0|list:15'                                    , 'BASE'  ],

  # ==> LDMDA, LDMFA
  ['ldmda{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|1|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['ldmfa{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|1|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDMDB, LDMEA
  ['ldmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|1|Rn:4|list:1|list:1|0|list:13'                            , 'BASE FORM=PREFERRED'  ],
  ['ldmea{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|1|Rn:4|list:1|list:1|0|list:13'                            , 'BASE FORM=ALTERNATIVE'  ],
  ['ldmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|1|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['ldmea{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|1|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDMIB, LDMED
  ['ldmib{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|1|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['ldmed{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|1|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDR (immediate)
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z*4}]'               , 'T16: 0110|1|imm:5|Rn:3|Rt:3'                                                   , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [SP, {#{+}imm.z*4}]'               , 'T16: 1001|1|Rt:3|imm:8'                                                        , 'BASE'  ],
  ['ldr{%c}.W'         , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1101|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1101|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|1100|imm:8'                                  , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|001|Rn!=1111|Rt:4|imm:12'                               , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|001|Rn!=1111|Rt:4|imm:12'                               , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|011|Rn!=1111|Rt:4|imm:12'                               , 'BASE'  ],

  # ==> LDR (literal)
  ['ldr{%c}{%q}'       , 'Rt, rel.z*4'                           , 'T16: 0100|1|Rt:3|rel:8'                                                        , 'BASE FORM=PREFERRED'  ],
  ['ldr{%c}.W'         , 'Rt, rel.z'                             , 'T32: 1111|1000|U|1011|111|Rt:4|rel:12'                                         , 'BASE FORM=PREFERRED'  ],
  ['ldr{%c}{%q}'       , 'Rt, rel.z'                             , 'T32: 1111|1000|U|1011|111|Rt:4|rel:12'                                         , 'BASE FORM=PREFERRED'  ],
  ['ldr{%c}{%q}'       , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1000|U|1011|111|Rt:4|imm:12'                                         , 'BASE FORM=ALTERNATIVE'  ],
  ['ldr{%c}{%q}'       , 'Rt, rel.z'                             , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1111|1|Rt:4|rel:12'                          , 'BASE FORM=PREFERRED'  ],
  ['ldr{%c}{%q}'       , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|010|P!=0|U|0|W!=1|1111|1|Rt:4|imm:12'                          , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDR (register)
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|100|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['ldr{%c}.W'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|001|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|001|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['ldr{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|011|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> LDRB (immediate)
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T16: 0111|1|imm:5|Rn:3|Rt:3'                                                   , 'BASE'  ],
  ['ldrb{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1001|Rn!=1111|Rt!=1111|imm:12'                                  , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1001|Rn!=1111|Rt!=1111|imm:12'                                  , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|1100|imm:8'                              , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|101|Rn!=1111|Rt:4|imm:12'                               , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|101|Rn!=1111|Rt:4|imm:12'                               , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|111|Rn!=1111|Rt:4|imm:12'                               , 'BASE'  ],

  # ==> LDRB (literal)
  ['ldrb{%c}{%q}'      , 'Rt, rel.z'                             , 'T32: 1111|1000|U|0011|111|Rt!=1111|rel:12'                                     , 'BASE FORM=PREFERRED'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1000|U|0011|111|Rt!=1111|imm:12'                                     , 'BASE FORM=ALTERNATIVE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, rel.z'                             , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1111|1|Rt:4|rel:12'                          , 'BASE FORM=PREFERRED'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|010|P!=0|U|1|W!=1|1111|1|Rt:4|imm:12'                          , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDRB (register)
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|110|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['ldrb{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0001|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|101|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|101|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['ldrb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|111|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> LDRBT
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0001|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|111|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['ldrbt{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|111|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> LDRD (immediate)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1001|U|101|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1000|U|111|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1001|U|111|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z}]'          , 'A32: cond!=1111|0001|U|100|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z'            , 'A32: cond!=1111|0000|U|100|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z]!'           , 'A32: cond!=1111|0001|U|110|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , 'BASE'  ],

  # ==> LDRD (literal)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, rel.z*4'                      , 'T32: 1110|100|P!=0|U|1|W!=0|1111|1|Rt:4|Rt2:4|rel:8'                           , 'BASE FORM=PREFERRED'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [PC, #{+/-}imm.z]'            , 'T32: 1110|100|P!=0|U|1|W!=0|1111|1|Rt:4|Rt2:4|imm:8'                           , 'BASE FORM=ALTERNATIVE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, rel.z'                        , 'A32: cond!=1111|0001|U|1001|111|Rt:4|rel:4|1101|rel:4'                         , 'BASE FORM=PREFERRED'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [PC, #{+/-}imm.z]'            , 'A32: cond!=1111|0001|U|1001|111|Rt:4|imm:4|1101|imm:4'                         , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDRD (register)
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]'                , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn], {+/-}Rm'                , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],
  ['ldrd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]!'               , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],

  # ==> LDREX
  ['ldrex{%c}{%q}'     , 'Rt, [Rn, {#imm.z*4}]'                  , 'T32: 1110|1000|0101|Rn:4|Rt:4|1111|imm:8'                                      , 'BASE'  ],
  ['ldrex{%c}{%q}'     , 'Rt, [Rn, {{#}0}]'                      , 'A32: cond!=1111|0001|1001|Rn:4|Rt:4|1111|1001|1111'                            , 'BASE'  ],

  # ==> LDREXB
  ['ldrexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|0100|1111'                                  , 'BASE'  ],
  ['ldrexb{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1101|Rn:4|Rt:4|1111|1001|1111'                            , 'BASE'  ],

  # ==> LDREXD
  ['ldrexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'T32: 1110|1000|1101|Rn:4|Rt:4|Rt2:4|0111|1111'                                 , 'BASE'  ],
  ['ldrexd{%c}{%q}'    , 'Rt, Rt2, [Rn]'                         , 'A32: cond!=1111|0001|1011|Rn:4|Rt:4|1111|1001|1111'                            , 'BASE'  ],

  # ==> LDREXH
  ['ldrexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'T32: 1110|1000|1101|Rn:4|Rt:4|1111|0101|1111'                                  , 'BASE'  ],
  ['ldrexh{%c}{%q}'    , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1111|Rn:4|Rt:4|1111|1001|1111'                            , 'BASE'  ],

  # ==> LDRH (immediate)
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z*2}]'               , 'T16: 1000|1|imm:5|Rn:3|Rt:3'                                                   , 'BASE'  ],
  ['ldrh{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1011|Rn!=1111|Rt!=1111|imm:12'                                  , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1011|Rn!=1111|Rt!=1111|imm:12'                                  , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|1100|imm:8'                              , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1011|imm:4'                     , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1011|imm:4'                     , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1011|imm:4'                     , 'BASE'  ],

  # ==> LDRH (literal)
  ['ldrh{%c}{%q}'      , 'Rt, rel.z'                             , 'T32: 1111|1000|U|0111|111|Rt!=1111|rel:12'                                     , 'BASE FORM=PREFERRED'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1000|U|0111|111|Rt!=1111|imm:12'                                     , 'BASE FORM=ALTERNATIVE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1011|rel:4'                , 'BASE FORM=PREFERRED'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1011|imm:4'                , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDRH (register)
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|101|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['ldrh{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0011|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],
  ['ldrh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],

  # ==> LDRHT
  ['ldrht{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0011|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['ldrht{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1011|imm:4'                         , 'BASE'  ],
  ['ldrht{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],

  # ==> LDRSB (immediate)
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|1001|Rn!=1111|Rt!=1111|imm:12'                                  , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|1100|imm:8'                                  , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1101|imm:4'                     , 'BASE'  ],

  # ==> LDRSB (literal)
  ['ldrsb{%c}{%q}'     , 'Rt, rel.z'                             , 'T32: 1111|1001|U|0011|111|Rt!=1111|rel:12'                                     , 'BASE FORM=PREFERRED'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1001|U|0011|111|Rt!=1111|imm:12'                                     , 'BASE FORM=ALTERNATIVE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1101|rel:4'                , 'BASE FORM=PREFERRED'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1101|imm:4'                , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDRSB (register)
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|011|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['ldrsb{%c}.W'       , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1001|0001|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1001|0001|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],
  ['ldrsb{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],

  # ==> LDRSBT
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|0001|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1101|imm:4'                         , 'BASE'  ],
  ['ldrsbt{%c}{%q}'    , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1101|Rm:4'                           , 'BASE'  ],

  # ==> LDRSH (immediate)
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|1011|Rn!=1111|Rt!=1111|imm:12'                                  , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|1100|imm:8'                              , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|101|Rn!=1111|Rt:4|imm:4|1111|imm:4'                     , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|101|Rn!=1111|Rt:4|imm:4|1111|imm:4'                     , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|111|Rn!=1111|Rt:4|imm:4|1111|imm:4'                     , 'BASE'  ],

  # ==> LDRSH (literal)
  ['ldrsh{%c}{%q}'     , 'Rt, rel.z'                             , 'T32: 1111|1001|U|0111|111|Rt!=1111|rel:12'                                     , 'BASE FORM=PREFERRED'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'T32: 1111|1001|U|0111|111|Rt!=1111|imm:12'                                     , 'BASE FORM=ALTERNATIVE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, rel.z'                             , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|rel:4|1111|rel:4'                , 'BASE FORM=PREFERRED'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [PC, #{+/-}imm.z]'                 , 'A32: cond!=1111|000|P!=0|U|1|W!=1|1111|1|Rt:4|imm:4|1111|imm:4'                , 'BASE FORM=ALTERNATIVE'  ],

  # ==> LDRSH (register)
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|111|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['ldrsh{%c}.W'       , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|0000|00|imm2:2|Rm:4'                     , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1001|0011|Rn!=1111|Rt!=1111|0000|00|imm:2|Rm:4'                      , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|001|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|001|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],
  ['ldrsh{%c}{%q}'     , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|011|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],

  # ==> LDRSHT
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1001|0011|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|111|Rn:4|Rt:4|imm:4|1111|imm:4'                         , 'BASE'  ],
  ['ldrsht{%c}{%q}'    , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|011|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],

  # ==> LDRT
  ['ldrt{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0101|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['ldrt{%c}{%q}'      , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|011|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['ldrt{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|011|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> LSL (immediate)
  ['lsl%c{%q}'         , '{Rd}, Rm, #imm'                        , 'T16: 0000|0|imm!=00000|Rm:3|Rd:3'                                              , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['lsl%c.W'           , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm!=00000|000|Rm:4'                       , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> LSL (register)
  ['lsl%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['lsl%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0000|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0000|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['lsl{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0001|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> LSLS (immediate)
  ['lsls{%q}'          , '{Rd}, Rm, #imm'                        , 'T16: 0000|0|imm!=00000|Rm:3|Rd:3'                                              , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['lsls.W'            , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|00|Rm:4'                           , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm!=00000|000|Rm:4'                       , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> LSLS (register)
  ['lsls{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['lsls.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0001|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0001|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['lsls{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0001|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> LSR (immediate)
  ['lsr%c{%q}'         , '{Rd}, Rm, #imm'                        , 'T16: 0000|1|imm:5|Rm:3|Rd:3'                                                   , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['lsr%c.W'           , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm:5|010|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> LSR (register)
  ['lsr%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['lsr%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0010|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0010|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['lsr{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0011|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> LSRS (immediate)
  ['lsrs{%q}'          , '{Rd}, Rm, #imm'                        , 'T16: 0000|1|imm:5|Rm:3|Rd:3'                                                   , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['lsrs.W'            , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm:3|Rd:4|imm:2|01|Rm:4'                           , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm:5|010|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> LSRS (register)
  ['lsrs{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['lsrs.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0011|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0011|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['lsrs{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0011|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> MCR
  ['mcr{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'T32: 1110|1110|opc1:3|0|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                 , 'BASE'  ],
  ['mcr{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'A32: cond!=1111|1110|opc1:3|0|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'           , 'BASE'  ],

  # ==> MCRR
  ['mcrr{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'T32: 1110|1100|0100|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                       , 'BASE'  ],
  ['mcrr{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'A32: cond!=1111|1100|0100|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                 , 'BASE'  ],

  # ==> MLA, MLAS
  ['mla{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0000|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['mlas{%c}{%q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|0011|Rd:4|Ra:4|Rm:4|1001|Rn:4'                            , 'BASE'  ],
  ['mla{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|0010|Rd:4|Ra:4|Rm:4|1001|Rn:4'                            , 'BASE'  ],

  # ==> MLS
  ['mls{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0000|Rn:4|Ra:4|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['mls{%c}{%q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0000|0110|Rd:4|Ra:4|Rm:4|1001|Rn:4'                            , 'BASE'  ],

  # ==> MOV, MOVS (immediate)
  ['mov%c{%q}'         , 'Rd, #imm.z'                            , 'T16: 0010|0|Rd:3|imm:8'                                                        , 'BASE IT=IN'  ],
  ['movs{%q}'          , 'Rd, #imm.z'                            , 'T16: 0010|0|Rd:3|imm:8'                                                        , 'BASE IT=OUT'  ],
  ['mov%c.W'           , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0011|110|cnst:3|Rd:4|cnst:8'                           , 'BASE IT=IN'  ],
  ['mov{%c}{%q}'       , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0011|110|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['movs.W'            , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0111|110|cnst:3|Rd:4|cnst:8'                           , 'BASE IT=OUT'  ],
  ['movs{%c}{%q}'      , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|0111|110|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['mov{%c}{%q}'       , 'Rd, #imm.z'                            , 'T32: 1111|0|imm.B:1|1001|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , 'BASE'  ],
  ['movw{%c}{%q}'      , 'Rd, #imm.z'                            , 'T32: 1111|0|imm.B:1|1001|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , 'BASE'  ],
  ['mov{%c}{%q}'       , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1010|0000|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['movs{%c}{%q}'      , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1011|0000|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['mov{%c}{%q}'       , 'Rd, #imm.z'                            , 'A32: cond!=1111|0011|0000|imm:4|Rd:4|imm:12'                                   , 'BASE'  ],
  ['movw{%c}{%q}'      , 'Rd, #imm.z'                            , 'A32: cond!=1111|0011|0000|imm:4|Rd:4|imm:12'                                   , 'BASE'  ],

  # ==> MOV, MOVS (register)
  ['mov{%c}{%q}'       , 'Rd, Rm'                                , 'T16: 0100|0110|Rd:1|Rm:3|Rd:4'                                                 , 'BASE'  ],
  ['mov%c{%q}'         , 'Rd, Rm, {shift #amount}'               , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                         , 'BASE IT=IN'  ],
  ['movs{%q}'          , 'Rd, Rm, {shift #amount}'               , 'T16: 000|shift!=11|amount:5|Rm:3|Rd:3'                                         , 'BASE IT=OUT'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0100|1111|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['mov{%c}.W'         , 'Rd, Rm, {LSL #0}'                      , 'T32: 1110|1010|0100|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE'  ],
  ['mov%c.W'           , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0100|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE IT=IN'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0100|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0101|1111|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['movs.W'            , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0101|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE IT=OUT'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0101|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1010|0000|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1010|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1011|0000|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1011|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> MOV, MOVS (register-shifted register)
  ['mov%c{%q}'         , 'Rdm, Rdm, ASR Rs'                      , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'BASE IT=IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, ASR Rs'                      , 'T16: 0100|0001|00|Rs:3|Rdm:3'                                                  , 'BASE IT=OUT'  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, LSL Rs'                      , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'BASE IT=IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, LSL Rs'                      , 'T16: 0100|0000|10|Rs:3|Rdm:3'                                                  , 'BASE IT=OUT'  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, LSR Rs'                      , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'BASE IT=IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, LSR Rs'                      , 'T16: 0100|0000|11|Rs:3|Rdm:3'                                                  , 'BASE IT=OUT'  ],
  ['mov%c{%q}'         , 'Rdm, Rdm, ROR Rs'                      , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'BASE IT=IN'  ],
  ['movs{%q}'          , 'Rdm, Rdm, ROR Rs'                      , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'BASE IT=OUT'  ],
  ['movs.W'            , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                            , 'BASE IT=OUT'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                            , 'BASE'  ],
  ['mov%c.W'           , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                            , 'BASE IT=IN'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'T32: 1111|1010|0|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                            , 'BASE'  ],
  ['movs{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['mov{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> MOVT
  ['movt{%c}{%q}'      , 'Rd, #imm'                              , 'T32: 1111|0|imm.B:1|1011|00|imm.A:4|0|imm.C:3|Rd:4|imm.D:8'                    , 'BASE'  ],
  ['movt{%c}{%q}'      , 'Rd, #imm'                              , 'A32: cond!=1111|0011|0100|imm:4|Rd:4|imm:12'                                   , 'BASE'  ],

  # ==> MRC
  ['mrc{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'T32: 1110|1110|opc1:3|1|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'                 , 'BASE'  ],
  ['mrc{%c}{%q}'       , 'coproc, {#}opc1, Rt, CRn, CRm, {{#}opc2}', 'A32: cond!=1111|1110|opc1:3|1|CRn:4|Rt:4|coproc=111x|opc2:3|1|CRm:4'           , 'BASE'  ],

  # ==> MRRC
  ['mrrc{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'T32: 1110|1100|0101|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                       , 'BASE'  ],
  ['mrrc{%c}{%q}'      , 'coproc, {#}opc1, Rt, Rt2, CRm'         , 'A32: cond!=1111|1100|0101|Rt2:4|Rt:4|coproc=111x|opc1:4|CRm:4'                 , 'BASE'  ],

  # ==> MRS
  ['mrs{%c}{%q}'       , 'Rd, sreg'                              , 'T32: 1111|0011|111|sreg:1|1111|1000|Rd:4|0000|0000'                            , 'BASE'  ],
  ['mrs{%c}{%q}'       , 'Rd, sreg'                              , 'A32: cond!=1111|0001|0|sreg:1|0011|11|Rd:4|0000|0000|0000'                     , 'BASE'  ],

  # ==> MRS (Banked register)
  ['mrs{%c}{%q}'       , 'Rd, breg'                              , 'T32: 1111|0011|111|breg.A:1|breg.C:4|1000|Rd:4|001|breg.B:1|0000'              , 'BASE'  ],
  ['mrs{%c}{%q}'       , 'Rd, breg'                              , 'A32: cond!=1111|0001|0|breg.A:1|00|breg.C:4|Rd:4|001|breg.B:1|0000|0000'       , 'BASE'  ],

  # ==> MSR (Banked register)
  ['msr{%c}{%q}'       , 'breg, Rn'                              , 'T32: 1111|0011|100|breg.A:1|Rn:4|1000|breg.C:4|001|breg.B:1|0000'              , 'BASE'  ],
  ['msr{%c}{%q}'       , 'breg, Rn'                              , 'A32: cond!=1111|0001|0|breg.A:1|10|breg.C:4|1111|001|breg.B:1|0000|Rn:4'       , 'BASE'  ],

  # ==> MSR (immediate)
  ['msr{%c}{%q}'       , 'sreg, #imm.x'                          , 'A32: cond!=1111|0011|0|R!=0|10|mask!=0000|1111|imm:12'                         , 'BASE'  ],

  # ==> MSR (register)
  ['msr{%c}{%q}'       , 'sreg, Rn'                              , 'T32: 1111|0011|100|R|Rn:4|1000|mask:4|0000|0000'                               , 'BASE'  ],
  ['msr{%c}{%q}'       , 'sreg, Rn'                              , 'A32: cond!=1111|0001|0|R|10|mask:4|1111|0000|0000|Rn:4'                        , 'BASE'  ],

  # ==> MUL, MULS
  ['mul%c{%q}'         , 'Rdm, Rn, {Rdm}'                        , 'T16: 0100|0011|01|Rn:3|Rdm:3'                                                  , 'BASE IT=IN'  ],
  ['muls{%q}'          , 'Rdm, Rn, {Rdm}'                        , 'T16: 0100|0011|01|Rn:3|Rdm:3'                                                  , 'BASE IT=OUT'  ],
  ['mul%c.W'           , 'Rd, Rn, {Rm}'                          , 'T32: 1111|1011|0000|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE IT=IN'  ],
  ['mul{%c}{%q}'       , 'Rd, Rn, {Rm}'                          , 'T32: 1111|1011|0000|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['muls{%c}{%q}'      , 'Rd, Rn, {Rm}'                          , 'A32: cond!=1111|0000|0001|Rd:4|0000|Rm:4|1001|Rn:4'                            , 'BASE'  ],
  ['mul{%c}{%q}'       , 'Rd, Rn, {Rm}'                          , 'A32: cond!=1111|0000|0000|Rd:4|0000|Rm:4|1001|Rn:4'                            , 'BASE'  ],

  # ==> MVN, MVNS (immediate)
  ['mvn{%c}{%q}'       , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|1011|110|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['mvns{%c}{%q}'      , 'Rd, #cnst.c'                           , 'T32: 1111|0|cnst:1|0001|1111|110|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['mvn{%c}{%q}'       , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1110|0000|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['mvns{%c}{%q}'      , 'Rd, #cnst.c'                           , 'A32: cond!=1111|0011|1111|0000|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> MVN, MVNS (register)
  ['mvn%c{%q}'         , 'Rd, Rm'                                , 'T16: 0100|0011|11|Rm:3|Rd:3'                                                   , 'BASE IT=IN'  ],
  ['mvns{%q}'          , 'Rd, Rm'                                , 'T16: 0100|0011|11|Rm:3|Rd:3'                                                   , 'BASE IT=OUT'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0110|1111|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['mvn%c.W'           , 'Rd, Rm'                                , 'T32: 1110|1010|0110|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=IN'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0110|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'T32: 1110|1010|0111|1111|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['mvns.W'            , 'Rd, Rm'                                , 'T32: 1110|1010|0111|1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=OUT'  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'T32: 1110|1010|0111|1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1110|0000|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1110|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, RRX'                           , 'A32: cond!=1111|0001|1111|0000|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['mvns{%c}{%q}'      , 'Rd, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|1111|0000|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> MVN, MVNS (register-shifted register)
  ['mvns{%c}{%q}'      , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1111|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['mvn{%c}{%q}'       , 'Rd, Rm, type Rs'                       , 'A32: cond!=1111|0001|1110|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> NOP
  ['nop{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0000|0000'                                                      , 'BASE'  ],
  ['nop{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0000'                                  , 'BASE'  ],
  ['nop{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0000'                            , 'BASE'  ],

  # ==> ORN, ORNS (immediate)
  ['orns{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|11|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , 'BASE'  ],
  ['orn{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|10|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , 'BASE'  ],

  # ==> ORN, ORNS (register)
  ['orn{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0110|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['orn{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0110|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['orns{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0111|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['orns{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0111|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],

  # ==> ORR, ORRS (immediate)
  ['orr{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|00|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , 'BASE'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'T32: 1111|0|cnst:1|0001|01|Rn!=1111|0|cnst:3|Rd:4|cnst:8'                      , 'BASE'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1000|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, #cnst.c'                     , 'A32: cond!=1111|0011|1001|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> ORR, ORRS (register)
  ['orr%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|00|Rm:3|Rdn:3'                                                  , 'BASE IT=IN'  ],
  ['orrs{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0011|00|Rm:3|Rdn:3'                                                  , 'BASE IT=OUT'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0100|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['orr%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0100|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'BASE IT=IN'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0100|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1010|0101|Rn!=1111|0000|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['orrs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1010|0101|Rn!=1111|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'BASE IT=OUT'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1010|0101|Rn!=1111|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> ORR, ORRS (register-shifted register)
  ['orrs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1001|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['orr{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> PKHBT, PKHTB
  ['pkhbt{%c}{%q}'     , '{Rd}, Rn, Rm, {LSL #imm}'              , 'T32: 1110|1010|1100|Rn:4|0|imm:3|Rd:4|imm2:2|00|Rm:4'                          , 'BASE'  ],
  ['pkhtb{%c}{%q}'     , '{Rd}, Rn, Rm, {ASR #imm}'              , 'T32: 1110|1010|1100|Rn:4|0|imm:3|Rd:4|imm2:2|10|Rm:4'                          , 'BASE'  ],
  ['pkhbt{%c}{%q}'     , '{Rd}, Rn, Rm, {LSL #imm}'              , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|imm:5|001|Rm:4'                            , 'BASE'  ],
  ['pkhtb{%c}{%q}'     , '{Rd}, Rn, Rm, {ASR #imm}'              , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|imm:5|101|Rm:4'                            , 'BASE'  ],

  # ==> PLD, PLDW (immediate)
  ['pld{%c}{%q}'       , '[Rn, {#{+}imm.z}]'                     , 'T32: 1111|1000|1001|Rn!=1111|1111|imm:12'                                      , 'BASE'  ],
  ['pldw{%c}{%q}'      , '[Rn, {#{+}imm.z}]'                     , 'T32: 1111|1000|1011|Rn!=1111|1111|imm:12'                                      , 'BASE'  ],
  ['pld{%c}{%q}'       , '[Rn, {#-imm.z}]'                       , 'T32: 1111|1000|0001|Rn!=1111|1111|1100|imm:8'                                  , 'BASE'  ],
  ['pldw{%c}{%q}'      , '[Rn, {#-imm.z}]'                       , 'T32: 1111|1000|0011|Rn!=1111|1111|1100|imm:8'                                  , 'BASE'  ],
  ['pld{%c}{%q}'       , '[Rn, {#{+/-}imm.z}]'                   , 'A32: 1111|0101|U|101|Rn!=1111|1111|imm:12'                                     , 'BASE'  ],
  ['pldw{%c}{%q}'      , '[Rn, {#{+/-}imm.z}]'                   , 'A32: 1111|0101|U|001|Rn!=1111|1111|imm:12'                                     , 'BASE'  ],

  # ==> PLD (literal)
  ['pld{%c}{%q}'       , 'rel.z'                                 , 'T32: 1111|1000|U|0011|1111|111|rel:12'                                         , 'BASE FORM=PREFERRED'  ],
  ['pld{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'T32: 1111|1000|U|0011|1111|111|imm:12'                                         , 'BASE FORM=ALTERNATIVE'  ],
  ['pld{%c}{%q}'       , 'rel.z'                                 , 'A32: 1111|0101|U|1011|1111|111|rel:12'                                         , 'BASE FORM=PREFERRED'  ],
  ['pld{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'A32: 1111|0101|U|1011|1111|111|imm:12'                                         , 'BASE FORM=ALTERNATIVE'  ],

  # ==> PLD, PLDW (register)
  ['pld{%c}{%q}'       , '[Rn, {+}Rm, {LSL #amount}]'            , 'T32: 1111|1000|0001|Rn!=1111|1111|0000|00|amount:2|Rm:4'                       , 'BASE'  ],
  ['pldw{%c}{%q}'      , '[Rn, {+}Rm, {LSL #amount}]'            , 'T32: 1111|1000|0011|Rn!=1111|1111|0000|00|amount:2|Rm:4'                       , 'BASE'  ],
  ['pld{%c}{%q}'       , '[Rn, {+/-}Rm, {shift #amount}]'        , 'A32: 1111|0111|U|101|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                 , 'BASE'  ],
  ['pld{%c}{%q}'       , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111|0111|U|101|Rn:4|1111|0000|0110|Rm:4'                                 , 'BASE'  ],
  ['pldw{%c}{%q}'      , '[Rn, {+/-}Rm, {shift #amount}]'        , 'A32: 1111|0111|U|001|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                 , 'BASE'  ],
  ['pldw{%c}{%q}'      , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111|0111|U|001|Rn:4|1111|0000|0110|Rm:4'                                 , 'BASE'  ],

  # ==> PLI (immediate, literal)
  ['pli{%c}{%q}'       , '[Rn, {#{+}imm.z}]'                     , 'T32: 1111|1001|1001|Rn!=1111|1111|imm:12'                                      , 'BASE'  ],
  ['pli{%c}{%q}'       , '[Rn, {#-imm.z}]'                       , 'T32: 1111|1001|0001|Rn!=1111|1111|1100|imm:8'                                  , 'BASE'  ],
  ['pli{%c}{%q}'       , 'rel.z'                                 , 'T32: 1111|1001|U|0011|1111|111|rel:12'                                         , 'BASE FORM=PREFERRED'  ],
  ['pli{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'T32: 1111|1001|U|0011|1111|111|imm:12'                                         , 'BASE FORM=ALTERNATIVE'  ],
  ['pli{%c}{%q}'       , '[Rn, {#{+/-}imm.z}]'                   , 'A32: 1111|0100|U|101|Rn:4|1111|imm:12'                                         , 'BASE'  ],
  ['pli{%c}{%q}'       , 'rel.z'                                 , 'A32: 1111|0100|U|101|Rn:4|1111|rel:12'                                         , 'BASE FORM=PREFERRED'  ],
  ['pli{%c}{%q}'       , '[PC, #{+/-}imm.z]'                     , 'A32: 1111|0100|U|101|Rn:4|1111|imm:12'                                         , 'BASE FORM=ALTERNATIVE'  ],

  # ==> PLI (register)
  ['pli{%c}{%q}'       , '[Rn, {+}Rm, {LSL #amount}]'            , 'T32: 1111|1001|0001|Rn!=1111|1111|0000|00|amount:2|Rm:4'                       , 'BASE'  ],
  ['pli{%c}{%q}'       , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111|0110|U|101|Rn:4|1111|0000|0110|Rm:4'                                 , 'BASE'  ],
  ['pli{%c}{%q}'       , '[Rn, {+/-}Rm, {shift #amount}]'        , 'A32: 1111|0110|U|101|Rn:4|1111|amount!=00000|shift!=11|0|Rm:4'                 , 'BASE'  ],

  # ==> POP
  ['pop{%c}{%q}'       , 'list'                                  , 'T16: 1011|110|list.A:1|list.I:8'                                               , 'BASE FORM=PREFERRED'  ],
  ['ldm{%c}{%q}'       , 'SP!, list'                             , 'T16: 1011|110|list.A:1|list.I:8'                                               , 'BASE FORM=ALTERNATIVE'  ],

  # ==> POP (multiple registers)
  ['pop{%c}.W'         , 'list'                                  , 'T32: 1110|1000|1011|1101|list:1|list:1|0|list:13'                              , 'BASE ALIAS_OF=ldm PREFERRED_IF=BitCount(list)>1'  ],
  ['pop{%c}{%q}'       , 'list'                                  , 'T32: 1110|1000|1011|1101|list:1|list:1|0|list:13'                              , 'BASE ALIAS_OF=ldm PREFERRED_IF=BitCount(list)>1'  ],
  ['pop{%c}{%q}'       , 'list'                                  , 'A32: cond!=1111|1000|1011|1101|list:16'                                        , 'BASE ALIAS_OF=ldm PREFERRED_IF=BitCount(list)>1'  ],

  # ==> POP (single register)
  ['pop{%c}{%q}'       , 'RtList'                                , 'T32: 1111|1000|0101|1101|Rt:4|1011|0000|0100'                                  , 'BASE ALIAS_OF=ldr PREFERRED_IF=ALWAYS'  ],
  ['pop{%c}{%q}'       , 'RtList'                                , 'A32: cond!=1111|0100|1001|1101|Rt:4|0000|0000|0100'                            , 'BASE ALIAS_OF=ldr PREFERRED_IF=ALWAYS'  ],

  # ==> PUSH
  ['push{%c}{%q}'      , 'list'                                  , 'T16: 1011|010|list.A:1|list.H:8'                                               , 'BASE FORM=PREFERRED'  ],
  ['stmdb{%c}{%q}'     , 'SP!, list'                             , 'T16: 1011|010|list.A:1|list.H:8'                                               , 'BASE FORM=ALTERNATIVE'  ],

  # ==> PUSH (multiple registers)
  ['push{%c}.W'        , 'list'                                  , 'T32: 1110|1001|0010|1101|0|list.B:1|0|list.C:13'                               , 'BASE ALIAS_OF=stmdb PREFERRED_IF=BitCount(list.B:list.C)>1'  ],
  ['push{%c}{%q}'      , 'list'                                  , 'T32: 1110|1001|0010|1101|0|list.B:1|0|list.C:13'                               , 'BASE ALIAS_OF=stmdb PREFERRED_IF=BitCount(list.B:list.C)>1'  ],
  ['push{%c}{%q}'      , 'list'                                  , 'A32: cond!=1111|1001|0010|1101|list:16'                                        , 'BASE ALIAS_OF=stmdb PREFERRED_IF=BitCount(list)>1'  ],

  # ==> PUSH (single register)
  ['push{%c}{%q}'      , 'RtList'                                , 'T32: 1111|1000|0100|1101|Rt:4|1101|0000|0100'                                  , 'BASE ALIAS_OF=str PREFERRED_IF=ALWAYS'  ],
  ['push{%c}{%q}'      , 'RtList'                                , 'A32: cond!=1111|0101|0010|1101|Rt:4|0000|0000|0100'                            , 'BASE ALIAS_OF=str PREFERRED_IF=ALWAYS'  ],

  # ==> QADD
  ['qadd{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['qadd{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0000|Rn:4|Rd:4|0000|0101|Rm:4'                            , 'BASE'  ],

  # ==> QADD16
  ['qadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['qadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> QADD8
  ['qadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['qadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|1001|Rm:4'                            , 'BASE'  ],

  # ==> QASX
  ['qasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['qasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> QDADD
  ['qdadd{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1001|Rm:4'                                  , 'BASE'  ],
  ['qdadd{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0100|Rn:4|Rd:4|0000|0101|Rm:4'                            , 'BASE'  ],

  # ==> QDSUB
  ['qdsub{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1011|Rm:4'                                  , 'BASE'  ],
  ['qdsub{%c}{%q}'     , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0110|Rn:4|Rd:4|0000|0101|Rm:4'                            , 'BASE'  ],

  # ==> QSAX
  ['qsax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['qsax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0101|Rm:4'                            , 'BASE'  ],

  # ==> QSUB
  ['qsub{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|1010|Rm:4'                                  , 'BASE'  ],
  ['qsub{%c}{%q}'      , '{Rd}, Rm, Rn'                          , 'A32: cond!=1111|0001|0010|Rn:4|Rd:4|0000|0101|Rm:4'                            , 'BASE'  ],

  # ==> QSUB16
  ['qsub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['qsub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|0111|Rm:4'                            , 'BASE'  ],

  # ==> QSUB8
  ['qsub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['qsub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0010|Rn:4|Rd:4|1111|1111|Rm:4'                            , 'BASE'  ],

  # ==> RBIT
  ['rbit{%c}{%q}'      , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1010|Rm:4'                                  , 'BASE'  ],
  ['rbit{%c}{%q}'      , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1111|1111|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> REV
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'T16: 1011|1010|00|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['rev{%c}.W'         , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['rev{%c}{%q}'       , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1011|1111|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> REV16
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'T16: 1011|1010|01|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['rev16{%c}.W'       , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1001|Rm:4'                                  , 'BASE'  ],
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1001|Rm:4'                                  , 'BASE'  ],
  ['rev16{%c}{%q}'     , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1011|1111|Rd:4|1111|1011|Rm:4'                            , 'BASE'  ],

  # ==> REVSH
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'T16: 1011|1010|11|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['revsh{%c}.W'       , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1011|Rm:4'                                  , 'BASE'  ],
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|1011|Rm:4'                                  , 'BASE'  ],
  ['revsh{%c}{%q}'     , 'Rd, Rm'                                , 'A32: cond!=1111|0110|1111|1111|Rd:4|1111|1011|Rm:4'                            , 'BASE'  ],

  # ==> RFE, RFEDA, RFEDB, RFEIA, RFEIB
  ['rfedb{%c}{%q}'     , 'Rn{!}'                                 , 'T32: 1110|1000|00|W|1|Rn:4|1100|0000|0000|0000'                                , 'BASE IT=IN|LAST|OUT'  ],
  ['rfe{ia}{%c}{%q}'   , 'Rn{!}'                                 , 'T32: 1110|1001|10|W|1|Rn:4|1100|0000|0000|0000'                                , 'BASE IT=IN|LAST|OUT'  ],
  ['rfeda{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111|1000|00|W|1|Rn:4|0000|1010|0000|0000'                                , 'BASE'  ],
  ['rfedb{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111|1001|00|W|1|Rn:4|0000|1010|0000|0000'                                , 'BASE'  ],
  ['rfe{ia}{%c}{%q}'   , 'Rn{!}'                                 , 'A32: 1111|1000|10|W|1|Rn:4|0000|1010|0000|0000'                                , 'BASE'  ],
  ['rfeib{%c}{%q}'     , 'Rn{!}'                                 , 'A32: 1111|1001|10|W|1|Rn:4|0000|1010|0000|0000'                                , 'BASE'  ],

  # ==> ROR (immediate)
  ['ror{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0100|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                      , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['ror{%c}{%q}'       , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1010|0000|Rd:4|imm!=00000|110|Rm:4'                       , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> ROR (register)
  ['ror%c{%q}'         , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=mov IT=IN'  ],
  ['ror%c.W'           , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0110|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS IT=IN'  ],
  ['ror{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0110|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['ror{%c}{%q}'       , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1010|0000|Rd:4|Rs:4|0111|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> RORS (immediate)
  ['rors{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'T32: 1110|1010|0101|1111|0|imm!=000|Rd:4|imm!=00|11|Rm:4'                      , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['rors{%c}{%q}'      , '{Rd}, Rm, #imm'                        , 'A32: cond!=1111|0001|1011|0000|Rd:4|imm!=00000|110|Rm:4'                       , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> RORS (register)
  ['rors{%q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 0100|0001|11|Rs:3|Rdm:3'                                                  , 'BASE ALIAS_OF=movs IT=OUT'  ],
  ['rors.W'            , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0111|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS IT=OUT'  ],
  ['rors{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'T32: 1111|1010|0111|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['rors{%c}{%q}'      , '{Rd}, Rm, Rs'                          , 'A32: cond!=1111|0001|1011|0000|Rd:4|Rs:4|0111|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> RRX
  ['rrx{%c}{%q}'       , '{Rd}, Rm'                              , 'T32: 1110|1010|0100|1111|0000|Rd:4|0011|Rm:4'                                  , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],
  ['rrx{%c}{%q}'       , '{Rd}, Rm'                              , 'A32: cond!=1111|0001|1010|0000|Rd:4|0000|0110|Rm:4'                            , 'BASE ALIAS_OF=mov PREFERRED_IF=ALWAYS'  ],

  # ==> RRXS
  ['rrxs{%c}{%q}'      , '{Rd}, Rm'                              , 'T32: 1110|1010|0101|1111|0000|Rd:4|0011|Rm:4'                                  , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],
  ['rrxs{%c}{%q}'      , '{Rd}, Rm'                              , 'A32: cond!=1111|0001|1011|0000|Rd:4|0000|0110|Rm:4'                            , 'BASE ALIAS_OF=movs PREFERRED_IF=ALWAYS'  ],

  # ==> RSB, RSBS (immediate)
  ['rsb%c{%q}'         , '{Rd,}Rn, #0'                           , 'T16: 0100|0010|01|Rn:3|Rd:3'                                                   , 'BASE IT=IN'  ],
  ['rsbs{%q}'          , '{Rd,}Rn, #0'                           , 'T16: 0100|0010|01|Rn:3|Rd:3'                                                   , 'BASE IT=OUT'  ],
  ['rsb%c.W'           , '{Rd}, Rn, #0'                          , 'T32: 1111|0|i|0111|00|Rn:4|0|imm3:3|Rd:4|imm8:8'                               , 'BASE IT=IN'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0111|00|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['rsbs.W'            , '{Rd}, Rn, #0'                          , 'T32: 1111|0|i|0111|01|Rn:4|0|imm3:3|Rd:4|imm8:8'                               , 'BASE IT=OUT'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0111|01|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0110|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0111|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> RSB, RSBS (register)
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1100|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1100|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1101|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1101|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> RSB, RSBS (register-shifted register)
  ['rsbs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0111|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['rsb{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0110|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> RSC, RSCS (immediate)
  ['rsc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1110|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['rscs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1111|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> RSC, RSCS (register)
  ['rsc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['rsc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['rscs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['rscs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> RSC, RSCS (register-shifted register)
  ['rscs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1111|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['rsc{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1110|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> SADD16
  ['sadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['sadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> SADD8
  ['sadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['sadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|1001|Rm:4'                            , 'BASE'  ],

  # ==> SASX
  ['sasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['sasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> SBC, SBCS (immediate)
  ['sbc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|10|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0101|11|Rn:4|0|cnst:3|Rd:4|cnst:8'                          , 'BASE'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1100|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|1101|Rn:4|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> SBC, SBCS (register)
  ['sbc%c{%q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|10|Rm:3|Rdn:3'                                                  , 'BASE IT=IN'  ],
  ['sbcs{%q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 0100|0001|10|Rm:3|Rdn:3'                                                  , 'BASE IT=OUT'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0110|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['sbc%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0110|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=IN'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0110|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|0111|Rn:4|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['sbcs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|0111|Rn:4|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE IT=OUT'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|0111|Rn:4|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> SBC, SBCS (register-shifted register)
  ['sbcs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['sbc{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|1100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> SBFX
  ['sbfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'T32: 1111|0011|0100|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                         , 'BASE'  ],
  ['sbfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'A32: cond!=1111|0111|101|width:5|Rd:4|lsb:5|101|Rn:4'                          , 'BASE'  ],

  # ==> SDIV
  ['sdiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|1001|Rn:4|1111|Rd:4|1111|Rm:4'                                  , 'BASE'  ],
  ['sdiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0001|Rd:4|1111|Rm:4|0001|Rn:4'                            , 'BASE'  ],

  # ==> SEL
  ['sel{%c}{%q}'       , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|1000|Rm:4'                                  , 'BASE'  ],
  ['sel{%c}{%q}'       , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|1000|Rn:4|Rd:4|1111|1011|Rm:4'                            , 'BASE'  ],

  # ==> SETEND
  ['setend{%q}'        , 'endian'                                , 'T16: 1011|0110|0101|endian:1|000'                                              , 'BASE IT=OUT'  ],
  ['setend{%q}'        , 'endian'                                , 'A32: 1111|0001|0000|0001|0000|00|endian:1|0000|0000|0'                         , 'BASE'  ],

  # ==> SEV
  ['sev{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0100|0000'                                                      , 'BASE'  ],
  ['sev{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0100'                                  , 'BASE'  ],
  ['sev{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0100'                            , 'BASE'  ],

  # ==> SEVL
  ['sevl{%c}{%q}'      , ''                                      , 'T16: 1011|1111|0101|0000'                                                      , 'BASE'  ],
  ['sevl{%c}.W'        , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0101'                                  , 'BASE'  ],
  ['sevl{%c}{%q}'      , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0101'                            , 'BASE'  ],

  # ==> SHADD16
  ['shadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['shadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> SHADD8
  ['shadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['shadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|1001|Rm:4'                            , 'BASE'  ],

  # ==> SHASX
  ['shasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['shasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> SHSAX
  ['shsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['shsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0101|Rm:4'                            , 'BASE'  ],

  # ==> SHSUB16
  ['shsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['shsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|0111|Rm:4'                            , 'BASE'  ],

  # ==> SHSUB8
  ['shsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['shsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0011|Rn:4|Rd:4|1111|1111|Rm:4'                            , 'BASE'  ],

  # ==> SMC
  ['smc{%c}{%q}'       , '{#}imm'                                , 'T32: 1111|0111|1111|imm:4|1000|0000|0000|0000'                                 , 'BASE'  ],
  ['smc{%c}{%q}'       , '{#}imm'                                , 'A32: cond!=1111|0001|0110|0000|0000|0000|0111|imm:4'                           , 'BASE'  ],

  # ==> SMLABB, SMLABT, SMLATB, SMLATT
  ['smlabb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['smlabt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , 'BASE'  ],
  ['smlatb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0010|Rm:4'                              , 'BASE'  ],
  ['smlatt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0001|Rn:4|Ra!=1111|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['smlabb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1000|Rn:4'                            , 'BASE'  ],
  ['smlabt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1100|Rn:4'                            , 'BASE'  ],
  ['smlatb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1010|Rn:4'                            , 'BASE'  ],
  ['smlatt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0000|Rd:4|Ra:4|Rm:4|1110|Rn:4'                            , 'BASE'  ],

  # ==> SMLAD, SMLADX
  ['smlad{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0010|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['smladx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0010|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , 'BASE'  ],
  ['smlad{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                        , 'BASE'  ],
  ['smladx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0011|Rn:4'                        , 'BASE'  ],

  # ==> SMLAL, SMLALS
  ['smlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , 'BASE'  ],
  ['smlals{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1111|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],
  ['smlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1110|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],

  # ==> SMLALBB, SMLALBT, SMLALTB, SMLALTT
  ['smlalbb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1000|Rm:4'                              , 'BASE'  ],
  ['smlalbt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1001|Rm:4'                              , 'BASE'  ],
  ['smlaltb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1010|Rm:4'                              , 'BASE'  ],
  ['smlaltt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1011|Rm:4'                              , 'BASE'  ],
  ['smlalbb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1000|Rn:4'                        , 'BASE'  ],
  ['smlalbt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1100|Rn:4'                        , 'BASE'  ],
  ['smlaltb{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1010|Rn:4'                        , 'BASE'  ],
  ['smlaltt{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0001|0100|RdHi:4|RdLo:4|Rm:4|1110|Rn:4'                        , 'BASE'  ],

  # ==> SMLALD, SMLALDX
  ['smlald{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1100|Rm:4'                              , 'BASE'  ],
  ['smlaldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1100|Rn:4|RdLo:4|RdHi:4|1101|Rm:4'                              , 'BASE'  ],
  ['smlald{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0001|Rn:4'                        , 'BASE'  ],
  ['smlaldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0011|Rn:4'                        , 'BASE'  ],

  # ==> SMLAWB, SMLAWT
  ['smlawb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0011|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['smlawt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0011|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , 'BASE'  ],
  ['smlawb{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0010|Rd:4|Ra:4|Rm:4|1000|Rn:4'                            , 'BASE'  ],
  ['smlawt{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0001|0010|Rd:4|Ra:4|Rm:4|1100|Rn:4'                            , 'BASE'  ],

  # ==> SMLSD, SMLSDX
  ['smlsd{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0100|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['smlsdx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0100|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , 'BASE'  ],
  ['smlsd{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0101|Rn:4'                        , 'BASE'  ],
  ['smlsdx{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0000|Rd:4|Ra!=1111|Rm:4|0111|Rn:4'                        , 'BASE'  ],

  # ==> SMLSLD, SMLSLDX
  ['smlsld{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1101|Rn:4|RdLo:4|RdHi:4|1100|Rm:4'                              , 'BASE'  ],
  ['smlsldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1101|Rn:4|RdLo:4|RdHi:4|1101|Rm:4'                              , 'BASE'  ],
  ['smlsld{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0101|Rn:4'                        , 'BASE'  ],
  ['smlsldx{%c}{%q}'   , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0111|0100|RdHi:4|RdLo:4|Rm:4|0111|Rn:4'                        , 'BASE'  ],

  # ==> SMMLA, SMMLAR
  ['smmla{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0101|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['smmlar{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0101|Rn:4|Ra!=1111|Rd:4|0001|Rm:4'                              , 'BASE'  ],
  ['smmla{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                        , 'BASE'  ],
  ['smmlar{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra!=1111|Rm:4|0011|Rn:4'                        , 'BASE'  ],

  # ==> SMMLS, SMMLSR
  ['smmls{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0110|Rn:4|Ra:4|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['smmlsr{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0110|Rn:4|Ra:4|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['smmls{%c}{%q}'     , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra:4|Rm:4|1101|Rn:4'                            , 'BASE'  ],
  ['smmlsr{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|0101|Rd:4|Ra:4|Rm:4|1111|Rn:4'                            , 'BASE'  ],

  # ==> SMMUL, SMMULR
  ['smmul{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0101|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['smmulr{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0101|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['smmul{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0101|Rd:4|1111|Rm:4|0001|Rn:4'                            , 'BASE'  ],
  ['smmulr{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0101|Rd:4|1111|Rm:4|0011|Rn:4'                            , 'BASE'  ],

  # ==> SMUAD, SMUADX
  ['smuad{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0010|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['smuadx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0010|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['smuad{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0001|Rn:4'                            , 'BASE'  ],
  ['smuadx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0011|Rn:4'                            , 'BASE'  ],

  # ==> SMULBB, SMULBT, SMULTB, SMULTT
  ['smulbb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['smulbt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['smultb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0010|Rm:4'                                  , 'BASE'  ],
  ['smultt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0001|Rn:4|1111|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['smulbb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1000|Rn:4'                            , 'BASE'  ],
  ['smulbt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1100|Rn:4'                            , 'BASE'  ],
  ['smultb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1010|Rn:4'                            , 'BASE'  ],
  ['smultt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0110|Rd:4|0000|Rm:4|1110|Rn:4'                            , 'BASE'  ],

  # ==> SMULL, SMULLS
  ['smull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1000|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , 'BASE'  ],
  ['smulls{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1101|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],
  ['smull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1100|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],

  # ==> SMULWB, SMULWT
  ['smulwb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0011|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['smulwt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0011|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['smulwb{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0010|Rd:4|0000|Rm:4|1010|Rn:4'                            , 'BASE'  ],
  ['smulwt{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0001|0010|Rd:4|0000|Rm:4|1110|Rn:4'                            , 'BASE'  ],

  # ==> SMUSD, SMUSDX
  ['smusd{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0100|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['smusdx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0100|Rn:4|1111|Rd:4|0001|Rm:4'                                  , 'BASE'  ],
  ['smusd{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0101|Rn:4'                            , 'BASE'  ],
  ['smusdx{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0000|Rd:4|1111|Rm:4|0111|Rn:4'                            , 'BASE'  ],

  # ==> SRS, SRSDA, SRSDB, SRSIA, SRSIB
  ['srsdb{%c}{%q}'     , 'SP{!}, #mode'                          , 'T32: 1110|1000|00|W|0110|1110|0000|0000|mode:5'                                , 'BASE'  ],
  ['srs{ia}{%c}{%q}'   , 'SP{!}, #mode'                          , 'T32: 1110|1001|10|W|0110|1110|0000|0000|mode:5'                                , 'BASE'  ],
  ['srsda{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111|1000|01|W|0110|1000|0010|1000|mode:5'                                , 'BASE'  ],
  ['srsdb{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111|1001|01|W|0110|1000|0010|1000|mode:5'                                , 'BASE'  ],
  ['srs{ia}{%c}{%q}'   , 'SP{!}, #mode'                          , 'A32: 1111|1000|11|W|0110|1000|0010|1000|mode:5'                                , 'BASE'  ],
  ['srsib{%c}{%q}'     , 'SP{!}, #mode'                          , 'A32: 1111|1001|11|W|0110|1000|0010|1000|mode:5'                                , 'BASE'  ],

  # ==> SSAT
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, ASR #amount'           , 'T32: 1111|0011|0010|Rn:4|0|amount!=000|Rd:4|amount!=00|0|sat:5'                , 'BASE'  ],
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, {LSL #amount}'         , 'T32: 1111|0011|0000|Rn:4|0|amount:3|Rd:4|amount:2|0|sat:5'                     , 'BASE'  ],
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, ASR #amount'           , 'A32: cond!=1111|0110|101|sat:5|Rd:4|amount:5|101|Rn:4'                         , 'BASE'  ],
  ['ssat{%c}{%q}'      , 'Rd, #sat+1, Rn, {LSL #amount}'         , 'A32: cond!=1111|0110|101|sat:5|Rd:4|amount:5|001|Rn:4'                         , 'BASE'  ],

  # ==> SSAT16
  ['ssat16{%c}{%q}'    , 'Rd, #sat+1, Rn'                        , 'T32: 1111|0011|0010|Rn:4|0000|Rd:4|0000|sat:4'                                 , 'BASE'  ],
  ['ssat16{%c}{%q}'    , 'Rd, #sat+1, Rn'                        , 'A32: cond!=1111|0110|1010|sat:4|Rd:4|1111|0011|Rn:4'                           , 'BASE'  ],

  # ==> SSAX
  ['ssax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['ssax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0101|Rm:4'                            , 'BASE'  ],

  # ==> SSUB16
  ['ssub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['ssub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|0111|Rm:4'                            , 'BASE'  ],

  # ==> SSUB8
  ['ssub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['ssub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0001|Rn:4|Rd:4|1111|1111|Rm:4'                            , 'BASE'  ],

  # ==> STC
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1101|U|000|Rn:4|0101|1110|imm:8'                                     , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1100|U|010|Rn:4|0101|1110|imm:8'                                     , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1101|U|010|Rn:4|0101|1110|imm:8'                                     , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'T32: 1110|1100|1000|Rn:4|0101|1110|option:8'                                   , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, {#{+/-}imm.z*4}]'        , 'A32: cond!=1111|1101|U|000|Rn:4|0101|1110|imm:8'                               , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], #{+/-}imm.z*4'          , 'A32: cond!=1111|1100|U|010|Rn:4|0101|1110|imm:8'                               , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn, #{+/-}imm.z*4]!'         , 'A32: cond!=1111|1101|U|010|Rn:4|0101|1110|imm:8'                               , 'BASE'  ],
  ['stc{%c}{%q}'       , 'p14, c5, [Rn], option'                 , 'A32: cond!=1111|1100|1000|Rn:4|0101|1110|option:8'                             , 'BASE'  ],

  # ==> STL
  ['stl{%c}{%q}'       , 'Rt, [Rn]'                              , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1010|1111'                                  , 'BASE'  ],
  ['stl{%c}{%q}'       , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1000|Rn:4|1111|1100|1001|Rt:4'                            , 'BASE'  ],

  # ==> STLB
  ['stlb{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1000|1111'                                  , 'BASE'  ],
  ['stlb{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1100|Rn:4|1111|1100|1001|Rt:4'                            , 'BASE'  ],

  # ==> STLEX
  ['stlex{%c}{%q}'     , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1110|Rd:4'                                  , 'BASE'  ],
  ['stlex{%c}{%q}'     , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|1110|1001|Rt:4'                            , 'BASE'  ],

  # ==> STLEXB
  ['stlexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1100|Rd:4'                                  , 'BASE'  ],
  ['stlexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|1110|1001|Rt:4'                            , 'BASE'  ],

  # ==> STLEXD
  ['stlexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 1110|1000|1100|Rn:4|Rt:4|Rt2:4|1111|Rd:4'                                 , 'BASE'  ],
  ['stlexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'A32: cond!=1111|0001|1010|Rn:4|Rd:4|1110|1001|Rt:4'                            , 'BASE'  ],

  # ==> STLEXH
  ['stlexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1101|Rd:4'                                  , 'BASE'  ],
  ['stlexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1110|Rn:4|Rd:4|1110|1001|Rt:4'                            , 'BASE'  ],

  # ==> STLH
  ['stlh{%c}{%q}'      , 'Rt, [Rn]'                              , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|1001|1111'                                  , 'BASE'  ],
  ['stlh{%c}{%q}'      , 'Rt, [Rn]'                              , 'A32: cond!=1111|0001|1110|Rn:4|1111|1100|1001|Rt:4'                            , 'BASE'  ],

  # ==> STM, STMIA, STMEA
  ['stm{ia}{%c}{%q}'   , 'Rn!, list'                             , 'T16: 1100|0|Rn:3|list:8'                                                       , 'BASE FORM=PREFERRED'  ],
  ['stmea{%c}{%q}'     , 'Rn!, list'                             , 'T16: 1100|0|Rn:3|list:8'                                                       , 'BASE FORM=ALTERNATIVE'  ],
  ['stm{ia}{%c}.W'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , 'BASE FORM=PREFERRED'  ],
  ['stmea{%c}.W'       , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , 'BASE FORM=ALTERNATIVE'  ],
  ['stm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , 'BASE FORM=PREFERRED'  ],
  ['stmea{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1000|10|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , 'BASE FORM=ALTERNATIVE'  ],
  ['stm{ia}{%c}{%q}'   , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|0|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['stmea{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|10|W|0|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> STM (User registers)
  ['stm{%amode}{%c}{%q}', 'Rn, list'                              , 'A32: cond!=1111|100|P|U|100|Rn:4|list:16'                                      , 'BASE'  ],

  # ==> STMDA, STMED
  ['stmda{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|0|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['stmed{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1000|00|W|0|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> STMDB, STMFD
  ['stmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , 'BASE FORM=PREFERRED'  ],
  ['stmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'T32: 1110|1001|00|W|0|Rn:4|0|list.B:1|0|list.C:13'                             , 'BASE FORM=ALTERNATIVE'  ],
  ['stmdb{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|0|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['stmfd{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|00|W|0|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> STMIB, STMFA
  ['stmib{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|0|Rn:4|list:16'                                      , 'BASE FORM=PREFERRED'  ],
  ['stmfa{%c}{%q}'     , 'Rn{!}, list'                           , 'A32: cond!=1111|1001|10|W|0|Rn:4|list:16'                                      , 'BASE FORM=ALTERNATIVE'  ],

  # ==> STR (immediate)
  ['str{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z*4}]'               , 'T16: 0110|0|imm:5|Rn:3|Rt:3'                                                   , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [SP, {#{+}imm.z*4}]'               , 'T16: 1001|0|Rt:3|imm:8'                                                        , 'BASE'  ],
  ['str{%c}.W'         , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1100|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1100|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|1100|imm:8'                                  , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|000|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|000|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|010|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],

  # ==> STR (register)
  ['str{%c}{%q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|000|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['str{%c}.W'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|000|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|000|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['str{%c}{%q}'       , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|010|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> STRB (immediate)
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T16: 0111|0|imm:5|Rn:3|Rt:3'                                                   , 'BASE'  ],
  ['strb{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1000|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1000|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|1100|imm:8'                                  , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0101|U|100|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0100|U|100|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0101|U|110|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],

  # ==> STRB (register)
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|010|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['strb{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]'  , 'A32: cond!=1111|0111|U|100|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|100|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],
  ['strb{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm, {shift {#amount}}]!' , 'A32: cond!=1111|0111|U|110|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> STRBT
  ['strbt{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0000|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['strbt{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|110|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['strbt{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|110|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> STRD (immediate)
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z*4}]'        , 'T32: 1110|1001|U|100|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z*4'          , 'T32: 1110|1000|U|110|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z*4]!'         , 'T32: 1110|1001|U|110|Rn!=1111|Rt:4|Rt2:4|imm:8'                                , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {#{+/-}imm.z}]'          , 'A32: cond!=1111|0001|U|100|Rn:4|Rt:4|imm:4|1111|imm:4'                         , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], #{+/-}imm.z'            , 'A32: cond!=1111|0000|U|100|Rn:4|Rt:4|imm:4|1111|imm:4'                         , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, #{+/-}imm.z]!'           , 'A32: cond!=1111|0001|U|110|Rn:4|Rt:4|imm:4|1111|imm:4'                         , 'BASE'  ],

  # ==> STRD (register)
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]'                , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn], {+/-}Rm'                , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],
  ['strd{%c}{%q}'      , 'Rt, Rt2, [Rn, {+/-}Rm]!'               , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1111|Rm:4'                           , 'BASE'  ],

  # ==> STREX
  ['strex{%c}{%q}'     , 'Rd, Rt, [Rn, {#imm.z*4}]'              , 'T32: 1110|1000|0100|Rn:4|Rt:4|Rd:4|imm:8'                                      , 'BASE'  ],
  ['strex{%c}{%q}'     , 'Rd, Rt, [Rn, {{#}0}]'                  , 'A32: cond!=1111|0001|1000|Rn:4|Rd:4|1111|1001|Rt:4'                            , 'BASE'  ],

  # ==> STREXB
  ['strexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|0100|Rd:4'                                  , 'BASE'  ],
  ['strexb{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1100|Rn:4|Rd:4|1111|1001|Rt:4'                            , 'BASE'  ],

  # ==> STREXD
  ['strexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 1110|1000|1100|Rn:4|Rt:4|Rt2:4|0111|Rd:4'                                 , 'BASE'  ],
  ['strexd{%c}{%q}'    , 'Rd, Rt, Rt2, [Rn]'                     , 'A32: cond!=1111|0001|1010|Rn:4|Rd:4|1111|1001|Rt:4'                            , 'BASE'  ],

  # ==> STREXH
  ['strexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'T32: 1110|1000|1100|Rn:4|Rt:4|1111|0101|Rd:4'                                  , 'BASE'  ],
  ['strexh{%c}{%q}'    , 'Rd, Rt, [Rn]'                          , 'A32: cond!=1111|0001|1110|Rn:4|Rd:4|1111|1001|Rt:4'                            , 'BASE'  ],

  # ==> STRH (immediate)
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z*2}]'               , 'T16: 1000|0|imm:5|Rn:3|Rt:3'                                                   , 'BASE'  ],
  ['strh{%c}.W'        , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1010|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|1010|Rn!=1111|Rt:4|imm:12'                                      , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#-imm.z}]'                   , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|1100|imm:8'                                  , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|10|U|1|imm:8'                                , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|11|U|1|imm:8'                                , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {#{+/-}imm.z}]'               , 'A32: cond!=1111|0001|U|100|Rn:4|Rt:4|imm:4|1011|imm:4'                         , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], #{+/-}imm.z'                 , 'A32: cond!=1111|0000|U|100|Rn:4|Rt:4|imm:4|1011|imm:4'                         , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, #{+/-}imm.z]!'                , 'A32: cond!=1111|0001|U|110|Rn:4|Rt:4|imm:4|1011|imm:4'                         , 'BASE'  ],

  # ==> STRH (register)
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|001|Rm:3|Rn:3|Rt:3'                                                  , 'BASE'  ],
  ['strh{%c}.W'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|0000|00|imm2:2|Rm:4'                         , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+}Rm, {LSL #imm}]'           , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|0000|00|imm:2|Rm:4'                          , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: cond!=1111|0001|U|000|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|000|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],
  ['strh{%c}{%q}'      , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: cond!=1111|0001|U|010|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],

  # ==> STRHT
  ['strht{%c}{%q}'     , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0010|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['strht{%c}{%q}'     , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0000|U|110|Rn:4|Rt:4|imm:4|1011|imm:4'                         , 'BASE'  ],
  ['strht{%c}{%q}'     , 'Rt, [Rn], {+/-}Rm'                     , 'A32: cond!=1111|0000|U|010|Rn:4|Rt:4|0000|1011|Rm:4'                           , 'BASE'  ],

  # ==> STRT
  ['strt{%c}{%q}'      , 'Rt, [Rn, {#{+}imm.z}]'                 , 'T32: 1111|1000|0100|Rn!=1111|Rt:4|1110|imm:8'                                  , 'BASE'  ],
  ['strt{%c}{%q}'      , 'Rt, [Rn], {#{+/-}imm.z}'               , 'A32: cond!=1111|0100|U|010|Rn:4|Rt:4|imm:12'                                   , 'BASE'  ],
  ['strt{%c}{%q}'      , 'Rt, [Rn], {+/-}Rm, {shift {#amount}}'  , 'A32: cond!=1111|0110|U|010|Rn:4|Rt:4|amount:5|shift:2|0|Rm:4'                  , 'BASE'  ],

  # ==> SUB (immediate, from PC)
  ['sub{%c}{%q}'       , 'Rd, PC, #imm.z'                        , 'T32: 1111|0|imm:1|1010|1011|110|imm:3|Rd:4|imm:8'                              , 'BASE ALIAS_OF=adr PREFERRED_IF=imm==000000000000'  ],
  ['sub{%c}{%q}'       , 'Rd, PC, #cnst.x'                       , 'A32: cond!=1111|0010|0100|1111|Rd:4|cnst:12'                                   , 'BASE ALIAS_OF=adr PREFERRED_IF=cnst==000000000000'  ],

  # ==> SUB, SUBS (immediate)
  ['sub%c{%q}'         , 'Rd, Rn, #imm.z'                        , 'T16: 0001|111|imm:3|Rn:3|Rd:3'                                                 , 'BASE IT=IN'  ],
  ['subs{%q}'          , 'Rd, Rn, #imm.z'                        , 'T16: 0001|111|imm:3|Rn:3|Rd:3'                                                 , 'BASE IT=OUT'  ],
  ['sub%c{%q}'         , 'Rdn, #imm.z'                           , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'BASE IT=IN'  ],
  ['sub%c{%q}'         , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'BASE IT=IN'  ],
  ['subs{%q}'          , 'Rdn, #imm.z'                           , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'BASE IT=OUT'  ],
  ['subs{%q}'          , '{Rdn}, Rdn, #imm.z'                    , 'T16: 0011|1|Rdn:3|imm:8'                                                       , 'BASE IT=OUT'  ],
  ['sub%c.W'           , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|10|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , 'BASE IT=IN'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|10|Rn!=1101|0|cnst:3|Rd:4|cnst:8'                      , 'BASE'  ],
  ['subs.W'            , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|11|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , 'BASE IT=OUT'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|11|Rn!=1101|0|cnst:3|Rd!=1111|cnst:8'                  , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1010|10|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , 'BASE'  ],
  ['subw{%c}{%q}'      , '{Rd}, Rn, #imm.z'                      , 'T32: 1111|0|imm:1|1010|10|Rn!=11x1|0|imm:3|Rd:4|imm:8'                         , 'BASE'  ],
  ['subs{%c}{%q}'      , 'PC, LR, #imm.z'                        , 'T32: 1111|0011|1101|1110|1000|1111|imm!=00000000'                              , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0100|Rn!=11x1|Rd:4|cnst:12'                               , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, #cnst.x'                     , 'A32: cond!=1111|0010|0101|Rn!=1101|Rd:4|cnst:12'                               , 'BASE'  ],

  # ==> SUB, SUBS (register)
  ['sub%c{%q}'         , 'Rd, Rn, Rm'                            , 'T16: 0001|101|Rm:3|Rn:3|Rd:3'                                                  , 'BASE IT=IN'  ],
  ['subs{%q}'          , '{Rd}, Rn, Rm'                          , 'T16: 0001|101|Rm:3|Rn:3|Rd:3'                                                  , 'BASE IT=OUT'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1010|Rn!=1101|0000|Rd:4|0011|Rm:4'                              , 'BASE'  ],
  ['sub%c.W'           , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|1010|Rn!=1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'          , 'BASE IT=IN'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1010|Rn!=1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110|1011|1011|Rn!=1101|0000|Rd!=1111|0011|Rm:4'                          , 'BASE'  ],
  ['subs.W'            , '{Rd}, Rn, Rm'                          , 'T32: 1110|1011|1011|Rn!=1101|0|imm3!=000|Rd!=1111|imm2!=00|type!=11|Rm:4'      , 'BASE IT=OUT'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'T32: 1110|1011|1011|Rn!=1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4' , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0100|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0100|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, RRX'                     , 'A32: cond!=1111|0000|0101|Rn!=1101|Rd:4|0000|0110|Rm:4'                        , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0101|Rn!=1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'        , 'BASE'  ],

  # ==> SUB, SUBS (register-shifted register)
  ['subs{%c}{%q}'      , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0101|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, Rn, Rm, type Rs'                 , 'A32: cond!=1111|0000|0100|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> SUB, SUBS (SP minus immediate)
  ['sub{%c}{%q}'       , '{SP}, SP, #imm.z*4'                    , 'T16: 1011|0000|1|imm:7'                                                        , 'BASE'  ],
  ['sub{%c}.W'         , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|1011|010|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|1011|010|cnst:3|Rd:4|cnst:8'                           , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'T32: 1111|0|cnst:1|0110|1111|010|cnst:3|Rd!=1111|cnst:8'                       , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1010|1011|010|imm:3|Rd:4|imm:8'                              , 'BASE'  ],
  ['subw{%c}{%q}'      , '{Rd}, SP, #imm.z'                      , 'T32: 1111|0|imm:1|1010|1011|010|imm:3|Rd:4|imm:8'                              , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|0100|1101|Rd:4|cnst:12'                                   , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, #cnst.x'                     , 'A32: cond!=1111|0010|0101|1101|Rd:4|cnst:12'                                   , 'BASE'  ],

  # ==> SUB, SUBS (SP minus register)
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|1010|1101|0000|Rd:4|0011|Rm:4'                                  , 'BASE'  ],
  ['sub{%c}.W'         , '{Rd}, SP, Rm'                          , 'T32: 1110|1011|1010|1101|0|imm3!=000|Rd:4|imm2!=00|type!=11|Rm:4'              , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|1010|1101|0|amount!=000|Rd:4|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110|1011|1011|1101|0000|Rd!=1111|0011|Rm:4'                              , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'T32: 1110|1011|1011|1101|0|amount!=000|Rd!=1111|amount!=00|shift!=11|Rm:4'     , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|0100|1101|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['sub{%c}{%q}'       , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0100|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm , RRX'                    , 'A32: cond!=1111|0000|0101|1101|Rd:4|0000|0110|Rm:4'                            , 'BASE'  ],
  ['subs{%c}{%q}'      , '{Rd}, SP, Rm, {shift #amount}'         , 'A32: cond!=1111|0000|0101|1101|Rd:4|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> SVC
  ['svc{%c}{%q}'       , '{#}imm.z'                              , 'T16: 1101|1111|imm:8'                                                          , 'BASE'  ],
  ['svc{%c}{%q}'       , '{#}imm.z'                              , 'A32: cond!=1111|1111|imm:24'                                                   , 'BASE'  ],

  # ==> SXTAB
  ['sxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0100|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , 'BASE'  ],
  ['sxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1010|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , 'BASE'  ],

  # ==> SXTAB16
  ['sxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0010|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , 'BASE'  ],
  ['sxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1000|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , 'BASE'  ],

  # ==> SXTAH
  ['sxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0000|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , 'BASE'  ],
  ['sxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1011|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , 'BASE'  ],

  # ==> SXTB
  ['sxtb{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|01|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['sxtb{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0100|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , 'BASE'  ],
  ['sxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0100|1111|1111|Rd:4|10|amount:2|Rm:4'                           , 'BASE'  ],
  ['sxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1010|1111|Rd:4|amount:2|0001|11|Rm:4'                     , 'BASE'  ],

  # ==> SXTB16
  ['sxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0010|1111|1111|Rd:4|10|amount:2|Rm:4'                           , 'BASE'  ],
  ['sxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1000|1111|Rd:4|amount:2|0001|11|Rm:4'                     , 'BASE'  ],

  # ==> SXTH
  ['sxth{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|00|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['sxth{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0000|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , 'BASE'  ],
  ['sxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0000|1111|1111|Rd:4|10|amount:2|Rm:4'                           , 'BASE'  ],
  ['sxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1011|1111|Rd:4|amount:2|0001|11|Rm:4'                     , 'BASE'  ],

  # ==> TBB, TBH
  ['tbb{%c}{%q}'       , '[Rn, Rm]'                              , 'T32: 1110|1000|1101|Rn:4|1111|0000|0000|Rm:4'                                  , 'BASE IT=IN|LAST|OUT'  ],
  ['tbh{%c}{%q}'       , '[Rn, Rm, LSL #1]'                      , 'T32: 1110|1000|1101|Rn:4|1111|0000|0001|Rm:4'                                  , 'BASE IT=IN|LAST|OUT'  ],

  # ==> TEQ (immediate)
  ['teq{%c}{%q}'       , 'Rn, #cnst.c'                           , 'T32: 1111|0|cnst:1|0010|01|Rn:4|0|cnst:3|1111|cnst:8'                          , 'BASE'  ],
  ['teq{%c}{%q}'       , 'Rn, #cnst.c'                           , 'A32: cond!=1111|0011|0011|Rn:4|0000|cnst:12'                                   , 'BASE'  ],

  # ==> TEQ (register)
  ['teq{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1010|1001|Rn:4|0000|1111|0011|Rm:4'                                  , 'BASE'  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'T32: 1110|1010|1001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0011|Rn:4|0000|0000|0110|Rm:4'                            , 'BASE'  ],
  ['teq{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0011|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> TEQ (register-shifted register)
  ['teq{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0011|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> TST (immediate)
  ['tst{%c}{%q}'       , 'Rn, #cnst.c'                           , 'T32: 1111|0|cnst:1|0000|01|Rn:4|0|cnst:3|1111|cnst:8'                          , 'BASE'  ],
  ['tst{%c}{%q}'       , 'Rn, #cnst.c'                           , 'A32: cond!=1111|0011|0001|Rn:4|0000|cnst:12'                                   , 'BASE'  ],

  # ==> TST (register)
  ['tst{%c}{%q}'       , 'Rn, Rm'                                , 'T16: 0100|0010|00|Rm:3|Rn:3'                                                   , 'BASE'  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'T32: 1110|1010|0001|Rn:4|0000|1111|0011|Rm:4'                                  , 'BASE'  ],
  ['tst{%c}.W'         , 'Rn, Rm'                                , 'T32: 1110|1010|0001|Rn:4|0|imm3!=000|1111|imm2!=00|type!=11|Rm:4'              , 'BASE'  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'T32: 1110|1010|0001|Rn:4|0|amount!=000|1111|amount!=00|shift!=11|Rm:4'         , 'BASE'  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, RRX'                           , 'A32: cond!=1111|0001|0001|Rn:4|0000|0000|0110|Rm:4'                            , 'BASE'  ],
  ['tst{%c}{%q}'       , 'Rn, Rm, {shift #amount}'               , 'A32: cond!=1111|0001|0001|Rn:4|0000|amount!=00000|shift!=11|0|Rm:4'            , 'BASE'  ],

  # ==> TST (register-shifted register)
  ['tst{%c}{%q}'       , 'Rn, Rm, type Rs'                       , 'A32: cond!=1111|0001|0001|Rn:4|0000|Rs:4|0|type:2|1|Rm:4'                      , 'BASE'  ],

  # ==> UADD16
  ['uadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0100|Rm:4'                                  , 'BASE'  ],
  ['uadd16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> UADD8
  ['uadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0100|Rm:4'                                  , 'BASE'  ],
  ['uadd8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|1001|Rm:4'                            , 'BASE'  ],

  # ==> UASX
  ['uasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0100|Rm:4'                                  , 'BASE'  ],
  ['uasx{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> UBFX
  ['ubfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'T32: 1111|0011|1100|Rn:4|0|lsb:3|Rd:4|lsb:2|0|width:5'                         , 'BASE'  ],
  ['ubfx{%c}{%q}'      , 'Rd, Rn, #lsb, #width+1'                , 'A32: cond!=1111|0111|111|width:5|Rd:4|lsb:5|101|Rn:4'                          , 'BASE'  ],

  # ==> UDF
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'T16: 1101|1110|imm:8'                                                          , 'BASE'  ],
  ['udf{%c}.W'         , '{#}imm.z'                              , 'T32: 1111|0111|1111|imm:4|1010|imm:12'                                         , 'BASE'  ],
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'T32: 1111|0111|1111|imm:4|1010|imm:12'                                         , 'BASE'  ],
  ['udf{%c}{%q}'       , '{#}imm.z'                              , 'A32: 1110|0111|1111|imm:12|1111|imm:4'                                         , 'BASE'  ],

  # ==> UDIV
  ['udiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|1011|Rn:4|1111|Rd:4|1111|Rm:4'                                  , 'BASE'  ],
  ['udiv{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|0011|Rd:4|1111|Rm:4|0001|Rn:4'                            , 'BASE'  ],

  # ==> UHADD16
  ['uhadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0110|Rm:4'                                  , 'BASE'  ],
  ['uhadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> UHADD8
  ['uhadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0110|Rm:4'                                  , 'BASE'  ],
  ['uhadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|1001|Rm:4'                            , 'BASE'  ],

  # ==> UHASX
  ['uhasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0110|Rm:4'                                  , 'BASE'  ],
  ['uhasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> UHSAX
  ['uhsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0110|Rm:4'                                  , 'BASE'  ],
  ['uhsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0101|Rm:4'                            , 'BASE'  ],

  # ==> UHSUB16
  ['uhsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0110|Rm:4'                                  , 'BASE'  ],
  ['uhsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|0111|Rm:4'                            , 'BASE'  ],

  # ==> UHSUB8
  ['uhsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0110|Rm:4'                                  , 'BASE'  ],
  ['uhsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0111|Rn:4|Rd:4|1111|1111|Rm:4'                            , 'BASE'  ],

  # ==> UMAAL
  ['umaal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1110|Rn:4|RdLo:4|RdHi:4|0110|Rm:4'                              , 'BASE'  ],
  ['umaal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|0100|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],

  # ==> UMLAL, UMLALS
  ['umlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1110|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , 'BASE'  ],
  ['umlals{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1011|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],
  ['umlal{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1010|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],

  # ==> UMULL, UMULLS
  ['umull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 1111|1011|1010|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                              , 'BASE'  ],
  ['umulls{%c}{%q}'    , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1001|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],
  ['umull{%c}{%q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: cond!=1111|0000|1000|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                        , 'BASE'  ],

  # ==> UQADD16
  ['uqadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1001|Rn:4|1111|Rd:4|0101|Rm:4'                                  , 'BASE'  ],
  ['uqadd16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0001|Rm:4'                            , 'BASE'  ],

  # ==> UQADD8
  ['uqadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1000|Rn:4|1111|Rd:4|0101|Rm:4'                                  , 'BASE'  ],
  ['uqadd8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|1001|Rm:4'                            , 'BASE'  ],

  # ==> UQASX
  ['uqasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1010|Rn:4|1111|Rd:4|0101|Rm:4'                                  , 'BASE'  ],
  ['uqasx{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0011|Rm:4'                            , 'BASE'  ],

  # ==> UQSAX
  ['uqsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0101|Rm:4'                                  , 'BASE'  ],
  ['uqsax{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0101|Rm:4'                            , 'BASE'  ],

  # ==> UQSUB16
  ['uqsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0101|Rm:4'                                  , 'BASE'  ],
  ['uqsub16{%c}{%q}'   , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|0111|Rm:4'                            , 'BASE'  ],

  # ==> UQSUB8
  ['uqsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0101|Rm:4'                                  , 'BASE'  ],
  ['uqsub8{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0110|Rn:4|Rd:4|1111|1111|Rm:4'                            , 'BASE'  ],

  # ==> USAD8
  ['usad8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1011|0111|Rn:4|1111|Rd:4|0000|Rm:4'                                  , 'BASE'  ],
  ['usad8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0111|1000|Rd:4|1111|Rm:4|0001|Rn:4'                            , 'BASE'  ],

  # ==> USADA8
  ['usada8{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'T32: 1111|1011|0111|Rn:4|Ra!=1111|Rd:4|0000|Rm:4'                              , 'BASE'  ],
  ['usada8{%c}{%q}'    , 'Rd, Rn, Rm, Ra'                        , 'A32: cond!=1111|0111|1000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                        , 'BASE'  ],

  # ==> USAT
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, ASR #amount'             , 'T32: 1111|0011|1010|Rn:4|0|amount!=000|Rd:4|amount!=00|0|sat:5'                , 'BASE'  ],
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, {LSL #amount}'           , 'T32: 1111|0011|1000|Rn:4|0|amount:3|Rd:4|amount:2|0|sat:5'                     , 'BASE'  ],
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, ASR #amount'             , 'A32: cond!=1111|0110|111|sat:5|Rd:4|amount:5|101|Rn:4'                         , 'BASE'  ],
  ['usat{%c}{%q}'      , 'Rd, #sat, Rn, {LSL #amount}'           , 'A32: cond!=1111|0110|111|sat:5|Rd:4|amount:5|001|Rn:4'                         , 'BASE'  ],

  # ==> USAT16
  ['usat16{%c}{%q}'    , 'Rd, #sat, Rn'                          , 'T32: 1111|0011|1010|Rn:4|0000|Rd:4|0000|sat:4'                                 , 'BASE'  ],
  ['usat16{%c}{%q}'    , 'Rd, #sat, Rn'                          , 'A32: cond!=1111|0110|1110|sat:4|Rd:4|1111|0011|Rn:4'                           , 'BASE'  ],

  # ==> USAX
  ['usax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1110|Rn:4|1111|Rd:4|0100|Rm:4'                                  , 'BASE'  ],
  ['usax{%c}{%q}'      , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0101|Rm:4'                            , 'BASE'  ],

  # ==> USUB16
  ['usub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1101|Rn:4|1111|Rd:4|0100|Rm:4'                                  , 'BASE'  ],
  ['usub16{%c}{%q}'    , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|0111|Rm:4'                            , 'BASE'  ],

  # ==> USUB8
  ['usub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1111|1010|1100|Rn:4|1111|Rd:4|0100|Rm:4'                                  , 'BASE'  ],
  ['usub8{%c}{%q}'     , '{Rd}, Rn, Rm'                          , 'A32: cond!=1111|0110|0101|Rn:4|Rd:4|1111|1111|Rm:4'                            , 'BASE'  ],

  # ==> UXTAB
  ['uxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0101|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , 'BASE'  ],
  ['uxtab{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1110|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , 'BASE'  ],

  # ==> UXTAB16
  ['uxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0011|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , 'BASE'  ],
  ['uxtab16{%c}{%q}'   , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1100|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , 'BASE'  ],

  # ==> UXTAH
  ['uxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'T32: 1111|1010|0001|Rn!=1111|1111|Rd:4|10|amount:2|Rm:4'                       , 'BASE'  ],
  ['uxtah{%c}{%q}'     , '{Rd}, Rn, Rm, {ROR #amount*8}'         , 'A32: cond!=1111|0110|1111|Rn!=1111|Rd:4|amount:2|0001|11|Rm:4'                 , 'BASE'  ],

  # ==> UXTB
  ['uxtb{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|11|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['uxtb{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0101|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , 'BASE'  ],
  ['uxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0101|1111|1111|Rd:4|10|amount:2|Rm:4'                           , 'BASE'  ],
  ['uxtb{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1110|1111|Rd:4|amount:2|0001|11|Rm:4'                     , 'BASE'  ],

  # ==> UXTB16
  ['uxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0011|1111|1111|Rd:4|10|amount:2|Rm:4'                           , 'BASE'  ],
  ['uxtb16{%c}{%q}'    , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1100|1111|Rd:4|amount:2|0001|11|Rm:4'                     , 'BASE'  ],

  # ==> UXTH
  ['uxth{%c}{%q}'      , '{Rd}, Rm'                              , 'T16: 1011|0010|10|Rm:3|Rd:3'                                                   , 'BASE'  ],
  ['uxth{%c}.W'        , '{Rd}, Rm'                              , 'T32: 1111|1010|0001|1111|1111|Rd:4|10|rotate:2|Rm:4'                           , 'BASE'  ],
  ['uxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'T32: 1111|1010|0001|1111|1111|Rd:4|10|amount:2|Rm:4'                           , 'BASE'  ],
  ['uxth{%c}{%q}'      , '{Rd}, Rm, {ROR #amount*8}'             , 'A32: cond!=1111|0110|1111|1111|Rd:4|amount:2|0001|11|Rm:4'                     , 'BASE'  ],

  # ==> WFE
  ['wfe{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0010|0000'                                                      , 'BASE'  ],
  ['wfe{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0010'                                  , 'BASE'  ],
  ['wfe{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0010'                            , 'BASE'  ],

  # ==> WFI
  ['wfi{%c}{%q}'       , ''                                      , 'T16: 1011|1111|0011|0000'                                                      , 'BASE'  ],
  ['wfi{%c}.W'         , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0011'                                  , 'BASE'  ],
  ['wfi{%c}{%q}'       , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0011'                            , 'BASE'  ],

  # ==> YIELD
  ['yield{%c}{%q}'     , ''                                      , 'T16: 1011|1111|0001|0000'                                                      , 'BASE'  ],
  ['yield{%c}.W'       , ''                                      , 'T32: 1111|0011|1010|1111|1000|0000|0000|0001'                                  , 'BASE'  ],
  ['yield{%c}{%q}'     , ''                                      , 'A32: cond!=1111|0011|0010|0000|1111|0000|0000|0001'                            , 'BASE'  ],


  # ===>                     AArch64.Base instructions                     <===

  # ==> ADC
  ['adc'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['adc'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> ADCS
  ['adcs'              , 'Wd, Wn, Wm'                            , 'A64: 0011|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['adcs'              , 'Xd, Xn, Xm'                            , 'A64: 1011|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> ADD (extended register)
  ['add'               , '$Wd, $Wn, Wm, {extend {#amount}}'      , 'A64: 0000|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , 'ARMv8+ BASE'  ],
  ['add'               , '$Xd, $Xn, R.m, {extend {#amount}}'     , 'A64: 1000|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , 'ARMv8+ BASE'  ],

  # ==> ADD (immediate)
  ['add'               , '$Wd, $Wn, #imm.z, {shift {#amount}}'   , 'A64: 0001|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , 'ARMv8+ BASE'  ],
  ['add'               , '$Xd, $Xn, #imm.z, {shift {#amount}}'   , 'A64: 1001|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , 'ARMv8+ BASE'  ],

  # ==> ADD (shifted register)
  ['add'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0000|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['add'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1000|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> ADDS (extended register)
  ['adds'              , 'Wd, $Wn, Wm, {extend {#amount}}'       , 'A64: 0010|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , 'ARMv8+ BASE'  ],
  ['adds'              , 'Xd, $Xn, R.m, {extend {#amount}}'      , 'A64: 1010|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , 'ARMv8+ BASE'  ],

  # ==> ADDS (immediate)
  ['adds'              , 'Wd, $Wn, #imm.z, {shift {#amount}}'    , 'A64: 0011|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , 'ARMv8+ BASE'  ],
  ['adds'              , 'Xd, $Xn, #imm.z, {shift {#amount}}'    , 'A64: 1011|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , 'ARMv8+ BASE'  ],

  # ==> ADDS (shifted register)
  ['adds'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0010|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['adds'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1010|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> ADR
  ['adr'               , 'Xd, rel.s'                             , 'A64: 0|rel.B:2|1000|0|rel.A:19|Xd:5'                                           , 'ARMv8+ BASE'  ],

  # ==> ADRP
  ['adrp'              , 'Xd, rel.s'                             , 'A64: 1|rel.B:2|1000|0|rel.A:19|Xd:5'                                           , 'ARMv8+ BASE'  ],

  # ==> AND (immediate)
  ['and'               , '$Wd, Wn, #bimm'                        , 'A64: 0001|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , 'ARMv8+ BASE'  ],
  ['and'               , '$Xd, Xn, #bimm'                        , 'A64: 1001|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , 'ARMv8+ BASE'  ],

  # ==> AND (shifted register)
  ['and'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0000|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['and'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1000|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> ANDS (immediate)
  ['ands'              , 'Wd, Wn, #bimm'                         , 'A64: 0111|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , 'ARMv8+ BASE'  ],
  ['ands'              , 'Xd, Xn, #bimm'                         , 'A64: 1111|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , 'ARMv8+ BASE'  ],

  # ==> ANDS (shifted register)
  ['ands'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0110|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['ands'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1110|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> ASR (register)
  ['asr'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|10|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=asrv PREFERRED_IF=ALWAYS'  ],
  ['asr'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|10|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=asrv PREFERRED_IF=ALWAYS'  ],

  # ==> ASR (immediate)
  ['asr'               , 'Wd, Wn, #shift'                        , 'A64: 0001|0011|00|shift:6|0111|11|Wn:5|Wd:5'                                   , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],
  ['asr'               , 'Xd, Xn, #shift'                        , 'A64: 1001|0011|01|shift:6|1111|11|Xn:5|Xd:5'                                   , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],

  # ==> ASRV
  ['asrv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|10|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['asrv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|10|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> AT
  ['at'                , 'at_op, Xt'                             , 'A64: 1101|0101|0000|1|at_op:3|0111|at_op=100x|at_op:3|Xt:5'                    , 'ARMv8+ BASE ALIAS_OF=sys PREFERRED_IF=SysOp(at_op,0111,at_op,at_op)==Sys_AT'  ],

  # ==> B.cond
  ['b.%c'              , 'rel.s*4'                               , 'A64: 0101|0100|rel:19|0|cond:4'                                                , 'ARMv8+ BASE'  ],

  # ==> B
  ['b'                 , 'rel.s*4'                               , 'A64: 0001|01|rel:26'                                                           , 'ARMv8+ BASE'  ],

  # ==> BFI
  ['bfi'               , 'Wd, Wn, #lsb, #width'                  , 'A64: 0011|0011|00|immr:6|imms:6|Wn!=11111|Wd:5'                                , 'ARMv8+ BASE ALIAS_OF=bfm PREFERRED_IF=UInt(imms)<UInt(immr)'  ],
  ['bfi'               , 'Xd, Xn, #lsb, #width'                  , 'A64: 1011|0011|01|immr:6|imms:6|Xn!=11111|Xd:5'                                , 'ARMv8+ BASE ALIAS_OF=bfm PREFERRED_IF=UInt(imms)<UInt(immr)'  ],

  # ==> BFM
  ['bfm'               , 'Wd, Wn, #immr, #imms'                  , 'A64: 0011|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['bfm'               , 'Xd, Xn, #immr, #imms'                  , 'A64: 1011|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> BFXIL
  ['bfxil'             , 'Wd, Wn, #lsb, #width'                  , 'A64: 0011|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=bfm PREFERRED_IF=UInt(imms)>=UInt(immr)'  ],
  ['bfxil'             , 'Xd, Xn, #lsb, #width'                  , 'A64: 1011|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=bfm PREFERRED_IF=UInt(imms)>=UInt(immr)'  ],

  # ==> BIC (shifted register)
  ['bic'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0000|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['bic'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1000|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> BICS (shifted register)
  ['bics'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0110|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['bics'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1110|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> BL
  ['bl'                , 'rel.s*4'                               , 'A64: 1001|01|rel:26'                                                           , 'ARMv8+ BASE'  ],

  # ==> BLR
  ['blr'               , 'Xn'                                    , 'A64: 1101|0110|0011|1111|0000|00|Xn:5|0000|0'                                  , 'ARMv8+ BASE'  ],

  # ==> BR
  ['br'                , 'Xn'                                    , 'A64: 1101|0110|0001|1111|0000|00|Xn:5|0000|0'                                  , 'ARMv8+ BASE'  ],

  # ==> BRK
  ['brk'               , '#imm'                                  , 'A64: 1101|0100|001|imm:16|0000|0'                                              , 'ARMv8+ BASE'  ],

  # ==> CBNZ
  ['cbnz'              , 'Wt, rel.s*4'                           , 'A64: 0011|0101|rel:19|Wt:5'                                                    , 'ARMv8+ BASE'  ],
  ['cbnz'              , 'Xt, rel.s*4'                           , 'A64: 1011|0101|rel:19|Xt:5'                                                    , 'ARMv8+ BASE'  ],

  # ==> CBZ
  ['cbz'               , 'Wt, rel.s*4'                           , 'A64: 0011|0100|rel:19|Wt:5'                                                    , 'ARMv8+ BASE'  ],
  ['cbz'               , 'Xt, rel.s*4'                           , 'A64: 1011|0100|rel:19|Xt:5'                                                    , 'ARMv8+ BASE'  ],

  # ==> CCMN (immediate)
  ['ccmn'              , 'Wn, #imm.z, #nzcv, cond'               , 'A64: 0011|1010|010|imm:5|cond:4|10|Wn:5|0|nzcv:4'                              , 'ARMv8+ BASE'  ],
  ['ccmn'              , 'Xn, #imm.z, #nzcv, cond'               , 'A64: 1011|1010|010|imm:5|cond:4|10|Xn:5|0|nzcv:4'                              , 'ARMv8+ BASE'  ],

  # ==> CCMN (register)
  ['ccmn'              , 'Wn, Wm, #nzcv, cond'                   , 'A64: 0011|1010|010|Wm:5|cond:4|00|Wn:5|0|nzcv:4'                               , 'ARMv8+ BASE'  ],
  ['ccmn'              , 'Xn, Xm, #nzcv, cond'                   , 'A64: 1011|1010|010|Xm:5|cond:4|00|Xn:5|0|nzcv:4'                               , 'ARMv8+ BASE'  ],

  # ==> CCMP (immediate)
  ['ccmp'              , 'Wn, #imm.z, #nzcv, cond'               , 'A64: 0111|1010|010|imm:5|cond:4|10|Wn:5|0|nzcv:4'                              , 'ARMv8+ BASE'  ],
  ['ccmp'              , 'Xn, #imm.z, #nzcv, cond'               , 'A64: 1111|1010|010|imm:5|cond:4|10|Xn:5|0|nzcv:4'                              , 'ARMv8+ BASE'  ],

  # ==> CCMP (register)
  ['ccmp'              , 'Wn, Wm, #nzcv, cond'                   , 'A64: 0111|1010|010|Wm:5|cond:4|00|Wn:5|0|nzcv:4'                               , 'ARMv8+ BASE'  ],
  ['ccmp'              , 'Xn, Xm, #nzcv, cond'                   , 'A64: 1111|1010|010|Xm:5|cond:4|00|Xn:5|0|nzcv:4'                               , 'ARMv8+ BASE'  ],

  # ==> CINC
  ['cinc'              , 'Wd, Wn, cond'                          , 'A64: 0001|1010|100|Rm!=11111|cond!=111x|01|Wn!=11111|Wd:5'                     , 'ARMv8+ BASE ALIAS_OF=csinc PREFERRED_IF=Wn==Rm'  ],
  ['cinc'              , 'Xd, Xn, cond'                          , 'A64: 1001|1010|100|Rm!=11111|cond!=111x|01|Xn!=11111|Xd:5'                     , 'ARMv8+ BASE ALIAS_OF=csinc PREFERRED_IF=Xn==Rm'  ],

  # ==> CINV
  ['cinv'              , 'Wd, Wn, cond'                          , 'A64: 0101|1010|100|Rm!=11111|cond!=111x|00|Wn!=11111|Wd:5'                     , 'ARMv8+ BASE ALIAS_OF=csinv PREFERRED_IF=Wn==Rm'  ],
  ['cinv'              , 'Xd, Xn, cond'                          , 'A64: 1101|1010|100|Rm!=11111|cond!=111x|00|Xn!=11111|Xd:5'                     , 'ARMv8+ BASE ALIAS_OF=csinv PREFERRED_IF=Xn==Rm'  ],

  # ==> CLREX
  ['clrex'             , '{#imm}'                                , 'A64: 1101|0101|0000|0011|0011|imm:4|0101|1111'                                 , 'ARMv8+ BASE'  ],

  # ==> CLS
  ['cls'               , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0001|01|Wn:5|Wd:5'                                    , 'ARMv8+ BASE'  ],
  ['cls'               , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0001|01|Xn:5|Xd:5'                                    , 'ARMv8+ BASE'  ],

  # ==> CLZ
  ['clz'               , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0001|00|Wn:5|Wd:5'                                    , 'ARMv8+ BASE'  ],
  ['clz'               , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0001|00|Xn:5|Xd:5'                                    , 'ARMv8+ BASE'  ],

  # ==> CMN (extended register)
  ['cmn'               , '$Wn, Wm, {extend {#amount}}'           , 'A64: 0010|1011|001|Wm:5|extend:3|amount:3|Wn:5|1111|1'                         , 'ARMv8+ BASE ALIAS_OF=adds PREFERRED_IF=ALWAYS'  ],
  ['cmn'               , '$Xn, R.m, {extend {#amount}}'          , 'A64: 1010|1011|001|m:5|R/extend:3|amount:3|Xn:5|1111|1'                        , 'ARMv8+ BASE ALIAS_OF=adds PREFERRED_IF=ALWAYS'  ],

  # ==> CMN (immediate)
  ['cmn'               , '$Wn, #imm.z, {shift {#amount}}'        , 'A64: 0011|0001|shift:2|imm:12|Wn:5|1111|1'                                     , 'ARMv8+ BASE ALIAS_OF=adds PREFERRED_IF=ALWAYS'  ],
  ['cmn'               , '$Xn, #imm.z, {shift {#amount}}'        , 'A64: 1011|0001|shift:2|imm:12|Xn:5|1111|1'                                     , 'ARMv8+ BASE ALIAS_OF=adds PREFERRED_IF=ALWAYS'  ],

  # ==> CMN (shifted register)
  ['cmn'               , 'Wn, Wm, {shift #amount}'               , 'A64: 0010|1011|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                            , 'ARMv8+ BASE ALIAS_OF=adds PREFERRED_IF=ALWAYS'  ],
  ['cmn'               , 'Xn, Xm, {shift #amount}'               , 'A64: 1010|1011|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                            , 'ARMv8+ BASE ALIAS_OF=adds PREFERRED_IF=ALWAYS'  ],

  # ==> CMP (extended register)
  ['cmp'               , '$Wn, Wm, {extend {#amount}}'           , 'A64: 0110|1011|001|Wm:5|extend:3|amount:3|Wn:5|1111|1'                         , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],
  ['cmp'               , '$Xn, R.m, {extend {#amount}}'          , 'A64: 1110|1011|001|m:5|R/extend:3|amount:3|Xn:5|1111|1'                        , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],

  # ==> CMP (immediate)
  ['cmp'               , '$Wn, #imm.z, {shift {#amount}}'        , 'A64: 0111|0001|shift:2|imm:12|Wn:5|1111|1'                                     , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],
  ['cmp'               , '$Xn, #imm.z, {shift {#amount}}'        , 'A64: 1111|0001|shift:2|imm:12|Xn:5|1111|1'                                     , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],

  # ==> CMP (shifted register)
  ['cmp'               , 'Wn, Wm, {shift #amount}'               , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                            , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],
  ['cmp'               , 'Xn, Xm, {shift #amount}'               , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                            , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],

  # ==> CNEG
  ['cneg'              , 'Wd, Wn, cond'                          , 'A64: 0101|1010|100|Rm:5|cond!=111x|01|Wn:5|Wd:5'                               , 'ARMv8+ BASE ALIAS_OF=csneg PREFERRED_IF=Wn==Rm'  ],
  ['cneg'              , 'Xd, Xn, cond'                          , 'A64: 1101|1010|100|Rm:5|cond!=111x|01|Xn:5|Xd:5'                               , 'ARMv8+ BASE ALIAS_OF=csneg PREFERRED_IF=Xn==Rm'  ],

  # ==> CRC32B, CRC32H, CRC32W, CRC32X
  ['crc32b'            , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0100|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['crc32h'            , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0100|01|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['crc32w'            , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0100|10|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['crc32x'            , 'Wd, Wn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0100|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> CRC32CB, CRC32CH, CRC32CW, CRC32CX
  ['crc32cb'           , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0101|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['crc32ch'           , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0101|01|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['crc32cw'           , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0101|10|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['crc32cx'           , 'Wd, Wn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0101|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> CSEL
  ['csel'              , 'Wd, Wn, Wm, cond'                      , 'A64: 0001|1010|100|Wm:5|cond:4|00|Wn:5|Wd:5'                                   , 'ARMv8+ BASE'  ],
  ['csel'              , 'Xd, Xn, Xm, cond'                      , 'A64: 1001|1010|100|Xm:5|cond:4|00|Xn:5|Xd:5'                                   , 'ARMv8+ BASE'  ],

  # ==> CSET
  ['cset'              , 'Wd, cond'                              , 'A64: 0001|1010|1001|1111|cond!=111x|0111|111|Wd:5'                             , 'ARMv8+ BASE ALIAS_OF=csinc PREFERRED_IF=ALWAYS'  ],
  ['cset'              , 'Xd, cond'                              , 'A64: 1001|1010|1001|1111|cond!=111x|0111|111|Xd:5'                             , 'ARMv8+ BASE ALIAS_OF=csinc PREFERRED_IF=ALWAYS'  ],

  # ==> CSETM
  ['csetm'             , 'Wd, cond'                              , 'A64: 0101|1010|1001|1111|cond!=111x|0011|111|Wd:5'                             , 'ARMv8+ BASE ALIAS_OF=csinv PREFERRED_IF=ALWAYS'  ],
  ['csetm'             , 'Xd, cond'                              , 'A64: 1101|1010|1001|1111|cond!=111x|0011|111|Xd:5'                             , 'ARMv8+ BASE ALIAS_OF=csinv PREFERRED_IF=ALWAYS'  ],

  # ==> CSINC
  ['csinc'             , 'Wd, Wn, Wm, cond'                      , 'A64: 0001|1010|100|Wm:5|cond:4|01|Wn:5|Wd:5'                                   , 'ARMv8+ BASE'  ],
  ['csinc'             , 'Xd, Xn, Xm, cond'                      , 'A64: 1001|1010|100|Xm:5|cond:4|01|Xn:5|Xd:5'                                   , 'ARMv8+ BASE'  ],

  # ==> CSINV
  ['csinv'             , 'Wd, Wn, Wm, cond'                      , 'A64: 0101|1010|100|Wm:5|cond:4|00|Wn:5|Wd:5'                                   , 'ARMv8+ BASE'  ],
  ['csinv'             , 'Xd, Xn, Xm, cond'                      , 'A64: 1101|1010|100|Xm:5|cond:4|00|Xn:5|Xd:5'                                   , 'ARMv8+ BASE'  ],

  # ==> CSNEG
  ['csneg'             , 'Wd, Wn, Wm, cond'                      , 'A64: 0101|1010|100|Wm:5|cond:4|01|Wn:5|Wd:5'                                   , 'ARMv8+ BASE'  ],
  ['csneg'             , 'Xd, Xn, Xm, cond'                      , 'A64: 1101|1010|100|Xm:5|cond:4|01|Xn:5|Xd:5'                                   , 'ARMv8+ BASE'  ],

  # ==> DC
  ['dc'                , 'dc_op, Xt'                             , 'A64: 1101|0101|0000|1|dc_op:3|0111|dc_op:4|dc_op:3|Xt:5'                       , 'ARMv8+ BASE ALIAS_OF=sys PREFERRED_IF=SysOp(dc_op,0111,dc_op,dc_op)==Sys_DC'  ],

  # ==> DCPS1
  ['dcps1'             , '{#imm}'                                , 'A64: 1101|0100|101|imm:16|0000|1'                                              , 'ARMv8+ BASE'  ],

  # ==> DCPS2
  ['dcps2'             , '{#imm}'                                , 'A64: 1101|0100|101|imm:16|0001|0'                                              , 'ARMv8+ BASE'  ],

  # ==> DCPS3
  ['dcps3'             , '{#imm}'                                , 'A64: 1101|0100|101|imm:16|0001|1'                                              , 'ARMv8+ BASE'  ],

  # ==> DMB
  ['dmb'               , 'option|#imm'                           , 'A64: 1101|0101|0000|0011|0011|imm:4|1011|1111'                                 , 'ARMv8+ BASE'  ],

  # ==> DRPS
  ['drps'              , ''                                      , 'A64: 1101|0110|1011|1111|0000|0011|1110|0000'                                  , 'ARMv8+ BASE'  ],

  # ==> DSB
  ['dsb'               , 'option|#imm'                           , 'A64: 1101|0101|0000|0011|0011|imm:4|1001|1111'                                 , 'ARMv8+ BASE'  ],

  # ==> EON (shifted register)
  ['eon'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0100|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['eon'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1100|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> EOR (immediate)
  ['eor'               , '$Wd, Wn, #bimm'                        , 'A64: 0101|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , 'ARMv8+ BASE'  ],
  ['eor'               , '$Xd, Xn, #bimm'                        , 'A64: 1101|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , 'ARMv8+ BASE'  ],

  # ==> EOR (shifted register)
  ['eor'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0100|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['eor'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1100|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> ERET
  ['eret'              , ''                                      , 'A64: 1101|0110|1001|1111|0000|0011|1110|0000'                                  , 'ARMv8+ BASE'  ],

  # ==> EXTR
  ['extr'              , 'Wd, Wn, Wm, #lsb'                      , 'A64: 0001|0011|100|Wm:5|lsb=0xxxxx|Wn:5|Wd:5'                                  , 'ARMv8+ BASE'  ],
  ['extr'              , 'Xd, Xn, Xm, #lsb'                      , 'A64: 1001|0011|110|Xm:5|lsb:6|Xn:5|Xd:5'                                       , 'ARMv8+ BASE'  ],

  # ==> HINT
  ['hint'              , '#imm'                                  , 'A64: 1101|0101|0000|0011|0010|0000|imm=11x|1111|1'                             , 'ARMv8+ BASE'  ],
  ['hint'              , '#imm'                                  , 'A64: 1101|0101|0000|0011|0010|imm!=0000|imm:3|1111|1'                          , 'ARMv8+ BASE'  ],

  # ==> HLT
  ['hlt'               , '#imm'                                  , 'A64: 1101|0100|010|imm:16|0000|0'                                              , 'ARMv8+ BASE'  ],

  # ==> HVC
  ['hvc'               , '#imm'                                  , 'A64: 1101|0100|000|imm:16|0001|0'                                              , 'ARMv8+ BASE'  ],

  # ==> IC
  ['ic'                , 'ic_op, {Xt}'                           , 'A64: 1101|0101|0000|1|ic_op:3|0111|ic_op:4|ic_op:3|Xt:5'                       , 'ARMv8+ BASE ALIAS_OF=sys PREFERRED_IF=SysOp(ic_op,0111,ic_op,ic_op)==Sys_IC'  ],

  # ==> ISB
  ['isb'               , '{option|#imm}'                         , 'A64: 1101|0101|0000|0011|0011|imm:4|1101|1111'                                 , 'ARMv8+ BASE'  ],

  # ==> LDAR
  ['ldar'              , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|1101|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],
  ['ldar'              , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|1101|1111|1111|11|Xn:5|Xt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDARB
  ['ldarb'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|1101|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDARH
  ['ldarh'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|1101|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDAXP
  ['ldaxp'             , 'Wt1, Wt2, [$Xn, {#0}]'                 , 'A64: 1000|1000|0111|1111|1|Wt2:5|Xn:5|Wt1:5'                                   , 'ARMv8+ BASE'  ],
  ['ldaxp'             , 'Xt1, Xt2, [$Xn, {#0}]'                 , 'A64: 1100|1000|0111|1111|1|Xt2:5|Xn:5|Xt1:5'                                   , 'ARMv8+ BASE'  ],

  # ==> LDAXR
  ['ldaxr'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|0101|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],
  ['ldaxr'             , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|0101|1111|1111|11|Xn:5|Xt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDAXRB
  ['ldaxrb'            , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|0101|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDAXRH
  ['ldaxrh'            , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|0101|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDNP
  ['ldnp'              , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1000|01|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldnp'              , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1000|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],

  # ==> LDP
  ['ldp'               , 'Wt1, Wt2, [$Xn], #imm*4'               , 'A64: 0010|1000|11|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldp'               , 'Xt1, Xt2, [$Xn], #imm*8'               , 'A64: 1010|1000|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldp'               , 'Wt1, Wt2, [$Xn, #imm*4]!'              , 'A64: 0010|1001|11|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldp'               , 'Xt1, Xt2, [$Xn, #imm*8]!'              , 'A64: 1010|1001|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldp'               , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1001|01|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldp'               , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1001|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],

  # ==> LDPSW
  ['ldpsw'             , 'Xt1, Xt2, [$Xn], #imm*4'               , 'A64: 0110|1000|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldpsw'             , 'Xt1, Xt2, [$Xn, #imm*4]!'              , 'A64: 0110|1001|11|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],
  ['ldpsw'             , 'Xt1, Xt2, [$Xn, {#imm*4}]'             , 'A64: 0110|1001|01|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],

  # ==> LDR (immediate)
  ['ldr'               , 'Wt, [$Xn], #imm.s'                     , 'A64: 1011|1000|010|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Xt, [$Xn], #imm.s'                     , 'A64: 1111|1000|010|imm:9|01|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 1011|1000|010|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 1111|1000|010|imm:9|11|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Wt, [$Xn, {#imm.z*4}]'                 , 'A64: 1011|1001|01|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Xt, [$Xn, {#imm.z*8}]'                 , 'A64: 1111|1001|01|imm:12|Xn:5|Xt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> LDR (literal)
  ['ldr'               , 'Wt, rel.s*4'                           , 'A64: 0001|1000|rel:19|Wt:5'                                                    , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Xt, rel.s*4'                           , 'A64: 0101|1000|rel:19|Xt:5'                                                    , 'ARMv8+ BASE'  ],

  # ==> LDR (register)
  ['ldr'               , 'Wt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 1011|1000|011|m:5|R<0>/extend:3|amount:1|10|Xn:5|Wt:5'                    , 'ARMv8+ BASE'  ],
  ['ldr'               , 'Xt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 1111|1000|011|m:5|R<0>/extend:3|amount:1|10|Xn:5|Xt:5'                    , 'ARMv8+ BASE'  ],

  # ==> LDRB (immediate)
  ['ldrb'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0011|1000|010|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrb'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|010|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrb'              , 'Wt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|01|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> LDRB (register)
  ['ldrb'              , 'Wt, [$Xn, R.m, extend {amount}]'       , 'A64: 0011|1000|011|m:5|R<0>/extend!=011|amount:1|10|Xn:5|Wt:5'                 , 'ARMv8+ BASE'  ],
  ['ldrb'              , 'Wt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|011|Xm:5|011|amount:1|10|Xn:5|Wt:5'                             , 'ARMv8+ BASE'  ],

  # ==> LDRH (immediate)
  ['ldrh'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0111|1000|010|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrh'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|010|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrh'              , 'Wt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|01|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> LDRH (register)
  ['ldrh'              , 'Wt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 0111|1000|011|m:5|R<0>/extend:3|amount:1|10|Xn:5|Wt:5'                    , 'ARMv8+ BASE'  ],

  # ==> LDRSB (immediate)
  ['ldrsb'             , 'Wt, [$Xn], #imm.s'                     , 'A64: 0011|1000|110|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Xt, [$Xn], #imm.s'                     , 'A64: 0011|1000|100|imm:9|01|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|110|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|100|imm:9|11|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Wt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|11|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Xt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|10|imm:12|Xn:5|Xt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> LDRSB (register)
  ['ldrsb'             , 'Wt, [$Xn, R.m, extend {amount}]'       , 'A64: 0011|1000|111|m:5|R<0>/extend!=011|amount:1|10|Xn:5|Wt:5'                 , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Wt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|111|Xm:5|011|amount:1|10|Xn:5|Wt:5'                             , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Xt, [$Xn, R.m, extend {amount}]'       , 'A64: 0011|1000|101|m:5|R<0>/extend!=011|amount:1|10|Xn:5|Xt:5'                 , 'ARMv8+ BASE'  ],
  ['ldrsb'             , 'Xt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|101|Xm:5|011|amount:1|10|Xn:5|Xt:5'                             , 'ARMv8+ BASE'  ],

  # ==> LDRSH (immediate)
  ['ldrsh'             , 'Wt, [$Xn], #imm.s'                     , 'A64: 0111|1000|110|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsh'             , 'Xt, [$Xn], #imm.s'                     , 'A64: 0111|1000|100|imm:9|01|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsh'             , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|110|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsh'             , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|100|imm:9|11|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsh'             , 'Wt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|11|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],
  ['ldrsh'             , 'Xt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|10|imm:12|Xn:5|Xt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> LDRSH (register)
  ['ldrsh'             , 'Wt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 0111|1000|111|m:5|R<0>/extend:3|amount:1|10|Xn:5|Wt:5'                    , 'ARMv8+ BASE'  ],
  ['ldrsh'             , 'Xt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 0111|1000|101|m:5|R<0>/extend:3|amount:1|10|Xn:5|Xt:5'                    , 'ARMv8+ BASE'  ],

  # ==> LDRSW (immediate)
  ['ldrsw'             , 'Xt, [$Xn], #imm.s'                     , 'A64: 1011|1000|100|imm:9|01|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsw'             , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 1011|1000|100|imm:9|11|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldrsw'             , 'Xt, [$Xn, {#imm.z*4}]'                 , 'A64: 1011|1001|10|imm:12|Xn:5|Xt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> LDRSW (literal)
  ['ldrsw'             , 'Xt, rel.s*4'                           , 'A64: 1001|1000|rel:19|Xt:5'                                                    , 'ARMv8+ BASE'  ],

  # ==> LDRSW (register)
  ['ldrsw'             , 'Xt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 1011|1000|101|m:5|R<0>/extend:3|amount:1|10|Xn:5|Xt:5'                    , 'ARMv8+ BASE'  ],

  # ==> LDTR
  ['ldtr'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|010|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldtr'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|010|imm:9|10|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDTRB
  ['ldtrb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|010|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDTRH
  ['ldtrh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|010|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDTRSB
  ['ldtrsb'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|110|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldtrsb'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|100|imm:9|10|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDTRSH
  ['ldtrsh'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|110|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldtrsh'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|100|imm:9|10|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDTRSW
  ['ldtrsw'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|100|imm:9|10|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDUR
  ['ldur'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|010|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldur'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|010|imm:9|00|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDURB
  ['ldurb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|010|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDURH
  ['ldurh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|010|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDURSB
  ['ldursb'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|110|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldursb'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|100|imm:9|00|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDURSH
  ['ldursh'            , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|110|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['ldursh'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|100|imm:9|00|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDURSW
  ['ldursw'            , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|100|imm:9|00|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> LDXP
  ['ldxp'              , 'Wt1, Wt2, [$Xn, {#0}]'                 , 'A64: 1000|1000|0111|1111|0|Wt2:5|Xn:5|Wt1:5'                                   , 'ARMv8+ BASE'  ],
  ['ldxp'              , 'Xt1, Xt2, [$Xn, {#0}]'                 , 'A64: 1100|1000|0111|1111|0|Xt2:5|Xn:5|Xt1:5'                                   , 'ARMv8+ BASE'  ],

  # ==> LDXR
  ['ldxr'              , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|0101|1111|0111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],
  ['ldxr'              , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|0101|1111|0111|11|Xn:5|Xt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDXRB
  ['ldxrb'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|0101|1111|0111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LDXRH
  ['ldxrh'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|0101|1111|0111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> LSL (register)
  ['lsl'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=lslv PREFERRED_IF=ALWAYS'  ],
  ['lsl'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|00|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=lslv PREFERRED_IF=ALWAYS'  ],

  # ==> LSL (immediate)
  ['lsl'               , 'Wd, Wn, #shift'                        , 'A64: 0101|0011|00|immr:6|imms!=011111|Wn:5|Wd:5'                               , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=imms+1==immr'  ],
  ['lsl'               , 'Xd, Xn, #shift'                        , 'A64: 1101|0011|01|immr:6|imms!=111111|Xn:5|Xd:5'                               , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=imms+1==immr'  ],

  # ==> LSLV
  ['lslv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['lslv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|00|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> LSR (register)
  ['lsr'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|01|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=lsrv PREFERRED_IF=ALWAYS'  ],
  ['lsr'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|01|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=lsrv PREFERRED_IF=ALWAYS'  ],

  # ==> LSR (immediate)
  ['lsr'               , 'Wd, Wn, #shift'                        , 'A64: 0101|0011|00|shift:6|0111|11|Wn:5|Wd:5'                                   , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=ALWAYS'  ],
  ['lsr'               , 'Xd, Xn, #shift'                        , 'A64: 1101|0011|01|shift:6|1111|11|Xn:5|Xd:5'                                   , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=ALWAYS'  ],

  # ==> LSRV
  ['lsrv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|01|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['lsrv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|01|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> MADD
  ['madd'              , 'Wd, Wn, Wm, Wa'                        , 'A64: 0001|1011|000|Wm:5|0|Wa:5|Wn:5|Wd:5'                                      , 'ARMv8+ BASE'  ],
  ['madd'              , 'Xd, Xn, Xm, Xa'                        , 'A64: 1001|1011|000|Xm:5|0|Xa:5|Xn:5|Xd:5'                                      , 'ARMv8+ BASE'  ],

  # ==> MNEG
  ['mneg'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1011|000|Wm:5|1111|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=msub PREFERRED_IF=ALWAYS'  ],
  ['mneg'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|000|Xm:5|1111|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=msub PREFERRED_IF=ALWAYS'  ],

  # ==> MOV (to/from SP)
  ['mov'               , '$Wd, $Wn'                              , 'A64: 0001|0001|0000|0000|0000|00|Wn:5|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=add PREFERRED_IF=(Wd==11111||Wn==11111)'  ],
  ['mov'               , '$Xd, $Xn'                              , 'A64: 1001|0001|0000|0000|0000|00|Xn:5|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=add PREFERRED_IF=(Xd==11111||Xn==11111)'  ],

  # ==> MOV (inverted wide immediate)
  ['mov'               , 'Wd, #imm'                              , 'A64: 0001|0010|1|imm.B:2|imm.A:16|Wd:5'                                        , 'ARMv8+ BASE ALIAS_OF=movn PREFERRED_IF="!(IsZero(imm.A) && imm.B!=00) && !IsOnes(imm.A)"'  ],
  ['mov'               , 'Xd, #imm'                              , 'A64: 1001|0010|1|imm.B:2|imm.A:16|Xd:5'                                        , 'ARMv8+ BASE ALIAS_OF=movn PREFERRED_IF="!(IsZero(imm.A) && imm.B!=00)"'  ],

  # ==> MOV (wide immediate)
  ['mov'               , 'Wd, #imm'                              , 'A64: 0101|0010|1|imm.B:2|imm.A:16|Wd:5'                                        , 'ARMv8+ BASE ALIAS_OF=movz PREFERRED_IF="!(IsZero(imm.A) && imm.B!=00)"'  ],
  ['mov'               , 'Xd, #imm'                              , 'A64: 1101|0010|1|imm.B:2|imm.A:16|Xd:5'                                        , 'ARMv8+ BASE ALIAS_OF=movz PREFERRED_IF="!(IsZero(imm.A) && imm.B!=00)"'  ],

  # ==> MOV (bitmask immediate)
  ['mov'               , '$Wd, #bimm'                            , 'A64: sf=0|0110|0100|N=0|bimm.B:6|bimm.A:6|1111|1|Wd:5'                         , 'ARMv8+ BASE ALIAS_OF=orr PREFERRED_IF=!MoveWidePreferred(sf,N,bimm.A,bimm.B)'  ],
  ['mov'               , '$Xd, #bimm'                            , 'A64: sf=1|0110|0100|bimm.A:1|bimm.C:6|bimm.B:6|1111|1|Xd:5'                    , 'ARMv8+ BASE ALIAS_OF=orr PREFERRED_IF=!MoveWidePreferred(sf,bimm.A,bimm.B,bimm.C)'  ],

  # ==> MOV (register)
  ['mov'               , 'Wd, Wm'                                , 'A64: 0010|1010|000|Wm:5|0000|0011|111|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=orr PREFERRED_IF=ALWAYS'  ],
  ['mov'               , 'Xd, Xm'                                , 'A64: 1010|1010|000|Xm:5|0000|0011|111|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=orr PREFERRED_IF=ALWAYS'  ],

  # ==> MOVK
  ['movk'              , 'Wd, #imm, {LSL #shift*16}'             , 'A64: 0111|0010|1|shift:2|imm:16|Wd:5'                                          , 'ARMv8+ BASE'  ],
  ['movk'              , 'Xd, #imm, {LSL #shift*16}'             , 'A64: 1111|0010|1|shift:2|imm:16|Xd:5'                                          , 'ARMv8+ BASE'  ],

  # ==> MOVN
  ['movn'              , 'Wd, #imm, {LSL #shift*16}'             , 'A64: 0001|0010|1|shift:2|imm:16|Wd:5'                                          , 'ARMv8+ BASE'  ],
  ['movn'              , 'Xd, #imm, {LSL #shift*16}'             , 'A64: 1001|0010|1|shift:2|imm:16|Xd:5'                                          , 'ARMv8+ BASE'  ],

  # ==> MOVZ
  ['movz'              , 'Wd, #imm, {LSL #shift*16}'             , 'A64: 0101|0010|1|shift:2|imm:16|Wd:5'                                          , 'ARMv8+ BASE'  ],
  ['movz'              , 'Xd, #imm, {LSL #shift*16}'             , 'A64: 1101|0010|1|shift:2|imm:16|Xd:5'                                          , 'ARMv8+ BASE'  ],

  # ==> MRS
  ['mrs'               , 'Xt, sysreg'                            , 'A64: 1101|0101|0011|sysreg:1|sysreg:3|sysreg:4|sysreg:4|sysreg:3|Xt:5'         , 'ARMv8+ BASE'  ],

  # ==> MSR (immediate)
  ['msr'               , 'state, #imm'                           , 'A64: 1101|0101|0000|0|state:3|0100|imm:4|state:3|1111|1'                       , 'ARMv8+ BASE'  ],

  # ==> MSR (register)
  ['msr'               , 'sysreg, Xt'                            , 'A64: 1101|0101|0001|sysreg:1|sysreg:3|sysreg:4|sysreg:4|sysreg:3|Xt:5'         , 'ARMv8+ BASE'  ],

  # ==> MSUB
  ['msub'              , 'Wd, Wn, Wm, Wa'                        , 'A64: 0001|1011|000|Wm:5|1|Wa:5|Wn:5|Wd:5'                                      , 'ARMv8+ BASE'  ],
  ['msub'              , 'Xd, Xn, Xm, Xa'                        , 'A64: 1001|1011|000|Xm:5|1|Xa:5|Xn:5|Xd:5'                                      , 'ARMv8+ BASE'  ],

  # ==> MUL
  ['mul'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1011|000|Wm:5|0111|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=madd PREFERRED_IF=ALWAYS'  ],
  ['mul'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|000|Xm:5|0111|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=madd PREFERRED_IF=ALWAYS'  ],

  # ==> MVN
  ['mvn'               , 'Wd, Wm, {shift #amount}'               , 'A64: 0010|1010|shift:2|1|Wm:5|amount:6|1111|1|Wd:5'                            , 'ARMv8+ BASE ALIAS_OF=orn PREFERRED_IF=ALWAYS'  ],
  ['mvn'               , 'Xd, Xm, {shift #amount}'               , 'A64: 1010|1010|shift:2|1|Xm:5|amount:6|1111|1|Xd:5'                            , 'ARMv8+ BASE ALIAS_OF=orn PREFERRED_IF=ALWAYS'  ],

  # ==> NEG (shifted register)
  ['neg'               , 'Wd, Wm, {shift #amount}'               , 'A64: 0100|1011|shift:2|0|Wm:5|amount:6|1111|1|Wd:5'                            , 'ARMv8+ BASE ALIAS_OF=sub PREFERRED_IF=ALWAYS'  ],
  ['neg'               , 'Xd, Xm, {shift #amount}'               , 'A64: 1100|1011|shift:2|0|Xm:5|amount:6|1111|1|Xd:5'                            , 'ARMv8+ BASE ALIAS_OF=sub PREFERRED_IF=ALWAYS'  ],

  # ==> NEGS
  ['negs'              , 'Wd, Wm, {shift #amount}'               , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|1111|1|Wd:5'                            , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],
  ['negs'              , 'Xd, Xm, {shift #amount}'               , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|1111|1|Xd:5'                            , 'ARMv8+ BASE ALIAS_OF=subs PREFERRED_IF=ALWAYS'  ],

  # ==> NGC
  ['ngc'               , 'Wd, Wm'                                , 'A64: 0101|1010|000|Wm:5|0000|0011|111|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbc PREFERRED_IF=ALWAYS'  ],
  ['ngc'               , 'Xd, Xm'                                , 'A64: 1101|1010|000|Xm:5|0000|0011|111|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbc PREFERRED_IF=ALWAYS'  ],

  # ==> NGCS
  ['ngcs'              , 'Wd, Wm'                                , 'A64: 0111|1010|000|Wm:5|0000|0011|111|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbcs PREFERRED_IF=ALWAYS'  ],
  ['ngcs'              , 'Xd, Xm'                                , 'A64: 1111|1010|000|Xm:5|0000|0011|111|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbcs PREFERRED_IF=ALWAYS'  ],

  # ==> NOP
  ['nop'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0001|1111'                                  , 'ARMv8+ BASE'  ],

  # ==> ORN (shifted register)
  ['orn'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0010|1010|shift:2|1|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['orn'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1010|1010|shift:2|1|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> ORR (immediate)
  ['orr'               , '$Wd, Wn, #bimm'                        , 'A64: 0011|0010|00|bimm.B:6|bimm.A:6|Wn:5|Wd:5'                                 , 'ARMv8+ BASE'  ],
  ['orr'               , '$Xd, Xn, #bimm'                        , 'A64: 1011|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|Xd:5'                         , 'ARMv8+ BASE'  ],

  # ==> ORR (shifted register)
  ['orr'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0010|1010|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['orr'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1010|1010|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> PRFM (immediate)
  ['prfm'              , 'prfop, [$Xn, {#imm.z*8}]'              , 'A64: 1111|1001|10|imm:12|Xn:5|prfop:5'                                         , 'ARMv8+ BASE'  ],

  # ==> PRFM (literal)
  ['prfm'              , 'prfop, rel.s*4'                        , 'A64: 1101|1000|rel:19|prfop:5'                                                 , 'ARMv8+ BASE'  ],

  # ==> PRFM (register)
  ['prfm'              , 'prfop, [$Xn, R.m, {extend {amount}}]'  , 'A64: 1111|1000|101|m:5|R<0>/extend:3|amount:1|10|Xn:5|prfop:5'                 , 'ARMv8+ BASE'  ],

  # ==> PRFM (unscaled offset)
  ['prfum'             , 'prfop, [$Xn, {#imm.s}]'                , 'A64: 1111|1000|100|imm:9|00|Xn:5|prfop:5'                                      , 'ARMv8+ BASE'  ],

  # ==> RBIT
  ['rbit'              , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0000|00|Wn:5|Wd:5'                                    , 'ARMv8+ BASE'  ],
  ['rbit'              , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|00|Xn:5|Xd:5'                                    , 'ARMv8+ BASE'  ],

  # ==> RET
  ['ret'               , '{Xn}'                                  , 'A64: 1101|0110|0101|1111|0000|00|Xn:5|0000|0'                                  , 'ARMv8+ BASE'  ],

  # ==> REV
  ['rev'               , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0000|10|Wn:5|Wd:5'                                    , 'ARMv8+ BASE'  ],
  ['rev'               , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|11|Xn:5|Xd:5'                                    , 'ARMv8+ BASE'  ],

  # ==> REV16
  ['rev16'             , 'Wd, Wn'                                , 'A64: 0101|1010|1100|0000|0000|01|Wn:5|Wd:5'                                    , 'ARMv8+ BASE'  ],
  ['rev16'             , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|01|Xn:5|Xd:5'                                    , 'ARMv8+ BASE'  ],

  # ==> REV32
  ['rev32'             , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|10|Xn:5|Xd:5'                                    , 'ARMv8+ BASE'  ],

  # ==> REV64
  ['rev64'             , 'Xd, Xn'                                , 'A64: 1101|1010|1100|0000|0000|11|Xn:5|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=rev PREFERRED_IF=NEVER'  ],

  # ==> ROR (immediate)
  ['ror'               , 'Wd, Ws, #shift'                        , 'A64: 0001|0011|100|Rm:5|shift=0xxxxx|Ws:5|Wd:5'                                , 'ARMv8+ BASE ALIAS_OF=extr PREFERRED_IF=Ws==Rm'  ],
  ['ror'               , 'Xd, Xs, #shift'                        , 'A64: 1001|0011|110|Rm:5|shift:6|Xs:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=extr PREFERRED_IF=Xs==Rm'  ],

  # ==> ROR (register)
  ['ror'               , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=rorv PREFERRED_IF=ALWAYS'  ],
  ['ror'               , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=rorv PREFERRED_IF=ALWAYS'  ],

  # ==> RORV
  ['rorv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0010|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['rorv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0010|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SBC
  ['sbc'               , 'Wd, Wn, Wm'                            , 'A64: 0101|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['sbc'               , 'Xd, Xn, Xm'                            , 'A64: 1101|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SBCS
  ['sbcs'              , 'Wd, Wn, Wm'                            , 'A64: 0111|1010|000|Wm:5|0000|00|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['sbcs'              , 'Xd, Xn, Xm'                            , 'A64: 1111|1010|000|Xm:5|0000|00|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SBFIZ
  ['sbfiz'             , 'Wd, Wn, #lsb, #width'                  , 'A64: 0001|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=UInt(imms)<UInt(immr)'  ],
  ['sbfiz'             , 'Xd, Xn, #lsb, #width'                  , 'A64: 1001|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=UInt(imms)<UInt(immr)'  ],

  # ==> SBFM
  ['sbfm'              , 'Wd, Wn, #immr, #imms'                  , 'A64: 0001|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['sbfm'              , 'Xd, Xn, #immr, #imms'                  , 'A64: 1001|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SBFX
  ['sbfx'              , 'Wd, Wn, #lsb, #width'                  , 'A64: sf=0|opc=00|1001|100|immr:6|imms:6|Wn:5|Wd:5'                             , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=BFXPreferred(sf,opc<1>,imms,immr)'  ],
  ['sbfx'              , 'Xd, Xn, #lsb, #width'                  , 'A64: sf=1|opc=00|1001|101|immr:6|imms:6|Xn:5|Xd:5'                             , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=BFXPreferred(sf,opc<1>,imms,immr)'  ],

  # ==> SDIV
  ['sdiv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0000|11|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['sdiv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0000|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SEV
  ['sev'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|1001|1111'                                  , 'ARMv8+ BASE'  ],

  # ==> SEVL
  ['sevl'              , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|1011|1111'                                  , 'ARMv8+ BASE'  ],

  # ==> SMADDL
  ['smaddl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|001|Wm:5|0|Xa:5|Wn:5|Xd:5'                                      , 'ARMv8+ BASE'  ],

  # ==> SMC
  ['smc'               , '#imm'                                  , 'A64: 1101|0100|000|imm:16|0001|1'                                              , 'ARMv8+ BASE'  ],

  # ==> SMNEGL
  ['smnegl'            , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|001|Wm:5|1111|11|Wn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=smsubl PREFERRED_IF=ALWAYS'  ],

  # ==> SMSUBL
  ['smsubl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|001|Wm:5|1|Xa:5|Wn:5|Xd:5'                                      , 'ARMv8+ BASE'  ],

  # ==> SMULH
  ['smulh'             , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|010|Xm:5|0111|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SMULL
  ['smull'             , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|001|Wm:5|0111|11|Wn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=smaddl PREFERRED_IF=ALWAYS'  ],

  # ==> STLR
  ['stlr'              , 'Wt, [$Xn, {#0}]'                       , 'A64: 1000|1000|1001|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],
  ['stlr'              , 'Xt, [$Xn, {#0}]'                       , 'A64: 1100|1000|1001|1111|1111|11|Xn:5|Xt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> STLRB
  ['stlrb'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0000|1000|1001|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> STLRH
  ['stlrh'             , 'Wt, [$Xn, {#0}]'                       , 'A64: 0100|1000|1001|1111|1111|11|Xn:5|Wt:5'                                    , 'ARMv8+ BASE'  ],

  # ==> STLXP
  ['stlxp'             , 'Ws, Wt1, Wt2, [$Xn, {#0}]'             , 'A64: 1000|1000|001|Ws:5|1|Wt2:5|Xn:5|Wt1:5'                                    , 'ARMv8+ BASE'  ],
  ['stlxp'             , 'Ws, Xt1, Xt2, [$Xn, {#0}]'             , 'A64: 1100|1000|001|Ws:5|1|Xt2:5|Xn:5|Xt1:5'                                    , 'ARMv8+ BASE'  ],

  # ==> STLXR
  ['stlxr'             , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 1000|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                     , 'ARMv8+ BASE'  ],
  ['stlxr'             , 'Ws, Xt, [$Xn, {#0}]'                   , 'A64: 1100|1000|000|Ws:5|1111|11|Xn:5|Xt:5'                                     , 'ARMv8+ BASE'  ],

  # ==> STLXRB
  ['stlxrb'            , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0000|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                     , 'ARMv8+ BASE'  ],

  # ==> STLXRH
  ['stlxrh'            , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0100|1000|000|Ws:5|1111|11|Xn:5|Wt:5'                                     , 'ARMv8+ BASE'  ],

  # ==> STNP
  ['stnp'              , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1000|00|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['stnp'              , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1000|00|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],

  # ==> STP
  ['stp'               , 'Wt1, Wt2, [$Xn], #imm*4'               , 'A64: 0010|1000|10|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['stp'               , 'Xt1, Xt2, [$Xn], #imm*8'               , 'A64: 1010|1000|10|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],
  ['stp'               , 'Wt1, Wt2, [$Xn, #imm*4]!'              , 'A64: 0010|1001|10|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['stp'               , 'Xt1, Xt2, [$Xn, #imm*8]!'              , 'A64: 1010|1001|10|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],
  ['stp'               , 'Wt1, Wt2, [$Xn, {#imm*4}]'             , 'A64: 0010|1001|00|imm:7|Wt2:5|Xn:5|Wt1:5'                                      , 'ARMv8+ BASE'  ],
  ['stp'               , 'Xt1, Xt2, [$Xn, {#imm*8}]'             , 'A64: 1010|1001|00|imm:7|Xt2:5|Xn:5|Xt1:5'                                      , 'ARMv8+ BASE'  ],

  # ==> STR (immediate)
  ['str'               , 'Wt, [$Xn], #imm.s'                     , 'A64: 1011|1000|000|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['str'               , 'Xt, [$Xn], #imm.s'                     , 'A64: 1111|1000|000|imm:9|01|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['str'               , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 1011|1000|000|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['str'               , 'Xt, [$Xn, #imm.s]!'                    , 'A64: 1111|1000|000|imm:9|11|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],
  ['str'               , 'Wt, [$Xn, {#imm.z*4}]'                 , 'A64: 1011|1001|00|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],
  ['str'               , 'Xt, [$Xn, {#imm.z*8}]'                 , 'A64: 1111|1001|00|imm:12|Xn:5|Xt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> STR (register)
  ['str'               , 'Wt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 1011|1000|001|m:5|R<0>/extend:3|amount:1|10|Xn:5|Wt:5'                    , 'ARMv8+ BASE'  ],
  ['str'               , 'Xt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 1111|1000|001|m:5|R<0>/extend:3|amount:1|10|Xn:5|Xt:5'                    , 'ARMv8+ BASE'  ],

  # ==> STRB (immediate)
  ['strb'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0011|1000|000|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['strb'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0011|1000|000|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['strb'              , 'Wt, [$Xn, {#imm.z}]'                   , 'A64: 0011|1001|00|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> STRB (register)
  ['strb'              , 'Wt, [$Xn, R.m, extend {amount}]'       , 'A64: 0011|1000|001|m:5|R<0>/extend!=011|amount:1|10|Xn:5|Wt:5'                 , 'ARMv8+ BASE'  ],
  ['strb'              , 'Wt, [$Xn, Xm, {LSL amount}]'           , 'A64: 0011|1000|001|Xm:5|011|amount:1|10|Xn:5|Wt:5'                             , 'ARMv8+ BASE'  ],

  # ==> STRH (immediate)
  ['strh'              , 'Wt, [$Xn], #imm.s'                     , 'A64: 0111|1000|000|imm:9|01|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['strh'              , 'Wt, [$Xn, #imm.s]!'                    , 'A64: 0111|1000|000|imm:9|11|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['strh'              , 'Wt, [$Xn, {#imm.z*2}]'                 , 'A64: 0111|1001|00|imm:12|Xn:5|Wt:5'                                            , 'ARMv8+ BASE'  ],

  # ==> STRH (register)
  ['strh'              , 'Wt, [$Xn, R.m, {extend {amount}}]'     , 'A64: 0111|1000|001|m:5|R<0>/extend:3|amount:1|10|Xn:5|Wt:5'                    , 'ARMv8+ BASE'  ],

  # ==> STTR
  ['sttr'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|000|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['sttr'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|000|imm:9|10|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> STTRB
  ['sttrb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|000|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> STTRH
  ['sttrh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|000|imm:9|10|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> STUR
  ['stur'              , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 1011|1000|000|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],
  ['stur'              , 'Xt, [$Xn, {#imm.s}]'                   , 'A64: 1111|1000|000|imm:9|00|Xn:5|Xt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> STURB
  ['sturb'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0011|1000|000|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> STURH
  ['sturh'             , 'Wt, [$Xn, {#imm.s}]'                   , 'A64: 0111|1000|000|imm:9|00|Xn:5|Wt:5'                                         , 'ARMv8+ BASE'  ],

  # ==> STXP
  ['stxp'              , 'Ws, Wt1, Wt2, [$Xn, {#0}]'             , 'A64: 1000|1000|001|Ws:5|0|Wt2:5|Xn:5|Wt1:5'                                    , 'ARMv8+ BASE'  ],
  ['stxp'              , 'Ws, Xt1, Xt2, [$Xn, {#0}]'             , 'A64: 1100|1000|001|Ws:5|0|Xt2:5|Xn:5|Xt1:5'                                    , 'ARMv8+ BASE'  ],

  # ==> STXR
  ['stxr'              , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 1000|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                     , 'ARMv8+ BASE'  ],
  ['stxr'              , 'Ws, Xt, [$Xn, {#0}]'                   , 'A64: 1100|1000|000|Ws:5|0111|11|Xn:5|Xt:5'                                     , 'ARMv8+ BASE'  ],

  # ==> STXRB
  ['stxrb'             , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0000|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                     , 'ARMv8+ BASE'  ],

  # ==> STXRH
  ['stxrh'             , 'Ws, Wt, [$Xn, {#0}]'                   , 'A64: 0100|1000|000|Ws:5|0111|11|Xn:5|Wt:5'                                     , 'ARMv8+ BASE'  ],

  # ==> SUB (extended register)
  ['sub'               , '$Wd, $Wn, Wm, {extend {#amount}}'      , 'A64: 0100|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , 'ARMv8+ BASE'  ],
  ['sub'               , '$Xd, $Xn, R.m, {extend {#amount}}'     , 'A64: 1100|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , 'ARMv8+ BASE'  ],

  # ==> SUB (immediate)
  ['sub'               , '$Wd, $Wn, #imm.z, {shift {#amount}}'   , 'A64: 0101|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , 'ARMv8+ BASE'  ],
  ['sub'               , '$Xd, $Xn, #imm.z, {shift {#amount}}'   , 'A64: 1101|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , 'ARMv8+ BASE'  ],

  # ==> SUB (shifted register)
  ['sub'               , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0100|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['sub'               , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1100|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> SUBS (extended register)
  ['subs'              , 'Wd, $Wn, Wm, {extend {#amount}}'       , 'A64: 0110|1011|001|Wm:5|extend:3|amount:3|Wn:5|Wd:5'                           , 'ARMv8+ BASE'  ],
  ['subs'              , 'Xd, $Xn, R.m, {extend {#amount}}'      , 'A64: 1110|1011|001|m:5|R/extend:3|amount:3|Xn:5|Xd:5'                          , 'ARMv8+ BASE'  ],

  # ==> SUBS (immediate)
  ['subs'              , 'Wd, $Wn, #imm.z, {shift {#amount}}'    , 'A64: 0111|0001|shift:2|imm:12|Wn:5|Wd:5'                                       , 'ARMv8+ BASE'  ],
  ['subs'              , 'Xd, $Xn, #imm.z, {shift {#amount}}'    , 'A64: 1111|0001|shift:2|imm:12|Xn:5|Xd:5'                                       , 'ARMv8+ BASE'  ],

  # ==> SUBS (shifted register)
  ['subs'              , 'Wd, Wn, Wm, {shift #amount}'           , 'A64: 0110|1011|shift:2|0|Wm:5|amount:6|Wn:5|Wd:5'                              , 'ARMv8+ BASE'  ],
  ['subs'              , 'Xd, Xn, Xm, {shift #amount}'           , 'A64: 1110|1011|shift:2|0|Xm:5|amount:6|Xn:5|Xd:5'                              , 'ARMv8+ BASE'  ],

  # ==> SVC
  ['svc'               , '#imm'                                  , 'A64: 1101|0100|000|imm:16|0000|1'                                              , 'ARMv8+ BASE'  ],

  # ==> SXTB
  ['sxtb'              , 'Wd, Wn'                                , 'A64: 0001|0011|0000|0000|0001|11|Wn:5|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],
  ['sxtb'              , 'Xd, Wn'                                , 'A64: 1001|0011|0100|0000|0001|11|Wn:5|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],

  # ==> SXTH
  ['sxth'              , 'Wd, Wn'                                , 'A64: 0001|0011|0000|0000|0011|11|Wn:5|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],
  ['sxth'              , 'Xd, Wn'                                , 'A64: 1001|0011|0100|0000|0011|11|Wn:5|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],

  # ==> SXTW
  ['sxtw'              , 'Xd, Wn'                                , 'A64: 1001|0011|0100|0000|0111|11|Wn:5|Xd:5'                                    , 'ARMv8+ BASE ALIAS_OF=sbfm PREFERRED_IF=ALWAYS'  ],

  # ==> SYS
  ['sys'               , '#op1, Cn, Cm, #op2, {Xt}'              , 'A64: 1101|0101|0000|1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                              , 'ARMv8+ BASE'  ],

  # ==> SYSL
  ['sysl'              , 'Xt, #op1, Cn, Cm, #op2'                , 'A64: 1101|0101|0010|1|op1:3|Cn:4|Cm:4|op2:3|Xt:5'                              , 'ARMv8+ BASE'  ],

  # ==> TBNZ
  ['tbnz'              , 'R.t, #imm.s, rel.s*4'                  , 'A64: R/imm:1|0110|111|imm:5|rel:14|t:5'                                        , 'ARMv8+ BASE'  ],

  # ==> TBZ
  ['tbz'               , 'R.t, #imm.s, rel.s*4'                  , 'A64: R/imm:1|0110|110|imm:5|rel:14|t:5'                                        , 'ARMv8+ BASE'  ],

  # ==> TLBI
  ['tlbi'              , 'tlbi_op, {Xt}'                         , 'A64: 1101|0101|0000|1|tlbi_op:3|1000|tlbi_op:4|tlbi_op:3|Xt:5'                 , 'ARMv8+ BASE ALIAS_OF=sys PREFERRED_IF=SysOp(tlbi_op,1000,tlbi_op,tlbi_op)==Sys_TLBI'  ],

  # ==> TST (immediate)
  ['tst'               , 'Wn, #bimm'                             , 'A64: 0111|0010|00|bimm.B:6|bimm.A:6|Wn:5|1111|1'                               , 'ARMv8+ BASE ALIAS_OF=ands PREFERRED_IF=ALWAYS'  ],
  ['tst'               , 'Xn, #bimm'                             , 'A64: 1111|0010|0|bimm.A:1|bimm.C:6|bimm.B:6|Xn:5|1111|1'                       , 'ARMv8+ BASE ALIAS_OF=ands PREFERRED_IF=ALWAYS'  ],

  # ==> TST (shifted register)
  ['tst'               , 'Wn, Wm, {shift #amount}'               , 'A64: 0110|1010|shift:2|0|Wm:5|amount:6|Wn:5|1111|1'                            , 'ARMv8+ BASE ALIAS_OF=ands PREFERRED_IF=ALWAYS'  ],
  ['tst'               , 'Xn, Xm, {shift #amount}'               , 'A64: 1110|1010|shift:2|0|Xm:5|amount:6|Xn:5|1111|1'                            , 'ARMv8+ BASE ALIAS_OF=ands PREFERRED_IF=ALWAYS'  ],

  # ==> UBFIZ
  ['ubfiz'             , 'Wd, Wn, #lsb, #width'                  , 'A64: 0101|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=UInt(imms)<UInt(immr)'  ],
  ['ubfiz'             , 'Xd, Xn, #lsb, #width'                  , 'A64: 1101|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=UInt(imms)<UInt(immr)'  ],

  # ==> UBFM
  ['ubfm'              , 'Wd, Wn, #immr, #imms'                  , 'A64: 0101|0011|00|immr:6|imms:6|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['ubfm'              , 'Xd, Xn, #immr, #imms'                  , 'A64: 1101|0011|01|immr:6|imms:6|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> UBFX
  ['ubfx'              , 'Wd, Wn, #lsb, #width'                  , 'A64: sf=0|opc=10|1001|100|immr:6|imms:6|Wn:5|Wd:5'                             , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=BFXPreferred(sf,opc<1>,imms,immr)'  ],
  ['ubfx'              , 'Xd, Xn, #lsb, #width'                  , 'A64: sf=1|opc=10|1001|101|immr:6|imms:6|Xn:5|Xd:5'                             , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=BFXPreferred(sf,opc<1>,imms,immr)'  ],

  # ==> UDIV
  ['udiv'              , 'Wd, Wn, Wm'                            , 'A64: 0001|1010|110|Wm:5|0000|10|Wn:5|Wd:5'                                     , 'ARMv8+ BASE'  ],
  ['udiv'              , 'Xd, Xn, Xm'                            , 'A64: 1001|1010|110|Xm:5|0000|10|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> UMADDL
  ['umaddl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|101|Wm:5|0|Xa:5|Wn:5|Xd:5'                                      , 'ARMv8+ BASE'  ],

  # ==> UMNEGL
  ['umnegl'            , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|101|Wm:5|1111|11|Wn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=umsubl PREFERRED_IF=ALWAYS'  ],

  # ==> UMSUBL
  ['umsubl'            , 'Xd, Wn, Wm, Xa'                        , 'A64: 1001|1011|101|Wm:5|1|Xa:5|Wn:5|Xd:5'                                      , 'ARMv8+ BASE'  ],

  # ==> UMULH
  ['umulh'             , 'Xd, Xn, Xm'                            , 'A64: 1001|1011|110|Xm:5|0111|11|Xn:5|Xd:5'                                     , 'ARMv8+ BASE'  ],

  # ==> UMULL
  ['umull'             , 'Xd, Wn, Wm'                            , 'A64: 1001|1011|101|Wm:5|0111|11|Wn:5|Xd:5'                                     , 'ARMv8+ BASE ALIAS_OF=umaddl PREFERRED_IF=ALWAYS'  ],

  # ==> UXTB
  ['uxtb'              , 'Wd, Wn'                                , 'A64: 0101|0011|0000|0000|0001|11|Wn:5|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=ALWAYS'  ],

  # ==> UXTH
  ['uxth'              , 'Wd, Wn'                                , 'A64: 0101|0011|0000|0000|0011|11|Wn:5|Wd:5'                                    , 'ARMv8+ BASE ALIAS_OF=ubfm PREFERRED_IF=ALWAYS'  ],

  # ==> WFE
  ['wfe'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0101|1111'                                  , 'ARMv8+ BASE'  ],

  # ==> WFI
  ['wfi'               , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0111|1111'                                  , 'ARMv8+ BASE'  ],

  # ==> YIELD
  ['yield'             , ''                                      , 'A64: 1101|0101|0000|0011|0010|0000|0011|1111'                                  , 'ARMv8+ BASE'  ],

);
