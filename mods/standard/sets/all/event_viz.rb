#~~~~~~~~~~~~~~~~
# EXPERIMENTAL
# the following methods are for visualing card events
#  not ready for prime time!

def events action
  @action = action
  root = _validate_callbacks + _save_callbacks
  events = [ events_tree(:validation), events_tree(:save)]
  @action = nil
  puts_events events
end

private

def puts_events events, prefix='', depth=0
  r = ''
  depth += 1
  events.each do |e|
    space = ' ' * (depth * 2)

    #FIXME - this is not right.  before and around callbacks are processed in declaration order regardless of kind.
    # not all befores then all arounds
    
    if e[:before]
      r += puts_events( e[:before], space+'v  ', depth)
    end
    if e[:around]
      r += puts_events( e[:around], space+'vv ', depth )
    end
    
    
    output = "#{prefix}#{e[:name]}"
    #warn output
    r+= "#{output}\n"
    
    if e[:after]
      r += puts_events( e[:after ].reverse, space+'^  ', depth )
    end
  end
  r
end

def events_tree filt
  hash = {:name => filt }
  if respond_to? "_#{filt}_callbacks"
    send( "_#{filt}_callbacks" ).each do |callback|
      next unless callback.applies? self
      hash[callback.kind] ||= []    
      hash[callback.kind] << events_tree( callback.filter )
    end
  end
  hash
end
#FIXME - this doesn't belong here!!

class ::ActiveSupport::Callbacks::Callback
  def applies? object
    object.send :eval, "value=nil;halted=false;!!(#{@compiled_options})"
  end
end

