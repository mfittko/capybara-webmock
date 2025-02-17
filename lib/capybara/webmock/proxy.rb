require 'rack/proxy'
require 'capybara/webmock'
require 'digest/sha1'

class Capybara::Webmock::Proxy < Rack::Proxy
  ALLOWED_HOSTS = allowed_hosts = ['127.0.0.1', 'localhost', /(.*\.|\A)lvh.me/]
  @@cache = {}

  def call(env)
    @streaming = true
    super
  end

  def perform_request(env)
    request = Rack::Request.new(env)

    if allowed_host?(request.host)
      @@cache[Digest::SHA1.hexdigest(request.env.inspect)] ||= super(env)
    else
      headers = {
        'Content-Type' => 'text/html',
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => '*',
        'Access-Control-Allow-Headers' => '*'
      }
      ['200', headers, ['']]
    end
  end

  private

  def allowed_host?(host)
    ALLOWED_HOSTS.any? do |allowed_host|
      case allowed_host
      when Regexp
        allowed_host =~ host
      when String
        allowed_host == host
      end
    end
  end
end

