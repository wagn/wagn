module Wql
  class Condition
    def initialize( options={} )     
      @node = "cards"
      @conditions=[]                      
      @joins = []

      options.each_pair do |key, value|
        # for now, skip blank ones
        next if value.blank?
        
        case key.to_sym
        when :type;      @conditions << "type='#{value}'"
        when :cardtype;  @conditions << "type='#{value}'"
        when :plus;      @joins << ["plus",         Condition.new(value)]
        when :tagging;   @joins << ["tagging",      Condition.new(value)]
        when :connected; @joins << ["connected to", Condition.new(value)]
        when :pieces;    @node = "pieces of cards"  
        when :backlink;  @joins << ["link to",      Condition.new(value)]   
        when :keyword;   @conditions <<  "(name matching '#{value}' or content matching '#{value}')"
        when :id;        @conditions << "#{key}=#{value}"
        when :exclude;   @conditions << "id not in (#{value})"
        else
          if key.to_s.match( /^#{Parser.field_pattern}$/)
            @conditions << "#{key}='#{value}'"
          end
        end
      end
    end

    def to_s  
      "#{@node} where " + ([@conditions].flatten + @joins.collect{|k,v| k + " " + v.to_s}).join(" and ")
    end
  end
  
  module QueryGenerator
    def generate_query( options={} )
      options.keys.each {|k| 
        if k.to_sym != k
          options[k.to_sym]=options.delete(k)
        end 
      } 
      # sorting
      @order = "priority desc, name"
      if !options[:sort_by].blank? and sort_field = options.delete(:sort_by)  
        @order = 
          case sort_field                    
          when 'creation'; 'created_at'
          when 'last change'; 'updated_at'  
          #when 'relevance'; 'trunk_id is not null, name'
          else sort_field
          end
          if !options[:sortdir].blank? and sortdir = options.delete(:sortdir)
            @order << " " + (sortdir.match(/desc/i) ? 'desc' : 'asc')
          end
      end      
      
      #limit
      pagesize = options[:pagesize].blank? ? System.pagesize.to_s : options.delete(:pagesize).to_i
      page = options[:page].blank? ? 1 : options.delete(:page).to_i
      @limit =  page > 1 ? "#{pagesize}, #{pagesize * (page-1)}" : " #{pagesize}"
             
              
      Condition.new(options).to_s + " order by #{@order} limit #{@limit}"
    end
  end
end
