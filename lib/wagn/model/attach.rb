module Wagn::Model::Attach
  def attach_array()
    c=self.content
    #warn "attach_array #{c}"
    if !(c=self.content) || c =~ /^\s*<img /
       ['','','']
      else
        c.split(/\n/) 
      end
  end

  def attach_array_set(i, v)
    #Rails.logger.debug "attach_set #{inspect} [#{i.inspect}] = #{v}"
    c = attach_array
    if c[i] != v
      c[i] = v
      #warn "update #{i} #{v}"
      self.content = c*"\n"
    end
  end
  def attach_file_name() attach_array[0] end
  def attach_content_type() attach_array[1] end
  def attach_file_size() attach_array[2] end

  def attach_file_name=(v) attach_array_set(0, v) if v end
  def attach_content_type=(v) attach_array_set(1, v) if v end
  def attach_file_size=(v) attach_array_set(2, v) if v end

  
  def before_post_attach
    ext = $1 if attach_file_name =~ /\.([^\.]+)$/
    self.attach.instance_write :file_name, "#{self.key.gsub('*','X').camelize}.#{ext}"
    #warn "attach post #{self}, #{attach_file_name}"
    typecode == 'Image'
  end

  #def item_names(args={}) [self.cardname] end

  def self.included(base)
    base.class_eval do
      has_attached_file :attach,
        :url => ":base_url/:card_id/:size:revision_id.:extension",
        :path => ":local/:card_id/:size:revision_id.:extension",
        :styles => { :icon   => '16x16#', :small  => '75x75#',
                   :medium => '200x200>', :large  => '500x500>' } 

      before_post_process :before_post_attach
    end
  end
end

module Paperclip::Interpolations
  def local(at, style_name)    Wagn::Conf[:attachment_storage_dir] end
  def base_url(at, style_name) Wagn::Conf[:attachment_base_url]    end
  def card_id(at, style_name)  at.instance.id                end

  def size(at, style_name)
    (at.instance.typecode != 'File'||style_name.blank?) && "#{style_name}-"||''
  end

  def revision_id(at, style_name)
    (cr=at.instance.current_revision) && cr.id || 0
  end
end

