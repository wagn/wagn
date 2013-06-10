# -*- encoding : utf-8 -*-
module Wagn
  module Set::Self::Misc
    extend Wagn::Set

    format :base

    view :raw, :name=>'now' do |args|
      Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z')
    end
    view(:raw, {:name=>'now'}, :core)


    view :raw, :name=>:version do |args|
      Wagn::Version.to_s
    end
    view(:raw, {:name=>:version}, :core)


    view :raw, :name=>'alerts' do |args|
      '<!-- *alerts is deprecated. please remove from layout -->'
    end
    view(:raw, {:name=>'alerts'}, :core)
  end
end
