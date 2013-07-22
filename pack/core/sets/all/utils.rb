# -*- encoding : utf-8 -*-
module ClassMethods
  
  def empty_trash
    Card.where(:trash=>true).delete_all
    User.delete_cardless
    Card::Revision.delete_cardless
    Card::Reference.repair_missing_referees
    Card.delete_trashed_files
  end
  
  def delete_trashed_files #deletes any file not associated with a real card.
    dir = Wagn::Conf[:attachment_storage_dir]
    card_ids = Card.connection.select_all( %{ select id from cards where trash is false } ).map( &:values ).flatten
    file_ids = Dir.entries( dir )[2..-1].map( &:to_i )
    file_ids.each do |file_id|
      if !card_ids.member?(file_id)
        raise Wagn::Error, "Narrowly averted deleting current file" if Card.exists?(file_id) #double check!
        FileUtils.rm_rf("#{dir}/#{file_id}", :secure => true)
      end
    end
  end
  
  def merge name, attribs={}, opts={}
    Rails.logger.info "about to merge: #{name}, #{attribs}, #{opts}"
    card = fetch name, :new=>{}
    unless opts[:pristine] && !card.pristine?
      card.attributes = attribs
      card.save!
    end
  end
  
end

def debug_type
  "#{typecode||'no code'}:#{type_id}"
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