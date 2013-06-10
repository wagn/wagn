# -*- encoding : utf-8 -*-

module Wagn

  include Wagn::Exceptions
  
  module Loader
    CARDLIB   = "#{Rails.root}/lib/cardlib/*.rb"
    SETS      = "#{Rails.root}/lib/wagn/set/"
    RENDERERS = "#{Rails.root}/lib/wagn/renderer/*.rb"

    def load_cardlib
      load_dir File.expand_path( CARDLIB, __FILE__ )
    end
    
    def load_renderers
      load_dir File.expand_path( RENDERERS, __FILE__ )
    end

    def load_sets
      load_dir File.expand_path( "#{SETS}/*.rb", __FILE__ )
      [ SETS, Wagn::Conf[:pack_dirs].split( /,\s*/ ) ].flatten.each do |dirname|
        load_dir File.expand_path( "#{dirname}/**/*.rb", __FILE__ )
      end
    end

    private
    
    def load_dir dir
      Dir[dir].each do |file|
        begin
          require_dependency file
        rescue Exception=>e
          Rails.logger.debug "Error loading file #{file}: #{e.message}\n#{e.backtrace*"\n"}"
          raise e
        end
      end
    end
          
  end
end
