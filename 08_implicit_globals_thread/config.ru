require_relative "../shared/init.rb"

require "sinatra/base"

HTTP_STATUS_OK = 200

class Application < Sinatra::Base
  def initialize
    super
  end

  before do
    Thread.current[:key] = "#{Thread.current.object_id}-#{env['HTTP_SESSION_SECRET']}+#{rand(1000)}"
    puts("Before [#{ Thread.current.object_id }] key: #{Thread.current[:key]}")
  end

  after do
    puts("After [#{ Thread.current.object_id }] key: #{Thread.current[:key]}")
  end

  get '/logged_in_method' do
    secret = env['HTTP_SESSION_SECRET']
    sleep(rand)
    respond({
      thread_current_key: Thread.current[:key],
      secret: secret,
      thread_id: Thread.current.object_id
    })
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
