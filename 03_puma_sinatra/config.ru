require_relative "../shared/init.rb"

require "sinatra/base"

HTTP_STATUS_OK = 200

class Application < Sinatra::Base
  def initialize
    super
    @mutex = Mutex.new
  end

  get '/thread_safe_increment' do
    value_on_enter = $my_professional_global
    value_after_increment = nil
    @mutex.synchronize {
      value_after_increment = ($my_professional_global += 1)
    }
    value_before_response = $my_professional_global
    puts("#{Thread.current.object_id}: #{value_after_increment}")
    respond({
      value_on_enter: value_on_enter,
      counter: value_after_increment,
      value_before_response: value_before_response,
      thread: Thread.current.object_id,
    })
  end

  # I like to live on the edge,
  # so I kept the dangerous one.
  get '/thread_dangerous_increment' do
    value_on_enter = $my_professional_global
    value_after_increment = ($my_professional_global += 1)
    value_before_response = $my_professional_global
    puts("#{Thread.current.object_id}: #{value_after_increment}")
    respond({
      value_on_enter: value_on_enter,
      counter: value_after_increment,
      value_before_response: value_before_response,
      thread: Thread.current.object_id,
    })
  end

  get '/' do
    # Just a chill endpoint that absorbs what's around it.
    # There's more to life than experimentation.
    # There's more to life than fulfilling a meaningful purpose.
    # There's more to life than danger and safety.
    respond([
      Thread.current.object_id,
      "/thread_safe_increment",
      "/thread_dangerous_increment",
    ])
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
