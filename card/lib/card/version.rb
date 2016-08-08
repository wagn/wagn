# -*- encoding : utf-8 -*-

module Card::Version
  class << self
    def release
      @@version ||= File.read(File.expand_path "../../../VERSION", __FILE__).strip
    end
  end
end
