# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  require_dependency 'card/codename'
  require_dependency 'card/query'
  require_dependency 'card/set_pattern'  
  require_dependency 'card/set'
  require_dependency 'card/format'
  require_dependency 'card/exceptions'
  require_dependency 'card/auth'
  require_dependency 'card/loader'

  extend Set

  has_many :revisions, :order => :id
  has_many :references_from, :class_name => :Reference, :foreign_key => :referee_id
  has_many :references_to,   :class_name => :Reference, :foreign_key => :referer_id

  cache_attributes 'name', 'type_id' #Review - still worth it in Rails 3?

  cattr_accessor :set_patterns, :error_codes
  @@set_patterns, @@error_codes = [], {}

  attr_writer :selected_revision_id #writer because read method is in mod (and does not override upon load)
  attr_accessor :action, :supercard,         
    :comment, :comment_author,    # obviated soon
    :update_referencers           # wrong mechanism for this


  define_callbacks :approve, :store, :extend
  
  before_validation :approve
  around_save :store
  after_save :extend

  Loader.load_mods

  tracks :content # we can phase this out and just use "dirty" handling once current content is stored in the cards table

end
