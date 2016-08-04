=begin

# following may be useful, but is neither tested nor in use

def card_attributes
  if Card::Set.traits
    set_modules.each do |mod|
      if mod_traits = Card::Set.traits[mod]
        return mod_traits
      end
    end
  end
  nil
end

def trait_var? var_name
  !instance_variable_get( var_name ).nil?
end

=end

def trait_var _var_name, &_block
  # FIXME: - following optimization attempt needs to handle cache clearing!
  #  instance_variable_get var_name or begin
  #    instance_variable_set var_name, block_given? ? yield : raise("no block?")
  #  end
  yield
end

# FIXME: -this needs a better home!
def format opts={}
  opts = { format: opts.to_sym } if [Symbol, String].member? opts.class

  Card::Format.new self, opts
end
