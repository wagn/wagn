# -*- encoding : utf-8 -*-

include_set Abstract::Script

include_set Abstract::Machine
include_set Abstract::MachineInput

store_machine_output filetype: "js"

format :js do
  view :core do
    _render_raw
  end
end
