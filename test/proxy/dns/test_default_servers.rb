require_relative "../../test_helper"

class Test::Proxy::Dns::TestDefaultServers < Minitest::Test
  include ApiUmbrellaTestHelpers::Setup
  parallelize_me!

  def setup
    super
    setup_server
  end

  def test_static_ipv4
    prepend_api_backends([
      {
        :frontend_host => "127.0.0.1",
        :backend_host => "localhost",
        :servers => [{ :host => "127.0.0.1", :port => 9444 }],
        :url_matches => [{ :frontend_prefix => "/#{unique_test_id}/ipv4/", :backend_prefix => "/hello/" }],
      },
    ]) do
      response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_id}/ipv4/", http_options)
      assert_response_code(200, response)
      assert_equal("Hello World", response.body)
    end
  end

  def test_static_ipv6
    unless IPV6_SUPPORT
      warn "Skipping test_static_ipv6 due to lack of IPv6 support."
      return skip("WARNING: Skipping test_static_ipv6 due to lack of IPv6 support.")
    end

    prepend_api_backends([
      {
        :frontend_host => "127.0.0.1",
        :backend_host => "localhost",
        :servers => [{ :host => "::1", :port => 9444 }],
        :url_matches => [{ :frontend_prefix => "/#{unique_test_id}/ipv6/", :backend_prefix => "/hello/" }],
      },
    ]) do
      response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_id}/ipv6/", http_options)
      assert_response_code(200, response)
      assert_equal("Hello World", response.body)
    end
  end

  def test_static_localhost
    prepend_api_backends([
      {
        :frontend_host => "127.0.0.1",
        :backend_host => "localhost",
        :servers => [{ :host => "localhost", :port => 9444 }],
        :url_matches => [{ :frontend_prefix => "/#{unique_test_id}/localhost/", :backend_prefix => "/hello/" }],
      },
    ]) do
      response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_id}/localhost/", http_options)
      assert_response_code(200, response)
      assert_equal("Hello World", response.body)
    end
  end

  def test_external_hostname
    prepend_api_backends([
      {
        :frontend_host => "127.0.0.1",
        :backend_host => "www.google.com",
        :servers => [{ :host => "www.google.com", :port => 80 }],
        :url_matches => [{ :frontend_prefix => "/#{unique_test_id}/valid-external-hostname/", :backend_prefix => "/" }],
      },
    ]) do
      response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_id}/valid-external-hostname/humans.txt", http_options)
      assert_response_code(200, response)
      assert_match("Google is built by a large team", response.body)
    end
  end

  def test_invalid_hostname
    prepend_api_backends([
      {
        :frontend_host => "127.0.0.1",
        :backend_host => "invalid.ooga",
        :servers => [{ :host => "invalid.ooga", :port => 90 }],
        :url_matches => [{ :frontend_prefix => "/#{unique_test_id}/invalid-hostname/", :backend_prefix => "/" }],
      },
    ]) do
      response = Typhoeus.get("http://127.0.0.1:9080/#{unique_test_id}/invalid-hostname/", http_options)
      assert_response_code(502, response)
    end
  end
end
