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
  
  def self.render_chunk action, text
    case action
    when '+'      then render_added_chunk text
    when :added   then render_added_chunk text
    when '-'      then render_deleted_chunk text
    when :deleted then render_deleted_chunk text
    else text
    end
  end

  class DiffBuilder
    attr_reader :summary, :complete
    
    # diff options 
    # :format  => :html|:text|:pointer|:raw 
    #   :html    = maintain html structure, but compare only content
    #   :text    = remove all html tags; compare plain text
    #   :pointer = remove all double square brackets
    #   :raw     = escape html tags and compare everything
    #
    # :summary => {:length=><number> , :joint=><string> }
    
    def initialize(old_version, new_version, opts={})
      @new_version = new_version
      @old_version = old_version
      @lcs_opts = lcs_opts_for_format opts[:format]
      @lcs_opts[:summary] = opts[:summary]
      @dels_cnt = 0
      @adds_cnt = 0
      
      if not @new_version
        @complete = ''
        @summary  = ''
      else
        lcs_diff
      end
    end

    def red?
      @dels_cnt > 0 
    end
    
    def green?
      @adds_cnt > 0 
    end
    
    def lcs_opts_for_format format
      opts = {}
      case format
      when :html
        opts[:exclude] = /^</
      when :text
        opts[:reject] =  /^</
        opts[:postprocess] = Proc.new do |word|
          word.gsub("\n",'<br>')
        end
      when :pointer
        opts[:preprocess] = Proc.new do |word|
          word.gsub('[[','').gsub(']]','')
        end
      else #:raw
        opts[:preprocess] = Proc.new do |word|
          CGI::escapeHTML(word)
        end
      end
      opts
    end
    
    def lcs_diff
      @lcs = LCS.new(@old_version, @new_version, @lcs_opts)
      @summary  = @lcs.summary
      @complete = @lcs.complete
      @dels_cnt = @lcs.dels_cnt
      @adds_cnt = @lcs.adds_cnt
    end

    
    class LCS
      attr_reader :adds_cnt, :dels_cnt
      def initialize old_text, new_text, opts, summary=nil
        @reject_pattern  = opts[:reject]        # regex; remove match completely from diff
        @exclude_pattern = opts[:exclude]       # regex; put back to the result after diff
        @preprocess      = opts[:preprocess]    # block; called with every word
        @postprocess     = opts[:postprocess]   # block; called with complete diff
        
        @adds_cnt = 0
        @dels_cnt = 0
        
        @splitters = %w( <[^>]+>  \[\[[^\]]+\]\]  \{\{[^}]+\}\}  \s+ )
        @disjunction_pattern = /^\s/ 
        @summary ||= Summary.new opts[:summary]
        if not old_text
          list = split_and_preprocess(new_text)
          if @exclude_pattern
            list = list.reject{ |word| word.match @exclude_pattern }
          end
          text = postprocess list.join
          @result = added_chunk text
          @summary.add text
        else
          init_diff old_text, new_text
          run_diff
        end
      end
      
      def summary 
        @summary.result
      end
      
      def complete
        @result
      end
      
      private 
      
      def init_diff old_text, new_text
        @adds = []
        @dels = []
        @result = ''
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
        
      def run_diff 
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
      
        @result = postprocess @result
      end

      
      def added_chunk text, count=true
        @adds_cnt += 1 if count
        Card::Diff.render_added_chunk text
      end
  
      def deleted_chunk text, count=true
        @dels_cnt += 1 if count
        Card::Diff.render_deleted_chunk text
      end

      
      def write_unchanged text
        @result << text
        @summary.omit
      end
      
      def write_dels
        if !@dels.empty?
          @result << deleted_chunk(@dels.join)
          @summary.delete @dels.join
          @dels = []
        end
      end
      
      def write_adds
        if !@adds.empty?
          @result << added_chunk(@adds.join)
          @summary.add @adds.join
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
      
      def process_word word
        process_element word.old_element, word.new_element, word.action
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
          write_unchanged new_element
          @excludees[:new].word_step
        end
      end
      
      def separate_comparables_from_excludees text
        # return two arrays, one with all words, one with pairs (index in word list, html_tag)
        list = split_and_preprocess text
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
    
      def split_and_preprocess text
        splitted = split_to_list_of_words(text).select do |s|
          s.size > 0 and (!@reject_pattern or !s.match @reject_pattern)
        end
        @preprocess ? splitted.map {|s| @preprocess.call(s) } : splitted
      end
    
      def split_to_list_of_words text
        split_regex = /(#{@splitters.join '|'})/
        text.split(split_regex)
      end
          
      def preprocess text
        if @preprocess
          @preprocess.call(text)
        else
          text
        end
      end
      
      def postprocess text
        if @postprocess
          @postprocess.call(text)
        else
          text
        end
      end
      
  
      class Summary 
        def initialize opts
          opts ||= {}
          @remaining_chars = opts[:length] || 50 
          @joint = opts[:joint] || '...'
          
          @summary = nil
          @chunks = []
        end
        
        def result
          @summary ||= render_chunks
        end
        
        def add text
          add_chunk text, :added
        end
        
        def delete text
          add_chunk text, :deleted
        end
        
        def omit 
           if @chunks.empty? or @chunks.last[:action] != :ellipsis
            add_chunk @joint, :ellipsis
          end
        end  
        
        private
        
        def add_chunk text, action
          if @remaining_chars > 0
            @chunks << {:action => action, :text=>text}
            @remaining_chars -= text.size
          end
        end
        
        def render_chunks
          truncate_overlap
          @chunks.map do |chunk|
              Card::Diff.render_chunk chunk[:action], chunk[:text]
          end.join 
        end
   
        def truncate_overlap
          if @remaining_chars < 0
            if @chunks.last[:action] == :ellipsis
              @chunks.pop
              @remaining_chars += @joint.size
            end
            
            index = @chunks.size - 1
            while @remaining_chars < @joint.size and index >= 0
              if @remaining_chars + @chunks[index][:text].size == @joint.size   # d
                @chunks.pop
                if index-1 >= 0 
                  if @chunks[index-1][:action] == :added
                    @chunks << {:action => :ellipsis, :text=>@joint}
                  elsif @chunks[index-1][:action] == :deleted
                    @chunks << {:action => :added, :text=>@joint}
                  end
                end
                break
              elsif @remaining_chars + @chunks[index][:text].size > @joint.size
                @chunks[index][:text] =  @chunks[index][:text][0..(@remaining_chars-@joint.size-1)] 
                @chunks[index][:text] += @joint
                break
              else
                @remaining_chars += @chunks[index][:text].size
                @chunks.delete_at(index)
              end
              index -= 1
            end
          end
        end 
        
      end
     
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
      
    end
  end
end

