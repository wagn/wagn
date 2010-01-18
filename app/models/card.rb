module Card
  class << self
    # This is just taking inventory of all the stuff we call on Card
    # that is defined in Card::Base.  interesting.
    %w[ auto_card quoted_table_name add_builtin find subclasses add_observer
        find_builtin new create create! find_by_key find_by_key_and_trash find_by_name
        find_virtual create_virtual search find_by_sql find_by_type_and_trash
        find_or_create update_all retrieve_extension_attribute count_by_wql find_or_new
        count default_setting default_setting_card 
      ].each do |method|
      module_eval %{
        def #{method}(*args, &block)
          Card::Base.send :#{method}, *args, &block
        end
      }
    end

    def [](arg)
      Card::Base[arg]
    end
    
  end
end  

