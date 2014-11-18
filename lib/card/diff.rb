# -*- encoding : utf-8 -*-
module Card::Diff
  
  def self.complete a, b, opts={}
    DiffBuilder.new(a, b, opts).complete
  end
  
  def self.summary a, b, opts={}
    DiffBuilder.new(a, b, opts).summary
  end
  
  def self.render_added_chunk text
    "<ins class='diffins diff-green'>#{text}</ins>"
  end
  
  def self.render_deleted_chunk text, count=true
    "<del class='diffdel diff-red'>#{text}</del>"
  end

  class DiffBuilder
    def initialize(old_version, new_version, opts={})
      @new_version = new_version || ''
      @old_version = old_version
      @post_process = nil

      reject_pattern  = nil    # remove completely from diff
      exclude_pattern = nil  # put back to the result after diff
      pre_process     = nil
      case opts[:format]
      when :html
        exclude_pattern = /^</
      when :text
        reject_pattern = /^</
      else #:raw
        pre_process = Proc.new do |word|
          CGI::escapeHTML(word)
        end
      end
      @lcs = LCS.new(@old_version, @new_version, exclude_pattern, reject_pattern, pre_process)
      @summary = nil
      @complete = nil
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
  
    def complete opts
      @complete ||= begin 
        clear_stats
        if @old_version
          if @old_version.size > 1000 or opts[:fast]
            fast_diff
          else
            @lcs.diff
            @adds = @lcs.adds_cnt
            @dels = @lcs.dels_cnt
          end
        else
          added_chunk(@new_version) 
        end 
      end
    end
    
    class LCS
      
      class ExcludeeIterator     
        def initialize list
          @list = list
          @index = 0
          @chunk_index = 0
        end
        
        def word_step
          @chunk_index += 1
        end
        
        def next
          if @index < @list.size and @list[@index][:chunk_index] == @chunk_index
            res = @list[@index]
            @index += 1
            @chunk_index +=1
            res
          end
        end
      end
      
      
      attr_reader :result, :add_cnt, :dels_cnt, :summary
      def initialize old_text, new_text, excl_pattern = nil, rej_pattern = nil, pre_process=nil, post_process=nil
        @result = ''
        @adds = []
        @dels = []
        @adds_cnt = 0
        @dels_cnt = 0
        
        @splitters = %w( <[^>]+>  \[\[[^\]]+\]\]  \{\{[^}]+\}\}  \s+ )
        @disjunction_pattern = /^\s/ 
        @reject_pattern  = rej_pattern    # remove completely from diff
        @exclude_pattern = excl_pattern  # put back to the result after diff
        @pre_process = pre_process
        @post_process = post_process
        
        old_words, old_ex = separate_comparables_from_excludees old_text
        new_words, new_ex = separate_comparables_from_excludees new_text
        @words = {
          :old => old_words,
          :new => new_words
        }
        @excludees = {
          :old => ExcludeeIterator.new(old_ex),
          :new => ExcludeeIterator.new(new_ex)
        }
      end
      
      def added_chunk text, count=true
        @adds_cnt += 1 if count
        Card::Diff.render_added_chunk text
      end
  
      def deleted_chunk text, count=true
        @dels_cnt += 1 if count
        Card::Diff.render_deleted_chunk text
      end
  
      
      def write_dels
        if !@dels.empty?
          @result << deleted_chunk(@dels.join)
          @dels = []
        end
      end
      
      def write_adds
        if !@adds.empty?
          @result << added_chunk(@adds.join)
          @adds = []
        end
      end
      
      def write_excludees
        while ex = @excludees[:new].next
          @result << ex[:element]
        end
      end
      
      def del_old_excludees
        while ex = @excludees[:old].next
          if ex[:type] == :disjunction
            @dels << ex[:element]
          else
            write_dels
            @result << ex[:element]
          end
        end
      end
      
      def add_new_excludees
        while ex = @excludees[:new].next
          if ex[:type] == :disjunction
            @adds << ex[:element]
          else
            write_adds
            @result << ex[:element]
          end
        end
      end
      
      def process_element old_element, new_element, action
        case action
        when '-'
          @dels << old_element
          @excludees[:old].word_step
        when '+'
          @adds << new_element
          @excludees[:new].word_step
        when '!'
          @dels << old_element
          @adds << new_element
          @excludees[:old].word_step
          @excludees[:new].word_step
        else
          @result << new_element
          @excludees[:new].word_step
        end
      end
      
      def process_word word
        process_element word.old_element, word.new_element, word.action
      end
        
      def diff 
        prev_action = nil        
        ::Diff::LCS.traverse_balanced(@words[:old], @words[:new]) do |word|

          if prev_action 
            if prev_action != word.action and
              !(prev_action == '-' and word.action == '!') and 
              !(prev_action == '!' and word.action == '+')

              # delete and/or add section stops here; write changes to result
              write_dels
              write_adds
                  
              write_excludees # new neutral section starts, we can just write excludees to result
              
            else # current word belongs to edit of previous word
              case word.action
              when '-'
                del_old_excludees
              when '+'
                add_new_excludees
              when '!'
                del_old_excludees
                add_new_excludees
              else
                write_excludees
              end             
            end
          else
            write_excludees
          end
          
          process_word word
          prev_action = word.action      
        end
        write_dels
        write_adds
        write_excludees
      
        @result = @post_process.call(@result) if @post_process
        @result
      end
      
      def separate_comparables_from_excludees text
        # return two arrays, one with all words, one with pairs (index in word list, html_tag)
        list = split_to_list_of_words text
        if @exclude_pattern
          list.each_with_index.inject([[],[]]) do |res, pair|
            element, index = pair  
            if element.match @disjunction_pattern
              res[1] << {:chunk_index=>index, :element=>element, :type=>:disjunction}
            elsif element.match @exclude_pattern
              res[1] << {:chunk_index=>index, :element=>element, :type=>:excludee}
            else
              res[0] << element
            end
            res
          end
        else
          [list, []]
        end
      end
    
      def split_to_list_of_words text
        split_regex = /(#{@splitters.join '|'})/
        splitted = text.split(split_regex).select do |s|
            s.size > 0 and (!@reject_pattern or !s.match @reject_pattern)
          end
        if @pre_process
          splitted.map {|s| @pre_process.call(s) }
        else
          splitted
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
