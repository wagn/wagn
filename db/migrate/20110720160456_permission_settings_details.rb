class PermissionSettingsDetails < ActiveRecord::Migration
  def self.up
    User.as :wagbot do
      help_content = {
        :create => "Who can add cards in the [[set]].", 
        :read => "Who can view cards in the [[set]].",
        :update => "Who can edit cards in the [[set]].", 
        :delete => "Who can remove cards in the [[set]].", 
        :comment => "Who can add comments to cards in the [[set]]."
      }
    
      %w{ create read update delete comment }.each do |setting|
        set_name = "*#{setting}+*right"
      
        opts = Card.fetch_or_create("#{set_name}+*options")
        opts.typecode = 'Search'
        opts.content = '{"extension_type":"User"}'
        opts.save
      
        default = Card.fetch_or_create("#{set_name}+*default")
        default.typecode = 'Pointer'
        default.save
      
        help = Card.fetch_or_create("#{set_name}+*edit help")
        help.content = help_content[setting.to_sym]
        help.save
      end
      
      if c = Card.fetch('Setting+*self+*content') and
        (c.revisions.empty? || c.revisions.map(&:author).map(&:login).uniq == ["wagbot"])
        c.destroy
      end
    end
  end

  def self.down
  end
end
