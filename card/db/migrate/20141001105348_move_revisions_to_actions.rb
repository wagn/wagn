class MoveRevisionsToActions < ActiveRecord::Migration
  class TmpRevision < ActiveRecord::Base
    belongs_to :tmp_card, foreign_key: :card_id
    self.table_name = "card_revisions"
    def self.delete_cardless
      left_join = "LEFT JOIN card_revisions "\
                  "ON card_revisions.card_id = cards.id"
      TmpRevision.joins(left_join).where("cards.id IS NULL").delete_all
    end
  end
  class TmpAct < ActiveRecord::Base
    self.table_name = "card_acts"
  end
  class TmpAction < ActiveRecord::Base
    self.table_name = "card_actions"
  end
  class TmpChange < ActiveRecord::Base
    self.table_name = "card_changes"
  end
  class TmpCard < ActiveRecord::Base
    belongs_to :tmp_revision, foreign_key: :current_revision_id
    has_many :tmp_actions, foreign_key: :card_id
    self.table_name = "cards"
  end

  def up
    TmpRevision.delete_cardless

    conn = TmpRevision.connection
    created = Set.new

    TmpRevision.find_each do |rev|
      TmpAct.create({ id: rev.id, card_id: rev.card_id, actor_id: rev.creator_id, acted_at: rev.created_at }, without_protection: true)
      if created.include? rev.card_id
        TmpAction.connection.execute "INSERT INTO card_actions (id, card_id, card_act_id, action_type) VALUES
                                                               ('#{rev.id}', '#{rev.card_id}', '#{rev.id}', 1)"
        TmpChange.connection.execute "INSERT INTO card_changes (card_action_id, field, value) VALUES
                                                               ('#{rev.id}', 2, #{conn.quote(rev.content)})"
      else
        TmpAction.connection.execute "INSERT INTO card_actions (id, card_id, card_act_id, action_type) VALUES
                                                              ('#{rev.id}', '#{rev.card_id}', '#{rev.id}', 0)"

        if (tmp_card = rev.tmp_card)
          TmpChange.connection.execute "INSERT INTO card_changes (card_action_id, field, value) VALUES
              ('#{rev.id}', 0, #{conn.quote tmp_card.name}),
              ('#{rev.id}', 1, '#{tmp_card.type_id}'),
              ('#{rev.id}', 2, #{conn.quote(rev.content)}),
              ('#{rev.id}', 3, #{tmp_card.trash})"
        end
        created.add rev.card_id
      end
    end

    TmpCard.find_each do |card|
      card.update_column(:db_content, card.tmp_revision.content) if card.tmp_revision
    end

    # drop_table :card_revisions
    # remove_column :cards, :current_revision
  end

  def down
  end
end
