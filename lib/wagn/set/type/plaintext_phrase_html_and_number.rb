module Wagn
  module Set::Type::PlaintextPhraseHtmlAndNumber
    include Sets

    format :base

    define_view :editor, :type=>'plain_text' do |args|
      form.text_area :content, :rows=>3, :class=>'card-content'
    end

    define_view :editor, :type=>'phrase' do |args|
      form.text_field :content, :class=>'phrasebox card-content'
    end

    define_view :editor, :type=>'number' do |args|
      form.text_field :content, :class=>'card-content'
    end

    define_view :editor, :type=>'html' do |args|
      form.text_area :content, :rows=>30, :class=>'card-content'
    end

    define_view :closed_content, :type=>'html' do |args|
      ''
    end

    format :html

    define_view :core, :type=>'plain_text' do |args|
      process_content_object( CGI.escapeHTML _render_raw )
    end
  end
end
