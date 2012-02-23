# -*- encoding : utf-8 -*-
class Role < ActiveRecord::Base
  #acts_as_card_extension
  #has_and_belongs_to_many :users
  #cattr_accessor :cache
  
  #class << self
    #def find_configurables
      #FIXME: switch to +*roles search
      #Card.search(:refer_to => {:right=>'*roles'}, :return => :id).reject{|i| i==Card::AdminID}
      #@roles = Role.find :all, :conditions=>"codename <> 'admin'"
    #end  
    
    #def [](key)
      #if c = self.cache
        #c.read(key.to_s) || c.write(key.to_s, (Integer===key ? find(key) : find_by_codename(key.to_s)))
      #else
        #warn "no role cache #{key}"
        #(Integer===key ? find(key) : find_by_codename(key.to_s))
      #end
    #end
  #end
        
  #def task_list() (self.tasks || '').split "," end
  #def admin?()    codename == 'admin'          end
  #def cardname()  self.card.cardname           end  

end
