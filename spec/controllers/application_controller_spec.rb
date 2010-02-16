require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do
  describe "main_card?" do
    it "should be true for main card" do
      @controller.instance_variable_set('@context', "main_d8d070f")
      @controller.send(:main_card?).should be_true
    end

    it "should not be true for non main card" do
      @controller.instance_variable_set('@context', "main_d8d070f_faf914")
      @controller.send(:main_card?).should_not be_true
    end
  end
  
  describe "per_request_setup" do
    it "invokes params hook" do
      Wagn::Hook.should_receive(:call).with(:before_request, "*all", instance_of(ApplicationController))
      @controller.send(:per_request_setup)
    end
  end
end
