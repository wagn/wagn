class AdminController < ApplicationController
  layout 'application'

  def setup
    raise(Wagn::Oops, "Already setup") unless User.no_logins? && !User[:first]
    Wagn::Conf[:recaptcha_on] = false
    if request.post?
      #Card::User  # wtf - trigger loading of Card::User, otherwise it tries to use U
      User.as :wagbot do
        @extension, @card = User.create_with_card( params[:extension].merge({:login=>'first'}), params[:card] )
        set_default_request_recipient
      end

      warn "ext id = #{@extension.id}"

      if @extension.errors.empty?
        roles_card = Card.fetch_or_new(@card.cardname.star_rule(:roles))
        roles_card.content = "[[#{Card[Card::AdminID].name}]]"
        roles_card.save
        self.session_user = @card
        User.cache.delete 'no_logins'
        flash[:notice] = "You're good to go!"
        redirect_to Card.path_setting('/')
      else
        flash[:notice] = "Durn, setup went awry..."
      end
    else
      @card = Card.new( params[:card] || {} ) #should prolly skip defaults
      @extension = User.new( params[:user] || {} )
    end
  end

  def tasks
    raise Wagn::PermissionDenied.new('Only Administrators can view tasks') unless User.always_ok?
    @tasks = Wagn::Conf[:role_tasks]
    #role.cache.reset
    
    @roles = Card.find_configurables.sort{|a,b| a.name <=> b.name }
    @role_tasks = @roles.inject({}) do |h, rolecard|
      h[rolecard.id] = Card[rolecard.cardname.star_rule(:tasks)].item_names
    end
  end

  def save_tasks
    raise Wagn::PermissionDenied.new('Only Administrators can change task permissions') unless User.always_ok?
    role_tasks = params[:role_task] || {}
    rule_update = {}
    Card.find(:type_id => Card::RoleID ).each do |role|

      if tasks = role_tasks[role_id.to__s]
        tasks.keys.each do |task|
          rule_update[Card.task_rule(task)] = "#{rule_update[rulename]}[[#{role.name}]]"
        end
      end
    end

    rule_update.each do |rulename, content|
      rulecard = Card.fetch_or_new(rulename)
      rulecard.content = content
      rulecard.save
    end

    flash[:notice] = 'permissions saved'
    redirect_to :action=>'tasks'
  end
  
  def show_cache
    key = params[:id].to_cardname.to_key
    @cache_card = Card.fetch(key)
    @db_card = Card.find_by_key(key)
  end
  
  def clear_cache
    response = 
      if User.always_ok?
        Wagn::Cache.reset_global
        'Cache cleared'
      else
        "You don't have permission to clear the cache"
      end
    render :text =>response, :layout=> true  
  end

  private
  
  def set_default_request_recipient
    to_card = Card.fetch_or_new('*request+*to')
    to_card.content=params[:extension][:email]
    to_card.save
  end

end
