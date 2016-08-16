module ClassMethods
  def empty_trash
    Card.delete_trashed_files
    Card.where(trash: true).delete_all
    Card::Action.delete_cardless
    Card::Reference.unmap_if_referee_missing
    Card::Reference.delete_if_referer_missing
    Card.delete_tmp_files_of_cached_uploads
  end

  # deletes any file not associated with a real card.
  def delete_trashed_files
    trashed_card_ids = all_trashed_card_ids
    file_ids = all_file_ids
    dir = Cardio.paths["files"].existent.first
    file_ids.each do |file_id|
      next unless trashed_card_ids.member?(file_id)
      if Card.exists?(file_id) # double check!
        raise Card::Error, "Narrowly averted deleting current file"
      end
      FileUtils.rm_rf "#{dir}/#{file_id}", secure: true
    end
  end

  def all_file_ids
    dir = Card.paths["files"].existent.first
    Dir.entries(dir)[2..-1].map(&:to_i)
  end

  def all_trashed_card_ids
    trashed_card_sql = %( select id from cards where trash is true )
    sql_results = Card.connection.select_all(trashed_card_sql)
    sql_results.map(&:values).flatten.map(&:to_i)
  end

  def delete_tmp_files_of_cached_uploads
    actions = Card::Action.find_by_sql "SELECT * FROM card_actions
      INNER JOIN cards ON card_actions.card_id = cards.id
      WHERE cards.type_id IN (#{Card::FileID}, #{Card::ImageID})
      AND card_actions.draft = true"
    actions.each do |action|
      # we don't want to delete uploads in progress
      if older_than_five_days?(action.created_at) && (card = action.card)
        # we don't want to delete uploads in progress
        card.delete_files_for_action action
      end
    end
  end

  def merge_list attribs, opts={}
    unmerged = []
    attribs.each do |row|
      result = begin
        merge row["name"], row, opts
      end
      unmerged.push row unless result == true
    end

    if unmerged.empty?
      Rails.logger.info "successfully merged all!"
    else
      unmerged_json = JSON.pretty_generate unmerged
      report_unmerged_json unmerged_json, opts[:output_file]
    end
    unmerged
  end

  def report_unmerged_json unmerged_json, output_file
    if output_file
      ::File.open output_file, "w" do |f|
        f.write unmerged_json
      end
    else
      Rails.logger.info "failed to merge:\n\n#{unmerged_json}"
    end
  end

  def merge name, attribs={}, opts={}
    puts "merging #{name}"
    card = fetch name, new: {}
    [:image, :file].each do |attach|
      next unless attribs[attach] && attribs[attach].is_a?(String)
      attribs[attach] = ::File.open(attribs[attach])
    end
    if opts[:pristine] && !card.pristine?
      false
    else
      card.update_attributes! attribs
    end
  end

  def older_than_five_days? time
    Time.now - time > 432_000
  end
end

def debug_type
  "#{type_code || ''}:#{type_id}"
end

def to_s
  "#<#{self.class.name}[#{debug_type}]#{attributes['name']}>"
end

def inspect
  tags = []
  tags << "trash"    if trash
  tags << "new"      if new_card?
  tags << "frozen"   if frozen?
  tags << "readonly" if readonly?
  tags << "virtual"  if @virtual
  tags << "set_mods_loaded" if @set_mods_loaded

  error_messages = errors.any? ? "<E*#{errors.full_messages * ', '}*>" : ""

  "#<Card##{id}[#{debug_type}](#{name})#{error_messages}{#{tags * ','}}"
end
