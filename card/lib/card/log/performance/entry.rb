class Card::Log::Performance
  class Entry
    attr_accessor :level, :valid, :context, :parent, :children_cnt, :duration, :children
    attr_reader :message, :category, :category_duration

    def initialize( parent, level, args )
      @start = Time.new
      start_category_timer
      @message = "#{ args[:title] ||  args[:method] || '' }"
      @message += ": #{ args[:message] }" if args[:message]
      @details = args[:details]
      @context = args[:context]
      @category = args[:category]

      @level = level
      @duration = nil
      @valid = true
      @parent = parent
      @children_cnt = 0
      @children = []
      if @parent
        @parent.add_children self
        #@sibling_nr = @parent.children_cnt
      end
    end

    def add_children child=false
      @children_cnt += 1
      @children << child if child
    end

    def delete_children child=false
      @children_cnt -= 1
      @children.delete child if child

    end

    def has_younger_siblings?
      @parent && @parent.children_cnt > 0 #@sibling_nr
    end

    def start_category_timer
      @category_duration = 0
      @category_start = Time.now
    end

    def pause_category_timer
      save_category_duration
    end

    def save_category_duration
      if @category
        @category_duration += (Time.now - @category_start) * 1000
      end
    end

    def continue_category_timer
      if @category
        @category_start = Time.now
      end
    end

    def save_duration
      save_category_duration
      @duration = (Time.now - @start) * 1000
    end

    def delete
      @valid = false
      @parent.delete_children(self) if @parent
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
    def to_html
      @to_html ||= begin
        msg = "<span title='#{@details}'>"
        msg += @message if @message
        msg += "<span class='badge #{"badge-danger" if @duration > 100}'> %d.2ms </span>" % @duration if @duration
        msg += '</span>'
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
end