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
      @main_view = normalized_options.delete :main_view
    end

    def process
      prepare_render
      return if optional? && hide?(ok_view)
      fetch do
        yield ok_view, foreign_options
      end
    end

    def prepare_render
      prep_options
      process_visibility_options
      @prepared = true
    end

    def original_view
      @original_view ||= View.canonicalize(@raw_view)
    end

    def requested_view
      @requested_view ||=
        View.canonicalize(prep_options[:view] || original_view)
    end

    def ok_view
      @ok_view ||=
        @format.ok_view requested_view, options[:skip_permissions]
    end

    def main_view?
      @main_view
    end
  end
end
