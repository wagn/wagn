module ClassMethods
  def delete_tmp_files id=nil
    dir = Cardio.paths["files"].existent.first + "/tmp"
    dir += "/#{id}" if id
    FileUtils.rm_rf dir, secure: true
  rescue
    Rails.logger.info "failed to remove tmp files"
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
    # puts "merging #{name}"
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

  def seed_test_db
    system "env RAILS_ENV=test bundle exec rake db:fixtures:load"
  end
end
