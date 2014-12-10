if defined?(::Net) && defined?(Net::HTTP)
  ProfileIt::Agent.instance.logger.debug "Instrumenting Net::HTTP"
  Net::HTTP.class_eval do
    include ProfileIt::Tracer
    
    def request_with_profile_it_instruments(*args,&block)
      self.class.profile_it_instrument("HTTP/request", :desc => "#{(@address+args.first.path.split('?').first)[0..99]}") do
        request_without_profile_it_instruments(*args,&block)
      end
    end
    alias request_without_profile_it_instruments request
    alias request request_with_profile_it_instruments
  end
end