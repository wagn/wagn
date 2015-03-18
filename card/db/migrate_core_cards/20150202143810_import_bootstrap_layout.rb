# -*- encoding : utf-8 -*-

class ImportBootstrapLayout < Card::CoreMigration
  def up
    layout = Card.fetch "Default Layout"    
    if layout
      layout.name = "Classic Layout"
      layout.update_referencers = true
      layout.save!
    end
        
    import_json "bootstrap_layout.json"#, :pristine=>true, :output_file=>nil

#    if unmerged.empty?
      if layout && layout.pristine? &&
        all = Card[:all]
        layout_rule_card = all.fetch :trait=>:layout
        style_rule_card  = all.fetch :trait=>:style
        if layout_rule_card.pristine? && style_rule_card.pristine?
          layout_rule_card.update_attributes! :content=> '[[Default Layout]]'
          style_rule_card. update_attributes! :content=> '[[classic bootstrap skin]]'
        end
      end
#    else
#      unmerged.map! do |row|
#        puts "didn't merge #{row['name']}"
#        row['name'] += '+alternate'
#        row
#      end
#      Card.merge_list unmerged
#    end

    # these are hard-coded
    Card.create! :name=>'style: bootstrap theme', :type_code=>:css, :codename=>'bootstrap_theme_css'
    Card.create! :name=>'style: bootstrap', :type_code=>:css, :codename=>'bootstrap_css'
    Card.create! :name=>'script: bootstrap', :type_code=>:js, :codename=>'bootstrap_js'
    
    # add new setting: *default html view
    Card.create! :name=>'*default html view', :type_code=>:setting, :codename=>'default_html_view'
    Card.create! :name=>'*default html view+*right+*default', :type_code=>:phrase
    
    # retain old behavior (default view was content, now titled)
    Card.create! :name=>'*all+*default html view', :content=>'content'
    
    # update layouts to have explicit views in inclusions
    Card.search( :type_id=>Card::LayoutTypeID ) do |lcard|
      lcontent = Card::Content.new lcard.content, lcard
      lcontent.find_chunks( Card::Chunk::Include ).each do |nest|
        nest.explicit_view = (nest.options[:inc_name]=='_main' ? 'open' : 'core')
      end    
      lcard.update_attributes! :content=>lcontent.to_s
    end
    
  end
end
