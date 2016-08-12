format :html do
  view :views_by_format do
    format_views =
      self.class.ancestors.each_with_object({}) do |format_class, hash|
        views =
          format_class.instance_methods.map do |method|
            next unless method.to_s =~ /^_view_(.+)$/
            Regexp.last_match(1)
          end.compact
        next unless  views.present?
        format_class.name =~ /^Card(::Set)?::(.+?)$/ #::(\w+Format)
        hash[Regexp.last_match(2)] = views
      end
    accordion_group format_views
  end

  view :views_by_name do
    views = methods.map do |method|
      Regexp.last_match(1) if method.to_s =~ /^_view_(.+)$/
    end.compact.sort
    list_group views
  end
end
