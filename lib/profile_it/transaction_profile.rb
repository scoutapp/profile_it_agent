class ProfileIt::TransactionProfile
  BACKTRACE_THRESHOLD = 0.5 # the minimum threshold to record the backtrace for a metric.
  BACKTRACE_LIMIT = 5 # Max length of callers to display
  MAX_SIZE = 100 # Limits the size of the metric hash to prevent a metric explosion.
  attr_reader :metric_name, :total_call_time, :metrics, :meta, :uri
  
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
  
  def initialize(uri,metric_name,total_call_time,metrics)
    @uri = uri
    @metric_name = metric_name
    @total_call_time = total_call_time
    @metrics = metrics
  end
end