
require 'rmagick'
require 'paperclip'

def attach_array
  
  c= self.content
  !c || c =~ /^\s*<img / ?  ['','',''] : c.split(/\n/)
end

def attach_array_set i, v
  c = attach_array[0..2]  # make sure there is no mod set for uploaded files
  if c[i] != v
    c[i] = v
    self.content = c*"\n"
  end
end

def attach_file_name()    attach_array[0] end
def attach_content_type() attach_array[1] end
def attach_file_size()    attach_array[2] end
def attach_mod()         attach_array[3] end

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
  if ext.present? and attach and original_ext=attach_extension 
    if['file', original_ext].member? ext
      original_ext
    elsif exts = MIME::Types[attach.content_type] 
      if exts.find {|mt| mt.extensions.member? ext }
        ext
      else
        exts[0].extensions[0]
      end
    end
  end   
rescue => e
  Rails.logger.info "attachment_format issue: #{e.message}"
  nil
end

# FIXME: test extension matches content type


def attachment_symlink_to(prior_action_id) # create filesystem links to files from prior action
  styles = case type_code
    when :file; ['']
    when :image; STYLES
  end
  if styles and prior_action_id != last_action_id
    save_action_id = selected_action_id
    links = {}
    
    self.selected_action_id = prior_action_id
    styles.each { |style|  links[style] = ::File.basename(attach.path(style))          }

    self.selected_action_id = last_action_id
    styles.each { |style|  ::File.symlink links[style], attach.path(style) }

    self.selected_action_id = save_action_id
  end
end

def before_post_attach
#  Rails.logger.info "bpa called for #{name}"

  at=self.attach
  at.instance_write :file_name, at.original_filename
  Card::ImageID == (type_id || Card.fetch_id( @type_args[:type] || @type_args[:type_code]) )
  # returning true enables thumnail creation
end


def self.included(base)
  base.class_eval do
    include Paperclip::Glue
    Paperclip::Attachment.default_options[:use_timestamp] = false
    # the need for this seems related to moving the initializer code here (line above comment)
    # this isn't quite right, but without it, we see logging to STDOUT
    Paperclip.options[:log] = false

    has_attached_file :attach, :preserve_files=>true,
      :default_url => "missing",
      :url => ":web_dir/:basename-:size:action_id.:extension",
      :path => ":system_path.:extension",
      :styles => { :icon   => '16x16#', :small  => '75x75',
                 :medium => '200x200>', :large  => '500x500>' }

    before_post_process :before_post_attach

    validates_each :attach do |rec, attr, value|
      if [Card::FileID, Card::ImageID].member? rec.type_id
        max_size = (max = Card['*upload max']) ? max.db_content.to_i : 5
        if value.size.to_i > max_size.megabytes
          rec.errors.add :file_size, "File cannot be larger than #{max_size} megabytes"
        end
      end
    end
  end
end



module Paperclip::Interpolations
  
  extend Card::Format::Location

  def system_path at, style
    card = at.instance
    if mod = at.instance.attach_mod
      # generalize this to work with any mod (needs design)
      codecard = card.cardname.junction? ? card.left : card
      "#{ Cardio.gem_root}/mod/#{mod}/file/#{codecard.codename}/#{size at, style}#{card.type_code}"
    else
      "#{ Card.paths['files'].existent.first }/#{card.id}/#{size at, style}#{action_id at, style}"
    end
  end
      
  def web_dir at, style_name
    card_path Card.config.files_web_path
  end

  def basename at, style_name
    at.instance.name.to_name.url_key
  end

  def size(at, style_name)
    at.instance.type_id==Card::FileID || style_name.blank? ? '' : "#{style_name}-"
  end

  def action_id(at, style_name) 
    at.instance.selected_content_action_id 
  end
end

