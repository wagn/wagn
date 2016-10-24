class Card
  class View
    module Cache
      CACHE_SETTING_NEST_LEVEL =
        { always: :full, nested: :off, never: :stub }.freeze

      def fetch &block
        level = cache_level
         # puts "#{@card.name}/#{original_view}" \
         #      " cache level #{level.to_s.upcase} :: "\
         #      " #{cache_key}\n-nonstandard=#{foreign_options}"
         #      # " depth = #{@format.instance_variable_get '@depth'}"
         #      # binding.pry if options[:nest_name] == "+*email"
        case level
        when :off  then yield
        when :full then cache_fetch(&block)
        when :stub then stub_nest
        else raise "Invalid cache level #{level}"
        end
      end

      def cache_fetch &block
        cached_view = progressively do
          self.class.cache.fetch cache_key, &block
        end
        return cached_view if self.class.in_progress?
        @format.complete_cached_view_render cached_view
      end

      def progressively
        self.class.progressively(self) { yield }
      end

      def stub_nest
        "<card-view>#{stub_json}</card-view>"
      end

      def stub_json
        JSON.generate stub_array
      end

      def stub_array
        [@card.cast, normalized_options, @format.mode]
      end

      def cache_level
        # return :off # unless Card.config.view_cache
        level_method = self.class.in_progress? ? :cache_nest : :cache_default
        # binding.pry if level_method == :cache_nest && @card.name == "*signin+*email"
        send "#{level_method}_level"
      end

      def cache_nest_level
        if ok_view == :too_deep
          :off
        elsif cacheable_nest_name? && cache_permissible?
          CACHE_SETTING_NEST_LEVEL[cache_setting]
        else
          :stub
        end
      end

      def cache_permissible?
        return false unless original_view == ok_view
        return false unless permissible_card_state?
        return true if options[:skip_permissions]
        view_permissions_ok?
      end

      def permissible_card_state?
        return false if @card.unknown?
        return false if @card.db_content_changed?
        # FIXME: might consider other changes as disqualifying, though
        # we should make sure not to disallow caching of virtual cards
        true
      end

      def view_permissions_ok?
        case Card::Format.perms[original_view]
        when :none      then true
        when :read, nil then anyone_can_read?
        else                 false
        end
      end

      def anyone_can_read?
        Card::Auth.as(:anonymous) { @card.ok? :read }
      end

      def cache_setting
        @format.view_cache_setting original_view
      end

      # "default" means not in the context of a nest within an active
      # cache result
      def cache_default_level
        ok_to_cache_independently? ? :full : :off
      end

      def ok_to_cache_independently?
        cache_setting == :always && foreign_options.empty? && cache_permissible?
      end

      # names
      def cacheable_nest_name?
        case options[:nest_name]
        when "_main" then @format.main?
        when "_user" then false
        else true
        end
      end

      def cache_strategy
        Card.config.view_cache
      end

      def cache_key
        [
          @card.key, @format.class, @format.mode, original_view, options
        ].map(&:to_s).join "-"
      end

      module ClassMethods
        def cache
          Card::Cache[Card::View]
        end

        def in_progress?
          @in_progress
        end

        def progressively voo
          return yield if @in_progress
          @in_progress = voo
          result = yield
          @in_progress = nil
          result
        end

        def fetch cache_key, &block
          send fetch_method, cache_key, &block
        end

        def fetch_method
          @fetch_method ||= begin
            config_option = Card.config.view_cache
            config_option == "debug" ? :verbose_fetch : :standard_fetch
          end
        end

        def reset
          cache.reset
        end

        def canonicalize view
          return if view.blank? # error?
          view.to_viewname.key.to_sym
        end

        private

        def standard_fetch key, &block
          cache.fetch key, &block
        end

        def verbose_fetch key, &block
          if cache.exist? key
            "fetched from view cache: #{cache.read key}"
          else
            "written to view cache: #{cache.fetch(key, &block)}"
          end
        end
      end
    end
  end
end
