drop view root_pages;
create or replace view root_pages as 
select 
  p.title as tag_name, 
  t.tag_type as node_type, 
  p.created_at, 
  v.body as body, 
  a.name_tag as author
from page p join tag t on t.name=p.title join entry_version v on v.page_id=p.id  
  and v.created_at=(select max(created_at) from entry_version where page_id=p.id)  
join users a on v.author_id=a.id where not t.name ~* ' ' and not t.name ~* '~';

drop view tag_pages;
create or replace view tag_pages as
select
  split_part(p.title,' ',1) as page_name, 
  split_part(p.title, ' ',2) as tag_name,
  p.created_at,
  v.body as body,
  a.name_tag as author
from page p join tag t on t.name=p.title join entry_version v on v.page_id=p.id  
  and v.created_at=(select created_at from entry_version where page_id=p.id order by created_at desc limit 1)  
join users a on v.author_id=a.id where t.name ~* ' '
UNION
select
  split_part(p.title,'~',1) as page_name, 
  split_part(p.title, '~',2) as tag_name,
  p.created_at,
  v.body as body,
  a.name_tag as author
from page p join tag t on t.name=p.title join entry_version v on v.page_id=p.id  
  and v.created_at=(select created_at from entry_version where page_id=p.id order by created_at desc limit 1)  
join users a on v.author_id=a.id where t.name ~* '~';

