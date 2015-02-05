module ProfileIt::Instruments
  module ActionControllerInstruments
    def self.included(instrumented_class)
      ProfileIt::Agent.instance.logger.debug "Instrumenting #{instrumented_class.inspect}"
      instrumented_class.class_eval do
        unless instrumented_class.method_defined?(:perform_action_without_profile_it_instruments)
          alias_method :perform_action_without_profile_it_instruments, :perform_action
          alias_method :perform_action, :perform_action_with_profile_it_instruments
          private :perform_action
        end
      end
    end # self.included

    # In addition to instrumenting actions, this also sets the scope to the controller action name. The scope is later
    # applied to metrics recorded during this profile. This lets us associate ActiveRecord calls with 
    # specific controller actions.
    def perform_action_with_profile_it_instruments(*args, &block)
      key_from_headers = request.headers['x-profileit-key']
      if !key_from_headers.blank? && key_from_headers == ProfileIt::Agent.instance.config.settings['key']
        profile_it_controller_action = "Controller/#{controller_path}/#{action_name}"
        self.class.profile_request(profile_it_controller_action, :uri => request.request_uri) do
          perform_action_without_profile_it_instruments(*args, &block)
        end
      else
        perform_action_without_profile_it_instruments(*args, &block)
      end
    end
  end
end

if defined?(ActionController) && defined?(ActionController::Base)
  ActionController::Base.class_eval do
    include ProfileIt::Tracer
    include ::ProfileIt::Instruments::ActionControllerInstruments
  end
  ProfileIt::Agent.instance.logger.debug "Instrumenting ActionView::Template"
  ActionView::Template.class_eval do
    include ::ProfileIt::Tracer
    profile_it_instrument_method :render, :metric_name => 'View/#{path[%r{^(/.*/)?(.*)$},2]}/Rendering', :scope => true
  end
end
