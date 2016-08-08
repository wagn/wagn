# -*- encoding : utf-8 -*-
require_dependency "card/env"

require "smart_name"

class Card
  class ViewName < SmartName
    @@name2viewnameobject = {}

    class << self
      def new obj
        return obj if self.class === obj
        str = Array === obj ? obj * joint : obj.to_s
        if known_name = @@name2viewnameobject[str]
          known_name
        else
          super str.strip
        end
      end
    end

    def initialize str
      @s = str.to_s.strip
      @s = @s.encode("UTF-8") if RUBYENCODING
      @key = if @s.index(self.class.joint)
               @parts = @s.split(/\s*#{JOINT_RE}\s*/)
          @parts << "" if @s[-1, 1] == self.class.joint
          @simple = false
          @parts.map { |p| p.to_name.key } * self.class.joint
             else
               @parts = [str]
          @simple = true
          str.empty? ? "" : simple_key
        end
      @@name2viewnameobject[str] = self
    end

    def simple_key
      decoded.underscore.gsub(/[^#{OK4KEY_RE}]+/, "_").split(/_+/).reject(&:empty?) * "_"
    end

    def to_viewname
      self
    end
  end
end
