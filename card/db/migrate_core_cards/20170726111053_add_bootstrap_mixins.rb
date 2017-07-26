# -*- encoding : utf-8 -*-

class AddBootstrapMixins < Card::Migration::Core
  def up
    ensure_card "style: bootstrap mixins", type_id: Card::ScssID,
                codename: "style_bootstrap_mixins"

    ensure_card "style: bootstrap breakpoints", type_id: Card::ScssID,
                    codename: "style_bootstrap_breakpoints"
  end
end
