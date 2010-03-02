FakeWeb.allow_net_connect = false

# Some WSDL and SOAP request.
FakeWeb.register_uri :post, EndpointHelper.soap_endpoint, :body => ResponseFixture.authentication

# WSDL and SOAP request with a Savon::SOAPFault.
FakeWeb.register_uri :post, EndpointHelper.soap_endpoint(:soap_fault), :body => ResponseFixture.soap_fault

# WSDL and SOAP request with a Savon::HTTPError.
FakeWeb.register_uri :post, EndpointHelper.soap_endpoint(:http_error), :body => "", :status => ["404", "Not Found"]

# WSDL and SOAP request with an invalid endpoint.
FakeWeb.register_uri :post, EndpointHelper.soap_endpoint(:invalid), :body => "", :status => ["404", "Not Found"]

module HttpStubs
  def self.stub_opens
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint).returns WSDLFixture.authentication
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint(:soap_fault)).returns WSDLFixture.authentication
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint(:http_error)).returns WSDLFixture.authentication
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint(:no_namespace)).returns WSDLFixture.no_namespace
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint(:invalid)).returns ""
    # WSDL request returning a WSDL document with namespaced SOAP actions.
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint(:namespaced_actions)).returns WSDLFixture.namespaced_actions
    # WSDL request returning a WSDL document with geotrust SOAP actions.
    Kernel.stubs(:open).with(EndpointHelper.wsdl_endpoint(:geotrust)).returns WSDLFixture.geotrust
  end
end
