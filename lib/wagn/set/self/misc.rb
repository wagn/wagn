# -*- encoding : utf-8 -*-
module Wagn
  module Set::Self::Misc
    include Wagn::Sets

    format :base

    define_view :raw, :name=>'now' do |args|
      Time.now.strftime('%A, %B %d, %Y %I:%M %p %Z')
    end
    alias_view(:raw, {:name=>'now'}, :core)


    define_view :raw, :name=>:version do |args|
      Wagn::Version.to_s
    end
    alias_view(:raw, {:name=>:version}, :core)


    define_view :raw, :name=>'alerts' do |args|
      '<!-- *alerts is deprecated. please remove from layout -->'
    end
    alias_view(:raw, {:name=>'alerts'}, :core)
  end
end
