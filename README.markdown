# ProfileIt

A Ruby gem for detailed Rails profiling analysis. Metrics are reported to [profileit.io](https://profileit.io).

## Getting Started

Install the gem:

    gem install profile_it
    
Signup for a [profileit.io](https://profileit.io) account and copy the config file to `RAILS_ROOT/config/profile_it.yml`.

Your config file should look like:

    common: &defaults
      name: YOUR_APPLICATION_NAME
      key: YOUR_APPLICATION_KEY
      profile: true

    production:
      <<: *defaults
      
## Supported Frameworks

* Rails 2.2 through Rails 4

## Supported Rubies

* Ruby 1.8.7 through Ruby 2.1.2

## Supported Application Servers

* Phusion Passenger
* Thin
* WEBrick
* Unicorn (make sure to add `preload_app true` to `config/unicorn.rb`)

## Help

Email support@profileit.io if you need a hand.
