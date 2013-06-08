# -*- encoding : utf-8 -*-
module Wagn
  module Set::Type::PlaintextPhraseHtmlAndNumber
    extend Set

    format :base

    view :editor, :type=>'plain_text' do |args|
      form.text_area :content, :rows=>3, :class=>'card-content'
    end

    view :editor, :type=>'phrase' do |args|
      form.text_field :content, :class=>'phrasebox card-content'
    end

    view :editor, :type=>'number' do |args|
      form.text_field :content, :class=>'card-content'
    end

    view :editor, :type=>'html' do |args|
      form.text_area :content, :rows=>15, :class=>'card-content'
    end

    view :closed_content, :type=>'html' do |args|
      ''
    end

    format :html

    view :core, :type=>'plain_text' do |args|
      process_content_object( CGI.escapeHTML _render_raw )
    end
  end
end
