require 'digest/sha1'

class User < ActiveRecord::Base
  #FIXME: THIS WHOLE MODEL WILL BE SPLIT INTO User and Account
  # Card::Account will be a new extended cardtype
  # Refactor to warden/devise first

  # Declare devise configuration
  devise :all

  cattr_accessor :current_user, :first_user

  has_and_belongs_to_many :roles
  belongs_to :invite_sender,     :class_name=>'User',
               :foreign_key=>'invite_sender_id'
  has_many   :invite_recipients, :class_name=>'User',
               :foreign_key=>'invite_sender_id'

  acts_as_card_extension

  validates_presence_of     :email,                 :if => :email_required?
  validates_format_of       :email, :with =>
     /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i  , :if => :email_required?
  validates_length_of       :email,
                              :within => 3..100,    :if => :email_required?
  validates_uniqueness_of   :email, :scope=>:login, :if => :email_required?
  validates_presence_of     :password,              :if => :password_required?
  validates_presence_of     :password_confirmation, :if => :password_required?
  validates_length_of       :password,
                              :within => 5..40,     :if => :password_required?
  validates_confirmation_of :password,              :if => :password_required?
  validates_presence_of     :invite_sender,         :if => :active?
#  validates_uniqueness_of   :salt, :allow_nil => true

  before_validation :downcase_email!

  cattr_reader :cache, :root_login, :nobody_login, :aliases
  @@aliases = {}
  @@cache = {}
  @@root_login=self.find_by_id(1).login
  logger.info("Login:Root: #{self.cache[:root]}\n")
  @@nobody_login=self.find_by_id(2).login
  logger.info("Login:Nobody: #{self.cache[:nobody]}\n")
  self.first_user=self.find_by_id(3)
  logger.info("Login:First: #{self.cache[:first]}\n")

  class << self
    # CURRENT USER
    Card::Base.login_alias :root, :admin, :wagbot
    Card::Base.login_alias :nobody, :anon, :anonymous
    def current_user; @@current_user ||= self.anonymous end
    def first_login;
#debugger
(u=self.first_user).valid? && u.login
#if u.valid?
#u.login
#end
end
    def first_login=(user)
      self.first_user = User===user ? user : self.find_by_login(user)
    end
    def current_user=(user)
raise "User not user #{user.class}" if user && !User===user
#logger.info "User not user #{user.class}" if user && !User===user
      @@current_user = user ? User===user ? user : self[user] : anonymous
    end
    def anonymous; self[self.nobody_login] end
    def admin; self[self.root_login] end

    def as(as_user=nil)
      unless as_user===User
#b=as_user
        as_user = as_user && self[as_user] || admin
#c = self[b] if b
#d = admin unless b and c
#as_user = b and c or d
#debugger unless User === as_user
raise "User for as not user (#{b}) #{as_user.class}\n#{as_user.inspect}\n" unless User===as_user
      end
      #logger.info("WagnRunAs *#{as_user}*\n")
      tmp_user, self.current_user = self.current_user, as_user
      if block_given?
        value = yield
        self.current_user = tmp_user
        return value
      else
        current_user
      end
    end

    # FIXME: args=params.  should be less coupled..
    def create_with_card(user_args, card_args, email_args={})
      @card = (Hash===card_args ? Card.new({'type'=>'User'}.merge(card_args)) : card_args)
      @user = User.new({:invite_sender=>User.current_user, :status=>'active'}.merge(user_args))
      # gen_pw = Does devise do the mailing here? need to look into it
      #@user.generate_password if @user.encrypted_password.blank?
      @user.save_with_card(@card)
      #begin
      #  @user.send_account_info(email_args) if @user.errors.empty? && !email_args.empty?
      #end
      [@user, @card]
    end

