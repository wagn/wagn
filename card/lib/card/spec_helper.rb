module SpecHelper
end

module Card::SpecHelper
  include Rails::Dom::Testing::Assertions::SelectorAssertions
  # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#

  def login_as user
    Card::Auth.current_id = (uc = Card[user.to_s]) && uc.id
    return unless @request
    @request.session[:user] = Card::Auth.current_id
    # warn "(ath)login_as #{user.inspect}, #{Card::Auth.current_id}, "\
    #      "#{@request.session[:user]}"
  end

  def create! name, content=""
    Card.create! name: name, content: content
  end

  def assert_view_select view_html, *args, &block
    node = Nokogiri::HTML::Document.parse(view_html).root
    if block_given?
      assert_select node, *args, &block
    else
      assert_select node, *args
    end
  end

  def debug_assert_view_select view_html, *args, &block
    Rails.logger.rspec <<-HTML
      #{CodeRay.scan(Nokogiri::XML(view_html, &:noblanks).to_s, :html).div}
      <style>
        .CodeRay {
          background-color: #FFF;
          border: 1px solid #CCC;
          padding: 1em 0px 1em 1em;
        }
        .CodeRay .code pre { overflow: auto }
      </style>
    HTML
    assert_view_select view_html, *args, &block
  end

  def render_editor type
    card = Card.create(name: "my favority #{type} + #{rand(4)}", type: type)
    card.format.render(:edit)
  end

  def render_content content, format_args={}
    render_content_with_args content, format_args
  end

  def render_content_with_args content, format_args={}, view_args={}
    @card ||= Card.new name: "Tempo Rary 2"
    @card.content = content
    @card.format(format_args)._render :core, view_args
  end

  def render_card view, card_args={}, format_args={}
    render_card_with_args view, card_args, format_args
  end

  def render_card_with_args view, card_args={}, format_args={}, view_args={}
    card = begin
      if card_args[:name]
        Card.fetch card_args[:name], new: card_args
      else
        Card.new card_args.merge(name: "Tempo Rary")
      end
    end
    card.format(format_args)._render(view, view_args)
  end

  def users
    SharedData::USERS.sort
  end

  # Make expectations in the event phase.
  # Takes a stage and registers the event_block in this stage as an event.
  # Unknown methods in the event_block are executed in the rspec context
  # instead of the card's context.
  # An additionally :trigger block in opts is expected that is called
  # to start the event phase.
  # Other event options like :on or :when are not supported yet.
  # Example:
  # in_stage :initialize,
  #          trigger: ->{ test_card.update_attributes! content: '' } do
  #            expect(item_names).to eq []
  #          end
  def in_stage stage, opts={}, &event_block
    Card.rspec_binding = binding
    add_test_event stage, :in_stage_test, opts, &event_block
    trigger =
      if opts[:trigger].is_a?(Symbol)
        method(opts[:trigger])
      else
        opts[:trigger]
      end
    trigger.call
  ensure
    remove_test_event stage, :in_stage_test
  end

  def add_test_event stage, name, opts={}, &event_block
    # use random set module that is always included so that the
    # event applies to all cards
    opts[:set] ||= Card::Set::All::Event
    if (only_for_card = opts.delete(:for))
      opts[:when] = proc { |c| c.name == only_for_card }
    end
    Card.class_eval do
      extend Card::Set::Event
      event name, stage, opts, &event_block
    end
  end

  def remove_test_event stage, name
    stage_sym = :"#{stage}_stage"
    Card.skip_callback stage_sym, :after, name
  end

  def test_event stage, opts={}, &block
    event_name = :"test_event_#{@events.size}"
    @events << [stage, event_name]
    add_test_event stage, event_name, opts, &block
  end

  def with_test_events
    @events = []
    Card.rspec_binding = binding
    yield
  ensure
    @events.each do |stage, name|
      remove_test_event stage, name
    end
    Card.rspec_binding = false
  end
end
