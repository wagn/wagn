require_dependency 'registerable'

module Datatype
  include Registerable
  
  class Base
    include InheritableClassAttributes
    
    cattr_inheritable_accessor :description
    cattr_inheritable_accessor :label
    cattr_inheritable_accessor :editor_type
    
    class << self
      def label(value=nil)
        if value.nil?
          @label.nil? ? registered_id : @label
        else
          @label = value
        end
      end

      def description(value = nil)
        if value.nil?
          @description
        else
          @description = value
        end
      end

      def editor_type(value = nil)
        if value.nil?
          return @editor_type unless @editor_type.nil?
          if self.superclass.to_s == 'Datatype::Base'
            # don't let it crawl all the way up to Base class
            raise "No editor defined for class #{self.to_s}"
          elsif self.to_s == "Datatype::Base"
            # but if somehow you started with the base class, go ahead and use a default value
            @editor_type = "PlainText"
          else
            self.superclass.editor_type
          end
        else
          @editor_type = value
        end
      end
    end  

    def allow_duplicate_revisions
      false
    end
    
    def initialize(card)
      @card = card
    end
    
    def content_for_rendering
      @card.content
    end
    
    def cacheable?
      return true
    end
    
    def editor_type
      self.class.editor_type
    end
    
    def pre_render( content )
      content
    end
    
    def post_render( content )
      content
    end
    
    def before_save( content )
      content 
    end
    
    def on_revise( content )
      Renderer.instance.render( @card, content, update_references=true )
    end
    
    def validate( content )
      if !valid_content?(content)
        raise Wagn::Oops.new( "#{@card.datatype_key} validation failed: #{content}" )     
      end
    end

    def valid_content?( content )
      true
    end
    
    def valid_number?( string )
      valid = true
      begin
        Kernel.Float( string )
      rescue ArgumentError, TypeError
        valid = false
      end
      valid    
    end
    
    
  end
end


Datatype.clear_registry        
# Believe it or not, the sort seems to fix an "superclass type mismatch"
# on reloading the datatypes in development
Dir["#{RAILS_ROOT}/app/datatypes/*_datatype.rb"].sort.each do |datatype|
  datatype.gsub!(/.*\/([^\/]*)$/, '\1')
  require_dependency "datatypes/#{datatype}"
end

