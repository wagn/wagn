# -*- encoding : utf-8 -*-

#FIXME need more specific assertions

describe Card::Set::Self::Signin do
  
  before :each do
    @card = Card[:signin]
  end
  
  it 'open view should have email and password fields' do
    open_view = @card.format.render_open
    open_view.should =~ /email/
    open_view.should =~ /password/
    
  end
  
  it 'edit view should prompt for forgot password' do
    edit_view = @card.format.render_edit
    edit_view.should =~ /email/
    edit_view.should =~ /reset_password/
  end
  
  it 'password reset success view should prompt to check email' do
    rps_view = @card.format.render_reset_password_success
    rps_view.should =~ /Check your email/
  end
  
  it 'delete action should sign out account' do
    Card::Auth.current_id.should == Card['joe_user'].id
    @card.delete
    Card::Auth.current_id.should == Card::AnonymousID
  end
  
  context "#update" do
    it 'should trigger signin with valid credentials' do
      @card.update_attributes! '+*email'=>'joe@admin.com', '+*password'=>'joe_pass'
      Card::Auth.current.should == Card['joe admin']
    end


    it 'should not trigger signin with bad email' do
      @card.update_attributes! '+*email'=>'schmoe@admin.com', '+*password'=>'joe_pass'
      @card.errors[:signin].first.should =~ /Unrecognized email/
    end
    
    it 'should not trigger signin with bad password' do
      @card.update_attributes! '+*email'=>'joe@admin.com', '+*password'=>'joe_fail'
      @card.errors[:signin].first.should =~ /Wrong password/
    end
    
    
  end
  
  context '#reset password' do
    before :each do
      Card::Env.params[:reset_password] = true
    end
    
    it 'should be triggered by an update' do
      #Card['joe admin'].account.token.should be_nil FIXME - this should be t
      @card.update_attributes! '+*email'=>'joe@admin.com'
      Card['joe admin'].account.token.should_not be_nil
    end
    
    it 'should return an error if email is not found' do
      @card.update_attributes! '+*email'=>'schmoe@admin.com'
      @card.errors[:account].first.should =~ /not found/
    end
  end
  
end

