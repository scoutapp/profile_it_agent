module ProfileIt::Instruments
  # Contains ActiveRecord instrument, aliasing +ActiveRecord::ConnectionAdapters::AbstractAdapter#log+ calls
  # to trace calls to the database. 
  module ActiveRecordInstruments
    def self.included(instrumented_class)
      ProfileIt::Agent.instance.logger.debug "Instrumenting #{instrumented_class.inspect}"
      instrumented_class.class_eval do
        unless instrumented_class.method_defined?(:log_without_scout_instruments)
          alias_method :log_without_scout_instruments, :log
          alias_method :log, :log_with_scout_instruments
          protected :log
        end
      end
    end # self.included
    
    def log_with_scout_instruments(*args, &block)
      sql, name = args
      self.class.instrument(scout_ar_metric_name(sql,name), :desc => scout_sanitize_sql(sql)) do
        log_without_scout_instruments(sql, name, &block)
      end
    end
    
    def scout_ar_metric_name(sql,name)
      # sql: SELECT "places".* FROM "places"  ORDER BY "places"."position" ASC
      # name: Place Load
      if name && (parts = name.split " ") && parts.size == 2
        model = parts.first
        operation = parts.last.downcase
        metric_name = case operation
                      when 'load' then 'find'
                      when 'indexes', 'columns' then nil # not under developer control
                      when 'destroy', 'find', 'save', 'create', 'exists' then operation
                      when 'update' then 'save'
                      else
                        if model == 'Join'
                          operation
                        end
                      end
        metric = "ActiveRecord/#{model}/#{metric_name}" if metric_name
        metric = "ActiveRecord/SQL/other" if metric.nil?
      else
        metric = "ActiveRecord/SQL/Unknown"
      end
      metric
    end
    
    # Removes actual values from SQL. Used to both obfuscate the SQL and group 
    # similar queries in the UI.
    def scout_sanitize_sql(sql)
      return nil if sql.length > 1000 # safeguard - don't sanitize large SQL statements
      sql = sql.dup
      sql.gsub!(/\\"/, '') # removing escaping double quotes
      sql.gsub!(/\\'/, '') # removing escaping single quotes
      sql.gsub!(/'(?:[^']|'')*'/, '?') # removing strings (single quote)
      sql.gsub!(/"(?:[^"]|"")*"/, '?') # removing strings (double quote)
      sql.gsub!(/\b\d+\b/, '?') # removing integers
      sql.gsub!(/\?(,\?)+/,'?') # replace multiple ? w/a single ?
      sql
    end
    
  end # module ActiveRecordInstruments
end # module Instruments

def add_instruments
  if defined?(ActiveRecord) && defined?(ActiveRecord::Base)
    ActiveRecord::ConnectionAdapters::AbstractAdapter.module_eval do
      include ::ProfileIt::Instruments::ActiveRecordInstruments
      include ::ProfileIt::Tracer
    end
    ActiveRecord::Base.class_eval do
       include ::ProfileIt::Tracer
    end
  end
rescue
  ProfileIt::Agent.instance.logger.warn "ActiveRecord instrumentation exception: #{$!.message}"
end

if defined?(::Rails) && ::Rails::VERSION::MAJOR.to_i == 3
  Rails.configuration.after_initialize do
    ProfileIt::Agent.instance.logger.debug "Adding ActiveRecord instrumentation to a Rails 3 app"
    add_instruments
  end
else
  add_instruments
end