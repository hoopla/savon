require "basic_spec_helper"

FileList["spec/fixtures/**/*.rb"].each { |fixture| require fixture }
require "endpoint_helper"
require "http_stubs"

Spec::Runner.configure do |config|
  config.before do
    HttpStubs.stub_opens
  end
end
