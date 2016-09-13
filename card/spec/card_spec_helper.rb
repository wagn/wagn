class Card
  def self.gimme! name, args={}
    Card::Auth.as_bot do
      c = Card.fetch(name, new: args)
      c.putty args
      Card.fetch name
    end
  end

  def self.gimme name, args={}
    Card::Auth.as_bot do
      c = Card.fetch(name, new: args)
      if args[:content] && c.content != args[:content]
        c.putty args
        c = Card.fetch name
      end
      c
    end
  end

  cattr_accessor :rspec_binding

  module SpecHelper
    include Rails::Dom::Testing::Assertions::SelectorAssertions

    # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#

    include Card::Model::SaveHelper
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

    def create_or_update name_or_args, args={}
      Card::Auth.as_bot { super }
    end

    def update name, args
      Card::Auth.as_bot { update_card name, args }
    end

    def putty args={}
      Card::Auth.as_bot do
        if args.present?
          update_attributes! args
        else
          save!
        end
      end
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

    def bucket_credentials key
      @buckets ||= begin
        yml_file =
          ENV["BUCKET_CREDENTIALS_PATH"] ||
            File.expand_path("../config/bucket_credentials.yml", __FILE__)
        File.exist?(yml_file) ? YAML.load_file(yml_file).deep_symbolize_keys : {}
      end
      @buckets[key]
    end

    # rubocop:disable Lint/Eval
    def method_missing m, *args, &block
      return super unless Card.rspec_binding
      suppress_name_error do
        method = eval("method(%s)" % m.inspect, Card.rspec_binding)
        return method.call(*args, &block)
      end
      suppress_name_error do
        return eval(m.to_s, Card.rspec_binding)
      end
      super
    end
    # rubocop:enable Lint/Eval

    def suppress_name_error
      yield
    rescue NameError
    end

    def format_with_set set, format_type=:html
      singleton_class.send :include, set
      format = format format_type
      format_class = Card::Format.format_class_name format_type
      format.singleton_class.send :include, set.const_get(format_class)
      yield(format)
    end
  end
end
