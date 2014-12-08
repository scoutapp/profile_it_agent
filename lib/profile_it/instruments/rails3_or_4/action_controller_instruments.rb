# Rails 3/4
module ProfileIt::Instruments
  module ActionControllerInstruments
    # Instruments the action and tracks errors.
    def process_action(*args)
      scout_controller_action = "Controller/#{controller_path}/#{action_name}"
      #ProfileIt::Agent.instance.logger.debug "Processing #{scout_controller_action}"
      self.class.trace(scout_controller_action, :uri => request.fullpath) do
        begin
          super
        rescue Exception => e
          ProfileIt::Agent.instance.store.track!("Errors/Request",1, :scope => nil)
          raise
        ensure
          Thread::current[:scout_scope_name] = nil
        end
      end
    end
  end
end

# ActionController::Base is a subclass of ActionController::Metal, so this instruments both
# standard Rails requests + Metal.
if defined?(ActionController) && defined?(ActionController::Metal)
  ProfileIt::Agent.instance.logger.debug "Instrumenting ActionController::Metal"
  ActionController::Metal.class_eval do
    include ProfileIt::Tracer
    include ::ProfileIt::Instruments::ActionControllerInstruments
  end
end

if defined?(ActionView) && defined?(ActionView::PartialRenderer)
  ProfileIt::Agent.instance.logger.debug "Instrumenting ActionView::PartialRenderer"
  ActionView::PartialRenderer.class_eval do
    include ProfileIt::Tracer
    instrument_method :render_partial, :metric_name => 'View/#{@template.virtual_path}/Rendering', :scope => true
  end
end
