# -*- encoding : utf-8 -*-
module Card::Diff
  
  def diff_complete(a, b)
    DiffBuilder.new(a, b).complete
  end
  
  def diff_summary(a, b)
    DiffBuilder.new(a, b).summary
  end
  
  def self.render_added_chunk text
    "<ins class='diffins diff-green'>#{text}</ins>"
  end
  
  def self.render_deleted_chunk text, count=true
    "<del class='diffdel diff-red'>#{text}</del>"
  end

  class DiffBuilder
    def initialize(old_version, new_version, opts={})
      @old_version, @new_version = old_version, new_version
      @opts = opts
      @new_version ||= ''
      if !opts[:compare_html]
        @old_version.gsub! /<[^>]*>/,'' if @old_version
        @new_version.gsub! /<[^>]*>/,''
      else
        @old_version = CGI::escapeHTML(@old_version) if @old_version
        @new_version = CGI::escapeHTML(@new_version)
      end
      @summary = false
      @complete = false
      @adds = 0
      @dels = 0
    end

    
    def red?
      complete and @dels > 0 
    end
    def green?
      complete and @adds > 0 
    end
    
    def summary  max_length = 50, joint = '...'
      @summary ||= begin
        if @old_version 
          last_position = 0
          remaining_chars = max_length
          res = ''
          new_aggregated_lcs.each do |change|
            if change[:position] > last_position
              res += joint
            end
            res += render_chunk change[:action], change[:text][0..remaining_chars], false
            remaining_chars -= change[:text].size
            if remaining_chars < 0  # no more space left
              res += joint
              break
            end
            last_position = change[:position]
          end
          res
        else
          res = @new_version[0..max_length]
          res += joint if @new_version.size > max_length 
          added_chunk(res, false) 
        end
      end
    end
  
    def complete
      @complete ||= begin 
        clear_stats
        if @old_version
          if @old_version.size < 1000
            complete_lcs_diff
          else
            fast_diff
          end
        else
          added_chunk(@new_version) 
        end 
      end
    end
    
    private
    
    def clear_stats
      @adds = 0
      @dels = 0
    end
    
    def added_chunk text, count=true
      @adds += 1 if count
      Card::Diff.render_added_chunk text
    end
  
    def deleted_chunk text, count=true
      @dels += 1 if count
      Card::Diff.render_deleted_chunk text
    end
  
  
    def render_chunk action, text, count=true
      case action
      when '+'      then added_chunk(text,count)
      when :added   then added_chunk(text,count)
      when '-'      then deleted_chunk(text,count)
      when :deleted then deleted_chunk(text,count)
      else text
      end
    end


    def better_complete_lcs_diff old_v=@old_version, new_v=@new_version
      last_position = 0
      old_v = old_v.split(' ')
      new_v = new_v.split(' ')
      res = ''
      dels = []
      adds = []
      prev_action = nil
      ::Diff::LCS.traverse_balanced(old_v, new_v) do |chunk|
        if prev_action and prev_action != chunk.action and
          !(prev_action == '-' and chunk.action == '!') and 
          !(prev_action == '!' and chunk.action == '+')
       
          if dels.present?
            res += deleted_chunk(dels.join(' '))
            dels = []
          end
          if !adds.empty?
            res += added_chunk(adds.join(' '))
            adds = []
          end
        end
        
        case chunk.action
        when '-' then dels += chunk.old_element
        when '+' then adds += chunk.new_element
        when '!' 
          dels += chunk.old_element
          adds += chunk.new_element
        else
          res += chunk.new_element
        end
        prev_action = chunk.action
      end
      res += deleted_chunk(dels.join(' ')) if dels.present?
      res += added_chunk(adds.join(' ')) if adds.present?
      res
    end
    
    
    
    def complete_lcs_diff old_v=@old_version, new_v=@new_version
      last_position = 0
      res = ''
      dels = ''
      adds = ''
      prev_action = nil
      ::Diff::LCS.traverse_balanced(old_v, new_v) do |chunk|
        if prev_action and prev_action != chunk.action and
          !(prev_action == '-' and chunk.action == '!') and 
          !(prev_action == '!' and chunk.action == '+')
       
          if dels.present?
            res += deleted_chunk(dels)
            dels = ''
          end
          if !adds.empty?
            res += added_chunk(adds)
            adds = ''
          end
        end
        
        case chunk.action
        when '-' then dels += chunk.old_element
        when '+' then adds += chunk.new_element
        when '!' 
          dels += chunk.old_element
          adds += chunk.new_element
        else
          res += chunk.new_element
        end
        prev_action = chunk.action
      end
      res += deleted_chunk(dels) if dels.present?
      res += added_chunk(adds) if adds.present?
      res
    end
    
    def complete_diffy_diff
      new_diffy.to_s(:html)
    end
    
    # combines diffy and lcs:
    # find with diffy line changes
    # whenever added lines follow immediately after deleted lines compare them with lcs
    def fast_diff
      lines = { :deleted => [], :added=>[], :unchanged=>[], :eof=>[] }
      prev_action = nil
      res = ''
      inspect = false
      new_diffy.each_chunk do |line|
        action = case line
        when /^\+/ then :added
        when /^-/ then :deleted
        when /^ / then :unchanged
        else 
          next
        end
        lines[action] << line.sub(/^./,'')
        if action == :added and prev_action == :deleted
          inspect = true
        end
    
        if inspect 
          if action != :added
            res += complete_lcs_diff lines[:deleted].join, lines[:added].join
            inspect = false
            lines[:deleted].clear
            lines[:added].clear
          end
        elsif prev_action and action != prev_action
          text = lines[prev_action].join
          res += render_chunk prev_action, text
          lines[prev_action].clear
        end
        prev_action = action
      end
      
      res += if inspect
        complete_lcs_diff lines[:deleted].join, lines[:added].join
      elsif lines[prev_action].present?
        render_chunk prev_action, lines[prev_action].join
      else
        ''
      end
    end
    
 
    def new_aggregated_lcs
      new_lcs.inject([]) do |res, change_block|
        last_action = nil
        change_block.each do |change| 
          if change.action != last_action
            res << { :position => change.position,
                   :action   => change.action,
                   :text   => change.element
                 }
          else
            res.last[:text] += change.element
          end
          last_action = change.action
        end
        res
      end
    end
    
    def new_diffy
      ::Diffy::Diff.new(@old_version, @new_version)
    end
  
    def new_lcs
      ::Diff::LCS.diff(@old_version,@new_version)
    end
  end
end
