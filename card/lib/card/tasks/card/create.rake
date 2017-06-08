require "colorize"

namespace :card do
  namespace :create do
    DEFAULT_RULE = { style: "*all+*style",
                     script: "*all+*script" }.freeze

    # 1. Creates a js/coffee/css/scss file with the appropriate path in
    #    the given mod.
    #    If a card with the given name exists it copies the content to that
    #    file.
    # 2. Creates a self set file that loads the code file as content
    # 3. Creates a card migration that adds the code card to the script/style
    #    rule defined by DEFAULT_RULE. Override the rule_card_name
    #    method to change it.
    # @parem mod [String] the name of the mod where the files are created
    # @param name [String] the card name
    #   A "script: " or "style: " prefix is added if missing.
    #   Whitespaces are translated to underscores for the codename.
    # @param type supported options are js, coffee, css, scss
    desc "create folders and files for scripts or styles"
    task codefile: :environment do
      with_params(:mod, :name, :type) do |mod, name, category, type, type_codename|
        create_content_file mod, name, type
        create_rb_file mod, name
        create_migration_file name, category, type_codename
      end
    end

    # shortcut for create:codefile type=scss
    desc "create folders and files for stylesheet"
    task style: :environment do
      ENV["type"] ||= "scss"
      Rake::Task["card:create:codefile"].invoke
    end

    # shortcut for create:codefile type=coffee
    desc "create folders and files for script"
    task script: :environment do
      ENV["type"] ||= "coffee"
      Rake::Task["card:create:codefile"].invoke
    end

    def create_content_file mod, name, type
      write_to_mod(mod, content_dir(type), content_filename(name, type)) do |f|
        content = (card = Card.fetch(name)) ? card.content : ""
        f.puts content
      end
    end

    def create_rb_file mod, name
      self_dir = File.join "set", "self"
      self_file = name + ".rb"
      write_to_mod(mod, self_dir, self_file) do |f|
        f.puts("include_set Abstract::CodeFile")
      end
    end

    def create_migration_file name, category, type_codename
      puts "creating migration file...".yellow
      migration_out = `bundle exec wagn generate card:migration #{name}`
      migration_file = migration_out[/db.*/]
      content = migration_content name, category, type_codename
      write_at migration_file, 5, content # 5 is line no.
    end

    def with_params *keys
      return unless parameters_present?(*keys)
      values = keys.map { |k| ENV[k.to_s] }
      mod, name, type = values
      name = remove_prefix name
      typecode = type_codename(type)
      yield mod, name, category(typecode), type, typecode
    end

    def remove_prefix name
      name.sub(/^(?:script|style):?_?\s*/, "")
    end

    def category typecode
      case typecode
      when :java_script, :coffee_script then
        :script
      when :css, :scss then
        :style
      end
    end

    def parameters_present? *env_keys
      missing = env_keys.select { |k| !ENV[k.to_s] }
      return true if missing.empty?
      missing.each do |key|
        color_puts "missing parameter:", :red, key
      end
      false
    end

    def color_puts colored_text, color, text=""
      puts "#{colored_text.send(color.to_s)} #{text}"
    end

    def write_at fname, at_line, sdat
      open(fname, "r+") do |f|
        (at_line - 1).times do # read up to the line you want to write after
          f.readline
        end
        pos = f.pos # save your position in the file
        rest = f.read # save the rest of the file
        f.seek pos # go back to the old position
        f.puts sdat # write new data & rest of file
        f.puts rest
        color_puts "created", :green, fname
      end
    end

    def write_to_mod mod, relative_dir, filename
      mod_dir = File.join "mod", mod
      dir = File.join mod_dir, relative_dir
      path = File.join dir, filename
      Dir.mkdir(dir) unless Dir.exist?(dir)
      if File.exist?(path)
        color_puts "file exists", :yellow, path
      else
        File.open(path, "w") do |opened_file|
          yield(opened_file)
          color_puts "created", :green, path
        end
      end
    end

    def type_codename type
      case type
      when "js" then
        :java_script
      when "coffee" then
        :coffee_script
      when "css", "scss" then
        type.to_sym
      else
        color_puts "'#{type}' is not a valid type. "\
                 "Please choose between js, coffee, css and scss.", :red
        exit
      end
    end

    def migration_content name, category, type_codename
      <<-RUBY
    add_#{category} "#{name}",
                type_id: #{type_id type_codename},
                to: "#{rule_card_name category}"
      RUBY
    end

    def content_dir type
      dir = case type
      when "js", "coffee" then
        "javascript"
      when "css", "scss" then
        "stylesheets"
      end
      File.join "lib", dir
    end

    def content_filename name, type
      file_ext = type == "coffee" ? ".js.coffee" : "." + type
      name + file_ext
    end

    def type_id type_codename
      "Card::#{type_codename.to_s.camelcase}ID"
    end

    def rule_card_name category
      DEFAULT_RULE[category]
    end
  end
end
