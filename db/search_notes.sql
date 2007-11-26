  
-- add vector column 
alter table cards add column indexed_content tsvector;


-- update vector column
update cards set indexed_content = concat( setweight( to_tsvector( name ), 'A' ), 
to_tsvector( (select content from revisions where id=cards.current_revision_id) ) ) 



