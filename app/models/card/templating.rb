require 'ruby-debug'

module CardLib
  module Templating

    def self.included(base)
      super
      base.extend(ClassMethods)
    end

    module ClassMethods
      def template(name)
        right_template(name) || type_template(name) || default_template
      end

      def right_template(name='')
        return nil unless name and name.junction?
        (tag = find_template(name.tag_name) and
          find_template(Cardtype.name_for(tag.type)+"+*rform")) ||
          find_template(name.tag_name+"+*rform")
      end

      def type_template(name, type=nil)
        ## OPTIMIZE!!!
        multi_type_template(name) || single_type_template #(name)
      end

      def single_type_template(name)
        card = find_template(name)
        card && tform(Cardtype.name_for(self.type)) || tform('Basic')
      end

      def multi_type_template(name)
        if name and !name.simple?
          trunk = find_template(name.trunk_name) or return nil
          tag   = find_template(name.tag_name)   or return nil
          tform "#{Cardtype.name_for(trunk.type)}+#{Cardtype.name_for(tag.type)}"
        end
      end

      def tform(name)
        find_template(name+'+*tform')
      end

      def find_template(name)
        CachedCard.get_real(name) #
      end

      def default_template
        # FIXME -- this should be out by 1.0
        # this last case where we create a dummy defaults card should
        # ONLY come up during migration from pre templating wagns
        # -- after that we should always have a type card
        Card::Basic.new(:content=>"",
          :permissions=>[Permission.new(:task=>'read',:party=>::Role[:anon])] +
            [:edit,:comment, :delete].map{|t| Permission.new(:task=>t.to_s, :party=>::Role[:auth])}
         )
      end

#
# xml specific template support
#
      def xform(name)
        find_template(name+'+*xform')
      end

      def xml_template(name='', type=nil)
        return nil unless name and name.junction?
        (tag = find_template(name.tag_name) and
          find_template(Cardtype.name_for(tag.type)+"+*xform")) ||
            find_template(name.tag_name+"+*xform")
      end

      def single_xml_template(name)
        card = find_template(name)
        card && xform(name) || xform('Basic')
      end

      def multi_xml_template(name)
        if name and !name.simple?
          trunk = find_template(name.trunk_name) or return nil
          tag   = find_template(name.tag_name)   or return nil
          xform "#{Cardtype.name_for(trunk.type)}+#{Cardtype.name_for(tag.type)}"
        end
      end
    end


    #------( this template governs me )

    def template
      @template ||= right_template ||
                    type_template ||
                    self.class.default_template
    end

    def right_template
      @right_template ||= self.class.right_template(name)
    end

    def type_template
      @type_template ||= self.class.multi_type_template(name) ||
                         single_type_template
    end

    def hard_template
      (t=template) && t.hard_template? ? t : nil
    end

    def single_type_template
      self.class.tform(Cardtype.name_for(self.type)) || self.class.tform('Basic')
    end

    def find_template(name)
      self.class.find_template(name)
    end

#
# xml support (matching to *xform tag)
#
    def xml_template
      @xml_template ||= self.class.multi_xml_template(name) ||
                        self.single_xml_template
    end

    def xml_hard_template
      (t=xml_template) && t.hard_template? ? t : nil
    end

    def single_xml_template
      self.class.xform(Cardtype.name_for(self.type)) || self.class.xform('Basic')
    end


    #--------( I "control" a template )

    def templator?  #used to be template tsar
      type_templator? or right_templator?
    end

    def type_templator?
      attribute_card '*tform'
    end

    def right_templator?
      attribute_card '*rform'
    end

    def xml_templator?
      attribute_card '*xform'
    end


    #-----( I am a template )

    def xml_template?
      name ? (name.tag_name == '*xform') : (tag and tag.name == '*xform')
    end

    def template?
      type_template? or right_template? or xml_template?
    end

    def type_template?
      name ? (name.tag_name == '*tform') : (tag and tag.name == '*tform')
    end

    def right_template?
      name ? (name.tag_name == '*rform') : (tag and tag.name == '*rform')
    end

    def hard_template?
      extension_type=='HardTemplate'
    end

    def soft_template?
      !hard_template?
    end

    def auto_template?
      hard_template? and !(type_template? and trunk.simple?)
    end

    #-----( ... and I govern these cards )

    def real_card
      self
    end

    def hard_templatees
      if wql=hard_templatee_wql
        User.as(:admin) {  Card.search(wql)  }
      else
        []
      end
    end

    def expire_templatee_references
	   return unless respond_to?('references_expired')
      if wql=hard_templatee_wql
        condition = User.as(:admin){ Wql2::CardSpec.new(wql.merge(:return=>"condition")).to_sql }
        card_ids_to_update = connection.select_rows("select id from cards t where #{condition}").map(&:first)
        card_ids_to_update.each_slice(100) do |id_batch|
          connection.execute "update cards set references_expired=1 where id in (#{id_batch.join(',')})"
        end
      end
    end

    private
    def hard_templatee_wql
      return nil unless template? and hard_template?
      wql =
        case
        when right_template?
          trunk.simple? ? {:right=>trunk.id} : {:left=>{:type=>trunk.trunk.name},:right=>trunk.tag.id}
        when type_template?
          trunk.simple? ? {:type=>trunk.name} : {:left=>{:type=>trunk.trunk.name},:right=>{:type=>trunk.tag.name}}
        end
    end

  end
end
