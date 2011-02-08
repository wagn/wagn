class Renderer

  view(:raw, :name=>'*recent_change') do
    %{{"sort":"update", "dir":"desc", "view":"change"}}
  end

  view(:raw, :name=>'*search') do
    %{{"match":"_keyword", "sort":"relevance"}}
  end

  view(:raw, :name=>'*broken_link') do
    %{{"link_to":"_none"}}
  end
end
