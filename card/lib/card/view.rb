require_dependency "card/view/visibility"
require_dependency "card/view/fetch"
require_dependency "card/view/cache"
require_dependency "card/view/stub"
require_dependency "card/view/options"

class Card
  class View
    include Visibility
    include Fetch
    include Cache
    include Stub
    include Options
    extend Cache::ClassMethods

    attr_reader :format, :parent, :card

    def self.canonicalize view
      return if view.blank? # error?
      view.to_viewname.key.to_sym
    end

    def initialize format, view, raw_options={}, parent=nil
      @format = format
      @raw_view = view
      @raw_options = raw_options
      @parent = parent

      @card = @format.card
      normalize_options
    end

    # handle rendering, including optional visibility, permissions, and caching
    def process
      process_live_options
      process_visibility_options
      return if optional? && hide?(requested_view)
      fetch { yield ok_view, foreign_live_options }
    end

    # the view to "attempt".  Typically the same as @raw_view, but @raw_view is
    # often overridden for the main view (top view of the main card on a page)
    def requested_view
      @requested_view ||= View.canonicalize live_options[:view]
    end

    # the final view.  can be different from @requested_view when there are
    # issues with permissions, recursions, unknown cards, etc.
    def ok_view
      @ok_view ||= format.ok_view requested_view,
                                  normalized_options[:skip_perms]
    end
  end
end
