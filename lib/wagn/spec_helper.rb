module Wagn::SpecHelper

  include ActionDispatch::Assertions::SelectorAssertions
  #~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
  
  def login_as user
    Card::Auth.current_id = (uc=Card[user.to_s] and uc.id)
    if @request
      @request.session[:user] = Card::Auth.current_id
    end
    #warn "(ath)login_as #{user.inspect}, #{Card::Auth.current_id}, #{@request.session[:user]}"
  end
  
  def newcard name, content=""
    #FIXME - misleading name; sounds like it doesn't save.
    Card.create! :name=>name, :content=>content
  end

  def assert_view_select(view_html, *args, &block)
    node = HTML::Document.new(view_html).root
    if block_given?
      assert_select node, *args, &block
    else
      assert_select node, *args
    end
  end

  def render_editor(type)
    card = Card.create(:name=>"my favority #{type} + #{rand(4)}", :type=>type)
    card.format.render(:edit)
  end

  def render_content content, format_args={}
    @card ||= Card.new :name=>"Tempo Rary 2"
    @card.content = content
    @card.format(format_args)._render :core
  end

  def render_card view, card_args={}, format_args={}
    card = begin
      if card_args[:name]
        Card.fetch card_args[:name], :new=>card_args
      else
        Card.new card_args.merge( :name=> 'Tempo Rary' )
      end
    end
    card.format(format_args)._render(view)
  end
end
