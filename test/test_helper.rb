require 'rubygems'

unless defined? TEST_ROOT
  ENV["RAILS_ENV"] = "test"
  require 'pathname'
  TEST_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__))).cleanpath(true).to_s
  require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
  require 'test_help' 
  
  load TEST_ROOT + '/helpers/wagn_test_helper.rb'
  load TEST_ROOT + '/helpers/permission_test_helper.rb'
  load TEST_ROOT + '/helpers/chunk_test_helper.rb'  # FIXME-- should only be in certain tests
  
  class ActiveSupport::TestCase
    include AuthenticatedTestHelper
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

    Wagn::Cache::Main.new( Rails.cache, "#{System.host}/test" ).reset
    Wagn::Cache::Main.new( Rails.cache, "#{System.host}/cucumber" ).reset

    def setup
      # let the cache stick accross test-runs while profiling
      unless ActionController.const_defined?("PerformanceTest") and self.class.superclass == ActionController::PerformanceTest
        Wagn::Cache.reset_for_tests
      end
    end
  end

  class ActiveSupport::TestCase      
    include AuthenticatedTestHelper
    include WagnTestHelper
    include ChunkTestHelper

    def prepare_url(url, cardtype)
      if url =~ /:id/
        # find by naming convention in test data:
        card = Card["Sample #{cardtype}"] or puts "ERROR finding 'Sample #{cardtype}'"
        url.gsub!(/:id/,card.id.to_s)
      end
      url
    end
  
    class << self      
      def test_render(url,*args)  
        RenderTest.new(self,url,*args)
      end
      
      # Class method for test helpers
      def test_helper(*names)
        names.each do |name|
          name = name.to_s
          name = $1 if name =~ /^(.*?)_test_helper$/i
          name = name.singularize
          first_time = true
          begin
            constant = (name.camelize + 'TestHelper').constantize
            self.class_eval { include constant }
          rescue NameError
            filename = File.expand_path(TEST_ROOT + '/helpers/' + name + '_test_helper.rb')
            require filename if first_time
            first_time = false
            retry
          end
        end
      end    
      alias :test_helpers :test_helper
    end
    
    class RenderTest
      attr_reader :title, :url, :cardtype, :user, :status, :card
      def initialize(test_class,url,args={})
        @test_class,@url = test_class,url
        
        args[:users] ||= { :anon=>200 }
        args[:cardtypes] ||= ['Basic']
        if args[:cardtypes]==:all 
          cardtypes_defined_in_code =  Dir["app/cardtypes/*.rb"].map {|x| x.match(/\/([^\/\.]+)\.rb$/)[1].camelize }
          cardtypes_loaded_in_fixtures = YAML.load_file('test/fixtures/cardtypes.yml').collect {|k,v| v['class_name']}                   
          args[:cardtypes] = cardtypes_defined_in_code & cardtypes_loaded_in_fixtures
        end

        args[:users].each_pair do |user,status|
          user = user.to_s

          args[:cardtypes].each do |cardtype|    
            next if cardtype=~ /Cardtype|UserForm/

            title = url.gsub(/:id/,'').gsub(/\//,'_') + "_#{cardtype}"
            login = (user=='anon' ? '' : "integration_login_as '#{user}'")
            test_def = %{
              def test_render_#{title}_#{user}_#{status} 
                #{login}
                url = prepare_url('#{url}', '#{cardtype}')
                #warn "GET \#\{url\}"
                get url
                assert_response #{status}, "\#\{url\} as #{user} should have status #{status}"
              end
            }
            @test_class.class_eval test_def
            #puts test_def
          end
        end
      end                     
    end
    
  end


end  

