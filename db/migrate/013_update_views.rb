class UpdateViews < ActiveRecord::Migration
  def self.up
    execute "drop view page_summaries"
    execute "drop view page_titles"
    execute "drop view page_tag_names"
    execute "drop view current_revisions"
    execute "drop view current_tag_revisions"
    
    execute %{
      create view page_summaries as
      select 
        p.id as page_id,
        p.parent_id,
        p.name,
        p.value,
        pr.content,
        
        t.id as tag_id,
        tr.name as tag_name,
        
        t.node_id,
        case when n.type is not null then 'Node::' || n.type
              else t.node_type end as node_type
        
      from pages p
      join revisions pr on pr.id=p.current_revision_id
      
      join tags t on t.id=p.tag_id
      join tag_revisions tr on tr.id=t.current_revision_id
      
      left join nodes n on t.node_id = n.id and t.node_type='Node::Base'
        
    }
  end

  def self.down
  
    execute "drop view page_summaries"   
  
    execute %{
      create view current_revisions as
        select distinct on (page_id)
        id, page_id, revised_at, created_by, content 
        from revisions ORDER BY page_id, revised_at DESC
    }
    
    execute %{
      create view current_tag_revisions as
        select distinct on (tag_id)
        id, tag_id, revised_at, created_by, name 
        from tag_revisions ORDER BY tag_id, revised_at DESC
    }

    execute %{
      create or replace view page_tag_names as
      select p.id as page_id, p.parent_id, tr.name 
      from pages p join current_tag_revisions tr on tr.tag_id = p.tag_id
    }

    execute %{
      create view page_titles as
      select 
      p1.page_id,
      coalesce(
      p6.name || ' ~ ' || p5.name || ' ~ ' || p4.name || ' ~ ' || p3.name || ' ~ ' || p2.name || ' ~ ' || p1.name,
      p5.name || ' ~ ' || p4.name || ' ~ ' || p3.name || ' ~ ' || p2.name || ' ~ ' || p1.name,
      p4.name || ' ~ ' || p3.name || ' ~ ' || p2.name || ' ~ ' || p1.name,
      p3.name || ' ~ ' || p2.name || ' ~ ' || p1.name,
      p2.name || ' ~ ' || p1.name,
      p1.name) as title
      from page_tag_names p1 
      left join page_tag_names p2 on p2.page_id = p1.parent_id 
      left join page_tag_names p3 on p3.page_id = p2.parent_id 
      left join page_tag_names p4 on p4.page_id = p3.parent_id 
      left join page_tag_names p5 on p5.page_id = p4.parent_id 
      left join page_tag_names p6 on p6.page_id = p5.parent_id 
    }
    
    execute %{
      create view page_summaries as
      select distinct
        t.node_id,
        t.id as tag_id,
        p.id as page_id,
        p.parent_id,
        pt.title as name,
        case when n.type is not null then 'Node::' || n.type
              else t.node_type end as node_type,
        tr.name as tag_name,
        p.value,
        pr.revised_at,
        utr.name as revised_by,
        pr.content
        
      from pages p 
      join page_titles pt on pt.page_id=p.id
      join current_revisions pr on pr.page_id=p.id
      join users pu on pu.id=pr.created_by
        join tags ut on ut.node_id=pu.id and ut.node_type='User'
        join current_tag_revisions utr on utr.tag_id=ut.id 
      join tags t on t.id=p.tag_id
      join current_tag_revisions tr on tr.tag_id=t.id
      left join nodes n on t.node_id = n.id and t.node_type='Node::Base'
    }
  
  end
end
