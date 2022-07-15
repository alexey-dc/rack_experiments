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

  before do
    Thread.current[:env] = env
  end

  after do
    Thread.current[:env] = nil
  end

  get '/logged_in_method' do
    secret = env['HTTP_SESSION_SECRET']
    response = @http_client.get("/")
    sleep(rand)
    respond({
      http_response: response,
      secret: secret,
      thread_id: Thread.current.object_id
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
