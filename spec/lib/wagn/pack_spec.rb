# -*- encoding : utf-8 -*-
require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe Wagn::Sets do
  context "load_all" do
    it "loads files in the modules directory" do
      pending 'needs further isolation; generates broader dependency issues'
      begin
        file = "#{Rails.root}/local/dummy_spec_module.rb"
        File.open(file, "w") do |f|
          f.write <<-EOF
            module JBob
              def self.foo(); "bar"; end
            end
          EOF
        end
        Wagn::Sets.dirs << file
        Wagn::Sets.load
        JBob.foo.should == "bar"
      ensure
        `rm #{file}`  #PLATFORM SPECIFIC
      end
    end
  end
end
