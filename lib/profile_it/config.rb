module ProfileIt
  class Config   
    DEFAULTS =  {
        'host' => 'profileit.io', 
        'log_level' => 'debug', # changed from info for dev
        'name' => 'LOCAL APP',
        'key' => 'DEV'
    }

    def initialize(config_path = nil)
      @config_path = config_path
    end
    
    def settings
      return @settings if @settings
      load_file
    end
    
    def config_path
      @config_path || File.join(ProfileIt::Agent.instance.environment.root,"config","profile_it.yml")
    end
    
    def config_file
      File.expand_path(config_path)
    end
    
    def load_file
      begin
        if !File.exist?(config_file)
          ProfileIt::Agent.instance.logger.warn "No config file found at [#{config_file}]."
          @settings = {}
        else
          @settings = YAML.load(ERB.new(File.read(config_file)).result(binding))[ProfileIt::Agent.instance.environment.env] || {} 
        end  
      rescue Exception => e
        ProfileIt::Agent.instance.logger.warn "Unable to load the config file."
        ProfileIt::Agent.instance.logger.warn e.message
        ProfileIt::Agent.instance.logger.warn e.backtrace
        @settings = {}
      end
      @settings = DEFAULTS.merge(@settings)
    end
  end # Config
end # ProfileIt