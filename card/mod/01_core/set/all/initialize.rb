JUNK_INIT_ARGS = %w{ missing skip_virtual id }

module ClassMethods
  def new args={}, options={}
    args = (args || {}).stringify_keys
    JUNK_INIT_ARGS.each { |a| args.delete(a) }
    %w{ type type_code }.each { |k| args.delete(k) if args[k].blank? }
    args.delete('content') if args['attach'] # should not be handled here!
    super args
  end
end

def initialize args={}
  args['name']    = args['name'   ].to_s
  args['type_id'] = args['type_id'].to_i

  args.delete('type_id') if args['type_id'] == 0 # can come in as 0, '', or nil
  @type_args = {
    :type      => args.delete('type'     ),
    :type_code => args.delete('type_code'),
    :type_id   => args[       'type_id'  ]
  }
  
  args['db_content'] = args.delete('content') if args['content']

  #FIXME -- too much of the above is duplicated by assign_attributes (tracked_attributes.rb)

  @supercard = args.delete 'supercard' # must come before name =
  skip_modules = args.delete 'skip_modules'

  super args # ActiveRecord #initialize
  
  if tid = get_type_id( @type_args )
    self.type_id = tid
  end
  
  include_set_modules unless skip_modules
  self
end

def include_set_modules
  unless @set_mods_loaded
    set_modules.each do |m|
      singleton_class.send :include, m
    end
    @set_mods_loaded=true
  end
  self
end
