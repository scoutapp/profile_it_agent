module ProfileIt
end
require 'socket'
require 'set'
require 'net/http'
require 'net/https'
require 'logger'
require 'yaml'
require 'cgi'
require File.expand_path('../profile_it/version.rb', __FILE__)
require File.expand_path('../profile_it/agent.rb', __FILE__)
require File.expand_path('../profile_it/agent/logging.rb', __FILE__)
require File.expand_path('../profile_it/agent/reporting.rb', __FILE__)
require File.expand_path('../profile_it/config.rb', __FILE__)
require File.expand_path('../profile_it/environment.rb', __FILE__)
require File.expand_path('../profile_it/metric_meta.rb', __FILE__)
require File.expand_path('../profile_it/metric_stats.rb', __FILE__)
require File.expand_path('../profile_it/stack_item.rb', __FILE__)
require File.expand_path('../profile_it/store.rb', __FILE__)
require File.expand_path('../profile_it/tracer.rb', __FILE__)
require File.expand_path('../profile_it/profile.rb', __FILE__)

if defined?(Rails) and !defined?(Rails::Console)
  if Rails.respond_to?(:version) and Rails.version >= '3'
    module ProfileIt
      class Railtie < Rails::Railtie
        initializer "profile_it.start" do |app|
          ProfileIt::Agent.instance.start
        end
      end
    end
  else
    ProfileIt::Agent.instance.start
  end
end

