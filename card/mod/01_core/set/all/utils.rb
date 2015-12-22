
module ClassMethods

  def empty_trash
    Card.delete_trashed_files
    Card.where(trash: true).delete_all
    Card::Action.delete_cardless
    Card::Reference.repair_missing_referees
    Card::Reference.delete_missing_referers
    Card.delete_tmp_files_of_cached_uploads
  end

  def delete_trashed_files #deletes any file not associated with a real card.
    dir = Card.paths['files'].existent.first
    trashed_card_sql = %{ select id from cards where trash is true }
    trashed_card_ids = Card.connection.select_all( trashed_card_sql ).map( &:values ).flatten.map &:to_i
    file_ids = Dir.entries( dir )[2..-1].map( &:to_i )
    file_ids.each do |file_id|
      if trashed_card_ids.member?(file_id)
        raise Card::Error, "Narrowly averted deleting current file" if Card.exists?(file_id) #double check!
        FileUtils.rm_rf "#{dir}/#{file_id}", secure: true
      end
    end
  end

  def delete_tmp_files_of_cached_uploads
    actions = Card::Action.find_by_sql "SELECT * FROM card_actions
      INNER JOIN cards ON card_actions.card_id = cards.id
      WHERE cards.type_id IN (#{Card::FileID}, #{Card::ImageID}) AND card_actions.draft = true"
    actions.each do |action|
      if older_than_five_days?(action.created_at) && card = action.card # we don't want to delete uploads in progress
        card.delete_files_for_action action
      end
    end
  end

  def merge_list attribs, opts={}
    unmerged = []
    attribs.each do |row|
      result = begin
        merge row['name'], row, opts
#      rescue => e
#        Rails.logger.info "merge_list problem: #{ e.message }"
#        false
      end
      unmerged.push row unless result == true
    end

    if unmerged.empty?
      Rails.logger.info "successfully merged all!"
    else
      unmerged_json = JSON.pretty_generate unmerged
      if output_file = opts[:output_file]
        ::File.open output_file, 'w' do |f|
          f.write unmerged_json
        end
      else
        Rails.logger.info "failed to merge:\n\n#{ unmerged_json }"
      end
    end
    unmerged
  end


  def merge name, attribs={}, opts={}
    puts "merging #{ name }"
    card = fetch name, new: {}

    if opts[:pristine] && !card.pristine?
      false
    else
      card.attributes = attribs
      card.save!
    end
  end


  def older_than_five_days? time
    Time.now - time > 432000
  end

end

def debug_type
  "#{type_code||'no code'}:#{type_id}"
end

def to_s
  "#<#{self.class.name}[#{debug_type}]#{self.attributes['name']}>"
end

def inspect
  "#<#{self.class.name}" + "##{id}" +
  "###{object_id}" + #"l#{left_id}r#{right_id}" +
  "[#{debug_type}]" + "(#{self.name})" + #"#{object_id}" +
  #(errors.any? ? '*Errors*' : 'noE') +
  (errors.any? ? "<E*#{errors.full_messages*', '}*>" : '') +
  #"{#{references_expired==1 ? 'Exp' : "noEx"}:" +
  "{#{trash&&'trash:'||''}#{new_card? &&'new:'||''}#{frozen? ? 'Fz' : readonly? ? 'RdO' : ''}" +
  "#{@virtual &&'virtual:'||''}#{@set_mods_loaded&&'I'||'!loaded' }:#{references_expired.inspect}}" +
  '>'
end

format :html do
  view :views_by_format do |args|
    format_views = self.class.ancestors.each_with_object({}) do |format_class, hash|
      views =
        format_class.instance_methods.map do |method|
          if method.to_s.match /^_view_(.+)$/
            "<li>#{$1}</li>"
          end
        end.compact.join "\n"
      if views.present?
        format_class.name.match /^Card(::Set)?::(.+?)$/ #::(\w+Format)
        hash[$2] = views
      end
    end
    accordion_group format_views
  end

  view :views_by_name do |args|
    views = methods.map do |method|
      if method.to_s.match /^_view_(.+)$/
        $1
      end
    end.compact.sort
    "<ul>
    #{ wrap_each_with :li, views }
    </ul>"
  end




  def accordion_group list, collapse_id=card.cardname.safe_key
    accordions = ''
    index = 1
    list.each_pair do |title, content|
      accordions << accordion(title, content, "#{collapse_id}-#{index}")
      index += 1
    end
    content_tag :div, accordions.html_safe, class: "panel-group", id: "accordion-#{collapse_id}", role: "tablist", 'aria-multiselectable'=>"true"
  end

  def accordion title, content, collapse_id=card.cardname.safe_key
    panel_body =
      case content
      when Hash
        accordion_group accordion(content, collapse_id)
      when Array
        content.join "\n"
      else
        content
      end
    %{
      <div class="panel panel-default">
        <div class="panel-heading" role="tab" id="heading-#{collapse_id}">
          <h4 class="panel-title">
            <a data-toggle="collapse" data-parent="#accordion-#{collapse_id}" href="##{collapse_id}" aria-expanded="true" aria-controls="#{collapse_id}">
              #{ title }
            </a>
          </h4>
        </div>
        <div id="#{collapse_id}" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-#{collapse_id}">
          <div class="panel-body">
            #{ panel_body }
          </div>
        </div>
      </div>
      }.html_safe
  end
end

