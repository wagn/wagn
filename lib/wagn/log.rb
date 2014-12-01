
class Wagn::Log  
  TAB_SIZE = 2
  @@log = []
  @@last_toplevel_card = nil
  
  class << self
    
    # args: 
    # :method  => :view|:event|:fetch|:search
    # :cardname, :message, :details
    def start_block args  
      level = @@log.last ? @@log.last[:level] + 1 : 1
      @@log << args.merge( :start => Time.now, :level=>level, :subtree =>[] )
    end
    
    def finish_block
      log = @@log.pop
      duration = (Time.now - log[:start]) * 1000
      return if limit = Wagn.config.log[:limit] and limit > 0 and duration < limit
        
      log_msg = "#{ indent log[:level] }(%d.2ms) #{ log[:method] }: #{ log[:message] }" % duration
      log_msg += details log if Wagn.config.log[:details] 
      log_msg += subtree log
      
      if log_parent = @@log.last
        if sibling = log_parent[:subtree].last and ( sibling[:card] == log[:cardname] or not log[:cardname] )
          sibling[:lines] << log_msg
        else
          log_parent[:subtree] << {:card=>log[:cardname], :lines=>[log_msg]}
        end
      else
        if log[:cardname] and @@last_toplevel_card != log[:cardname]
          @@last_toplevel_card = log[:cardname]
          Rails.logger.wagn log[:cardname]
        end
        Rails.logger.wagn log_msg
      end
    end
    
    
    def indent level, args={}
       res = (' '*TAB_SIZE + '|') * level
       res += args[:no_link] ? '  ' : '--'
    end
    
    def details log
      if log[:details]
        ", " + log[:details].to_s.gsub( "\n", "\n#{ indent( log[:level]+1, :no_link=>true) }" )  
      else
        ''
      end
    end
    
    def subtree log
      if log[:subtree].present?
        "\n" + log[:subtree].map do |subentry| 
            msg = subentry[:card] ? "#{ indent(log[:level]) }#{ subentry[:card] }\n" : ''        
            msg += subentry[:lines].join("\n")
          end.join("\n")
      else
        ''
      end
    end
    
  end
  
end

