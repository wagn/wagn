require 'csv'


class Wagn::Log

  class Request
    def self.path
      path = (Wagn.paths['request_log'] && Wagn.paths['request_log'].first) || File.dirname(Wagn.paths['log'].first)
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

        File.open(Wagn::Log::Request.path, "a") do |f|
          f.write CSV.generate_line(log)
        end
      end
    end

  end
  
  DEFAULT_LOG_CLASS           = Card
  DEFAULT_LOG_METHOD_TYPE     = :all
  DEFAULT_LOG_METHOD_OPTIONS  = { Card => {:fetch => {:message=>2, :details=>3 }} }
  
  # possible config options  
  #   class =>  method type => method name => log options
  # {
  #   Card  => { 
  #              :all       => { 
  #                              :fetch    => { 
  #                                             :message => 2                           # use second argument passed to fetch
  #                                             :details => :to_s                       # use return value of to_s in method context
  #                                             :title => proc { |method_context|  }
  #                                           },
  #                            },
  #              :singleton => [ :fetch, :search ],
  #              :instance  => { }
  #            },
  #  
  # class, method type and log options are optional. 
  # Default values are 'Card', ':all'  and { :title => method name, :message => first argument, :details=> remaining argumetns }, i.e.
  #
  #  [:fetch]  
  #  
  #  is equivalent to 
  #  
  #  Card => { :all => { :fetch  => { :me}}
  #              
  #  Wagn =>  { :cache => {  }   #
  #           },
  #
  #  
  #
  # }

  class Performance
    # def self.apply_defaults args
    #   args.each |klass, method_types| do
    #     default_klass = DEFAULT_LOG_OPTIONS[klass]
    #     method_types.each do |method_type, methods|
    #       default_method_type = default_klass[method_type]
    #       methods.each do ||
    #     end
    #   end
    # end
    
    def self.hashify_and_verify_keys args, default_key=nil
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
    
    def self.load_config args
      classes = hashify_and_verify_keys( args, DEFAULT_LOG_CLASS ) do |key|
        key.kind_of?(Class) || key.kind_of?(Module)
      end
      
      classes.each do |klass, method_types|
        klass.extend BigBrother
          
        method_types = hashify_and_verify_keys( method_types, DEFAULT_LOG_METHOD_TYPE ) do |key|
          [:all, :instance, :singleton].include? key
        end
               
        method_types.each do |method_type, methods|
          methods = hashify_and_verify_keys methods        
          methods.each do |method_name, options|
            logging_args = {
              :title  => :method_name,
              :message => :'args[0]',
              :details => :'args[1..-1]',
              :context => nil
            }
            options.each do |option_name, value|
              logging_args[option_name] = case value
                when Integer
                  :"args[#{value-1}]"
                when Symbol
                  :"send(:#{value})"
                else
                  value
                end
            end
            klass.watch_method  method_name, method_type, logging_args
          end
            
        end
      end

    end
    
    module BigBrother
      def add_to_config name
        Wagn.config.performance_logger ||= {}
        Wagn.config.performance_logger[:methods] ||= []
        Wagn.config.performance_logger[:methods] << name
      end
      
      def watch_method method_name, method_type, options
        add_to_config method_name
        if method_type == :all || method_type == :singleton
          add_singleton_logging method_name, options
        end
        if method_type == :all || method_type == :instance
          add_instance_logging method_name, options
        end
      end
      
      def add_singleton_logging method_name, options
        return unless singleton_class.method_defined? method_name
        m = method(method_name)
        add_logging method_name, :define_singleton_method, options do |bind_object, args, &block|
          m.call(*args, &block)
        end
      end
      #
      # def add_instance_logging  method_name, options
      #   #binding.pry
      #   return unless method_defined? method_name
      #   m = instance_method(method_name)
      #
      #   send(:define_method, method_name) do |*args, &block|
      #     #method = options[:method] ? eval(options[:method]) : method_name
      #     Rails.logger.wagn 'yesh'
      #     puts "####### multiple define #{method_name} #{options[:title]}"
      #     #if !self.class.class_variable_defined? "@@#{method_name}_#{define_method}_add_logging_options".to_sym
      #       hash = {}
      #       puts "defined new variable ############"
      #       options.each do |key,value|
      #         hash[key] = value.kind_of?(Symbol) ? eval(value) : value
      #       end
      #      #   self.class.class_variable_set("@@#{method_name}_#{define_method}_add_logging_options".to_sym, hash )
      #     #end
      #     o#ptions = self.class.class_variable_get "@@#{method_name}_#{define_method}_add_logging_options".to_sym
      #     Wagn::Log::Performance.with_timer(method_name, hash) do
      #       m.bind(self).(*args, &block)
      #     end
      #   end
      #
      #
      #
      #   add_logging method_name, :define_method, options do  |bind_object, args, &block|
      #     m.bind(bind_object).(*args, &block)
      #   end
      # end
  
      def add_instance_logging  method_name, options
        return unless method_defined? method_name
        m = instance_method(method_name)
        add_logging method_name, :define_method, options do  |bind_object, args, &block|
          m.bind(bind_object).(*args, &block)
        end
      end
      
      def options_variable_name method_name, define_method
        "@_#{method_name.hash}_#{define_method}_add_logging_options".to_sym
      end
        
      def add_logging method_name, define_method, options, &bind_block
        store_name = options_variable_name(method_name, define_method)
        send(define_method, method_name) do |*args, &block|
          
          if !self.class.instance_variable_defined? store_name
            hash = {}
            options.each do |key,value| 
              hash[key] = case value
                when Symbol then eval(value.to_s) 
                when Proc   then value.call(self)
                else             value
                end
            end
            self.class.instance_variable_set(store_name, hash )
          end
          options = self.class.instance_variable_get store_name
          Wagn::Log::Performance.with_timer(method_name, options) do
            bind_block.call(self, args, &block)
          end
        end
      end
      
      
      def watch_instance_method *names
        names.each do |name|
          add_to_config name
          m = instance_method(name)
          send(:define_method, name) do |*args, &block|
            Wagn.with_logging name, :message=>args[0], :details=>args[1..-1] do
              
              m.bind(self).(*args, &block)
            end
          end
        end
      end
  
      def watch_singleton_method *names
        names.each do |name|
          add_to_config name
          m = method(name)
          send(:define_singleton_method, name) do |*args, &block|
            Wagn.with_logging name, :message=>args[0], :details=>args[1..-1] do
              m.call(*args, &block)
            end
          end
        end
      end
  
      def watch_all_instance_methods
        watch_instance_method *instance_methods
      end
  
      def watch_all_singleton_methods
        fragile_methods = %i( default_scope default_scopes default_scopes= )  # if I touch these methods ActiveRecord breaks
        watch_singleton_method *(singleton_methods - fragile_methods)
      end
  
      def watch_all_methods
        watch_all_instance_methods
        watch_all_singleton_methods
      end
      
    end
    
    
    TAB_SIZE = 3
    @@log = []
    @@context_entries = []
    @@active_entries = []
    @@current_level = 0
   
    def self.the_log
     @@the_log  
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
          msg += if @duration
              "(%d.2ms) #{@message}" % @duration
            else
              @message
            end
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


    class << self
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
          # the finish the context if it's a different context
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

      private 
      
      def print_log
        @@log.each do |entry|
          Rails.logger.wagn entry.to_s! if entry.valid
        end
      end
      
      def new_entry args
        args.delete(:details) unless Wagn.config.performance_logger[:details]
        level = @@current_level
                
        last_entry = @@active_entries.last
        parent = if last_entry
            last_entry.level == level ? last_entry.parent : last_entry
          end
        
        @@log << Wagn::Log::Performance::Entry.new(parent, level, args )
        @@current_level += 1 
        @@active_entries << @@log.last
        
        @@log.last
      end
      
      def finish_entry entry
        min_time = Wagn.config.performance_logger[:min_time]
        max_depth = Wagn.config.performance_logger[:max_depth]
        if (max_depth && entry.level > max_depth) || (min_time && entry.duration < min_time)
          entry.delete
        end
        @@active_entries.pop
        @@current_level -= 1
      end
      
    end
  end

end

