class Permission < ActiveRecord::Base
  belongs_to :party, :polymorphic=>true
  belongs_to :card
end
