require_relative "../shared/init.rb"
require_relative "./lib/poro.rb"
require "sinatra/base"

HTTP_STATUS_OK = 200

class Application < Sinatra::Base
  def initialize
    super
  end

  before do
    Poro.kv_store[Thread.current.object_id] = env['HTTP_SESSION_SECRET']
    Poro.shared_key_store['shared_key'] = env['HTTP_SESSION_SECRET']
    puts("#{Thread.current.object_id} wrote value to shared key #{Poro.shared_key_store['shared_key']}")
    Thread.current[:env] = env
  end

  after do
    Poro.kv_store.delete Thread.current.object_id
    puts("#{Thread.current.object_id} deleting value from shared key #{Poro.shared_key_store['shared_key']}")
    Poro.shared_key_store.delete 'shared_key'
    Thread.current[:env] = nil
  end

  get '/logged_in_method' do
    secret = env['HTTP_SESSION_SECRET']
    sleep(rand)
    respond({
      kv_store: Poro.kv_store[Thread.current.object_id],
      shared_key_store: Poro.shared_key_store['shared_key'],
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
