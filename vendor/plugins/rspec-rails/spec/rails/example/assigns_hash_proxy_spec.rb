require File.dirname(__FILE__) + '/../../spec_helper'

describe "AssignsHashProxy" do
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/example/assigns_hash_proxy_spec.rb
  def orig_assigns
    @object.assigns
  end
  
  before(:each) do
    @object = Class.new do
      attr_accessor :assigns
    end.new
    @object.assigns = Hash.new
    @proxy = Spec::Rails::Example::AssignsHashProxy.new self do
      @object
    end
  end
  
  it "should set ivars on object using string" do
    @proxy['foo'] = 'bar'
    @object.instance_eval{@foo}.should == 'bar'
  end
  
  it "should set ivars on object using symbol" do
    @proxy[:foo] = 'bar'
    @object.instance_eval{@foo}.should == 'bar'
  end
  
  it "should access object's assigns with a string" do
    @object.assigns['foo'] = 'bar'
    @proxy[:foo].should == 'bar'
  end
  
  it "should access object's assigns with a symbol" do
    @object.assigns['foo'] = 'bar'
    @proxy[:foo].should == 'bar'
  end

  it "iterates through each element like a Hash" do
=======
  before(:each) do
    @object = Object.new
    @assigns = Hash.new
    @object.stub!(:assigns).and_return(@assigns)
    @proxy = Spec::Rails::Example::AssignsHashProxy.new(@object)
  end

  it "has [] accessor" do
    @proxy['foo'] = 'bar'
    @assigns['foo'].should == 'bar'
    @proxy['foo'].should == 'bar'
  end

  it "works for symbol key" do
    @assigns[:foo] = 2
    @proxy[:foo].should == 2
  end

  it "checks for string key before symbol key" do
    @assigns['foo'] = false
    @assigns[:foo] = 2
    @proxy[:foo].should == false
  end

  it "each method iterates through each element like a Hash" do
>>>>>>> add/update rspec:vendor/plugins/rspec-rails/spec/rails/example/assigns_hash_proxy_spec.rb
    values = {
      'foo' => 1,
      'bar' => 2,
      'baz' => 3
    }
    @proxy['foo'] = values['foo']
    @proxy['bar'] = values['bar']
    @proxy['baz'] = values['baz']
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/example/assigns_hash_proxy_spec.rb
  
=======

>>>>>>> add/update rspec:vendor/plugins/rspec-rails/spec/rails/example/assigns_hash_proxy_spec.rb
    @proxy.each do |key, value|
      key.should == key
      value.should == values[key]
    end
  end
<<<<<<< HEAD:vendor/plugins/rspec-rails/spec/rails/example/assigns_hash_proxy_spec.rb
  
  it "deletes the element of passed in key" do
    @object.assigns['foo'] = 'bar'
    @proxy.delete('foo').should == 'bar'
    @proxy['foo'].should be_nil
  end
  
  it "detects the presence of a key" do
    @object.assigns['foo'] = 'bar'
    @proxy.has_key?('foo').should == true
    @proxy.has_key?('bar').should == false
  end
=======

  it "delete method deletes the element of passed in key" do
    @proxy['foo'] = 'bar'
    @proxy.delete('foo').should == 'bar'
    @proxy['foo'].should be_nil
  end

  it "has_key? detects the presence of a key" do
    @proxy['foo'] = 'bar'
    @proxy.has_key?('foo').should == true
    @proxy.has_key?('bar').should == false
  end
  
  it "should sets an instance var" do
    @proxy['foo'] = 'bar'
    @object.instance_eval { @foo }.should == 'bar'
  end
>>>>>>> add/update rspec:vendor/plugins/rspec-rails/spec/rails/example/assigns_hash_proxy_spec.rb
end
