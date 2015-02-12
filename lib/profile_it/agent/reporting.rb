# Methods related to sending metrics to profile_itapp.com.
module ProfileIt
  class Agent
    module Reporting

      CA_FILE     = File.join( File.dirname(__FILE__), *%w[.. .. .. data cacert.pem] )
      VERIFY_MODE = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

      def checkin_uri
        URI.parse("#{config.settings['host']}/#{config.settings['key']}/profiles/create?name=#{CGI.escape(config.settings['name'])}&rails_version=#{Rails::VERSION::STRING}&gem_version=#{ProfileIt::VERSION}&env=#{Rails.env}")
      end

      def send_profile(profile)
        uri = checkin_uri
        logger.debug "Sending profile [#{profile.uri}] to #{uri}"
        form_data = profile.to_form_data.merge({
                "profile[extension_version]" => Thread::current[:profile_it_extension_version],
                "profile[extension_fingerprint]" => Thread::current[:profile_it_extension_fingerprint],
                "profile[user_id]" => Thread::current[:profile_it_user_id]
            })
        Thread.new do
          begin
            response =  post(uri, form_data)
            if response and response.is_a?(Net::HTTPSuccess)
              logger.debug "Profile Sent [#{profile.uri}]."
            else
              logger.debug "Error sending profile [#{profile.uri}]."
            end
          rescue Exception => e
            logger.error "Exception sending profile [#{profile.uri}]: [#{e}]"
            logger.error e.backtrace.join("\n")
          end
        end
      end

      def post(url, data, headers = Hash.new)
        response = nil
        request(url) do |connection|
          post = Net::HTTP::Post.new( url.path +
                                      (url.query ? ('?' + url.query) : ''),
                                      HTTP_HEADERS.merge(headers) )
          post.set_form_data(data)

          response=connection.request(post)
        end
        response
      end

      def request(url, &connector)
        response           = nil
        response           = build_http(url).start(&connector)
        logger.debug "got response: #{response.inspect}"
        case response
        when Net::HTTPSuccess, Net::HTTPNotModified
          logger.debug "/checkin OK"
        when Net::HTTPBadRequest
          logger.warn "/checkin FAILED: The Account Key [#{config.settings['key']}] is invalid."
        else
          logger.debug "/checkin FAILED: #{response.inspect}"
        end
      rescue Exception
        logger.debug "Exception sending request to server: #{$!.message}"
      ensure
        response
      end

      # take care of http/https proxy, if specified in command line options
      # Given a blank string, the proxy_uri URI instance's host/port/user/pass will be nil
      # Net::HTTP::Proxy returns a regular Net::HTTP class if the first argument (host) is nil
      def build_http(uri)
        proxy_uri = URI.parse(config.settings['proxy'].to_s)
        http = Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.port).new(uri.host, uri.port)

        if uri.is_a?(URI::HTTPS)
          http.use_ssl = true
          http.ca_file = CA_FILE
          http.verify_mode = VERIFY_MODE
        end
        http
      end
    end # module Reporting
    include Reporting
  end # class Agent
end # module ProfileIt