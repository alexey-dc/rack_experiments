require_relative "../shared/init.rb"

class Application

  def initialize
    $my_big_global = 0
  end

  def call(env)
    # This server is run in a single thread,
    # so there are no race conditions here.
    # Definitely...
    $my_big_global += 1


    puts("#{Thread.current.object_id}: #{$my_big_global}")

    status  = 200
    headers = { "Content-Type" => "application/json" }
    body    = [{
      thread: Thread.current.object_id,
      counter: $my_big_global
    }.to_json]

    [status, headers, body]
  end
end

run Application.new
