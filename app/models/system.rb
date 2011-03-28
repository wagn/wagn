class System < ActiveRecord::Base
  #Why is this an ActiveRecord?
  set_table_name 'system'
  
  def self.reset_cache
    @@cache={
      :always => {},
      :ok_hash => {}
    }
  end
  reset_cache
  
  cattr_writer :attachment_storage    # storage option passed to attachment_fu   
  cattr_accessor :role_tasks, :request,                          
    # Configuration Options     
    :base_url, :max_render_time, :max_renders,   # Common; docs in sample_wagn.rb
    :enable_ruby_cards, :enable_server_cards,    # Uncommon; Check Security risks before enabling these cardtypes (wagn.org ref url?)
    :enable_postgres_fulltext, :postgres_src_dir, :postgres_tsearch_dir, # Optimize PostgreSQL performance
    :multihost,:wagn_name,
    # In development / nonfunctional
    :google_maps_api_key,    
    # Deprecated
    :site_name, :invitation_email_body, :invitation_email_subject, :invitation_request_email, :invite_request_alert_email 
    # Crap?  :admin_user_defaults, :debug_wql, :pagesize, :time, 
    
    
  class << self
    def base_url
      if (request and request.env['HTTP_HOST'] and !@@base_url)
        'http://' + request.env['HTTP_HOST']
      else
        @@base_url
      end
    end
   
    def host
      # FIXME: hacking this so users don't have to update config.  will want to fix later 
      System.base_url.gsub(/^http:\/\//,'')
    end
    
    def attachment_storage
      @@attachment_storage || :file_system
    end
    
    # CARD-BASED SETTINGS

    def setting(name)
      User.as :wagbot  do
        card=Card.fetch(name, :skip_virtual => true) and !card.content.strip.empty? and card.content
      end
    rescue
      nil
    end           
    
    def toggle(val)
      val == '1'
    end

    def layout_card(card, cardname)
      User.as(:wagbot) do 
        layout_from_url(cardname) or layout_from_setting(card)
      end
    end
    
    def layout_from_url(cardname)
      return nil unless cardname.present? and 
        lo_card = Card.fetch(cardname, :skip_virtual => true) and
        lo_card.ok?(:read)
      lo_card
    end
    
    def layout_from_setting(card)
      return unless setting_card = ((card && card.setting_card('layout')) or Card.default_setting_card('layout'))
      return unless setting_card.is_a?(Card::Pointer) and  # type check throwing lots of warnings under cucumber: setting_card.type == 'Pointer'        and
        layout_name=setting_card.item_names.first     and
        !layout_name.nil?                             and
        lo_card = Card.fetch(layout_name, :skip_virtual => true)    and
        lo_card.ok?(:read)
      lo_card
    end
   
    def image_setting(name)
      if content = setting(name) and content.match(/src=\"([^\"]+)/)
        $~[1]
      end
    end

    def site_title
      setting('*title') || 'Wagn'
    end
    
    def favicon
      # bit of a kludge. 
      image_setting('*favicon') || image_setting('*logo') || '/images/favicon.ico'
    end
    
    def logo
      image_setting('*logo') || (File.exists?("#{RAILS_ROOT}/public/images/logo.gif") ? "/images/logo.gif" : nil)
    end

    # PERMISSIONS
    
    def ok?(task)
      return true if always_ok?
      ok_hash.key? task.to_s
    end
    
    def ok!(task)
      if !ok?(task)
        #FIXME -- needs better error message handling
        raise Wagn::PermissionDenied.new(self.new)
      end
    end
    
    def role_ok?(role_id)
      return true if always_ok?
      ok_hash[:role_ids].key? role_id
    end
    
    def party_ok?(party)
      return false if party.nil?
      return true if always_ok?
      #warn party.inspect
      party.class.name == 'Role' ? 
         role_ok?(party.id) :
          (party == User.current_user)      
    end
    
    # FIXME stick this in session? cache it somehow??
    def ok_hash
      usr = User.current_user
      if (h = @@cache[:ok_hash][usr]).nil?
        @@cache[:ok_hash][usr] = begin
          ok = {}
          ok[:role_ids] = {}
          usr.all_roles.each do |role|
            ok[:role_ids][role.id] = true
            role.task_list.each { |t| ok[t] = 1 }
          end
          ok
        end || false
      else
        h
      end
    end
    
    def always_ok?   
      return false unless usr = User.current_user
      if (c = @@cache[:always][usr]).nil?
        @@cache[:always][usr] = usr.roles.detect { |r| r.codename == 'admin' } || false
      else
        c
      end
    end
  end 

  @@role_tasks = %w{
    set_global_permissions
    set_card_permissions
    administrate_users
    create_accounts
    assign_user_roles
  }
  
end        

