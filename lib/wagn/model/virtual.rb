module Wagn::Model::Virtual
  module ClassMethods    
    def pattern_virtual(name, cached_card=nil)
      return nil unless name && name.junction?
      cached_card = nil if cached_card && cached_card.trash
      test_card = cached_card || Card.new(:name=>name, :missing=>true, :typecode=>'Basic', :skip_defaults=>true)
      if template=test_card.template(reset=true) and template.hard_template? 
        args=[name, template.content, template.typecode]
        if cached_card
          cached_attrs = [:name, :content, :typecode].map{|attr| cached_card.send(attr)}
          return cached_card if args==cached_attrs
        end
        Card.new_virtual name, template.content, template.typecode
      elsif System.ok?(:administrate_users) and name.tag_name =~ /^\*(email)$/
        attr_name = $~[1]
        content = Card.retrieve_extension_attribute( name.trunk_name, attr_name ) || ""
        User.as(:wagbot) do
          Card.new_virtual name, content  
        end
      else
        return nil
      end
    end
    alias find_virtual pattern_virtual

    def retrieve_extension_attribute( cardname, attr_name )
      c = Card.fetch(cardname) and e = c.extension and e.send(attr_name)
    end

    def new_virtual(name, content, type='Basic')
      Card.new(:name=>name, :content=>content, :typecode=>type, :missing=>true, :virtual=>true, :skip_defaults=>true)
    end
  end
  
  def self.included(base)   
    super
    Card.extend(ClassMethods)
  end
end
