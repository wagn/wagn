module SpecHelper
end
module Card::SpecHelper
  include Rails::Dom::Testing::Assertions::SelectorAssertions
  # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#

  def login_as user
    Card::Auth.current_id = (uc = Card[user.to_s]) && uc.id
    return unless @request
    @request.session[:user] = Card::Auth.current_id
    # warn "(ath)login_as #{user.inspect}, #{Card::Auth.current_id}, #{@request.session[:user]}"
  end

  def newcard name, content=''
    #FIXME - misleading name; sounds like it doesn't save.
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
    Rails.logger.rspec %(
      #{CodeRay.scan(Nokogiri::XML(view_html, &:noblanks).to_s, :html).div}
      <style>
        .CodeRay {
          background-color: #FFF;
          border: 1px solid #CCC;
          padding: 1em 0px 1em 1em;
        }
        .CodeRay .code pre { overflow: auto }
      </style>
    )
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
    @card ||= Card.new name: 'Tempo Rary 2'
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
        Card.new card_args.merge(name: 'Tempo Rary')
      end
    end
    card.format(format_args)._render(view, view_args)
  end

  def users
    SharedData::USERS.sort
  end

  # Make expectations in the event phase.
  # Takes the usual event options :on and :before/:after/:around
  # and registers the event_block with these options as an event.
  # Unknown methods in the event_block are executed in the rspec context
  # instead of the card's context.
  # An additionaly :trigger block in opts is expected that is called
  # to start the event phase.
  # Example:
  # in_phase before: :approve, on: :save,
  #          trigger: ->{ test_card.update_attributes! content: '' } do
  #            expect(item_names).to eq []
  #          end
  def in_phase opts, &event_block
    $rspec_binding = binding
    Card.class_eval do
      def method_missing m, *args
        begin
          method = eval('method(%s)' % m.inspect, $rspec_binding)
        rescue NameError
        else
          return method.call(*args)
        end
        begin
          value = eval(m.to_s, $rspec_binding)
          return value
        rescue NameError
        end
        super
#        raise NoMethodError
      end
      define_method :in_phase_test, event_block
    end
    Card.define_callbacks :in_phase_test
    kind =  ([:before, :after, :around] & opts.keys).first
    name = opts.delete(kind)
    Card.set_callback name, kind, :in_phase_test, prepend: true
    opts[:trigger].call
  ensure
    Card.skip_callback name, kind, :in_phase_test
  end
end
