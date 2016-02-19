class WagnGenerator
  class Interactive
    def initialize options, destination_root
      @options = options
      @destination_root = destination_root
    end

    def run
      require config_path('application') # need this for Rails.env
      menu_options = ActiveSupport::OrderedHash.new
      add_config_options menu_options
      add_seed_options menu_options
      menu_options['x'] = {
        desc: "exit (run 'wagn seed' to complete the installation later)"
      }
      while (answer = ask(build_menu(menu_options))) != 'x'
        menu_options[answer][:code].call
      end
    end

    private

    def dev?
      @options['core-dev'] || @options['mod-dev']
    end

    def config_path file
      File.join destination_root, 'config', file
    end


    def bundle_exec command, opts={}
      rails_env = "RAILS_ENV=#{opts[:rails_env]}" if opts[:rails_env]
      system "cd #{destination_root} && #{rails_env} bundle exec #{command}"
    end

    def build_menu options
      lines = ['What would you like to do next?']
      lines += options.map do |key, v|
        if v[:command]
          command = ' ' * (65 - v[:desc].size) + '[' + v[:command] + ']'
        end
        "  #{key} - #{v[:desc]}#{command if command}"
      end
      lines << "[#{options.keys.join}]"
      "\n#{lines.join("\n")}\n"
    end

    def add_config_options menu_options
      menu_options['d'] = {
        desc: 'edit database configuration file',
        command: 'nano config/database.yml',
        code: proc { system "nano #{config_path 'database.yml'}" }
      }
      menu_options['c'] = {
        desc: 'configure Wagn (e.g. email settings)',
        command: 'nano config/application.rb',
        code: proc { system "nano #{config_path 'application.rb'}" }
      }
    end

    def add_seed_options menu_options
      database_seeded = proc do
        menu_options['x'][:desc] = 'exit'
        menu_options['r'] = {
          desc:    'run wagn server',
          command: 'wagn server',
          code:    proc { bundle_exec 'wagn server' }
        }
      end

      menu_options['s'] = {
        desc: "seed #{Rails.env}#{' and test' if dev?} database",
        command: 'wagn seed',
        code: proc do
          bundle_exec 'rake wagn:seed'
          bundle_exec 'rake wagn:seed', rails_env: 'test' if dev?
          database_seeded.call
        end
      }
      menu_options['a'] = {
        desc: 'seed all databases (production, development, and test)',
        command: 'wagn seed --all',
        code: proc do
          %w( production development test ).each do |env|
            bundle_exec 'rake wagn:seed', rails_env: env
          end
          database_seeded.call
        end
      }
    end

  end
end