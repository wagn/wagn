module Wagn::Model::Extensions
  def self.included(base)
    super
    #Rails.logger.debug "add card methods for extensions #{base} #{self}"
    base.class_eval { cattr_accessor :extension_tags }
    base.extend(CardMethods)
  end

  def extension_submenu(tag, menu_name, on)
    menu_name = menu_name.to_s
    div(:class=>'submenu') do
      extension_forms(tag, menu_name) do |keycard, tcard, ok, args|
        key = keycard.name
        if ok
          link_to_remote( key, { :url=>url_for("card/#{menu_name}",args,key),
              :update => id , :menu => key}, :class=>(key==on.to_s ? 'on' : '') )
        end
      end
    end.compact.join
  end

  def extension_forms(tag, menu_name)
    return unless extcard = @card.extcard(tag.to_s) and
             formcard = extcard.setting_card(menu_name.to_star) and
             formcard.is_a?(Card::Pointer)
    formcard.pointees.map do |item|
      if c = Card.fetch(item, :skip_virtual=>true) and
         tag = (c.tag || c)
        block_given? ? yield(tag, c, true, []) : tag
      end
    end
  end

  def extension_form(action)
    ext_tag = '*sol' if action == :declare
    raise "No tag" unless ext_tag
    which_form = nil #@state.to_s
    extension_forms(ext_tag, action.to_s) do |keycard, tcard, ok, args|
      which_form = tcard if keycard.name == @state.to_s or not which_form
    end
    which_form.content
  end

  # was in Card::Base
  module CardMethods
    def add_extension_tag(tag, *options)
      options = options[0] if options.length == 1
      Card.extension_tags[tag] = options
    end

    def has_ext?(tag)
      raise "No card #{self}" unless self
      Rails.logger.info("has_ext? #{self.inspect}")
      true if extcard(tag)
    end

    def extcard(tag) 
      raise "No card #{self}" unless self
      Rails.logger.info("extcard #{self}")
      Card[name+JOINT+tag]
    end
     
    def tag_extensions
      extension_tags().keys.map do |tag|
        if extcard = Card[name+JOINT+tag]
          Rails.logger.info("tag_ext #{name} + #{tag} #{extcard.name}")
          yield(tag, extcard) if block_given? else tag
        end
      end.compact
    end  
        
    def menu_options(options=[])
      tag_extensions() do |tag, extcard|
        new_options = extension_tags()[tag]
        Rails.logger.info("menu_options N: #{tag} #{new_options}")
        if Hash===new_options
          new_options.each_pair do |where, what|
            if where == :right
              options.push(*what)
            elsif where == :left
              options.unshift(*what)
            elsif Array === where
              action = where.shift
              location = where.shift
              idx = 0
              if Symbol===location
                idx = options.index(location)
              elsif Fixnum===location
                idx = location
                idx = options.length+idx+1 if idx<0
              else raise "Location? #{location.class} #{location.inspect}"
              end
              if action == :left_of or action == :before
                idx = if idx then idx-1 else -1 end
              elsif action == :right_of or action == :after
                idx = options.length unless idx
              else raise "Action? #{action.inspect}"
              end
              idx = options.length if idx > options.length
              if idx < 0
                options.unshift(*what)
              else
                options[idx,0] = what
              end
            end
          end
        else
          if Array===new_options and new_options.length > 0 or new_options
            options.push(*new_options)
          end
        end
      end
      options
    end
  end

end
