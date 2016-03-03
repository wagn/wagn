def prepare_for_phases
  reset_patterns
  include_set_modules
end

def run_phases?
  director.main? && !skip_phases
end

delegate :validation_phase, to: :director
delegate :storage_phase, to: :director
delegate :integration_phase, to: :director

def clean_up
  Card::DirectorRegister.clear
end
