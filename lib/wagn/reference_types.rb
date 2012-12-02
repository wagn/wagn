
module Wagn::ReferenceTypes

  LINK                = 'L'
  WANTED_LINK         = 'W'
  TRANSCLUSION        = 'T'
  WANTED_TRANSCLUSION = 'M'

  TYPE_MAP = {
    Chunk::Link       => { false => LINK,         true => WANTED_LINK },
    Chunk::Transclude => { false => TRANSCLUSION, true => WANTED_TRANSCLUSION }
  }

  LINK_TYPES       = [ LINK,          WANTED_LINK ]
  TRANSCLUDE_TYPES = [ TRANSCLUSION,  WANTED_TRANSCLUSION ]
  REF_TYPES        = [ *LINK_TYPES,  *TRANSCLUDE_TYPES ]

end
