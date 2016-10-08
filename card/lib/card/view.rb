class Card
  class View
    def self.canonicalize view
      return if view.blank? # error?
      view.to_viewname.key.to_sym
    end

    def initialize format, view, args={}
      @format = format
      @original = view
      @original_args = args
    end

    def requested
      @requested ||= View.canonicalize @original
    end

    def approved
      @approved ||= @format.ok_view requested
    end

    def view_args
      @view_args ||= hash_args_from_originals
    end

    def approved_args
      default_method = "default_#{approved}_args"
      if @format.respond_to? default_method
        @format.send default_method, view_args
      end
      view_args
    end

    def hash_args_from_originals
      case (a = @original_args.clone)
      when nil   then {}
      when Hash  then a.clone
      when Array then a[0].merge a[1]
      else raise Card::Error, "bad view args: #{a}"
      end
    end

    def render
      if hide?
        puts "hiding #{requested}"
        return
      end
      approve!
      #      cached_render do
      #binding.pry


      yield approved, approved_args
      #      end
    end

    def approve!
    end

    # VISIBILITY

    def optional?
      @optional ||= view_args.delete :optional
    end

    def hide?
      !show?
    end

    def show?
      puts "visibility for #{requested}, #{@format.card.name} = #{optional?}, #{visibility_config == :show}"
      return true unless optional?
      # binding.pry

      visibility_config == :show
    end

    def raw_visibility_config
      @raw_visibility_config ||= view_args["optional_#{requested}".to_sym]
    end

    def visibility_config
      @visibility_config ||= (forced_visibility     ||
                              wagneered_visibility  ||
                              raw_visibility_config ||
                              default_visibility    ||
                              :show)
    end

    def forced_visibility
      puts "visibility_config = #{raw_visibility_config}"
      case raw_visibility_config
      when :always then :show
      when :never  then :hide
      else nil
      end
    end

    def default_visibility
      @default_visibility ||= view_args.delete :default_visibility
    end

    def wagneered_visibility
      [:show, :hide].each do |setting|
        view_list = visible_view_list view_args[setting]
        return setting if view_list.member? requested
      end
      nil
    end

    def visible_view_list val
      case val
      when NilClass then []
      when Array    then val
      when String   then val.split(/[\s,]+/)
      else raise Card::Error, "bad show/hide argument: #{val}"
      end.map { |view| View.canonicalize view }
    end

  end
end
