# the events method is a developer's tool for visualizing the event order
# for a given card.
# For example, from a console you might run
#
#   puts mycard.events :update
#
# to see the order of events that will be executed on mycard.
# The indention and arrows (^v) indicate event dependencies.
#
# Note: as of yet, the functionality is a bit rough.  It does not display events
# that are called directly from within other events,
# and certain event requirements (like the presence of a 'current_act') may
# prevent events from showing up in the tree.
def events action
  @action = action
  events = Card::Stage::STAGES.map { |stage| events_tree("#{stage}_stage") }
  @action = nil
  puts_events events
end

# private

def puts_events events, prefix="", depth=0
  r = ""
  depth += 1
  events.each do |e|
    space = " " * (depth * 2)

    # FIXME: this is not right.  before and around callbacks are processed in
    # declaration order regardless of kind.  not all befores then all arounds
    e[:before] && r += puts_events(e[:before], space + "v  ", depth)
    e[:around] && r += puts_events(e[:around], space + "vv ", depth)
    r += "#{prefix}#{e[:name]}\n"
    e[:after] && r += puts_events(e[:after].reverse, space + "^  ", depth)
  end
  r
end

def events_tree filt
  hash = { name: filt }
  if respond_to? "_#{filt}_callbacks"
    send("_#{filt}_callbacks").each do |callback|
      next unless callback.applies? self
      hash[callback.kind] ||= []
      hash[callback.kind] << events_tree(callback.filter)
    end
  end

  hash
end

class ::ActiveSupport::Callbacks::Callback
  def applies? object
    conditions_lambdas.all? { |c| c.call(object, nil) }
  end
end
