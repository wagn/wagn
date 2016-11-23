JUNK_INIT_ARGS = %w(missing skip_virtual id).freeze

module ClassMethods
  def new args={}, _options={}
    args = (args || {}).stringify_keys
    JUNK_INIT_ARGS.each { |a| args.delete(a) }
    %w(type type_code).each { |k| args.delete(k) if args[k].blank? }
    args.delete("content") if args["attach"] # should not be handled here!
    super args
  end
end

def initialize args={}
  initialize_name args
  initialize_content args
  @supercard = args.delete "supercard" # must come before name=

  handle_skip_args args do
    super args # ActiveRecord #initialize
  end
  self
end

def handle_skip_args args
  skip_modules = args.delete "skip_modules"
  skip_type_lookup = args["skip_type_lookup"]
  yield
  self.type_id = get_type_id_from_structure if !type_id && !skip_type_lookup
  include_set_modules unless skip_modules
end

def initialize_name args
  args["name"] = Card.compose_mark(args["name"]) if args["name"].is_a?(Array)
  args["name"] = args["name"].to_s
end

def initialize_content args
  args["db_content"] = args.delete("content") if args["content"]
end

def include_set_modules
  unless @set_mods_loaded
    set_modules.each do |m|
      singleton_class.send :include, m
    end
    assign_set_specific_attributes
    @set_mods_loaded = true
  end
  self
end
