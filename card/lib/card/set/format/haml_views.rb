class Card
  module Set
    module Format
      module HamlViews
        def haml_view_block view, &block
          template = ::File.read haml_template_path view
          if block_given?
            proc do |view_args|
              instance_exec view_args, &block
              locals = instance_variables.each_with_object({}) do |var, h|
                h[var.to_s.tr("@","").to_sym] = instance_variable_get var
              end
              voo = View.new(self, view, view_args, @voo)
              with_voo voo do
                haml_to_html template, locals
              end
            end
          else
            proc do |view_args|
              voo = View.new(self, view, view_args, @voo)
              with_voo voo do
                haml_to_html template, view_args
              end
            end
          end
        end

        def haml_template_path view
          source = source_location
          basename = ::File.basename(source, ".rb")
          try_haml_template_path("../#{view}", source) ||
            try_haml_template_path("../#{basename}/#{view}", source) ||
            raise(Card::Error, "can't find haml template for #{view}")
        end

        def try_haml_template_path template_path, source_path, ext="haml"
          path = ::File.expand_path("#{template_path}.#{ext}", source_path)
                       .gsub(%r{/set/}, '/view/')
          ::File.exist?(path) && path
        end

        def haml_to_html haml, locals, a_binding=nil
          a_binding ||= binding
          ::Haml::Engine.new(haml).render a_binding, locals || {}
        end
      end
    end
  end
end
