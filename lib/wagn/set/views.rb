module Wagn::Set::Views
  #mattr_accessor :dirs

  @@ruby19 = !!(RUBY_VERSION =~ /^1\.9/)

  class << self
    def dirs() @@dirs ||= [] end

    def dir(newdir)
      dirs << newdir
      #STDERR << "dir[#{dirs.inspect}]\n"
      @@dirs
    end

    def load_all
      #Rails.logger.debug "load_all available_modules = #{@@dirs.inspect}\n"
      dirs.each do |dir|
        Dir[dir].each do |file|
          begin
            #warn "load all F:#{file}"
            require_dependency file
            file =~ %r{lib/(wagn/set/.*)/([^/]+?)(_module|_view|_event)?\.rb}
            #warn "load all #{$1}/#{$2}, #{"#{$1}/#{$2}/view".camelcase}"
            base = "#{$1}/#{$2}/view".camelcase #.constantize
            #warn "load all Base:#{base}"
            #inc=if @@ruby19
            #  base.const_defined?(View, false) ? base.const_get(View, false) : nil
            #else
            #  base.const_defined?(View)        ? base.const_get(View)        : nil
            #end
            #warn "include #{inc}"
            #Wagn::Renderer.class_eval { include inc }
          rescue Exception=>e
            warn "Error loading #{file} #{e.message}\n#{e.backtrace*"\n"}"
            return nil if NameError===e
            Rails.logger.warn "Error loading #{file} #{e.message}\n#{e.backtrace.join*"\n"}"
            raise e
          end
        end
      end
    end
  end
end

module Wagn::Load
  load_dirs = Rails.env =~ /^cucumber|test$/ ? "#{Rails.root}/lib/wagn/set" : Wagn::Conf[:load_dirs]

  load_dirs.split(/,\s*/).each do |dir|
    #warn "loading #{dir}"
    Wagn::Set::Views.dir File.expand_path( "#{dir}/**/*.rb",__FILE__)
  end

  #Wagn::Set::Views.dir File.expand_path( "#{Rails.root}/lib/wagn/set/*/*.rb", __FILE__ )
end
include Wagn::Load

