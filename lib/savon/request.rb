module Savon

  # == Savon::Request
  #
  # Handles both WSDL and SOAP HTTP requests.
  class Request

    # Content-Types by SOAP version.
    ContentType = { 1 => "text/xml;charset=UTF-8", 2 => "application/soap+xml;charset=UTF-8" }

    # Whether to log HTTP requests.
    @@log = true

    # The default logger.
    @@logger = Logger.new STDOUT

    # The default log level.
    @@log_level = :debug

    # Sets whether to log HTTP requests.
    def self.log=(log)
      @@log = log
    end

    # Returns whether to log HTTP requests.
    def self.log?
      @@log
    end

    # Sets the logger.
    def self.logger=(logger)
      @@logger = logger
    end

    # Returns the logger.
    def self.logger
      @@logger
    end

    # Sets the log level.
    def self.log_level=(log_level)
      @@log_level = log_level
    end

    # Returns the log level.
    def self.log_level
      @@log_level
    end

    # Expects a SOAP +endpoint+ String. Also accepts an optional Hash
    # of +options+ for specifying a proxy server.
    def initialize(endpoint, options = {})
      @endpoint = URI endpoint
      @proxy = options[:proxy] ? URI(options[:proxy]) : URI("")
    end

    # Returns the endpoint URI.
    attr_reader :endpoint

    # Returns the proxy URI.
    attr_reader :proxy

    # Returns the HTTP headers for a SOAP request.
    def headers
      @headers ||= {}
    end

    # Sets the HTTP headers for a SOAP request.
    def headers=(headers)
      @headers = headers if headers.kind_of? Hash
    end

    # Sets the +username+ and +password+ for HTTP basic authentication.
    def basic_auth(username, password)
      @basic_auth = [username, password]
    end

    # Retrieves WSDL document and returns the Net::HTTP response.
    def wsdl
      log "Retrieving WSDL from: #{@endpoint}"
      Kernel.open(@endpoint.to_s)
    end

    # Executes a SOAP request using a given Savon::SOAP instance and
    # returns the Net::HTTP response.
    def soap(soap)
      @soap = soap
      http.endpoint @soap.endpoint.host, @soap.endpoint.port
      http.use_ssl = @soap.endpoint.ssl?

      log_request
      @response = http.start do |h|
        h.request request(:soap) { |request| request.body = @soap.to_xml }
      end
      log_response
      @response
    end

    # Returns the Net::HTTP object.
    def http
      @http ||= Net::HTTP::Proxy(@proxy.host, @proxy.port).new @endpoint.host, @endpoint.port
    end

  private

    # Logs the SOAP request.
    def log_request
      log "SOAP request: #{@soap.endpoint}"
      log soap_headers.merge(headers).map { |key, value| "#{key}: #{value}" }.join(", ")
      log @soap.to_xml
    end

    # Logs the SOAP response.
    def log_response
      log "SOAP response (status #{@response.code}):"
      log @response.body
    end

    # Returns a Net::HTTP request for a given +type+. Yields the request
    # to an optional block.
    def request(type)
      request = case type
        when :wsdl then Net::HTTP::Get.new @endpoint.request_uri
        when :soap then Net::HTTP::Post.new @soap.endpoint.request_uri, soap_headers.merge(headers)
      end

      request.basic_auth(*@basic_auth) if @basic_auth
      yield request if block_given?
      request
    end

    # Returns a Hash containing the SOAP headers for an HTTP request.
    def soap_headers
      { "Content-Type" => ContentType[@soap.version], "SOAPAction" => @soap.action }
    end

    # Logs a given +message+.
    def log(message)
      self.class.logger.send self.class.log_level, message if self.class.log?
    end

  end
end
