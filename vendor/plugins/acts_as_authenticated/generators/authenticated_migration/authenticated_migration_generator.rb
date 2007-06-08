class AuthenticatedMigrationGenerator < Rails::Generator::NamedBase
  attr_reader :user_table_name
  def initialize(runtime_args, runtime_options = {})
    @user_table_name = (runtime_args.length < 2 ? 'users' : runtime_args[1]).tableize
    runtime_args << 'add_authenticated_table' if runtime_args.empty?
    super
  end

  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate'
    end
  end
end
