helper_path = File.expand_path "../helper/*.rb", __FILE__
Dir[helper_path].each { |f| require f }

class Card
  # to be included in  RSpec::Core::ExampleGroup
  module SpecHelper
    include RenderHelper
    include EventHelper
    include SaveHelper

    # ~~~~~~~~~  HELPER METHODS ~~~~~~~~~~~~~~~#
    include Rails::Dom::Testing::Assertions::SelectorAssertions

    def login_as user
      Card::Auth.current_id = (uc = Card[user.to_s]) && uc.id
      return unless @request
      @request.session[:user] = Card::Auth.current_id
      # warn "(ath)login_as #{user.inspect}, #{Card::Auth.current_id}, "\
      #      "#{@request.session[:user]}"
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
      log_html view_html
      assert_view_select view_html, *args, &block
    end

    def log_html html
      parsed_html = CodeRay.scan(Nokogiri::XML(html, &:noblanks).to_s, :html)
      if Rails.logger.respond_to? :rspec
        Rails.logger.rspec "#{parsed_html.div}#{CODE_RAY_STYLE}"
      else
        puts parsed.text
      end
    end

    CODE_RAY_STYLE = <<-HTML
      <style>
        .CodeRay {
          background-color: #FFF;
          border: 1px solid #CCC;
          padding: 1em 0px 1em 1em;
        }
        .CodeRay .code pre { overflow: auto }
      </style>
    HTML

    def users
      SharedData::USERS.sort
    end

    def bucket_credentials key
      @buckets ||= bucket_credentials_from_yml_file || {}
      @buckets[key]
    end

    def bucket_credentials_from_yml_file
      yml_file = ENV["BUCKET_CREDENTIALS_PATH"] ||
                 File.expand_path("../bucket_credentials.yml", __FILE__)
      File.exist?(yml_file) && YAML.load_file(yml_file).deep_symbolize_keys
    end
  end
end
