module Wagn::Card
 module ModuleMethods    

  def create_these( *args )                                                                                  
    definitions = args.size > 1 ? args : (args.first.inject([]) {|a,p| a.push({p.first=>p.last}); a })
    definitions.map do |input|
      final_args = {}
      input.each do |key, content|
        type, name = (key =~ /\:/ ? key.split(':') : ['Basic',key])   
        final_args.merge! :name=>name, :type=>type, :content=>content
      end
#      warn "final args for create_these: #{final_args.inspect}"    
      Card.create! final_args
    end
  end

  def valid_constant?(candidate)
    begin
      Card.const_defined?( candidate )
    rescue Exception => e
      return false
    end
    true
  end

  def generate_codename_for(cardname)
    codename = cardname.gsub(/^\W+|\W+$/,'').gsub(/\W+/,'_').camelize   
    base, i = codename, 1
    while codename_unavailable?(codename)  
      codename = base+i.to_s
      i+=1
    end
    codename
  end
  
  def codename_unavailable?(codename)
    Card.find_by_codename(codename) || ::Cardtype.find_by_class_name(codename)
  end
   
  def default_typecode_key
    "Basic"
  end
 end
end    


