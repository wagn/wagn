class AddCommentToActions < ActiveRecord::Migration
  def up
    add_column :card_actions, :comment, :text
  end
end
