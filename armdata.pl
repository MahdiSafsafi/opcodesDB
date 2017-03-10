# ===>        ARM instruction set        <===

warn "Work still in progress and data may contain some bugs.\n";

my @instructions = (

  # ===>                     AArch32.Base instructions                     <===

  ['adc{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1010|0|Rn:4|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['adcs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1010|1|Rn:4|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['adc{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|101|0|Rn:4|Rd:4|ImmX:12'                                  , ''  ],
  ['adcs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|101|1|Rn:4|Rd:4|ImmX:12'                                  , ''  ],

  ['adc%c{q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0101|Rm:3|Rdn:3'                                                   , 'IT:IN'  ],
  ['adcs{q}'           , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0101|Rm:3|Rdn:3'                                                   , 'IT:OUT'  ],
  ['adc{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1010|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['adc%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1010|0|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:IN'  ],
  ['adc{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1010|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['adcs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1010|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['adcs.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1010|1|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:OUT'  ],
  ['adcs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1010|1|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['adc{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|101|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['adc{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|101|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['adcs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|101|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['adcs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|101|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['adcs{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|101|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['adc{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|101|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['add%c{q}'          , 'Rd, Rn, #ImmZ'                         , 'T16: 000111|0|ImmZ:3|Rn:3|Rd:3'                                                , 'IT:IN'  ],
  ['adds{q}'           , 'Rd, Rn, #ImmZ'                         , 'T16: 000111|0|ImmZ:3|Rn:3|Rd:3'                                                , 'IT:OUT'  ],
  ['add%c{q}'          , 'Rdn, #ImmZ'                            , 'T16: 001|10|Rdn:3|ImmZ:8'                                                      , 'IT:IN'  ],
  ['add%c{q}'          , '{Rdn}, Rdn, #ImmZ'                     , 'T16: 001|10|Rdn:3|ImmZ:8'                                                      , 'IT:IN'  ],
  ['adds{q}'           , 'Rdn, #ImmZ'                            , 'T16: 001|10|Rdn:3|ImmZ:8'                                                      , 'IT:OUT'  ],
  ['adds{q}'           , '{Rdn}, Rdn, #ImmZ'                     , 'T16: 001|10|Rdn:3|ImmZ:8'                                                      , 'IT:OUT'  ],
  ['add%c.w'           , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|0|Rn!=1101|0|ImmX:3|Rd:4|ImmX:8'                      , 'IT:IN'  ],
  ['add{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|0|Rn!=1101|0|ImmX:3|Rd:4|ImmX:8'                      , ''  ],
  ['adds.w'            , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|1|Rn!=1101|0|ImmX:3|Rd!=1111|ImmX:8'                  , 'IT:OUT'  ],
  ['adds{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|1|Rn!=1101|0|ImmX:3|Rd!=1111|ImmX:8'                  , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|0|0|0|0|Rn!=11x1|0|ImmZ:3|Rd:4|ImmZ:8'                    , ''  ],
  ['addw{c}{q}'        , '{Rd}, Rn, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|0|0|0|0|Rn!=11x1|0|ImmZ:3|Rd:4|ImmZ:8'                    , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|100|0|Rn!=11x1|Rd:4|ImmX:12'                              , ''  ],
  ['adds{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|100|1|Rn!=1101|Rd:4|ImmX:12'                              , ''  ],

  ['add%c{q}'          , 'Rd, Rn, Rm'                            , 'T16: 000110|0|Rm:3|Rn:3|Rd:3'                                                  , 'IT:IN'  ],
  ['adds{q}'           , '{Rd}, Rn, Rm'                          , 'T16: 000110|0|Rm:3|Rn:3|Rd:3'                                                  , 'IT:OUT'  ],
  ['add%c{q}'          , 'Rdn, Rm'                               , 'T16: 010001|00|Rm!=1101|Rdn.B!=101'                                            , 'IT:IN FORM=IN'  ],
  ['add{c}{q}'         , '{Rdn}, Rdn, Rm'                        , 'T16: 010001|00|Rm!=1101|Rdn.B!=101'                                            , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1000|0|Rn!=1101|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['add%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1000|0|Rn!=1101|0|!=000|Rd:4|!=00|!=11|Rm:4'                      , 'IT:IN'  ],
  ['add{c}.w'          , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1000|0|Rn!=1101|0|!=000|Rd:4|!=00|!=11|Rm:4'                      , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1000|0|Rn!=1101|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['adds{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1000|1|Rn!=1101|0|000|Rd!=1111|00|11|Rm:4'                        , ''  ],
  ['adds.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1000|1|Rn!=1101|0|!=000|Rd!=1111|!=00|!=11|Rm:4'                  , 'IT:OUT'  ],
  ['adds{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1000|1|Rn!=1101|0|Amount!=000|Rd!=1111|Amount!=00|Shift!=11|Rm:4' , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|100|0|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|100|0|Rn!=1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'       , ''  ],
  ['adds{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|100|1|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['adds{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|100|1|Rn!=1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'       , ''  ],

  ['adds{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|100|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['add{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|100|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['add{c}{q}'         , 'Rd, SP, #ImmZ*4'                       , 'T16: 1010|1|Rd:3|ImmZ:8'                                                       , ''  ],
  ['add{c}{q}'         , '{SP}, SP, #ImmZ*4'                     , 'T16: 10110000|0|ImmZ:7'                                                        , ''  ],
  ['add{c}.w'          , '{Rd}, SP, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|0|1101|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|0|1101|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['adds{c}{q}'        , '{Rd}, SP, #ImmX'                       , 'T32: 11110|ImmX:1|0|1000|1|1101|0|ImmX:3|Rd!=1111|ImmX:8'                      , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|0|0|0|0|1101|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['addw{c}{q}'        , '{Rd}, SP, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|0|0|0|0|1101|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, #ImmX'                       , 'A32: Cond!=1111|0010|100|0|1101|Rd:4|ImmX:12'                                  , ''  ],
  ['adds{c}{q}'        , '{Rd}, SP, #ImmX'                       , 'A32: Cond!=1111|0010|100|1|1101|Rd:4|ImmX:12'                                  , ''  ],

  ['add{c}{q}'         , '{Rdm}, SP, Rdm'                        , 'T16: 010001|00|1|101|Rdm:4'                                                    , ''  ],
  ['add{c}{q}'         , '{SP}, SP, Rm'                          , 'T16: 010001|00|1|Rm!=1101|101'                                                 , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110101|1000|0|1101|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['add{c}.w'          , '{Rd}, SP, Rm'                          , 'T32: 1110101|1000|0|1101|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, Rm, {Shift #Amount}'         , 'T32: 1110101|1000|0|1101|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['adds{c}{q}'        , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110101|1000|1|1101|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['adds{c}{q}'        , '{Rd}, SP, Rm, {Shift #Amount}'         , 'T32: 1110101|1000|1|1101|0|Amount!=000|Rd!=1111|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, Rm, RRX'                     , 'A32: Cond!=1111|0000|100|0|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['add{c}{q}'         , '{Rd}, SP, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|100|0|1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['adds{c}{q}'        , '{Rd}, SP, Rm, RRX'                     , 'A32: Cond!=1111|0000|100|1|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['adds{c}{q}'        , '{Rd}, SP, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|100|1|1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['add{c}{q}'         , 'Rd, PC, #ImmZ*4'                       , 'T16: 1010|0|Rd:3|ImmZ:8'                                                       , ''  ],
  ['addw{c}{q}'        , 'Rd, PC, #ImmZ'                         , 'T32: 11110|ImmZ:1|10|0|0|0|0|1111|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['add{c}{q}'         , 'Rd, PC, #ImmZ'                         , 'T32: 11110|ImmZ:1|10|0|0|0|0|1111|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['add{c}{q}'         , 'Rd, PC, #ImmX'                         , 'A32: Cond!=1111|0010|100|0|1111|Rd:4|ImmX:12'                                  , ''  ],

  ['adr{c}{q}'         , 'Rd, RelZ*4'                            , 'T16: 1010|0|Rd:3|RelZ:8'                                                       , ''  ],
  ['adr{c}{q}'         , 'Rd, RelZ'                              , 'T32: 11110|RelZ:1|10|1|0|1|0|1111|0|RelZ:3|Rd:4|RelZ:8'                        , ''  ],
  ['adr{c}.w'          , 'Rd, RelZ'                              , 'T32: 11110|RelZ:1|10|0|0|0|0|1111|0|RelZ:3|Rd:4|RelZ:8'                        , ''  ],
  ['adr{c}{q}'         , 'Rd, RelZ'                              , 'T32: 11110|RelZ:1|10|0|0|0|0|1111|0|RelZ:3|Rd:4|RelZ:8'                        , ''  ],
  ['adr{c}{q}'         , 'Rd, RelX'                              , 'A32: Cond!=1111|0010|100|0|1111|Rd:4|RelX:12'                                  , ''  ],
  ['adr{c}{q}'         , 'Rd, RelX'                              , 'A32: Cond!=1111|0010|010|0|1111|Rd:4|RelX:12'                                  , ''  ],

  ['and{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0000|0|Rn:4|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['ands{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0000|1|Rn:4|0|ImmC:3|Rd!=1111|ImmC:8'                      , ''  ],
  ['and{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|0010|000|0|Rn:4|Rd:4|ImmC:12'                                  , ''  ],
  ['ands{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|0010|000|1|Rn:4|Rd:4|ImmC:12'                                  , ''  ],

  ['and%c{q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0000|Rm:3|Rdn:3'                                                   , 'IT:IN'  ],
  ['ands{q}'           , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0000|Rm:3|Rdn:3'                                                   , 'IT:OUT'  ],
  ['and{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0000|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['and%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0000|0|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:IN'  ],
  ['and{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0000|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['ands{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0000|1|Rn:4|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['ands.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0000|1|Rn:4|0|!=000|Rd!=1111|!=00|!=11|Rm:4'                      , 'IT:OUT'  ],
  ['ands{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0000|1|Rn:4|0|Amount!=000|Rd!=1111|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['and{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|000|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['and{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|000|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['ands{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|000|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['ands{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|000|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['ands{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|000|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['and{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|000|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['asr%c{q}'          , '{Rd}, Rm, #Imm'                        , 'T16: 000|10|Imm:5|Rm:3|Rd:3'                                                   , 'IT:IN'  ],
  ['asr%c.w'           , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm:3|Rd:4|Imm:2|10|Rm:4'                           , 'IT:IN'  ],
  ['asr{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm:3|Rd:4|Imm:2|10|Rm:4'                           , ''  ],
  ['asr{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Imm:5|10|0|Rm:4'                          , ''  ],

  ['asr%c{q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['asr%c.w'           , '{Rd}, Rm, Rs'                          , 'T32: 111110100|10|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['asr{c}{q}'         , '{Rd}, Rm, Rs'                          , 'T32: 111110100|10|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asr{c}{q}'         , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|10|1|Rm:4'                         , ''  ],

  ['asrs{q}'           , '{Rd}, Rm, #Imm'                        , 'T16: 000|10|Imm:5|Rm:3|Rd:3'                                                   , 'IT:OUT'  ],
  ['asrs.w'            , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm:3|Rd:4|Imm:2|10|Rm:4'                           , 'IT:OUT'  ],
  ['asrs{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm:3|Rd:4|Imm:2|10|Rm:4'                           , ''  ],
  ['asrs{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Imm:5|10|0|Rm:4'                          , ''  ],

  ['asrs{q}'           , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['asrs.w'            , '{Rd}, Rm, Rs'                          , 'T32: 111110100|10|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['asrs{c}{q}'        , '{Rd}, Rm, Rs'                          , 'T32: 111110100|10|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['asrs{c}{q}'        , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|10|1|Rm:4'                         , ''  ],

  ['b%c{q}'            , 'RelS*2'                                , 'T16: 1101|Cond!=111x|RelS:8'                                                   , ''  ],
  ['b{c}{q}'           , 'RelS*2'                                , 'T16: 11100|RelS:11'                                                            , 'IT:OUT:LAST'  ],
  ['b%c.w'             , 'RelS*2'                                , 'T32: 11110|RelS.A:1|Cond!=111x|RelS.D:6|10|RelS.C:1|0|RelS.B:1|RelS.E:11'      , ''  ],
  ['b%c{q}'            , 'RelS*2'                                , 'T32: 11110|RelS.A:1|Cond!=111x|RelS.D:6|10|RelS.C:1|0|RelS.B:1|RelS.E:11'      , ''  ],
  ['b{c}.w'            , 'RelS*2'                                , 'T32: 11110|RelS.A:1|RelS.D:10|10|RelS.B:1|1|RelS.C:1|RelS.E:11'                , ''  ],
  ['b{c}{q}'           , 'RelS*2'                                , 'T32: 11110|RelS.A:1|RelS.D:10|10|RelS.B:1|1|RelS.C:1|RelS.E:11'                , ''  ],
  ['b{c}{q}'           , 'RelS*4'                                , 'A32: Cond!=1111|101|0|RelS:24'                                                 , ''  ],

  ['bfc{c}{q}'         , 'Rd, #Lsb, #Width'                      , 'T32: 11110|0|11|01|1|0|1111|0|Lsb:3|Rd:4|Lsb:2|0|Width:5'                      , ''  ],
  ['bfc{c}{q}'         , 'Rd, #Lsb, #Width'                      , 'A32: Cond!=1111|0111110|Width:5|Rd:4|Lsb:5|001|1111'                           , ''  ],

  ['bfi{c}{q}'         , 'Rd, Rn, #Lsb, #Width'                  , 'T32: 11110|0|11|01|1|0|Rn!=1111|0|Lsb:3|Rd:4|Lsb:2|0|Width:5'                  , ''  ],
  ['bfi{c}{q}'         , 'Rd, Rn, #Lsb, #Width'                  , 'A32: Cond!=1111|0111110|Width:5|Rd:4|Lsb:5|001|Rn!=1111'                       , ''  ],

  ['bic{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0001|0|Rn:4|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['bics{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0001|1|Rn:4|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['bic{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|00111|10|0|Rn:4|Rd:4|ImmC:12'                                  , ''  ],
  ['bics{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|00111|10|1|Rn:4|Rd:4|ImmC:12'                                  , ''  ],

  ['bic%c{q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|1110|Rm:3|Rdn:3'                                                   , 'IT:IN'  ],
  ['bics{q}'           , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|1110|Rm:3|Rdn:3'                                                   , 'IT:OUT'  ],
  ['bic{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0001|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['bic%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0001|0|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:IN'  ],
  ['bic{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0001|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['bics{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0001|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['bics.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0001|1|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:OUT'  ],
  ['bics{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0001|1|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['bic{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|00011|10|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['bic{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|00011|10|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['bics{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|00011|10|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['bics{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|00011|10|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['bics{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|00011|10|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['bic{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|00011|10|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['bkpt{q}'           , '{#}ImmZ'                               , 'T16: 10111110|ImmZ:8'                                                          , ''  ],
  ['bkpt{q}'           , '{#}Imm'                                , 'A32: Cond!=1111|00010|01|0|Imm:12|0111|Imm:4'                                  , ''  ],

  ['bl{c}{q}'          , 'RelS*2'                                , 'T32: 11110|RelS.A:1|RelS.D:10|11|RelS.B:1|1|RelS.C:1|RelS.E:11'                , ''  ],
  ['blx{c}{q}'         , 'RelS*4'                                , 'T32: 11110|RelS.A:1|RelS.D:10|11|RelS.B:1|0|RelS.C:1|RelS.E:10|x'              , ''  ],
  ['bl{c}{q}'          , 'RelS*4'                                , 'A32: Cond!=1111|101|1|RelS:24'                                                 , ''  ],
  ['blx{c}{q}'         , 'RelS*2'                                , 'A32: 1111|101|RelS.B:1|RelS.A:24'                                              , ''  ],

  ['blx{c}{q}'         , 'Rm'                                    , 'T16: 01000111|1|Rm:4|0|0|0'                                                    , ''  ],
  ['blx{c}{q}'         , 'Rm'                                    , 'A32: Cond!=1111|00010010|1|1|1|1|1|1|1|1|1|1|1|1|0011|Rm:4'                    , ''  ],

  ['bx{c}{q}'          , 'Rm'                                    , 'T16: 01000111|0|Rm:4|0|0|0'                                                    , ''  ],
  ['bx{c}{q}'          , 'Rm'                                    , 'A32: Cond!=1111|00010010|1|1|1|1|1|1|1|1|1|1|1|1|0001|Rm:4'                    , ''  ],

  ['bxj{c}{q}'         , 'Rm'                                    , 'T32: 111100111100|Rm:4|10|0|0|1|1|1|1|0|0|0|0|0|0|0|0'                         , ''  ],
  ['bxj{c}{q}'         , 'Rm'                                    , 'A32: Cond!=1111|00010010|1|1|1|1|1|1|1|1|1|1|1|1|0010|Rm:4'                    , ''  ],

  ['cbnz{q}'           , 'Rn, RelZ*2'                            , 'T16: 1011|1|0|RelZ:1|1|RelZ:5|Rn:3'                                            , ''  ],
  ['cbz{q}'            , 'Rn, RelZ*2'                            , 'T16: 1011|0|0|RelZ:1|1|RelZ:5|Rn:3'                                            , ''  ],

  ['clrex{c}{q}'       , ''                                      , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0010|1111'                            , ''  ],
  ['clrex{c}{q}'       , ''                                      , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0001|1111'                           , ''  ],

  ['clz{c}{q}'         , 'Rd, Rm'                                , 'T32: 111110101|011|xxxx|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['clz{c}{q}'         , 'Rd, Rm'                                , 'A32: Cond!=1111|00010110|1|1|1|1|Rd:4|1|1|1|1|0001|Rm:4'                       , ''  ],

  ['cmn{c}{q}'         , 'Rn, #ImmX'                             , 'T32: 11110|ImmX:1|0|1000|1|Rn:4|0|ImmX:3|1111|ImmX:8'                          , ''  ],
  ['cmn{c}{q}'         , 'Rn, #ImmX'                             , 'A32: Cond!=1111|00110|11|1|Rn:4|0|0|0|0|ImmX:12'                               , ''  ],

  ['cmn{c}{q}'         , 'Rn, Rm'                                , 'T16: 010000|1011|Rm:3|Rn:3'                                                    , ''  ],
  ['cmn{c}{q}'         , 'Rn, Rm, RRX'                           , 'T32: 1110101|1000|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['cmn{c}.w'          , 'Rn, Rm'                                , 'T32: 1110101|1000|1|Rn:4|0|!=000|1111|!=00|!=11|Rm:4'                          , ''  ],
  ['cmn{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'T32: 1110101|1000|1|Rn:4|0|Amount!=000|1111|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['cmn{c}{q}'         , 'Rn, Rm, RRX'                           , 'A32: Cond!=1111|00010|11|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['cmn{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00010|11|1|Rn:4|0|0|0|0|Amount!=00000|Shift!=11|0|Rm:4'        , ''  ],

  ['cmn{c}{q}'         , 'Rn, Rm, type Rs'                       , 'A32: Cond!=1111|00010|11|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  ['cmp{c}{q}'         , 'Rn, #ImmZ'                             , 'T16: 001|01|Rn:3|ImmZ:8'                                                       , ''  ],
  ['cmp{c}.w'          , 'Rn, #ImmX'                             , 'T32: 11110|ImmX:1|0|1101|1|Rn:4|0|ImmX:3|1111|ImmX:8'                          , ''  ],
  ['cmp{c}{q}'         , 'Rn, #ImmX'                             , 'T32: 11110|ImmX:1|0|1101|1|Rn:4|0|ImmX:3|1111|ImmX:8'                          , ''  ],
  ['cmp{c}{q}'         , 'Rn, #ImmX'                             , 'A32: Cond!=1111|00110|10|1|Rn:4|0|0|0|0|ImmX:12'                               , ''  ],

  ['cmp{c}{q}'         , 'Rn, Rm'                                , 'T16: 010000|1010|Rm:3|Rn:3'                                                    , ''  ],
  ['cmp{c}{q}'         , 'Rn, Rm'                                , 'T16: 010001|01|Rn:1|Rm:3|Rn:4'                                                 , ''  ],
  ['cmp{c}{q}'         , 'Rn, Rm, RRX'                           , 'T32: 1110101|1101|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['cmp{c}.w'          , 'Rn, Rm'                                , 'T32: 1110101|1101|1|Rn:4|0|!=000|1111|!=00|!=11|Rm:4'                          , ''  ],
  ['cmp{c}{q}'         , 'Rn, Rm, Shift #Amount'                 , 'T32: 1110101|1101|1|Rn:4|0|Amount!=000|1111|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['cmp{c}{q}'         , 'Rn, Rm, RRX'                           , 'A32: Cond!=1111|00010|10|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['cmp{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00010|10|1|Rn:4|0|0|0|0|Amount!=00000|Shift!=11|0|Rm:4'        , ''  ],

  ['cmp{c}{q}'         , 'Rn, Rm, type Rs'                       , 'A32: Cond!=1111|00010|10|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  ['cpsid{q}'          , 'Iflags'                                , 'T16: 1011011001|1|1|0|A|I|F'                                                   , ''  ],
  ['cpsie{q}'          , 'Iflags'                                , 'T16: 1011011001|1|0|0|A|I|F'                                                   , ''  ],
  ['cps{q}'            , '#Mode'                                 , 'T32: 111100111010|1|1|1|1|10|0|0|0|00|1|x|x|x|Mode:5'                          , ''  ],
  ['cpsid.w'           , 'Iflags'                                , 'T32: 111100111010|1|1|1|1|10|0|0|0|11|0|A|I|F|xxxxx'                           , ''  ],
  ['cpsid{q}'          , 'Iflags, #Mode'                         , 'T32: 111100111010|1|1|1|1|10|0|0|0|11|1|A|I|F|Mode:5'                          , ''  ],
  ['cpsie.w'           , 'Iflags'                                , 'T32: 111100111010|1|1|1|1|10|0|0|0|10|0|A|I|F|xxxxx'                           , ''  ],
  ['cpsie{q}'          , 'Iflags, #Mode'                         , 'T32: 111100111010|1|1|1|1|10|0|0|0|10|1|A|I|F|Mode:5'                          , ''  ],
  ['cps{q}'            , '#Mode'                                 , 'A32: 111100010000|00|1|0|0|0|0|0|0|0|0|x|x|x|0|Mode:5'                         , ''  ],
  ['cpsid{q}'          , 'Iflags'                                , 'A32: 111100010000|11|0|0|0|0|0|0|0|0|0|A|I|F|0|xxxxx'                          , ''  ],
  ['cpsid{q}'          , 'Iflags, #Mode'                         , 'A32: 111100010000|11|1|0|0|0|0|0|0|0|0|A|I|F|0|Mode:5'                         , ''  ],
  ['cpsie{q}'          , 'Iflags'                                , 'A32: 111100010000|10|0|0|0|0|0|0|0|0|0|A|I|F|0|xxxxx'                          , ''  ],
  ['cpsie{q}'          , 'Iflags, #Mode'                         , 'A32: 111100010000|10|1|0|0|0|0|0|0|0|0|A|I|F|0|Mode:5'                         , ''  ],

  ['crc32b{q}'         , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|0|Rn:4|1111|Rd:4|10|00|Rm:4'                                 , ''  ],
  ['crc32h{q}'         , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|0|Rn:4|1111|Rd:4|10|01|Rm:4'                                 , ''  ],
  ['crc32w{q}'         , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|0|Rn:4|1111|Rd:4|10|10|Rm:4'                                 , ''  ],
  ['crc32b{q}'         , 'Rd, Rn, Rm'                            , 'A32: Cond!=1111|00010|00|0|Rn:4|Rd:4|0|0|0|0|0100|Rm:4'                        , ''  ],
  ['crc32h{q}'         , 'Rd, Rn, Rm'                            , 'A32: Cond!=1111|00010|01|0|Rn:4|Rd:4|0|0|0|0|0100|Rm:4'                        , ''  ],
  ['crc32w{q}'         , 'Rd, Rn, Rm'                            , 'A32: Cond!=1111|00010|10|0|Rn:4|Rd:4|0|0|0|0|0100|Rm:4'                        , ''  ],

  ['crc32cb{q}'        , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|1|Rn:4|1111|Rd:4|10|00|Rm:4'                                 , ''  ],
  ['crc32ch{q}'        , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|1|Rn:4|1111|Rd:4|10|01|Rm:4'                                 , ''  ],
  ['crc32cw{q}'        , 'Rd, Rn, Rm'                            , 'T32: 111110101|10|1|Rn:4|1111|Rd:4|10|10|Rm:4'                                 , ''  ],
  ['crc32cb{q}'        , 'Rd, Rn, Rm'                            , 'A32: Cond!=1111|00010|00|0|Rn:4|Rd:4|0|0|1|0|0100|Rm:4'                        , ''  ],
  ['crc32ch{q}'        , 'Rd, Rn, Rm'                            , 'A32: Cond!=1111|00010|01|0|Rn:4|Rd:4|0|0|1|0|0100|Rm:4'                        , ''  ],
  ['crc32cw{q}'        , 'Rd, Rn, Rm'                            , 'A32: Cond!=1111|00010|10|0|Rn:4|Rd:4|0|0|1|0|0100|Rm:4'                        , ''  ],

  ['dbg{c}{q}'         , '#Option'                               , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|1111|Option:4'                          , ''  ],
  ['dbg{c}{q}'         , '#Option'                               , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|00001111|Option:4'                    , ''  ],

  ['dcps1'             , ''                                      , 'T32: 111101111000|1111|1000|0000000000|01'                                     , ''  ],
  ['dcps2'             , ''                                      , 'T32: 111101111000|1111|1000|0000000000|10'                                     , ''  ],
  ['dcps3'             , ''                                      , 'T32: 111101111000|1111|1000|0000000000|11'                                     , ''  ],

  ['dmb{c}{q}'         , '{Option}'                              , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0101|Option:4'                        , ''  ],
  ['dmb{c}{q}'         , '{Option}'                              , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0101|Option:4'                       , ''  ],

  ['dsb{c}{q}'         , '{Option}'                              , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0100|Option:4'                        , ''  ],
  ['dsb{c}{q}'         , '{Option}'                              , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0100|Option:4'                       , ''  ],

  ['eor{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0100|0|Rn:4|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['eors{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0100|1|Rn:4|0|ImmC:3|Rd!=1111|ImmC:8'                      , ''  ],
  ['eor{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|0010|001|0|Rn:4|Rd:4|ImmC:12'                                  , ''  ],
  ['eors{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|0010|001|1|Rn:4|Rd:4|ImmC:12'                                  , ''  ],

  ['eor%c{q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0001|Rm:3|Rdn:3'                                                   , 'IT:IN'  ],
  ['eors{q}'           , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0001|Rm:3|Rdn:3'                                                   , 'IT:OUT'  ],
  ['eor{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0100|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['eor%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0100|0|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:IN'  ],
  ['eor{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0100|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['eors{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0100|1|Rn:4|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['eors.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0100|1|Rn:4|0|!=000|Rd!=1111|!=00|!=11|Rm:4'                      , 'IT:OUT'  ],
  ['eors{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0100|1|Rn:4|0|Amount!=000|Rd!=1111|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['eor{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|001|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['eor{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|001|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['eors{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|001|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['eors{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|001|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['eors{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|001|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['eor{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|001|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['eret{c}{q}'        , ''                                      , 'T32: 111100111101|1110|10|0|0|1|1|1|1|00000000'                                , ''  ],
  ['eret{c}{q}'        , ''                                      , 'A32: Cond!=1111|00010110|0|0|0|0|0|0|0|0|0|0|0|0|0110|1|1|1|0'                 , ''  ],

  ['hlt{q}'            , '{#}Imm'                                , 'T16: 1011101010|Imm:6'                                                         , ''  ],
  ['hlt{q}'            , '{#}Imm'                                , 'A32: Cond!=1111|00010|00|0|Imm:12|0111|Imm:4'                                  , ''  ],

  ['hvc{q}'            , '{#}Imm'                                , 'T32: 11110111111|0|Imm:4|10|0|0|Imm:12'                                        , ''  ],
  ['hvc{q}'            , '{#}Imm'                                , 'A32: Cond!=1111|00010|10|0|Imm:12|0111|Imm:4'                                  , ''  ],

  ['isb{c}{q}'         , '{Option}'                              , 'T32: 111100111011|1|1|1|1|10|0|0|1|1|1|1|0110|Option:4'                        , ''  ],
  ['isb{c}{q}'         , '{Option}'                              , 'A32: 111101010111|1|1|1|1|1|1|1|1|0|0|0|0|0110|Option:4'                       , ''  ],

  ['it{<x>{<y>{<z>}}}{q}', 'Cond'                                  , 'T16: 10111111|Cond:4|Z!=0000'                                                  , ''  ],

  ['lda{c}{q}'         , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|0|10|1111'                                 , ''  ],
  ['lda{c}{q}'         , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|00|1|Rn:4|Rt:4|1|1|0|0|1001|1111'                        , ''  ],

  ['ldab{c}{q}'        , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|0|00|1111'                                 , ''  ],
  ['ldab{c}{q}'        , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|10|1|Rn:4|Rt:4|1|1|0|0|1001|1111'                        , ''  ],

  ['ldaex{c}{q}'       , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|1|10|1111'                                 , ''  ],
  ['ldaex{c}{q}'       , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|00|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  ['ldaexb{c}{q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|1|00|1111'                                 , ''  ],
  ['ldaexb{c}{q}'      , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|10|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  ['ldaexd{c}{q}'      , 'Rt, Rt2, [Rn]'                         , 'T32: 11101000110|1|Rn:4|Rt:4|Rt2:4|1|1|11|1111'                                , ''  ],
  ['ldaexd{c}{q}'      , 'Rt, Rt2=Rt+1, [Rn]'                    , 'A32: Cond!=1111|00011|01|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  ['ldaexh{c}{q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|1|01|1111'                                 , ''  ],
  ['ldaexh{c}{q}'      , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|11|1|Rn:4|Rt:4|1|1|1|0|1001|1111'                        , ''  ],

  ['ldah{c}{q}'        , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|1|0|01|1111'                                 , ''  ],
  ['ldah{c}{q}'        , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|11|1|Rn:4|Rt:4|1|1|0|0|1001|1111'                        , ''  ],

  ['ldc{c}{q}'         , 'p14, c5, [Rn,{#{+/-}ImmZ*4}]'          , 'T32: 111|0|110|1|U|0|0|1|Rn!=1111|0101|111|0|ImmZ:8'                           , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn], #{+/-}ImmZ*4'           , 'T32: 111|0|110|0|U|0|1|1|Rn!=1111|0101|111|0|ImmZ:8'                           , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn, #{+/-}ImmZ*4]!'          , 'T32: 111|0|110|1|U|0|1|1|Rn!=1111|0101|111|0|ImmZ:8'                           , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn], Option'                 , 'T32: 111|0|110|0|1|0|0|1|Rn!=1111|0101|111|0|Option:8'                         , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn,{#{+/-}ImmZ*4}]'          , 'A32: Cond!=1111|110|1|U|0|0|1|Rn!=1111|0101|111|0|ImmZ:8'                      , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn], #{+/-}ImmZ*4'           , 'A32: Cond!=1111|110|0|U|0|1|1|Rn!=1111|0101|111|0|ImmZ:8'                      , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn, #{+/-}ImmZ*4]!'          , 'A32: Cond!=1111|110|1|U|0|1|1|Rn!=1111|0101|111|0|ImmZ:8'                      , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [Rn], Option'                 , 'A32: Cond!=1111|110|0|1|0|0|1|Rn!=1111|0101|111|0|Option:8'                    , ''  ],

  ['ldc{c}{q}'         , 'p14, c5, RelZ*4'                       , 'T32: 111|0|110|1|1|0|1|1|1111|0101|111|0|RelZ:8'                               , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [PC, #{+/-}ImmZ*4]'           , 'T32: 111|0|110|1|U=1|0|1|1|1111|0101|111|0|ImmZ:8'                             , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, RelZ*4'                       , 'A32: Cond!=1111|110|1|1|0|1|1|1111|0101|111|0|RelZ:8'                          , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [PC, #{+/-}ImmZ*4]'           , 'A32: Cond!=1111|110|1|U=1|0|1|1|1111|0101|111|0|ImmZ:8'                        , ''  ],
  ['ldc{c}{q}'         , 'p14, c5, [PC], Option'                 , 'A32: Cond!=1111|110|1|1|0|1|1|1111|0101|111|0|Option:8'                        , ''  ],

  ['ldm{ia}{c}{q}'     , 'Rn{!}, List'                           , 'T16: 1100|1|Rn:3|List.I:8'                                                     , 'FORM='  ],
  ['ldmfd{c}{q}'       , 'Rn{!}, List'                           , 'T16: 1100|1|Rn:3|List.I:8'                                                     , 'FORM='  ],
  ['ldm{ia}{c}.w'      , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|1|Rn:4|List:1|List:1|0|List:13'                            , 'FORM='  ],
  ['ldmfd{c}.w'        , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|1|Rn:4|List:1|List:1|0|List:13'                            , 'FORM='  ],
  ['ldm{ia}{c}{q}'     , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|1|Rn:4|List:1|List:1|0|List:13'                            , 'FORM='  ],
  ['ldmfd{c}{q}'       , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|1|Rn:4|List:1|List:1|0|List:13'                            , 'FORM='  ],
  ['ldm{ia}{c}{q}'     , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|1|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],
  ['ldmfd{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|1|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],

  ['ldm{<amode>}{c}{q}', 'Rn{!}, List^'                          , 'A32: Cond!=1111|100|x|x|1|W|1|Rn:4|1|List:15'                                  , ''  ],

  ['ldm{<amode>}{c}{q}', 'Rn, List^'                             , 'A32: Cond!=1111|100|x|x|1|0|1|Rn:4|0|List:15'                                  , ''  ],

  ['ldmda{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|0|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],
  ['ldmfa{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|0|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],

  ['ldmdb{c}{q}'       , 'Rn{!}, List'                           , 'T32: 1110100|10|0|W|1|Rn:4|List:1|List:1|0|List:13'                            , 'FORM='  ],
  ['ldmea{c}{q}'       , 'Rn{!}, List'                           , 'T32: 1110100|10|0|W|1|Rn:4|List:1|List:1|0|List:13'                            , 'FORM='  ],
  ['ldmdb{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|0|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],
  ['ldmea{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|0|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],

  ['ldmib{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|1|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],
  ['ldmed{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|1|0|W|1|Rn:4|List:16'                                    , 'FORM='  ],

  ['ldr{c}{q}'         , 'Rt, [Rn ,{#{+}ImmZ*4}]'                , 'T16: 011|0|1|ImmZ:5|Rn:3|Rt:3'                                                 , ''  ],
  ['ldr{c}{q}'         , 'Rt, [SP,{#{+}ImmZ*4}]'                 , 'T16: 1001|1|Rt:3|ImmZ:8'                                                       , ''  ],
  ['ldr{c}.w'          , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|10|1|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|10|1|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1|1|0|0|ImmZ:8'                            , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|010|1|U|0|0|1|Rn!=1111|Rt:4|ImmZ:12'                           , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|010|0|U|0|0|1|Rn!=1111|Rt:4|ImmZ:12'                           , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|010|1|U|0|1|1|Rn!=1111|Rt:4|ImmZ:12'                           , ''  ],

  ['ldr{c}{q}'         , 'Rt, RelZ*4'                            , 'T16: 01001|Rt:3|RelZ:8'                                                        , ''  ],
  ['ldr{c}.w'          , 'Rt, RelZ'                              , 'T32: 1111100|0|x|10|1|1111|Rt:4|RelZ:12'                                       , 'FORM='  ],
  ['ldr{c}{q}'         , 'Rt, RelZ'                              , 'T32: 1111100|0|x|10|1|1111|Rt:4|RelZ:12'                                       , 'FORM='  ],
  ['ldr{c}{q}'         , 'Rt, [PC, #{+/-}ImmZ]'                  , 'T32: 1111100|0|U|10|1|1111|Rt:4|ImmZ:12'                                       , 'FORM='  ],
  ['ldr{c}{q}'         , 'Rt, RelZ'                              , 'A32: Cond!=1111|010|1|x|0|x|1|1111|Rt:4|RelZ:12'                               , ''  ],
  ['ldr{c}{q}'         , 'Rt, [PC, #{+/-}ImmZ]'                  , 'A32: Cond!=1111|010|1|U|0|x|1|1111|Rt:4|ImmZ:12'                               , 'FORM='  ],

  ['ldr{c}{q}'         , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|0|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldr{c}.w'          , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|000000|xx|Rm:4'                            , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|000000|Imm:2|Rm:4'                         , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn, {+/-}Rm,{Shift}]'             , 'A32: Cond!=1111|011|1|U|0|0|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|0|0|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['ldr{c}{q}'         , 'Rt, [Rn, {+/-}Rm,{Shift}]!'            , 'A32: Cond!=1111|011|1|U|0|1|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['ldrb{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T16: 011|1|1|ImmZ:5|Rn:3|Rt:3'                                                 , ''  ],
  ['ldrb{c}.w'         , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|00|1|Rn!=1111|Rt!=1111|ImmZ:12'                               , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|00|1|Rn!=1111|Rt!=1111|ImmZ:12'                               , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt!=1111|1|1|0|0|ImmZ:8'                        , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|010|1|U|1|0|1|Rn!=1111|Rt:4|ImmZ:12'                           , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|010|0|U|1|0|1|Rn!=1111|Rt:4|ImmZ:12'                           , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|010|1|U|1|1|1|Rn!=1111|Rt:4|ImmZ:12'                           , ''  ],

  ['ldrb{c}{q}'        , 'Rt, RelZ'                              , 'T32: 1111100|0|x|00|1|1111|Rt!=1111|RelZ:12'                                   , 'FORM='  ],
  ['ldrb{c}{q}'        , 'Rt, [PC, #{+/-}ImmZ]'                  , 'T32: 1111100|0|U|00|1|1111|Rt!=1111|ImmZ:12'                                   , 'FORM='  ],
  ['ldrb{c}{q}'        , 'Rt, RelZ'                              , 'A32: Cond!=1111|010|1|x|1|x|1|1111|Rt:4|RelZ:12'                               , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [PC, #{+/-}ImmZ]'                  , 'A32: Cond!=1111|010|1|U|1|x|1|1111|Rt:4|ImmZ:12'                               , 'FORM='  ],

  ['ldrb{c}{q}'        , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|1|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrb{c}.w'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt!=1111|000000|xx|Rm:4'                        , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt!=1111|000000|Imm:2|Rm:4'                     , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn, {+/-}Rm,{Shift}]'             , 'A32: Cond!=1111|011|1|U|1|0|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|1|0|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['ldrb{c}{q}'        , 'Rt, [Rn, {+/-}Rm,{Shift}]!'            , 'A32: Cond!=1111|011|1|U|1|1|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['ldrbt{c}{q}'       , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|0|00|1|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['ldrbt{c}{q}'       , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|010|0|U|1|1|1|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['ldrbt{c}{q}'       , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|1|1|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['ldrd{c}{q}'        , 'Rt, Rt2, [Rn ,{#{+/-}ImmZ*4}]'         , 'T32: 1110100|1|U|1|0|1|Rn!=1111|Rt:4|Rt2:4|ImmZ:8'                             , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2, [Rn], #{+/-}ImmZ*4'           , 'T32: 1110100|0|U|1|1|1|Rn!=1111|Rt:4|Rt2:4|ImmZ:8'                             , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2, [Rn, #{+/-}ImmZ*4]!'          , 'T32: 1110100|1|U|1|1|1|Rn!=1111|Rt:4|Rt2:4|ImmZ:8'                             , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn ,{#{+/-}ImmZ}]'      , 'A32: Cond!=1111|000|1|U|1|0|0|Rn!=1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'              , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn], #{+/-}ImmZ'        , 'A32: Cond!=1111|000|0|U|1|0|0|Rn!=1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'              , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn, #{+/-}ImmZ]!'       , 'A32: Cond!=1111|000|1|U|1|1|0|Rn!=1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'              , ''  ],

  ['ldrd{c}{q}'        , 'Rt, Rt2, RelZ*4'                       , 'T32: 1110100|1|x|1|1|1|1111|Rt:4|Rt2:4|RelZ:8'                                 , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2, [PC, #{+/-}ImmZ*4]'           , 'T32: 1110100|1|U|1|1|1|1111|Rt:4|Rt2:4|ImmZ:8'                                 , 'FORM='  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, RelZ'                    , 'A32: Cond!=1111|000|1|x|1|0|0|1111|Rt:4|RelZ:4|1|10|1|RelZ:4'                  , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [PC, #{+/-}ImmZ]'        , 'A32: Cond!=1111|000|1|U|1|0|0|1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'                  , 'FORM='  ],

  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn, {+/-}Rm]'           , 'A32: Cond!=1111|000|1|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn], {+/-}Rm'           , 'A32: Cond!=1111|000|0|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn, {+/-}Rm]!'          , 'A32: Cond!=1111|000|1|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],

  ['ldrex{c}{q}'       , 'Rt, [Rn ,{#ImmZ*4}]'                   , 'T32: 11101000010|1|Rn:4|Rt:4|1111|ImmZ:8'                                      , ''  ],
  ['ldrex{c}{q}'       , 'Rt, [Rn ,{{#}0}]'                      , 'A32: Cond!=1111|00011|00|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  ['ldrexb{c}{q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|01|00|1111'                                  , ''  ],
  ['ldrexb{c}{q}'      , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|10|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  ['ldrexd{c}{q}'      , 'Rt, Rt2, [Rn]'                         , 'T32: 11101000110|1|Rn:4|Rt:4|Rt2:4|01|11|1111'                                 , ''  ],
  ['ldrexd{c}{q}'      , 'Rt, Rt2=Rt+1, [Rn]'                    , 'A32: Cond!=1111|00011|01|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  ['ldrexh{c}{q}'      , 'Rt, [Rn]'                              , 'T32: 11101000110|1|Rn:4|Rt:4|1111|01|01|1111'                                  , ''  ],
  ['ldrexh{c}{q}'      , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|11|1|Rn:4|Rt:4|1|1|1|1|1001|1111'                        , ''  ],

  ['ldrh{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ*2}]'                , 'T16: 1000|1|ImmZ:5|Rn:3|Rt:3'                                                  , ''  ],
  ['ldrh{c}.w'         , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|01|1|Rn!=1111|Rt!=1111|ImmZ:12'                               , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|01|1|Rn!=1111|Rt!=1111|ImmZ:12'                               , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt!=1111|1|1|0|0|ImmZ:8'                        , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|000|1|U|1|0|1|Rn!=1111|Rt:4|ImmZ:4|1|01|1|ImmZ:4'              , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|000|0|U|1|0|1|Rn!=1111|Rt:4|ImmZ:4|1|01|1|ImmZ:4'              , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|000|1|U|1|1|1|Rn!=1111|Rt:4|ImmZ:4|1|01|1|ImmZ:4'              , ''  ],

  ['ldrh{c}{q}'        , 'Rt, RelZ'                              , 'T32: 1111100|0|x|01|1|1111|Rt!=1111|RelZ:12'                                   , 'FORM='  ],
  ['ldrh{c}{q}'        , 'Rt, [PC, #{+/-}ImmZ]'                  , 'T32: 1111100|0|U|01|1|1111|Rt!=1111|ImmZ:12'                                   , 'FORM='  ],
  ['ldrh{c}{q}'        , 'Rt, RelZ'                              , 'A32: Cond!=1111|000|1|x|1|x|1|1111|Rt:4|RelZ:4|1|01|1|RelZ:4'                  , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [PC, #{+/-}ImmZ]'                  , 'A32: Cond!=1111|000|1|U|1|x|1|1111|Rt:4|ImmZ:4|1|01|1|ImmZ:4'                  , 'FORM='  ],

  ['ldrh{c}{q}'        , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|0|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrh{c}.w'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt!=1111|000000|xx|Rm:4'                        , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt!=1111|000000|Imm:2|Rm:4'                     , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: Cond!=1111|000|1|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['ldrh{c}{q}'        , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: Cond!=1111|000|1|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  ['ldrht{c}{q}'       , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|0|01|1|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['ldrht{c}{q}'       , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|000|0|U|1|1|1|Rn:4|Rt:4|ImmZ:4|1|01|1|ImmZ:4'                  , ''  ],
  ['ldrht{c}{q}'       , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  ['ldrsb{c}{q}'       , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|1|1|00|1|Rn!=1111|Rt!=1111|ImmZ:12'                               , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1|1|0|0|ImmZ:8'                            , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|000|1|U|1|0|1|Rn!=1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'              , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|000|0|U|1|0|1|Rn!=1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'              , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|000|1|U|1|1|1|Rn!=1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'              , ''  ],

  ['ldrsb{c}{q}'       , 'Rt, RelZ'                              , 'T32: 1111100|1|x|00|1|1111|Rt!=1111|RelZ:12'                                   , 'FORM='  ],
  ['ldrsb{c}{q}'       , 'Rt, [PC, #{+/-}ImmZ]'                  , 'T32: 1111100|1|U|00|1|1111|Rt!=1111|ImmZ:12'                                   , 'FORM='  ],
  ['ldrsb{c}{q}'       , 'Rt, RelZ'                              , 'A32: Cond!=1111|000|1|x|1|x|1|1111|Rt:4|RelZ:4|1|10|1|RelZ:4'                  , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [PC, #{+/-}ImmZ]'                  , 'A32: Cond!=1111|000|1|U|1|x|1|1111|Rt:4|ImmZ:4|1|10|1|ImmZ:4'                  , 'FORM='  ],

  ['ldrsb{c}{q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|1|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrsb{c}.w'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt!=1111|000000|xx|Rm:4'                        , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt!=1111|000000|Imm:2|Rm:4'                     , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: Cond!=1111|000|1|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],
  ['ldrsb{c}{q}'       , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: Cond!=1111|000|1|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],

  ['ldrsbt{c}{q}'      , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|1|0|00|1|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['ldrsbt{c}{q}'      , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|000|0|U|1|1|1|Rn:4|Rt:4|ImmZ:4|1|10|1|ImmZ:4'                  , ''  ],
  ['ldrsbt{c}{q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|10|1|Rm:4'                   , ''  ],

  ['ldrsh{c}{q}'       , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|1|1|01|1|Rn!=1111|Rt!=1111|ImmZ:12'                               , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt!=1111|1|1|0|0|ImmZ:8'                        , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|000|1|U|1|0|1|Rn!=1111|Rt:4|ImmZ:4|1|11|1|ImmZ:4'              , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|000|0|U|1|0|1|Rn!=1111|Rt:4|ImmZ:4|1|11|1|ImmZ:4'              , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|000|1|U|1|1|1|Rn!=1111|Rt:4|ImmZ:4|1|11|1|ImmZ:4'              , ''  ],

  ['ldrsh{c}{q}'       , 'Rt, RelZ'                              , 'T32: 1111100|1|x|01|1|1111|Rt!=1111|RelZ:12'                                   , 'FORM='  ],
  ['ldrsh{c}{q}'       , 'Rt, [PC, #{+/-}ImmZ]'                  , 'T32: 1111100|1|U|01|1|1111|Rt!=1111|ImmZ:12'                                   , 'FORM='  ],
  ['ldrsh{c}{q}'       , 'Rt, RelZ'                              , 'A32: Cond!=1111|000|1|x|1|x|1|1111|Rt:4|RelZ:4|1|11|1|RelZ:4'                  , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [PC, #{+/-}ImmZ]'                  , 'A32: Cond!=1111|000|1|U|1|x|1|1111|Rt:4|ImmZ:4|1|11|1|ImmZ:4'                  , 'FORM='  ],

  ['ldrsh{c}{q}'       , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|1|1|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['ldrsh{c}.w'        , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt!=1111|000000|xx|Rm:4'                        , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt!=1111|000000|Imm:2|Rm:4'                     , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: Cond!=1111|000|1|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|0|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['ldrsh{c}{q}'       , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: Cond!=1111|000|1|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],

  ['ldrsht{c}{q}'      , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|1|0|01|1|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['ldrsht{c}{q}'      , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|000|0|U|1|1|1|Rn:4|Rt:4|ImmZ:4|1|11|1|ImmZ:4'                  , ''  ],
  ['ldrsht{c}{q}'      , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|1|1|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],

  ['ldrt{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|0|10|1|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['ldrt{c}{q}'        , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|010|0|U|0|1|1|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['ldrt{c}{q}'        , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|0|1|1|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['lsl%c{q}'          , '{Rd}, Rm, #Imm'                        , 'T16: 000|00|Imm!=00000|Rm:3|Rd:3'                                              , 'IT:IN'  ],
  ['lsl%c.w'           , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm:3|Rd:4|Imm:2|00|Rm:4'                           , 'IT:IN'  ],
  ['lsl{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm:3|Rd:4|Imm:2|00|Rm:4'                           , ''  ],
  ['lsl{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Imm!=00000|00|0|Rm:4'                     , ''  ],

  ['lsl%c{q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['lsl%c.w'           , '{Rd}, Rm, Rs'                          , 'T32: 111110100|00|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['lsl{c}{q}'         , '{Rd}, Rm, Rs'                          , 'T32: 111110100|00|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsl{c}{q}'         , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|00|1|Rm:4'                         , ''  ],

  ['lsls{q}'           , '{Rd}, Rm, #Imm'                        , 'T16: 000|00|Imm!=00000|Rm:3|Rd:3'                                              , 'IT:OUT'  ],
  ['lsls.w'            , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm:3|Rd:4|Imm:2|00|Rm:4'                           , 'IT:OUT'  ],
  ['lsls{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm:3|Rd:4|Imm:2|00|Rm:4'                           , ''  ],
  ['lsls{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Imm!=00000|00|0|Rm:4'                     , ''  ],

  ['lsls{q}'           , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['lsls.w'            , '{Rd}, Rm, Rs'                          , 'T32: 111110100|00|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['lsls{c}{q}'        , '{Rd}, Rm, Rs'                          , 'T32: 111110100|00|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsls{c}{q}'        , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|00|1|Rm:4'                         , ''  ],

  ['lsr%c{q}'          , '{Rd}, Rm, #Imm'                        , 'T16: 000|01|Imm:5|Rm:3|Rd:3'                                                   , 'IT:IN'  ],
  ['lsr%c.w'           , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm:3|Rd:4|Imm:2|01|Rm:4'                           , 'IT:IN'  ],
  ['lsr{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm:3|Rd:4|Imm:2|01|Rm:4'                           , ''  ],
  ['lsr{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Imm:5|01|0|Rm:4'                          , ''  ],

  ['lsr%c{q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['lsr%c.w'           , '{Rd}, Rm, Rs'                          , 'T32: 111110100|01|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['lsr{c}{q}'         , '{Rd}, Rm, Rs'                          , 'T32: 111110100|01|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsr{c}{q}'         , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|01|1|Rm:4'                         , ''  ],

  ['lsrs{q}'           , '{Rd}, Rm, #Imm'                        , 'T16: 000|01|Imm:5|Rm:3|Rd:3'                                                   , 'IT:OUT'  ],
  ['lsrs.w'            , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm:3|Rd:4|Imm:2|01|Rm:4'                           , 'IT:OUT'  ],
  ['lsrs{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm:3|Rd:4|Imm:2|01|Rm:4'                           , ''  ],
  ['lsrs{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Imm:5|01|0|Rm:4'                          , ''  ],

  ['lsrs{q}'           , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['lsrs.w'            , '{Rd}, Rm, Rs'                          , 'T32: 111110100|01|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['lsrs{c}{q}'        , '{Rd}, Rm, Rs'                          , 'T32: 111110100|01|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['lsrs{c}{q}'        , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|01|1|Rm:4'                         , ''  ],

  ['mcr{c}{q}'         , 'Coproc, {#}Opc1, Rt, CRn, CRm, {{#}Opc2}', 'T32: 111|0|1110|Opc10|0|CRn0|Rt:4|111|Opc20|1|CRm0'                            , ''  ],
  ['mcr{c}{q}'         , 'Coproc, {#}Opc1, Rt, CRn, CRm, {{#}Opc2}', 'A32: Cond!=1111|1110|Opc10|0|CRn0|Rt:4|111|Opc20|1|CRm0'                       , ''  ],

  ['mcrr{c}{q}'        , 'Coproc, {#}Opc1, Rt, Rt2, CRm'         , 'T32: 111|0|11000|1|0|0|Rt2:4|Rt:4|111|Opc10|CRm0'                              , ''  ],
  ['mcrr{c}{q}'        , 'Coproc, {#}Opc1, Rt, Rt2, CRm'         , 'A32: Cond!=1111|11000|1|0|0|Rt2:4|Rt:4|111|Opc10|CRm0'                         , ''  ],

  ['mla{c}{q}'         , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|000|Rn:4|Ra!=1111|Rd:4|00|00|Rm:4'                              , ''  ],
  ['mlas{c}{q}'        , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|0000|001|1|Rd:4|Ra:4|Rm:4|1001|Rn:4'                           , ''  ],
  ['mla{c}{q}'         , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|0000|001|0|Rd:4|Ra:4|Rm:4|1001|Rn:4'                           , ''  ],

  ['mls{c}{q}'         , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|000|Rn:4|Ra:4|Rd:4|00|01|Rm:4'                                  , ''  ],
  ['mls{c}{q}'         , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|0000|011|0|Rd:4|Ra:4|Rm:4|1001|Rn:4'                           , ''  ],

  ['mov%c{q}'          , 'Rd, #ImmZ'                             , 'T16: 001|00|Rd:3|ImmZ:8'                                                       , 'IT:IN'  ],
  ['movs{q}'           , 'Rd, #ImmZ'                             , 'T16: 001|00|Rd:3|ImmZ:8'                                                       , 'IT:OUT'  ],
  ['mov%c.w'           , 'Rd, #ImmC'                             , 'T32: 11110|ImmC:1|0|0010|0|1111|0|ImmC:3|Rd:4|ImmC:8'                          , 'IT:IN'  ],
  ['mov{c}{q}'         , 'Rd, #ImmC'                             , 'T32: 11110|ImmC:1|0|0010|0|1111|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['movs.w'            , 'Rd, #ImmC'                             , 'T32: 11110|ImmC:1|0|0010|1|1111|0|ImmC:3|Rd:4|ImmC:8'                          , 'IT:OUT'  ],
  ['movs{c}{q}'        , 'Rd, #ImmC'                             , 'T32: 11110|ImmC:1|0|0010|1|1111|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['mov{c}{q}'         , 'Rd, #ImmZ'                             , 'T32: 11110|ImmZ.B:1|10|0|100|ImmZ.A:4|0|ImmZ.C:3|Rd:4|ImmZ.D:8'                , ''  ],
  ['movw{c}{q}'        , 'Rd, #ImmZ'                             , 'T32: 11110|ImmZ.B:1|10|0|100|ImmZ.A:4|0|ImmZ.C:3|Rd:4|ImmZ.D:8'                , ''  ],
  ['mov{c}{q}'         , 'Rd, #ImmC'                             , 'A32: Cond!=1111|00111|01|0|0000|Rd:4|ImmC:12'                                  , ''  ],
  ['movs{c}{q}'        , 'Rd, #ImmC'                             , 'A32: Cond!=1111|00111|01|1|0000|Rd:4|ImmC:12'                                  , ''  ],
  ['mov{c}{q}'         , 'Rd, #ImmZ'                             , 'A32: Cond!=1111|00110|0|00|ImmZ:4|Rd:4|ImmZ:12'                                , ''  ],
  ['movw{c}{q}'        , 'Rd, #ImmZ'                             , 'A32: Cond!=1111|00110|0|00|ImmZ:4|Rd:4|ImmZ:12'                                , ''  ],

  ['mov{c}{q}'         , 'Rd, Rm'                                , 'T16: 010001|10|Rd:1|Rm:3|Rd:4'                                                 , ''  ],
  ['mov%c{q}'          , 'Rd, Rm, {Shift #Amount}'               , 'T16: 000|Shift!=11|Amount:5|Rm:3|Rd:3'                                         , 'IT:IN'  ],
  ['movs{q}'           , 'Rd, Rm, {Shift #Amount}'               , 'T16: 000|Shift!=11|Amount:5|Rm:3|Rd:3'                                         , 'IT:OUT'  ],
  ['mov{c}{q}'         , 'Rd, Rm, RRX'                           , 'T32: 1110101|0010|0|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['mov{c}.w'          , 'Rd, Rm, {LSL #0}'                      , 'T32: 1110101|0010|0|1111|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , ''  ],
  ['mov%c.w'           , 'Rd, Rm, {Shift #Amount}'               , 'T32: 1110101|0010|0|1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , 'IT:IN'  ],
  ['mov{c}{q}'         , 'Rd, Rm, {Shift #Amount}'               , 'T32: 1110101|0010|0|1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['movs{c}{q}'        , 'Rd, Rm, RRX'                           , 'T32: 1110101|0010|1|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['movs.w'            , 'Rd, Rm, {Shift #Amount}'               , 'T32: 1110101|0010|1|1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , 'IT:OUT'  ],
  ['movs{c}{q}'        , 'Rd, Rm, {Shift #Amount}'               , 'T32: 1110101|0010|1|1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['mov{c}{q}'         , 'Rd, Rm, RRX'                           , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['mov{c}{q}'         , 'Rd, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['movs{c}{q}'        , 'Rd, Rm, RRX'                           , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['movs{c}{q}'        , 'Rd, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['mov%c{q}'          , 'Rdm, Rdm, ASR Rs'                      , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['movs{q}'           , 'Rdm, Rdm, ASR Rs'                      , 'T16: 010000|0100|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['mov%c{q}'          , 'Rdm, Rdm, LSL Rs'                      , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['movs{q}'           , 'Rdm, Rdm, LSL Rs'                      , 'T16: 010000|0010|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['mov%c{q}'          , 'Rdm, Rdm, LSR Rs'                      , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['movs{q}'           , 'Rdm, Rdm, LSR Rs'                      , 'T16: 010000|0011|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['mov%c{q}'          , 'Rdm, Rdm, ROR Rs'                      , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['movs{q}'           , 'Rdm, Rdm, ROR Rs'                      , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['movs.w'            , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                              , 'IT:OUT'  ],
  ['movs{c}{q}'        , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|1|Rm:4|1111|Rd:4|0000|Rs:4'                              , ''  ],
  ['mov%c.w'           , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                              , 'IT:IN'  ],
  ['mov{c}{q}'         , 'Rd, Rm, type Rs'                       , 'T32: 111110100|type:2|0|Rm:4|1111|Rd:4|0000|Rs:4'                              , ''  ],
  ['movs{c}{q}'        , 'Rd, Rm, type Rs'                       , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['mov{c}{q}'         , 'Rd, Rm, type Rs'                       , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['movt{c}{q}'        , 'Rd, #Imm'                              , 'T32: 11110|Imm.B:1|10|1|100|Imm.A:4|0|Imm.C:3|Rd:4|Imm.D:8'                    , ''  ],
  ['movt{c}{q}'        , 'Rd, #Imm'                              , 'A32: Cond!=1111|00110|1|00|Imm:4|Rd:4|Imm:12'                                  , ''  ],

  ['mrc{c}{q}'         , 'Coproc, {#}Opc1, Rt, CRn, CRm, {{#}Opc2}', 'T32: 111|0|1110|Opc10|1|CRn0|Rt:4|111|Opc20|1|CRm0'                            , ''  ],
  ['mrc{c}{q}'         , 'Coproc, {#}Opc1, Rt, CRn, CRm, {{#}Opc2}', 'A32: Cond!=1111|1110|Opc10|1|CRn0|Rt:4|111|Opc20|1|CRm0'                       , ''  ],

  ['mrrc{c}{q}'        , 'Coproc, {#}Opc1, Rt, Rt2, CRm'         , 'T32: 111|0|11000|1|0|1|Rt2:4|Rt:4|111|Opc10|CRm0'                              , ''  ],
  ['mrrc{c}{q}'        , 'Coproc, {#}Opc1, Rt, Rt2, CRm'         , 'A32: Cond!=1111|11000|1|0|1|Rt2:4|Rt:4|111|Opc10|CRm0'                         , ''  ],

  ['mrs{c}{q}'         , 'Rd, Spec_reg'                          , 'T32: 11110011111|Spec_reg:1|1|1|1|1|10|0|0|Rd:4|0|0|0|0|0|0|0|0'               , ''  ],
  ['mrs{c}{q}'         , 'Rd, Spec_reg'                          , 'A32: Cond!=1111|00010|Spec_reg:1|0|0|1111|Rd:4|0|0|0|0|0000|0000'              , ''  ],

  ['mrs{c}{q}'         , 'Rd, Banked_reg'                        , 'T32: 11110011111|Banked_reg.A:1|Banked_reg.C:4|10|0|0|Rd:4|0|0|1|Banked_reg.B:1|0|0|0|0', ''  ],
  ['mrs{c}{q}'         , 'Rd, Banked_reg'                        , 'A32: Cond!=1111|00010|Banked_reg.A:1|0|0|Banked_reg.C:4|Rd:4|0|0|1|Banked_reg.B:1|0000|0000', ''  ],

  ['msr{c}{q}'         , 'Banked_reg, Rn'                        , 'T32: 11110011100|Banked_reg.A:1|Rn:4|10|0|0|Banked_reg.C:4|0|0|1|Banked_reg.B:1|0|0|0|0', ''  ],
  ['msr{c}{q}'         , 'Banked_reg, Rn'                        , 'A32: Cond!=1111|00010|Banked_reg.A:1|1|0|Banked_reg.C:4|1111|0|0|1|Banked_reg.B:1|0000|Rn:4', ''  ],

  ['msr{c}{q}'         , 'Spec_reg, #ImmX'                       , 'A32: Cond!=1111|00110|1|10|!=0000|1|1|1|1|ImmX:12'                             , ''  ],

  ['msr{c}{q}'         , 'Spec_reg, Rn'                          , 'T32: 11110011100|x|Rn:4|10|0|0|xxxx|0|0|0|0|0|0|0|0'                           , ''  ],
  ['msr{c}{q}'         , 'Spec_reg, Rn'                          , 'A32: Cond!=1111|00010|x|1|0|xxxx|1111|0|0|0|0|0000|Rn:4'                       , ''  ],

  ['mul%c{q}'          , 'Rdm, Rn, {Rdm}'                        , 'T16: 010000|1101|Rn:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['muls{q}'           , 'Rdm, Rn, {Rdm}'                        , 'T16: 010000|1101|Rn:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['mul%c.w'           , 'Rd, Rn, {Rm}'                          , 'T32: 111110110|000|Rn:4|1111|Rd:4|00|00|Rm:4'                                  , 'IT:IN'  ],
  ['mul{c}{q}'         , 'Rd, Rn, {Rm}'                          , 'T32: 111110110|000|Rn:4|1111|Rd:4|00|00|Rm:4'                                  , ''  ],
  ['muls{c}{q}'        , 'Rd, Rn, {Rm}'                          , 'A32: Cond!=1111|0000|000|1|Rd:4|0000|Rm:4|1001|Rn:4'                           , ''  ],
  ['mul{c}{q}'         , 'Rd, Rn, {Rm}'                          , 'A32: Cond!=1111|0000|000|0|Rd:4|0000|Rm:4|1001|Rn:4'                           , ''  ],

  ['mvn{c}{q}'         , 'Rd, #ImmC'                             , 'T32: 11110|ImmC:1|0|0011|0|1111|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['mvns{c}{q}'        , 'Rd, #ImmC'                             , 'T32: 11110|ImmC:1|0|0011|1|1111|0|ImmC:3|Rd:4|ImmC:8'                          , ''  ],
  ['mvn{c}{q}'         , 'Rd, #ImmC'                             , 'A32: Cond!=1111|00111|11|0|0000|Rd:4|ImmC:12'                                  , ''  ],
  ['mvns{c}{q}'        , 'Rd, #ImmC'                             , 'A32: Cond!=1111|00111|11|1|0000|Rd:4|ImmC:12'                                  , ''  ],

  ['mvn%c{q}'          , 'Rd, Rm'                                , 'T16: 010000|1111|Rm:3|Rd:3'                                                    , 'IT:IN'  ],
  ['mvns{q}'           , 'Rd, Rm'                                , 'T16: 010000|1111|Rm:3|Rd:3'                                                    , 'IT:OUT'  ],
  ['mvn{c}{q}'         , 'Rd, Rm, RRX'                           , 'T32: 1110101|0011|0|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['mvn%c.w'           , 'Rd, Rm'                                , 'T32: 1110101|0011|0|1111|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:IN'  ],
  ['mvn{c}{q}'         , 'Rd, Rm, {Shift #Amount}'               , 'T32: 1110101|0011|0|1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['mvns{c}{q}'        , 'Rd, Rm, RRX'                           , 'T32: 1110101|0011|1|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['mvns.w'            , 'Rd, Rm'                                , 'T32: 1110101|0011|1|1111|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:OUT'  ],
  ['mvns{c}{q}'        , 'Rd, Rm, {Shift #Amount}'               , 'T32: 1110101|0011|1|1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['mvn{c}{q}'         , 'Rd, Rm, RRX'                           , 'A32: Cond!=1111|00011|11|0|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['mvn{c}{q}'         , 'Rd, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00011|11|0|0000|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['mvns{c}{q}'        , 'Rd, Rm, RRX'                           , 'A32: Cond!=1111|00011|11|1|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['mvns{c}{q}'        , 'Rd, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00011|11|1|0000|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['mvns{c}{q}'        , 'Rd, Rm, type Rs'                       , 'A32: Cond!=1111|00011|11|1|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['mvn{c}{q}'         , 'Rd, Rm, type Rs'                       , 'A32: Cond!=1111|00011|11|0|0000|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['nop{c}{q}'         , ''                                      , 'T16: 10111111|0000|0000'                                                       , ''  ],
  ['nop{c}.w'          , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0000'                              , ''  ],
  ['nop{c}{q}'         , ''                                      , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|000000000000'                         , ''  ],

  ['orns{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0011|1|Rn!=1111|0|ImmC:3|Rd:4|ImmC:8'                      , ''  ],
  ['orn{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0011|0|Rn!=1111|0|ImmC:3|Rd:4|ImmC:8'                      , ''  ],

  ['orn{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0011|0|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orn{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0011|0|Rn!=1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['orns{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0011|1|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orns{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0011|1|Rn!=1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'     , ''  ],

  ['orr{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0010|0|Rn!=1111|0|ImmC:3|Rd:4|ImmC:8'                      , ''  ],
  ['orrs{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'T32: 11110|ImmC:1|0|0010|1|Rn!=1111|0|ImmC:3|Rd:4|ImmC:8'                      , ''  ],
  ['orr{c}{q}'         , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|00111|00|0|Rn:4|Rd:4|ImmC:12'                                  , ''  ],
  ['orrs{c}{q}'        , '{Rd}, Rn, #ImmC'                       , 'A32: Cond!=1111|00111|00|1|Rn:4|Rd:4|ImmC:12'                                  , ''  ],

  ['orr%c{q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|1100|Rm:3|Rdn:3'                                                   , 'IT:IN'  ],
  ['orrs{q}'           , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|1100|Rm:3|Rdn:3'                                                   , 'IT:OUT'  ],
  ['orr{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0010|0|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orr%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0010|0|Rn!=1111|0|!=000|Rd:4|!=00|!=11|Rm:4'                      , 'IT:IN'  ],
  ['orr{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0010|0|Rn!=1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['orrs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|0010|1|Rn!=1111|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['orrs.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|0010|1|Rn!=1111|0|!=000|Rd:4|!=00|!=11|Rm:4'                      , 'IT:OUT'  ],
  ['orrs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|0010|1|Rn!=1111|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['orr{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|00011|00|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['orr{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|00011|00|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['orrs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|00011|00|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['orrs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|00011|00|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['orrs{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|00011|00|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['orr{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|00011|00|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['pkhbt{c}{q}'       , '{Rd}, Rn, Rm, {LSL #Imm}'              , 'T32: 1110101|0110|0|Rn:4|0|Imm:3|Rd:4|xx|0|0|Rm:4'                             , ''  ],
  ['pkhtb{c}{q}'       , '{Rd}, Rn, Rm, {ASR #Imm}'              , 'T32: 1110101|0110|0|Rn:4|0|Imm:3|Rd:4|xx|1|0|Rm:4'                             , ''  ],
  ['pkhbt{c}{q}'       , '{Rd}, Rn, Rm, {LSL #Imm}'              , 'A32: Cond!=1111|01101000|Rn:4|Rd:4|Imm:5|0|01|Rm:4'                            , ''  ],
  ['pkhtb{c}{q}'       , '{Rd}, Rn, Rm, {ASR #Imm}'              , 'A32: Cond!=1111|01101000|Rn:4|Rd:4|Imm:5|1|01|Rm:4'                            , ''  ],

  ['pld{c}{q}'         , '[Rn ,{#{+}ImmZ}]'                      , 'T32: 1111100|0|1|0|0|1|Rn!=1111|1111|ImmZ:12'                                  , ''  ],
  ['pldw{c}{q}'        , '[Rn ,{#{+}ImmZ}]'                      , 'T32: 1111100|0|1|0|1|1|Rn!=1111|1111|ImmZ:12'                                  , ''  ],
  ['pld{c}{q}'         , '[Rn ,{#-ImmZ}]'                        , 'T32: 1111100|0|0|0|0|1|Rn!=1111|1111|1100|ImmZ:8'                              , ''  ],
  ['pldw{c}{q}'        , '[Rn ,{#-ImmZ}]'                        , 'T32: 1111100|0|0|0|1|1|Rn!=1111|1111|1100|ImmZ:8'                              , ''  ],
  ['pld{c}{q}'         , '[Rn ,{#{+/-}ImmZ}]'                    , 'A32: 1111010|1|U|1|01|Rn!=1111|1|1|1|1|ImmZ:12'                                , ''  ],
  ['pldw{c}{q}'        , '[Rn ,{#{+/-}ImmZ}]'                    , 'A32: 1111010|1|U|0|01|Rn!=1111|1|1|1|1|ImmZ:12'                                , ''  ],

  ['pld{c}{q}'         , 'RelZ'                                  , 'T32: 1111100|0|x|0|0|1|1111|1111|RelZ:12'                                      , 'FORM='  ],
  ['pld{c}{q}'         , '[PC, #{+/-}ImmZ]'                      , 'T32: 1111100|0|U|0|0|1|1111|1111|ImmZ:12'                                      , 'FORM='  ],
  ['pld{c}{q}'         , 'RelZ'                                  , 'A32: 1111010|1|x|1|01|1111|1|1|1|1|RelZ:12'                                    , ''  ],
  ['pld{c}{q}'         , '[PC, #{+/-}ImmZ]'                      , 'A32: 1111010|1|U|1|01|1111|1|1|1|1|ImmZ:12'                                    , 'FORM='  ],

  ['pld{c}{q}'         , '[Rn, {+}Rm ,{LSL #Amount}]'            , 'T32: 1111100|0|0|0|0|1|Rn!=1111|1111|000000|Amount:2|Rm:4'                     , ''  ],
  ['pldw{c}{q}'        , '[Rn, {+}Rm ,{LSL #Amount}]'            , 'T32: 1111100|0|0|0|1|1|Rn!=1111|1111|000000|Amount:2|Rm:4'                     , ''  ],
  ['pld{c}{q}'         , '[Rn, {+/-}Rm ,{Shift #Amount}]'        , 'A32: 1111011|1|U|1|01|Rn:4|1|1|1|1|Amount!=00000|Shift!=11|0|Rm:4'             , ''  ],
  ['pld{c}{q}'         , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111011|1|U|1|01|Rn:4|1|1|1|1|00000|11|0|Rm:4'                            , ''  ],
  ['pldw{c}{q}'        , '[Rn, {+/-}Rm ,{Shift #Amount}]'        , 'A32: 1111011|1|U|0|01|Rn:4|1|1|1|1|Amount!=00000|Shift!=11|0|Rm:4'             , ''  ],
  ['pldw{c}{q}'        , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111011|1|U|0|01|Rn:4|1|1|1|1|00000|11|0|Rm:4'                            , ''  ],

  ['pli{c}{q}'         , '[Rn ,{#{+}ImmZ}]'                      , 'T32: 1111100|1|1|00|1|Rn!=1111|1111|ImmZ:12'                                   , ''  ],
  ['pli{c}{q}'         , '[Rn ,{#-ImmZ}]'                        , 'T32: 1111100|1|0|00|1|Rn!=1111|1111|1100|ImmZ:8'                               , ''  ],
  ['pli{c}{q}'         , 'RelZ'                                  , 'T32: 1111100|1|x|00|1|1111|1111|RelZ:12'                                       , 'FORM='  ],
  ['pli{c}{q}'         , '[PC, #{+/-}ImmZ]'                      , 'T32: 1111100|1|U|00|1|1111|1111|ImmZ:12'                                       , 'FORM='  ],
  ['pli{c}{q}'         , '[Rn ,{#{+/-}ImmZ}]'                    , 'A32: 1111010|0|U|1|01|Rn:4|1|1|1|1|ImmZ:12'                                    , ''  ],
  ['pli{c}{q}'         , 'RelZ'                                  , 'A32: 1111010|0|x|1|01|xxxx|1|1|1|1|RelZ:12'                                    , ''  ],
  ['pli{c}{q}'         , '[PC, #{+/-}ImmZ]'                      , 'A32: 1111010|0|U|1|01|xxxx|1|1|1|1|ImmZ:12'                                    , 'FORM='  ],

  ['pli{c}{q}'         , '[Rn, {+}Rm ,{LSL #Amount}]'            , 'T32: 1111100|1|0|00|1|Rn!=1111|1111|000000|Amount:2|Rm:4'                      , ''  ],
  ['pli{c}{q}'         , '[Rn, {+/-}Rm , RRX]'                   , 'A32: 1111011|0|U|1|01|Rn:4|1|1|1|1|00000|11|0|Rm:4'                            , ''  ],
  ['pli{c}{q}'         , '[Rn, {+/-}Rm ,{Shift #Amount}]'        , 'A32: 1111011|0|U|1|01|Rn:4|1|1|1|1|Amount!=00000|Shift!=11|0|Rm:4'             , ''  ],

  ['pop{c}{q}'         , 'List'                                  , 'T16: 1011|1|10|List.A:1|List.I:8'                                              , 'FORM='  ],
  ['ldm{c}{q}'         , 'SP!, List'                             , 'T16: 1011|1|10|List.A:1|List.I:8'                                              , 'FORM='  ],

  ['pop{c}.w'          , 'List'                                  , 'T32: 1110100|01|0|1|1|1101|List:1|List:1|0|List:13'                            , ''  ],
  ['pop{c}{q}'         , 'List'                                  , 'T32: 1110100|01|0|1|1|1101|List:1|List:1|0|List:13'                            , ''  ],
  ['pop{c}{q}'         , 'List'                                  , 'A32: Cond!=1111|100|0|1|0|1|1|1101|List:16'                                    , ''  ],

  ['pop{c}{q}'         , 'Single_register_list'                  , 'T32: 1111100|0|0|10|1|1101|xxxx|1|0|1|1|00000100'                              , ''  ],
  ['pop{c}{q}'         , 'Single_register_list'                  , 'A32: Cond!=1111|010|0|1|0|0|1|1101|xxxx|000000000100'                          , ''  ],

  ['push{c}{q}'        , 'List'                                  , 'T16: 1011|0|10|List.B:1|List.I:8'                                              , 'FORM='  ],
  ['stmdb{c}{q}'       , 'SP!, List'                             , 'T16: 1011|0|10|List.B:1|List.I:8'                                              , 'FORM='  ],

  ['push{c}.w'         , 'List'                                  , 'T32: 1110100|10|0|1|0|1101|0|List.B:1|0|List.C:13'                             , ''  ],
  ['push{c}{q}'        , 'List'                                  , 'T32: 1110100|10|0|1|0|1101|0|List.B:1|0|List.C:13'                             , ''  ],
  ['push{c}{q}'        , 'List'                                  , 'A32: Cond!=1111|100|1|0|0|1|0|1101|List:16'                                    , ''  ],

  ['push{c}{q}'        , 'Single_register_list'                  , 'T32: 1111100|0|0|10|0|1101|xxxx|1|1|0|1|00000100'                              , ''  ],
  ['push{c}{q}'        , 'Single_register_list'                  , 'A32: Cond!=1111|010|1|0|0|1|0|1101|xxxx|000000000100'                          , ''  ],

  ['qadd{c}{q}'        , '{Rd}, Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['qadd{c}{q}'        , '{Rd}, Rm, Rn'                          , 'A32: Cond!=1111|00010|00|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  ['qadd16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|1|Rm:4'                   , ''  ],
  ['qadd16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|0|1|0|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  ['qadd8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qadd8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  ['qasx{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qasx{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  ['qdadd{c}{q}'       , '{Rd}, Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|01|Rm:4'                                  , ''  ],
  ['qdadd{c}{q}'       , '{Rd}, Rm, Rn'                          , 'A32: Cond!=1111|00010|10|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  ['qdsub{c}{q}'       , '{Rd}, Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|11|Rm:4'                                  , ''  ],
  ['qdsub{c}{q}'       , '{Rd}, Rm, Rn'                          , 'A32: Cond!=1111|00010|11|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  ['qsax{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qsax{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  ['qsub{c}{q}'        , '{Rd}, Rm, Rn'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|10|10|Rm:4'                                  , ''  ],
  ['qsub{c}{q}'        , '{Rd}, Rm, Rn'                          , 'A32: Cond!=1111|00010|01|0|Rn:4|Rd:4|0|0|0|0|0101|Rm:4'                        , ''  ],

  ['qsub16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|1|Rm:4'                   , ''  ],
  ['qsub16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|0|1|0|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  ['qsub8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|0|0|1|Rm:4'                                , ''  ],
  ['qsub8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|010|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  ['rbit{c}{q}'        , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|10|Rm:4'                                  , ''  ],
  ['rbit{c}{q}'        , 'Rd, Rm'                                , 'A32: Cond!=1111|01101|1|11|1|1|1|1|Rd:4|1|1|1|1|0|011|Rm:4'                    , ''  ],

  ['rev{c}{q}'         , 'Rd, Rm'                                , 'T16: 10111010|00|Rm:3|Rd:3'                                                    , ''  ],
  ['rev{c}.w'          , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['rev{c}{q}'         , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['rev{c}{q}'         , 'Rd, Rm'                                , 'A32: Cond!=1111|01101|0|11|1|1|1|1|Rd:4|1|1|1|1|0|011|Rm:4'                    , ''  ],

  ['rev16{c}{q}'       , 'Rd, Rm'                                , 'T16: 10111010|01|Rm:3|Rd:3'                                                    , ''  ],
  ['rev16{c}.w'        , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|01|Rm:4'                                  , ''  ],
  ['rev16{c}{q}'       , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|01|Rm:4'                                  , ''  ],
  ['rev16{c}{q}'       , 'Rd, Rm'                                , 'A32: Cond!=1111|01101|0|11|1|1|1|1|Rd:4|1|1|1|1|1|011|Rm:4'                    , ''  ],

  ['revsh{c}{q}'       , 'Rd, Rm'                                , 'T16: 10111010|11|Rm:3|Rd:3'                                                    , ''  ],
  ['revsh{c}.w'        , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|11|Rm:4'                                  , ''  ],
  ['revsh{c}{q}'       , 'Rd, Rm'                                , 'T32: 111110101|001|xxxx|1111|Rd:4|10|11|Rm:4'                                  , ''  ],
  ['revsh{c}{q}'       , 'Rd, Rm'                                , 'A32: Cond!=1111|01101|1|11|1|1|1|1|Rd:4|1|1|1|1|1|011|Rm:4'                    , ''  ],

  ['rfedb{c}{q}'       , 'Rn{!}'                                 , 'T32: 1110100|00|0|W|1|Rn:4|1|1|0|0000000000000'                                , 'IT:OUT:LAST'  ],
  ['rfe{ia}{c}{q}'     , 'Rn{!}'                                 , 'T32: 1110100|11|0|W|1|Rn:4|1|1|0|0000000000000'                                , 'IT:OUT:LAST'  ],
  ['rfeda{c}{q}'       , 'Rn{!}'                                 , 'A32: 1111100|0|0|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],
  ['rfedb{c}{q}'       , 'Rn{!}'                                 , 'A32: 1111100|1|0|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],
  ['rfe{ia}{c}{q}'     , 'Rn{!}'                                 , 'A32: 1111100|0|1|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],
  ['rfeib{c}{q}'       , 'Rn{!}'                                 , 'A32: 1111100|1|1|0|W|1|Rn:4|00001010000|00000'                                 , ''  ],

  ['ror{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|0|1111|0|Imm!=000|Rd:4|Imm!=00|11|Rm:4'                      , ''  ],
  ['ror{c}{q}'         , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Imm!=00000|11|0|Rm:4'                     , ''  ],

  ['ror%c{q}'          , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , 'IT:IN'  ],
  ['ror%c.w'           , '{Rd}, Rm, Rs'                          , 'T32: 111110100|11|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:IN'  ],
  ['ror{c}{q}'         , '{Rd}, Rm, Rs'                          , 'T32: 111110100|11|0|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['ror{c}{q}'         , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|Rs:4|0|11|1|Rm:4'                         , ''  ],

  ['rors{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'T32: 1110101|0010|1|1111|0|Imm!=000|Rd:4|Imm!=00|11|Rm:4'                      , ''  ],
  ['rors{c}{q}'        , '{Rd}, Rm, #Imm'                        , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Imm!=00000|11|0|Rm:4'                     , ''  ],

  ['rors{q}'           , '{Rdm}, Rdm, Rs'                        , 'T16: 010000|0111|Rs:3|Rdm:3'                                                   , 'IT:OUT'  ],
  ['rors.w'            , '{Rd}, Rm, Rs'                          , 'T32: 111110100|11|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , 'IT:OUT'  ],
  ['rors{c}{q}'        , '{Rd}, Rm, Rs'                          , 'T32: 111110100|11|1|Rm:4|1111|Rd:4|0000|Rs:4'                                  , ''  ],
  ['rors{c}{q}'        , '{Rd}, Rm, Rs'                          , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|Rs:4|0|11|1|Rm:4'                         , ''  ],

  ['rrx{c}{q}'         , '{Rd}, Rm'                              , 'T32: 1110101|0010|0|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rrx{c}{q}'         , '{Rd}, Rm'                              , 'A32: Cond!=1111|00011|01|0|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],

  ['rrxs{c}{q}'        , '{Rd}, Rm'                              , 'T32: 1110101|0010|1|1111|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rrxs{c}{q}'        , '{Rd}, Rm'                              , 'A32: Cond!=1111|00011|01|1|0000|Rd:4|00000|11|0|Rm:4'                          , ''  ],

  ['rsb%c{q}'          , '{Rd}, Rn, #0'                          , 'T16: 010000|1001|Rn:3|Rd:3'                                                    , 'IT:IN'  ],
  ['rsbs{q}'           , '{Rd}, Rn, #0'                          , 'T16: 010000|1001|Rn:3|Rd:3'                                                    , 'IT:OUT'  ],
  ['rsb%c.w'           , '{Rd}, Rn, #0'                          , 'T32: 11110|x|0|1110|0|Rn:4|0|xxx|Rd:4|xxxxxxxx'                                , 'IT:IN'  ],
  ['rsb{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1110|0|Rn:4|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['rsbs.w'            , '{Rd}, Rn, #0'                          , 'T32: 11110|x|0|1110|1|Rn:4|0|xxx|Rd:4|xxxxxxxx'                                , 'IT:OUT'  ],
  ['rsbs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1110|1|Rn:4|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['rsb{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|011|0|Rn:4|Rd:4|ImmX:12'                                  , ''  ],
  ['rsbs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|011|1|Rn:4|Rd:4|ImmX:12'                                  , ''  ],

  ['rsb{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1110|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rsb{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1110|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['rsbs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1110|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['rsbs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1110|1|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['rsb{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|011|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rsb{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|011|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['rsbs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|011|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rsbs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|011|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['rsbs{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|011|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['rsb{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|011|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['rsc{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|111|0|Rn:4|Rd:4|ImmX:12'                                  , ''  ],
  ['rscs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|111|1|Rn:4|Rd:4|ImmX:12'                                  , ''  ],

  ['rsc{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|111|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rsc{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|111|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['rscs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|111|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['rscs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|111|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['rscs{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|111|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['rsc{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|111|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['sadd16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|0|Rm:4'                   , ''  ],
  ['sadd16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|0|0|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  ['sadd8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['sadd8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  ['sasx{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['sasx{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  ['sbc{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1011|0|Rn:4|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['sbcs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1011|1|Rn:4|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['sbc{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|110|0|Rn:4|Rd:4|ImmX:12'                                  , ''  ],
  ['sbcs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|110|1|Rn:4|Rd:4|ImmX:12'                                  , ''  ],

  ['sbc%c{q}'          , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0110|Rm:3|Rdn:3'                                                   , 'IT:IN'  ],
  ['sbcs{q}'           , '{Rdn}, Rdn, Rm'                        , 'T16: 010000|0110|Rm:3|Rdn:3'                                                   , 'IT:OUT'  ],
  ['sbc{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1011|0|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['sbc%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1011|0|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:IN'  ],
  ['sbc{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1011|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['sbcs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1011|1|Rn:4|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['sbcs.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1011|1|Rn:4|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , 'IT:OUT'  ],
  ['sbcs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1011|1|Rn:4|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['sbc{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|110|0|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['sbc{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|110|0|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['sbcs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|110|1|Rn:4|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['sbcs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|110|1|Rn:4|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['sbcs{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|110|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['sbc{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|110|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['sbfx{c}{q}'        , 'Rd, Rn, #Lsb, #Width'                  , 'T32: 11110|0|11|01|0|0|Rn:4|0|Lsb:3|Rd:4|Lsb:2|0|Width:5'                      , ''  ],
  ['sbfx{c}{q}'        , 'Rd, Rn, #Lsb, #Width'                  , 'A32: Cond!=1111|01111|0|1|Width:5|Rd:4|Lsb:5|101|Rn:4'                         , ''  ],

  ['sdiv{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110111|001|Rn:4|1111|Rd:4|1111|Rm:4'                                   , ''  ],
  ['sdiv{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|001|Rd:4|1111|Rm:4|000|1|Rn:4'                           , ''  ],

  ['sel{c}{q}'         , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|10|00|Rm:4'                                  , ''  ],
  ['sel{c}{q}'         , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01101000|Rn:4|Rd:4|1|1|1|1|1011|Rm:4'                          , ''  ],

  ['setend{q}'         , 'Endian_specifier'                      , 'T16: 1011011001|0|1|Endian_specifier:1|000'                                    , ''  ],
  ['setend{q}'         , 'Endian_specifier'                      , 'A32: 111100010000|00|0|1|0|0|0|0|0|0|Endian_specifier:1|0|0|0|0|00000'         , ''  ],

  ['sev{c}{q}'         , ''                                      , 'T16: 10111111|0100|0000'                                                       , ''  ],
  ['sev{c}.w'          , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0100'                              , ''  ],
  ['sev{c}{q}'         , ''                                      , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|000000000100'                         , ''  ],

  ['sevl{c}{q}'        , ''                                      , 'T16: 10111111|0101|0000'                                                       , ''  ],
  ['sevl{c}.w'         , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0101'                              , ''  ],
  ['sevl{c}{q}'        , ''                                      , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|000000000101'                         , ''  ],

  ['shadd16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|0|1|0|Rm:4'                   , ''  ],
  ['shadd16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|0|1|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  ['shadd8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shadd8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  ['shasx{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shasx{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  ['shsax{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shsax{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  ['shsub16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|0|1|0|Rm:4'                   , ''  ],
  ['shsub16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|0|1|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  ['shsub8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|0|1|0|Rm:4'                                , ''  ],
  ['shsub8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|011|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  ['smc{c}{q}'         , '{#}Imm'                                , 'T32: 11110111111|1|Imm:4|10|0|0|000000000000'                                  , ''  ],
  ['smc{c}{q}'         , '{#}Imm'                                , 'A32: Cond!=1111|00010|11|0|000000000000|0111|Imm:4'                            , ''  ],

  ['smlabb{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smlabt{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlatb{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|1|0|Rm:4'                             , ''  ],
  ['smlatt{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|001|Rn:4|Ra!=1111|Rd:4|00|1|1|Rm:4'                             , ''  ],
  ['smlabb{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|0|0|0|Rn:4'                        , ''  ],
  ['smlabt{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|1|0|0|Rn:4'                        , ''  ],
  ['smlatb{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|0|1|0|Rn:4'                        , ''  ],
  ['smlatt{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|00010|00|0|Rd:4|Ra:4|Rm:4|1|1|1|0|Rn:4'                        , ''  ],

  ['smlad{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|010|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smladx{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|010|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlad{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|00|0|1|Rn:4'                      , ''  ],
  ['smladx{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|00|1|1|Rn:4'                      , ''  ],

  ['smlal{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['smlals{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|111|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['smlal{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|111|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  ['smlalbb{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|0|0|Rm:4'                             , ''  ],
  ['smlalbt{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|0|1|Rm:4'                             , ''  ],
  ['smlaltb{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|1|0|Rm:4'                             , ''  ],
  ['smlaltt{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|10|1|1|Rm:4'                             , ''  ],
  ['smlalbb{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|0|0|0|Rn:4'                    , ''  ],
  ['smlalbt{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|1|0|0|Rn:4'                    , ''  ],
  ['smlaltb{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|0|1|0|Rn:4'                    , ''  ],
  ['smlaltt{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|00010|10|0|RdHi:4|RdLo:4|Rm:4|1|1|1|0|Rn:4'                    , ''  ],

  ['smlald{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|110|0|Rm:4'                              , ''  ],
  ['smlaldx{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|100|Rn:4|RdLo:4|RdHi:4|110|1|Rm:4'                              , ''  ],
  ['smlald{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|00|0|1|Rn:4'                      , ''  ],
  ['smlaldx{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|00|1|1|Rn:4'                      , ''  ],

  ['smlawb{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|011|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smlawt{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|011|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlawb{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|00010|01|0|Rd:4|Ra:4|Rm:4|1|0|0|0|Rn:4'                        , ''  ],
  ['smlawt{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|00010|01|0|Rd:4|Ra:4|Rm:4|1|1|0|0|Rn:4'                        , ''  ],

  ['smlsd{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|100|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smlsdx{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|100|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smlsd{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|01|0|1|Rn:4'                      , ''  ],
  ['smlsdx{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|000|Rd:4|Ra!=1111|Rm:4|01|1|1|Rn:4'                      , ''  ],

  ['smlsld{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|101|Rn:4|RdLo:4|RdHi:4|110|0|Rm:4'                              , ''  ],
  ['smlsldx{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|101|Rn:4|RdLo:4|RdHi:4|110|1|Rm:4'                              , ''  ],
  ['smlsld{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|01|0|1|Rn:4'                      , ''  ],
  ['smlsldx{c}{q}'     , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|01110|100|RdHi:4|RdLo:4|Rm:4|01|1|1|Rn:4'                      , ''  ],

  ['smmla{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|101|Rn:4|Ra!=1111|Rd:4|00|0|0|Rm:4'                             , ''  ],
  ['smmlar{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|101|Rn:4|Ra!=1111|Rd:4|00|0|1|Rm:4'                             , ''  ],
  ['smmla{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|101|Rd:4|Ra!=1111|Rm:4|00|0|1|Rn:4'                      , ''  ],
  ['smmlar{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|101|Rd:4|Ra!=1111|Rm:4|00|1|1|Rn:4'                      , ''  ],

  ['smmls{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|110|Rn:4|Ra:4|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smmlsr{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|110|Rn:4|Ra:4|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smmls{c}{q}'       , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|101|Rd:4|Ra:4|Rm:4|11|0|1|Rn:4'                          , ''  ],
  ['smmlsr{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01110|101|Rd:4|Ra:4|Rm:4|11|1|1|Rn:4'                          , ''  ],

  ['smmul{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110110|101|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smmulr{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|101|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smmul{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|101|Rd:4|1111|Rm:4|00|0|1|Rn:4'                          , ''  ],
  ['smmulr{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|101|Rd:4|1111|Rm:4|00|1|1|Rn:4'                          , ''  ],

  ['smuad{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110110|010|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smuadx{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|010|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smuad{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|000|Rd:4|1111|Rm:4|00|0|1|Rn:4'                          , ''  ],
  ['smuadx{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|000|Rd:4|1111|Rm:4|00|1|1|Rn:4'                          , ''  ],

  ['smulbb{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smulbt{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smultb{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|1|0|Rm:4'                                 , ''  ],
  ['smultt{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|001|Rn:4|1111|Rd:4|00|1|1|Rm:4'                                 , ''  ],
  ['smulbb{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|0|0|0|Rn:4'                        , ''  ],
  ['smulbt{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|1|0|0|Rn:4'                        , ''  ],
  ['smultb{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|0|1|0|Rn:4'                        , ''  ],
  ['smultt{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|00010|11|0|Rd:4|0000|Rm:4|1|1|1|0|Rn:4'                        , ''  ],

  ['smull{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|000|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['smulls{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|110|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['smull{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|110|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  ['smulwb{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|011|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smulwt{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|011|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smulwb{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|00010|01|0|Rd:4|0000|Rm:4|1|0|1|0|Rn:4'                        , ''  ],
  ['smulwt{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|00010|01|0|Rd:4|0000|Rm:4|1|1|1|0|Rn:4'                        , ''  ],

  ['smusd{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110110|100|Rn:4|1111|Rd:4|00|0|0|Rm:4'                                 , ''  ],
  ['smusdx{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110110|100|Rn:4|1111|Rd:4|00|0|1|Rm:4'                                 , ''  ],
  ['smusd{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|000|Rd:4|1111|Rm:4|01|0|1|Rn:4'                          , ''  ],
  ['smusdx{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|000|Rd:4|1111|Rm:4|01|1|1|Rn:4'                          , ''  ],

  ['srsdb{c}{q}'       , 'SP{!}, #Mode'                          , 'T32: 1110100|00|0|W|0|1101|1|1|0|00000000|Mode:5'                              , ''  ],
  ['srs{ia}{c}{q}'     , 'SP{!}, #Mode'                          , 'T32: 1110100|11|0|W|0|1101|1|1|0|00000000|Mode:5'                              , ''  ],
  ['srsda{c}{q}'       , 'SP{!}, #Mode'                          , 'A32: 1111100|0|0|1|W|0|1101|00000101000|Mode:5'                                , ''  ],
  ['srsdb{c}{q}'       , 'SP{!}, #Mode'                          , 'A32: 1111100|1|0|1|W|0|1101|00000101000|Mode:5'                                , ''  ],
  ['srs{ia}{c}{q}'     , 'SP{!}, #Mode'                          , 'A32: 1111100|0|1|1|W|0|1101|00000101000|Mode:5'                                , ''  ],
  ['srsib{c}{q}'       , 'SP{!}, #Mode'                          , 'A32: 1111100|1|1|1|W|0|1101|00000101000|Mode:5'                                , ''  ],

  ['ssat{c}{q}'        , 'Rd, #Imm, Rn, ASR #Amount'             , 'T32: 11110|0|11|00|1|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|0|Imm:5'             , ''  ],
  ['ssat{c}{q}'        , 'Rd, #Imm, Rn, {LSL #Amount}'           , 'T32: 11110|0|11|00|0|0|Rn:4|0|Amount:3|Rd:4|Amount:2|0|Imm:5'                  , ''  ],
  ['ssat{c}{q}'        , 'Rd, #Imm, Rn, ASR #Amount'             , 'A32: Cond!=1111|01101|0|1|Imm:5|Rd:4|Amount:5|1|01|Rn:4'                       , ''  ],
  ['ssat{c}{q}'        , 'Rd, #Imm, Rn, {LSL #Amount}'           , 'A32: Cond!=1111|01101|0|1|Imm:5|Rd:4|Amount:5|0|01|Rn:4'                       , ''  ],

  ['ssat16{c}{q}'      , 'Rd, #Imm, Rn'                          , 'T32: 11110|0|11|00|1|0|Rn:4|0|000|Rd:4|00|0|0|Imm:4'                           , ''  ],
  ['ssat16{c}{q}'      , 'Rd, #Imm, Rn'                          , 'A32: Cond!=1111|01101|0|10|Imm:4|Rd:4|1|1|1|1|0011|Rn:4'                       , ''  ],

  ['ssax{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['ssax{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  ['ssub16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|0|0|0|Rm:4'                   , ''  ],
  ['ssub16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|0|0|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  ['ssub8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|0|0|0|Rm:4'                                , ''  ],
  ['ssub8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|001|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  ['stc{c}{q}'         , 'p14, c5, [Rn,{#{+/-}ImmZ*4}]'          , 'T32: 111|0|110|1|U|0|0|0|Rn:4|0101|111|0|ImmZ:8'                               , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn], #{+/-}ImmZ*4'           , 'T32: 111|0|110|0|U|0|1|0|Rn:4|0101|111|0|ImmZ:8'                               , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn, #{+/-}ImmZ*4]!'          , 'T32: 111|0|110|1|U|0|1|0|Rn:4|0101|111|0|ImmZ:8'                               , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn], Option'                 , 'T32: 111|0|110|0|1|0|0|0|Rn:4|0101|111|0|Option:8'                             , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn,{#{+/-}ImmZ*4}]'          , 'A32: Cond!=1111|110|1|U|0|0|0|Rn:4|0101|111|0|ImmZ:8'                          , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn], #{+/-}ImmZ*4'           , 'A32: Cond!=1111|110|0|U|0|1|0|Rn:4|0101|111|0|ImmZ:8'                          , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn, #{+/-}ImmZ*4]!'          , 'A32: Cond!=1111|110|1|U|0|1|0|Rn:4|0101|111|0|ImmZ:8'                          , ''  ],
  ['stc{c}{q}'         , 'p14, c5, [Rn], Option'                 , 'A32: Cond!=1111|110|0|1|0|0|0|Rn:4|0101|111|0|Option:8'                        , ''  ],

  ['stl{c}{q}'         , 'Rt, [Rn]'                              , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|0|10|1111'                                 , ''  ],
  ['stl{c}{q}'         , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|00|0|Rn:4|1111|1|1|0|0|1001|Rt:4'                        , ''  ],

  ['stlb{c}{q}'        , 'Rt, [Rn]'                              , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|0|00|1111'                                 , ''  ],
  ['stlb{c}{q}'        , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|10|0|Rn:4|1111|1|1|0|0|1001|Rt:4'                        , ''  ],

  ['stlex{c}{q}'       , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|1|10|Rd:4'                                 , ''  ],
  ['stlex{c}{q}'       , 'Rd, Rt, [Rn]'                          , 'A32: Cond!=1111|00011|00|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  ['stlexb{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|1|00|Rd:4'                                 , ''  ],
  ['stlexb{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'A32: Cond!=1111|00011|10|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  ['stlexd{c}{q}'      , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 11101000110|0|Rn:4|Rt:4|Rt2:4|1|1|11|Rd:4'                                , ''  ],
  ['stlexd{c}{q}'      , 'Rd, Rt, Rt2=Rt+1, [Rn]'                , 'A32: Cond!=1111|00011|01|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  ['stlexh{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|1|01|Rd:4'                                 , ''  ],
  ['stlexh{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'A32: Cond!=1111|00011|11|0|Rn:4|Rd:4|1|1|1|0|1001|Rt:4'                        , ''  ],

  ['stlh{c}{q}'        , 'Rt, [Rn]'                              , 'T32: 11101000110|0|Rn:4|Rt:4|1111|1|0|01|1111'                                 , ''  ],
  ['stlh{c}{q}'        , 'Rt, [Rn]'                              , 'A32: Cond!=1111|00011|11|0|Rn:4|1111|1|1|0|0|1001|Rt:4'                        , ''  ],

  ['stm{ia}{c}{q}'     , 'Rn!, List'                             , 'T16: 1100|0|Rn:3|List.I:8'                                                     , 'FORM='  ],
  ['stmea{c}{q}'       , 'Rn!, List'                             , 'T16: 1100|0|Rn:3|List.I:8'                                                     , 'FORM='  ],
  ['stm{ia}{c}.w'      , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|List.B:1|0|List.C:13'                             , 'FORM='  ],
  ['stmea{c}.w'        , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|List.B:1|0|List.C:13'                             , 'FORM='  ],
  ['stm{ia}{c}{q}'     , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|List.B:1|0|List.C:13'                             , 'FORM='  ],
  ['stmea{c}{q}'       , 'Rn{!}, List'                           , 'T32: 1110100|01|0|W|0|Rn:4|0|List.B:1|0|List.C:13'                             , 'FORM='  ],
  ['stm{ia}{c}{q}'     , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|1|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],
  ['stmea{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|1|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],

  ['stm{<amode>}{c}{q}', 'Rn, List^'                             , 'A32: Cond!=1111|100|x|x|1|0|0|Rn:4|List:16'                                    , ''  ],

  ['stmda{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|0|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],
  ['stmed{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|0|0|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],

  ['stmdb{c}{q}'       , 'Rn{!}, List'                           , 'T32: 1110100|10|0|W|0|Rn:4|0|List.B:1|0|List.C:13'                             , 'FORM='  ],
  ['stmfd{c}{q}'       , 'Rn{!}, List'                           , 'T32: 1110100|10|0|W|0|Rn:4|0|List.B:1|0|List.C:13'                             , 'FORM='  ],
  ['stmdb{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|0|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],
  ['stmfd{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|0|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],

  ['stmib{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|1|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],
  ['stmfa{c}{q}'       , 'Rn{!}, List'                           , 'A32: Cond!=1111|100|1|1|0|W|0|Rn:4|List:16'                                    , 'FORM='  ],

  ['str{c}{q}'         , 'Rt, [Rn ,{#{+}ImmZ*4}]'                , 'T16: 011|0|0|ImmZ:5|Rn:3|Rt:3'                                                 , ''  ],
  ['str{c}{q}'         , 'Rt, [SP,{#{+}ImmZ*4}]'                 , 'T16: 1001|0|Rt:3|ImmZ:8'                                                       , ''  ],
  ['str{c}.w'          , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|10|0|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|10|0|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1|1|0|0|ImmZ:8'                            , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|010|1|U|0|0|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|010|0|U|0|0|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|010|1|U|0|1|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],

  ['str{c}{q}'         , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|0|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['str{c}.w'          , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|000000|xx|Rm:4'                            , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|000000|Imm:2|Rm:4'                         , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn, {+/-}Rm,{Shift}]'             , 'A32: Cond!=1111|011|1|U|0|0|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|0|0|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['str{c}{q}'         , 'Rt, [Rn, {+/-}Rm,{Shift}]!'            , 'A32: Cond!=1111|011|1|U|0|1|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['strb{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T16: 011|1|0|ImmZ:5|Rn:3|Rt:3'                                                 , ''  ],
  ['strb{c}.w'         , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|00|0|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|00|0|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1|1|0|0|ImmZ:8'                            , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|010|1|U|1|0|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|010|0|U|1|0|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|010|1|U|1|1|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],

  ['strb{c}{q}'        , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|1|0|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['strb{c}.w'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|000000|xx|Rm:4'                            , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|000000|Imm:2|Rm:4'                         , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn, {+/-}Rm,{Shift}]'             , 'A32: Cond!=1111|011|1|U|1|0|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|1|0|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],
  ['strb{c}{q}'        , 'Rt, [Rn, {+/-}Rm,{Shift}]!'            , 'A32: Cond!=1111|011|1|U|1|1|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['strbt{c}{q}'       , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|0|00|0|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['strbt{c}{q}'       , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|010|0|U|1|1|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['strbt{c}{q}'       , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|1|1|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['strd{c}{q}'        , 'Rt, Rt2, [Rn ,{#{+/-}ImmZ*4}]'         , 'T32: 1110100|1|U|1|0|0|Rn!=1111|Rt:4|Rt2:4|ImmZ:8'                             , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2, [Rn], #{+/-}ImmZ*4'           , 'T32: 1110100|0|U|1|1|0|Rn!=1111|Rt:4|Rt2:4|ImmZ:8'                             , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2, [Rn, #{+/-}ImmZ*4]!'          , 'T32: 1110100|1|U|1|1|0|Rn!=1111|Rt:4|Rt2:4|ImmZ:8'                             , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn ,{#{+/-}ImmZ}]'      , 'A32: Cond!=1111|000|1|U|1|0|0|Rn:4|Rt:4|ImmZ:4|1|11|1|ImmZ:4'                  , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn], #{+/-}ImmZ'        , 'A32: Cond!=1111|000|0|U|1|0|0|Rn:4|Rt:4|ImmZ:4|1|11|1|ImmZ:4'                  , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn, #{+/-}ImmZ]!'       , 'A32: Cond!=1111|000|1|U|1|1|0|Rn:4|Rt:4|ImmZ:4|1|11|1|ImmZ:4'                  , ''  ],

  ['strd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn, {+/-}Rm]'           , 'A32: Cond!=1111|000|1|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn], {+/-}Rm'           , 'A32: Cond!=1111|000|0|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],
  ['strd{c}{q}'        , 'Rt, Rt2=Rt+1, [Rn, {+/-}Rm]!'          , 'A32: Cond!=1111|000|1|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|11|1|Rm:4'                   , ''  ],

  ['strex{c}{q}'       , 'Rd, Rt, [Rn ,{#ImmZ*4}]'               , 'T32: 11101000010|0|Rn:4|Rt:4|Rd:4|ImmZ:8'                                      , ''  ],
  ['strex{c}{q}'       , 'Rd, Rt, [Rn ,{{#}0}]'                  , 'A32: Cond!=1111|00011|00|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  ['strexb{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|01|00|Rd:4'                                  , ''  ],
  ['strexb{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'A32: Cond!=1111|00011|10|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  ['strexd{c}{q}'      , 'Rd, Rt, Rt2, [Rn]'                     , 'T32: 11101000110|0|Rn:4|Rt:4|Rt2:4|01|11|Rd:4'                                 , ''  ],
  ['strexd{c}{q}'      , 'Rd, Rt, Rt2=Rt+1, [Rn]'                , 'A32: Cond!=1111|00011|01|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  ['strexh{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'T32: 11101000110|0|Rn:4|Rt:4|1111|01|01|Rd:4'                                  , ''  ],
  ['strexh{c}{q}'      , 'Rd, Rt, [Rn]'                          , 'A32: Cond!=1111|00011|11|0|Rn:4|Rd:4|1|1|1|1|1001|Rt:4'                        , ''  ],

  ['strh{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ*2}]'                , 'T16: 1000|0|ImmZ:5|Rn:3|Rt:3'                                                  , ''  ],
  ['strh{c}.w'         , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|01|0|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|1|01|0|Rn!=1111|Rt:4|ImmZ:12'                                   , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn ,{#-ImmZ}]'                    , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1|1|0|0|ImmZ:8'                            , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1|0|U|1|ImmZ:8'                            , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1|1|U|1|ImmZ:8'                            , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn ,{#{+/-}ImmZ}]'                , 'A32: Cond!=1111|000|1|U|1|0|0|Rn:4|Rt:4|ImmZ:4|1|01|1|ImmZ:4'                  , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn], #{+/-}ImmZ'                  , 'A32: Cond!=1111|000|0|U|1|0|0|Rn:4|Rt:4|ImmZ:4|1|01|1|ImmZ:4'                  , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn, #{+/-}ImmZ]!'                 , 'A32: Cond!=1111|000|1|U|1|1|0|Rn:4|Rt:4|ImmZ:4|1|01|1|ImmZ:4'                  , ''  ],

  ['strh{c}{q}'        , 'Rt, [Rn, {+}Rm]'                       , 'T16: 0101|0|0|1|Rm:3|Rn:3|Rt:3'                                                , ''  ],
  ['strh{c}.w'         , 'Rt, [Rn, {+}Rm]'                       , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|000000|xx|Rm:4'                            , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn, {+}Rm,{LSL #Imm}]'            , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|000000|Imm:2|Rm:4'                         , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn, {+/-}Rm]'                     , 'A32: Cond!=1111|000|1|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|0|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],
  ['strh{c}{q}'        , 'Rt, [Rn, {+/-}Rm]!'                    , 'A32: Cond!=1111|000|1|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  ['strht{c}{q}'       , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|0|01|0|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['strht{c}{q}'       , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|000|0|U|1|1|0|Rn:4|Rt:4|ImmZ:4|1|01|1|ImmZ:4'                  , ''  ],
  ['strht{c}{q}'       , 'Rt, [Rn], {+/-}Rm'                     , 'A32: Cond!=1111|000|0|U|0|1|0|Rn:4|Rt:4|0|0|0|0|1|01|1|Rm:4'                   , ''  ],

  ['strt{c}{q}'        , 'Rt, [Rn ,{#{+}ImmZ}]'                  , 'T32: 1111100|0|0|10|0|Rn!=1111|Rt:4|1110|ImmZ:8'                               , ''  ],
  ['strt{c}{q}'        , 'Rt, [Rn], {#{+/-}ImmZ}'                , 'A32: Cond!=1111|010|0|U|0|1|0|Rn:4|Rt:4|ImmZ:12'                               , ''  ],
  ['strt{c}{q}'        , 'Rt, [Rn], {+/-}Rm, {Shift}'            , 'A32: Cond!=1111|011|0|U|0|1|0|Rn:4|Rt:4|xxxxx|Shift:2|0|Rm:4'                  , ''  ],

  ['sub{c}{q}'         , 'Rd, PC, #ImmZ'                         , 'T32: 11110|ImmZ:1|10|1|0|1|0|1111|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['sub{c}{q}'         , 'Rd, PC, #ImmX'                         , 'A32: Cond!=1111|0010|010|0|1111|Rd:4|ImmX:12'                                  , ''  ],

  ['sub%c{q}'          , 'Rd, Rn, #ImmZ'                         , 'T16: 000111|1|ImmZ:3|Rn:3|Rd:3'                                                , 'IT:IN'  ],
  ['subs{q}'           , 'Rd, Rn, #ImmZ'                         , 'T16: 000111|1|ImmZ:3|Rn:3|Rd:3'                                                , 'IT:OUT'  ],
  ['sub%c{q}'          , 'Rdn, #ImmZ'                            , 'T16: 001|11|Rdn:3|ImmZ:8'                                                      , 'IT:IN'  ],
  ['sub%c{q}'          , '{Rdn}, Rdn, #ImmZ'                     , 'T16: 001|11|Rdn:3|ImmZ:8'                                                      , 'IT:IN'  ],
  ['subs{q}'           , 'Rdn, #ImmZ'                            , 'T16: 001|11|Rdn:3|ImmZ:8'                                                      , 'IT:OUT'  ],
  ['subs{q}'           , '{Rdn}, Rdn, #ImmZ'                     , 'T16: 001|11|Rdn:3|ImmZ:8'                                                      , 'IT:OUT'  ],
  ['sub%c.w'           , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|0|Rn!=1101|0|ImmX:3|Rd:4|ImmX:8'                      , 'IT:IN'  ],
  ['sub{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|0|Rn!=1101|0|ImmX:3|Rd:4|ImmX:8'                      , ''  ],
  ['subs.w'            , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|1|Rn!=1101|0|ImmX:3|Rd!=1111|ImmX:8'                  , 'IT:OUT'  ],
  ['subs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|1|Rn!=1101|0|ImmX:3|Rd!=1111|ImmX:8'                  , ''  ],
  ['sub{c}{q}'         , '{Rd}, Rn, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|1|0|1|0|Rn!=11x1|0|ImmZ:3|Rd:4|ImmZ:8'                    , ''  ],
  ['subw{c}{q}'        , '{Rd}, Rn, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|1|0|1|0|Rn!=11x1|0|ImmZ:3|Rd:4|ImmZ:8'                    , ''  ],
  ['subs{c}{q}'        , 'PC, LR, #ImmZ'                         , 'T32: 111100111101|1110|10|0|0|1|1|1|1|ImmZ!=00000000'                          , ''  ],
  ['sub{c}{q}'         , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|010|0|Rn!=11x1|Rd:4|ImmX:12'                              , ''  ],
  ['subs{c}{q}'        , '{Rd}, Rn, #ImmX'                       , 'A32: Cond!=1111|0010|010|1|Rn!=1101|Rd:4|ImmX:12'                              , ''  ],

  ['sub%c{q}'          , 'Rd, Rn, Rm'                            , 'T16: 000110|1|Rm:3|Rn:3|Rd:3'                                                  , 'IT:IN'  ],
  ['subs{q}'           , '{Rd}, Rn, Rm'                          , 'T16: 000110|1|Rm:3|Rn:3|Rd:3'                                                  , 'IT:OUT'  ],
  ['sub{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1101|0|Rn!=1101|0|000|Rd:4|00|11|Rm:4'                            , ''  ],
  ['sub%c.w'           , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1101|0|Rn!=1101|0|!=000|Rd:4|!=00|!=11|Rm:4'                      , 'IT:IN'  ],
  ['sub{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1101|0|Rn!=1101|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['subs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'T32: 1110101|1101|1|Rn!=1101|0|000|Rd!=1111|00|11|Rm:4'                        , ''  ],
  ['subs.w'            , '{Rd}, Rn, Rm'                          , 'T32: 1110101|1101|1|Rn!=1101|0|!=000|Rd!=1111|!=00|!=11|Rm:4'                  , 'IT:OUT'  ],
  ['subs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'T32: 1110101|1101|1|Rn!=1101|0|Amount!=000|Rd!=1111|Amount!=00|Shift!=11|Rm:4' , ''  ],
  ['sub{c}{q}'         , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|010|0|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['sub{c}{q}'         , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|010|0|Rn!=1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'       , ''  ],
  ['subs{c}{q}'        , '{Rd}, Rn, Rm, RRX'                     , 'A32: Cond!=1111|0000|010|1|Rn!=1101|Rd:4|00000|11|0|Rm:4'                      , ''  ],
  ['subs{c}{q}'        , '{Rd}, Rn, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|010|1|Rn!=1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'       , ''  ],

  ['subs{c}{q}'        , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|010|1|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],
  ['sub{c}{q}'         , '{Rd}, Rn, Rm, type Rs'                 , 'A32: Cond!=1111|0000|010|0|Rn:4|Rd:4|Rs:4|0|type:2|1|Rm:4'                     , ''  ],

  ['sub{c}{q}'         , '{SP}, SP, #ImmZ*4'                     , 'T16: 10110000|1|ImmZ:7'                                                        , ''  ],
  ['sub{c}.w'          , '{Rd}, SP, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|0|1101|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['sub{c}{q}'         , '{Rd}, SP, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|0|1101|0|ImmX:3|Rd:4|ImmX:8'                          , ''  ],
  ['subs{c}{q}'        , '{Rd}, SP, #ImmX'                       , 'T32: 11110|ImmX:1|0|1101|1|1101|0|ImmX:3|Rd!=1111|ImmX:8'                      , ''  ],
  ['sub{c}{q}'         , '{Rd}, SP, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|1|0|1|0|1101|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['subw{c}{q}'        , '{Rd}, SP, #ImmZ'                       , 'T32: 11110|ImmZ:1|10|1|0|1|0|1101|0|ImmZ:3|Rd:4|ImmZ:8'                        , ''  ],
  ['sub{c}{q}'         , '{Rd}, SP, #ImmX'                       , 'A32: Cond!=1111|0010|010|0|1101|Rd:4|ImmX:12'                                  , ''  ],
  ['subs{c}{q}'        , '{Rd}, SP, #ImmX'                       , 'A32: Cond!=1111|0010|010|1|1101|Rd:4|ImmX:12'                                  , ''  ],

  ['sub{c}{q}'         , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110101|1101|0|1101|0|000|Rd:4|00|11|Rm:4'                                , ''  ],
  ['sub{c}.w'          , '{Rd}, SP, Rm'                          , 'T32: 1110101|1101|0|1101|0|!=000|Rd:4|!=00|!=11|Rm:4'                          , ''  ],
  ['sub{c}{q}'         , '{Rd}, SP, Rm, {Shift #Amount}'         , 'T32: 1110101|1101|0|1101|0|Amount!=000|Rd:4|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['subs{c}{q}'        , '{Rd}, SP, Rm, RRX'                     , 'T32: 1110101|1101|1|1101|0|000|Rd!=1111|00|11|Rm:4'                            , ''  ],
  ['subs{c}{q}'        , '{Rd}, SP, Rm, {Shift #Amount}'         , 'T32: 1110101|1101|1|1101|0|Amount!=000|Rd!=1111|Amount!=00|Shift!=11|Rm:4'     , ''  ],
  ['sub{c}{q}'         , '{Rd}, SP, Rm, RRX'                     , 'A32: Cond!=1111|0000|010|0|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['sub{c}{q}'         , '{Rd}, SP, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|010|0|1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],
  ['subs{c}{q}'        , '{Rd}, SP, Rm, RRX'                     , 'A32: Cond!=1111|0000|010|1|1101|Rd:4|00000|11|0|Rm:4'                          , ''  ],
  ['subs{c}{q}'        , '{Rd}, SP, Rm, {Shift #Amount}'         , 'A32: Cond!=1111|0000|010|1|1101|Rd:4|Amount!=00000|Shift!=11|0|Rm:4'           , ''  ],

  ['svc{c}{q}'         , '{#}ImmZ'                               , 'T16: 1101111|1|ImmZ:8'                                                         , ''  ],
  ['svc{c}{q}'         , '{#}ImmZ'                               , 'A32: Cond!=1111|1111|ImmZ:24'                                                  , ''  ],

  ['sxtab{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'T32: 111110100|10|0|Rn!=1111|1111|Rd:4|1|0|Amount:2|Rm:4'                      , ''  ],
  ['sxtab{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'A32: Cond!=1111|01101|0|10|Rn!=1111|Rd:4|Amount:2|0|0|0111|Rm:4'               , ''  ],

  ['sxtab16{c}{q}'     , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'T32: 111110100|01|0|Rn!=1111|1111|Rd:4|1|0|Amount:2|Rm:4'                      , ''  ],
  ['sxtab16{c}{q}'     , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'A32: Cond!=1111|01101|0|00|Rn!=1111|Rd:4|Amount:2|0|0|0111|Rm:4'               , ''  ],

  ['sxtah{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'T32: 111110100|00|0|Rn!=1111|1111|Rd:4|1|0|Amount:2|Rm:4'                      , ''  ],
  ['sxtah{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'A32: Cond!=1111|01101|0|11|Rn!=1111|Rd:4|Amount:2|0|0|0111|Rm:4'               , ''  ],

  ['sxtb{c}{q}'        , '{Rd}, Rm'                              , 'T16: 10110010|0|1|Rm:3|Rd:3'                                                   , ''  ],
  ['sxtb{c}.w'         , '{Rd}, Rm'                              , 'T32: 111110100|10|0|1111|1111|Rd:4|1|0|xx|Rm:4'                                , ''  ],
  ['sxtb{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'T32: 111110100|10|0|1111|1111|Rd:4|1|0|Amount:2|Rm:4'                          , ''  ],
  ['sxtb{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'A32: Cond!=1111|01101|0|10|1111|Rd:4|Amount:2|0|0|0111|Rm:4'                   , ''  ],

  ['sxtb16{c}{q}'      , '{Rd}, Rm, {ROR #Amount*8}'             , 'T32: 111110100|01|0|1111|1111|Rd:4|1|0|Amount:2|Rm:4'                          , ''  ],
  ['sxtb16{c}{q}'      , '{Rd}, Rm, {ROR #Amount*8}'             , 'A32: Cond!=1111|01101|0|00|1111|Rd:4|Amount:2|0|0|0111|Rm:4'                   , ''  ],

  ['sxth{c}{q}'        , '{Rd}, Rm'                              , 'T16: 10110010|0|0|Rm:3|Rd:3'                                                   , ''  ],
  ['sxth{c}.w'         , '{Rd}, Rm'                              , 'T32: 111110100|00|0|1111|1111|Rd:4|1|0|xx|Rm:4'                                , ''  ],
  ['sxth{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'T32: 111110100|00|0|1111|1111|Rd:4|1|0|Amount:2|Rm:4'                          , ''  ],
  ['sxth{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'A32: Cond!=1111|01101|0|11|1111|Rd:4|Amount:2|0|0|0111|Rm:4'                   , ''  ],

  ['tbb{c}{q}'         , '[Rn, Rm]'                              , 'T32: 111010001101|Rn:4|1|1|1|1|0|0|0|0|000|0|Rm:4'                             , 'IT:OUT:LAST'  ],
  ['tbh{c}{q}'         , '[Rn, Rm, LSL #1]'                      , 'T32: 111010001101|Rn:4|1|1|1|1|0|0|0|0|000|1|Rm:4'                             , 'IT:OUT:LAST'  ],

  ['teq{c}{q}'         , 'Rn, #ImmC'                             , 'T32: 11110|ImmC:1|0|0100|1|Rn:4|0|ImmC:3|1111|ImmC:8'                          , ''  ],
  ['teq{c}{q}'         , 'Rn, #ImmC'                             , 'A32: Cond!=1111|00110|01|1|Rn:4|0|0|0|0|ImmC:12'                               , ''  ],

  ['teq{c}{q}'         , 'Rn, Rm, RRX'                           , 'T32: 1110101|0100|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['teq{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'T32: 1110101|0100|1|Rn:4|0|Amount!=000|1111|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['teq{c}{q}'         , 'Rn, Rm, RRX'                           , 'A32: Cond!=1111|00010|01|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['teq{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00010|01|1|Rn:4|0|0|0|0|Amount!=00000|Shift!=11|0|Rm:4'        , ''  ],

  ['teq{c}{q}'         , 'Rn, Rm, type Rs'                       , 'A32: Cond!=1111|00010|01|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  ['tst{c}{q}'         , 'Rn, #ImmC'                             , 'T32: 11110|ImmC:1|0|0000|1|Rn:4|0|ImmC:3|1111|ImmC:8'                          , ''  ],
  ['tst{c}{q}'         , 'Rn, #ImmC'                             , 'A32: Cond!=1111|00110|00|1|Rn:4|0|0|0|0|ImmC:12'                               , ''  ],

  ['tst{c}{q}'         , 'Rn, Rm'                                , 'T16: 010000|1000|Rm:3|Rn:3'                                                    , ''  ],
  ['tst{c}{q}'         , 'Rn, Rm, RRX'                           , 'T32: 1110101|0000|1|Rn:4|0|000|1111|00|11|Rm:4'                                , ''  ],
  ['tst{c}.w'          , 'Rn, Rm'                                , 'T32: 1110101|0000|1|Rn:4|0|!=000|1111|!=00|!=11|Rm:4'                          , ''  ],
  ['tst{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'T32: 1110101|0000|1|Rn:4|0|Amount!=000|1111|Amount!=00|Shift!=11|Rm:4'         , ''  ],
  ['tst{c}{q}'         , 'Rn, Rm, RRX'                           , 'A32: Cond!=1111|00010|00|1|Rn:4|0|0|0|0|00000|11|0|Rm:4'                       , ''  ],
  ['tst{c}{q}'         , 'Rn, Rm, {Shift #Amount}'               , 'A32: Cond!=1111|00010|00|1|Rn:4|0|0|0|0|Amount!=00000|Shift!=11|0|Rm:4'        , ''  ],

  ['tst{c}{q}'         , 'Rn, Rm, type Rs'                       , 'A32: Cond!=1111|00010|00|1|Rn:4|0|0|0|0|Rs:4|0|type:2|1|Rm:4'                  , ''  ],

  ['uadd16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|0|Rm:4'                   , ''  ],
  ['uadd16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|1|0|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  ['uadd8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['uadd8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  ['uasx{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['uasx{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  ['ubfx{c}{q}'        , 'Rd, Rn, #Lsb, #Width'                  , 'T32: 11110|0|11|11|0|0|Rn:4|0|Lsb:3|Rd:4|Lsb:2|0|Width:5'                      , ''  ],
  ['ubfx{c}{q}'        , 'Rd, Rn, #Lsb, #Width'                  , 'A32: Cond!=1111|01111|1|1|Width:5|Rd:4|Lsb:5|101|Rn:4'                         , ''  ],

  ['udf{c}{q}'         , '{#}ImmZ'                               , 'T16: 1101111|0|ImmZ:8'                                                         , ''  ],
  ['udf{c}.w'          , '{#}ImmZ'                               , 'T32: 11110111111|1|ImmZ:4|10|1|0|ImmZ:12'                                      , ''  ],
  ['udf{c}{q}'         , '{#}ImmZ'                               , 'T32: 11110111111|1|ImmZ:4|10|1|0|ImmZ:12'                                      , ''  ],
  ['udf{c}{q}'         , '{#}ImmZ'                               , 'A32: 1110|01111111|ImmZ:12|1111|ImmZ:4'                                        , ''  ],

  ['udiv{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110111|011|Rn:4|1111|Rd:4|1111|Rm:4'                                   , ''  ],
  ['udiv{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01110|011|Rd:4|1111|Rm:4|000|1|Rn:4'                           , ''  ],

  ['uhadd16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|1|1|0|Rm:4'                   , ''  ],
  ['uhadd16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|1|1|1|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  ['uhadd8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhadd8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  ['uhasx{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhasx{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  ['uhsax{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhsax{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  ['uhsub16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|1|1|0|Rm:4'                   , ''  ],
  ['uhsub16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|1|1|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  ['uhsub8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|1|1|0|Rm:4'                                , ''  ],
  ['uhsub8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|111|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  ['umaal{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|110|Rn:4|RdLo:4|RdHi:4|0110|Rm:4'                               , ''  ],
  ['umaal{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|010|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  ['umlal{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|110|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['umlals{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|101|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['umlal{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|101|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  ['umull{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'T32: 111110111|010|Rn:4|RdLo:4|RdHi:4|0000|Rm:4'                               , ''  ],
  ['umulls{c}{q}'      , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|100|1|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],
  ['umull{c}{q}'       , 'RdLo, RdHi, Rn, Rm'                    , 'A32: Cond!=1111|0000|100|0|RdHi:4|RdLo:4|Rm:4|1001|Rn:4'                       , ''  ],

  ['uqadd16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|0|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|1|Rm:4'                   , ''  ],
  ['uqadd16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|1|1|0|Rn:4|Rd:4|1|1|1|1|0|0|0|1|Rm:4'                , ''  ],

  ['uqadd8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110101|000|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqadd8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|1|00|1|Rm:4'                       , ''  ],

  ['uqasx{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|010|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqasx{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|0|01|1|Rm:4'                       , ''  ],

  ['uqsax{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqsax{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  ['uqsub16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|1|Rm:4'                   , ''  ],
  ['uqsub16{c}{q}'     , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|1|1|0|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  ['uqsub8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|1|0|1|Rm:4'                                , ''  ],
  ['uqsub8{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|110|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  ['usad8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|1|0|1|1|1|Rn:4|1|1|1|1|Rd:4|0|0|0|0|Rm:4'                   , ''  ],
  ['usad8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|1|1|0|0|0|Rd:4|1|1|1|1|Rm:4|0|0|0|1|Rn:4'                , ''  ],

  ['usada8{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'T32: 111110110|111|Rn:4|Ra!=1111|Rd:4|00|00|Rm:4'                              , ''  ],
  ['usada8{c}{q}'      , 'Rd, Rn, Rm, Ra'                        , 'A32: Cond!=1111|01111000|Rd:4|Ra!=1111|Rm:4|0001|Rn:4'                         , ''  ],

  ['usat{c}{q}'        , 'Rd, #Imm, Rn, ASR #Amount'             , 'T32: 11110|0|11|10|1|0|Rn:4|0|Amount!=000|Rd:4|Amount!=00|0|Imm:5'             , ''  ],
  ['usat{c}{q}'        , 'Rd, #Imm, Rn, {LSL #Amount}'           , 'T32: 11110|0|11|10|0|0|Rn:4|0|Amount:3|Rd:4|Amount:2|0|Imm:5'                  , ''  ],
  ['usat{c}{q}'        , 'Rd, #Imm, Rn, ASR #Amount'             , 'A32: Cond!=1111|01101|1|1|Imm:5|Rd:4|Amount:5|1|01|Rn:4'                       , ''  ],
  ['usat{c}{q}'        , 'Rd, #Imm, Rn, {LSL #Amount}'           , 'A32: Cond!=1111|01101|1|1|Imm:5|Rd:4|Amount:5|0|01|Rn:4'                       , ''  ],

  ['usat16{c}{q}'      , 'Rd, #Imm, Rn'                          , 'T32: 11110|0|11|10|1|0|Rn:4|0|000|Rd:4|00|0|0|Imm:4'                           , ''  ],
  ['usat16{c}{q}'      , 'Rd, #Imm, Rn'                          , 'A32: Cond!=1111|01101|1|10|Imm:4|Rd:4|1|1|1|1|0011|Rn:4'                       , ''  ],

  ['usax{c}{q}'        , '{Rd}, Rn, Rm'                          , 'T32: 111110101|110|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['usax{c}{q}'        , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|0|10|1|Rm:4'                       , ''  ],

  ['usub16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'T32: 1|1|1|1|1|0|1|0|1|1|0|1|Rn:4|1|1|1|1|Rd:4|0|1|0|0|Rm:4'                   , ''  ],
  ['usub16{c}{q}'      , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|0|1|1|0|0|1|0|1|Rn:4|Rd:4|1|1|1|1|0|1|1|1|Rm:4'                , ''  ],

  ['usub8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'T32: 111110101|100|Rn:4|1111|Rd:4|0|1|0|0|Rm:4'                                , ''  ],
  ['usub8{c}{q}'       , '{Rd}, Rn, Rm'                          , 'A32: Cond!=1111|01100|101|Rn:4|Rd:4|1|1|1|1|1|11|1|Rm:4'                       , ''  ],

  ['uxtab{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'T32: 111110100|10|1|Rn!=1111|1111|Rd:4|1|0|Amount:2|Rm:4'                      , ''  ],
  ['uxtab{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'A32: Cond!=1111|01101|1|10|Rn!=1111|Rd:4|Amount:2|0|0|0111|Rm:4'               , ''  ],

  ['uxtab16{c}{q}'     , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'T32: 111110100|01|1|Rn!=1111|1111|Rd:4|1|0|Amount:2|Rm:4'                      , ''  ],
  ['uxtab16{c}{q}'     , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'A32: Cond!=1111|01101|1|00|Rn!=1111|Rd:4|Amount:2|0|0|0111|Rm:4'               , ''  ],

  ['uxtah{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'T32: 111110100|00|1|Rn!=1111|1111|Rd:4|1|0|Amount:2|Rm:4'                      , ''  ],
  ['uxtah{c}{q}'       , '{Rd}, Rn, Rm, {ROR #Amount*8}'         , 'A32: Cond!=1111|01101|1|11|Rn!=1111|Rd:4|Amount:2|0|0|0111|Rm:4'               , ''  ],

  ['uxtb{c}{q}'        , '{Rd}, Rm'                              , 'T16: 10110010|1|1|Rm:3|Rd:3'                                                   , ''  ],
  ['uxtb{c}.w'         , '{Rd}, Rm'                              , 'T32: 111110100|10|1|1111|1111|Rd:4|1|0|xx|Rm:4'                                , ''  ],
  ['uxtb{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'T32: 111110100|10|1|1111|1111|Rd:4|1|0|Amount:2|Rm:4'                          , ''  ],
  ['uxtb{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'A32: Cond!=1111|01101|1|10|1111|Rd:4|Amount:2|0|0|0111|Rm:4'                   , ''  ],

  ['uxtb16{c}{q}'      , '{Rd}, Rm, {ROR #Amount*8}'             , 'T32: 111110100|01|1|1111|1111|Rd:4|1|0|Amount:2|Rm:4'                          , ''  ],
  ['uxtb16{c}{q}'      , '{Rd}, Rm, {ROR #Amount*8}'             , 'A32: Cond!=1111|01101|1|00|1111|Rd:4|Amount:2|0|0|0111|Rm:4'                   , ''  ],

  ['uxth{c}{q}'        , '{Rd}, Rm'                              , 'T16: 10110010|1|0|Rm:3|Rd:3'                                                   , ''  ],
  ['uxth{c}.w'         , '{Rd}, Rm'                              , 'T32: 111110100|00|1|1111|1111|Rd:4|1|0|xx|Rm:4'                                , ''  ],
  ['uxth{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'T32: 111110100|00|1|1111|1111|Rd:4|1|0|Amount:2|Rm:4'                          , ''  ],
  ['uxth{c}{q}'        , '{Rd}, Rm, {ROR #Amount*8}'             , 'A32: Cond!=1111|01101|1|11|1111|Rd:4|Amount:2|0|0|0111|Rm:4'                   , ''  ],

  ['wfe{c}{q}'         , ''                                      , 'T16: 10111111|0010|0000'                                                       , ''  ],
  ['wfe{c}.w'          , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0010'                              , ''  ],
  ['wfe{c}{q}'         , ''                                      , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|000000000010'                         , ''  ],

  ['wfi{c}{q}'         , ''                                      , 'T16: 10111111|0011|0000'                                                       , ''  ],
  ['wfi{c}.w'          , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0011'                              , ''  ],
  ['wfi{c}{q}'         , ''                                      , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|000000000011'                         , ''  ],

  ['yield{c}{q}'       , ''                                      , 'T16: 10111111|0001|0000'                                                       , ''  ],
  ['yield{c}.w'        , ''                                      , 'T32: 111100111010|1|1|1|1|10|0|0|0|000|0000|0001'                              , ''  ],
  ['yield{c}{q}'       , ''                                      , 'A32: Cond!=1111|00110|0|10|00|00|1|1|1|1|000000000001'                         , ''  ],

);
