class Renderer

  view(:raw, '*recent_change+*self') do
    %{{"sort":"update", "dir":"desc", "view":"change"}}
  end

  view(:raw, '*search+*self') do
    %{{"match":"_keyword", "sort":"relevance"}}
  end

  view(:raw, '*broken_link+*self') do
    %{{"link_to":"_none"}}
  end
end
