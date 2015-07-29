module CarrierWave
  module Storage
    class CardFile < CarrierWave::Storage::File
      def retrieve!(identifier)
        path = ::File.expand_path(uploader.store_path, uploader.root)
        CarrierWave::SanitizedFile.new(path)
      end
    end
  end
end