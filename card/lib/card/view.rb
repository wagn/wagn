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
    extend Options::ClassMethods

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
      normalize_options!
    end

    def process
      prepare_render
      return if optional? && hide?(requested_view)
      fetch do
        yield ok_view, foreign_live_options
      end
    end

    def prepare_render
      prep_options
      process_visibility_options
      @prepared = true
    end

    def requested_view
      @requested_view ||= View.canonicalize normalized_options[:view]
    end

    def ok_view
      @ok_view ||=
        @format.ok_view requested_view, normalized_options[:skip_permissions]
    end
  end
end
