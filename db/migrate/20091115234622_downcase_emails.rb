class DowncaseEmails < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |user|
      begin
        user.status = 'system' if %w{ wagbot anon }.member?( user.login )
        user.login = nil unless %w{ wagbot anon first joe_user joe_admin joe_camel u1 u2 u3 sample_user }.member?( user.login )
        user.downcase_email!
        user.save!
      rescue
        puts "User update failed: #{user.inspect}"
      end
    end
  end

  def self.down
  end
end
