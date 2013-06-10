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
      [ SETS, Wagn::Conf[:pack_dirs].split( /,\s*/ ) ].flatten.each do |dirname|
        load_dir File.expand_path( "#{dirname}/**/*.rb", __FILE__ )
      end
      
      tmpsetdir = "#{Rails.root}/lib/wagn/newset/"

      #note: these should really go from broadest to narrowest set.
      Dir.foreach tmpsetdir do |set_pattern|
        next if set_pattern =~ /^\./
        set_pattern_mod_name = set_pattern.camelize
        
        base = if Wagn::Set.const_defined? set_pattern_mod_name
          Wagn::Set.const_get set_pattern.camelize
        else
          Wagn::Set.const_set set_pattern.camelize, Module.new
        end
        
        Dir.foreach "#{tmpsetdir}/#{set_pattern}" do |anchor|
          next if anchor =~ /^\./
          anchor.gsub! /\.rb$/, ''
          Wagn::Set::current_set_opts = { set_pattern.to_sym => anchor.to_sym }
          base.const_set anchor.camelize, (Module.new do
            extend Wagn::Set
            class_eval File.read( "#{tmpsetdir}/#{set_pattern}/#{anchor}.rb" )
          end )
        end
      end
      
    end

    private
    
    def load_dir dir
      Dir[dir].sort.each do |file|
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
