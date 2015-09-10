class HtmlFormatter

  def initialize performance_logger
    @log = performance_logger.log
    @category_log = performance_logger.category_log
  end

  def output
    @output ||=
      begin
        list =
          @log.inject([]) do |tree, entry|
            if !entry.parent && entry.message != 'fetch: performance_log'
              tree << entry
            end
            tree
          end
        list_to_accordion list
      end
  end

  private

  def list_to_accordion list
    list.map do |entry|
      if entry.children && entry.children.present?
        accordion_entry entry
      else
        simple_entry entry
      end
    end.join "\n"
  end


  def duration_badge duration
    if duration
      <<-HTML
        <span class='badge #{"badge-danger" if duration > 100} open-slow-items'> #{"%d.2ms" % duration}
        </span>
      HTML
    end
  end


  def panel_heading entry, collapse_id
    <<-HTML
      <h4 class="panel-title">
        <a data-toggle="collapse" data-parent="#accordion-#{collapse_id}" href="##{collapse_id}" aria-expanded="true" aria-controls="#{collapse_id}" class="show-fast-items">
          <span title='#{entry.details}'>
            #{entry.message}
          </span>
        </a>
        #{ duration_badge entry.duration}
      </h4>
      #{ extra_info entry }
    HTML
  end

  def extra_info entry
    if entry == @log.first
      cat_sum = ''
      @category_log.each_pair do |category, time|
        cat_sum << "<strong>%s:</strong> %d.2ms  " % [category, time]
      end
      <<-HTML
        #{cat_sum}
        <span class="pull-right">
          <a class="toggle-fast-items">hide < 100ms</a>
        </span>
      HTML
    end
  end

  def simple_entry entry
    <<-HTML
      <li class='list-group-item  #{ entry.duration > 100 ? 'panel-danger' : 'duration-ok'}'>
        <span title='#{entry.details}'>
          #{ entry.message }
        </span>
        #{ duration_badge entry.duration}
      </li>
    HTML
  end

  def accordion_entry entry
    panel_body = list_to_accordion entry.children
    collapse_id = entry.hash.to_s
    %{
      <div class="panel-group" id="accordion-#{collapse_id}" role="tablist" aria-multiselectable="true">
        <div class="panel panel-default #{ entry.duration > 100 ? 'panel-danger' : 'duration-ok'}">
          <div class="panel-heading" role="tab" id="heading-#{collapse_id}">
            #{ panel_heading entry, collapse_id }
          </div>
          <div id="#{collapse_id}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-#{collapse_id}">
            <div class="panel-body">
              #{ panel_body }
            </div>
          </div>
        </div>
      </div>
      }
  end
end
