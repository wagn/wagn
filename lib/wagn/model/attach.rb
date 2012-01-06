module Wagn::Model::Attach
  def attach_array(rev_id=nil)
    c=if rev_id || self.new_card? || selected_rev_id==current_revision_id
        self.content
      else
        Revision.find_by_id(selected_rev_id).content
      end
    #warn "aa #{rev_id.inspect}, #{rev&&rev.id} #{selected_rev_id}}\ncc #{c}"
    !c || c =~ /^\s*<img / ?  ['','',''] : c.split(/\n/) 
  end

  def attach_array_set(i, v)
    #Rails.logger.debug "attach_set #{inspect} [#{i.inspect}] = #{v}"
    c = attach_array((cr=cached_revision)&&cr.id)
    if c[i] != v
      c[i] = v
      #warn "update #{i} #{v}"
      self.content = c*"\n"
    end
  end
    #r=warn "Afn #{r}"; r
  def attach_file_name()
    r=attach_array[0]
#    raise "fn nil ???" if r.nil?; r
  end
  def attach_content_type() attach_array[1] end
  def attach_file_size() attach_array[2] end

  def attach_file_name=(v) attach_array_set(0, v) if v end
  def attach_content_type=(v) attach_array_set(1, v) if v end
  def attach_file_size=(v) attach_array_set(2, v) if v end

  STYLES = %w{ icon small medium large original }

  def attachment_style(typecode, style)
    case typecode
    when 'File'; ''
    when 'Image'
      style.nil? || style.to_sym == :full ? :original : style
    end
  end

  def attachment_format(ext)
    return nil unless ext && !ext.blank? && attach
    exts = MIME::Types[attach.content_type]
    return nil unless exts
    return ext if exts.find {|mt| mt.extensions.member? ext }
    return exts[0].extensions[0]
  end
    
  # FIXME: test extension matches content type


  
  def attachment_link(rev_id)
    if styles = case typecode
          when 'File'; ['']
          when 'Image'; STYLES
        end
      save_rev_id = selected_rev_id
      self.selected_rev_id = rev_id
      links = {}
      styles.each {|style| links[style] = attach.path(style) }
      self.selected_rev_id = current_revision_id
      styles.each {|style|
        #warn "link to new rev #{links[style]}, #{attach.path(style)}"
        File.link  links[style], attach.path(style)}
      self.selected_rev_id = save_rev_id
    end
  end

  def before_post_attach
    at=self.attach
    at.instance_write :file_name,
      "#{self.key.gsub('*','X').camelize}#{File.extname(at.original_filename)}"
    #warn "before_post_attach #{attach_file_name}, #{attach_content_type}"

    'Image' == (typecode || Cardtype.classname_for( @type_args[:type] ) )
    # returning true enables thumbnail creation
  end

  #def item_names(args={}) [self.cardname] end

  def self.included(base)
    base.class_eval do
      has_attached_file :attach, :preserve_files=>true,
        :url => ":base_url/:basename-:size:revision_id.:content_type_extension",
        :path => ":local/:card_id/:size:revision_id.:content_type_extension",
        :styles => { :icon   => '16x16#', :small  => '75x75#',
                   :medium => '200x200>', :large  => '500x500>' } 

      before_post_process :before_post_attach
      
      validates_each :attach do |rec, attr, value|
        if ['File', 'Image'].member? rec.typecode
          max_size = 5 #this should eventually be a wagn configuration choice
          if value.size.to_i > max_size.megabytes
            rec.errors.add :file_size, "File cannot be larger than #{max_size} megabytes"
          end
        end
      end      
    end
  end
end



module Paperclip::Interpolations
  
  def local(    at, style_name )  Wagn::Conf[:attachment_storage_dir]  end
  def base_url( at, style_name )  Wagn::Conf[:attachment_web_dir]      end
  def card_id(  at, style_name )  at.instance.id                       end

  def basename(at, style_name)
    at.instance.name.to_cardname.to_url_key
  end

  def size(at, style_name)
    at.instance.typecode=='File' || style_name.blank? ? '' : "#{style_name}-"
  end

  def revision_id(at, style_name) at.instance.selected_rev_id end
end

