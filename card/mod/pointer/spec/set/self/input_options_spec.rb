describe Card::Set::Self::InputOptions do
  it "loads the self set" do
    $stop = true
    expect(Card[:input, :right, :options].raw_content).to eq "somethging"
  end
end
