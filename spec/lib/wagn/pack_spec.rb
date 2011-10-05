require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Wagn::Pack do
  context "load_all" do
    it "loads files in the modules directory" do
      begin
        file = "#{RAILS_ROOT}/modules/dummy_spec_module.rb"
        File.open(file, "w") do |f|
          f.write <<-EOF
            module JBob 
              def self.foo(); "bar"; end
            end
          EOF
        end
        Wagn::Pack.dirs << file
        Wagn::Pack.load_all
        JBob.foo.should == "bar"
      ensure
        `rm #{file}`
      end
    end
  end
end                                            
