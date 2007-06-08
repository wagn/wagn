class DatatypeFixups < ActiveRecord::Migration
  def self.up
    execute "update tags set datatype='string' where datatype is null;"
    execute "alter table tags alter column datatype set not null";
    #execute "drop view card_summaries"
    execute %{      
      CREATE VIEW card_summaries AS
      SELECT c.*, cr.content AS content, cr.revised_at AS revised_at
      FROM cards c
      JOIN revisions cr ON cr.id = c.current_revision_id
    }
    
  end

  def self.down
    execute "alter table tags alter column datatype drop not null";
    #execute "drop view card_summaries"
    execute %{      
      CREATE VIEW card_summaries AS
      SELECT c.*, cr.content AS content, cr.revised_at AS revised_at
      FROM cards c
      JOIN revisions cr ON cr.id = c.current_revision_id
    }
  end
end
