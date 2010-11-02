module CardData
  def extract_plus_data!
    keys.inject({}) {|h,k| h[k] = delete(k) if k =~ /^\+/; h }
  end
end

module Card
  class << self
    # This is just taking inventory of all the stuff we call on Card
    # that is defined in Card::Base.  interesting.
    # %w[ auto_card quoted_table_name add_builtin find subclasses add_observer
    #     find_builtin new create create! find_by_key find_by_key_and_trash find_by_name
    #     find_virtual create_virtual search find_by_sql find_by_type_and_trash
    #     find_or_create update_all retrieve_extension_attribute count_by_wql find_or_new
    #     count default_setting default_setting_card 
    #   ].each do |method|
    #   module_eval %{
    #     def #{method}(*args, &block)
    #       Card::Base.send :#{method}, *args, &block
    #     end
    #   }
    # end

    def method_missing( method_id, *args )
      Card::Base.send(method_id, *args )
    end

    def [](arg)
      Card::Base[arg]
    end
    
    def class_for(name, field='codename')
      Card.const_get(
        field.to_sym == :codename ? name :
          ( cardname = ::Cardtype.name_for_key(name.to_key) and
            ::Cardtype.classname_for( cardname ) )
      )
    rescue Exception=>e
      nil
    end

    def add_extension_tag(tag, options)
      Card::Base.extension_tags[tag] = options
    end

    def create_or_update args
      if c = Card[ args[:name] ]
        c.update_attributes args
        c
      else
        c= Card.new args
        c.save!
        #Card.create! args
        c
      end
    end

    def save_all_log_entry( name, content, prefix="\t" )
      "Card SaveAll: #{prefix}#{name}, " + (content||"").gsub("\n","")[0..50] + "\n"
    end
    
    def save_all data, opts = {}
      options = {
        :strategy => :create_or_update,  # :find_or_new, :create!, :update
        :plus_strategy => :create_or_update
      }.merge( opts )

      data.extend CardData
      plusses = data.extract_plus_data!

      log = ""
      time = Benchmark.measure do 
        Card::Base.transaction do
          base_card = Card.send options[:strategy], data

          plusses.each do |plus_name, plus_data|
            plus_card_name = base_card.name + plus_name
            case plus_data
              when String;  
                Card.send options[:plus_strategy], :name=> plus_card_name, :content => plus_data
                log << save_all_log_entry( plus_card_name, plus_data)

              when Array;
                if block_given?
                  plus_data = plus_data..map{|x| yield(plus_name, x) }
                end
                card_args = {
                  :name => plus_card_name, 
                  :type => "Pointer",  
                  :content => plus_data.map{|x| "[[#{x}]]" }.join("\n")
                }
                Card.send options[:plus_strategy], card_args
                log << save_all_log_entry( card_args[:name], card_args[:content])
              when Hash;
                plus_data[:name] ||= plus_card_name
                Card.send options[:plus_strategy], plus_data
                log << save_all_log_entry( plus_data[:name], plus_data[:content])
            end
          end
        end
      end
      log = save_all_log_entry( data[:name], data[:content], prefix="(+#{plusses.size}, #{sprintf("%.3f",time.real)}s)  ") + log
      ActiveRecord::Base.logger.info log
    end
  end

end  

