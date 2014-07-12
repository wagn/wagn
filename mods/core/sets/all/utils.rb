
module ClassMethods
  
  def empty_trash
    Card.where(:trash=>true).delete_all
    Card::Revision.delete_cardless
    Card::Reference.repair_missing_referees
    Card.delete_trashed_files
  end
  
  def delete_trashed_files #deletes any file not associated with a real card.
    dir = Wagn.paths['files'].existent.first
    card_ids = Card.connection.select_all( %{ select id from cards where trash is false } ).map( &:values ).flatten
    file_ids = Dir.entries( dir )[2..-1].map( &:to_i )
    file_ids.each do |file_id|
      if !card_ids.member?(file_id)
        raise Card::Error, "Narrowly averted deleting current file" if Card.exists?(file_id) #double check!
        FileUtils.rm_rf "#{dir}/#{file_id}", :secure => true
      end
    end
  end
  
  def delete_tmp_files id=nil
    dir = Wagn.paths['files'].existent.first + '/tmp'
    dir += "/#{id}" if id
    FileUtils.rm_rf dir, :secure=>true
  rescue
    Rails.logger.info "failed to remove tmp files"
  end
  
  
  def merge_list attribs, opts
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
  end    
    
  
  def merge name, attribs={}, opts={}
    card = fetch name, :new=>{}
    
    if opts[:pristine] && !card.pristine?
      false
    else
      card.attributes = attribs
      card.save!
    end
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

