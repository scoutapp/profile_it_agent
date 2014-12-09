# Methods related to sending metrics to scoutapp.com.
module ProfileIt
  class Agent
    module Reporting
     
      def checkin_uri
        URI.parse("http://#{config.settings['host']}/#{config.settings['key']}/transaction_profiles/create?name=#{CGI.escape(config.settings['name'])}")
      end

      def send_transaction(transaction)
        Thread.new do 
          begin
            response =  post( checkin_uri, transaction.to_form_data)
            if response and response.is_a?(Net::HTTPSuccess)
              logger.debug "Transaction Profile Sent."
            else
              logger.debug "Error sending transaction sample."
            end
          rescue Exception => e
            logger.error "Exception sending transaction sample: [#{e}]"
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
        response           = http(url).start(&connector)
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

      # Take care of the http proxy, if specified in config.
      # Given a blank string, the proxy_uri URI instance's host/port/user/pass will be nil.
      # Net::HTTP::Proxy returns a regular Net::HTTP class if the first argument (host) is nil.
      def http(url)
        proxy_uri = URI.parse(config.settings['proxy'].to_s)
        Net::HTTP::Proxy(proxy_uri.host,proxy_uri.port,proxy_uri.user,proxy_uri.password).new(url.host, url.port)
      end
    end # module Reporting
    include Reporting
  end # class Agent
end # module ProfileIt