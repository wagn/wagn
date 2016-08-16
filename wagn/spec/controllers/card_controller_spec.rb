# -*- encoding : utf-8 -*-

describe CardController do
  routes { Decko::Engine.routes }

  include Capybara::DSL
  describe "- route generation" do
    def card_route_to opts={}
      route_to opts.merge(controller: "card")
    end

    it "should recognize type" do
      # all_routes = Rails.application.routes.routes
      # require 'rails/application/route_inspector'
      # warn "rountes#{ENV['CONTROLLER']}:\n" + Rails::Application::RouteInspector.new.format(all_routes, ENV['CONTROLLER'])* "\n"

      expect(get: "/new/Phrase")
        .to card_route_to(action: "read", type: "Phrase", view: "new")
    end

    it "should recognize .rss on /recent" do
      expect(get: "/recent.rss")
        .to card_route_to(action: "read", id: ":recent", format: "rss")
    end

    it "should handle RESTful posts" do
      expect(put: "/mycard").to card_route_to(action: "update", id: "mycard")
      expect(put: "/").to card_route_to(action: "update")
    end

    it "handle asset requests" do
      expect(get: "/asset/application.js")
        .to card_route_to(action: "asset", id: "application", format: "js")
    end

    ["/wagn", ""].each do |prefix|
      describe "routes prefixed with '#{prefix}'" do
        it "should recognize .rss format" do
          expect(get: "#{prefix}/*recent.rss")
            .to card_route_to(action: "read", id: "*recent", format: "rss")
        end

        it "should recognize .xml format" do
          expect(get: "#{prefix}/*recent.xml")
            .to card_route_to(action: "read", id: "*recent", format: "xml")
        end

        it "should accept cards without dots" do
          expect(get: "#{prefix}/random")
            .to card_route_to(action: "read", id: "random")
        end
      end
    end
  end

  describe "#create" do
    before do
      login_as "joe_user"
    end

    # FIXME: several of these tests go all the way to DB,
    #  which means they're closer to integration than unit tests.
    #  maybe think about refactoring to use mocks etc. to reduce
    #  test dependencies.
    it "creates cards" do
      post :create, card: {
        name: "NewCardFoo",
        type: "Basic",
        content: "Bananas"
      }
      assert_response 302
      c = Card["NewCardFoo"]
      expect(c.type_code).to eq(:basic)
      expect(c.content).to eq("Bananas")
    end

    it "handles permission denials" do
      post :create, card: {
        name: "LackPerms",
        type: "Html"
      }
      assert_response 403
      expect(Card["LackPerms"]).to be_nil
    end

    # no controller-specific handling.  move test elsewhere
    it "creates cardtype cards" do
      xhr :post, :create,
          card: { "content" => "test", type: "Cardtype", name: "Editor" }
      expect(assigns["card"]).not_to be_nil
      assert_response 200
      c = Card["Editor"]
      expect(c.type_code).to eq(:cardtype)
    end

    # no controller-specific handling.  move test elsewhere
    it "pulls deleted cards from trash" do
      @c = Card.create! name: "Problem", content: "boof"
      @c.delete!
      post :create,
           card: {
             "name" => "Problem", "type" => "Phrase", "content" => "noof"
           }
      assert_response 302
      c = Card["Problem"]
      expect(c.type_code).to eq(:phrase)
    end

    context "multi-create" do
      it "catches missing name error" do
        post :create, "card" => {
          "name" => "",
          "type" => "Fruit",
          "subcards" => { "+text" => { "content" => "<p>abraid</p>" } }
        }, "view" => "open"
        assert_response 422
        expect(assigns["card"].errors[:name].first).to eq("can't be blank")
      end

      it "creates card with subcards" do
        login_as "joe_admin"
        xhr :post, :create, success: "REDIRECT: /", card: {
          name: "Gala",
          type: "Fruit",
          subcards: {
            "+kind"  => { content: "apple" },
            "+color" => { type: "Phrase", content: "red"  }
          }
        }
        assert_response 200
        expect(Card["Gala"]).not_to be_nil
        expect(Card["Gala+kind"].content).to eq("apple")
        expect(Card["Gala+color"].type_name).to eq("Phrase")
      end
    end

    it "renders errors if create fails" do
      post :create, "card" => { "name" => "Joe User" }
      assert_response 422
    end

    it "redirects to thanks if present" do
      login_as "joe_admin"
      xhr :post, :create, success: "REDIRECT: /thank_you",
                          card: { "name" => "Wombly" }
      assert_response 200
      json = JSON.parse response.body
      expect(json["redirect"]).to match(/^http.*\/thank_you$/)
    end

    it "redirects to card if thanks is blank" do
      login_as "joe_admin"
      post :create, success: "REDIRECT: _self",
                    "card" => { "name" => "Joe+boop" }
      assert_redirected_to "/Joe+boop"
    end

    it "redirects to previous" do
      # Fruits (from shared_data) are anon creatable but not readable
      login_as :anonymous
      post :create, { success: "REDIRECT: *previous",
                      "card" => { "type" => "Fruit", name: "papaya" } },
           history: ["/blam"]
      assert_redirected_to "/blam"
    end
  end

  describe "#read" do
    it "works for basic request" do
      get :read, id: "Sample_Basic"
      expect(response.body.match(/\<body[^>]*\>/im)).to be_truthy
      # have_selector broke in commit 8d3bf2380eb8197410e962304c5e640fced684b9,
      # presumably because of a gem (like capybara?)
      # response.should have_selector('body')
      assert_response :success
      expect("Sample Basic").to eq(assigns["card"].name)
    end

    it "handles nonexistent card with create permission" do
      login_as "joe_user"
      get :read, id: "Sample_Fako"
      assert_response :success
    end

    it "handles nonexistent card without create permissions" do
      get :read, id: "Sample_Fako"
      assert_response 404
    end

    it "handles nonexistent card ids" do
      get :read, id: "~9999999"
      assert_response 404
    end

    it "returns denial when no read permission" do
      Card::Auth.as_bot do
        Card.create! name: "Strawberry", type: "Fruit" # only admin can read
      end
      get :read, id: "Strawberry"
      assert_response 403
      get :read, id: "Strawberry", format: "txt"
      assert_response 403
    end

    context "view = new" do
      before do
        login_as "joe_user"
      end

      it "should work on index" do
        get :read, view: "new"
        expect(assigns["card"].name).to eq("")
        assert_response :success, "response should succeed"
        assert_equal Card::BasicID, assigns["card"].type_id,
                     "@card type should == Basic"
      end

      it "new with name" do
        post :read, card: { name: "BananaBread" }, view: "new"
        assert_response :success, "response should succeed"
        assert_equal "BananaBread", assigns["card"].name,
                     "@card.name should == BananaBread"
      end

      it "new with existing name" do
        get :read, card: { name: "A" }, view: "new"
        # really?? how come this is ok?
        assert_response :success, "response should succeed"
      end

      it "new with type_code" do
        post :read, card: { type: "Date" }, view: "new"
        assert_response :success, "response should succeed"
        assert_equal Card::DateID, assigns["card"].type_id,
                     "@card type should == Date"
      end

      it "new should work for creatable nonviewable cardtype" do
        login_as :anonymous
        get :read, type: "Fruit", view: "new"
        assert_response :success
      end

      it "should use card params name over id in new cards" do
        get :read, id: "my_life", card: { name: "My LIFE" }, view: "new"
        expect(assigns["card"].name).to eq("My LIFE")
      end
    end

    context "css" do
      before do
        @all_style = Card["#{Card[:all].name}+#{Card[:style].name}"]
        @all_style.reset_machine_output
      end

      it "creates missing machine output file" do
        args = { id: @all_style.machine_output_card.name,
                 format: "css",
                 explicit_file: true }
        get :read, args
        # output_card = Card[:all, :style, :machine_output]
        expect(response).to redirect_to(@all_style.machine_output_url)
        get :read, args
        expect(response.status).to eq(200)
      end
    end

    context "file" do
      before do
        Card::Auth.as_bot do
          Card.create name: "mao2", type_code: "image",
                      image: File.new(File.join(FIXTURES_PATH, "mao2.jpg"))
          Card.create name: "mao2+*self+*read", content: "[[Administrator]]"
        end
      end

      it "handles image with no read permission" do
        get :read, id: "mao2"
        assert_response 403, "should deny html card view"
        get :read, id: "mao2", format: "jpg"
        assert_response 403, "should deny simple file view"
      end

      it "handles image with read permission" do
        login_as "joe_admin"
        get :read, id: "mao2"
        assert_response 200
        get :read, id: "mao2", format: "jpg"
        assert_response 200
      end
    end
  end

  describe "#asset" do
    it "serves file" do
      filename = "asset-test.txt"
      args = { id: filename, format: "txt", explicit_file: true }
      path =
        File.join(Decko::Engine.paths["gem-assets"].existent.first, filename)
      File.open(path, "w") { |f| f.puts "test" }
      args = { filename: filename.to_s }
      visit "/assets/#{filename}"
      expect(page.body).to eq "test\n"
      FileUtils.rm path
    end

    it "denies access to other directories" do
      args = { filename: "/../../Gemfile" }
      get :asset, args
      expect(response.status).to eq(404)
    end
  end

  describe "unit tests" do
    before do
      @simple_card = Card["Sample Basic"]
      login_as "joe_user"
    end

    describe "#update" do
      it "works" do
        xhr :post, :update, id: "~#{@simple_card.id}",
                            card: { content: "brand new content" }
        assert_response :success, "edited card"
        assert_equal "brand new content", Card["Sample Basic"].content,
                     "content was updated"
      end

      it "rename without update references should work" do
        f = Card.create! type: "Cardtype", name: "Apple"
        xhr :post, :update, id: "~#{f.id}", card: {
          name: "Newt",
          update_referers: "false"
        }
        expect(assigns["card"].errors.empty?).not_to be_nil
        assert_response :success
        expect(Card["Newt"]).not_to be_nil
      end

      it "update type_code" do
        xhr :post, :update, id: "~#{@simple_card.id}", card: { type: "Date" }
        assert_response :success, "changed card type"
        expect(Card["Sample Basic"].type_code).to eq(:date)
      end
    end

    describe "delete" do
      it "works" do
        c = Card.create(name: "Boo", content: "booya")
        post :delete, id: "~#{c.id}"
        assert_response :redirect
        expect(Card["Boo"]).to eq(nil)
      end

      # FIXME: this should probably be files in the spot for a delete test
      it "returns to previous undeleted card after deletion" do
        t1 = t2 = nil
        Card::Auth.as_bot do
          t1 = Card.create! name: "Testable1", content: "hello"
          t2 = Card.create! name: "Testable1+bandana", content: "world"
        end

        get :read, id: t1.key
        get :read, id: t2.key

        post :delete, id: "~" + t2.id.to_s
        assert_nil Card[t2.name]
        assert_redirected_to "/#{t1.name}"

        post :delete, id: "~" + t1.id.to_s
        assert_redirected_to "/"
        assert_nil Card[t1.name]
      end
    end

    it "should comment" do
      Card::Auth.as_bot do
        Card.create name: "basicname+*self+*comment",
                    content: "[[Anyone Signed In]]"
      end
      post :update, id: "basicname",
                    card: { comment: " and more\n  \nsome lines\n\n" }
      cont = Card["basicname"].content
      expect(cont).to match(/basiccontent/)
      expect(cont).to match(/some lines/)
    end
  end
end
