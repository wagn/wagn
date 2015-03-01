require 'csv'

class Card::Log

  class Request

    def self.path
      path = (Card.paths['request_log'] && Card.paths['request_log'].first) || File.dirname(Card.paths['log'].first)
      filename = "#{Date.today}_#{Rails.env}.csv"
      File.join path, filename
    end

    def self.write_log_entry controller
      return if controller.env["REQUEST_URI"] =~ %r{^/files?/}

      controller.instance_eval do
        log = []
        log << (Card::Env.ajax? ? "YES" : "NO")
        log << env["REMOTE_ADDR"]
        log << Card::Auth.current_id
        log << card.name
        log << action_name
        log << params['view'] || (s = params['success'] and  s['view'])
        log << env["REQUEST_METHOD"]
        log << status
        log << env["REQUEST_URI"]
        log << DateTime.now.to_s
        log << env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(/^[a-z]{2}/).first
        log << env["HTTP_REFERER"]

        File.open(Card::Log::Request.path, "a") do |f|
          f.write CSV.generate_line(log)
        end
      end
    end

  end


  class Performance
    # To enable logging add a performance_logger hash to your configuration and change the log_level to :wagn
    # config options
    #
    # Example:
    # config.performance_logger = {
    #     :min_time => 100,                              # show only method calls that are slower than 100ms
    #     :max_depth => 3,                               # show nested method calls only up to depth 3
    #     :details=> true                                # show method arguments and sql
    #     :methods => [:event, :search, :fetch, :view],  # choose methods to log
    # }
    #
    # If you give :methods a hash you can log arbitrary methods. The syntax is as follows:
    #   class =>  method type => method name => log options
    #
    # Example:
    #   Card  => {
    #              :instance  => [ :fetch, :search ],
    #              :singleton => { :fetch    => { :title => 'Card.fetch' } },
    #              :all       => {
    #                              :fetch    => {
    #                                             :message => 2                           # use second argument passed to fetch
    #                                             :details => :to_s                       # use return value of to_s in method context
    #                                             :title => proc { |method_context| method_context.name }
    #                                           },
    #                            },
    #            },
    #
    # class, method type and log options are optional.
    # Default values are 'Card', ':all'  and { :title => method name, :message => first argument, :details=> remaining arguments }.
    # For example [:fetch] is equivalent to Card => { :all => { :fetch  => { :message=>1, :details=>1..-1 } }

    DEFAULT_CLASS           = Card
    DEFAULT_METHOD_TYPE     = :all
    DEFAULT_METHOD_OPTIONS  = {
                                :title   => :method_name,
                                :message => 1,
                                :details => 1..-1,
                                :context => nil
                              }

    SPECIAL_METHODS     = [:search, :view, :event]  # these methods have already a Wagn.with_logging block
                                                        # we don't have to monkey patch them, only turn the logging on with adding the symbol to the methods hash



    TAB_SIZE = 3
    @@log = []
    @@context_entries = []
    @@active_entries = []
    @@current_level = 0


    class << self
      def load_config args
        @details   = args[:details]   || false
        @max_depth = args[:max_depth] || false
        @min_time  = args[:min_time]  || false
        @enabled_methods = ::Set.new
        prepare_methods_for_logging args[:methods] if args[:methods]
      end
      
      def start args={}
        @@current_level = 0
        @@log = []
        @@context_entries = []
        @@active_entries = []
        @@first_entry = new_entry(args)
      end

      def stop
        while (entry = @@context_entries.pop) do
          finish_entry entry
        end
        if @@first_entry
          @@first_entry.save_duration
          finish_entry @@first_entry
        end
        print_log
      end

      
      def with_timer method, args, &block
        if args[:context]

          # if the previous context was created by an entry on the same level
          # then finish the current context if it's a different context
          if @@context_entries.last && @@current_level == @@context_entries.last.level+1 &&
                                       args[:context] != @@context_entries.last.context
            finish_entry @@context_entries.pop
          end

          # start new context if it's different from the parent context
          if  @@context_entries.empty? || args[:context] != @@context_entries.last.context
            @@context_entries << new_entry( :title=>'process', :message=>args[:context], :context=>args[:context] )
          end
        end

        timer = new_entry args.merge(:method=>method )
        begin
          result = block.call
        ensure
          timer.save_duration
          finish_entry timer

          # finish all deeper nested contexts
          while @@context_entries.last && @@context_entries.last.level >= @@current_level
            finish_entry @@context_entries.pop
          end
          # we don't know whether the next entry will belong to the same context or will start a new one
          # so we save the time
          @@context_entries.last.save_duration if @@context_entries.last
        end
        result
      end
      

      def enable_method method_name
        @enabled_methods ||= ::Set.new
        @enabled_methods << method_name
      end

      def enabled_method? method_name
        @enabled_methods && @enabled_methods.include?(method_name)
      end

      private

      def print_log
        @@log.each do |entry|
          Rails.logger.wagn entry.to_s! if entry.valid
        end
      end

      def new_entry args
        args.delete(:details) unless @details
        level = @@current_level

        last_entry = @@active_entries.last
        parent = if last_entry
            last_entry.level == level ? last_entry.parent : last_entry
          end

        @@log << Card::Log::Performance::Entry.new(parent, level, args )
        @@current_level += 1
        @@active_entries << @@log.last

        @@log.last
      end

      def finish_entry entry
        if (@max_depth && entry.level > @max_depth) || (@min_time && entry.duration < @min_time)
          entry.delete
        end
        @@active_entries.pop
        @@current_level -= 1
      end
      
      def prepare_methods_for_logging args
        classes = hashify_and_verify_keys( args, DEFAULT_CLASS ) do |key|
          key.kind_of?(Class) || key.kind_of?(Module)
        end

        classes.each do |klass, method_types|
          klass.extend BigBrother  # add watch methods

          method_types = hashify_and_verify_keys( method_types, DEFAULT_METHOD_TYPE ) do |key|
            [:all, :instance, :singleton].include? key
          end

          method_types.each do |method_type, methods|
            methods = hashify_and_verify_keys methods
            methods.each do |method_name, options|
              klass.watch_method  method_name, method_type, DEFAULT_METHOD_OPTIONS.merge(options)
            end
          end

        end
      end


      def hashify_and_verify_keys args, default_key=nil
        if default_key
          case args
            when Symbol
              { default_key => [ args ] }
            when Array
              { default_key => args }
            when Hash
              if block_given?
                args.keys.select{ |key| !(yield(key)) }.each do |key|
                  args[default_key] = { key => args[key] }
                  args.delete key
                end
              end
              args
            end
        else
          case args
          when Symbol
            { args => {} }
          when Array
            args.inject({}) do |h, key|
              h[key] = {}
              h
            end
          else
            args
          end
        end
      end

    end
    
    
    class Entry
      attr_accessor :level, :valid, :context, :parent, :children_cnt, :duration

      def initialize( parent, level, args )
        @start = Time.new
        @message = "#{ args[:title] ||  args[:method] || '' }"
        @message += ": #{ args[:message] }" if args[:message]
        @details = args[:details]
        @context = args[:context]
        @level = level
        @duration = nil
        @valid = true
        @parent = parent
        @children_cnt = 0
        if @parent
          @parent.add_children
          #@sibling_nr = @parent.children_cnt
        end
      end

      def add_children
        @children_cnt += 1
      end

      def delete_children
        @children_cnt -= 1
      end

      def has_younger_siblings?
        @parent && @parent.children_cnt > 0 #@sibling_nr
      end

      def save_duration
        @duration = (Time.now - @start) * 1000
      end

      def delete
        @valid = false
        @parent.delete_children if @parent
      end


      # deletes the children counts in order to print the tree;
      # must be called in the right order
      #
      # More robuts but more expensive approach: use @sibling_nr instead of counting @children_cnt down,
      # but @sibling_nr has to be updated for all siblings of an entry if the entry gets deleted due to
      # min_time or max_depth restrictions in the config, so we have to save all children relations for that
      def to_s!
        @to_s ||= begin
          msg = indent
          msg += "(%d.2ms) " % @duration if @duration
          msg += @message if @message

          if @details
            msg +=  ", " + @details.to_s.gsub( "\n", "\n#{ indent(false) }#{' '* TAB_SIZE}" )
          end
          @parent.delete_children if @parent
          msg
        end
      end

      private

      def indent link=true
        @indent ||= begin
          if @level == 0
            "\n"
          else
            res = '  '
            res += (1..level-1).inject('') do |msg, index|
                if younger_siblings[index]
                  msg <<  '|' + ' ' * (TAB_SIZE-1)
                else
                  msg << ' ' * TAB_SIZE
                end
              end

            res += link ? '|--' : '  '
          end
        end
      end

      def younger_siblings
        res = []
        next_parent = self
        while (next_parent)
          res << next_parent.has_younger_siblings?
          next_parent = next_parent.parent
        end
        res.reverse
      end

    end
    
    
    module BigBrother

      def watch_method method_name, method_type=:all, options={}
        Card::Log::Performance.enable_method method_name

        if !SPECIAL_METHODS.include? method_name
          if method_type == :all || method_type == :singleton
            add_singleton_logging method_name, options
          end
          if method_type == :all || method_type == :instance
            add_instance_logging method_name, options
          end
        end
      end

      def watch_instance_method *names
        names.each do |name|
          watch_method name, :instance
        end
      end

      def watch_singleton_method *names
        names.each do |name|
          watch_method name, :singleton
        end
      end

      def watch_all_instance_methods
        watch_instance_method *instance_methods
      end

      def watch_all_singleton_methods
        fragile_methods = [:default_scope, :default_scopes, :default_scopes=]  # if I touch these methods ActiveRecord breaks
        watch_singleton_method *(singleton_methods - fragile_methods)
      end

      def watch_all_methods
        watch_all_instance_methods
        watch_all_singleton_methods
      end

      private

      def add_singleton_logging method_name, options
        return unless singleton_class.method_defined? method_name
        m = method(method_name)
        add_logging method_name, :define_singleton_method, options do |bind_object, args, &block|
          m.call(*args, &block)
        end
      end

      def add_instance_logging  method_name, options
        return unless method_defined? method_name
        m = instance_method(method_name)
        add_logging method_name, :define_method, options do  |bind_object, args, &block|
          m.bind(bind_object).(*args, &block)
        end
      end

      def add_logging method_name, define_method, options, &bind_block
        send(define_method, method_name) do |*args, &block|
          log_args = {}
          options.each do |key,value|
            log_args[key] = case value
              when Integer then args[value-1]
              when Range   then args[value]
              when Symbol  then eval(value.to_s)
              when Proc    then value.call(self)
              else              value
              end
          end
          Card::Log::Performance.with_timer(method_name, log_args) do
            bind_block.call(self, args, &block)
          end
        end
      end

      def log_options_variable_name method_name, define_method
        "@_#{self.class.name}_#{method_name.hash.to_s.sub(/^-/,'_')}_#{define_method}_logging_options".to_sym
      end

    end
    
    
  end

end

class Card
  def self.with_logging method, opts, &block
    if Card::Log::Performance.enabled_method? method
      Card::Log::Performance.with_timer(method, opts) do
        block.call
      end
    else
      block.call
    end
  end
end

