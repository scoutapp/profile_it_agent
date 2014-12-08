# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "profile_it/version"

Gem::Specification.new do |s|
  s.name        = "profile_it"
  s.version     = ProfileIt::VERSION
  s.authors     = ["Derek Haynes",'Andre Lewis']
  s.email       = ["support@scoutapp.com"]
  s.homepage    = "https://github.com/scoutapp/profile_it"
  s.summary     = "Rails Profiler UI"
  s.description = "Profile a Ruby on Rails application in your browser and reports detailed metrics to profileit.io."

  s.rubyforge_project = "profile_it"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
