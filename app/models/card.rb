# -*- encoding : utf-8 -*-

class Card < ActiveRecord::Base
  require_dependency 'card/query'
  require_dependency 'card/constant'
  require_dependency 'card/set'
  require_dependency 'card/format'

  extend Card::Set
  extend Card::Constant
  extend Wagn::Loader

  require_dependency 'card/exceptions'
  include Card::Exceptions

  has_many :revisions, :order => :id
  has_many :references_from, :class_name => :Reference, :foreign_key => :referee_id
  has_many :references_to,   :class_name => :Reference, :foreign_key => :referer_id

  cattr_accessor :set_patterns, :error_codes
  @@set_patterns, @@error_codes = [], {}

  attr_writer :selected_revision_id #writer because read method is in mod (and does not override upon load)
  attr_accessor :action,
    :cards, :loaded_left, :nested_edit,          # merge these concepts?
    :comment, :comment_author, :account_args,    # obviated soon
    :update_referencers                          # wrong mechanism for this


  define_callbacks :approve, :store, :extend
  before_validation :approve
  around_save :store
  after_save :extend

  load_set_patterns
  load_formats
  load_sets



  cache_attributes 'name', 'type_id' #Review - still worth it in Rails 3?


  

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # EVENTS
  # The following events are all currently defined AFTER the sets are loaded and are therefore unexposed to the API.  Not good.  (my fault) - efm




  set_callback :store, :after, :update_ruled_cards, :prepend=>true
  set_callback :store, :after, :process_read_rule_update_queue, :prepend=>true

  event :expire_related, :after=>:store do
    self.expire

    if self.is_hard_template?
      self.hard_templatee_names.each do |name|
        Card.expire name
      end
    end
    # FIXME really shouldn't be instantiating all the following bastards.  Just need the key.
    # fix in id_cache branch
    self.dependents.each       { |c| c.expire }
    self.referencers.each      { |c| c.expire }
    self.name_referencers.each { |c| c.expire }
    # FIXME: this will need review when we do the new defaults/templating system
  end


  # ~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  # ATTRIBUTE TRACKING
  # we can phase this out and just use "dirty" handling once current content is stored in the cards table
  
  # Because of the way it chains methods, 'tracks' needs to come after
  # all the basic method definitions, and validations have to come after
  # that because they depend on some of the tracking methods.
  tracks :name, :content, :comment

  # this method piggybacks on the name tracking method and
  # must therefore be defined after the #tracks call

  def name_with_resets= newname
    newkey = newname.to_name.key
    if key != newkey
      self.key = newkey
      reset_patterns_if_rule # reset the old name - should be handled in tracked_attributes!!
      reset_patterns
    end
    @cardname = nil if name != newname.to_s
    self.name_without_resets = newname.to_s
  end
  alias_method_chain :name=, :resets
  alias cardname= name=



end
