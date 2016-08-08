# -*- encoding : utf-8 -*-
ENV["RAILS_ENV"] = "test"
require File.expand_path("../../lib/wagn/environment", __FILE__)
require "rails/test_help"
require "pathname"

unless defined? TEST_ROOT
  TEST_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__))).cleanpath(true).to_s

  class ActiveSupport::TestCase
    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
    #
    # Note: You'll currently still have to declare fixtures explicitly in integration tests
    # -- they do not yet inherit this setting
    # fixtures :all

    # Add more helper methods to be used by all tests here...

    # Transactional fixtures accelerate your tests by wrapping each test method
    # in a transaction that's rolled back on completion.  This ensures that the
    # test database remains unchanged so your fixtures don't have to be reloaded
    # between every test method.  Fewer database queries means faster tests.
    #
    # Read Mike Clark's excellent walkthrough at
    #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
    #
    # Every Active Record database supports transactions except MyISAM tables
    # in MySQL.  Turn off transactional fixtures in this case; however, if you
    # don't care one way or the other, switching from MyISAM to InnoDB tables
    # is recommended.
    self.use_transactional_fixtures = true

    # Instantiated fixtures are slow, but give you @david where otherwise you
    # would need people(:david).  If you don't want to migrate your existing
    # test cases which use the @david style and don't mind the speed hit (each
    # instantiated fixtures translates to a database query per test method),
    # then set this back to true.
    self.use_instantiated_fixtures  = false

    def prepare_url url, cardtype
      if url =~ /:id/
        # find by naming convention in test data:
        renames = { "layout_type" => "Layout", "search_type" => "Search" }
        if card = Card["Sample #{renames[cardtype] || cardtype}"]
          url.gsub!(/:id/, "~#{card.id}")
        else puts("ERROR finding 'Sample #{cardtype}'") end
      end
      url
    end

    class << self
      def test_render url, *args
        RenderTest.new(self, url, *args)
      end

      # Class method for test helpers
      def test_helper *names
        names.each do |name|
          name = name.to_s
          name = Regexp.last_match(1) if name =~ /^(.*?)_test_helper$/i
          name = name.singularize
          first_time = true
          begin
            constant = (name.camelize + "TestHelper").constantize
            class_eval { include constant }
          rescue NameError
            filename = File.expand_path(TEST_ROOT + "/helpers/" + name + "_test_helper.rb")
            require filename if first_time
            first_time = false
            retry
          end
        end
      end
      alias test_helpers test_helper
    end

    class RenderTest
      attr_reader :title, :url, :cardtype, :user, :status, :card
      def initialize test_class, url, args={}
        @test_class = test_class
        @url = url

        args[:users] ||= { anonymous: 200 }
        args[:cardtypes] ||= ["Basic"]
        if args[:cardtypes] == :all
          # FIXME: need a better data source for this?
          # args[:cardtypes] = YAML.load_file('db/bootstrap/card_codenames.yml').
          bootstrap_file = File.join(Cardio.gem_root, "db/bootstrap/cards.yml")
          args[:cardtypes] = YAML.load_file(bootstrap_file).select do |p|
            !%w(set setting).member?(p[1]["codename"]) &&
              (card = Card[p[1]["name"]]) && card.type_id == Card::CardtypeID
          end.map { |_k, v| v["codename"] }
        end

        args[:users].each_pair do |user, status|
          user = user.to_s
          current_id = Integer === user ? user : Card[user].id

          args[:cardtypes].each do |cardtype|
            next if cardtype =~ /Cardtype|UserForm|Set|Fruit|Optic|Book/

            title = url.gsub(/:id/, "").gsub(/\//, "_") + "_#{cardtype}"
            login = (current_id == Card::AnonymousID ? "" : "integration_login_as '#{user}'")
            test_def = %{
              def test_render_#{title}_#{user}_#{status}
                #{login}
                url = prepare_url('#{url}', '#{cardtype}')
                get url
                assert_response #{status}, "\#\{url\} as #{user} should have status #{status}"
              end
            }

            @test_class.class_eval test_def
          end
        end
      end
    end
  end
end
