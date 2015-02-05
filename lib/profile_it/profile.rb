class ProfileIt::Profile
  BACKTRACE_THRESHOLD = 0.5 # the minimum threshold to record the backtrace for a metric.
  BACKTRACE_LIMIT = 5 # Max length of callers to display
  MAX_SIZE = 100 # Limits the size of the metric hash to prevent a metric explosion.
  attr_reader :metric_name, :total_call_time, :metrics, :meta, :uri, :request_id
  
  # Given a call stack, generates a filtered backtrace that:
  # * Limits to the app/models, app/controllers, or app/views directories
  # * Limits to 5 total callers
  # * Makes the app folder the top-level folder used in trace info
  def self.backtrace_parser(backtrace)
    stack = []
    backtrace.each do |c|
      if m=c.match(/(\/app\/(controllers|models|views)\/.+)/)
        stack << m[1]
        break if stack.size == BACKTRACE_LIMIT
      end
    end
    stack
  end
  
  def initialize(uri,request_id,metric_name,total_call_time,metrics)
    @uri = uri
    @metric_name = metric_name
    @total_call_time = total_call_time
    @request_id = request_id
    @metrics = metrics
  end

  def to_form_data
    {
      "profile[uri]" => uri,
      "profile[metric_name]" => metric_name,
      "profile[total_call_time]" => total_call_time,
      "profile[id]" => request_id,
      "profile[metrics]" => Marshal.dump(metrics)
    }
  end
end