module ProfileIt
  # The agent gathers performance data from a Ruby application. One Agent instance is created per-Ruby process. 
  #
  # Each Agent object creates a worker thread (unless monitoring is disabled or we're forking). 
  # The worker thread wakes up every +Agent#period+, merges in-memory metrics w/those saved to disk, 
  # saves the merged data to disk, and sends it to the Scout server.
  class Agent
    # Headers passed up with all API requests.
    HTTP_HEADERS = { "Agent-Hostname" => Socket.gethostname }
    # see self.instance
    @@instance = nil 
    
    # Accessors below are for associated classes
    attr_accessor :store
    attr_accessor :config
    attr_accessor :environment
    
    attr_accessor :logger
    attr_accessor :log_file # path to the log file
    attr_accessor :options # options passed to the agent when +#start+ is called.
    attr_accessor :metric_lookup # Hash used to lookup metric ids based on their name and scope
    
    # All access to the agent is thru this class method to ensure multiple Agent instances are not initialized per-Ruby process. 
    def self.instance(options = {})
      @@instance ||= self.new(options)
    end
    
    # Note - this doesn't start instruments or the worker thread. This is handled via +#start+ as we don't 
    # want to start the worker thread or install instrumentation if (1) disabled for this environment (2) a worker thread shouldn't
    # be started (when forking).
    def initialize(options = {})
      @started = false
      @options ||= options
      @store = ProfileIt::Store.new
      @config = ProfileIt::Config.new(options[:config_path])
      @metric_lookup = Hash.new
    end
    
    def environment
      @environment ||= ProfileIt::Environment.new
    end
    
    # This is called via +ProfileIt::Agent.instance.start+ when ProfileIt is required in a Ruby application.
    # It initializes the agent and starts the worker thread (if appropiate).
    def start(options = {})
      raise "hey!!!"
      @options.merge!(options)
      init_logger
      logger.info "Attempting to start profileit.io [#{ProfileIt::VERSION}] on [#{Socket.gethostname}]"
      if !config.settings['profile'] and !@options[:force]
        logger.warn "Profiling isn't enabled for the [#{environment.env}] environment."
        return false
      elsif !environment.app_server
        logger.warn "Couldn't find a supported app server. Not starting agent."
        return false
      elsif started?
        logger.warn "Already started profileit.io."
        return false
      end
      @started = true
      logger.info "Starting profiling. Framework [#{environment.framework}] App Server [#{environment.app_server}]."
      start_instruments
      logger.info "Scout Agent [#{ProfileIt::VERSION}] Initialized"
    end
   
    def started?
      @started
    end
    
    def gem_root
      File.expand_path(File.join("..","..",".."), __FILE__)
    end
    
    # Loads the instrumention logic.
    def load_instruments
      case environment.framework
      when :rails
        require File.expand_path(File.join(File.dirname(__FILE__),'instruments/rails/action_controller_instruments.rb'))
      when :rails3_or_4
        require File.expand_path(File.join(File.dirname(__FILE__),'instruments/rails3_or_4/action_controller_instruments.rb'))
      end
      require File.expand_path(File.join(File.dirname(__FILE__),'instruments/active_record_instruments.rb'))
      require File.expand_path(File.join(File.dirname(__FILE__),'instruments/net_http.rb'))
      require File.expand_path(File.join(File.dirname(__FILE__),'instruments/moped_instruments.rb'))
      require File.expand_path(File.join(File.dirname(__FILE__),'instruments/mongoid_instruments.rb'))
    rescue
      logger.warn "Exception loading instruments:"
      logger.warn $!.message
      logger.warn $!.backtrace
    end
    
    # Injects instruments into the Ruby application.
    def start_instruments
      logger.debug "Installing instrumentation"
      load_instruments
    end
    
  end # class Agent
end # module ProfileIt