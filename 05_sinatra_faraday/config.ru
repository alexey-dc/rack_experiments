require_relative "../shared/init.rb"
require 'faraday'
require_relative "./lib/faraday_middleware.rb"

require "sinatra/base"

HTTP_STATUS_OK = 200

class Application < Sinatra::Base
  def initialize
    super
    @http_client = Faraday.new("http://localhost:9292/empty") do |f|
      f.use FaradayMiddleware
    end
  end

  get '/logged_in_method' do
    # Where did `env` come from?
    # This is implicit state that resembles a global:
    # It's global to Sinatra's endpoints,
    # but not available outside of sinatra
    secret = env['HTTP_SESSION_SECRET']
    response = @http_client.get("/")

    respond({
      http_response: response.body,
      secret: secret
    })
  end

  get '/empty' do
    respond({hello: :world})
  end



  error do
    content_type :json
    status 418 # I _am_ a teapot.

    e = env['sinatra.error']
    {:result => 'error', :message => e.message}.to_json
  end


  def respond(serializable)
    return [
      HTTP_STATUS_OK,
      { "Content-Type" => "application/json" },
      serializable.to_json
    ]
  end


end

run Application.new
