# 1.1.3

* Rails 4 support

# 1.1.2

* Fix for webrick detection

# 1.1.1

* Adjusting ordering of app server detection.
* Changing Passenger detection to look for ::PhusionPassenger vs. ::IN_PHUSION_PASSENGER.
* Added license

# 1.1.0

* Limiting the size of the transaction hash to 100 metrics to prevent large transaction samples.

# 1.0.9

* Rainbows! app server support.
* Removed undocumented Sinatra support.
* Limiting metric hash size to 1000 to prevent a metric explosion.

# 1.0.8

* Processing metrics when a process starts + exits to prevent losing in-memory metrics on process exit.
* Ensuring scope is nil for samplers (could be run when a process is killed before scope is reset)

# 1.0.7

* Sinatra 1.3+ compatibility (alias dispatch! instead of route_eval)
* Requiring libraries that may not be present in bare-bones Sinatra apps

# 1.0.6

* More filtering on transaction sample backtraces

# 1.0.5

* Removing duplicate Enviornment#unicorn? method 
* Removing logging when not instrumenting unscoped method (confusing - looks like an error)
* Recording ActiveRecord exists queries as MODEL#exists vs. SQL#UNKNOWN
* Handling log_level config option and defaulting to 'info' instead of 'debug'
* Not crashing the app when log file isn't writeable
* Handling the :reset directive. Resets the metric_lookup when provided.

# 1.0.4

* Added Mongo + Moped instrumentation. Mongo is used for Mongoid < 3.
* Proxy support

# 1.0.3

* MetricMeta equality - downcase
* Suppressing "cat: /proc/cpuinfo: No such file or directory" error on distros that don't support it.

# 1.0.2

* Net::HTTP instrumentation
* ActionController::Metal instrumentation
* Determining number of processors for CPU % calculation

# 1.0.1

* Unicorn support (requires "preload_app true" in unicorn config file)
* Fix for Thin detection - ensure it's actually running
* Fixing name conflict btw Tracer#store and ActiveRecord::Store

# 1.0.0

* Release!

# 0.0.6.pre

* Rails 2 - Not collecting traces when an exception occurs
* Increased Transaction Sample Storage to 2 seconds from 1 second to decrease noise in UI

# 0.0.5

* Support for custom categories
* Not raising an exception w/an unbalanced stack
* Only allows controllers as the entry point for a transaction

# 0.0.4

* Transaction Sampling

# 0.0.3.pre

* Removed dynamic ActiveRecord caller instrumentation
* Fixed issue that prevents the app from loading if ActiveRecord isn't used.
* Using a metric hash for each request, then merging when complete. Ensures data associated w/requests that overlap a 
  minute boundary are correctly associated.

# 0.0.2

* Doesn't prevent app from loading if no configuration exists for the current environment.

# 0.0.1

* Boom! Initial Release.