require_relative "../shared/init.rb"

class Application
  @number_of_constructions = 0
  class << self
    def number_of_constructions=(n)
      @number_of_constructions = n
    end

    def number_of_constructions
      @number_of_constructions
    end
  end


  def initialize
    # In principle this is a bug too:
    # the intention is to initialize this once (well, who knows what I want...
    # maybe I _want_ the bug. Maybe if you want the bug,
    # the bug is not the bug, and then you don't have what you want).
    #
    # Each thread would create its own Application instance,
    # and thus would re-initialize the global value.
    # E.g. if threads get re-created often, or if
    # a request happens to get processed in just between the initialization
    # of two threads, this write would overwrite the increment from the HTTP
    # endpoint.
    #
    # E.g. placing it outside the constructor is not a solution either -
    # this entire file is run on each thread.
    # The real solution for Puma is in the next chapter.
    Application.number_of_constructions =Application.number_of_constructions + 1
    puts("Constructing Rack instance \##{Application::number_of_constructions}")
    $my_big_global = 0

  end

  def call(env)
    # This would be a bug/race condition on some Ruby VMs,
    # since in general Ruby does not guarantee
    # arithmetic thread-safety.
    $my_big_global += 1
    sleep(rand)

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


puts("RUNNING APPLICATION 000")
run Application.new
