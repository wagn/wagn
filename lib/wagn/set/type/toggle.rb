
module Wagn
  module Set::Type::Toggle
    include Sets

    format :base

    define_view :core, :type=>'toggle' do |args|
      case card.raw_content.to_i
        when 1; 'yes'
        when 0; 'no'
        else  ; '?'
        end
    end

    define_view :editor, :type=>'toggle' do |args|
      form.check_box :content
    end
  end
end
