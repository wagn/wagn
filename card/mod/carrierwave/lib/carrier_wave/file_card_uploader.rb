# *DATABASE CONTENT*
# mod file:
#   :codename/modname.ext
# protected file:
#   ~card_id/action_id.ext
# bucket file
#   (bucket)/card_id/action_id.ext
#
# *FILE SYSTEM*
# mod file:
#   mod_dir/files/codename/type_code-variant.ext  (no colon on codename!)
# protected:
#   files_dir/id/action_id-variant.ext            (no tilde on id!)
# bucket:
#   bucket/bucket_subdir/id/action_id-variant.ext
#
# variant = icon|small|medium|large|original  (only for images)
#
# *URLS*
# mark.ext
# mark/revision.ext
# mark/revision-variant.ext
#
# revision = modname or action_id
#
# Examples:
# ~22/33-medium.png
# :yeti_skin/standard-large.png
#
# bucket files generate absolut urls
module CarrierWave
  module Uploader
    module Versions
      private

      # put version at the end of the filename
      def full_filename for_file
        name = super(for_file)
        parts = name.split "."
        basename = [parts.shift, version_name].compact.join("-")
        "#{basename}.#{parts.join('.')}"
      end
    end
  end

  class FileCardUploader < Uploader::Base
    attr_accessor :mod
    include Card::Env::Location

    STORAGE_TYPES = [:cloud, :web, :protected, :coded, :unprotected].freeze

    def self.update_all_storage_locations
      Card.search(type_id: ["in", FileID, ImageID]).each do |card|
        card.update_storage_location!
      end
    end

    def self.delete_tmp_files_of_cached_uploads
      actions = Card::Action.find_by_sql "SELECT * FROM card_actions
      INNER JOIN cards ON card_actions.card_id = cards.id
      WHERE cards.type_id IN (#{Card::FileID}, #{Card::ImageID})
      AND card_actions.draft = true"
      actions.each do |action|
        # we don't want to delete uploads in progress
        if older_than_five_days?(action.created_at) && (card = action.card)
          # we don't want to delete uploads in progress
          card.delete_files_for_action action
          action.delete
        end
      end
    end

    def self.older_than_five_days? time
      Time.now - time > 432_000
    end
    #storage :fog #:file

    def filename
      if mod_file?
        "#{model.type_code}#{extension}"
      else
        "#{action_id}#{extension}"
      end
    end

    def extension
      case
      when file && file.extension.present? then ".#{file.extension}"
      when card_content = model.content    then File.extname(card_content)
      when orig = original_filename        then File.extname(orig)
      else                                   ""
      end.downcase
    end

    # generate identifier that gets stored in the card's db_content field
    def db_content opts={}
      return "" unless file.present?
      model.load_from_mod = opts[:mod] if opts[:mod] && !model.load_from_mod
      "%s/%s" % [file_dir, url_filename(opts)]
    end

    def url_filename opts={}
      model.load_from_mod = opts[:mod] if opts[:mod] && !model.load_from_mod

      basename = if (mod = mod_file?)
                   "#{mod}#{extension}"
                 else
                   "#{action_id}#{extension}"
                 end
    end

    def url opts={}
      return file.url if bucket
      "%s/%s/%s" % [card_path(Card.config.files_web_path), file_dir,
                    full_filename(url_filename(opts))]
    end

    def file_dir
      return ":#{model.codename}" if mod_file?

      file_id = model.id? ? model.id : model.upload_cache_card.id
      if bucket
        "(#{bucket})/#{file_id}"
      else
        "~#{file_id}"
      end
    end

    def cache_dir
      Cardio.paths["files"].existent.first + "/cache"
    end

    # Carrierwave calls store_path without argument when it stores the file
    # and with the identifier from the db when it retrieves the file
    # In our case the first part of our identifier is not part of the path
    # but we can construct the filename from db data. So we don't need the
    # identifier.
    def store_path for_file=nil
      if for_file
        retrieve_path
      else
        File.join([store_dir, full_filename(filename)].compact)
      end
    end

    def retrieve_path
      File.join([retrieve_dir, full_filename(filename)].compact)
    end

    def tmp_path
      Dir.mkdir model.tmp_upload_dir unless Dir.exist? model.tmp_upload_dir
      File.join model.tmp_upload_dir, filename
    end

    def create_versions? _new_file
      model.create_versions?
    end

    # paperclip compatibility used in type/file.rb#core (base format)
    def path version=nil
      version ? versions[version].path : super()
    end

    def original_filename
      @original_filename ||= model.selected_action &&
        model.selected_action.comment
    end

    delegate :store_dir, :retrieve_dir, :mod_file?, :bucket, to: :model

    def action_id
      model.selected_content_action_id
    end

    [:provider, :attributes, :credentials, :directory, :public,
     :authenticated_url_expiration, :use_ssl_for_aws].each do |name|
      define_method "fog_#{name}" do
        Cardio.config.file_buckets &&
          (b = bucket) && (b_config = Cardio.config.file_buckets[b]) &&
          b_config[name]
      end
    end

    private

    def storage
      case @model.storage_type
      when :cloud then ::CarrierWave::Storage::Fog.new(self)
      when :web then ::CarrierWave::Storage::Web.new(self)
      else ::CarrierWave::Storage::File.new(self)
      end
    end
  end
end
