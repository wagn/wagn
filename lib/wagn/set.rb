module Wagn::Set

  @@dirs = []
  class << self
    def dir newdir
      @@dirs << newdir
    end

    def load_dir dir
      Dir[dir].each do |file|
        begin
          require_dependency file
        rescue Exception=>e
          Rails.logger.warn "Error loading #{file} #{e.message}\n#{e.backtrace*"\n"}"
          raise e
        end
      end
    end

    def load
      @@dirs.each do |dir| load_dir dir end
    end
  end
end

module Wagn::Load
  load_dirs = Rails.env =~ /^cucumber|test$/ ? "#{Rails.root}/lib/wagn/set" : Wagn::Conf[:load_dirs]

  Wagn::Set.dir File.expand_path( "#{Rails.root}/lib/wagn/renderer/*.rb",__FILE__)

  load_dirs.split(/,\s*/).each do |dir|
    Wagn::Set.dir File.expand_path( "#{dir}/**/*.rb",__FILE__)
  end
end
include Wagn::Load

