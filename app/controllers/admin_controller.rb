# -*- encoding : utf-8 -*-

#require_dependency 'card'

class AdminController < CardController
  layout 'application'
  before_filter :admin_only, :except=>:setup
  
  def setup
    raise Wagn::Oops, "Already setup" unless Account.no_logins?
    Wagn::Conf[:recaptcha_on] = false
    if request.post?
      #Card::User  # wtf - trigger loading of Card::User, otherwise it tries to use U
      Account.as_bot do
        @account, @card = User.create_with_card( params[:account].merge({:login=>'first'}), params[:card] )
        set_default_request_recipient

        if @card.errors.empty?
          roles_card = card.fetch :trait=>:roles, :new=>{}
          roles_card.content = "[[#{Card[Card::AdminID].name}]]"
          roles_card.save
          self.current_account_id = @card.id
          Card.cache.delete 'no_logins'
          flash[:notice] = "You're good to go!"
          redirect_to Card.path_setting('/')
        else
          flash[:notice] = "Durn, setup went awry..."
        end
      end
    else
      @card = Card.new( params[:card] || {} ) #should prolly skip defaults
      @account = User.new( params[:account] || {} )
    end
  end

  def show_cache
    key = params[:id].to_name.key
    @cache_card = Card.fetch(key)
    @db_card = Card.find_by_key(key)
  end

  def clear_cache
    Wagn::Cache.reset_global
    render_text 'Cache cleared'
  end

  def memory
    oldmem = session[:memory]
    session[:memory] = total = profile_memory
    
    render_text %{      
      <p>Total: #{total} </p>
      #{
        if oldmem
          %{ <p>Diff: #{total - oldmem}</p> }
        end
      }
    }
  end


  def tasks
    render_text %{
      <h1>Global Permissions - REMOVED</h1>
      <p>&nbsp;</p>
      <p>After moving so much configuration power into cards, the old, weaker global system is no longer needed.</p>
      <p>&nbsp;</p>
      <p>Account permissions are now controlled through +*account cards and role permissions through +*role cards.</p>
    }
  end
  
  def repair_references
    conn = ActiveRecord::Base.connection
    conn.execute 'truncate card_references'
    conn.execute 'update cards set references_expired=1'

    expired_cards_remain = true
    batchsize, count_updated = 100, 0

    while expired_cards_remain
      batch = Card.find_all_by_references_expired(1, :order=>"name ASC", :limit=>batchsize)
      if batch.empty?
        expired_cards_remain = false
      else
        Rails.logger.debug "Updating references for '#{batch.first.name}' to '#{batch.last.name}' ... "; $stdout.flush        
        batch.each do |card|
          count_updated += 1
          card.update_references
        end
        Rails.logger.info "batch done.  \t\t#{count_updated} total updated"
      end
    end
    render_text "Done! Stats: #{Card::Reference.count} references from #{count_updated} cards"
  end


  def stats
    render_text %{
      <p>cards: #{Card.count}</p>
      <p>trashed cards: #{Card.where(:trash=>true).count}</p>
      <p>revisions: #{Card::Revision.count}</p>
      <p>references: #{Card::Reference.count}</p>
    }
  end

  def empty_trash
    Card.where(:trash=>true).delete_all
    [Card::Revision, User].each do |model|
      model.where(Card.where(:id=>model.arel_table[:card_id]).exists.not).delete_all
    end
    Card::Reference.where( Card.where(:id=>Card::Reference.arel_table[:referee_id]).exists.not).update_all :referee_id=>nil
    render_text 'emptied!' 
  end
  
  def delete_old_revisions
    Card::Revision.where( Card.where(:current_revision_id=>Card::Revision.arel_table[:id]).exists.not ).delete_all
    render_text 'deleted!'
  end

  def delete_old_sessions
    if params[:months] and params[:months].to_i > 0
      sql = 'DELETE FROM sessions WHERE updated_at < DATE_SUB(NOW(), INTERVAL %s MONTH);' % params[:months]
      ActiveRecord::Base.connection.execute(sql)
      render_text 'deleted'
    else
      render_text %{
        <form>Delete session records last updated more than <input name="months"> months ago</form>
      }
    end
  end

  private

  def get_current_memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i
  end
  
  def profile_memory(&block)
    before = get_current_memory_usage
    file, line, _ = caller[0].split(':')
    if block_given?
      instance_eval(&block)
      (get_current_memory_usage - before) / 1024.0
    else
      before = 0
      (get_current_memory_usage - before) / 1024.0
    end
  end



  def render_text response
    render :text =>response, :layout=> true
  end
  
  def admin_only
    raise Wagn::PermissionDenied unless Account.always_ok?
  end

  def set_default_request_recipient
    to_card = Card.fetch '*request+*to', :new=>{}
    to_card.content=params[:account][:email]
    to_card.save
  end
end
