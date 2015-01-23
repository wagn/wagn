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
  

  class Performance
    TAB_SIZE = 3
    @@log = []
    @@context_entries = []
    @@active_entries = []
    @@current_level = 0
   
    def self.the_log
     @@the_log  
    end
    class Entry
      attr_accessor :level, :valid, :context, :parent, :children_cnt
      
      def initialize( parent, level, args )
        @start = Time.new
        @message = "#{ args[:method] }: #{ args[:message] }"
        @details = args[:details]
        @context = args[:context]
        @level = level
        @duration = nil
        @valid = true
        @parent = parent
        @children_cnt = 0
        @parent.add_children if @parent
      end

      def add_children
        @children_cnt += 1
      end
      
      def delete_children
        @children_cnt -= 1
      end
      
      def save_duration
        @duration = (Time.now - @start) * 1000
      end
      
      def delete
        @valid = false
        @parent.delete_children if @parent
      end

      
      # destroys the tree structure in order to print the tree
      # must be called in the right order
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
            res = if tree_info
                (0..level-1).inject('') do |msg, index|
                  if tree_info[index] && tree_info[index] > 0
                    msg << ' ' * (TAB_SIZE-1) + '|'
                  else
                    msg << ' ' * TAB_SIZE
                  end
                end
              else
                ' ' * TAB_SIZE *  level
              end
            res += link ? '--' : '  '
          end
        end
      end
      
      def tree_info
        ancestors.map do |entry|
          entry.children_cnt
        end
      end

      def ancestors
        res = []
        next_parent = @parent
        while (next_parent)
          res << next_parent
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
      
      def with_timer method, message, args, &block
        if args[:context] 
          
          # if the previous context was created by an entry on the same level 
          # the finish the context if it's a different context
          if @@context_entries.last && @@current_level == @@context_entries.last.level+1 && 
                                       args[:context] != @@context_entries.last.context
            finish_entry @@context_entries.pop
          end
          
          # start new context if it's different from the parent context
          if  @@context_entries.empty? || args[:context] != @@context_entries.last.context
            @@context_entries << new_entry( :method=>'process', :message=>args[:context], :context=>args[:context] )
          end
        end

        timer = new_entry args.merge(:method=>method, :message=>message)
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
        limit = Wagn.config.performance_logger[:limit]
        level = Wagn.config.performance_logger[:level]
        if (level && entry.level > level) || (limit && entry.duration < limit)
          entry.delete
        end
        @@active_entries.pop
        @@current_level -= 1
      end
      
    end
  end

end

