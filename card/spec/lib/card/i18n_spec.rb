# -*- encoding : utf-8 -*-
require "pathname"

use_i18_tasks = !(RUBY_VERSION =~ /^(1|2\.0)/)
if use_i18_tasks
  require "i18n/tasks"
end

# Note: I18n::Tasks only knows how to function when run from root of Card GEM,
# since it locates its configuration file and source to parse relative to this

def card_gem_root
  Pathname(__FILE__).parent.parent.parent.parent.to_s
end

RSpec.describe "I18n" do
  if use_i18_tasks
    let(:i18n) { Dir.chdir(card_gem_root) { I18n::Tasks::BaseTask.new } }
    let(:missing_keys) { Dir.chdir(card_gem_root) { i18n.missing_keys } }
    let(:unused_keys) { Dir.chdir(card_gem_root) { i18n.unused_keys } }
  end

  it "does not have missing keys" do
    unless use_i18_tasks
      skip "upgrade to Ruby 2.1+ and install i18n-tasks gem"
    end
    expect(missing_keys).to be_empty,
      "Missing #{missing_keys.leaves.count} i18n keys, to show them `cd` to " \
      "root of `card` gem and run `i18n-tasks missing`"
  end

  it "does not have unused keys" do
    unless use_i18_tasks
      skip "upgrade to Ruby 2.1+ and install i18n-tasks gem"
    end
    expect(unused_keys).to be_empty,
      "#{unused_keys.leaves.count} unused i18n keys, to show them `cd` to " \
      "root of `card` gem and run `i18n-tasks unused`"
  end
end
