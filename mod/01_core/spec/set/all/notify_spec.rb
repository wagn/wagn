describe Card::Set::All::Notify do
  describe '#change_notice' do
    context 'for a new card' do
      subject { Card.create!(:name=>'cn card', :content=>'my content', 
                              :subcards=>{ '+s1'=>{:content=>'this is s1'}, 
                                           '+s2'=>{:content=>'this is s2'} }).format.render_change_notice
                }
      it { is_expected.to include('my content') }
    end
  end
end