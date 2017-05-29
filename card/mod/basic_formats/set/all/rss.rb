format :rss do
  attr_accessor :xml

  def initialize card, args
    super
    @xml = @parent ? @parent.xml : ::Builder::XmlMarkup.new
  end

  def show view, args
    view ||= :feed
    render view, args
  end

  # FIXME: integrate this with common XML features when it is added
  view :feed, cache: :never do
    begin
      @xml.instruct! :xml, version: "1.0", standalone: "yes"
      @xml.rss version: "2.0",
               "xmlns:content" => "http://purl.org/rss/1.0/modules/content/" do
        @xml.channel do
          @xml.title       render_feed_title
          @xml.description render_feed_description
          @xml.link        render_url
          render_feed_body
        end
      end
    rescue => e
      @xml.error "\n\nERROR rendering RSS: #{e.inspect}\n\n #{e.backtrace}"
    end
  end

  def raw_feed_items
    [card]
  end

  view :feed_body, cache: :never do
    render_feed_item_list
  end

  view :feed_item_list, cache: :never do
    raw_feed_items.each do |item|
      @xml.item do
        subformat(item).render(:feed_item,
                               description_view: feed_item_description_view)
      end
    end
  end

  view :feed_title do
    Card.global_setting(:title) + " : " + card.name.gsub(/^\*/, "")
  end

  view :feed_item, cache: :never do |args|
    @xml.title card.name
    add_name_context
    @xml.description description(args)
    @xml.pubDate pub_date
    @xml.link render_url
    @xml.guid render_url
  end

  def pub_date
    (card.updated_at || Time.zone.now).to_s(:rfc822)
    # updated_at fails on virtual
    # cards, because not all to_s's take args (just actual dates)
  end

  def description args
    render(args[:description_view] || :open_content)
  end

  def feed_item_description_view
    :open_content
  end

  view :feed_description do "" end
  view :comment_box      do "" end
  view :menu             do "" end

  view :open,         view: :titled, mod: All::Base::Format
  view :content,      view: :core,   mod: All::Base::Format
  view :open_content, view: :core,   mod: All::Base::Format
  view :closed,       view: :link,   mod: All::Base::Format
end
