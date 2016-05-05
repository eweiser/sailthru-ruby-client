require 'minitest/autorun'
require 'minitest/pride'
require 'uri'
require 'json'
require 'fakeweb'

require 'sailthru'

FakeWeb.allow_net_connect = false

class Minitest::Test

  include Sailthru::Helpers

  def setup
    FakeWeb.clean_registry
  end

  def fixture_file(filename)
    return '' if filename == ''
    File.read(fixture_file_path(filename))
  end

  def fixture_file_path(filename)
    File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  end

  def sailthru_api_base_url(url)
    url
  end

  def sailthru_api_call_url(url, action)
    url += '/' if !url.end_with?('/')
    sailthru_api_base_url(url + action)
  end

  def stub_get(url, filename, headers={})
    options = { :body => fixture_file(filename), :content_type => 'application/json' }
    options.merge!(headers)
    FakeWeb.register_uri(:get, URI.parse(url), options)
  end

  def stub_delete(url, filename, headers={})
    options = { :body => fixture_file(filename), :content_type => 'application/json' }
    options.merge!(headers)
    FakeWeb.register_uri(:delete, URI.parse(url), options)
  end

  def stub_post(url, filename, headers={})
      options = { :body => fixture_file(filename), :content_type => 'application/json' }
      options.merge!(headers)
    FakeWeb.register_uri(:post, URI.parse(url), options)
  end

  def stub_exception(url, filename)
    FakeWeb.register_uri(:any, URI.parse(url), :exception => StandardError)
  end

  def create_query_string(secret, params)
    params['sig'] = get_signature_hash(params, secret)
    params.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end

  def create_json_payload(api_key, secret, params)
      data = {}
      data['api_key'] = api_key
      data['format'] = 'json'
      data['json'] = params.to_json
      data['sig'] = get_signature_hash(data, secret)
      data.map{ |key, value| "#{CGI::escape(key.to_s)}=#{CGI::escape(value.to_s)}" }.join("&")
  end

  def get_rate_info_headers(limit, remaining, reset)
      {
              :x_rate_limit_limit => limit,
              :x_rate_limit_remaining => remaining,
              :x_rate_limit_reset => reset
      }
  end

end
