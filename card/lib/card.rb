# -*- encoding : utf-8 -*-
require 'carrierwave'

Object.send :remove_const, :Card if Object.send(:const_defined?, :Card)

# This documentation is intended for developers who want to understand:
#
# a. how ruby Card objects work, and
# b. how to extend them.
#
# It assumes that you've already read the introductory text
# in {file:README_Developers.rdoc}.
#
class Card < ActiveRecord::Base
  # attributes that ActiveJob can handle
  def self.serializable_attr_accessor *args
    self.serializable_attributes = args
    attr_accessor *args
  end

  require_dependency 'card/active_record_ext'
  require_dependency 'card/codename'
  require_dependency 'card/query'
  require_dependency 'card/format'
  require_dependency 'card/exceptions'
  require_dependency 'card/auth'
  require_dependency 'card/loader'
  require_dependency 'card/content'
  require_dependency 'card/action'
  require_dependency 'card/act'
  require_dependency 'card/change'
  require_dependency 'card/reference'
  require_dependency 'card/subcards'
  require_dependency 'card/view_cache'

  has_many :references_from, class_name: :Reference, foreign_key: :referee_id
  has_many :references_to,   class_name: :Reference, foreign_key: :referer_id
  has_many :acts, -> { order :id }
  has_many :actions, -> { where(draft: [nil, false]).order :id }
  has_many :drafts, -> { where(draft: true).order :id }, class_name: :Action

  cattr_accessor :set_patterns, :serializable_attributes, :error_codes,
                 :set_specific_attributes
  @@set_patterns = []
  @@error_codes = {}

  serializable_attr_accessor(
    :action, :supercard, :superleft,
    :current_act, :current_action,
    :comment, :comment_author,    # obviated soon
    :update_referencers,          # wrong mechanism for this
    :update_all_users,            # if the above is wrong then this one too
    :silent_change,               # and this probably too
    :remove_rule_stash,
    :last_action_id_before_edit
  )

  attr_accessor :follower_stash

  define_callbacks :prepare, :approve, :store, :stored, :extend, :subsequent,
                   :select_action, :show, :handle

  before_validation :prepare
  before_validation :approve
  around_save :store
  after_save :extend

  TRACKED_FIELDS = %w(name type_id db_content trash)
  extend CarrierWave::Mount
  ActiveSupport.run_load_hooks(:card, self)
end
