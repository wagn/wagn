module Wagn::Set::Right::Account
  class Wagn::Renderer::Html
    # from app/view/card/_declare.rhtml
    define_view(:account_form, :right=>'account') do |args|
    end
  
    define_view(:account) do |args|
      #tcard = @card.trait_card(:sol)
      tcard = @card.trait_card(:account)
      raise "No card" unless tcard
  
      wrap( args ) do
        %{#{#slot.header  I don't understand why this doesn't work here?
        }<style>.SELF-#{tcard.safe_key
        } .account-area .title-#{
          tcard.cardname.safe_key
        } { display: none; }</style>} +
  
        div( :id=>id('card-body'), :class=>'card-body') do
          Rails.logger.debug "render account sub #{tcard&&tcard.name}"
          self.subrenderer(tcard).render(:account_form)
        end + notice
      end
    end
  
    # Traits can have submenus: This is the links for differet form selections
    def trait_submenu(menu_name, on)
      menu_name = menu_name.to_s
      div(:class=>'submenu') do
        trait_forms(menu_name) do |key, ok, args|
          if ok
            #link_to_remote( key, { :url=>url_for("card/#{menu_name}",args,key),
            #    :update => id , :menu => key}, :class=>(key==on.to_s ? 'on' : '') )
          end
        end
      end
    end
  
    def trait_forms(action)
    end
    def trait_form(action)
      forms = trait_forms(action=action.to_s)
      return forms if String === forms
      #Rails.logger.info "trait_form(#{action.inspect}) #{forms.inspect}"
      if form = forms.find { |k|
        #Rails.logger.info "trait_search(#{action.inspect}) #{card.attribute.inspect}, #{k.tag.inspect} #{forms.inspect}"
        k.tag == action } and form = Card.fetch(form)
        form.content
      else
        "No form card #{@state} #{card&&card.name}"
      end
    end
  end

  def self.included(base)
    super
#    base.register_trait('*account', :account)
#    Rails.logger.debug "including +*account #{base}"

#    base.class_eval { attr_accessor :attribute }
#    base.send :before_save, :save_account
  end

end
