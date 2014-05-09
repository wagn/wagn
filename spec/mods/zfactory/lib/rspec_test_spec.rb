describe 'my pet' do
  shared_examples_for 'a dog' do |filetype|
    it 'has a supplies card' do
      @test = "kukcuk"
      input.call(@test)
    end
  end

  it_should_behave_like 'a dog', "test" do
    let(:input) { Proc.new {|x| puts x} }
  end
end