=begin
def create(*args)
super
rescue Exception=>e
debugger
raise e
end
=end
    def random_base64(n=9)
      ActiveSupport::SecureRandom.base64(n)
    end

    def authenticate?(email, password)
      (u = self.find_by_email(email.strip.downcase)) &&
        self.authenticate({:email => u.email, :password => password.strip}) ? u : nil
    end

    def alias_to_user(login)
      return u if (u=self.aliases[login])===User
      self.aliases[login] = self.cache[login]
    end
    def [](login)
      if (login=login.to_s).blank? ; nil
      else self[login] = alias_to_user(login) || self.find_by_login(login) end
    end
    def active_users; self.find(:all, :conditions=>"status='active'") end
    def []=(login, user); self.cache[login] = user end
    def clear_cache; @@cache = {} end
  end

  ## INSTANCE METHODS
  def save_with_card(card)
    #fail "save with card #{card.inspect}"
    User.transaction do
      save
      card.extension = self
      card.save
      card.errors.each do |key,err|
        next if key=='extension'
        self.errors.add key,err
      end
      raise ActiveRecord::RecordInvalid.new(self) if !self.errors.empty?
    end
  rescue
  end

  def accept(email_args)
    User.as do #what permissions does approver lack?  Should we check for them?
      card.type = 'User'  # change from Invite Request -> User
      card.permit :edit, Card.new(:type=>'User').who_can(:edit) #give default user permissions
      self.status='active'
      self.invite_sender = ::User.current_user
      email_args[:password] = generate_password
      save_with_card(card)
    end
    #card.save #hack to make it so last editor is current user.
    self.send_account_info(email_args) if self.errors.empty?
  end

  def send_account_info(args)
    #return if args[:no_email]
    raise(Wagn::Oops, "subject is required") unless (args[:subject])
    raise(Wagn::Oops, "message is required") unless (args[:message])
    begin
#self.deliver_account_info(self, args[:subject], args[:message], args[:password])
logger.info("Send acct info #{self}, #{args[:subject]}, #{args[:message]}, #{args[:password]})\n")
    rescue Exception=>e; warn("\nACCOUNT INFO DELIVERY FAILED: #{e.full_message} \n #{args.inspect}")
#debugger
    end
  end

  def all_roles
    @cached_roles ||= (login=='anon' ? [Role[:anon]] :
      roles + [Role[:anon], Role[:auth]])
  end
  def generate_password;
    if encrypted_password.blank?; password = User.random_base64 else '' end
  end
  def active?; status=='active' end
  def blocked?; status=='blocked' end
  def built_in?; status=='system' end
  def pending?; status=='pending' end
  def anonymous?; login == nobody_login end
  def to_s; "#<#{self.class.name}:#{login.blank? ? email : login}}>" end
  def mocha_inspect; to_s end
  def downcase_email!; self.email=self.email.downcase if self.email end
  # blocked methods for legacy boolean status
  def blocked=(block)
    self.status = if block != '0'; 'blocked'
      elsif !built_in?; 'active'
      else self.status end
  end

  protected
  def password_required?
     rs = !built_in? && !pending? && local? &&
      (encrypted_password.blank? or not password.blank?)
  end
  def email_required?; !built_in? end
  def local?; true end # make false for remove service based logins ...
end

class User
  class Mailer < ::DeviseMailer
