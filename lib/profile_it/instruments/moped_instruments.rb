if defined?(::Moped)
  ProfileIt::Agent.instance.logger.debug "Instrumenting Moped"
  Moped::Node.class_eval do
    include ProfileIt::Tracer
    def process_with_profile_it_instruments(operation, &callback)
      if operation.respond_to?(:collection)
        collection = operation.collection
        self.class.instrument("MongoDB/Process/#{collection}/#{operation.class.to_s.split('::').last}", :desc => profile_it_sanitize_log(operation.log_inspect)) do
          process_without_profile_it_instruments(operation, &callback)
        end
      end
    end
    alias_method :process_without_profile_it_instruments, :process
    alias_method :process, :process_with_profile_it_instruments
    
    # replaces values w/ ?
    def profile_it_sanitize_log(log)
      return nil if log.length > 1000 # safeguard - don't sanitize large SQL statements
      log.gsub(/(=>")((?:[^"]|"")*)"/) do 
        $1 + '?' + '"'
      end
    end
  end
end