module Wagn
  include Wagn::Sets

  namespace 'Self::Accountable::Model' do
    #warn "mod accountable #{inspect}"
    def config key=nil
      @configs||={
        :group=>:other,
        :seq=>99
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::AddHelp::Model' do
    #warn "mod AHlp #{inspect}"
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>10
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Autoname::Model' do
    def config key=nil
      @configs||={
        :group=>:other,
        :seq=>97
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Captcha::Model' do
    def config key=nil
      @configs||={
        :group=>:other,
        :seq=>98
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Comment::Model' do
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>5
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Content::Model' do
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>7
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Create::Model' do
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>1
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Default::Model' do
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>6
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Delete::Model' do
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>99
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::EditHelp::Model' do
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>11
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Input::Model' do
    def config key=nil
      @configs||={
        :group=>:pointer_group,
        :seq=>19
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Layout::Model' do
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>8
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::OptionsLabel::Model' do
    def config key=nil
      @configs||={
        :group=>:pointer_group,
        :seq=>18
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Options::Model' do
    def config key=nil
      @configs||={
        :group=>:pointer_group,
        :seq=>17
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Read::Model' do
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>2
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Send::Model' do
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>12
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Sol::Model' do
    def config key=nil
      @configs||={
        :trait=>true,
        :seq=>99
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::TableOfContent::Model' do
    def config key=nil
      @configs||={
        :group=>:look,
        :seq=>9
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Thanks::Model' do
    def config key=nil
      @configs||={
        :group=>:com,
        :seq=>13
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end

  namespace 'Self::Update::Model' do
    def config key=nil
      @configs||={
        :group=>:perms,
        :seq=>3
      }
      key.nil? ? @configs : @configs[key.to_sym]
    end
  end
end
