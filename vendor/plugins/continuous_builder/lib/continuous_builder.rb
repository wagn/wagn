module ContinuousBuilder
  class Build
    attr_reader :output, :success, :checkout, :status

    def initialize(options = {})
      @options  = options

      @status = Status.new(@options[:application_root] + "/log/last_build.log")

      @checkout = Checkout.new(options)
      @checkout.update!
    end
 
    def run
      previous_status = @status.recall
      
      if checkout.has_changes?
        if status = make
          @status.keep(:succesful)
          previous_status == :failed ? :revived : :succesful
        else
          @status.keep(:failed)
          previous_status == :failed ? :broken : :failed
        end
      else
        :unchanged
      end
    end
 
    private
      def make
        @output = `cd #{@options[:application_root]} && #{@options[:bin_path]}rake #{@options[:task_name]} RAILS_ENV=test`
        make_successful?
      end
      
      def make_successful?
        $?.exitstatus == 0
      end
  end
  
  class Checkout
    def initialize(path, options = {})
      @path, @options = path, options
    end

    def update!
      @status = execute("svn update")
    end

    def has_changes?
      @status =~ /[A-Z]\s+[\w\/]+/
    end

    def current_revision
      info['Revision'].to_i
    end
 
    def url
      info['URL']
    end
 
    def last_commit_message
      execute("svn log", " -rHEAD -v")
    end
 
    def last_author
      info['Last Changed Author']
    end

    private
      def info
        @info ||= YAML.load(execute("svn info"))
      end
      
      def execute(command, parameters = nil)
        `#{@options[:env_command]}#{command} #{@options[:application_root]} #{parameters}`
      end
  end

  class Status
    def initialize(path)
      @path = path
    end
    
    def keep(status)
      File.open(@path, "w+", 0777) { |file| file.write(status.to_s) }
    end
    
    def recall
      value = File.exists?(@path) ? File.read(@path) : false
      value.blank? ? false : value.to_sym
    end
  end

  class Notifier < ActionMailer::Base
    def failure(build, options, sent_at = Time.now)
      @subject = "[#{options[:application_name]}] Build broken by #{build.checkout.last_author} (##{build.checkout.current_revision})"
      @body    = [ build.checkout.last_commit_message, build.output ].join("\n\n")

      @recipients, @from, @sent_on = options[:recipients], options[:sender], sent_at
    end
    
    def broken(build, options, sent_at = Time.now)
      @subject = "[#{options[:application_name]}] Build still broken (##{build.checkout.current_revision})"
      @body    = [ build.checkout.last_commit_message, build.output ].join("\n\n")

      @recipients, @from, @sent_on = options[:recipients], options[:sender], sent_at
    end
    
    def revival(build, options, sent_at = Time.now)
      @subject = "[#{options[:application_name]}] Build fixed by #{build.checkout.last_author} (##{build.checkout.current_revision})"
      @body    = [ build.checkout.last_commit_message ].join("\n\n")

      @recipients, @from, @sent_on = options[:recipients], options[:sender], sent_at
    end
  end
end