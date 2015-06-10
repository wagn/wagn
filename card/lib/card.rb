# -*- encoding : utf-8 -*-

Object.send :remove_const, :Card if Object.send(:const_defined?, :Card)

class Card < ActiveRecord::Base
  require_dependency 'card/active_record_ext'
  require_dependency 'card/codename'
  require_dependency 'card/query'
  require_dependency 'card/format'
  require_dependency 'card/exceptions'
  require_dependency 'card/auth'
  require_dependency 'card/log'
  require_dependency 'card/loader'
  require_dependency 'card/content'
  require_dependency 'card/action'
  require_dependency 'card/act'
  require_dependency 'card/change'
  require_dependency 'card/reference'

  has_many :references_from, :class_name => :Reference, :foreign_key => :referee_id
  has_many :references_to,   :class_name => :Reference, :foreign_key => :referer_id
  has_many :acts, -> { order :id }
  has_many :actions, -> { where( :draft=>[nil,false]).order :id }
  has_many :drafts, { :class_name=> :Action }, -> { where( :draft=>true ).order :id }

  cattr_accessor :set_patterns, :error_codes
  @@set_patterns, @@error_codes = [], {}

  attr_accessor :action, :supercard, :current_act, :current_action, 
    :comment, :comment_author,    # obviated soon
    :update_referencers,          # wrong mechanism for this
    :update_all_users,                  # if the above is wrong then this one too
    :follower_stash, :remove_rule_stash,
    :last_action_id_before_edit
    
  define_callbacks :approve, :store, :extend
  
  before_validation :approve
  around_save :store
  after_save :extend
  
  TRACKED_FIELDS = %w(name type_id db_content trash)

  ActiveSupport.run_load_hooks(:card, self)
end

