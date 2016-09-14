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

    def users
      SharedData::USERS.sort
    end

    def bucket_credentials key
      @buckets ||= begin
        yml_file =
          ENV["BUCKET_CREDENTIALS_PATH"] ||
          File.expand_path("../config/bucket_credentials.yml", __FILE__)
        if File.exist?(yml_file)
          YAML.load_file(yml_file).deep_symbolize_keys
        else
          {}
        end
      end
      @buckets[key]
    end
  end
end