#debugger
#raise "Mail pw reset #{@user}, #{subject}, #{message}, #{generated_password})"
    def account_info(user, subject, message, password=nil)
      from_user = User.current_user || User[:wagbot]
      from_name = from_user.card ? from_user.card.name : ''
      url_key = user.card.name.to_url_key

      recipients "#{user.email}"
      from       (System.setting('*account+*from') || "#{from_name} <#{from_user.email}>") #FIXME - might want different from settings for different emails?
      subject    subject
      sent_on    Time.now
      body  :email    => (user.email    or raise Wagn::Oops.new("Oops didn't have user email")),
            :password => (password or user.password or raise Wagn::Oops.new("Oops didn't have user password")),

            :card_url => "#{System.base_url}/wagn/#{url_key}",
            :pw_url   => "#{System.base_url}/card/options/#{url_key}",

            :login_url=> "#{System.base_url}/account/signin",
            :message  => message.clone
    end

    def signup_alert(invite_request)
      recipients  System.setting('*request+*to')
      from        System.setting('*request+*from') || invite_request.extension.email
      subject "#{invite_request.name} signed up for #{System.site_title}"
      content_type 'text/html'
      body  :site => System.site_title,
            :card => invite_request,
            :email => invite_request.extension.email,
            :name => invite_request.name,
            :content => invite_request.content,
            :url =>  url_for(:host=>System.host, :controller=>'card', :action=>'show', :id=>invite_request.name.to_url_key)
    end


    def change_notice( user, card, action, watched, subedits=[], updated_card=nil )
      updated_card ||= card
      updater = updated_card.updater
      recipients "#{user.email}"
      from       System.setting('*notify+*from') || User.find_by_login('wagbot').email
      subject    "[#{System.setting('*title')} notice] #{updater.card.name} #{action} \"#{card.name}\""
      content_type 'text/html'
      body :card => card,
           :updater => updater.card.name,
           :action => action,
           :subedits => subedits,
           :card_url => "#{System.base_url}/wagn/#{card.name.to_url_key}",
           :change_url => "#{System.base_url}/card/changes/#{card.name.to_url_key}",
           :unwatch_url => "#{System.base_url}/card/unwatch/#{watched.to_url_key}",
           :udpater_url => "#{System.base_url}/wagn/#{card.updater.card.name.to_url_key}",
           :watched => (watched == card.name ? "#{watched}" : "#{watched} cards")
    end

    # from devise ...
    def confirmation_instructions(user)
      setup_mail(user, :confirmation_instructions)
    end

  private

    # Configure default email options
    def setup_mail(user, key)
      mapping = Devise::Mapping.find_by_class(user.class)
      raise "Invalid devise resource #{user}" unless mapping

      subject      translate(mapping, key)
      from         self.class.sender
      recipients   user.email
      sent_on      Time.now
      content_type 'text/html'
      body         render_with_scope(key, mapping, mapping.name => user, :resource => user)
    end

  end

end
=begin
class DeviseMailer < ::ActionMailer::Base

  # Sets who is sending the e-mail
  def self.sender=(value)
    @@sender = value
  end

  # Reads who is sending the e-mail
  def self.sender
    @@sender
  end
  self.sender = nil

  # Deliver confirmation instructions when the user is created or its email is
  # updated, and also when confirmation is manually requested
  def confirmation_instructions(record)
    setup_mail(record, :confirmation_instructions)
  end

  # Deliver reset password instructions when manually requested
  def reset_password_instructions(record)
    setup_mail(record, :reset_password_instructions)
  end

  private

    # Configure default email options
    def setup_mail(record, key)
      mapping = Devise::Mapping.find_by_class(record.class)
      raise "Invalid devise resource #{record}" unless mapping

      subject      translate(mapping, key)
      from         self.class.sender
      recipients   record.email
      sent_on      Time.now
      content_type 'text/html'
      body         render_with_scope(key, mapping, mapping.name => record, :resource => record)
    end

    def render_with_scope(key, mapping, assigns)
      if Devise.scoped_views
        begin
          render :file => "devise_mailer/#{mapping.as}/#{key}", :body => assigns
        rescue ActionView::MissingTemplate
          render :file => "devise_mailer/#{key}", :body => assigns
        end
      else
        render :file => "devise_mailer/#{key}", :body => assigns
      end
    end

    # Setup subject namespaced by model. It means you're able to setup your
    # messages using specific resource scope, or provide a default one.
    # Example (i18n locale file):
    #
    #   en:
    #     devise:
    #       mailer:
    #         confirmation_instructions: '...'
    #         user:
    #           confirmation_instructions: '...'
    def translate(mapping, key)
      I18n.t(:"#{mapping.name}.#{key}", :scope => [:devise, :mailer], :default => key)
    end
end
=end
