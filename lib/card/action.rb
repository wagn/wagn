# -*- encoding : utf-8 -*-
class Card
  def find_action_by_params args
    case 
    when args[:rev]
      nth_action(args[:rev].to_i-1)
    when args[:rev_id]
      action = Card::Action.find(args[:rev_id]) 
      if action.card_id == id 
        action 
      end
    end
  end
  
  def nth_revision index
    revision(nth_action(index))
  end
  
  def nth_action index
    Card::Action.where("(draft IS NULL OR draft = :draft) AND card_id = ':id'", {:draft=>false, :id=>id})[index-1]
  end
  
  def revision action
    if action.is_a? Integer
      action = Card::Action.find(action)
    end
    action and Card::TRACKED_FIELDS.inject({}) do |attr_changes, field|
      last_change = action.changes.find_by_field(field) || last_change_on(field, :not_after=>action)
      attr_changes[field.to_sym] = (last_change ? last_change.value : self[field])
      attr_changes
    end
  end
  
  def last_change_on(field, opts={})
    where_sql =  'card_actions.card_id = :card_id AND field = :field AND (draft = 0 OR draft IS NULL)'
    where_sql += if opts[:before]
      'AND card_action_id < :action_id'      
    elsif opts[:not_after]
      'AND card_action_id <= :action_id'
    else
      ''
    end
    
    action_arg = opts[:before] || opts[:not_after]
    action_id =  (action_arg.kind_of?(Card::Action) && action_arg.id) or action_arg
    field_index = Card::TRACKED_FIELDS.index(field.to_s)
    Change.joins(:action).where(where_sql, 
                          {:card_id=>id, :field=>field_index, :action_id=>action_id}
      ).order(:id).last
  end
  
  def delete_old_actions
    Card::TRACKED_FIELDS.each do |field|
        if (not last_action.change_for(field).present?) and (last_change = last_change_on(field))
          last_change = Card::Change.find(last_change.id)   # last_change comes as readonly record
          last_change.update_attributes!(:card_action_id=>last_action_id)
        end
    end
    actions.where('id != ?', last_action_id ).delete_all
  end
  
  
  class Action < ActiveRecord::Base
    belongs_to :card
    belongs_to :act,  :foreign_key=>:card_act_id, :inverse_of=>:actions 
    has_many   :changes, :foreign_key=>:card_action_id, :inverse_of=>:action, :dependent=>:delete_all
    
    belongs_to :super_action, class_name: "Action", :inverse_of=>:sub_actions
    has_many   :sub_actions,  class_name: "Action", :inverse_of=>:super_action
    
    scope :created_by, lambda { |actor_id| joins(:act).where('card_acts.actor_id = ?', actor_id) }
    
    # replace with enum if we start using rails 4 
    TYPE = [:create, :update, :delete]
    
    # def card
    #   Card.fetch card_id
    # end
    
    def self.delete_cardless
      Card::Action.where( Card.where( :id=>arel_table[:card_id] ).exists.not ).delete_all
    end
    
    def self.delete_old 
      Card.find_each do |card|
        card.delete_old_actions
      end    
      Card::Act.delete_actionless
    end
    
    def edit_info
      @edit_info ||= {
        :action_type  => "#{action_type}d",
        :new_content  => new_values[:content],
        :new_name     => new_values[:name],
        :new_cardtype => new_values[:cardtype],
        :old_content  => old_values[:content],
        :old_name     => old_values[:name],
        :old_cardtype => old_values[:cardtype]
      }
    end
    
    def new_values
      @new_values ||= {
        :content  => new_value_for(:db_content),
        :name     => new_value_for(:name),
        :cardtype => ( typecard = Card[new_value_for(:type_id).to_i] and typecard.name.capitalize )
      }
    end
    
    def old_values
      @old_values ||= {
        :content  => last_value_for(:db_content),
        :name     => last_value_for(:name),
        :cardtype => ( value = last_value_for(:type_id) and 
                       typecard = Card.find(value) and  typecard.name.capitalize )
      }
    end
    
    def last_value_for field
       ch = self.card.last_change_on(field, :before=>self) and ch.value
    end
    
    def new_value_for(field)
       ch = changes.find_by_field(field) and ch.value
    end
    def change_for(field) 
      changes.where('card_changes.field = ?', field)
    end
    
    
    def new_type?
      new_value_for(:type_id)
    end
    def new_content?
      new_value_for(:db_content)
    end
    def new_name?
      new_value_for(:name)
    end
    
    
    def action_type=(value)
      write_attribute(:action_type, TYPE.index(value))
    end
    
    def action_type
      TYPE[read_attribute(:action_type)]
    end
    
    def set_act
      self.set_act ||= self.acts.last
    end
    
    def revision_nr 
      self.card.actions.index_of(self)
    end
    
    def red?
      content_diff_builder.red?
    end
    
    def green?
      content_diff_builder.green?
    end
    
    
    # def diff
    #   @diff ||= { :cardtype=>type_diff, :content=>content_diff, :name=>name_diff}
    # end
      
  
    def name_diff
      if new_name?
        Card::Diff::DiffBuilder.new(old_values[:name],new_values[:name]).complete
      end
    end
  
    def cardtype_diff
      if new_type?
        Card::Diff::DiffBuilder.new(old_values[:cardtype],new_values[:cardtype]).complete
      end
    end
  
    def content_diff diff_type=:expanded
      if new_content?
        if diff_type == :summary
          content_diff_builder.summary
        else
          content_diff_builder.complete
        end
      end
    end
    
    def content_diff_builder
      @content_diff_builder ||= begin
        Card::Diff::DiffBuilder.new(old_values[:content], new_values[:content], :compare_html=>true)
      end
    end
    
  end
end


