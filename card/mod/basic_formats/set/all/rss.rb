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
  view :feed do
    begin
      @xml.instruct! :xml, version: "1.0"
      @xml.rss version: "2.0" do
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

  def raw_feed_items _args
    [card]
  end

  view :feed_body do |_args|
    render_feed_item_list
  end

  view :feed_item_list do |args|
    raw_feed_items(args).each do |item|
      @xml.item do
        # FIXME: yuck.
        subformat(item).render_feed_item view_changes: (card.id == RecentID)
      end
    end
  end

  view :feed_title do
    Card.global_setting(:title) + " : " + card.name.gsub(/^\*/, "")
  end

  view :feed_item do |args|
    @xml.title card.name
    add_name_context
    @xml.description render((args[:view_changes] ? :change : :open_content))
    @xml.pubDate card.revised_at.to_s(:rfc822)  # updated_at fails on virtual
    # cards, because not all to_s's take args (just actual dates)
    @xml.link render_url
    @xml.guid render_url
  end

  view :feed_description do "" end
  view :comment_box      do "" end
  view :menu             do "" end

  view :open,         view: :titled, mod: All::Base::Format
  view :content,      view: :core,   mod: All::Base::Format
  view :open_content, view: :core,   mod: All::Base::Format
  view :closed,       view: :link,   mod: All::Base::Format
end
