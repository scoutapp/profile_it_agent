# Rails 3/4
module ProfileIt::Instruments
  module ActionControllerInstruments
    # Instruments the action and tracks errors.
    def process_action(*args)
      key_from_headers = request.headers['x-profileit-key']
      # ProfileIt::Agent.instance.logger.debug "in perform_action_with_profile_it_instruments request key = #{key_from_headers}. config key = #{ProfileIt::Agent.instance.config.settings['key']}. "
      if !key_from_headers.blank? && key_from_headers == ProfileIt::Agent.instance.config.settings['key']
        profile_it_controller_action = "Controller/#{controller_path}/#{action_name}"
        self.class.profile_request(profile_it_controller_action, :uri => request.fullpath, :request_id => request.env["action_dispatch.request_id"]) do
          begin
            super
          rescue Exception => e
            raise
          ensure
            Thread::current[:profile_it_scope_name] = nil
          end
        end
      else
        super
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
    profile_it_instrument_method :render_partial, :metric_name => 'View/#{@template.virtual_path}/Rendering', :scope => true
  end
end
