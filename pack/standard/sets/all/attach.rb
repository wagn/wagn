# -*- encoding : utf-8 -*-

def attach_array(rev_id=nil)
  c=if rev_id || self.new_card? || selected_revision_id==current_revision_id
      self.content
    else      
      Card::Revision.find_by_id(selected_revision_id).content
    end
  !c || c =~ /^\s*<img / ?  ['','',''] : c.split(/\n/)
end

def attach_array_set(i, v)
  c = attach_array((cr=current_revision)&&cr.id)
  if c[i] != v
    c[i] = v
    self.content = c*"\n"
  end
end
def attach_file_name()    attach_array[0] end
def attach_content_type() attach_array[1] end
def attach_file_size()    attach_array[2] end

def attach_extension()    attach.send( :interpolate, ':extension' )  end

def attach_file_name=(v)
  return if !v # does this happen?
  attach_array_set 0, v
  attach_array_set 1, MIME::Types.type_for(v).first.to_s
  # was having issues with browsers getting mime types wrong,
  # eg application/octet-stream for pdfs in Firefox (both versions 4 and 10)
  # this solution means we just do a lookup based on the extension.
  # perhaps not ideal, but at least consistent.  Not sure browsers do much more.
end
def attach_file_size=(v) attach_array_set(2, v) if v end

STYLES = %w{ icon small medium large original }


def attachment_format(ext)
  return nil unless ext.present? && attach
  return nil unless original_ext = attach_extension
  return original_ext if ['file', original_ext].member? ext
  exts = MIME::Types[attach.content_type]
  return nil unless exts
  return ext if exts.find {|mt| mt.extensions.member? ext }
  return exts[0].extensions[0]
rescue Exception => e
  Rails.logger.info "attachment_format issue: #{e.message}"
  nil
end

# FIXME: test extension matches content type



def attachment_link(rev_id) # create filesystem links to previous revision
  if styles = case type_code
        when 'File'; ['']
        when 'Image'; STYLES
      end
    save_rev_id = selected_revision_id
    links = {}

    self.selected_revision_id = rev_id
    styles.each { |style|  links[style] = attach.path(style)          }

    self.selected_revision_id = current_revision_id
    styles.each { |style|  File.link links[style], attach.path(style) }

    self.selected_revision_id = save_rev_id
  end
end

def before_post_attach
  at=self.attach
  at.instance_write :file_name, at.original_filename

  Card::ImageID == (type_id || Card.fetch_id( @type_args[:type] ) )
  # returning true enables thumnail creation
end


def self.included(base)
  base.class_eval do
    has_attached_file :attach, :preserve_files=>true,
      :default_url => "missing",
      :url => ":base_url/:basename-:size:revision_id.:extension",
      :path => ":local/:card_id/:size:revision_id.:extension",
      :styles => { :icon   => '16x16#', :small  => '75x75',
                 :medium => '200x200>', :large  => '500x500>' }

    before_post_process :before_post_attach

    validates_each :attach do |rec, attr, value|
      if [Card::FileID, Card::ImageID].member? rec.type_id
        max_size = (max = Card['*upload max']) ? max.content.to_i : 5
        if value.size.to_i > max_size.megabytes
          rec.errors.add :file_size, "File cannot be larger than #{max_size} megabytes"
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
    at.instance.name.to_name.url_key
  end

  def size(at, style_name)
    at.instance.type_id==Card::FileID || style_name.blank? ? '' : "#{style_name}-"
  end

  def revision_id(at, style_name) at.instance.selected_revision_id end
end

