module Wagn::Model::Collection
  module ClassMethods    
    def search(spec) 
      ::Wql.new(spec).run
    end

    def [](name) 
       Card.fetch(name, :skip_virtual=>true)
    end             

    def count_by_wql(spec)       
      spec.delete(:offset)
      search spec.merge(:return=>'count')
    end

    def find_by_name( name, opts={} ) 
      self.find_by_key_and_trash( name.to_cardname.to_key, false, opts.merge( :include=>:current_revision ))
    end
  end

  def item_names(args={})
    Wagn::Renderer.new(self)._render_raw.split /[,\n]/
  end
  
  def item_cards(args={})  ## FIXME this is inconsistent with item_names
    [self]
  end
  
  def extended_list context = nil
    context = (context ? context.cardname : self.cardname)
    args={ :limit=>'' }
    self.item_cards(args.merge(:context=>context)).map do |x|
      x.item_cards(args) 
    end.flatten.map do |x| 
      x.item_cards(args)
    end.flatten.map do |y|
      y.item_names(args)
    end.flatten
    # this could go on and on.  more elegant to recurse until you don't have a collection
  end
  
  def contextual_content(context_card=nil, renderer_args={})
    renderer_args[:not_current] = true
    Wagn::Renderer.new(context_card, renderer_args).process_content(
      Wagn::Renderer.new(self, :not_current=>true)._render_raw
    )
  end
  
  def update_search_index     
    return unless @name_or_content_changed && Wagn::Conf[:enable_postgres_fulltext]
    
    connection.execute %{
      update cards set indexed_content = concat( setweight( to_tsvector( name ), 'A' ), 
      to_tsvector( (select content from card_revisions where id=cards.current_revision_id) ) ),
      indexed_name = to_tsvector( name ) where id=#{self.id}
    }
    @name_or_content_changed = false
    true
  end

  def self.included(base)   
    super
    Card.extend(ClassMethods)
    base.after_save :update_search_index
  end
end
