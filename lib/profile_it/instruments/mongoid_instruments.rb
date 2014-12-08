# Mongoid versions that use Moped should instrument Moped.
if defined?(::Mongoid) and !defined?(::Moped)
  ProfileIt::Agent.instance.logger.debug "Instrumenting Mongoid"
  Mongoid::Collection.class_eval do
    include ProfileIt::Tracer
    (Mongoid::Collections::Operations::ALL - [:<<, :[]]).each do |method|
      instrument_method method, :metric_name => "MongoDB/\#{@klass}/#{method}"
    end
  end
end