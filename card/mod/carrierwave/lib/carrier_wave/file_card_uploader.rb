module CarrierWave
  module Uploader
    # Implements a different name pattern for versions than CarrierWave's
    # default: we expect the version name at the end of the filename separated
    # by a dash
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

  # Takes care of the file upload for cards with attached files.
  # Most of the upload behaviour depends on the card itself.
  # (e.g. card type and storage option chosen for the card). So in contrary
  # to CarrierWave's default uploader we depend very much on the model
  # (= card object) to get the correct paths for retrieving and storing
  # the file.
  #
  # Cards that support attachments (by default those are cards of type "file"
  # and "image") accept a file handle as a card attribute.
  #
  # @example Attaching a file to a file card
  #   Card.create name: "file card", type: :file,
  #               file: File.new(path_to_file)
  #
  # @example Attaching a image to a image card
  #   Card.create name: "file card", type: :image,
  #               image: File.new(path_to_image)
  #
  # It's possible to upload files using a url. The card attribute for that is
  # remote_<attachment_type>_url
  #
  # @example Create a file card using a remote url
  #   Card.create name: "file_card", type: :file,
  #               remote_file_url: "http://a.file.in/the.web"
  #
  # @example Updating a image card using a remote url
  #   card.update_attributes remote_image_url: "http://a.image/somewhere.png"
  #
  # ## Storage types
  # You can choose between four different storage options
  #  - coded: These files are in the codebase, like the default logo.
  #      Every view is a wagn request.
  #  - local: Uploaded files which are stored in a local upload directory
  #      (upload path is configurable via config.paths["files"]).
  #      If read permissions are set such that "Anyone" can read, then there is
  #      a symlink from the public directory.  Otherwise every view is a wagn
  #      request.
  #  - cloud: You can configure buckets that refer to an external storage
  #      service. Link is rendered as absolute url
  #  - web: A fixed url (to external source). No upload or other file
  #      processing. Link is just the saved url.
  #
  # Currently, there is no web interface that let's a user or administrator
  # choose a storage option for a specific card or set of cards.
  # There is only a global config option to set the storage type for all new
  # uploads (config.storage_type). On the *admin card it's possible to
  # update all existing file cards according to the current global config.
  #
  # Storage types for single cards can be changed by developers using
  # the card attributes "storage_type", "bucket", and "mod".
  #
  # @example Creating a hard-coded file
  #   Card.create name: "file card", type_id: Card::FileID,
  #               file: File.new(path),
  #               storage_type: :coded, mod: "account"
  #
  # @example Moving a file to a cloud service
  #   # my_deck/config/application.rb:
  #   config.file_buckets = {
  #     aws_bucket: {
  #       provider: "fog/aws",
  #       directory: "bucket-name",
  #       subdirectory: "files",
  #       credentials: {
  #          provider: 'AWS'                         # required
  #          aws_access_key_id: 'key'                # required
  #          aws_secret_access_key: 'secret-key'     # required
  #       public: true,
  #      }
  #   }
  #
  #   # wagn console or rake task:
  #   card.update_attributes storage_type: :cloud, bucket: :aws_bucket
  #
  # @example Creating a file card with fixed external link
  #   Card.create name: "file card", type_id: Card::FileID,
  #               content: "http://animals.org/cat.png"
  #               storage_type: :web
  #
  #   Card.create name: "file card", type_id: Card::FileID,
  #               file: "http://animals.org/cat.png"
  #               storage_type: :web
  #
  # Depending on the storage type the uploader uses the following paths
  # and identifiers.
  # ### Identifier (stored in the database as db_content)
  #  - coded: :codename/mod_name.ext
  #  - local: ~card_id/action_id.ext
  #  - cloud: (bucket)/card_id/action_id.ext
  #  - web: http://url
  #
  # ### Storage path
  #  - coded:
  #    mod_dir/file/codename/type_code(-variant).ext  (no colon on codename!)
  #  - local:
  #    files_dir/card_id/action_id(-variant).ext           (no tilde on id!)
  #  - cloud:
  #    bucket/bucket_subdir/id/action_id(-variant).ext
  #  - web: no storage
  #
  # Variants are only used for images. Possible options are
  # icon|small|medium|large|original.
  # files_dir, bucket, and bucket_subdir can be changed via config options.
  #
  # ### Supported url patterns
  # mark.ext
  # mark/revision.ext
  # mark/revision-variant.ext
  # /files/mark/revision-variant.ext  # <- public symlink if readable by
  #                                   #    "Anyone"
  #
  # <mark> can be one of the following options
  # - <card name>
  # - ~<card id>
  # - :<code name>
  #
  # <revision> is the mod name if the file is coded or and action_id in any
  # case
  #
  # Examples:
  # *logo.png
  # ~22/33-medium.png               # local
  # :yeti_skin/standard-large.png   # coded
  #
  class FileCardUploader < Uploader::Base
    attr_accessor :mod
    include Card::Env::Location

    STORAGE_TYPES = [:cloud, :web, :coded, :local].freeze
    delegate :store_dir, :retrieve_dir, :file_dir, :mod, :bucket, to: :model

    def filename
      if model.coded?
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
    # @param opts [Hash] generate an identifier using the given storage options
    #   instead of the storage options derived from the model and
    #   the global configuration
    # @option opts [Symbol] storage_type
    # @option opts [String] mod
    # @option opts [Symbol] bucket
    def db_content opts={}
      model.with_storage_options opts do
        return model.content if model.web?
        return "" unless file.present?
        "%s/%s" % [file_dir, url_filename]
      end
    end

    def url_filename opts={}
      model.with_storage_options opts do
        if model.coded?
          "#{model.mod}#{extension}"
        else
          "#{action_id}#{extension}"
        end
      end
    end

    def url opts={}
      if model.cloud?
        file.url
      elsif model.web?
        model.content
      else
        local_url opts
      end
    end

    def local_url opts={}
      "%s/%s/%s" % [card_path(Card.config.files_web_path), file_dir,
                    full_filename(url_filename(opts))]
    end

    def public_path
      File.join Cardio.paths["public"].existent.first, url
    end

    def cache_dir
      Cardio.paths["files"].existent.first + "/cache"
    end

    # Carrierwave calls store_path without argument when it stores the file
    # and with the identifier from the db when it retrieves the file.
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

    def action_id
      model.selected_content_action_id
    end

    # delegate carrierwave's fog config methods to cardio's config methods
    [:provider, :attributes, :directory, :public,
     :authenticated_url_expiration, :use_ssl_for_aws].each do |name|
      define_method("fog_#{name}") { @model.bucket_config[name] }
    end

    def fog_credentials
      binding.pry
      credentials = @model.bucket_config[:credentials]
      [:aws_access_key_id, :aws_secret_access_key].each do |key|
        env_key = "#{@model.bucket.to_s.upcase}_#{key.to_s.upcase}"
        credentials[key] = ENV[env_key] if ENV[env_key]
      end
      credentials
    end

    private

    def storage
      case @model.storage_type
      when :cloud then ::CarrierWave::Storage::Fog.new(self)
      else ::CarrierWave::Storage::File.new(self)
      end
    end
  end
end
