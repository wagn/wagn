include Machine
include MachineInput

store_machine_output filetype: 'css'

include Pointer
format      { include Pointer::Format     }
format(:html) { include Pointer::HtmlFormat }
format(:css) { include Pointer::CssFormat  }
