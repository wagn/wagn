include_set Abstract::BootstrapCodeFile

def load_stylesheets
  add_stylesheet "font-awesome", type: :css
  add_stylesheet "material-icons", type: :css
  add_bs_stylesheet "variables"
  add_bs_stylesheet "mixins"
  add_bs_subdir "mixins"
  [
    %w[custom],
    # Reset and dependencies
    %w[normalize print],
    # Core CSS
    %w[reboot type images code grid tables forms buttons],
    # Components
    %w[transitions dropdown button-group input-group custom-forms nav navbar card
       breadcrumb pagination badge jumbotron alert progress media list-group
       responsive-embed close],
    # Components w/ JavaScript
    %w[modal tooltip popover carousel]
  ].each do |names|
    names.map do |name|
      add_bs_stylesheet name
    end
  end
  add_bs_subdir "utilities"
end

