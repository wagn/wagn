module Wagn
  class Dumper
    def initialize(fh=nil, args={})
      @fh = fh || STDOUT
      @author_names = {}            
      @card_names = {}
    end
    
    def dump_yaml() dump(:yaml) end
    def dump_xml()  dump(:xml) end
    def dump_json() dump(:json) end
                
    private
    
    def dump(method)
      @data={'revisions'=>[]}
      last_revision_hash do |data|
        @data['revisions'] << data
      end 
      @fh.write( @data.send("to_#{method}") )
    end

    def last_revision_hash
      ::Revision.find(:all, :select => "cards.name, cards.type, card_id, created_by, content, revisions.created_at, max(date(created_at))",
                      :group => "card_id HAVING date(revisions.created_at) = max(date(revisions.created_at))", :include=>['card']).each do |rev|
       if rev.card
        yield( rev_to_hash(rev) )
       end
      end
    end
      
    def each_revision_hash
      Card::Revision.find(:all, :include=>['card']).each do |rev|
       if rev.card
        yield( rev_to_hash(rev) )
       end
      end
    end
      
    def rev_to_hash( rev )
      c = rev.card
      {
        'name'=> c.name,
        'type'=> c.type,
        'content'=>rev.content,
        'date'=>rev.created_at,
        'author'=>get_user(rev)
      }
    end         
    
    def get_card(rev)
      id = rev.attributes['card_id']
      unless @card_names[id]
        @card_names[id] = rev.card.name
      end
      @card_names[id]
    end

    def get_user(rev)
      id = rev.attributes['creator_id']
      if !@author_names[id]
        @author_names[id] = rev.author.name
      end
      @author_names[id]
    end
    
  end
end
