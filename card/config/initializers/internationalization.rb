# -*- encoding : utf-8 -*-

# Arrange for locale files to be found
#
# Necessary since 'card' is packaged as a gem which is not an Engine

I18n.load_path += Dir.glob(Pathname(__FILE__).parent.parent.to_s +
                           "/locales/*.{rb,yml}")

# see http://svenfuchs.com/2009/7/19/experimental-ruby-i18n-extensions-pluralization-fallbacks-gettext-cache-and-chained-backend
module I18n::Backend::Transformers

  # this variable is a hook to allow dynamic activation/deactivation
  @@demark_enable = true

  def translate(*args)
    transform_text(super) { |entry| "⟪#{entry}⟫" }
  end

  def localize(*args)
    transform_text(super) { |entry| "⟦#{entry}⟧" }
  end

  def transform_text entry
    if @@demark_enable && entry && (entry.is_a? String)
      yield(entry)
    else
      entry
    end
  end
end

# For testing/debugging purposes, one can set the WAGN_I18N_DEMARK environment
# variable, and this will cause all translated text to include visual
# demarcation that distinguishes it from text not obtained from I18n.
#
# Enable by setting WAGN_I18N_DEMARK=1 in the host environment, or
# with ENV['WAGN_I18N_DEMARK']=1 on the command line in server startup,
# or ./config/environments/*.rb file.

if ENV["WAGN_I18N_DEMARK"]
  I18n::Backend::Simple.send(:include, I18n::Backend::Transformers)
  puts "WAGN_I18N_DEMARK is active"
end
