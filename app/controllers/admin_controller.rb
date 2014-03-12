# -*- encoding : utf-8 -*-
class AdminController < CardController
  before_filter :admin_only, :except=>:setup
  
  def setup
    raise Card::Oops, "Already setup" unless Account.no_logins?
    if request.post?
      Wagn::Env[:recaptcha_on] = false
      handle do
        Account.as_bot do
          @card = Card.create params[:card].merge( :subcards=>{
              '+*roles'      => { :content=>"[[#{Card[:administrator].name}]]"    },
              '*request+*to' => { :content=>params[:card][:account_args][:email]  }
            })
        
          @card.errors.empty?                 and
          self.current_account_id = @card.id  and
          Card.cache.delete 'no_logins'       and
          flash[:notice] = "You're good to go!"
        end
      end
    else
      @card = Card.new #should prolly skip default
      show :setup
    end
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

  #DEPRECATED.  migrated away old links?
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
    Card::Reference.repair_all
    stats 'References Repaired'
  end


  def stats msg
    render_text %{
      <h2>#{msg}</h2>
      <p>cards: #{Card.where(:trash=>false).count}</p>
      <p>trashed cards: #{Card.where(:trash=>true).count}</p>
      <p>revisions: #{Card::Revision.count}</p>
      <p>references: #{Card::Reference.count}</p>
    }
  end

  def empty_trash
    Card.empty_trash
    stats 'Trash Emptied'
  end
  
  def delete_old_revisions
    Card::Revision.delete_old
    stats 'Old Revisions Deleted'
  end

  def delete_old_sessions
    if params[:months] and params[:months].to_i > 0
      sql = 'DELETE FROM sessions WHERE updated_at < DATE_SUB(NOW(), INTERVAL %s MONTH);' % params[:months]
      ActiveRecord::Base.connection.execute(sql)
      render_text 'deleted'
    else
      render_text %{
        <form>Delete session records last updated more than <input name="months"/> months ago</form>
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
    render :text =>response
  end
  
  def admin_only
    raise Wagn::PermissionDenied unless Account.always_ok?
  end

end
