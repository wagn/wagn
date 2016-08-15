
describe Card::Mod::Loader::ModDirs do
  it 'loads mods from Modfile' do
    path = File.expand_path "..", __FILE__
    tg = Card::Mod::Loader::ModDirs.new path
    expect(tg.mods).to eq %w(mod1 mod2)
  end
end
