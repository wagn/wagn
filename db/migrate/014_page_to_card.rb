class PageToCard < ActiveRecord::Migration
  def self.up
    execute "alter table revisions rename page_id to card_id"
    execute "alter table wiki_references rename page_id to card_id"
    execute "alter table wiki_references rename referenced_page_id to referenced_card_id"
    execute "alter table pages rename to cards" 
    execute "alter table page_summaries rename page_id to card_id"
    execute "alter table page_summaries rename to card_summaries"
  end

  def self.down
    execute "alter table revisions rename card_id to page_id"
    execute "alter table wiki_references rename card_id to page_id"
    execute "alter table wiki_references rename referenced_card_id to referenced_page_id"
    execute "alter table cards rename to pages"
    execute "alter table card_summaries rename to page_summaries"
    execute "alter table page_summaries rename card_id to page_id"
  end
end
